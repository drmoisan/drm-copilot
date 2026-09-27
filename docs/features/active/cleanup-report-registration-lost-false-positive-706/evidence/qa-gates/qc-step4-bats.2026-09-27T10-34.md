# QC Step 4: Local Tests (P4-T5), pass 1

Timestamp: 2026-09-27T10-34
Command: npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_seam.bats
EXIT_CODE: 0
Output Summary: 17 tests, 17 ok, 0 not ok. Tests 1 through 4 and the existing scan-dirs test pass; the not ok set is empty (both P0-T11 and P0-T12 baseline failure sets are empty).

TAP output:

```text
1..17
ok 1 scan-dirs emits has_gitfile/target_exists/size for each candidate directory
ok 2 scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory
ok 3 scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist
ok 4 scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths
ok 5 scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths
ok 6 scan_stale_refs emits STALE_REF for a remote-tracking ref with no configured remote
ok 7 scan_stale_refs emits nothing when the remote exists
ok 8 scan_orphan_dirs emits ORPHAN_DIR for an unregistered, .git-less directory
ok 9 scan_orphan_dirs emits nothing for a registered worktree directory
ok 10 scan_registration_loss emits WARN|registration-lost for a broken gitdir pointer
ok 11 scan_registration_loss emits nothing when the gitdir pointer resolves
ok 12 cleanup_wt_scan_roots derives both roots from the main worktree path
ok 13 cleanup_wt_scan_roots honors the CLEANUP_WT_ORPHAN_ROOTS override
ok 14 cleanup_wt_scan_roots emits no root when the worktree listing hard-fails
ok 15 run_report performs exactly one filesystem scan
ok 16 cleanup_wt_scan_bin honors an executable CLEANUP_WT_SCAN_BIN override
ok 17 cleanup_wt_scan_bin falls back to the bundled scan helper when unset
```
