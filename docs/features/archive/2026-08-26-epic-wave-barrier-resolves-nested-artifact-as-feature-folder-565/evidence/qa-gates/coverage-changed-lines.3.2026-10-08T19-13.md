# Changed-Line Coverage (PS-EXISTING), Final QC Iteration 3

Timestamp: 2026-10-08T19-13
Command: $mb = '991aae0a180a09d504b59bc9460ec4b00b85d11b'; [xml]$x = Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml; foreach ($p in @(<PS-EXISTING, seven paths>)) { ... 'CHANGED ' + $p + ' Executable=' + $ln.Count + ' Covered=' + ($ln.Count - $un.Count) + ' Uncovered=' + ($un -join ',') }  (CLC template; full body in <scratchpad>/c2-565-P10-T11.ps1)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P10-T11.ps1
EXIT_CODE: 0
Output Summary: PASS. Every uncovered changed line is inside the catch body of a D6 dot-source guard (quoted below), which runs only when feature-folder-resolution.ps1 fails to load. The iteration 2 blocking lines in enforce-feature-folder-order.ps1 are resolved: line 117 (-RequiredFile default) is now covered by a test, and the final exit line is no longer a changed line. W01 and W09 are new files; their whole-file coverage (100.00%) is governed by P10-T10.

```
CHANGED .claude/hooks/enforce-epic-wave-barrier.ps1 Executable=15 Covered=13 Uncovered=62,63
CHANGED .claude/hooks/enforce-parallel-cohort-barrier.ps1 Executable=17 Covered=15 Uncovered=82,83
CHANGED .claude/hooks/enforce-parallel-drift-gate.ps1 Executable=16 Covered=15 Uncovered=93
CHANGED .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Executable=19 Covered=18 Uncovered=41
CHANGED .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Executable=19 Covered=18 Uncovered=41
CHANGED .claude/hooks/enforce-feature-folder-order.ps1 Executable=31 Covered=30 Uncovered=50
CHANGED .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 Executable=7 Covered=6 Uncovered=39
```

| File:line | Source line | Enclosing construct |
|---|---|---|
| enforce-epic-wave-barrier.ps1:62 | `if (-not $script:EpicWaveBarrierResolutionImportFailure) {` | catch body of the feature-folder-resolution.ps1 dot-source guard |
| enforce-epic-wave-barrier.ps1:63 | `$script:EpicWaveBarrierResolutionImportFailure = 'feature-folder-resolution.ps1'` | same catch body |
| enforce-parallel-cohort-barrier.ps1:82 | `if (-not $script:ParallelCohortBarrierResolutionImportFailure) {` | catch body of the feature-folder-resolution.ps1 dot-source guard |
| enforce-parallel-cohort-barrier.ps1:83 | `$script:ParallelCohortBarrierResolutionImportFailure = 'feature-folder-resolution.ps1'` | same catch body |
| enforce-parallel-drift-gate.ps1:93 | `if (-not $script:ParallelDriftGateResolutionImportFailure) { $script:ParallelDriftGateResolutionImportFailure = 'feature-folder-resolution.ps1' }` | catch body of the feature-folder-resolution.ps1 dot-source guard |
| .claude/hooks/...-modes.ps1:41 | `$script:OrchestrationFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'` | catch body of the dot-source guard |
| .codex/hooks/...-modes.ps1:41 | `$script:OrchestrationFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'` | catch body of the dot-source guard |
| enforce-feature-folder-order.ps1:50 | `$script:FeatureFolderOrderResolutionImportFailure = 'feature-folder-resolution.ps1'` | catch body of the dot-source guard |
| enforce-prd-feature-before-planner-helpers.ps1:39 | `$script:PrdFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'` | catch body of the dot-source guard |
