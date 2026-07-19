# Phase 2 — Coverage Delta (Pre-Merge vs Post-Merge) (Issue #369, Remediation Cycle 1)

Timestamp: 2026-07-18T22-36

## Sources
- Pre-merge baseline: `evidence/remediation-baseline/r1c1-phase0-pytest-baseline.2026-07-18T22-27.md`
- Post-merge: `evidence/qa-gates/r1c1-pytest.2026-07-18T22-36.md`

## Coverage Comparison

| Metric | Pre-Merge Baseline | Post-Merge | Threshold | Post-Merge Meets Threshold |
|---|---|---|---|---|
| Line coverage | 89.2% (Stmts 12314, Miss 1328) | 89.29% (Stmts 12474, Miss 1336) | >= 85% | Yes |
| Branch coverage | 87.5% (Branch 4512, BrPart 564) | 87.55% (Branch 4530, BrPart 564) | >= 75% | Yes |
| Combined coverage.py TOTAL | 87% | 87% | n/a | n/a |
| Tests passed | 1975 | 2064 | n/a | n/a |
| Tests failed | 0 | 1 (pre-existing integration defect; see r1c1-pytest artifact) | n/a | n/a |

## Threshold and Regression Assessment
- Post-merge line coverage 89.29% >= 85%: PASS.
- Post-merge branch coverage 87.55% >= 75%: PASS.
- No regression: post-merge line (89.29%) and branch (87.55%) coverage are each marginally higher than the pre-merge baseline (89.2% / 87.5%), reflecting additional covered production code brought in by the merged integration branch. There is no coverage regression on the merged tree.
- Note: the merge is additive to `pyproject.toml` (three console-script entries) and introduces no production or test logic on this feature's side. The single post-merge test failure is a pre-existing integration-branch bundle push-down defect documented and escalated in `r1c1-pytest.2026-07-18T22-36.md`; it is unrelated to coverage and to the authorized conflict-resolution scope.
