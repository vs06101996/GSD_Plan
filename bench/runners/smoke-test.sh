#!/usr/bin/env bash
# Phase 3 gate: toy GSD new-project in smoke/ (requires claude login).
set -euo pipefail
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
"$(dirname "$0")/check-auth.sh"

SMOKE="$BENCH_ROOT/smoke"
mkdir -p "$SMOKE"
cd "$SMOKE"

echo "Running non-interactive smoke (max \$2)..."
claude -p \
  --dangerously-skip-permissions \
  --permission-mode bypassPermissions \
  --max-budget-usd 2 \
  "Read SPEC.md. Use gsd-new-project skill flow if available, or implement hello CLI per spec. Module hello-cli." \
  2>&1 | tee "$BENCH_ROOT/results/smoke-transcript.txt"

if [[ -f go.mod ]] || [[ -f main.go ]]; then
  echo "Smoke: artifacts present."
  exit 0
fi
echo "Smoke: no go artifacts — check transcript." >&2
exit 1
