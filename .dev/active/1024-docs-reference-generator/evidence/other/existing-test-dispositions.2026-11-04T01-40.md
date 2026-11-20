# Existing Test Dispositions (issue 1024)

Timestamp: 2026-11-04T01-40
Task: [P0-T4]
Command: git fetch origin; git grep -l -e 'Get-DocsCommandTable' -e 'Test-DocsCommandTable' -e 'generate-reference' -e 'Invoke-DocsCommand.ps1' -e 'core.json' -- tests/ (on HEAD) and the same search against origin/epic/documentation-estate-tooling-integration; Read of each docs suite assertion; git grep for exact-count assertions over core.json paths
EXIT_CODE: 0
Output Summary: 39 matching files on HEAD; the search against the fetched integration ref returned the identical 39-file list (siblings 1022, 1023 and 1033 have not merged into the integration branch at the time of the search). Every matching test asserts membership, an in-memory manifest, or another file; no test asserts a row count or set equality over the dispatch table or the Claude core.json paths. No `update` disposition; no BLOCKED record.

## Dispatch-table tests

| Test file | Test name | Disposition | Reason |
|---|---|---|---|
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` | `Dispatch table` / `returns no finding for the committed table` | unchanged | `Test-DocsCommandTable` over the committed table; the new row satisfies the table rules (name unique, options `Profile`, `Snapshot`, `OutputDirectory`, `Write` not reserved, kinds `value`/`switch`, function matches `^Invoke-Docs[A-Za-z]+Command$`) |
| same | `Dispatch table` / `rejects <Case>` | unchanged | in-memory tables |
| same | `Dispatch table` / `carries the anchors 1020, 1021, 1022, 1023, 1024 and 1034 in order, with no placeholder or 1031 anchor` | unchanged | anchor order and absence of placeholder anchors; no anchor is added or renamed |
| same | `Dispatch table` / `contains the check row directly under the 1021 anchor` | unchanged | membership of the `check` row by `Name` |
| `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` | the `Test-DocsCommandTable` and `check`-row case (`Test-DocsCommandTable` count 0; `check` row found once by `Name`) | unchanged | membership and table validity only |

## core.json tests

| Test file | Test name | Disposition | Reason |
|---|---|---|---|
| `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` | `Docs core.json manifest membership` (all five cases) | unchanged | membership: every file discovered on disk under `.claude/lib/docs/` is listed exactly once and has a byte-identical bundle copy. Each new module is listed and mirrored by [P8-T1] and [P8-T2]; between the creation of the first new module and [P8-T2] this suite is expected to report the new files as unlisted (transient, satisfied by Phase 8, not a change of the test) |
| same | `Select-DocsCoreManifestPath` / `drops paths in the python subtree and keeps every other path` | unchanged | in-memory input |
| `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` | (support module; mentions `Invoke-DocsCommand.ps1` in help text) | unchanged | not a test |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`, `ci-gate/CiGate.Manifest.Tests.ps1`, `ci-gate/MergeConfirmationParser.Manifest.Tests.ps1`, `codex-routing/CodexRouting.Manifest.Tests.ps1`, `discovery-validation/DiscoveryValidation.Manifest.Tests.ps1`, `file-size-policy/FileSizePolicy.Manifest.Tests.ps1`, `model-routing/ModelRouting.Manifest.Tests.ps1`, `orchestrator-state/OrchestratorState.Manifest.Tests.ps1`, `parallel-drift/ParallelDrift.Manifest.Tests.ps1`, `project-file-merge/ProjectFileMerge.Manifest.Tests.ps1`, `worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` | each area's manifest membership case (`$occurrences | Should -Be 1`) | unchanged | each asserts its own area's paths exactly once; appended `.claude/lib/docs/` entries do not affect them |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | all | unchanged | bundle presence and equal text, satisfied by [P8-T1] |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | all | unchanged | every bundled file is in a pack manifest, satisfied by [P8-T2] |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | all (not matched by the search tokens; listed by the plan) | unchanged | `$PSScriptRoot` closure: every sibling the new modules import is already listed in core |
| `tests/scripts/dev_tools/test_discovery_publication_contracts.py` | `test_generated_discovery_paths_are_listed_in_the_core_manifests`, `test_native_hooks_and_helpers_are_published_and_listed` | unchanged | membership of discovery paths only |
| `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`, `test_push_down_claude_gitignore_delivery.py`, `test_push_down_claude_exclusion_filter.py`, `test_push_down_claude_config_carriage.py` | all | unchanged | in-memory manifests |
| `tests/scripts/dev_tools/test_codex_core_manifest_closure.py` | all | unchanged | reads the Codex `core.json`, which is not edited |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_generate_codex_agent_variants.py` | all | unchanged | Codex `core.json` under `codex-and-agents-customizations`, not edited |
| `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `epic-child-launch-hardening.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1` | all | unchanged | Codex `core.json`, not edited |
| `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` | all | unchanged | names the Claude `core.json` path as a registry constant; asserts no entry |
| `tests/shell/parallel_bash_manifest_membership.bats` | `every repository bash library file has a core.json entry` | unchanged | membership of `.claude/lib/bash` files only |
| `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` | (helper; names `core.json` in a comment) | unchanged | comment only |
| `tests/fixtures/blast_radius/combination/combination-contract-only.json`, `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`, `epic-655-followups.json`, `followups-2026-09-27.json`, `tests/fixtures/blast_radius/write-intent/write-intent-shared-surface-read-citation.json`, `tests/fixtures/blast_radius_overlay/shared-surfaces-demote-already-append-only.json` | (fixtures) | unchanged | static fixture data that names the path; no assertion over the manifest contents |

## Planned-by-1020 suites named by the plan

- `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`, `Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1`: present on the merged tree; dispositions above (`DocsNeutrality.Tests.ps1` does not match the search tokens; it scans framework files for consumer identifiers and is unchanged).
- No 1021, 1022, 1023 or 1033 suite enumerating the dispatch table by count exists on HEAD or on the fetched integration ref.
