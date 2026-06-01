#!/usr/bin/env bash
set -euo pipefail

# BLAST the 5 split-paralog CDS queries against the F1maize collapsed transcripts.
# For each query, report best-hit PB.X.Y (with pident, qcovhsp) and confirm
# coordinate overlap with the cluster via the PB.X group set from script 03.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
QUERY="$ROOT/data/queries/jmj_5_paralog_queries.fasta"
DB_FASTA="$ROOT/data/zenodo/F1maize.FINAL.fasta"
OUT_DIR="$ROOT/results/intermediate"
TABLES="$ROOT/results/tables"
mkdir -p "$OUT_DIR" "$TABLES"

DB_DIR="$OUT_DIR/blastdb"
DB="$DB_DIR/F1maize.FINAL"
mkdir -p "$DB_DIR"

# Build DB (idempotent: skip if .nsq already present).
if [[ ! -s "${DB}.nsq" ]]; then
  echo "Building BLAST DB..."
  makeblastdb -in "$DB_FASTA" -dbtype nucl -out "$DB" -parse_seqids >/dev/null
fi

RAW="$OUT_DIR/blast_paralogs_raw.tsv"
echo -e "qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tqcovhsp\tqlen\tslen" > "$RAW"
blastn \
  -query "$QUERY" \
  -db "$DB" \
  -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovhsp qlen slen' \
  -evalue 1e-30 \
  -max_target_seqs 20 \
  -num_threads 4 \
  >> "$RAW"

# PB.X groups inside the cluster (from script 03).
CLUSTER_PBX="$OUT_DIR/cluster_PBX_groups.txt"
[[ -s "$CLUSTER_PBX" ]] || { echo "Run script 03 first (cluster PB.X list missing)." >&2; exit 1; }

# Best-hit per query: highest bitscore; flag whether subject's PB.X is in the cluster set.
BEST="$TABLES/04_paralog_best_hit.tsv"
awk -v cluster_file="$CLUSTER_PBX" -F'\t' '
BEGIN{ while ((getline l < cluster_file) > 0) cluster[l]=1; OFS="\t" }
NR==1 { print $0, "PB_X", "in_cluster"; next }
{
  pbx=$2; sub(/\..*\..*/,"",pbx); sub(/(\.[0-9]+)$/,"",pbx);
  # PB.X.Y -> strip trailing .Y to get PB.X
  s=$2; n=split(s,a,"."); pbx=a[1]"."a[2];
  inc = (pbx in cluster) ? "yes" : "no";
  if (best_score[$1] == "" || $12+0 > best_score[$1]+0) {
    best_score[$1] = $12;
    best_line[$1]  = $0 OFS pbx OFS inc;
  }
}
END {
  print "qseqid","sseqid","pident","length","mismatch","gapopen","qstart","qend","sstart","send","evalue","bitscore","qcovhsp","qlen","slen","PB_X","in_cluster";
  for (q in best_line) print best_line[q];
}' "$RAW" > "$BEST"

# Per-query: all hits whose PB.X is in the cluster, ranked by bitscore.
ALL_IN_CLUSTER="$TABLES/04_paralog_cluster_hits.tsv"
awk -v cluster_file="$CLUSTER_PBX" -F'\t' '
BEGIN{ while ((getline l < cluster_file) > 0) cluster[l]=1; OFS="\t" }
NR==1 { print $0, "PB_X"; next }
{ n=split($2,a,"."); pbx=a[1]"."a[2]; if (pbx in cluster) print $0, pbx }
' "$RAW" | sort -k1,1 -k12,12gr > "$ALL_IN_CLUSTER"

echo
echo "Best-hit per paralog query -> $BEST"
column -ts $'\t' "$BEST" | cut -c1-200
echo
echo "All cluster-mapped hits -> $ALL_IN_CLUSTER"
wc -l "$ALL_IN_CLUSTER"
