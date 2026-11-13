# Scope check (issue #1157, cycle 1, P2-T7)

Timestamp: 2026-11-13T15-58
Command: sh SCRATCH/issue-1157-scope.sh (in the item worktree: git diff --name-status $(git merge-base origin/main HEAD); git status --porcelain; a search of the name-status listing for added .py files and for the forbidden paths; git diff $(git merge-base origin/main HEAD) over the three AC-29 suites, counted in lines)
EXIT_CODE: 0
Output Summary:
- git diff --name-status from the merge base: EXIT_CODE 0, 139 entries (listed below).
- git status --porcelain: EXIT_CODE 0, empty (every change is committed).
- No added .py file: PASS (the only Python entry is M tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py).
- No change to .claude/agents/epic-orchestrator.md, .claude/agents/orchestrator.md, .claude/agents/parallel-orchestrator.md, any .codex/hooks/ or Copilot hook file, scripts/dev_tools/validate_orchestration_artifacts.py, or extensions/drm-copilot/src/lib/validate/: PASS (no matching entry).
- AC-29 suites tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1, tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1, and tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1: diff against the merge base 0 lines: PASS.
- Note: the P1-T4 and P1-T5 suites other than validate-orchestrator-output.TargetWorktree.Tests.ps1, hook-dependency-failure.Claude.Tests.ps1, and hook-import-failure-exemptions.FailClosed.Tests.ps1 now equal the merge base and are absent from the listing; WorktreeResolution and MutationRejection carry the P1-T7 filter rename.

