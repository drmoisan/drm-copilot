# Baseline Local Test Step: report records and scan seam (P0-T12)

Timestamp: 2026-09-27T10-03
Command: npx --yes bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_seam.bats
EXIT_CODE: 0
Output Summary: 12 tests, 12 ok, 0 not ok. Baseline failure set: empty.

Full TAP output:

```text
1..12
ok 1 scan_stale_refs emits STALE_REF for a remote-tracking ref with no configured remote
ok 2 scan_stale_refs emits nothing when the remote exists
ok 3 scan_orphan_dirs emits ORPHAN_DIR for an unregistered, .git-less directory
ok 4 scan_orphan_dirs emits nothing for a registered worktree directory
ok 5 scan_registration_loss emits WARN|registration-lost for a broken gitdir pointer
ok 6 scan_registration_loss emits nothing when the gitdir pointer resolves
ok 7 cleanup_wt_scan_roots derives both roots from the main worktree path
ok 8 cleanup_wt_scan_roots honors the CLEANUP_WT_ORPHAN_ROOTS override
ok 9 cleanup_wt_scan_roots emits no root when the worktree listing hard-fails
ok 10 run_report performs exactly one filesystem scan
ok 11 cleanup_wt_scan_bin honors an executable CLEANUP_WT_SCAN_BIN override
ok 12 cleanup_wt_scan_bin falls back to the bundled scan helper when unset
```

Names of not ok tests: none
