# Pester and coverage baseline ([P0-T3])

Timestamp: 2026-11-04T14-36
Command: sh SCRATCH/issue-1033-poshqc-test.sh (PowerShell 7: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs` in one process; counts read from artifacts/pester/pester-junit.xml and per-file line coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1033-summary.ps1)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: tests=1668, passed=1666, failures=2, errors=0, skipped=0 (86 suite files). The two failures are exactly the two F1 tests; no other failure. This is the F1 fail-before record. Line coverage: DocsAnalyzerDotnetHttp.psm1 99.43% (173/174), DocsExtensionShape.psm1 100.00% (103/103), DocsAnalyzerExtensionImport.psm1 100.00% (195/195).

## Failing tests (JUnit `testcase` elements with a failure)

1. `Invoke-DocsInventoryCommand.exits 0 with a dry-run snapshot, no finding, no WriteText call, revision null and the fixed clock` (`tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1`)
2. `New-DocsInventorySnapshot over both corpora.validates against surface-inventory-snapshot through Test-DocsArtifactText with no finding and carries the header fields` (`tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1`)

Both fail on the exact five-entry analyzer list, because the merged registry also lists the seven 1033 analyzers.

## Line coverage of the three touched modules

| Module | covered | lines | line coverage % |
|---|---|---|---|
| `.claude/lib/docs/DocsAnalyzerDotnetHttp.psm1` | 173 | 174 | 99.43 |
| `.claude/lib/docs/DocsExtensionShape.psm1` | 103 | 103 | 100.00 |
| `.claude/lib/docs/DocsAnalyzerExtensionImport.psm1` | 195 | 195 | 100.00 |
