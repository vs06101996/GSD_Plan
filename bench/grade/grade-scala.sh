#!/usr/bin/env bash
# Grade a Scala/SBT workspace using compile + hidden grader scripts.
set -euo pipefail

ARTIFACT="${1:?artifact directory required}"
OUT="${2:-}"

BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$BENCH_ROOT/bench/lib/resolve-task.sh"
# shellcheck source=/dev/null
SBT_BIN="$("$BENCH_ROOT/bench/lib/find-sbt.sh")"

ARTIFACT_ABS="$(cd "$ARTIFACT" && pwd)"
GRADER_DIR="${SCALA_GRADER_DIR:-$GRADER_DIR}"
MARKER="${SCALA_ROOT_MARKER:-build.sbt}"
COMPILE_TARGET="${SCALA_COMPILE:-compile}"
TEST_TIMEOUT="${SCALA_TEST_TIMEOUT_SEC:-600}"
COMPILE_TIMEOUT="${SCALA_COMPILE_TIMEOUT_SEC:-900}"

if [[ ! -f "$ARTIFACT_ABS/$MARKER" ]]; then
  echo "error: $ARTIFACT_ABS/$MARKER not found (Scala root)" >&2
  exit 1
fi

if [[ ! -d "$GRADER_DIR" ]]; then
  echo "error: grader dir not found: $GRADER_DIR" >&2
  exit 1
fi

run_sbt() {
  local dir="$1"
  local target="$2"
  local timeout_sec="$3"
  (
    cd "$dir"
    export SBT_OPTS="${SBT_OPTS:-} -Dsbt.supershell=false -Dsbt.log.noformat=true"
    timeout "$timeout_sec" "$SBT_BIN" "$target"
  )
}

BUILD_OK=false
VET_OK=true
TEST_OK=false
TESTS_TOTAL=0
TESTS_PASSED=0

if run_sbt "$ARTIFACT_ABS" "$COMPILE_TARGET" "$COMPILE_TIMEOUT"; then
  BUILD_OK=true
fi

export BENCH_ARTIFACT="$ARTIFACT_ABS"
export BENCH_TASK_ID="$TASK_ID"
if [[ -x "$GRADER_DIR/run-tests.sh" ]]; then
  if "$GRADER_DIR/run-tests.sh"; then
    TEST_OK=true
    TESTS_TOTAL=1
    TESTS_PASSED=1
  else
    TESTS_TOTAL=1
  fi
elif [[ -f "$GRADER_DIR/acceptance/smoke.sh" ]]; then
  if bash "$GRADER_DIR/acceptance/smoke.sh"; then
    TEST_OK=true
    TESTS_TOTAL=1
    TESTS_PASSED=1
  else
    TESTS_TOTAL=1
  fi
else
  echo "error: no grader/run-tests.sh or grader/acceptance/smoke.sh" >&2
  exit 1
fi

PASS=false
if $BUILD_OK && $VET_OK && $TEST_OK; then
  PASS=true
fi

JSON=$(python3 - "$PASS" "$BUILD_OK" "$VET_OK" "$TEST_OK" "$TESTS_PASSED" "$TESTS_TOTAL" "$ARTIFACT_ABS" "$TASK_ID" "scala" "$COMPILE_TARGET" <<'PY'
import json, sys
pass_all, build_ok, vet_ok, tests_ok = sys.argv[1:5]
tests_passed, tests_total, artifact, task_id, language, compile_target = int(sys.argv[5]), int(sys.argv[6]), sys.argv[7], sys.argv[8], sys.argv[9], sys.argv[10]
def b(s): return s == "true"
print(json.dumps({
  "pass": b(pass_all),
  "build_ok": b(build_ok),
  "vet_ok": b(vet_ok),
  "tests_ok": b(tests_ok),
  "tests_passed": tests_passed,
  "tests_total": tests_total,
  "artifact": artifact,
  "task_id": task_id,
  "language": language,
  "scala_compile": compile_target,
}, indent=2))
PY
)

if [[ -n "$OUT" ]]; then
  mkdir -p "$(dirname "$OUT")"
  echo "$JSON" > "$OUT"
fi
echo "$JSON"
$PASS || exit 1
