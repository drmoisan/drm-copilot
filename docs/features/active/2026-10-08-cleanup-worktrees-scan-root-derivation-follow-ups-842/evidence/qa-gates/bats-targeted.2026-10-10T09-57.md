# P2-T3 final-QC local bats run over TARGETED-SET

Timestamp: 2026-10-10T09-57
Command: npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_scan_roots.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_scan_seam.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_detached.bats
EXIT_CODE: 0
Output Summary: plan line `1..85` (M=85 equals BASELINE_N 80 plus 5: met); 85 `ok` lines; 0 `not ok` lines, so no failure from the three gating suites and none outside the P0-T9 baseline failure set (which was empty). The run exceeded the 120 s foreground limit and completed as a background task. The five new tests in tests/shell/test_cleanup_worktrees_scan_roots.bats:
- ok 17 cleanup_wt_derive_scan_roots drops a drive-relative parent for a registration directly under another drive root (T1; not ok 17 in P1-T7)
- ok 18 cleanup_wt_scan_roots does not emit a drive-relative root for a D:/wt registration (T2; not ok 18 in P1-T7)
- ok 19 run_report passes no drive-relative root to its single filesystem scan (T3; not ok 19 in P1-T7)
- ok 20 cleanup_wt_derive_scan_roots converts a backslash registration path before taking its parent (T4)
- ok 21 cleanup_wt_scan_roots emits forward-slash roots for backslash registrations (T5)
