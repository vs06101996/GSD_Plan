# Pluggable benchmark tasks

Tasks are defined by a manifest at `tasks/<taskId>/task.yaml`. The harness resolves the active task from `config.yaml` (`active_task`) or the environment variable `BENCH_TASK`.

## Language support

| Language | Register | Grade |
|----------|----------|-------|
| **Go** | Directory with `go.mod` | `go build`, `go vet`, hidden `grader/acceptance/*_test.go` |
| **Scala** | SBT root with `build.sbt` | `sbt <compile target>`, hidden `grader/run-tests.sh` |

Prerequisites for Scala: **sbt** on PATH (`brew install sbt`) or set `SBT=/path/to/sbt`.

Do not point at a Go subfolder inside a Scala monorepo — use the **SBT root** (e.g. `occm-root`, not `occm-go/`).

### Scala manifest (`scala:` block)

```yaml
language: scala
scala:
  root_marker: build.sbt
  compile: common/compile    # sbt target for grading compile check
  test: none                 # optional native test on reference during validate
  grader_dir: grader
```

Register Occm:

```bash
./bench/tasks/register.sh --id occm \
  --path /Users/you/Repositories/Occm/cvo/occm-root \
  --scala-compile common/compile
```

## Quick commands

```bash
# List registered tasks
./bench/tasks/list.sh

# Brownfield: point at your Go repo (default: copy_per_run workspace)
./bench/tasks/register.sh --id chorebot --path /absolute/path/to/repo

# Optional snapshot under tasks/<id>/reference/
./bench/tasks/register.sh --id chorebot --path /abs/path --bundle symlink

# From git
./bench/tasks/register.sh --id mysvc --git https://github.com/org/repo.git

# Switch active task
# Edit config.yaml: active_task: chorebot
# Or one-off:
BENCH_TASK=chorebot ./bench/runners/prepare-run.sh runs/baseline/run-01
```

## Manifest schema (`task.yaml`)

| Field | Description |
|-------|-------------|
| `id` | Task identifier (directory name under `tasks/`) |
| `mode` | `greenfield` — build from SPEC in run dir; `brownfield` — copy existing repo into `workspace/` |
| `language` | `go` today (reserved for future) |
| `spec` | Agent-facing spec file relative to task dir (usually `SPEC.md`) |
| `go.module` | Module path from `go.mod` (used for grader `replace`) |
| `go.grader_dir` | Hidden tests directory (default `grader`) |
| `source.type` | `bundled` \| `local` \| `git` |
| `source.local_path` | Absolute path for brownfield local repos |
| `workspace.strategy` | `copy_per_run` (default), `git_worktree`, or `in_place` |
| `workspace.subdir` | Brownfield working tree under each run (default `workspace`) |

### Example: bundled greenfield (Uber-Eats)

```yaml
id: uber-eats
mode: greenfield
source:
  type: bundled
go:
  module: uber-eats
```

### Example: brownfield local service

```yaml
id: chorebot
mode: brownfield
source:
  type: local
  local_path: /Users/you/Projects/chorebot
workspace:
  strategy: copy_per_run
  subdir: workspace
go:
  module: chorebot
```

## What agents see

Each prepared run contains:

- `SPEC.md` — feature goal (copied from the task)
- `RUN_INSTRUCTIONS.md` — where to work, module name, safety rules
- `workspace/` — brownfield only: rsync copy of `local_path` (not the hidden grader)

Agents must **not** read `tasks/<id>/grader/` or bundled `reference/` trees.

## Grading

`bench/grade/grade.sh` patches the task grader’s `replace <module> =>` to point at the run artifact, then runs `go build`, `go vet`, and `go test ./acceptance/...`.

Pluggable **workspace** is automatic; pluggable **grading** requires you to author acceptance tests per service (or extend the register template smoke test).

## Safety

| Strategy | Behavior |
|----------|----------|
| `copy_per_run` | **Recommended.** Each run gets an isolated `runs/<arm>/run-NN/workspace/` copy via `rsync`. |
| `in_place` | Agent edits `source.local_path` directly. Requires `register.sh --in-place --i-understand-mutates-repo`. |

`.gitignore` excludes `runs/**/workspace/` from version control.

## Validation without an LLM

```bash
./bench/runners/validate-pipeline.sh
```

Grades `REF_PATH` from the manifest (bundled `reference/` or `local_path`) against the active task grader.

## Resolver API

```bash
python3 bench/lib/resolve_task.py --json
source bench/lib/resolve-task.sh   # exports TASK_ID, TASK_MODE, GO_MODULE, REF_PATH, ...
```