## git diff --name-status listing

    M	.agents/skills/execution-environment/SKILL.md
    M	.agents/skills/owner-directives/SKILL.md
    M	.claude/agents/atomic-executor.md
    M	.claude/agents/atomic-planner.md
    M	.claude/agents/csharp-typed-engineer.md
    M	.claude/agents/feature-review.md
    M	.claude/agents/powershell-typed-engineer.md
    M	.claude/agents/prd-feature.md
    M	.claude/agents/python-typed-engineer.md
    M	.claude/agents/task-researcher.md
    M	.claude/agents/typescript-engineer.md
    A	.claude/hooks/enforce-owner-directive-pass-down.ps1
    A	.claude/hooks/owner-directive-pass-down-target.ps1
    A	.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1
    M	.claude/hooks/validate-orchestrator-output.ps1
    A	.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1
    A	.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1
    M	.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1
    M	.claude/rules/orchestrator-state.md
    M	.claude/settings.json
    M	.claude/skills/epic-orchestrate/SKILL.md
    M	.claude/skills/execution-environment/SKILL.md
    M	.claude/skills/orchestrate/SKILL.md
    M	.claude/skills/owner-directives/SKILL.md
    M	.claude/skills/parallel-orchestrate/SKILL.md
    M	.github/skills/execution-environment/SKILL.md
    M	.github/skills/owner-directives/SKILL.md
    M	docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch
    A	docs/features/active/owner-directive-pass-down-1157/code-review.2026-11-13T14-04.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/baseline/pester-baseline.2026-11-10T04-02.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/baseline/powershell-static.2026-11-10T03-13.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/baseline/pytest-baseline.2026-11-10T04-08.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/baseline/python-static.2026-11-10T03-14.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/frozen-digest.2026-11-11T04-50.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/main-sync.2026-11-11T04-47.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/preflight-fixes.2026-11-09T22-23.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/preflight-fixes.2026-11-09T22-42.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/preflight-fixes.2026-11-13T14-27.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/preflight-fixes.2026-11-13T14-41.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/preparation-receipt.2026-11-09T22-43.json
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/scope-check.2026-11-11T06-59.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/scope-check.2026-11-13T13-48.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P0-T1.2026-11-13T14-43.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P0-T2.2026-11-13T14-43.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P1-T1.2026-11-13T14-45.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P1-T2.2026-11-13T14-48.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P1-T3.2026-11-13T14-49.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P1-T4.2026-11-13T14-51.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P1-T5.2026-11-13T14-52.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P1-T6.2026-11-13T14-53.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P1-T7.2026-11-13T14-58.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P2-T1.2026-11-13T15-34.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P2-T2.2026-11-13T15-35.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P2-T3.2026-11-13T15-48.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P2-T4.2026-11-13T15-49.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P2-T5.2026-11-13T15-55.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P2-T6.2026-11-13T15-56.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P6-T10.2026-11-13T13-53.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P6-T9.2026-11-13T13-50.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/bundle-parity.2026-11-13T15-56.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/coverage-comparison.2026-11-11T06-20.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/coverage-comparison.2026-11-11T06-55.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/coverage-comparison.2026-11-12T13-05.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/coverage-comparison.2026-11-13T15-49.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/pester-final.2026-11-11T05-28.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/pester-final.2026-11-11T06-18.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/pester-final.2026-11-11T06-38.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/pester-final.2026-11-11T06-55.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/pester-final.2026-11-12T13-05.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/pester-final.2026-11-13T15-48.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/phase-gate.P1.2026-11-13T15-34.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/powershell-static.2026-11-11T04-57.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/powershell-static.2026-11-11T05-49.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/powershell-static.2026-11-12T12-38.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/powershell-static.2026-11-13T15-34.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/pytest-final.2026-11-11T06-58.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/pytest-final.2026-11-13T13-47.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/pytest-final.2026-11-13T15-55.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/python-static.2026-11-11T04-58.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/python-static.2026-11-12T12-38.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/python-static.2026-11-13T15-35.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/self-review.2026-11-13T13-52.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/regression-testing/fail-before.F1.2026-11-13T14-53.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/regression-testing/fail-before.F3.2026-11-13T14-45.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/remediation-baseline/baseline-reference.2026-11-13T14-43.md
    A	docs/features/active/owner-directive-pass-down-1157/evidence/remediation-baseline/powershell-static.2026-11-13T14-42.md
    A	docs/features/active/owner-directive-pass-down-1157/feature-audit.2026-11-13T14-04.md
    A	docs/features/active/owner-directive-pass-down-1157/issue.md
    A	docs/features/active/owner-directive-pass-down-1157/plan.2026-11-09T16-32.md
    A	docs/features/active/owner-directive-pass-down-1157/policy-audit.2026-11-13T14-04.md
    A	docs/features/active/owner-directive-pass-down-1157/remediation-inputs.2026-11-13T14-04.md
    A	docs/features/active/owner-directive-pass-down-1157/remediation-plan.2026-11-13T14-04.md
    A	docs/features/active/owner-directive-pass-down-1157/research/research.2026-11-09T21-37.md
    A	docs/features/active/owner-directive-pass-down-1157/spec.md
    A	docs/features/active/owner-directive-pass-down-1157/user-story.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/agents/typescript-engineer.md
    A	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-owner-directive-pass-down.ps1
    A	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/owner-directive-pass-down-target.ps1
    A	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1
    M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1
    A	extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1
    A	extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1
    M	extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1
    M	extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/settings.json
    M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/owner-directives/SKILL.md
    M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
    M	extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
    M	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md
    M	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/owner-directives/SKILL.md
    M	extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md
    M	extensions/drm-copilot/resources/customizations/.github/skills/owner-directives/SKILL.md
    M	tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1
    A	tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1
    M	tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
    M	tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
    A	tests/scripts/claude-hooks/owner-directive-pass-down-target.Tests.ps1
    M	tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1
    A	tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1
    M	tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1
    M	tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1
    M	tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1
    A	tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.Tests.ps1
    A	tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.Tests.ps1
    A	tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Entry.Tests.ps1
    A	tests/scripts/claude-runtime/owner-directive-pass-down.Registration.Tests.ps1
    M	tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1
    M	tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py

## git status --porcelain listing

    (empty)
