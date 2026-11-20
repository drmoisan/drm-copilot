# Coverage Pass 2 ([P10-T3])

Timestamp: 2026-10-10T05-42
Command: R-PESTER (Invoke-PoshQCTest, console streamed by <SCRATCHPAD>/pstream.ps1), then R-JUNIT, R-COV, and R-CHANGED-LINES (<SCRATCHPAD>/rpester.ps1 -SkipRun) for the 57 W-CHANGED-PROD files
EXIT_CODE: 0
Output Summary: Report last-write times are 2026-10-10T05-51-22 (coverage) and 2026-10-10T05-52-54 (JUnit). The console reports `Tests Passed: 9495, Failed: 0, Skipped: 10`, and the JUnit root reports tests 9505, failures 0, errors 0. Fifty-three of the 57 files are at or above 85.00.

BELOW-FLOOR (pass 2): .codex/hooks/enforce-epic-child-worktree-binding.ps1 (74.70), .codex/hooks/enforce-epic-planning-only.ps1 (82.25), .codex/hooks/hook-dependency-guard.ps1 (57.89), .codex/hooks/validate-bash.ps1 (80.25).

UNCOVERED-CHANGED (pass 2), none of which is an RS-4 known-uncovered candidate:
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466-468 (tail)
- .codex/hooks/hook-dependency-guard.ps1:103-111 (decision body)
- .codex/hooks/validate-bash.ps1:304-306 (tail)

KNOWN-UNCOVERED: none

ACCEPTANCE-GAP: the acceptance requires every COVERAGE: percent to be at least 85.00 and every UNCOVERED-CHANGED line to be a known-uncovered candidate. Neither holds for the four Codex files above. Existing tests execute these lines and pass, and coverage runs scoped to tests/scripts/codex-hooks, or to the claude-hooks, claude-lib, claude-runtime, and codex-hooks set, report them covered: validate-bash.ps1, hook-dependency-guard.ps1, and enforce-orchestration-preimplementation-gate.ps1 each miss one command, and enforce-epic-child-worktree-binding.ps1 misses 13 of 214. In full-suite runs the per-file results for these Codex files vary between runs while the overall total stays the same (87.07% in both of the last two runs). The Pester 5.6.1 profiler tracer is therefore not attributing these hits consistently in the full run. One cause, B1 mocks built with [scriptblock]::Create, was found and removed ([P10-T2]); the remaining cause is not identified. [P10-T3] is left unchecked and escalated (deviations.md, [P10-T3]).

```text
Tests completed in 538.71s
Tests Passed: 9495, 
Failed: 0, 
Skipped: 10, 
Covered 87.07% / 0%. 25,713 analyzed Commands in 192 Files.
```

```text
RUN_START: 2026-10-10T05-53-05
JUNIT_LAST_WRITE: 2026-10-10T05-52-54
COVERAGE_LAST_WRITE: 2026-10-10T05-51-22
JUNIT_ROOT: tests=9505 failures=0 errors=0
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
COVERAGE: .claude/hooks/enforce-epic-merge-gate.ps1 | 99.25 | covered=132 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-merge-gate.ps1 | covered=12 | total=12
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
COVERAGE: .claude/hooks/validate-feature-review-coverage.ps1 | 97.22 | covered=210 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-feature-review-coverage.ps1 | covered=6 | total=6
COVERAGE: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 98.94 | covered=93 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-orchestrator-output-resolution.ps1 | covered=0 | total=0
COVERAGE: .claude/hooks/validate-orchestrator-output.ps1 | 95.42 | covered=125 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-orchestrator-output.ps1 | covered=15 | total=15
COVERAGE: .claude/hooks/validate-planner-output.ps1 | 97.94 | covered=190 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-planner-output.ps1 | covered=6 | total=6
COVERAGE: .claude/hooks/validate-pr-author-output.ps1 | 100.00 | covered=39 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-pr-author-output.ps1 | covered=6 | total=6
COVERAGE: .claude/hooks/validate-prd-feature-output.ps1 | 98.15 | covered=53 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-prd-feature-output.ps1 | covered=6 | total=6
COVERAGE: .codex/hooks/check-powershell-test-purity.ps1 | 100.00 | covered=68 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/check-powershell-test-purity.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/check-python-test-purity.ps1 | 100.00 | covered=73 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/check-python-test-purity.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 98.48 | covered=65 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/codex-epic-child-launch-attestation.ps1 | covered=1 | total=1
COVERAGE: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 99.09 | covered=109 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-checkpoint-monotonic.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-codex-model-routing.ps1 | 100.00 | covered=78 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-codex-model-routing.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-completion-consistency.ps1 | 100.00 | covered=153 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-completion-consistency.ps1 | covered=9 | total=9
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 74.70 | covered=124 | missed=42 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.09 | covered=154 | missed=3 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-merge-gate.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 82.25 | covered=139 | missed=30 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-planning-only.ps1 | covered=6 | total=6
COVERAGE: .codex/hooks/enforce-epic-root-invocation.ps1 | 100.00 | covered=56 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-root-invocation.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-epic-wave-barrier.ps1 | 95.68 | covered=133 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-wave-barrier.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.72 | covered=77 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-evidence-locations.ps1 | 100.00 | covered=47 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-evidence-locations.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 86.55 | covered=148 | missed=23 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466 | if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('PREIMPLEMENTATION_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
UNCOVERED-CHANGED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:467 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'PREIMPLEMENTATION_GATE_BLOCKED:'
UNCOVERED-CHANGED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:468 | if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }
CHANGED-LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | covered=9 | total=12
COVERAGE: .codex/hooks/enforce-powershell-batch-budget.ps1 | 99.05 | covered=104 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-powershell-batch-budget.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-promotion-mcp-only.ps1 | 100.00 | covered=71 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-promotion-mcp-only.ps1 | covered=8 | total=8
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
COVERAGE: .codex/hooks/validate-codex-subagent-routing.ps1 | 100.00 | covered=68 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/validate-codex-subagent-routing.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/validate-feature-review-coverage.ps1 | 99.29 | covered=140 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/validate-feature-review-coverage.ps1 | covered=4 | total=4
```
