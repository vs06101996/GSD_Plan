#!/usr/bin/env bash
# Merge hand-captured phase metrics into results/<arm>/run-NN/metadata.json
# Usage: ./bench/runners/log-phase-metrics.sh <arm> <run-id> <metrics.json>
set -euo pipefail
ARM="${1:?baseline|gsd|recipe}"
RUN_ID="${2:?run-01}"
METRICS="${3:?path to phase-metrics JSON}"
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RESULT="$BENCH_ROOT/results/$ARM/$RUN_ID"
META="$RESULT/metadata.json"

mkdir -p "$RESULT"
if [[ ! -f "$META" ]]; then
  echo '{"arm":"'"$ARM"'","run_id":"'"$RUN_ID"'","status":"in_progress"}' > "$META"
fi

python3 - <<PY
import json, pathlib, sys
meta_path = pathlib.Path("$META")
metrics_path = pathlib.Path("$METRICS")
if not metrics_path.exists():
    sys.exit(f"metrics file not found: {metrics_path}")
meta = json.loads(meta_path.read_text())
metrics = json.loads(metrics_path.read_text())
metrics["arm"] = metrics.get("arm") or "$ARM"
meta["phase_metrics"] = metrics
meta["live_agent"] = meta.get("live_agent", True)
meta["status"] = "metrics_logged"
meta_path.write_text(json.dumps(meta, indent=2) + "\n")
print(f"Updated {meta_path}")
PY
