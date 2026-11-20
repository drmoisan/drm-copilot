# Decision Record (Issue #984)

Timestamp: 2026-10-20T12-51
Command: Read of the five FR-6 hooks and the Codex completion hook; content searches recorded below
EXIT_CODE: 0
Output Summary: FR-2 add (no intentional exclusion found); FR-6 confirmed for all five hooks; FR-7 unchanged; handler ids H9 to H12; leaf column added; no test pins core.json contents or counts.

## FR-2 — Codex `post-codex-worktree-session.ps1`: add

- SearchScope: `docs/`, `scripts/`, `tests/`, `extensions/drm-copilot/` (the whole tree, excluding this feature folder)
- SearchPatterns: `post-codex-worktree-session`; case-insensitive `(exclu|manifest).*(post-codex)|post-codex.*(exclu|manifest)`
- SearchResult: 74 files contain the name. The issue #697 inventory `docs/features/completed/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/other/prepack-nested-scripts-inventory.2026-09-25T20-15.md` lists the bundle copy as "nested (newly shipped)". `extensions/drm-copilot/src/extension.ts` uses `.codex/scripts/post-codex-worktree-session.ps1` as the default of `postCodexScriptPath`. The second pattern matched only a coverage-exclusion-policy note (issues #847 and the promoted record) and a scope-diff command (#268); none records an intentional manifest exclusion.
- Decision: add the path to the Codex `core.json`.

## FR-6 — evaluation-only dependencies (re-confirmed by reading each hook)

- Claude `enforce-discovery-artifact-gate.ps1`: `DiscoveryValidation.psm1` is imported at script level and used only by `Invoke-DiscoveryValidatorExe` (which re-imports it and calls `Invoke-DiscoveryArtifactValidation`). `Invoke-DiscoveryValidatorExe` is called in `Invoke-DiscoveryArtifactGateDecision` only after the missing-`file_path` allow, the Edit (no content) allow, and the `Get-DiscoveryArtifactType` allow. Evaluation-only: confirmed.
- Claude `enforce-python-batch-budget.ps1`: `enforce-batch-budget-route.ps1` supplies `Test-BatchBudgetLargePathRoute` and `Get-BatchBudgetSelectedRoute`, called only in `Invoke-PythonBatchBudgetHook` after the `.py` extension allow. Confirmed.
- Claude `enforce-powershell-batch-budget.ps1`: same helper, called only in `Invoke-PowerShellBatchBudgetHook` after the `.(ps1|psm1|psd1)` allow. Confirmed.
- Codex `enforce-python-batch-budget.ps1` and `enforce-powershell-batch-budget.ps1`: same helper, same call sites after the extension allow in their `Invoke-*BatchBudgetHook`. `codex-pretooluse-file-mapping.ps1` supplies `ConvertFrom-CodexPreToolUsePayload` and `ConvertTo-CodexFileEditInput` (payload transport and path mapping), a scope dependency, and stays guarded through `Add-HookDependencyFailure`. The handler therefore covers the single evaluation-only dependency completely. Confirmed; both converted.
- `HookPayload.psm1` remains fail-closed for every call in every Claude hook.

## FR-7 — Codex `enforce-completion-consistency.ps1` unchanged

Its helper `enforce-completion-helpers.ps1` is already in the Codex core manifest. Its checkpoint path mapping depends on `codex-pretooluse-file-mapping.ps1` and on `enforce-checkpoint-monotonic.ps1` (which supplies `$script:GovernedCheckpointPath`), both scope dependencies, so a handler would cover one of three dependencies. The file has 491 physical lines. Not edited; [P4-T9] proves it and its bundle copy are unchanged.

## Handler ids

H7 and H8 are skipped because `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` already labels its validate-orchestrator-output rows H7 and H8. New entries:

| Id | Surface | Hook | Variable | Leaf | Deny code |
|---|---|---|---|---|---|
| H9 | claude | `.claude/hooks/enforce-completion-consistency.ps1` | `CompletionHelpersImportFailure` | `enforce-completion-helpers.ps1` | `COMPLETION_CONSISTENCY_BLOCKED:` |
| H10 | claude | `.claude/hooks/enforce-discovery-artifact-gate.ps1` | `DiscoveryValidationImportFailure` | `DiscoveryValidation.psm1` | `DISCOVERY_ARTIFACT_GATE_BLOCKED:` |
| H11 | claude, codex | `enforce-python-batch-budget.ps1` | `PythonBatchBudgetRouteImportFailure` | `enforce-batch-budget-route.ps1` | `PYTHON_LARGE_PATH_REQUIRED:` |
| H12 | claude, codex | `enforce-powershell-batch-budget.ps1` | `PowerShellBatchBudgetRouteImportFailure` | `enforce-batch-budget-route.ps1` | `POWERSHELL_LARGE_PATH_REQUIRED:` |

HandlerFile, ConsumerFile, and DenyPathFile are the hook itself; DenyPathCondition is `$script:<Variable>`.

## Leaf column

`Get-HookImportFailureExemption` gains an eleventh tuple element per handler row, emitted as `Leaf = @($h[10])`. H1 to H6 carry `feature-folder-resolution.ps1`, so their emitted objects are unchanged. Consumers (`hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, `HookGuardShape.Helpers.ps1` `Test-HookGuardExemptEdge`, `Get-HookExemptionFinding`) read `Leaf` as an array.

## Named `$PSScriptRoot` forms found in the real bundles ([P1-T3])

The exhaustiveness guard of `test_push_down_pack_manifest_dependency_closure.py` found two spellings in manifested Codex sources beyond the spec's two named non-dependency forms. Each was classified by reading the source and is matched by a named pattern in `tests/scripts/dev_tools/pack_manifest_dependency_scan.py`, exercised by `test_named_non_dependency_forms_are_recognized` in `tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py`:

- `-BasePath $PSScriptRoot` in `.codex/scripts/launch-epic-child-wave.ps1` (`Get-CodexChildCanonicalPath -Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -BasePath $PSScriptRoot`): the base directory for path canonicalization; no file is read or loaded from it. Provably a non-dependency form.
- `Get-CodexRoutingModuleCandidate -ScriptRoot $PSScriptRoot -ModuleName '<module>'` in `.codex/scripts/Resolve-CodexDeployment.ps1` and `.codex/scripts/Resolve-CodexTopology.ps1`: the F8 call site of spec FR-4.6. Its dynamic candidates are checked by `test_codex_routing_module_candidates_are_in_codex_core` against `CODEX_ROUTING_MODULE_CANDIDATES`, so the call site is a named dynamic form rather than an unrecognized one.

No other unrecognized occurrence was found; execution continues.

## core.json pin search

- SearchScope: `tests/`, `extensions/drm-copilot/test/`
- SearchPatterns: `core\.json`, `CORE_PACK`, `"core"`
- SearchResult: real-manifest readers are membership checks only (`*.Manifest.Tests.ps1` under `tests/scripts/claude-lib/`, `legacy-codex-hook-contracts.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`, `test_push_down_claude_resource_contracts.py::test_handoff_runtime_has_bundle_pack_and_effective_install_parity`, `test_codex_core_manifest_closure.py`, `test_generate_codex_agent_variants.py` (generator round-trip), `tests/shell/parallel_bash_manifest_membership.bats`); every other match is an in-memory synthetic manifest. No test pins the contents or the count of either `core.json`.
