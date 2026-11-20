# Existing-Test Disposition ([P0-T4], re-run after the plan revision)

Timestamp: 2026-11-04T14-54
Command: sh SCRATCH/issue-1031-p0t4-search2.sh (grep -rlF and grep -cF of each [P0-T4] symbol over TESTS, GUARD, tests/scripts/codex-hooks, tests/scripts/dev_tools, tests/discovery_runtime and extensions/drm-copilot/test; grep -rlE for Get-ChildItem or EnumerateFiles enumerations of LIB over TESTS, tests/scripts/claude-lib and tests/scripts/ci)
EXIT_CODE: 0
Output Summary: every match falls under a planned [P0-T4] disposition; no unplanned existing-test change. This artifact supersedes existing-test-disposition.2026-11-04T14-15.md, whose stop led to the plan revision.

Symbols searched: `DocsAnalyzerNativeRow`, `Get-DocsAnalyzerRegistration`, `Select-DocsAnalyzerRegistration`, `New-DocsInventorySnapshot`, `Invoke-DocsInventoryCommand`, `Invoke-DocsCommandCli`, `Get-DocsCommandTable`, `DocsCommandRow`, `New-DocsTestContext`, `TestFile`, `InvokeProcess`, `analysis_method`, `Get-PythonInvocationFinding`, `Get-PythonInvocationAllowlist`, `shouldCopy`, `vscodeignore`, `python.json`, `extraPaths`, `pythonpath`, `coverage.run`.

## Matches and dispositions

