# GSD live tutorial — operator playbook

Walk through the **full GSD command catalog** on a sibling sandbox repo. Each lab: **you invoke the skill** → inspect artifacts → check pass criteria → log in `tutorial-log.md`.

## Critical rule

| Who | Action |
|-----|--------|
| **You** | Run every `gsd-*` skill in Cursor Agent |
| **Agent / automation** | Must **not** invoke GSD workflows; may only author docs, scaffold files, and review artifacts after you run commands |

Setup: [GSD-TUTORIAL-SANDBOX.md](GSD-TUTORIAL-SANDBOX.md). Reference: [GSD-COMMANDS.md](GSD-COMMANDS.md).

**Real-world workflows (PRD-only greenfield vs brownfield feature/bug):** [GSD-TUTORIAL-PLAYBOOKS.md](GSD-TUTORIAL-PLAYBOOKS.md).

---

## Per-lab ritual

1. **Before:** `git status`; read `.planning/STATE.md` position  
2. **Run:** copy the invoke line into Agent (you execute)  
3. **After:** open listed paths  
4. **Pass:** all bullets in Pass criteria  
5. **Log:** one row in `~/Projects/gsd-tutorial-sandbox/tutorial-log.md`

---

## Session 0 — Bootstrap (you run)

**Prereq:** Sandbox open in Cursor, GSD `full` profile installed.

| Step | You invoke | Pass criteria |
|------|------------|---------------|
| 0.1 | `gsd-new-project` | `.planning/PROJECT.md`, `REQUIREMENTS.md`, `ROADMAP.md`, `STATE.md`, `config.json` |
| 0.2 | `gsd-discuss-phase 1` | `phases/01-*/CONTEXT.md` (or skipped if PRD path used later) |
| 0.3 | `gsd-plan-phase 1` | `phases/01-*/01-01-PLAN.md` |
| 0.4 | `gsd-execute-phase 1` | Code on disk; task commits; `go test ./...` OK |
| 0.5 | `go test ./...` (terminal, you) | Tests green |

**Stop here** before Module 1 unless Phase 1 is green.

---

## Module 1 — Orientation

| # | You invoke | Open after | Pass |
|---|------------|------------|------|
| 1.1 | `gsd-help` | — | Help text renders |
| 1.2 | `gsd-help --brief` | — | Short list |
| 1.3 | `gsd-help --full` | — | Long reference |
| 1.4 | `gsd-help debug` | — | Debug section only |
| 1.5 | `gsd-progress` | `STATE.md`, `ROADMAP.md` | Shows phase position |
| 1.6 | `gsd-stats` | — | Stats output |
| 1.7 | `gsd-surface list` | — | Lists clusters/skills |

---

## Module 2 — Core loop (Phase 2)

| # | You invoke | Open after | Pass |
|---|------------|------------|------|
| 2.1 | `gsd-discuss-phase 2` | `phases/02-*/CONTEXT.md` | Context file exists |
| 2.2 | `gsd-spec-phase 2` | phase `SPEC.md` if created | Spec or documented skip |
| 2.3 | `gsd-plan-phase 2` | `02-01-PLAN.md` | Plan with tasks |
| 2.4 | `gsd-plan-phase 2 --research-phase 2` | `RESEARCH.md` | Research only, no full replan |
| 2.5 | `gsd-plan-phase 2 --prd docs/phase2-prd.md` | CONTEXT from PRD | Discuss skipped |
| 2.6 | `gsd-mvp-phase 2` then `gsd-plan-phase 2` | MVP-shaped plan | Vertical slice in plan |
| 2.7 | `gsd-execute-phase 2` | source + commits | API code exists |
| 2.8 | `gsd-execute-phase 2 --wave 1` | — | Only wave 1 ran |
| 2.9 | `gsd-verify-work 2` | UAT / fix notes | Session completed |
| 2.10 | `gsd-progress --next` | — | Suggests next command |

---

## Module 3 — Fast paths and capture

