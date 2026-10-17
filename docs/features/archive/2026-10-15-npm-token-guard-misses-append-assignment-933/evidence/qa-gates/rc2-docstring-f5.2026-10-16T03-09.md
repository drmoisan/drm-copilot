# rc2 Docstring F5 (P2-T11)

Timestamp: 2026-10-16T03-09
Command: poetry run python -c "import ast, pathlib; m = ast.parse(pathlib.Path('tests/scripts/dev_tools/npm_token_guard_test_support.py').read_text(encoding='utf-8')); f = next(n for n in m.body if isinstance(n, ast.FunctionDef) and n.name == 'find_npm_token_assignments'); d = ' '.join((ast.get_docstring(f) or '').replace(chr(96), '').split()); print(*[t in d for t in ('an +== sequence', 'a +== sequence', 'an == comparison')])"
EXIT_CODE: 0
Output Summary: False True True
BaselineArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-docstring-f5.2026-10-16T02-57.md
