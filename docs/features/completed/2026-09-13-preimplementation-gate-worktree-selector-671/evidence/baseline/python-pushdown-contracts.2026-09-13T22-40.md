# Baseline — Python Push-Down Contract Tests (issue #671)

Timestamp: 2026-09-17T08-02
Task: [P0-T9]
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -v -p no:cacheprovider --no-cov (run from the worktree root via a scratchpad `sh` wrapper)
EXIT_CODE: 0

Output Summary:
- 16 collected; passed=16; failed=0 ("16 passed in 0.29s").
- `test_push_down_claude_resource_contracts.py`: 14 passed, including `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- `test_push_down_claude_pack_manifest_completeness.py`: 2 passed.
- `--no-cov` was supplied because this run measures pass/fail only; no Python file is in scope for coverage.
