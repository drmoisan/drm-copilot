# [P12-T5] Both parity mechanisms

Timestamp: 2026-09-07T15-57

Command:

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q
```

and, for `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`:

```
mcp__drm-copilot__run_poshqc_test
  workspace_root = C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31
  scan_folders   = ["tests/scripts/codex-hooks"]
```

EXIT_CODE: 0 (pytest) and 1 (MCP Pester runner, folder-wide; see the exit-code note below)

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context, so the Pester suite could not be run through
`Invoke-Pester -Path tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. It was run
through `mcp__drm-copilot__run_poshqc_test` scoped by `scan_folders` to `tests/scripts/codex-hooks`,
and the per-suite and per-case results below were read from `artifacts/pester/pester-junit.xml`. The
MCP runner reports one exit code for the whole scanned folder, not per suite, so the folder-wide exit
code of 1 is decomposed below into its single cause, which is not the suite this task gates on.

## Output Summary

Both parity mechanisms are green in the same change.

| Mechanism | Subject | Result |
| --- | --- | --- |
| Python push-down contract suite (content equality, Claude pairs) | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | **10 passed, 1 deselected, 0 failed** |
| Codex contract suite (SHA-256 byte identity, Codex pairs) | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | **43 tests, 0 failures, 0 errors** |

Neither run reports a failed test in the suites this task gates on.

## Run 1 — the Python push-down contract suite

Verbatim output:

```
..........                                                               [100%]
10 passed, 1 deselected in 0.12s
```

Exit code 0. 11 cases are collected in the module; 10 ran and passed and 1 was deselected.

### Named results

| Case | Property it enforces | Result |
| --- | --- | --- |
| `test_bundled_claude_payload_contains_required_runtime_files` | **content equality** — the bundled Claude payload carries the required runtime files | passed |
| `test_planner_review_resources_exist_and_are_byte_identical` | **content equality** — the named planner-review resources are byte-identical across the pair | passed |
| `test_pack_manifests_are_outside_the_parity_scope` | **pack manifest** — Claude side: the pack manifests are correctly excluded from the parity comparison scope | passed |
| `test_bundled_claude_payload_excludes_settings_local_json` | exclusion of `.claude/settings.local.json` | passed |
| `test_bundled_claude_payload_excludes_variant_subtree_from_parity` | exclusion of the variant subtree | passed |
| `test_variant_subtree_is_bundle_only_and_non_colliding` | variant subtree is bundle-only | passed |
| `test_bundled_agent_memory_scopes_are_well_formed` | agent-memory scope shape | passed |
| `test_claude_legacy_variant_files_contain_corrected_gate_commands` | legacy variant gate commands present | passed |
| `test_claude_legacy_variant_files_exclude_stale_gate_commands` | legacy variant stale commands absent | passed |
| `test_claude_modern_csharp_profile_retains_modern_gate_commands` | modern C# profile gate commands retained | passed |
| `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | full repo-tree runtime-contract enumeration | **deselected — see below** |

### The deselection, and its issue #510 citation

`test_bundled_claude_payload_contains_all_repo_runtime_contracts` is deselected by node ID:

```
--deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

Reason, as recorded in the plan preamble: that case enumerates the repository `.claude` tree from the
filesystem and excludes only `.claude/settings.local.json` and `.claude/agent-memory/**`. From
[P1-T2] onward, `.claude/hooks/enforce-powershell-batch-budget.ps1` recreates `.claude/state/` on the
first `Write` or `Edit` of a `.ps1`, `.psm1`, or `.psd1` file, and that gitignored directory is then
enumerated by the case and reported as an unbundled runtime contract. The case is therefore red for a
cause this change does not create, and it is red locally while green in CI, where `.claude/state/`
does not exist. This is **open issue #510**. The deselection is by node ID rather than by a skip
marker, so the case remains present in the module and is reported as `1 deselected` rather than
silently dropped.

### The deselected case's property is discharged independently

The byte-identity property the deselected case exists to enforce is discharged independently by
[P12-T4], which recomputes `SHA-256` from current on-disk content for every canonical file and its
bundle mirror across the whole copy set. That artifact records **19 pairs recomputed, 19 with equal
hashes, 0 unequal**, over 38 distinct files, cross-checked against an empty
`git status --porcelain` restricted to the copy-set paths. Equal SHA-256 digests are a strictly
stronger result than the content-equality comparison the push-down suite performs, so the property is
established rather than merely assumed while the case is deselected.

Artifact: `evidence/other/pair-hash-parity.2026-09-07T15-52.md`.

## Run 2 — the Codex contract suite

`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`: **43 tests, 0 failures, 0 errors**,
read from the `testsuite` element for that file in `artifacts/pester/pester-junit.xml`.

### Named results

| Case (`It` name) | Property it enforces | Result |
| --- | --- | --- |
| `keeps the canonical hooks byte-identical to their bundled copies` | **byte identity** — the Codex canonical/bundle pairs are SHA-256 equal | **Passed** |
| `lists every shared hook module in the core pack manifest` | **pack manifest** — Codex side: every shared hook module is listed in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | **Passed** |
| `parse-checks each root and bundled hook and keeps every file within 500 lines` | parse and the 500-line cap, for every root and bundled hook | **Passed** |

The two parser siblings registered into `$script:SharedModuleNames` by [P4-T13] are inside the scope
of all three cases above, so their byte identity, their pack-manifest membership, their parse, and
their line counts are enforced by this passing run and not only by the [P12-T4] hashes.

### Exit-code decomposition

The MCP Pester runner returned exit code 1 for the scanned folder. The folder-wide totals were
**752 tests, 1 failure, 0 errors** across 29 suites. The single failure is:

```
tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
  Every registered Codex PreToolUse handler accepts every tool name its matcher admits
    > allows every registered handler for every tool name its own matcher admits
```

That case is ambient-state driven by this worktree's epic checkpoint, is not a member of the [P1-T13]
known-red inventory, and is not a subject of this task. It is documented in the execution delegation
as a pre-existing failure outside this change's scope. **`legacy-codex-hook-contracts.Tests.ps1`
itself contributed 0 of that 1 failure**, which is the result this task gates on.

The other 28 suites in the folder reported 0 failures and 0 errors, including the five suites this
change created or edited on the Codex side:

| Suite | Tests | Failures |
| --- | --- | --- |
| `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 59 | 0 |
| `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 23 | 0 |
| `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` | 8 | 0 |
| `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 5 | 0 |
| `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` | 5 | 0 |
| `validate-bash-trigger-scoping.Tests.ps1` | 3 | 0 |
| `hook-command-scanner.Tests.ps1` | 41 | 0 |
| `hook-command-invocation.Tests.ps1` | 39 | 0 |
