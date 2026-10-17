# Baseline Python Full Suite (Issue #849)

Timestamp: 2026-10-10T09-53
Task: P0-T9
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-full-coverage.2026-10-09T01-33.json
EXIT_CODE: 0

## Summary line (verbatim)

```text
================= 6821 passed, 6 skipped in 97.75s (0:01:37) ==================
```

- Collected: 6827 items
- RB_PY_FULL_PASSED: 6821
- Skipped: 6 (1 in test_blast_radius_regression_452.py, 5 in test_parallel_manifest_bash_parity.py)
- RB_PY_FULL_FAILED: {}

## TOTAL row (verbatim)

```text
TOTAL                                                                 17630   1101   6362    509    92%
```

Module row for reference (verbatim):

```text
scripts\dev_tools\_orchestrator_state_issue_adoption.py                 113      0     46      0   100%
```

## JSON totals

JSON file: `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-full-coverage.2026-10-09T01-33.json`. File keys are repo-relative paths in this worktree (the module key is `scripts\dev_tools\_orchestrator_state_issue_adoption.py`); no key and no value in the JSON carries an absolute host path (0 matches for a drive-letter or `/home/` prefix).

```json
{"covered_lines": 16529, "num_statements": 17630, "percent_covered": 92.23907969323108, "missing_lines": 1101, "excluded_lines": 590, "percent_statements_covered": 93.75496313102666, "num_branches": 6362, "num_partial_branches": 509, "covered_branches": 5601, "missing_branches": 761, "percent_branches_covered": 88.03835271927068}
```

- Line: covered_lines / num_statements = 16529 / 17630 = 93.75%
- Branch: covered_branches / num_branches = 5601 / 6362 = 88.04%
- Combined (coverage.py `percent_covered`, shown as the TOTAL Cover column): 92.24%

Output Summary: Full suite exit 0: 6821 passed, 6 skipped, 0 failed (RB_PY_FULL_FAILED = {}). scripts.dev_tools totals: line 93.75% (16529/17630), branch 88.04% (5601/6362), combined 92.24%.
