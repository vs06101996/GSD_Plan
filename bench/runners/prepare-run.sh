#!/usr/bin/env bash
# Prepare a fresh run workspace (SPEC + optional brownfield workspace copy).
set -euo pipefail
RUN_DIR="${1:?run directory, e.g. runs/baseline/run-01}"
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$BENCH_ROOT/bench/lib/resolve-task.sh"

RUN_ABS="$BENCH_ROOT/$RUN_DIR"
mkdir -p "$RUN_ABS"

# Clear run dir but keep path
find "$RUN_ABS" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

cp "$SPEC_PATH" "$RUN_ABS/SPEC.md"

if [[ "$TASK_MODE" == "brownfield" ]]; then
  WS="$RUN_ABS/$WORKSPACE_SUBDIR"
  mkdir -p "$WS"
  if [[ "$WORKSPACE_STRATEGY" == "in_place" ]]; then
    echo "warning: in_place — agent should work at REF_PATH=$REF_PATH" >&2
    ln -sfn "$REF_PATH" "$WS" 2>/dev/null || true
    cat > "$RUN_ABS/WORKSPACE_LINK.txt" <<EOF
Brownfield in_place: edit repository at:
$REF_PATH

Symlink (if created): $WS -> $REF_PATH
EOF
  else
    rsync -a --delete \
      --exclude '.git' \
      --exclude 'target' \
      --exclude '*/target' \
      --exclude '.bloop' \
      --exclude '.metals' \
      --exclude 'tasks' \
      "$REF_PATH/" "$WS/"
  fi
  if [[ "$LANGUAGE" == "scala" ]]; then
    INSTRUCTIONS=$(cat <<EOF
# Run instructions

- Task: $TASK_ID ($TASK_MODE, Scala/SBT)
- Work in \`$WORKSPACE_SUBDIR/\` (copy of the repo). Do not read \`tasks/$TASK_ID/grader\`.
- Read SPEC.md for the feature/goal to implement.
- Build from repo root: \`sbt ${SCALA_COMPILE}\` (see task.yaml for compile target).
- Meet SPEC acceptance criteria; grading uses hidden scripts in the task grader.
EOF
)
  else
    INSTRUCTIONS=$(cat <<EOF
# Run instructions

- Task: $TASK_ID ($TASK_MODE)
- Work in \`$WORKSPACE_SUBDIR/\` (copy of the service). Do not read \`tasks/$TASK_ID/grader\`.
- Also read SPEC.md for the feature/goal to implement.
- Module: $GO_MODULE
- Goal: \`go build ./...\` from $WORKSPACE_SUBDIR and meet SPEC acceptance criteria.
EOF
)
  fi
else
  if [[ "$LANGUAGE" == "scala" ]]; then
    INSTRUCTIONS=$(cat <<EOF
# Run instructions

- Task: $TASK_ID ($TASK_MODE, Scala/SBT)
- Work only from SPEC.md in this directory (greenfield).
- Do not read \`tasks/$TASK_ID/grader\` or reference trees.
- Goal: \`sbt ${SCALA_COMPILE}\` and behavior in SPEC acceptance criteria.
EOF
)
  else
    INSTRUCTIONS=$(cat <<EOF
# Run instructions

- Task: $TASK_ID ($TASK_MODE)
- Work only from SPEC.md in this directory.
- Do not read \`tasks/$TASK_ID/grader\` or reference trees.
- Implement module \`$GO_MODULE\` per spec.
- Goal: \`go build ./...\` and behavior in SPEC acceptance criteria.
EOF
)
  fi
fi

echo "$INSTRUCTIONS" > "$RUN_ABS/RUN_INSTRUCTIONS.md"
echo "Prepared $RUN_ABS (task=$TASK_ID mode=$TASK_MODE)"
