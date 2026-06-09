# Benchmark context

## Experiment (three rungs)

Full agenda: [docs/EXPERIMENT-AGENDA.md](../docs/EXPERIMENT-AGENDA.md). Implementation plan: [ROADMAP.md](ROADMAP.md).

| Rung | Arm dir | Who carries the job | Metrics |
|------|---------|---------------------|---------|
| 1 Baseline | `runs/baseline/` | Human + agent (vibe/spec) | Hand: `phase-metrics.template.json` |
| 2 Vanilla GSD | `runs/gsd/` | GSD orchestrator | Hand + GSD session notes |
| 3 Recipe | `runs/recipe/` | GSD + `bench/recipe/` customizations | Stamps (`emit-stamp.sh`) + hand where needed |

**Quality gate (all rungs):** Hidden grader — not GSD verify. See [docs/GSD-PRODUCT-CONTEXT.md](../docs/GSD-PRODUCT-CONTEXT.md).

**Pilot features:** A = shipped anchor (`features/feature-a-baseline.template.json`); B = build recipe on vanilla GSD; C = same feature, three methods (directional).

## v0 harness (coding task)

- **Baseline:** Cursor Agent + `SPEC.md` only.
- **GSD:** Same spec + gsd-new-project → plan → execute → verify (advisory).
- **Definition of done:** `tasks/<id>/grader/` via `finalize-run.sh`.

## Operator constraints

| Setting | Choice |
|---------|--------|
| Profile | `standard` (local); prefer core/standard over full |
| Config | `bench/planning/config.yolo.template.json` → `.planning/config.json` |
| Workspace | Fresh `runs/<arm>/run-NN/` per attempt |
| Invoke | Skill names, not `/gsd-*` slash commands |
| Compare | Same spec, pinned model; baseline vs GSD vs recipe |

## Scripts

```bash
./bench/runners/log-phase-metrics.sh gsd run-01 bench/capture/phase-metrics.template.json
./bench/runners/emit-stamp.sh recipe run-01 started prd-to-stories EPIC-1
```
