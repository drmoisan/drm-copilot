# PowerShell Format Baseline (check-only) - issue 1114

Timestamp: 2026-11-07T18-59
Command: sh SCRATCH/issue-1114-static.sh baseline (PowerShell 7: for each *.ps1 and *.psm1 under .codex/hooks and tests/scripts/codex-hooks, compare the file text with Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; no file is written)
EXIT_CODE: 0
Output Summary:
- Files scanned: 141
- Files the formatter would change: 0
- `git status --porcelain` after the run: empty (0 lines)
