# Parity and Size Verification (P7-T8)

Timestamp: 2026-11-14T17-15
Command: sh SCRATCH/issue-1173-codexgen.sh --check; results of the `## Mirror Contract Tests` read from evidence/qa-gates/final-qc-pytest.2026-11-14T17-11.md and final-qc-pester.2026-11-14T17-11.md; cmp of every bundle copy added or modified since the merge base of origin/main and HEAD with its source (extensions/drm-copilot/resources/{claude-customizations,customizations,codex-and-agents-customizations}/<path> against <path>); md5sum of the six execution-environment brief copies; wc -l of every file in `## File-Size Targets` and every other edited or new production, test and script file, compared with evidence/baseline/file-size-baseline.2026-11-14T06-49.md
EXIT_CODE: 0
Output Summary:

## Parity

| Check | Result | Evidence |
|---|---|---|
| Codex generator --check | PASS | gen_exit=0 |
| test_push_down_claude_resource_contracts.py | PASS | final pytest run, 0 failed |
| test_push_down_codex_and_agents_resource_contracts.py | PASS | final pytest run, 0 failed |
| test_push_down_claude_pack_manifest_completeness.py | PASS | final pytest run, 0 failed |
| test_push_down_pack_manifest_dependency_closure.py | PASS | final pytest run, 0 failed |
| test_codex_agent_wrapper_contracts.py | PASS | final pytest run, 0 failed |
| test_execution_environment_brief_contracts.py | PASS | final pytest run, 0 failed |
| docs-authoring-roles.Mirrors.Tests.ps1 | PASS | final Pester run, 0 failures |
| docs-authoring-roles.Skills.Tests.ps1 | PASS | final Pester run, 0 failures |
| docs-authoring-roles.WorkflowText.Tests.ps1 | PASS | final Pester run, 0 failures |
| documentation-workflow.CommitStage.Tests.ps1 | PASS | final Pester run, 0 failures |
| hook-dependency-guard-completeness.Tests.ps1 | PASS | final Pester run, 0 failures |
| Byte identity of every bundle copy | PASS | 78 changed bundle files compared with their sources, 0 differ; pack-manifests/core.json has no source copy and gains DocsProfileSourceRoot, DocsLedgerBatch, DocsLedgerBindRefs and DocsReferenceSplit |
| Six execution-environment brief copies | PASS | .claude, .github and .agents skills and their three bundle copies share one md5 digest; each states the docs-pages-written probe |

## Size (physical lines; hard limit 800)

