# rc2 After Edit (P1-T5)

Timestamp: 2026-10-16T03-01
Command: poetry run python -c "import subprocess, pathlib; ps = ('docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T00-56.md', 'tests/scripts/dev_tools/npm_token_guard_test_support.py', 'tests/scripts/dev_tools/test_workflow_npm_token_guard.py'); r = [(subprocess.run(['git', 'show', '3bc4ee9d1:' + p], capture_output=True, check=True).stdout.decode('utf-8').splitlines(), pathlib.Path(p).read_text(encoding='utf-8').splitlines()) for p in ps]; print(*[(len(a), len(b), [i + 1 for i, (x, y) in enumerate(zip(a, b)) if x != y]) for a, b in r])"
EXIT_CODE: 0
Output Summary: (242, 242, [242]) (184, 184, [132]) (404, 404, [265])

RegexCommand: poetry run python -c "import hashlib, importlib.util as u; s = u.spec_from_file_location('guard', 'tests/scripts/dev_tools/npm_token_guard_test_support.py'); m = u.module_from_spec(s); s.loader.exec_module(m); p = m._NPM_TOKEN_ASSIGNMENT; print(hashlib.sha256(p.pattern.encode('utf-8')).hexdigest(), int(p.flags))"
RegexOutput: bc428627fe0eef814c8a5779810079c99295acb66d8f9e03d80a1f7e35d8d445 34
RegexExitCode: 0

PytestCommand: poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q
PytestOutput: 70 passed in 0.20s
PytestExitCode: 0
