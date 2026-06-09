#!/usr/bin/env bash
# GSD arm: interactive session recommended. This script prepares the run and
# prints the exact slash-command sequence; optional -p attempt is best-effort.
set -euo pipefail
RUN_ID="${1:?e.g. run-01}"
TRY_PRINT="${2:-0}"
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUN_DIR="$BENCH_ROOT/runs/gsd/$RUN_ID"
RESULT_DIR="$BENCH_ROOT/results/gsd/$RUN_ID"
mkdir -p "$RESULT_DIR/artifact"

"$BENCH_ROOT/bench/runners/prepare-run.sh" "runs/gsd/$RUN_ID"

# shellcheck source=/dev/null
source "$BENCH_ROOT/bench/lib/resolve-task.sh"

WORK_HINT="$RUN_DIR"
if [[ "$TASK_MODE" == "brownfield" ]]; then
  WORK_HINT="$RUN_DIR/$WORKSPACE_SUBDIR"
fi

cat > "$RESULT_DIR/GSD_SESSION.md" <<EOF
# GSD interactive session (recommended)

Task: **$TASK_ID** ($TASK_MODE) — module \`$GO_MODULE\`

From this directory:

\`\`\`bash
cd $WORK_HINT
\`\`\`

Open **$RUN_DIR** in Cursor (or the workspace subfolder for brownfield).

Invoke skills by name (Cursor):

1. **gsd-new-project** — provide SPEC.md as the product brief
2. **gsd-discuss-phase** (optional)
3. **gsd-plan-phase**
4. **gsd-execute-phase**
5. **gsd-verify-work**
6. **gsd-ship**

Set mode yolo via **gsd-settings** or \`.planning/config.json\`.

After completion:

\`\`\`bash
$BENCH_ROOT/bench/runners/finalize-run.sh gsd $RUN_ID
\`\`\`

Do not read \`tasks/$TASK_ID/grader/\`.
EOF

if [[ "$TRY_PRINT" == "1" ]]; then
  START=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  PROMPT="Use available gsd-* skills. Start with gsd-new-project for SPEC.md. Complete plan, execute, verify for phase 1. Implement $GO_MODULE per SPEC."
  cd "$WORK_HINT"
  claude -p --dangerously-skip-permissions --permission-mode bypassPermissions --max-budget-usd 8 "$PROMPT" 2>&1 | tee "$RESULT_DIR/transcript.txt" || true
  END=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  python3 -c "import json,pathlib; pathlib.Path('$RESULT_DIR/metadata.json').write_text(json.dumps({'arm':'gsd','run_id':'$RUN_ID','task_id':'$TASK_ID','started_at':'$START','ended_at':'$END','mode':'claude_print_best_effort'},indent=2))"
  "$BENCH_ROOT/bench/runners/finalize-run.sh" gsd "$RUN_ID" || true
fi

echo "Prepared GSD run $RUN_ID (task=$TASK_ID). See $RESULT_DIR/GSD_SESSION.md"
