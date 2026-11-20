# Scope Baseline (remediation cycle 1)

Timestamp: 2026-11-03T19-22
Task: [P0-T2]
Command: git diff --name-only --no-renames $(git merge-base origin/main HEAD) HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary: merge base 01706c697f3ad4a53b4a771d99d851afc7417ea9; branch feature/parallel-add-and-plan-resume-prepared-items-1047 at head 5000b6455e2a76d10b7468313f3566efbeb4142b; 98 paths changed since the merge base; porcelain lists only the remediation plan check-off and the new remediation-baseline folder, both under <FEATURE>/, so no tracked modification exists outside <FEATURE>/.

Branch head: 5000b6455e2a76d10b7468313f3566efbeb4142b
Merge base: 01706c697f3ad4a53b4a771d99d851afc7417ea9

## Merge-base name-only listing

```
.claude/agents/parallel-orchestrator.md
.claude/agents/parallel-planner.md
.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1
.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1
.claude/lib/parallel-admission/ParallelAdmission.psm1
.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1
.claude/rules/parallel-orchestration.md
.claude/settings.json
.claude/skills/parallel-add/SKILL.md
.claude/skills/parallel-orchestrate/SKILL.md
.claude/skills/parallel-plan/SKILL.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/code-review.2026-11-03T18-43.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/black-baseline.2026-11-03T12-55.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/pester-baseline.2026-11-03T12-53.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/phase0-instructions-read.2026-11-03T12-51.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/poshqc-static-baseline.2026-11-03T12-54.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/pyright-baseline.2026-11-03T12-55.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/pytest-contracts-baseline.2026-11-03T12-55.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/quality-tiers-baseline.2026-11-03T12-55.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/ruff-baseline.2026-11-03T12-55.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/baseline/scope-baseline.2026-11-03T12-51.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/mirror-hashes.2026-11-03T13-36.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/mirror-hashes.2026-11-03T13-37.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/mirror-hashes.2026-11-03T14-22.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/module-size.2026-11-03T13-02.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/module-size.2026-11-03T13-09.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/module-size.2026-11-03T13-24.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/module-size.2026-11-03T13-26.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/orchestrator-state-snapshot.2026-11-03T14-38.json
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/preflight-fixes.2026-11-03T12-47.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/preflight-fixes.2026-11-03T19-17.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/quality-tiers.2026-11-03T13-37.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/black-final.2026-11-03T13-42.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/black-final.2026-11-03T13-53.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/coverage-delta.2026-11-03T13-41.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/coverage-delta.2026-11-03T13-52.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/pester-coverage.2026-11-03T13-41.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/pester-coverage.2026-11-03T13-52.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/poshqc-analyze.2026-11-03T13-40.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/poshqc-analyze.2026-11-03T13-52.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/poshqc-format.2026-11-03T13-40.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/poshqc-format.2026-11-03T13-52.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/pyright-final.2026-11-03T13-42.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/pyright-final.2026-11-03T13-53.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/pytest-contracts.2026-11-03T13-38.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/ruff-final.2026-11-03T13-42.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/ruff-final.2026-11-03T13-53.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/scope-diff.2026-11-03T13-46.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/scope-diff.2026-11-03T14-20.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/qa-gates/self-review.2026-11-03T14-21.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/integration-closed-run.2026-11-03T13-39.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/integration-half-prepared.2026-11-03T13-39.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/integration-seed.2026-11-03T13-39.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/pester-full.2026-11-03T14-20.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/pester-parallel-shards.2026-11-03T14-00.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/pester-shuffle.2026-11-03T13-45.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/pester-shuffle.2026-11-03T13-54.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/pytest-n-auto.2026-11-03T13-42.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/pytest-n-auto.2026-11-03T13-53.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/pytest-strict-markers-nauto.2026-11-03T18-42.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/python-reversed.2026-11-03T13-43.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/python-reversed.2026-11-03T13-53.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/regression-testing/review-linux-reruns.2026-11-03T18-43.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/feature-audit.2026-11-03T18-43.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/issue.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/plan.2026-11-03T06-52.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/policy-audit.2026-11-03T18-43.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/remediation-inputs.2026-11-03T18-43.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/remediation-plan.2026-11-03T18-43.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/research/research.2026-11-03T12-30.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/spec.md
docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/user-story.md
docs/features/potential/promoted/2026-10-31-parallel-add-and-plan-resume-prepared-items-without-replanning.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/ParallelAdmission.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
extensions/drm-copilot/resources/claude-customizations/.claude/settings.json
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
quality-tiers.yml
tests/fixtures/parallel_admission/closed-orchestrator-state.json
tests/fixtures/parallel_admission/seed-orchestrator-state.json
tests/fixtures/parallel_admission/seed-parallel.md
tests/fixtures/parallel_admission/seed-planner-state.json
tests/fixtures/parallel_admission/seed-scheduling-record.json
tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1
tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1
tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1
tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1
tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1
tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1
tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
```

## git status --porcelain

```
 M docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/remediation-plan.2026-11-03T18-43.md
?? docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/remediation-baseline/
```
