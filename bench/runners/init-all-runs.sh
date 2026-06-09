#!/usr/bin/env bash
# Prepare all run workspaces and placeholder results metadata.
set -euo pipefail
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
for arm in baseline gsd recipe; do
  for i in 01 02 03 04 05; do
    "$BENCH_ROOT/bench/runners/prepare-run.sh" "runs/$arm/run-$i"
    RESULT="$BENCH_ROOT/results/$arm/run-$i"
    mkdir -p "$RESULT/artifact"
    if [[ ! -f "$RESULT/metadata.json" ]]; then
      python3 - <<PY
import json, pathlib
p = pathlib.Path("$RESULT/metadata.json")
p.write_text(json.dumps({
  "arm": "$arm",
  "run_id": "run-$i",
  "status": "pending",
  "live_agent": False,
}, indent=2))
PY
    fi
    if [[ ! -f "$RESULT/grade.json" ]]; then
      echo '{"pass":false,"build_ok":false,"vet_ok":false,"tests_ok":false,"tests_passed":0,"tests_total":0,"note":"not_run"}' > "$RESULT/grade.json"
    fi
  done
done
echo "All run workspaces prepared under $BENCH_ROOT/runs"
