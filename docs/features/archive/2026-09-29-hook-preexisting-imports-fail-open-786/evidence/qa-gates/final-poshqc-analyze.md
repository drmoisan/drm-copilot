# Final PoshQC Analyze ([P11-T2])

Timestamp: 2026-10-10T06-06
Pass: 4
Command: <SCRATCHPAD>/ranalyze.ps1 -Files @<SCRATCHPAD>/qcfiles.txt (R-ANALYZE via Invoke-PoshQCAnalyze, then R-PSSA-FILE with the repository settings for each of the 92 [P11-T1] files).
EXIT_CODE: 0
Output Summary: Recorded `PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>`. All 92 `PSSA:` lines show a count of 0.

Acceptance: met.

```text
PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>
PSSA: .claude/hooks/check-powershell-test-purity.ps1 | 0
PSSA: .claude/hooks/check-python-test-purity.ps1 | 0
PSSA: .claude/hooks/enforce-checkpoint-monotonic.ps1 | 0
PSSA: .claude/hooks/enforce-completion-consistency.ps1 | 0
PSSA: .claude/hooks/enforce-discovery-artifact-gate.ps1 | 0
PSSA: .claude/hooks/enforce-epic-invocation-origin.ps1 | 0
PSSA: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 0
PSSA: .claude/hooks/enforce-epic-merge-gate.ps1 | 0
PSSA: .claude/hooks/enforce-epic-wave-barrier.ps1 | 0
PSSA: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 0
PSSA: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 0
PSSA: .claude/hooks/enforce-evidence-locations.ps1 | 0
PSSA: .claude/hooks/enforce-feature-folder-order.ps1 | 0
PSSA: .claude/hooks/enforce-mermaid-validation.ps1 | 0
PSSA: .claude/hooks/enforce-model-routing-receipt.ps1 | 0
PSSA: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 0
PSSA: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 0
PSSA: .claude/hooks/enforce-parallel-abandon-gate.ps1 | 0
PSSA: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 0
PSSA: .claude/hooks/enforce-parallel-drift-gate.ps1 | 0
PSSA: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 0
PSSA: .claude/hooks/enforce-powershell-batch-budget.ps1 | 0
PSSA: .claude/hooks/enforce-pr-author-skill.ps1 | 0
PSSA: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 0
PSSA: .claude/hooks/enforce-prd-feature-before-planner.ps1 | 0
PSSA: .claude/hooks/enforce-promotion-mcp-only.ps1 | 0
PSSA: .claude/hooks/enforce-python-batch-budget.ps1 | 0
PSSA: .claude/hooks/hook-dependency-guard.ps1 | 0
PSSA: .claude/hooks/validate-bash.ps1 | 0
PSSA: .claude/hooks/validate-discovery-artifact-gate.ps1 | 0
PSSA: .claude/hooks/validate-feature-review-coverage.ps1 | 0
PSSA: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 0
PSSA: .claude/hooks/validate-orchestrator-output.ps1 | 0
PSSA: .claude/hooks/validate-planner-output.ps1 | 0
PSSA: .claude/hooks/validate-pr-author-output.ps1 | 0
PSSA: .claude/hooks/validate-prd-feature-output.ps1 | 0
PSSA: .codex/hooks/check-powershell-test-purity.ps1 | 0
PSSA: .codex/hooks/check-python-test-purity.ps1 | 0
PSSA: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 0
PSSA: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 0
PSSA: .codex/hooks/enforce-codex-model-routing.ps1 | 0
PSSA: .codex/hooks/enforce-completion-consistency.ps1 | 0
PSSA: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 0
PSSA: .codex/hooks/enforce-epic-merge-gate.ps1 | 0
PSSA: .codex/hooks/enforce-epic-planning-only.ps1 | 0
PSSA: .codex/hooks/enforce-epic-root-invocation.ps1 | 0
PSSA: .codex/hooks/enforce-epic-wave-barrier.ps1 | 0
PSSA: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 0
PSSA: .codex/hooks/enforce-evidence-locations.ps1 | 0
PSSA: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 0
PSSA: .codex/hooks/enforce-powershell-batch-budget.ps1 | 0
PSSA: .codex/hooks/enforce-promotion-mcp-only.ps1 | 0
PSSA: .codex/hooks/enforce-python-batch-budget.ps1 | 0
PSSA: .codex/hooks/hook-dependency-guard.ps1 | 0
PSSA: .codex/hooks/validate-bash.ps1 | 0
PSSA: .codex/hooks/validate-codex-subagent-routing.ps1 | 0
PSSA: .codex/hooks/validate-feature-review-coverage.ps1 | 0
PSSA: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | 0
PSSA: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | 0
PSSA: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | 0
PSSA: tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1 | 0
PSSA: tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1 | 0
PSSA: tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1 | 0
PSSA: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 0
PSSA: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 0
```
