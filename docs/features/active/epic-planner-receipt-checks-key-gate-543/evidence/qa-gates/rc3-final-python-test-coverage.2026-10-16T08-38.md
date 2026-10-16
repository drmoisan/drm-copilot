# Remediation Cycle 3 Final Python Test Coverage (P5-T5)

Timestamp: 2026-10-16T08-38
Loop iteration: 1
Command: poetry run pytest -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --cov=scripts.dev_tools --cov-branch --cov-report=term-missing > SCRATCH/rc3/py-full-final.txt; grep -e ' passed' -e ' failed' SCRATCH/rc3/py-full-final.txt; grep -e '^TOTAL' SCRATCH/rc3/py-full-final.txt; grep -e 'epic_planner_git_integrity.py ' -e 'epic_planner_readiness.py ' SCRATCH/rc3/py-full-final.txt
EXIT_CODE: 0
Output Summary:
- Result: 7178 passed, 6 skipped, 1 deselected in 75.07s (0:01:15) (deselected 1 = the #510 local-only bundle-parity test; passed = P0-T10 7164 + 14)
- TOTAL                                                                 17664   1058   6378    478    93%
- scripts\dev_tools\epic_planner_git_integrity.py                         159      0     90      0   100%
- scripts\dev_tools\epic_planner_readiness.py                             182      0     86      6    98%   220->213, 249->262, 251->250, 325->329, 332->336, 348->341
- Failed: none (P0-T10 also recorded Failed: none)
