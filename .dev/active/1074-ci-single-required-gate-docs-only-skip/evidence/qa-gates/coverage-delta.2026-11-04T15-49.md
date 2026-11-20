# PowerShell Coverage Delta (Issue #1074)

Timestamp: 2026-11-04T15-49
Task: [P6-T4]
Command: compare evidence/baseline/pester-ci-workflows.2026-11-04T15-28.md (P0-T4) with evidence/qa-gates/pester-coverage.2026-11-04T15-49.md (P6-T3); both read from artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:

| File | Baseline line % | Post-change line % | Floor | Result |
|---|---|---|---|---|
| `scripts/ci/CiChangeScope.psm1` | 93.57 (131/140) | 93.57 (131/140) | not lower | pass |
| `scripts/ci/Invoke-CiChangeScope.ps1` | 91.15 (103/113) | 91.15 (103/113) | not lower | pass |
| `scripts/ci/CiRequiredGate.psm1` (new) | n/a | 100.00 (90/90) | 85 | pass |
| `scripts/ci/Invoke-CiRequiredGate.ps1` (new) | n/a | 90.00 (27/30) | 85 | pass |

- Every value is present; no existing file regressed; each new file is at least 85%.
- Result: pass (no remediation required). Branch coverage is not measured for PowerShell.
