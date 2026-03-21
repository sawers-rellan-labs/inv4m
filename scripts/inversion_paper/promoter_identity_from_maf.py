#!/usr/bin/env python3
"""
Extract percent identity in genomic windows from a MAF file.

Usage:
    python3 promoter_identity_from_maf.py <maf_file> <bed_file> <output_csv>

The BED file has: chrom, start, end, gene_id
The MAF file is filtered to alignment blocks overlapping the BED intervals.
For each BED interval, identity = matches / aligned_bases across all overlapping
MAF blocks.
"""

import sys
import csv
from collections import defaultdict


def parse_maf_chr4(maf_path):
    """Yield (ref_chrom, ref_start, ref_end, ref_seq, qry_seq) for chr4 blocks."""
    with open(maf_path) as f:
        block = []
        for line in f:
            if line.startswith("a"):
                block = []
            elif line.startswith("s"):
                block.append(line.strip().split())
                if len(block) == 2:
                    ref_name = block[0][1]
                    if ref_name == "chr4":
                        ref_start = int(block[0][2])
                        ref_len = int(block[0][3])
                        ref_seq = block[0][6]
                        qry_seq = block[1][6]
                        yield ref_start, ref_start + ref_len, ref_seq, qry_seq


def compute_identity_in_window(ref_start, ref_seq, qry_seq, win_start, win_end):
    """Count matches and aligned bases within [win_start, win_end) from a MAF block."""
    matches = 0
    aligned = 0
    ref_pos = ref_start

    for r, q in zip(ref_seq, qry_seq):
        if r == "-":
            # insertion in query, ref position doesn't advance
            continue
        if win_start <= ref_pos < win_end:
            if q != "-":
                aligned += 1
                if r.upper() == q.upper():
                    matches += 1
        ref_pos += 1
        if ref_pos >= win_end:
            break

    return matches, aligned


def main():
    maf_file = sys.argv[1]
    bed_file = sys.argv[2]
    output_file = sys.argv[3]

    # Load BED windows
    windows = []
    with open(bed_file) as f:
        for row in csv.reader(f, delimiter="\t"):
            windows.append((int(row[1]), int(row[2]), row[3]))  # start, end, gene

    # Sort windows for efficient scanning
    windows.sort()

    # Track per-gene counts
    gene_matches = defaultdict(int)
    gene_aligned = defaultdict(int)

    # Min/max for quick block filtering
    min_win = windows[0][0]
    max_win = windows[-1][1]

    print(f"Processing {len(windows)} windows in chr4:{min_win}-{max_win}", file=sys.stderr)

    n_blocks = 0
    for ref_start, ref_end, ref_seq, qry_seq in parse_maf_chr4(maf_file):
        # Skip blocks outside our region of interest
        if ref_end < min_win or ref_start > max_win:
            continue

        n_blocks += 1
        for win_start, win_end, gene_id in windows:
            # Check overlap
            if ref_end <= win_start or ref_start >= win_end:
                continue
            m, a = compute_identity_in_window(ref_start, ref_seq, qry_seq,
                                               win_start, win_end)
            gene_matches[gene_id] += m
            gene_aligned[gene_id] += a

    print(f"Processed {n_blocks} chr4 MAF blocks", file=sys.stderr)

    # Write output
    with open(output_file, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["gene", "promoter_matches", "promoter_aligned",
                         "promoter_pct_identity"])
        for win_start, win_end, gene_id in windows:
            m = gene_matches[gene_id]
            a = gene_aligned[gene_id]
            pct = round(100 * m / a, 4) if a > 0 else None
            writer.writerow([gene_id, m, a, pct])


if __name__ == "__main__":
    main()
