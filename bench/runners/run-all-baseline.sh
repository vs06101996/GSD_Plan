#!/usr/bin/env bash
set -euo pipefail
BUDGET="${1:-5}"
for i in 01 02 03 04 05; do
  echo "=== baseline run-$i ==="
  "$(dirname "$0")/run-baseline.sh" "run-$i" "$BUDGET"
done
