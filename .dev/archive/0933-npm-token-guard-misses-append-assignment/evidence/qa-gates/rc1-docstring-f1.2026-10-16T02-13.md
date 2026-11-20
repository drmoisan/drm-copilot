# rc1 Docstring F1 Probe (P2-T11)

Timestamp: 2026-10-16T02-13
Command: poetry run python -c "import ast, pathlib; m = ast.parse(pathlib.Path('tests/scripts/dev_tools/npm_token_guard_test_support.py').read_text(encoding='utf-8')); f = next(n for n in m.body if isinstance(n, ast.FunctionDef) and n.name == 'find_npm_token_assignments'); d = ' '.join((ast.get_docstring(f) or '').split()); print(*[t in d for t in ('append', '+==', '#933', 'env.NPM_TOKEN += x', 'MY-NPM_TOKEN+=x', 'MY_NPM_TOKEN', 'without an assignment operator', 'longer or prefixed')])"
EXIT_CODE: 0
Output Summary: True True True True True True True False
BaselineArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc1-baseline-docstring-f1.2026-10-16T01-37.md
