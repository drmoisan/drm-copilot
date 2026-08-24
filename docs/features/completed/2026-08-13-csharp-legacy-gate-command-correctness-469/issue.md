# csharp-legacy-gate-command-correctness (Issue #469)

- Date captured: 2026-08-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/csharp-legacy-gate-command-correctness/ (Issue #469)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #469
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/469
- Last Updated: 2026-08-13
- Work Mode: full-bug

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

## Acceptance Criteria

- [x] AC1 — The `csharp-legacy` formatting gate applies formatting with `dotnet tool run csharpier format .` and verifies formatting read-only with `dotnet tool run csharpier check .`, in every affected legacy surface.
- [x] AC2 — The `csharp-legacy` formatting gate requires `dotnet tool restore` when the manifest tool has not been restored, and requires `dotnet tool run` so the manifest-pinned version is used.
- [x] AC3 — The global-CSharpier fallback (`csharpier .`) is removed from every affected `csharp-legacy` surface.
- [x] AC4 — The `csharp-legacy` local analyzer gate is documented as `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true`, with an explanation that `/t:Rebuild` is intentional for a warm local worktree and that CI may retain `/t:Build` on a cold checkout.
- [x] AC5 — The `csharp-legacy` local compiler and nullable gate is documented as `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:TreatWarningsAsErrors=true`, with an explanation that `/t:Rebuild` is required locally so compiler and nullable-flow diagnostics actually run.
- [x] AC6 — `/p:Nullable=enable` is absent from every documented command in every affected `csharp-legacy` surface, `/p:TreatWarningsAsErrors=true` is retained, and per-file nullable participation through `#nullable enable` is documented as the legacy opt-in model. The property name may appear in explanatory prose that instructs the reader not to pass it; see the scope note on nullable-literal scoping.
- [x] AC7 — The stale forms `dotnet tool run csharpier .`, the global `csharpier .` fallback, and warm local `/t:Build` gate instructions are absent from every affected `csharp-legacy` surface.
- [x] AC8 — Gate ordering (format → analyze → type-check → test), the restart-from-formatting rule, zero-regression comparisons, and the existing evidence and reporting contract are preserved unchanged.
- [x] AC9 — Deterministic tests prove that selecting the `csharp-legacy` pack emits the corrected canonical destination files for both the Claude and the Codex/Agents surfaces.
- [x] AC10 — Deterministic tests prove the legacy output contains `dotnet tool run csharpier format .` and `dotnet tool run csharpier check .`, that the local analyzer and type-check commands use `/t:Rebuild /m`, that the type-check command retains `/p:TreatWarningsAsErrors=true`, and that it does not contain `/p:Nullable=enable`.
- [x] AC11 — Deterministic tests prove the stale command forms of AC7 are absent from the affected legacy surfaces.
- [x] AC12 — Deterministic tests prove the modern/default C# profile is unchanged against its baseline, that legacy and modern pack selection remain mutually exclusive, and that repeated generation produces identical output.
- [x] AC13 — Only canonical `csharp-legacy` sources, the `README.md` legacy-pack description, and directly related tests are changed. The modern/default C# profile on both surfaces and all parallel-orchestration resources are unchanged.
- [x] AC14 — The full required upstream toolchain (format, lint, type-check, test) passes in one final clean sequence.
- [x] AC15 — The `README.md` "Legacy VSTO C# (.NET Framework)" section is updated so its documented format, analyze, and nullable commands match the corrected canonical sources and contain no stale command form.

### Scope note — platform-property quoting

All four affected legacy surfaces currently write the platform property in the value-only form `/p:Platform="Any CPU"`. AC4 and AC5 specify the whole-argument form `"/p:Platform=Any CPU"` verbatim. The whole-argument form is a single quoted token in both `cmd.exe` and PowerShell and reaches MSBuild identically, whereas the value-only form is tokenized differently per shell. MSBuild accepts either spelling, so this is a portability normalization, not a semantic change. The corrected form is required in all four files.

### Scope note — nullable-literal scoping for AC6, AC10, and AC11

The corrected text must warn the reader not to pass the project-wide nullable property. The clearest way to write that warning is to name the property literally, which means the string `/p:Nullable=enable` remains present in explanatory prose even though it is absent from every command.

The absence assertion is therefore **command-scoped, not file-scoped**, and the unit of scoping is the inline code span: no backtick-delimited code span may contain both `msbuild` and `/p:Nullable=enable`. This is the formulation that matches the requirement as originally stated ("the legacy type-check **command** … does not contain `/p:Nullable=enable`") and the implementation requirement ("do not add `/p:Nullable=enable` to the legacy profile", meaning do not add it as a command argument).

The span is the right unit because every documented command in these files lives inside an inline code span, and a command's arguments are exactly that span's contents. A line-scoped variant was rejected: the corrected step 3 carries the command span and the prohibition sentence on one source line, so a line-scoped rule would force a continuation-line split purely to satisfy the test, letting test granularity dictate document layout.

A file-wide literal ban was considered and rejected. It is satisfiable only by replacing the explicit property name with a circumlocution such as "the project-wide nullable MSBuild property", which is worse documentation: a maintainer who greps for `/p:Nullable=enable` to learn why it is absent would find nothing. Command scoping is a precise regression guard against the actual defect — the property being passed on the build command line — and it preserves explicit, greppable prose.

This scoping applies only to `/p:Nullable=enable`. The other forbidden literals (`csharpier .`, `sln /t:Build`, `/p:Platform="Any CPU"`) do not collide with any required prose and remain file-scoped within the four variant files.

### Scope note — forbidden-literal precision for AC7 and AC11

The corrected files intentionally mention `/t:Build` inside their explanation sentences ("CI may retain `/t:Build` on a cold checkout"). A bare `/t:Build` absence scan would therefore fail by design. The forbidden literal for the warm-local build instruction is the command context `sln /t:Build`, which is absent from the corrected text and present in every stale command. The forbidden literal for both CSharpier stale forms is `csharpier .`, which matches `dotnet tool run csharpier .` and the global `` `csharpier .` `` fallback and matches nothing in the corrected text (`csharpier check .` does not contain `csharpier .` as a contiguous substring).

### Out-of-scope defect observed during research

The Codex/Agents default (modern) slot files `.agents/skills/csharp/SKILL.md` and `.agents/skills/csharp-qa-gate/SKILL.md` carry classic-MSBuild, `TaskMaster.sln`, MSTest, and `/p:Nullable=enable` content, so the Codex modern profile is not modern. This is a pre-existing defect that predates this change. It is deliberately not corrected here because the requirement set mandates that the default C# profile remain unchanged. It is recorded as a separate potential-bug entry for follow-up. Consequently the AC11 stale-form absence assertions are scoped to the `csharp-legacy` variant surfaces only, not to the default-slot files.

### Explicitly out of scope

The downstream handoff also proposed requiring an MSBuild file or binary log plus a positive `CoreCompile` execution-count assertion as proof that compilation occurred. That requirement is struck by owner decision on 2026-08-13: the handoff was authored without visibility into this repository, which has no classic-MSBuild solution and no MSBuild harness with which to establish it. No binlog or `CoreCompile`-count requirement is added to any legacy surface, and no such assertion is added to any test.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
