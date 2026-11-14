# Task Check P3-T2

Timestamp: 2026-11-14T05-26
Command: sh SCRATCH/issue-1162-tc.sh "<changed files>" "tests/scripts/claude-skills/epic-progress-report;tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1"
EXIT_CODE: 1
Output Summary: format differences 0; analyzer findings 0; Pester passed=467 failed=3 total=470. Every Schedule, CriticalPath, Schedule.Range, and golden test passes. The three failures are in EpicProgressReport.SkillContract.Tests.ps1 and are owned by later plan tasks (listed below).

## Changed files (WIP commit, verified against the task text)

- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1: Compare-EpicProgressIssue orders a numeric issue before any non-numeric node and two non-numeric nodes by ordinal text; Invoke-EpicProgressListSchedule reads the optional External property and an external node holds no cap slot.
- .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.CriticalPath.ps1: Get-EpicProgressCriticalChain prints an external node as slug#issue with no leading '#'; Get-EpicProgressScheduleRange re-prices external nodes through Get-EpicProgressExternalSecond at each side rate; Get-EpicProgressCriticalPathReport feeds external nodes into the schedule (no feature row, no serial-sum share) and returns CrossEpic rows.
- tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Schedule.Tests.ps1: cap-1 start at 0, the four Compare-EpicProgressIssue orderings, the blocked closure without the external node, and the unchanged wave edges and dependency graph with a raw cross_epic_depends_on value.
- tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CriticalPath.Tests.ps1: chain lengthened by a pending external prerequisite, range re-pricing equal to a local twin, and report wiring without a feature row.

## Selection and rule

Every file under tests/scripts/claude-skills/epic-progress-report dot-sources the entry script, which dot-sources the changed part files, so the selection is that folder plus the forwarder suite tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 that names the entry script.

## Failures owned by later tasks

- EpicProgressReport.SkillContract.Tests.ps1 'states the report format fragments' (external (default) in Report Formats): P3-T4.
- EpicProgressReport.SkillContract.Tests.ps1 'lists every skill-folder file exactly once in core.json' (Get-EpicProgressReport.CrossEpic.ps1): P4-T5.
- EpicProgressReport.SkillContract.Tests.ps1 'mirrors every skill-folder file byte-identically in the bundle' (SKILL.md): P4-T5.
