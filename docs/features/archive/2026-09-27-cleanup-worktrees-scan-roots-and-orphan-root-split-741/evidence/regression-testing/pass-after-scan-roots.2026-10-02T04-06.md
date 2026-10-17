# P1-T18 Pass-after gate: NEW-SUITE and TARGETED-SET (CI-sourced; DEV-2, DEV-7)

Timestamp: 2026-10-02T04-06
Command: CI `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741` (orchestrator, dispatched 2026-10-02T07:59:35Z UTC) running `scripts/bash/shell-qc.sh test --coverage`, which includes NEW-SUITE and every TARGETED-SET suite. The plan command `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_scan_roots.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_scan_seam.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_failures.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats tests/shell/test_cleanup_worktrees_cli.bats` was not run locally (DEV-2).
EXIT_CODE: 0
Output Summary:
- CI run https://github.com/drmoisan/drm-copilot/actions/runs/36981519472 ; job "Shell Coverage (Bats + kcov)" https://github.com/drmoisan/drm-copilot/actions/runs/36981519472/job/110756906007 ; headSha 598691e72e2e9c0ee180c55e9678798bdbdaaf37 ; conclusion success. EXIT_CODE 0 above is the job conclusion.
- Plan line `1..521`. Expected count per DEV-5: CI N = 507 (baseline) + 16 (NEW-SUITE) - 2 (moved out of the scan-helper suite) = 521. Match.
- `not ok` lines in the whole run: 0. The P0-T9 baseline failure set (CI run 36978610292) was empty, so no `not ok` line appears outside it.
- Bash coverage (lines): 93.8% (informational here; the coverage gate is P2-T12 on FINAL_SHA).
- NEW-SUITE occupies TAP numbers 455-470 (two fewer than in P1-T4 because the scan-helper suite, which runs earlier, lost two tests). All 16 print `ok`.
- The 14 P1-T4 failures with their new `ok` lines (P1-T4 TAP number from CI run 36979697644 -> P1-T18 line):
  - T1: not ok 457 -> ok 455 cleanup_wt_scan_roots appends registration-derived parents after the default pair
  - T2: not ok 458 -> ok 456 cleanup_wt_scan_roots excludes the main worktree, its ancestors, and paths equal to or inside a registered worktree
  - T3: not ok 459 -> ok 457 cleanup_wt_scan_roots appends derived roots after the override roots
  - T5: not ok 461 -> ok 459 CLEANUP_WT_ORPHAN_ROOTS keeps a drive-letter root whole
  - T6: not ok 462 -> ok 460 CLEANUP_WT_ORPHAN_ROOTS splits colon-separated drive-letter roots
  - T7: not ok 463 -> ok 461 CLEANUP_WT_ORPHAN_ROOTS splits on semicolons
  - T8: not ok 464 -> ok 462 CLEANUP_WT_ORPHAN_ROOTS splits on newlines
  - T9: not ok 465 -> ok 463 CLEANUP_WT_ORPHAN_ROOTS drops empty segments
  - T10: not ok 466 -> ok 464 CLEANUP_WT_ORPHAN_ROOTS keeps a glob character literally
  - T11: not ok 467 -> ok 465 CLEANUP_WT_ORPHAN_ROOTS drops a relative segment with a stderr diagnostic
  - T12: not ok 468 -> ok 466 run_report passes a registration-derived root to its single filesystem scan
  - T13: not ok 469 -> ok 467 cleanup_wt_is_absolute_path returns 0 for slash-leading and drive-letter paths
  - T14: not ok 470 -> ok 468 cleanup_wt_is_absolute_path returns non-zero for relative, drive-relative, and empty paths
  - T15: not ok 471 -> ok 469 preserve_relative_path_reason honors an override of the shared absolute-path predicate
- Regression guards still passing: T4 ok 458 cleanup_wt_scan_roots emits exactly the override roots when the worktree listing hard-fails; T16 ok 470 preserve_relative_path_reason rejects a drive-letter source_path as absolute.
- Deferred bats clauses from P1-T5 through P1-T10 (DEV-5) are satisfied by this run: every test in tests/shell/test_cleanup_worktrees_report_records.bats, tests/shell/test_cleanup_worktrees_scan_helper.bats (3 tests), the preserve suites, and tests/shell/test_cleanup_worktrees_cli.bats printed `ok` (zero `not ok` in the run).
- Deviation DEV-7 (form only, not outcome): bats ran in CI on head 598691e7 rather than locally; the plan line covers the whole CI set (`1..521`) rather than NEW-SUITE plus TARGETED-SET alone. Full TAP output is held in the CI job log above; this artifact records the NEW-SUITE lines and the `not ok` count as supplied by the orchestrator's log readout.
