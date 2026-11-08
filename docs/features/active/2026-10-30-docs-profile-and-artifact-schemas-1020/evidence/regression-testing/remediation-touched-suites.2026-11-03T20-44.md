# Touched suites (cycle 1, P1-T6)

Timestamp: 2026-11-03T20-44
Command: Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs (module scripts/powershell/PoshQC/PoshQC.psd1, launched through a sh script under SCRATCH); counts read from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: 385 tests, 0 failures, 0 errors (baseline for the same folder was 383).

Required suites (all 0 failures):

- Invoke-DocsCommand.Tests.ps1: 46 tests (baseline 44, plus exactly 2)
- DocsProfileCommands.Tests.ps1: 22 tests (baseline 22, unchanged)
- DocsSchema.Tests.ps1: 37 tests (baseline 37, unchanged)
- Docs.Manifest.Tests.ps1: 7 tests (baseline 7, unchanged; byte-identical bundle check passes)

Invoke-DocsCommand.ps1 line coverage from this run: 87.33% (131 covered, 19 missed).
