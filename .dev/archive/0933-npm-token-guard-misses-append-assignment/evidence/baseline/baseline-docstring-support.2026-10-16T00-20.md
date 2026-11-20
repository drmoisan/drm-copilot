# baseline-docstring-support

Timestamp: 2026-10-16T00-20
Command: poetry run python -c "import ast, pathlib; m = ast.parse(pathlib.Path('tests/scripts/dev_tools/npm_token_guard_test_support.py').read_text(encoding='utf-8')); f = next(n for n in m.body if isinstance(n, ast.FunctionDef) and n.name == 'find_npm_token_assignments'); d = ' '.join((ast.get_docstring(f) or '').split()); print(*[t in d for t in ('append', '+==', '#933')])"
EXIT_CODE: 0
Output Summary:

```text
False False False
```
