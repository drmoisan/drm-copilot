# Format Baseline: scripts/dev-tools (Issue #1080, P0-T5)

Timestamp: 2026-11-04T20-36
Command: sh SCRATCH/issue-1080-tool.sh issue-1080-format-check.ps1 issue-1080-p0t5.log scripts/dev-tools (SCRATCH/issue-1080-format-check.ps1 compares each top-level .ps1 file of scripts/dev-tools with Invoke-Formatter output under scripts/powershell/PoshQC/settings/pssa.settings.psd1, ordinal comparison, no write)
EXIT_CODE: 0

## Result

- FILES-CHECKED=29
- FORMAT-DIFF-COUNT=0
- Differing paths: none.

The two new production files `scripts/dev-tools/Get-EpicProgressReport.ps1` and `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` do not yet exist, so they are not in the checked set.

Output Summary: format baseline over the 29 .ps1 files of scripts/dev-tools: FORMAT-DIFF-COUNT=0 (no drift); the two new production files do not exist yet.
