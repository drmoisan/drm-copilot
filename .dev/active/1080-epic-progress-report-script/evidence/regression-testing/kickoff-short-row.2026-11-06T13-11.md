# NB-3 Short Row and Blank Plan Cell — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-11
Task: P1-T3
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r3-p1t3.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
EXIT_CODE: 0
Output Summary: TOTAL Tests=106 Passed=106 Failed=0; Logic tests=74 failed=0; script tests=32 failed=0.

## Change

`ConvertFrom-EpicProgressKickoffRow`: after the row match and before the wave parse, the cell count is the split element count minus one, minus one more when `$trimmed` ends with `|`. Below 5 the function throws the `## Design` literal `The kickoff row for issue #<issue> has <n> cells; a feature row needs 5 (issue, title, wave, band, plan path).`; when cell 5 is null or whitespace it throws `The kickoff row for issue #<issue> has a blank plan cell.`; the wave `TryParse` check and its message are unchanged and run after both. The function `.DESCRIPTION` states both errors.

## New tests (Describe 'ConvertFrom-EpicProgressKickoffRow')

- `It 'throws a clear error for a feature row with fewer than five cells'`
- `It 'throws a clear error for a feature row with a blank plan cell'`

## Printed lines

```text
TOTAL Tests=106 Passed=106 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=74 failed=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=32 failed=0
EXIT_CODE=0
```
