# push-down-language-packs-csharp-variant — Spec

- **Issue:** #226
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24
- **Status:** Draft
- **Version:** 0.2

## Overview

The "Push Down Claude Customizations" workflow copies the entire `.claude` tree to a
destination repository unconditionally. This feature adds opt-in, manifest-driven
language-pack selection, two selectable C# toolchain variants (modern default and
legacy), three agent-memory push-down modes (overwrite, merge, skip), a VS Code
selection UI, and corresponding MCP tool schema fields. All additions preserve the
existing no-argument behavior so callers that do not opt in receive today's behavior.

The change spans the TypeScript extension (command registration, service, MCP tool
inputs/definitions) and the Python push-down scripts, plus a bundle-only variant subtree
and test adaptations.

## Behavior

1. Opt-in language packs. Pack selection is manifest-driven. A `core` pack (non-language
   rules, hooks, skills, settings, orchestrator agent) is always pushed. Python,
   PowerShell, TypeScript, and C# packs are opt-in. When no packs are specified (for
   example an MCP call with only `workspace_root`, or the default command path), behavior
   is backward-compatible: push everything.

2. Two C# toolchain variants. The modern variant (default) is the current root C# files:
   CSharpier formatting, .NET Analyzers via `dotnet`, nullable analysis, xUnit, No-COM
   architecture. The legacy variant is the supplied alternative: legacy VSTO/.NET
   Framework, non-SDK `packages.config`, MSBuild, MSTest + Moq + FluentAssertions,
   `vstest.console.exe`, a fixed five-package analyzer stack (Meziantou.Analyzer,
   SonarAnalyzer.CSharp, Roslynator.Analyzers, AsyncFixer,
   Microsoft.CodeAnalysis.BannedApiAnalyzers), and coverage thresholds of 80% repository
   / 90% new code. The legacy variant comprises four files mapping to destination paths
   `.claude/rules/csharp.md`, `.claude/agents/csharp-typed-engineer.md`,
   `.claude/skills/csharp-qa-gate/SKILL.md`, `.claude/skills/invoke-csharp-engineer/SKILL.md`.
   The legacy variant exists only in the extension bundle, in the dedicated subtree
   `.claude-variants/csharp-legacy/`, never at the repository root `.claude` tree.
   Exactly one C# toolchain lands at the destination root (mutual exclusion).

3. Memory push-down mode. When agent-memory is pushed, the caller chooses one of:
   overwrite (default; current behavior), merge (keep destination memories that already
   exist), or skip (do not push memories at all). The mode is applied in addition to the
   existing general-vs-repo scope filter.

4. Extension UI. A multi-select QuickPick selects language packs. A conditional
   single-select QuickPick selects the C# variant, shown only when the C# pack is
   selected. A single-select QuickPick selects the memory mode. Selections flow through
   the `pushDownClaudeCustomizations` service input to Python CLI arguments (`--packs`,
   `--csharp-variant`, `--memory-mode`). The MCP tool schema gains optional `packs`,
   `csharp_variant`, and `memory_mode` fields. The existing no-argument invocation path
   remains backward-compatible.

5. Parity-test adaptation. The bundle-only variant subtree is excluded from the
   root-to-bundle byte-identical parity assertion in
   `test_push_down_claude_resource_contracts.py`. A new test asserts the variant subtree
   never collides with a root `.claude` path (conflict-prevention guarantee) and that the
   destination receives exactly one C# toolchain.

## Inputs / Outputs

- Inputs (CLI flags, files, env vars):
  - `--destination <path>` (existing): destination repository root.
  - `--packs <csv>` (new, optional): comma-separated pack names from the set
    `core,python,powershell,typescript,csharp`. When omitted, all packs are pushed
    (backward-compatible). `core` is always included even if not listed.
  - `--csharp-variant <modern|legacy>` (new, optional): selects the C# toolchain source.
    Default `modern`. Only meaningful when the C# pack is in the pushed set.
  - `--memory-mode <overwrite|merge|skip>` (new, optional): agent-memory handling.
    Default `overwrite` (backward-compatible).
  - Pack manifests (new, bundle-only files): JSON manifests under the bundled
    `resources/claude-customizations/` directory that map each pack name to its set of
    `.claude`-relative paths. Manifests are not pushed to the destination.
- Outputs (artifacts, logs, telemetry):
  - The destination `.claude` tree, filtered to the selected packs, with the selected C#
    variant and memory mode applied.
  - The existing JSON push-down summary artifact under
    `artifacts/claude-customizations/push-down-<timestamp>.json`.
- Config keys and defaults:
  - `packs` default: all packs (full tree). `csharp_variant` default: `modern`.
    `memory_mode` default: `overwrite`.
- Versioning or backward-compatibility constraints:
  - No new required CLI argument, service field, or MCP schema field. The no-argument
    command, no-argument MCP call, and existing service interface must continue to work
    unchanged.

