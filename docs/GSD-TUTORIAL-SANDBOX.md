# GSD tutorial sandbox — setup

Disposable lab repo for the live command tour. **Separate from** [gsd-benchmark](../README.md) so `runs/`, graders, and benchmark arms stay clean.

## Operator rule

**You run every GSD skill manually** in Cursor Agent. The benchmark repo agent must not invoke `gsd-*` workflows on your behalf. This doc and [GSD-TUTORIAL.md](GSD-TUTORIAL.md) are playbooks only.

---

## 1. Create or open the sandbox

Expected path:

```text
~/Projects/gsd-tutorial-sandbox
```

If the folder does not exist yet, create it and init git:

```bash
mkdir -p ~/Projects/gsd-tutorial-sandbox
cd ~/Projects/gsd-tutorial-sandbox
git init
```

Or open the repo if already scaffolded (see benchmark commit that added `BRIEF.md` / `README.md`).

**Cursor:** File → Open Folder → `gsd-tutorial-sandbox` (own workspace, not `gsd-benchmark`).

---

## 2. Install GSD (full profile)

From the sandbox workspace terminal (adjust path to your `gsd-core` clone):

```bash
node /tmp/gsd-core/bin/install.js --cursor --local --profile=full
```

Verify in Agent chat (you run):

```text
gsd-surface list
gsd-help --brief
```

You should see a large skill surface (~59 commands). Reference: [GSD-COMMANDS.md](GSD-COMMANDS.md).

Optional config after `gsd-new-project` creates `.planning/`:

```bash
cp /path/to/gsd-benchmark/bench/planning/config.yolo.template.json .planning/config.json
```

---

## 3. Seed brief (before Session 0)

The repo includes `BRIEF.md` at the sandbox root — 3-phase mini Task API. When **you** run `gsd-new-project`, use that brief as the product description (paste or point the agent at the file).

---

## 4. Session 0 — you run (bootstrap)

Do not skip. Creates `.planning/` and Phase 1 code.

```text
gsd-new-project
gsd-discuss-phase 1
gsd-plan-phase 1
gsd-execute-phase 1
```

**Pass before Module 1:**

- `.planning/PROJECT.md`, `ROADMAP.md`, `STATE.md`
- `.planning/phases/01-*/` with PLAN + SUMMARY
- `go test ./...` passes from repo root

Log results in `tutorial-log.md` in the sandbox repo.

---

## 5. Continue the tour

Follow [GSD-TUTORIAL.md](GSD-TUTORIAL.md) Modules 1–12. One module per chat session is recommended.

---

## Links

| Doc | Purpose |
|-----|---------|
| [GSD-TUTORIAL.md](GSD-TUTORIAL.md) | Full module playbook (command labs) |
| [GSD-TUTORIAL-PLAYBOOKS.md](GSD-TUTORIAL-PLAYBOOKS.md) | Case 1 (new + PRD) and Case 2 (existing + feature/bug) |
| [GSD-COMMANDS.md](GSD-COMMANDS.md) | Command reference |
| [EXPERIMENT-AGENDA.md](EXPERIMENT-AGENDA.md) | Benchmark experiment context |
