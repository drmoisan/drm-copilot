# PSScriptAnalyzer Baseline: scripts/dev-tools (Issue #1080, P0-T6)

Timestamp: 2026-11-04T20-37
Command: sh SCRATCH/issue-1080-tool.sh issue-1080-pssa.ps1 issue-1080-p0t6.log scripts/dev-tools (SCRATCH/issue-1080-pssa.ps1 runs Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 once per top-level .ps1 file of scripts/dev-tools, retrying once on an analyzer exception)
EXIT_CODE: 0

## Result

- FILES-CHECKED=29
- PSSA-FINDINGS=0
- ANALYZER-ERRORS=0
- Findings: none.

Output Summary: analyzer baseline over the 29 .ps1 files of scripts/dev-tools: PSSA-FINDINGS=0, no analyzer errors.
