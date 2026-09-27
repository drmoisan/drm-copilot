# CI Failure Count (P4-T11)

Timestamp: 2026-09-27T10-48
RUN_ID: 36326020967
ExpectedExitCode: 1
Command: gh run view 36326020967 --log | grep -c -E ' not ok [0-9]+ '
EXIT_CODE: 1
Output Summary: 0. No failing test anywhere in the CI suite, which includes tests/shell/test_cleanup_worktrees_report_records.bats unmodified.