## API / CLI Surface

- Python CLI (`scripts/dev_tools/push_down_claude_customizations.py`):
  - Existing: `--destination <workspaceRoot>`
  - New optional: `--packs core,typescript`, `--csharp-variant legacy`,
    `--memory-mode merge`
  - Example: `--destination /repo --packs core,csharp --csharp-variant legacy
    --memory-mode skip` copies `core` and legacy C# files to `/repo/.claude` and pushes
    no agent memories.
  - Example (backward-compatible): `--destination /repo` copies the full `.claude` tree
    and overwrites general-scoped memories.

- TypeScript service input (`repo-automation-service.ts`):
  - `PushDownClaudeCustomizationsInput extends WorkspaceExecutionInput` adds optional
    `packs?: ReadonlyArray<string>`, `csharpVariant?: "modern" | "legacy"`, and
    `memoryMode?: "overwrite" | "merge" | "skip"`. Absent fields produce the
    backward-compatible no-argument invocation.

- MCP tool definition (`mcp-tool-definitions.ts` and the duplicate
  `mcp-repo-automation-tool-definitions.ts`):
  - `push_down_claude_customizations.inputSchema.properties` gains optional `packs`
    (array of strings), `csharp_variant` (enum `modern`/`legacy`), and `memory_mode`
    (enum `overwrite`/`merge`/`skip`). No field is added to a `required` array; the
    schema retains `additionalProperties: false`.
  - `resolvePushDownClaudeCustomizationsToolInput` (`mcp-tool-inputs.ts`) maps the new
    raw fields to the service input, leaving them undefined when absent.

- Contracts and validation rules:
  - The C# variant single-select and the pack multi-select enforce that at most one C#
    toolchain reaches the destination.
  - The Python engine asserts the selected C# variant's destination paths do not collide
    with any other selected pack's destination paths.

## Data & State

- Data flow:
  - VS Code command gathers selections -> service input -> Python CLI args -> push-down
    engine -> destination `.claude` tree + summary artifact.
  - Pack manifests are read from the bundle to determine which `.claude`-relative paths
    belong to each selected pack.
  - For the legacy C# variant, the engine reads C# files from the bundle-only
    `.claude-variants/csharp-legacy/` subtree and writes them to the canonical
    destination C# paths; for the modern variant, it reads from the bundled `.claude/`
    tree.
- Data transformations and invariants:
  - Invariant: `core` is always in the pushed set.
  - Invariant: exactly one C# toolchain lands at the destination root.
  - Invariant: the `.claude-variants/` subtree never appears at the repository root
    `.claude` tree and is never enumerated by the default push-down.
  - Invariant: a file under `.claude-variants/csharp-legacy/`, after stripping the
    variant prefix, must not duplicate a root `.claude` file's content at the same
    relative path (the variant must be a distinct profile).
- Caching or persistence details:
  - No new persistent state. The push-down summary artifact format is unchanged.
- Migration or backfill requirements:
  - None. The legacy variant subtree is added to the bundle; the repository root
    `.claude` tree is unchanged.

## Constraints & Risks

- Backward compatibility is mandatory across the command, MCP, and service surfaces.
- The `merge` memory mode needs a destination-existence check that the fixed-path
  `EXCLUDED_RELATIVE_PATHS` mechanism cannot express; a filesystem-level check in the
  push-down filesystem wrapper is required. Tests must not use runtime temp files; the
  existing in-memory filesystem double covers this.
- Mutual exclusion of C# toolchains must be enforced both at the UI layer (single-select)
  and at the engine layer (path-collision assertion).
- The multi-step QuickPick flow (multi-select with pre-selected items, conditional C#
  variant prompt) is not fully exercised by the current mocked test harness. Coverage is
  provided by unit tests that mock `vscode.window.showQuickPick` at the
  command-registration layer; final UI appearance is verified manually before release.
- `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts` are currently
  identical; both must be updated consistently to avoid drift.
- Out of scope: `.claude/schemas/orchestrator-state.schema.json` from the diverged
  tocompare snapshot is excluded; no schema-file-based orchestrator-state validation is
  introduced.

## Implementation Strategy

- Implementation scope (what changes, not sequencing):
  - Python: add `--packs`, `--csharp-variant`, `--memory-mode` argument parsing and
    pack-manifest-driven filtering to `push_down_claude_customizations.py`; extend the
    excluding filesystem wrapper to implement overwrite/merge/skip memory modes and the
    variant source-path selection; add the path-collision assertion.
  - TypeScript: extend `registerPushDownClaudeCustomizationsCommand` with the three
    QuickPick prompts; extend the service input type and `pushDownClaudeCustomizations`
    implementation to build the new CLI args; extend
    `resolvePushDownClaudeCustomizationsToolInput` and the MCP tool definitions.
  - Bundle: add pack-manifest JSON files and the `.claude-variants/csharp-legacy/`
    subtree containing the four legacy files (canonical sources: `artifacts/csharp.md`,
    `artifacts/csharp-typed-engineer.md`, `artifacts/csharp-qa-gate/SKILL.md`,
    `artifacts/invoke-csharp-engineer/SKILL.md`).
  - Tests: adapt `test_push_down_claude_resource_contracts.py` to exclude the variant
    subtree from the byte-identical parity assertion; add the conflict-prevention and
    single-C#-toolchain tests; add Python engine tests for pack filtering, variant
    selection, and memory modes; add TypeScript tests for the command flow, service args,
    handler input resolution, and MCP dispatch.
