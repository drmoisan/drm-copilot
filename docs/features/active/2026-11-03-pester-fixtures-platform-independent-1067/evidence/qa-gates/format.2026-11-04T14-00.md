# Final QA: Format (P6-T4, restart pass after resume)

Timestamp: 2026-11-04T14-00
Command: sh SCRATCH/issue-1067-fmt-pssa.sh (pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-format-check.ps1: Invoke-Formatter comparison under scripts/powershell/PoshQC/settings/pssa.settings.psd1 of the change-set PowerShell files from git diff --name-only MB HEAD outside docs/; no file written)
EXIT_CODE: 0
Output Summary:
- FILES 22 (5 production files and 17 suites)
- FORMAT-DIFF-COUNT=0
- Restart reason: two PoshQC suites changed after the earlier P6-T4 to P6-T12 evidence (see evidence/other/execution-deviations.2026-11-04T13-58.md).
