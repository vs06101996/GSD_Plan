# Benchmarking Feature Delivery with Coding Agents

An experiment: can we deliver features faster, at a quality bar we trust, by equipping a coding agent with better knowledge and validation tooling across the whole lifecycle?

**Reporting rule:** This document and all derived reports state only numbers we have actually measured.

**Build blueprint:** [docs/SDLC-BLUEPRINT.md](SDLC-BLUEPRINT.md) — the arm-agnostic KPI instrument (the unconditional first build) and the measure-then-optimize method.

---

## Executive summary

The hard part is no longer getting an agent to write code. It is knowing whether building features this way is **faster**, at a **quality we trust**, and whether it **gets better over time**. Today that is a gut feeling, not a measurement.

**Three gaps today (invisible without instrumentation):**

| Gap | Symptom |
|-----|---------|
| Velocity | “Feels faster” — not measured |
| Quality | Rework, defects, incidents — often seen late |
| Improvement | No proof the approach compounds |
| Comparability | Same ticket, different operator/tool → irreproducible |

**Root cause (two missing pieces):**

1. **Self-graded work** — agent says tests pass; team says it was faster; no external ground truth.
2. **Unrecorded work** — steps leave no durable, comparable trail.

**The recipe** closes both: external checks + immutable marks in the team tracker (GitHub, Jira). Velocity and quality become numbers, not gut feel.

**Modest bet:** Treat the agent as a newly joined engineer — team knowledge + tools to check its own work. Every miss becomes a durable upgrade (check, skill, KB entry) the whole team inherits.

**Pilot:** Agent Studio provides one contained real service — ~3 comparable features, one already shipped to anchor baseline. Volunteers: two engineers + one product owner, time-boxed. Human-approved checkpoints; nothing auto-merged.

**Success:** Quality-gated velocity gain over baseline, improving trend across successive features, defect rate at or below baseline. Earned path toward tracker-driven autonomy (Symphony-class), not assumed.

---

## Three ways to build (rungs)

Same feature lifecycle: intent → stories → design → tests → implementation → review. What differs is **who carries the process**.

| Rung | Name | Who carries it | Measurement |
|------|------|----------------|-------------|
| 1 | **Baseline** | Human orchestrates (vibe or spec-driven); result varies by operator | Hand-logged times + rework |
| 2 | **Vanilla GSD** | Mature orchestrator (GSD out of the box); repeatable discipline | Hand-logged times + rework |
| 3 | **Recipe** | GSD + specialization (KB, templates, deterministic/semantic validators) + **automatic stamps** in tracker | Stamps → gaps = KPIs; grader/oracle where applicable |

**Headline metric:** **Quality-gated feature delivery velocity** — approved intent → approved result that **holds** (fast only counts if we do not reopen/rework).

---

## Feature sequence (pilot design)

| Feature | Purpose |
|---------|---------|
| **A** | Baseline anchor — already-shipped feature; known delivery time + post-ship defects |
| **B** | Build the recipe — volunteer team runs vanilla GSD, closes gaps with customizations as they go |
| **C** | Head-to-head — recipe assembled; three operators each use one method on the **same** feature (directional, not statistical) |

**Feature C assignment (by design):** PO on recipe; engineers on vibe and vanilla GSD. Method effect is entangled with operator — credibility from per-step mechanism, not sample size.

---

## Metrics (deliberately simple)

| Metric | Definition |
|--------|------------|
| Time per phase | Structured arms only (GSD, recipe) |
| Time to first approval | Loop duration until human “yes” |
| Post-approval modifications | Reopens after approval — **quality bar** |
| Total feature delivery time | End-to-end across phases |
| Cost (stretch) | Tokens/invocations where exposed; capture when possible |

**Recipe arm:** Tracker stamps emit as the loop runs (`started` → `review-ready` → `engineering-ready` → …). KPIs = gaps between stamps + reopen count.

**Baseline / vanilla:** Same metrics, **logged by hand** ([bench/capture/phase-metrics.template.json](../bench/capture/phase-metrics.template.json)).

**Compounding:** Across successive features, phase time and post-approval rework should trend down — measured outcome for rung 3 only if the loop was recorded.

---

## Canonical recipe step (PRD → engineering-ready stories)

Worked example for Feature B. Detail: [RECIPE-STEP-PRD-TO-STORIES.md](RECIPE-STEP-PRD-TO-STORIES.md).

| Step | Vanilla GSD gap | Recipe closure |
|------|-----------------|----------------|
| Feed PRD | Re-key; `.planning` unlinked from tracker; no start stamp | Pull EPIC from tracker; template validate; stamp `started` |
| Research | Unreliable KB read; no write-back | KB-first; gap-only research; proposed KB updates |
| Review phases | PO validates coverage by hand | Story-shaped output; deterministic + semantic oracles; stamp `review-ready` |
| Approve | Manual tracker issues + hand timing | Linked sub-issues with AC; stamp `engineering-ready` |

Pre-set template ships with recipe; seeded KB is team convention.

---

## Relation to this repository

| Agenda concept | Repo today | Target |
|----------------|------------|--------|
| Rung 1 baseline | `runs/baseline/` | Keep; add phase metrics capture |
| Rung 2 vanilla GSD | `runs/gsd/` | Keep; hand metrics + GSD session notes |
| Rung 3 recipe | *Not yet* | `runs/recipe/`, stamps, Jira/GitHub hooks, KB + validators |
| External quality gate | Hidden grader (`tasks/*/grader/`) | Align with “trust code, not self-grade” |
| Real service pilot | Pluggable `tasks/<id>/` | Register Agent Studio service + 3 features |
| Feature A anchor | *Manual* | `features/feature-a-baseline.json` capture |

Implementation plan: [.planning/ROADMAP.md](../.planning/ROADMAP.md).
