# Format Baseline (P0-T4)

Timestamp: 2026-11-04T03-55
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-format-check.ps1 (compares each of the 22 change-set files, 5 production and 17 test, with Invoke-Formatter output under scripts/powershell/PoshQC/settings/pssa.settings.psd1 after LF normalization, as Invoke-PoshQCFormat does; no file written)
EXIT_CODE: 0
Output Summary:
- FORMAT-DIFF-COUNT=0
- No differing paths.
