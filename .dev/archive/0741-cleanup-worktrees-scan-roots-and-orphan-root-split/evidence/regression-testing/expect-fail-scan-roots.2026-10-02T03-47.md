# P1-T4 [expect-fail] NEW-SUITE before any production edit (CI-sourced; DEV-2)

Timestamp: 2026-10-02T03-47
Command: `git status --porcelain -- .claude/skills/cleanup-merged-worktrees` (local); CI `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741` (orchestrator, dispatched 2026-10-02T07:39:14Z UTC) running `scripts/bash/shell-qc.sh test --coverage`, which includes `tests/shell/test_cleanup_worktrees_scan_roots.bats`. The plan command `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_scan_roots.bats` was not run locally (DEV-2).
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Local `git status --porcelain -- .claude/skills/cleanup-merged-worktrees`: printed nothing, exit 0 (no production file changed; HEAD 48c6023d carries NEW-SUITE and the scan_roots_derived fixture only).
- CI run https://github.com/drmoisan/drm-copilot/actions/runs/36979697644 ; job https://github.com/drmoisan/drm-copilot/actions/runs/36979697644/job/110751206291 ; headSha 48c6023d2aa4172eb4c5ff6642e22e7364a737d4 ; conclusion failure. EXIT_CODE 1 above is the job failure.
- Plan line `1..523` (507 baseline + 16 NEW-SUITE). NEW-SUITE occupies TAP numbers 457-472, in file order T1..T16 (verified against the `@test` order in the file).
- `not ok` lines (14; all in NEW-SUITE; none in any other suite):
  - not ok 457 cleanup_wt_scan_roots appends registration-derived parents after the default pair (T1)
  - not ok 458 cleanup_wt_scan_roots excludes the main worktree, its ancestors, and paths equal to or inside a registered worktree (T2)
  - not ok 459 cleanup_wt_scan_roots appends derived roots after the override roots (T3)
  - not ok 461 CLEANUP_WT_ORPHAN_ROOTS keeps a drive-letter root whole (T5)
  - not ok 462 CLEANUP_WT_ORPHAN_ROOTS splits colon-separated drive-letter roots (T6)
  - not ok 463 CLEANUP_WT_ORPHAN_ROOTS splits on semicolons (T7)
  - not ok 464 CLEANUP_WT_ORPHAN_ROOTS splits on newlines (T8)
  - not ok 465 CLEANUP_WT_ORPHAN_ROOTS drops empty segments (T9)
  - not ok 466 CLEANUP_WT_ORPHAN_ROOTS keeps a glob character literally (T10)
  - not ok 467 CLEANUP_WT_ORPHAN_ROOTS drops a relative segment with a stderr diagnostic (T11)
  - not ok 468 run_report passes a registration-derived root to its single filesystem scan (T12)
  - not ok 469 cleanup_wt_is_absolute_path returns 0 for slash-leading and drive-letter paths (T13)
  - not ok 470 cleanup_wt_is_absolute_path returns non-zero for relative, drive-relative, and empty paths (T14)
  - not ok 471 preserve_relative_path_reason honors an override of the shared absolute-path predicate (T15)
- `ok` NEW-SUITE lines: ok 460 cleanup_wt_scan_roots emits exactly the override roots when the worktree listing hard-fails (T4); ok 472 preserve_relative_path_reason rejects a drive-letter source_path as absolute (T16).
- Comparison with P1-T4 acceptance: the failing set (T1, T2, T3, T5-T15) and the passing set (T4, T16) match the plan exactly. No failing-set deviation.
- Deviations from the task text (form only, not outcome): (a) DEV-2: bats ran in CI, not locally; (b) the observed plan line is `1..523` for the whole CI set rather than `1..16` for NEW-SUITE alone; the NEW-SUITE slice is 16 tests (457-472). Neither affects the fail-before obligation for AC-1, AC-2, AC-5, AC-6, or AC-7, because each mapped test failed before the fix; T4 (AC-4) and T16 (AC-7) pass before the fix by design as regression guards.
- Full TAP output is held in the CI job log above; this artifact records every NEW-SUITE line and the `not ok` lines of the whole run as supplied by the orchestrator's log readout.
