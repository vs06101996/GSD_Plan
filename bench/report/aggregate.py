#!/usr/bin/env python3
"""Aggregate grade.json files into REPORT.md scorecard."""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

BENCH = Path(__file__).resolve().parents[2]
RESULTS = BENCH / "results"
CONFIG = BENCH / "config.yaml"
LIB = BENCH / "bench" / "lib"


def active_task_id() -> str:
    try:
        out = subprocess.check_output(
            [sys.executable, str(LIB / "resolve_task.py"), "--json"],
            text=True,
            cwd=str(BENCH),
        )
        return json.loads(out)["task_id"]
    except (subprocess.CalledProcessError, json.JSONDecodeError, KeyError):
        return "uber-eats"


def claude_logged_in() -> bool:
    try:
        out = subprocess.check_output(["claude", "auth", "status"], text=True, stderr=subprocess.DEVNULL)
        return json.loads(out).get("loggedIn", False)
    except (subprocess.CalledProcessError, json.JSONDecodeError, FileNotFoundError):
        return False


def load_grades(arm: str) -> list[dict]:
    rows = []
    arm_dir = RESULTS / arm
    if not arm_dir.exists():
        return rows
    for run_dir in sorted(arm_dir.glob("run-*")):
        grade_path = run_dir / "grade.json"
        meta_path = run_dir / "metadata.json"
        row = {"run_id": run_dir.name, "pass": False}
        if grade_path.exists():
            row.update(json.loads(grade_path.read_text()))
        if meta_path.exists():
            row["metadata"] = json.loads(meta_path.read_text())
        rows.append(row)
    return rows


def pass_at_k(rows: list[dict], k: int) -> float | None:
    if not rows:
        return None
    subset = rows[:k] if len(rows) >= k else rows
    passes = [1 if r.get("pass") else 0 for r in subset]
    return sum(passes) / len(passes) if passes else 0.0


def live_pass_count(rows: list[dict]) -> int:
    n = 0
    for r in rows:
        meta = r.get("metadata") or {}
        if meta.get("live_agent") and r.get("pass"):
            n += 1
    return n


def summarize(arm: str, rows: list[dict]) -> str:
    n = len(rows)
    passed = sum(1 for r in rows if r.get("pass"))
    live_passed = live_pass_count(rows)
    task_ids = sorted(
        {
            tid
            for r in rows
            if r
            for tid in [
                r.get("task_id") or (r.get("metadata") or {}).get("task_id"),
            ]
            if tid
        }
    )
    task_note = f" (tasks: {', '.join(t for t in task_ids if t)})" if task_ids else ""
    lines = [
        f"### {arm}{task_note}",
        f"- Runs with grade.json: {n}",
        f"- Passed (any): {passed}/{n}",
        f"- Passed (live agent only): {live_passed}/{n}",
    ]
    p1 = pass_at_k(rows, 1)
    p5 = pass_at_k(rows, 5)
    if p1 is not None:
        lines.append(f"- pass@1 (first run): {p1:.0%}")
    if n >= 1 and p5 is not None:
        lines.append(f"- pass@{min(5, n)}: {p5:.0%}")
    for r in rows:
        status = "PASS" if r.get("pass") else "FAIL"
        tests = f"{r.get('tests_passed', '?')}/{r.get('tests_total', '?')}"
        meta = r.get("metadata") or {}
        tag = meta.get("status", meta.get("note", ""))
        tid = r.get("task_id") or meta.get("task_id", "")
        tid_s = f" [{tid}]" if tid else ""
        lines.append(f"  - {r['run_id']}: {status} (tests {tests}){tid_s} {tag}")
    return "\n".join(lines) + "\n"


def execution_status() -> str:
    logged = claude_logged_in()
    return "\n".join(
        [
            "## Execution status",
            "",
            "| Item | Status |",
            "|------|--------|",
            "| Workspace, SPEC, grader | Complete |",
            "| GSD 1.2.0 (Cursor local, standard) | Installed |",
            f"| Claude login | {'OK' if logged else '**Required** — `claude /login` (CLI path only)'} |",
            "| Grading pipeline | Validated (`validate-pipeline.sh`) |",
            "| Live LLM runs (10 sessions) | "
            + ("Ready to run `./bench/runners/run-benchmark.sh`" if logged else "Use Cursor manual runs + `finalize-run.sh` |"),
            "",
        ]
    )


def main() -> None:
    task_id = active_task_id()
    baseline = load_grades("baseline")
    gsd = load_grades("gsd")
    report = BENCH / "REPORT.md"
    body = [
        f"# GSD Benchmark Report (active task: {task_id})",
        "",
        f"Config: `{CONFIG.name}` (`active_task: {task_id}`)",
        "",
        execution_status(),
        "## Scorecard",
        "",
        summarize("baseline", baseline),
        summarize("gsd", gsd),
        "## Next steps",
        "",
        "1. Register tasks: `./bench/tasks/register.sh --id <name> --path /abs/repo`",
        "2. Set `active_task` in `config.yaml`",
        "3. Cursor: run arms in `runs/{baseline,gsd}/run-NN/`, then `finalize-run.sh`",
        "4. `python3 bench/report/aggregate.py`",
        "",
        "## Notes",
        "",
        "- **pass@k** uses all graded runs; check **live agent only** for real benchmark scores.",
        "- Reference-oracle run-01 passes are pipeline checks, not LLM results.",
        "- See [docs/TASKS.md](docs/TASKS.md) for pluggable task manifests.",
        "",
    ]
    report.write_text("\n".join(body))
    print(f"Wrote {report}")


if __name__ == "__main__":
    main()
