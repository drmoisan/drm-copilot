# Pytest Parallel Baseline - Issue 1034 Remediation Cycle 4 (P0-T6)

Timestamp: 2026-11-07T14-22
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1034-coverage-baseline.json --junitxml=SCRATCH/issue-1034-pytest-baseline.xml --cov (worktree root, through sh SCRATCH/issue-1034-c4-pytest.sh baseline; summary by SCRATCH/issue-1034-c4-pytest-summary.ps1)
EXIT_CODE: 0
Output Summary: PASS, before any edit of cycle 4. 16350 passed, 6 skipped, 0 failed, 0 errors in 375.48 s. Baseline failure set: empty. Terminal TOTAL line: 35181 statements, 1110 missed, 13344 branches, 572 partial, 96%. JSON branch totals: 12528 of 13344 branches covered (93.88%).

| Item | Value |
|---|---|
| Exit code | 0 |
| Tests (JUnit) | 16356 |
| Passed | 16350 |
| Failed | 0 |
| Errored | 0 |
| Skipped | 6 |
| Terminal `TOTAL` line | `TOTAL 35181 1110 13344 572 96%` |
| Line coverage (JSON) | 34071 of 35181 statements, 96.84% |
| Branch coverage (JSON) | 12528 of 13344 branches, 93.88% |
| Combined coverage (JSON `percent_covered`) | 96.03% |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 14 tests, 0 failed or errored |

## Baseline Failure Set

None. No `testcase` in SCRATCH/issue-1034-pytest-baseline.xml holds a failure or error node.

## Parallel-Only Waiver

Owner directive (binding): the pytest gate is one `pytest -n auto` run, re-run only after a fix. No single-process, seeded-shuffle, reversed-order or ordering-comparison run was performed.
