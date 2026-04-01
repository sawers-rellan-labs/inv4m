#!/bin/bash
# ==============================================================================
# FIELD-ONLY PERTURBATION ANALYSIS - PSU 2022 Data Only
# ==============================================================================
#
# This script runs the consensus-based module perturbation analysis using
# ONLY PSU 2022 field data (no Crow 2020 growth chamber data).
#
# Key differences from joint perturbation pipeline:
#   - Uses only PSU 2022 field data (43 samples: 20 CTRL, 23 Inv4m)
#   - Stricter DEG filtering: FDR < 0.05 (confirmed DEGs only)
#   - No batch correction (single experiment)
#   - Same consensus + bootstrap framework
#
# Purpose: Test whether ribosome/ribonucleotide biosynthesis modules in CTRL
# are genuine or artifacts of including growth chamber samples.
#
# Steps:
#   Step 1: Data Preparation (PSU-only, no batch correction)
#   Step 2: Gene Filtering (FDR < 0.05 confirmed DEGs only)
#   Step 3: Reference Network (power fit + baseline minModuleSize)
#   Step 4: Consensus Networks (CTRL + Inv4m, N iterations each)
#   Step 5: Bootstrap Support (module stability via LFP)
#   Step 6: Preservation Analysis (consensus adjacency comparison)
#   Step 7: Module Annotation (with support metrics)
#
# Usage:
#   ./scripts/run_field_perturbation.sh [options]
#
# Options:
#   --mode MODE              Run mode: 'test' or 'production' (default: production)
#   --start N                Start from step N (1-7, default: 1)
#   --end N                  End at step N (1-7, default: 7)
#   --consensus-iterations N Consensus WGCNA iterations (default: 1000)
#   --bootstrap-iterations N Bootstrap iterations (default: 1000)
#   --permutations N         Permutations for preservation (default: 200)
#   --min-module-size N      Min module size for reference+bootstrap (default: 25)
#   --deep-split N           Deep split parameter for tree cutting (default: 4)
#   --network-type TYPE      Network type: 'signed', 'unsigned', 'signed hybrid' (default: signed)
#   --resume DIR             Resume from existing run directory
#   --skip-existing          Skip steps that have existing outputs
#   --yes                    Auto-confirm, skip interactive prompt
#
# Run Modes:
#   test:       consensus=50, bootstrap=50   (~5-10 min)
#   production: consensus=1000, bootstrap=1000 (~2-3 hours)
#
# Output Structure:
#   output/field_perturbation_YYYYMMDD_HHMMSS/
#     ├── config.yaml
#     ├── logs/
#     ├── 01_data_prep/
#     ├── 02_gene_filter/
#     ├── 03_reference_network/
#     │   ├── ctrl/
#     │   └── inv4m/
#     ├── 04_consensus_networks/
#     │   ├── ctrl/
#     │   └── inv4m/
#     ├── 05_bootstrap_support/
#     │   ├── ctrl/
#     │   └── inv4m/
#     ├── 06_preservation/
#     └── 07_module_annotation/
#
# Examples:
#   ./scripts/run_field_perturbation.sh                          # Full production run
#   ./scripts/run_field_perturbation.sh --mode test --yes        # Quick test
#   ./scripts/run_field_perturbation.sh --start 4                # From consensus networks
#   ./scripts/run_field_perturbation.sh --resume output/field_perturbation_20251231_120000
#
# ==============================================================================

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default options
MODE="production"
START_STEP=1
END_STEP=7
AUTO_CONFIRM=false
RESUME_DIR=""
SKIP_EXISTING=false

# Default iteration counts (production)
N_CONSENSUS_ITERATIONS=1000
N_BOOTSTRAP_ITERATIONS=1000
N_PERMUTATIONS=1000

# Other parameters
GENE_SUBSAMPLE_RATE=0.80
MIN_MODULE_SIZE=25  # Single minModuleSize for reference + bootstrap
MIN_MODULE_SIZE_RANGE="10,15,20,25,30,35"  # Range for consensus variability
DEEP_SPLIT=4
STABILITY_THRESHOLD_STABLE=0.70
STABILITY_THRESHOLD_MODERATE=0.50
NETWORK_TYPE="signed"  # signed, unsigned, or signed hybrid
FORCED_POWER=0       # 0 = auto-select; set to e.g. 18 to override pickSoftThreshold
LOG_FREQUENCY=50  # Log progress every N iterations
GENE_SELECTION="fdr"  # fdr (FDR < 0.05) or pvalue (P < 0.005)

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Step definitions
declare -a STEP_NAMES=(
    "Data Preparation"
    "Gene Filtering"
    "Reference Network"
    "Consensus Networks"
    "Bootstrap Support"
    "Preservation Analysis"
    "Module Annotation"
)

