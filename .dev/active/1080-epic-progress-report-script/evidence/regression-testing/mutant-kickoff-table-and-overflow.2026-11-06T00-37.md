# Mutant Demonstrations - Kickoff Table Gate and Wave Overflow (Issue 1080, Cycle 2)

Timestamp: 2026-11-06T00-37
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r2-p1t3-mutant-a.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Mutant A (table restriction removed) Failed=2, exit 1, the two table tests fail; mutant B (overflow handling removed) Failed=1, exit 1, the overflow test fails; restored run Failed=0, exit 0. Logic file restored from HEAD after each mutant; git diff --exit-code HEAD on the file exits 0.

## Mutant A - table restriction removed

Change in `ConvertFrom-EpicProgressKickoffRow`: `$inFeatureTable` initialized to `$true` and the end-of-table `break` statement deleted (diffstat: 1 insertion, 2 deletions).

Command: `sh SCRATCH/issue-1080-run.sh issue-1080-r2-p1t3-mutant-a.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`
EXIT_CODE: 1

```
TOTAL Tests=67 Passed=65 Failed=2 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=67 failed=2
TEST tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | ConvertFrom-EpicProgressKickoffRow.returns only rows of the feature-summary table | FAILED
TEST tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | ConvertFrom-EpicProgressKickoffRow.ignores a numeric-first row with a non-digit wave position outside the feature table | FAILED
EXIT_CODE=1
```

Result: `Failed=2`, exactly the two expected `TEST` lines. Killed.

Restore: `git checkout HEAD -- scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, then `git diff --exit-code HEAD -- scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` exited 0.

## Mutant B - overflow handling removed

Change: the `TryParse` call replaced with the `^\d+$` check followed by `[int]::Parse($cells[3], [cultureinfo]::InvariantCulture)`.

Command: `sh SCRATCH/issue-1080-run.sh issue-1080-r2-p1t3-mutant-b.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`
EXIT_CODE: 1

```
TOTAL Tests=67 Passed=66 Failed=1 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=67 failed=1
TEST tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | ConvertFrom-EpicProgressKickoffRow.throws a clear error for a wave cell beyond the Int32 range | FAILED
EXIT_CODE=1
```

Result: `Failed=1`, exactly the expected `TEST` line. Killed. This run is also the fail-before demonstration of the overflow test against the cycle-1 parsing form.

Restore: `git checkout HEAD -- scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, then `git diff --exit-code HEAD -- scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` exited 0.

## Restored run

Command: `sh SCRATCH/issue-1080-run.sh issue-1080-r2-p1t3-restored.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`
EXIT_CODE: 0

```
TOTAL Tests=67 Passed=67 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=67 failed=0
EXIT_CODE=0
```

## Tree state before the commit

`git status --porcelain` listed this evidence file (untracked) and the plan file (modified only by the `[P1-T2]` check-off). No source or test file was modified.
