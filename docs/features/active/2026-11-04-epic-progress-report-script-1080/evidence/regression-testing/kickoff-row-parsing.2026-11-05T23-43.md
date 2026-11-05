# Finding 3: Kickoff Row Parsing (Issue #1080, remediation cycle 1, P1-T4)

Timestamp: 2026-11-05T23-43
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r1-p1t4.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0

## Change

- `ConvertFrom-EpicProgressKickoffRow` (`scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`) matches a feature row with `^\|\s*(\d+)\s*\|`, raises `The kickoff row for issue #<issue> has a non-numeric wave cell '<cell>'.` when the wave cell is not all digits, and parses a numeric wave cell with the invariant culture. The `.DESCRIPTION` help states both rules.
- `Describe 'ConvertFrom-EpicProgressKickoffRow'` gains `It 'parses a feature row with variable whitespace around cells'` and `It 'throws a clear error for a non-numeric wave cell'`.

## Printed output

- TOTAL Tests=64 Passed=64 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=64 failed=0

Output Summary: Failed=0; the Logic suite is at tests=64 including `parses a feature row with variable whitespace around cells` and `throws a clear error for a non-numeric wave cell`.
