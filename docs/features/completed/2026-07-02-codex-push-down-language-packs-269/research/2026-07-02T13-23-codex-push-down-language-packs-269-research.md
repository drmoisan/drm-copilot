<!-- markdownlint-disable-file -->

# Task Research Notes: Codex Push-Down Language Packs and C# Variant Behavior 269

## Research Executed

### File Analysis

- docs/features/active/2026-07-02-codex-push-down-language-packs-269/issue.md
  - Verified this is the active issue document for issue #269. The document is still a promoted template with placeholder problem statement, placeholder acceptance criteria, and Work Mode `full-feature`.
- docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/issue.md
  - Verified the completed Claude feature behavior: no-argument backward compatibility, always-included `core`, opt-in language packs, selectable C# variants, memory modes, VS Code QuickPick flow, MCP fields, parity-test update, and conflict-prevention tests.
- docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/spec.md
  - Verified the implementation shape for the existing Claude feature: Python CLI flags, TypeScript service fields, MCP schema/input mapping, pack manifests, `.claude-variants/csharp-legacy/`, memory-mode filtering, and tests.
- scripts/dev_tools/push_down_claude_customizations.py
  - Verified the Claude Python entry point composes manifest loading, `ExcludingFileSystem`, C# variant routing, and memory modes before delegating to the shared push-down engine. Relevant anchors: `BUNDLE_ROOT_RELATIVE_DIR` at line 67, `PACK_MANIFEST_SUBDIR` at line 71, manifest resolution and mutual-exclusion check at lines 176 and 184, `ExcludingFileSystem` composition at line 261, and CLI flags at lines 319, 328, and 335.
- scripts/dev_tools/push_down_claude_pack_selection.py
  - Verified pure logic for manifest validation, `core` inclusion, C# canonical destination paths, legacy source routing, and mutual-exclusion detection. It has no direct disk I/O and uses the injected push-down filesystem adapter.
- scripts/dev_tools/push_down_codex_and_agents_customizations.py
  - Verified the Codex/agents Python entry point has only `--destination`, `ROOT_FOLDERS = (.codex, .agents)`, `ARTIFACT_DIRECTORY = artifacts/codex-and-agents-customizations`, and direct delegation to the shared engine. Relevant anchors: artifact/root constants at lines 37 and 39, publisher call at lines 52-70, and the only CLI argument at line 84.
- extensions/drm-copilot/src/lib/push-down/claude-customizations.ts
  - Verified the TypeScript Claude port mirrors the Python behavior with `resolvePublishedPaths`, pack manifests, `ExcludingFileSystem`, C# variant and memory-mode defaults, and service-call options.
- extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts
  - Verified the TypeScript pure helper mirrors the Python helper: `CORE_PACK_NAME`, `CSHARP_CANONICAL_PATHS`, `CSHARP_PACK_NAMES`, `LEGACY_VARIANT_SOURCE_PREFIX`, manifest parsing, path computation, variant routing, and mutual exclusion.
- extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts
  - Verified the TypeScript Codex/agents publisher currently delegates directly to the shared engine with `ROOT_FOLDERS = [".codex", ".agents"]` and no pack-selection, variant, or memory-mode layer.
- extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts
  - Verified the service call resolves Codex bundle root as `resources/codex-and-agents-customizations` and Claude bundle root as `resources/claude-customizations`; only Claude threads `packs`, `csharpVariant`, and `memoryMode`.
- extensions/drm-copilot/src/repo-automation-service.ts
  - Verified `PushDownClaudeCustomizationsInput` includes `packs`, `csharpVariant`, and `memoryMode`; `pushDownCodexAndAgentsCustomizations` still accepts only `WorkspaceExecutionInput`.
- extensions/drm-copilot/src/repo-automation-command-registration-admin.ts
  - Verified the Codex command invokes the service immediately with only `workspaceRoot` at lines 104-114. Verified the Claude command shows a multi-select pack QuickPick, conditional C# variant prompt, memory-mode prompt, pack-name translation, and service invocation at lines 139-204.
- extensions/drm-copilot/src/mcp-tool-definitions.ts and extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts
  - Verified `push_down_codex_and_agents_customizations` exposes only `workspace_root`. Verified `push_down_claude_customizations` exposes optional `packs`, `csharp_variant`, and `memory_mode`, with no required array for those fields.
