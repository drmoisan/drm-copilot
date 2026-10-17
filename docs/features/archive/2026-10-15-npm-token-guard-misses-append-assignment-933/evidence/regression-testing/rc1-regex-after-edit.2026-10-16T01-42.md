# rc1 Regex After Edit (P1-T7)

Timestamp: 2026-10-16T01-42
Command: poetry run python -c "import hashlib, importlib.util as u; s = u.spec_from_file_location('guard', 'tests/scripts/dev_tools/npm_token_guard_test_support.py'); m = u.module_from_spec(s); s.loader.exec_module(m); p = m._NPM_TOKEN_ASSIGNMENT; print(hashlib.sha256(p.pattern.encode('utf-8')).hexdigest(), int(p.flags))"
EXIT_CODE: 0
Output Summary: bc428627fe0eef814c8a5779810079c99295acb66d8f9e03d80a1f7e35d8d445 34
BaselineRegexArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc1-baseline-regex.2026-10-16T01-37.md
Result: output line is byte-identical to the P0-T20 baseline line (same digest, flags 34). D4 holds after the support-module docstring edit.
