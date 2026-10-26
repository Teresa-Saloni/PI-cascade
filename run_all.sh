#!/usr/bin/env bash
# Full pipeline. Usage:
#   bash run_all.sh quick                      # smoke test first (~20 min on a T4)
#   bash run_all.sh full                       # report numbers (~2-3 h on a T4)
#   bash run_all.sh full --set stage1_batch_size=4   # extra overrides go to every step
# Every step caches its output, so re-running continues where it stopped.
set -euo pipefail
cd "$(dirname "$0")"
PRESET=${1:-quick}
shift || true
ARGS=(--preset "$PRESET" "$@")

step () { echo; echo "================ $1 ================"; }

step "0. external repos";              bash scripts/00_setup_external.sh
step "1. datasets";                    python scripts/01_prepare_data.py "${ARGS[@]}"
step "2. Stage 1 features (GPU)";      python scripts/02_extract_features.py "${ARGS[@]}"
step "3. train probe + thresholds";    python scripts/03_train_probe.py "${ARGS[@]}"
step "4. PIGuard baseline (GPU)";      python scripts/05_piguard.py "${ARGS[@]}"
step "5. Stage 2 + KAD (GPU)";         python scripts/04_stage2.py "${ARGS[@]}"
step "6. evaluate + report";           python scripts/06_evaluate.py "${ARGS[@]}"