- New classes/functions/commands to add or update:
  - Python: pack-manifest loader; pack-filtering predicate (core always included);
    variant source-path resolver; memory-mode filesystem wrapper extension; CLI argument
    parsing in `parse_args`.
  - TypeScript: extended command handler with three QuickPick prompts;
    `PushDownClaudeCustomizationsInput` type extension; CLI-arg construction in the
    service implementation; MCP input resolver and tool definition updates.
- Dependency changes (new/removed packages) and rationale:
  - None expected. The work uses existing VS Code QuickPick APIs, the existing
    `promptForChoice` helper, the existing `PushDownFileSystem` protocol, and the
    existing in-memory test double.
- Logging/telemetry additions and locations:
  - The push-down summary artifact records the effective selections; no new telemetry
    sink is introduced.
- Rollout plan (feature flags, staged deploys, fallback path):
  - No feature flag. Defaults preserve current behavior, which is the fallback path. The
    feature is additive and reversible by omitting the new arguments.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format -> lint -> type-check -> test)

## Acceptance Criteria

- [ ] Invoking the push-down with no pack, variant, or memory-mode arguments copies the
      complete `.claude` tree and overwrites general-scoped memories, matching current
      behavior byte-for-byte (backward compatibility).
- [ ] The `core` pack is always included in the pushed set regardless of which language
      packs are selected.
- [ ] Supplying `--packs core,typescript` copies only `core` and TypeScript pack files;
      Python, PowerShell, and C# pack files are not written to the destination.
- [ ] The legacy C# variant files exist only under the bundle-only subtree
      `.claude-variants/csharp-legacy/` and never at the repository root `.claude` tree.
- [ ] Exactly one C# toolchain lands at the destination root `.claude` tree; selecting
      the legacy variant writes legacy content to the canonical destination C# paths
      (`.claude/rules/csharp.md`, `.claude/agents/csharp-typed-engineer.md`,
      `.claude/skills/csharp-qa-gate/SKILL.md`,
      `.claude/skills/invoke-csharp-engineer/SKILL.md`) and the modern C# files are not
      also written there.
- [ ] Memory mode `overwrite` copies general-scoped memories, overwriting destination
      files at the same path.
- [ ] Memory mode `merge` copies only general-scoped memories that do not already exist
      at the destination and preserves destination files that do exist.
- [ ] Memory mode `skip` excludes the entire `.claude/agent-memory/**` subtree from the
      copy regardless of scope.
- [ ] The VS Code command presents a multi-select QuickPick for language packs, a
      single-select QuickPick for the C# variant shown only when the C# pack is selected,
      and a single-select QuickPick for memory mode; selections are mapped to the
      `--packs`, `--csharp-variant`, and `--memory-mode` Python CLI arguments.
- [ ] The MCP tool `push_down_claude_customizations` schema gains optional `packs`,
      `csharp_variant`, and `memory_mode` fields; an invocation with only `workspace_root`
      remains valid and backward-compatible.
- [ ] The parity test in `test_push_down_claude_resource_contracts.py` excludes the
      bundle-only variant subtree from the root-to-bundle byte-identical assertion.
- [ ] A new test asserts the variant subtree never collides with a root `.claude` path
      (conflict-prevention guarantee) and that the destination receives exactly one C#
      toolchain.
- [ ] Python toolchain is green: Black, Ruff, Pyright, and Pytest with coverage
      >= 85% line and >= 75% branch.
- [ ] TypeScript toolchain is green: Prettier, ESLint, tsc, and Vitest with coverage
      meeting the repository thresholds.

## Seeded Test Conditions (from potential)

- [ ] Unit coverage: pack manifest parsing; pack filtering with `core` always included;
      C# variant source-path selection; memory-mode filtering (overwrite/merge/skip); CLI
      argument parsing and defaults.
- [ ] Integration scenarios: end-to-end push-down with selected packs and variant using
      the in-memory filesystem double; parity-test adaptation; conflict-prevention test;
      single-C#-toolchain destination assertion.
- [ ] CLI/API examples: `--packs`, `--csharp-variant`, `--memory-mode` argument
      combinations; MCP schema with and without the new optional fields; VS Code
      selection-to-argument mapping including cancellation handling.
