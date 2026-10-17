# P1-T14 pass-after gate over TARGETED-SET

Timestamp: 2026-10-10T10-01
Command: npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_scan_roots.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_scan_seam.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_detached.bats
EXIT_CODE: 0
Output Summary:
- TAP plan line: 1..85 (M = BASELINE_N 80 + 5)
- 85 ok lines, 0 not ok lines (P0-T9 baseline failure set was empty)
- All 21 tests of test_cleanup_worktrees_scan_roots.bats print ok.
- The 3 P1-T7 failures and their new ok lines:
  - was not ok 17 -> now: ok 17 cleanup_wt_derive_scan_roots drops a drive-relative parent for a registration directly under another drive root
  - was not ok 18 -> now: ok 18 cleanup_wt_scan_roots does not emit a drive-relative root for a D:/wt registration
  - was not ok 19 -> now: ok 19 run_report passes no drive-relative root to its single filesystem scan
- ok 20 and ok 21 (backslash tests T4, T5) unchanged from P1-T7.
