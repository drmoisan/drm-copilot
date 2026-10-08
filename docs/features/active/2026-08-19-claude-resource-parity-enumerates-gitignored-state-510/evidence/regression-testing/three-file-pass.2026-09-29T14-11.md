# P3-T5 Three-file pytest run

Timestamp: 2026-10-07T11-07
Command: poetry run --directory <worktree> pytest -p no:cacheprovider --rootdir=<worktree> -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_payload_scope_support.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py
EXIT_CODE: 0
Output Summary: `38 passed in 0.35s`; no FAILED or ERROR line. Run executed after the final Black/Ruff pass on the contracts file (Black stable: `1 file left unchanged`).
.claude/state files present: 0

Key PASSED lines (verbatim):
- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED [  5%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_state_file_from_issue_report_is_excluded PASSED [ 39%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_nested_state_paths_are_excluded PASSED [ 42%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_worktrees_paths_are_excluded PASSED [ 44%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_agent_memory_paths_remain_excluded PASSED [ 47%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_settings_local_json_remains_excluded PASSED [ 50%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained0] PASSED [ 52%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained1] PASSED [ 55%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained2] PASSED [ 57%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained3] PASSED [ 60%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained4] PASSED [ 63%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_filter_preserves_order_and_returns_list PASSED [ 65%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_missing_tracked_file_is_still_reported PASSED [ 68%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_subdirs_match_frontmatter_excluded_subdirs PASSED [ 71%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_single_part_claude_path_is_retained PASSED [ 73%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_bare_state_path_without_child_is_excluded PASSED [ 76%]
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_empty_input_returns_empty_list PASSED [ 78%]

All 16 helper tests PASSED (12 test functions, one parametrized x5). The other 22 tests in the contracts and frontmatter files also PASSED (14 + 8 minus the 16 above gives 38 total: 14 contracts, 16 helper, 8 frontmatter).
