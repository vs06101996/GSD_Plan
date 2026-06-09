#!/usr/bin/env python3
"""Arm-agnostic KPI instrument.

Reads stamps.jsonl across results/<arm>/<run>/ and computes the KPIs used to
decide whether an "optimized GSD" arm actually beats vanilla GSD on the same
feature work. Emits a markdown comparison table (stdout + KPI-REPORT.md).

KPIs:
  - End-to-end lead time  (velocity)   first -> last stamp per run
  - Stage cycle times     (velocity)   duration between adjacent milestones
  - Reopen count          (quality)    `reopened` stamps per run
  - First-pass yield      (quality)    stages reached without a reopen
  - Human-touch ratio     (effort)     human-actor stamps / all actor stamps
  - Grader pass rate       (correctness) from grade.json (quality floor)

Stamp schema: bench/capture/stamp.schema.json
"""
from __future__ import annotations

import json
import statistics
from datetime import datetime
from pathlib import Path

BENCH = Path(__file__).resolve().parents[2]
RESULTS = BENCH / "results"
ARMS = ["baseline", "gsd", "recipe"]

# Ordered lifecycle milestones; cycle times are computed between adjacent
# milestones that are both present in a run.
LIFECYCLE = [
    "started",
    "prd-approved",
    "engineering-ready",
    "build-started",
    "build-done",
    "review-ready",
    "approved",
    "settled",
]


def parse_at(value: str) -> datetime | None:
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except (ValueError, AttributeError):
        return None


def load_stamps(run_dir: Path) -> list[dict]:
    path = run_dir / "stamps.jsonl"
    if not path.exists():
        return []
    stamps = []
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            stamps.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    stamps.sort(key=lambda s: s.get("at", ""))
    return stamps


def run_metrics(stamps: list[dict]) -> dict | None:
    """Per-run KPI primitives. Returns None when a run has no stamps."""
    if not stamps:
        return None

    times = [t for t in (parse_at(s.get("at", "")) for s in stamps) if t]
    lead_time = (max(times) - min(times)).total_seconds() if len(times) >= 2 else 0.0

    # earliest timestamp per milestone status
    first_at: dict[str, datetime] = {}
    for s in stamps:
        at = parse_at(s.get("at", ""))
        status = s.get("status")
        if at and status and status not in first_at:
            first_at[status] = at

    # cycle time between adjacent present milestones
    cycle: dict[str, float] = {}
    present = [m for m in LIFECYCLE if m in first_at]
    for a, b in zip(present, present[1:]):
        cycle[f"{a}->{b}"] = (first_at[b] - first_at[a]).total_seconds()

    reopen_count = sum(1 for s in stamps if s.get("status") == "reopened")

    attempted_steps = {s.get("step") for s in stamps if s.get("step")}
    reopened_steps = {s.get("step") for s in stamps if s.get("status") == "reopened"}
    yield_ratio = (
        (len(attempted_steps) - len(reopened_steps)) / len(attempted_steps)
        if attempted_steps
        else None
    )

    actor_stamps = [s.get("actor") for s in stamps if s.get("actor")]
    human_ratio = (
        actor_stamps.count("human") / len(actor_stamps) if actor_stamps else None
    )

    return {
        "lead_time": lead_time,
        "cycle": cycle,
        "reopen_count": reopen_count,
        "yield": yield_ratio,
        "human_ratio": human_ratio,
    }


def grade_pass(run_dir: Path) -> bool | None:
    grade = run_dir / "grade.json"
    if not grade.exists():
        return None
    try:
        return bool(json.loads(grade.read_text()).get("pass"))
    except json.JSONDecodeError:
        return None


def collect_arm(arm: str) -> dict:
    arm_dir = RESULTS / arm
    runs = []
    if arm_dir.exists():
        for run_dir in sorted(arm_dir.glob("run-*")):
            m = run_metrics(load_stamps(run_dir))
            if m is None:
                continue
            m["run_id"] = run_dir.name
            m["grade_pass"] = grade_pass(run_dir)
            runs.append(m)
    return {"arm": arm, "runs": runs}


