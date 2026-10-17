# Remediation Cycle 1 Final Python Full Suite (P5-T8)

Timestamp: 2026-10-16T04-18
Loop iteration: 1
Command: poetry run pytest -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --cov=scripts.dev_tools --cov-branch --cov-report=term > SCRATCH/rc1/py-full-final.txt; grep -e ' passed' -e ' failed' SCRATCH/rc1/py-full-final.txt; grep -e '^TOTAL' SCRATCH/rc1/py-full-final.txt
EXIT_CODE: 0
Output Summary:
- Result line: 7114 passed, 6 skipped, 1 deselected in 142.94s (0:02:22) (deselected 1: the known local-only #510 node)
- 7114 equals the P0-T13 count (7100) plus 14.
- TOTAL row (verbatim): TOTAL                                                                 17665   1085   6380    500    92%
- Failed: none (P0-T13 also recorded Failed: none)
- This is the last pytest run in the plan; artifacts/python/lcov.info now carries the repository-wide figure.
