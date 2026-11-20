# Scope and Gate-Intent Evidence (loop pass 2)

Timestamp: 2026-11-03T14-20
Task: [P8-T13]
Command: git fetch origin main; git diff --name-only --no-renames $(git merge-base origin/main HEAD) HEAD; git diff --name-status --no-renames $(git merge-base origin/main HEAD) HEAD (added .py count); git status --porcelain
EXIT_CODE: 0
Output Summary: Loop pass 2, after P8-T12. The tracked path set is identical to the pass-1 record (diff of the two name lists is empty). The merge-base diff lists 37 paths outside the feature folder plus the feature-folder documents and evidence. It contains no `.ts` path and no added `.py` path, and exactly one modified `.py` path, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (test-support fragment pins). No path is under `.claude/lib/bash/`, `tests/shell/`, or `.claude/skills/orchestrate/`. Porcelain status outside the feature folder shows only modified tracked files: `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1` and its bundle copy (the loop-2 DynamicInvocation fix) and `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` (the formatter one-line indentation change); no untracked path exists outside the feature folder.

## Assertions

| Check | Observed | Result |
| --- | --- | --- |
| `.ts` paths in the merge-base diff | 0 | PASS |
| Added `.py` paths (name-status `A`) | 0 | PASS |
| Modified `.py` paths | 1: `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | PASS |
| Paths under `.claude/lib/bash/`, `tests/shell/`, `.claude/skills/orchestrate/` | 0 | PASS |

## Merge-base diff outside the feature folder

- .claude/agents/parallel-orchestrator.md
- .claude/agents/parallel-planner.md
- .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1
- .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1
- .claude/lib/parallel-admission/ParallelAdmission.psm1
- .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1
- .claude/rules/parallel-orchestration.md
- .claude/settings.json
- .claude/skills/parallel-add/SKILL.md
- .claude/skills/parallel-orchestrate/SKILL.md
- .claude/skills/parallel-plan/SKILL.md
- docs/features/potential/promoted/2026-10-31-parallel-add-and-plan-resume-prepared-items-without-replanning.md
- extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
- extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/ParallelAdmission.psm1
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1
- extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
- extensions/drm-copilot/resources/claude-customizations/.claude/settings.json
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
- quality-tiers.yml
- tests/fixtures/parallel_admission/closed-orchestrator-state.json
- tests/fixtures/parallel_admission/seed-orchestrator-state.json
- tests/fixtures/parallel_admission/seed-parallel.md
- tests/fixtures/parallel_admission/seed-planner-state.json
- tests/fixtures/parallel_admission/seed-scheduling-record.json
- tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1
- tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1
- tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1
- tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1
- tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1
- tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1
- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py

## Gate intent

- `test_parallel_mutation_run_bash_parity.py` passed in the P6-T6 serial run (`evidence/qa-gates/pytest-contracts.2026-11-03T13-38.md`) and in the P8-T8 `-n auto` run; the bash entry points and their Python authorities are not in the diff.
- CI-dependent items, checked at S9 on the pull-request head: `shell-coverage / Shell Coverage (Bats + kcov)` (the unchanged `tests/shell/*_parity.bats` suites) and `poshqc / PowerShell hook suites (Linux)` (the cohort-barrier hook suite, including the new `precedence predecessors` context, on `ubuntu-latest`).
