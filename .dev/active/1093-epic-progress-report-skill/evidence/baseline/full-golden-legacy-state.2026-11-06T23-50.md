# Full-Mode Golden With a Legacy Four-Sample State — Issue #1093

Timestamp: 2026-11-06T23-50
Command: sh SCRATCH/issue-1093-golden.sh (PowerShell 7 runs SCRATCH/issue-1093-golden.ps1 -ScriptPath scripts/dev-tools/Get-EpicProgressReport.ps1 from the item worktree root)
EXIT_CODE: 0
Output Summary: the unmodified merged tool printed 26 lines in Full mode; the fourth line is the bounded range `09:22 hrs to 09:39 hrs`; no state write occurred (newest sample 60 seconds old).

## Fixture

- The SCRATCH script dot-sources the unmodified `scripts/dev-tools/Get-EpicProgressReport.ps1` with `-EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z` and then redefines the I/O seams (`Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Test-EpicProgressCommand`, `Test-EpicProgressPath`, `Read-EpicProgressFile`, `Write-EpicProgressState`, `Get-EpicProgressUtcNow`, `Get-EpicProgressLastExitCode`) with the values of the `Invoke-EpicProgressReport` Describe of `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`: same kickoff (`Epic issue: #42`, issues 12, 12345, 77), same three plans, same live plan for `feature/beta`, same checkpoint JSON, gh output (`#7 MERGED`, `#8 OPEN`), cswap output (42.5), fixed now `2026-01-05T12:00:00Z` (Unix 1767614400), explicit `-StartUtc 2026-01-05T09:00:00Z`, `-RepositoryRoot /fixture-repo`, the fixture checkpoint path and the fixture state path `/fixture-temp/epic-progress-example-epic.json`.
- Deviation from the suite fixture: only the state file. The state path is listed as existing and its text is a legacy JSON array of four samples.

| Sample | Offset from fixed now (seconds) | ts | done |
|---|---|---|---|
| 1 | -10800 | 1767603600 | 0 |
| 2 | -7200 | 1767607200 | 1 |
| 3 | -3600 | 1767610800 | 2 |
| 4 | -60 | 1767614340 | 3 |

- State writes: 0 (the newest sample is 60 seconds old, below the 90-second rule).

## Output (26 lines, verbatim)

```text
**TL;DR:** Epic #42 is at 3 of 10 tasks (30%). 1 of 3 features are done. #12345 is running (1 of 5).
**Elapsed:** 3 h 00 min, with about 10 hours left on the wave-parallel estimate. **Weekly** quota is at 42.5%.
**Avg Velocity:** 1 tasks / hr. **Recent Velocity:** 1 tasks / hr since last check-in. (SD of recent velocity: 0, from 3 intervals)
**Estimated time remaining:** 09:22 hrs to 09:39 hrs

## Epic #42 example-epic: status at 12:00 UTC, Jan 5

**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 3 of 10 tasks complete, **30%**.

| State | Features |
|---|---|
| Completed | #12 |
| Running | #12345 (wave 2, large): 1 of 5 tasks (20%). Now at: Phase 1 - Build. PR #8 OPEN. |
| Pending, wave 3 | #77 (3) |

| Wave | Children | Tasks | Done |
|---|---|---|---|
| 1 | 1 | 2 | 2 |
| 2 | 1 | 5 | 1 |
| 3 | 1 | 3 | 0 |
| **Total** | **3** | **10** | **3** |

**Velocity:** 1 tasks per hour (one child's pace). **Remaining:** 7 tasks.
- Straight line, no parallelism: about 7 h 00 min (upper bound).
- Wave-parallel (longest chain 7 tasks plus about 1.25 h per open wave for review and CI): about **9 h 30 min**.
**Weekly quota (active account):** 42.5% used, +42.5 points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone.
```

Line 1 (TL;DR) to line 4 (range) form the TL;DR block; lines 5 to 26 are the Full lines. Line 4 is the bounded range form (`hrs to` followed by a clock value).
