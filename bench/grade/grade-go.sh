#!/usr/bin/env bash
# Grade a candidate Go module directory using the active task's hidden grader.
set -euo pipefail

ARTIFACT="${1:?artifact directory required}"
OUT="${2:-}"

BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$BENCH_ROOT/bench/lib/resolve-task.sh"

ARTIFACT_ABS="$(cd "$ARTIFACT" && pwd)"
GRADER_DIR="$GRADER_DIR"

if [[ ! -f "$ARTIFACT_ABS/go.mod" ]]; then
  echo "error: $ARTIFACT_ABS/go.mod not found" >&2
  exit 1
fi

if [[ ! -d "$GRADER_DIR" ]]; then
  echo "error: grader dir not found: $GRADER_DIR" >&2
  exit 1
fi

TMP_MOD="$GRADER_DIR/go.mod.bak"
cp "$GRADER_DIR/go.mod" "$TMP_MOD"

cleanup() {
  mv -f "$TMP_MOD" "$GRADER_DIR/go.mod"
}
trap cleanup EXIT

perl -i -pe "s|replace ${GO_MODULE} => .*|replace ${GO_MODULE} => $ARTIFACT_ABS|" "$GRADER_DIR/go.mod"

BUILD_OK=false
VET_OK=false
TEST_OK=false
TESTS_TOTAL=0
TESTS_PASSED=0

if (cd "$ARTIFACT_ABS" && go build ./... 2>&1); then
  BUILD_OK=true
fi

if (cd "$ARTIFACT_ABS" && go vet ./... 2>&1); then
  VET_OK=true
fi

TEST_LOG=""
if TEST_LOG=$(cd "$GRADER_DIR" && go test ./acceptance/... -count=1 -json 2>&1); then
  TEST_OK=true
fi

while IFS= read -r line; do
  action=$(echo "$line" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('Action',''))" 2>/dev/null || true)
  if [[ "$action" == "pass" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
  elif [[ "$action" == "fail" ]]; then
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
  fi
done <<< "$TEST_LOG"

PASS=false
if $BUILD_OK && $VET_OK && $TEST_OK; then
  PASS=true
fi

JSON=$(python3 - "$PASS" "$BUILD_OK" "$VET_OK" "$TEST_OK" "$TESTS_PASSED" "$TESTS_TOTAL" "$ARTIFACT_ABS" "$TASK_ID" "$GO_MODULE" "go" <<'PY'
import json, sys
pass_all, build_ok, vet_ok, tests_ok = sys.argv[1:5]
tests_passed, tests_total, artifact, task_id, go_module, language = int(sys.argv[5]), int(sys.argv[6]), sys.argv[7], sys.argv[8], sys.argv[9], sys.argv[10]
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
  "go_module": go_module,
}, indent=2))
PY
)

if [[ -n "$OUT" ]]; then
  mkdir -p "$(dirname "$OUT")"
  echo "$JSON" > "$OUT"
  echo "$JSON"
else
  echo "$JSON"
fi

$PASS || exit 1
