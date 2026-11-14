# QA Gate: Pester (Invoke-PoshQCParallelTest, Remediation Cycle 1)

Timestamp: 2026-11-07T17-04
Command: sh SCRATCH/issue-1096-pester-run.sh c1final (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCParallelTest -Root <item worktree>; the launcher exits with the returned ExitCode, read first)
EXIT_CODE: 0
Output Summary: Remediation cycle 1, one background run on the tree after P3-T1. ExitCode 0 from 8 shard processes in about 7.7 minutes. Merged artifacts/pester/pester-junit.xml holds 15684 testcases with 0 failed or erroring. The `LI-14` and `PRL-REAL-LEDGER-AGREES` testcases are present and Passed. Both merged files were copied to SCRATCH/c1final/pester/ after the run.

## Failures

GATE-FAILURE: NONE

## Named Testcases (merged JUnit)

- `Invoke-PoshQCLeakScan (issue #1096).LI-14 reports a file read failure as read-error, not parse-error` under `tests/scripts/powershell/PoshQC/PoshQC.LeakAllowlist.Tests.ps1`: Passed
- `Committed ledger.PRL-REAL-LEDGER-AGREES finds the committed README and entries in agreement` under `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`: Passed

## Tag Counts (testcases | passed)

- `LS-K`: 38 | 38
- `LS-R`: 31 | 31
- `LA-`: 21 | 21
- `LI-`: 14 | 14
- `VT-`: 6 | 6
- `WF06-LEAK-SCAN-STEP`: 1 | 1

## Decision 3 Titles

- `resolves a relative path against the PowerShell location, not the process directory`, under `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`: 1 testcase, Passed
- `resolves a relative virtual environment path against the PowerShell location, not the process directory`, under `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`: 1 testcase, Passed
- the test whose title begins `defaults $Root to $PWD.ProviderPath when -Root is not supplied`, under `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1`: 1 testcase, Passed

## Coverage (merged LINE counters)

- `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1`: 221/225, 98.22%
- `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1`: 86/90, 95.56%
- `scripts/powershell/PoshQC/PoshQC.psm1`: 54/61, 88.52%
- `scripts/dev-tools/DrmCopilotPromptSupport.ps1`: 35/40, 87.5%
