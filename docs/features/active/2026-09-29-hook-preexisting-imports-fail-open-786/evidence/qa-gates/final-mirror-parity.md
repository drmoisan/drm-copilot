# Final Mirror Parity ([P11-T8])

Timestamp: 2026-10-10T06-27
Pass: 4
Command: <SCRATCHPAD>/final11.ps1 repeats [P9-T6]. It records `git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a` together with `git status --porcelain`. It selects the paths beginning with `.claude/hooks/`, `.claude/lib/`, `.codex/hooks/`, or `.codex/scripts/`, then runs R-MIRROR (<SCRATCHPAD>/rmirror.ps1) for each selected path.
EXIT_CODE: 0
Output Summary: 57 paths selected, with one MIRROR: line per path. Every mark is `equal` (UNEQUAL_COUNT: 0).

Acceptance: met.

```text
git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a:
.claude/hooks/check-powershell-test-purity.ps1
.claude/hooks/check-python-test-purity.ps1
.claude/hooks/enforce-checkpoint-monotonic.ps1
.claude/hooks/enforce-completion-consistency.ps1
.claude/hooks/enforce-discovery-artifact-gate.ps1
.claude/hooks/enforce-epic-invocation-origin.ps1
.claude/hooks/enforce-epic-merge-gate-resolution.ps1
.claude/hooks/enforce-epic-merge-gate.ps1
.claude/hooks/enforce-epic-wave-barrier.ps1
.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
.claude/hooks/enforce-epic-worktree-removal-gate.ps1
.claude/hooks/enforce-evidence-locations.ps1
.claude/hooks/enforce-feature-folder-order.ps1
.claude/hooks/enforce-mermaid-validation.ps1
.claude/hooks/enforce-model-routing-receipt.ps1
.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
.claude/hooks/enforce-parallel-abandon-gate.ps1
.claude/hooks/enforce-parallel-cohort-barrier.ps1
.claude/hooks/enforce-parallel-drift-gate.ps1
.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
.claude/hooks/enforce-powershell-batch-budget.ps1
.claude/hooks/enforce-pr-author-skill.ps1
.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
.claude/hooks/enforce-prd-feature-before-planner.ps1
.claude/hooks/enforce-promotion-mcp-only.ps1
.claude/hooks/enforce-python-batch-budget.ps1
.claude/hooks/hook-dependency-guard.ps1
.claude/hooks/validate-bash.ps1
.claude/hooks/validate-discovery-artifact-gate.ps1
.claude/hooks/validate-feature-review-coverage.ps1
.claude/hooks/validate-orchestrator-output-resolution.ps1
.claude/hooks/validate-orchestrator-output.ps1
.claude/hooks/validate-planner-output.ps1
.claude/hooks/validate-pr-author-output.ps1
.claude/hooks/validate-prd-feature-output.ps1
.codex/hooks/check-powershell-test-purity.ps1
.codex/hooks/check-python-test-purity.ps1
.codex/hooks/codex-epic-child-launch-attestation.ps1
.codex/hooks/enforce-checkpoint-monotonic.ps1
.codex/hooks/enforce-codex-model-routing.ps1
.codex/hooks/enforce-completion-consistency.ps1
.codex/hooks/enforce-epic-child-worktree-binding.ps1
.codex/hooks/enforce-epic-merge-gate.ps1
.codex/hooks/enforce-epic-planning-only.ps1
.codex/hooks/enforce-epic-root-invocation.ps1
.codex/hooks/enforce-epic-wave-barrier.ps1
.codex/hooks/enforce-epic-worktree-removal-gate.ps1
.codex/hooks/enforce-evidence-locations.ps1
.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
.codex/hooks/enforce-powershell-batch-budget.ps1
.codex/hooks/enforce-promotion-mcp-only.ps1
.codex/hooks/enforce-python-batch-budget.ps1
.codex/hooks/hook-dependency-guard.ps1
.codex/hooks/validate-bash.ps1
.codex/hooks/validate-codex-subagent-routing.ps1
.codex/hooks/validate-feature-review-coverage.ps1
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
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/regression-first-summary.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/batch-budget-resets.md
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
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H1.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H2.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H3.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H4.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H5.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H6.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H7.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H8.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversions.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-mirror.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-repo.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-reconciliation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-rows.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-guard-worklist.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-load-check.2026-10-09T00-00.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/install-log.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/mirror-log.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/p1-spec-change-log.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/p4-runsettings.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/post-fix-enumeration.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/smoke-baseline.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/smoke-log.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/stdout-guard-offenders.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/coverage-comparison.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p1-t3-isolation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p1-t4-isolation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p10-coverage-pass1.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p10-coverage-pass2.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p10-remediation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p2-stdout-guard.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t1-isolation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t2-isolation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t3-isolation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t4-isolation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t5-isolation.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p4-helper-unit.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p4-pytest-guards.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p4-stdout-offenders.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-a-edit.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-a-verify.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-b-edit.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-b-verify.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-c-edit.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-c-verify.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-nonterm.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-cp-s-edit.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-cp-s-verify.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-cs-edit.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-cs-verify.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-special-cases.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-w690-suites.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-codex-suites.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-no-python.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xp-a-edit.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xp-a-verify.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xp-b-edit.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xp-b-verify.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xs-edit.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xs-verify.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p8-conversion-verify.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-ac12-remnants.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-exemption-guard.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-exit1-and-registrations.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-mirror-parity.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-no-python.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-preexisting-tests.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-pytest-guards.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-stdout-guard.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-structural.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/regression-testing/fail-before-behaviour.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/regression-testing/fail-before-exemption-guard.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/regression-testing/fail-before-structural.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md
docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-powershell-test-purity.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-python-test-purity.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-checkpoint-monotonic.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-invocation-origin.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-mermaid-validation.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-dependency-guard.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-resolution.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-powershell-test-purity.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-python-test-purity.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-epic-child-launch-attestation.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-checkpoint-monotonic.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-codex-model-routing.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-child-worktree-binding.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-root-invocation.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-wave-barrier.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-dependency-guard.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-codex-subagent-routing.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1
tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1
tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1
tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1
tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1
tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1
tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1

git status --porcelain:
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/commits.md
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/deviations.md
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md
 M tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
 M tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
 M tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
 M tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
 M tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1
 M tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
 M tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
 M tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1
 M tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
 M tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
 M tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
 M tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-mcp-poshqc.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pester-coverage.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-poshqc-analyze.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-poshqc-format.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pytest-full.md
?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pytest-guards.md

SELECTED: 57
MIRROR: .claude/hooks/check-powershell-test-purity.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-powershell-test-purity.ps1 | equal | 5956E53819C16CAE29A63CC2A18E93FE1AF7DF19BC26FCBC0D8406C7BD375332 | 5956E53819C16CAE29A63CC2A18E93FE1AF7DF19BC26FCBC0D8406C7BD375332
MIRROR: .claude/hooks/check-python-test-purity.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-python-test-purity.ps1 | equal | EF9D047951BA912436E1DEA53230AECF94E409F16C2103BFCA00E1E15A6BBFDE | EF9D047951BA912436E1DEA53230AECF94E409F16C2103BFCA00E1E15A6BBFDE
MIRROR: .claude/hooks/enforce-checkpoint-monotonic.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-checkpoint-monotonic.ps1 | equal | D4F55A5D82FE1E8875EDB554E18C8F25AFA2444DEC252324F55B4AA9164AD784 | D4F55A5D82FE1E8875EDB554E18C8F25AFA2444DEC252324F55B4AA9164AD784
MIRROR: .claude/hooks/enforce-completion-consistency.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 | equal | 9CA4D9C33B9F43644AC22370C9C82A544ECB22A2890B3B7B47028E169D5A64AE | 9CA4D9C33B9F43644AC22370C9C82A544ECB22A2890B3B7B47028E169D5A64AE
MIRROR: .claude/hooks/enforce-discovery-artifact-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | equal | 761AFA1F4B88DA88837908018F8A1E3468673ABACB4568DA087A923568C39BD5 | 761AFA1F4B88DA88837908018F8A1E3468673ABACB4568DA087A923568C39BD5
MIRROR: .claude/hooks/enforce-epic-invocation-origin.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-invocation-origin.ps1 | equal | 7E4B07B164941F936334700F019BE1E9117FDF23525089902C2D96EA601CB6E3 | 7E4B07B164941F936334700F019BE1E9117FDF23525089902C2D96EA601CB6E3
MIRROR: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1 | equal | 77FDFFC98D1A3B2F4330BCF11E9E4AA39FBF62B4486F8DF492BBCCA8229C6B59 | 77FDFFC98D1A3B2F4330BCF11E9E4AA39FBF62B4486F8DF492BBCCA8229C6B59
MIRROR: .claude/hooks/enforce-epic-merge-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 | equal | 76A3E5980E5E83607E0BAA66D353C8269F3DDC948F46BBEEF26EFB4C5F7B1723 | 76A3E5980E5E83607E0BAA66D353C8269F3DDC948F46BBEEF26EFB4C5F7B1723
MIRROR: .claude/hooks/enforce-epic-wave-barrier.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1 | equal | 2D7FD6ED863872344E49FB9BDB5DAF97014FE546F9DA0642E794D95B0618D978 | 2D7FD6ED863872344E49FB9BDB5DAF97014FE546F9DA0642E794D95B0618D978
MIRROR: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | equal | 7FEFA8C550E6FB01336C6BB639C545D83EC8E4E6763A54B860955188DE37531D | 7FEFA8C550E6FB01336C6BB639C545D83EC8E4E6763A54B860955188DE37531D
MIRROR: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 | equal | BCC358675E7E18EE74B05B397756947C44E266A3902B9B0DD6AE6ABF1DFF1E5D | BCC358675E7E18EE74B05B397756947C44E266A3902B9B0DD6AE6ABF1DFF1E5D
MIRROR: .claude/hooks/enforce-evidence-locations.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1 | equal | 24FBB9D65CC817E79F911B67D5144FD4E98286F8761E80976FE665690892C91A | 24FBB9D65CC817E79F911B67D5144FD4E98286F8761E80976FE665690892C91A
MIRROR: .claude/hooks/enforce-feature-folder-order.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1 | equal | ABD16D491BEDE4B4A9CBE3EE46F716557A7BF2DEF23767FA9C9FC4DB982B92D1 | ABD16D491BEDE4B4A9CBE3EE46F716557A7BF2DEF23767FA9C9FC4DB982B92D1
MIRROR: .claude/hooks/enforce-mermaid-validation.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-mermaid-validation.ps1 | equal | 1AA624095EFFC8431DDB6E92603319472A32B8EBEA22E1F3CC9CAA51AD902BE4 | 1AA624095EFFC8431DDB6E92603319472A32B8EBEA22E1F3CC9CAA51AD902BE4
MIRROR: .claude/hooks/enforce-model-routing-receipt.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1 | equal | 9CBF80ECDE57AD88FA8728B7AF94FC1BA0DFEAE6B040B89F15E622A8796F42C9 | 9CBF80ECDE57AD88FA8728B7AF94FC1BA0DFEAE6B040B89F15E622A8796F42C9
MIRROR: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | equal | C0B0BB86A033EB4230BBBD93480775A8C04DCE1894ABEC039095F908AF8BD333 | C0B0BB86A033EB4230BBBD93480775A8C04DCE1894ABEC039095F908AF8BD333
MIRROR: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | equal | 023C1FCA326856B5E8408B56AB1CBA291E9753DF1FD6EC3C3D2DA03E3C97A893 | 023C1FCA326856B5E8408B56AB1CBA291E9753DF1FD6EC3C3D2DA03E3C97A893
MIRROR: .claude/hooks/enforce-parallel-abandon-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1 | equal | 629CCD4FA613A8F4D819CDB3F1D577F7A45B3D37240E484DB238EE0272BC7C45 | 629CCD4FA613A8F4D819CDB3F1D577F7A45B3D37240E484DB238EE0272BC7C45
MIRROR: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1 | equal | DF23DFE8D4978D1E9AC5746DC9A38FD8DF42C56B282C898DF1D930D627C22950 | DF23DFE8D4978D1E9AC5746DC9A38FD8DF42C56B282C898DF1D930D627C22950
MIRROR: .claude/hooks/enforce-parallel-drift-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1 | equal | 0D19B5826B672EFC00872EBD7C71BD9B818D63C9B4C82E4C273E54084E736111 | 0D19B5826B672EFC00872EBD7C71BD9B818D63C9B4C82E4C273E54084E736111
MIRROR: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | equal | C2DEEA7D31FD02D14F89624CBB2E7A165D5A98EDB2BB5326D578D67DEDA97D2D | C2DEEA7D31FD02D14F89624CBB2E7A165D5A98EDB2BB5326D578D67DEDA97D2D
MIRROR: .claude/hooks/enforce-powershell-batch-budget.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 | equal | A5573CD7AF865229E2E598AFDBC4920F8336386A87EBE713B7D73F4C21FBC0A0 | A5573CD7AF865229E2E598AFDBC4920F8336386A87EBE713B7D73F4C21FBC0A0
MIRROR: .claude/hooks/enforce-pr-author-skill.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1 | equal | 014D8F5CD84FAD7DBE0629D5ECF4F4694D5F88EDF4C03AEC17DCF6D61671B11F | 014D8F5CD84FAD7DBE0629D5ECF4F4694D5F88EDF4C03AEC17DCF6D61671B11F
MIRROR: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | equal | 985768BDBC1707D94ED11BE19E413333EA75E6534BF19D38B9ED2E5E6F33B2C9 | 985768BDBC1707D94ED11BE19E413333EA75E6534BF19D38B9ED2E5E6F33B2C9
MIRROR: .claude/hooks/enforce-prd-feature-before-planner.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1 | equal | 23D7659412B8700B1EE0AAD1FE85D86136138282CE39DC98EA86C4DB12F96F74 | 23D7659412B8700B1EE0AAD1FE85D86136138282CE39DC98EA86C4DB12F96F74
MIRROR: .claude/hooks/enforce-promotion-mcp-only.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1 | equal | 774C8D52C203FDEDE41852E8D44F701EBEC6C1A1A7255B51526D16099425C7CA | 774C8D52C203FDEDE41852E8D44F701EBEC6C1A1A7255B51526D16099425C7CA
MIRROR: .claude/hooks/enforce-python-batch-budget.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1 | equal | 3AAB8B87129B3D473775D6EB95AFA884EA21FE6B8EE8C06EA620E0E650F07FD8 | 3AAB8B87129B3D473775D6EB95AFA884EA21FE6B8EE8C06EA620E0E650F07FD8
MIRROR: .claude/hooks/hook-dependency-guard.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-dependency-guard.ps1 | equal | F19385C165DE943DCBC6BC71345C9E4D8020D41669310BB4BAD2E70F21E4B300 | F19385C165DE943DCBC6BC71345C9E4D8020D41669310BB4BAD2E70F21E4B300
MIRROR: .claude/hooks/validate-bash.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 | equal | 77C3F188A4521A0D77698284E788C60B6EF66E4FD8493423944A0A3E88AE47E5 | 77C3F188A4521A0D77698284E788C60B6EF66E4FD8493423944A0A3E88AE47E5
MIRROR: .claude/hooks/validate-discovery-artifact-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | equal | 7E4F386128988C34DBCB6B5BAEB00153B0F201D01D5F4A27B3E2529CF7554401 | 7E4F386128988C34DBCB6B5BAEB00153B0F201D01D5F4A27B3E2529CF7554401
MIRROR: .claude/hooks/validate-feature-review-coverage.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | equal | FF063D8080D2A911D27E77113CF9CFD414F0262D9B7B7E2DAC4D9ED9414447B0 | FF063D8080D2A911D27E77113CF9CFD414F0262D9B7B7E2DAC4D9ED9414447B0
MIRROR: .claude/hooks/validate-orchestrator-output-resolution.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-resolution.ps1 | equal | CB82780B3F32B27C962F504C30C074AAEBD73F608D4E54C6BF71D62D73E5F980 | CB82780B3F32B27C962F504C30C074AAEBD73F608D4E54C6BF71D62D73E5F980
MIRROR: .claude/hooks/validate-orchestrator-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1 | equal | 029F2ECFE532C39DE8359E162AAC3AA06F206838F495FF2D450D14E9A1F8C78E | 029F2ECFE532C39DE8359E162AAC3AA06F206838F495FF2D450D14E9A1F8C78E
MIRROR: .claude/hooks/validate-planner-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1 | equal | B278C78933704C855564428C8E3BE328C7D25306F2842486E718290AB98596C3 | B278C78933704C855564428C8E3BE328C7D25306F2842486E718290AB98596C3
MIRROR: .claude/hooks/validate-pr-author-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1 | equal | 9391AC17538FC47D76BA73375DC35BF2933E51FAD201043CADC3197299AF5CE9 | 9391AC17538FC47D76BA73375DC35BF2933E51FAD201043CADC3197299AF5CE9
MIRROR: .claude/hooks/validate-prd-feature-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1 | equal | 1CE666427FB53F20E72DE967EF7A7291465E728719C4B2457166474F02906AC0 | 1CE666427FB53F20E72DE967EF7A7291465E728719C4B2457166474F02906AC0
MIRROR: .codex/hooks/check-powershell-test-purity.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-powershell-test-purity.ps1 | equal | DED6E929F4E598F70E8917D8BD792881A4ED7EAEBC99372FBBFCBA41E64395EB | DED6E929F4E598F70E8917D8BD792881A4ED7EAEBC99372FBBFCBA41E64395EB
MIRROR: .codex/hooks/check-python-test-purity.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-python-test-purity.ps1 | equal | DAE4B59C18567DEF67BC887CAB44C2889EDAA59521B52124BD6348F447833AA8 | DAE4B59C18567DEF67BC887CAB44C2889EDAA59521B52124BD6348F447833AA8
MIRROR: .codex/hooks/codex-epic-child-launch-attestation.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-epic-child-launch-attestation.ps1 | equal | F9E6FF273212998EABD89A1BE5A9E1A05B47B584A1B93EA4A369C659FBBCC613 | F9E6FF273212998EABD89A1BE5A9E1A05B47B584A1B93EA4A369C659FBBCC613
MIRROR: .codex/hooks/enforce-checkpoint-monotonic.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-checkpoint-monotonic.ps1 | equal | A8B70AC22FF84214236D16F827B6D875E70AD941806607C0F01D1ABF002CBDF8 | A8B70AC22FF84214236D16F827B6D875E70AD941806607C0F01D1ABF002CBDF8
MIRROR: .codex/hooks/enforce-codex-model-routing.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-codex-model-routing.ps1 | equal | 41BC222060FD17CBFE3302E41A2B883DA77D51539BDFC0E6ABF27C95103BA6C9 | 41BC222060FD17CBFE3302E41A2B883DA77D51539BDFC0E6ABF27C95103BA6C9
MIRROR: .codex/hooks/enforce-completion-consistency.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1 | equal | 9DAE74007157C39574C8B87C7528AE91959C1D7F995FC7B713F1600068A584D3 | 9DAE74007157C39574C8B87C7528AE91959C1D7F995FC7B713F1600068A584D3
MIRROR: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-child-worktree-binding.ps1 | equal | D70C6D492D94F0636F3E79190F36A50B41E6EE4763BC5430B312E7EE4645ED26 | D70C6D492D94F0636F3E79190F36A50B41E6EE4763BC5430B312E7EE4645ED26
MIRROR: .codex/hooks/enforce-epic-merge-gate.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 | equal | D5A564C8DEB216A61895B06F45BF03552FA6D85983ADC8A5C4087C96B8A4B03C | D5A564C8DEB216A61895B06F45BF03552FA6D85983ADC8A5C4087C96B8A4B03C
MIRROR: .codex/hooks/enforce-epic-planning-only.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1 | equal | D27BAE5F2358923EBE78CF78411661D62004511A3356C9841569BE0661E7CF65 | D27BAE5F2358923EBE78CF78411661D62004511A3356C9841569BE0661E7CF65
MIRROR: .codex/hooks/enforce-epic-root-invocation.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-root-invocation.ps1 | equal | 2D33C1C9DB8FA3E83C8D6727F54C5DCD998F9B5281CF5AE99B8832F2A80E8F06 | 2D33C1C9DB8FA3E83C8D6727F54C5DCD998F9B5281CF5AE99B8832F2A80E8F06
MIRROR: .codex/hooks/enforce-epic-wave-barrier.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-wave-barrier.ps1 | equal | 23158AB98A50E6B672494180039DF0C1C23823E8F4ECA6A602DC88E023FB0318 | 23158AB98A50E6B672494180039DF0C1C23823E8F4ECA6A602DC88E023FB0318
MIRROR: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1 | equal | EB9F896BFD21C13A96BC98C56B46632C64FD7ADA5861551F548CF7BC22A57D6E | EB9F896BFD21C13A96BC98C56B46632C64FD7ADA5861551F548CF7BC22A57D6E
MIRROR: .codex/hooks/enforce-evidence-locations.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1 | equal | E8901C213DD5E37754DBD47CB15ABE326B483E131A0883E116F6E382B61A3C37 | E8901C213DD5E37754DBD47CB15ABE326B483E131A0883E116F6E382B61A3C37
MIRROR: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | equal | 96CCBFDD2F4813A2C61EC219D12C2F69F318B19BC69C1AA925FDEC131F8CB930 | 96CCBFDD2F4813A2C61EC219D12C2F69F318B19BC69C1AA925FDEC131F8CB930
MIRROR: .codex/hooks/enforce-powershell-batch-budget.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1 | equal | 5D1049CCE985837D88384E7706550AC896264088F6C1272AB0D396BB7DE62E12 | 5D1049CCE985837D88384E7706550AC896264088F6C1272AB0D396BB7DE62E12
MIRROR: .codex/hooks/enforce-promotion-mcp-only.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1 | equal | 5F2A3241A9AB5B26C6118E71B530357BE68276B401100A03C5170BFEE3A921FC | 5F2A3241A9AB5B26C6118E71B530357BE68276B401100A03C5170BFEE3A921FC
MIRROR: .codex/hooks/enforce-python-batch-budget.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1 | equal | A1F1AB834057921FCE40835E19A92A228393C8576DB48CC308197B08FC435FFD | A1F1AB834057921FCE40835E19A92A228393C8576DB48CC308197B08FC435FFD
MIRROR: .codex/hooks/hook-dependency-guard.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-dependency-guard.ps1 | equal | F19385C165DE943DCBC6BC71345C9E4D8020D41669310BB4BAD2E70F21E4B300 | F19385C165DE943DCBC6BC71345C9E4D8020D41669310BB4BAD2E70F21E4B300
MIRROR: .codex/hooks/validate-bash.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1 | equal | 24B8E919C7961718823045AA614AC34C8B2A2EB6EBC2C3EF16BACF8D90E4B105 | 24B8E919C7961718823045AA614AC34C8B2A2EB6EBC2C3EF16BACF8D90E4B105
MIRROR: .codex/hooks/validate-codex-subagent-routing.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-codex-subagent-routing.ps1 | equal | 8035E04A3C16B1F228AD1F1CF6C109C804C633196FA0724370E8E90EDB7E4D5D | 8035E04A3C16B1F228AD1F1CF6C109C804C633196FA0724370E8E90EDB7E4D5D
MIRROR: .codex/hooks/validate-feature-review-coverage.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1 | equal | 278F92FE329107E90A7B8792FEF191FC7B302BFBD7DF9C4168FD3F1AF0A42E7E | 278F92FE329107E90A7B8792FEF191FC7B302BFBD7DF9C4168FD3F1AF0A42E7E
UNEQUAL_COUNT: 0
```
