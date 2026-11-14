# Isolation: Seeded Shuffled File Order - Issue #1021

Timestamp: 2026-11-03T23-46
Task: [P6-T5]
Command: `sh SCRATCH/issue-1021-shuffle.sh` (for each seed 1021, 20261030 and 7: one fresh PowerShell 7 process running `SCRATCH/issue-1021-shuffle.ps1`, which lists every `*.Tests.ps1` under `tests/scripts/claude-lib/docs` plus `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, sorts them ordinally, applies a Fisher-Yates shuffle driven by `[System.Random]::new(<seed>)`, and runs them in that order in one `Invoke-Pester` call with the repository run settings, coverage and JUnit off)
EXIT_CODE: 0
Output Summary: seed 1021: TOTAL=767 PASSED=767 FAILED=0; seed 20261030: TOTAL=767 PASSED=767 FAILED=0; seed 7: TOTAL=767 PASSED=767 FAILED=0. Each run: 23 files (the 1020 suites, the ten 1021 suites including `DocsPageMetadata.Tests.ps1`, and the module-convention suite), FAILED_BLOCKS=0, FAILED_CONTAINERS=0. No order dependence was found, so no fix and no re-run were needed.

## Per-seed output (counts and file order)

```text
SEED=1021 FILES=23
TOTAL=767 PASSED=767 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0
ORDER:
   1. tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1
   2. tests/scripts/claude-lib/docs/DocsPageDiataxis.Tests.ps1
   3. tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1
   4. tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1
   5. tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1
   6. tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1
   7. tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
   8. tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1
   9. tests/scripts/claude-lib/docs/DocsPageMetadataSchema.Tests.ps1
  10. tests/scripts/claude-lib/docs/DocsPageMarkdown.Tests.ps1
  11. tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1
  12. tests/scripts/claude-lib/docs/DocsPageMetadata.Tests.ps1
  13. tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1
  14. tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1
  15. tests/scripts/claude-lib/docs/DocsJson.Tests.ps1
  16. tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1
  17. tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1
  18. tests/scripts/claude-lib/docs/DocsPageOrphans.Tests.ps1
  19. tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1
  20. tests/scripts/claude-lib/docs/DocsSchemaWalk.Tests.ps1
  21. tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1
  22. tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1
  23. tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1
SEED=20261030 FILES=23
TOTAL=767 PASSED=767 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0
ORDER:
   1. tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1
   2. tests/scripts/claude-lib/docs/DocsPageOrphans.Tests.ps1
   3. tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1
   4. tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1
   5. tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1
   6. tests/scripts/claude-lib/docs/DocsPageDiataxis.Tests.ps1
   7. tests/scripts/claude-lib/docs/DocsPageMetadataSchema.Tests.ps1
   8. tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1
   9. tests/scripts/claude-lib/docs/DocsPageMetadata.Tests.ps1
  10. tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
  11. tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1
  12. tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1
  13. tests/scripts/claude-lib/docs/DocsSchemaWalk.Tests.ps1
  14. tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1
  15. tests/scripts/claude-lib/docs/DocsPageMarkdown.Tests.ps1
  16. tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1
  17. tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1
  18. tests/scripts/claude-lib/docs/DocsJson.Tests.ps1
  19. tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1
  20. tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1
  21. tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1
  22. tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1
  23. tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1
SEED=7 FILES=23
TOTAL=767 PASSED=767 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0
ORDER:
   1. tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1
   2. tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1
   3. tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1
   4. tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1
   5. tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1
   6. tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1
   7. tests/scripts/claude-lib/docs/DocsPageOrphans.Tests.ps1
   8. tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1
   9. tests/scripts/claude-lib/docs/DocsPageDiataxis.Tests.ps1
  10. tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1
  11. tests/scripts/claude-lib/docs/DocsJson.Tests.ps1
  12. tests/scripts/claude-lib/docs/DocsSchemaWalk.Tests.ps1
  13. tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1
  14. tests/scripts/claude-lib/docs/DocsPageMarkdown.Tests.ps1
  15. tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1
  16. tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1
  17. tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
  18. tests/scripts/claude-lib/docs/DocsPageMetadata.Tests.ps1
  19. tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1
  20. tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1
  21. tests/scripts/claude-lib/docs/DocsPageMetadataSchema.Tests.ps1
  22. tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1
  23. tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1
```
