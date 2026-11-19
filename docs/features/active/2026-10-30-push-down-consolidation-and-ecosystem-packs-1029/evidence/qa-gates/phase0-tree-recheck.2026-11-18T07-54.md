# Phase 0 Tree Re-check (P0-T2)

Timestamp: 2026-11-18T07-54
Command: node SCRATCH/issue-1029-cite-check2.cjs <worktree> <main merge base> HEAD (git show <ref>:<file> for every cited file and test name; symbol search over every .ts and .cjs file under extensions/drm-copilot/src and extensions/drm-copilot/test at each ref; physical line counts); sh SCRATCH/issue-1029-bases.sh
EXIT_CODE: 0
Output Summary: 352 citation rows checked at each of `BASE` (merge base of origin/main and HEAD) and `HEAD`. Every cited file, test name and symbol is present at both refs; none moved, was renamed or changed shape. The script reported five misses, all explained below: two were needle errors in the check script (the symbols are present), and `config/harness-parity-matrix.json` is absent at the main merge base only, because it is a child 1 output that lives on the integration branch and lies outside `extensions/drm-copilot/` and `tests/scripts/`. The line counts D9, D10 and P3-T2 rely on match `HEAD`.

Result: PASS

## Citation rows

| Citation group | BASE | HEAD |
| --- | --- | --- |
| 25 test files of X1 to X11 with their named describes and cases (including `pushDownCustomizations (engine)` and its eight cases, `classifies created vs overwritten files`, `copies the .codex and .agents trees in deterministic root then path order`, `publishes every virtual resource pair in full-tree mode`, `fails before any write, directory creation, or artifact write on a malformed manifest`, `leaves a present destination file byte-identical and counts a conflict`, `demotes quality-tiers.yml with tolerance 5000 on push (issue #1006 AC-04)`, `keeps Copilot push-down schemas workspace-root-only`, `resolves input and calls service.pushDownCopilotCustomizations exactly once with the resolved input`, `shows one warning notification when the result carries at least one conflict line`, `registers pushDownCopilotCustomizations`, `seedClaudeBundle`, `seedCodexBundle`, `publish`) | present | present |
| Python and Pester contract tests of X12 and X13 (`test_scanned_source_floor`, `test_codex_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`, `test_codex_command_text_closure`, `_load_surface`, `_closure_gaps`, `powershell_sources`, `test_bundled_codex_files_are_listed_in_some_pack_manifest`, `test_no_bundled_codex_file_is_absent_from_disk_and_exception_list`, `PRE_EXISTING_UNRELATED_AGENT_EXCEPTIONS`, `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`, `REQUIRED_PACK_MANIFESTS`, the five static parity tests, `test_codex_core_manifest_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_generate_codex_agent_variants.py`, `ProcessReductionChain.Ledger.Tests.ps1`, `FileSizePolicy.RepoGate.Tests.ps1`) | present | present |
| `scripts/dev_tools/generate_codex_agent_variants.py` `render_manifest` | present | present |
| `PD/claude-customizations.ts`: `ROOT_FOLDERS`, `MERGED_RELATIVE_PATHS`, `ROUTING_MERGE_RELATIVE_PATH`, `DESTINATION_WRITE_DECORATORS`, `EXCLUDED_RELATIVE_PATHS`, `deliverDestinationGitignore`, `ClaudePushDownOptions`, `ClaudePushDownSummary`, `pushDownCustomizations` (declared `export function pushDownCustomizations`; the check script's `async` needle was wrong) | present | present |
| `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` (exported from `PD/claude-filesystem-adapter.ts`; the check script looked in `PD/claude-customizations.ts`, the plan names no file for it) | present | present |
| `PD/codex-agents-customizations.ts`: `ROOT_FOLDERS`, `VIRTUAL_RESOURCE_PAIRS`, `VIRTUAL_RESOURCE_DIRECTORIES` (with the `.codex/lib/epic-wave` pair), `VIRTUAL_ROOT_FOLDERS`, `RoutingConfigFileSystem`, `CodexFilteringFileSystem`, `CodexAgentsPushDownOptions` | present | present; `VIRTUAL_RESOURCE_DIRECTORIES` gained a `.codex/lib/development-docs` pair from the upstream integration merge (value change, same shape) |
| `PD/copilot-customizations.ts` `COPILOT_ROOT_FOLDERS`, `PushDownCustomizationsOptions`; `PD/copilot-customizations-engine.ts` `PushDownFileResult`, `renderPushDownSummary`, `pushDownCustomizations`, `destination_status` | present | present |
| MCP and service files: `resolvePushDownCopilotCustomizationsToolInput`, `copilotPushDownSelectionProperties`, `RepoAutomationMcpToolResult`, `toMcpToolResult`, `pushDownCopilotCustomizations`, `runPushDownCopilotCustomizations`, `RepoAutomationExecutionResult`, `repo-automation-tool-names.ts` | present | present |
| 41 symbols searched over `extensions/drm-copilot/src` and `test` (including `EXCLUSION_CONFLICT_LINE_PREFIX`, `EXCLUSION_MANIFEST_RELATIVE_PATH`, `assertManifestPathIsRootLevel`, `stringifySorted`, `ExclusionFilterFileSystem`, `ExcludingFileSystem`, `RoutingMergeFileSystem`, `mergeClaudeGitignore`, `ReadThroughPushDownFileSystem`, `buildInMemoryFileSystem`, `enumerateSourceFiles`, `rewriteTextReferences`, `createRepoAutomationService`, `dispatchRepoAutomationTool`, `REPO_AUTOMATION_TOOL_DEFINITIONS`, `toolDefinitions`, `ManifestError`, `PushDownServiceCallResult`, `PushDownFileSystem`) | present | present |
| `EXT/jest.config.cjs` `coverageThreshold`, `EXT/run-jest.cjs`, `EXT/README.md`, `EXT/CHANGELOG.md` `## [Unreleased]`, `packages/mcp-server/prepack.cjs`, the three self-review templates, `AGENTS.md` and `.github/copilot-instructions.md` bundle copies | present | present |
| `config/harness-parity-matrix.json` (outside the checked folders) | absent (child 1 output, not on main) | present |

## Line counts

| File | BASE | HEAD | Plan figure |
| --- | --- | --- | --- |
| `EXT/jest.config.cjs` | 596 | 624 | 624 (D9) |
| `PD/claude-customizations.ts` | 497 | 497 | 497 (D10) |
| `extensions/drm-copilot/src/repo-automation-service.ts` | 476 | 495 | 495 at re-plan (P3-T2) |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts` | 483 | 483 | 483 |
| `extensions/drm-copilot/src/mcp-tools.ts` | 473 | 473 | 473 |
| `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` | 420 | 420 | cap 500 (P3-T4) |
| `PD/copilot-customizations-engine.ts` | 449 | 449 | shrink (P2-T5) |

The differences between `BASE` and `HEAD` come from the upstream integration merges (#1025, #1028), not from this item. The comparisons that judge this item's own growth use the integration merge base, as recorded in `evidence/other/execution-decision.scope-base.2026-11-18T07-54.md`.
