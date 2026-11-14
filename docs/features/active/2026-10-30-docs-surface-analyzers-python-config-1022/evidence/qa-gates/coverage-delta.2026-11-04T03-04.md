# [P6-T4] Coverage delta (issue #1022)

Timestamp: 2026-11-04T03-04
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p6t4-coverage.ps1 -WorktreeRoot <item worktree> (reads artifacts/pester/powershell-coverage.xml written by the [P6-T3] run: the root and per-class JaCoCo LINE counters, and the `line` hit records of the changed lines of the two edited 1020 files, which come from `git diff -U0 MERGE_BASE`)
EXIT_CODE: 0
Output Summary: Baseline overall 92.66% ([P0-T6]); post-change overall 93.33% ([P6-T3]). All eighteen new `.claude/lib/docs` modules are measured and each is at least 85% (minimum 99.22%, `DocsAnalyzerConfigFiles.psm1`). Every changed line of the two edited files is covered: `DocsAnalyzerRegistry.psm1` lines 37 to 41 (5/5) and `Invoke-DocsCommand.ps1` line 59 (1/1). No production file is excluded from measurement (`config/poshqc-coverage.json` measures `.claude/lib`; 287 files). S22 and U14 stay pending-CI until the `poshqc / PowerShell QC` shard jobs report.

Note: the plan text names seventeen new modules; `DocsPythonSyntax.psm1` was split into `DocsPythonSyntax.psm1` and `DocsPythonBindings.psm1` during [P1-T3] under the 500-line rule (`## Artifact Classification`), so eighteen modules are measured.

## Per-file line coverage (new modules)

| File | Line coverage | Covered / lines |
|---|---|---|
| `.claude/lib/docs/DocsSourceText.psm1` | 100% | 114 / 114 |
| `.claude/lib/docs/DocsPythonTokens.psm1` | 100% | 124 / 124 |
| `.claude/lib/docs/DocsPythonSyntax.psm1` | 99.44% | 176 / 177 |
| `.claude/lib/docs/DocsPythonBindings.psm1` | 100% | 161 / 161 |
| `.claude/lib/docs/DocsTomlKeys.psm1` | 99.45% | 181 / 182 |
| `.claude/lib/docs/DocsYamlKeys.psm1` | 99.34% | 151 / 152 |
| `.claude/lib/docs/DocsJsonSchemaKeys.psm1` | 100% | 134 / 134 |
| `.claude/lib/docs/DocsPythonCliArgparse.psm1` | 100% | 129 / 129 |
| `.claude/lib/docs/DocsPythonCliClick.psm1` | 100% | 159 / 159 |
| `.claude/lib/docs/DocsPythonCliTyper.psm1` | 100% | 147 / 147 |
| `.claude/lib/docs/DocsAnalyzerPythonCli.psm1` | 100% | 117 / 117 |
| `.claude/lib/docs/DocsPythonHttpSites.psm1` | 100% | 129 / 129 |
| `.claude/lib/docs/DocsAnalyzerPythonHttp.psm1` | 100% | 136 / 136 |
| `.claude/lib/docs/DocsAnalyzerPythonApi.psm1` | 100% | 149 / 149 |
| `.claude/lib/docs/DocsAnalyzerArchitecture.psm1` | 100% | 100 / 100 |
| `.claude/lib/docs/DocsAnalyzerConfigFiles.psm1` | 99.22% | 128 / 129 |
| `.claude/lib/docs/DocsInventorySnapshot.psm1` | 100% | 92 / 92 |
| `.claude/lib/docs/DocsInventory.psm1` | 100% | 100 / 100 |

## Edited 1020 files

| File | Baseline ([P0-T6]) | Post-change | Changed lines covered |
|---|---|---|---|
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 100% (119 / 119) | 100% (124 / 124) | 37, 38, 39, 40, 41 (each hit 9 times): 5 / 5 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 87.33% (131 / 150) | 87.42% (132 / 151) | 59 (hit 10 times): 1 / 1 |

Result: PASS (no value below 85).
