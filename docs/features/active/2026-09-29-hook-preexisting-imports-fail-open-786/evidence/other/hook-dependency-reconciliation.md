# FR-9.2 Reconciliation ([P0-T10])

Timestamp: 2026-10-09T22-00
Command: sh <SCRATCHPAD>/r.sh p0t10 (transcribed research Q3 pairs compared with the repository V-EDGES records; drift checks with git diff -U0 <RESEARCH_BASE> <BASE_SHA> -- <Via> and git show <RESEARCH_BASE>:<Via>; absent-pair check with git diff -U0 <RESEARCH_BASE> <BASE_SHA> -- .claude/hooks .claude/lib .codex/hooks .codex/scripts)
EXIT_CODE: 0
Output Summary: 126 research pairs PRESENT; 69 additional records EXPLAINED by upstream drift and 103 PRE-EXISTING; zero unexplained additional records, zero absent pairs, zero open UNRESOLVED records.

RESEARCH_BASE: b907f56e9336b752cbcb5394acd0271a4e30b39f
PRE_MERGE_BASE: 86e457a003be0c60b65e01156e4cccd6495dfd1a
BASE_SHA: 86e457a003be0c60b65e01156e4cccd6495dfd1a
PRESENT: 126
ADDITIONAL_EXPLAINED: 69
ADDITIONAL_PRE_EXISTING: 103
ADDITIONAL_UNEXPLAINED: 0
ABSENT_EXPLAINED: 0
ABSENT_UNEXPLAINED: 0
UNRESOLVED_OPEN: 0

Transcription notes:
- Entries of the form "`:<line>`" or "`:<a>-<b>`" with no kind and no target (for example "invocation `:17`" in the Claude enforce-promotion-mcp-only row, "WorktreeItemResolution `:31-32`", "WorktreeTargetResolution `:27`", "MermaidValidation `:46-48`", "MermaidLineScanner `:39`", "`OrchestratorStateUnconditional.psm1:51-55`, runtime `:93`", and "`OrchestratorStateCompletion.psm1:56-63` (...)") are not explicit `:<line> <kind> <target>` entries and are not transcribed, consistent with the closure-summary exclusion.
- The Codex enforce-epic-wave-barrier entry "conditionally (`if (Test-Path ...)`, `:3-6`) DS `.codex/scripts/epic-child-launch-contract.ps1`" names one target, so it yields one pair (Via codex-epic-child-launch-attestation.ps1).
- `$script:ParallelDriftGateHelpersPath` (Claude enforce-parallel-drift-gate) and `$script:CompletionHelpersPath` (Codex enforce-completion-consistency) carry no parenthesized file name and were mapped from the last single-quoted literal on the assigning line of the hook at RESEARCH_BASE.
- W-UNRESOLVED: no V-EDGES record has a Target beginning `UNRESOLVED`, so no resolution by reading was required.

Rows (PAIR = research pair; EDGE = repository V-EDGES record not matched by a research pair):

