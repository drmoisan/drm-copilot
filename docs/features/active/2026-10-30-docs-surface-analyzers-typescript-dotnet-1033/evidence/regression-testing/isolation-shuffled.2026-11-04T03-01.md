# Seeded shuffled file-order isolation runs, loop re-run after the [P7-T9] hygiene edit ([P7-T5])

Timestamp: 2026-11-04T03-01
Command: pwsh -NoProfile -File SCRATCH/issue-1033-shuffled-run.ps1 -Root <worktree> -Seed <seed>, once per seed 1033, 20261030 and 7 (every `*.Tests.ps1` under `tests/scripts/claude-lib/docs` plus `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, 32 files, sorted by repository-relative path and Fisher-Yates shuffled by `[System.Random]::new(<seed>)`, one Pester 5 process per seed with `Run.Path` in the shuffled order, no coverage, no strict mode in the runner)
EXIT_CODE: 0
Output Summary: seed 1033: total=744, passed=744, failed=0, skipped=0; seed 20261030: total=744, passed=744, failed=0, skipped=0; seed 7: total=744, passed=744, failed=0, skipped=0. No order dependence. First pass (same orders and counts): `isolation-shuffled.2026-11-04T02-32.md`, which also records the runner's strict-mode correction. The orders follow.

## Seed 1033

```
ORDER 01 tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1
ORDER 02 tests/scripts/claude-lib/docs/DocsScannerCommon.Tests.ps1
ORDER 03 tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptExports.Tests.ps1
ORDER 04 tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1
ORDER 05 tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptHttp.Tests.ps1
ORDER 06 tests/scripts/claude-lib/docs/DocsCSharpMember.Tests.ps1
ORDER 07 tests/scripts/claude-lib/docs/DocsExtensionShape.Tests.ps1
ORDER 08 tests/scripts/claude-lib/docs/DocsScannerContract.Tests.ps1
ORDER 09 tests/scripts/claude-lib/docs/DocsCSharpTokens.Tests.ps1
ORDER 10 tests/scripts/claude-lib/docs/DocsAnalyzerExtensionImport.Tests.ps1
ORDER 11 tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1
ORDER 12 tests/scripts/claude-lib/docs/DocsTypeScriptSyntax.Tests.ps1
ORDER 13 tests/scripts/claude-lib/docs/DocsAnalyzerDotnetConfig.Tests.ps1
ORDER 14 tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptCli.Tests.ps1
ORDER 15 tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1
ORDER 16 tests/scripts/claude-lib/docs/DocsTypeScriptTokens.Tests.ps1
ORDER 17 tests/scripts/claude-lib/docs/DocsAnalyzerDotnetApi.Tests.ps1
ORDER 18 tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
ORDER 19 tests/scripts/claude-lib/docs/DocsTypeScriptHttpDeclaration.Tests.ps1
ORDER 20 tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1
ORDER 21 tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1
ORDER 22 tests/scripts/claude-lib/docs/DocsTypeScriptCliSupport.Tests.ps1
ORDER 23 tests/scripts/claude-lib/docs/DocsAnalyzerDotnetHttp.Tests.ps1
ORDER 24 tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1
ORDER 25 tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1
ORDER 26 tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1
ORDER 27 tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1
ORDER 28 tests/scripts/claude-lib/docs/DocsJson.Tests.ps1
ORDER 29 tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1
ORDER 30 tests/scripts/claude-lib/docs/DocsSchemaWalk.Tests.ps1
ORDER 31 tests/scripts/claude-lib/docs/DocsTypeScriptHttpSupport.Tests.ps1
ORDER 32 tests/scripts/claude-lib/docs/DocsCSharpSyntax.Tests.ps1
SUMMARY seed=1033 total=744 passed=744 failed=0 skipped=0
```

## Seed 20261030

```
ORDER 01 tests/scripts/claude-lib/docs/DocsTypeScriptCliSupport.Tests.ps1
ORDER 02 tests/scripts/claude-lib/docs/DocsSchemaWalk.Tests.ps1
ORDER 03 tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1
ORDER 04 tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1
ORDER 05 tests/scripts/claude-lib/docs/DocsJson.Tests.ps1
ORDER 06 tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1
ORDER 07 tests/scripts/claude-lib/docs/DocsCSharpMember.Tests.ps1
ORDER 08 tests/scripts/claude-lib/docs/DocsScannerContract.Tests.ps1
ORDER 09 tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1
ORDER 10 tests/scripts/claude-lib/docs/DocsScannerCommon.Tests.ps1
ORDER 11 tests/scripts/claude-lib/docs/DocsTypeScriptSyntax.Tests.ps1
ORDER 12 tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1
ORDER 13 tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
ORDER 14 tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptCli.Tests.ps1
ORDER 15 tests/scripts/claude-lib/docs/DocsExtensionShape.Tests.ps1
ORDER 16 tests/scripts/claude-lib/docs/DocsTypeScriptHttpDeclaration.Tests.ps1
ORDER 17 tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptHttp.Tests.ps1
ORDER 18 tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1
ORDER 19 tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1
ORDER 20 tests/scripts/claude-lib/docs/DocsAnalyzerDotnetConfig.Tests.ps1
ORDER 21 tests/scripts/claude-lib/docs/DocsTypeScriptHttpSupport.Tests.ps1
ORDER 22 tests/scripts/claude-lib/docs/DocsCSharpTokens.Tests.ps1
ORDER 23 tests/scripts/claude-lib/docs/DocsTypeScriptTokens.Tests.ps1
ORDER 24 tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1
ORDER 25 tests/scripts/claude-lib/docs/DocsAnalyzerDotnetHttp.Tests.ps1
ORDER 26 tests/scripts/claude-lib/docs/DocsAnalyzerDotnetApi.Tests.ps1
ORDER 27 tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1
ORDER 28 tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptExports.Tests.ps1
ORDER 29 tests/scripts/claude-lib/docs/DocsAnalyzerExtensionImport.Tests.ps1
ORDER 30 tests/scripts/claude-lib/docs/DocsCSharpSyntax.Tests.ps1
ORDER 31 tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1
ORDER 32 tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1
SUMMARY seed=20261030 total=744 passed=744 failed=0 skipped=0
```

## Seed 7

```
ORDER 01 tests/scripts/claude-lib/docs/DocsCSharpMember.Tests.ps1
ORDER 02 tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1
ORDER 03 tests/scripts/claude-lib/docs/DocsTypeScriptCliSupport.Tests.ps1
ORDER 04 tests/scripts/claude-lib/docs/DocsScannerContract.Tests.ps1
ORDER 05 tests/scripts/claude-lib/docs/DocsTypeScriptTokens.Tests.ps1
ORDER 06 tests/scripts/claude-lib/docs/DocsExtensionShape.Tests.ps1
ORDER 07 tests/scripts/claude-lib/docs/DocsCSharpTokens.Tests.ps1
ORDER 08 tests/scripts/claude-lib/docs/DocsAnalyzerDotnetConfig.Tests.ps1
ORDER 09 tests/scripts/claude-lib/docs/DocsAnalyzerDotnetHttp.Tests.ps1
ORDER 10 tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1
ORDER 11 tests/scripts/claude-lib/docs/DocsJson.Tests.ps1
ORDER 12 tests/scripts/claude-lib/docs/DocsSchemaWalk.Tests.ps1
ORDER 13 tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
ORDER 14 tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1
ORDER 15 tests/scripts/claude-lib/docs/DocsAnalyzerExtensionImport.Tests.ps1
ORDER 16 tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1
ORDER 17 tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1
ORDER 18 tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1
ORDER 19 tests/scripts/claude-lib/docs/DocsAnalyzerDotnetApi.Tests.ps1
ORDER 20 tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptCli.Tests.ps1
ORDER 21 tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1
ORDER 22 tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptExports.Tests.ps1
ORDER 23 tests/scripts/claude-lib/docs/DocsTypeScriptSyntax.Tests.ps1
ORDER 24 tests/scripts/claude-lib/docs/DocsScannerCommon.Tests.ps1
ORDER 25 tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1
ORDER 26 tests/scripts/claude-lib/docs/DocsTypeScriptHttpSupport.Tests.ps1
ORDER 27 tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1
ORDER 28 tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptHttp.Tests.ps1
ORDER 29 tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1
ORDER 30 tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1
ORDER 31 tests/scripts/claude-lib/docs/DocsTypeScriptHttpDeclaration.Tests.ps1
ORDER 32 tests/scripts/claude-lib/docs/DocsCSharpSyntax.Tests.ps1
SUMMARY seed=7 total=744 passed=744 failed=0 skipped=0
```

