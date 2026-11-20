# Relocation Renames — Issue #1093

Timestamp: 2026-11-06T23-58
Command: git show --find-renames --name-status --format= HEAD (run immediately after the P1-T1 relocation commit, whose subject is `refactor(epic-progress-report): relocate the report scripts and suites into the skill folder (P1-T1)`)
EXIT_CODE: 0
Output Summary: four `R` entries; both production files are `R100` (byte-identical renames); the two suites are `R099` and `R098` (path lines and header comments repointed to the canonical folder).

```text
R100	scripts/dev-tools/Get-EpicProgressReport.Logic.ps1	.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1
R100	scripts/dev-tools/Get-EpicProgressReport.ps1	.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1
R099	tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1	tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1
R098	tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1	tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1
```

Relocated suites after the commit (sh SCRATCH/issue-1093-quick.sh, plain Pester 6 run of the two suites): `Get-EpicProgressReport.Logic.Tests.ps1` 74 passed, 0 failed; `Get-EpicProgressReport.Tests.ps1` 32 passed, 0 failed. Both equal the per-suite passed counts recorded in P0-T6 (74 and 32).

This artifact is the AC-09 rename proof: the forwarder recreated in P4-T1 keeps the old entry path, so a later range diff reports the canonical entry as added.
