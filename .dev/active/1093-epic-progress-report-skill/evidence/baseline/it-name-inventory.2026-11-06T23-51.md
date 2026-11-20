# It-Name Inventory at the Merge Base — Issue #1093

Timestamp: 2026-11-06T23-51
Command: sh SCRATCH/issue-1093-itnames.sh (resolves `git merge-base origin/main HEAD`, reads each suite with `git show <merge base>:<path>`, parses it with `[System.Management.Automation.Language.Parser]::ParseInput`, and lists every `It` name under its enclosing `Describe`)
EXIT_CODE: 0
Output Summary: Logic suite 74 It names; entry suite 32 It names; total 106. The entry-suite list contains `defaults the state path under the temporary root and outside the repository`.

Per-file counts:

| File | It count |
|---|---|
| `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | 74 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 32 |

Names (one per line, grouped by file and Describe; the `non-finite values print n/a` Context cases are listed under their Describe):

## tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 (74 It blocks)

### Describe: ConvertFrom-EpicProgressKickoffRow
- parses a feature row with a two-digit issue number
- parses a feature row with a five-digit issue number
- ignores the header and separator rows
- returns no rows for an empty kickoff
- parses a feature row with variable whitespace around cells
- throws a clear error for a non-numeric wave cell
- throws a clear error for a wave cell beyond the Int32 range
- returns only rows of the feature-summary table
- ignores a numeric-first row with a non-digit wave position outside the feature table
- throws a clear error for a kickoff whose feature-table header is not recognized
- throws a clear error for a feature table with no header row
- returns no rows for a whitespace-only kickoff
- reads a feature table whose header row is indented
- reads an indented row inside the feature table
- throws a clear error for a feature row with fewer than five cells
- throws a clear error for a feature row with a blank plan cell

### Describe: Get-EpicProgressIssueFromKickoff
- returns the issue number from a mid-line Epic issue marker
- returns null when the kickoff has no Epic issue marker

### Describe: ConvertFrom-EpicProgressWorktreeList
- maps each branch to its worktree path

### Describe: ConvertFrom-EpicProgressPrList
- returns the number and state of the first pull request
- returns an empty string for an empty pull request list
- returns an empty string for unparseable pull request output
- returns an empty string for blank pull request output
- returns an empty string for an entry without a number

### Describe: Get-EpicProgressWeeklyQuota
- returns the seven-day percentage of the active account
- returns NaN when no account is active
- returns NaN for unparseable quota output
- returns NaN when the output has no accounts list
- returns NaN when the active account has no seven-day percentage

### Describe: Get-EpicProgressTaskCount
- counts checked and unchecked task checkboxes
- ignores checkboxes without a task identifier

### Describe: Get-EpicProgressCurrentPhase
- returns the heading of the phase holding the first unchecked task
- falls back to Phase N when no heading matches
- returns an empty string when every task is checked

### Describe: Get-EpicProgressFeatureState
- classifies merged and worktree_removed features as Completed
- classifies a feature with a MERGED pull request as Completed
- classifies a started feature as Running
- classifies an unstarted feature as Pending

### Describe: Format-EpicProgressHour, Format-EpicProgressClock, and Format-EpicProgressNumber
- formats hours as H h MM min
- formats hours as HH:MM
- never prints 60 in the minute field
- returns n/a from each formatter for NaN
- returns n/a from each formatter for infinity
- rounds a number to the given digits with invariant text

### Describe: Select-EpicProgressSample
- adds the first sample
- adds a sample 90 seconds after the last
- does not add a sample 89 seconds after the last
- drops samples without a timestamp when adding
- keeps only the last SampleCap samples

### Describe: Get-EpicProgressAverageVelocity
- returns the average velocity since the baseline
- returns zero velocity when elapsed time is zero

### Describe: Get-EpicProgressRecentVelocityInterval
- skips intervals shorter than two minutes
- counts a pair exactly two minutes apart
- clamps a negative interval rate to zero

### Describe: Get-EpicProgressStandardDeviation
- returns NaN with fewer than three intervals
- returns the sample standard deviation of three intervals

### Describe: Get-EpicProgressCriticalPath
- sums the largest remaining count of each open wave
- returns NaN hours when velocity is zero

### Describe: Get-EpicProgressRangeText
- states that three intervals are needed
- returns a bounded range when the slow velocity exceeds 0.5
- returns the no-upper-bound wording at a slow velocity of 0.5

### Describe: Get-EpicProgressSummary, Get-EpicProgressTldrLine, and Get-EpicProgressFullLine
- composes the four TL;DR lines
- composes the Full lines in recovered order
- states that no feature is running
- names a single running feature
- lists several running features
- states that no feature is done yet
- prints n/a for the straight-line hours
- prints n/a for the wave-parallel hours
- prints n/a for the hours-left figure
- prints n/a for the range
- prints n/a for the weekly quota and its delta
- prints n/a estimates at zero elapsed time
- clamps elapsed time at zero when the start is after now

## tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 (32 It blocks)

### Describe: Resolve-EpicProgressSetting
- defaults the integration branch from the epic folder
- defaults the kickoff path from the epic folder
- defaults the checkpoint path under the repository root
- defaults the state path under the temporary root and outside the repository
- keeps explicit values over defaults

### Describe: I/O seams without side effects
- returns false for an absent command name
- returns false for an absent path
- reads the raw text of an existing file
- writes nothing when the state write runs with WhatIf
- returns the last native exit code

### Describe: Invoke-EpicProgressReport
- warns when git fetch fails
- does not warn when git fetch succeeds
- prints the four TL;DR lines in TLDR mode
- prints the TL;DR block followed by the Full sections in Full mode
- takes the epic issue from the kickoff when -EpicIssue is absent
- uses -EpicIssue over the kickoff marker
- throws when no epic issue can be resolved
- reads a live plan from the feature worktree
- prints n/a quota when cswap is not installed
- prints n/a quota when cswap output is unparseable
- leaves the PR state empty when gh is not installed
- leaves the PR state empty when gh output is unparseable
- treats an unparseable state file as empty
- passes only fetch, show and worktree list to git
- passes only pr list to gh
- writes only the state file at -StatePath
- does not write the state file within 90 seconds of the last sample

### Describe: Get-EpicProgressReport.ps1 repository constraints
- confines file writes to Write-EpicProgressState
- confines native commands to their wrappers
- contains no recovered hardcoded value
- documents every parameter in comment-based help
- carries at least one example

