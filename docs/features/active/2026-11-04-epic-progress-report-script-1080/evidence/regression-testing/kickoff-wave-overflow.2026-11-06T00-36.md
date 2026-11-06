# Kickoff Wave-Cell Overflow (Nit) - Remediation Cycle 2 (Issue 1080)

Timestamp: 2026-11-06T00-36
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r2-p1t2.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0
Output Summary: Logic suite tests=67 Failed=0 after replacing the ^\d+$ check and [int]::Parse with one [int]::TryParse call using NumberStyles::None and the invariant culture.

## Printed output

```
TOTAL Tests=67 Passed=67 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=67 failed=0
EXIT_CODE=0
```

## Change

In `ConvertFrom-EpicProgressKickoffRow`, the wave cell is parsed with `[int]::TryParse($cells[3], [System.Globalization.NumberStyles]::None, [cultureinfo]::InvariantCulture, [ref] $wave)`. On `$false` the existing terminating error `The kickoff row for issue #<issue> has a non-numeric wave cell '<cell>'.` is raised unchanged. `NumberStyles::None` admits ASCII digits only, so signs, separators, and values above `Int32` take the error path.

## Test

New: `It 'throws a clear error for a wave cell beyond the Int32 range'` (row `| 12 | Alpha | 99999999999 | small | docs/a/plan.md |`; expects `*#12 has a non-numeric wave cell '99999999999'*`). Its fail-before state is demonstrated by mutant B in P1-T3.
