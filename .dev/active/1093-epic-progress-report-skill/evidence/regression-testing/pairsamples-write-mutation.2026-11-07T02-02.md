# Regression: Mutation Proof for the -PairSamples Write Term — Issue #1093 (F1)

Timestamp: 2026-11-07T02-02
Command: sh SCRATCH/issue-1093-run.sh issue-1093-named.ps1 -File SCRATCH/mutant/tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1 -FullNameFilter 'Invoke-EpicProgressReport.pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample'; then the same filter with -File tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1 (PowerShell 7, Pester 6.2.0, direct `Invoke-Pester` with `Filter.FullName` and `Run.PassThru`; counts from the result object)
EXIT_CODE: 0
Output Summary: mutant run 0 passed, 1 failed (35 not run by the filter), failure message "Expected Write-EpicProgressState to be called 1 time exactly, but was called 0 times"; tracked-suite run 1 passed, 0 failed (35 not run by the filter); `git status --porcelain` empty before and after; `git diff HEAD --name-only -- .claude/skills/epic-progress-report` printed nothing.

## Tree state before the runs

`git status --porcelain` printed nothing.

## Scratch mutant

- Copies: the five `CANON` files to `SCRATCH/mutant/.claude/skills/epic-progress-report/scripts/` and `ENTRY_SUITE` to `SCRATCH/mutant/tests/scripts/claude-skills/epic-progress-report/`, so the suite's `$PSScriptRoot`-relative paths resolve into the copy.
- Edit, in the scratch copy of `Get-EpicProgressReport.ps1` only (`Invoke-EpicProgressReport` state-write condition): removed term `-or $PairSamples`.

| Version | Condition |
|---|---|
| Tracked | `if ($selection.Changed -or $ResetBaseline -or $PairSamples) {` |
| Scratch mutant | `if ($selection.Changed -or $ResetBaseline) {` |

`diff` of the tracked and scratch entry scripts reported exactly that one changed line.

## Results

| Run | Passed | Failed | Not run | Failure message |
|---|---|---|---|---|
| Mutant (`SCRATCH/mutant/...`) | 0 | 1 | 35 | Expected Write-EpicProgressState to be called 1 time exactly, but was called 0 times. Performed invocations: none |
| Tracked `ENTRY_SUITE` | 1 | 0 | 35 | none |

## Reasoning

With the term removed, the newest stored sample is 30 seconds old, so `Select-EpicProgressSample` returns `Changed` false; `-ResetBaseline` is absent; the condition is false; `Write-EpicProgressState` is never called; and the exactly-once assertion (`Should -Invoke Write-EpicProgressState -Times 1 -Exactly`) fails. The new case therefore discriminates the `-PairSamples` term of the write condition.

## Tree state after the runs

- `git status --porcelain` printed nothing.
- `git diff HEAD --name-only -- .claude/skills/epic-progress-report` printed nothing.
