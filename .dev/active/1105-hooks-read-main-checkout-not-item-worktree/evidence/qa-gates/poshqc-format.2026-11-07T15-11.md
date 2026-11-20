# QA gate: PowerShell format (issue 1105)

Timestamp: 2026-11-07T15-11
Task: [P4-T1]
Command: sh SCRATCH/issue-1105-format.sh final1 (pwsh -NoProfile: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root <item worktree> -ScanFolders @(".claude/hooks", "tests/scripts/claude-hooks")`)
EXIT_CODE: 0
Output Summary:
- Files processed: 305 (295 at baseline plus the 2 new hook files and the 8 new suites).
- Files changed by the formatter: 0 (every file reported `Already formatted:`).
- Tree observation: `git status --porcelain` listed 0 lines before the run and 0 lines after it; the worktree has no unstaged change.
- A check-only comparison in the same pass (SCRATCH/issue-1105-static.ps1) also reported 0 files the formatter would change.
