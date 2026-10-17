# rc2 Regex Unchanged (P2-T15)

Timestamp: 2026-10-16T03-09
Command: poetry run python -c "import hashlib, importlib.util as u; s = u.spec_from_file_location('guard', 'tests/scripts/dev_tools/npm_token_guard_test_support.py'); m = u.module_from_spec(s); s.loader.exec_module(m); p = m._NPM_TOKEN_ASSIGNMENT; print(hashlib.sha256(p.pattern.encode('utf-8')).hexdigest(), int(p.flags))"
EXIT_CODE: 0
Output Summary: bc428627fe0eef814c8a5779810079c99295acb66d8f9e03d80a1f7e35d8d445 34 (D4 holds)
BaselineRegexArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-regex.2026-10-16T02-57.md
