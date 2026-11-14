# [P6-T9] File size (issue #1022)

Timestamp: 2026-11-04T03-23
Command: (1) pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 -Verbosity None; (2) pwsh -NoProfile -File SCRATCH/issue-1022-p6t9-lines.ps1 -WorktreeRoot <item worktree>, which prints `@(Get-Content -LiteralPath <path>).Count` for every `.psm1` and `.ps1` file added under `.claude/lib/docs` and `tests/scripts/claude-lib/docs` since MERGE_BASE (`git diff --name-only --diff-filter=A`)
EXIT_CODE: 0
Output Summary: Pester gate: `FileSizePolicy.RepoGate.Tests.ps1` 5 passed, 0 failed (JUnit well-formed, tests=5 failures=0 errors=0 skipped=0), including `reports zero ratchet violations against config/file-size-baseline.json` (Passed). 37 new files counted: the largest production file is `DocsPythonSyntax.psm1` with 370 lines (every one of the 18 below 500); the largest test file is `DocsPythonBindings.Tests.ps1` with 369 lines (every one of the 19 at most 800). The eighteen new modules are one more than the plan text's seventeen because of the [P1-T3] split. The two edited files grew by 5 and 1 lines and stay below 500 (the [P6-T8] numstat). The JSON corpus fixtures are test fixture data and are not production, test-code or script files.

## Production files (limit: below 500)

| File | Lines |
|---|---|
| `.claude/lib/docs/DocsAnalyzerArchitecture.psm1` | 210 |
| `.claude/lib/docs/DocsAnalyzerConfigFiles.psm1` | 306 |
| `.claude/lib/docs/DocsAnalyzerPythonApi.psm1` | 277 |
| `.claude/lib/docs/DocsAnalyzerPythonCli.psm1` | 252 |
| `.claude/lib/docs/DocsAnalyzerPythonHttp.psm1` | 254 |
| `.claude/lib/docs/DocsInventory.psm1` | 278 |
| `.claude/lib/docs/DocsInventorySnapshot.psm1` | 255 |
| `.claude/lib/docs/DocsJsonSchemaKeys.psm1` | 288 |
| `.claude/lib/docs/DocsPythonBindings.psm1` | 302 |
| `.claude/lib/docs/DocsPythonCliArgparse.psm1` | 243 |
| `.claude/lib/docs/DocsPythonCliClick.psm1` | 288 |
| `.claude/lib/docs/DocsPythonCliTyper.psm1` | 281 |
| `.claude/lib/docs/DocsPythonHttpSites.psm1` | 276 |
| `.claude/lib/docs/DocsPythonSyntax.psm1` | 370 |
| `.claude/lib/docs/DocsPythonTokens.psm1` | 233 |
| `.claude/lib/docs/DocsSourceText.psm1` | 327 |
| `.claude/lib/docs/DocsTomlKeys.psm1` | 321 |
| `.claude/lib/docs/DocsYamlKeys.psm1` | 279 |

The `MIRROR` copies are byte-identical ([P5-T1], re-proven by the [P6-T7] contract tests) and have the same counts.

## Test files (limit: at most 800)

| File | Lines |
|---|---|
| `tests/scripts/claude-lib/docs/DocsAnalyzerArchitecture.Tests.ps1` | 228 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerConfigFiles.Tests.ps1` | 328 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonApi.Tests.ps1` | 217 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonCli.Tests.ps1` | 202 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonHttp.Tests.ps1` | 193 |
| `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1` | 341 |
| `tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1` | 328 |
| `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` | 305 |
| `tests/scripts/claude-lib/docs/DocsJsonSchemaKeys.Tests.ps1` | 246 |
| `tests/scripts/claude-lib/docs/DocsPythonBindings.Tests.ps1` | 369 |
| `tests/scripts/claude-lib/docs/DocsPythonCliArgparse.Tests.ps1` | 193 |
| `tests/scripts/claude-lib/docs/DocsPythonCliClick.Tests.ps1` | 234 |
| `tests/scripts/claude-lib/docs/DocsPythonCliTyper.Tests.ps1` | 233 |
| `tests/scripts/claude-lib/docs/DocsPythonHttpSites.Tests.ps1` | 297 |
| `tests/scripts/claude-lib/docs/DocsPythonSyntax.Tests.ps1` | 346 |
| `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | 205 |
| `tests/scripts/claude-lib/docs/DocsSourceText.Tests.ps1` | 318 |
| `tests/scripts/claude-lib/docs/DocsTomlKeys.Tests.ps1` | 252 |
| `tests/scripts/claude-lib/docs/DocsYamlKeys.Tests.ps1` | 186 |

CI: `poshqc / PowerShell QC` (windows-latest shards).
