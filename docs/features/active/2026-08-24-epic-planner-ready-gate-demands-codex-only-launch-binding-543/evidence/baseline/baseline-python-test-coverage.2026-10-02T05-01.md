# Baseline Python tests and coverage (issue #543)

Timestamp: 2026-10-02T05-01
Task: P0-T10
Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (worktree root, full suite)
EXIT_CODE: 0

Output Summary:
- Result line: `6437 passed, 6 skipped, 1 deselected in 87.15s` (0 failed). The 1 deselected node is the #510 local-only node `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- TOTAL row: `TOTAL                                                                 17499   1118   6320    576    92%`
- term-missing rows for the four write-set production files:
  - `scripts\dev_tools\_epic_orchestrator_state_launch_binding.py            119      3     56      3    97%   185, 224, 287`
  - `scripts\dev_tools\epic_planner_launch_evidence.py                       192     18     90     13    89%   43, 51, 54, 69-70, 77-78, 121-122, 126, 150, 158, 165, 171, 207, 290, 305, 311`
  - `scripts\dev_tools\epic_planner_readiness.py                             191     16     92     26    84%   33->exit, 35->exit, 37->exit, 39->exit, 41->exit, 106, 108, 125-126, 173, 178, 183-184, 214-219, 227, 230-231, 232->225, 250, 261->274, 263->262, 320->325, 326->333, 329->333, 333->342, 336->340, 344->354, 347, 352->345, 355->371, 365->371`
  - `scripts\dev_tools\validate_epic_planner_state.py                        180     15     94     15    89%   121, 127, 143-144, 149-150, 152, 154, 156, 169->173, 189, 211->209, 227, 236, 238, 255, 317`
- No test failed; the stop condition does not apply.
