# `2026-07-02-codex-push-down-language-packs` — User Story

- Issue: #269
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-02T13-20

## Story Statement

- As a repository maintainer, I want Codex push-down to publish only the language packs I
  select, so that destination repositories receive the relevant `.codex` and `.agents`
  runtime files without unrelated language policies.
- As an automation caller, I want Codex push-down to support selectable C# toolchain
  variants through CLI, VS Code, service, and MCP inputs, so that a destination
  repository receives the C# profile that matches its stack while existing no-argument
  calls keep working.

## Problem / Why

Codex and agents push-down currently copies the whole bundled `.codex` and `.agents`
tree to every destination repository. That behavior is compatible with existing callers,
but it does not support selective language rollout or the C# variant behavior already
available in the Claude push-down workflow used as the reference for issue #269.

Issue #269 must add Codex-specific pack selection and C# variant selection without
changing the default full-tree behavior. The result should let users choose a smaller
runtime surface when they need one, while preserving current automation behavior for
callers that provide only a destination or workspace root.

## Personas & Scenarios

- Persona: Repository maintainer for a TypeScript-only destination repository
  - Maintains a repository that uses Codex automation but does not need Python,
    PowerShell, or C# policies.
  - Cares about keeping pushed runtime files limited to the repository's supported
    stack.
  - Needs the current no-argument push-down path to remain available for broad updates.
  - Wants selected-pack behavior to be enforced by the push-down implementation, not
    only by the VS Code UI.
- Scenario: Selective TypeScript push-down
  - The maintainer starts Codex push-down from VS Code or through MCP.
  - The maintainer selects the TypeScript pack.
  - The system adds `core` automatically.
  - The destination receives only `core` and TypeScript `.codex` or `.agents` files.
  - Python, PowerShell, and C# pack files are not written.

- Persona: Automation maintainer for C# repositories with different toolchains
  - Maintains Codex customization rollout across repositories that may use different C#
    build and test stacks.
  - Cares that exactly one C# toolchain profile lands at the destination canonical paths.
  - Needs command, CLI, service, and MCP behavior to agree so automated and interactive
    push-down flows produce the same output.
  - Wants invalid variant combinations to fail before destination files are written.
- Scenario: Legacy C# variant push-down
  - The automation maintainer requests the C# pack and selects the legacy C# variant.
  - The push-down implementation reads legacy variant files from Codex bundle-only
    variant roots.
  - The destination receives legacy C# content at canonical `.agents` and `.codex`
    destination paths.
  - The modern C# profile is not also written to those same destination paths.
  - The summary artifact records the push-down result using the existing Codex artifact
    location.

## Acceptance Criteria

- [x] A no-argument Codex push-down invocation continues to publish the complete
      `.codex` and `.agents` trees and preserves existing summary artifact behavior.
- [x] When the user selects any explicit language pack set, the system includes `core`
      automatically.
- [x] When the user selects TypeScript only, the destination receives `core` and
      TypeScript pack files and does not receive Python, PowerShell, or C# pack files.
- [x] When the user selects C# with the legacy variant, legacy C# content is written to
      canonical `.agents` and `.codex` C# destination paths.
- [x] The destination never receives bundle-only Codex variant roots such as
      `.agents-variants/**` or `.codex-variants/**`.
- [x] The system rejects a request that would select both C# variants before writing any
      destination files.
- [x] The VS Code Codex push-down flow presents language-pack selection and prompts for a
      C# variant only when C# is selected.
- [x] Cancelling any VS Code selection step stops the operation before the push-down
      service is invoked.
- [x] The MCP tool accepts optional `packs`, `csharp_variant`, and `memory_mode` fields,
      and an invocation with only `workspace_root` remains valid.
- [x] Python and TypeScript tests verify the selected-pack behavior, C# variant routing,
      invalid-selection failures, no-argument compatibility, and MCP or service input
      forwarding.

## Non-Goals

- Do not change existing Claude push-down behavior.
- Do not reuse Claude manifests for Codex because Codex destination paths are
  `.codex/**` and `.agents/**`, not `.claude/**`.
- Do not modify repository policy files as part of issue #269.
- Do not make pack or variant fields required for CLI, VS Code, service, or MCP callers.
- Do not introduce a new dependency unless implementation proves the existing Python,
  TypeScript, and VS Code APIs cannot support the behavior.
- Do not add Codex memory semantics beyond an inert `memory_mode` parity field unless a
  Codex memory subtree is introduced and tested.
