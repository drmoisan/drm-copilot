# PowerShell coverage comparison (P5-T16)

Timestamp: 2026-09-30T07-56
Command: none (comparison of evidence/baseline/ps-test-coverage.2026-09-30T07-30.md against evidence/qa-gates/ps-test-coverage.2026-09-30T07-56.md)
Output Summary:
| Metric (LINE) | Baseline (P0-T18) | Post-change (P5-T13) | Difference |
|---|---|---|---|
| Report as a whole | 96.25% (10688 covered, 416 missed) | 96.25% (10688 covered, 416 missed) | 0.00 |
| OrchestratorStateRoutingContract.psm1 | 99.07% (106 covered, 1 missed) | 99.07% (106 covered, 1 missed) | 0.00 |

- Both post-change values are greater than or equal to their baselines: PASS. The `COVERAGE-UNMEASURED` disposition is not used; both figures were produced numerically.
- No PowerShell production file changed (see evidence/regression-testing/bundle-and-authority-unchanged.2026-09-30T07-39.md: empty `.claude/lib` diff and porcelain listings, equal bundle hashes).
- New-code coverage figure: none. No PowerShell branch-coverage figure exists for Pester.
