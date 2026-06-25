# `push-down-language-packs-csharp-variant` — User Story

- Issue: #226
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-06-24

## Story Statement

- As a developer adopting the drm-copilot runtime in a destination repository, I want to
  push down only the language packs my repository uses, so that the destination `.claude`
  tree does not carry rules, agents, and skills for languages it does not use.
- As a developer maintaining a legacy VSTO/.NET Framework repository, I want to select a
  legacy C# toolchain variant during push-down, so that the destination receives C#
  standards matching MSBuild, MSTest, and `vstest.console.exe` instead of the modern
  xUnit/CSharpier profile.
- As a developer whose destination repository has curated its own general-scoped agent
  memories, I want to choose how memories are pushed (overwrite, merge, or skip), so that
  I can preserve local memory customizations.
- As an MCP client or automation caller, I want the push-down to remain callable with
  only a workspace root, so that existing automation that does not specify packs continues
  to work unchanged.

## Problem / Why

The push-down workflow copies the entire `.claude` tree unconditionally and offers no
way to select a subset of language packs, no alternative C# toolchain profile, and no
control over agent-memory handling beyond overwrite. Destination repositories that use a
single language, or that run a legacy C# stack, or that have local memory customizations
cannot tailor what they receive. The feature adds opt-in selection while preserving the
current no-argument behavior for callers that do not opt in.

## Personas & Scenarios

- Persona: Destination-repository maintainer (single-language)
  - Who: A developer responsible for a TypeScript-only repository adopting the runtime.
  - What they care about: A clean `.claude` tree that contains only what is relevant to
    their stack and does not introduce unused language rules.
  - Constraints: They invoke the push-down through the VS Code command and expect a
    predictable, cancellable selection flow.
  - Goals and frustrations: They want to opt in to TypeScript and core only; today the
    workflow forces the full multi-language tree.
  - Context and motivations: Reducing noise in the destination repository and keeping
    the runtime surface minimal.

- Persona: Legacy C# repository maintainer
  - Who: A developer on a VSTO/.NET Framework codebase using non-SDK `packages.config`,
    MSBuild, MSTest + Moq + FluentAssertions, and `vstest.console.exe`.
  - What they care about: C# standards that match their actual build and test toolchain,
    including the fixed five-package analyzer stack and the 80% repo / 90% new coverage
    thresholds.
  - Constraints: Exactly one C# toolchain must land at the destination; the modern and
    legacy profiles must not coexist.
  - Goals and frustrations: They need the legacy profile available without polluting the
    repository root `.claude` tree with a second C# profile.
  - Context and motivations: The destination cannot adopt the modern No-COM profile, so
    the legacy variant is required for accurate guidance.

- Persona: Automation / MCP caller
  - Who: A script or MCP client that invokes `push_down_claude_customizations` with only
    a workspace root.
  - What they care about: The call continues to succeed and behaves as it does today.
  - Constraints: No new required fields may be introduced on the tool schema.
  - Goals and frustrations: Backward compatibility with existing automation.

- Scenario: Single-language maintainer selects packs through the VS Code command
  - Who is acting: The TypeScript-only repository maintainer.
  - What triggered the action: They run the `Push Down Claude Customizations` command
    from the VS Code command palette.
  - Steps they take: A multi-select QuickPick lists the language packs with all packs
    pre-selected; they deselect Python, PowerShell, and C#, leaving TypeScript. Because
    C# is not selected, the C# variant prompt is not shown. A memory-mode QuickPick
    appears; they choose `Overwrite`.
  - Obstacles or decisions: They may cancel at any prompt, which aborts the push-down.
  - Outcome they expect: The destination `.claude` tree receives the `core` and
    TypeScript pack files only; Python, PowerShell, and C# pack files are absent.

- Scenario: Legacy C# maintainer selects the legacy variant
  - Who is acting: The legacy C# repository maintainer.
  - What triggered the action: They run the push-down command and keep the C# pack
    selected.
  - Steps they take: After the pack multi-select, a single-select C# variant QuickPick
    appears because C# is selected; they choose the legacy variant. They then choose a
    memory mode.
  - Obstacles or decisions: Only one C# variant can be chosen (single-select), enforcing
    mutual exclusion at the UI layer.
  - Outcome they expect: The destination `.claude/rules/csharp.md`,
    `.claude/agents/csharp-typed-engineer.md`, `.claude/skills/csharp-qa-gate/SKILL.md`,
    and `.claude/skills/invoke-csharp-engineer/SKILL.md` contain legacy-variant content,
    sourced from the bundle-only `.claude-variants/csharp-legacy/` subtree, and the
    modern C# files are not also written.

## Acceptance Criteria

- [ ] Invoking the push-down with no pack, variant, or memory-mode arguments copies the
      complete `.claude` tree and overwrites general-scoped memories, matching current
      behavior (backward compatibility).
- [ ] The `core` pack is always included regardless of which language packs are selected.
- [ ] Supplying a pack selection of `core` plus TypeScript copies only `core` and
      TypeScript pack files; Python, PowerShell, and C# pack files are not written.
- [ ] The legacy C# variant files exist only under the bundle-only subtree
      `.claude-variants/csharp-legacy/` and never at the repository root `.claude` tree.
- [ ] Exactly one C# toolchain lands at the destination root; selecting the legacy
      variant writes legacy content to the canonical destination C# paths and the modern
      C# files are not also written there.
- [ ] The VS Code command shows a multi-select QuickPick for language packs, a
      single-select C# variant QuickPick only when the C# pack is selected, and a
      single-select memory-mode QuickPick; cancellation at any prompt aborts the push-down.
- [ ] The C# variant single-select enforces that only one C# toolchain is chosen
      (mutual exclusion at the UI layer).
- [ ] Memory mode selection (overwrite, merge, skip) is presented and applied to the
      `.claude/agent-memory/**` subtree.
- [ ] An MCP or automation invocation with only `workspace_root` remains valid and
      behaves as today.

## Non-Goals

- Introducing `.claude/schemas/orchestrator-state.schema.json` or any schema-file-based
  orchestrator-state validation. Orchestrator-state validation remains the Python
  validator per `.claude/rules/orchestrator-state.md`.
- Propagating non-language-specific differences found only in the diverged tocompare
  snapshot into the repository root.
- Adding language packs beyond `core`, Python, PowerShell, TypeScript, and C#.
- Adding C# variants beyond the modern (default) and legacy profiles.
- Building a full VS Code integration-test host for the QuickPick flow; UI appearance is
  verified manually before release.
