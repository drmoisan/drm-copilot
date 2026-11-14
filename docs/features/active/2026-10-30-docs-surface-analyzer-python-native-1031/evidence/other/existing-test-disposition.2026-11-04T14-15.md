# Existing-Test Disposition ([P0-T4])

Timestamp: 2026-11-04T14-15
Command: sh SCRATCH/issue-1031-p0t4-search.sh (grep -rnF of each symbol over TESTS, GUARD, tests/scripts/codex-hooks, tests/scripts/dev_tools, tests/discovery_runtime, extensions/drm-copilot/test), plus sh SCRATCH/issue-1031-run.sh issue-1031-p0t4-probe.ps1 issue-1031-p0t4-probe.out (registry filter probe)
EXIT_CODE: 0
Output Summary: BLOCKED: unplanned existing-test change. Two suites outside the planned dispositions assert behavior that [P4-T5] changes: `TESTS/DocsAnalyzerConfigFiles.Tests.ps1` and `TESTS/DocsInventorySnapshot.Tests.ps1`.

Symbols searched: `DocsAnalyzerNativeRow`, `Get-DocsAnalyzerRegistration`, `Invoke-DocsInventoryCommand`, `DocsCommandRow`, `Get-PythonInvocationFinding`, `Get-PythonInvocationAllowlist`, `shouldCopy`, `vscodeignore`, `python.json`, `extraPaths`, `pythonpath`, `coverage.run`.

## Matches and dispositions

