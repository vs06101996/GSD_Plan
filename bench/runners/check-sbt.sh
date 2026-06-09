#!/usr/bin/env bash
set -euo pipefail
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
SBT="$("$BENCH_ROOT/bench/lib/find-sbt.sh")"
"$SBT" --script-version 2>/dev/null || "$SBT" sbtVersion 2>/dev/null | head -3
echo "sbt OK: $SBT"
