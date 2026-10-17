# rc1 Baseline Regex Digest (P0-T20)

Timestamp: 2026-10-16T01-37
Command: poetry run python -c "import hashlib, importlib.util as u; s = u.spec_from_file_location('guard', 'tests/scripts/dev_tools/npm_token_guard_test_support.py'); m = u.module_from_spec(s); s.loader.exec_module(m); p = m._NPM_TOKEN_ASSIGNMENT; print(hashlib.sha256(p.pattern.encode('utf-8')).hexdigest(), int(p.flags))"
EXIT_CODE: 0
Output Summary: bc428627fe0eef814c8a5779810079c99295acb66d8f9e03d80a1f7e35d8d445 34
BaselinePatternDigest: bc428627fe0eef814c8a5779810079c99295acb66d8f9e03d80a1f7e35d8d445
BaselinePatternFlags: 34
