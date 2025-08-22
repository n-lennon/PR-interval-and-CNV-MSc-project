#Code to run text file from command line

for baf_file in /project/path_to_baf_files/*_baf.txt; do
  dx run app-swiss-army-knife \
    -iin= # FILE ID \
    -icmd="bash generate_pfb.sh ${baf_file} /project/path_to/probes.txt /project/output_folder" \
    --destination="/project/PFB_output" \
    --instance-type mem1_ssd1_v2_x2 \
    --priority normal \
    -y
done

#Code for pulling the probe data from UK Biobank, upload as a text file to UK Biobank project and use code above to run.

#!/bin/bash

baf_file=$1
probe_info_file=$2
output_folder=$3

# Extract batch name
batch=$(basename ${baf_file} | cut -d "_" -f1)

# Output file paths
temp_pfb_output="${output_folder}/${batch}_pfb_temp.txt"
final_pfb_output="${output_folder}/${batch}_pfb.txt"

echo "Processing batch: ${batch}"

# Calculate PFB: mean BAF value per SNP across samples
awk '{sum=cnt=0; for (i=1;i<=NF;i++) if ($i != "NA") { sum+=$i; cnt++ } print (cnt ? sum/cnt : "NA") }' ${baf_file} | sed '1 i\PFB' > ${temp_pfb_output}

# Check row counts
lines_probe=$(wc -l < "${probe_info_file}")
lines_temp_pfb=$(wc -l < "${temp_pfb_output}")

echo "Probe info lines: ${lines_probe}, PFB values lines: ${lines_temp_pfb}"

# Combine probe info and PFB values
paste ${probe_info_file} ${temp_pfb_output} | grep -vw NA > ${final_pfb_output}

# Clean up temp file
rm ${temp_pfb_output}

echo "PFB file created: ${final_pfb_output}"
