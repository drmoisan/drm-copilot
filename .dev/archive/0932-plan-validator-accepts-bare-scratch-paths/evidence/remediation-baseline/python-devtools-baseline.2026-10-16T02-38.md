# Python Dev-Tools Regression Baseline (Remediation Cycle 1)

Timestamp: 2026-10-16T02-38
Task: [P0-T15]
Command: poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:

- Final summary: `7055 passed, 6 skipped in 33.59s`.
- Counts: 7055 passed, 0 failed, 0 errors, 6 skipped.
- Failing or erroring node IDs (reference set for [P5-T6]): none. The #510 node `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed in this run.
- The 6 skips are in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231` (fixtures that declare no accessor expectation).