declare -a STEP_SCRIPTS=(
    "inversion_paper/field_perturbation/01_data_prep.Rmd"
    "inversion_paper/field_perturbation/02_gene_filter.Rmd"
    "inversion_paper/field_perturbation/03_reference_network.Rmd"
    "inversion_paper/field_perturbation/04_consensus_networks.Rmd"
    "inversion_paper/field_perturbation/05_bootstrap_support.Rmd"
    "inversion_paper/field_perturbation/06_preservation.Rmd"
    "inversion_paper/field_perturbation/07_module_annotation.Rmd"
)

declare -a STEP_OUTPUT_DIRS=(
    "01_data_prep"
    "02_gene_filter"
    "03_reference_network"
    "04_consensus_networks"
    "05_bootstrap_support"
    "06_preservation"
    "07_module_annotation"
)

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

print_header() {
    echo -e "${CYAN}"
    echo "=============================================================================="
    echo "  FIELD-ONLY PERTURBATION ANALYSIS - Consensus Networks"
    echo "  PSU 2022 Field Data Only (FDR < 0.05 DEGs)"
    echo "=============================================================================="
    echo -e "${NC}"
}

print_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --mode MODE              Run mode: 'test' or 'production' (default: production)"
    echo "  --start N                Start from step N (1-7, default: 1)"
    echo "  --end N                  End at step N (1-7, default: 7)"
    echo "  --consensus-iterations N Consensus WGCNA iterations (default: 1000)"
    echo "  --bootstrap-iterations N Bootstrap iterations (default: 1000)"
    echo "  --permutations N         Permutations for preservation (default: 200)"
    echo "  --min-module-size N      Min module size for reference+bootstrap (default: 25)"
    echo "  --deep-split N           Deep split for tree cutting (default: 4)"
    echo "  --network-type TYPE      Network type: signed, unsigned, 'signed hybrid' (default: signed)"
    echo "  --gene-selection METHOD  Gene selection: 'fdr' (FDR<0.05) or 'pvalue' (P<0.005) (default: fdr)"
    echo "  --resume DIR             Resume from existing run directory"
    echo "  --skip-existing          Skip steps that have existing outputs"
    echo "  --yes                    Auto-confirm"
    echo "  --help                   Show this help"
    echo ""
    echo "Run Modes:"
    echo "  test:       consensus=50, bootstrap=50   (~5-10 min)"
    echo "  production: consensus=1000, bootstrap=1000 (~2-3 hours)"
    echo ""
    echo "Network Types:"
    echo "  signed:        (0.5 + 0.5*cor)^power - preserves sign of correlation"
    echo "  unsigned:      |cor|^power - ignores sign, treats +/- correlation equally"
    echo "  signed hybrid: |cor|^power * sign(cor)"
    echo ""
    echo "Key differences from joint pipeline:"
    echo "  - Uses only PSU 2022 field data (43 samples)"
    echo "  - Stricter DEG filtering: FDR < 0.05 (~465 genes)"
    echo "  - No batch correction needed"
}

