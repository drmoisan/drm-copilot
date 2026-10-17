# Remediation Cycle 2 Fix E-HDF ([P2-T6])

Timestamp: 2026-10-10T21-09
Command: Edit (section 3 E-HDF substring replacements on tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1); sh <SCRATCHPAD>/r.sh r2-fixobs -File tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 (R-DRIVE-LITERALS, R-LINES, git diff --numstat f72a63752fc43c8d78fe3d952bd68c68a2b62547 -- tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1, git status --porcelain -- tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1); sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 (R-SCOPED); additional runs listed below
EXIT_CODE: 0
Output Summary: numstat 3 added and 0 removed; LINES 213 (the [P0-T10] value 210 plus 3, at most 500); the inserted third line is the only line containing Remove-Module (REMOVE-MODULE-LINES 1); R-SCOPED EXIT_CODE 0, FailedCount 0, passed=75 (equal to [P0-T12]); R-CIPARITY r6-fixed over the [P1-T4] REPRO-LIST (192 containers, no census container): PARITY r6-fixed containers=192 passed=5541 failed=0, ORDER-PRESERVED: yes, INTERCEPTION-ROW for hook-dependency-failure.Codex.Tests.ps1 passed.

## Observations

```text
DRIVE-LITERALS: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 0
LINES: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 213
NUMSTAT: 3	0	tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
PORCELAIN:  M tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
REMOVE-MODULE-LINES: 1
DIFF:
  diff --git a/tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 b/tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
  index 6df5e4714..de4e62112 100644
  --- a/tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
  +++ b/tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
  @@ -39,0 +40,3 @@ Describe 'Codex hook dependency-failure behaviour (issue #786)' {
  +        # A suite that ran earlier in the same Pester session can leave EpicScopeResolution bound to a replaced instance of
  +        # a sibling module; unloading the family first makes the registration below build one coherent set (#737 probe harness).
  +        Remove-Module -Name 'EpicScopeResolution', 'WorktreeRunResolution', 'WorktreeItemResolution', 'WorktreeResolution', 'WorktreeTargetResolution', 'EpicScopeReadiness' -Force -ErrorAction SilentlyContinue
```

## R-SCOPED

```text

Starting discovery in 1 files.
Discovery found 75 tests in 485ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 4.85s (4.02s|364ms)
Tests completed in 4.86s
Tests Passed: 75, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 75
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | result=Passed | passed=75 | failed=0
PASSED: baseline mock interception probe
PASSED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-agent-profile-attestation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 blocks naming codex-epic-child-launch-attestation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/check-python-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-checkpoint-monotonic.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails
PASSED: B1: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B2: PreToolUse .codex/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B4: has a reason-prefix entry for every discovered Codex hook and no other
PASSED: X1: .codex/hooks/enforce-epic-wave-barrier.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure
PASSED: X1: .codex/hooks/enforce-epic-child-worktree-binding.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure
PASSED: X2: .codex/hooks/enforce-epic-wave-barrier.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load
PASSED: X2: .codex/hooks/enforce-epic-child-worktree-binding.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load
PASSED: X3: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED:
```

## Output of <SCRATCHPAD>/r2-ciparity-r6-fixed.out

