# GSD Benchmark Report (active task: uber-eats)

Config: `config.yaml` (`active_task: uber-eats`)

## Execution status

| Item | Status |
|------|--------|
| Workspace, SPEC, grader | Complete |
| GSD 1.2.0 (Cursor local, standard) | Installed |
| Claude login | **Required** — `claude /login` (CLI path only) |
| Grading pipeline | Validated (`validate-pipeline.sh`) |
| Live LLM runs (10 sessions) | Use Cursor manual runs + `finalize-run.sh` |

## Scorecard

### baseline (tasks: uber-eats)
- Runs with grade.json: 5
- Passed (any): 1/5
- Passed (live agent only): 0/5
- pass@1 (first run): 100%
- pass@5: 20%
  - run-01: PASS (tests 14/14) [uber-eats] pipeline_validated_reference_oracle
  - run-02: FAIL (tests 0/0) pending_claude_login
  - run-03: FAIL (tests 0/0) pending_claude_login
  - run-04: FAIL (tests 0/0) pending_claude_login
  - run-05: FAIL (tests 0/0) pending_claude_login

### gsd (tasks: uber-eats)
- Runs with grade.json: 5
- Passed (any): 1/5
- Passed (live agent only): 0/5
- pass@1 (first run): 100%
- pass@5: 20%
  - run-01: PASS (tests 14/14) [uber-eats] pipeline_validated_reference_oracle
  - run-02: FAIL (tests 0/0) pending_claude_login
  - run-03: FAIL (tests 0/0) pending_claude_login
  - run-04: FAIL (tests 0/0) pending_claude_login
  - run-05: FAIL (tests 0/0) pending_claude_login

## Next steps

1. Register tasks: `./bench/tasks/register.sh --id <name> --path /abs/repo`
2. Set `active_task` in `config.yaml`
3. Cursor: run arms in `runs/{baseline,gsd}/run-NN/`, then `finalize-run.sh`
4. `python3 bench/report/aggregate.py`

## Notes

- **pass@k** uses all graded runs; check **live agent only** for real benchmark scores.
- Reference-oracle run-01 passes are pipeline checks, not LLM results.
- See [docs/TASKS.md](docs/TASKS.md) for pluggable task manifests.
