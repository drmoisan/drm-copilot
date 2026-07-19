# r3c3 QA Gate — PowerShell Coverage Threshold Verification

Timestamp: 2026-07-18T23-30

Command: Threshold evaluation of the numeric values recorded in `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/evidence/qa-gates/r3c3-powershell-coverage-summary.2026-07-18T23-30.md` (derived from `artifacts/pester/powershell-coverage.xml`).

EXIT_CODE: 0

## Output Summary

Line-coverage threshold (>= 85%) for the discovery-artifact-gate hook logic:

| Hook | LINE % | >= 85% |
|---|---|---|
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 87.27% | PASS |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 87.93% | PASS |
| Aggregate (two hooks) | 87.61% | PASS |

- Line coverage >= 85% holds for each discovery-artifact-gate hook and for the aggregate. PASS.
- Branch coverage (>= 75%): Pester `CoverageGutters` output emits no report-level `BRANCH` counters (command/line-based instrument). Per the established repo convention (issue #344), branch coverage is not separately emitted for PowerShell; the line figure is the authorized threshold value under this line-based-instrument limitation. The line-coverage results above satisfy the coverage gate for the discovery-artifact-gate hook logic. No PowerShell logic was changed in this cycle, so there is no changed-line coverage regression.
- Result: the PowerShell coverage gate for Blocking finding R-1 is satisfied. P1-T1 through P1-T3 do not require revisiting.
