Timestamp: 2026-10-07T00-00
Command: poetry run --directory <worktree> pytest tests/scripts/dev_tools/test_claude_payload_scope_support.py -v -p no:cacheprovider --rootdir=<worktree> --no-cov
EXIT_CODE: 0
Output Summary: 16 passed in 0.09s. All node IDs below show PASSED. (`--no-cov` added only to suppress the project addopts coverage reporter for a clean verbose listing.)

tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_state_file_from_issue_report_is_excluded PASSED [  6%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_nested_state_paths_are_excluded PASSED [ 12%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_worktrees_paths_are_excluded PASSED [ 18%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_agent_memory_paths_remain_excluded PASSED [ 25%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_settings_local_json_remains_excluded PASSED [ 31%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained0] PASSED [ 37%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained1] PASSED [ 43%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained2] PASSED [ 50%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained3] PASSED [ 56%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained[retained4] PASSED [ 62%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_filter_preserves_order_and_returns_list PASSED [ 68%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_missing_tracked_file_is_still_reported PASSED [ 75%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_subdirs_match_frontmatter_excluded_subdirs PASSED [ 81%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_single_part_claude_path_is_retained PASSED [ 87%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_bare_state_path_without_child_is_excluded PASSED [ 93%]
tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_empty_input_returns_empty_list PASSED [100%]

Note: after this run, Black reformatting and two Ruff fixes (TC003 type-checking import, E501 docstring length) were applied to the new helper and test files; a rerun of the three affected test files afterward reported 38 passed (22 baseline + 16 new).
