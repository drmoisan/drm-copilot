# Logic Summary and Line Composition (Issue #1080, P1-T5)

Timestamp: 2026-11-04T20-46
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p1t5.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0

## Change

- Added `Get-EpicProgressSummary`, `Get-EpicProgressTldrLine`, `Get-EpicProgressFullLine`, and the private helper `Get-EpicProgressWeeklyText` (`N%` or `n/a`) to `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`. The lines keep the recovered wording; `Epic #<EpicIssue>` and the heading name `<EpicName>` come from the summary; times use the invariant culture; non-finite values print `n/a`.
- Added the `Describe 'Get-EpicProgressSummary, Get-EpicProgressTldrLine, and Get-EpicProgressFullLine'` block, which asserts complete string arrays on fixed summaries (three features across waves 1 to 3, hourly samples).

## Result

TOTAL Tests=60 Passed=60 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=60 failed=0

## Plan-named It blocks (11, all passed)

- composes the four TL;DR lines
- composes the Full lines in recovered order
- states that no feature is running
- names a single running feature
- lists several running features
- states that no feature is done yet
- Context 'non-finite values print n/a': prints n/a for the straight-line hours
- Context 'non-finite values print n/a': prints n/a for the wave-parallel hours
- Context 'non-finite values print n/a': prints n/a for the hours-left figure
- Context 'non-finite values print n/a': prints n/a for the range
- Context 'non-finite values print n/a': prints n/a for the weekly quota and its delta

Asserted literals from the plan `## Design`: `about n/a hours left on the wave-parallel estimate`, `**Weekly** quota is at n/a.`, `Straight line, no parallelism: about n/a (upper bound).`, `about **n/a**.`, `n/a used, n/a points since the epic started.`, and `n/a hrs (range needs 3 or more check-in intervals)`.

## Additional It block (1, passed)

- Context 'non-finite values print n/a': prints n/a estimates at zero elapsed time (AC5 zero-elapsed case)

Output Summary: 60 tests (48 earlier plus 12), Failed=0 for Get-EpicProgressReport.Logic.Tests.ps1; all eleven plan-named It blocks pass.
