Timestamp: 2026-08-31T11-30
Command: `Import-Module PSScriptAnalyzer -ErrorAction Stop; $path = '.codex/hooks/enforce-epic-planning-only.ps1'; $source = (Get-Content -Raw -LiteralPath $path) -replace "`r?`n", "`n"; $formatted = Invoke-Formatter -ScriptDefinition $source -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'; if ($formatted -cne $source) { Write-Error "$path is not formatter-equivalent"; exit 1 }`
EXIT_CODE: 0
Output Summary: PASS. The source bytes were formatter-equivalent after newline normalization. The command performed no write operation, and a scoped Git status check confirmed zero file changes.
