#!/usr/bin/env bash
# Full benchmark orchestrator (requires claude /login).
# Usage: ./bench/runners/run-benchmark.sh [budget_usd_per_baseline_run]
set -euo pipefail
BUDGET="${1:-5}"
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DIR="$(dirname "$0")"

echo "=== Phase: validate pipeline (no LLM) ==="
"$DIR/validate-pipeline.sh"

echo "=== Phase: check auth ==="
if ! "$DIR/check-auth.sh"; then
  echo ""
  echo "Infrastructure ready. Live runs skipped."
  echo "After: claude /login"
  echo "  $DIR/smoke-test.sh"
  echo "  $DIR/run-baseline.sh run-01 $BUDGET   # pilot baseline"
  echo "  $DIR/run-gsd.sh run-01 && follow GSD_SESSION.md"
  echo "  $DIR/run-all-baseline.sh $BUDGET"
  echo "  # then 4 more GSD runs + finalize-run.sh each"
  python3 "$BENCH_ROOT/bench/report/aggregate.py"
  exit 2
fi

echo "=== Phase: smoke test ==="
"$DIR/smoke-test.sh"

echo "=== Phase: pilot baseline run-01 ==="
"$DIR/run-baseline.sh" run-01 "$BUDGET"

echo "=== Phase: pilot GSD run-01 (best-effort -p) ==="
"$DIR/run-gsd.sh" run-01 1

echo "=== Phase: full baseline runs 02-05 ==="
for i in 02 03 04 05; do
  "$DIR/run-baseline.sh" "run-$i" "$BUDGET"
done

echo "=== GSD runs 02-05: prepare interactive sessions ==="
for i in 02 03 04 05; do
  "$DIR/run-gsd.sh" "run-$i"
  echo "Complete results/gsd/run-$i via GSD_SESSION.md then finalize-run.sh gsd run-$i"
done

python3 "$BENCH_ROOT/bench/report/aggregate.py"
echo "Benchmark orchestration done (GSD 02-05 may need interactive completion)."
