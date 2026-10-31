# PowerShell Format (issue #1006)

Timestamp: 2026-10-31T08-34
Task: P8-T5
Command: sh SCRATCH/issue-1006-ps.sh issue-1006-format.ps1 (Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 over files 6 to 10, 29 to 31, and 40; one child process per file; any change written back)
EXIT_CODE: 0
Output Summary: `FORMAT_CHANGED_COUNT: 0`, `FORMAT_ERRORS: 0`; all nine files UNCHANGED. `git status --porcelain` captured before and after the run was identical (the only modified path at that point was `scripts/dev_tools/push_down_claude_blast_radius_overlay.py`, from the Ruff fix).
