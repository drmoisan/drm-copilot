# Regression: -PairSamples Write Without a New Sample at Branch Head — Issue #1093 (F1)

Timestamp: 2026-11-07T02-01
Command: sh SCRATCH/issue-1093-run.sh issue-1093-named.ps1 -File tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1 -NameLike '*PairSamples*' (PowerShell 7, Pester 6.2.0, direct `Invoke-Pester` with `Run.PassThru`; counts from the result object); line count by sh SCRATCH/issue-1093-lines.sh (`@(Get-Content -LiteralPath <path>).Count`)
EXIT_CODE: 0
Output Summary: `ENTRY_SUITE` 36 passed, 0 failed, 0 skipped; the new case `pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample` passed; `ENTRY_SUITE` has 586 physical lines (below 700). No production file changed.

## Run result

| Test (ExpandedPath) | Result |
|---|---|
| `Invoke-EpicProgressReport.rewrites the stored samples in pairs with -PairSamples` | Passed |
| `Invoke-EpicProgressReport.pairs and writes the stored samples with -PairSamples within 90 seconds of the last sample` | Passed |
| `Invoke-EpicProgressReport.throws before any I/O when -ResetBaseline and -PairSamples are combined` | Passed |

Totals: passed=36, failed=0, skipped=0, notrun=0.

## Case design

- Stored version-1 state: `startUnixSeconds` 1767600000 (2026-01-05T08:00:00Z, different from the fixture `-StartUtc`), `baselineDone` 1, `baselineWeeklyPct` 12.5, five samples at the fixed now minus 1230, 930, 630, 330 and 30 seconds (done 2 each).
- Run without `-StartUtc`, with `-PairSamples` and `-Mode TLDR`.
- Asserted: `Write-EpicProgressState` invoked exactly once; one recorded write at `$script:statePath`; written `samples.ts` equal now minus 1230, 630 and 30 (no sample at the fixed now); `startUnixSeconds` 1767600000, `baselineDone` 1 and `baselineWeeklyPct` 12.5 carried over.
- The newest stored sample is 30 seconds old, so `Select-EpicProgressSample` returns `Changed` false and only the `-PairSamples` term of the write condition causes the write.

## File size

| File | Physical lines |
|---|---|
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` | 586 |
