# Pester Test With Coverage ([P6-T3])

Timestamp: 2026-11-03T18-44
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib issue-1020-p6t3.log (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders 'tests/scripts/claude-lib'); counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1020-summary.ps1; missed-line attribution by SCRATCH/issue-1020-attrib.ps1 (AST FunctionDefinitionAst extents)
EXIT_CODE: 0
Output Summary: tests=3784 failures=0 errors=0 skipped=1 (127 suites). Every production file under .claude/lib/docs/ is present in the coverage report and at or above 85% line coverage; lowest is Invoke-DocsCommand.ps1 at 85.91% (128 covered, 21 missed). All 21 missed lines of Invoke-DocsCommand.ps1 lie inside the two capped bodies: 16 in Invoke-DocsProcess (cap 20) and 5 in Write-DocsFileText (cap 6); 0 outside. PASS.

## Counts (artifacts/pester/pester-junit.xml)

- tests: 3784
- failures: 0
- errors: 0
- skipped: 1 (root `disabled` attribute 1; the skipped test is outside `tests/scripts/claude-lib/docs/`)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 | 0 |
| Docs.Manifest.Tests.ps1 | 7 | 0 | 0 | 0 |
| DocsAnalyzerRegistry.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsFinding.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsJson.Tests.ps1 | 27 | 0 | 0 | 0 |
| DocsNeutrality.Tests.ps1 | 35 | 0 | 0 | 0 |
| DocsProfile.Tests.ps1 | 24 | 0 | 0 | 0 |
| DocsProfileCommands.Tests.ps1 | 22 | 0 | 0 | 0 |
| DocsSchema.Tests.ps1 | 37 | 0 | 0 | 0 |
| DocsSchemaContract.Tests.ps1 | 49 | 0 | 0 | 0 |
| DocsSchemaWalk.Tests.ps1 | 12 | 0 | 0 | 0 |
| DocsSurface.Tests.ps1 | 66 | 0 | 0 | 0 |
| Invoke-DocsCommand.Tests.ps1 | 44 | 0 | 0 | 0 |

## Per-file line coverage (artifacts/pester/powershell-coverage.xml)

| File | covered | missed | percent | >= 85 |
|---|---|---|---|---|
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 119 | 0 | 100 | yes |
| .claude/lib/docs/DocsFinding.psm1 | 88 | 0 | 100 | yes |
| .claude/lib/docs/DocsJson.psm1 | 102 | 0 | 100 | yes |
| .claude/lib/docs/DocsProfile.psm1 | 81 | 0 | 100 | yes |
| .claude/lib/docs/DocsProfileCommands.psm1 | 67 | 2 | 97.1 | yes |
| .claude/lib/docs/DocsSchema.psm1 | 127 | 0 | 100 | yes |
| .claude/lib/docs/DocsSchemaWalk.psm1 (split module) | 87 | 0 | 100 | yes |
| .claude/lib/docs/DocsSurface.psm1 | 130 | 0 | 100 | yes |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 128 | 21 | 85.91 | yes |

All nine production PowerShell files (the eight planned files plus the split module `DocsSchemaWalk.psm1`) appear in the report; none is absent and none is excluded.

## Invoke-DocsCommand.ps1 missed-line attribution

AST extents read with `[System.Management.Automation.Language.Parser]::ParseFile`:

- `Invoke-DocsProcess`: lines 195-224
- `Write-DocsFileText`: lines 226-245

| Missed lines (report) | Owner | Count | Cap |
|---|---|---|---|
| 207, 209-223 | Invoke-DocsProcess | 16 | 20 |
| 240-244 | Write-DocsFileText | 5 | 6 |
| (none) | outside both bodies | 0 | 0 |

Result: ATTRIBUTION_OK=True. Every missed line lies inside one of the two bodies, within budget. No fix was required.

Note: the overall percentage of this run (32.95%) is not a gate here, because the coverage population derived from `config/poshqc-coverage.json` spans more than the `tests/scripts/claude-lib` scan scope; the overall figure is taken from the `tests/scripts` run in [P6-T6].

CI: `poshqc / PowerShell QC` (windows-latest).
