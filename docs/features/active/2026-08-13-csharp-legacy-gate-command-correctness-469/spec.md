# csharp-legacy-gate-command-correctness (Spec)

- **Issue:** #469
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-13T16-26
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this spec is the sole AC source file; no `user-story.md` exists for this feature)

## Context
The `csharp-legacy` customization profile documents three C# quality-gate commands that either fail to run or can report success without executing the gate they claim to enforce. The defect is in the upstream canonical variant sources, so every downstream repository that selects the `csharp-legacy` pack inherits non-executing gates.

Environment:
- OS/version: Windows 11 (downstream consumer: TaskMaster, classic-MSBuild / .NET Framework)
- Python version: n/a (defect is in Markdown resource payloads, not Python code)
- Command/flags used: `push_down_claude_customizations` and `push_down_codex_and_agents_customizations` with `--packs core,csharp-legacy`
- Data source or fixture: `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/**` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/**`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Downstream consumers of the `csharp-legacy` pack believe three quality gates are enforced when they are not. The defect is silent: the commands exit 0 or fail with an unrelated usage error, so it is not detected by ordinary use.


## Repro & Evidence
Steps to Reproduce:
1. Push the `csharp-legacy` pack down into a classic-MSBuild consumer repository that pins CSharpier 1.2.6 in `.config/dotnet-tools.json`.
2. Follow the emitted formatting gate literally and run `dotnet tool run csharpier .`.
3. Follow the emitted analyzer and type-check gates literally and run the documented `msbuild ... /t:Build ...` commands twice in the same warm worktree.

Expected:
Each documented gate command runs and enforces the gate it names: the formatter executes, the analyzer build compiles and surfaces analyzer diagnostics, and the type-check build compiles and surfaces compiler and nullable-flow diagnostics under the repository's actual nullable opt-in model.

Actual:
1. `dotnet tool run csharpier .` exits with `Required command was not provided`. CSharpier 1.x requires a `format` or `check` subcommand. The alternative `csharpier .` form documented alongside it resolves a globally installed CSharpier whose version can differ from the manifest-pinned version used by CI.
2. The analyzer and type-check gates use `/t:Build`. On a warm worktree MSBuild's incremental check skips `CoreCompile` for every project, so the build exits 0 without compiling. Exit code 0 therefore does not establish that analyzers or compiler diagnostics ran.
3. The type-check gate passes `/p:Nullable=enable`. The legacy consumer's projects opt into nullable per file with `#nullable enable` and set no project-wide `<Nullable>` property, so the command-line property opts every unannotated file in at once and produces a large volume of pre-existing errors on a clean baseline, making the gate unusable.

Logs / Screenshots:
- [x] Attached minimal logs or snippet
- Snippet: `dotnet tool run csharpier .` → `Required command was not provided.`


## Scope & Non-Goals

### In scope

1. Content correction of the four canonical `csharp-legacy` variant source files (listed in Root Cause Analysis), including the fifth edit site at line 83 of the Claude `rules/csharp.md` variant (the "Severity-first ordering invariant" section cites the stale type-check command and must drop `/p:Nullable=enable` from the cited fragment).
2. Update of the `README.md` "Legacy VSTO C# (.NET Framework)" section (currently lines 352-359; command lines 356-358) so its documented format, analyze, and nullable commands match the corrected canonical sources and contain no stale command form (AC15).
3. Deterministic test additions in the existing Python resource-contract and push-down test files, per the Test Strategy section.

### Out of scope / non-goals

1. **No MSBuild binary-log or `CoreCompile`-execution-count proof requirement.** The downstream handoff proposed requiring an MSBuild file or binary log plus a positive `CoreCompile` execution-count assertion as proof that compilation occurred. That requirement was struck by owner decision on 2026-08-13: this repository has no classic-MSBuild solution and no MSBuild harness with which to establish it. No binlog or `CoreCompile`-count requirement appears in any legacy surface, any test, or any other part of this specification.
2. **No change to the modern/default C# profile on either surface**, and no change to any parallel-orchestration resource (AC13).
3. **No correction of the pre-existing Codex default-slot defect.** The Codex/Agents default (modern) slot files `.agents/skills/csharp/SKILL.md` and `.agents/skills/csharp-qa-gate/SKILL.md` (root and bundle mirrors) carry classic-MSBuild, `TaskMaster.sln`, MSTest, and `/p:Nullable=enable` content. This predates this change, is deliberately not corrected here because the default C# profile must remain unchanged, and is recorded separately at `docs/features/potential/2026-08-13-codex-default-csharp-slot-carries-legacy-content.md`. Consequently the stale-form absence assertions (AC11) are scoped to the four `csharp-legacy` variant files only, never to the default-slot files, the bundle at large, or the repository at large.
4. **No edit to `packages/mcp-server/resources/**`.** That tree is untracked build output regenerated by `packages/mcp-server/prepack.cjs`.
5. **No execution of the classic TaskMaster MSBuild commands against this repository.** `drm-copilot` uses the modern SDK-style C# profile and has no classic-MSBuild solution; the corrected commands are validated as emitted text, not by running them here.
6. `.github/instructions/csharp-*.instructions.md`, `.github/agents/csharp-*.agent.md`, and their bundle mirrors under `extensions/drm-copilot/resources/customizations/.github/` are Copilot-surface policy files, excluded by repository policy and not named by the issue.

### Explicitly excluded systems, integrations, or datasets

- The Copilot customization surface (`.github/**` and its bundle mirror).
- All parallel-orchestration resources.
- Downstream consumer repositories: this change corrects the upstream canonical sources; downstream re-push is a consumer action, not part of this change.

### Known constraint (not a gap to be filled)

Neither push-down CLI has a dry-run or check-only flag. `scripts/dev_tools/push_down_claude_customizations.py` and `scripts/dev_tools/push_down_codex_and_agents_customizations.py` accept exactly `--destination`, `--packs`, `--csharp-variant`, and `--memory-mode`. Validation for this change is therefore the pytest and Jest suites only; no push-down command is executed against a real destination as part of verification.

## Root Cause Analysis
The legacy variant sources were authored against an older CSharpier CLI and against an assumed solution-wide nullable opt-in, and they reused the CI `/t:Build` target for local invocation without accounting for MSBuild incrementality in a warm local worktree. Affected canonical sources:

- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`

The modern/default C# profile describes a modern SDK-style repository and is out of scope; it must remain unchanged.


## Proposed Fix

### Design summary (what changes where):

#### The corrected gate contract (stated once, authoritative for all four files)

The `csharp-legacy` profile documents the following gate commands:

1. **Formatting (CSharpier, manifest-pinned).** Apply formatting with `dotnet tool run csharpier format .`; verify formatting read-only with `dotnet tool run csharpier check .`. Run `dotnet tool restore` first when the manifest tool has not been restored. Always invoke through `dotnet tool run` so the manifest-pinned CSharpier version is used. The global-CSharpier fallback (`csharpier .`) is removed; there is no global fallback. (AC1, AC2, AC3)

2. **Analyzer gate (local).**

   ```
   msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true
   ```

   The documentation explains that `/t:Rebuild` is intentional for a warm local worktree: `/t:Build` can skip `CoreCompile` through MSBuild incrementality and exit 0 without running analyzers. CI may retain `/t:Build` on a cold checkout. (AC4)

3. **Compiler and nullable gate (local).**

   ```
   msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:TreatWarningsAsErrors=true
   ```

   The documentation explains that `/t:Rebuild` is required locally so compiler and nullable-flow diagnostics actually run. Per-file nullable participation through `#nullable enable` is documented as the legacy opt-in model. `/p:Nullable=enable` must not appear in any documented command; it may appear in explanatory prose that instructs the reader not to pass it, per the Nullable-Literal Scoping section. `/p:TreatWarningsAsErrors=true` is retained. (AC5, AC6)

4. **Preserved unchanged.** Gate ordering (format → analyze → type-check → test), the restart-from-formatting rule, zero-regression comparisons, and the existing evidence and reporting contract are preserved exactly as they stand today. The test gate (`vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`) is unchanged. (AC8)

#### Platform-property quoting (normative)

All four files carry the whole-argument form `"/p:Platform=Any CPU"`, replacing the current value-only form `/p:Platform="Any CPU"`. The whole-argument form is a single quoted token in both `cmd.exe` and PowerShell and reaches MSBuild identically; the value-only form is tokenized differently per shell. MSBuild accepts either spelling, so this is a portability normalization, not a semantic change. Because AC10 tests assert exact substrings, one canonical form is required.

#### Solution-placeholder conventions (preserve, do not normalize)

- Claude-surface files use the placeholder `<solution>.sln`.
- Codex-surface files use the literal `TaskMaster.sln`.

Each file keeps its existing convention; the fix does not normalize across surfaces.

### Boundaries and invariants to preserve:

- The variant subtree remains bundle-only and non-colliding with the modern subtree (existing contract test `test_variant_subtree_is_bundle_only_and_non_colliding` continues to hold, because the corrected variant text remains different from the modern counterpart per file).
- Root-to-bundle byte parity for the modern-profile files is unchanged.
- Pack manifests, routing logic, push-down engines, and all enums are untouched; the change is byte-level Markdown content only.
- Legacy and modern pack selection remain mutually exclusive (`assert_single_csharp_toolchain` on both surfaces, already tested; no change).

### Dependencies or blocked work:

None. The change has no dependency on other active features and blocks nothing.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production (Markdown resource payloads only):

1. `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md` — Toolchain steps 1-3 (lines 14-16) replaced with the corrected contract using `<solution>.sln`; step 4 and the ordering sentence unchanged. Additionally, line 83 ("Severity-first ordering invariant") drops `/p:Nullable=enable` from the cited command fragment; the surrounding warning-to-error rationale remains valid because `/p:TreatWarningsAsErrors=true` is retained.
2. `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` — the numbered four-step sequence (lines 30-33) replaced with the corrected commands using `<solution>.sln`, keeping the four-step numbering, plus one explanation paragraph inserted immediately after the list covering the `/t:Rebuild /m` rationale, the CI `/t:Build` allowance, and the `#nullable enable` per-file opt-in model.
3. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md` — identical to the file-1 steps-1-3 replacement with `TaskMaster.sln` in place of `<solution>.sln`. This file has no Analyzer Stack section, so there is no line-83 analogue.
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` — identical to the file-2 replacement (lines 32-35 plus the explanation paragraph) with `TaskMaster.sln` in place of `<solution>.sln`.

Documentation:

5. `README.md` — the "Legacy VSTO C# (.NET Framework)" section: the format, analyze, and nullable command lines (currently 356-358) are rewritten to match the corrected canonical Claude-surface commands (`<solution>.sln` placeholder convention) and contain no stale form. The test line is unchanged. (AC15)

Tests: see Test Strategy. The exact corrected wording per file is recorded in the research artifact, section 6 (`research/2026-08-13T12-00-csharp-legacy-gate-command-correctness-research.md`); that section is the authoritative replacement text.

#### Functions/classes/CLI commands impacted:

None. No Python or TypeScript production code changes. No CLI flag changes. The push-down engines copy source bytes to destination verbatim, so correcting the canonical sources corrects the emitted output.

#### Data flow and validation changes:

None at runtime. Validation changes are test-only (new contract assertions and determinism tests).

#### Error handling and logging updates:

None.

#### Rollback/feature-flag considerations (if applicable):

None. Rollback is a revert of the content commits; no flag, migration, or staged rollout applies.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Inputs are the four canonical Markdown variant sources; outputs are the byte-identical files emitted by the push-down engines at the canonical destinations when the `csharp-legacy` pack is selected. The content contract is the required/forbidden substring set in the Test Strategy section.

#### Required configuration keys and defaults:

None changed. Pack manifests (`pack-manifests/csharp-legacy.json` on both surfaces) are untouched.

#### Backward-compatibility expectations:

Pack names, manifest shapes, destination paths, CLI flags, and the modern profile are all unchanged. Downstream consumers receive corrected command text on their next push-down; no consumer-side migration is required beyond re-running the push-down.

#### Performance constraints (latency/throughput/memory):

Not applicable; the change is static Markdown content plus deterministic tests.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The push-down engines copy source bytes verbatim to destinations (established by the existing end-to-end routing tests), so real-bytes assertions on the canonical sources establish the emitted content.
  - CSharpier 1.x requires a `format` or `check` subcommand; downstream pins CSharpier via `.config/dotnet-tools.json`.
- Constraints (budget, performance, compatibility):
  - No classic MSBuild command may be executed against this repository (no classic-MSBuild solution exists here).
  - `packages/mcp-server/resources/**` must not be edited (untracked build output).
  - Both resource-contract test files must remain under the 500-line limit after extension (currently 287 and 238 lines).
  - Neither push-down CLI has a dry-run or check-only flag; test suites are the only validation mechanism.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact
- User-facing or API changes: documented gate command text changes in the `csharp-legacy` pack output and in the `README.md` legacy section. No API, tool-schema, or CLI change.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no flags, schemas, or version identifiers change.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: pack-selection and resource-contract tests asserting the corrected command forms are emitted for both the Claude and Codex/Agents `csharp-legacy` packs, and asserting the stale forms are absent.
- [x] Integration scenario to retest: end-to-end push-down pack selection for `core,csharp-legacy`, plus a modern-profile no-regression assertion and a repeated-generation determinism assertion.
- [x] Manual verification notes: validate through resource-contract and push-down tests only. `drm-copilot` uses the modern SDK-style C# profile and has no classic-MSBuild solution, so the classic commands must not be executed against `drm-copilot` itself.

### Verification contract — which test surfaces can carry which assertions

Only two test files read real repository bytes and can therefore carry real-content assertions:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — carries the AC10/AC11 content assertions for the two Claude variant files, plus the Claude modern-profile invariant assertions (AC12).
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` — carries the AC10/AC11 content assertions for the two Codex variant files.

The four pack-selection/end-to-end Python tests (`test_push_down_claude_pack_selection.py`, `test_push_down_claude_pack_end_to_end.py`, `test_push_down_codex_and_agents_customizations.py`, `test_push_down_codex_pack_selection.py`) and both TypeScript push-down tests (`extensions/drm-copilot/test/repo-automation-service.push-down-claude.test.ts`, `.push-down-codex.test.ts`) use in-memory doubles with synthetic content and therefore cannot assert real emitted text. They are used only for routing, mutual exclusion, and determinism assertions. No TypeScript test changes are required.

### Required-substring set (AC10), asserted per affected variant file

- `dotnet tool run csharpier format .`
- `dotnet tool run csharpier check .`
- `dotnet tool restore`
- `/t:Rebuild /m`
- `"/p:Platform=Any CPU"`
- `/p:TreatWarningsAsErrors=true`
- `#nullable enable`

### Forbidden-substring set (AC11), asserted per affected variant file

- `csharpier .` — this single literal covers both stale CSharpier forms: it matches `dotnet tool run csharpier .` and the global `` `csharpier .` `` fallback, and it matches nothing in the corrected text (`csharpier check .` does not contain `csharpier .` as a contiguous substring).
- `sln /t:Build` — the forbidden build literal is the command context `sln /t:Build`, NOT bare `/t:Build`. The corrected files intentionally mention `/t:Build` inside their explanation sentences ("CI may retain `/t:Build` on a cold checkout"), so a bare `/t:Build` absence scan fails by design. `sln /t:Build` is absent from the corrected text and present in every stale command.
- `/p:Platform="Any CPU"` (the superseded value-only quoting form)

Scoping rule: absence scans run only against the four `csharp-legacy` variant files. Bundle-wide or repository-wide scans are prohibited because out-of-scope files (README history, Codex default-slot files, `.github/` policy files) legitimately carry stale forms outside this change's scope.

### Nullable-Literal Scoping (AC6, AC10, AC11)

`/p:Nullable=enable` is deliberately NOT in the file-scoped forbidden set above. Its absence assertion is **command-scoped**, and the unit of scoping is the inline code span, not the line:

> In any of the four `csharp-legacy` variant files, no backtick-delimited inline code span may contain both `msbuild` and `/p:Nullable=enable`.

Implementation: extract spans with the pattern `` `([^`\n]+)` `` and assert the conjunction holds for none of them. Matching is case-sensitive; the lowercase `msbuild` token appears only in command spans, whereas prose refers to the product as `MSBuild`.

The span is the correct unit because these files document every command inside an inline code span, and a command's arguments are exactly the contents of that span. A line-scoped predicate was considered and rejected: the corrected step 3 places the command span and the prohibition sentence on one source line, so a line-scoped rule would force the prohibition sentence onto a separate continuation line purely to satisfy the test. That lets the test's granularity dictate document layout, which is fragile and inverts the intended dependency. The span-scoped predicate needs no layout change.

Verified against the current files: there are zero fenced code blocks in all four, so inline spans are the complete command surface; and the predicate flags exactly the five pre-fix violations (the Claude `rules/csharp.md` variant's step-3 command and its line-83 cited fragment, plus one command in each of the other three files).

Rationale. The corrected text must warn the reader not to pass the project-wide nullable property, and the clearest warning names the property literally. That leaves the string present in explanatory prose while absent from every command. Command scoping is the formulation that matches the requirement as originally stated — "the legacy type-check **command** … does not contain `/p:Nullable=enable`" (AC10) and "do not add `/p:Nullable=enable` to the legacy profile", meaning do not add it as a command argument.

A file-wide literal ban was considered and rejected. It is satisfiable only by replacing the explicit property name with a circumlocution such as "the project-wide nullable MSBuild property", which is worse documentation: a maintainer who greps for `/p:Nullable=enable` to learn why it is absent would find nothing. The command-scoped predicate is a precise regression guard against the actual defect — the property appearing on a build command line — and it preserves explicit, greppable prose.

Satisfiability is established: after correction, the only spans containing `/p:Nullable=enable` are the standalone `` `/p:Nullable=enable` `` spans inside prohibition sentences, which contain no `msbuild`. The line-83 site in the Claude `rules/csharp.md` variant currently carries both tokens inside one span and is corrected by dropping the property from the cited fragment, so it satisfies the predicate after the edit. No source line needs to be split.

This scoping applies only to `/p:Nullable=enable`. The other three forbidden literals do not collide with any required prose and remain file-scoped.

### Regression tests to add or update:

- New content-contract test functions in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` asserting the required-substring set present and the forbidden-substring set absent in the two Claude variant files (AC9, AC10, AC11).
- New content-contract test functions in `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` doing the same for the two Codex variant files (AC9, AC10, AC11).
- Claude modern-profile invariant assertions in the Claude resource-contract file: root `.claude/rules/csharp.md` and `.claude/skills/csharp-qa-gate/SKILL.md` contain `dotnet csharpier check .` and `dotnet build`, and contain neither `msbuild` nor `/t:Rebuild` (AC12; bundle byte parity is already enforced by existing tests). No equivalent "modern lacks msbuild" assertion is added on the Codex side, because the Codex default-slot files carry pre-existing, out-of-scope classic-MSBuild content; the Codex AC12 obligation reduces to the diff not touching the default files, which the existing parity test plus change-scope review establish.
- Repeated-generation determinism tests (AC12): in `test_push_down_claude_pack_end_to_end.py`, run `push_down_customizations` twice with `packs=frozenset({"core", "csharp-legacy"})` and `csharp_variant="legacy"` into two destination roots on the same `RecordingFileSystem` and assert the two `{relative_path: content}` maps are equal; mirror the same shape in `test_push_down_codex_and_agents_customizations.py` for the Codex engine.
- No new mutual-exclusivity tests: both surfaces already cover the reject and accept branches of `assert_single_csharp_toolchain` (AC12).

### Unit tests (pytest) for the fixed behavior and boundaries:

Follow the existing pattern in each contract file: module-level constants for variant file paths and required/forbidden substrings, one test function per surface class, the existing `read_text` helper, and one assertion message per substring. No new test file; both contract files remain under 500 lines.

### Edge cases and negative scenarios (invalid inputs, missing data, boundary values):

- Substring collision: `csharpier check .` must not trip the `csharpier .` forbidden scan (it does not, as a contiguous-substring matter; the test literals above are chosen for this reason).
- Explanation-sentence collision: the corrected text's "CI may retain `/t:Build`" sentence must not trip the build-form forbidden scan (hence `sln /t:Build`, not bare `/t:Build`).
- Both-variant selection continues to raise `ManifestError` (existing tests).

### Error handling and logging verification:

Not applicable; no production code paths change.

### Coverage impact and targets for changed lines/modules:

No Python or TypeScript production file changes; Markdown is not in any coverage denominator, and `tests/` is excluded from coverage by policy. The obligation reduces to the uniform gates (line >= 85%, branch >= 75%) continuing to pass on unchanged production code, verified by the AC14 toolchain run.

### Toolchain commands to run (format → lint → type-check → test):

1. `poetry run black .`
2. `poetry run ruff check .`
3. `poetry run pyright`
4. `poetry run pytest --cov --cov-branch --cov-report=term-missing`
5. In `extensions/drm-copilot/`: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test` (coverage via `npm run test:coverage`)

Restart from step 1 if any stage fails or rewrites files; AC14 requires one final clean pass of the full sequence.

### Manual validation steps (if required):

None beyond diff-scope review for AC13. Do not run push-down against a real destination and do not execute any classic MSBuild command against this repository.


## Acceptance Criteria

Each criterion below traces one-to-one to the identically numbered criterion in `issue.md`. The forbidden-literal precision of the issue's scope note applies to AC7 and AC11: the CSharpier forbidden literal is `csharpier .` and the build forbidden literal is `sln /t:Build`, not bare `/t:Build`.

- [x] AC1 — The `csharp-legacy` formatting gate applies formatting with `dotnet tool run csharpier format .` and verifies formatting read-only with `dotnet tool run csharpier check .`, in every affected legacy surface.
- [x] AC2 — The `csharp-legacy` formatting gate requires `dotnet tool restore` when the manifest tool has not been restored, and requires `dotnet tool run` so the manifest-pinned version is used.
- [x] AC3 — The global-CSharpier fallback (`csharpier .`) is removed from every affected `csharp-legacy` surface.
- [x] AC4 — The `csharp-legacy` local analyzer gate is documented as `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true`, with an explanation that `/t:Rebuild` is intentional for a warm local worktree and that CI may retain `/t:Build` on a cold checkout.
- [x] AC5 — The `csharp-legacy` local compiler and nullable gate is documented as `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:TreatWarningsAsErrors=true`, with an explanation that `/t:Rebuild` is required locally so compiler and nullable-flow diagnostics actually run.
- [x] AC6 — `/p:Nullable=enable` is absent from every documented command in every affected `csharp-legacy` surface, `/p:TreatWarningsAsErrors=true` is retained, and per-file nullable participation through `#nullable enable` is documented as the legacy opt-in model. The property name may appear in explanatory prose that instructs the reader not to pass it; the absence assertion is command-scoped per the Nullable-Literal Scoping section.
- [x] AC7 — The stale forms `dotnet tool run csharpier .`, the global `csharpier .` fallback, and warm local `/t:Build` gate instructions are absent from every affected `csharp-legacy` surface.
- [x] AC8 — Gate ordering (format → analyze → type-check → test), the restart-from-formatting rule, zero-regression comparisons, and the existing evidence and reporting contract are preserved unchanged.
- [x] AC9 — Deterministic tests prove that selecting the `csharp-legacy` pack emits the corrected canonical destination files for both the Claude and the Codex/Agents surfaces.
- [x] AC10 — Deterministic tests prove the legacy output contains `dotnet tool run csharpier format .` and `dotnet tool run csharpier check .`, that the local analyzer and type-check commands use `/t:Rebuild /m`, that the type-check command retains `/p:TreatWarningsAsErrors=true`, and that it does not contain `/p:Nullable=enable`.
- [x] AC11 — Deterministic tests prove the stale command forms of AC7 are absent from the affected legacy surfaces.
- [x] AC12 — Deterministic tests prove the modern/default C# profile is unchanged against its baseline, that legacy and modern pack selection remain mutually exclusive, and that repeated generation produces identical output.
- [x] AC13 — Only canonical `csharp-legacy` sources, the `README.md` legacy-pack description, and directly related tests are changed. The modern/default C# profile on both surfaces and all parallel-orchestration resources are unchanged.
- [x] AC14 — The full required upstream toolchain (format, lint, type-check, test) passes in one final clean sequence.
- [x] AC15 — The `README.md` "Legacy VSTO C# (.NET Framework)" section is updated so its documented format, analyze, and nullable commands match the corrected canonical sources and contain no stale command form.

## Risks & Mitigations
- Technical or operational risks:
  - A naive absence scan using bare `/t:Build` or a bundle-/repo-wide scope would fail on intentionally retained explanation text or on out-of-scope files. Mitigation: the forbidden literals and per-file scoping are fixed normatively in the Test Strategy section.
  - The line-83 edit site in the Claude `rules/csharp.md` variant could be missed because it is outside the three-line command block. Mitigation: it is named explicitly in scope and covered by the command-scoped `/p:Nullable=enable` assertion, which that line violates before the edit (it carries both `msbuild` and the property on one line).
  - Prohibition prose collides with a file-wide literal ban: the corrected text must name `/p:Nullable=enable` in order to tell the reader not to pass it, which a file-wide absence scan would reject. Mitigation: the assertion is command-scoped per the Nullable-Literal Scoping section, so the prohibition sentence is permitted and the command line is still guarded.
  - Editing a modern-profile or default-slot file by mistake would violate AC13. Mitigation: the Claude modern-invariant assertions plus the existing byte-parity tests detect Claude-side drift; Codex-side protection is the parity test plus diff-scope review.
- Mitigations and rollbacks: revert the content commits; no state, schema, or configuration to unwind.

## Rollout & Follow-up
- Release/rollout steps: standard PR to `main`. Downstream consumers pick up the corrected commands on their next `csharp-legacy` push-down; no coordinated rollout is required.
- Post-fix monitoring or clean-up tasks: none for this change. The Codex default-slot defect remains open as a separate follow-up.
- Links: issue #469 (https://github.com/drmoisan/drm-copilot/issues/469); requirements: `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/issue.md`; research: `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/research/2026-08-13T12-00-csharp-legacy-gate-command-correctness-research.md`; out-of-scope defect record: `docs/features/potential/2026-08-13-codex-default-csharp-slot-carries-legacy-content.md`.
