# codex-push-down-language-packs (Issue #269)

- Date captured: 2026-07-02
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-07-02-codex-push-down-language-packs-269/ (Issue #269)

- Issue: #269
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/269
- Last Updated: 2026-07-02
- Work Mode: full-feature

## Problem / Why

The Codex and agents push-down workflow currently publishes the complete `.codex` and
`.agents` bundle to a destination repository. Unlike the completed Claude push-down
workflow used as the behavior reference for issue #269, the Codex workflow has no
language-pack selection, no manifest layer, no C# toolchain variant selection, and no VS
Code or MCP inputs for selecting the runtime surface that should be written.

This creates avoidable destination churn for repositories that only need a subset of
language policies, and it prevents a destination repository from selecting the C#
toolchain profile that matches its stack. Issue #269 must bring Codex push-down behavior
to parity with the Claude language-pack and C# variant workflow while preserving the
existing no-argument full-tree behavior.

## Proposed Behavior

Add Codex-specific, manifest-driven language-pack selection for the
`push_down_codex_and_agents_customizations` workflow. The `core` pack is always included
when explicit packs are selected, while Python, PowerShell, TypeScript, and C# packs are
selected explicitly. When no packs are supplied, the workflow keeps the current behavior:
publish the full `.codex` and `.agents` trees.

Add Codex C# toolchain variant handling equivalent to the Claude workflow. Exactly one
C# toolchain writes to canonical `.agents` and `.codex` destination paths. Variant source
files remain in bundle-only variant roots, such as `.agents-variants/csharp-legacy/` and
`.codex-variants/csharp-legacy/`, and those variant roots are never written to the
destination.

Extend the Python CLI, TypeScript extension implementation, VS Code command flow, service
input, MCP input resolver, and both MCP tool-definition files so Codex push-down accepts
optional `packs`, `csharp_variant`, and `memory_mode` fields. The `memory_mode` field is
included for Claude schema parity; it must be inert unless a Codex memory subtree is
introduced.

## Acceptance Criteria

- [ ] Invoking Codex push-down with only the existing destination or workspace-root input
      publishes the complete `.codex` and `.agents` trees and preserves the current
      summary artifact behavior.
- [ ] Supplying an explicit pack selection always includes the `core` pack, even when
      `core` is not listed by the caller.
- [ ] Supplying `--packs core,typescript` publishes only `core` and TypeScript Codex or
      agents files, excluding Python, PowerShell, and C# pack files from the destination.
- [ ] Codex pack manifests exist under
      `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/`
      and are not written to destination repositories.
- [ ] C# variant sources exist only in Codex bundle-only variant roots and are excluded
      from default full-tree root enumeration and destination writes.
- [ ] Selecting the legacy C# variant writes legacy C# content to canonical `.agents` and
      `.codex` destination paths and does not also write the modern C# toolchain to those
      paths.
- [ ] Selecting both C# variants in one run fails before writing files and reports a
      specific selection or manifest error.
- [ ] The VS Code Codex push-down command presents language-pack selection, prompts for a
      C# variant only when C# is selected, and cancels without invoking the service when
      the user cancels any selection step.
- [ ] The MCP tool `push_down_codex_and_agents_customizations` accepts optional `packs`,
      `csharp_variant`, and `memory_mode` fields while keeping workspace-root-only calls
      valid and preserving `additionalProperties: false`.
- [ ] Python and TypeScript tests cover pack parsing, `core` inclusion, C# variant source
      routing, mutual-exclusion failure, no-argument backward compatibility, service
      forwarding, MCP schema/input resolution, and VS Code command selection behavior.

## Constraints & Risks

- Backward compatibility is mandatory for the Python CLI, TypeScript service, VS Code
  command, MCP calls, and existing summary artifact behavior.
- Codex cannot reuse Claude manifests because Claude paths target `.claude/**`, while
  Codex paths target `.codex/**` and `.agents/**`.
- Variant source roots must not be included by resource parity tests that compare root
  runtime files to bundled resources.
- The implementation must define the Codex C# canonical path list before routing variant
  reads. At minimum, the verified C# surfaces include `.agents/skills/csharp/SKILL.md`,
  `.agents/skills/csharp-qa-gate/SKILL.md`,
  `.agents/skills/invoke-csharp-engineer/SKILL.md`, and
  `.codex/agents/csharp-typed-engineer.toml`.
- `memory_mode` is included for schema parity with Claude push-down, but no Codex memory
  subtree was verified in the current bundle. Its behavior must be documented and tested
  as inert unless memory files are added.
- Do not modify policy files as part of this feature. Runtime behavior belongs in the
  push-down scripts, extension code, bundled resources, and tests.

## Test Conditions to Consider

- [ ] Unit coverage: Codex manifest parsing, malformed or missing manifest errors, pack
      parsing, `core` inclusion, C# variant source-path resolution, and mutual-exclusion
      validation.
- [ ] Integration scenarios: no-argument full-tree push-down, selected-pack push-down,
      legacy C# variant writes to canonical destination paths, and variant roots excluded
      from destination writes.
- [ ] CLI/API examples: `--packs core,typescript`, `--packs core,csharp
      --csharp-variant legacy`, workspace-root-only MCP input, MCP input with optional
      fields, and VS Code cancellation before service invocation.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/2026-07-02-codex-push-down-language-packs-269/` folder
      from the template
