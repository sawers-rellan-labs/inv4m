#!/usr/bin/env python3
"""
For each bQTL position, check the B73-vs-Mi21 MAF alignment for a mismatch.
Output per-gene counts of bQTL total and bQTL mismatches.

Usage:
    python3 bqtl_mismatches_from_maf.py <maf_file> <bqtl_bed> <output_csv>

bqtl_bed format: chr4 <start> <end> <gene_id> <bqtl_pos>
  (one row per bQTL, with the gene it's assigned to)
"""

import sys
import csv
from collections import defaultdict


def parse_maf_chr4(maf_path):
    """Yield (ref_start, ref_end, ref_seq, qry_seq) for chr4 blocks."""
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


def query_base_at_pos(ref_start, ref_seq, qry_seq, target_pos):
    """Return (ref_base, qry_base) at a specific reference position, or None."""
    ref_pos = ref_start
    for r, q in zip(ref_seq, qry_seq):
        if r == "-":
            continue
        if ref_pos == target_pos:
            return r.upper(), q.upper()
        ref_pos += 1
        if ref_pos > target_pos:
            break
    return None


def main():
    maf_file = sys.argv[1]
    bqtl_bed = sys.argv[2]
    output_file = sys.argv[3]

    # Load bQTL: gene -> list of positions
    gene_bqtl = defaultdict(list)
    with open(bqtl_bed) as f:
        for row in csv.reader(f, delimiter="\t"):
            gene = row[3]
            pos = int(row[4])
            gene_bqtl[gene].append(pos)

    # Collect all unique positions to query
    all_positions = set()
    for positions in gene_bqtl.values():
        all_positions.update(positions)

    all_positions = sorted(all_positions)
    min_pos = all_positions[0]
    max_pos = all_positions[-1]
    pos_set = set(all_positions)

    print(f"Querying {len(all_positions)} bQTL positions across {len(gene_bqtl)} genes",
          file=sys.stderr)

    # Scan MAF and record base calls at bQTL positions
    base_calls = {}  # pos -> (ref, qry)
    n_blocks = 0
    for ref_start, ref_end, ref_seq, qry_seq in parse_maf_chr4(maf_file):
        if ref_end < min_pos or ref_start > max_pos:
            continue
        n_blocks += 1
        # Check each bQTL position that falls in this block
        for p in all_positions:
            if p < ref_start or p >= ref_end:
                continue
            if p in base_calls:
                continue
            result = query_base_at_pos(ref_start, ref_seq, qry_seq, p)
            if result:
                base_calls[p] = result

    print(f"Processed {n_blocks} MAF blocks, resolved {len(base_calls)}/{len(all_positions)} positions",
          file=sys.stderr)

    # Tally per gene
    with open(output_file, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["gene", "n_bqtl", "n_aligned", "n_mismatch", "n_match",
                         "n_gap", "bqtl_mismatch_rate"])
        for gene in sorted(gene_bqtl.keys()):
            positions = gene_bqtl[gene]
            n_bqtl = len(positions)
            n_aligned = 0
            n_mismatch = 0
            n_match = 0
            n_gap = 0
            for p in positions:
                if p in base_calls:
                    ref_b, qry_b = base_calls[p]
                    if qry_b == "-":
                        n_gap += 1
                    else:
                        n_aligned += 1
                        if ref_b != qry_b:
                            n_mismatch += 1
                        else:
                            n_match += 1
            rate = round(n_mismatch / n_aligned, 4) if n_aligned > 0 else None
            writer.writerow([gene, n_bqtl, n_aligned, n_mismatch, n_match,
                             n_gap, rate])


if __name__ == "__main__":
    main()
