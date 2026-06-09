# GSD KPI comparison (vanilla vs optimized)

Derived from immutable stamps (`results/<arm>/<run>/stamps.jsonl`).
Arms with no stamps show `no data` until a run is captured.

## Summary

| KPI | baseline | gsd | recipe |
|-----|-------|-------|-------|
| Runs measured | 0 | 0 | 0 |
| Mean lead time | no data | no data | no data |
| Mean reopen count | no data | no data | no data |
| Mean first-pass yield | no data | no data | no data |
| Human-touch ratio | no data | no data | no data |
| Grader pass rate | no data | no data | no data |

## Stage cycle time (mean across runs)

_No stage transitions stamped yet._

## Notes

- Lower lead time / reopen count and higher first-pass yield at an equal or
  higher grader pass rate is the signal an optimization is real.
- Human-touch ratio needs `actor` on stamps; emit with `emit-stamp.sh ... <actor>`.
- Repeat-defect rate (compounding) is computed across features, not here.
