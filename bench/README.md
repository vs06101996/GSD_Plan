# Benchmark harness

| Path | Purpose |
|------|---------|
| `grade/grade.sh` | Grade artifact dir (build, vet, hidden acceptance tests) |
| `runners/prepare-run.sh` | Fresh run dir with SPEC only |
| `runners/run-baseline.sh` | Non-interactive baseline via `claude -p` |
| `runners/run-gsd.sh` | Prepare GSD run + optional `-p` attempt |
| `runners/finalize-run.sh` | Copy run → artifact + grade |
| `runners/validate-pipeline.sh` | Reference oracle (no LLM) |
| `runners/run-benchmark.sh` | Full orchestrator |
| `report/aggregate.py` | Build REPORT.md |

Future (Phase 8 extension): `runners/baseline.ts` / `gsd.ts` using `@anthropic-ai/claude-agent-sdk`.
