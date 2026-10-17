# Remediation Cycle 3 Baseline Python Full Suite (P0-T10)

Timestamp: 2026-10-16T08-20
Command: poetry run pytest -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --cov=scripts.dev_tools --cov-branch --cov-report=term-missing > SCRATCH/rc3/py-full-baseline.txt; grep -e ' passed' -e ' failed' SCRATCH/rc3/py-full-baseline.txt; grep -e '^TOTAL' SCRATCH/rc3/py-full-baseline.txt; grep -e 'epic_planner_git_integrity.py ' -e 'epic_planner_readiness.py ' SCRATCH/rc3/py-full-baseline.txt
EXIT_CODE: 0
Output Summary:
- Result: 7164 passed, 6 skipped, 1 deselected in 94.62s (0:01:34) (deselected 1 = the #510 local-only bundle-parity test)
- TOTAL                                                                 17663   1067   6378    482    93%
- scripts\dev_tools\epic_planner_git_integrity.py                         158      0     90      0   100%
- scripts\dev_tools\epic_planner_readiness.py                             182      9     86     10    92%   113-114, 202-207, 215, 218-219, 220->213, 238, 249->262, 251->250, 325->329, 332->336, 348->341, 365->371
- Failed: none
