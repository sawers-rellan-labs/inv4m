#!/usr/bin/env bash
set -euo pipefail

# Fetch the three required files from the Wang 2020 Zenodo deposit
# (10.5281/zenodo.2611319) into data/zenodo/. Idempotent: skips files
# already present at expected size. Write-protects data/ on success.
#
# We pull only what the pipeline needs:
#   - F1maize.FINAL.fasta              (collapsed transcripts, for BLAST)
#   - F1maize.FINAL.gff                (transcript GFF on v4, for intersect)
#   - F1maize.FINAL.demux_FL_count.txt (per-sample FL count matrix)
# The two INTERMEDIATE.*.fastq.gz files (~8 GB combined) and the protein .faa
# are NOT needed for the falsifier and are skipped.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/data/zenodo"
mkdir -p "$DEST"

REC_BASE="https://zenodo.org/api/records/2611319/files"

fetch() {
  local name="$1" expected="$2"
  local out="$DEST/$name"
  if [[ -f "$out" ]]; then
    local got
    got=$(stat -f%z "$out" 2>/dev/null || stat -c%s "$out")
    if [[ "$got" == "$expected" ]]; then
      echo "skip (already $expected bytes): $name"
      return
    fi
    echo "re-fetching (size $got != $expected): $name"
    rm -f "$out"
  fi
  echo "fetching: $name"
  curl -L --fail --progress-bar -o "$out" "$REC_BASE/$name/content"
}

fetch F1maize.FINAL.demux_FL_count.txt 2653173
fetch F1maize.FINAL.gff                59650292
fetch F1maize.FINAL.fasta             187170721

echo
echo "Zenodo deposit files:"
ls -la "$DEST"

# Write-protect fetched data. Run only after a successful, complete fetch.
chmod -R a-w "$ROOT/data/zenodo" "$ROOT/data/supp" 2>/dev/null || true
echo "data/zenodo and data/supp are now write-protected."
