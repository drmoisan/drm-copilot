# rc1 Baseline Characterization Probe (P0-T19)

Timestamp: 2026-10-16T01-37
Command: poetry run python -c "import importlib.util as u; s = u.spec_from_file_location('guard', 'tests/scripts/dev_tools/npm_token_guard_test_support.py'); m = u.module_from_spec(s); s.loader.exec_module(m); print(*[m.find_npm_token_assignments(t) for t in ('env.NPM_TOKEN += x', 'MY-NPM_TOKEN+=x', '(( NPM_TOKEN += 1 ))', 'NPM_TOKEN++=x')])"
EXIT_CODE: 0
Output Summary: [1] [1] [1] []
Each of the four new rows passes against the unchanged regex (three report line 1; NPM_TOKEN++=x reports nothing).
