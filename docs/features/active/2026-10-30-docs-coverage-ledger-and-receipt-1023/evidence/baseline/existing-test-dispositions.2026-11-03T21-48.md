# Existing Test Dispositions ([P0-T3])

Timestamp: 2026-11-03T21-48
Command: grep -rn -l -E 'Invoke-DocsCommand|Get-DocsCommandTable|lib/docs|core\.json|DocsLedger' tests/ extensions/drm-copilot/test/ (tracked and untracked files; worktree root), then grep -n for the matching lines of every hit outside tests/scripts/claude-lib/docs and sed reads of the assertions that parse core.json
EXIT_CODE: 0
Output Summary: 60 files hit at least one token. Every hit is assigned a disposition below. No hit asserts an exact dispatch-row set, an exact `core.json` path set, or an exact `LIB` file set, so the run continues (no `BLOCKED at [P0-T3]`). The token `DocsLedger` matches no existing file; `Get-DocsCommandTable` matches only `Invoke-DocsCommand.Tests.ps1`.

Terms: `LIB` = `.claude/lib/docs`; `TESTS` = `tests/scripts/claude-lib/docs`. "Unchanged" means the test asserts no behavior this plan changes.

## Hits in `## Existing Tests Affected` (disposition from the plan table)

| Hit | Token(s) | Disposition |
|---|---|---|
| `TESTS/Invoke-DocsCommand.Tests.ps1` | `Invoke-DocsCommand`, `Get-DocsCommandTable`, `lib/docs` | Unchanged ([P4-T2]): [P0-T1] recorded no row-count, row-set, or help-text assertion beyond `-Match 'validate-profile'` and `usage` count greater than 1; `Test-DocsCommandTable` must stay finding-free and the anchor order must hold, which the three rows under the 1023 anchor satisfy |
| `TESTS/Docs.Manifest.Tests.ps1` | `lib/docs`, `core.json` | Unchanged ([P6-T2]): membership and byte-identity per discovered file, not an exact set; gains cases for the new files |
| `TESTS/DocsNeutrality.Tests.ps1` | `lib/docs` | Unchanged ([P6-T2]): one case per discovered file |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `core.json` | Unchanged ([P7-T7]): parity of every distributable `.claude` file with the bundle; `core.json` is read for handoff-pack membership only |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | (none of the five tokens; listed in the plan table) | Unchanged ([P7-T7]): `$PSScriptRoot` closure of manifested files; literal joins and the `core.json` lines satisfy it |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | `core.json` | Unchanged ([P7-T7]): enumerates agents, hooks and skills; does not enumerate `lib` |
| `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` | `core.json` | Unchanged ([P7-T8]): every bundled file is in some pack manifest; satisfied by [P6-T2] |

## Hits outside the plan table

