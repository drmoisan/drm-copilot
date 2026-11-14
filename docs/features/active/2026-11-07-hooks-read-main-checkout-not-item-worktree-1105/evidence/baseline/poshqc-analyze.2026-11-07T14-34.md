# Baseline: PSScriptAnalyzer (issue 1105)

Timestamp: 2026-11-07T14-34
Task: [P0-T2]
Command: sh SCRATCH/issue-1105-static.sh baseline (pwsh -NoProfile -File SCRATCH/issue-1105-static.ps1: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` for every `*.ps1` and `*.psm1` file under `.claude/hooks` and `tests/scripts/claude-hooks`)
EXIT_CODE: 0
Output Summary:
- Files scanned: 295
- Findings: 0 (Error: 0, Warning: 0, Information: 0)
- Files with findings: none
