Timestamp: 2026-03-14T18:36:16-04:00
Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_change_budget_router_requires_orchestrated_small_path_wording
EXIT_CODE: 1
Output Summary: EXPECTED RED — the C# change-budget router still describes the small path without the required `--work-mode minor-audit` lifecycle wording.

Failure Excerpt:
AssertionError: assert '--work-mode minor-audit' in router_text

Pytest Summary:
1 failed, 3 deselected in 0.06s
