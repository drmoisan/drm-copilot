# Baseline: PowerShell format check (issue 1105)

Timestamp: 2026-11-07T14-34
Task: [P0-T2]
Command: sh SCRATCH/issue-1105-static.sh baseline (pwsh -NoProfile -File SCRATCH/issue-1105-static.ps1: for every `*.ps1` and `*.psm1` file under `.claude/hooks` and `tests/scripts/claude-hooks`, compares `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` output with the file content; check-only, no file is written)
EXIT_CODE: 0
Output Summary:
- Files scanned: 295
- Files the formatter would change: 0
- The tree was not rewritten.