# Save config.yaml to run directory
save_config() {
    local config_file="$RUN_DIR/config.yaml"
    cat > "$config_file" << EOF
# Field-Only Perturbation Pipeline Configuration
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# Run directory: $RUN_DIR

# Run parameters
mode: "$MODE"
start_step: $START_STEP
end_step: $END_STEP

# Iteration counts
n_consensus_iterations: $N_CONSENSUS_ITERATIONS
n_bootstrap_iterations: $N_BOOTSTRAP_ITERATIONS
n_permutations: $N_PERMUTATIONS

# WGCNA parameters
gene_subsample_rate: $GENE_SUBSAMPLE_RATE
min_module_size: $MIN_MODULE_SIZE
min_module_size_range: "$MIN_MODULE_SIZE_RANGE"
deep_split: $DEEP_SPLIT
network_type: "$NETWORK_TYPE"

# Stability thresholds
stability_threshold_stable: $STABILITY_THRESHOLD_STABLE
stability_threshold_moderate: $STABILITY_THRESHOLD_MODERATE

# Data source
data_source: "PSU 2022 field only"
gene_selection: "$GENE_SELECTION"
deg_filter: "$([ "$GENE_SELECTION" = "fdr" ] && echo "FDR < 0.05" || echo "P < 0.005")"
batch_correction: false
EOF
    log_info "Config saved: $config_file"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ------------------------------------------------------------------------------
# Parse arguments
# ------------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --start)
            START_STEP="$2"
            shift 2
            ;;
        --end)
            END_STEP="$2"
            shift 2
            ;;
        --consensus-iterations)
            N_CONSENSUS_ITERATIONS="$2"
            shift 2
            ;;
        --bootstrap-iterations)
            N_BOOTSTRAP_ITERATIONS="$2"
            shift 2
            ;;
        --permutations)
            N_PERMUTATIONS="$2"
            shift 2
            ;;
        --min-module-size)
            MIN_MODULE_SIZE="$2"
            shift 2
            ;;
        --deep-split)
            DEEP_SPLIT="$2"
            shift 2
            ;;
        --network-type)
            NETWORK_TYPE="$2"
            shift 2
            ;;
        --gene-selection)
            GENE_SELECTION="$2"
            shift 2
            ;;
        --log-frequency)
            LOG_FREQUENCY="$2"
            shift 2
            ;;
        --resume)
            RESUME_DIR="$2"
            shift 2
            ;;
        --skip-existing)
            SKIP_EXISTING=true
            shift
            ;;
        --yes)
            AUTO_CONFIRM=true
            shift
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Apply mode settings
if [[ "$MODE" == "test" ]]; then
    N_CONSENSUS_ITERATIONS=50
    N_BOOTSTRAP_ITERATIONS=50
    N_PERMUTATIONS=50
    LOG_FREQUENCY=10  # More frequent logging in test mode
    log_info "Test mode: consensus=$N_CONSENSUS_ITERATIONS, bootstrap=$N_BOOTSTRAP_ITERATIONS, log_frequency=$LOG_FREQUENCY"
fi

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

print_header

cd "$PROJECT_ROOT"

# Create or resume run directory
if [[ -n "$RESUME_DIR" ]]; then
    if [[ ! -d "$RESUME_DIR" ]]; then
        log_error "Resume directory not found: $RESUME_DIR"
        exit 1
    fi
    RUN_DIR="$RESUME_DIR"
    log_info "Resuming from: $RUN_DIR"
else
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    RUN_DIR="results/inversion_paper/field_perturbation/run_${TIMESTAMP}"
    mkdir -p "$RUN_DIR/logs"
    log_info "Created run directory: $RUN_DIR"
    save_config
fi

# Create output subdirectories
for dir in "${STEP_OUTPUT_DIRS[@]}"; do
    mkdir -p "$RUN_DIR/$dir"
done

# Create subdirectories with ctrl/inv4m structure
mkdir -p "$RUN_DIR/03_reference_network/ctrl"
mkdir -p "$RUN_DIR/03_reference_network/inv4m"
mkdir -p "$RUN_DIR/04_consensus_networks/ctrl"
mkdir -p "$RUN_DIR/04_consensus_networks/inv4m"
mkdir -p "$RUN_DIR/05_bootstrap_support/ctrl"
mkdir -p "$RUN_DIR/05_bootstrap_support/inv4m"

# Log file
LOG_FILE="$RUN_DIR/logs/pipeline.log"

# Display configuration
echo ""
log_info "Configuration:"
log_info "  Mode: $MODE"
log_info "  Run directory: $RUN_DIR"
log_info "  Steps: $START_STEP to $END_STEP"
log_info "  Consensus iterations: $N_CONSENSUS_ITERATIONS"
log_info "  Bootstrap iterations: $N_BOOTSTRAP_ITERATIONS"
log_info "  Permutations: $N_PERMUTATIONS"
log_info "  Min module size (ref+bootstrap): $MIN_MODULE_SIZE"
log_info "  Min module size range (consensus): $MIN_MODULE_SIZE_RANGE"
log_info "  Deep split: $DEEP_SPLIT"
log_info "  Network type: $NETWORK_TYPE"
log_info "  Gene selection: $GENE_SELECTION"
log_info "  Gene subsample rate: $GENE_SUBSAMPLE_RATE"
echo ""
if [[ "$GENE_SELECTION" == "fdr" ]]; then
    log_info "Analysis type: PSU 2022 field-only (FDR < 0.05 DEGs)"
else
    log_info "Analysis type: PSU 2022 field-only (nominal P < 0.005 neighborhood)"
fi
echo ""

