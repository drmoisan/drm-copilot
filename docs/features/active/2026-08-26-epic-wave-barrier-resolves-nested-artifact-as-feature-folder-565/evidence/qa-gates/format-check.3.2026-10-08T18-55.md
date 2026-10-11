# Format Check (non-writing), Final QC Iteration 3

Timestamp: 2026-10-08T18-55
Command: Import-Module PSScriptAnalyzer; $s = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'; $n = 0; foreach ($f in @(<PS-PROD plus PS-TESTS, 20 paths>)) { $o = (Get-Content -Raw -LiteralPath $f) -replace '\r?\n', [string][char]10; $t = Invoke-Formatter -ScriptDefinition $o -Settings $s; if ($t -ne $o) { $n++; 'FORMAT-DRIFT ' + $f } else { 'FORMAT-CLEAN ' + $f } }; exit ([int]($n -gt 0))  (full body in <scratchpad>/c2-565-P10-T2.ps1)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P10-T2.ps1
EXIT_CODE: 0
Output Summary: 20 FORMAT-CLEAN, 0 FORMAT-DRIFT (after the iteration 2 remediation of W07 and W30).

```
FORMAT-CLEAN .claude/hooks/feature-folder-resolution.ps1
FORMAT-CLEAN .claude/hooks/enforce-epic-wave-barrier.ps1
FORMAT-CLEAN .claude/hooks/enforce-parallel-cohort-barrier.ps1
FORMAT-CLEAN .claude/hooks/enforce-parallel-drift-gate.ps1
FORMAT-CLEAN .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
FORMAT-CLEAN .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
FORMAT-CLEAN .claude/hooks/enforce-feature-folder-order.ps1
FORMAT-CLEAN .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
FORMAT-CLEAN .codex/hooks/feature-folder-resolution.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
FORMAT-CLEAN tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
FORMAT-CLEAN tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
FORMAT-CLEAN tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```