| Hit | Token(s) | Disposition |
|---|---|---|
| `TESTS/Docs.TestSupport.psm1` | `lib/docs` (schema directory read) | Unchanged: reads `LIB/schemas/v1`, which 1023 does not edit |
| `TESTS/DocsAnalyzerRegistry.Tests.ps1` | `lib/docs` (module path, a `Module outside .claude/lib/docs` registry case) | Unchanged: registry rows only; 1023 adds no registry row |
| `TESTS/DocsFinding.Tests.ps1`, `DocsJson.Tests.ps1`, `DocsProfile.Tests.ps1`, `DocsProfileCommands.Tests.ps1`, `DocsSchema.Tests.ps1`, `DocsSchemaWalk.Tests.ps1`, `DocsSurface.Tests.ps1` | `lib/docs` (import paths) | Unchanged: they import 1020 modules that 1023 does not edit |
| `TESTS/DocsSchemaContract.Tests.ps1` | `lib/docs` (runtime schema directory) | Unchanged: asserts the `schemas/docs/v1` and `LIB/schemas/v1` file sets are equal with count 8 and byte-identical; 1023 creates no schema file, so the count holds (this is a schema-file set, not a `LIB` module set) |
| `TESTS/fixtures/DocsAnalyzerFixture.psm1` | `lib/docs` (import path) | Unchanged: fixture import only |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`, `ci-gate/CiGate.Manifest.Tests.ps1`, `ci-gate/MergeConfirmationParser.Manifest.Tests.ps1`, `codex-routing/CodexRouting.Manifest.Tests.ps1`, `discovery-validation/DiscoveryValidation.Manifest.Tests.ps1`, `file-size-policy/FileSizePolicy.Manifest.Tests.ps1`, `model-routing/ModelRouting.Manifest.Tests.ps1`, `orchestrator-state/OrchestratorState.Manifest.Tests.ps1`, `parallel-drift/ParallelDrift.Manifest.Tests.ps1`, `project-file-merge/ProjectFileMerge.Manifest.Tests.ps1`, `worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` | `core.json` | Unchanged: each asserts membership of its own `.claude/lib/<area>` files in `core.json` (not an exact path set); 1023 appends `.claude/lib/docs/` entries only |
| `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` | `core.json` (comment text) | Unchanged: a scope comment |
| `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `epic-child-launch-hardening.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1` | `core.json` | Unchanged: they read the Codex `codex-and-agents-customizations/pack-manifests/core.json`, which 1023 does not edit |
| `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` | `core.json` (the manifest path as an append-only tolerance key) | Unchanged: names the file as a registry path; does not parse its contents |
| `tests/scripts/dev_tools/test_codex_core_manifest_closure.py` | `core.json` | Unchanged: Codex `core.json` closure (hooks and resolvers); not the Claude manifest |
| `tests/scripts/dev_tools/test_discovery_publication_contracts.py` | `core.json` | Unchanged: `_manifest_paths` returns the path inventory for membership checks of discovery files; not an exact set |
| `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` | `core.json` | Unchanged: generated Codex `core.json` text; 1023 does not run the generator with changes |
| `tests/scripts/dev_tools/test_push_down_claude_config_carriage.py`, `test_push_down_claude_exclusion_filter.py`, `test_push_down_claude_gitignore_delivery.py`, `test_push_down_claude_pack_selection.py` | `core.json` | Unchanged: in-memory manifests written by the tests themselves |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_resource_contracts.py` | `core.json` | Unchanged: Codex bundle manifests |
| `tests/fixtures/blast_radius/combination/combination-contract-only.json`, `historical-runs/backlog-2026-09-26.json`, `historical-runs/epic-655-followups.json`, `historical-runs/followups-2026-09-27.json`, `write-intent/write-intent-shared-surface-read-citation.json`, `tests/fixtures/blast_radius_overlay/shared-surfaces-demote-already-append-only.json` | `core.json` | Unchanged: data fixtures that name the manifest path as a shared surface |
| `tests/shell/parallel_bash_manifest_membership.bats` | `core.json` | Unchanged: membership of `.claude/lib/bash` files in `core.json` |
| `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts`, `repo-automation-service.push-down-claude.test.ts`, `repo-automation-service.push-down-codex.test.ts` | `core.json` | Unchanged: list the manifest path among bundled files read by the push-down |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts` | `core.json` | Unchanged: the manifest path as a tolerance key |
| `extensions/drm-copilot/test/lib/push-down/claude-customizations.test.ts`, `claude-pack-selection.test.ts`, `codex-agents-customizations.test.ts`, `codex-pack-selection.test.ts`, `config-carriage.test-helpers.ts`, `push-down-service-call.test.ts` | `core.json` | Unchanged: in-memory manifests built by the tests themselves |

## Stop-rule check

- Exact dispatch-row set assertion: none found (only `Invoke-DocsCommand.Tests.ps1` references `Get-DocsCommandTable`, and it asserts validity and anchor order, not a row set).
- Exact `core.json` path set assertion: none found (every parser of the committed Claude manifest checks membership of its own files).
- Exact `LIB` file set assertion: none found (`DocsSchemaContract.Tests.ps1` pins the schema-file set of `LIB/schemas/v1`, which 1023 does not change).
- Sibling-addition note (1021, 1022, 1033 append rows under their own anchors and `core.json` entries): no hit becomes order- or count-sensitive to those additions either.
