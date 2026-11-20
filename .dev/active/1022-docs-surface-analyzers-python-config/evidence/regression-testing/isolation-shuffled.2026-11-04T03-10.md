# [P6-T5] Seeded shuffled file-order isolation runs (issue #1022)

Timestamp: 2026-11-04T03-10
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p6t5-shuffle.ps1 -WorktreeRoot <item worktree> -Seed <seed>, once per seed 1022, 4711 and 90210, each in a new single PowerShell process (the order is a Fisher-Yates shuffle of the 21 suite paths driven by `[System.Random]::new($seed).Next`; the suites run through SCRATCH/issue-1022-pester-suite.ps1, which calls Invoke-Pester with scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, no coverage, JUnit to artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Three seeds, 21 suites each (the nineteen new 1022 suites plus `DocsAnalyzerRegistry.Tests.ps1` and `Invoke-DocsCommand.Tests.ps1`): seed 1022 383 passed / 0 failed / 0 skipped; seed 4711 383 / 0 / 0; seed 90210 383 / 0 / 0. JUnit file well-formed for each run and equal to the result object counts. No order dependence found.

Note: the plan text names eighteen new suites (seventeen module suites plus `DocsInventoryProperties.Tests.ps1`); the [P1-T3] split added `DocsPythonBindings.Tests.ps1`, so nineteen new suites run. Invoke-Pester runs `Run.Path` in the order supplied; the `testsuite` order of the seed 90210 JUnit file equals the order listed below.

## Seed 1022

Count source: `artifacts/pester/pester-junit.xml` (well-formed: tests=383 failures=0 errors=0 skipped=0), equal to the result object (Passed=383 Failed=0 Skipped=0).

Order: DocsPythonCliTyper, DocsSourceText, DocsAnalyzerArchitecture, DocsTomlKeys, DocsJsonSchemaKeys, DocsPythonCliArgparse, DocsAnalyzerConfigFiles, DocsPythonCliClick, DocsPythonHttpSites, DocsPythonBindings, DocsAnalyzerRegistry, DocsPythonTokens, DocsYamlKeys, DocsInventoryProperties, DocsInventory, DocsInventorySnapshot, DocsAnalyzerPythonCli, DocsAnalyzerPythonHttp, DocsPythonSyntax, Invoke-DocsCommand, DocsAnalyzerPythonApi (each `tests/scripts/claude-lib/docs/<name>.Tests.ps1`).

## Seed 4711

Count source: `artifacts/pester/pester-junit.xml` (well-formed: tests=383 failures=0 errors=0 skipped=0), equal to the result object (Passed=383 Failed=0 Skipped=0).

Order: DocsPythonCliClick, DocsInventorySnapshot, DocsPythonCliTyper, DocsJsonSchemaKeys, DocsPythonHttpSites, Invoke-DocsCommand, DocsAnalyzerConfigFiles, DocsPythonBindings, DocsInventory, DocsTomlKeys, DocsSourceText, DocsYamlKeys, DocsAnalyzerArchitecture, DocsAnalyzerPythonHttp, DocsAnalyzerPythonCli, DocsPythonCliArgparse, DocsAnalyzerRegistry, DocsPythonTokens, DocsAnalyzerPythonApi, DocsPythonSyntax, DocsInventoryProperties.

## Seed 90210

Count source: `artifacts/pester/pester-junit.xml` (well-formed: tests=383 failures=0 errors=0 skipped=0), equal to the result object (Passed=383 Failed=0 Skipped=0).

Order: DocsAnalyzerConfigFiles, DocsJsonSchemaKeys, DocsInventory, DocsInventoryProperties, DocsAnalyzerRegistry, DocsSourceText, DocsPythonHttpSites, DocsAnalyzerPythonCli, DocsInventorySnapshot, DocsPythonCliArgparse, DocsPythonCliClick, DocsPythonBindings, DocsAnalyzerPythonApi, DocsYamlKeys, DocsPythonTokens, Invoke-DocsCommand, DocsAnalyzerPythonHttp, DocsTomlKeys, DocsPythonCliTyper, DocsPythonSyntax, DocsAnalyzerArchitecture.