# Confirmation
if [[ "$AUTO_CONFIRM" != true ]]; then
    echo "Steps to run:"
    for ((i=START_STEP; i<=END_STEP; i++)); do
        echo "  Step $i: ${STEP_NAMES[$((i-1))]}"
    done
    echo ""
    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Aborted by user"
        exit 0
    fi
fi

# Run steps
for ((step=START_STEP; step<=END_STEP; step++)); do
    step_name="${STEP_NAMES[$((step-1))]}"
    step_script="${STEP_SCRIPTS[$((step-1))]}"
    step_output_dir="${STEP_OUTPUT_DIRS[$((step-1))]}"

    echo ""
    log_info "============================================"
    log_info "Step $step: $step_name"
    log_info "============================================"

    # Check if script exists
    if [[ ! -f "scripts/$step_script" ]]; then
        log_warning "Script not found: scripts/$step_script (skipping)"
        continue
    fi

    # Build params based on step
    PARAMS="run_dir='$RUN_DIR'"

    # Add step-specific params
    case $step in
        1)
            PARAMS="$PARAMS, n_permutations=$N_PERMUTATIONS"
            ;;
        2)
            PARAMS="$PARAMS, n_permutations=$N_PERMUTATIONS"
            PARAMS="$PARAMS, gene_selection='$GENE_SELECTION'"
            ;;
        3)
            # Reference network: minModuleSize + deepSplit for power fit + baseline
            PARAMS="$PARAMS, min_module_size=$MIN_MODULE_SIZE"
            PARAMS="$PARAMS, deep_split=$DEEP_SPLIT"
            PARAMS="$PARAMS, network_type='$NETWORK_TYPE'"
            PARAMS="$PARAMS, forced_power=$FORCED_POWER"
            ;;
        4)
            # Consensus networks: use params from reference network
            PARAMS="$PARAMS, n_consensus_iterations=$N_CONSENSUS_ITERATIONS"
            PARAMS="$PARAMS, gene_subsample_rate=$GENE_SUBSAMPLE_RATE"
            PARAMS="$PARAMS, min_module_size_range='$MIN_MODULE_SIZE_RANGE'"
            PARAMS="$PARAMS, deep_split=$DEEP_SPLIT"
            PARAMS="$PARAMS, network_type='$NETWORK_TYPE'"
            PARAMS="$PARAMS, log_frequency=$LOG_FREQUENCY"
            ;;
        5)
            # Bootstrap support: uses params from reference network
            PARAMS="$PARAMS, n_bootstrap_iterations=$N_BOOTSTRAP_ITERATIONS"
            PARAMS="$PARAMS, stability_threshold_stable=$STABILITY_THRESHOLD_STABLE"
            PARAMS="$PARAMS, stability_threshold_moderate=$STABILITY_THRESHOLD_MODERATE"
            PARAMS="$PARAMS, network_type='$NETWORK_TYPE'"
            PARAMS="$PARAMS, log_frequency=$LOG_FREQUENCY"
            ;;
        6|7)
            PARAMS="$PARAMS, n_permutations=$N_PERMUTATIONS"
            ;;
    esac

    # Output directory for HTML
    output_dir="$RUN_DIR/$step_output_dir"

    log_info "Running: $step_script"
    log_info "Output: $output_dir"
    log_info "Params: $PARAMS"

    # Run the Rmd script
    if Rscript -e "rmarkdown::render('scripts/$step_script', output_dir='$output_dir', params=list($PARAMS))" >> "$LOG_FILE" 2>&1; then
        log_success "Step $step completed"
    else
        log_error "Step $step failed. Check $LOG_FILE"
        log_error "Last 20 lines of log:"
        tail -20 "$LOG_FILE"
        exit 1
    fi
done

echo ""
log_success "============================================"
log_success "Pipeline completed successfully!"
log_success "============================================"
log_info "Results in: $RUN_DIR"
log_info "Log file: $LOG_FILE"
echo ""

# Print summary of outputs
log_info "Key outputs:"
log_info "  Reference network:  $RUN_DIR/03_reference_network/"
log_info "  Consensus networks: $RUN_DIR/04_consensus_networks/"
log_info "  Bootstrap support:  $RUN_DIR/05_bootstrap_support/"
log_info "  Preservation:       $RUN_DIR/06_preservation/"
log_info "  Module annotation:  $RUN_DIR/07_module_annotation/"
echo ""
log_info "Results saved to: $RUN_DIR"
log_info "Key outputs:"
log_info "  Module support: $RUN_DIR/05_bootstrap_support/ctrl/module_support.csv"
log_info "  Preservation: $RUN_DIR/06_preservation/preservation_summary.csv"