| # | You invoke | Open after | Pass |
|---|------------|------------|------|
| 3.1 | `gsd-quick add health check endpoint` | `.planning/quick/` | PLAN + execution |
| 3.2 | `gsd-fast fix README typo` | git log | Commit, no quick PLAN dir |
| 3.3 | `gsd-capture remember pagination` | `todos/pending/` | Todo file |
| 3.4 | `gsd-capture --note tried redis cache` | `notes/` | Note file |
| 3.5 | `gsd-capture --list` | — | Lists todos |
| 3.6 | `gsd-capture --seed add webhooks when events ship` | seeds | Seed file |
| 3.7 | `gsd-capture --backlog dark mode` | ROADMAP 999.x | Backlog entry |
| 3.8 | `gsd-explore` | explore artifact | Ideation output |
| 3.9 | `gsd-spike can we use sqlite` | `.planning/spikes/` | Spike dir + verdict |
| 3.10 | `gsd-spike --wrap-up` | skills or WRAP-UP | Wrap-up summary |
| 3.11 | `gsd-sketch task list UI` | `.planning/sketches/` | HTML variants |
| 3.12 | `gsd-sketch --wrap-up` | sketch skill | Wrap-up |

---

## Module 4 — Roadmap and session

| # | You invoke | Open after | Pass |
|---|------------|------------|------|
| 4.1 | `gsd-phase Add metrics phase` | `ROADMAP.md` | New phase appended |
| 4.2 | `gsd-phase --insert 2 Hotfix auth` | `ROADMAP.md` | Phase 2.1 exists |
| 4.3 | `gsd-phase --edit 3` | `ROADMAP.md` | Phase 3 fields updated |
| 4.4 | `gsd-pause-work` | `.continue-here`, `STATE.md` | Handoff present |
| 4.5 | `gsd-pause-work --report` | `.planning/reports/` | Report file |
| 4.6 | `gsd-resume-work` | — | Resumes from STATE |

---

## Module 5 — Brownfield and knowledge

| # | You invoke | Open after | Pass |
|---|------------|------------|------|
| 5.1 | `gsd-map-codebase` | `.planning/codebase/*.md` | 7 docs or subset |
| 5.2 | `gsd-map-codebase --fast` | codebase/ | Lighter map |
| 5.3 | `gsd-graphify build` | `.planning/graphs/` | **Skip OK** if graphify CLI missing |
| 5.4 | `gsd-graphify query task` | — | Query result or skip |
| 5.5 | `gsd-ingest-docs docs` | planning merge | Ingest report |
| 5.6 | `gsd-import` (use `docs/sample-external-plan.md`) | conflict output | Import summary |
| 5.7 | `gsd-extract-learnings 1` | learnings | Extracted content |
| 5.8 | `gsd-thread list` | threads | List or empty |

---

## Module 6 — Quality and review

| # | You invoke | Open after | Pass |
|---|------------|------------|------|
| 6.1 | `gsd-code-review 1 --depth=quick` | review output | Findings or clean |
| 6.2 | `gsd-review --phase 2` | `REVIEWS.md` | **Skip OK** without external CLIs |
| 6.3 | `gsd-plan-review-convergence 2` | convergence log | **Skip OK** without codex/gemini |
| 6.4 | `gsd-validate-phase 1` | validation report | Report exists |
| 6.5 | `gsd-secure-phase 2` | security notes | Notes exist |
| 6.6 | `gsd-add-tests 2` | `*_test.go` | New tests |
| 6.7 | `gsd-audit-uat` | audit output | UAT debt list |
| 6.8 | `gsd-debug list endpoint returns empty` | `.planning/debug/` | Debug session file |

---

## Module 7 — UI and AI specs

| # | You invoke | Open after | Pass |
|---|------------|------------|------|
| 7.1 | `gsd-ui-phase 3` | `UI-SPEC.md` | UI spec |
| 7.2 | `gsd-ui-review 3` | review doc | UI review |
| 7.3 | `gsd-ai-integration-phase` | `AI-SPEC.md` | **Skip OK** if no AI phase |
| 7.4 | `gsd-eval-review` | `EVAL-REVIEW.md` | **Skip OK** if N/A |

---

## Module 8 — Milestones and ship

