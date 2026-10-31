# Baseline Python Contract Tests (Issue #1010, remediation cycle 1, P0-T6)

Timestamp: 2026-10-30T22-16
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary: 45 passed, 0 failed in 0.98s (one invocation over the five contract files).
