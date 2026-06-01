#!/usr/bin/env bash
set -euo pipefail

# Intersect the Wang 2020 collapsed-transcript GFF (on v4 coords) with the
# v4 cluster BED. Count distinct PB.X gene groups overlapping the cluster.
# That count is the falsifier of the "one-locus alt-isoforms" hypothesis.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GFF="$ROOT/data/zenodo/F1maize.FINAL.gff"
REGION_BED="$ROOT/data/queries/jmj_cluster_region_v4.bed"
OUT_DIR="$ROOT/results/intermediate"
TABLES="$ROOT/results/tables"
mkdir -p "$OUT_DIR" "$TABLES"

# Wang GFF uses "chrN"; bundled BED uses "N". Build chr-prefixed BED for intersect.
REGION_CHR_BED="$OUT_DIR/jmj_cluster_region_v4.chr.bed"
awk -v OFS='\t' '{ if ($1 !~ /^chr/) $1="chr"$1; print }' "$REGION_BED" > "$REGION_CHR_BED"

# Pull the per-transcript records and turn them into a BED of (chr, start-1, end, transcript_id, gene_id, strand).
TR_BED="$OUT_DIR/F1maize.transcripts.bed"
awk -v OFS='\t' -F'\t' '$3=="transcript"{
  gid=$9; sub(/.*gene_id "/,"",gid); sub(/".*/,"",gid);
  tid=$9; sub(/.*transcript_id "/,"",tid); sub(/".*/,"",tid);
  print $1, $4-1, $5, tid, gid, $7
}' "$GFF" > "$TR_BED"

# Intersect: transcripts whose mapped span overlaps the cluster region.
HIT_BED="$OUT_DIR/cluster_transcripts.bed"
bedtools intersect -a "$TR_BED" -b "$REGION_CHR_BED" -u > "$HIT_BED"

N_TX=$(wc -l < "$HIT_BED" | tr -d ' ')
N_PBX=$(cut -f5 "$HIT_BED" | sort -u | wc -l | tr -d ' ')

# Per-PB.X summary
cut -f5 "$HIT_BED" | sort -u > "$OUT_DIR/cluster_PBX_groups.txt"
awk -v OFS='\t' 'BEGIN{print "PB_X","n_isoforms","min_start","max_end","strands"}
{
  g=$5; n[g]++;
  if (s[g]=="" || $2<s[g]) s[g]=$2;
  if (e[g]=="" || $3>e[g]) e[g]=$3;
  st[g] = (st[g]=="" ? $6 : (index(st[g],$6) ? st[g] : st[g]","$6));
}
END{ for (g in n) print g, n[g], s[g]+1, e[g], st[g] }' "$HIT_BED" \
  | (read -r hdr; echo "$hdr"; sort -k3,3n) > "$TABLES/03_PBX_groups_at_cluster.tsv"

{
  echo -e "metric\tvalue"
  echo -e "n_transcripts_overlapping_cluster\t$N_TX"
  echo -e "n_distinct_PB_X_groups\t$N_PBX"
} > "$TABLES/03_PBX_count.tsv"

echo "Transcripts overlapping cluster: $N_TX"
echo "Distinct PB.X groups at cluster: $N_PBX"
echo
echo "Per-group summary -> $TABLES/03_PBX_groups_at_cluster.tsv"
column -ts $'\t' "$TABLES/03_PBX_groups_at_cluster.tsv"
