# 2026-07-02-codex-push-down-language-packs — Spec

- **Issue:** #269
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-02T13-20
- **Status:** Draft
- **Version:** 0.1

## Overview

Issue #269 adds Codex and agents language-pack selection and C# toolchain variant
selection to the existing Codex push-down workflow. The feature mirrors the completed
Claude push-down behavior where applicable, but uses Codex-specific destination paths
under `.codex/**` and `.agents/**`.

The change must preserve backward compatibility. A caller that invokes Codex push-down
with no new pack, C# variant, or memory-mode selection receives the current full-tree
publish behavior and the existing push-down summary artifact behavior.

## Behavior

1. Backward-compatible default path. When no packs are selected, the Codex workflow does
   not require manifests and publishes the complete `.codex` and `.agents` trees from
   `extensions/drm-copilot/resources/codex-and-agents-customizations/`.

2. Manifest-driven pack selection. When packs are selected, the workflow loads Codex
   pack manifests from
   `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/`.
   The `core` pack is always included. Python, PowerShell, TypeScript, and C# files are
   written only when their pack is included in the effective selection.

3. Codex C# toolchain variants. The selected C# variant writes exactly one C# toolchain
   to canonical `.agents` and `.codex` destination paths. The verified initial canonical
   C# path set includes `.agents/skills/csharp/SKILL.md`,
   `.agents/skills/csharp-qa-gate/SKILL.md`,
   `.agents/skills/invoke-csharp-engineer/SKILL.md`, and
   `.codex/agents/csharp-typed-engineer.toml`. Implementation may include additional
   C# support files after confirming they are part of the runtime C# pack.

4. Bundle-only variant sources. Variant source files live outside the default `.codex`
   and `.agents` root folders, for example under `.agents-variants/csharp-legacy/` and
   `.codex-variants/csharp-legacy/`. The default full-tree root enumeration must not
   copy those variant roots to the destination. Variant reads map from the bundle-only
   source path to the canonical destination path.

5. Command, service, MCP, and CLI parity. The Python CLI, TypeScript extension service,
   VS Code command, MCP input resolver, `mcp-tool-definitions.ts`, and
   `mcp-repo-automation-tool-definitions.ts` accept the same optional Codex selection
   fields. Workspace-root-only and destination-only calls remain valid.

6. Memory-mode parity field. The Codex MCP and service surface may expose `memory_mode`
   for parity with Claude push-down. Because no Codex memory subtree was verified in the
   current bundle, `memory_mode` is inert unless Codex memory files are introduced. Tests
   must prove it does not change non-memory files.

## Inputs / Outputs

- Runtime inputs:
  - `--destination <path>`: existing Python CLI destination repository root.
  - `--packs <csv>`: optional comma-separated pack names. Supported names are
    `core`, `python`, `powershell`, `typescript`, and `csharp`. Omitted or empty pack
    input means full-tree backward-compatible publish.
  - `--csharp-variant <modern|legacy>`: optional C# toolchain variant. The default must
    be documented as the current root Codex C# profile before implementation.
  - `--memory-mode <overwrite|merge|skip>`: optional parity field. It is inert for the
    current Codex bundle unless Codex memory files are added.
  - Codex pack manifests under
    `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/`.
  - Codex variant source files under bundle-only variant roots that are not part of
    `.codex` or `.agents` root enumeration.
- Outputs (artifacts, logs, telemetry):
  - Destination `.codex` and `.agents` trees filtered to the effective pack selection,
    or full-tree output when no packs are selected.
  - Selected C# variant content written to canonical `.agents` and `.codex` destination
    paths.
  - Existing JSON push-down summary artifact under
    `artifacts/codex-and-agents-customizations/`.
- Config keys and defaults:
  - `packs` default: omitted or empty means full tree.
  - Explicit pack selection default: `core` is added automatically.
  - `csharp_variant` default: current root Codex C# profile, documented before coding.
  - `memory_mode` default: `overwrite` for schema parity; no effect without Codex memory
    files.
- Versioning or backward-compatibility constraints:
  - No new required CLI argument, service field, MCP schema field, or VS Code selection.
  - Existing Codex push-down callers must continue to succeed without changing input.

