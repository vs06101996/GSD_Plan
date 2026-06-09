#!/usr/bin/env bash
# Register a pluggable benchmark task (Go or Scala/SBT brownfield).
set -euo pipefail

BENCH_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEMPLATES="$BENCH_ROOT/bench/tasks/templates"

usage() {
  cat <<'EOF'
Usage: ./bench/tasks/register.sh --id <taskId> [options]

Options:
  --path <abs>              Brownfield: existing repo (Go go.mod or Scala build.sbt root)
  --bundle copy|symlink     Also snapshot under tasks/<id>/reference/
  --git <url>               Clone into tasks/<id>/reference/ (brownfield)
  --language go|scala       Force language (default: auto-detect from path)
  --scala-compile <target>  sbt target for compile check (default: compile)
  --scala-test <target>     Optional native sbt test on reference (default: none)
  --greenfield              Register greenfield task (no workspace copy)
  --in-place                workspace.strategy: in_place (requires --i-understand-mutates-repo)
  --i-understand-mutates-repo  Acknowledge in_place mutates the canonical repo

Examples:
  ./bench/tasks/register.sh --id occm --path /path/to/occm-root
  ./bench/tasks/register.sh --id chorebot --path /path/to/go-service
EOF
  exit 1
}

TASK_ID=""
LOCAL_PATH=""
BUNDLE=""
GIT_URL=""
MODE="brownfield"
IN_PLACE=false
I_UNDERSTAND=false
FORCE_LANG=""
SCALA_COMPILE="compile"
SCALA_TEST="none"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id) TASK_ID="${2:-}"; shift 2 ;;
    --path) LOCAL_PATH="${2:-}"; shift 2 ;;
    --bundle) BUNDLE="${2:-}"; shift 2 ;;
    --git) GIT_URL="${2:-}"; shift 2 ;;
    --language) FORCE_LANG="${2:-}"; shift 2 ;;
    --scala-compile) SCALA_COMPILE="${2:-}"; shift 2 ;;
    --scala-test) SCALA_TEST="${2:-}"; shift 2 ;;
    --greenfield) MODE="greenfield"; shift ;;
    --in-place) IN_PLACE=true; shift ;;
    --i-understand-mutates-repo) I_UNDERSTAND=true; shift ;;
    -h|--help) usage ;;
    *) echo "error: unknown arg: $1" >&2; usage ;;
  esac
done

