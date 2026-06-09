#!/usr/bin/env bash
# Grade a run artifact using the active task's language-specific grader.
# Usage: ./bench/grade/grade.sh <artifact-dir> [output-grade.json]
set -euo pipefail

ARTIFACT="${1:?artifact directory required}"
OUT="${2:-}"

BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$BENCH_ROOT/bench/lib/resolve-task.sh"

case "$LANGUAGE" in
  scala)
    exec "$BENCH_ROOT/bench/grade/grade-scala.sh" "$ARTIFACT" "$OUT"
    ;;
  go|*)
    exec "$BENCH_ROOT/bench/grade/grade-go.sh" "$ARTIFACT" "$OUT"
    ;;
esac
