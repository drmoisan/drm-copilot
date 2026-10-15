# Final Line Counts ([P11-T7], AC-25)

Timestamp: 2026-10-10T06-27
Pass: 4
Command: <SCRATCHPAD>/final11.ps1 records `git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a` together with `git status --porcelain`. It selects every existing .ps1, .psm1 and .psd1 path (production, test and test-support) and runs R-LINES (`@(Get-Content -LiteralPath <path>).Count`) on each.
EXIT_CODE: 0
Output Summary: 149 PowerShell paths selected, with one `LINES:` line per path. OVER_500: 0. The largest file is .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 and its mirror, at 500 lines each.

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

SELECTED: 149
LINES: .claude/hooks/check-powershell-test-purity.ps1 | 151
LINES: .claude/hooks/check-python-test-purity.ps1 | 153
LINES: .claude/hooks/enforce-checkpoint-monotonic.ps1 | 315
LINES: .claude/hooks/enforce-completion-consistency.ps1 | 470
LINES: .claude/hooks/enforce-discovery-artifact-gate.ps1 | 239
LINES: .claude/hooks/enforce-epic-invocation-origin.ps1 | 286
LINES: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 243
LINES: .claude/hooks/enforce-epic-merge-gate.ps1 | 472
LINES: .claude/hooks/enforce-epic-wave-barrier.ps1 | 380
LINES: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 236
LINES: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 461
LINES: .claude/hooks/enforce-evidence-locations.ps1 | 229
LINES: .claude/hooks/enforce-feature-folder-order.ps1 | 287
LINES: .claude/hooks/enforce-mermaid-validation.ps1 | 408
LINES: .claude/hooks/enforce-model-routing-receipt.ps1 | 301
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 275
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 471
LINES: .claude/hooks/enforce-parallel-abandon-gate.ps1 | 359
LINES: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 346
LINES: .claude/hooks/enforce-parallel-drift-gate.ps1 | 451
LINES: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 456
LINES: .claude/hooks/enforce-powershell-batch-budget.ps1 | 492
LINES: .claude/hooks/enforce-pr-author-skill.ps1 | 334
LINES: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 343
LINES: .claude/hooks/enforce-prd-feature-before-planner.ps1 | 483
LINES: .claude/hooks/enforce-promotion-mcp-only.ps1 | 312
LINES: .claude/hooks/enforce-python-batch-budget.ps1 | 495
LINES: .claude/hooks/hook-dependency-guard.ps1 | 114
LINES: .claude/hooks/validate-bash.ps1 | 448
LINES: .claude/hooks/validate-discovery-artifact-gate.ps1 | 264
LINES: .claude/hooks/validate-feature-review-coverage.ps1 | 465
LINES: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 309
LINES: .claude/hooks/validate-orchestrator-output.ps1 | 466
LINES: .claude/hooks/validate-planner-output.ps1 | 416
LINES: .claude/hooks/validate-pr-author-output.ps1 | 142
LINES: .claude/hooks/validate-prd-feature-output.ps1 | 97
LINES: .codex/hooks/check-powershell-test-purity.ps1 | 172
LINES: .codex/hooks/check-python-test-purity.ps1 | 172
LINES: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 129
LINES: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 345
LINES: .codex/hooks/enforce-codex-model-routing.ps1 | 204
LINES: .codex/hooks/enforce-completion-consistency.ps1 | 491
LINES: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 340
LINES: .codex/hooks/enforce-epic-merge-gate.ps1 | 385
LINES: .codex/hooks/enforce-epic-planning-only.ps1 | 371
LINES: .codex/hooks/enforce-epic-root-invocation.ps1 | 141
LINES: .codex/hooks/enforce-epic-wave-barrier.ps1 | 301
LINES: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 190
LINES: .codex/hooks/enforce-evidence-locations.ps1 | 202
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 500
LINES: .codex/hooks/enforce-powershell-batch-budget.ps1 | 347
LINES: .codex/hooks/enforce-promotion-mcp-only.ps1 | 297
LINES: .codex/hooks/enforce-python-batch-budget.ps1 | 350
LINES: .codex/hooks/hook-dependency-guard.ps1 | 114
LINES: .codex/hooks/validate-bash.ps1 | 319
LINES: .codex/hooks/validate-codex-subagent-routing.ps1 | 160
LINES: .codex/hooks/validate-feature-review-coverage.ps1 | 304
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-powershell-test-purity.ps1 | 151
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-python-test-purity.ps1 | 153
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-checkpoint-monotonic.ps1 | 315
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 | 470
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | 239
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-invocation-origin.ps1 | 286
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 243
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 | 472
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1 | 380
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 236
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 461
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1 | 229
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1 | 287
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-mermaid-validation.ps1 | 408
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1 | 301
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 275
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 471
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1 | 359
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1 | 346
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1 | 451
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 456
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 | 492
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1 | 334
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 343
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1 | 483
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1 | 312
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1 | 495
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-dependency-guard.ps1 | 114
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 | 448
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | 264
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | 465
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-resolution.ps1 | 309
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1 | 466
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1 | 416
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1 | 142
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1 | 97
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-powershell-test-purity.ps1 | 172
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-python-test-purity.ps1 | 172
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-epic-child-launch-attestation.ps1 | 129
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-checkpoint-monotonic.ps1 | 345
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-codex-model-routing.ps1 | 204
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1 | 491
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-child-worktree-binding.ps1 | 340
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 | 385
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1 | 371
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-root-invocation.ps1 | 141
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-wave-barrier.ps1 | 301
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 190
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1 | 202
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 500
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1 | 347
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1 | 297
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1 | 350
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-dependency-guard.ps1 | 114
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1 | 319
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-codex-subagent-routing.ps1 | 160
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1 | 304
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | 43
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | 309
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | 255
LINES: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | 217
LINES: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 176
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | 256
LINES: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | 181
LINES: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | 168
LINES: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 193
LINES: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | 196
LINES: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | 236
LINES: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | 142
LINES: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 474
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 296
LINES: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | 235
LINES: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | 249
LINES: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | 46
LINES: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | 54
LINES: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | 46
LINES: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | 238
LINES: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | 98
LINES: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | 156
LINES: tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1 | 328
LINES: tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1 | 155
LINES: tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1 | 160
LINES: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | 70
LINES: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 128
LINES: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 94
LINES: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 181
LINES: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 210
LINES: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | 136
LINES: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 80
LINES: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 497
LINES: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 113
LINES: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 199
OVER_500: 0
```
