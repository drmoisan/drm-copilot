# Task Check: P5-T2

Timestamp: 2026-11-14T04-11
Command: sh SCRATCH/issue-1158-pycheck.sh (black --check, ruff check --no-fix, pyright on the changed Python files, then `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <selection>`); sh SCRATCH/issue-1158-pester-files.sh (the two ledger test files, Run.Exit $true)
EXIT_CODE: 0
Output Summary: black 0 files to reformat; ruff `All checks passed!`; pyright 0 errors; launcher pytest selection 104 passed, 0 failed (re-run after moving the new shell-step test: 49 passed, 0 failed); ledger debugging run 20 passed, 0 failed.

## Changed Files

- `scripts/dev_tools/fix_all_runtime.py` (`suite_lock` keyword seam, default `threading.Lock()` per call, passed to the four test-step branches)
- `scripts/dev_tools/fix_all_branches.py` (`run_suite_command`, `report_suite_failure`, `run_launcher_test_step`; shell `bats` and Pester `pester` steps through the launcher)
- `scripts/dev_tools/fix_all_branches_extra.py` (pytest `pytest` and Jest `jest` steps through the launcher)
- `tests/scripts/dev_tools/test_fix_all_branches.py` (launcher-argv assertions updated by design; new `test_shell_test_step_runs_launcher_bats_suite`)
- `tests/scripts/dev_tools/test_fix_all_launcher_steps.py` (new)
- `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` (ledger rule: Pester-step block regenerated, the `-Command` block of `fix_all_branches.py` and the `pytest_command` block of `fix_all_branches_extra.py` removed with a stated reason, the `test_fix_all_branches.py` block regenerated, `## Files Changed` notes and a `Rebased over #1158` paragraph updated)

## Selection and Rule

Rule: mirrored tests of each changed production file plus every test file that imports or names a changed module (`## Test Cadence (Mandatory)`); for the changed ledger entry, the ledger contract tests.

- pytest: `tests/scripts/dev_tools/test_fix_all_launcher_steps.py`, `test_fix_all_branches.py`, `test_fix_all_json_cancel.py`, `test_fix_all_failure_paths.py`, `test_fix_all.py`, `test_execution_environment_brief_contracts.py` (names `fix_all`).
- Pester: `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE |
|---|---|---|
| format | `env -u VIRTUAL_ENV poetry run black --check <5 files>` | 0 |
| lint | `env -u VIRTUAL_ENV poetry run ruff check --no-fix <5 files>` | 0 |
| type check | `env -u VIRTUAL_ENV poetry run pyright <5 files>` | 0 |
| tests | `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <6 test files>` | 0 |
| ledger | Pester `Run.Path` = the two ledger test files, `Run.Exit` = `$true` | 0 |

## Notes

- The no-overlap case passes `suite_lock` to `fix_all_runtime.run_fix_all`, which the pre-change tree does not accept, and asserts the injected lock is held for each of the four launcher steps; the pre-change steps never acquire it.
- The pytest-exit-2 case (`test_pytest_exit_2_with_session_output_keeps_todays_message`) fails against a classifier that reads the code alone, which would log `TEST_EXECUTION_POLICY_BLOCKED`.
- `scripts/dev_tools/fix_all.py` is unchanged; its `run_fix_all` wrapper uses the default lock.
