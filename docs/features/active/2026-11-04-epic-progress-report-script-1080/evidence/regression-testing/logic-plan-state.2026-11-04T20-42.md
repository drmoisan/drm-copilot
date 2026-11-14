# Logic Plan and State Functions (Issue #1080, P1-T2)

Timestamp: 2026-11-04T20-42
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p1t2.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0

## Change

- Added `Get-EpicProgressTaskCount`, `Get-EpicProgressCurrentPhase`, and `Get-EpicProgressFeatureState` to `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (the recovered regexes and classification rule).
- Added the matching `Describe` blocks to `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`.

## Result

TOTAL Tests=26 Passed=26 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=26 failed=0

## Plan-named It blocks (9, all passed)

- counts checked and unchecked task checkboxes
- ignores checkboxes without a task identifier
- returns the heading of the phase holding the first unchecked task
- falls back to Phase N when no heading matches
- returns an empty string when every task is checked
- classifies merged and worktree_removed features as Completed
- classifies a feature with a MERGED pull request as Completed
- classifies a started feature as Running
- classifies an unstarted feature as Pending

Output Summary: 26 tests (17 from P1-T1 plus 9), Failed=0 for Get-EpicProgressReport.Logic.Tests.ps1; all nine plan-named It blocks pass.
