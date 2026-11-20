# PowerShell static baseline (P0-T1)

Timestamp: 2026-11-08T13-32
Command: pwsh -NoProfile -File SCRATCH/issue-1128-static.ps1 -Root <worktree> -Phase P0 (Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, Severity Error/Warning/Information, plus Invoke-Formatter check-only comparison, over .claude/hooks, .claude/lib, tests/scripts/claude-hooks, tests/scripts/claude-lib)
EXIT_CODE: 0
Output Summary: Files=708 AnalyzerFindings=0 FormatDriftFiles=0. `git status --porcelain` showed no tracked change after the run (the format check is read-only).
