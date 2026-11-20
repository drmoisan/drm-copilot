# Final QC Static: PowerShell (P4-T1)

Timestamp: 2026-11-16T03-28
Command: pwsh -NoProfile -File SCRATCH/issue-1025-static.ps1 -FolderList scripts/harness,tests/scripts/harness
EXIT_CODE: 0
Output Summary: format check: 7 files, every file already formatted, 0 would change; `git status --porcelain` identical before and after; PSSA: 7 files, 0 findings; type check not applicable (PowerShell).

## Step 1: Format (check-only)

Command: Invoke-PoshQCFormat -ScanFolders scripts/harness,tests/scripts/harness -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1 with a no-op WriteFile that records would-change files
EXIT_CODE: 0
Finding count: 0 (would-change 0 of 7)

Files reported already formatted:

- scripts/harness/HarnessInventory.psm1
- scripts/harness/HarnessParityMatrix.psm1
- scripts/harness/HarnessSkillContract.psm1
- tests/scripts/harness/HarnessInventory.Tests.ps1
- tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1
- tests/scripts/harness/HarnessParityMatrix.Tests.ps1
- tests/scripts/harness/HarnessSkillContract.Tests.ps1

## Step 2: Lint (PSSA)

Command: Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information on each of the 7 files
EXIT_CODE: 0
Finding count: 0

## Step 3: Type check

Not applicable for PowerShell.
