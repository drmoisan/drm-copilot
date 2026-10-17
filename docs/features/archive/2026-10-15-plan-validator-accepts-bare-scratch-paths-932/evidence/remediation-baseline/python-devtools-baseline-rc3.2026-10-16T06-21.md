# Python Dev-Tools Regression Baseline (Remediation Cycle 3)

Timestamp: 2026-10-16T06-21
Task: [P0-T14]
Command: poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: `7080 passed, 6 skipped in 25.47s`. 0 failed, 0 errors, 6 skipped (all in `test_parallel_manifest_bash_parity.py`, fixtures that declare no accessor expectation).

Reference set of failing or erroring node IDs (for [P5-T6]): none. The #510 node `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed locally in this run.
