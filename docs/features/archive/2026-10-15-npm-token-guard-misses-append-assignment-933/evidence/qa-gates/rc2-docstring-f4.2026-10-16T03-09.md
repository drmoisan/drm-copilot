# rc2 Docstring F4 (P2-T10)

Timestamp: 2026-10-16T03-09
Command: poetry run python -c "import ast, pathlib; m = ast.parse(pathlib.Path('tests/scripts/dev_tools/test_workflow_npm_token_guard.py').read_text(encoding='utf-8')); f = next(n for n in m.body if isinstance(n, ast.FunctionDef) and n.name == 'test_find_npm_token_assignments_ignores_non_matching_text'); d = ' '.join((ast.get_docstring(f) or '').replace(chr(96), '').split()); print(*[t in d for t in ('reads but does not assign', 'no assignment operator applied to NPM_TOKEN', 'is not reported')])"
EXIT_CODE: 0
Output Summary: False True True
BaselineArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-docstring-f4.2026-10-16T02-57.md
