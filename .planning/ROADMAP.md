# Roadmap — harness → full experiment

> **Reframe (current direction):** the goal is a more optimal GSD, proven by KPIs.
> The unconditional first build is the **arm-agnostic KPI instrument**
> ([bench/capture/stamp.schema.json](../bench/capture/stamp.schema.json),
> [bench/runners/emit-stamp.sh](../bench/runners/emit-stamp.sh),
> [bench/report/kpi.py](../bench/report/kpi.py)). Tracker bridge and the
> `.sdlc/patterns/` convention are **candidate optimizations** that ship only if
> they move a KPI. See [docs/SDLC-BLUEPRINT.md](../docs/SDLC-BLUEPRINT.md).

## Phase 0 — Done (v0 harness)

- [x] Pluggable tasks + hidden grader
- [x] `baseline` and `gsd` arms, `runs/` / `results/` layout
- [x] GSD product context + Cursor install (standard profile)
- [x] Experiment agenda documented

## Phase 1 — Metrics layer (next)

**Goal:** Same simple metrics on all arms; recipe-ready stamp format.

| Task | Owner hint | Deliverable |
|------|------------|-------------|
| 1.1 | Eng | `bench/capture/phase-metrics.template.json` + `log-phase-metrics.sh` wired in RUNBOOK |
| 1.2 | Eng | Extend `metadata.json` with `phase_metrics`, `reopen_count`, `delivery_time_sec` |
| 1.3 | PO | `features/feature-a-baseline.json` template for shipped Feature A anchor |
| 1.4 | Eng | `aggregate.py` — surface delivery metrics alongside grader pass/fail |

## Phase 2 — Agent Studio pilot task

**Goal:** Real service registered; three comparable feature specs.

| Task | Deliverable |
|------|-------------|
| 2.1 | Register service repo via `bench/tasks/register.sh` |
| 2.2 | `tasks/<feature-id>/SPEC.md` per pilot feature (A anchor doc only; B/C executable) |
| 2.3 | Grader or smoke acceptance aligned with service’s real quality bar |
| 2.4 | PO signs off feature comparability (scope, dependencies) |

## Phase 3 — Recipe arm (Feature B)

**Goal:** Close vanilla gaps for PRD→stories (then next steps).

| Task | Deliverable |
|------|-------------|
| 3.1 | `runs/recipe/` arm in `init-all-runs.sh`, `finalize-run.sh` docs |
| 3.2 | `bench/recipe/` — PRD template, validator stubs, KB seed layout |
| 3.3 | `bench/recipe/emit-stamp.sh` — append stamp JSONL per run |
| 3.4 | Jira: pull EPIC, create sub-issues, stamp transitions (Atlassian MCP or REST skill) |
| 3.5 | Cursor skills wrapping recipe step (thin; orchestration stays GSD) |

See [docs/RECIPE-STEP-PRD-TO-STORIES.md](../docs/RECIPE-STEP-PRD-TO-STORIES.md).

## Phase 4 — Feature C head-to-head

| Task | Deliverable |
|------|-------------|
| 4.1 | Single SPEC copied to three run dirs; operator assignment recorded in metadata |
| 4.2 | Comparison report section: grader + phase metrics + stamps (recipe only) |
| 4.3 | Retrospective: gaps closed in B → checklist for next lifecycle step |

## Phase 5 — Compounding proof

| Task | Deliverable |
|------|-------------|
| 5.1 | KB write-back from recipe research step |
| 5.2 | Bank misses → new checks/skills in `bench/recipe/upgrades/` |
| 5.3 | Trend chart or table across Feature B → C → next |

---

## Immediate actions (this week)

Command reference: [docs/GSD-COMMANDS.md](../docs/GSD-COMMANDS.md). **Live GSD tutorial (you run skills):** [docs/GSD-TUTORIAL.md](../docs/GSD-TUTORIAL.md) + sandbox `~/Projects/gsd-tutorial-sandbox`.

1. Run **Feature B** vanilla GSD on pilot PRD; log gaps using [docs/RECIPE-STEP-PRD-TO-STORIES.md](../docs/RECIPE-STEP-PRD-TO-STORIES.md).
2. Fill **Feature A** anchor file when Agent Studio confirms shipped feature id.
3. Complete at least one **live** `gsd` + `baseline` run on current task to validate metrics + grader path.
4. Pick tracker (Jira vs GitHub) for recipe stamps before implementing Phase 3.4.
