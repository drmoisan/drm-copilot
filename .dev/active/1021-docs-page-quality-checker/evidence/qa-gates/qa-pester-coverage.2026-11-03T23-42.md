# QA Pester and Coverage - Issue #1021

Timestamp: 2026-11-03T23-42
Task: [P6-T3]
Command: `sh SCRATCH/issue-1021-qa-pester.sh tests/scripts/claude-lib issue-1021-qa-claudelib2.txt` (PowerShell 7: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1`; `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib`, one process, repository run settings with coverage; counts from `artifacts/pester/pester-junit.xml`, per-file line coverage from `artifacts/pester/powershell-coverage.xml`)
EXIT_CODE: 0
Output Summary: JUnit `tests=4162 failures=0 errors=0 skipped=1`. Line coverage per new module: `DocsPageMarkdown.psm1` 100.00% (102 of 102), `DocsPageFrontMatter.psm1` 100.00% (180 of 180), `DocsPageMetadata.psm1` 100.00% (109 of 109), `DocsPageLinks.psm1` 100.00% (114 of 114), `DocsPageDiataxis.psm1` 100.00% (54 of 54), `DocsPageOrphans.psm1` 100.00% (28 of 28), `DocsPageCheck.psm1` 100.00% (157 of 157); each is at least 85% and none is absent from the report. No further split module exists. CI: CI-PESTER.

## Edited 1020 files (same run)

- `Invoke-DocsCommand.ps1` 87.42% (132 of 151)
- `DocsSchema.psm1` 100.00% (129 of 129)
- `DocsProfileCommands.psm1` 97.30% (72 of 74)

## Notes

- EVIDENCE_LOCATION_OVERRIDE_REJECTED: `<FEATURE>/evidence/coverage/` (spec coverage criterion, user-story U10) replaced with `<FEATURE>/evidence/qa-gates/` (plan `## Execution Context`).
- The overall figure of this scoped run (35.03%, 8548 of 24403) covers the whole configured coverage population while only the `tests/scripts/claude-lib` suites run, so it is not a project figure; the project figure comes from the `tests/scripts` run of [P6-T6].
- No production file is excluded: `config/poshqc-coverage.json` lists `.claude/lib` and is not edited. No branch figure applies to Pester.
- An earlier pass of this task (before the `DocsPageCheck.Tests.ps1` size trim and the loop restart) reported `tests=4164 failures=0 errors=0` with identical per-file figures.
