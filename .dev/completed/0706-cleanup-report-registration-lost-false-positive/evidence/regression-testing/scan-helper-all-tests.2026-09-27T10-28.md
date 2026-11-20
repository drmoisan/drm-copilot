# Scan Helper All Tests (P3-T3)

Timestamp: 2026-09-27T10-28
Command: npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats
EXIT_CODE: 0
Output Summary: 5 tests, 5 ok, 0 not ok. Tests 1 through 4 and the existing scan-dirs test all pass.

TAP output:

```text
1..5
ok 1 scan-dirs emits has_gitfile/target_exists/size for each candidate directory
ok 2 scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory
ok 3 scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist
ok 4 scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths
ok 5 scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths
```
