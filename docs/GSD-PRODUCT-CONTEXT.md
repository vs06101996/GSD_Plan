# GSD Core — Product Context (Findings)

**Product:** GSD Core — `@opengsd/gsd-core`, npm, MIT — *Git. Ship. Done.*

Meta-prompting + context engineering + spec-driven development for AI coding agents. Not an application: skills/commands + `.planning/` artifacts installed into your agent (Cursor, Claude Code, Codex, etc.).

**Problem:** Context rot — quality drops as the main session fills up.

---

## Core loop

| Step | What happens |
|------|----------------|
| New project | Questions → research → requirements → roadmap |
| Discuss phase | Capture decisions before planning |
| Plan phase | Research + small plans + plan-check loop |
| Execute phase | Parallel waves; executors get fresh context; atomic commits |
| Verify work | Acceptance testing (often manual) |
| Ship / milestone | PR, archive, next phase |

**Persistent artifacts:** `PROJECT.md`, `REQUIREMENTS.md`, `ROADMAP.md`, `STATE.md`, `CONTEXT.md`, `.planning/config.json`

---

## What GSD gets right

- Opinionated process beats unstructured agent chat on large, multi-session builds
- Subagent orchestration keeps main context ~30–40% (claimed; design intent is sound)
- On-disk memory survives `/clear` and session boundaries
- Engineering rigor — large test suite, ADRs, changesets, workflow size budgets, package verification (slopcheck with fallback)
- Multi-runtime — one installer adapts to 15+ tools (must use installer, not hand-copy files)

---

## Structural weaknesses

| Issue | Detail |
|-------|--------|
| Markdown-as-database | `STATE.md` parsed with regex → recurring drift/merge bugs |
| Verify gap | Often ends at human testing; not fully closed-loop automated |
| Security | Hooks often advisory-only; broad permissions recommended for automation |
| Runtime fragmentation | 14+ targets → parity drift, converter maintenance, no cross-runtime test matrix |
| Prompt tuning | Hand-edited at scale; no built-in eval gate |
| Parallelism | Worktrees + waves help; semantic merge conflicts still unsolved industry-wide |
| Dependencies | External tools (e.g. graphify, slopcheck); hooks vary by runtime |

**Verdict:** Best as a workflow coach for phased shipping; not yet a trustworthy fully autonomous shipper.

| Use when | Skip when |
|----------|-----------|
| You know what you want; multi-day/multi-phase work; you follow the loop and read `.planning/` | Tiny one-off edits; you need unattended sandboxed CI agents today |

---

## Cursor-specific

- GSD supports Cursor via `~/.cursor/skills/gsd-*` and project `.cursor/skills/`
- No `/gsd-*` slash commands — invoke by skill name or `@gsd-new-project`
- Install: `node …/bin/install.js --cursor --global --profile=standard` (or `--local`)
- Some workflow files still reference `.claude` paths (installer warns)
- Profiles: **core** (~7 skills), **standard** (~19), **full** (~66) — smaller profile = less token overhead

---

## Efficiency (how to use GSD well)

- Use `--profile=core` or `standard`, not full surface
- Freeze spec before plan; skip discuss if spec is complete
- Set mode: `yolo` in `.planning/config.json` to reduce stop-and-ask
- Own acceptance tests — GSD verify ≠ your product’s definition of done
- Fresh workspace per attempt — don’t reuse contaminated `.planning/`
- Pin model + profile for comparable runs
- Compare baseline agent vs GSD on the same spec or you’re paying token tax without proof

---

## Improvement directions (if rebuilding, e.g. “Keel”)

- Event-sourced state (JSONL + projections), not markdown round-trip
- Sandboxed executors + enforcing guards at boundary
- Closed-loop verify (tests → diagnose → fix → retry)
- Runtime-agnostic IR + conformance CI per target
- Eval harness for prompt changes (e.g. GEPA-style offline optimization)

---

## One line

GSD turns agent coding into a repeatable plan–execute–verify loop with shared memory; its ceiling is limited by fragile state, manual verify, and multi-runtime glue — still valuable on Cursor for big builds if you keep the profile thin and grade outcomes yourself.

---

*Used by [gsd-benchmark](../README.md) to frame what we measure (outcomes) vs what we do not claim (fully autonomous shipping).*
