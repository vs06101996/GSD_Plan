# Recipe step: PRD (EPIC) → engineering-ready stories

Reference walkthrough for **Feature B** — where vanilla GSD gaps become recipe customizations. Operator: product owner (e.g. Prabu).

---

## Vanilla GSD — gaps

| Step | What happens | Gap |
|------|--------------|-----|
| Feed PRD | Re-key into interview or ingest → `.planning`; unlinked from live tracker issue | No start stamp; not SSOT |
| Research | GSD researches domain | KB not read reliably; findings not written back |
| Review phases | GSD proposes phases; PO validates story-shape and coverage | Coverage is agent’s claim; manual reshape |
| Approve | PO approves roadmap; opens tracker issues manually | Timing/rework hand-logged; no immutable KPI trail |

---

## Recipe — gaps closed

| Step | What happens | Stamp / artifact |
|------|--------------|------------------|
| Feed PRD | Pull EPIC from tracker; structural + semantic template validation | `started` on live issue |
| Research | Read seeded KB first; chase gaps only; propose KB updates | KB delta proposals |
| Review phases | Story-shaped phases; deterministic + semantic check vs EPIC | `review-ready` |
| Approve | Create linked, tagged sub-issues with acceptance criteria | `engineering-ready` |

**Template:** ships with recipe. **KB:** team-seeded convention.

---

## What the stamps measure

| KPI | From stamps |
|-----|-------------|
| Time to first approval | `started` → `engineering-ready` (or via `review-ready`) |
| Agent + tooling vs human review | `started` → `review-ready` vs `review-ready` → `engineering-ready` |
| Total loop time | `started` → settled |
| Quality | Count of reopens after `engineering-ready` |

Stamps are immutable and emitted during the loop — not editable self-reports. Schema: [bench/capture/stamp.schema.json](../bench/capture/stamp.schema.json).

---

## Repeat the move

Same pattern for every lifecycle step (story→tasks, design, tests, build, review):

1. What does the agent need to **stop guessing**? → check, skill, template, or KB entry.
2. What **mark** should the step leave? → timestamp stamp the report can read.

Teams inherit the **move**, not a finished recipe — run it where their work is weakest first.