| File | Baseline | Final | Result |
|---|---|---|---|
| .claude/lib/docs/DocsLedgerCommands.psm1 | 707 | 758 | PASS |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 621 | 624 | PASS |
| .claude/lib/docs/DocsReferencePlan.psm1 | 411 | 430 | PASS |
| .claude/lib/docs/DocsReferenceWriter.psm1 | 377 | 472 | PASS |
| .claude/lib/docs/DocsProfile.psm1 | 228 | 237 | PASS |
| .claude/lib/docs/DocsProfileCommands.psm1 | 239 | 270 | PASS |
| .claude/lib/docs/DocsPageLinks.psm1 | 335 | 341 | PASS |
| .claude/lib/docs/DocsInventorySnapshot.psm1 | 255 | 298 | PASS |
| .claude/lib/docs/DocsPythonCliArgparse.psm1 | 243 | 394 | PASS |
| .claude/lib/docs/DocsAnalyzerPythonCli.psm1 | 252 | 335 | PASS |
| .claude/lib/docs/DocsJson.psm1 | 323 | 361 | PASS |
| .claude/lib/docs/DocsValidation.psm1 | 367 | 367 | PASS |
| .claude/lib/docs/DocsReceipt.psm1 | 299 | 301 | PASS |
| .claude/lib/docs/DocsLedgerMutation.psm1 | 168 | 170 | PASS |
| .claude/lib/docs/DocsValidateCommands.psm1 | 250 | 250 | PASS |
| .claude/lib/docs/DocsSurfaceDeltaCommands.psm1 | 221 | 221 | PASS |
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 376 | 382 | PASS |
| .claude/lib/docs/DocsAnalyzerExtensionImport.psm1 | 491 | 496 | PASS |
| .claude/hooks/docs-role-contract.ps1 | 273 | 278 | PASS |
| .claude/hooks/validate-docs-role-output.ps1 | 119 | 120 | PASS |
| .claude/lib/docs/python/docs_python_native/cli_argparse.py | 354 | 522 | PASS |
| .claude/lib/docs/python/docs_python_native/cli.py | 271 | 357 | PASS |
| .claude/lib/docs/python/docs_python_native/call_sites.py | 271 | 315 | PASS |
| extensions/drm-copilot/src/mcp-tool-inputs-docs.ts | 492 | 508 | PASS |
| extensions/drm-copilot/src/mcp-docs-tool-definitions.ts | 135 | 147 | PASS |
| extensions/drm-copilot/src/repo-automation-execute-docs.ts | 185 | 188 | PASS |
| extensions/drm-copilot/src/mcp-handlers/docs-handlers.ts | 55 | 55 | PASS |
| extensions/drm-copilot/jest.docs-coverage.json | 7 | 8 | PASS |
| extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | 453 | 457 | PASS |
| tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1 | 696 | 696 | PASS |
| tests/scripts/claude-lib/docs/DocsLedgerCommands.UpdateLedger.Tests.ps1 | 651 | 651 | PASS |
| tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 | 499 | 499 | PASS |
| extensions/drm-copilot/test/mcp-tool-inputs-docs.test.ts | 485 | 485 | PASS |
| tests/scripts/claude-hooks/docs-role-contract.Tests.ps1 | 309 | 336 | PASS |
| tests/scripts/claude-hooks/validate-docs-role-output.Tests.ps1 | 332 | 345 | PASS |
| tests/scripts/claude-hooks/validate-docs-role-output.TargetWorktree.Tests.ps1 | 111 | 117 | PASS |
| tests/scripts/claude-runtime/docs-authoring-roles.Templates.Tests.ps1 | 77 | 106 | PASS |
| tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1 | 312 | 365 | PASS |
| tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1 | 314 | 330 | PASS |
| tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1 | 159 | 184 | PASS |
| tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1 | 294 | 351 | PASS |
| tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1 | 179 | 216 | PASS |
| tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1 | 179 | 181 | PASS |
| tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1 | 305 | 305 | PASS |
| tests/scripts/claude-lib/docs/DocsJson.Tests.ps1 | 293 | 324 | PASS |
| tests/scripts/claude-lib/docs/DocsReceipt.Properties.Tests.ps1 | 191 | 191 | PASS |
| tests/scripts/claude-lib/docs/DocsReceipt.Tests.ps1 | 291 | 291 | PASS |
| tests/scripts/claude-lib/docs/DocsAnalyzerExtensionImport.Tests.ps1 | 455 | 470 | PASS |
| tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1 | 358 | 375 | PASS |
| tests/scripts/claude-lib/docs/Docs.ScannerTestSupport.psm1 | 276 | 280 | PASS |
| tests/scripts/claude-lib/docs/Docs.TestSupport.psm1 | 261 | 266 | PASS |
| tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1 | 553 | 553 | PASS |
| tests/scripts/claude-lib/docs/DocsLedgerCommands.Properties.Tests.ps1 | 112 | 114 | PASS |
| tests/scripts/claude-lib/docs/DocsReferenceBoundary.Tests.ps1 | 278 | 281 | PASS |
| tests/scripts/claude-lib/docs/DocsReferencePlan.Tests.ps1 | 412 | 430 | PASS |
| tests/scripts/claude-lib/docs/DocsReferencePlan.Properties.Tests.ps1 | 290 | 312 | PASS |
| tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1 | 314 | 316 | PASS |
| tests/scripts/claude-lib/docs/DocsReferenceWriter.Errors.Tests.ps1 | 285 | 285 | PASS |
| tests/scripts/claude-lib/docs/DocsReferenceWriter.Properties.Tests.ps1 | 286 | 286 | PASS |
| tests/scripts/claude-lib/docs/DocsPythonCliArgparse.Tests.ps1 | 193 | 234 | PASS |
| tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_argparse.py | 164 | 262 | PASS |
| tests/scripts/claude-lib/docs/python/test_docs_python_native_cli.py | 124 | 263 | PASS |
| tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json | 3569 | 3823 | PASS (JSON fixture exemption) |
| tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json | 100 | 101 | PASS |
| extensions/drm-copilot/test/mcp-handlers/docs-handlers.test.ts | 230 | 305 | PASS |
| extensions/drm-copilot/test/mcp-docs-tool-definitions.test.ts | 189 | 203 | PASS |
| extensions/drm-copilot/test/mcp-tool-inputs-docs.ledger.test.ts | 203 | 282 | PASS |
| extensions/drm-copilot/test/repo-automation-execute-docs.test.ts | 398 | 421 | PASS |
| extensions/drm-copilot/test/mcp-server.docs.test.ts | 212 | 238 | PASS |
| .claude/lib/docs/DocsLedgerBatch.psm1 | new | 439 | PASS |
| .claude/lib/docs/DocsLedgerBindRefs.psm1 | new | 150 | PASS |
| .claude/lib/docs/DocsProfileSourceRoot.psm1 | new | 164 | PASS |
| .claude/lib/docs/DocsReferenceSplit.psm1 | new | 216 | PASS |
| extensions/drm-copilot/src/mcp-tool-inputs-docs-ledger-batch.ts | new | 206 | PASS |
| extensions/drm-copilot/test/mcp-tool-inputs-docs-ledger-batch.test.ts | new | 179 | PASS |
| extensions/drm-copilot/test/mcp-tool-inputs-docs.reference.test.ts | new | 102 | PASS |
| tests/scripts/claude-lib/docs/DocsHashLineEnding.Tests.ps1 | new | 225 | PASS |
| tests/scripts/claude-lib/docs/DocsLedgerBatch.Properties.Tests.ps1 | new | 123 | PASS |
| tests/scripts/claude-lib/docs/DocsLedgerBatch.TestSupport.psm1 | new | 211 | PASS |
| tests/scripts/claude-lib/docs/DocsLedgerBatch.Tests.ps1 | new | 445 | PASS |
| tests/scripts/claude-lib/docs/DocsLedgerBindRefs.Tests.ps1 | new | 209 | PASS |
| tests/scripts/claude-lib/docs/DocsPageCheck.MalformedLink.Tests.ps1 | new | 103 | PASS |
| tests/scripts/claude-lib/docs/DocsProfileSourceRoot.Tests.ps1 | new | 94 | PASS |
| tests/scripts/claude-lib/docs/DocsReferenceSplit.Properties.Tests.ps1 | new | 84 | PASS |
| tests/scripts/claude-lib/docs/DocsReferenceSplit.Tests.ps1 | new | 149 | PASS |
| tests/scripts/claude-lib/docs/DocsReferenceWriter.PathPrefix.Tests.ps1 | new | 94 | PASS |
| tests/scripts/claude-lib/docs/DocsReferenceWriter.Split.Tests.ps1 | new | 110 | PASS |
| tests/scripts/claude-lib/docs/Invoke-DocsCommand.InventoryParity.Tests.ps1 | new | 72 | PASS |
| tests/scripts/claude-lib/docs/Invoke-DocsCommand.Stdin.Tests.ps1 | new | 70 | PASS |
| tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1 | new | 145 | PASS |

- Stated ceilings held: DocsLedgerCommands.psm1 758 (ceiling 760), Invoke-DocsCommand.ps1 624 (ceiling 640), mcp-tool-inputs-docs.ts 508 (ceiling 520); DocsPageCheck.Tests.ps1 696 (unchanged), DocsLedgerCommands.UpdateLedger.Tests.ps1 651, Invoke-DocsCommand.Tests.ps1 499 and mcp-tool-inputs-docs.test.ts 485 (no growth).
- python-surface-corpus.json (3823) is a JSON test-data fixture under the raw-fixture exemption recorded in the baseline; it is not a PowerShell, Python or TypeScript file.
- Every row is PASS.
