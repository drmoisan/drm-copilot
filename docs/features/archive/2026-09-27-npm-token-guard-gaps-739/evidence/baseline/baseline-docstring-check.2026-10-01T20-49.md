# Baseline: module docstring probe (P0-T15)

Timestamp: 2026-10-01T20-49
Command: poetry run python -c "import ast, pathlib; d = ' '.join((ast.get_docstring(ast.parse(pathlib.Path('tests/scripts/dev_tools/test_workflow_npm_token_guard.py').read_text(encoding='utf-8'))) or '').split()); print(*[t in d for t in ('tracked files', 'enumerated and read from disk', 'whether or not version control tracks them', 'secret or variable', 'NODE_AUTH_TOKEN', '_authToken', 'assignment')])"
EXIT_CODE: 0
Output Summary: True False False False True False False (matches the expected baseline line)
