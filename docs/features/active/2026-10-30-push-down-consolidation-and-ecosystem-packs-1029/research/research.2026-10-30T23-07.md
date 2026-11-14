# Research: Push-Down Consolidation and Per-Ecosystem Pack Selection (Issue #1029)

- Issue: #1029 (epic #1018, child 4)
- Mode: preparation research; no source file was changed
- Feature folder (`<FEATURE>`): `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029`
- Inputs read: `<FEATURE>/issue.md`, `<FEATURE>/spec.md` (template state), `docs/features/epics/shared-agent-harness-layer/epic.md`, `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md` (settled, not re-opened), `.claude/skills/execution-environment/SKILL.md`, and the upstream extracts in `SCRATCH` (`child1/spec.md`, `child1/research__research.2026-10-30T21-08.md`, `child1/user-story.md`, `child3/research__research.2026-10-30T22-46.md`, `parallel-manifest.md`).
- Tree state: the working tree is `origin/main` plus the epic documents (caller statement). Every repository fact below was read from this tree with Read, Grep and Glob. Facts that need `git` or `gh` are marked UNVERIFIED for the orchestrator.
- Timestamp: the file-name stamp is the UTC time read from an external clock service immediately before the write.
- Line counts below are physical line counts from a ripgrep `^` match count per file; they equal logical counts when the file ends with one terminator.

---

## 1. Current Push-Down Architecture

### 1.1 MCP tools and extension commands

