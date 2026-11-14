# Seeded shuffled isolation runs of the touched suites ([P5-T5])

Timestamp: 2026-11-04T15-28
Command: sh SCRATCH/issue-1033-shuffle.sh (three separate single-process PowerShell 7 runs of SCRATCH/issue-1033-shuffle.ps1 -Seed <n>: a Fisher-Yates shuffle of the five suite paths driven by `[System.Random]::new(<n>)`, then one `Invoke-Pester` call with `Run.Path` in that order and `Run.PassThru`; counts from the result object)
EXIT_CODE: 0
Output Summary: seeds 1033, 4242 and 7 each ran 133 tests with 133 passed, 0 failed, 0 skipped, 0 failed containers. No order dependence observed.

| Seed | File order (supplied to `Run.Path`) | Total | Passed | Failed |
|---|---|---|---|---|
| 1033 | DocsAnalyzerExtensionImport, DocsInventory, DocsAnalyzerDotnetHttp, DocsExtensionShape, DocsInventorySnapshot | 133 | 133 | 0 |
| 4242 | DocsInventory, DocsExtensionShape, DocsAnalyzerDotnetHttp, DocsInventorySnapshot, DocsAnalyzerExtensionImport | 133 | 133 | 0 |
| 7 | DocsAnalyzerDotnetHttp, DocsInventory, DocsAnalyzerExtensionImport, DocsExtensionShape, DocsInventorySnapshot | 133 | 133 | 0 |

Suites (all under `tests/scripts/claude-lib/docs/`, `.Tests.ps1` suffix omitted in the table): `DocsInventory`, `DocsInventorySnapshot`, `DocsAnalyzerDotnetHttp`, `DocsExtensionShape`, `DocsAnalyzerExtensionImport`. The single-process docs-folder run of [P5-T3] (1671 tests, 0 failures) is the companion fresh-process run.
