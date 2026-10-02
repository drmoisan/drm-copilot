# Baseline Python Tests With Coverage (Full Suite)

Timestamp: 2026-10-02T01-17
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-744-baseline.json --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Deselection reason: issue #510. `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails locally on gitignored `.claude/state/` files independent of this change; it runs separately in P0-T20 and in CI.
- BaselineResultLine: `6331 passed, 6 skipped, 1 deselected in 101.46s (0:01:41)`
- N_py_passed: 6331
- TOTAL row: `TOTAL                                                                 17246   1116   6232    573    92%`
- term-missing row: `scripts\dev_tools\pr_context\verification_evidence.py                    58      1     18      2    96%   98->97, 124`
- BaselineFailingNodes: none
- `artifacts/python/coverage-744-baseline.json` written (intermediate tool output; values transcribed in python-coverage-baseline.2026-09-30T03-18.md).
- Command note: `-q -p no:cacheprovider` were appended to the plan command (quieter progress output and no `.pytest_cache` write); they do not change selection, coverage measurement, or the result line. Recorded as plan deviation D-TOOLS.
