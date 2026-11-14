# Remediation cycle 1 coverage comparison against the main final gate (P2-T3)

Timestamp: 2026-11-09T17-52
Command: sh SCRATCH/issue-1153-summary.sh (per-file and repo-wide LINE counters of artifacts/pester/powershell-coverage.xml from the P2-T2 run recorded in evidence/qa-gates/pester.2026-11-09T17-52.md); then sh SCRATCH/run-ps.sh SCRATCH/issue-1153-addedcov.ps1 (for each script under .claude/skills/epic-progress-report/scripts: the added lines of git diff -U0 <merge base of origin/main and HEAD> HEAD, intersected with the executable lines of the same coverage report)
EXIT_CODE: 0
Output Summary:
  Reference: evidence/qa-gates/coverage-comparison.2026-11-09T16-54.md (main final gate). Post-change: the P2-T2 run (21216 tests, 0 failures).

  | File | Main final gate | Post-change | Result |
  |---|---|---|---|
  | Get-EpicProgressReport.ps1 | 107/111 96.40% | 107/111 96.40% | no drop |
  | Get-EpicProgressReport.Durations.ps1 | 122/124 98.39% | 122/124 98.39% | no drop |
  | Get-EpicProgressReport.Gather.ps1 | 196/197 99.49% | 196/197 99.49% | no drop |
  | Get-EpicProgressReport.Logic.ps1 | 72/72 100% | 73/73 100% | no drop |
  | Get-EpicProgressReport.Metrics.ps1 | 59/59 100% | 59/59 100% | no drop |
  | Get-EpicProgressReport.Render.ps1 | 222/222 100% | 222/222 100% | no drop |
  | Get-EpicProgressReport.Stages.ps1 | 60/60 100% | 60/60 100% | no drop |
  | Get-EpicProgressReport.State.ps1 | 152/152 100% | 153/153 100% | no drop |
  | Get-EpicProgressReport.Steps.ps1 | 135/137 98.54% | 135/137 98.54% | no drop |
  | Get-EpicProgressReport.Velocity.ps1 | 94/94 100% | 109/109 100% | no drop |
  | Get-EpicProgressReport.Schedule.ps1 | 305/305 100% | 203/203 100% | no drop (compared by percentage; 102 lines moved to CriticalPath) |
  | Get-EpicProgressReport.CriticalPath.ps1 | new file (no pre-change run) | 102/102 100% | at least 90% |

  Every file is at least 85% with no drop against the main final gate; Get-EpicProgressReport.CriticalPath.ps1 is 100% (at least 90%). Schedule 203 + CriticalPath 102 = 305 executable lines, equal to the Schedule figure before the split.
  Added executable lines since the merge base of origin/main and HEAD: 661 of 661 covered (100%): CriticalPath 102/102, Gather 68/68, Logic 3/3, Metrics 3/3, entry 28/28, Render 100/100, Schedule 203/203, State 45/45, Velocity 109/109; Durations, Stages, and Steps have no added line.
  Repo-wide line coverage: 95.79% main final gate, 95.80% post-change (37492 covered, 1645 missed; no drop).
  No shortfall; no test was added in this task.
  The remaining missed lines are unchanged from the main final gate: the native wrapper bodies and the clock read in the entry script (4), two Durations lines, two Steps lines, and one Gather line.
