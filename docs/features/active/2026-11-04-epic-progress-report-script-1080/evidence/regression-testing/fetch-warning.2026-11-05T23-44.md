# Finding 4: Fetch Failure Warning (Issue #1080, remediation cycle 1, P1-T5)

Timestamp: 2026-11-05T23-44
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r1-p1t5.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
EXIT_CODE: 0

## Change

- `scripts/dev-tools/Get-EpicProgressReport.ps1` gains the seam `Get-EpicProgressLastExitCode` (comment-based help, `[OutputType([int])]`, returns `$LASTEXITCODE`). `Invoke-EpicProgressReport` reads it after the unchanged `fetch -q origin` call and, when the value is not 0, writes `git fetch -q origin failed with exit code <n>; the report uses the last fetched state of <IntegrationBranch>.` with `Write-Warning`, then continues. The `.DESCRIPTION` help states the warning.
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`: the `Describe 'Invoke-EpicProgressReport'` `BeforeEach` sets `$script:fetchExitCode = 0` and mocks `Get-EpicProgressLastExitCode`; new `It 'warns when git fetch fails'` (exit code 128, one warning matching `git fetch -q origin failed with exit code 128;*`, report lines still returned), `It 'does not warn when git fetch succeeds'` (zero warnings), and, in `Describe 'I/O seams without side effects'`, `It 'returns the last native exit code'`.

## Printed output

- TOTAL Tests=32 Passed=32 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=32 failed=0
- One `What if:` line from the existing `-WhatIf` state-write seam test; no file written.

Output Summary: Failed=0; the script suite is at tests=32 including `warns when git fetch fails`, `does not warn when git fetch succeeds`, and `returns the last native exit code`.
