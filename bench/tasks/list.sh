#!/usr/bin/env bash
# List registered benchmark tasks.
set -euo pipefail
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TASKS_ROOT="$BENCH_ROOT/tasks"

ACTIVE=""
if [[ -f "$BENCH_ROOT/config.yaml" ]]; then
  ACTIVE=$(grep -E '^\s*active_task:' "$BENCH_ROOT/config.yaml" | head -1 | sed -E 's/^[[:space:]]*active_task:[[:space:]]*//' | tr -d "'\"")
fi

echo "Registered tasks (active_task: ${ACTIVE:-<none>})"
echo ""

shopt -s nullglob
found=0
for manifest in "$TASKS_ROOT"/*/task.yaml; do
  found=1
  task_dir=$(dirname "$manifest")
  task_id=$(basename "$task_dir")
  mode=$(grep -E '^\s*mode:' "$manifest" | head -1 | sed -E 's/^[[:space:]]*mode:[[:space:]]*//' | tr -d "'\"")
  lang=$(grep -E '^language:' "$manifest" | head -1 | sed -E 's/^language:[[:space:]]*//' | tr -d "'\"")
  mod=$(awk '/^  module:/{print $2; exit}' "$manifest" 2>/dev/null || true)
  sbt_compile=$(awk '/^  compile:/{print $2; exit}' "$manifest" 2>/dev/null || true)
  src=$(awk '/^  type:/{print $2; exit}' "$manifest" 2>/dev/null || true)
  marker=""
  [[ "$task_id" == "$ACTIVE" ]] && marker=" *"
  if [[ "$lang" == "scala" ]]; then
    echo "  $task_id$marker  mode=$mode  language=scala  sbt=${sbt_compile:-compile}  source.type=${src:-?}"
  else
    echo "  $task_id$marker  mode=$mode  language=${lang:-go}  go.module=${mod:-?}  source.type=${src:-?}"
  fi
done
shopt -u nullglob

if [[ "$found" -eq 0 ]]; then
  echo "  (no tasks with task.yaml)"
fi

echo ""
echo "Set active: edit config.yaml active_task: <id>"
echo "Override:   BENCH_TASK=<id> ./bench/runners/prepare-run.sh runs/baseline/run-01"
