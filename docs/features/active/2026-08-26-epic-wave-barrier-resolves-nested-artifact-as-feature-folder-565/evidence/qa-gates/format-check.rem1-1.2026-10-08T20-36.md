# Final QC (Remediation Cycle 1, Iteration 1): Format Check (non-writing, 12 paths)

Timestamp: 2026-10-08T20-36
Command: Import-Module PSScriptAnalyzer; $s = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'; $n = 0; foreach ($f in @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1', '.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1', 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1')) { $o = (Get-Content -Raw -LiteralPath $f) -replace '\r?\n', [string][char]10; $t = Invoke-Formatter -ScriptDefinition $o -Settings $s; if ($t -ne $o) { $n++; 'FORMAT-DRIFT ' + $f } else { 'FORMAT-CLEAN ' + $f } }; exit ([int]($n -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T16.ps1 (same FMT body as the baseline)
EXIT_CODE: 0
Output Summary: 12 FORMAT-CLEAN, 0 FORMAT-DRIFT.

```
FORMAT-CLEAN .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
FORMAT-CLEAN .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
FORMAT-CLEAN .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
FORMAT-CLEAN .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
FORMAT-CLEAN .claude/hooks/enforce-epic-wave-barrier.ps1
FORMAT-CLEAN .claude/hooks/enforce-parallel-cohort-barrier.ps1
FORMAT-CLEAN .claude/hooks/enforce-parallel-drift-gate.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
FORMAT-CLEAN tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
FORMAT-CLEAN tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
```
