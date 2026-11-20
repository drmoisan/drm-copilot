# Finding 1: Inclusive Two-Minute Boundary (Issue #1080, remediation cycle 1, P1-T1)

Timestamp: 2026-11-05T23-41
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r1-p1t1.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0

## Change

Test-only. `Describe 'Get-EpicProgressRecentVelocityInterval'` in `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` gains `It 'counts a pair exactly two minutes apart'`: samples `ts 0, done 0` and `ts 120, done 1` return one interval whose rate is 30 within 1e-9. No production file changed.

## Printed output

- TOTAL Tests=61 Passed=61 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=61 failed=0

Output Summary: Failed=0; the Logic suite is at tests=61 (60 + the new `counts a pair exactly two minutes apart`).
