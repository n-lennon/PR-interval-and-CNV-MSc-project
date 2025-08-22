#code to create a intensity file for each individual


# -------------------------------
# Step 1: Download necessary files
# -------------------------------
dx download eid
dx download baf 
dx download lrr      

# -------------------------------
# Step 2: Map EIDs to columns
# -------------------------------
awk -v batch="Batch_b001" 'BEGIN { OFS="\t" } NR > 1 && $3 == batch { print $1, ++n }' sorted_eid_positions.tsv > eid_col_map_b001.txt

# -------------------------------
# Step 3: Split mapping into chunks for faster processing
# -------------------------------
mkdir -p chunks_b001
split -l 100 eid_col_map_b001.txt chunks_b001/part_

# -------------------------------
# Step 4: Extract BAF per individual
# -------------------------------
for chunkfile in chunks_b001/part_*; do
  outdir="baf_split_b001_$(basename "$chunkfile")"
  mkdir -p "$outdir"

  cat "$chunkfile" | xargs -P 8 -n 2 bash -c '
    eid="$0"
    col="$1"
    echo "Extracting BAF for $eid (column $col)"
    tail -n +2 merged_batch_b001_sorted.txt | cut -f "$col" > "'"$outdir"'/${eid}_baf.txt"
  '
done

# -------------------------------
# Step 5: Extract LRR per individual
# -------------------------------
mkdir -p l2r_chunks_b001
split -l 100 eid_col_map_b001.txt l2r_chunks_b001/part_

for chunkfile in chunks_b001/part_*; do
  mkdir -p l2r_split_b002_$(basename "$chunkfile")
  cat "$chunkfile" | xargs -P 8 -n 2 bash -c '
    eid=$0
    col=$1
    echo "Extracting LRR for $eid (column $col)"
    tail -n +2 l2r_merged_batch_b001_sorted.txt | cut -f "$col" > l2r_split_b001_$(basename '"$chunkfile"')/${eid}_l2r.txt
  '
done

# -------------------------------
# Step 6: Create intensity files 
# -------------------------------
for baf_file in all_baf_b001/*_baf.txt; do
  eid=$(basename "$baf_file" _baf.txt"

  l2r_file="all_l2r_b001/${eid}_l2r.txt"
  
  if [ -f "$l2r_file" ]; then
    echo "Creating intensity file for $eid"
    paste pfb_b001_combined.txt "$baf_file" "$l2r_file" > intensity_files_b001/${eid}_intensity.txt
  else
    echo "Warning: LRR file not found for $eid"
  fi
done


