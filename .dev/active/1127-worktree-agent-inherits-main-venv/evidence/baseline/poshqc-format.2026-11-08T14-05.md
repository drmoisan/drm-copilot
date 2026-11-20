# Baseline: PoshQC format check (P0-T1)

Timestamp: 2026-11-08T14-05
Command: sh SCRATCH/issue-1127-static.sh p0 (imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat -Root <item worktree> -ScanFolders .claude/hooks,.codex/hooks,tests/scripts/claude-hooks,tests/scripts/codex-hooks with a no-op -WriteFile scriptblock and a capturing -Logger)
EXIT_CODE: 0
Output Summary:
- Files checked: 461
- `Already formatted:` lines: 461
- `Formatted:` lines: 0
- Check-only run: the no-op WriteFile scriptblock wrote no file.
