#Code to run text file from command line
chr= #1-22, x, xy
for i in {1..106}; do
  dx run app-swiss-army-knife \
    -iin= #Text file ID \
    -icmd="bash  ${chr} ${i}" \
    --destination="/project/L2R/chr${chr}_batches" \
    --instance-type  \
    --priority  \
    -y
done

#Code for pulling the LRR data from UK Biobank, uploaded as a text file.

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

# Path to the  L2R files
path_to_l2r="/mnt/project/Bulk/Genotype Results/Genotype copy number variants, log2ratios/ukb22431_c${chr}_b0_v2.txt" 

echo "Used zipped L2R file: ${path_to_l2r}"

# Path to batch info file
batch_info="/mnt/project/batch.txt"

################
#     JOB      #
################

# Get parameters for batch i
batch=$(awk 'NR=='"$i"'{print $1}' ${batch_info} | tr -d '\r')
start=$(awk 'NR=='"$i"'{print $2}' ${batch_info} | tr -d '\r')
end=$(awk 'NR=='"$i"'{print $3}' ${batch_info} | tr -d '\r')

output_file="L2r_${batch}_chr${chr}.txt"

# Extract data
echo "Start extracting: ${batch}"
awk -v b=${start} -v e=${end} '{for (c=b; c<=e; c++) {printf("%s ", $c)} print ""}' "${path_to_l2r}" | tr ' ' '\t' > "${output_file}"

echo "Job done"
