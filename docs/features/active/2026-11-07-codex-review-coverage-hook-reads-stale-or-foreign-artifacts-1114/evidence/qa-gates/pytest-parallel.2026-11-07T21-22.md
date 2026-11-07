# Pytest Bundle Contract Gate (parallel) - remediation cycle 2, issue #1114

Timestamp: 2026-11-07T21-22
Command: sh SCRATCH/issue-1114-pytest-c2.sh (poetry run python -m pytest -n auto -v -p no:cacheprovider --no-cov tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py; no coverage because no Python file is in scope)
EXIT_CODE: 0
Output Summary:
- 11 passed, 0 failed, 0 errors in 3.84s.
- `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` PASSED and `test_bundled_codex_files_are_listed_in_some_pack_manifest` PASSED, as in the cycle 1 pytest artifact (pytest-parallel.2026-11-07T20-33.md).
