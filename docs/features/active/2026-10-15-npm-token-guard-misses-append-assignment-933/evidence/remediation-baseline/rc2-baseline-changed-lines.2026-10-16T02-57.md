# rc2 Baseline Changed Lines (P0-T20)

Timestamp: 2026-10-16T02-57
Command: poetry run python -c "import subprocess, pathlib; ps = ('docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T00-56.md', 'tests/scripts/dev_tools/npm_token_guard_test_support.py', 'tests/scripts/dev_tools/test_workflow_npm_token_guard.py'); r = [(subprocess.run(['git', 'show', '3bc4ee9d1:' + p], capture_output=True, check=True).stdout.decode('utf-8').splitlines(), pathlib.Path(p).read_text(encoding='utf-8').splitlines()) for p in ps]; print(*[(len(a), len(b), [i + 1 for i, (x, y) in enumerate(zip(a, b)) if x != y]) for a, b in r])"
EXIT_CODE: 0
Output Summary: (242, 242, []) (184, 184, []) (404, 404, [])
