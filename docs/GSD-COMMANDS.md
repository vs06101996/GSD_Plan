# GSD commands — Cursor reference

GSD Core **@opengsd/gsd-core** (installed v1.2.0 in this repo). On **Cursor**, invoke by **skill name** in Agent chat (e.g. `gsd-plan-phase 1` or `@gsd-plan-phase`). Claude Code uses the same workflows as `/gsd-plan-phase` slash commands.

**Not a per-command CLI** — the agent runs workflows; `gsd-tools` is internal plumbing.

**This repo’s profile:** `standard` (~19 skills). Unlock the rest: `gsd-surface profile full` or reinstall with `--profile=full`.

Related: [GSD-PRODUCT-CONTEXT.md](GSD-PRODUCT-CONTEXT.md) · [EXPERIMENT-AGENDA.md](EXPERIMENT-AGENDA.md) · [.planning/ROADMAP.md](../.planning/ROADMAP.md)

---

## Installed here (standard — use today)

| Command | What it does |
|---------|----------------|
| **gsd-new-project** | Greenfield init: questions → optional research → REQUIREMENTS + ROADMAP + STATE + `config.json` |
| **gsd-discuss-phase** *N* | Before planning: vision, boundaries → `CONTEXT.md` (`--batch`, `--analyze`, `--power`, `--assumptions`) |
| **gsd-plan-phase** *N* | RESEARCH (optional) + PLAN.md + plan-check (`--prd`, `--ingest`, `--tdd`, `--mvp`, `--gaps`, `--research-phase`) |
| **gsd-execute-phase** *N* | Parallel waves, atomic commits, STATE/ROADMAP updates (`--wave`, `--gaps-only`, `--tdd`) |
| **gsd-verify-work** *N* | Conversational UAT from SUMMARYs; may create fix plans |
| **gsd-phase** | Add / insert / remove / edit ROADMAP phases (`--insert`, `--remove`, `--edit`) |
| **gsd-progress** | Status, what’s next, smart router (`--next`, `--forensic`, `--do "…"`) |
| **gsd-quick** | Ad-hoc task under `.planning/quick/` (`--full`, `--validate`, `--discuss`, `--research`) |
| **gsd-resume-work** | Restore context from STATE after a break |
| **gsd-pause-work** | Mid-phase handoff (`--report` → session summary) |
| **gsd-workspace** | Isolated workspaces (`--new`, `--list`, `--remove`) |
| **gsd-review** | Cross-AI plan review → REVIEWS.md (`--phase N`, `--all`, per-CLI flags) |
| **gsd-code-review** *N* | Phase code review (`--depth`, `--fix`, `--auto`) |
| **gsd-import** | External plan ingest + conflicts (`--from-gsd2` for legacy `.gsd/`) |
| **gsd-config** | Toggles, models, integrations (`--profile`, `--advanced`, `--integrations`) |
| **gsd-settings** | Interactive config (simpler than config) |
| **gsd-surface** | Skill profiles / clusters (`list`, `profile full`, `disable …`) |
| **gsd-update** | Upgrade + changelog (`--sync`, `--reapply`) |
| **gsd-help** | Help (`--brief`, `--full`, or topic e.g. `debug`) |

**Benchmark loop (vanilla GSD arm):**

```text
gsd-new-project → gsd-plan-phase 1 → gsd-execute-phase 1 → gsd-verify-work 1
→ ./bench/runners/finalize-run.sh gsd run-01
```

Grader pass/fail is **not** `gsd-verify-work` — use `bench/grade/grade.sh`.

---

## Profiles

| Profile | ~Skills | When |
|---------|---------|------|
| **core** | ~8 | Main loop only; lowest token overhead |
| **standard** | ~19 | **Active in this repo** |
| **full** | ~59–66 | Entire catalog below |

```bash
# In Agent chat:
gsd-surface profile full

# Or reinstall:
node /path/to/gsd-core/bin/install.js --cursor --local --profile=full
```

---

## Full catalog (full profile)

### Core lifecycle

