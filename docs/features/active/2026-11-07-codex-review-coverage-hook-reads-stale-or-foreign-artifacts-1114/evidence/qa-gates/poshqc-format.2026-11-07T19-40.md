# PowerShell Format Gate - issue 1114

Timestamp: 2026-11-07T19-40
Command: sh SCRATCH/issue-1114-format.sh final1 (PowerShell 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root <item worktree> -ScanFolders .codex/hooks, tests/scripts/codex-hooks, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks), then the check-only pass sh SCRATCH/issue-1114-static.sh final1 over the same three folders
EXIT_CODE: 0
Output Summary:
- Write-mode formatter: 201 files reported `Already formatted:`; no file was rewritten. `git status --porcelain` held 0 lines before and 0 lines after the run.
- Check-only pass after the last write: 201 files scanned; 0 files the formatter would change.
- No bundle copy needed re-copying; the loop did not restart.
- `git status --porcelain` after committing: empty.
