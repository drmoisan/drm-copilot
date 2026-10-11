# Remediation Cycle 1 AC-6 Verification ([P6-T1])

Timestamp: 2026-10-10T18-38
Command: sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 (R-SCOPED); sh <SCRATCHPAD>/r.sh r1-p6t1b (R-SCOPED with $configuration.Filter.FullName = @('*H1 *', '*H4 *', '*H5 *', '*H6 *') over tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1); PROOF_RESULT lines read from evidence/other/fail-closed-proof.H1.md, .H4.md, .H5.md, .H6.md
EXIT_CODE: 0
Output Summary: run 1 EXIT_CODE 0, PassedCount 139, FailedCount 0, 68 `PASSED: B1: PreToolUse` lines; run 2 EXIT_CODE 0, PassedCount 10, FailedCount 0, with the H1, H4, H5, and H6 deny rows passed; all eight PROOF_RESULT lines (two per proof file) read FAIL-CLOSED; the [P1-T3] acceptance is met (r1-spec-amendment.md EXIT_CODE 0, and the amended AC-6 line still carries every [P1-T1] literal).

Run 1 EXIT_CODE: 0
Run 2 EXIT_CODE: 0

PROOF_RESULT lines:

```text
fail-closed-proof.H1.md:PROOF_RESULT: FAIL-CLOSED
fail-closed-proof.H1.md:PROOF_RESULT: FAIL-CLOSED
fail-closed-proof.H4.md:PROOF_RESULT: FAIL-CLOSED
fail-closed-proof.H4.md:PROOF_RESULT: FAIL-CLOSED
fail-closed-proof.H5.md:PROOF_RESULT: FAIL-CLOSED
fail-closed-proof.H5.md:PROOF_RESULT: FAIL-CLOSED
fail-closed-proof.H6.md:PROOF_RESULT: FAIL-CLOSED
fail-closed-proof.H6.md:PROOF_RESULT: FAIL-CLOSED
```

P1-T3-ACCEPTANCE: met (evidence/other/r1-spec-amendment.md records the [P1-T1] and [P1-T2] checks as pass; a re-check on the current spec.md found exactly one `- [ ] AC-6:` line containing `Change Log 2026-10-10`, `H1, H4, H5, and H6`, `exemption-decisions.md`, and the four `fail-closed-proof.H<n>.md` names)

Run 1 and run 2 outputs follow, in that order.

```text

Starting discovery in 1 files.
Discovery found 139 tests in 745ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 8.88s (7.67s|486ms)
Tests completed in 8.89s
Tests Passed: 139, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 139
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | result=Passed | passed=139 | failed=0
PASSED: baseline mock interception probe
PASSED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill.epic-base-branch.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorStateUnconditional.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-authorization.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-resolution.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming enforce-epic-worktree-removal-gate-resolution.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/check-python-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming DiscoveryValidation.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeTargetResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming enforce-prd-feature-before-planner-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming EpicScopeResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming enforce-parallel-cohort-barrier-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming enforce-parallel-drift-gate-helpers.ps1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 blocks naming DiscoveryValidation.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-resolution.ps1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateEpicWaveBarrier.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateCompletion.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateUnconditional.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B2: PreToolUse .claude/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-planner-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-pr-author-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-planner-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-pr-author-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B4: has a reason-prefix entry for every discovered Claude hook and no other
```

```text

Starting discovery in 1 files.
Discovery found 19 tests in 153ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 1.92s (1.5s|287ms)
Tests completed in 1.94s
Tests Passed: 10, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 9
PassedCount: 10
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Passed | passed=10 | failed=0
PASSED: H1 control: enforce-feature-folder-order.ps1 allows a full-bug plan write whose prerequisites exist when feature-folder-resolution.ps1 loads
PASSED: H1 enforce-feature-folder-order.ps1 denies that plan write with FEATURE_FOLDER_ORDER_BLOCKED: when feature-folder-resolution.ps1 fails to load
PASSED: H1 enforce-feature-folder-order.ps1 calls no resolver function for a non-plan write when feature-folder-resolution.ps1 loads
PASSED: H1 enforce-feature-folder-order.ps1 returns the same allow for a non-plan write whether or not feature-folder-resolution.ps1 loads
PASSED: H4 control: enforce-epic-wave-barrier.ps1 allows the W10 delegation when feature-folder-resolution.ps1 loads
PASSED: H4 enforce-epic-wave-barrier.ps1 denies that delegation with EPIC_WAVE_BARRIER_BLOCKED: when feature-folder-resolution.ps1 fails to load
PASSED: H5 control: enforce-parallel-drift-gate.ps1 allows the D1 delegation when feature-folder-resolution.ps1 loads
PASSED: H5 enforce-parallel-drift-gate.ps1 denies that delegation with PARALLEL_DRIFT_GATE_BLOCKED: when feature-folder-resolution.ps1 fails to load
PASSED: H6 control: enforce-parallel-cohort-barrier.ps1 allows the C1 delegation when feature-folder-resolution.ps1 loads
PASSED: H6 enforce-parallel-cohort-barrier.ps1 denies that delegation with PARALLEL_COHORT_BARRIER_BLOCKED: when feature-folder-resolution.ps1 fails to load
```
