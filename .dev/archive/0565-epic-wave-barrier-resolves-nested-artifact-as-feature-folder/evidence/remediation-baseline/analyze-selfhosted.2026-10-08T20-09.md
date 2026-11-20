# Remediation Baseline: Analyzer (self-hosted, 12 paths)

Timestamp: 2026-10-08T20-09
Command: Import-Module PSScriptAnalyzer; $r = @(foreach ($f in @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1', '.claude/hooks/enforce-epic-wave-barrier.ps1', '.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-drift-gate.ps1', 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1')) { Invoke-ScriptAnalyzer -Path $f -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1' -Severity Error, Warning, Information }); 'Findings=' + $r.Count; $r | ForEach-Object { 'FINDING ' + $_.ScriptName + ':' + $_.Line + ' ' + $_.RuleName }; exit ([int]($r.Count -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T17.ps1
EXIT_CODE: 0
Output Summary: Findings=0.

```
Findings=0
```