| Surface | Name | Defined in |
| --- | --- | --- |
| MCP tool | `push_down_copilot_customizations` | `extensions/drm-copilot/src/repo-automation-tool-names.ts`; schemas in both `REPO_AUTOMATION_TOOL_DEFINITIONS` (`extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, the list returned by `listRepoAutomationTools`) and `toolDefinitions` (`extensions/drm-copilot/src/mcp-tool-definitions.ts`, imported by Jest tests) |
| MCP tool | `push_down_codex_and_agents_customizations` | same |
| MCP tool | `push_down_claude_customizations` | same |
| Extension command | `drmCopilotExtension.pushDownCopilotCustomizations`, `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`, `drmCopilotExtension.pushDownClaudeCustomizations` | `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` (QuickPick of `CODEX_PUSH_DOWN_PACK_ITEMS` / `CLAUDE_PUSH_DOWN_PACK_ITEMS`, all pre-picked; C# variant prompt; Claude memory-mode prompt; `translateSelectedPackNames`) |

- Input schemas: `extensions/drm-copilot/src/mcp-push-down-schema-properties.ts`. `workspaceRootProperty` is required on all three. `claudePushDownSelectionProperties` and `codexPushDownSelectionProperties` add optional `packs` (string array), `csharp_variant` (`modern`/`legacy`) and `memory_mode` (`overwrite`/`merge`/`skip`; inert for Codex). `copilotPushDownSelectionProperties` is `{}`: the Copilot tool has no pack selection.
- Input parsing: `resolvePushDownClaudeCustomizationsToolInput` and `resolvePushDownCodexAndAgentsCustomizationsToolInput` in `extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts`.
- Dispatch: `dispatchRepoAutomationTool` in `extensions/drm-copilot/src/mcp-tools.ts` (three `case` arms) calls `extensions/drm-copilot/src/mcp-handlers/push-down-handlers.ts`, which calls `RepoAutomationService.pushDown*Customizations` (`extensions/drm-copilot/src/repo-automation-service.ts`, contract in `repo-automation-service-contract.ts`), which delegates to `runPushDown*` in `extensions/drm-copilot/src/repo-automation-service-push-down.ts`, which calls `pushDown*CustomizationsServiceCall` in `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts`.
- MCP result envelope: `toMcpToolResult` in `mcp-tools.ts` maps `RepoAutomationExecutionResult` to `{ ok, tool, workspace_root, summary, artifacts?, warnings?, ... }`. A field not mapped there does not reach MCP callers.
- MCP server package: `packages/mcp-server` (`@danmoisan/drm-copilot-mcp`, version `1.1.23`) has no source of its own. `packages/mcp-server/esbuild-mcp-server.cjs` bundles `extensions/drm-copilot/src/mcp-server.ts`; `packages/mcp-server/prepack.cjs` (`shouldCopy`) copies `extensions/drm-copilot/resources/` into the package and excludes every `.py` file and the resources-root `scripts/` subtree. The push-down TypeScript therefore runs inside the MCP server process and inside the VS Code extension host; it is never copied to a destination.
- Codex exposure: `.codex/config.toml` `[mcp_servers.drm-copilot]` `enabled_tools` lists all three push-down tools; `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` pins that list (`EXPECTED_DRM_COPILOT_TOOLS`, `APPROVED_DRM_COPILOT_TOOLS`).

### 1.2 Implementing modules

| Module (`extensions/drm-copilot/src/lib/push-down/`) | Role | Lines |
| --- | --- | --- |
| `copilot-customizations-engine.ts` | The one shared engine (`pushDownCustomizations`): `validateDestination`, `enumerateSourceFiles`, copy loop with `created`/`overwritten` classification, `writeSummaryArtifact` (`artifacts/<dir>/push-down-<UTC>.json`, sorted-key JSON via `stringifySorted`) | 449 |
| `copilot-customizations.ts` | Copilot wrapper: `COPILOT_ROOT_FOLDERS` (`.github/agents`, `.github/hooks`, `.github/instructions`, `.github/prompts`, `.github/skills`) and `rewriteTextReferences` | 102 |
| `codex-agents-customizations.ts` | Codex wrapper: `ROOT_FOLDERS` (`.codex`, `.agents`), `VIRTUAL_RESOURCE_PAIRS` (three `config/orchestration-*` files and three `.codex/lib/codex-routing/*.psm1`), `VIRTUAL_RESOURCE_DIRECTORIES` (`.codex/lib/discovery-validation`), `CodexFilteringFileSystem`, `RoutingConfigFileSystem` | 391 |
| `claude-customizations.ts` | Claude wrapper: `ROOT_FOLDERS` (`.claude`, `config`), `EXCLUDED_RELATIVE_PATHS`, `DESTINATION_WRITE_DECORATORS` (routing merge, blast-radius overlay, blast-radius derive), `MERGED_RELATIVE_PATHS`, `resolvePublishedPaths`, `deliverDestinationGitignore`, exclusion-manifest wiring | 496 |
| `claude-pack-selection.ts`, `codex-pack-selection.ts` | Manifest load/validate (`loadPackManifests`), union with `core` (`computePublishedPaths`), C# variant routing and mutual exclusion; Codex adds `resolveManifestPackNames` (public `csharp` to `csharp-modern`/`csharp-legacy`) | 309, 245 |
| `claude-filesystem-adapter.ts` (`ExcludingFileSystem`), `claude-memory-scope.ts` | Claude enumeration filter: excluded paths, pack selection, C# variant reads, agent-memory scope and mode | 332, 136 |
| `claude-exclusion-manifest.ts`, `claude-exclusion-filter.ts` | Destination-owned `.push-down-exclusions` (`EXCLUSION_MANIFEST_RELATIVE_PATH`, `assertManifestPathIsRootLevel`, `ExclusionFilterFileSystem`, `renderExclusionLines`, `EXCLUSION_CONFLICT_LINE_PREFIX`) | 343, 337 |
| `claude-routing-merge.ts`, `claude-blast-radius-*.ts`, `claude-gitignore-merge.ts` | Destination-aware merges for `config/orchestration-routing.json`, `config/blast-radius.json` (+ `config/blast-radius.local.json` overlay) and `.gitignore` | 312; 447 (overlay); 166 |
| `filesystem-adapter.ts` | `PushDownFileSystem` (`listFiles`, `isDir`, `isFile`, `readTextFile`, `writeTextFile` with LF normalization, `ensureDir`); `RealPushDownFileSystem`. No delete operation exists | 203 |
| `push-down-service-call.ts` | Resolves bundled source roots, calls the three entry points, returns `PushDownServiceCallResult` `{ tool, workspaceRoot, summary, artifacts: [one path], warnings? }` | 214 |

- Python ports: `scripts/dev_tools/push_down_*.py` (claude customizations, filesystem, pack selection, destination writes, exclusion filter, gitignore merge, routing merge, blast-radius derive/overlay; codex customizations, filesystem, pack selection; copilot customizations, filesystem, rewrites; exclusion manifest). They are not used at runtime by the extension or the MCP server (the TypeScript ports state "no Python dependency remains", and `prepack.cjs` excludes `.py`). They are exercised by the Python tests under `tests/scripts/dev_tools/test_push_down_*.py` and by static parity tests (section 2.3).
- PowerShell: no PowerShell implements push-down. Pester suites only read `pack-manifests/core.json` (section 2.3).

### 1.3 Payload roots and pack manifests

| Ecosystem | Bundle root (`extensions/drm-copilot/resources/`) | Published roots | Pack manifests |
| --- | --- | --- | --- |
| Claude | `claude-customizations/` (`.claude/**`, `config/**`, `.claude-variants/csharp-legacy/**`) | `.claude`, `config` | `pack-manifests/{core,python,powershell,typescript,csharp-modern,csharp-legacy}.json` |
| Codex | `codex-and-agents-customizations/` (`.codex/**`, `.agents/**`, `AGENTS.md`, `.agents-variants/**`, `.codex-variants/**`) plus `resources/config/*` and `resources/lib/{codex-routing,discovery-validation}/*` through virtual paths | `.codex`, `.agents`, virtual `config` and `.codex/lib/*` | same six names |
| Copilot | `customizations/` (`.github/**`) | the five `.github/<sub>` folders | none |
| (unused) | `claude-dir-customizations/.mcp.json` | not published; no file outside `docs/` references `claude-dir-customizations` | none |

- Manifest format (no schema file exists; validated in code by `parseManifest`): `{ "name": string, "label": string, "paths": string[], "source_prefix"?: string }`. Paths are destination-relative.
- Codex `core.json` is partly generated: `render_manifest` in `scripts/dev_tools/generate_codex_agent_variants.py` appends the required base and variant agent paths for `PACK_FAMILIES`; every other entry is hand-maintained, and `--check` reports a manifest only when a required agent path is missing.
- Not published today although bundled: `codex-and-agents-customizations/AGENTS.md` (outside `.codex`/`.agents`), `customizations/.github/copilot-instructions.md` (outside the five sub-roots), and `claude-dir-customizations/.mcp.json`. No `CLAUDE.md` is bundled.

### 1.4 Pack selection today

- `packs` omitted or empty: publish everything under the published roots, with no manifest read (`resolvePublishedPaths` returns `null`).
- `packs` supplied: publish only the union of `core` plus the selected manifests' `paths`. A bundled file that no manifest lists is silently not published.
- The extension commands always pass `packs` (all four language packs pre-picked), so extension-command push-downs are always manifest-scoped; MCP callers that omit `packs` get the full tree.
- Consequence for child 1's contracts: child 1 adds `references/standard.md` bundle copies with no manifest entry, on the assumption that they stay in the bundle (child 1 research). That holds only for manifest-scoped runs; an MCP call without `packs` already publishes every file under `.agents`, including those contracts, once they are bundled.
- Completeness tests are partial: `test_push_down_claude_pack_manifest_completeness.py` enumerates only `.claude/agents/*.md`, `.claude/hooks/*` and `.claude/skills/*/SKILL.md`; `test_push_down_codex_and_agents_pack_manifest_completeness.py` enumerates only `.codex/agents/*.toml`, `.codex/hooks/*` and `.agents/skills/*/SKILL.md`, and carries 26 agent and 34 skill entries in `PRE_EXISTING_UNRELATED_*_EXCEPTIONS` (counted from the two frozensets; informational). Rules, libs, skill supporting files and config are not checked except through the `$PSScriptRoot` closure in `test_push_down_pack_manifest_dependency_closure.py`. Every excepted or unchecked file is dropped by a manifest-scoped push-down.

### 1.5 Write and overwrite decisions; receipts; dry run

- Every enumerated file is written unconditionally; the engine only classifies it as `created` or `overwritten` by `fs.isFile` before the write. There is no content comparison and no hash.
- Exceptions, Claude only: paths in `.push-down-exclusions` are withheld (`ExclusionFilterFileSystem`), `config/orchestration-routing.json` is merged so local routes survive (`RoutingMergeFileSystem`), `config/blast-radius.json` is derived and composed with the destination-owned overlay, and `.gitignore` is merged and written only when the text changes (`deliverDestinationGitignore`).
- Inconsistency: the Codex push-down publishes `config/orchestration-routing.json` through `RoutingConfigFileSystem`, which reads the bundle copy and writes it directly with no merge, so a Codex push-down overwrites local routes that a Claude push-down preserves.
- Receipt: each run writes a summary artifact into the destination (`artifactRoot: destinationRoot` in `push-down-service-call.ts`) at `artifacts/<ecosystem>-customizations/push-down-<UTC>.json` with per-file `relative_path` and `destination_status`, and absolute `repo_root`/`destination_root`. It carries no content hash, no pack selection, and a new file per run; it is not a usable "last pushed-down manifest".
- Dry run: none of the push-down tools has one. Prior art for a dry run and for hash-pinned non-overwrite exists in the discovery tools (`dryRun` and `expected_sha256` in `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts`; one tool is described as "Never overwrites; dry_run reports the plan").

### 1.6 Who invokes the push-down

- `.agents/skills/repo-automation-adapter/SKILL.md` (`## Published MCP Tool Surface`, `### Customization publishing and hard-lock resolution`) instructs Codex workflows to call `push_down_copilot_customizations` and `push_down_codex_and_agents_customizations` as MCP tools; it does not name `push_down_claude_customizations`. It lists the extension command IDs as legacy, not to be invoked.
- No file under `.claude/skills`, `.claude/hooks`, `.codex/hooks`, `.github/**`, `AGENTS.md` or `CLAUDE.md` invokes a push-down (Grep for `push_down_` and `pushDown(Claude|Codex|Copilot)`). The brief copies only name the contract tests.
- No skill or hook runs push-down code as a script; the only invocation route from agent content is an MCP tool call.

---

## 2. Shared Versus Per-Ecosystem Logic

### 2.1 What becomes one pipeline

| Concern | Today | One pipeline |
| --- | --- | --- |
| Enumeration, validation, copy loop, summary artifact | already shared (`copilot-customizations-engine.ts`) | unchanged core, extended by a plan step |
| Pack-manifest load, union with `core`, C# exclusion | duplicated in `claude-pack-selection.ts` and `codex-pack-selection.ts` | one loader keyed by ecosystem; Copilot gains manifests |
| Destination exclusions, routing merge, gitignore merge | Claude only | applied once per run for every selected ecosystem (owner question O-8 for the exclusion file) |
| Shared layer (`AGENTS.md`, shared `.agents/skills/**`, shared `config/orchestration-*`) | split between Codex (`.agents`, three configs) and Claude (`config`) | installed by every call |
| Planning (create/update/unchanged/conflict), manifest comparison, dry-run report, manifest write | absent | new, ecosystem-neutral |

Per-ecosystem logic that stays per ecosystem: root folders, Copilot `rewriteTextReferences`, Claude memory scope and mode, Claude blast-radius derive/overlay (Claude runtime reads it), C# variant source prefixes per bundle.

### 2.2 What the thin wrappers must keep

- Tool names and required `workspace_root`; all existing optional fields with the same enums and defaults.
- `RepoAutomationExecutionResult` / `PushDownServiceCallResult` shape: `tool`, `workspaceRoot`, the existing `summary` strings, `artifacts` as a one-element array of the normalized summary-artifact path, and `warnings` present only when non-empty (exclusion lines with `EXCLUSION_CONFLICT_LINE_PREFIX`, which the Claude extension command counts).
- `packs` omitted: first run on a destination without a manifest must still publish the full ecosystem tree (backward compatibility; see owner question O-5 for the persisted-selection case).
- New fields are additive and optional: `dry_run` (boolean, default false), Copilot `packs`, and an option to overwrite unmanaged differing files (O-4). New result content goes into a new optional field mapped in `toMcpToolResult` (for example `push_down_report`), not into existing fields.

### 2.3 Tests that assert current push-down behavior

The plan must name each with a disposition. Preflight must also search the test tree for every changed symbol, file name and asserted output (brief, `## Preflight Defect Classes the Validator Cannot See`).

Jest (`extensions/drm-copilot/test/`):

- `lib/push-down/`: `copilot-customizations-engine.test.ts`, `copilot-customizations.test.ts`, `codex-agents-customizations.test.ts`, `codex-bundle-publish.integration.test.ts`, `codex-pack-selection.test.ts`, `claude-customizations.test.ts`, `claude-pack-selection.test.ts`, `claude-pack-name-translation.test.ts`, `claude-pack-manifest-completeness.test.ts`, `claude-filesystem-adapter.test.ts`, `claude-config-carriage.test.ts`, `claude-gitignore-delivery.test.ts`, `claude-gitignore-merge.test.ts`, `claude-gitignore-merge-parity.test.ts`, `claude-exclusion-filter.test.ts`, `claude-exclusion-manifest.test.ts`, `claude-exclusion-parity.test.ts`, `claude-routing-merge-parity.test.ts`, `claude-blast-radius-overlay.test.ts`, `claude-blast-radius-overlay-parity.test.ts`, `claude-blast-radius-derive.test.ts`, `blast-radius-derive*.test.ts`, `filesystem-adapter.test.ts`, `reference-rewrites.test.ts`, `push-down-service-call.test.ts`, and helpers `push-down.test-helpers.ts`, `real-bundle-filesystem.test-helpers.ts`, `config-carriage.test-helpers.ts`, `seeded-random.test-helpers.ts`.
- Top level: `mcp-tools.push-down-claude.test.ts`, `push-down-claude-handler.test.ts`, `mcp-tool-inputs.push-down-codex.test.ts`, `repo-automation-service.push-down-claude.test.ts`, `repo-automation-service.push-down-codex.test.ts`, `extension.push-down-claude-customizations.test.ts`, `repo-automation-command-registration-admin.test.ts`, `mcp-repo-automation-tool-definitions.test.ts`, `mcp-server.test.ts`, `extension.workflow-commands.test.ts`, `extension.integration.test.ts`; and the tool-list or stub-service references in `mcp-server-test-service.ts`, `mcp-server-epic-validation.test.ts`, `mcp-server.discovery.test.ts`, `mcp-server-parallel-validation.test.ts`, `mcp-plan-gate-warning-projection.test.ts`, `mcp-tools.workspace-root.test.ts`, `mcp-tools.discovery.test.ts`, `mcp-tools.codex-native-converter.test.ts`, `mcp-tools.potential-to-issue-target-repository.test.ts`.

Python (`tests/scripts/dev_tools/`):

- Behavior of the Python ports (unaffected while the ports are unchanged): `test_push_down_claude_customizations.py`, `_destination_writes`, `_exclusion_filter`, `_gitignore_delivery`, `_gitignore_merge`, `_memory_scope`, `_pack_selection`, `_pack_memory_modes`, `_pack_end_to_end`, `_config_carriage`, `_routing_merge`, `_blast_radius_*`, `test_push_down_codex_and_agents_customizations.py`, `_variant_packs`, `_virtual_paths`, `test_push_down_codex_pack_selection.py`, `test_push_down_copilot_customizations*.py`, `test_push_down_exclusion_manifest.py`.
- Static parity pins that read TypeScript source text and break when a pinned declaration moves or changes: `test_push_down_claude_parity.py` (`TS_CUSTOMIZATIONS` `ROOT_FOLDERS`, merged-path registries, `TS_FILESYSTEM_ADAPTER`, `TS_DERIVE_CORE`), `test_push_down_claude_overlay_parity.py` (`TS_OVERLAY`), `test_push_down_claude_exclusion_parity.py`, `test_push_down_claude_gitignore_parity.py`, and `test_skill_bundle_contract_repo.py` (regex on `export const ROOT_FOLDERS` in `claude-customizations.ts` compared with `PUBLISHED_ROOT_FOLDERS` in `scripts/dev_tools/skill_bundle_contract.py`).
- Bundle and manifest contracts: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both completeness tests, `test_push_down_pack_manifest_dependency_closure.py`, `test_codex_core_manifest_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_push_down_tier_rule_adoption_gate.py`.

Pester (read `claude-customizations/pack-manifests/core.json`, and one also the Codex `core.json`): `tests/scripts/claude-lib/*/*.Manifest.Tests.ps1` for blast-radius, ci-gate (`CiGate`, `MergeConfirmationParser`), codex-routing, discovery-validation, file-size-policy, model-routing, orchestrator-state, parallel-drift, project-file-merge, worktree-resolution. These are unaffected unless the manifest location or shape changes.

---

## 3. Language Classification

Owner rule (verbatim): "Avoid new Python (existing Python is tolerated: reuse, call or extend in place only). The language depends on where the new code runs: (1) anything pushed down to destination repos, meaning skills, skill helpers, hooks and libs, must be PowerShell or bash, never TypeScript and never Python; (2) TypeScript is ONLY for MCP commands (tools in the MCP server package) and extension commands." Owner exception E2: a language-native analyzer is allowed when it analyzes that same language and ships only with that language's pack; PowerShell remains the baseline.

Key question. The pipeline core runs in the MCP server process (bundled into `@danmoisan/drm-copilot-mcp` from `extensions/drm-copilot/src`) and in the extension host; it is never pushed down, and no skill or hook runs it as a script. The only agent-content route to it is the `repo-automation-adapter` skill instructing an MCP tool call. Under clause (2) the core is MCP-command code and is TypeScript. The epic's generator sentence ("if a skill or hook invokes it, it is PowerShell or bash") could be read as covering a skill that calls an MCP tool; that reading would contradict clause (2) and the settled #1016 precedent (the migration command is an MCP tool with an `npx` entry). This is raised as owner question O-1 with TypeScript as the default.

| Artifact | Runs where | Classification | Notes |
| --- | --- | --- | --- |
| Pipeline core (ecosystem and pack resolution, shared-layer selection, plan builder, apply step) | MCP server and extension host | TypeScript (MCP command code) | new modules under `extensions/drm-copilot/src/lib/push-down/`; O-1 |
| Manifest comparator (hash of destination file vs last manifest entry vs payload) | same | TypeScript | `node:crypto` is already used in `extensions/drm-copilot/src` (discovery and handoff modules) |
| Dry-run reporter (report object and text lines) | same | TypeScript | pure function |
| MCP wrappers (three existing tools; any new tool) | MCP server | TypeScript | thin; schema and input parsing additive |
| Extension commands (three existing) | VS Code extension host | TypeScript | may gain a dry-run step |
| Pack manifests (existing six per bundle, new Copilot and shared manifests) | data, bundled | JSON | not code |
| Destination push-down manifest file | data written into destinations | JSON | not code, so not covered by clause (1) |
| Any destination-side check of local edits (hook or skill helper) | destination | PowerShell or bash | not recommended for child 4; if requested, R4 in `quality-tiers.yml` applies |
| Generators (child 3) | repository | PowerShell (child 3) | not pushed down by default (O-9) |
| Python ports `scripts/dev_tools/push_down_*.py` | repository tests only | existing Python, unchanged | O-6 |
| New tests | CI | Jest for TypeScript; Pester only if PowerShell is added | no new Python test files |
| Existing Python contract tests | CI | existing Python, edited in place only where a contract changes | "extend in place" |

E2: not applicable; no artifact is a language-native analyzer.

---

## 4. Destination-Edit Detection

### 4.1 Recommended design

- Path: `.push-down-manifest.json` at the destination root, outside every published root, guarded the same way as `EXCLUSION_MANIFEST_RELATIVE_PATH` (`assertManifestPathIsRootLevel`) so it is never enumerated or excluded by accident. One file for all ecosystems.
- Schema (sorted-key JSON through `stringifySorted`, LF, UTF-8 without BOM, no timestamps and no absolute paths, so an unchanged second run writes nothing):

```json
{
  "schema_version": "1.0.0",
  "payload_version": "<extension version>",
  "selection": {
    "claude": { "packs": ["core", "python"], "csharp_variant": "modern", "memory_mode": "overwrite" },
    "codex": { "packs": ["core"] }
  },
  "files": {
    ".agents/skills/orchestrate/SKILL.md": { "layer": "shared", "pack": "core", "sha256": "<hex>" },
    ".claude/rules/python.md": { "layer": "claude", "pack": "python", "sha256": "<hex>" }
  }
}
```

- Hash: SHA-256 of the LF-normalized UTF-8 text, which is exactly what `PushDownFileSystem.writeTextFile` writes. Normalizing the destination text before hashing prevents a false "local edit" on a Windows checkout with `core.autocrlf`.
- Decision table per payload file (D = destination file, M = manifest entry, P = payload text after rewrite and variant routing):

| D | M | Comparison | Action | Write |
| --- | --- | --- | --- | --- |
| absent | absent | | `create` | yes |
| absent | present | | `deleted-locally` (reported) | no |
| present | present | hash(D) = M, hash(P) = M | `unchanged` | no |
| present | present | hash(D) = M, hash(P) differs | `update` | yes |
| present | present | hash(D) differs from M, hash(D) = hash(P) | `converged` (record) | no |
| present | present | hash(D) differs from M and from hash(P) | `conflict` (reported) | no |
| present | absent | hash(D) = hash(P) | `adopt` (record) | no |
| present | absent | hash(D) differs | `unmanaged-conflict` (reported; overwritten only with the O-4 opt-in) | no by default |

- Paths shaped by merges (`config/orchestration-routing.json`, `config/blast-radius.json`, `.gitignore`) bypass the comparator and are reported as `merge`; the merge already preserves destination content. For the second-run no-op to hold, each merged path is written only when the merged text differs from the current destination text (today only `.gitignore` skips an unchanged write; whether the routing and blast-radius decorators rewrite identical text was not verified). Paths withheld by `.push-down-exclusions` are reported as `excluded`.
- Manifest entries with no payload counterpart (pack or ecosystem deselected, file retired) are reported as `orphaned` and never deleted (`PushDownFileSystem` has no delete; O-7).
- The manifest is rewritten after an apply run only when its rendered text changes; entries for `conflict` files keep their previous hash.

### 4.2 First-time destinations

A destination with no manifest is handled non-destructively: absent files are created, identical files are adopted, and differing files are reported as `unmanaged-conflict` and left untouched. This includes every destination pushed down by a release before this feature, where older payload versions differ from the new payload; such a destination needs either the opt-in overwrite (O-4) or manual resolution. Today those files are overwritten, so this is a behavior change for existing callers and for existing tests whose fixtures pre-populate a destination and assert `overwritten` (for example `copilot-customizations-engine.test.ts`, the Claude and Codex customization tests and the service-call tests).

### 4.3 Dry-run report shape

- `dry_run: true` performs every read and the full plan, and writes nothing to the destination (no payload file, no manifest, no summary artifact).
- The report is returned in a new optional result field (for example `push_down_report`), mapped in `toMcpToolResult`:
  `{ "mode": "dry-run" | "apply", "ecosystems": { "<name>": { "packs": [...], ... } }, "files": [ { "path", "layer", "pack", "action", "reason" } ], "counts": { "<action>": n } }`, with `files` sorted by path and no absolute paths, so tests can assert it exactly.
- In apply mode the same plan is computed first and written into the existing summary artifact, with the new `action` per file next to the existing `destination_status`; conflict lines are also returned in `warnings` so the extension commands surface them as they do exclusion conflicts.
- O-3 decides whether apply without a prior dry run stays allowed.

---

## 5. Per-Ecosystem Pack Selection

### 5.1 Selection parameter shape

Recommended default (O-2): no new MCP tool. Each existing tool selects its own ecosystem and always installs the shared layer; a destination that uses Claude and Codex calls two tools, and the second call finds the shared layer `unchanged`. Copilot gains an optional `packs` property and pack manifests. All three gain `dry_run`. A unified tool (for example `push_down_harness` with `ecosystems` and per-ecosystem `packs`) is the alternative; it adds a tool name to `repo-automation-tool-names.ts`, both definition lists, `.codex/config.toml` `enabled_tools` (which child 3's MCP generator will own), `EXPECTED_DRM_COPILOT_TOOLS`, the `repo-automation-adapter` skill and its bundle copy, and an MCP package release.

Persisted selection: the manifest's `selection` records the last packs per ecosystem. O-5 decides whether an omitted `packs` reuses it.

### 5.2 The shared layer

Concrete contents (subject to child 1 dispositions and child 3 outputs, re-checked at the Phase 0 gate):

- `AGENTS.md` (instruction source; read natively by Codex and Copilot; Claude reads it through `CLAUDE.md`).
- `.agents/skills/<name>/**` for every skill whose matrix entry is `codex:skill:<name>` with disposition `shared` (child 1 `### Contract Format`, required set), including `references/standard.md` if Q1 is answered yes. Codex-only skills stay in `.agents/skills` (their native folder) but belong to the Codex ecosystem layer, because VS Code Copilot also reads `.agents/skills` and a Claude-only destination must not receive Codex-only skills.
- Shared config read by more than one ecosystem: `config/orchestration-routing.json` (merged, not overwritten), `config/orchestration-handoff-registry.json`, `config/orchestration-handoff.schema.json`.

Ecosystem layers: Claude = `CLAUDE.md` (O-10), `.claude/**` (including child 3's generated skill mirror, rules and agents), `config/blast-radius.json`, `.mcp.json` (O-10); Codex = `.codex/**` (including `config.toml` and `.codex/lib/**`), Codex-only `.agents/skills/**`; Copilot = `.github/**` (including `copilot-instructions.md`, which is bundled but not published today).

Pack manifests: keep the existing per-bundle `pack-manifests/` directories (the Pester manifest suites and the Codex generator hard-code `core.json` paths), add `customizations/pack-manifests/*.json` for Copilot, and add one shared-layer manifest that every run loads. Partitioning `.agents/skills` between the shared manifest and the Codex `core.json` is a hand edit that the Codex generator `--check` tolerates (it only requires agent paths).

### 5.3 Testing "an unused ecosystem installs no files"

Jest, in-memory destination through the existing `PushDownFileSystem` fakes and the real-bundle reader (`real-bundle-filesystem.test-helpers.ts`): call one wrapper per ecosystem and assert that every written path is under the shared-layer set or that ecosystem's roots, and that no path is under another ecosystem's roots. A data-driven test over the three ecosystems also asserts that the shared-layer set is written in each case. A completeness test over the full bundle (every file under a published root is in exactly one layer's manifest, or in a documented exception) closes the gap in section 1.4.

---

## 6. Quality-Tier and Toolchain Implications

- `quality-tiers.yml` exists. `extensions/drm-copilot` is T3; `packages/mcp-server` is T4. New TypeScript modules in `extensions/drm-copilot/src/lib/push-down/` need no new entry. A new PowerShell module folder needs an entry only if it creates a discovered project (`scripts/dev_tools/quality_tiers_contract.py`: R2 `*.psd1` with a same-stem `*.psm1`, R3 `scripts/<name>` with code, R4 `.claude/lib/<name>`, R5 hook folders); otherwise QT008 fails. The recommended design adds no PowerShell.
- Jest: `extensions/drm-copilot/jest.config.cjs` (535 lines) has per-file entries only and no `global` key; push-down entries exist for `claude-blast-radius-derive-core.ts`, `-derive-manifests.ts`, `claude-gitignore-merge.ts`, `claude-exclusion-manifest.ts`, `claude-exclusion-filter.ts`, `claude-customizations.ts`, `claude-filesystem-adapter.ts`, `push-down-service-call.ts`, `copilot-customizations-engine.ts`, `claude-blast-radius-overlay.ts`, `codex-agents-customizations.ts`. Each new production file needs its own entry (lines 85, branches 75). The file is in the parallel run's blast radius (items 1003, 1006).
- Pester coverage: not applicable unless PowerShell is added; `config/poshqc-coverage.json` roots are `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.github/hooks`, `.codex/scripts`, `scripts`.
- File sizes (500 guidance / 700 advisory / 800 hard): `claude-customizations.ts` 496 (at the guidance tier; new logic goes into new modules), `mcp-tool-inputs.ts` 483, `mcp-tool-definitions.ts` 462, `mcp-tools.ts` 461, `repo-automation-service.ts` 450, `copilot-customizations-engine.ts` 449, `claude-blast-radius-overlay.ts` 447, `mcp-repo-automation-tool-definitions.ts` 425, `repo-automation-command-registration-admin.ts` 420, `codex-agents-customizations.ts` 391; tests `mcp-server.test.ts` 494, `codex-agents-customizations.test.ts` 481. None is near 700 or 800; `jest.config.cjs` is 535 (configuration, above the guidance tier). No push-down file is in `config/file-size-baseline.json`.

---

## 7. Bundle Mirrors and Contract Tests

From the brief (`## Contract Tests That Pin Mirrored Files`), child 4 must keep green:

- `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` (bundle equality; also `EXPECTED_DRM_COPILOT_TOOLS` and `.codex/config.toml` root/bundle equality).
- `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py` (any new or moved manifest entry).
- `test_push_down_pack_manifest_dependency_closure.py` (core plus owning pack closure; a new shared-layer manifest must be included in the closure model or the test extended in place).
- The Codex generator `--check` (`scripts/dev_tools/generate_codex_agent_variants.py`; Codex `core.json` edits must keep required agent paths).
- `test_push_down_issue_824_follow_ups.py` (pushed rules and skills name no consuming product; the shared layer adds files in scope).
- `test_claude_rules_frontmatter.py`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `parallel_orchestrator_surface_expectations.py`, `test_typescript_toolchain_instruction_contracts.py`, `claude-architecture-doc.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`: not affected unless child 4 edits the files they pin.
- Not in the brief but affected: `test_push_down_claude_parity.py` and `test_skill_bundle_contract_repo.py` (TypeScript `ROOT_FOLDERS` text), the four parity tests in section 2.3, and the Pester `*.Manifest.Tests.ps1` suites.
- Brief maintenance: adding a contract test (for example the full-bundle completeness test or a Copilot manifest completeness test) to the brief list, or changing the brief's push-down fact (`## MCP Surfaces Run the Installed Extension`), requires a same-change update of all six byte-identical copies.

---

## 8. Overlap With the In-Flight Parallel Run

Union source: `blast_radius.paths` of the nine items in `SCRATCH/parallel-manifest.md` (1001, 1002, 1003, 1006, 1009, 1010, 1011, 1012, 1013). Item 1009 appears merged (`Merge pull request #1017 from drmoisan/bug/batch-budget-hooks-coordinator-root-1009` is in the recent commit list); the merge state of the other eight is UNVERIFIED (orchestrator `gh`).

Child 4's likely file set and its overlaps with that union (child 4 must not edit any of these before the run merges):

| Path | Items |
| --- | --- |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 1002, 1006, 1009, 1010, 1012, 1013 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | 1009, 1010 |
| `extensions/drm-copilot/jest.config.cjs` | 1003, 1006 |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 1001, 1002, 1010, 1013 |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | 1010 |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | 1010, 1013 |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | 1010 |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | 1003, 1010, 1013 |
| `tests/scripts/dev_tools/test_push_down_claude_customizations.py`, `test_push_down_codex_and_agents_customizations.py` | 1009 |
| `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | 1013 |
| `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py`, `test_push_down_claude_blast_radius_overlay.py` | 1006 (1013 also names the latter's Python source) |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` (1006 also adds `claude-blast-radius-overlay-demote.ts`) | 1006 |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | 1006, 1013 |
| `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-parity.test.ts` | 1006 |
| `.claude/skills/execution-environment/SKILL.md` | 1001, 1002, 1006, 1009, 1010, 1012, 1013 |
| `.agents/`, `.github/` and the three bundled `execution-environment/SKILL.md` copies | 1009 |
| `.codex/config.toml` (only if a new MCP tool is added) | 1009, 1010 |
| `extensions/drm-copilot/package.json`, `README.md`, `CHANGELOG.md` | 1003 |
| `extensions/drm-copilot/test/extension.workflow-commands.test.ts` | 1003 |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`; `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` (only if manifest shape changes) | 1009; 1013 |
| `scripts/dev_tools/generate_codex_agent_variants.py` (run, not edited) | 1002, 1010, 1012, 1013 |

No overlap: the other push-down TypeScript modules, `mcp-push-down-schema-properties.ts`, `mcp-tool-inputs-push-down.ts`, `mcp-tools.ts`, the service files, both tool-definition lists, `repo-automation-command-registration-admin.ts`, the remaining Jest push-down tests, `customizations/pack-manifests/` (new), and `.agents/skills/repo-automation-adapter/SKILL.md`. Item 1006 changes the Claude destination-write chain (overlay demotion), so the Phase 0 gate re-reads `DESTINATION_WRITE_DECORATORS` after the run merges.

---

## 9. Upstream Assumptions

Child 1 (#1025; `SCRATCH/child1/spec.md`, `## Interface Contracts`):

- Matrix at `config/harness-parity-matrix.json` (schema `config/harness-parity-matrix.schema.json`, Draft 2020-12, `schema_version` 1.x); child 4 selects entries by the `ecosystem`, `kind`, `name` and `disposition` fields, not by parsing `id`.
- Contracts at `.agents/skills/<name>/references/standard.md` with byte-identical bundle copies under `codex-and-agents-customizations/.agents/skills/<name>/references/`; no manifest entry (Q1 deferred to child 4).

Child 3 (no branch exists; the epic manifest child 3 scope is the authority; `SCRATCH/child3/research__research.2026-10-30T22-46.md` is a preparation artifact, not merged). Child 4 assumes:

- `.agents/skills/<name>/` is the shared-skill source and `.claude/skills/<name>/` its generated mirror; both written with bundle copies under the existing roots (`codex-and-agents-customizations/.agents/skills`, `claude-customizations/.claude/skills`).
- Rules generated into `.claude/rules/*.md` (`paths:`) and `.github/instructions/*.instructions.md` (`applyTo`), with bundle copies under `claude-customizations` and `customizations`; possibly `.agents/skills/<rule>/SKILL.md` (child 3 OQ-2).
- MCP generated into the root `.mcp.json` and the `[mcp_servers]` table of `.codex/config.toml`; bundle copies at `codex-and-agents-customizations/.codex/config.toml` and a `.mcp.json` location that child 3 names (today only the unused `claude-dir-customizations/.mcp.json` exists).
- Agents generated into `.claude/agents/*.md` and `.codex/agents/*.toml` with bundle copies; Codex variants still produced by `generate_codex_agent_variants.py`, which keeps appending agent paths to the Codex manifests.
- `AGENTS.md` as the hand-authored instruction source and `CLAUDE.md` as `@AGENTS.md` plus Claude-only text; the `AGENTS.md` bundle copy stays at `codex-and-agents-customizations/AGENTS.md`; no `CLAUDE.md` bundle copy exists yet.
- Generators are PowerShell and repository-internal (child 3 OQ-1 default); destinations receive generated outputs, not generators.
- Child 3 adds manifest entries for the files the existing completeness tests enumerate; child 4 owns the remaining "pack manifests list the generated files" work.

---

## Recommended Approach

- One TypeScript pipeline in new modules under `extensions/drm-copilot/src/lib/push-down/` (for example an ecosystem registry, a shared-layer and pack resolver, a planner and comparator, a manifest reader/writer, and a reporter), built on the existing engine's enumeration and the existing decorators. `claude-customizations.ts` (496 lines) receives no new logic; the three entry points become thin adapters that call the pipeline with one ecosystem.
- Existing pinned TypeScript declarations (`ROOT_FOLDERS`, `MERGED_RELATIVE_PATHS`, `DESTINATION_WRITE_DECORATORS`, `EXCLUDED_RELATIVE_PATHS`, the Codex virtual pairs) keep their names and literal values where possible, so the static parity tests and `test_skill_bundle_contract_repo.py` stay green without Python edits; the shared layer is a separate declaration. Where a pinned value must change, O-6 applies.
- Destination edits detected through `.push-down-manifest.json` with SHA-256 of LF-normalized text and the decision table in section 4.1; dry run returns a deterministic report and writes nothing.
- Additive MCP schema changes only; no new tool by default.
- Manifests: existing per-bundle directories, new Copilot manifests, one shared-layer manifest, and a full-bundle completeness test in Jest.

Rejected alternatives:

- PowerShell pipeline core invoked by the MCP server: adds a process boundary and a second implementation next to the TypeScript engine; the core is not pushed down, so clause (1) does not require it.
- Using the existing per-run summary artifact as the "last manifest": no hashes, a new file per run, absolute paths, and usually under a gitignored `artifacts/`.
- One merged payload root replacing the three bundle roots: breaks every bundle contract test, child 1's bundle-copy path and the Codex generator for no functional gain.

---

## Behavior Semantics (for the spec)

- Success: an apply run writes exactly the `create` and `update` files, adopts identical files, records the manifest, and returns the report; a second identical run writes no file outside `artifacts/` and reports every file `unchanged` (O-11 for the summary artifact).
- Failure before any write: missing or malformed pack manifest, both C# variants selected, malformed `.push-down-exclusions`, malformed `.push-down-manifest.json` (unknown `schema_version`, invalid JSON, missing fields), destination missing or equal to the source.
- Ordering: read exclusions and the manifest, resolve selection, enumerate shared layer then ecosystem roots, plan, then (apply only) write files, merges, `.gitignore`, the manifest, and the summary artifact.
- Edge cases: CRLF destination copies; files under a deselected pack or ecosystem (`orphaned`); a destination that deleted a managed file; a merged path with local content; Copilot reference rewrites changing the payload hash; legacy C# variant routing (hash of the routed payload).

## Testing Implications

- Jest unit tests per new module with in-memory `PushDownFileSystem` fakes (no temporary files): each row of the decision table, dry run writes nothing, manifest idempotence, selection persistence (per O-5), shared layer present for each ecosystem, no foreign-ecosystem path for each ecosystem, schema rejection paths, and wrapper result shape unchanged when the new fields are absent.
- Integration-style Jest with the real bundle reader and an in-memory destination: push down twice (second run no-op), push down with a local edit (preserved and reported), first run against a pre-populated destination (unmanaged conflicts).
- Python and Pester contract tests run unchanged except where section 2.3 names an in-place update; the plan records each disposition.
- Coverage: per-file `coverageThreshold` entries for every new file; isolation runs per the brief (seeded shuffled Jest with the seed recorded).

## Numeric Derivation Evidence

No numeric count, enumeration or population is proposed for a `spec.md` acceptance criterion. The counts in this document (line counts, exception-set sizes) are informational planning context and are not acceptance thresholds.

## Pre-Mortem

- Review checklists: a reviewer can find that a wrapper's result shape or default changed for callers that pass no new field, or that a test asserting `overwritten` was edited without a stated reason. Mitigation: the plan lists every test in section 2.3 with its disposition, and a wrapper-compatibility test asserts the old shape for old inputs.
- Coverage: new pipeline modules without their own `coverageThreshold` entry are ungated, and a planner tested only through blanket mocks of the comparator overstates coverage. Mitigation: one entry per new file in `jest.config.cjs` (after the parallel run merges) and unit tests that exercise real comparator and reporter code with in-memory fakes.
- Mirror parity: new Copilot or shared manifests, moved `.agents/skills` entries, or a new contract test can break the resource-contract, completeness and closure tests or leave the brief stale. Mitigation: run every test in section 7 after each manifest change; if the brief's contract-test list or push-down facts change, one task updates all six copies.
- File size: `claude-customizations.ts` is at 496 lines and several MCP files are between 420 and 483. Mitigation: new logic only in new modules; each edited file re-measured before commit.
- Test isolation: tests that share a mutable in-memory destination or a module-level registry can leak between cases under shuffled order. Mitigation: a fresh fake per test, no module-level mutable state in the pipeline, and the seeded shuffled Jest run recorded under `<FEATURE>/evidence/regression-testing/`.
- CI-only behavior: drive-letter fixture paths fail `path.isAbsolute` on Linux, and a CRLF fixture is normalized to LF on checkout. Mitigation: POSIX in-memory roots such as `/dest`, CRLF content built in test code rather than committed, and the Jest suites run on both `ubuntu-latest` and `windows-latest`.
- Evidence: counts taken from PoshQC MCP summaries or evidence with absolute paths fail review. Mitigation: evidence under `<FEATURE>/evidence/<kind>/` with `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`, scratch paths recorded as `SCRATCH`, and Jest counts read from the run output.

## Automation Feasibility

| Step | Needs a human? | Notes |
| --- | --- | --- |
| Pipeline, wrappers, manifests, tests | no | TypeScript and JSON; Jest with in-memory destinations |
| Push-down to a realistic destination | no | the real-bundle reader plus an in-memory destination covers create, no-op, local-edit and first-run cases; no real directory is needed |
| Live MCP check of the branch | not required | MCP tools run the installed extension (brief); a live check needs a build and install and is optional evidence, not an acceptance condition |
| Phase 0 gate (parallel-run merge state, ruleset, child 1 and child 3 outputs) | no | orchestrator `gh` and file reads |
| Owner questions O-1 to O-11 | yes, before planning or at preflight | defaults below allow planning to proceed |
| Child 1 approvals and child 3 merge | owned upstream | consumed at the Phase 0 gate |

## Owner Questions

Each carries a recommended default for planning.

- **Q1 (from child 1) Contracts in destinations.** Should `.agents/skills/<name>/references/standard.md` reach destinations through pack-manifest entries, or stay repository-local? Default: deliver them with their skill (same pack and layer as the `SKILL.md`), because the shared-skill contract is part of the shared layer and an unlisted bundled file is already published by any MCP call without `packs`. If the answer is "repository-local", child 4 must also exclude them from the no-`packs` path.
- **O-1 Language of the pipeline core.** The core runs only in the MCP server and extension host and is reached from agent content only as an MCP tool call by the `repo-automation-adapter` skill. Confirm that this is MCP-command code (TypeScript) and that the epic's "if a skill invokes it" clause does not apply to MCP tool calls. Default: TypeScript.
- **O-2 New unified MCP tool.** Add a single tool with `ecosystems` and per-ecosystem `packs`, or keep only the three wrappers? Default: wrappers only in child 4; a unified tool changes `.codex/config.toml` `enabled_tools` (child 3 generator source), `EXPECTED_DRM_COPILOT_TOOLS`, the adapter skill and an MCP release.
- **O-3 Dry run before writing.** The issue says a push-down "reports a dry run before writing". Is an explicit `dry_run: true` call followed by an apply call sufficient (apply still computes and reports the plan), or must apply refuse to run until a dry run was made? Default: `dry_run` optional, default false, plan always reported; conflicts are never overwritten, so apply stays non-destructive.
- **O-4 Unmanaged differing files.** A destination with no manifest (including every destination pushed down by an earlier release) has files that differ from the new payload. Report and skip by default, with an explicit opt-in such as `overwrite_unmanaged: true`? Default: report and skip; opt-in available.
- **O-5 Omitted `packs` after a first run.** Reuse the selection recorded in the manifest, or keep today's publish-everything meaning? Default: reuse the recorded selection when one exists for that ecosystem; publish everything only when none exists.
- **O-6 Python ports and their parity pins.** The issue says the Python ports "may be reused or called, not added to"; the epic rule allows "extend in place". If a pinned TypeScript declaration must change, update the Python port in place, or retire the ports and their parity tests? Default: avoid changing pinned declarations; if unavoidable, stop for this decision.
- **O-7 Removal of orphaned files.** When a pack or ecosystem is deselected, delete managed, unmodified files, or only report them? Default: report only (`orphaned`); no delete operation in child 4.
- **O-8 `.push-down-exclusions` scope.** Apply the destination exclusion file to Codex and Copilot as well as Claude in the one pipeline? Default: yes.
- **O-9 Generators in destinations (child 3 OQ-1).** Push generators down? Default: no; destinations receive generated outputs only.
- **O-10 Root instruction and MCP files.** Should the push-down write `AGENTS.md`, `CLAUDE.md` and `.mcp.json` to destination roots, where a destination usually has its own? Default: deliver them as whole files under the no-overwrite rule (a destination's own file becomes a reported conflict); `AGENTS.md` in the shared layer, `CLAUDE.md` and `.mcp.json` in the Claude layer.
- **O-11 Manifest tracking and no-op definition.** Is `.push-down-manifest.json` committed in destinations (recommended, so a fresh clone keeps protection) or ignored, and does "second run is a no-op" exclude the per-run summary artifact under `artifacts/`? Default: committed; no-op means no file outside `artifacts/` changes.
- **O-12 Pre-existing manifest gaps.** The Codex completeness test excepts 26 agents and 34 skills, and neither completeness test covers rules, libs or supporting files, so manifest-scoped push-downs drop them. Close the gaps in child 4 (with a full-bundle completeness test), or leave them? Default: close them in child 4, because acceptance criterion 5 and per-ecosystem selection make manifest-scoped runs the normal case.
