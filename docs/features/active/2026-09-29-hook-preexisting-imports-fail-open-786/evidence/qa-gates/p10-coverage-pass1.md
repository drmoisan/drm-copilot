# Coverage Pass 1 ([P10-T1])

Timestamp: 2026-10-10T01-29
Command: R-PESTER (`Invoke-PoshQCTest -Root <WORKSPACE_ROOT> -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, console streamed by <SCRATCHPAD>/pstream.ps1), then R-JUNIT, R-COV, and R-CHANGED-LINES (<SCRATCHPAD>/rpester.ps1 -SkipRun) for the 57 W-CHANGED-PROD files selected in [P9-T6]
EXIT_CODE: 0
Output Summary: report last-write times 2026-10-10T01-38-01 (coverage) and 2026-10-10T01-39-30 (JUnit), both after Timestamp. Console line: `Tests Passed: 9337, Failed: 0, Skipped: 10`. JUnit root: tests 9347, failures 0, errors 0. There is one COVERAGE: line per W-CHANGED-PROD file, each with SOURCEFILE_MATCHES: 1. An earlier attempt at this pass failed two C4 rows and is not used; RS-10 was applied before this run (deviations.md, [P10-T1]).

BELOW-FLOOR: .claude/hooks/validate-feature-review-coverage.ps1 (50.00), .claude/hooks/validate-pr-author-output.ps1 (82.05), .codex/hooks/codex-epic-child-launch-attestation.ps1 (77.27), .codex/hooks/enforce-codex-model-routing.ps1 (60.26), .codex/hooks/enforce-epic-child-worktree-binding.ps1 (74.70), .codex/hooks/enforce-epic-planning-only.ps1 (82.25), .codex/hooks/enforce-epic-root-invocation.ps1 (46.43), .codex/hooks/enforce-epic-wave-barrier.ps1 (43.17), .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 (73.68), .codex/hooks/enforce-promotion-mcp-only.ps1 (76.06), .codex/hooks/hook-dependency-guard.ps1 (57.89), .codex/hooks/validate-bash.ps1 (80.25), .codex/hooks/validate-codex-subagent-routing.ps1 (38.24), .codex/hooks/validate-feature-review-coverage.ps1 (8.51)

Observation: several Codex files that the codex-hooks folder alone covers almost fully (enforce-promotion-mcp-only.ps1, validate-bash.ps1, and hook-dependency-guard.ps1 each miss one command in a folder-only coverage run) report their entry-point tails uncovered in the full run, although the tests that execute those tails pass. This is recorded and investigated under [P10-T2].

```text
Tests completed in 533.49s
Tests Passed: 9337, 
Failed: 0, 
Skipped: 10, 
Covered 84.65% / 0%. 25,713 analyzed Commands in 192 Files.
```

```text
RUN_START: 2026-10-10T01-40-02
JUNIT_LAST_WRITE: 2026-10-10T01-39-30
COVERAGE_LAST_WRITE: 2026-10-10T01-38-01
JUNIT_ROOT: tests=9347 failures=0 errors=0
FAILING_TESTCASES: none
PACKAGES:
  <WORKSPACE_ROOT>/.claude/hooks
  <WORKSPACE_ROOT>/.claude/lib/blast-radius
  <WORKSPACE_ROOT>/.claude/lib/ci-gate
  <WORKSPACE_ROOT>/.claude/lib/cleanup-manifest
  <WORKSPACE_ROOT>/.claude/lib/codex-routing
  <WORKSPACE_ROOT>/.claude/lib/discovery-validation
  <WORKSPACE_ROOT>/.claude/lib/hook-payload
  <WORKSPACE_ROOT>/.claude/lib/mermaid
  <WORKSPACE_ROOT>/.claude/lib/model-routing
  <WORKSPACE_ROOT>/.claude/lib/orchestrator-state
  <WORKSPACE_ROOT>/.claude/lib/parallel-drift
  <WORKSPACE_ROOT>/.claude/lib/project-file-merge
  <WORKSPACE_ROOT>/.claude/lib/requirements
  <WORKSPACE_ROOT>/.claude/lib/worktree-resolution
  <WORKSPACE_ROOT>/.codex/hooks
  <WORKSPACE_ROOT>/.codex/scripts
  <WORKSPACE_ROOT>/scripts/dev-tools
  <WORKSPACE_ROOT>/scripts/powershell
  <WORKSPACE_ROOT>/scripts/powershell/PoshQC
COVERAGE: .claude/hooks/check-powershell-test-purity.ps1 | 93.44 | covered=57 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/check-powershell-test-purity.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/check-python-test-purity.ps1 | 93.94 | covered=62 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/check-python-test-purity.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-checkpoint-monotonic.ps1 | 96.00 | covered=96 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-checkpoint-monotonic.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-completion-consistency.ps1 | 93.84 | covered=137 | missed=9 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-completion-consistency.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/enforce-discovery-artifact-gate.ps1 | 95.65 | covered=66 | missed=3 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-discovery-artifact-gate.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/enforce-epic-invocation-origin.ps1 | 90.41 | covered=66 | missed=7 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-invocation-origin.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 95.24 | covered=40 | missed=2 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | covered=2 | total=2
COVERAGE: .claude/hooks/enforce-epic-merge-gate.ps1 | 96.24 | covered=128 | missed=5 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .claude/hooks/enforce-epic-merge-gate.ps1:472 | exit ([int]$entryPointResult[-1])
CHANGED-LINES: .claude/hooks/enforce-epic-merge-gate.ps1 | covered=11 | total=12
COVERAGE: .claude/hooks/enforce-epic-wave-barrier.ps1 | 98.96 | covered=95 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-wave-barrier.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 98.04 | covered=50 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | covered=1 | total=1
COVERAGE: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 96.52 | covered=111 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | covered=11 | total=11
COVERAGE: .claude/hooks/enforce-evidence-locations.ps1 | 91.30 | covered=42 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-evidence-locations.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-feature-folder-order.ps1 | 93.94 | covered=62 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-feature-folder-order.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-mermaid-validation.ps1 | 94.12 | covered=80 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-mermaid-validation.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-model-routing-receipt.ps1 | 95.89 | covered=70 | missed=3 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-model-routing-receipt.ps1 | covered=9 | total=9
COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 98.63 | covered=72 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | covered=4 | total=4
COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 96.86 | covered=154 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | covered=12 | total=12
COVERAGE: .claude/hooks/enforce-parallel-abandon-gate.ps1 | 94.05 | covered=79 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-parallel-abandon-gate.ps1 | covered=9 | total=9
COVERAGE: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 98.78 | covered=81 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | covered=10 | total=10
COVERAGE: .claude/hooks/enforce-parallel-drift-gate.ps1 | 99.15 | covered=116 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-parallel-drift-gate.ps1 | covered=10 | total=10
COVERAGE: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 93.64 | covered=103 | missed=7 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | covered=11 | total=11
COVERAGE: .claude/hooks/enforce-powershell-batch-budget.ps1 | 95.65 | covered=132 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-powershell-batch-budget.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/enforce-pr-author-skill.ps1 | 92.98 | covered=53 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-pr-author-skill.ps1 | covered=12 | total=12
COVERAGE: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 96.61 | covered=57 | missed=2 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | covered=1 | total=1
COVERAGE: .claude/hooks/enforce-prd-feature-before-planner.ps1 | 96.97 | covered=96 | missed=3 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-prd-feature-before-planner.ps1 | covered=10 | total=10
COVERAGE: .claude/hooks/enforce-promotion-mcp-only.ps1 | 93.94 | covered=62 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-promotion-mcp-only.ps1 | covered=9 | total=9
COVERAGE: .claude/hooks/enforce-python-batch-budget.ps1 | 95.65 | covered=132 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-python-batch-budget.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/hook-dependency-guard.ps1 | covered=19 | total=19
COVERAGE: .claude/hooks/validate-bash.ps1 | 94.95 | covered=94 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-bash.ps1 | covered=9 | total=9
COVERAGE: .claude/hooks/validate-discovery-artifact-gate.ps1 | 92.65 | covered=63 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-discovery-artifact-gate.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/validate-feature-review-coverage.ps1 | 50.00 | covered=108 | missed=108 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .claude/hooks/validate-feature-review-coverage.ps1:456 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-feature-review-coverage:'
UNCOVERED-CHANGED: .claude/hooks/validate-feature-review-coverage.ps1:457 | if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
CHANGED-LINES: .claude/hooks/validate-feature-review-coverage.ps1 | covered=4 | total=6
COVERAGE: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 98.94 | covered=93 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-orchestrator-output-resolution.ps1 | covered=0 | total=0
COVERAGE: .claude/hooks/validate-orchestrator-output.ps1 | 95.42 | covered=125 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-orchestrator-output.ps1 | covered=15 | total=15
COVERAGE: .claude/hooks/validate-planner-output.ps1 | 95.36 | covered=185 | missed=9 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .claude/hooks/validate-planner-output.ps1:407 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-planner-output:'
UNCOVERED-CHANGED: .claude/hooks/validate-planner-output.ps1:408 | if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
CHANGED-LINES: .claude/hooks/validate-planner-output.ps1 | covered=4 | total=6
COVERAGE: .claude/hooks/validate-pr-author-output.ps1 | 82.05 | covered=32 | missed=7 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .claude/hooks/validate-pr-author-output.ps1:132 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'PR_AUTHOR_OUTPUT_MISSING:'
UNCOVERED-CHANGED: .claude/hooks/validate-pr-author-output.ps1:133 | if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
CHANGED-LINES: .claude/hooks/validate-pr-author-output.ps1 | covered=4 | total=6
COVERAGE: .claude/hooks/validate-prd-feature-output.ps1 | 90.74 | covered=49 | missed=5 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .claude/hooks/validate-prd-feature-output.ps1:93 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-prd-feature-output:'
UNCOVERED-CHANGED: .claude/hooks/validate-prd-feature-output.ps1:94 | if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
CHANGED-LINES: .claude/hooks/validate-prd-feature-output.ps1 | covered=4 | total=6
COVERAGE: .codex/hooks/check-powershell-test-purity.ps1 | 100.00 | covered=68 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/check-powershell-test-purity.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/check-python-test-purity.ps1 | 100.00 | covered=73 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/check-python-test-purity.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 77.27 | covered=51 | missed=15 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/codex-epic-child-launch-attestation.ps1 | covered=1 | total=1
COVERAGE: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 99.09 | covered=109 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-checkpoint-monotonic.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-codex-model-routing.ps1 | 60.26 | covered=47 | missed=31 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-codex-model-routing.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-completion-consistency.ps1 | 100.00 | covered=153 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-completion-consistency.ps1 | covered=9 | total=9
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 74.70 | covered=124 | missed=42 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.09 | covered=154 | missed=3 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-merge-gate.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 82.25 | covered=139 | missed=30 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-planning-only.ps1 | covered=6 | total=6
COVERAGE: .codex/hooks/enforce-epic-root-invocation.ps1 | 46.43 | covered=26 | missed=30 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-root-invocation.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-epic-wave-barrier.ps1 | 43.17 | covered=60 | missed=79 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/enforce-epic-wave-barrier.ps1:258 | if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('EPIC_WAVE_BARRIER_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
UNCOVERED-CHANGED: .codex/hooks/enforce-epic-wave-barrier.ps1:259 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'EPIC_WAVE_BARRIER_BLOCKED:'
UNCOVERED-CHANGED: .codex/hooks/enforce-epic-wave-barrier.ps1:260 | if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }
CHANGED-LINES: .codex/hooks/enforce-epic-wave-barrier.ps1 | covered=4 | total=7
COVERAGE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.72 | covered=77 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-evidence-locations.ps1 | 100.00 | covered=47 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-evidence-locations.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 73.68 | covered=126 | missed=45 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466 | if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('PREIMPLEMENTATION_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
UNCOVERED-CHANGED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:467 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'PREIMPLEMENTATION_GATE_BLOCKED:'
UNCOVERED-CHANGED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:468 | if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }
CHANGED-LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | covered=9 | total=12
COVERAGE: .codex/hooks/enforce-powershell-batch-budget.ps1 | 99.05 | covered=104 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-powershell-batch-budget.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-promotion-mcp-only.ps1 | 76.06 | covered=54 | missed=17 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/enforce-promotion-mcp-only.ps1:282 | if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('PROMOTION_MCP_ONLY_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
UNCOVERED-CHANGED: .codex/hooks/enforce-promotion-mcp-only.ps1:283 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'PROMOTION_MCP_ONLY_BLOCKED:'
UNCOVERED-CHANGED: .codex/hooks/enforce-promotion-mcp-only.ps1:284 | if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }
CHANGED-LINES: .codex/hooks/enforce-promotion-mcp-only.ps1 | covered=5 | total=8
COVERAGE: .codex/hooks/enforce-python-batch-budget.ps1 | 99.05 | covered=104 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-python-batch-budget.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 57.89 | covered=11 | missed=8 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:103 | $reason = Get-HookDependencyFailureReason -ReasonPrefix $ReasonPrefix
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:104 | if ($HookEvent -eq 'SubagentStop') {
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:105 | return [pscustomobject]@{ ExitCode = 2; Reason = $reason }
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:107 | return [ordered]@{
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:108 | hookSpecificOutput = [ordered]@{
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:109 | hookEventName            = 'PreToolUse'
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:110 | permissionDecision       = 'deny'
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:111 | permissionDecisionReason = $reason
CHANGED-LINES: .codex/hooks/hook-dependency-guard.ps1 | covered=11 | total=19
COVERAGE: .codex/hooks/validate-bash.ps1 | 80.25 | covered=65 | missed=16 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/validate-bash.ps1:304 | if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('HOOK_DEPENDENCY_LOAD_FAILED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
UNCOVERED-CHANGED: .codex/hooks/validate-bash.ps1:305 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'HOOK_DEPENDENCY_LOAD_FAILED:'
UNCOVERED-CHANGED: .codex/hooks/validate-bash.ps1:306 | if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }
CHANGED-LINES: .codex/hooks/validate-bash.ps1 | covered=5 | total=8
COVERAGE: .codex/hooks/validate-codex-subagent-routing.ps1 | 38.24 | covered=26 | missed=42 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/validate-codex-subagent-routing.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/validate-feature-review-coverage.ps1 | 8.51 | covered=12 | missed=129 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/validate-feature-review-coverage.ps1:234 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-feature-review-coverage:'
UNCOVERED-CHANGED: .codex/hooks/validate-feature-review-coverage.ps1:235 | if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
CHANGED-LINES: .codex/hooks/validate-feature-review-coverage.ps1 | covered=2 | total=4
```
