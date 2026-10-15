# P2-T1 [expect-fail] - Python RED-SET against unfixed production code

Timestamp: 2026-10-10T08-15
Command: git status --porcelain -- scripts/dev_tools extensions/drm-copilot/src; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- git status --porcelain (scripts/dev_tools, extensions/drm-copilot/src): EXIT 0, printed nothing (no production file changed).
- pytest: EXIT 1, `collected 76 items`, summary `37 failed, 39 passed in 0.51s` (planned: exactly 37 failed, 39 passed). No collection error.
- Failure causes observed: 17 x `ModuleNotFoundError: No module named 'scripts.dev_tools.push_down_claude_gitignore_merge'` (16 merge tests + `test_gitignore_merge_fixture_parity`); `AssertionError: extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts: found zero LOCAL_RUNTIME_RELATIVE_DIRECTORIES declarations`; 3 x `AttributeError: module 'scripts.dev_tools.push_down_claude_pack_selection' has no attribute 'resolve_published_paths'`; delivery D1-D9, D11-D14 and F1-F3 fail by assertion/lookup (no `.gitignore` write, no skip record, runtime paths still listed).
- Passing set (39): D10 `test_destination_validation_failure_writes_no_gitignore`; F4, F5, F6; `test_local_runtime_directories_comparison_detects_divergence`; 34 pre-existing tests (8 customizations + 10 parity + 16 pack selection).
- FAILED lines of the -ra summary (37), verbatim:
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_constants_match_typescript_values
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_absent_input_returns_bare_block
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_appends_block_after_one_blank_line
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_replaces_stale_block_in_place
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_up_to_date_block_is_fixed_point
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_is_idempotent
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_input_without_trailing_newline
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_normalizes_crlf_input
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_normalizes_lone_cr_input
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_blank_only_input_returns_bare_block
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_strips_multiple_trailing_blank_lines_before_append
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_begin_without_end_keeps_later_lines
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_ignores_end_before_begin
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_keeps_managed_entry_duplicated_outside_block
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_sentinel_with_trailing_whitespace_does_not_match
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py::test_merge_considers_only_first_begin_sentinel
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_unscoped_push_down_writes_block_into_absent_gitignore
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_pack_scoped_push_down_writes_block_into_gitignore
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_push_down_preserves_unrelated_gitignore_lines_in_order
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_second_push_down_performs_no_gitignore_write
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_manifest_skip_with_absent_gitignore_reads_and_writes_nothing
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_manifest_skip_with_present_gitignore_keeps_bytes
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_gitignore_skip_follows_enumeration_skips_in_artifact
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_exclusion_lines_report_gitignore_skip_after_enumeration_skip
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_gitignore_delivery_follows_summary_artifact_write
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_gitignore_write_is_absent_from_summary_files_and_counts
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_gitignore_written_through_raw_fs_with_active_manifest
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_crlf_up_to_date_gitignore_is_not_rewritten
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py::test_crlf_stale_gitignore_is_rewritten_lf_only
  - FAILED tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py::test_gitignore_merge_fixture_parity
  - FAILED tests/scripts/dev_tools/test_push_down_claude_customizations.py::test_excluding_file_system_list_files_drops_local_runtime_directories
  - FAILED tests/scripts/dev_tools/test_push_down_claude_customizations.py::test_list_files_drops_runtime_paths_even_when_published
  - FAILED tests/scripts/dev_tools/test_push_down_claude_customizations.py::test_push_down_excludes_claude_state_and_worktrees_subtrees
  - FAILED tests/scripts/dev_tools/test_push_down_claude_parity.py::test_local_runtime_directories_match_typescript
  - FAILED tests/scripts/dev_tools/test_push_down_claude_pack_selection.py::test_resolve_published_paths_returns_none_without_selection
  - FAILED tests/scripts/dev_tools/test_push_down_claude_pack_selection.py::test_resolve_published_paths_unions_selected_pack_with_core
  - FAILED tests/scripts/dev_tools/test_push_down_claude_pack_selection.py::test_resolve_published_paths_rejects_both_csharp_variants
- Result: PASS (planned red split observed exactly).