[[ -n "$TASK_ID" ]] || { echo "error: --id required" >&2; usage; }
if [[ ! "$TASK_ID" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "error: --id must be lowercase alphanumeric with hyphens" >&2
  exit 1
fi

if $IN_PLACE && ! $I_UNDERSTAND; then
  echo "error: --in-place requires --i-understand-mutates-repo" >&2
  exit 1
fi

if [[ -n "$BUNDLE" && "$BUNDLE" != "copy" && "$BUNDLE" != "symlink" ]]; then
  echo "error: --bundle must be copy or symlink" >&2
  exit 1
fi

TASK_DIR="$BENCH_ROOT/tasks/$TASK_ID"
mkdir -p "$TASK_DIR"

REF_DIR="$TASK_DIR/reference"
SOURCE_TYPE="local"
WORKSPACE_STRATEGY="copy_per_run"

if [[ -n "$GIT_URL" ]]; then
  rm -rf "$REF_DIR"
  git clone --depth 1 "$GIT_URL" "$REF_DIR"
  LOCAL_PATH="$REF_DIR"
  SOURCE_TYPE="git"
elif [[ -n "$LOCAL_PATH" ]]; then
  LOCAL_PATH="$(cd "$LOCAL_PATH" 2>/dev/null && pwd)" || {
    echo "error: path not found: $LOCAL_PATH" >&2
    exit 1
  }
  if [[ -n "$BUNDLE" ]]; then
    rm -rf "$REF_DIR"
    mkdir -p "$(dirname "$REF_DIR")"
    if [[ "$BUNDLE" == "symlink" ]]; then
      ln -sfn "$LOCAL_PATH" "$REF_DIR"
    else
      rsync -a --delete --exclude '.git' --exclude 'target' --exclude '*/target' "$LOCAL_PATH/" "$REF_DIR/"
    fi
  fi
else
  if [[ "$MODE" == "brownfield" ]]; then
    echo "error: brownfield requires --path or --git" >&2
    exit 1
  fi
  SOURCE_TYPE="bundled"
fi

detect_language() {
  local root="$1"
  if [[ -n "$FORCE_LANG" ]]; then
    echo "$FORCE_LANG"
    return
  fi
  if [[ -f "$root/build.sbt" ]]; then
    echo "scala"
    return
  fi
  if [[ -f "$root/go.mod" ]]; then
    echo "go"
    return
  fi
  echo "unknown"
}

ROOT_PATH="${LOCAL_PATH:-$REF_DIR}"
LANG=$(detect_language "$ROOT_PATH")

if [[ "$LANG" == "unknown" ]]; then
  echo "error: could not detect language (need build.sbt or go.mod at $ROOT_PATH)" >&2
  exit 1
fi

if [[ "$MODE" == "brownfield" ]]; then
  if [[ "$LANG" == "scala" && ! -f "$ROOT_PATH/build.sbt" ]]; then
    echo "error: build.sbt not found at $ROOT_PATH" >&2
    exit 1
  fi
  if [[ "$LANG" == "go" && ! -f "$ROOT_PATH/go.mod" ]]; then
    echo "error: go.mod not found at $ROOT_PATH" >&2
    exit 1
  fi
fi

GO_MODULE=$(awk '/^module /{print $2; exit}' "$ROOT_PATH/go.mod" 2>/dev/null || echo "$TASK_ID")
if $IN_PLACE; then
  WORKSPACE_STRATEGY="in_place"
fi

write_manifest() {
  if [[ "$LANG" == "scala" ]]; then
    if [[ "$SOURCE_TYPE" == "bundled" ]]; then
      cat > "$TASK_DIR/task.yaml" <<EOF
id: $TASK_ID
mode: $MODE
language: scala

spec: SPEC.md

scala:
  root_marker: build.sbt
  compile: $SCALA_COMPILE
  test: $SCALA_TEST
  grader_dir: grader

source:
  type: bundled

workspace:
  strategy: $WORKSPACE_STRATEGY
  subdir: workspace
EOF
    else
      cat > "$TASK_DIR/task.yaml" <<EOF
id: $TASK_ID
mode: $MODE
language: scala

spec: SPEC.md

scala:
  root_marker: build.sbt
  compile: $SCALA_COMPILE
  test: $SCALA_TEST
  grader_dir: grader

source:
  type: $SOURCE_TYPE
  local_path: $LOCAL_PATH

workspace:
  strategy: $WORKSPACE_STRATEGY
  subdir: workspace
EOF
    fi
  else
    if [[ "$SOURCE_TYPE" == "bundled" ]]; then
      cat > "$TASK_DIR/task.yaml" <<EOF
id: $TASK_ID
mode: $MODE
language: go

spec: SPEC.md

go:
  module: $GO_MODULE
  grader_dir: grader

source:
  type: bundled

workspace:
  strategy: $WORKSPACE_STRATEGY
  subdir: workspace
EOF
    else
      cat > "$TASK_DIR/task.yaml" <<EOF
id: $TASK_ID
mode: $MODE
language: go

spec: SPEC.md

go:
  module: $GO_MODULE
  grader_dir: grader

source:
  type: $SOURCE_TYPE
  local_path: $LOCAL_PATH

workspace:
  strategy: $WORKSPACE_STRATEGY
  subdir: workspace
EOF
    fi
  fi
}

write_manifest

if [[ ! -f "$TASK_DIR/SPEC.md" ]]; then
  if [[ "$LANG" == "scala" ]]; then
    sed -e "s|{{TASK_ID}}|$TASK_ID|g" "$TEMPLATES/SPEC-scala.md.stub" > "$TASK_DIR/SPEC.md"
  else
    sed -e "s|{{TASK_ID}}|$TASK_ID|g" -e "s|{{MODULE}}|$GO_MODULE|g" \
      "$TEMPLATES/SPEC.md.stub" > "$TASK_DIR/SPEC.md"
  fi
  echo "Created $TASK_DIR/SPEC.md (edit before benchmarking)"
fi

GRADER_DIR="$TASK_DIR/grader"
if [[ "$LANG" == "scala" ]]; then
  if [[ ! -f "$GRADER_DIR/run-tests.sh" ]]; then
    mkdir -p "$GRADER_DIR/acceptance"
    cp "$TEMPLATES/grader-scala/acceptance/smoke.sh" "$GRADER_DIR/acceptance/smoke.sh"
    cp "$TEMPLATES/grader-scala/run-tests.sh" "$GRADER_DIR/run-tests.sh"
    chmod +x "$GRADER_DIR/run-tests.sh" "$GRADER_DIR/acceptance/smoke.sh"
    echo "Scaffolded $GRADER_DIR/ (Scala grader scripts)"
  fi
else
  if [[ ! -d "$GRADER_DIR/acceptance" ]]; then
    mkdir -p "$GRADER_DIR/acceptance"
    cp "$TEMPLATES/grader/acceptance/smoke_test.go" "$GRADER_DIR/acceptance/smoke_test.go"
    if [[ -d "$REF_DIR" ]]; then
      REPLACE_TARGET="../reference"
    elif [[ -n "$LOCAL_PATH" ]]; then
      REPLACE_TARGET="$LOCAL_PATH"
    else
      REPLACE_TARGET="../reference"
    fi
    sed -e "s|{{TASK_ID}}|$TASK_ID|g" \
        -e "s|{{MODULE}}|$GO_MODULE|g" \
        -e "s|{{REPLACE_TARGET}}|$REPLACE_TARGET|g" \
      "$TEMPLATES/grader/go.mod.template" > "$GRADER_DIR/go.mod"
    echo "Scaffolded $GRADER_DIR/ (Go acceptance tests)"
  fi
fi

TEST_PATH="${LOCAL_PATH:-$REF_DIR}"
if [[ "$LANG" == "go" && -f "$TEST_PATH/go.mod" ]]; then
  echo "Running go test on reference path..."
  if ! (cd "$TEST_PATH" && go test ./...); then
    echo "warning: go test ./... failed on $TEST_PATH" >&2
  fi
elif [[ "$LANG" == "scala" ]]; then
  if [[ -x "$BENCH_ROOT/bench/lib/find-sbt.sh" ]]; then
    if SBT_BIN="$("$BENCH_ROOT/bench/lib/find-sbt.sh" 2>/dev/null)"; then
      echo "sbt found: $SBT_BIN"
      if [[ "$SCALA_TEST" != "none" ]]; then
        echo "Running sbt $SCALA_TEST on reference (optional)..."
        (cd "$TEST_PATH" && "$SBT_BIN" -Dsbt.supershell=false -Dsbt.log.noformat=true "$SCALA_TEST") \
          || echo "warning: sbt $SCALA_TEST failed — set --scala-test none to skip" >&2
      fi
    fi
  else
    echo "warning: sbt not installed — install before validate-pipeline (brew install sbt)" >&2
  fi
fi

echo ""
echo "Registered task: $TASK_ID"
echo "  Language:  $LANG"
echo "  Manifest:  $TASK_DIR/task.yaml"
echo "  Mode:      $MODE"
echo "  Ref path:  ${LOCAL_PATH:-$REF_DIR}"
if [[ "$LANG" == "scala" ]]; then
  echo "  Compile:   sbt $SCALA_COMPILE"
fi
if [[ "$LANG" == "go" ]]; then
  echo "  Module:    $GO_MODULE"
fi
if $IN_PLACE; then
  echo "  WARNING: in_place — agent mutates $LOCAL_PATH directly"
fi
echo ""
echo "Next:"
echo "  1. Edit $TASK_DIR/SPEC.md"
echo "  2. Extend $TASK_DIR/grader/ acceptance checks"
echo "  3. Set active_task: $TASK_ID in config.yaml (or BENCH_TASK=$TASK_ID)"
echo "  4. ./bench/runners/validate-pipeline.sh"
