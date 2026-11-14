# PowerShell Static Remediation Baseline (issue #1157, cycle 1, P0-T1)

Timestamp: 2026-11-13T14-42
Command: sh SCRATCH/issue-1157-static.sh -File <four files below> (in the item worktree; pwsh 7: Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 comparing formatted text with file text, nothing written; Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; SHA-256 of each file before and after)
EXIT_CODE: 0
Output Summary:
- Run before any cycle 1 edit.
- .claude/hooks/validate-orchestrator-output-owner-pass-down.ps1: drift 0, analyzer findings 0, before/after hash equal.
- .claude/hooks/enforce-owner-directive-pass-down.ps1: drift 0, analyzer findings 0, before/after hash equal.
- tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1: drift 0, analyzer findings 0, before/after hash equal.
- tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1: drift 0, analyzer findings 0, before/after hash equal.
- Totals: 4 files, drift 0, findings 0.
