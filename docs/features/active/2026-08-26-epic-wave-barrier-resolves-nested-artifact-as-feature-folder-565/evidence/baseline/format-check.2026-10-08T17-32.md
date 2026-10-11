# Baseline Format Check (non-writing)

Timestamp: 2026-10-08T17-32
Command: Import-Module PSScriptAnalyzer; $s = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'; $n = 0; foreach ($f in @(<PS-EXISTING plus W29, W30, W31>)) { $o = (Get-Content -Raw -LiteralPath $f) -replace '\r?\n', [string][char]10; $t = Invoke-Formatter -ScriptDefinition $o -Settings $s; if ($t -ne $o) { $n++; 'FORMAT-DRIFT ' + $f } else { 'FORMAT-CLEAN ' + $f } }; exit ([int]($n -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P0-T15.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: 10 FORMAT-CLEAN, 0 FORMAT-DRIFT. No pre-existing drift. No writing formatter was run before this baseline.

```
FORMAT-CLEAN .claude/hooks/enforce-epic-wave-barrier.ps1
FORMAT-CLEAN .claude/hooks/enforce-parallel-cohort-barrier.ps1
FORMAT-CLEAN .claude/hooks/enforce-parallel-drift-gate.ps1
FORMAT-CLEAN .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
FORMAT-CLEAN .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
FORMAT-CLEAN .claude/hooks/enforce-feature-folder-order.ps1
FORMAT-CLEAN .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
FORMAT-CLEAN tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```
