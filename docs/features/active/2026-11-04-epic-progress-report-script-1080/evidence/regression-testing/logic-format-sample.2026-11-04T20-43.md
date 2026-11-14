# Logic Formatters and Sample Retention (Issue #1080, P1-T3)

Timestamp: 2026-11-04T20-43
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p1t3.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0

## Change

- Added `Format-EpicProgressHours` (`H h MM min`), `Format-EpicProgressClock` (`HH:MM`), `Format-EpicProgressNumber` (invariant rounded text), and `Select-EpicProgressSample` to `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`. Both hour formatters derive the hour and minute fields from the rounded total minutes, and every formatter returns `n/a` for a non-finite value.
- Added the matching `Describe` blocks to `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`.

## Result

TOTAL Tests=37 Passed=37 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=37 failed=0

## Plan-named It blocks (10, all passed)

- formats hours as H h MM min
- formats hours as HH:MM
- never prints 60 in the minute field
- returns n/a from each formatter for NaN
- returns n/a from each formatter for infinity
- adds the first sample
- adds a sample 90 seconds after the last
- does not add a sample 89 seconds after the last
- drops samples without a timestamp when adding
- keeps only the last SampleCap samples

## Additional It block (1, passed)

- rounds a number to the given digits with invariant text

Output Summary: 37 tests (26 earlier plus 11), Failed=0 for Get-EpicProgressReport.Logic.Tests.ps1; all ten plan-named It blocks pass.
