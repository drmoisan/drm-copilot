# r2c2 Coverage Delta — Baseline vs Post-Change

Timestamp: 2026-07-18T22-58

Sources:
- Baseline: `evidence/remediation-baseline/r2c2-phase0-pytest-baseline.2026-07-18T22-58.md`
- Post-change: `evidence/qa-gates/r2c2-pytest.2026-07-18T22-58.md`

Coverage comparison (identical TOTAL row in both runs: Stmts=12474, Miss=1336, Branch=4530, BrPart=564):

| Metric | Baseline | Post-Change | Threshold | Pass |
|---|---|---|---|---|
| Line coverage | 89.29% | 89.29% | >= 85% | Yes |
| Branch coverage | 87.55% | 87.55% | >= 75% | Yes |
| Combined (pytest-cov Cover) | 87% | 87% | n/a | n/a |

Test outcome delta:
- Baseline: 1 failed, 2064 passed.
- Post-change: 0 failed, 2065 passed.
- The single previously-failing test (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) now passes.

Regression check:
- No coverage regression. Line and branch coverage are byte-identical to baseline because no Python production code was added or modified. The change adds two byte-identical PowerShell resource files and mirrors one JSON settings file into the bundle payload only.
- Both threshold checks pass: line coverage 89.29% >= 85% and branch coverage 87.55% >= 75%.
