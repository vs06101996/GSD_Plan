# Project — Agent delivery benchmark

## Problem

Teams cannot show whether coding agents make feature delivery **faster**, at a **trusted quality bar**, with **compounding improvement** — because work is self-graded and unrecorded.

## Solution (experiment)

Benchmark three rungs on comparable features on one real service:

1. **Baseline** — human-orchestrated agent work (current default).
2. **Vanilla GSD** — orchestrator carries the lifecycle; gaps documented.
3. **Recipe** — GSD + KB/templates/validators + immutable tracker stamps; misses banked as upgrades.

## Scope (this repo)

- Harness for isolated runs, **external grading** (hidden tests), and metrics capture.
- Pilot alignment with Agent Studio service (~3 features; Feature A = shipped anchor).
- Recipe assembly on Feature B; Feature C head-to-head on identical work.

## Out of scope (v0)

- Auto-merge or unattended production deploys.
- Statistical multi-operator study (Feature C is directional).
- Claiming autonomy — human checkpoints remain by design.

## References

- [docs/EXPERIMENT-AGENDA.md](../docs/EXPERIMENT-AGENDA.md)
- [docs/GSD-PRODUCT-CONTEXT.md](../docs/GSD-PRODUCT-CONTEXT.md)
- [.planning/ROADMAP.md](ROADMAP.md)
