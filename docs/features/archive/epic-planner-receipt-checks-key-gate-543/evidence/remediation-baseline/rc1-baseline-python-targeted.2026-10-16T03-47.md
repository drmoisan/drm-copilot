# Remediation Cycle 1 Baseline Python Targeted Tests and Coverage (P0-T11)

Timestamp: 2026-10-16T03-47
Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_git_integrity.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov=scripts.dev_tools._epic_orchestrator_state_launch_binding --cov=scripts.dev_tools.epic_planner_git_integrity --cov-branch --cov-report=term-missing > SCRATCH/rc1/py-targeted-baseline.txt 2>&1
EXIT_CODE: 0
Output Summary:
- Result line: 110 passed in 0.86s (0 failed)
- term-missing rows (verbatim):
  scripts\dev_tools\_epic_orchestrator_state_launch_binding.py     119      3     56      3    97%   188, 227, 296
  scripts\dev_tools\epic_planner_git_integrity.py                  133      2     78      2    98%   220, 259
  scripts\dev_tools\validate_epic_planner_state.py                 188     14    100     14    90%   121, 127, 143-144, 149-150, 152, 154, 156, 169->173, 189, 211->209, 271, 280, 282, 346
  TOTAL                                                            440     19    234     19    94%
- Output was redirected to a SCRATCH file because the worktree isolation guard refuses pipes.
