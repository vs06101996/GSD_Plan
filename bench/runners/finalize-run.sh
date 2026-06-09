#!/usr/bin/env bash
# Copy run workspace to artifact and grade (after manual or automated session).
set -euo pipefail
ARM="${1:?baseline|gsd|recipe}"
RUN_ID="${2:?run-01}"
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$BENCH_ROOT/bench/lib/resolve-task.sh"

RUN_DIR="$BENCH_ROOT/runs/$ARM/$RUN_ID"
RESULT_DIR="$BENCH_ROOT/results/$ARM/$RUN_ID"
mkdir -p "$RESULT_DIR/artifact"

artifact_from_workspace() {
  local ws="$RUN_DIR/$WORKSPACE_SUBDIR"
  if [[ "$LANGUAGE" == "scala" && -f "$ws/$SCALA_ROOT_MARKER" ]]; then
    rsync -a --delete --exclude '.git' --exclude 'target' --exclude '*/target' "$ws/" "$RESULT_DIR/artifact/"
    return 0
  fi
  if [[ -f "$ws/go.mod" ]]; then
    rsync -a --delete --exclude '.git' "$ws/" "$RESULT_DIR/artifact/"
    return 0
  fi
  return 1
}

if [[ "$TASK_MODE" == "brownfield" && -d "$RUN_DIR/$WORKSPACE_SUBDIR" ]]; then
  artifact_from_workspace || {
    echo "error: brownfield workspace missing build.sbt or go.mod" >&2
    exit 1
  }
elif [[ "$LANGUAGE" == "scala" && -f "$RUN_DIR/$SCALA_ROOT_MARKER" ]]; then
  rsync -a --delete \
    --exclude '.git' \
    --exclude '.planning' \
    --exclude 'RUN_INSTRUCTIONS.md' \
    --exclude 'SPEC.md' \
    --exclude 'WORKSPACE_LINK.txt' \
    --exclude 'target' \
    --exclude '*/target' \
    "$RUN_DIR/" "$RESULT_DIR/artifact/"
elif [[ -f "$RUN_DIR/go.mod" ]]; then
  rsync -a --delete \
    --exclude '.git' \
    --exclude '.planning' \
    --exclude 'RUN_INSTRUCTIONS.md' \
    --exclude 'SPEC.md' \
    --exclude 'WORKSPACE_LINK.txt' \
    "$RUN_DIR/" "$RESULT_DIR/artifact/"
else
  echo "error: nothing to grade at run root or $WORKSPACE_SUBDIR/" >&2
  exit 1
fi

"$BENCH_ROOT/bench/grade/grade.sh" "$RESULT_DIR/artifact" "$RESULT_DIR/grade.json" || true

python3 - <<PY
import json, pathlib
p = pathlib.Path("$RESULT_DIR/metadata.json")
m = json.loads(p.read_text()) if p.exists() else {}
m.update({
  "task_id": "$TASK_ID",
  "task_mode": "$TASK_MODE",
  "language": "$LANGUAGE",
  "go_module": "$GO_MODULE",
})
p.write_text(json.dumps(m, indent=2))
PY

echo "Finalized $ARM/$RUN_ID (task=$TASK_ID) -> $RESULT_DIR/grade.json"
