# Coverage Delta (P7-T6, issue #1118)

Timestamp: 2026-11-07T23-06
Command: pwsh -NoProfile -File SCRATCH/issue-1118-covdelta.ps1 -Root <item worktree> (reads the per-file and repo-wide line coverage rows of the lexicographically greatest evidence/baseline/pester-parallel-baseline.*.md and evidence/qa-gates/pester-parallel-final.*.md; ends with VERDICT(nine files present, each at or above 85%, no existing file below its baseline, repo-wide at or above 85%))
EXIT_CODE: 0
Output Summary:
- Inputs: pester-parallel-baseline.2026-11-07T22-04.md and pester-parallel-final.2026-11-07T22-59.md (one Invoke-PoshQCParallelTest run each).
- Per-file line coverage (Pester measures line coverage only; there is no PowerShell branch gate):

| File | Baseline | Final | Delta |
|---|---|---|---|
| Get-EpicProgressReport.ps1 | 90.82% | 95.56% | +4.74 |
| Get-EpicProgressReport.Logic.ps1 | 100% | 100% | 0 |
| Get-EpicProgressReport.Metrics.ps1 | 100% | 100% | 0 |
| Get-EpicProgressReport.Render.ps1 | 100% | 100% | 0 |
| Get-EpicProgressReport.State.ps1 | 100% | 100% | 0 |
| Get-EpicProgressReport.Stages.ps1 | new | 100% | n/a (threshold only) |
| Get-EpicProgressReport.Steps.ps1 | new | 97.01% | n/a (threshold only) |
| Get-EpicProgressReport.Durations.ps1 | new | 98.39% | n/a (threshold only) |
| Get-EpicProgressReport.Gather.ps1 | new | 99.28% | n/a (threshold only) |

- Repo-wide line coverage: 94.21% final against 94.1% baseline.
- Remaining missed lines: entry script 4 (the git, gh, and cswap native calls and the [datetime]::UtcNow read inside their seams); Steps 4, Durations 2, Gather 1 (defensive branches for absent or out-of-range records).
- VERDICT: True. Every file is at or above 85%, no existing file is below its baseline, and repo-wide coverage is at or above 85%.
