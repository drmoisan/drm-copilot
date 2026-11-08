# Pytest Parallel Final Gate - Issue 1034 Remediation Cycle 4 (P2-T6)

Timestamp: 2026-11-07T14-40
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1034-coverage-final.json --junitxml=SCRATCH/issue-1034-pytest-final.xml --cov (worktree root, through sh SCRATCH/issue-1034-c4-pytest.sh final; summary by SCRATCH/issue-1034-c4-pytest-summary.ps1)
EXIT_CODE: 0
Output Summary: PASS on the first run. 16350 passed, 6 skipped, 0 failed, 0 errors in 226.50 s, equal to the baseline baseline/pytest-parallel.2026-11-07T14-22.md. Failure set: empty, so there is no new failure. tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py: 14 tests, 0 failed or errored. Coverage totals are information only, since no Python file changed.

## Comparison Against the Baseline

| Item | Baseline (P0-T6) | Final (P2-T6) |
|---|---|---|
| Exit code | 0 | 0 |
| Tests (JUnit) | 16356 | 16356 |
| Passed | 16350 | 16350 |
| Failed | 0 | 0 |
| Errored | 0 | 0 |
| Skipped | 6 | 6 |
| Failure set | empty | empty |
| New failures | | none |
| `test_push_down_claude_resource_contracts.py` | 14 tests, 0 failed | 14 tests, 0 failed |

## Coverage Totals (information)

| Item | Baseline | Final |
|---|---|---|
| Terminal `TOTAL` line | `TOTAL 35181 1110 13344 572 96%` | `TOTAL 35181 1110 13344 573 96%` |
| Line coverage (JSON) | 34071 of 35181, 96.84% | 34071 of 35181, 96.84% |
| Branch coverage (JSON) | 12528 of 13344, 93.88% | 12527 of 13344, 93.88% |
| Combined (JSON `percent_covered`) | 96.03% | 96.03% |

The final run reports one more partial branch than the baseline (573 against 572). No Python file changed between the two runs (qa-gates/scope-check of P2-T7 lists the changed paths), so the difference comes from the run itself and not from this cycle's edits. The plan records these totals as information only.

## Parallel-Only Waiver

Owner directive (binding): the pytest gate is one `pytest -n auto` run, re-run only after a fix. This gate passed on its first run, so it was not re-run. No single-process, seeded-shuffle, reversed-order or ordering-comparison run was performed.
