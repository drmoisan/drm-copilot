# rc2 Line Width (P2-T17)

Timestamp: 2026-10-16T03-09
Command: poetry run python -c "import pathlib; print(*[max(len(x) for x in pathlib.Path(p).read_text(encoding='utf-8').splitlines()) for p in ('tests/scripts/dev_tools/npm_token_guard_test_support.py', 'tests/scripts/dev_tools/test_workflow_npm_token_guard.py')])"
EXIT_CODE: 0
Output Summary: 87 88
BaselineArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-line-width.2026-10-16T02-57.md
