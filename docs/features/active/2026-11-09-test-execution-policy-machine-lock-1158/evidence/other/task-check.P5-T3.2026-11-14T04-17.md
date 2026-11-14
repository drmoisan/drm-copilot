# Task Check: P5-T3

Timestamp: 2026-11-14T04-17
Command: sh SCRATCH/issue-1158-pycheck.sh (black --check, ruff check --no-fix, pyright on the changed Python files, then `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <selection>`); sh SCRATCH/issue-1158-pester-files.sh (the two ledger test files, Run.Exit $true)
EXIT_CODE: 0
Output Summary: black 0 files to reformat; ruff `All checks passed!` (first pass found 1 E501 in the new test file, fixed and re-run); pyright 0 errors; launcher pytest selection 97 passed, 0 failed; ledger debugging run 20 passed, 0 failed.

## Changed Files

- `scripts/dev_tools/atomic_executor/cli_preflight.py` (`PreflightQCResult.launcher_outcome`, placed last; launcher `pytest` and `jest` steps; classification ahead of the `expectations is None` return; the `--collect-only` step stays direct)
- `scripts/dev_tools/atomic_executor/cli_task_runtime.py` (`run_preflight_qc_fix_loop` returns 5 on a set `launcher_outcome`, before the missing-executable branch)
- `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` (`_PYTEST_STEP`, `_JEST_STEP`, the Jest mock key, and identity `shutil.which` patches in three tests, updated by design)
- `tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py` (`test_preflight_pytest_step_runs_xdist_workers` gains the identity patch)
- `tests/scripts/dev_tools/atomic_executor/test_cli_preflight.py` (new)
- `tests/scripts/dev_tools/atomic_executor/test_cli_task_runtime.py` (new)
- `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` (ledger rule: the `cli_preflight.py`, `_PYTEST_STEP`, and `test_cli_part2_part2.py` blocks regenerated; `Rebased over #1158` paragraph added)

## Selection and Rule

Rule: mirrored tests of each changed production file plus every test file that imports or names a changed module (`## Test Cadence (Mandatory)`), including the `cli` facade tests that re-export these functions; for the changed ledger entry, the ledger contract tests.

- pytest: `tests/scripts/dev_tools/atomic_executor/test_cli_preflight.py`, `test_cli_task_runtime.py`, `test_cli.py`, `test_cli_part2.py`, `test_cli_part2_part2.py`, `test_cli_part3.py`, `test_cli_part4.py`, `test_cli_part4_part2.py`, `tests/scripts/dev_tools/test_atomic_executor_cli.py`.
- Pester: `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE |
|---|---|---|
| format | `env -u VIRTUAL_ENV poetry run black --check <6 files>` | 0 |
| lint | `env -u VIRTUAL_ENV poetry run ruff check --no-fix <6 files>` | 0 |
| type check | `env -u VIRTUAL_ENV poetry run pyright <6 files>` | 0 |
| tests | `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <9 test files>` | 0 |
| ledger | Pester `Run.Path` = the two ledger test files, `Run.Exit` = `$true` | 0 |

## Notes

- `test_preflight_missing_test_ref` and `test_preflight_qc_result_dataclass` are unchanged, as the plan states.
- The `expectations=None` cases fail against a classification placed after the existing `expectations is None` early return, which returns before any launcher outcome is set.
