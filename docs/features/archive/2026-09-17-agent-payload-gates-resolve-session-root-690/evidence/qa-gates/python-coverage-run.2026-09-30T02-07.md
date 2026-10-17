# Repository Python Suite with Coverage (P1-T1, RF-1)

Timestamp: 2026-09-30T02-07
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- KL-510: STATE-ONLY
- Summary line: 1 failed, 5339 passed, 6 skipped in 67.09s
- Terminal TOTAL line: 16307 statements, 1124 missed, 5924 branches, 582 partial, 91%
- FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts (the only FAILED node; assertion "Repo file missing from bundle: .claude\state\current-session-id").
- artifacts/python/lcov.info exists after the run (written by the pyproject addopts lcov reporter).
