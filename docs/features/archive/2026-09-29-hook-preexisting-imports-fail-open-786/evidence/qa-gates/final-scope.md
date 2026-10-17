# Final Scope Check ([P11-T9])

Timestamp: 2026-10-10T06-27
Pass: 4
Command: <SCRATCHPAD>/final11.ps1 records `git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a` together with `git status --porcelain`. Each listed path is classified against the section 6 allowed prefixes, the rule 8 runtime-local prefixes and the rule 12 files. For each W-EXEMPT sibling handler file (H2 modes on both surfaces, H3 helpers, and their mirrors), the script records whether it is listed and, if it is, its `git diff -U0` output.
EXIT_CODE: 0
Output Summary:
- OUTSIDE: 0. RULE12_LISTED: 0.
- Two W-EXEMPT sibling files are listed: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 and its Claude mirror. Each shows exactly one removed and one added line, both at line 30. Line 30 is the W-NONTERM `Line` of that `Via` in hook-guard-worklist.md, and the change is the end-of-line ` -ErrorAction Stop` append.
- The H2 modes files and their mirrors on both surfaces are not listed.

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

SCOPE: .claude/hooks/check-powershell-test-purity.ps1 | allowed | -
SCOPE: .claude/hooks/check-python-test-purity.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-checkpoint-monotonic.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-completion-consistency.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-discovery-artifact-gate.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-epic-invocation-origin.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-epic-merge-gate.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-epic-wave-barrier.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-evidence-locations.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-feature-folder-order.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-mermaid-validation.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-model-routing-receipt.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-parallel-abandon-gate.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-parallel-drift-gate.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-powershell-batch-budget.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-pr-author-skill.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-prd-feature-before-planner.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-promotion-mcp-only.ps1 | allowed | -
SCOPE: .claude/hooks/enforce-python-batch-budget.ps1 | allowed | -
SCOPE: .claude/hooks/hook-dependency-guard.ps1 | allowed | -
SCOPE: .claude/hooks/validate-bash.ps1 | allowed | -
SCOPE: .claude/hooks/validate-discovery-artifact-gate.ps1 | allowed | -
SCOPE: .claude/hooks/validate-feature-review-coverage.ps1 | allowed | -
SCOPE: .claude/hooks/validate-orchestrator-output-resolution.ps1 | allowed | -
SCOPE: .claude/hooks/validate-orchestrator-output.ps1 | allowed | -
SCOPE: .claude/hooks/validate-planner-output.ps1 | allowed | -
SCOPE: .claude/hooks/validate-pr-author-output.ps1 | allowed | -
SCOPE: .claude/hooks/validate-prd-feature-output.ps1 | allowed | -
SCOPE: .codex/hooks/check-powershell-test-purity.ps1 | allowed | -
SCOPE: .codex/hooks/check-python-test-purity.ps1 | allowed | -
SCOPE: .codex/hooks/codex-epic-child-launch-attestation.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-checkpoint-monotonic.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-codex-model-routing.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-completion-consistency.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-epic-merge-gate.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-epic-planning-only.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-epic-root-invocation.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-epic-wave-barrier.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-evidence-locations.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-powershell-batch-budget.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-promotion-mcp-only.ps1 | allowed | -
SCOPE: .codex/hooks/enforce-python-batch-budget.ps1 | allowed | -
SCOPE: .codex/hooks/hook-dependency-guard.ps1 | allowed | -
SCOPE: .codex/hooks/validate-bash.ps1 | allowed | -
SCOPE: .codex/hooks/validate-codex-subagent-routing.ps1 | allowed | -
SCOPE: .codex/hooks/validate-feature-review-coverage.ps1 | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-baseline-green.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-batch-budget-probe.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-execution-route.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-feature-documents-read.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-line-counts.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-mcp-poshqc-format.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-merge.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-mirror-sha.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pester-coverage.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-poshqc-analyze.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-poshqc-format.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pre-merge-state.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pytest-full.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pytest-guards.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-runsettings-coverage-path.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-upstream-precondition.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/phase0-instructions-read.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/regression-first-summary.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/batch-budget-resets.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/bf1-feature-folder-order-analysis.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/commits.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/deviations.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/exemption-decisions.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H1.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H2.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H3.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H4.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H5.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H6.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H7.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H8.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H1.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H2.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H3.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H4.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H5.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H6.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H7.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversion.H8.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/handler-conversions.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-mirror.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-enumeration-repo.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-reconciliation.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-dependency-rows.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-guard-worklist.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/hook-load-check.2026-10-09T00-00.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/install-log.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/mirror-log.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/p1-spec-change-log.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/p4-runsettings.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/post-fix-enumeration.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/smoke-baseline.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/smoke-log.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/stdout-guard-offenders.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/coverage-comparison.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-mcp-poshqc.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pester-coverage.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-poshqc-analyze.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-poshqc-format.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pytest-full.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pytest-guards.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p1-t3-isolation.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p1-t4-isolation.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p10-coverage-pass1.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p10-coverage-pass2.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p10-remediation.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p2-stdout-guard.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t1-isolation.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t2-isolation.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t3-isolation.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t4-isolation.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p3-t5-isolation.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p4-helper-unit.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p4-pytest-guards.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p4-stdout-offenders.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-a-edit.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-a-verify.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-b-edit.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-b-verify.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-c-edit.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-cp-c-verify.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p5-nonterm.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-cp-s-edit.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-cp-s-verify.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-cs-edit.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-cs-verify.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-special-cases.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p6-w690-suites.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-codex-suites.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-no-python.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xp-a-edit.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xp-a-verify.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xp-b-edit.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xp-b-verify.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xs-edit.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p7-xs-verify.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p8-conversion-verify.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-ac12-remnants.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-exemption-guard.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-exit1-and-registrations.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-mirror-parity.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-no-python.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-preexisting-tests.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-pytest-guards.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-stdout-guard.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p9-structural.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/regression-testing/fail-before-behaviour.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/regression-testing/fail-before-exemption-guard.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/regression-testing/fail-before-structural.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md | allowed | -
SCOPE: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-powershell-test-purity.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-python-test-purity.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-checkpoint-monotonic.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-invocation-origin.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-mermaid-validation.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-dependency-guard.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-resolution.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-powershell-test-purity.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-python-test-purity.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-epic-child-launch-attestation.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-checkpoint-monotonic.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-codex-model-routing.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-child-worktree-binding.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-root-invocation.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-wave-barrier.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-dependency-guard.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-codex-subagent-routing.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1 | allowed | -
SCOPE: extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json | allowed | -
SCOPE: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | allowed | -
SCOPE: tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1 | allowed | -
SCOPE: tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1 | allowed | -
SCOPE: tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | allowed | -
SCOPE: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | allowed | -
OUTSIDE: 0
RULE12_LISTED: 0
EXEMPT_SIBLING_NOT_LISTED: .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
EXEMPT_SIBLING_NOT_LISTED: .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
EXEMPT_SIBLING_LISTED: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
git diff -U0 86e457a003be0c60b65e01156e4cccd6495dfd1a -- .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1:
diff --git a/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 b/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
index f5f6de24a..d26e143b2 100644
--- a/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
+++ b/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
@@ -30 +30 @@
-Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeResolution.psm1') -Force
+Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeResolution.psm1') -Force -ErrorAction Stop
REMOVED: 1 ADDED: 1
EXEMPT_SIBLING_NOT_LISTED: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
EXEMPT_SIBLING_NOT_LISTED: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
EXEMPT_SIBLING_LISTED: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
git diff -U0 86e457a003be0c60b65e01156e4cccd6495dfd1a -- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1:
diff --git a/extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 b/extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
index f5f6de24a..d26e143b2 100644
--- a/extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
+++ b/extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
@@ -30 +30 @@
-Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeResolution.psm1') -Force
+Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeResolution.psm1') -Force -ErrorAction Stop
REMOVED: 1 ADDED: 1
```
