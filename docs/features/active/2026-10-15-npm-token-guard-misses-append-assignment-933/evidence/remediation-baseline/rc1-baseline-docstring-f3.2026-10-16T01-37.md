# rc1 Baseline Docstring Probe F3 (P0-T18)

Timestamp: 2026-10-16T01-37
Command: poetry run python -c "import ast, pathlib; m = ast.parse(pathlib.Path('tests/scripts/dev_tools/test_workflow_npm_token_guard.py').read_text(encoding='utf-8')); f = next(n for n in m.body if isinstance(n, ast.FunctionDef) and n.name == 'test_find_npm_token_assignments_pins_documented_residuals'); d = ' '.join((ast.get_docstring(f) or '').split()); print(*[t in d for t in ('#933 reversed', 'remain reported', 'pin the current behavior', 'existing')])"
EXIT_CODE: 0
Output Summary: True True False True