| Command | What it does |
|---------|----------------|
| **gsd-new-project** | Initialize `.planning/` (PROJECT, REQUIREMENTS, ROADMAP, STATE, config) |
| **gsd-map-codebase** | Brownfield map → `.planning/codebase/` (`--fast`, `--focus`, `--query`) |
| **gsd-discuss-phase** *N* | Phase context before planning |
| **gsd-spec-phase** *N* | Phase SPEC.md (`--auto`, `--text`) |
| **gsd-plan-phase** *N* | PLAN.md + plan-check loop |
| **gsd-mvp-phase** *N* | Vertical-slice shaping → then plan |
| **gsd-ultraplan-phase** *N* | [Beta] Ultrapan in cloud, import back |
| **gsd-execute-phase** *N* | Execute plans (waves, subagents) |
| **gsd-verify-work** *N* | Conversational acceptance testing |
| **gsd-ship** *N* | PR from phase (`--draft`; needs `gh`) |
| **gsd-autonomous** | Run phases end-to-end (`--from`, `--to`, `--only`, `--interactive`) |

### Progress, session, fast paths

| Command | What it does |
|---------|----------------|
| **gsd-progress** | Status / route next step / `--do` smart router |
| **gsd-resume-work** | Resume session |
| **gsd-pause-work** | Pause + `.continue-here` |
| **gsd-quick** | Small task, GSD guarantees, skip optional agents |
| **gsd-fast** *"task"* | Inline trivial fix (≤3 files), no PLAN.md |
| **gsd-debug** *issue* | Persistent debug (survives clear); `--diagnose` one-shot |

### Roadmap & milestones

| Command | What it does |
|---------|----------------|
| **gsd-phase** | CRUD phases on ROADMAP |
| **gsd-new-milestone** *name* | New milestone flow |
| **gsd-complete-milestone** *ver* | Archive + git tag |
| **gsd-milestone-summary** | Summary for onboarding/review |
| **gsd-cleanup** | Archive phases to `milestones/` |
| **gsd-review-backlog** | Promote backlog → active |

### Capture & ideation

| Command | What it does |
|---------|----------------|
| **gsd-capture** | Todo from conversation |
| **gsd-capture** `--note` *text* | Quick note; `list` / `promote` |
| **gsd-capture** `--list` | Pending todos |
| **gsd-capture** `--seed` *idea* | Triggered idea for later milestones |
| **gsd-capture** `--backlog` *idea* | 999.x backlog parking lot |
| **gsd-explore** | Ideation before committing |
| **gsd-spike** *idea* | Feasibility spikes (`--quick`, `--wrap-up`) |
| **gsd-sketch** *idea* | HTML UI variants (`--quick`, `--wrap-up`) |

### Quality, review, audit

| Command | What it does |
|---------|----------------|
| **gsd-review** | External AI plan review |
| **gsd-plan-review-convergence** *N* | Replan until no HIGH concerns |
| **gsd-code-review** *N* | Code review on phase diff |
| **gsd-secure-phase** *N* | Security / threat retro check |
| **gsd-validate-phase** *N* | Nyquist validation gaps |
| **gsd-ui-review** *N* | Frontend visual audit |
| **gsd-eval-review** *N* | AI eval coverage audit |
| **gsd-add-tests** *N* | Tests from UAT + implementation |
| **gsd-audit-uat** | Cross-phase UAT debt |
| **gsd-audit-milestone** | Shipped vs requirements |
| **gsd-audit-fix** | Audit → fix pipeline (`--dry-run`) |

### Discovery, import, docs

| Command | What it does |
|---------|----------------|
| **gsd-import** | External plan + conflict detection |
| **gsd-ingest-docs** | Bootstrap `.planning/` from repo docs |
| **gsd-ai-integration-phase** | AI-SPEC.md for AI phases |
| **gsd-ui-phase** | UI-SPEC.md for frontend phases |
| **gsd-docs-update** | Project docs from codebase |

### Knowledge & intel

| Command | What it does |
|---------|----------------|
| **gsd-graphify** | Knowledge graph (`build`, `query`, `status`, `diff`) |
| **gsd-thread** | Context threads (`list`, `close`, `status`) |
| **gsd-extract-learnings** *N* | Decisions/lessons from phase |
| **gsd-profile-user** | Developer profile artifacts |
| **gsd-stats** | Phase/git/timeline stats |

### Workspace & orchestration

| Command | What it does |
|---------|----------------|
| **gsd-workspace** | Isolated workspaces |
| **gsd-workstreams** | Parallel workstreams |
| **gsd-manager** | Multi-phase control (`--analyze-deps`) |
| **gsd-inbox** | GitHub issue/PR triage |

### Git & shipping

| Command | What it does |
|---------|----------------|
| **gsd-pr-branch** | Clean PR branch (no `.planning/` commits) |
| **gsd-undo** | Revert GSD commits (`--last`, `--phase`, `--plan`) |

### Config, install, help

