# Final QA: Coverage Comparison (issue #897, epic child E1)

Timestamp: 2026-10-11T13-14
Task: [P5-T6]
Pass: 1
Command: values copied from `evidence/baseline/p0-pester-coverage.md` ([P0-T9] `Covered` line and R-COV `PACKAGE:` line), `evidence/qa-gates/final-pester-coverage.md` ([P5-T4] `Covered` line), and `evidence/qa-gates/final-helper-coverage.md` ([P5-T5] R-COV lines).
EXIT_CODE: 0
Output Summary: baseline total 89.16, post total 88.67; hooks package 96.19 -> 96.23; new helper 100.00 (threshold 85.00 met); no PowerShell production line other than the new helper changed.

BASELINE_TOTAL: 89.16
POST_TOTAL: 88.67
BASELINE_HOOKS_PACKAGE: 96.19
POST_HOOKS_PACKAGE: 96.23
NEW_CODE: .claude/hooks/subagentstop-envelope.ps1 | baseline n/a (new file) | post 100.00
CHANGED_PRODUCTION_LINES: .claude/settings.json and the bundled copy are JSON and outside the Pester coverage population; no PowerShell production line other than the new helper changed

## Derivations

- BASELINE_HOOKS_PACKAGE: 100 * 5226 / (5226 + 207) = 96.19
- POST_HOOKS_PACKAGE: 100 * 5286 / (5286 + 207) = 96.23
- The `.claude/hooks` package gained 60 covered commands and 0 missed commands between the two runs, which is the new helper (covered=60, missed=0). The total-figure movement (89.16 -> 88.67) therefore originates outside `.claude/hooks` and outside the changed files; it is recorded in `final-pester-coverage.md`.
