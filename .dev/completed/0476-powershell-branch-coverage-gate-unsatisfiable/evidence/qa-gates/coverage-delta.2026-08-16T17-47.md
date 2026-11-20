# Coverage Delta Reconciliation (Issue #476)

Timestamp: 2026-08-16T17-47

Command: comparison of the numeric values recorded in the four coverage artifacts named below; no additional command was executed for this task.

EXIT_CODE: 0

## Sources

| Role | Artifact |
| --- | --- |
| Python baseline | `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/pytest-full-baseline.2026-08-16T17-10.md` |
| Python post-change | `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/final-pytest-full.2026-08-16T17-45.md` |
| Jest baseline | `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/jest-coverage-baseline.2026-08-16T17-12.md` |
| Jest post-change | `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/final-jest-coverage.2026-08-16T17-46.md` |

## Python Suite (`poetry run pytest --cov --cov-branch --cov-report=term-missing`)

| Metric | Baseline | Post-change | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Statements (denominator) | 14396 | 14396 | 0 | — | — |
| Statements missed | 1108 | 1108 | 0 | — | — |
| Line coverage | 92.30% | 92.30% | 0.00 pp | >= 85% | PASS |
| Branches (denominator) | 5286 | 5286 | 0 | — | — |
| Branches partial | 557 | 557 | 0 | — | — |
| Branch coverage | 89.46% | 89.46% | 0.00 pp | >= 75% | PASS |
| Combined reported total | 90% | 90% | 0 pp | — | — |
| Tests passed | 3785 | 3785 | 0 | — | — |
| Tests skipped | 5 | 5 | 0 | — | — |
| Exit code | 0 | 0 | — | 0 | PASS |

## Extension Jest Suite (`npm run test:coverage`)

| Metric | Baseline | Post-change | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Statements | 96.61% (41738/43200) | 96.61% (41738/43200) | 0.00 pp | — | — |
| Branches | 89.96% (5901/6559) | 89.96% (5901/6559) | 0.00 pp | >= 75% | PASS |
| Functions | 90.11% (1221/1355) | 90.11% (1221/1355) | 0.00 pp | — | — |
| Lines | 96.61% (41738/43200) | 96.61% (41738/43200) | 0.00 pp | >= 85% | PASS |
| Test suites passed | 185 | 185 | 0 | — | — |
| Tests passed | 2552 | 2552 | 0 | — | — |
| Exit code | 0 | 0 | — | 0 | PASS |

## New- and Changed-Code Coverage

Not applicable. The change set is 17 Markdown files and contains no production or test source in any measured language. There is no new code and no changed code in the coverage denominator, so there is no new-code coverage figure to report and no changed-lines regression to evaluate. The relevant regression control for this change is root/bundle byte parity (P5-T1), not a coverage delta.

## Verdict

Every numeric value matches its baseline exactly, including the raw covered/total counts rather than only the rounded percentages. The expected delta for a Markdown-only change was zero and the observed delta is zero on all 19 compared values. No regression is present, so no remediation and no Phase 5 restart is required.

Output Summary: PASS. Zero delta on all compared metrics across both suites. Python line coverage 92.30% and branch coverage 89.46%; Jest line coverage 96.61% and branch coverage 89.96%. Both suites exit 0, matching baseline. No new- or changed-code coverage applies because the change set contains no source code.