| Command | What it does |
|---------|----------------|
| **gsd-settings** | Interactive config |
| **gsd-config** | Full config surface |
| **gsd-surface** | Profiles / clusters |
| **gsd-update** | Version upgrade |
| **gsd-help** | Help tiers / topics |

### Meta routers

| Command | Routes to |
|---------|-----------|
| **gsd-context** | map-codebase, graphify, docs, learnings |
| **gsd-ideate** | explore, sketch, spike, spec, capture |
| **gsd-manage** | workstreams, thread, update, ship, inbox |
| **gsd-project** | milestones, audits, summary |
| **gsd-quality** | code-review, debug, audits, security, ui |
| **gsd-workflow** | discuss, plan, execute, verify, phase |

### Diagnostics

| Command | What it does |
|---------|----------------|
| **gsd-health** | Planning dir health (`--repair`, `--context`) |
| **gsd-forensics** | Failed-run post-mortem |

---

## High-value flags

| Parent | Flags | Effect |
|--------|-------|--------|
| **gsd-plan-phase** | `--prd file.md` | Skip discuss; PRD locks context |
| **gsd-plan-phase** | `--research-phase N` | Research only → RESEARCH.md |
| **gsd-plan-phase** | `--ingest path` | Pre-load ADRs/PRDs |
| **gsd-plan-phase** | `--tdd` / `--mvp` | TDD or MVP-shaped plans |
| **gsd-execute-phase** | `--wave 2` | Single wave |
| **gsd-progress** | `--do "…"` | Natural-language command router |
| **gsd-capture** | `--note` / `--list` / `--seed` / `--backlog` | Notes, todos, seeds, backlog |
| **gsd-update** | `--sync` / `--reapply` | Sync skills / reapply patches |
| **gsd-pause-work** | `--report` | Session report in `.planning/reports/` |
| **gsd-config** | `--profile budget` | Model profile switch |

---

## Mapping to the three-run experiment

| Rung | Commands to lean on | Measurement |
|------|---------------------|-------------|
| **Baseline** | None (agent + SPEC only) | Hand metrics + grader |
| **Vanilla GSD** | new-project → plan → execute → verify-work | Hand metrics + grader |
| **Recipe** | Above + custom skills/scripts (tracker pull, validators, stamps) | Stamps + grader |

Planned recipe additions (not GSD built-ins): pull EPIC from Jira/GitHub, template validator, `emit-stamp.sh` — see [.planning/ROADMAP.md](../.planning/ROADMAP.md).

---

## Live tutorial (sandbox)

**You run every GSD command** — agents do not invoke GSD workflows.

1. Open `~/Projects/gsd-tutorial-sandbox` in Cursor  
2. [GSD-TUTORIAL-SANDBOX.md](GSD-TUTORIAL-SANDBOX.md) — install full profile  
3. [GSD-TUTORIAL-PLAYBOOKS.md](GSD-TUTORIAL-PLAYBOOKS.md) — Case 1 (new + PRD) / Case 2 (brownfield)  
4. [GSD-TUTORIAL.md](GSD-TUTORIAL.md) — Modules 0–12 with pass criteria  
5. Log in sandbox `tutorial-log.md`

---

## Real-time usage plan (benchmark pilot)

Use this doc when running the Agent Studio pilot:

1. **Feature A** — Document only; no GSD (historical anchor).
2. **Feature B** — `gsd-discuss-phase` / `gsd-plan-phase --prd` on tracker EPIC → `gsd-execute-phase` → log gaps → add recipe pieces under `bench/recipe/`.
3. **Feature C** — Same SPEC; assign arm per operator; compare phase metrics + `finalize-run.sh`.
4. **Before Feature B** — Optional dry run on `runs/gsd/run-01` with the standard loop above.
5. **Unlock as needed** — `gsd-capture --note`, `gsd-import`, `gsd-graphify` via `gsd-surface profile full` when building KB/research steps.

Pin in `config.yaml`: model, profile, `mode: yolo` in run `.planning/config.json` after init.

---

## Cursor vs Claude Code

| | Claude Code | Cursor |
|---|-------------|--------|
| Invoke | `/gsd-*` | Skill name / `@gsd-*` |
| GSD event hooks | Installed | **Not installed** — use `.cursor/hooks.json` for custom guards |
| Workflows | Yes | Yes |

Canonical upstream help: invoke **gsd-help --full** in Agent (sources `.cursor/get-shit-done/workflows/help/modes/full.md`).
