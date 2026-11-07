# QA Gate: Pester (Invoke-PoshQCParallelTest)

Timestamp: 2026-11-07T15-12
Command: sh SCRATCH/issue-1096-pester-run.sh final (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCParallelTest -Root <item worktree>; the launcher exits with the returned ExitCode)
EXIT_CODE: 0
Output Summary: ExitCode 0 from 8 shard processes in about 5.4 minutes. Merged artifacts/pester/pester-junit.xml holds 14825 testcases with 0 failed or erroring. Merged artifacts/pester/powershell-coverage.xml was read for the P6-T5 files. Both merged files were copied to SCRATCH/final/pester/ after the run.

## Failures

GATE-FAILURE: NONE

## Tag Counts (testcases | passed)

- `LS-K`: 38 | 38
- `LS-R`: 31 | 31
- `LA-`: 21 | 21
- `LI-`: 13 | 13
- `VT-`: 6 | 6
- `WF06-LEAK-SCAN-STEP`: 1 | 1

## Decision 3 Titles

- `resolves a relative path against the PowerShell location, not the process directory`, read under the `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` testsuite: 1 testcase, Passed
- `resolves a relative virtual environment path against the PowerShell location, not the process directory`, read under the `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` testsuite: 1 testcase, Passed
- the test whose title begins `defaults $Root to $PWD.ProviderPath when -Root is not supplied`, under `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1`: 1 testcase, Passed

## Coverage (merged LINE counters)

- `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1`: 221/225, 98.22%
- `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1`: 83/87, 95.4%
- `scripts/powershell/PoshQC/PoshQC.psm1`: 54/61, 88.52%
- `scripts/dev-tools/DrmCopilotPromptSupport.ps1`: 35/40, 87.5%
