# AC-13 Scope Verification Anchored to origin/main (#841, P6-T15)

Timestamp: 2026-10-10T09-44
Command: git fetch origin main; git diff --name-only origin/main...HEAD; git status --porcelain; git diff --exit-code origin/main...HEAD -- .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md .agents/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md .claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/rules .github/instructions .github/workflows .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json .github/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
EXIT_CODE: 0
Output Summary:
- `git fetch origin main`: exit 0. origin/main resolves to 179c586676d0f942043e349f7666852c551f25fb (unchanged by the fetch; already current locally). Merge base of HEAD and origin/main: 5431ccdd471c184917493c4211afcd715bb4b95c (= BASE_SHA). origin/main is 17 commits ahead of the merge base; the branch has not been merged with it (merges are owned by the orchestrator).
- `git diff --name-only origin/main...HEAD` (three-dot, from the merge base): 59 paths = the ten `## Files Written` code paths, the preparation-run path `docs/features/potential/promoted/2026-10-08-ci-gate-vacuous-on-empty-check-list.md`, and 48 paths (evidence/baseline 14, evidence/other 4, evidence/qa-gates 15, evidence/regression-testing 11, issue.md, plan, research, spec.md) under `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/`. No other path. This is the P6-T15 set.
- `git status --porcelain`: ` M docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md` only (the P6-T14 check-off).
- Appendix G3 protected-path diff: exit 0, no output.
- Informational: `git diff --name-only HEAD...origin/main` restricted to the ten code paths' directories printed nothing, so the 17 main commits since the merge base do not modify any file this branch writes.

Route: git commands run exactly as written (no route substitution applies).

## Ten code paths present in the name-only list

- .agents/skills/feature-review-workflow/SKILL.md
- .claude/lib/ci-gate/Invoke-CiGateParser.ps1
- .claude/skills/feature-review-workflow/SKILL.md
- .claude/skills/orchestrate/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md
- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1
- tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py

## Protected paths (none listed; G3 exit 0)

`.claude/skills/epic-orchestrate/SKILL.md` and mirror, `.agents/skills/orchestrate/SKILL.md` and mirror, `.claude/rules/**` and mirror, `.github/instructions/**`, `.github/workflows/**`, `.claude/agents/orchestrator.md` and mirror, `pack-manifests/core.json`, both Copilot `feature-review-workflow/SKILL.md` copies, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.

Surface-pin tests (AC-13 test half): `test_parallel_orchestrator_surface_contracts.py` 36 passed, `test_parallel_planner_surface_contracts.py` 16 passed, `test_parallel_planner_surface_contracts_landed.py` 8 passed (P6-T9).

G3_EXIT=0
