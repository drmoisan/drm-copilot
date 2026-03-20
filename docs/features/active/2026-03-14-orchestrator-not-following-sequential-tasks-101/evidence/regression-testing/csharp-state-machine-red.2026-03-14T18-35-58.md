Timestamp: 2026-03-14T18:35:58-04:00
Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_orchestration_state_machine_requires_plan_path_and_bootstrap_fields
EXIT_CODE: 1
Output Summary: EXPECTED RED — the C# orchestration state-machine skill still omits required short-path continuity fields such as `work-mode` and `plan-path`.

Failure Excerpt:
AssertionError: assert 'work-mode' in state_machine_text

Pytest Summary:
1 failed, 2 deselected in 0.07s
