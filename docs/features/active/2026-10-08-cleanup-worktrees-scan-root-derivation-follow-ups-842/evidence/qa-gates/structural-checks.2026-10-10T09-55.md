# P2-T7 structural checks (AC-1 through AC-5)

Timestamp: 2026-10-10T09-55
Command: twelve plain grep commands, run in the order (1) through (12) of the P2-T7 task text over the enumerate library, scan helper, detached library, scan-roots bats suite, and the two fixtures (no git grep).
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: the top-level EXIT_CODE is the last grep's exit code (1, the pass condition). All twelve results match the acceptance conditions.
- (1) GREP value=1 exit=0 (new code line count in enumerate_lib).
- (2) GREP exit=0; lines: `350:` guard line (G=350), `352:` `cleanup_wt_is_absolute_path "$parent" || continue` (G+2), `353:` `n=$(normalize_wt_path "$parent")` (G+3).
- (3) GREP exit=0; lines: `44:` reason (`SC1091 is the expected, benign result.`), `45:` `shellcheck source=` directive, `46:` `shellcheck disable=SC1091` directive.
- (4) GREP value=0 exit=1 (stale `enumerate_lib.sh:115` line range removed).
- (5) GREP value=1 exit=0 (`emit_record, nested in parse_worktree_list` present).
- (6) GREP value=21 exit=0 (`@test` count in test_cleanup_worktrees_scan_roots.bats).
- (7) GREP value=1 exit=0 (T1 name).
- (8) GREP value=1 exit=0 (T2 name).
- (9) GREP value=1 exit=0 (T4 name).
- (10) GREP value=1 exit=0 (T5 name).
- (11) GREP value=0 exit=1 (no CR byte in scan_roots_drive_relative fixture).
- (12) GREP value=0 exit=1 (no CR byte in scan_roots_backslash fixture).
