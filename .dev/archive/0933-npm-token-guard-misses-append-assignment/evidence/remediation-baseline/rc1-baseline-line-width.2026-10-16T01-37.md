# rc1 Baseline Line Width (P0-T22)

Timestamp: 2026-10-16T01-37
Command: poetry run python -c "import pathlib; print(*[max(len(x) for x in pathlib.Path(p).read_text(encoding='utf-8').splitlines()) for p in ('tests/scripts/dev_tools/npm_token_guard_test_support.py', 'tests/scripts/dev_tools/test_workflow_npm_token_guard.py')])"
EXIT_CODE: 0
Output Summary: 87 88
