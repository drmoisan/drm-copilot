# Final QA: Format (P6-T4, second restart pass after resume)

Timestamp: 2026-11-04T14-42
Command: sh SCRATCH/issue-1067-fmt-pssa.sh (pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-format-check.ps1: Invoke-Formatter comparison under scripts/powershell/PoshQC/settings/pssa.settings.psd1 of the 22 change-set PowerShell files from git diff --name-only MB HEAD outside docs/, plus their working-copy content; no file written)
EXIT_CODE: 0
Output Summary:
- FILES 22
- FORMAT-DIFF-COUNT=0
- Loop history: P6-T13 (2026-11-04T14-30) failed one test each in `PoshQC.ScanFolders.Tests.ps1` and `PoshQC.TestingCommands.Tests.ps1` (IOException: Permission denied creating `/repo`). Both tests were restructured to run inside `InModuleScope PoshQC`, and the loop restarted here. The first check of this pass (2026-11-04T14-41) printed FORMAT-DIFF-COUNT=2 for indentation inside the new wrapper; `Invoke-Formatter` was applied to the two files (whitespace-only change, confirmed with `git diff -w`), and this check prints 0.
