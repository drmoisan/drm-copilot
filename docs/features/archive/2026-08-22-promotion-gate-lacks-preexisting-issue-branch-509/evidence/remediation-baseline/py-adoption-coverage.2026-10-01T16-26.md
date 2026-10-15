# Baseline Targeted Coverage: `_orchestrator_state_issue_adoption` (Remediation Cycle 1)

Timestamp: 2026-10-01T16-26
Task: [P0-T6]
Location: worktree root
Command: `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/py-adoption-coverage.json`
EXIT_CODE: 0

Output Summary:

- Pytest summary line: `============================= 43 passed in 0.22s ==============================`
- `RB_TARGETED_PASSED` = 43 (failed 0), matching the expected 43.
- `term-missing` row (verbatim):

```text
scripts\dev_tools\_orchestrator_state_issue_adoption.py     113      0     46      0   100%
```

- JSON `summary` for key `scripts\dev_tools\_orchestrator_state_issue_adoption.py` (matched by suffix `_orchestrator_state_issue_adoption.py`):
  - `RB_ADOPTION_LINE` = covered_lines / num_statements = 113 / 113 = 100.0%
  - `RB_ADOPTION_BRANCH` = covered_branches / num_branches = 46 / 46 = 100.0%
- Note: the planner recorded 114/114 statements from the first-execution artifact; the merged tree reports 113/113. The percentage (100.0) is unchanged; the observed values here are the reference for P4-T4.
