# Fail-Before Run (P1-T5) [expect-fail]

Timestamp: 2026-09-27T10-17
ExpectedExitCode: 1
Command: npx --yes bats --print-output-on-failure tests/shell/test_cleanup_worktrees_scan_helper.bats
EXIT_CODE: 1
Output Summary: 3 tests; 1 not ok (test 1, the drive-letter regression test), 2 ok. The failed line is the assertion `[[ "$output" == *"/wt_drive|1|1|"?* ]]` and the printed output is a record ending `/wt_drive|1|0|1.0K`, reproducing the issue #706 false positive in the record shape `scan_registration_loss` consumes. `scripts/bash/cleanup_worktrees_scan_helper.sh` was unmodified at the time of the run.

TAP output (verbatim; the worktree path prefix is replaced by `<REPO_ROOT>`):

```text
1..3
ok 1 scan-dirs emits has_gitfile/target_exists/size for each candidate directory
not ok 2 scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory
# (in test file tests/shell/test_cleanup_worktrees_scan_helper.bats, line 50)
#   `[[ "$output" == *"/wt_drive|1|1|"?* ]]' failed
# Last output:
# <REPO_ROOT>/tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive|1|0|1.0K
ok 3 scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist
```

not ok count: 1 (names test 1: `scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory`).
