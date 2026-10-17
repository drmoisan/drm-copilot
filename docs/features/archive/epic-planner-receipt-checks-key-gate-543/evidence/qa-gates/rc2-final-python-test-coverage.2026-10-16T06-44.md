# Final Python Unit Tests with Coverage (P7-T5)

Timestamp: 2026-10-16T06-41
Loop iteration: 1
Command: poetry run pytest -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --cov=scripts.dev_tools --cov-branch --cov-report=term-missing > SCRATCH/rc2/py-full-final.txt; grep -e ' passed' -e ' failed' SCRATCH/rc2/py-full-final.txt; grep -e '^TOTAL' SCRATCH/rc2/py-full-final.txt; grep -e 'validate_epic_planner_state.py ' -e '_epic_orchestrator_state_launch_binding.py ' -e 'epic_planner_git_integrity.py ' -e 'epic_planner_readiness.py ' SCRATCH/rc2/py-full-final.txt
EXIT_CODE: 0
Output Summary:
- Result line: 7153 passed, 6 skipped, 1 deselected in 122.64s (0:02:02)  (deselected 1: #510 local-only bundle-parity test; 7153 = P0-T10 7119 + 34)
- TOTAL                                                                 17663   1067   6378    482    93%
- scripts\dev_tools\_epic_orchestrator_state_launch_binding.py            119      0     56      0   100%
- scripts\dev_tools\epic_planner_git_integrity.py                         158      0     90      0   100%
- scripts\dev_tools\epic_planner_readiness.py                             182      9     86     10    92%   113-114, 202-207, 215, 218-219, 220->213, 238, 249->262, 251->250, 325->329, 332->336, 348->341, 365->371
- scripts\dev_tools\validate_epic_planner_state.py                        191      0    100      1    99%   174->178
- Failed: none (P0-T10 also recorded none).