## API / CLI Surface

- Python CLI:
  - `python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <repo>`
    publishes the full `.codex` and `.agents` trees.
  - `python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <repo> --packs core,typescript`
    publishes only `core` and TypeScript pack files.
  - `python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <repo> --packs core,csharp --csharp-variant legacy`
    publishes `core` and legacy C# content to canonical destination paths.

- TypeScript service input:
  - Extend the Codex service input used by `pushDownCodexAndAgentsCustomizations` with
    optional `packs?: ReadonlyArray<string>`,
    `csharpVariant?: "modern" | "legacy"`, and
    `memoryMode?: "overwrite" | "merge" | "skip"`.
  - Absent fields produce the backward-compatible full-tree invocation.

- MCP tool definition:
  - Update `push_down_codex_and_agents_customizations` in both
    `extensions/drm-copilot/src/mcp-tool-definitions.ts` and
    `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`.
  - Add optional `packs` as an array of strings, `csharp_variant` as enum
    `modern`/`legacy`, and `memory_mode` as enum `overwrite`/`merge`/`skip`.
  - Preserve `workspace_root` compatibility, preserve `additionalProperties: false`,
    and do not add any new required fields.

- Contracts and validation rules:
  - Unknown pack names fail before writes.
  - Missing or malformed manifests fail before writes.
  - Explicit selection always includes `core`.
  - Selecting both C# variants fails before writes.
  - Selecting a C# variant without C# selected follows the Claude behavior: the variant
    is meaningful only when C# is in the effective pack selection.
  - Variant source roots are never written to destination repositories.

## Data & State

- Data transformations and invariants:
  - VS Code command selections map to service input.
  - Service input maps to Python CLI arguments for the extension-hosted push-down path.
  - MCP raw input maps through the Codex input resolver to the same service fields.
  - Pack manifests map pack names to canonical `.codex` and `.agents` relative paths.
  - Variant routing maps bundle-only C# source files to canonical destination paths.
  - Invariant: `core` is always part of explicit pack selection.
  - Invariant: no explicit selection writes files outside the selected packs and `core`.
  - Invariant: exactly one C# toolchain writes to the canonical C# destination paths.
  - Invariant: variant roots do not appear in destination output.
- Caching or persistence details:
  - No new persistent state is required.
  - Existing summary artifact generation remains under
    `artifacts/codex-and-agents-customizations/`.
- Migration or backfill requirements (if any):
  - None for destination repositories. Existing callers can omit the new fields.
  - Resource-contract tests must be updated so bundle-only manifests and variant roots
    are treated as bundle resources, not root runtime files.

## Constraints & Risks

Backwards-compatible behavior is required for all existing Codex push-down entry points.
The no-selection path must avoid manifest dependency so a manifest defect cannot break
legacy full-tree usage.

Codex-specific manifests are required because Claude manifests target `.claude/**` paths.
Reusing Claude manifests would write the wrong destination paths and would not cover the
two-root Codex and agents bundle.

The C# root profile currently includes legacy-oriented details such as MSTest,
FluentAssertions, Moq, and `vstest.console.exe`. Before implementation, the default
`modern` or `legacy` label must be aligned with the actual root profile or the root
profile must be moved into the appropriate variant source.

The VS Code QuickPick command flow must cancel cleanly at every prompt without invoking
the service. Tests should cover this because cancellation is part of preserving the
existing non-destructive command behavior.

## Implementation Strategy

- Implementation scope (what changes, not sequencing):
  - Add `scripts/dev_tools/push_down_codex_pack_selection.py` for pure manifest parsing,
    effective pack resolution, C# variant path routing, and mutual-exclusion checks.
  - Extend `scripts/dev_tools/push_down_codex_and_agents_customizations.py` with
    optional `--packs`, `--csharp-variant`, and `--memory-mode` arguments.
  - Add Codex pack manifests under
    `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/`.
  - Add Codex C# variant sources under bundle-only Codex-specific variant roots.
  - Add `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts`.
  - Extend `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`
    with pack filtering and variant source routing.
  - Extend `extensions/drm-copilot/src/repo-automation-service.ts`,
    `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts`, Codex MCP
    input resolution, and both MCP definition files.
  - Extend `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts`
    with the Codex language-pack and conditional C# variant QuickPick flow.
