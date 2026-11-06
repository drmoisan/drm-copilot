# PowerShell Coverage Gate (remediation cycle 2, loop pass 1)

Timestamp: 2026-11-03T21-51
Task: [P3-T5]
Command: sh SCRATCH/issue-1047-pester.sh: one fresh PowerShell 7 process importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCTest -ScanFolders tests/scripts with the module-default settings scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (coverage population from config/poshqc-coverage.json); the last Pester run of this plan. Coverage read from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1047-read-results.ps1
EXIT_CODE: 255
Output Summary: artifacts/pester/powershell-coverage.xml was written by this run (modification time moved from 2026-11-03T20-56 UTC to 2026-11-03T21-51 UTC, the run's end). Invoke-ParallelAdmission.ps1 219 covered, 8 missed, 96.48% (baseline 96.44%); no missed line in Get-ParallelAdmissionUsageError. Repo-wide report-level LINE 21596 covered, 1724 missed, 92.61% (baseline 92.61%). Run totals (Pester console summary and the JUnit testsuites header): 13949 tests, 13530 passed, 409 failed, 10 skipped, 6 errors. The JUnit export is truncated (a 0x1B character in a failure message, the same failure mode recorded in cycle 1), so per-suite counts come from the console failure lines. The 97 distinct failure lines printed by Pester, normalized for ANSI codes and durations, are identical to the cycle 1 final run (pester-coverage.2026-11-03T20-57.md); none names a suite under tests/scripts/claude-lib/parallel-admission, ClaudeLibModuleConvention.Tests.ps1, or FileSizePolicy.RepoGate.Tests.ps1. Exit 255 comes from those pre-existing host-fixture failures and the export error.

| File | Baseline covered / missed / % | Post-change covered / missed / % | Result |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 217 / 8 / 96.44 | 219 / 8 / 96.48 | PASS (>= 96.44 and >= [P0-T3] figure) |
| .claude/lib/parallel-admission/ParallelAdmission.psm1 | 141 / 0 / 100.00 | 141 / 0 / 100.00 | unchanged |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 179 / 0 / 100.00 | 179 / 0 / 100.00 | unchanged |
| .claude/lib/parallel-admission/ParallelAdmissionJson.psm1 | 55 / 0 / 100.00 | 55 / 0 / 100.00 | unchanged |
| Repo-wide (report-level LINE counter) | 21594 / 1724 / 92.61 | 21596 / 1724 / 92.61 | recorded |

Baseline source: remediation-baseline/pester-coverage-baseline.2026-11-03T21-26.md.

## Missed lines of Invoke-ParallelAdmission.ps1 by function

| Function | Missed lines | Reason |
| --- | --- | --- |
| Invoke-ParallelAdmissionGit | 2 | the real git process call and result; every suite mocks the seam |
| Read-ParallelAdmissionJsonText | 1 | the real file read |
| Get-ParallelAdmissionPlannerItem | 1 | unchanged from cycle 1 |
| guarded entry body (script body) | 4 | runs only under pwsh -File |
| Get-ParallelAdmissionUsageError | 0 | the two new executable lines are covered |

## Failure-line comparison

- Distinct failure lines this run: 97; cycle 1 final run: 97; normalized diff: identical.
- Failure lines naming tests/scripts/claude-lib/parallel-admission, ClaudeLibModuleConvention.Tests.ps1, or FileSizePolicy.RepoGate.Tests.ps1: 0.
- The windows-latest shards of `poshqc / PowerShell QC` remain the full-suite gate, as stated in the plan's Required References.
