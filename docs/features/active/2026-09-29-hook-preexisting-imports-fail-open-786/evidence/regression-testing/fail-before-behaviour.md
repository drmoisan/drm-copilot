# Fail-Before: Dependency-Failure Behaviour ([P3-T6], expect-fail)

Timestamp: 2026-10-09T23-14
Command: git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a HEAD; git status --porcelain; R-SCOPED over tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1, tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1, tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1, tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1, tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 (sh <SCRATCHPAD>/r.sh p3t6)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 6 passed, 235 failed, 2 failed blocks; both helper containers read result=Failed (the helper does not exist yet); every B1, B2, and B3 row fails on both surfaces; C1, C2, C3, C4, C6, C7, and C8 fail; B4 (both surfaces), the three probe rows, and C5 pass; no production file has changed since [P0-T6] (PATHS_OUTSIDE_DOCS_AND_TESTS: 0); AND_ROUTE_MOCKS_OBSERVED: yes.

AND_ROUTE_MOCKS_OBSERVED: yes

Status of the rows the acceptance records with their status: B4 Claude PASSED; B4 Codex PASSED; C5 PASSED.

Both git observations, the runner output, and one CLASSIFY line per testcase follow (classification rule RS-6 applied to the first line of each FAILED message).

```text
## git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a HEAD
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-baseline-green.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-batch-budget-probe.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-execution-route.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-feature-documents-read.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-line-counts.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-mcp-poshqc-format.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-merge.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-mirror-sha.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pester-coverage.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-poshqc-analyze.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-poshqc-format.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pre-merge-state.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pytest-full.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pytest-guards.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-runsettings-coverage-path.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-upstream-precondition.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/phase0-instructions-read.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/bf1-feature-folder-order-analysis.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/commits.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/deviations.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/exemption-decisions.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H1.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H2.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H3.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H4.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H5.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H6.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H7.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H8.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-mirror.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-repo.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-reconciliation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-rows.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-guard-worklist.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-load-check.2026-10-09T00-00.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/p1-spec-change-log.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/smoke-baseline.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/stdout-guard-offenders.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p1-t3-isolation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p1-t4-isolation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p2-stdout-guard.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/regression-testing/fail-before-exemption-guard.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/regression-testing/fail-before-structural.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1
tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1
tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1
tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1
tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
## git status --porcelain
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/commits.md
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/deviations.md
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t1-isolation.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t2-isolation.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t3-isolation.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t4-isolation.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t5-isolation.md
?? tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
?? tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
?? tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
?? tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
?? tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
PATHS_OUTSIDE_DOCS_AND_TESTS: 0
## R-SCOPED
PassedCount: 6
FailedCount: 235
FailedBlocksCount: 2
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | result=Failed | passed=0 | failed=12
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | result=Failed | passed=0 | failed=11
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | result=Failed | passed=2 | failed=130
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | result=Failed | passed=2 | failed=73
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | result=Failed | passed=2 | failed=9
FAILED: H1: records a dependency failure by name | 
FAILED: H2: reports no failure before any record | 
FAILED: H3: reports a failure after a record | 
FAILED: H4: builds the reason from the prefix, the dependency name, and the first exception line | 
FAILED: H5: returns the PreToolUse deny decision in the hookSpecificOutput shape | 
FAILED: H6: returns a SubagentStop result carrying exit code 2 and the reason | 
FAILED: H7: returns null from the decision builder when nothing failed | 
FAILED: H8: keeps earlier records when the helper is dot-sourced again | 
FAILED: H9: writes nothing to any output stream when recording a failure | 
FAILED: H10: contains no Import-Module and no dot-source | 
FAILED: H11: is byte-identical across all four copies | 
FAILED: H12: stays within 500 lines | 
FAILED: H1: records a dependency failure by name | 
FAILED: H2: reports no failure before any record | 
FAILED: H3: reports a failure after a record | 
FAILED: H4: builds the reason from the prefix, the dependency name, and the first exception line | 
FAILED: H5: returns the PreToolUse deny decision in the hookSpecificOutput shape | 
FAILED: H6: returns a SubagentStop result carrying exit code 2 and the reason | 
FAILED: H7: returns null from the decision builder when nothing failed | 
FAILED: H8: keeps earlier records when the helper is dot-sourced again | 
FAILED: H9: writes nothing to any output stream when recording a failure | 
FAILED: H10: contains no Import-Module and no dot-source | 
FAILED: H12: stays within 500 lines | 
FAILED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails | simulated load failure: OrchestratorState.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill.epic-base-branch.ps1 when that direct edge fails | simulated load failure: enforce-pr-author-skill.epic-base-branch.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill-helpers.ps1 when that direct edge fails | simulated load failure: enforce-pr-author-skill-helpers.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-helpers.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-modes.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-epic-scope.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-authorization.ps1 when that direct edge fails | simulated load failure: enforce-epic-merge-gate-authorization.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-resolution.ps1 when that direct edge fails | simulated load failure: enforce-epic-merge-gate-resolution.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails | simulated load failure: CleanupWorktreeManifest.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming enforce-epic-worktree-removal-gate-resolution.ps1 when that direct edge fails | simulated load failure: enforce-epic-worktree-removal-gate-resolution.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails | simulated load failure: CleanupWorktreeManifest.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | Expected Read-ClaudeHookRawPayload to be called 0 times exactly, but was called 1 times
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .claude/hooks/check-python-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | simulated load failure: enforce-batch-budget-route.ps1
FAILED: B1: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | simulated load failure: enforce-batch-budget-route.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails | simulated load failure: enforce-completion-helpers.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeTargetResolution.psm1 when that direct edge fails | simulated load failure: WorktreeTargetResolution.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | simulated load failure: WorktreeItemResolution.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming enforce-prd-feature-before-planner-helpers.ps1 when that direct edge fails | simulated load failure: enforce-prd-feature-before-planner-helpers.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | Expected 'deny', but got $null.
FAILED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | simulated load failure: WorktreeItemResolution.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming EpicScopeResolution.psm1 when that direct edge fails | simulated load failure: EpicScopeResolution.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | Expected 'deny', but got $null.
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | Expected 'deny', but got $null.
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming enforce-parallel-cohort-barrier-helpers.ps1 when that direct edge fails | simulated load failure: enforce-parallel-cohort-barrier-helpers.ps1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | simulated load failure: HookPayload.psm1
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | Expected 'deny', but got $null.
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | Expected 'deny', but got $null.
FAILED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming enforce-parallel-drift-gate-helpers.ps1 when that direct edge fails | simulated load failure: enforce-parallel-drift-gate-helpers.ps1
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails | simulated load failure: OrchestratorState.psm1
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-resolution.ps1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateEpicWaveBarrier.psm1 when that direct edge fails | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B2: PreToolUse .claude/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-planner-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-pr-author-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B3: PreToolUse .claude/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | discovery artifact gate hook: CLAUDE_HOOK_INPUT is empty
FAILED: B3: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | feature-review hook: CLAUDE_HOOK_INPUT is empty; cannot validate review output.
FAILED: B3: SubagentStop .claude/hooks/validate-planner-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | atomic-planner hook: CLAUDE_HOOK_INPUT is empty; cannot validate planner output.
FAILED: B3: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | prd-feature hook: CLAUDE_HOOK_INPUT is empty.
FAILED: B3: SubagentStop .claude/hooks/validate-pr-author-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | PR_AUTHOR_OUTPUT_MISSING: CLAUDE_HOOK_INPUT is empty; the pr-author agent produced no transcript to validate.
FAILED: B3: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.
FAILED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-helpers.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-modes.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails | simulated load failure: enforce-orchestration-preimplementation-gate-epic-scope.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | simulated load failure: hook-command-scanner.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | simulated load failure: hook-command-invocation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails | simulated load failure: codex-authority-store.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails | simulated load failure: codex-authority-store.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-agent-profile-attestation.ps1 when that direct edge fails | simulated load failure: codex-agent-profile-attestation.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 blocks naming codex-epic-child-launch-attestation.ps1 when that direct edge fails | simulated load failure: codex-epic-child-launch-attestation.ps1
FAILED: B1: PreToolUse .codex/hooks/check-python-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | simulated load failure: enforce-batch-budget-route.ps1
FAILED: B1: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | simulated load failure: enforce-batch-budget-route.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-checkpoint-monotonic.ps1 when that direct edge fails | simulated load failure: enforce-checkpoint-monotonic.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | simulated load failure: codex-pretooluse-file-mapping.ps1
FAILED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails | simulated load failure: enforce-completion-helpers.ps1
FAILED: B1: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails | simulated load failure: codex-authority-store.ps1
FAILED: B2: PreToolUse .codex/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B2: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | Expected $true, but got $false.
FAILED: B3: PreToolUse .codex/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected 2, but got 0.
FAILED: B3: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected $true, because Cannot bind argument to parameter 'AgentId' it is an empty string., but got $false.
FAILED: B3: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | Expected $true, because Feature-review coverage validator error: validate-feature-review-coverage hook input requires boolean stop_hook_active., but got $false.
FAILED: X1: .codex/hooks/enforce-epic-wave-barrier.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure | The term 'Test-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: X1: .codex/hooks/enforce-epic-child-worktree-binding.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure | The term 'Test-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: X2: .codex/hooks/enforce-epic-wave-barrier.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load | The term 'synthetic-missing/epic-child-launch-contract.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: X2: .codex/hooks/enforce-epic-child-worktree-binding.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load | The term 'synthetic-missing/epic-child-launch-contract.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: X3: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED: | simulated load failure: hook-command-scanner.ps1
FAILED: C1: reports a nested EpicScopeReadiness.psm1 failure under enforce-pr-author-skill-helpers.ps1 as that top-level dependency | simulated load failure: EpicScopeReadiness.psm1
FAILED: C2: reports a nested hook-command-scanner.ps1 load failure under enforce-pr-author-skill.epic-base-branch.ps1 as that top-level dependency | The term 'synthetic-missing/hook-command-scanner.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: C3: denies through the merge gate when enforce-epic-merge-gate-authorization.ps1 fails to load | simulated load failure: enforce-epic-merge-gate-authorization.ps1
FAILED: C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1 | Expected a value, because the pre-loaded OrchestratorStateUnconditional must satisfy the Get-Command check for Get-OrchestratorStateUnconditionalError, but got $null or empty.
FAILED: C4: makes the pre-loaded OrchestratorStateCompletion visible to the lazy-load check in .claude/hooks/validate-orchestrator-output.ps1 | Expected a value, because the pre-loaded OrchestratorStateCompletion must satisfy the Get-Command check for Test-OrchestratorStateCompletionReadiness, but got $null or empty.
FAILED: C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1 | Expected a value, because the pre-loaded OrchestratorStateUnconditional must satisfy the Get-Command check for Get-OrchestratorStateUnconditionalError, but got $null or empty.
FAILED: C6: enforce-mermaid-validation.ps1 denies naming HookPayload.psm1 when that import fails | simulated load failure: HookPayload.psm1
FAILED: C7: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED: | simulated load failure: HookPayload.psm1
FAILED: C8: .claude/hooks/validate-orchestrator-output.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail | simulated load failure: OrchestratorState.psm1
PASSED: baseline mock interception probe
PASSED: B4: has a reason-prefix entry for every discovered Claude hook and no other
PASSED: baseline mock interception probe
PASSED: B4: has a reason-prefix entry for every discovered Codex hook and no other
PASSED: baseline mock interception probe
PASSED: C5: enforce-mermaid-validation.ps1 returns no deny when MermaidValidation is unavailable
FAILED-BLOCK: hook-dependency-guard.ps1 helper (Claude) | The term '<WORKSPACE_ROOT>\.claude\hooks\hook-dependency-guard.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED-BLOCK: hook-dependency-guard.ps1 helper (Codex) | The term '<WORKSPACE_ROOT>\.codex\hooks\hook-dependency-guard.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
RUNNER_EXIT: 1
## CLASSIFY
CLASSIFY: H1: records a dependency failure by name | THROW
CLASSIFY: H2: reports no failure before any record | THROW
CLASSIFY: H3: reports a failure after a record | THROW
CLASSIFY: H4: builds the reason from the prefix, the dependency name, and the first exception line | THROW
CLASSIFY: H5: returns the PreToolUse deny decision in the hookSpecificOutput shape | THROW
CLASSIFY: H6: returns a SubagentStop result carrying exit code 2 and the reason | THROW
CLASSIFY: H7: returns null from the decision builder when nothing failed | THROW
CLASSIFY: H8: keeps earlier records when the helper is dot-sourced again | THROW
CLASSIFY: H9: writes nothing to any output stream when recording a failure | THROW
CLASSIFY: H10: contains no Import-Module and no dot-source | THROW
CLASSIFY: H11: is byte-identical across all four copies | THROW
CLASSIFY: H12: stays within 500 lines | THROW
CLASSIFY: H1: records a dependency failure by name | THROW
CLASSIFY: H2: reports no failure before any record | THROW
CLASSIFY: H3: reports a failure after a record | THROW
CLASSIFY: H4: builds the reason from the prefix, the dependency name, and the first exception line | THROW
CLASSIFY: H5: returns the PreToolUse deny decision in the hookSpecificOutput shape | THROW
CLASSIFY: H6: returns a SubagentStop result carrying exit code 2 and the reason | THROW
CLASSIFY: H7: returns null from the decision builder when nothing failed | THROW
CLASSIFY: H8: keeps earlier records when the helper is dot-sourced again | THROW
CLASSIFY: H9: writes nothing to any output stream when recording a failure | THROW
CLASSIFY: H10: contains no Import-Module and no dot-source | THROW
CLASSIFY: H12: stays within 500 lines | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill.epic-base-branch.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill-helpers.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-authorization.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-resolution.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming enforce-epic-worktree-removal-gate-resolution.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | OTHER
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/check-python-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeTargetResolution.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming enforce-prd-feature-before-planner-helpers.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | NO-DECISION
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming EpicScopeResolution.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | NO-DECISION
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | NO-DECISION
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming enforce-parallel-cohort-barrier-helpers.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | NO-DECISION
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | NO-DECISION
CLASSIFY: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming enforce-parallel-drift-gate-helpers.ps1 when that direct edge fails | THROW
CLASSIFY: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails | THROW
CLASSIFY: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-resolution.ps1 when that direct edge fails | THROW
CLASSIFY: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails | THROW
CLASSIFY: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails | THROW
CLASSIFY: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateEpicWaveBarrier.psm1 when that direct edge fails | THROW
CLASSIFY: B2: PreToolUse .claude/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: SubagentStop .claude/hooks/validate-planner-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: SubagentStop .claude/hooks/validate-pr-author-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | THROW
CLASSIFY: B3: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | THROW
CLASSIFY: B3: SubagentStop .claude/hooks/validate-planner-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | THROW
CLASSIFY: B3: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | THROW
CLASSIFY: B3: SubagentStop .claude/hooks/validate-pr-author-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | THROW
CLASSIFY: B3: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-agent-profile-attestation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 blocks naming codex-epic-child-launch-attestation.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/check-python-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-checkpoint-monotonic.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails | THROW
CLASSIFY: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails | THROW
CLASSIFY: B1: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails | THROW
CLASSIFY: B2: PreToolUse .codex/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B2: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: B3: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load | OTHER
CLASSIFY: X1: .codex/hooks/enforce-epic-wave-barrier.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure | THROW
CLASSIFY: X1: .codex/hooks/enforce-epic-child-worktree-binding.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure | THROW
CLASSIFY: X2: .codex/hooks/enforce-epic-wave-barrier.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load | THROW
CLASSIFY: X2: .codex/hooks/enforce-epic-child-worktree-binding.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load | THROW
CLASSIFY: X3: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED: | THROW
CLASSIFY: C1: reports a nested EpicScopeReadiness.psm1 failure under enforce-pr-author-skill-helpers.ps1 as that top-level dependency | THROW
CLASSIFY: C2: reports a nested hook-command-scanner.ps1 load failure under enforce-pr-author-skill.epic-base-branch.ps1 as that top-level dependency | THROW
CLASSIFY: C3: denies through the merge gate when enforce-epic-merge-gate-authorization.ps1 fails to load | THROW
CLASSIFY: C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1 | NO-DECISION
CLASSIFY: C4: makes the pre-loaded OrchestratorStateCompletion visible to the lazy-load check in .claude/hooks/validate-orchestrator-output.ps1 | NO-DECISION
CLASSIFY: C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1 | NO-DECISION
CLASSIFY: C6: enforce-mermaid-validation.ps1 denies naming HookPayload.psm1 when that import fails | THROW
CLASSIFY: C7: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED: | THROW
CLASSIFY: C8: .claude/hooks/validate-orchestrator-output.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail | THROW
CLASSIFY: baseline mock interception probe | PASSED
CLASSIFY: B4: has a reason-prefix entry for every discovered Claude hook and no other | PASSED
CLASSIFY: baseline mock interception probe | PASSED
CLASSIFY: B4: has a reason-prefix entry for every discovered Codex hook and no other | PASSED
CLASSIFY: baseline mock interception probe | PASSED
CLASSIFY: C5: enforce-mermaid-validation.ps1 returns no deny when MermaidValidation is unavailable | PASSED
AND_ROUTE_MOCKS_OBSERVED: yes
```
