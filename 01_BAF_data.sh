#Code to run text file from command line
chr= #1-22, x, xy
for i in {1..106}; do
  dx run app-swiss-army-knife \
    -iin= #FILE ID \
    -icmd="bash chr_batches.sh ${chr} ${i}" \
    --destination="/project/chr${chr}_batches" \
    --instance-type mem1_ssd1_v2_x2 \
    --priority normal \
    -y
done

#Code for pulling the BAF data from UK Biobank, upload as a text file to UK Biobank project and use code above to run.

#!/bin/bash

# Check input
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <chr> <batch_number>"
  exit 1
fi

chr=$1
i=$2

################
#  VARIABLES   #
################

# Path to the zipped BAF files
path_to_baf="/mnt/project/Bulk/Genotype Results/Genotype copy number variants B-allele frequencies/ukb22437_c${chr}_b0_v2.txt"
echo "Used zipped BAF file: ${path_to_baf}"

# Path to batch info file
batch_info="/mnt/project/batch.txt"

################
#     JOB      #
################

# Get parameters for batch i
batch=$(awk 'NR=='"$i"'{print $1}' ${batch_info} | tr -d '\r')
start=$(awk 'NR=='"$i"'{print $2}' ${batch_info} | tr -d '\r')
end=$(awk 'NR=='"$i"'{print $3}' ${batch_info} | tr -d '\r')

output_file="Batch_${batch}_chr${chr}.txt"

# Extract data
echo "Start extracting: ${batch}"
awk -v b=${start} -v e=${end} '{for (c=b; c<=e; c++) {printf("%s ", $c)} print ""}' "${path_to_baf}" | tr ' ' '\t' > "${output_file}"

echo "Job done"
Cancel
