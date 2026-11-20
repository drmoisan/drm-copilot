# CI Shard Coverage Check-Off (S22, U14) — Issue 1022

Timestamp: 2026-11-04T04-22
Command: gh run download 41769642636 -n poshqc-test-results (into SCRATCH), then a SCRATCH parser over powershell-coverage.xml (JaCoCo LINE counters, source tree .claude/lib/docs)
EXIT_CODE: 0
Output Summary: PR #1072 head 1530b01607a285a2d00dbfe72a2490653420eefe, CI run 41769642636 (pull_request, CI full run success). All 24 checks pass, including the 20 required contexts of ruleset 15241672. Per-file line coverage from the merged `poshqc / PowerShell QC` report built from the `poshqc / PowerShell QC shard` 1-3 jobs on windows-latest: every one of the 18 new modules is at or above 99.22%; minimum across the 20 files listed below is 87.74% (Invoke-DocsCommand.ps1, a 1020 file edited by one row). S22 (spec.md) and U14 (user-story.md) are checked off.

| File | Covered/Total | Line % |
|---|---|---|
| DocsSourceText.psm1 | 114/114 | 100.00 |
| DocsPythonTokens.psm1 | 124/124 | 100.00 |
| DocsPythonSyntax.psm1 | 176/177 | 99.44 |
| DocsPythonBindings.psm1 | 161/161 | 100.00 |
| DocsTomlKeys.psm1 | 181/182 | 99.45 |
| DocsYamlKeys.psm1 | 151/152 | 99.34 |
| DocsJsonSchemaKeys.psm1 | 134/134 | 100.00 |
| DocsPythonCliArgparse.psm1 | 129/129 | 100.00 |
| DocsPythonCliClick.psm1 | 159/159 | 100.00 |
| DocsPythonCliTyper.psm1 | 147/147 | 100.00 |
| DocsAnalyzerPythonCli.psm1 | 117/117 | 100.00 |
| DocsPythonHttpSites.psm1 | 129/129 | 100.00 |
| DocsAnalyzerPythonHttp.psm1 | 136/136 | 100.00 |
| DocsAnalyzerPythonApi.psm1 | 149/149 | 100.00 |
| DocsAnalyzerArchitecture.psm1 | 100/100 | 100.00 |
| DocsAnalyzerConfigFiles.psm1 | 128/129 | 99.22 |
| DocsInventorySnapshot.psm1 | 92/92 | 100.00 |
| DocsInventory.psm1 | 100/100 | 100.00 |
| DocsAnalyzerRegistry.psm1 (edited, 1020) | 124/124 | 100.00 |
| Invoke-DocsCommand.ps1 (edited, 1020) | 136/155 | 87.74 |
