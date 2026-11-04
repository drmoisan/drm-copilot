# Main Script Report Wiring (Issue #1080, P1-T7)

Timestamp: 2026-11-04T20-51
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p1t7.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1,tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 0

## Change

- Added `Invoke-EpicProgressReport` (wiring only) and the guarded entry point (`if ($MyInvocation.InvocationName -ne '.')`, Push-Location to the repository root, `Invoke-EpicProgressReport @PSBoundParameters`, Pop-Location in `finally`) to `scripts/dev-tools/Get-EpicProgressReport.ps1`.
- Added `Describe 'Invoke-EpicProgressReport'` to `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`. Every seam is mocked with a matching parameter signature (`param([string[]] $GitArgs)`, `param([string[]] $GhArgs)`, `param([string[]] $CswapArgs)`, `param([string] $Name)`, `param([string] $Path)`, `param([string] $Path, [string] $Content)`), and the clock mock returns a fixed `[datetime]` built with `[datetime]::new`. Call logs are rebuilt in `BeforeEach`.
- Analyzer remediation inside this task: an early analyzer pass over the four files reported `PSUseSingularNouns` for `Format-EpicProgressHours` and `PSUseOutputTypeCorrectly` for `Get-EpicProgressTldrLine`. The plan's `## Design` requires singular nouns and the plan's gates require zero findings, so the hours formatter is renamed `Format-EpicProgressHour` (behavior unchanged; tests updated), and `Get-EpicProgressTldrLine` returns an explicit `[string[]]`. The analyzer then reports `PSSA-FINDINGS=0` for the four files.

## Result

TOTAL Tests=84 Passed=84 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=24 failed=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=60 failed=0

## Plan-named It blocks (15, all passed)

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

Output Summary: 24 tests in Get-EpicProgressReport.Tests.ps1 (9 earlier plus 15), Failed=0; the logic suite stays at 60 tests, Failed=0, after the formatter rename; all fifteen plan-named It blocks pass.
