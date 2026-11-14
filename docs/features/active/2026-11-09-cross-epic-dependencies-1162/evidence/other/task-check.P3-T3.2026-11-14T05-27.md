# Task Check P3-T3

Timestamp: 2026-11-14T05-27
Command: sh SCRATCH/issue-1162-tc.sh "<changed files>" "tests/scripts/claude-skills/epic-progress-report;tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1"
EXIT_CODE: 1
Output Summary: format differences 0; analyzer findings 0; Pester passed=467 failed=3 total=470. Every Render, Render.CriticalPath, and Invoke-EpicProgressReport test passes, including the golden TL;DR and Full expectations. The three failures are the same EpicProgressReport.SkillContract.Tests.ps1 cases recorded in task-check.P3-T2, owned by P3-T4 (external (default) fragment) and P4-T5 (core.json listing and bundle byte identity).

## Changed files (WIP commit, verified against the task text)

- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1: Get-EpicProgressCriticalPathLine adds one '**Cross-epic:**' bold-label line only when CrossEpic rows exist.
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1: Invoke-EpicProgressReport builds edges and external nodes with call sites only (no item-mode edges) and passes them to Get-EpicProgressCriticalPathReport.
- tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.CriticalPath.Tests.ps1: the Cross-epic line, its absence without an edge, the chain label, and the five TL;DR prefixes.
- tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1: Describe 'Invoke-EpicProgressReport' case showing an unchanged TL;DR first line with a pending cross-epic edge (Invoke-GitExe is mocked in that Describe).

## Selection and rule

Every file under tests/scripts/claude-skills/epic-progress-report dot-sources the entry script, so the selection is that folder plus the forwarder suite tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1.

## File size

wc -l: Get-EpicProgressReport.ps1 534, Get-EpicProgressReport.Render.ps1 453, Get-EpicProgressReport.Schedule.ps1 505, Get-EpicProgressReport.CriticalPath.ps1 332, Get-EpicProgressReport.Tests.ps1 699, Get-EpicProgressReport.Render.CriticalPath.Tests.ps1 287. No edited file reaches 700 lines.
