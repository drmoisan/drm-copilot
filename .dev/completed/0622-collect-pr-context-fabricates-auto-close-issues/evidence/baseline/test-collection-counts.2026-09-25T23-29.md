# Test Collection Counts for Split Files (P0-T13)

Timestamp: 2026-09-26T19-39

Command: poetry run pytest --collect-only -q tests/scripts/dev_tools/test_collect_pr_context.py
EXIT_CODE: 0
Command: poetry run pytest --collect-only -q tests/scripts/dev_tools/test_collect_pr_context_part4.py
EXIT_CODE: 0
Command: poetry run pytest --collect-only -q tests/scripts/dev_tools/test_render.py
EXIT_CODE: 0

Output Summary:
- N_cpc = 21 (`21 tests collected`) for tests/scripts/dev_tools/test_collect_pr_context.py
- N_p4 = 5 (`5 tests collected`) for tests/scripts/dev_tools/test_collect_pr_context_part4.py
- N_render = 58 (`58 tests collected`) for tests/scripts/dev_tools/test_render.py (13 of them in class TestResolveFeatureDir)
