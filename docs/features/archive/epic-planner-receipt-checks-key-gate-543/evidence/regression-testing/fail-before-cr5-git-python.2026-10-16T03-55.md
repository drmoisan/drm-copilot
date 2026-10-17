# Fail-Before CR-5 Python Git Integrity (P1-T6) [expect-fail]

Timestamp: 2026-10-16T03-55
Command: poetry run pytest tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py -vv (output redirected to SCRATCH/rc1/py-git-fail-before.txt)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Result: 2 failed, 4 passed in 0.13s (pre-fix production code)
- FAILED test_planning_commit_prefix_uses_original_index_after_non_object_entry
- FAILED test_planning_commit_prefix_uses_original_index_after_planless_entry
- PASSED test_planning_commit_prefix_unchanged_without_skipped_entries
- PASSED test_planning_commit_prefix_keeps_positional_pairing_without_plan_paths
- PASSED test_plans_without_object_entries_report_no_feature_error[empty]
- PASSED test_plans_without_object_entries_report_no_feature_error[not-list]
- First failure assertion-diff line (compacted index):
  E         At index 0 diff: 'Epic planner checkpoint features[1].planning_commit must be hexadecimal.' != 'Epic planner checkpoint features[2].planning_commit must be hexadecimal.'
- Second failure left-hand value: `assert [] == ['Epic planner checkpoint features[1].planning_commit must be hexadecimal.']` (the entry at the compacted position carries no planning_commit)
- Both failures are AssertionErrors; no import, collection, or fixture error.
