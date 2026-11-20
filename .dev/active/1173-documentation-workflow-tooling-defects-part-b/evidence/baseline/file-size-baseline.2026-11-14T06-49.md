# File-Size Baseline (P0-T7)

Timestamp: 2026-11-14T06-49
Command: wc -l < <file> for each existing edit-target file named in the plan (`## File-Size Targets` and every other file the plan edits), run from the worktree root; tier: ok below 500, guidance at 500, advisory at 700, over-800 above 800.
EXIT_CODE: 0
Output Summary:
- 69 existing edit-target files measured; none missing.
- Production files at or above a tier: DocsLedgerCommands.psm1 707 (advisory; plan ceiling 760), Invoke-DocsCommand.ps1 621 (guidance; ceiling 640). mcp-tool-inputs-docs.ts 492 (ceiling 520).
- Test files at or above a tier: DocsPageCheck.Tests.ps1 696, DocsLedgerCommands.UpdateLedger.Tests.ps1 651, DocsLedgerCommands.Tests.ps1 553 (guidance).
- python-surface-corpus.json 3569 is a JSON test-data fixture (raw fixture exemption; not a PowerShell, Python or TypeScript file).
- DocsReferenceWriter.psm1 measures 377 by wc -l (the plan's 378 counted differently); no file is above 800 among production, test and script files.

| File | Lines | Tier |
|---|---|---|
| .claude/lib/docs/DocsLedgerCommands.psm1 | 707 | advisory |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 621 | guidance |
| .claude/lib/docs/DocsReferencePlan.psm1 | 411 | ok |
| .claude/lib/docs/DocsReferenceWriter.psm1 | 377 | ok |
| .claude/lib/docs/DocsProfile.psm1 | 228 | ok |
| .claude/lib/docs/DocsProfileCommands.psm1 | 239 | ok |
| .claude/lib/docs/DocsPageLinks.psm1 | 335 | ok |
| .claude/lib/docs/DocsInventorySnapshot.psm1 | 255 | ok |
| .claude/lib/docs/DocsPythonCliArgparse.psm1 | 243 | ok |
| .claude/lib/docs/DocsAnalyzerPythonCli.psm1 | 252 | ok |
| .claude/lib/docs/DocsJson.psm1 | 323 | ok |
| .claude/lib/docs/DocsValidation.psm1 | 367 | ok |
| .claude/lib/docs/DocsReceipt.psm1 | 299 | ok |
| .claude/lib/docs/DocsLedgerMutation.psm1 | 168 | ok |
| .claude/lib/docs/DocsValidateCommands.psm1 | 250 | ok |
| .claude/lib/docs/DocsSurfaceDeltaCommands.psm1 | 221 | ok |
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 376 | ok |
| .claude/lib/docs/DocsAnalyzerExtensionImport.psm1 | 491 | ok |
| .claude/hooks/docs-role-contract.ps1 | 273 | ok |
| .claude/hooks/validate-docs-role-output.ps1 | 119 | ok |
| .claude/lib/docs/python/docs_python_native/cli_argparse.py | 354 | ok |
| .claude/lib/docs/python/docs_python_native/cli.py | 271 | ok |
| .claude/lib/docs/python/docs_python_native/call_sites.py | 271 | ok |
| extensions/drm-copilot/src/mcp-tool-inputs-docs.ts | 492 | ok |
| extensions/drm-copilot/src/mcp-docs-tool-definitions.ts | 135 | ok |
| extensions/drm-copilot/src/repo-automation-execute-docs.ts | 185 | ok |
| extensions/drm-copilot/src/mcp-handlers/docs-handlers.ts | 55 | ok |
| extensions/drm-copilot/jest.docs-coverage.json | 7 | ok |
| extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | 453 | ok |
| tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1 | 696 | guidance |
| tests/scripts/claude-lib/docs/DocsLedgerCommands.UpdateLedger.Tests.ps1 | 651 | guidance |
| tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 | 499 | ok |
| extensions/drm-copilot/test/mcp-tool-inputs-docs.test.ts | 485 | ok |
| tests/scripts/claude-hooks/docs-role-contract.Tests.ps1 | 309 | ok |
| tests/scripts/claude-hooks/validate-docs-role-output.Tests.ps1 | 332 | ok |
| tests/scripts/claude-hooks/validate-docs-role-output.TargetWorktree.Tests.ps1 | 111 | ok |
| tests/scripts/claude-runtime/docs-authoring-roles.Templates.Tests.ps1 | 77 | ok |
| tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1 | 312 | ok |
| tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1 | 314 | ok |
| tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1 | 159 | ok |
| tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1 | 294 | ok |
| tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1 | 179 | ok |
| tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1 | 179 | ok |
| tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1 | 305 | ok |
| tests/scripts/claude-lib/docs/DocsJson.Tests.ps1 | 293 | ok |
| tests/scripts/claude-lib/docs/DocsReceipt.Properties.Tests.ps1 | 191 | ok |
| tests/scripts/claude-lib/docs/DocsReceipt.Tests.ps1 | 291 | ok |
| tests/scripts/claude-lib/docs/DocsAnalyzerExtensionImport.Tests.ps1 | 455 | ok |
| tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1 | 358 | ok |
| tests/scripts/claude-lib/docs/Docs.ScannerTestSupport.psm1 | 276 | ok |
| tests/scripts/claude-lib/docs/Docs.TestSupport.psm1 | 261 | ok |
| tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1 | 553 | guidance |
| tests/scripts/claude-lib/docs/DocsLedgerCommands.Properties.Tests.ps1 | 112 | ok |
| tests/scripts/claude-lib/docs/DocsReferenceBoundary.Tests.ps1 | 278 | ok |
| tests/scripts/claude-lib/docs/DocsReferencePlan.Tests.ps1 | 412 | ok |
| tests/scripts/claude-lib/docs/DocsReferencePlan.Properties.Tests.ps1 | 290 | ok |
| tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1 | 314 | ok |
| tests/scripts/claude-lib/docs/DocsReferenceWriter.Errors.Tests.ps1 | 285 | ok |
| tests/scripts/claude-lib/docs/DocsReferenceWriter.Properties.Tests.ps1 | 286 | ok |
| tests/scripts/claude-lib/docs/DocsPythonCliArgparse.Tests.ps1 | 193 | ok |
| tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_argparse.py | 164 | ok |
| tests/scripts/claude-lib/docs/python/test_docs_python_native_cli.py | 124 | ok |
| tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json | 3569 | fixture (exempt) |
| tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json | 100 | ok |
| extensions/drm-copilot/test/mcp-handlers/docs-handlers.test.ts | 230 | ok |
| extensions/drm-copilot/test/mcp-docs-tool-definitions.test.ts | 189 | ok |
| extensions/drm-copilot/test/mcp-tool-inputs-docs.ledger.test.ts | 203 | ok |
| extensions/drm-copilot/test/repo-automation-execute-docs.test.ts | 398 | ok |
| extensions/drm-copilot/test/mcp-server.docs.test.ts | 212 | ok |
