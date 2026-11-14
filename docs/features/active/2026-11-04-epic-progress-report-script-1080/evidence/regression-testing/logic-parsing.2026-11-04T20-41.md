# Logic Parsing Functions (Issue #1080, P1-T1)

Timestamp: 2026-11-04T20-41
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p1t1.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0

## Change

- Created `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` with `ConvertFrom-EpicProgressKickoffRow`, `Get-EpicProgressIssueFromKickoff`, `ConvertFrom-EpicProgressWorktreeList`, `ConvertFrom-EpicProgressPrList`, `Get-EpicProgressWeeklyQuota`, and the shared private guard `Test-EpicProgressJsonText` (blank or malformed JSON returns `$false`, so unparseable tool output is treated as absent without a catch-all).
- Created `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` (dot-sources the logic file; in-memory fixtures only; the kickoff fixture uses issues 12 and 12345).

## Result

TOTAL Tests=17 Passed=17 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=17 failed=0

## Plan-named It blocks (12, all passed)

- parses a feature row with a two-digit issue number
- parses a feature row with a five-digit issue number
- ignores the header and separator rows
- returns the issue number from a mid-line Epic issue marker
- returns null when the kickoff has no Epic issue marker
- maps each branch to its worktree path
- returns the number and state of the first pull request
- returns an empty string for an empty pull request list
- returns an empty string for unparseable pull request output
- returns the seven-day percentage of the active account
- returns NaN when no account is active
- returns NaN for unparseable quota output

## Additional It blocks (5, all passed)

- returns no rows for an empty kickoff
- returns an empty string for blank pull request output
- returns an empty string for an entry without a number
- returns NaN when the output has no accounts list
- returns NaN when the active account has no seven-day percentage

Early checks on the two files: FORMAT-DIFF-COUNT=0, PSSA-FINDINGS=0.

Output Summary: 17 tests, Failed=0 for Get-EpicProgressReport.Logic.Tests.ps1; all twelve plan-named It blocks pass.