| # | You invoke | Open after | Pass |
|---|------------|------------|------|
| 8.1 | `gsd-execute-phase 3` | phase 3 code | Phase 3 done first |
| 8.2 | `gsd-verify-work 3` | UAT | Verified |
| 8.3 | `gsd-complete-milestone 0.1.0` | `milestones/` | Archived milestone |
| 8.4 | `gsd-new-milestone v0.2` | ROADMAP | New milestone phases |
| 8.5 | `gsd-milestone-summary` | summary doc | Summary exists |
| 8.6 | `gsd-ship 2` | PR URL | **Skip OK** without `gh auth` |
| 8.7 | `gsd-pr-branch` | branch | **Skip OK** without gh |
| 8.8 | `gsd-cleanup` | `milestones/*-phases/` | Phases archived |
| 8.9 | `gsd-review-backlog` | ROADMAP | Backlog reviewed |

---

## Module 9 — Workspace and orchestration

| # | You invoke | Pass |
|---|------------|------|
| 9.1 | `gsd-workspace --list` | Lists workspaces |
| 9.2 | `gsd-workspace --new tutorial-ws` | Workspace created (optional) |
| 9.3 | `gsd-workstreams` | Workstream status |
| 9.4 | `gsd-manager` | Manager UI / flow started |
| 9.5 | `gsd-inbox` | **Skip OK** without gh repo |
| 9.6 | `gsd-autonomous --only 3` | **Careful:** yolo; only if Phase 3 planned |

---

## Module 10 — Config and maintenance

| # | You invoke | Pass |
|---|------------|------|
| 10.1 | `gsd-settings` | config touched |
| 10.2 | `gsd-config --profile budget` | Profile updated |
| 10.3 | `gsd-config --advanced` | Advanced keys visible |
| 10.4 | `gsd-config --integrations` | Integrations section |
| 10.5 | `gsd-update` | Version compare (no install unless you confirm) |
| 10.6 | `gsd-health` | Health report |
| 10.7 | `gsd-health --repair` | Repairs if needed |
| 10.8 | `gsd-forensics last execute failed` | Forensics doc |
| 10.9 | `gsd-undo --last 1` | **Throwaway branch only** |
| 10.10 | `gsd-docs-update` | Docs generated |

---

## Module 11 — Meta routers

You invoke; confirm routing to the right skill (full execution optional).

| # | You invoke |
|---|------------|
| 11.1 | `gsd-context map the codebase` |
| 11.2 | `gsd-ideate spike websocket tasks` |
| 11.3 | `gsd-manage show workstreams` |
| 11.4 | `gsd-project milestone status` |
| 11.5 | `gsd-quality code review phase 2` |
| 11.6 | `gsd-workflow plan phase 3` |
| 11.7 | `gsd-progress --do audit uat debt` |

---

## Module 12 — Edge and beta

| # | You invoke | Notes |
|---|------------|-------|
| 12.1 | `gsd-ultraplan-phase 2` | Beta; optional |
| 12.2 | `gsd-audit-milestone` | After milestone |
| 12.3 | `gsd-audit-fix --source audit-uat --dry-run` | Dry run only |
| 12.4 | `gsd-profile-user` | Profile artifacts |
| 12.5 | `gsd-phase --remove` | **Only** on future unstarted phase |

---

## Skip ledger (deps)

Log `skip` + reason in `tutorial-log.md`:

| Command(s) | Reason |
|------------|--------|
| `gsd-review`, `gsd-plan-review-convergence` | No gemini/codex/claude CLI |
| `gsd-ship`, `gsd-inbox`, `gsd-pr-branch` | No `gh auth` |
| `gsd-graphify` | graphify CLI / config off |
| `gsd-ultraplan-phase` | Beta / optional |
| GSD runtime hooks | Not on Cursor — see Cursor `hooks.json` separately |

---

## After the tour

- Copy gaps into `gsd-benchmark/bench/recipe/` for experiment Feature B  
- Compare notes with [EXPERIMENT-AGENDA.md](EXPERIMENT-AGENDA.md) recipe step (PRD → stories)

---

## tutorial-log.md format

```markdown
| Date | Module | Command | Result | Notes |
|------|--------|---------|--------|-------|
| 2026-06-04 | 0 | gsd-new-project | pass | |
```
