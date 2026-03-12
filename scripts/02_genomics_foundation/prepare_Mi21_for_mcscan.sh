#!/bin/bash
#BSUB -J prep_Mi21_mcscan
#BSUB -n 1
#BSUB -R "rusage[mem=16G] span[hosts=1]"
#BSUB -W 1:00
#BSUB -o /rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly/logs/prep_Mi21_mcscan_%J.out
#BSUB -e /rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly/logs/prep_Mi21_mcscan_%J.err

set -euo pipefail

source /usr/local/apps/miniconda20240526/etc/profile.d/conda.sh
conda activate /share/maize/frodrig4/conda/env/mcscan

PROJDIR="/rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly"
export MSDIR="${PROJDIR}/microsynteny"
GFF="${PROJDIR}/liftoff/B73/Mi21_liftoff_B73.gff3"
FASTA="${PROJDIR}/ragtag/merge/ragtag.merge.fasta"

cd "${PROJDIR}"
mkdir -p "${MSDIR}"

# ============================================================================
# Step 1: Use full Liftoff GFF3 (all copies — needed to detect CNV at JMJ)
# ============================================================================
echo "=== Step 1: GFF3 feature counts ==="
echo "Total features: $(grep -c '^[^#]' ${GFF})"
echo "Primary genes (extra_copy_number=0): $(grep 'extra_copy_number=0' ${GFF} | grep -c gene)"
echo "Extra copies (extra_copy_number>0): $(grep -v 'extra_copy_number=0' ${GFF} | grep -c 'extra_copy_number=')"

# ============================================================================
# Step 2: Generate BED via jcvi
# ============================================================================
echo "=== Step 2: Generate BED ==="
python3 -m jcvi.formats.gff bed \
    --type=mRNA --key=ID \
    "${GFF}" \
    -o "${MSDIR}/Mi21.bed"

echo "Mi21 BED lines: $(wc -l < ${MSDIR}/Mi21.bed)"
echo "Sample:"
head -3 "${MSDIR}/Mi21.bed"

# ============================================================================
# Step 3: Extract CDS sequences from assembly using Liftoff GFF3
# ============================================================================
echo "=== Step 3: Extract CDS sequences ==="
python3 << 'PYEOF'
import os
import re
from collections import defaultdict
import pyfaidx

gff_file = "liftoff/B73/Mi21_liftoff_B73.gff3"
fasta_file = "ragtag/merge/ragtag.merge.fasta"
msdir = os.environ.get("MSDIR", "/rsstu/users/r/rrellan/DOE_CAREER/inv4m/assembly/microsynteny")

print("Loading FASTA index...")
fasta = pyfaidx.Fasta(fasta_file)

# Parse GFF3 directly — group CDS features by their Parent mRNA ID
# Also track mRNA strand and seqid from mRNA lines
print("Parsing GFF3...")
mrna_info = {}  # mrna_id -> (seqid, strand)
cds_by_parent = defaultdict(list)  # mrna_id -> [(seqid, start, end, strand)]

with open(gff_file) as f:
    for line in f:
        if line.startswith("#"):
            continue
        parts = line.strip().split("\t")
        if len(parts) != 9:
            continue
        seqid, source, ftype, start, end, score, strand, phase, attrs = parts
        start, end = int(start), int(end)

        # Parse attributes
        attr_dict = {}
        for a in attrs.split(";"):
            if "=" in a:
                k, v = a.split("=", 1)
                attr_dict[k] = v

        if ftype == "mRNA":
            mrna_id = attr_dict.get("ID", "")
            mrna_info[mrna_id] = (seqid, strand)

        elif ftype == "CDS":
            parent = attr_dict.get("Parent", "")
            cds_by_parent[parent].append((seqid, start, end, strand))

print(f"mRNAs found: {len(mrna_info)}")
print(f"mRNAs with CDS: {len(cds_by_parent)}")

def revcomp(seq):
    comp = str.maketrans("ACGTacgt", "TGCAtgca")
    return seq.translate(comp)[::-1]

count = 0
skipped = 0
with open(f"{msdir}/Mi21.cds", "w") as out:
    for mrna_id, (seqid, strand) in mrna_info.items():
        cds_parts = cds_by_parent.get(mrna_id, [])
        if not cds_parts:
            skipped += 1
            continue

        # Sort by genomic position
        cds_parts.sort(key=lambda x: x[1])

        # Extract and concatenate
        seq_parts = []
        ok = True
        for c_seqid, c_start, c_end, c_strand in cds_parts:
            try:
                s = str(fasta[c_seqid][c_start - 1 : c_end])
                seq_parts.append(s)
            except (KeyError, ValueError):
                ok = False
                break

        if not ok or not seq_parts:
            skipped += 1
            continue

        cds_seq = "".join(seq_parts)
        if strand == "-":
            cds_seq = revcomp(cds_seq)

        if len(cds_seq) >= 3:
            out.write(f">{mrna_id}\n{cds_seq}\n")
            count += 1
        else:
            skipped += 1

print(f"CDS extracted: {count}")
print(f"Skipped (no CDS or missing scaffold): {skipped}")
PYEOF

echo "Mi21 CDS sequences: $(grep -c '^>' ${MSDIR}/Mi21.cds)"

# ============================================================================
# Step 4: Format CDS with jcvi
# ============================================================================
echo "=== Step 4: Format CDS ==="
python3 -m jcvi.formats.fasta format "${MSDIR}/Mi21.cds" "${MSDIR}/Mi21.cds.tmp"
mv "${MSDIR}/Mi21.cds.tmp" "${MSDIR}/Mi21.cds"

# ============================================================================
# Step 5: JMJ gene check
# ============================================================================
echo ""
echo "=== JMJ gene check in Mi21 BED (all copies) ==="
echo "Zm00001eb191790 (jmj2) copies:"
grep "Zm00001eb191790" "${MSDIR}/Mi21.bed" || echo "  NOT FOUND"
echo "Zm00001eb191820 (jmj4) copies:"
grep "Zm00001eb191820" "${MSDIR}/Mi21.bed" || echo "  NOT FOUND"
echo ""
echo "=== JMJ gene check in Mi21 CDS (all copies) ==="
grep -c "Zm00001eb191790" "${MSDIR}/Mi21.cds" && echo "  Zm00001eb191790 CDS entries" || echo "  Zm00001eb191790 NOT FOUND in CDS"
grep -c "Zm00001eb191820" "${MSDIR}/Mi21.cds" && echo "  Zm00001eb191820 CDS entries" || echo "  Zm00001eb191820 NOT FOUND in CDS"

echo ""
echo "=== All JMJ cluster genes in Liftoff GFF3 ==="
echo "Searching full JMJ region genes (Zm00001eb1917* and Zm00001eb1918*):"
grep -E "Zm00001eb1917[0-9]{2}|Zm00001eb1918[0-9]{2}" "${GFF}" | grep "mRNA" | \
    awk -F'\t' '{print $1, $4, $5, $7, $9}' | sed 's/.*ID=\([^;]*\).*/\1/' | sort

echo ""
echo "=== Done ==="
echo "Output: ${MSDIR}/Mi21.bed, ${MSDIR}/Mi21.cds"
