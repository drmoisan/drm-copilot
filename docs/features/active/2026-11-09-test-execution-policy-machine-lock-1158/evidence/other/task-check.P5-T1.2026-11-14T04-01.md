# Task Check: P5-T1

Timestamp: 2026-11-14T04-01
Command: sh SCRATCH/issue-1158-pycheck.sh (black --check, ruff check --no-fix, pyright on the changed Python files, then `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <selection>`); sh SCRATCH/issue-1158-pester-files.sh (New-PesterConfiguration with Run.Path set to the two ledger test files and Run.Exit $true)
EXIT_CODE: 0
Output Summary: black 0 files to reformat; ruff `All checks passed!`; pyright 0 errors; launcher pytest selection 63 passed, 0 failed; ledger debugging run 20 passed, 0 failed.

## Changed Files

- `scripts/dev_tools/atomic_executor/qc_runner_expectations.py` (launcher contract; pause-commit work verified against the task text, docstrings and decision comments completed)
- `scripts/dev_tools/atomic_executor/qc_runner.py` (`FULL_TEST`, `FULL_TS_TEST`, `full_test`, loop-method classification)
- `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` (three argv assertions updated by design)
- `tests/scripts/dev_tools/atomic_executor/test_qc_runner_expectations.py` (new)
- `tests/scripts/dev_tools/atomic_executor/test_qc_runner_launcher.py` (new)
- `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` (ledger rule: the two `qc_runner.py` blocks and the two `test_qc_runner.py` blocks under `### Later Landing: #1096` regenerated; `Rebased over #1158` paragraph added to `## Summary`)

## Selection and Rule

Rule: the mirrored tests of each changed production file plus every test file that imports the changed modules (`## Test Cadence (Mandatory)`); for the changed ledger entry, the contract tests that read it.

- pytest: `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`, `test_qc_runner_expectations.py`, `test_qc_runner_launcher.py`.
- Pester: `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE |
|---|---|---|
| format | `env -u VIRTUAL_ENV poetry run black --check <5 files>` | 0 |
| lint | `env -u VIRTUAL_ENV poetry run ruff check --no-fix <5 files>` | 0 |
| type check | `env -u VIRTUAL_ENV poetry run pyright <5 files>` | 0 |
| tests | `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <3 test files>` | 0 |
| ledger | Pester `Run.Path` = the two ledger test files, `Run.Exit` = `$true` | 0 |

The first pass found 3 files to reformat, 2 E501 findings, and 3 pyright findings in a test lambda; they were fixed and the check re-run from format.

## Notes

- Focused Pester runs go directly through `New-PesterConfiguration`, because the launcher `pester` suite runs `Invoke-PoshQCParallelTest`, which takes no test-path selection; a task check is not a gate.
- The exit-2 cases (`test_without_expectations_exit_2_stays_plain`, `test_exit_2_collection_error_reaches_parser`, `test_exit_2_runtime_error_raises_plain`, `test_pytest_exit_2_session_output_returned_unchanged`, and the classifier rows `(2, pytest session output)` and `(2, None)`) fail against a classifier that reads the code alone, because such a classifier returns a refusal for every exit 2.
