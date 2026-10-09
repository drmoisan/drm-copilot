# Baseline format state ([P0-T9])

Timestamp: 2026-10-08T17-31
Command: pwsh -NoProfile -Command 'Import-Module PSScriptAnalyzer; foreach ($p in @(<7 paths>)) { $n = (Get-Content -Raw -LiteralPath $p) -replace "`r?`n", "`n"; $f = Invoke-Formatter -ScriptDefinition $n -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; "FORMAT_UNCHANGED=$($f -eq $n) $p" }'
EXIT_CODE: 0
Output Summary: seven lines, all FORMAT_UNCHANGED=True.

FORMAT_UNCHANGED=True .claude/hooks/enforce-completion-consistency.ps1
FORMAT_UNCHANGED=True .claude/hooks/enforce-completion-helpers.ps1
FORMAT_UNCHANGED=True .codex/hooks/enforce-completion-consistency.ps1
FORMAT_UNCHANGED=True .codex/hooks/enforce-completion-helpers.ps1
FORMAT_UNCHANGED=True tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1
FORMAT_UNCHANGED=True tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1
FORMAT_UNCHANGED=True tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
