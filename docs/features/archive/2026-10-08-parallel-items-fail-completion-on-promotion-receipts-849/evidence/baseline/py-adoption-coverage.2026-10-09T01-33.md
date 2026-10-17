# Baseline Python Targeted Coverage (Issue #849)

Timestamp: 2026-10-10T09-51
Task: P0-T8
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-adoption-coverage.2026-10-09T01-33.json
EXIT_CODE: 0

## Pytest summary line (verbatim)

```text
============================= 75 passed in 0.49s ==============================
```

RB_PY_TARGETED_PASSED: 75 (collected 75 items; 0 failed)

## term-missing row (verbatim)

```text
Name                                                      Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------
scripts\dev_tools\_orchestrator_state_issue_adoption.py     113      0     46      0   100%
```

## JSON summary for the module

JSON file: `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-adoption-coverage.2026-10-09T01-33.json`

Key (matched by suffix `_orchestrator_state_issue_adoption.py`): `scripts\dev_tools\_orchestrator_state_issue_adoption.py`. This is the repo-relative path inside this worktree; it does not name another worktree. The JSON contains no absolute host path (search for a drive-letter or `/home/` prefix returned 0 matches).

```json
{"covered_lines": 113, "num_statements": 113, "percent_covered": 100.0, "missing_lines": 0, "excluded_lines": 2, "num_branches": 46, "num_partial_branches": 0, "covered_branches": 46, "missing_branches": 0, "percent_branches_covered": 100.0}
```

- RB_PY_LINE: covered_lines / num_statements = 113 / 113 = 1.0000 = 100.00%
- RB_PY_BRANCH: covered_branches / num_branches = 46 / 46 = 1.0000 = 100.00%

Output Summary: 75 passed, 0 failed. Module `_orchestrator_state_issue_adoption.py`: 113 statements, 0 missed, 46 branches, 0 partial; RB_PY_LINE = 100.00% (113/113), RB_PY_BRANCH = 100.00% (46/46).
