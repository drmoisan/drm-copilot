# rc2 Baseline Docstring F5 (P0-T15)

Timestamp: 2026-10-16T02-57
Command: poetry run python -c "import ast, pathlib; m = ast.parse(pathlib.Path('tests/scripts/dev_tools/npm_token_guard_test_support.py').read_text(encoding='utf-8')); f = next(n for n in m.body if isinstance(n, ast.FunctionDef) and n.name == 'find_npm_token_assignments'); d = ' '.join((ast.get_docstring(f) or '').replace(chr(96), '').split()); print(*[t in d for t in ('an +== sequence', 'a +== sequence', 'an == comparison')])"
EXIT_CODE: 0
Output Summary: True False True
