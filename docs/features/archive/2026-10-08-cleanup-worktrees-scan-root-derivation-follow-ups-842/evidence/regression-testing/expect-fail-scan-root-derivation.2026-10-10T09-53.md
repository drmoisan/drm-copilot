# P1-T7 [expect-fail] new suite before any production edit

Timestamp: 2026-10-10T09-53
Command: git status --porcelain --untracked-files=all -- .claude/skills extensions; npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_scan_roots.bats
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- git status over .claude/skills and extensions: no output, exit 0 (no production file or mirror changed yet).
- bats exit 1; plan line 1..21; exactly 3 `not ok` lines (17, 18, 19); ok for tests 1-16, 20, 21.
- not ok 17 = T1, not ok 18 = T2, not ok 19 = T3. Pass/fail split matches the acceptance condition.

Full TAP output:
1..21
ok 1 cleanup_wt_scan_roots appends registration-derived parents after the default pair
ok 2 cleanup_wt_scan_roots excludes the main worktree, its ancestors, and paths equal to or inside a registered worktree
ok 3 cleanup_wt_scan_roots appends derived roots after the override roots
ok 4 cleanup_wt_scan_roots emits exactly the override roots when the worktree listing hard-fails
ok 5 CLEANUP_WT_ORPHAN_ROOTS keeps a drive-letter root whole
ok 6 CLEANUP_WT_ORPHAN_ROOTS splits colon-separated drive-letter roots
ok 7 CLEANUP_WT_ORPHAN_ROOTS splits on semicolons
ok 8 CLEANUP_WT_ORPHAN_ROOTS splits on newlines
ok 9 CLEANUP_WT_ORPHAN_ROOTS drops empty segments
ok 10 CLEANUP_WT_ORPHAN_ROOTS keeps a glob character literally
ok 11 CLEANUP_WT_ORPHAN_ROOTS drops a relative segment with a stderr diagnostic
ok 12 run_report passes a registration-derived root to its single filesystem scan
ok 13 cleanup_wt_is_absolute_path returns 0 for slash-leading and drive-letter paths
ok 14 cleanup_wt_is_absolute_path returns non-zero for relative, drive-relative, and empty paths
ok 15 preserve_relative_path_reason honors an override of the shared absolute-path predicate
ok 16 preserve_relative_path_reason rejects a drive-letter source_path as absolute
not ok 17 cleanup_wt_derive_scan_roots drops a drive-relative parent for a registration directly under another drive root
# (in test file tests/shell/test_cleanup_worktrees_scan_roots.bats, line 256)
#   `[ "${#lines[@]}" -eq 1 ]' failed
not ok 18 cleanup_wt_scan_roots does not emit a drive-relative root for a D:/wt registration
# (in test file tests/shell/test_cleanup_worktrees_scan_roots.bats, line 265)
#   `[ "${#lines[@]}" -eq 3 ]' failed
not ok 19 run_report passes no drive-relative root to its single filesystem scan
# (in test file tests/shell/test_cleanup_worktrees_scan_roots.bats, line 285)
#   `[ "$argv_lines" -eq 1 ]' failed
ok 20 cleanup_wt_derive_scan_roots converts a backslash registration path before taking its parent
ok 21 cleanup_wt_scan_roots emits forward-slash roots for backslash registrations
