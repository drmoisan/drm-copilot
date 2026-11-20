# Coverage comparison against the Phase 0 baseline (P6-T3)

Timestamp: 2026-11-09T16-54
Command: sh SCRATCH/issue-1153-summary.sh (per-file and repo-wide LINE counters of artifacts/pester/powershell-coverage.xml from the P6-T2 run recorded in evidence/qa-gates/pester.2026-11-09T16-54.md); then SCRATCH/issue-1153-addedcov.ps1 through sh SCRATCH/run-ps.sh (for each script under .claude/skills/epic-progress-report/scripts: the added lines of git diff -U0 <merge base of origin/main and HEAD> HEAD, intersected with the executable lines of the same coverage report)
EXIT_CODE: 0
Output Summary:
  Baseline: evidence/baseline/pester.2026-11-09T15-50.md. Post-change: the P6-T2 re-run (21204 tests, 0 failures).

  | File | Baseline | Post-change | Result |
  |---|---|---|---|
  | Get-EpicProgressReport.ps1 | 86/90 95.56% | 107/111 96.40% | no drop |
  | Get-EpicProgressReport.Durations.ps1 | 122/124 98.39% | 122/124 98.39% | no drop |
  | Get-EpicProgressReport.Gather.ps1 | 145/146 99.32% | 196/197 99.49% | no drop |
  | Get-EpicProgressReport.Logic.ps1 | 70/70 100% | 72/72 100% | no drop |
  | Get-EpicProgressReport.Metrics.ps1 | 65/65 100% | 59/59 100% | no drop |
  | Get-EpicProgressReport.Render.ps1 | 152/152 100% | 222/222 100% | no drop |
  | Get-EpicProgressReport.Stages.ps1 | 60/60 100% | 60/60 100% | no drop |
  | Get-EpicProgressReport.State.ps1 | 117/117 100% | 152/152 100% | no drop |
  | Get-EpicProgressReport.Steps.ps1 | 135/137 98.54% | 135/137 98.54% | no drop |
  | Get-EpicProgressReport.Velocity.ps1 | new file (no pre-change run) | 94/94 100% | at least 90% |
  | Get-EpicProgressReport.Schedule.ps1 | new file (no pre-change run) | 305/305 100% | at least 90% |

  Every file is at least 85% with no drop; Velocity.ps1 and Schedule.ps1 are at least 90%.
  Added executable lines since the merge base: 644 of 644 covered (100%): Gather 68/68, Logic 2/2, Metrics 3/3, entry 28/28, Render 100/100, Schedule 305/305, State 44/44, Velocity 94/94; Durations, Stages, and Steps have no added line.
  Repo-wide line coverage: 95.73% baseline, 95.79% post-change (no drop).
  Shortfall found and fixed in this task: the first P6-T2 run (evidence/qa-gates/pester.2026-11-09T16-45.md) read Get-EpicProgressReport.State.ps1 at 151/152 (99.34%), below its 100% baseline, with the object-valued `features` branch of ConvertTo-EpicProgressStateJson unexecuted. The case `writes the features of a sample given as an object, sorted by issue` was added to Get-EpicProgressReport.State.V3.Tests.ps1, and P6-T1 and P6-T2 were re-run.
  The remaining missed lines are outside this change: the native wrapper bodies and the clock read in the entry script (4), two Durations lines, two Steps lines, and the sync-row sample line of Get-EpicProgressStepReport (Gather 1, unchanged from the baseline count).
