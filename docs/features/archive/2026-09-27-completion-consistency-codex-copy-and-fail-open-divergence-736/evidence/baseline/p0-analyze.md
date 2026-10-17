# Baseline analyzer findings ([P0-T10])

Timestamp: 2026-10-08T17-31
Command: pwsh -NoProfile -Command 'Import-Module PSScriptAnalyzer; foreach ($p in @(<7 paths>)) { $r = @(Invoke-ScriptAnalyzer -Path $p -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information); "PSSA_FINDINGS $p=$($r.Count)"; ... }'
EXIT_CODE: 0
Output Summary: seven PSSA_FINDINGS lines, all zero; no PSSA_RULE lines.

PSSA_FINDINGS .claude/hooks/enforce-completion-consistency.ps1=0
PSSA_FINDINGS .claude/hooks/enforce-completion-helpers.ps1=0
PSSA_FINDINGS .codex/hooks/enforce-completion-consistency.ps1=0
PSSA_FINDINGS .codex/hooks/enforce-completion-helpers.ps1=0
PSSA_FINDINGS tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1=0
PSSA_FINDINGS tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1=0
PSSA_FINDINGS tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1=0
