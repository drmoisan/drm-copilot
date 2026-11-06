# NB-1 No-Header Throw — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-09
Task: P1-T1
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r3-p1t1.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
EXIT_CODE: 0
Output Summary: TOTAL Tests=102 Passed=102 Failed=0; Logic tests=70 failed=0; script tests=32 failed=0.

## Change

`ConvertFrom-EpicProgressKickoffRow` in `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`: after the loop, when `$inFeatureTable` is `$false` and `$KickoffText -match '\S'`, the function throws the literal from `## Design`:

`The kickoff has no feature-summary table: no table header row whose first cell is 'issue_num' or 'Issue' was found.`

The function `.DESCRIPTION` states that non-whitespace kickoff text without the header raises a terminating error and that empty or whitespace-only text returns no rows.

## New tests (Describe 'ConvertFrom-EpicProgressKickoffRow')

- `It 'throws a clear error for a kickoff whose feature-table header is not recognized'`
- `It 'throws a clear error for a feature table with no header row'`
- `It 'returns no rows for a whitespace-only kickoff'`

## Printed lines

```text
TOTAL Tests=102 Passed=102 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=70 failed=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=32 failed=0
EXIT_CODE=0
```

## Existing tests

Every existing test listed in the plan's `## Existing Tests That Assert Changed Behavior` (Logic suite: the two-digit, five-digit, header-and-separator, empty-kickoff, variable-whitespace, non-numeric wave, Int32-range, feature-summary-only, and numeric-first-outside-table tests, and the `Get-EpicProgressIssueFromKickoff` block; script suite: every `Invoke-EpicProgressReport` test and the repository-constraint tests) passed unmodified. No existing test was edited in this task: 67 + 32 existing tests plus 3 new tests equal the 102 passed.
