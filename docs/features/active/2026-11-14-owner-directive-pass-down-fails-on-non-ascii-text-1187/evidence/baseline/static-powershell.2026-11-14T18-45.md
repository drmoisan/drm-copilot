# Static PowerShell Baseline (P0-T1)

Timestamp: 2026-11-14T18-44
Command: sh SCRATCH/issue-1187-static-p0.sh (pwsh -NoProfile -File SCRATCH/issue-1187-static.ps1 <files>; per file: check-only Invoke-Formatter -ScriptDefinition <LF-normalized content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared ordinally with the content, no file written; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary:
- .claude/hooks/invoke-pretooluse-dispatch.ps1: formatter-unchanged=True, pssa-findings=0
- .codex/hooks/invoke-pretooluse-dispatch.ps1: formatter-unchanged=True, pssa-findings=0
- tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1: formatter-unchanged=True, pssa-findings=0
- tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1: formatter-unchanged=True, pssa-findings=0
- tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1: formatter-unchanged=True, pssa-findings=0
- tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1: formatter-unchanged=True, pssa-findings=0
- tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.Tests.ps1: formatter-unchanged=True, pssa-findings=0
- tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1: formatter-unchanged=True, pssa-findings=0
- SUMMARY files=8 formatter-would-change=0 pssa-total=0
