# Logic Velocity and Estimate Functions (Issue #1080, P1-T4)

Timestamp: 2026-11-04T20-44
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p1t4.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0

## Change

- Added `Get-EpicProgressAverageVelocity`, `Get-EpicProgressRecentVelocityInterval`, `Get-EpicProgressStandardDeviation`, `Get-EpicProgressCriticalPath`, and `Get-EpicProgressRangeText` to `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (recovered rules: 2-minute interval floor, clamp to 0, n - 1 SD with at least 3 intervals, largest remaining count per open wave, 2.05 SD range with the 0.5 tasks/hr threshold).
- Added the matching `Describe` blocks to `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`.

## Result

TOTAL Tests=48 Passed=48 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=48 failed=0

## Plan-named It blocks (11, all passed)

- returns the average velocity since the baseline
- returns zero velocity when elapsed time is zero
- skips intervals shorter than two minutes
- clamps a negative interval rate to zero
- returns NaN with fewer than three intervals
- returns the sample standard deviation of three intervals
- sums the largest remaining count of each open wave
- returns NaN hours when velocity is zero
- states that three intervals are needed
- returns a bounded range when the slow velocity exceeds 0.5
- returns the no-upper-bound wording at a slow velocity of 0.5

Output Summary: 48 tests (37 earlier plus 11), Failed=0 for Get-EpicProgressReport.Logic.Tests.ps1; all eleven plan-named It blocks pass.
