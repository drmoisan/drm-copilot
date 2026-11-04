# PowerShell Coverage Gate (R1, loop pass 3)

Timestamp: 2026-11-03T20-57
Task: [P6-T6]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-run-pester.ps1: one fresh pwsh process importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCTest -ScanFolders tests/scripts with the module-default settings scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (coverage population from config/poshqc-coverage.json); the last Pester run of the plan (loop pass 3); coverage read from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1047-read-results.ps1
EXIT_CODE: 255
Output Summary: artifacts/pester/powershell-coverage.xml exists after the run (written by this run). Coverage thresholds all met: ParallelAdmission.psm1 100.00%, ParallelAdmissionPrecedence.psm1 100.00%, ParallelAdmissionJson.psm1 100.00%, Invoke-ParallelAdmission.ps1 96.44% (baseline 96.15%), enforce-parallel-cohort-barrier-helpers.ps1 100.00% (baseline 100.00%), repo-wide LINE 92.61% (baseline 92.59%). Test outcome: 13946 discovered, 13527 passed, 409 failed, 10 skipped (Pester console summary); the JUnit file is truncated (export failed on a 0x1B character), and the 409 failures are the same failure lines as the pre-edit baseline run [P0-T3], none in a suite this item adds or changes. The "zero failures and zero errors" part of the [P6-T6] acceptance is therefore not met on this Linux host.

| File | Covered | Missed | Line % | Threshold | Result |
| --- | --- | --- | --- | --- | --- |
| .claude/lib/parallel-admission/ParallelAdmission.psm1 | 141 | 0 | 100.00 | 85 | PASS |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 179 | 0 | 100.00 | 85 | PASS |
| .claude/lib/parallel-admission/ParallelAdmissionJson.psm1 | 55 | 0 | 100.00 | 85 | PASS |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 217 | 8 | 96.44 | 85 | PASS |
| .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1 | 97 | 0 | 100.00 | baseline 100.00 | PASS |
| Repo-wide (report-level LINE counter) | 21594 | 1724 | 92.61 | 85 | PASS |

Missed lines of Invoke-ParallelAdmission.ps1 by function: Invoke-ParallelAdmissionGit (2, the real git process call and result, which every suite mocks), Read-ParallelAdmissionJsonText (1, the real file read), Get-ParallelAdmissionPlannerItem (1), guarded entry body (4, runs only under pwsh -File).

## Test outcome deviation

The failures are pre-existing on this host and identical to [P0-T3] at branch head 5000b6455 before any edit: the sorted list of 97 failure lines printed by Pester ("[-] ...", durations stripped) is identical between the two runs. Causes, recorded in remediation-baseline/pester-coverage-baseline.2026-11-03T19-45.md: Windows-host fixtures under tests/scripts/dev-tools and tests/scripts/powershell, and a PATH leak from tests/scripts/dev-tools/run-actionlint.Tests.ps1 ($env:PATH = '/existing' outside its restoring AfterEach) that makes later suites in the same process fail to resolve pwsh and python. The suites of this item (six under tests/scripts/claude-lib/parallel-admission, enforce-parallel-cohort-barrier.Tests.ps1, validate-orchestrator-output.MutationRejection.Tests.ps1, ClaudeLibModuleConvention.Tests.ps1, FileSizePolicy.RepoGate.Tests.ps1, and the three claude-runtime pins) report no failure line.
