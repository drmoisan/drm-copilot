# Static baseline - PowerShell PSScriptAnalyzer

Timestamp: 2026-11-17T20-23
Command: sh SCRATCH/issue-1201-ps-static.sh <the four gate copies> (Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary:
- Findings: 0 across .claude/hooks/enforce-orchestration-preimplementation-gate.ps1, .codex/hooks/enforce-orchestration-preimplementation-gate.ps1, and their two bundle copies.
- Physical line counts: Claude gate 493 (both copies); Codex gate 485 (both copies).
