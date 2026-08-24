# QA Gate: Coverage Delta and Omit-List Invariant

Timestamp: 2026-07-18T22-28
Command: manual comparison of P0-T5 baseline coverage (evidence/baseline/py-test.2026-07-18T21-19.md)
against P5-T5 post-change coverage (evidence/qa-gates/final-py-test.2026-07-18T22-25.md); manual
inspection of `[tool.coverage.run] omit` in pyproject.toml.
EXIT_CODE: 0 (manual verification; no single command)

Output Summary:

| Metric | Baseline (P0-T5) | Post-change (P5-T5) | Delta | Threshold | Result |
|---|---|---|---|---|---|
| Line coverage | 88.87% | 88.95% | +0.08 pp | >= 85% | PASS |
| Branch coverage | 79.51% | 79.60% | +0.09 pp | >= 75% | PASS |
| Test count | 1839 passed | 1869 passed | +30 | n/a | n/a |

No regression on any pre-existing (changed or unchanged) line: both line and branch coverage
increased slightly, and no pre-existing production file's coverage decreased (the plan's 10 new
files are additive; no existing module was modified). Both post-change thresholds (line >= 85%,
branch >= 75%) are met.

New-module coverage for `scripts/dev_tools/discovery/**` (this plan's five new production
modules; see `evidence/qa-gates/final-py-test.2026-07-18T22-25.md` for per-module figures):
- io.py: 100% line, 100% branch
- rendering.py: 100% line, 100% branch
- coverage_report.py: 95.0% line, 100% branch
- parity_report.py: 95.0% line, 100% branch
- completion_report.py: 92.16% line, 100% branch

`[tool.coverage.run] omit` (pyproject.toml lines 121-126) is unchanged from baseline:
`["tests/*", "*/tests/*", "*/__pycache__/*", "*/site-packages/*"]`. No entry matching
`scripts/dev_tools/discovery/**` (or any other production path) was added, satisfying the
Coverage Exclusion Policy (`.claude/rules/general-unit-test.md`).
