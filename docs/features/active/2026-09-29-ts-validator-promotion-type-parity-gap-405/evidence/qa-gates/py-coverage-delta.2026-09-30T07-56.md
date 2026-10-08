# Python coverage comparison (P5-T15)

Timestamp: 2026-09-30T07-56
Command: none (comparison of P0-T14 against P5-T9 and P0-T15 against P5-T8; evidence/baseline/py-pytest-coverage.2026-09-30T07-18.md, evidence/qa-gates/py-pytest-coverage.2026-09-30T07-45.md, evidence/baseline/py-routing-coverage.2026-09-30T07-19.md, evidence/qa-gates/py-routing-coverage.2026-09-30T07-43.md)
Output Summary:
| Metric | Baseline | Post-change | Difference |
|---|---|---|---|
| Repository-wide percent_statements_covered | 93.4 (15811/16937) | 93.4 (15811/16937) | 0.0 |
| Repository-wide percent_branches_covered | 86.3 (5270/6106) | 86.3 (5270/6106) | 0.0 |
| _orchestrator_state_routing.py percent_statements_covered (targeted run) | 83.1 (182/219) | 83.6 (183/219) | +0.5 |
| _orchestrator_state_routing.py percent_branches_covered (targeted run) | 67.9 (76/112) | 68.8 (77/112) | +0.9 |

- Every post-change value is greater than or equal to its baseline: PASS. The routing-module gain comes from the new parity test running against that module; the repository-wide totals are unchanged because the full-suite run already exercised the routing module through other tests.
- Production Python is unchanged; new-code coverage figure: none.
