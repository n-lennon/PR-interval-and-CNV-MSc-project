import pandas as pd
import pyranges as pr

# Step 1
hr_df = pd.read_csv('RHR_untrans_noBB_boundaries_300323.txt', sep=r'\s+', header=None, names=['CHR', 'START', 'END', 'LENGTH', 'LOCUS_ID'])
hr_df['CHR'] = hr_df['CHR'].astype(str)
hr_df['START'] = hr_df['START'].astype(int)
hr_df['END'] = hr_df['END'].astype(int)

hr_ranges = pr.PyRanges(pd.DataFrame({
    'Chromosome': hr_df['CHR'],
    'Start': hr_df['START'],
    'End': hr_df['END'],
    'Locus_ID': hr_df['LOCUS_ID']
}))

print(hr_df.head())
hr_df.to_csv('step1_hr_loci.csv', index=False)

# Step 2
pr_df = pd.read_excel('Previously reported loci PR loci.xlsx')
pr_df['CHR'] = pr_df['CHR'].astype(str)


print(pr_df.columns)  


pr_df['POS'] = pr_df['POS'].astype(int)

pr_ranges = pr.PyRanges(pd.DataFrame({
    'Chromosome': pr_df['CHR'],
    'Start': pr_df['POS'],
    'End': pr_df['POS'] + 1,
    'Gene': pr_df['Nearest reported gene'],
    'rsID': pr_df['rsID']
}))
print (len(pr_df))
# Step 3
overlapping_pr_hr = pr_ranges.join(hr_ranges)

print(f"Number of overlap: {len(overlapping_pr_hr)}")
overlapping_pr_hr.df.to_csv('step3_overlapping_pr_hr.csv', index=False)

# STEP 4
hr_overlap_regions = overlapping_pr_hr.df[['Chromosome', 'Start_b', 'End_b']].drop_duplicates()
hr_overlap_regions.columns = ['Chromosome', 'Start', 'End']

hr_overlap_regions.to_csv('step4_hr_overlap_regions.csv', index=False)

overlap_ranges = pr.PyRanges(hr_overlap_regions)
# STEP 5
cnv_df = pd.read_csv('SD1_Auwerx_2021_CNV_Frequency_UKBB.txt', sep='\t', low_memory=False)
cnv_df['CHR'] = cnv_df['CHR'].astype(str)
cnv_df['POS'] = cnv_df['POS'].astype(int)

print(cnv_df.head())

cnv_ranges = pr.PyRanges(pd.DataFrame({
    'Chromosome': cnv_df['CHR'],
    'Start': cnv_df['POS'],
    'End': cnv_df['POS'] + 1,
    'ID': cnv_df['ID'],
    'FreqCNV': cnv_df['FreqCNV']
}))

cnv_in_overlap = cnv_ranges.join(overlap_ranges)


cnv_in_overlap.df.to_csv('step5_cnvs_in_overlap.csv', index=False)

# STEP 6
gwas_df = pd.read_csv('GCST90027357_buildGRCh37.tsv', sep='\t')
gwas_df['base_pair_location'] = gwas_df['base_pair_location'].astype(int)
gwas_df['chromosome'] = gwas_df['chromosome'].astype(str)

print(gwas_df.head())

# STEP 7
cnv_ids = set(cnv_in_overlap.df['ID'])
gwas_ids = set(gwas_df['variant_id'])
common_ids = cnv_ids.intersection(gwas_ids)

filtered_cnv = cnv_in_overlap.df[cnv_in_overlap.df['ID'].isin(common_ids)]

merged_results = pd.merge(
    filtered_cnv,
    gwas_df,
    left_on='ID',
    right_on='variant_id',
    how='left'
)

print(merged_results.head())

merged_results.to_csv('step7_merged_cnv_gwas.csv', index=False)

# STEP 8
num_tests = merged_results['p_value'].notnull().sum()
bonferroni = 0.05 / num_tests if num_tests > 0 else None

merged_results['Significant'] = False
if bonferroni is not None:
    merged_results['Significant'] = merged_results['p_value'] < bonferroni

print(f"\n Number of tests: {num_tests}")
print(f"Bonferroni : {bonferroni if bonferroni is not None else 'N/A'}")
print(f"significant CNVs: {merged_results['Significant'].sum()}")

merged_results.to_csv('step8_final_results.csv', index=False)

!pip install matplotlib

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# to generate Figure 3

df = pd.read_csv("step8_final_results.csv")
df = df.dropna(subset=["p_value"])
df = df.sort_values("p_value")


plt.figure(figsize=(10, 5))
plt.scatter(range(len(df)), -np.log10(df["p_value"]), color="navy", s=20)
plt.axhline(-np.log10(0.05 / len(df)), color="red", linestyle="--", label="Bonferroni threshold")

plt.xlabel("CNV Rank", fontsize=12)
plt.ylabel("-log10(p-value)", fontsize=12)
plt.legend()
plt.tight_layout()

plt.show()

#to generate Table 1

loci_per_chr = hr_df.groupby("CHR").size().reset_index(name="Count")
print(loci_per_chr)

#to generate table 2
prloci_per_chr = pr_df.groupby("CHR").size().reset_index(name="Count")
print(prloci_per_chr)

#to generate table 3

import pandas as pd

merged_results = pd.read_csv("step7_merged_cnv_gwas.csv")

merged_results = merged_results.dropna(subset=["p_value"])

merged_sorted = merged_results.sort_values("p_value")

top5_table = merged_sorted[["ID", "Chromosome", "Start", "beta", "p_value"]].head(5)

top5_table.to_csv("Table3_top5_CNVs_uncorrected.csv", index=False)

print(top5_table)

