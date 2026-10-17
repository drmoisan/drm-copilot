# Remediation Cycle 2 Baseline Python Full Suite (P0-T10)

Timestamp: 2026-10-16T06-19
Command: poetry run pytest -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --cov=scripts.dev_tools --cov-branch --cov-report=term-missing > SCRATCH/rc2/py-full-baseline.txt; grep -e ' passed' -e ' failed' SCRATCH/rc2/py-full-baseline.txt; grep -e '^TOTAL' SCRATCH/rc2/py-full-baseline.txt; grep -e 'validate_epic_planner_state.py ' -e '_epic_orchestrator_state_launch_binding.py ' -e 'epic_planner_git_integrity.py ' -e 'epic_planner_readiness.py ' SCRATCH/rc2/py-full-baseline.txt
EXIT_CODE: 0
Output Summary:
- Result line: 7119 passed, 6 skipped, 1 deselected in 107.36s (0:01:47)  (deselected 1: the #510 local-only bundle-parity test)
- TOTAL                                                                 17665   1085   6380    500    92%
- scripts\dev_tools\_epic_orchestrator_state_launch_binding.py            119      2     56      2    98%   188, 299
- scripts\dev_tools\epic_planner_git_integrity.py                         151      1     86      1    99%   295
- scripts\dev_tools\epic_planner_readiness.py                             191     13     92     14    90%   106, 108, 125-126, 173, 178, 214-219, 227, 230-231, 232->225, 250, 261->274, 263->262, 337->341, 344->348, 360->353, 377->383
- scripts\dev_tools\validate_epic_planner_state.py                        191     11    100     12    92%   121, 127, 151-152, 154, 156, 158, 174->178, 194, 216->214, 277, 286, 356
- Failed: none