```text
PESTER-VERSION: 5.6.1

Starting discovery in 192 files.
Discovery found 5541 tests in 28.08s.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-powershell-test-purity.Tests.ps1 473ms (144ms|222ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-python-test-purity.Tests.ps1 121ms (77ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1 1.89s (1.72s|134ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-checkpoint-monotonic.Tests.ps1 153ms (85ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1 237ms (202ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 113ms (77ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditSemantics.Tests.ps1 165ms (102ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditTarget.Tests.ps1 99ms (58ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.FailClosed.Tests.ps1 109ms (68ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Payload.Tests.ps1 80ms (36ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Tests.ps1 271ms (163ms|74ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.Tests.ps1 186ms (114ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 132ms (82ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-invocation-origin.Tests.ps1 145ms (77ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1 412ms (358ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 126ms (55ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 224ms (184ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 374ms (320ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1 717ms (585ms|95ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1 315ms (260ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 332ms (291ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 247ms (189ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 273ms (181ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 259ms (217ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 223ms (186ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 664ms (587ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1 708ms (591ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 164ms (122ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 233ms (196ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-evidence-locations.Tests.ps1 129ms (71ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-feature-folder-order.Tests.ps1 326ms (238ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 97ms (60ms|26ms)
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 82.53s (60.08s|214ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 137ms (87ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 267ms (211ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1 367ms (299ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-mermaid-validation.Tests.ps1 788ms (703ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1 207ms (171ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.Tests.ps1 185ms (132ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 1.21s (1.16s|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 308ms (239ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 207ms (162ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 126ms (71ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 145ms (70ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 43ms (10ms|21ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 300ms (236ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 391ms (277ms|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 42ms (12ms|21ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.ps1 381ms (294ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 978ms (883ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 119ms (78ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 1.34s (1.2s|103ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 491ms (432ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 424ms (378ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 187ms (154ms|21ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 2.11s (2.06s|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 973ms (823ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1 382ms (308ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 402ms (352ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 282ms (235ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1 186ms (129ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 116ms (81ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 200ms (147ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Payload.Tests.ps1 135ms (99ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 325ms (222ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 183ms (147ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate-helpers.Tests.ps1 208ms (157ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 204ms (151ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.Tests.ps1 407ms (317ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 171ms (129ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 271ms (225ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 612ms (519ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1 662ms (561ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 156ms (113ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 229ms (191ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget-routing.Tests.ps1 240ms (155ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 231ms (168ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-command-allowlist.Tests.ps1 294ms (243ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1 751ms (684ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 295ms (236ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1 501ms (455ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1 2.63s (2.57s|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 3.49s (3.43s|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 1.03s (982ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1 323ms (276ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1 887ms (846ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 1.27s (1.15s|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1 729ms (650ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 3.8s (3.75s|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 219ms (170ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 368ms (290ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 269ms (218ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 371ms (311ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.Tests.ps1 363ms (285ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Issue824.Tests.ps1 602ms (518ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Tests.ps1 205ms (138ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 143ms (97ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget-routing.Tests.ps1 219ms (155ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 210ms (144ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\feature-folder-resolution.Tests.ps1 170ms (85ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-consumers.Issue824.Tests.ps1 1.05s (979ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation-operands.Tests.ps1 507ms (430ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824.Tests.ps1 800ms (651ms|108ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1 1.84s (1.74s|79ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Tests.ps1 273ms (179ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1 444ms (389ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-payload.Tests.ps1 494ms (395ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Issue824.Tests.ps1 121ms (70ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Tests.ps1 182ms (99ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 6.52s (6s|159ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 2.94s (1.34s|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 104ms (53ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.14s (2.06s|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\persist-session-id.Tests.ps1 174ms (124ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUsePayload.Contract.Tests.ps1 201ms (122ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUseSchema.Contract.Tests.ps1 634ms (594ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\session-root-reads-850.Constraints.Tests.ps1 940ms (894ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.Tests.ps1 195ms (136ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.TriggerScoping.Tests.ps1 149ms (98ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.Tests.ps1 808ms (729ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 104ms (64ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-executor-output.Tests.ps1 111ms (65ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 364ms (290ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1 78ms (39ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 560ms (520ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 653ms (598ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.human-interaction.Tests.ps1 318ms (280ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.model-routing.Tests.ps1 490ms (448ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1 596ms (514ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WaveBarrier.Tests.ps1 472ms (405ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WorktreeResolution.Tests.ps1 817ms (753ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 45ms (15ms|18ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Tests.ps1 202ms (144ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Coverage.Tests.ps1 52ms (22ms|20ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Tests.ps1 1.01s (970ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Coverage.Tests.ps1 42ms (13ms|19ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Tests.ps1 121ms (88ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-required-artifact-output.Tests.ps1 62ms (20ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-task-researcher-output.Tests.ps1 190ms (123ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 348ms (280ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 125ms (59ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 13.88s (13.84s|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 94ms (53ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 248ms (198ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 104ms (60ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 479ms (432ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 270ms (189ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 78ms (35ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 245ms (174ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 216ms (131ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 234ms (168ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 176ms (93ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 30.67s (30.63s|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 23.57s (23.5s|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 183ms (120ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 248ms (189ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 156ms (83ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 258ms (216ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 95ms (62ms|21ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 140ms (85ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 150ms (70ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 95ms (48ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 99ms (61ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 394ms (338ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 282ms (231ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 240ms (193ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 166ms (122ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 304ms (254ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 338ms (270ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 553ms (479ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 197ms (154ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 1.41s (1.27s|105ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 444ms (349ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 422ms (370ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 702ms (616ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 235ms (163ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 255ms (160ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 172ms (118ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 163ms (132ms|21ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 390ms (332ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 306ms (238ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 123ms (81ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 101ms (57ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 299ms (250ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 194ms (126ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 4.5s (4.41s|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 228ms (173ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 142ms (99ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 166ms (94ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 227ms (143ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 179ms (108ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 3.03s (2.76s|93ms)
Tests completed in 244.33s
Tests Passed: 5541, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PARITY: r6-fixed | containers=192 | passed=5541 | failed=0
ORDER: 1 | tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1
ORDER: 2 | tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1
ORDER: 3 | tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1
ORDER: 4 | tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1
ORDER: 5 | tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
ORDER: 6 | tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1
ORDER: 7 | tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1
ORDER: 8 | tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1
ORDER: 9 | tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1
ORDER: 10 | tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1
ORDER: 11 | tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1
ORDER: 12 | tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1
ORDER: 13 | tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
ORDER: 14 | tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1
ORDER: 15 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1
ORDER: 16 | tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1
ORDER: 17 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1
ORDER: 18 | tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
ORDER: 19 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1
ORDER: 20 | tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
ORDER: 21 | tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
ORDER: 22 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
ORDER: 23 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1
ORDER: 24 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1
ORDER: 25 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
ORDER: 26 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
ORDER: 27 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
ORDER: 28 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
ORDER: 29 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
ORDER: 30 | tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1
ORDER: 31 | tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
ORDER: 32 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
ORDER: 33 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
ORDER: 34 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
ORDER: 35 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1
ORDER: 36 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
ORDER: 37 | tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1
ORDER: 38 | tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1
ORDER: 39 | tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1
ORDER: 40 | tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1
ORDER: 41 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 42 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
ORDER: 43 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1
ORDER: 44 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1
ORDER: 45 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
ORDER: 46 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 47 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 48 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
ORDER: 49 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
ORDER: 50 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
ORDER: 51 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1
ORDER: 52 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
ORDER: 53 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
ORDER: 54 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
ORDER: 55 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1
ORDER: 56 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
ORDER: 57 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1
ORDER: 58 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
ORDER: 59 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
ORDER: 60 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1
ORDER: 61 | tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1
ORDER: 62 | tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1
ORDER: 63 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
ORDER: 64 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1
ORDER: 65 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1
ORDER: 66 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1
ORDER: 67 | tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1
ORDER: 68 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
ORDER: 69 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
ORDER: 70 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1
ORDER: 71 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
ORDER: 72 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
ORDER: 73 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
ORDER: 74 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
ORDER: 75 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
ORDER: 76 | tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
ORDER: 77 | tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1
ORDER: 78 | tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
ORDER: 79 | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1
ORDER: 80 | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
ORDER: 81 | tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
ORDER: 82 | tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
ORDER: 83 | tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
ORDER: 84 | tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
ORDER: 85 | tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1
ORDER: 86 | tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
ORDER: 87 | tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
ORDER: 88 | tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
ORDER: 89 | tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
ORDER: 90 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1
ORDER: 91 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1
ORDER: 92 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1
ORDER: 93 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1
ORDER: 94 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1
ORDER: 95 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1
ORDER: 96 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1
ORDER: 97 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
ORDER: 98 | tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1
ORDER: 99 | tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1
ORDER: 100 | tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
ORDER: 101 | tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1
ORDER: 102 | tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1
ORDER: 103 | tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1
ORDER: 104 | tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
ORDER: 105 | tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1
ORDER: 106 | tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
ORDER: 107 | tests/scripts/claude-hooks/hook-command-payload.Tests.ps1
ORDER: 108 | tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1
ORDER: 109 | tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
ORDER: 110 | tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
ORDER: 111 | tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
ORDER: 112 | tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
ORDER: 113 | tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 114 | tests/scripts/claude-hooks/persist-session-id.Tests.ps1
ORDER: 115 | tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1
ORDER: 116 | tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
ORDER: 117 | tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1
ORDER: 118 | tests/scripts/claude-hooks/validate-bash.Tests.ps1
ORDER: 119 | tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
ORDER: 120 | tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
ORDER: 121 | tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
ORDER: 122 | tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
ORDER: 123 | tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER: 124 | tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1
ORDER: 125 | tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
ORDER: 126 | tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1
ORDER: 127 | tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1
ORDER: 128 | tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1
ORDER: 129 | tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
ORDER: 130 | tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
ORDER: 131 | tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1
ORDER: 132 | tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1
ORDER: 133 | tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
ORDER: 134 | tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
ORDER: 135 | tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
ORDER: 136 | tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
ORDER: 137 | tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
ORDER: 138 | tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1
ORDER: 139 | tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
ORDER: 140 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 141 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 142 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 143 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 144 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 145 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 146 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 147 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 148 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 149 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 150 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 151 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 152 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 153 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 154 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 155 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 156 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 157 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 158 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 159 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 160 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 161 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 162 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 163 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 164 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 165 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 166 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 167 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 168 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 169 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 170 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 171 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 172 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 173 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 174 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 175 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 176 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 177 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 178 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 179 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 180 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 181 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 182 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 183 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 184 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 185 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 186 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 187 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 188 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 189 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 190 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 191 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 192 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER-PRESERVED: yes
INTERCEPTION-ROW: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed
```
