# Isolation - Seeded Shuffled File Order - issue #1021, remediation cycle 1

Timestamp: 2026-11-04T00-58
Task: [P3-T6]
Command: `sh SCRATCH/issue-1021-shuffle.sh` (for each seed, one PowerShell 7 process running `SCRATCH/issue-1021-shuffle.ps1 -Seed <seed>`: the `*.Tests.ps1` files under `tests/scripts/claude-lib/docs` sorted ordinally, then shuffled by Fisher-Yates with `System.Random(<seed>)`, then run by `Invoke-Pester` with `Run.Path` in that order and `Run.PassThru`)
EXIT_CODE: 0
Output Summary: 23 suites per seed; seed 1021: 765 passed, 0 failed; seed 20261030: 765 passed, 0 failed; seed 7: 765 passed, 0 failed. No failed block or container. `DocsPageCheck.LinkMap.Tests.ps1` appears in every order.

## Seed 1021

Result: total=765 passed=765 failed=0 skipped=0 failedBlocks=0 failedContainers=0

Order: DocsSchema.Tests.ps1, DocsPageDiataxis.Tests.ps1, DocsProfileCommands.Tests.ps1, Invoke-DocsCommand.Tests.ps1, DocsAnalyzerRegistry.Tests.ps1, DocsSchemaContract.Tests.ps1, Docs.Manifest.Tests.ps1, DocsSurface.Tests.ps1, DocsPageMetadataSchema.Tests.ps1, DocsPageMarkdown.Tests.ps1, DocsPageCheck.LinkMap.Tests.ps1, DocsPageMetadata.Tests.ps1, DocsProfile.Tests.ps1, DocsPageTemplates.Tests.ps1, DocsNeutrality.Tests.ps1, DocsPageLinks.Tests.ps1, DocsPageCheck.Tests.ps1, DocsPageOrphans.Tests.ps1, DocsJson.Tests.ps1, DocsSchemaWalk.Tests.ps1, DocsPageImportIsolation.Tests.ps1, DocsPageFrontMatter.Tests.ps1, DocsFinding.Tests.ps1

## Seed 20261030

Result: total=765 passed=765 failed=0 skipped=0 failedBlocks=0 failedContainers=0

Order: DocsPageLinks.Tests.ps1, DocsPageOrphans.Tests.ps1, DocsSchema.Tests.ps1, DocsPageImportIsolation.Tests.ps1, Invoke-DocsCommand.Tests.ps1, DocsPageDiataxis.Tests.ps1, DocsPageMetadataSchema.Tests.ps1, DocsSurface.Tests.ps1, DocsPageMetadata.Tests.ps1, Docs.Manifest.Tests.ps1, DocsProfile.Tests.ps1, DocsSchemaContract.Tests.ps1, DocsSchemaWalk.Tests.ps1, DocsProfileCommands.Tests.ps1, DocsPageMarkdown.Tests.ps1, DocsFinding.Tests.ps1, DocsAnalyzerRegistry.Tests.ps1, DocsNeutrality.Tests.ps1, DocsPageCheck.Tests.ps1, DocsJson.Tests.ps1, DocsPageFrontMatter.Tests.ps1, DocsPageCheck.LinkMap.Tests.ps1, DocsPageTemplates.Tests.ps1

## Seed 7

Result: total=765 passed=765 failed=0 skipped=0 failedBlocks=0 failedContainers=0

Order: Invoke-DocsCommand.Tests.ps1, DocsPageImportIsolation.Tests.ps1, DocsSchema.Tests.ps1, DocsProfile.Tests.ps1, DocsPageLinks.Tests.ps1, DocsFinding.Tests.ps1, DocsPageOrphans.Tests.ps1, DocsJson.Tests.ps1, DocsPageDiataxis.Tests.ps1, DocsSurface.Tests.ps1, DocsNeutrality.Tests.ps1, DocsSchemaWalk.Tests.ps1, DocsPageCheck.LinkMap.Tests.ps1, DocsPageMarkdown.Tests.ps1, DocsProfileCommands.Tests.ps1, DocsPageTemplates.Tests.ps1, Docs.Manifest.Tests.ps1, DocsPageMetadata.Tests.ps1, DocsPageCheck.Tests.ps1, DocsAnalyzerRegistry.Tests.ps1, DocsPageMetadataSchema.Tests.ps1, DocsSchemaContract.Tests.ps1, DocsPageFrontMatter.Tests.ps1

## Notes

- The `closure of ...` lines and three `What if:` lines in the console are informational output of `DocsPageImportIsolation.Tests.ps1` and `-WhatIf` cases; they are not failures and no file is written.
