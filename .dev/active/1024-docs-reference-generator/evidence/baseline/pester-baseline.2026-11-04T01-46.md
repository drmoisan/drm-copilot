# Pester Baseline with Coverage (issue 1024)

Timestamp: 2026-11-04T01-46
Task: [P0-T7]
Command: sh SCRATCH/issue-1024-run.sh SCRATCH/issue-1024-pester.ps1 (Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs, tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1, tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1024-report.ps1
EXIT_CODE: 0
Output Summary: JUnit tests=804, failures=0, errors=0 (passed 804, failed 0). Pester 5.9.1, PowerShell 7.6. Line coverage of the existing `.claude/lib/docs` files is listed below; the whole coverage population (config/poshqc-coverage.json roots) reported 8.72% because only the docs suites ran. NEW-MODULES are not present.

## Line coverage per existing LIB file

| File | Line coverage | Covered/Total |
|---|---|---|
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 100% | 119/119 |
| `.claude/lib/docs/DocsFinding.psm1` | 100% | 88/88 |
| `.claude/lib/docs/DocsJson.psm1` | 100% | 102/102 |
| `.claude/lib/docs/DocsPageCheck.psm1` | 100% | 159/159 |
| `.claude/lib/docs/DocsPageDiataxis.psm1` | 100% | 54/54 |
| `.claude/lib/docs/DocsPageFrontMatter.psm1` | 100% | 183/183 |
| `.claude/lib/docs/DocsPageLinks.psm1` | 100% | 114/114 |
| `.claude/lib/docs/DocsPageMarkdown.psm1` | 100% | 102/102 |
| `.claude/lib/docs/DocsPageMetadata.psm1` | 100% | 109/109 |
| `.claude/lib/docs/DocsPageOrphans.psm1` | 100% | 28/28 |
| `.claude/lib/docs/DocsProfile.psm1` | 100% | 81/81 |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 97.3% | 72/74 |
| `.claude/lib/docs/DocsSchema.psm1` | 100% | 129/129 |
| `.claude/lib/docs/DocsSchemaWalk.psm1` | 100% | 87/87 |
| `.claude/lib/docs/DocsSurface.psm1` | 100% | 130/130 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 87.42% | 132/151 |

## NEW-MODULES

| File | State |
|---|---|
| `.claude/lib/docs/DocsReferencePlan.psm1` | not present |
| `.claude/lib/docs/DocsReferenceRender.psm1` | not present |
| `.claude/lib/docs/DocsReferenceMarkers.psm1` | not present |
| `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | not present |
| `.claude/lib/docs/DocsReferenceWriter.psm1` | not present |
| `.claude/lib/docs/DocsReferenceReport.psm1` | not present |

## Pre-existing failures under fix on main

Issues #1066 (`$env:PATH` leak in `run-actionlint.Tests.ps1`) and #1067 (platform-dependent Pester fixtures in the dev-tools and PoshQC suites) are pre-existing and are not caused by this feature. Neither suite is in this baseline's scan set, so neither appears in the counts above; they will be recorded as pre-existing if a later run that covers `tests/scripts` reports them.
