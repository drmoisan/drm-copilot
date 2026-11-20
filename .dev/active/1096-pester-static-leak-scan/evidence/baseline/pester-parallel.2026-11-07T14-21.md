# Baseline Gate: Pester (Invoke-PoshQCParallelTest)

Timestamp: 2026-11-07T14-21
Command: sh SCRATCH/issue-1096-pester-run.sh baseline (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCParallelTest -Root <item worktree>; the launcher exits with the returned ExitCode)
EXIT_CODE: 0
Output Summary: ExitCode 0 from 8 shard processes in about 6 minutes. Merged artifacts/pester/pester-junit.xml holds 14713 testcases with 0 failed or erroring. Merged artifacts/pester/powershell-coverage.xml read for the two existing PowerShell files of P6-T5. Both files were copied to SCRATCH/baseline/pester/ after the run. No shard was missing a JUnit or coverage file (the run was green, so the merged files were read).

## Failures

BASELINE-FAILURE: NONE

## Coverage

BASELINE-COVERAGE: scripts/powershell/PoshQC/PoshQC.psm1 | line 54/61 | 88.52%
BASELINE-COVERAGE: scripts/dev-tools/DrmCopilotPromptSupport.ps1 | line 33/38 | 86.84%
