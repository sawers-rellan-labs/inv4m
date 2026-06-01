#!/usr/bin/env bash
set -euo pipefail

# Count distinct v4 gene models inside the JMJ cluster region.
# Uses the bundled GFF3 subset (data/queries/jmj_cluster_region_v4.gff3) and
# the cluster BED (data/queries/jmj_cluster_region_v4.bed). No external fetch.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GFF="$ROOT/data/queries/jmj_cluster_region_v4.gff3"
REGION_BED="$ROOT/data/queries/jmj_cluster_region_v4.bed"
OUT_DIR="$ROOT/results/intermediate"
TABLES="$ROOT/results/tables"
mkdir -p "$OUT_DIR" "$TABLES"

read -r CHR START END _ < "$REGION_BED"

awk -v OFS='\t' -F'\t' '$3=="gene"{
  id=$9; sub(/.*gene_id=/,"",id); sub(/;.*/,"",id);
  print $1, $4-1, $5, id, ".", $7
}' "$GFF" > "$OUT_DIR/_v4_all_genes.bed"

bedtools intersect \
  -a "$OUT_DIR/_v4_all_genes.bed" \
  -b "$REGION_BED" -u \
  > "$OUT_DIR/v4_genes_in_region.bed"

N=$(wc -l < "$OUT_DIR/v4_genes_in_region.bed" | tr -d ' ')

{
  echo -e "metric\tvalue"
  echo -e "v4_genes_in_cluster\t$N"
  echo -e "cluster_region\t${CHR}:${START}-${END}"
} > "$TABLES/01_v4_gene_count.tsv"

echo "v4 gene models in cluster (${CHR}:${START}-${END}): $N"
cut -f4 "$OUT_DIR/v4_genes_in_region.bed"
