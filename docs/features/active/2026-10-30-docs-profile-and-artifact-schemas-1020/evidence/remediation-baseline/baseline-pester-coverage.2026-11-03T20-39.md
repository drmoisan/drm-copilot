# Pester baseline (cycle 1)

Timestamp: 2026-11-03T20-39
Command: Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib (module scripts/powershell/PoshQC/PoshQC.psd1, launched through a sh script under SCRATCH); counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: 3784 tests, 0 failures, 0 errors, 1 disabled. Invoke-DocsCommand.ps1 line coverage 85.91% (128 covered of 149; 21 missed).

Missed-line attribution (from the coverage XML, by function):

- Invoke-DocsProcess: 16 missed
- Write-DocsFileText: 5 missed
- all other functions: 0 missed

Per-suite counts under tests/scripts/claude-lib/docs: Docs.Manifest 7, DocsAnalyzerRegistry 30, DocsFinding 30, DocsJson 27, DocsNeutrality 35, DocsProfile 24, DocsProfileCommands 22, DocsSchema 37, DocsSchemaContract 49, DocsSchemaWalk 12, DocsSurface 66, Invoke-DocsCommand 44 (all 0 failures).
