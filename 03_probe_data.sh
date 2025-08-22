
#code to pull probe data 

batch_file=$1

# Path to probe info file 
probe_info="/mnt/project/project/merged_probes_selected_chrs.bim"

# Output directory for PFB files 
output_dir="/project/pfb_files"
mkdir -p "$output_dir"

# Extract batch name 
batch_name=$(basename "$batch_file" | sed 's/merged_batch_\(.*\)_sorted.txt/\1/')

# Calculate mean BAF per line 
awk '{
  sum=0; count=0;
  for (i=1; i<=NF; i++) {
    if ($i != "NA") {
      sum+=$i; count++
    }
  }
  if (count > 0) {
    printf "%.4f\n", sum/count
  } else {
    print "NA"
  }
}' "$batch_file" > "$output_dir/${batch_name}_pfb.txt"

echo "Generated PFB file for ${batch_name}."