def fmt_secs(seconds: float | None) -> str:
    if seconds is None:
        return "n/a"
    if seconds < 90:
        return f"{seconds:.0f}s"
    if seconds < 5400:
        return f"{seconds / 60:.1f}m"
    return f"{seconds / 3600:.1f}h"


def fmt_pct(ratio: float | None) -> str:
    return "n/a" if ratio is None else f"{ratio:.0%}"


def mean(values: list[float]) -> float | None:
    vals = [v for v in values if v is not None]
    return statistics.mean(vals) if vals else None


def _pass_rate(arm: dict) -> str:
    graded = [r["grade_pass"] for r in arm["runs"] if r["grade_pass"] is not None]
    return fmt_pct(sum(graded) / len(graded)) if graded else "n/a"


def _reopen_cell(arm: dict) -> str:
    avg = mean([r["reopen_count"] for r in arm["runs"]])
    return f"{avg:.1f}" if avg is not None else "n/a"


def summary_table(arms: list[dict]) -> str:
    header = "| KPI | " + " | ".join(a["arm"] for a in arms) + " |"
    sep = "|-----|" + "|".join(["-------"] * len(arms)) + "|"
    rows = [header, sep]

    # (label, per-arm value function); "no data" when an arm has no stamped runs
    metrics = [
        ("Runs measured", lambda a: str(len(a["runs"]))),
        ("Mean lead time", lambda a: fmt_secs(mean([r["lead_time"] for r in a["runs"]]))),
        ("Mean reopen count", _reopen_cell),
        ("Mean first-pass yield", lambda a: fmt_pct(mean([r["yield"] for r in a["runs"]]))),
        ("Human-touch ratio", lambda a: fmt_pct(mean([r["human_ratio"] for r in a["runs"]]))),
        ("Grader pass rate", _pass_rate),
    ]

    for label, fn in metrics:
        cells = []
        for a in arms:
            if not a["runs"] and label != "Runs measured":
                cells.append("no data")
            else:
                cells.append(fn(a))
        rows.append(f"| {label} | " + " | ".join(cells) + " |")
    return "\n".join(rows)


def cycle_table(arms: list[dict]) -> str:
    transitions: list[str] = []
    for a in arms:
        for r in a["runs"]:
            for k in r["cycle"]:
                if k not in transitions:
                    transitions.append(k)
    if not transitions:
        return "_No stage transitions stamped yet._"
    order = {f"{a}->{b}": i for i, (a, b) in enumerate(zip(LIFECYCLE, LIFECYCLE[1:]))}
    transitions.sort(key=lambda t: order.get(t, 999))

    header = "| Stage transition | " + " | ".join(a["arm"] for a in arms) + " |"
    sep = "|------------------|" + "|".join(["-------"] * len(arms)) + "|"
    rows = [header, sep]
    for t in transitions:
        cells = []
        for a in arms:
            vals = [r["cycle"][t] for r in a["runs"] if t in r["cycle"]]
            cells.append(fmt_secs(mean(vals)) if vals else "n/a")
        rows.append(f"| `{t}` | " + " | ".join(cells) + " |")
    return "\n".join(rows)


def main() -> None:
    arms = [collect_arm(a) for a in ARMS]
    total_runs = sum(len(a["runs"]) for a in arms)

    body = [
        "# GSD KPI comparison (vanilla vs optimized)",
        "",
        "Derived from immutable stamps (`results/<arm>/<run>/stamps.jsonl`).",
        "Arms with no stamps show `no data` until a run is captured.",
        "",
        "## Summary",
        "",
        summary_table(arms),
        "",
        "## Stage cycle time (mean across runs)",
        "",
        cycle_table(arms),
        "",
        "## Notes",
        "",
        "- Lower lead time / reopen count and higher first-pass yield at an equal or",
        "  higher grader pass rate is the signal an optimization is real.",
        "- Human-touch ratio needs `actor` on stamps; emit with `emit-stamp.sh ... <actor>`.",
        "- Repeat-defect rate (compounding) is computed across features, not here.",
        "",
    ]
    out = "\n".join(body)
    report = BENCH / "KPI-REPORT.md"
    report.write_text(out)
    print(out)
    print(f"\nWrote {report} ({total_runs} run(s) with stamps across {len(ARMS)} arms)")


if __name__ == "__main__":
    main()