| Test file | Case or usage | Disposition |
|---|---|---|
| TESTS/DocsAnalyzerRegistry.Tests.ps1 | `It 'declares the scanner table with the 1022 then 1033 anchors and the native table after it with the 1031 anchor'`, `It 'holds both tables in module scope (read only)'`, `It 'reports no finding for the committed registry'` | planned: updated in [P4-T5] (membership of the four rows); the current cases assert anchor order and no finding only, no emptiness, so they stay valid |
| TESTS/DocsAnalyzerRegistry.Tests.ps1 | `Describe 'Get-DocsAnalyzerRegistration'` cases with in-memory `-ScannerRow` and `-NativeRow` | unchanged (in-memory rows, unaffected) |
| TESTS/DocsAnalyzerConfigFiles.Tests.ps1 | `Context 'registration'`, `It 'registers the five 1022 scanner rows in the committed registry and Test-DocsAnalyzerRegistration returns no finding'`: per identifier, `@($registration | Where-Object { [string] $_.Id -ceq $id }).Count | Should -Be 1` over the committed registry | UNPLANNED, affected: after [P4-T5] the committed registry holds a `native` row for `python-architecture`, `python-cli`, `python-http` and `python-public-api`, so the filter returns 2 rows for each (probe: rows=2 for the four identifiers, rows=1 for `config-files`) and the assertion fails |
| TESTS/DocsInventorySnapshot.Tests.ps1 | `$script:Registry = Get-DocsAnalyzerRegistration` (all committed rows) used by `Invoke-TestAnalyzerSet` and `New-DocsInventorySnapshot -Registration $script:Registry`; `It 'validates against surface-inventory-snapshot through Test-DocsArtifactText with no finding and carries the header fields'` asserts the snapshot `analyzers` list equals exactly the five `<id>:scanner:1.0.0` entries | UNPLANNED, affected: after [P4-T5] the committed registry has 9 rows (probe), `New-DocsInventorySnapshot` adds one `analyzers` entry per row including the four `native` rows, and the exact-list assertion fails; the property case `It 'property: New-DocsInventorySnapshot is byte-identical under permuted inputs and analyzer outputs'` also consumes the 9-row registry |
| TESTS/DocsInventoryProperties.Tests.ps1 | `$registry = Get-DocsAnalyzerRegistration`, then the `config-files` row only | unchanged (selects `config-files`, which gets no native row) |
| TESTS/DocsInventory.Tests.ps1 | `It 'registers the inventory row with its options and Test-DocsCommandTable returns no finding'` (exact option set `Analyzer, Profile, Revision, Write`) | planned: updated in [P4-T6] to admit `AnalysisMethod` |
| TESTS/DocsInventory.Tests.ps1 | `It 'never passes a non-template env-family file to ReadBytes (recording wrapper) ...'` (records ReadBytes calls; `-Analyzer config-files`) | planned category [P4-T6] (context-call set); with `config-files` only, no native call occurs, so the expected update is none |
| TESTS/DocsInventory.Tests.ps1 | `It 'is the only 1022 module that references the command context: the other seventeen new module texts contain no Context token'` | unchanged (names the seventeen 1022 modules explicitly, not an enumeration of `LIB`) |
| TESTS/DocsInventory.Tests.ps1 | other `Invoke-DocsInventoryCommand` cases (default profile, absent pack in the test context) | unchanged (`TestFile` of the helper path is false in the test context, so `auto` is silent) |
| GUARD/enforcement-hooks-no-python-invocation.Tests.ps1 | `It 'ships an empty allowlist'` | planned: updated in [P4-T7] |
| GUARD/enforcement-hooks-no-python-invocation.Tests.ps1 | `It 'reports no Python invocation beyond the allowlist across the guarded tree'`, `It 'carries no stale allowlist entry'` | planned: unchanged text, exercised in [P4-T7] |
| GUARD/enforcement-hooks-no-python-invocation.Tests.ps1 | `It 'reports no finding for a scriptblock-parameter seam invocation'`, `It 'reports no finding when a seam variable differs from its parameter by letter case'` and the other `Get-PythonInvocationFinding` fixture cases | planned: unchanged |
| GUARD/EnforcementHooksNoPythonInvocation.Helpers.ps1, GUARD/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1 | definitions of `Get-PythonInvocationFinding`, `Get-PythonInvocationAllowlist` | planned: edited in [P4-T7] |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | zero-finding case over `.codex/hooks` files | planned: unchanged |
| extensions/drm-copilot/test/packaging/discovery-resources.test.ts | `it("keeps the explicit Python-source exclusion in both distributables")`, `it("excludes no published discovery resource from the VSIX")` | planned: updated in [P5-T3] |
| extensions/drm-copilot/test/packaging/discovery-resources.test.ts | `it("copies every discovery resource into the standalone MCP package")` (`shouldCopy` true for discovery resources) | unchanged (discovery paths are not `.py`) |
| extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts | `it("excludes Python files at every depth")` and the other `shouldCopy` cases | planned: unchanged |
| tests/scripts/dev_tools/test_blast_radius_token_shapes.py | `.vscodeignore` as a token-shape string | unchanged (string data, unrelated) |
| tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py | Codex `pack-manifests/python.json` path | unchanged (the Codex manifest is not edited) |
| extensions/drm-copilot/test/lib/push-down/claude-pack-selection.test.ts, claude-customizations.test.ts | in-memory `python.json` manifests | unchanged (in-memory fixtures) |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | `.codex/state/python.json` state-file name | unchanged (unrelated) |
| tests/discovery_runtime/test_package_contract.py | `[tool.coverage.run]` split | planned: unchanged (additive edit) |
| `extraPaths`, `pythonpath`, `DocsCommandRow` | no match in the searched trees | n/a |

## BLOCKED signal

BLOCKED: unplanned existing-test change

- `TESTS/DocsAnalyzerConfigFiles.Tests.ps1` `It 'registers the five 1022 scanner rows in the committed registry and Test-DocsAnalyzerRegistration returns no finding'` fails once [P4-T5] adds the four native rows (filter by `Id` returns 2 rows per Python identifier).
- `TESTS/DocsInventorySnapshot.Tests.ps1` `It 'validates against surface-inventory-snapshot through Test-DocsArtifactText with no finding and carries the header fields'` fails once [P4-T5] adds the four native rows (the snapshot built from the whole committed registry lists nine analyzers); the suite's `$script:Registry` fixture feeds every case of `Describe 'New-DocsInventorySnapshot over both corpora'`.

Required plan delta (for atomic-planner): add both suites to the planned dispositions of [P0-T4] and to the file set of [P4-T5], with the update reason "the committed registry now holds 1031 native rows": in `DocsAnalyzerConfigFiles.Tests.ps1` filter the registration case by `AnalysisMethod -ceq 'scanner'` (and optionally assert one `native` row for each Python identifier); in `DocsInventorySnapshot.Tests.ps1` build `$script:Registry` from the scanner rows only (`Where-Object { $_.AnalysisMethod -ceq 'scanner' }`), so the snapshot fixture and its exact `analyzers` assertion stay unchanged.
