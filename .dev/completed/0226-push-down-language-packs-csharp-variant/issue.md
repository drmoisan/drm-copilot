# push-down-language-packs-csharp-variant (Issue #226)

- Date captured: 2026-06-24
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/ (Issue #226)

- Issue: #226
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/226
- Last Updated: 2026-06-24
- Work Mode: full-feature

## Problem / Why

The "Push Down Claude Customizations" workflow currently copies the entire `.claude`
tree from the bundled payload to a destination repository unconditionally. The Python
entry point `scripts/dev_tools/push_down_claude_customizations.py` defines
`ROOT_FOLDERS = (Path(".claude"),)` and enumerates every file under that root. The VS
Code command `drmCopilotExtension.pushDownClaudeCustomizations` takes no user inputs and
calls the service with only the workspace root.

This produces three gaps:

1. A destination repository that uses only a subset of the supported languages (for
   example, a TypeScript-only repository) receives Python, PowerShell, and C# rules,
   agents, and skills it does not need.
2. There is no mechanism to deliver an alternative C# toolchain profile. The repository
   root carries a single C# profile (modern: CSharpier, .NET Analyzers/dotnet, nullable
   analysis, xUnit, No-COM). A consuming repository on a legacy VSTO/.NET Framework
   stack (non-SDK `packages.config`, MSBuild, MSTest + Moq + FluentAssertions,
   `vstest.console.exe`) cannot select a matching profile.
3. Agent-memory push-down always overwrites destination memories of `scope: general`.
   A destination that has curated its own general-scoped memories cannot preserve them.

## Proposed Behavior

Add opt-in, manifest-driven language-pack selection to the push-down workflow, two
selectable C# toolchain variants (modern default and legacy), three agent-memory
push-down modes (overwrite, merge, skip), and a VS Code selection UI that flows the
selections to Python CLI arguments and to the MCP tool schema. All additions are
backward-compatible: an invocation with no pack, variant, or memory-mode selection
behaves exactly as today (push everything, overwrite memories).

- A `core` pack (non-language rules, hooks, skills, settings, orchestrator agent) is
  always pushed. Python, PowerShell, TypeScript, and C# packs are opt-in.
- The legacy C# variant exists only in a bundle-only subtree
  (`.claude-variants/csharp-legacy/`) and never at the repository root `.claude` tree.
  Exactly one C# toolchain lands at the destination root (mutual exclusion).
- Agent-memory push-down honors the selected mode and continues to apply the existing
  general-vs-repo scope filter.

## Acceptance Criteria

- [x] Invoking the push-down with no pack, variant, or memory-mode arguments copies the
      complete `.claude` tree and overwrites general-scoped memories, matching current
      behavior byte-for-byte (backward compatibility).
- [x] The `core` pack is always included in the pushed set regardless of which
      language packs are selected.
- [x] Supplying `--packs core,typescript` copies only `core` and TypeScript pack files;
      Python, PowerShell, and C# pack files are not written to the destination.
- [x] The legacy C# variant files exist only under the bundle-only subtree
      `.claude-variants/csharp-legacy/` and never at the repository root `.claude` tree.
- [x] Exactly one C# toolchain lands at the destination root `.claude` tree; selecting
      the legacy variant places legacy content at the canonical destination paths
      (`.claude/rules/csharp.md`, `.claude/agents/csharp-typed-engineer.md`,
      `.claude/skills/csharp-qa-gate/SKILL.md`,
      `.claude/skills/invoke-csharp-engineer/SKILL.md`) and the modern files are not also
      written there.
- [x] Memory mode `overwrite` copies general-scoped memories, overwriting destination
      files at the same path.
- [x] Memory mode `merge` copies only general-scoped memories that do not already exist
      at the destination and preserves destination files that do exist.
- [x] Memory mode `skip` excludes the entire `.claude/agent-memory/**` subtree from the
      copy regardless of scope.
- [x] The VS Code command presents a multi-select QuickPick for language packs, a
      single-select QuickPick for the C# variant shown only when the C# pack is selected,
      and a single-select QuickPick for memory mode; the selections are mapped to the
      `--packs`, `--csharp-variant`, and `--memory-mode` Python CLI arguments.
- [x] The MCP tool `push_down_claude_customizations` schema gains optional `packs`,
      `csharp_variant`, and `memory_mode` fields; an invocation with only `workspace_root`
      remains valid and backward-compatible.
- [x] The parity test in `test_push_down_claude_resource_contracts.py` excludes the
      bundle-only variant subtree from the root-to-bundle byte-identical assertion.
- [x] A new test asserts the variant subtree never collides with a root `.claude` path
      (conflict-prevention guarantee) and that the destination receives exactly one C#
      toolchain.
- [x] Python toolchain is green: Black, Ruff, Pyright, and Pytest with coverage
      >= 85% line and >= 75% branch.
- [x] TypeScript toolchain is green: Prettier, ESLint, tsc, and Vitest with coverage
      meeting the repository thresholds.

## Constraints & Risks

- Backward compatibility is mandatory: the no-argument command, the no-argument MCP
  invocation, and the existing service interface must continue to function unchanged.
- Mutual exclusion of C# toolchains must be enforced so the destination never receives
  both the modern and legacy C# files.
- The legacy variant subtree must not be enumerated by the default push-down and must
  never appear at the repository root `.claude` tree.
- The `merge` memory mode requires a destination-existence check, which the current
  fixed-path `EXCLUDED_RELATIVE_PATHS` mechanism cannot express; a filesystem-level
  check is required without introducing runtime temp-file use in tests.
- The multi-step VS Code QuickPick flow cannot be fully validated by the current mocked
  test harness; conditional display and multi-select behavior require either mocked
  unit coverage at the command-registration layer or a VS Code integration host. Final
  UI appearance is verified manually before release.
- Out of scope: `.claude/schemas/orchestrator-state.schema.json` from the diverged
  tocompare snapshot is excluded; no schema-file-based orchestrator-state validation is
  introduced.

## Test Conditions to Consider

- [x] Unit coverage: pack manifest parsing, pack filtering (core always included),
      variant source-path selection, memory-mode filtering (overwrite/merge/skip), CLI
      argument parsing and defaults.
- [x] Integration scenarios: end-to-end push-down with selected packs and variant using
      the in-memory filesystem double; parity test adaptation; conflict-prevention test.
- [x] CLI/API examples: `--packs`, `--csharp-variant`, `--memory-mode` argument
      combinations; MCP schema with and without the new optional fields; VS Code
      selection-to-argument mapping.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/` folder from the template