- New classes/functions/commands to add or update:
  - Python: Codex manifest loader, effective pack resolver, C# variant resolver, CLI
    parsing, and tests for each validation rule.
  - TypeScript: Codex pack-selection helper, service input type fields, command prompts,
    MCP schema/input mapping, and tests for forwarding and cancellation.
- Dependency changes (new/removed packages) and rationale:
  - None expected. The feature can use existing Python standard library modules,
    existing TypeScript helpers, the current VS Code QuickPick API, and existing test
    doubles.
- Logging/telemetry additions and locations:
  - The existing push-down summary artifact should include the effective pack selection,
    selected C# variant, and memory-mode value if the summary format already supports
    adding metadata without breaking readers.
- Rollout plan (feature flags, staged deploys, fallback path):
  - No feature flag is required. Omitting all new fields remains the fallback behavior.
  - Release validation must include no-argument CLI, service, VS Code command, and MCP
    scenarios before enabling selected-pack use.

Implementation note:

- The default Codex C# variant is `modern`, using the root Codex C# profile.
- Codex `memory_mode` is accepted for Claude schema parity and is inert while the Codex
  bundle has no memory subtree.

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos.
- [x] Behavior matches acceptance criteria for the Python CLI, TypeScript service, VS
      Code command, and MCP tool surfaces.
- [x] Python tests are updated or added for Codex manifest parsing, pack filtering, C#
      variant routing, backward compatibility, and failure cases.
- [x] TypeScript tests are updated or added for Codex pack selection, service forwarding,
      command prompts and cancellation, MCP schema parity, and MCP input resolution.
- [x] Edge cases and error handling are covered by tests, including unknown packs,
      missing or malformed manifests, both C# variants selected, and variant source
      collisions.
- [x] Resource-contract tests verify pack manifests and variant roots exist in the
      bundle and are excluded from root-runtime byte-identical assertions.
- [x] Docs updated in `docs/features/active/2026-07-02-codex-push-down-language-packs-269/`.
- [x] Toolchain pass completed in repository order: format -> lint -> type-check -> test.

## Acceptance Criteria

- [x] No-argument Codex push-down publishes the complete `.codex` and `.agents` trees and
      preserves current summary artifact behavior.
- [x] Explicit pack selection always includes `core`.
- [x] `--packs core,typescript` publishes only `core` and TypeScript pack files.
- [x] Codex pack manifests are loaded from the Codex bundle and are not written to the
      destination.
- [x] Bundle-only C# variant roots are excluded from default root enumeration and from
      destination writes.
- [x] The selected C# variant writes exactly one toolchain to canonical `.agents` and
      `.codex` C# destination paths.
- [x] Invalid pack names, malformed manifests, missing variant sources, and selection of
      both C# variants fail before writes.
- [x] VS Code Codex push-down prompts for language packs and conditionally prompts for a
      C# variant only when C# is selected.
- [x] MCP definitions and input resolution accept optional `packs`, `csharp_variant`, and
      `memory_mode` while preserving workspace-root-only compatibility.
- [x] Python and TypeScript test coverage proves backward compatibility, selected-pack
      behavior, C# variant routing, schema parity, and cancellation behavior.

## Seeded Test Conditions (from potential)

- [x] Unit coverage: Codex pack manifest parsing; missing and malformed manifest errors;
      pack filtering with `core` always included; C# variant source-path selection;
      mutual-exclusion rejection; CLI argument parsing and defaults.
- [x] Integration scenarios: end-to-end Codex push-down with no selection; selected
      TypeScript pack; selected C# legacy variant; variant roots excluded from
      destination; resource-contract parity update.
- [x] CLI/API examples: `--packs core,typescript`, `--packs core,csharp
      --csharp-variant legacy`, workspace-root-only MCP input, MCP input with optional
      fields, and VS Code selection-to-service mapping with cancellation handling.
