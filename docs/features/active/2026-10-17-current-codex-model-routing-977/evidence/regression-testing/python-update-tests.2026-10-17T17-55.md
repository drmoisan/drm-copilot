Timestamp: 2026-10-17T17:55:39.560905+00:00
Command: poetry run pytest --no-cov tests/scripts/dev_tools/test_resolve_codex_deployment.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_epic_planner_launch_evidence.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py
EXIT_CODE: 0
Output Summary:

============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 119 items

tests\scripts\dev_tools\test_resolve_codex_deployment.py ............... [ 12%]
........                                                                 [ 19%]
tests\scripts\dev_tools\test_generate_codex_agent_variants.py .......... [ 27%]
.....                                                                    [ 31%]
tests\scripts\dev_tools\test_validate_orchestrator_state_codex_model_routing.py . [ 32%]
...........                                                              [ 42%]
tests\scripts\dev_tools\test_validate_orchestrator_state_codex_topology.py . [ 42%]
............                                                             [ 52%]
tests\scripts\dev_tools\test_validate_epic_planner_state.py ............ [ 63%]
...............                                                          [ 75%]
tests\scripts\dev_tools\test_epic_planner_launch_evidence.py ........... [ 84%]
...............                                                          [ 97%]
tests\scripts\dev_tools\test_codex_full_migration_inventory.py ...       [100%]

============================= 119 passed in 0.51s =============================

Full sanitized output: SCRATCH/issue-977-regression-testing-python-update-tests.log
