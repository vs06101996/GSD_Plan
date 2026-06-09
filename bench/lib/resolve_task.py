#!/usr/bin/env python3
"""Load active benchmark task from tasks/<id>/task.yaml and config.yaml."""
from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path


def bench_root() -> Path:
    return Path(__file__).resolve().parents[2]


def load_simple_yaml(path: Path) -> dict:
    """Minimal YAML subset for task manifests (no PyYAML required)."""
    data: dict = {}
    stack: list[tuple[int, dict]] = [(-1, data)]

    for raw in path.read_text().splitlines():
        line = raw.split("#", 1)[0].rstrip()
        if not line.strip():
            continue
        indent = len(raw) - len(raw.lstrip())
        key, _, val = line.partition(":")
        key = key.strip()
        val = val.strip()

        while stack and indent <= stack[-1][0]:
            stack.pop()
        parent = stack[-1][1]

        if not val:
            node: dict = {}
            parent[key] = node
            stack.append((indent, node))
        else:
            if val in ("true", "false"):
                parent[key] = val == "true"
            elif re.fullmatch(r"-?\d+", val):
                parent[key] = int(val)
            else:
                parent[key] = val.strip("'\"")

    return data


def active_task_id(root: Path) -> str:
    env = os.environ.get("BENCH_TASK", "").strip()
    if env:
        return env
    cfg = root / "config.yaml"
    if not cfg.exists():
        return "uber-eats"
    for line in cfg.read_text().splitlines():
        m = re.match(r"^\s*active_task:\s*(\S+)", line)
        if m:
            return m.group(1).strip("'\"")
        m = re.match(r"^\s*task:\s*(\S+)", line)
        if m:
            return m.group(1).strip("'\"")
    return "uber-eats"


def resolve(root: Path | None = None) -> dict:
    root = root or bench_root()
    task_id = active_task_id(root)
    task_dir = root / "tasks" / task_id
    manifest_path = task_dir / "task.yaml"
    if not manifest_path.exists():
        raise SystemExit(f"error: task manifest not found: {manifest_path}")

    m = load_simple_yaml(manifest_path)
    language = m.get("language", "go")
    go = m.get("go") or {}
    scala = m.get("scala") or {}
    source = m.get("source") or {}
    workspace = m.get("workspace") or {}

    source_type = source.get("type", "bundled")
    local_path = source.get("local_path", "")
    if source_type == "bundled":
        ref = task_dir / "reference"
    elif source_type in ("local", "git"):
        ref = Path(local_path).expanduser().resolve() if local_path else task_dir / "reference"
    else:
        ref = task_dir / "reference"

    mode = m.get("mode", "greenfield")
    strategy = workspace.get("strategy", "copy_per_run")
    subdir = workspace.get("subdir", "workspace")

    grader_dir = str(task_dir / (scala.get("grader_dir") or go.get("grader_dir") or "grader"))

    info = {
        "task_id": task_id,
        "task_dir": str(task_dir),
        "manifest_path": str(manifest_path),
        "mode": mode,
        "language": language,
        "spec_file": m.get("spec", "SPEC.md"),
        "spec_path": str(task_dir / m.get("spec", "SPEC.md")),
        "go_module": go.get("module", task_id),
        "grader_dir": grader_dir,
        "ref_path": str(ref),
        "source_type": source_type,
        "workspace_strategy": strategy,
        "workspace_subdir": subdir,
        "bench_root": str(root),
        "scala_root_marker": scala.get("root_marker", "build.sbt"),
        "scala_compile": scala.get("compile", "compile"),
        "scala_test": scala.get("test", "none"),
        "scala_grader_dir": grader_dir,
    }
    return info


def shell_exports(info: dict) -> str:
    lines = []
    for k, v in info.items():
        lines.append(f'export {k.upper()}="{v}"')
    lines.append(f'export TASK_ID="{info["task_id"]}"')
    lines.append(f'export TASK_DIR="{info["task_dir"]}"')
    lines.append(f'export TASK_MODE="{info["mode"]}"')
    lines.append(f'export LANGUAGE="{info["language"]}"')
    lines.append(f'export GO_MODULE="{info["go_module"]}"')
    lines.append(f'export GRADER_DIR="{info["grader_dir"]}"')
    lines.append(f'export REF_PATH="{info["ref_path"]}"')
    lines.append(f'export SPEC_PATH="{info["spec_path"]}"')
    lines.append(f'export BENCH_ROOT="{info["bench_root"]}"')
    lines.append(f'export WORKSPACE_STRATEGY="{info["workspace_strategy"]}"')
    lines.append(f'export WORKSPACE_SUBDIR="{info["workspace_subdir"]}"')
    lines.append(f'export SCALA_ROOT_MARKER="{info["scala_root_marker"]}"')
    lines.append(f'export SCALA_COMPILE="{info["scala_compile"]}"')
    lines.append(f'export SCALA_TEST_TARGET="{info["scala_test"]}"')
    lines.append(f'export SCALA_GRADER_DIR="{info["scala_grader_dir"]}"')
    return "\n".join(lines)


def main() -> None:
    if len(sys.argv) > 1 and sys.argv[1] == "--json":
        print(json.dumps(resolve(), indent=2))
    elif len(sys.argv) > 1 and sys.argv[1] == "--shell":
        print(shell_exports(resolve()))
    else:
        print(json.dumps(resolve(), indent=2))


if __name__ == "__main__":
    main()
