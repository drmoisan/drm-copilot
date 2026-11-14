# Pester coverage gate (cycle 1, P2-T3)

Timestamp: 2026-11-03T20-49
Command: Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib (module scripts/powershell/PoshQC/PoshQC.psd1, launched through a sh script under SCRATCH); counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: 3786 tests, 0 failures, 0 errors, 1 disabled (baseline 3784; plus the 2 new -WhatIf tests). Invoke-DocsCommand.ps1 line coverage 87.33% (131 covered, 19 missed) against a baseline of 85.91% (128 covered, 21 missed); the threshold is 85%.

Missed-line attribution by function (from the coverage XML) against the P4-T4 budget:

- Invoke-DocsProcess: 16 missed, budget at most 20 (unchanged from baseline)
- Write-DocsFileText: 3 missed of 6, budget at most 6 (baseline 5 missed of 5); the ShouldProcess line is covered by the -WhatIf tests, and the guarded body lines (directory creation, stream creation, stream write) stay uncovered by design because tests create no files
- all other functions: 0 missed, budget none

Per-suite counts under tests/scripts/claude-lib/docs: Docs.Manifest 7, DocsAnalyzerRegistry 30, DocsFinding 30, DocsJson 27, DocsNeutrality 35, DocsProfile 24, DocsProfileCommands 22, DocsSchema 37, DocsSchemaContract 49, DocsSchemaWalk 12, DocsSurface 66, Invoke-DocsCommand 46 (all 0 failures).
