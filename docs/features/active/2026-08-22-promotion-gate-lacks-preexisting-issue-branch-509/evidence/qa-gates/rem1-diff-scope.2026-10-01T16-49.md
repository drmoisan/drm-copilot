# Final QA: Remediation Diff Scope (Remediation Cycle 1)

Timestamp: 2026-10-01T16-49
Task: [P4-T15]
Location: worktree root

## 1. Anchor ancestry

Command: `git merge-base --is-ancestor 0aff3f47802bd57cb41e22a2dd61d8cdf91aa070 HEAD`
EXIT_CODE: 0
Output Summary: ancestor, so the three-dot range measures exactly the commits made after the merge.

## 2. Committed changes since the anchor

Command: `git diff --name-only 0aff3f47802bd57cb41e22a2dd61d8cdf91aa070...HEAD`
EXIT_CODE: 0
Output Summary: 50 paths, grouped:

- Python tests (4): `tests/scripts/dev_tools/orchestrator_state_issue_adoption_test_support.py`, `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py`, `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py`
- Python production (1): `scripts/dev_tools/_orchestrator_state_issue_adoption.py`
- PowerShell (2): `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`
- Feature documents (2): `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md`, `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/remediation-plan.2026-09-30T15-25.md`
- Evidence (41): files under `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/` in `remediation-baseline/` (20), `regression-testing/` (13), and `other/` (8).

## 3. Working-tree status

Command: `git status --porcelain`
EXIT_CODE: 0
Output Summary: ` M` for this remediation plan and `??` for 20 new files, all under `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/` (`other/remediation-p3-commit.2026-10-01T16-41.md` and 19 files under `qa-gates/`).

## Scope result

The union of the two listings contains only paths named in "Scope of the diff": the four test files, the Python module, the two PowerShell copies, the executed plan, this plan, and files under the feature folder's `evidence/` (`spec.md` is edited later by P4-T16). It contains no path under `.claude/hooks/`, `.codex/hooks/`, `.claude/rules/`, `.claude/skills/`, `.agents/skills/`, `.github/instructions/`, `extensions/drm-copilot/src/`, or `extensions/drm-copilot/test/`; no path under `extensions/drm-copilot/resources/` other than the bundled `OrchestratorStateIssueAdoption.psm1` copy; and none of `extensions/drm-copilot/jest.config.cjs`, `scripts/dev_tools/validate_orchestrator_state.py`, `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`, or `config/orchestration-routing.json`. Result: PASS.
