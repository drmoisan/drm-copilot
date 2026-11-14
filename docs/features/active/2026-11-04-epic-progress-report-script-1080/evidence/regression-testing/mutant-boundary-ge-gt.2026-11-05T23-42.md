# Finding 1: Mutant Demonstration, -ge to -gt (Issue #1080, remediation cycle 1, P1-T2) [expect-fail]

Timestamp: 2026-11-05T23-42
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r1-p1t2-mutant.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1

## Mutant run

Mutation: in `Get-EpicProgressRecentVelocityInterval` (`scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`) the comparison `$hours -ge (2 / 60)` was changed to `$hours -gt (2 / 60)`.

- TOTAL Tests=61 Passed=60 Failed=1 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=61 failed=1
- TEST tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | Get-EpicProgressRecentVelocityInterval.counts a pair exactly two minutes apart | FAILED
- EXIT_CODE: 1 (Failed=1, exactly one TEST line, naming `counts a pair exactly two minutes apart`)

## Restored run

The `-ge (2 / 60)` comparison was restored.

- Command: sh SCRATCH/issue-1080-run.sh issue-1080-r1-p1t2-restored.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
- TOTAL Tests=61 Passed=61 Failed=0 Skipped=0 NotRun=0
- Exit 0, Failed=0

## Tree after restoration

- `git diff --exit-code HEAD -- scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` exited 0 (the logic file equals HEAD).
- `git status --porcelain` before this evidence file was written printed nothing; after it was written, and before the plan check-off and the commit, it listed only `?? docs/features/active/2026-11-04-epic-progress-report-script-1080/evidence/regression-testing/mutant-boundary-ge-gt.2026-11-05T23-42.md`.

Output Summary: the -gt mutant fails exactly one test (`counts a pair exactly two minutes apart`, exit 1 as expected); after restoration the Logic suite passes 61/61 and the logic file has no diff against HEAD.
