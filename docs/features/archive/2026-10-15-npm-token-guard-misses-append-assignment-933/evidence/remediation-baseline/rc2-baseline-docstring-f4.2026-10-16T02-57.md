# rc2 Baseline Docstring F4 (P0-T14)

Timestamp: 2026-10-16T02-57
Command: poetry run python -c "import ast, pathlib; m = ast.parse(pathlib.Path('tests/scripts/dev_tools/test_workflow_npm_token_guard.py').read_text(encoding='utf-8')); f = next(n for n in m.body if isinstance(n, ast.FunctionDef) and n.name == 'test_find_npm_token_assignments_ignores_non_matching_text'); d = ' '.join((ast.get_docstring(f) or '').replace(chr(96), '').split()); print(*[t in d for t in ('reads but does not assign', 'no assignment operator applied to NPM_TOKEN', 'is not reported')])"
EXIT_CODE: 0
Output Summary: True False True
