# Seeded Shuffled File-Order Isolation ([P6-T5])

Timestamp: 2026-11-03T18-50
Command: sh SCRATCH/issue-1020-ps.sh issue-1020-shuffle.ps1 -Seed <seed>, once each for seeds 1020, 20261030, 7 (PowerShell 7, one process per seed; SCRATCH/issue-1020-shuffle.ps1 collects every `*.Tests.ps1` under `tests/scripts/claude-lib/docs/` sorted by name plus `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, applies a Fisher-Yates shuffle driven by `[System.Random]::new(<seed>)`, and runs `Invoke-Pester` with `Run.Path` set to the shuffled list in one process; no coverage)
EXIT_CODE: 0
Output Summary: 3 of 3 seeds passed. Each run: 13 files, 389 tests, 389 passed, 0 failed, 0 skipped, 0 failed containers. The executed container order (Pester `Containers` in result order) equals the shuffled order for each seed. No order dependence found.

The 13 files are the twelve suites under `tests/scripts/claude-lib/docs/` (the eleven planned suites plus `DocsSchemaWalk.Tests.ps1`, the suite of the split module) and `ClaudeLibModuleConvention.Tests.ps1`.

## Seed 1020

- Order: DocsNeutrality.Tests.ps1 | DocsJson.Tests.ps1 | DocsSchemaWalk.Tests.ps1 | Invoke-DocsCommand.Tests.ps1 | DocsProfile.Tests.ps1 | Docs.Manifest.Tests.ps1 | DocsSurface.Tests.ps1 | ClaudeLibModuleConvention.Tests.ps1 | DocsProfileCommands.Tests.ps1 | DocsFinding.Tests.ps1 | DocsSchemaContract.Tests.ps1 | DocsAnalyzerRegistry.Tests.ps1 | DocsSchema.Tests.ps1
- Counts: total=389 passed=389 failed=0 skipped=0 notrun=0 containersFailed=0; EXIT_CODE: 0

## Seed 20261030

- Order: ClaudeLibModuleConvention.Tests.ps1 | DocsProfileCommands.Tests.ps1 | DocsSurface.Tests.ps1 | DocsProfile.Tests.ps1 | DocsJson.Tests.ps1 | DocsSchema.Tests.ps1 | Docs.Manifest.Tests.ps1 | DocsSchemaWalk.Tests.ps1 | Invoke-DocsCommand.Tests.ps1 | DocsAnalyzerRegistry.Tests.ps1 | DocsNeutrality.Tests.ps1 | DocsFinding.Tests.ps1 | DocsSchemaContract.Tests.ps1
- Counts: total=389 passed=389 failed=0 skipped=0 notrun=0 containersFailed=0; EXIT_CODE: 0

## Seed 7

- Order: DocsProfileCommands.Tests.ps1 | DocsFinding.Tests.ps1 | DocsAnalyzerRegistry.Tests.ps1 | DocsSchemaContract.Tests.ps1 | ClaudeLibModuleConvention.Tests.ps1 | Invoke-DocsCommand.Tests.ps1 | DocsSchemaWalk.Tests.ps1 | DocsProfile.Tests.ps1 | DocsJson.Tests.ps1 | Docs.Manifest.Tests.ps1 | DocsSchema.Tests.ps1 | DocsSurface.Tests.ps1 | DocsNeutrality.Tests.ps1
- Counts: total=389 passed=389 failed=0 skipped=0 notrun=0 containersFailed=0; EXIT_CODE: 0
