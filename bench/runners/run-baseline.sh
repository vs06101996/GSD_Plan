#!/usr/bin/env bash
# Non-interactive baseline arm via Claude Code -p.
set -euo pipefail
RUN_ID="${1:?e.g. run-01}"
MAX_BUDGET="${2:-5}"
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUN_DIR="$BENCH_ROOT/runs/baseline/$RUN_ID"
RESULT_DIR="$BENCH_ROOT/results/baseline/$RUN_ID"
mkdir -p "$RESULT_DIR/artifact"

"$BENCH_ROOT/bench/runners/prepare-run.sh" "runs/baseline/$RUN_ID"

# shellcheck source=/dev/null
source "$BENCH_ROOT/bench/lib/resolve-task.sh"

WORK_DIR="$RUN_DIR"
if [[ "$TASK_MODE" == "brownfield" ]]; then
  WORK_DIR="$RUN_DIR/$WORKSPACE_SUBDIR"
fi

START=$(date -u +%Y-%m-%dT%H:%M:%SZ)
if [[ "$LANGUAGE" == "scala" ]]; then
  if [[ "$TASK_MODE" == "brownfield" ]]; then
    PROMPT=$(cat <<EOF
You are implementing a change in an existing Scala/SBT codebase. Read SPEC.md and RUN_INSTRUCTIONS.md.
Work only under $WORKSPACE_SUBDIR/ (repository root with build.sbt).
Meet SPEC acceptance criteria. Run sbt ${SCALA_COMPILE} when done.
Do not ask questions; make reasonable choices aligned with the spec.
EOF
)
  else
    PROMPT=$(cat <<EOF
You are implementing a greenfield Scala/SBT project from SPEC.md only.
Run sbt ${SCALA_COMPILE} when done. Do not ask questions.
EOF
)
  fi
elif [[ "$TASK_MODE" == "brownfield" ]]; then
  PROMPT=$(cat <<EOF
You are implementing a change in an existing Go service. Read SPEC.md and RUN_INSTRUCTIONS.md.
Work only under the $WORKSPACE_SUBDIR/ directory (module $GO_MODULE).
Meet the acceptance criteria in SPEC.md. Run go build ./... from $WORKSPACE_SUBDIR when done.
Do not ask questions; make reasonable choices aligned with the spec.
EOF
)
else
  PROMPT=$(cat <<EOF
You are implementing a greenfield Go project. Read SPEC.md in this directory only.
Build the full $GO_MODULE module described in SPEC.md.
Use module name $GO_MODULE. Create all packages and files needed. Run go build ./... when done.
Do not ask questions; make reasonable choices aligned with the spec.
EOF
)
fi

set +e
TRANSCRIPT="$RESULT_DIR/transcript.txt"
cd "$WORK_DIR"
claude -p \
  --dangerously-skip-permissions \
  --permission-mode bypassPermissions \
  --max-budget-usd "$MAX_BUDGET" \
  --output-format text \
  "$PROMPT" 2>&1 | tee "$TRANSCRIPT"
EXIT=$?
set -e
END=$(date -u +%Y-%m-%dT%H:%M:%SZ)

"$BENCH_ROOT/bench/runners/finalize-run.sh" baseline "$RUN_ID" || true

python3 - <<PY
import json, pathlib
p = pathlib.Path("$RESULT_DIR/metadata.json")
m = json.loads(p.read_text()) if p.exists() else {}
m.update({
  "arm": "baseline",
  "run_id": "$RUN_ID",
  "task_id": "$TASK_ID",
  "task_mode": "$TASK_MODE",
  "started_at": "$START",
  "ended_at": "$END",
  "claude_exit": $EXIT,
  "max_budget_usd": float("$MAX_BUDGET"),
  "mode": "claude_print_noninteractive",
})
p.write_text(json.dumps(m, indent=2))
PY

echo "Done baseline $RUN_ID (task=$TASK_ID exit $EXIT). See $RESULT_DIR"
