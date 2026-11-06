# Kickoff Feature-Table Gate (CR-1) - Remediation Cycle 2 (Issue 1080)

Timestamp: 2026-11-06T00-35
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r2-p1t1.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0
Output Summary: Logic suite tests=66 Failed=0 after adding the feature-table gate to ConvertFrom-EpicProgressKickoffRow (64 baseline + 2 new tests).

## Printed output

```
TOTAL Tests=66 Passed=66 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=66 failed=0
EXIT_CODE=0
```

## Change

`ConvertFrom-EpicProgressKickoffRow` in `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`:

- `$inFeatureTable` starts `$false`; while false, each line only sets the flag to `-match '^\|\s*(issue_num|issue)\s*\|'` (case-insensitive) and continues.
- Inside the table, a line not matching `^\s*\|` ends the table with `break`; non-numeric first cells (the separator row) are skipped by the existing `^\|\s*(\d+)\s*\|` match.
- `.SYNOPSIS` and `.DESCRIPTION` state that only the feature-summary table is read, name both header spellings, and state the end-of-table rule.

## Tests (Describe 'ConvertFrom-EpicProgressKickoffRow')

New:

- `It 'returns only rows of the feature-summary table'` (`issue_num` header, followed by a `| wave | features | width |` table).
- `It 'ignores a numeric-first row with a non-digit wave position outside the feature table'` (`| id | note | detail | extra |` table with row `| 7 | notes | n/a | more |`, then the `Issue` header table).

Updated (fixture gains the `| Issue | Title | Wave | Band | Plan |` header and `|---|---|---|---|---|` separator; assertions unchanged):

- `It 'parses a feature row with variable whitespace around cells'`
- `It 'throws a clear error for a non-numeric wave cell'`

## Additional check

The script suite was also run (`sh SCRATCH/issue-1080-run.sh issue-1080-r2-p1t1-script.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`): `tests=32 failed=0`, exit 0, consistent with the plan's statement that every `Invoke-EpicProgressReport` test is unaffected.