```text
## Research pairs
PAIR: claude | .claude/hooks/validate-bash.ps1 | validate-bash.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/validate-bash.ps1 | validate-bash.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/validate-bash.ps1 | validate-bash.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: claude | .claude/hooks/validate-bash.ps1 | hook-command-invocation.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | enforce-promotion-mcp-only.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | enforce-promotion-mcp-only.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | enforce-promotion-mcp-only.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill.ps1 | OrchestratorState.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill.ps1 | enforce-pr-author-skill.epic-base-branch.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill.ps1 | enforce-pr-author-skill-helpers.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill.epic-base-branch.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill.epic-base-branch.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill-helpers.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill-helpers.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill-helpers.ps1 | WorktreeResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill-helpers.ps1 | WorktreeTargetResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill-helpers.ps1 | WorktreeItemResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill-helpers.ps1 | EpicScopeResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | enforce-pr-author-skill-helpers.ps1 | EpicScopeReadiness.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | EpicScopeResolution.psm1 | WorktreeResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | EpicScopeResolution.psm1 | WorktreeTargetResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | EpicScopeResolution.psm1 | WorktreeRunResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | WorktreeRunResolution.psm1 | WorktreeResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | WorktreeRunResolution.psm1 | WorktreeTargetResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | WorktreeRunResolution.psm1 | WorktreeItemResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-pr-author-skill.ps1 | OrchestratorState.psm1 | OrchestratorStateUnconditional.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-helpers.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-modes.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | WorktreeItemResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | WorktreeRunResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | EpicScopeResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | EpicScopeReadiness.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate-authorization.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate-resolution.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate-resolution.ps1 | WorktreeRunResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | enforce-epic-worktree-removal-gate.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | enforce-epic-worktree-removal-gate.ps1 | CleanupWorktreeManifest.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | enforce-epic-worktree-removal-gate.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | enforce-epic-worktree-removal-gate.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | enforce-epic-worktree-removal-gate.ps1 | enforce-epic-worktree-removal-gate-resolution.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | enforce-epic-worktree-removal-gate-resolution.ps1 | WorktreeRunResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | enforce-parallel-worktree-removal-gate.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | enforce-parallel-worktree-removal-gate.ps1 | CleanupWorktreeManifest.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | enforce-parallel-worktree-removal-gate.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | enforce-parallel-worktree-removal-gate.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | enforce-parallel-worktree-removal-gate.ps1 | WorktreeRunResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | enforce-parallel-abandon-gate.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | enforce-parallel-abandon-gate.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | enforce-parallel-abandon-gate.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: claude | .claude/hooks/check-python-test-purity.ps1 | check-python-test-purity.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-python-batch-budget.ps1 | enforce-python-batch-budget.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-python-batch-budget.ps1 | enforce-python-batch-budget.ps1 | enforce-batch-budget-route.ps1 | PRESENT
PAIR: claude | .claude/hooks/check-powershell-test-purity.ps1 | check-powershell-test-purity.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-powershell-batch-budget.ps1 | enforce-powershell-batch-budget.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-powershell-batch-budget.ps1 | enforce-powershell-batch-budget.ps1 | enforce-batch-budget-route.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-evidence-locations.ps1 | enforce-evidence-locations.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-feature-folder-order.ps1 | enforce-feature-folder-order.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-checkpoint-monotonic.ps1 | enforce-checkpoint-monotonic.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-completion-consistency.ps1 | enforce-completion-consistency.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-completion-consistency.ps1 | enforce-completion-consistency.ps1 | enforce-completion-helpers.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-discovery-artifact-gate.ps1 | enforce-discovery-artifact-gate.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-discovery-artifact-gate.ps1 | enforce-discovery-artifact-gate.ps1 | DiscoveryValidation.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-mermaid-validation.ps1 | enforce-mermaid-validation.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-mermaid-validation.ps1 | enforce-mermaid-validation.ps1 | MermaidValidation.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | enforce-prd-feature-before-planner.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | enforce-prd-feature-before-planner.ps1 | WorktreeTargetResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | enforce-prd-feature-before-planner.ps1 | WorktreeItemResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | enforce-prd-feature-before-planner.ps1 | enforce-prd-feature-before-planner-helpers.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | enforce-prd-feature-before-planner-helpers.ps1 | WorktreeResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | enforce-epic-wave-barrier.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | enforce-epic-wave-barrier.ps1 | WorktreeRunResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | enforce-model-routing-receipt.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | enforce-model-routing-receipt.ps1 | WorktreeItemResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | enforce-model-routing-receipt.ps1 | EpicScopeResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-epic-invocation-origin.ps1 | enforce-epic-invocation-origin.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | enforce-parallel-cohort-barrier.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | enforce-parallel-cohort-barrier.ps1 | WorktreeRunResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | enforce-parallel-cohort-barrier.ps1 | enforce-parallel-cohort-barrier-helpers.ps1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | enforce-parallel-drift-gate.ps1 | HookPayload.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | enforce-parallel-drift-gate.ps1 | WorktreeRunResolution.psm1 | PRESENT
PAIR: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | enforce-parallel-drift-gate.ps1 | enforce-parallel-drift-gate-helpers.ps1 | PRESENT
PAIR: claude | .claude/hooks/validate-orchestrator-output.ps1 | validate-orchestrator-output.ps1 | OrchestratorState.psm1 | PRESENT
PAIR: claude | .claude/hooks/validate-orchestrator-output.ps1 | validate-orchestrator-output.ps1 | OrchestratorStateCompletion.psm1 | PRESENT
PAIR: claude | .claude/hooks/validate-discovery-artifact-gate.ps1 | validate-discovery-artifact-gate.ps1 | DiscoveryValidation.psm1 | PRESENT
PAIR: codex | .codex/hooks/validate-bash.ps1 | validate-bash.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: codex | .codex/hooks/validate-bash.ps1 | validate-bash.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: codex | .codex/hooks/validate-bash.ps1 | hook-command-invocation.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | enforce-promotion-mcp-only.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | enforce-promotion-mcp-only.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | codex-pretooluse-file-mapping.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-helpers.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-modes.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate-epic-scope.ps1 | enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | enforce-orchestration-preimplementation-gate.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-epic-merge-gate.ps1 | enforce-epic-merge-gate.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | enforce-epic-worktree-removal-gate.ps1 | hook-command-scanner.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | enforce-epic-worktree-removal-gate.ps1 | hook-command-invocation.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-epic-root-invocation.ps1 | enforce-epic-root-invocation.ps1 | codex-authority-store.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-codex-model-routing.ps1 | enforce-codex-model-routing.ps1 | codex-authority-store.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-codex-model-routing.ps1 | enforce-codex-model-routing.ps1 | codex-agent-profile-attestation.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-epic-wave-barrier.ps1 | enforce-epic-wave-barrier.ps1 | codex-epic-child-launch-attestation.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-epic-wave-barrier.ps1 | codex-epic-child-launch-attestation.ps1 | epic-child-launch-contract.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-epic-child-worktree-binding.ps1 | enforce-epic-child-worktree-binding.ps1 | epic-child-launch-contract.ps1 | PRESENT
PAIR: codex | .codex/hooks/check-python-test-purity.ps1 | check-python-test-purity.ps1 | codex-pretooluse-file-mapping.ps1 | PRESENT
PAIR: codex | .codex/hooks/check-powershell-test-purity.ps1 | check-powershell-test-purity.ps1 | codex-pretooluse-file-mapping.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-evidence-locations.ps1 | enforce-evidence-locations.ps1 | codex-pretooluse-file-mapping.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-checkpoint-monotonic.ps1 | enforce-checkpoint-monotonic.ps1 | codex-pretooluse-file-mapping.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-python-batch-budget.ps1 | enforce-python-batch-budget.ps1 | codex-pretooluse-file-mapping.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-python-batch-budget.ps1 | enforce-python-batch-budget.ps1 | enforce-batch-budget-route.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-powershell-batch-budget.ps1 | enforce-powershell-batch-budget.ps1 | codex-pretooluse-file-mapping.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-powershell-batch-budget.ps1 | enforce-powershell-batch-budget.ps1 | enforce-batch-budget-route.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-completion-consistency.ps1 | enforce-completion-consistency.ps1 | enforce-checkpoint-monotonic.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-completion-consistency.ps1 | enforce-completion-consistency.ps1 | codex-pretooluse-file-mapping.ps1 | PRESENT
PAIR: codex | .codex/hooks/enforce-completion-consistency.ps1 | enforce-completion-consistency.ps1 | enforce-completion-helpers.ps1 | PRESENT
PAIR: codex | .codex/hooks/validate-codex-subagent-routing.ps1 | validate-codex-subagent-routing.ps1 | codex-authority-store.ps1 | PRESENT
## Repository V-EDGES records
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/enforce-epic-merge-gate-resolution.ps1:46 | Module | WorktreeItemResolution.psm1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:32 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:33 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:31 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:32 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:33 | Module | WorktreeItemResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-merge-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/hooks/enforce-epic-wave-barrier.ps1:63 | DotSource | feature-folder-resolution.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:32 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:33 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:31 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:32 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:33 | Module | WorktreeItemResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-wave-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:32 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:33 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:31 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:32 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:33 | Module | WorktreeItemResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-feature-folder-order.ps1 | .claude/hooks/enforce-feature-folder-order.ps1:47 | DotSource | feature-folder-resolution.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-mermaid-validation.ps1 | .claude/lib/mermaid/MermaidLineScanner.psm1:39 | Module | MermaidGrammar.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-mermaid-validation.ps1 | .claude/lib/mermaid/MermaidValidation.psm1:46 | Module | MermaidGrammar.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-mermaid-validation.ps1 | .claude/lib/mermaid/MermaidValidation.psm1:47 | Module | MermaidLineScanner.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-mermaid-validation.ps1 | .claude/lib/mermaid/MermaidValidation.psm1:48 | Module | MermaidMarkdownFences.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1:40 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1:41 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1:42 | Module | WorktreeRunResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:32 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:33 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:31 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:32 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-model-routing-receipt.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:57 | DotSource | enforce-orchestration-preimplementation-gate-targets.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:38 | DotSource | feature-folder-resolution.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1:40 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/EpicScopeResolution.psm1:41 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:32 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:33 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:31 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:32 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-abandon-gate.ps1 | .claude/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/hooks/enforce-parallel-cohort-barrier.ps1:69 | Module | WorktreeItemResolution.psm1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/hooks/enforce-parallel-cohort-barrier.ps1:79 | DotSource | feature-folder-resolution.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:32 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:33 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:31 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:32 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:33 | Module | WorktreeItemResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-cohort-barrier.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/hooks/enforce-parallel-drift-gate.ps1:80 | Module | WorktreeItemResolution.psm1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/hooks/enforce-parallel-drift-gate.ps1:90 | DotSource | feature-folder-resolution.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:32 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:33 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:31 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:32 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:33 | Module | WorktreeItemResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-drift-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:32 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:33 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:31 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:32 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:33 | Module | WorktreeItemResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/enforce-pr-author-skill-helpers.ps1:53 | DotSource | enforce-pr-author-skill.artifact-root.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1:34 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1:36 | Module | CodexDeployment.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1:37 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1:39 | Module | CodexTopology.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1:31 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1:33 | Module | ModelRouting.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1:39 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1:40 | Module | OrchestratorStateRemediationAccounting.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1:34 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:51 | Module | OrchestratorStateReceipts.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:52 | Module | OrchestratorStateModelReceipts.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:53 | Module | OrchestratorStateCodexModelReceipts.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:54 | Module | OrchestratorStateCodexTopologyReceipts.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-pr-author-skill.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:55 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/enforce-prd-feature-before-planner.ps1 | .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1:36 | DotSource | feature-folder-resolution.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/enforce-promotion-mcp-only.ps1 | .claude/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/validate-bash.ps1 | .claude/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/hooks/validate-orchestrator-output.ps1:58 | DotSource | validate-orchestrator-output-resolution.ps1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/hooks/validate-orchestrator-output.ps1:66 | Module | WorktreeItemResolution.psm1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/hooks/validate-orchestrator-output.ps1:66 | Module | WorktreeRunResolution.psm1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/hooks/validate-orchestrator-output.ps1:73 | Module | OrchestratorStateEpicWaveBarrier.psm1 | ADDITIONAL EXPLAINED
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorState.psm1:431 | Module | OrchestratorStateUnconditional.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1:34 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1:36 | Module | CodexDeployment.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1:37 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1:39 | Module | CodexTopology.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1:58 | Module | ModelRouting.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1:59 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1:60 | Module | OrchestratorStateModelReceipts.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1:61 | Module | OrchestratorStateUnconditional.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1:62 | Module | OrchestratorStateCompletionChecks.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1:63 | Module | OrchestratorStateRoutingContract.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1:45 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1:46 | Module | OrchestratorStateRoutingMatrix.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1:31 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1:31 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1:33 | Module | ModelRouting.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1:39 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1:40 | Module | OrchestratorStateRemediationAccounting.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1:34 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1:59 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1:60 | Module | OrchestratorStateRoutingMatrix.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1:61 | Module | OrchestratorStateIssueAdoption.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1:44 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:51 | Module | OrchestratorStateReceipts.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:52 | Module | OrchestratorStateModelReceipts.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:53 | Module | OrchestratorStateCodexModelReceipts.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:54 | Module | OrchestratorStateCodexTopologyReceipts.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:55 | Module | OrchestratorStateCheckpointValue.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:32 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:33 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:31 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:32 | Module | WorktreeTargetResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1:33 | Module | WorktreeItemResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: claude | .claude/hooks/validate-orchestrator-output.ps1 | .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:27 | Module | WorktreeResolution.psm1 | ADDITIONAL PRE-EXISTING
EDGE: codex | .codex/hooks/enforce-epic-merge-gate.ps1 | .codex/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-epic-merge-gate.ps1 | .codex/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-epic-merge-gate.ps1 | .codex/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-epic-merge-gate.ps1 | .codex/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | .codex/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | .codex/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | .codex/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | .codex/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:38 | DotSource | enforce-orchestration-preimplementation-gate-targets.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:38 | DotSource | feature-folder-resolution.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | .codex/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | .codex/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | .codex/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | .codex/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/enforce-promotion-mcp-only.ps1 | .codex/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/validate-bash.ps1 | .codex/hooks/hook-command-invocation.ps1:22 | DotSource | hook-command-payload.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/validate-bash.ps1 | .codex/hooks/hook-command-invocation.ps1:23 | DotSource | hook-command-payload-powershell.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/validate-bash.ps1 | .codex/hooks/hook-command-invocation.ps1:24 | DotSource | hook-command-invocation-operands.ps1 | ADDITIONAL EXPLAINED
EDGE: codex | .codex/hooks/validate-bash.ps1 | .codex/hooks/hook-command-scanner.ps1:20 | DotSource | hook-command-heredoc.ps1 | ADDITIONAL EXPLAINED
## W-UNRESOLVED
none (no V-EDGES record has a Target beginning UNRESOLVED)
RESEARCH_BASE: b907f56e9336b752cbcb5394acd0271a4e30b39f
PRE_MERGE_BASE: 86e457a003be0c60b65e01156e4cccd6495dfd1a
BASE_SHA: 86e457a003be0c60b65e01156e4cccd6495dfd1a
PRESENT: 126
ADDITIONAL_EXPLAINED: 69
ADDITIONAL_PRE_EXISTING: 103
ADDITIONAL_UNEXPLAINED: 0
ABSENT_EXPLAINED: 0
ABSENT_UNEXPLAINED: 0
UNRESOLVED_OPEN: 0
```
