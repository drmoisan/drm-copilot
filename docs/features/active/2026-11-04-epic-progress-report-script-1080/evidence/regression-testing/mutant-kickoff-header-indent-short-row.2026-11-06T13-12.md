# Mutant Demonstrations (NB-1, NB-2, NB-3) — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-12
Task: P1-T4 [expect-fail]
Command: sh SCRATCH/issue-1080-r3-mutants.sh (for each mutant: edit the worktree copy of scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 with sed, run sh SCRATCH/issue-1080-run.sh <log> -1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1, restore the file from a SCRATCH copy; then run the suite once more and git diff --exit-code HEAD on the file)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Mutant A EXIT_CODE 1 Failed=2 (the two NB-1 throw tests); mutant B EXIT_CODE 1 Failed=1 (indented-row test); mutant C EXIT_CODE 1 Failed=1 (fewer-than-five-cells test); restored run EXIT_CODE 0 Failed=0; git diff --exit-code HEAD on the logic file exits 0.

## Mutant A — delete the post-loop NB-1 `if` and its `throw`

Edit: 3 lines removed (`if (-not $inFeatureTable -and $KickoffText -match '\S') {`, the `throw`, and the closing brace).

```text
TOTAL Tests=74 Passed=72 Failed=2 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=74 failed=2
TEST tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | ConvertFrom-EpicProgressKickoffRow.throws a clear error for a kickoff whose feature-table header is not recognized | FAILED
TEST tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | ConvertFrom-EpicProgressKickoffRow.throws a clear error for a feature table with no header row | FAILED
EXIT_CODE=1
```

Mutant A: EXIT_CODE: 1, Failed=2, exactly two `TEST` lines, as predicted.

## Mutant B — row-match operand changed from `$trimmed` to `$line`

```text
-        if ($trimmed -notmatch '^\|\s*(\d+)\s*\|') { continue }
+        if ($line -notmatch '^\|\s*(\d+)\s*\|') { continue }
TOTAL Tests=74 Passed=73 Failed=1 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=74 failed=1
TEST tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | ConvertFrom-EpicProgressKickoffRow.reads an indented row inside the feature table | FAILED
EXIT_CODE=1
```

Mutant B: EXIT_CODE: 1, Failed=1, one `TEST` line, as predicted (the indented-header test has unindented rows and still passes).

## Mutant C — delete the cell-count `if` and its `throw`

Edit: 3 lines removed (`if ($cellCount -lt 5) {`, the `throw`, and the closing brace).

```text
TOTAL Tests=74 Passed=73 Failed=1 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=74 failed=1
TEST tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | ConvertFrom-EpicProgressKickoffRow.throws a clear error for a feature row with fewer than five cells | FAILED
EXIT_CODE=1
```

Mutant C: EXIT_CODE: 1, Failed=1, one `TEST` line, as predicted (the four-cell row then raises the blank-plan message).

## Restored

```text
TOTAL Tests=74 Passed=74 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 tests=74 failed=0
EXIT_CODE=0
```

- `git diff --exit-code HEAD -- scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` exited 0.
- `git status --porcelain`, run after this file was written and before the plan checkbox edit, is recorded in the section below.

## git status --porcelain before the commit

```text
?? docs/features/active/2026-11-04-epic-progress-report-script-1080/evidence/regression-testing/mutant-kickoff-header-indent-short-row.2026-11-06T13-12.md
```

Only the new evidence file is listed. The plan checkbox for P1-T4 is edited after this observation and committed with this file.
