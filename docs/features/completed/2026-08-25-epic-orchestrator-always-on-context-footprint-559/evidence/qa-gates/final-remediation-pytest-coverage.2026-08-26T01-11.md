Timestamp: 2026-08-26T01-11

Command: poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing -q
EXIT_CODE: 1

Output Summary: 1 failed, 4150 passed, 5 skipped in 10.96s. The sole failing node
ID is
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
— the pre-existing tolerated failure — and no other test failed. Coverage TOTAL
row: `15014    1104    93%` (92.65% exact, 13910/15014 statements covered),
matching `[P0-T8]`'s pre-remediation baseline exactly, a signed delta of `+0.00`
percentage points.
