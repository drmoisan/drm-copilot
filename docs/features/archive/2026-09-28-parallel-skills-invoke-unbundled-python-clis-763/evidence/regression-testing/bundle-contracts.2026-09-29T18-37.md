# Python Bundle Contract Tests (P5-T12)

Timestamp: 2026-09-29T18-37
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `1 failed, 16 passed in 0.27s`
- KL-510: STATE-ONLY
  - The only FAILED node is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, with
    the assertion message
    `Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a90ad325ab30cb89c-bcb36b66.json`
    (first two path components `.claude` and `state`: a gitignored batch-budget state file written by
    the PreToolUse hook during this session).
  - No output line contains `Bundle content differs from repo for:` (count 0).
- Every other node PASSED (16), including:
  - `test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest`
  - `test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest`
  - `test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources`
  - the 13 other `test_push_down_claude_resource_contracts.py` nodes
