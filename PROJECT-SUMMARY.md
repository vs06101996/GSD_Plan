# Project Summary — GSD Benchmark

Overview of the GSD vs baseline benchmark: what we measure, how the harness works (including **pluggable tasks**), what was built, current results, and next steps. This repo is the benchmark harness only.

---

## 1. Agenda

| Goal | Description |
|------|-------------|
| **Empirical benchmark** | Test three rungs — **baseline** (human-orchestrated), **vanilla GSD**, **recipe** (GSD + KB/validators + tracker stamps) — on comparable features, with an external grader and simple delivery metrics. |
| **Objective grading** | Pass/fail from hidden Go tests — not subjective review. |
| **Cursor-only workflow** | No Claude Code CLI — invoke GSD skills in Agent; grade in the terminal. |
| **Reproducible runs** | Isolated run folders, frozen config, N=5 per arm (planned). |

---

## 2. Approach

| Design choice | Rationale |
|---------------|-----------|
| **Default task** | [Uber-Eats](https://github.com/vickky06/Uber-Eats) greenfield (`tasks/uber-eats/`, bundled reference) |
| **Pluggable tasks** | `tasks/<id>/task.yaml` — Go (`go.mod`) or Scala/SBT (`build.sbt`, e.g. **occm**) via `register.sh` |
| **Greenfield** | Agent gets `SPEC.md` only; builds in `runs/<arm>/run-NN/` |
| **Brownfield** | `copy_per_run` copies `source.local_path` → `runs/.../workspace/`; agent never sees `grader/` |
| **Arms** | **baseline** / **gsd** / **recipe** — see [docs/EXPERIMENT-AGENDA.md](docs/EXPERIMENT-AGENDA.md) |
| **Grading** | Hidden acceptance tests in `tasks/uber-eats/grader/` (14 tests); `go build`, `go vet`, `go test` |
| **Runs** | N=5 per arm; ten workspaces prepared under `runs/` and `results/` |
| **Runtime** | Cursor skills (`gsd-new-project`, etc.), not Claude `/slash` commands |

**Context:** GSD is the [open-gsd/gsd-core](https://github.com/open-gsd/gsd-core) workflow layer (plan → execute in fresh contexts, `.planning/` artifacts). This project measures **outcomes**, not GSD’s internal architecture. Full product findings: [docs/GSD-PRODUCT-CONTEXT.md](docs/GSD-PRODUCT-CONTEXT.md). Operator constraints for the GSD arm: [.planning/CONTEXT.md](.planning/CONTEXT.md).

---

## 3. Steps taken

### Benchmark setup

1. **Workspace:** `config.yaml`, directory layout, Uber-Eats cloned to `tasks/uber-eats/reference/` (grading oracle only)
2. **SPEC.md:** Agent-facing PRD (no test code, no solution paths)
3. **Grader:** `tasks/uber-eats/grader/` — 14 acceptance tests; **reference passes 14/14**
4. **Harness:** `bench/grade/grade.sh`, `bench/lib/resolve-task.sh`, runners, `bench/tasks/register.sh`, `bench/report/aggregate.py`, [docs/TASKS.md](docs/TASKS.md)
5. **GSD install:** v1.2.0 via git clone (`npm` TLS blocked `npx`); **Cursor** `--cursor --local --profile=standard` and `~/.cursor/skills/gsd-*`
6. **Pipeline validation:** Reference oracle on `results/*/run-01` — grading path confirmed
7. **Docs:** `README.md`, `RUNBOOK.md`, `REPORT.md`, `bench/README.md`

### Live agent runs

| Step | Status |
|------|--------|
| Automated runs via `claude -p` | **Not used** — Cursor-only workflow |
| Cursor manual test in `runs/gsd/run-01` | **Prepared** — operator runs GSD skills, then `finalize-run.sh` |
| Full N=5 × baseline + GSD | **Pending** |

---

## 4. Results

### Benchmark (measurable)

| Metric | Result |
|--------|--------|
| Grader vs reference | **PASS** — 14/14 tests, build, vet |
| Grading pipeline (run-01 oracle) | **PASS** — validates tooling, **not** an LLM result |
| Live baseline runs | **0/5** completed |
| Live GSD runs | **0/5** completed |
| pass@5 (live agent) | **Not yet meaningful** |

### Environment

- `npx @opengsd/gsd-core` failed: npm `UNABLE_TO_GET_ISSUER_CERT_LOCALLY` — installed from `/tmp/gsd-core` clone instead.
- **19 GSD skills** on Cursor (standard profile); invoke by skill name in Agent.
- Automated shell runners optional; primary path is **RUNBOOK.md** (Cursor + terminal).

---

## 5. Conclusion

1. **The v0 benchmark is built and gradable** but **not yet executed** with live Cursor agents. We can answer: “Can we score outputs objectively?” — **yes**. We cannot yet answer: “Does GSD beat baseline?” — that needs completed runs in `runs/baseline/run-NN` and `runs/gsd/run-NN` plus `finalize-run.sh`.

2. **Open the prepared run dir, not `tasks/<id>/reference/` or `grader/`.** Greenfield: `runs/.../run-NN/`. Brownfield: `runs/.../run-NN/workspace/`.

3. **Next action (Cursor):**
   ```bash
   cd ~/Projects/gsd-benchmark
   ./bench/runners/validate-pipeline.sh
   ./bench/runners/prepare-run.sh runs/gsd/run-01
   ```
   In Cursor on `runs/gsd/run-01`: **gsd-new-project** → **gsd-plan-phase 1** → **gsd-execute-phase 1** → **gsd-verify-work 1**, then:
   ```bash
   ./bench/runners/finalize-run.sh gsd run-01
   cat results/gsd/run-01/grade.json
   ```
   Repeat for baseline (no GSD skills) and for `run-02` … `run-05` if you want pass@5.

4. In **REPORT.md**, use **“Passed (live agent only)”** — ignore run-01 passes that are only reference-oracle pipeline checks.

---

## Related files

| File | Contents |
|------|----------|
| [RUNBOOK.md](RUNBOOK.md) | Operator steps (Cursor + terminal) |
| [REPORT.md](REPORT.md) | Scorecard (`python3 bench/report/aggregate.py`) |
| [config.yaml](config.yaml) | Pinned benchmark settings (`active_task`) |
| [docs/TASKS.md](docs/TASKS.md) | Task manifest schema and registration |
| [docs/GSD-COMMANDS.md](docs/GSD-COMMANDS.md) | GSD skills/commands for Cursor (standard + full) |
| [docs/EXPERIMENT-AGENDA.md](docs/EXPERIMENT-AGENDA.md) | Full experiment agenda |
| [.planning/ROADMAP.md](.planning/ROADMAP.md) | Harness → pilot implementation plan |
| [docs/GSD-PRODUCT-CONTEXT.md](docs/GSD-PRODUCT-CONTEXT.md) | GSD Core findings |
| [.planning/CONTEXT.md](.planning/CONTEXT.md) | Operator + three-rung context |
| [07-benchmark-test-plan.md](file:///Users/vs72964/Projects/Repos/Personal/gsd-keel-research/07-benchmark-test-plan.md) | Detailed test design (personal notes path) |

*Last updated: June 2026*
