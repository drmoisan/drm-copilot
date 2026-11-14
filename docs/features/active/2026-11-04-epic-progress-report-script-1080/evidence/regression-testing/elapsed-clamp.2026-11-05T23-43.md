# Finding 2: Elapsed Time Clamped at Zero (Issue #1080, remediation cycle 1, P1-T3)

Timestamp: 2026-11-05T23-43
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r1-p1t3.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0

## Change

- `Get-EpicProgressSummary` (`scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`) computes `ElapsedHours` as `[math]::Max(0.0, ($NowUtc - $StartUtc).TotalHours)`; its `.PARAMETER StartUtc` help states that a start after NowUtc counts as zero elapsed time.
- `Context 'non-finite values print n/a'` in the Logic test file gains `It 'clamps elapsed time at zero when the start is after now'` (start 30 minutes after `$script:nowUtc`; asserts `ElapsedHours` is 0 and the second TL;DR line is `**Elapsed:** 0 h 00 min, with about n/a hours left on the wave-parallel estimate. **Weekly** quota is at 42.5%.`).

## Printed output

- TOTAL Tests=62 Passed=62 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=62 failed=0

Output Summary: Failed=0; the Logic suite is at tests=62 including the new `clamps elapsed time at zero when the start is after now`.
