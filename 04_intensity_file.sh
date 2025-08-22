# code to generate an intensity file, 


#!/bin/bash
set -euo pipefail

# ---- INPUT ----
BATCH="$1"  # e.g., b001

# ---- FILE PATHS ----
INTENSITY_DIR="/mnt/project/project/intensity_files_${BATCH}"
PFB_FILE="/mnt/project/PFB/pfb_${BATCH}_combined.txt"
HMM_MODEL="/mnt/project/PennCNV/PennCNV/lib/hh550.hmm"
OUT_DIR="penncnv_results_${BATCH}"
PENNCNV_DIR="/mnt/project/PennCNV/PennCNV"

# ---- CHECKS ----
if [ ! -d "$INTENSITY_DIR" ]; then
  echo "ERROR: Intensity directory not found: $INTENSITY_DIR"
  exit 1
fi

for f in "$PFB_FILE" "$HMM_MODEL" "${PENNCNV_DIR}/detect_cnv.pl"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: Missing file: $f"
    exit 1
  fi
done

mkdir -p "$OUT_DIR"

# ---- RUN PENNCNV ----
for file in ${INTENSITY_DIR}/*_intensity.txt; do
  eid=$(basename "$file" _intensity.txt)
  echo "Running PennCNV for EID $eid"

  "${PENNCNV_DIR}/detect_cnv.pl" \
    -test \
    -hmm "$HMM_MODEL" \
    -pfb "$PFB_FILE" \
    -log "$OUT_DIR/${eid}.log" \
    -out "$OUT_DIR/${eid}.rawcnv" \
    -conf "$OUT_DIR/${eid}.conf" \
    "$file"
done

echo "PennCNV complete for $BATCH"

Cancel
