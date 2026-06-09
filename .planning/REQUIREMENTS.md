# Requirements — measurable outcomes

## R1 — External quality gate

Code arms must be scored by **hidden acceptance tests** (or service-specific oracle), not agent self-report or GSD verify alone.

- **Status:** Implemented (`tasks/<id>/grader/`, `bench/grade/grade.sh`).

## R2 — Three comparable arms

Same feature spec must be runnable under `baseline`, `gsd`, and `recipe` with frozen config (`config.yaml`).

- **Status:** `baseline` + `gsd` implemented; `recipe` pending.

## R3 — Phase and delivery metrics

Capture per run:

- Time per phase (structured arms).
- Time to first human approval.
- Post-approval modification count.
- Total feature delivery time.
- Cost (stretch): tokens/invocations when available.

- **Status:** Schema + hand template; stamp pipeline for recipe pending.

## R4 — Immutable stamps (recipe arm)

Each recipe step emits timestamped, append-only marks linkable to tracker issues (Jira/GitHub).

- **Status:** Schema defined; emitter + Jira integration pending.

## R5 — Feature pilot sequence

- **Feature A:** Baseline metrics from already-shipped feature (manual capture file).
- **Feature B:** Vanilla GSD run(s) → document gaps → add recipe customizations.
- **Feature C:** Same feature, three methods, three operators (documented assignment).

- **Status:** Process documented; Agent Studio task registration pending.

## R6 — Compounding evidence

Across successive features, show downward trend in phase time and post-approval rework on recipe arm.

- **Status:** Requires completed Feature B/C runs + stamp history.

## R7 — Reporting honesty

Published numbers only from completed runs with `live_agent: true` (or explicit anchor imports).

- **Status:** Partial (`aggregate.py` distinguishes live vs oracle).
