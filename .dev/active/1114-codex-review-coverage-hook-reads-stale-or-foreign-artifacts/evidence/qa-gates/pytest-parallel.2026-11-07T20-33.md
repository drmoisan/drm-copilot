# Pytest Bundle Contract Gate (parallel) - remediation cycle 1, issue #1114

Timestamp: 2026-11-07T20-33
Command: sh SCRATCH/issue-1114-pytest2.sh (poetry run python -m pytest -n auto -v -p no:cacheprovider --no-cov tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py)
EXIT_CODE: 0
Output Summary:
- 11 passed, 0 failed (3.53 s). No coverage was collected because no Python file is in scope.
- `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` PASSED.
- `test_bundled_codex_files_are_listed_in_some_pack_manifest` PASSED.
- The pre-cycle pytest artifact (evidence/qa-gates/pytest-parallel.2026-11-07T19-50.md) records both as passed.
