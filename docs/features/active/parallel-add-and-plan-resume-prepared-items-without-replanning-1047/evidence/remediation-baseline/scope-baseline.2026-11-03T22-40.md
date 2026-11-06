# Scope Baseline (remediation cycle 3)

Timestamp: 2026-11-03T22-40
Task: [P0-T2]
Command: git rev-parse HEAD; git merge-base origin/main HEAD; git diff --name-only --no-renames <merge base> HEAD; git status --porcelain; grep -c '' on the two files (both end with a line terminator, so the count equals the logical line count)
EXIT_CODE: 0
Output Summary: branch head b433ccc86 (merge base with origin/main 01706c697). The merge-base diff lists 175 paths: 135 under `<FEATURE>/` and the 40 paths below. `git status --porcelain` shows only two `<FEATURE>/` entries (the preflight edit of the plan and the preflight fix record); no tracked modification outside `<FEATURE>/`. Logical lines: `Invoke-ParallelAdmission.ps1` 625, `Invoke-ParallelAdmission.Tests.ps1` 695.

## Branch head

b433ccc86

## Merge-base diff, paths outside `<FEATURE>/` (40)

```
.claude/agents/parallel-orchestrator.md
.claude/agents/parallel-planner.md
.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1
.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1
.claude/lib/parallel-admission/ParallelAdmission.psm1
.claude/lib/parallel-admission/ParallelAdmissionJson.psm1
.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1
.claude/rules/parallel-orchestration.md
.claude/settings.json
.claude/skills/parallel-add/SKILL.md
.claude/skills/parallel-orchestrate/SKILL.md
.claude/skills/parallel-plan/SKILL.md
docs/features/potential/promoted/2026-10-31-parallel-add-and-plan-resume-prepared-items-without-replanning.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/ParallelAdmission.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/ParallelAdmissionJson.psm1
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
tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1
tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1
tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
```

## git status --porcelain

```
 M docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/remediation-plan.2026-11-03T22-32.md
?? docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/other/preflight-fixes.2026-11-03T22-40.md
```

The full 175-path listing is kept as `SCRATCH/c3-scope-base.txt` for the [P2-T8] comparison.