- extensions/drm-copilot/src/mcp-tool-inputs.ts and extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts
  - Verified Codex input resolution returns only `workspaceRoot`. Verified Claude input resolution validates and maps `packs`, `csharp_variant`, and `memory_mode`.
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json
  - Verified Claude manifests exist for `core`, `python`, `powershell`, `typescript`, `csharp-modern`, and `csharp-legacy`; the legacy C# manifest has `source_prefix: ".claude-variants/csharp-legacy"` and the same four canonical destination paths as the modern C# manifest.
- extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/**
  - Verified the Claude bundle-only legacy variant subtree exists with four files: C# rules, C# typed engineer, C# QA gate, and invoke-C# engineer.
- extensions/drm-copilot/resources/codex-and-agents-customizations/**
  - Verified the Codex bundle contains `.agents` skills and `.codex` agents, including C# assets, but has no `pack-manifests`, no `.codex-variants`, no `.agents-variants`, and no Codex-specific pack-selection helper.
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md
  - Verified the current Codex C# skill is a single root profile using CSharpier, MSBuild, nullable analysis, MSTest, Moq, FluentAssertions, and `vstest.console.exe`. It is not separated into selectable variant sources.
- tests/scripts/dev_tools/test_push_down_claude_pack_selection.py
  - Verified Python tests for Claude manifest parsing, `core` inclusion, variant source routing, C# mutual exclusion, CLI defaults, and explicit CLI arguments.
- tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py
  - Verified Python end-to-end coverage for selected packs, legacy content at canonical C# paths, mutual-exclusion failure, exactly one C# toolchain, and full-tree no-argument compatibility.
- tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py
  - Verified Codex Python tests cover only full `.codex`/`.agents` copying, artifact directory, passthrough rewrite counts, and CLI artifact output.
- tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
  - Verified Codex resource-contract tests require bundled runtime files and byte-identical inclusion of repo `.agents` and `.codex` files, with no variant-subtree exclusion.
- extensions/drm-copilot/test/lib/push-down/claude-pack-selection.test.ts
  - Verified TypeScript tests mirror the Claude pack-selection pure helper behavior.
- extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts
  - Verified TypeScript Codex tests cover deterministic full-tree copy, zero rewrites, artifact path, defaults, and created/overwritten classification only.
- extensions/drm-copilot/test/repo-automation-service.push-down-claude.test.ts
  - Verified service-level tests confirm Claude option forwarding and no-field backward compatibility.
- extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts
  - Verified MCP tests confirm Claude option forwarding and schema synchronization between both MCP definition files.

### Code Search Results

- `push_down_codex_pack_selection.py`
  - Verified absent with `Test-Path`: no Python Codex equivalent to `push_down_claude_pack_selection.py` exists.
- `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts`
  - Verified absent with `Test-Path`: no TypeScript Codex equivalent to `claude-pack-selection.ts` exists.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests`
  - Verified absent with `Test-Path`: Codex has no manifest directory.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants`
  - Verified absent with `Test-Path`: no Codex variant subtree exists.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants`
  - Verified absent with `Test-Path`: no agents variant subtree exists.
- `VSTO|packages.config|vstest.console|FluentAssertions|Moq`
  - Verified Codex bundle contains some legacy-toolchain indicators in the current root profile, but no variant-separated source tree.
- `pack-manifests|.claude-variants|csharp-legacy`
  - Verified Claude bundle contains the completed language-pack and legacy C# variant structure used as the implementation model for issue #269.

### External Research

- #githubRepo:"modelcontextprotocol/modelcontextprotocol inputSchema JSON Schema"
  - Verified the official MCP repository describes itself as containing the MCP specification, protocol schema, and official documentation. It states the schema is defined in TypeScript and made available as JSON Schema for compatibility: https://github.com/modelcontextprotocol/modelcontextprotocol
- #fetch:https://code.visualstudio.com/api/ux-guidelines/quick-picks
  - Verified VS Code Quick Picks are the official UI pattern for configuration selection, filtering, and list selection. The guidance supports multi-step quick picks for related selections and multi-select quick picks for closely related selections that should be selected in one step.
- #fetch:https://modelcontextprotocol.io/specification/2025-06-18/server/tools
  - Verified MCP tool definitions include a unique `name`, human-readable `description`, and `inputSchema` using JSON Schema for expected parameters. This supports adding optional Codex selection fields to both MCP definition files without making them required.
- #fetch:https://modelcontextprotocol.io/specification/2025-11-25/basic
  - Verified MCP uses JSON Schema for validation, defaults schemas without `$schema` to JSON Schema 2020-12, and requires clients and servers to validate schemas according to the declared or default dialect.

### Project Conventions

- Standards referenced: `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/python/SKILL.md`, `.agents/skills/typescript/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, and `.agents/skills/research-issue/SKILL.md`.
- Instructions followed: research-only behavior, write only under `artifacts/research/`, issue #269 as the current feature issue, no code implementation, no policy-file modification, rejected alternatives kept inside `## Recommended Approach`, verified findings only, and no nested delegation.

## Key Discoveries

### Project Structure

The push-down implementation has two runtime layers for each supported payload:

- Python scripts under `scripts/dev_tools/` preserve CLI and regression coverage.
- TypeScript files under `extensions/drm-copilot/src/lib/push-down/` provide the in-process extension implementation used by VS Code commands and MCP service calls.

The shared push-down engine handles destination validation, deterministic source enumeration, created/overwritten classification, optional text rewrite, and JSON summary artifact creation. Runtime-specific wrappers supply root folders, artifact directory, rewrite behavior, and any filtering adapter.

The Claude workflow has a complete selection stack:

- Bundle assets: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/` and `.claude-variants/csharp-legacy/`.
- Python logic: `push_down_claude_customizations.py`, `push_down_claude_pack_selection.py`, and `push_down_claude_filesystem.py`.
- TypeScript logic: `claude-customizations.ts`, `claude-pack-selection.ts`, and `claude-filesystem-adapter.ts`.
- UI/MCP/service surfaces: command registration, service input, service-call forwarding, MCP input resolution, and both MCP definition files.

The Codex/agents workflow is currently full-tree only:

- Bundle root: `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- Root folders: `.codex` and `.agents`.
- Python entry point: `push_down_codex_and_agents_customizations.py`.
- TypeScript entry point: `codex-agents-customizations.ts`.
- Service/MCP/UI surfaces accept only `workspaceRoot`.

### Implementation Patterns

The existing Claude implementation establishes the pattern issue #269 should follow:

- The no-selection path returns `None`/`null` for published paths and publishes the full tree without manifest reads.
- Explicit selection loads manifests for selected packs plus `core`.
- Pack filtering is enforced in the filesystem wrapper, not only in UI.
- C# variant routing changes the read source while preserving the canonical destination path.
- Mutual exclusion rejects both C# variants in one run.
- The VS Code command maps a user-facing `csharp` choice to variant-specific manifest names.
- MCP schema fields remain optional so existing calls remain valid.

The Codex implementation can reuse the shared engine but cannot reuse Claude manifests directly because destination roots differ (`.claude/**` versus `.codex/**` and `.agents/**`). It also cannot rely on UI-only selection because MCP and direct CLI callers must receive the same enforcement.

### Complete Examples

```typescript
// Existing Claude service input shape, verified in extensions/drm-copilot/src/repo-automation-service.ts.
export interface PushDownClaudeCustomizationsInput extends WorkspaceExecutionInput {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: "modern" | "legacy";
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}
```

```python
# Existing Codex entry point, verified in scripts/dev_tools/push_down_codex_and_agents_customizations.py.
ARTIFACT_DIRECTORY = "artifacts/codex-and-agents-customizations"
ROOT_FOLDERS: tuple[Path, ...] = (Path(".codex"), Path(".agents"))
```

```json
{
  "name": "csharp-legacy",
  "source_prefix": ".claude-variants/csharp-legacy",
  "paths": [
    ".claude/rules/csharp.md",
    ".claude/agents/csharp-typed-engineer.md",
    ".claude/skills/csharp-qa-gate/SKILL.md",
    ".claude/skills/invoke-csharp-engineer/SKILL.md"
  ]
}
```

### API and Schema Documentation

For issue #269, the Codex MCP schema should mirror the Claude shape while using Codex tool names and Codex service input names:

- Tool: `push_down_codex_and_agents_customizations`.
- Existing required fields: none.
- Existing optional field: `workspace_root`.
- New optional fields: `packs`, `csharp_variant`, and `memory_mode`.
- `additionalProperties: false` should remain.
- No new field should be added to `required`.

This is consistent with MCP tool definitions requiring an `inputSchema` for expected parameters and with MCP JSON Schema validation rules. Both `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts` must be updated together because existing tests enforce parity for the Claude schema and the repo has duplicate definition files.

### Configuration Examples

```json
{
  "name": "core",
  "label": "Core (always included)",
  "paths": [
    ".codex/config.toml",
    ".agents/README.md",
    ".agents/skills/README.md"
  ]
}
```

```json
{
  "name": "csharp-legacy",
  "label": "C# legacy",
  "source_prefix": ".agents-variants/csharp-legacy",
  "paths": [
    ".agents/skills/csharp/SKILL.md",
    ".agents/skills/csharp-qa-gate/SKILL.md",
    ".agents/skills/invoke-csharp-engineer/SKILL.md",
    ".codex/agents/csharp-typed-engineer.toml"
  ]
}
```

The second JSON block is a proposed Codex analogue, not an existing file. The exact Codex C# canonical path list must be finalized from the current `.agents` and `.codex` C# surfaces before implementation. The verified current C# surfaces include `.agents/skills/csharp/SKILL.md`, `.agents/skills/csharp-qa-gate/SKILL.md`, `.agents/skills/invoke-csharp-engineer/SKILL.md`, and `.codex/agents/csharp-typed-engineer.toml`; additional C# support files such as budget router and orchestration-state skills may need to remain in the C# pack or core depending on intended runtime coupling.

### Technical Requirements

- Preserve no-argument behavior for issue #269: existing Codex command, MCP call, and CLI call with only destination/workspace root must publish the full `.codex` and `.agents` trees.
- Add explicit Codex language-pack selection with `core` always included.
- Add a Codex C# variant mechanism that writes exactly one selected C# toolchain to canonical `.agents` and `.codex` destination paths.
- Keep variant sources bundle-only and exclude them from default full-tree destination writes.
- Add Codex bundle manifests because no Codex manifest directory exists today.
- Add Codex variant source directories because no `.codex-variants`, `.agents-variants`, or equivalent exists today.
- Add Python and TypeScript Codex pack-selection helpers because no Codex equivalents exist today.
- Add command, service, MCP input, MCP schema, and test coverage for the new optional fields.
- Decide whether `memory_mode` should apply to Codex. The current Codex bundle has no `.claude/agent-memory` equivalent in the inspected paths, so the field may be retained for Claude parity but should be inert unless a Codex memory subtree is introduced.

**Mandatory unachievable objective callout**:
- No issue #269 objective was proven unachievable. The required Codex behavior is achievable by adding missing Codex-specific manifest, variant, wrapper, UI, service, MCP, and test surfaces. The current issue document does not yet define detailed acceptance criteria, so implementation planning must derive concrete criteria from the Claude feature comparison unless issue #269 is expanded.

## Recommended Approach

Implement a Codex-specific pack-selection and C# variant layer that ports the Claude design to `.codex` and `.agents`, while preserving Codex no-argument full-tree behavior.

Recommended design:

- Add `scripts/dev_tools/push_down_codex_pack_selection.py` with the same pure-helper responsibilities as `push_down_claude_pack_selection.py`, but with Codex/agents canonical paths and variant prefixes.
- Add a Python filtering filesystem wrapper for Codex, or extend a narrowly named Codex wrapper module, to apply pack filtering and C# variant source redirection before delegating to the shared engine. Do not place this logic inside the shared engine because Claude-specific memory scope, Codex roots, and variant path spaces differ.
- Extend `scripts/dev_tools/push_down_codex_and_agents_customizations.py` with optional `--packs`, `--csharp-variant`, and `--memory-mode` arguments. The no-argument path should continue to publish everything and should not require manifest reads.
- Add `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts` and update `codex-agents-customizations.ts` to mirror the Python behavior in the in-process implementation.
- Add bundle-only Codex manifests under `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/`.
- Add bundle-only C# variant sources under a Codex-specific path. Use a path that cannot be enumerated by the default `.codex` and `.agents` roots, such as `.agents-variants/csharp-legacy/` for `.agents` destination files and `.codex-variants/csharp-legacy/` for `.codex` destination files. If implementation prefers one combined variant root, its source resolver must still map to both `.agents/**` and `.codex/**` canonical destinations without creating destination variant paths.
- Extend `PushDownCodexAndAgentsCustomizations` service types and forwarding in `repo-automation-service.ts`, `repo-automation-service-push-down.ts`, and `push-down-service-call.ts`.
- Extend `registerPushDownCodexAndAgentsCustomizationsCommand` to match the Claude command flow: pack multi-select, C# variant prompt only when C# is selected, memory-mode prompt only if issue #269 decides Codex memory handling is required. The VS Code Quick Pick guidance supports multi-step flows for related selections and multi-select quick picks for related choices.
- Extend `resolvePushDownCodexAndAgentsCustomizationsToolInput`, `mcp-tool-definitions.ts`, and `mcp-repo-automation-tool-definitions.ts` with optional `packs`, `csharp_variant`, and `memory_mode` fields. Preserve `additionalProperties: false` and no required array changes.
- Update Codex resource-contract tests to exclude variant-only roots from root-to-bundle byte-identical assertions, matching the Claude parity-test adaptation.

Rationale:

- This approach preserves the proven Claude semantics while respecting the different Codex destination path space.
- It keeps validation in pure helper modules and filesystem wrappers, where the existing tests can cover it without filesystem temp files.
- It avoids broad changes to the shared engine, reducing regression risk for Copilot and Claude push-down.
- It preserves backward compatibility by keeping selection fields optional and making the no-selection path publish everything.

Rejected alternatives:

- Generalize Claude and Codex into one cross-runtime pack engine now. Rejected for issue #269 because Claude has `.claude/agent-memory` filtering and Codex has two destination roots; a shared abstraction would be broader than needed and would increase the chance of changing working Claude behavior.
- Reuse Claude manifests for Codex. Rejected because Claude manifests enumerate `.claude/**` paths and cannot correctly select `.codex/**` and `.agents/**` destination paths.
- Implement selection only in the VS Code command. Rejected because MCP and CLI callers would bypass enforcement, and the existing Claude behavior enforces selection in the engine path.

## Implementation Guidance

- **Objectives**:
  - Add issue #269 Codex language-pack selection equivalent to the Claude workflow.
  - Add issue #269 Codex C# variant behavior with exactly one C# toolchain written to canonical destination paths.
  - Preserve no-argument backward compatibility for CLI, service, VS Code command, and MCP tool calls.
  - Document or implement an explicit decision for Codex memory mode because no Codex memory subtree was verified in the current bundle.

- **Key Tasks**:
  - Define Codex pack taxonomy and canonical path lists: `core`, `python`, `powershell`, `typescript`, `csharp-modern`, and `csharp-legacy`.
  - Build Codex manifest files under `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/`.
  - Create bundle-only Codex C# legacy or modern variant sources, depending on which profile is not represented by the root Codex bundle.
  - Add Python pure helper tests before wiring the CLI.
  - Add TypeScript pure helper tests before wiring service, command, and MCP.
  - Extend `push_down_codex_and_agents_customizations.py` and `codex-agents-customizations.ts` to compute published paths and route C# variant source reads.
  - Extend UI, service, MCP schema, MCP input resolution, and MCP dispatch tests.
  - Update resource-contract tests to include required manifests and exclude variant-only roots from byte-identical root parity.

- **Dependencies**:
  - No new runtime dependency is required based on verified code. Existing implementations use `json`, `argparse`, and injected filesystem adapters in Python; TypeScript uses current VS Code APIs, existing in-memory test helpers, and JSON parsing.
  - Existing external contracts support the design: VS Code Quick Picks support the required multi-step/multi-select user flow, and MCP supports optional tool parameters through JSON Schema input schemas.

- **Success Criteria**:
  - `python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <dest>` publishes the full `.codex` and `.agents` trees as it does today.
  - Supplying `--packs core,typescript` publishes `core` plus TypeScript Codex/agents files and excludes Python, PowerShell, and C# pack files.
  - Selecting a C# legacy or modern variant writes variant content to canonical `.agents` and `.codex` paths and never writes variant source paths to the destination.
  - Selecting both C# variants fails with a specific manifest/selection error.
  - `push_down_codex_and_agents_customizations` MCP schema accepts optional `packs`, `csharp_variant`, and `memory_mode`, and workspace-root-only calls remain valid.
  - VS Code Codex push-down command cancellation at any prompt aborts without invoking the service.
  - Codex resource parity tests pass while intentionally excluding bundle-only variant roots.
  - Python and TypeScript toolchains run in repository order after implementation: format, lint, type-check, tests, and any repository-required architecture/contract/integration checks.

### Requirements Mapping to Design

- Issue #269 current issue document is a template, so concrete requirements should be derived from the completed Claude behavior and recorded in issue #269 before execution.
- Acceptance criterion for backward compatibility maps to no-selection `None`/`null` published paths in both Python and TypeScript.
- Acceptance criterion for `core` maps to manifest loading that unions selected pack names with `core`.
- Acceptance criterion for pack filtering maps to a Codex filesystem wrapper that filters enumeration before shared engine processing.
- Acceptance criterion for C# variants maps to canonical Codex C# destination path constants and source-redirection logic.
- Acceptance criterion for MCP parity maps to updates in both MCP definition files and the Codex input resolver.
- Acceptance criterion for UI maps to `registerPushDownCodexAndAgentsCustomizationsCommand` using the same prompt order and cancellation behavior as the Claude command.
- Acceptance criterion for resource safety maps to contract tests proving variant subtrees are not root runtime files and are not written to destination variant paths.

### Behavior Semantics and Edge Cases

- No selected packs: publish everything, do not require manifests, preserve current destination writes and artifact behavior.
- Empty `packs` array from MCP: treat as no selection to match the Claude service-call behavior.
- Explicit packs without `core`: include `core` automatically.
- Unknown pack name: fail fast with a manifest-missing or invalid-selection error.
- C# pack selected without explicit variant: default to `modern` or the documented current-root profile. The implementation must define this explicitly before coding because the current Codex root C# profile already contains legacy-style MSTest and `vstest.console.exe` details.
- Both C# variants selected: fail before writes.
- C# variant selected while no C# pack is selected: either ignore the variant as not meaningful or fail validation. The Claude spec treats the variant as meaningful only when C# is pushed; issue #269 should preserve that behavior unless it defines stricter validation.
- Destination equals source root: shared engine already rejects this through destination validation.
- Variant source file missing: fail during source read or manifest validation; tests should prefer a specific manifest/source error.
- Variant source path collides with root path: resource-contract tests must catch this before release.
- Memory mode when no Codex memory subtree exists: leave behavior inert and documented, or defer `memory_mode` for Codex. If included for MCP parity, tests should prove it does not change non-memory files.

### Testing Implications

- Python unit tests:
  - Add `test_push_down_codex_pack_selection.py` for manifest parsing, missing/malformed manifest errors, `core` inclusion, variant source path resolution, mutual exclusion, and pack parsing.
  - Extend `test_push_down_codex_and_agents_customizations.py` for no-argument full-tree compatibility, selected pack filtering, C# variant routing, both-variant rejection, and summary file paths.
  - Extend `test_push_down_codex_and_agents_resource_contracts.py` for required manifests, required variant files, variant subtree exclusion from parity, and no destination collision.
- TypeScript unit tests:
  - Add `extensions/drm-copilot/test/lib/push-down/codex-pack-selection.test.ts`.
  - Extend `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts` for selected packs and C# variant routing.
  - Add or extend service tests for `pushDownCodexAndAgentsCustomizations` option forwarding.
  - Add or extend MCP tests for Codex schema parity, resolver validation, and dispatch forwarding.
  - Extend command-registration tests to verify the Codex QuickPick flow, conditional C# variant prompt, cancellation behavior, and selected-pack translation.
- Manual or integration validation:
  - VS Code visual verification should confirm the Codex command presents the same effective flow as Claude.
  - MCP list/call validation should confirm both definition files expose identical Codex schemas and workspace-root-only calls still succeed.
