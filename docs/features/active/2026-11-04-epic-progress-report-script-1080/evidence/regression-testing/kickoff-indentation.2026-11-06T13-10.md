# NB-2 One Anchoring Rule — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-10
Task: P1-T2
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r3-p1t2.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
EXIT_CODE: 0
Output Summary: TOTAL Tests=104 Passed=104 Failed=0; Logic tests=72 failed=0; script tests=32 failed=0.

## Change

`ConvertFrom-EpicProgressKickoffRow`: each line is trimmed once (`$trimmed = $line.Trim()`); the header match `^\|\s*(issue_num|issue)\s*\|`, the end-of-table test `$trimmed -notmatch '^\|'`, the row match `^\|\s*(\d+)\s*\|`, and the cell split all operate on `$trimmed`. The cell indices are unchanged. The function `.DESCRIPTION` states the trim rule and that a blank line ends the table.

## New tests (Describe 'ConvertFrom-EpicProgressKickoffRow')

- `It 'reads a feature table whose header row is indented'`
- `It 'reads an indented row inside the feature table'`

## Printed lines

```text
TOTAL Tests=104 Passed=104 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=72 failed=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=32 failed=0
EXIT_CODE=0
```
