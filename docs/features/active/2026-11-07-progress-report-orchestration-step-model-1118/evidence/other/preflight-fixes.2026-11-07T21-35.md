# Preflight Fixes

Timestamp: 2026-11-07T21-35
Plan: docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/plan.2026-11-07T15-48.md

## Fixes

- [P7-T1] | path wording | The task formatted "`SKILLDIR`, `TESTDIR`, and their bundle copies", but `TESTDIR` has no bundle copy (test files are not bundled; the bundle holds only `BUNDLE/.claude/skills/epic-progress-report/`). The text now names the bundle copy of `SKILLDIR` only. The set of formatted files and the acceptance condition are unchanged.

## Substantive defects returned (not fixed in place)

- [P5-T2] and [P5-T3] | wrong file set and file-size gate gap | `TESTDIR/Get-EpicProgressReport.Tests.ps1` has 587 lines. The two tasks add 11 new `It` cases, item-checkpoint fixtures, and longer Full goldens (two copies) to this file, which places it near or above the 800-line hard limit that `.claude/hooks/enforce-file-size-limit.ps1` and `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` enforce for test files. The P7-T7 verdict gates production files only.
- [P1-T1] or [P2-T3] | acceptance criterion without a test | The spec and user-story criterion on blockage requires that "a zero tick rate" does not mark an item blocked. No named `It` case asserts it.