| Test file | Match | Disposition |
|---|---|---|
| TESTS/DocsAnalyzerRegistry.Tests.ps1 | `DocsAnalyzerNativeRow`, `Get-DocsAnalyzerRegistration`, `Select-DocsAnalyzerRegistration`, `analysis_method` | `Describe 'Committed provider tables (membership only)'` cases (anchors, module scope, `It 'reports no finding for the committed registry'`) unchanged; in-memory `-ScannerRow`/`-NativeRow` cases unchanged; [P4-T5] adds one native-row case |
| TESTS/DocsAnalyzerConfigFiles.Tests.ps1 | `Get-DocsAnalyzerRegistration`, `analysis_method` | `It 'registers the five 1022 scanner rows in the committed registry and Test-DocsAnalyzerRegistration returns no finding'` updated in [P4-T5] (filter adds `AnalysisMethod -ceq 'scanner'`); other cases unchanged |
| TESTS/DocsInventorySnapshot.Tests.ps1 | `Get-DocsAnalyzerRegistration`, `New-DocsInventorySnapshot`, `analysis_method` | `$script:Registry` fixture updated in [P4-T5] to the scanner rows; case bodies and `Get-TestRegistryRow` unchanged |
| TESTS/DocsInventoryProperties.Tests.ps1 | `Get-DocsAnalyzerRegistration`, `Invoke-DocsInventoryCommand`, `New-DocsTestContext`, `TestFile`, `InvokeProcess`, `analysis_method` | cases unchanged (`config-files` row only; `TestFile` of the helper path false in `New-DocsTestContext`); `AfterAll` `Remove-Module` list updated in [P4-T6] |
| TESTS/DocsInventory.Tests.ps1 | `Invoke-DocsInventoryCommand`, `Invoke-DocsCommandCli`, `Get-DocsCommandTable`, `New-DocsTestContext`, `TestFile`, `InvokeProcess` | `It 'registers the inventory row with its options and Test-DocsCommandTable returns no finding'` and `AfterAll` updated in [P4-T6]; `It 'is the only 1022 module that references the command context: ...'` and every other case unchanged (`pack-absent`, silent, zero `InvokeProcess` calls) |
| TESTS/Invoke-DocsCommand.Tests.ps1 | `Invoke-DocsCommandCli`, `Get-DocsCommandTable`, `New-DocsTestContext`, `TestFile`, `InvokeProcess` | unchanged: `It 'returns no finding for the committed table'`, `It 'carries the anchors 1020, 1021, 1022, 1023, 1024 and 1034 in order, with no placeholder or 1031 anchor'`, `New-DocsCommandContext` cases |
| TESTS/DocsLedgerCommands.Tests.ps1, DocsLedgerCommands.UpdateLedger.Tests.ps1, DocsLedgerCommands.Validate.Tests.ps1, DocsCompleteIntegration.Tests.ps1, DocsPageCheck.Tests.ps1 | `Invoke-DocsCommandCli`, `Get-DocsCommandTable`, `TestFile` | unchanged: they run the coverage, update-ledger, validate and check rows and read a supplied snapshot; none runs `inventory`; their `Test-DocsCommandTable` no-finding assertions hold with the added `value` option |
| TESTS/DocsProfileCommands.Tests.ps1, DocsPageTemplates.Tests.ps1, DocsPageCheck.LinkMap.Tests.ps1 | `New-DocsTestContext` | unchanged (no inventory run) |
| TESTS/Docs.TestSupport.psm1, TESTS/DocsLedger.TestSupport.psm1, TESTS/DocsLedger.TestSupport.Tests.ps1, TESTS/DocsLedgerMutation.Tests.ps1 | `TestFile`, `InvokeProcess` | unchanged (test support; no ledger suite runs `inventory`) |
| TESTS analyzer, ledger, receipt, schema, surface, coverage-report suites and both corpora | `analysis_method` | unchanged (they assert existing `scanner` elements or schema text; no assertion depends on the native rows) |
| GUARD/enforcement-hooks-no-python-invocation.Tests.ps1 | `Get-PythonInvocationFinding`, `Get-PythonInvocationAllowlist` | `It 'ships an empty allowlist'` updated in [P4-T7]; seam cases `It 'reports no finding for a scriptblock-parameter seam invocation'` and `It 'reports no finding when a seam variable differs from its parameter by letter case'` unchanged |
| GUARD helper files | definitions | edited in [P4-T7] |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | `Get-PythonInvocationFinding` | unchanged (no `.codex/hooks` seam call with a constant interpreter target) |
| tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | `TestFile` (unrelated identifier) | unchanged |
| extensions/drm-copilot/test/packaging/discovery-resources.test.ts | `shouldCopy`, `vscodeignore` | `it("keeps the explicit Python-source exclusion in both distributables")` and `it("excludes no published discovery resource from the VSIX")` updated in [P5-T3]; `it("copies every discovery resource into the standalone MCP package")` unchanged |
| extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts | `shouldCopy` | unchanged, including `it("excludes Python files at every depth")` (fixture paths outside the carve-out) |
| tests/scripts/dev_tools/test_blast_radius_token_shapes.py | `vscodeignore` | unchanged (string data) |
| tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py | `python.json` | unchanged (Codex manifest not edited) |
| extensions/drm-copilot/test/lib/push-down/claude-pack-selection.test.ts, claude-customizations.test.ts | `python.json` | unchanged (in-memory manifests) |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | `python.json` | unchanged (state-file name) |
| tests/discovery_runtime/test_package_contract.py | `coverage.run` | unchanged (additive edit) |
| `DocsCommandRow`, `extraPaths`, `pythonpath` | no match | n/a |

## Suites that enumerate LIB

| Suite | Enumeration | Disposition |
|---|---|---|
| TESTS/DocsWriteBoundary.Tests.ps1, TESTS/Docs.Manifest.Tests.ps1, TESTS/DocsNeutrality.Tests.ps1 | all LIB modules | unchanged, run in [P5-T4] |
| TESTS/DocsPageImportIsolation.Tests.ps1, TESTS/DocsPageCheck.Tests.ps1 | `DocsPage*.psm1` only | unchanged (new modules are `DocsPython*` and `DocsAnalyzerPython*`) |
| TESTS/DocsSchemaContract.Tests.ps1 | schema directories only | unchanged |
| TESTS/DocsPageTemplates.Tests.ps1 | template directory only | unchanged |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1, tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 | whole library or tree | unchanged, run in [P5-T4] |
| tests/scripts/ci/CiChangeScope.Tests.ps1 | token list only | unchanged |

No unplanned existing-test change was found.
