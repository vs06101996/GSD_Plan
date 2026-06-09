#!/usr/bin/env bash
# Hidden smoke acceptance — extend with file checks or targeted sbt test filters.
set -euo pipefail
: "${BENCH_ARTIFACT:?}"

if [[ ! -f "$BENCH_ARTIFACT/build.sbt" ]]; then
  echo "error: missing build.sbt in artifact" >&2
  exit 1
fi

echo "scala acceptance smoke ok (task=${BENCH_TASK_ID:-unknown})"
