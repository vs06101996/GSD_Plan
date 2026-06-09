#!/usr/bin/env bash
# Prove grader + artifact path without LLM (reference oracle).
set -euo pipefail
BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$BENCH_ROOT/bench/lib/resolve-task.sh"

REF="$REF_PATH"

echo "== task: $TASK_ID ($TASK_MODE, $LANGUAGE) =="
echo "== reference: $REF =="

if [[ ! -d "$REF" ]]; then
  echo "error: reference path missing: $REF" >&2
  exit 1
fi

echo "== reference native checks =="
if [[ "$LANGUAGE" == "scala" ]]; then
  # shellcheck source=/dev/null
  SBT_BIN="$("$BENCH_ROOT/bench/lib/find-sbt.sh")"
  if [[ "${SCALA_TEST_TARGET}" != "none" && -n "${SCALA_TEST_TARGET}" ]]; then
    (cd "$REF" && "$SBT_BIN" -Dsbt.supershell=false -Dsbt.log.noformat=true "${SCALA_TEST_TARGET}") \
      || echo "warning: reference sbt ${SCALA_TEST_TARGET} failed or skipped"
  else
    echo "(skipped native sbt test; scala.test is none)"
  fi
else
  (cd "$REF" && go test ./...) || echo "warning: reference native tests failed or none"
fi

echo "== grader against reference =="
"$BENCH_ROOT/bench/grade/grade.sh" "$REF" /tmp/gsd-bench-validate-grade.json
python3 -c "import json; d=json.load(open('/tmp/gsd-bench-validate-grade.json')); assert d['pass'], d"

for arm in baseline gsd; do
  RESULT="$BENCH_ROOT/results/$arm/run-01"
  mkdir -p "$RESULT/artifact"
  rsync -a --delete \
    --exclude '.git' \
    --exclude 'target' \
    --exclude '*/target' \
    "$REF/" "$RESULT/artifact/"
  "$BENCH_ROOT/bench/grade/grade.sh" "$RESULT/artifact" "$RESULT/grade.json"
  python3 - <<PY
import json, pathlib
p = pathlib.Path("$RESULT/metadata.json")
m = json.loads(p.read_text()) if p.exists() else {}
m.update({
  "arm": "$arm",
  "run_id": "run-01",
  "task_id": "$TASK_ID",
  "language": "$LANGUAGE",
  "status": "pipeline_validated_reference_oracle",
  "live_agent": False,
})
p.write_text(json.dumps(m, indent=2))
PY
done

echo "Pipeline validation OK (task=$TASK_ID, reference passes hidden grader)."
