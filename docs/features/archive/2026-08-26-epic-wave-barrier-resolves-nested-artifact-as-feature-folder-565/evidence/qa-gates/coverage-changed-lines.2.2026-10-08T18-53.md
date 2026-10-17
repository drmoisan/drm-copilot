# Changed-Line Coverage (PS-EXISTING), Final QC Iteration 2

Timestamp: 2026-10-08T18-53
Command: $mb = '991aae0a180a09d504b59bc9460ec4b00b85d11b'; [xml]$x = Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml; foreach ($p in @(<PS-EXISTING, seven paths>)) { ... 'CHANGED ' + $p + ' Executable=' + $ln.Count + ' Covered=' + ($ln.Count - $un.Count) + ' Uncovered=' + ($un -join ',') }  (CLC template; full body in <scratchpad>/c2-565-P10-T11.ps1)
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P10-T11.ps1
EXIT_CODE: 0
Output Summary: FAIL for this iteration. Eight uncovered changed lines lie inside the catch body of a D6 dot-source guard (quoted below). Two uncovered changed lines in enforce-feature-folder-order.ps1 are not catch bodies and are blocking findings: line 117 (the -RequiredFile default value of Get-FeatureFolderMissingFile, which no test exercises) and line 281 (the script-tail exit statement, which never runs under dot-sourcing; it is marked changed only because the P6-T2 Write appended a trailing newline that the original file did not have, and its text is identical). Remediation: add a test that calls Get-FeatureFolderMissingFile without -RequiredFile, restore the original no-trailing-newline file ending, re-run P6-T5, and restart the loop at P10-T1 (iteration 3).

```
CHANGED .claude/hooks/enforce-epic-wave-barrier.ps1 Executable=15 Covered=13 Uncovered=62,63
CHANGED .claude/hooks/enforce-parallel-cohort-barrier.ps1 Executable=17 Covered=15 Uncovered=82,83
CHANGED .claude/hooks/enforce-parallel-drift-gate.ps1 Executable=16 Covered=15 Uncovered=93
CHANGED .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Executable=19 Covered=18 Uncovered=41
CHANGED .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Executable=19 Covered=18 Uncovered=41
CHANGED .claude/hooks/enforce-feature-folder-order.ps1 Executable=32 Covered=29 Uncovered=50,117,281
CHANGED .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 Executable=7 Covered=6 Uncovered=39
```

Uncovered lines and their source:

| File:line | Source | Inside a D6 catch body |
|---|---|---|
| enforce-epic-wave-barrier.ps1:62 | `if (-not $script:EpicWaveBarrierResolutionImportFailure) {` | yes |
| enforce-epic-wave-barrier.ps1:63 | `$script:EpicWaveBarrierResolutionImportFailure = 'feature-folder-resolution.ps1'` | yes |
| enforce-parallel-cohort-barrier.ps1:82 | `if (-not $script:ParallelCohortBarrierResolutionImportFailure) {` | yes |
| enforce-parallel-cohort-barrier.ps1:83 | `$script:ParallelCohortBarrierResolutionImportFailure = 'feature-folder-resolution.ps1'` | yes |
| enforce-parallel-drift-gate.ps1:93 | `if (-not $script:ParallelDriftGateResolutionImportFailure) { $script:ParallelDriftGateResolutionImportFailure = 'feature-folder-resolution.ps1' }` | yes |
| .claude/hooks/...-modes.ps1:41 | `$script:OrchestrationFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'` | yes |
| .codex/hooks/...-modes.ps1:41 | `$script:OrchestrationFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'` | yes |
| enforce-feature-folder-order.ps1:50 | `$script:FeatureFolderOrderResolutionImportFailure = 'feature-folder-resolution.ps1'` | yes |
| enforce-feature-folder-order.ps1:117 | `[string[]] $RequiredFile = @('issue.md', 'spec.md', 'user-story.md')` | no (blocking) |
| enforce-feature-folder-order.ps1:281 | `exit ([int]$entryPointResult[-1])` | no (blocking) |
| enforce-prd-feature-before-planner-helpers.ps1:39 | `$script:PrdFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'` | yes |
