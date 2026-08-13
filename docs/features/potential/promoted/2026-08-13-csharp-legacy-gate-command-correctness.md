# csharp-legacy-gate-command-correctness (Potential Bug)

- Date captured: 2026-08-13
- Author: Dan Moisan
- Status: Promoted -> https://github.com/drmoisan/drm-copilot/issues/469

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

The `csharp-legacy` customization profile documents three C# quality-gate commands that either fail to run or can report success without executing the gate they claim to enforce. The defect is in the upstream canonical variant sources, so every downstream repository that selects the `csharp-legacy` pack inherits non-executing gates.

## Environment

- OS/version: Windows 11 (downstream consumer: TaskMaster, classic-MSBuild / .NET Framework)
- Python version: n/a (defect is in Markdown resource payloads, not Python code)
- Command/flags used: `push_down_claude_customizations` and `push_down_codex_and_agents_customizations` with `--packs core,csharp-legacy`
- Data source or fixture: `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/**` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/**`

## Steps to Reproduce

1. Push the `csharp-legacy` pack down into a classic-MSBuild consumer repository that pins CSharpier 1.2.6 in `.config/dotnet-tools.json`.
2. Follow the emitted formatting gate literally and run `dotnet tool run csharpier .`.
3. Follow the emitted analyzer and type-check gates literally and run the documented `msbuild ... /t:Build ...` commands twice in the same warm worktree.

## Expected Behavior

Each documented gate command runs and enforces the gate it names: the formatter executes, the analyzer build compiles and surfaces analyzer diagnostics, and the type-check build compiles and surfaces compiler and nullable-flow diagnostics under the repository's actual nullable opt-in model.

## Actual Behavior

1. `dotnet tool run csharpier .` exits with `Required command was not provided`. CSharpier 1.x requires a `format` or `check` subcommand. The alternative `csharpier .` form documented alongside it resolves a globally installed CSharpier whose version can differ from the manifest-pinned version used by CI.
2. The analyzer and type-check gates use `/t:Build`. On a warm worktree MSBuild's incremental check skips `CoreCompile` for every project, so the build exits 0 without compiling. Exit code 0 therefore does not establish that analyzers or compiler diagnostics ran.
3. The type-check gate passes `/p:Nullable=enable`. The legacy consumer's projects opt into nullable per file with `#nullable enable` and set no project-wide `<Nullable>` property, so the command-line property opts every unannotated file in at once and produces a large volume of pre-existing errors on a clean baseline, making the gate unusable.

## Logs / Screenshots

- [x] Attached minimal logs or snippet
- Snippet: `dotnet tool run csharpier .` → `Required command was not provided.`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Downstream consumers of the `csharp-legacy` pack believe three quality gates are enforced when they are not. The defect is silent: the commands exit 0 or fail with an unrelated usage error, so it is not detected by ordinary use.

## Suspected Cause / Notes

The legacy variant sources were authored against an older CSharpier CLI and against an assumed solution-wide nullable opt-in, and they reused the CI `/t:Build` target for local invocation without accounting for MSBuild incrementality in a warm local worktree. Affected canonical sources:

- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`

The modern/default C# profile describes a modern SDK-style repository and is out of scope; it must remain unchanged.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: pack-selection and resource-contract tests asserting the corrected command forms are emitted for both the Claude and Codex/Agents `csharp-legacy` packs, and asserting the stale forms are absent.
- [x] Integration scenario to retest: end-to-end push-down pack selection for `core,csharp-legacy`, plus a modern-profile no-regression assertion and a repeated-generation determinism assertion.
- [x] Manual verification notes: validate through resource-contract and push-down tests only. `drm-copilot` uses the modern SDK-style C# profile and has no classic-MSBuild solution, so the classic commands must not be executed against `drm-copilot` itself.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch

## Restoration Note

This file was reconstructed on 2026-08-13 during the orchestration of issue #469. The `potential_to_issue` MCP call reported `destination_path` `docs/features/potential/promoted/2026-08-13-csharp-legacy-gate-command-correctness.md`, and the file was verified present on disk immediately after the call. It was later found missing, together with its pre-promotion source at `docs/features/potential/2026-08-13-csharp-legacy-gate-command-correctness.md`, with no intervening command in the orchestration that removes files. The content here is the authored original. The disappearance is recorded as a tooling anomaly in the orchestrator checkpoint; it did not affect issue #469, the branch, or the active feature folder.
