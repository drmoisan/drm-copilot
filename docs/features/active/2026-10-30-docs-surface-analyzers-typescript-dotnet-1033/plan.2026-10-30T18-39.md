# docs-surface-analyzers-typescript-dotnet - Plan

- **Issue:** #1033
- **Parent (optional):** #1019 (epic documentation-estate-tooling, manifest placeholder 900004, wave 1, band C4)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T23-40
- **Status:** Draft
- **Version:** 0.2 (first full plan; replaces the template stub)
- **Work Mode:** full-feature (AC sources: `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`)
- **Research (primary):** `research/2026-10-30T22-45-docs-surface-analyzers-typescript-dotnet-research.md`

## Required References

- Policy order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md` (and the `.github/instructions/` sources they mirror).
- Contracts: `spec.md` is normative for every symbol, declaration form, diagnostic code, bound, and registry row named below; this plan does not restate its tables. Binding upstream text: epic `docs/features/epics/documentation-estate-tooling/epic.md` headings `## Owner Directive: Implementation Language (2026-10-30, refined)`, `## Owner Decisions (2026-10-30, received through the coordinator)`, `### Amendment of 1020 required by D3 and D5`, the heading beginning `### PowerShell contracts from the re-preparation of 1020`, `### Command contract decisions from the first preparation of 1023 (language-independent)`, `### Analyzer decisions from the first preparation of 1022 (language-independent)`, `### 900004 - docs-surface-analyzers-typescript-dotnet (wave 1, C4)`; and 1020 `spec.md` `## Decisions Later Children Must Honor` and `### \`DocsAnalyzerRegistry.psm1\``.
- Environment: tool routes, launchers, command-text restrictions, the batch budget, hook context, MCP limits, and CI shape are owned by the `execution-environment` skill and are not restated here.

## Execution Context

- Prerequisite: 1020, including its D3/D5 amendment, is merged into the epic integration branch, and this item branch contains it. [P0-T3] verifies this and halts the run when it does not hold.
- Execution is launched later by `epic-orchestrator` in the item worktree of branch `feature/docs-surface-analyzers-typescript-dotnet-1033`, under an orchestration checkpoint that selects a batch-budget-exempt route (`execution-environment` `## Batch Budget`). The change touches at least 22 production PowerShell files (ten or eleven new modules, the registry edit, and one bundle copy of each), so it never runs in an isolated subagent worktree.
- `SCRATCH` is `<session scratchpad>/issue-1033/`; every scratch file, helper script, and report lives under it with a file name starting `issue-1033-`. Evidence records the literal token `SCRATCH`, never a host path.
- `FEATURE` is `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033`; `L` is `.claude/lib/docs/`; `B` is `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`; `T` is `tests/scripts/claude-lib/docs/`. Evidence files are `<name>.<timestamp>.md` with the UTC write time; a consumer selects the lexicographically greatest match. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- `MERGE_BASE` is the output of `git merge-base origin/main HEAD`; every scope diff anchors on it.
- Pester route (`execution-environment` `## PowerShell Route and PoshQC MCP Limits`): branch-current runs import `scripts/powershell/PoshQC/PoshQC.psd1` and call `Invoke-PoshQCTest`; counts come from `artifacts/pester/pester-junit.xml`, per-file line coverage from `artifacts/pester/powershell-coverage.xml`, analyzer findings from a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. PoshQC MCP results are never evidence.
- CI-PESTER: every suite under `T` runs with coverage on `windows-latest` in `poshqc / PowerShell QC shard 1`, `shard 2`, or `shard 3`, aggregated by the required check `poshqc / PowerShell QC`; `poshqc / PowerShell hook suites (Linux)` does not run these suites. Every Pester acceptance condition below relies on `poshqc / PowerShell QC`.
- Coverage: line coverage of at least 85% per new production module under `L`; Pester measures no branches, so no branch gate applies. `config/poshqc-coverage.json` (roots include `.claude/lib`) and `config/poshqc-scan.json` (scan folder `tests/scripts`) are not edited.
- EVIDENCE_LOCATION_OVERRIDE_REJECTED: `<FEATURE>/evidence/coverage/` (spec AC on Pester line coverage) replaced with `<FEATURE>/evidence/qa-gates/`.
- Read-only: `packages/discovery-runtime/`, `schemas/discovery/`, `.claude/lib/discovery-validation/`, every 1020 module other than the registry rows, `quality-tiers.yml`, and every Python, TypeScript, hook, skill, agent, and Codex file.

## Design Constraints From Existing Tests

- `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` (`Describe 'Claude library module conventions'`): every new `.psm1` carries the help sentence `imports its siblings with -ErrorAction Stop` before `Set-StrictMode -Version Latest`, the `$ErrorActionPreference = 'Stop'` guard on the next line, and `-ErrorAction Stop` on each column-0 `Import-Module`. Unchanged; must pass.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (`Get-PythonInvocationFinding` in `EnforcementHooksNoPythonInvocation.Helpers.ps1`): no `&` on a variable, member, or expression and no `Invoke-Expression` in `L`. Analyzers call tokenizers and helpers by static name; no new seam is added. Unchanged; must pass.
- Import cycle (spec `## Constraints & Risks`): `DocsAnalyzerExtensionImport.psm1` has no load-time import of `DocsAnalyzerRegistry.psm1`. It reads registered identifiers from `Selection.registered_analyzer_ids`; when that key is absent, `Invoke-DocsAnalyzerExtensionImport` imports the registry inside the function with a literal `Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerRegistry.psm1'` and without `-Force`, so the registry seam's `-Force` import of the analyzer never re-enters or reloads the registry module.
- `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (`test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`): every `$PSScriptRoot` use is the literal join form and every dependency is in core. Unchanged; must pass.
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (`files_naming_solution`, scan root `.claude/lib`): no new module names a solution file. Unchanged.
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`: 800-line hard limit; this plan holds every new production file to at most 500 logical lines (spec AC). A module that would exceed 500 moves a cohesive helper set into a new `L` `Docs<Area>.psm1` (R1 PowerShell) with its own suite, bundle copy, core entry, and classification row added in the same change.

## Artifact Classification

Permitting rules: R1 = owner language rule clause (1), pushed-down skills, helpers, hooks, and libs are PowerShell or bash; D = epic `### Artifact classes for this epic` (schema, configuration, data, test, documentation rows). "Avoid new Python" applies to every row. No row uses TypeScript.

| File | Class | Language | Permitting rule |
|---|---|---|---|
| `L`DocsScannerCommon.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsTypeScriptTokens.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsTypeScriptJsx.psm1 (only if the tokenizer would exceed 500 logical lines) | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsCSharpTokens.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsAnalyzerTypeScriptCli.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsAnalyzerTypeScriptHttp.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsAnalyzerTypeScriptExports.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsAnalyzerDotnetHttp.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsAnalyzerDotnetConfig.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsAnalyzerDotnetApi.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsAnalyzerExtensionImport.psm1 | pushed-down helper/lib | PowerShell | R1 |
| `L`DocsAnalyzerRegistry.psm1 (edit: rows under the 900004 anchor) | pushed-down helper/lib | PowerShell | R1 |
| `B`<each of the twelve `L` files above> (create; edit for the registry copy) | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `T`Docs.ScannerTestSupport.psm1 | test (support module) | PowerShell | D |
| `T`DocsScannerCommon.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsTypeScriptTokens.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsTypeScriptJsx.Tests.ps1 (only with the JSX split) | test | PowerShell (Pester) | D |
| `T`DocsCSharpTokens.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsAnalyzerTypeScriptCli.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsAnalyzerTypeScriptHttp.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsAnalyzerTypeScriptExports.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsAnalyzerDotnetHttp.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsAnalyzerDotnetConfig.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsAnalyzerDotnetApi.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsAnalyzerExtensionImport.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsScannerContract.Tests.ps1 | test | PowerShell (Pester) | D |
| `T`DocsAnalyzerRegistry.Tests.ps1 (edit, only if 1020's amendment has not made the change; C6) | test | PowerShell (Pester) | D |
| `FEATURE`/plan.2026-10-30T18-39.md (this file) and `FEATURE`/evidence/** | documentation | Markdown | D |

No MCP tool, extension command, hook, skill, agent, schema file, Python file, or TypeScript file is created or edited. Every row follows the language rule, so no owner exception is needed.

## Owner Questions

Carried from `spec.md` `## Owner Questions`; the plan proceeds on each provisional default and decides none of them: OQ-1 analysis method of imported elements (manifest extensions key `docs.analysis-method`, `scanner` when absent); OQ-2 ledger representation of the precision limit (decided by 1023); OQ-3 JavaScript sources (out of scope); OQ-4 `config-key` digest (line with values replaced by type names); OQ-5 anchor numbering (placeholder text stays as committed). No plan artifact falls outside the language rule, so no further owner question is raised.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads, Upstream Contract Gate, and Baselines

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, then `FEATURE/spec.md`, `FEATURE/user-story.md`, the primary research file, and the epic headings listed under `## Required References`.
  - Acceptance: `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:`, and the list of files read.
- [ ] [P0-T2] Validate this plan on the branch with the repository CLI `scripts/dev_tools/validate_orchestration_artifacts.py` (`plan` subcommand, Poetry module form).
  - Acceptance: exit 0; `FEATURE/evidence/baseline/baseline-plan-validation.<timestamp>.md` records the four fields and every `PLAN GATE WARNING: ` line (or `none`).
- [ ] [P0-T3] Verify the 1020 contract this plan consumes is present in the tree: modules `L`DocsJson.psm1 (`ConvertFrom-DocsJsonText`, `ConvertTo-DocsCanonicalJson`, `Get-DocsSha256Hex`, `Get-DocsBytesSha256Hex`), `L`DocsSurface.psm1 (`Get-DocsElementKind`, `Get-DocsElementId`, `New-DocsSurfaceElement` with the C1 analysis-method parameter, `ConvertFrom-DocsSurfaceElement`, `New-DocsDiagnostic`), `L`DocsAnalyzerRegistry.psm1 (`Get-DocsAnalyzerRegistration`, `Test-DocsAnalyzerRegistration`, `New-DocsCapturedInput`, `Invoke-DocsAnalyzer`, and the `$script:DocsAnalyzerRow` anchor for this child); suites `T`Docs.Manifest.Tests.ps1, `T`DocsNeutrality.Tests.ps1, `T`DocsAnalyzerRegistry.Tests.ps1; a `core.json` entry for `.claude/lib/docs/DocsSurface.psm1`; and a `.claude/lib/docs` entry in `quality-tiers.yml`. Each symbol is checked as an exported function after importing its module in a `sh`-launched PowerShell 7 run.
  - Acceptance: `FEATURE/evidence/other/upstream-contract-check.<timestamp>.md` records the four fields and one PRESENT or ABSENT row per item. All PRESENT: the record states `Result: PRESENT` and the run continues. Any ABSENT: the record states `Result: BLOCKED` with the absent items, no file outside `FEATURE/evidence/` is changed, and the executor stops with `BLOCKED at [P0-T3]: 1020 contract absent`.
- [ ] [P0-T4] Reconcile spec `## Contract Dependencies on 1020 and 1022` C1 through C10 against the merged 1020 `spec.md` amendment, the merged 1020 modules, and the re-prepared `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/spec.md`.
  - Behavior: one row per dependency with the upstream outcome, the adopted value (the spec's recommended default where upstream left it open), and the tasks it affects. The record fixes: the analysis-method field and parameter name (C1); whether 1020 exports a declaration-lines digest function and its final name, which decides whether `DocsScannerCommon.psm1` exports `Get-DocsDeclarationSha256` (C2); the `-Selection` keys (C3); the captured-input default bound, BOM rule, and codes (C4); the diagnostic constructor parameters (C5); the exact registry anchor literal for this child and whether `DocsAnalyzerRegistry.Tests.ps1` still asserts an empty row set (C6, OQ-5); the code grammar (C7); merge precedence (C8); the ledger decision status (C9); and the shared strings agreed with 1022 (C10). A divergent upstream decision is adopted here and does not change scope.
  - Acceptance: `FEATURE/evidence/other/contract-reconciliation.<timestamp>.md` exists with ten rows C1..C10, each naming its adopted symbol or literal; later tasks use the recorded names.
- [ ] [P0-T5] Record the scope baseline: `MERGE_BASE`, the output of `git diff --name-only MERGE_BASE HEAD`, and `git status --porcelain --untracked-files=all`; confirm that none of the ten module names of `## Artifact Classification` exists under `L` or `B`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-scope.<timestamp>.md` records both listings and the absence check.
- [ ] [P0-T6] Capture the formatting baseline: a SHA-256 digest listing (path and digest, sorted) of every file under `.claude/lib/docs` and `tests/scripts/claude-lib/docs` immediately before and after `Invoke-PoshQCFormat` over those two folders.
  - Acceptance: `FEATURE/evidence/baseline/baseline-poshqc-format.<timestamp>.md` records the four fields and both listings; any file whose digest changed is recorded as pre-existing drift and restored with `git checkout -- <path>`, so the baseline repairs nothing.
- [ ] [P0-T7] Capture the analyzer baseline with a direct `Invoke-ScriptAnalyzer` run (repository settings, recursive) over `.claude/lib/docs` and `tests/scripts/claude-lib/docs`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-pssa.<timestamp>.md` records the four fields and the finding count by severity.
- [ ] [P0-T8] Capture the Pester and coverage baseline with `Invoke-PoshQCTest` over `tests/scripts` in one process.
  - Acceptance: `FEATURE/evidence/baseline/baseline-pester-coverage.<timestamp>.md` records the four fields, the `tests`, `failures`, `errors`, and `skipped` counts from `artifacts/pester/pester-junit.xml`, each failing test name (or `none`), the overall line coverage from `artifacts/pester/powershell-coverage.xml`, and the per-file coverage of the 1020 modules under `L`; new-code baseline: not present. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P0-T9] Capture the push-down contract baseline: Pytest (no coverage) over `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-pushdown-contracts.<timestamp>.md` records the four fields and the passed and failed counts.

### Phase 1 — Test Support and Shared Scanner Helpers

- [ ] [P1-T1] Create `T`Docs.ScannerTestSupport.psm1 with in-memory builders: `New-DocsTestCapturedInput -Path -Text [-LineEnding <'LF'|'CRLF'>] [-Bom]` (encodes UTF-8 in code and calls 1020 `New-DocsCapturedInput`), `New-DocsTestOversizeInput -Path` (1048577 bytes against `-MaxBytes 1048576`), `New-DocsTestUndecodableInput -Path` (invalid UTF-8 bytes), `New-DocsTestExtensionManifest` (a valid manifest, result document, and source inputs as captured inputs, with `manifest_sha256` computed by `ConvertTo-DocsCanonicalJson` and `Get-DocsSha256Hex`), `ConvertTo-DocsTestOutputText` (canonical JSON of `@{ Elements; Diagnostics }`), and `Get-DocsTestShuffled -Item -Seed` (seeded `[System.Random]`).
  - Behavior: no file read or written, no `TestDrive`, no module-scope cache; CRLF and BOM variants are built in code because `.gitattributes` normalizes committed line endings.
  - Acceptance: consumed by every later suite, which passes in its own task.
- [ ] [P1-T2] Create `L`DocsScannerCommon.psm1 with the functions of spec `### \`DocsScannerCommon.psm1\` (pure)`, exporting `Get-DocsDeclarationSha256` only when the [P0-T4] C2 row records that 1020 does not export it; create `T`DocsScannerCommon.Tests.ps1.
  - Behavior: input selection by ordinal case-insensitive suffix and basename pattern, sorted by path; longest-root module path; matching-close and top-level argument spans; literal and literal-only `+` concatenation decoding, else `$null`; route template joining; diagnostic aggregation keyed by `(code, path)` with count and first line, converted through `New-DocsDiagnostic` and sorted by `id`, messages carrying no source text; declaration text and digest per spec `### Declaration-lines span and digest`; `Get-DocsScannerPrecisionLimit` returning the rows of spec `## Scanner Precision Limit`.
  - Tests: one `Context` per function with positive, negative, and boundary cases; `Get-DocsScannerPrecisionLimit` rows have exactly the keys `analyzer_id`, `code`, `construct`, `consequence`, are ordered by `analyzer_id` then `code` (ordinal), and every `analyzer_id` is one of the seven identifiers of spec `### Registry rows`; a seeded property test (seed printed on failure) that random edits outside a line range leave the digest unchanged and edits inside change it; LF and CRLF texts give equal digests.
  - Acceptance: 0 failures in a branch-current `Invoke-PoshQCTest` run of the suite (counts from `artifacts/pester/pester-junit.xml`); `FEATURE/evidence/regression-testing/p1-scanner-common.<timestamp>.md` records the counts and the seed. CI: `poshqc / PowerShell QC` (Windows shards).

### Phase 2 — Tokenizers

- [ ] [P2-T1] Create `L`DocsTypeScriptTokens.psm1 (`ConvertTo-DocsTypeScriptToken`) and `T`DocsTypeScriptTokens.Tests.ps1 covering every non-JSX lexical rule of spec `### \`DocsTypeScriptTokens.psm1\` (pure)`.
  - Behavior: shared token record; `\G`-anchored `[regex]` matching with one pattern per lexical state; BOM and hashbang skipped; comments produce no token; string escapes decoded into `Value`; template substitution stack with `Dynamic`; regex-versus-division by previous significant token; numeric forms; `#private`, Unicode escapes, decorators; `ts-lexical-invalid` and `token-limit` (token and depth bounds) as blocking diagnostics with no tokens returned.
  - Tests: kinds, `Value`, `Dynamic`, `Line`, `EndLine`, and `Depth` per lexical state; nested template substitutions; regex after `return` and `(` versus division after `)` and an identifier; a raw newline in a string gives one `ts-lexical-invalid`; `-MaxTokens` and `-MaxDepth` set low give one `token-limit` each.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p2-ts-tokens.<timestamp>.md` records the counts and the module's logical line count. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P2-T2] Add the JSX lexical state (`-Jsx`) of spec `### \`DocsTypeScriptTokens.psm1\` (pure)`: in `L`DocsTypeScriptTokens.psm1 when the module stays at or below 500 logical lines with it, otherwise in a new `L`DocsTypeScriptJsx.psm1 imported by literal join, with `T`DocsTypeScriptJsx.Tests.ps1.
  - Tests: element depth, attribute strings, `{...}` expression children, text with an apostrophe is not a string, closing and self-closing tags, `<T,>` and `<T extends U>` as type parameters.
  - Acceptance: 0 failures in the branch-current run of the JSX tests; `FEATURE/evidence/regression-testing/p2-ts-jsx.<timestamp>.md` records the counts, which module holds the JSX state, and its logical line count (at most 500). CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P2-T3] Create `L`DocsCSharpTokens.psm1 (`ConvertTo-DocsCSharpToken`) and `T`DocsCSharpTokens.Tests.ps1 per spec `### \`DocsCSharpTokens.psm1\` (pure)`.
  - Tests: `//`, `///`, `/* */`; directive lines produce no token and set `HasConditional` for `#if`; character literals; regular, verbatim (doubled quotes), interpolated (holes, `{{` escapes, `Dynamic`), and raw strings (quote-run length, `$$` brace width, single-line raw decoding); `u8` suffix; `@`-verbatim and `\u` identifiers with decoded `Value` and preserved `Text`; contextual keywords as identifiers; one `csharp-lexical-invalid` for an unterminated string; one `token-limit` each for the token and depth bounds.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p2-cs-tokens.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).

### Phase 3 — TypeScript Analyzers

Common to every analyzer task in Phases 3 to 5: the module follows spec `### Analyzer functions (pure; 1020 analyzer contract)` and `#### Common analyzer rules`, builds elements with `New-DocsSurfaceElement` (analysis method `scanner`, declaration-lines digest, non-null line range, per [P0-T4] C1 and C2), carries the `.NOTES` reference to `Get-DocsScannerPrecisionLimit`, and its suite asserts declarations, `parent_id`, `name`, properties, and `line_range`, plus one fixture per diagnostic code the spec assigns to that analyzer. Fixtures are single-quoted here-strings converted with `Docs.ScannerTestSupport.psm1`.

- [ ] [P3-T1] Create `L`DocsAnalyzerTypeScriptCli.psm1 (`Invoke-DocsAnalyzerTypeScriptCli`) and `T`DocsAnalyzerTypeScriptCli.Tests.ps1 per spec `### \`typescript-cli\` (Commander and yargs)`.
  - Tests: Commander chains across several lines, `command('name <arg> [opt]')` positional elements, `.command(name, description)` returning the parent, tracked `sub` variables and `.addCommand`, `.option` with `short`, `.requiredOption` with `required`, inline `.addOption(new Option(...))`, `.argument`; yargs `.command` string and object forms with arrow-function and object builders, `.option`/`.options` key rules, `.positional`; root `name_source` literal and module; declarations such as `tool serve` and `tool serve --port`; codes `cli-dynamic-registration`, `cli-unbound-registration`, `cli-command-module-unresolved`.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p3-ts-cli.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P3-T2] Create `L`DocsAnalyzerTypeScriptHttp.psm1 (`Invoke-DocsAnalyzerTypeScriptHttp`, two passes) and `T`DocsAnalyzerTypeScriptHttp.Tests.ps1 per spec `### \`typescript-http\` (Express and Fastify)`.
  - Tests: Express method set with `ANY` for `all`, path arrays, `route()` chains, a router in a second in-memory file mounted through a relative import with the composed prefix, a router mounted twice yielding two elements, an unmounted router with `mounted: false`; Fastify methods, `route({...})` with method arrays and `url` or `path`, `register` prefixes for inline, same-file, and relative-import plugins, `fp(fn)`; no implicit `HEAD`; codes `http-dynamic-route`, `http-prefix-dynamic` (element with `<dynamic>` and `prefix_resolved: false`), `http-mount-unresolved`.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p3-ts-http.<timestamp>.md` records the counts and the module's logical line count (at most 500, else split per `## Design Constraints From Existing Tests`). CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P3-T3] Create `L`DocsAnalyzerTypeScriptExports.psm1 (`Invoke-DocsAnalyzerTypeScriptExports`) and `T`DocsAnalyzerTypeScriptExports.Tests.ps1 per spec `### \`typescript-exports\``.
  - Tests: one `public-symbol` per exported name for each classified form with the module-path qualified declaration and `symbol_kind`; `type_only`, `local_name`, `reexport_from`; `export *` expanded from a relative in-memory module; a re-export cycle stopping with `ts-reexport-unresolved`; overload signatures merged into one element with `overloads`; codes `ts-export-pattern-unsupported`, `ts-export-assignment` (element `default` with `export_form: assignment`), `ts-ambient-module`, `ts-commonjs-export`; `.d.ts` and `.tsx` inputs selected.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p3-ts-exports.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).

### Phase 4 — .NET Analyzers

- [ ] [P4-T1] Create `L`DocsAnalyzerDotnetHttp.psm1 (`Invoke-DocsAnalyzerDotnetHttp`) and `T`DocsAnalyzerDotnetHttp.Tests.ps1 per spec `### \`dotnet-http\``.
  - Tests: controller detection, class prefix, `[controller]`, `[action]` without `Async`, literal `[area]`, `/` and `~/` overrides, multiple verbs and routes as combinations, `AcceptVerbs`, literal `+` folding; `MapGet` through `MapPatch`, `MapMethods` with array and collection expression, `Map` as `ANY`, nested `MapGroup` variables and chains; codes `http-dynamic-route`, `http-prefix-dynamic`, `http-receiver-unresolved`, `http-route-token-unresolved`, `http-endpoint-kind-unsupported` (once per kind and file), `dotnet-route-inherited-unresolved`, `dotnet-conventional-routing-unresolved`, `csharp-conditional-compilation`.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p4-dotnet-http.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P4-T2] Create `L`DocsAnalyzerDotnetConfig.psm1 (`Invoke-DocsAnalyzerDotnetConfig`: `System.Text.Json.JsonDocument` validity gate plus a lexical JSONC key walker for key lines) and `T`DocsAnalyzerDotnetConfig.Tests.ps1 per spec `### \`dotnet-config\``.
  - Tests: in-memory `appsettings.json` and `appsettings.Development.json` with comments and trailing commas yield one `config-key` per member path with bare and quoted segments and `[]` array segments, `value_type`, `configuration_path`, and `environment`; every configuration value is a distinctive string absent from the canonical JSON output (`ConvertTo-DocsTestOutputText`); the digest of a key line is unchanged when only its value changes (OQ-4 masking); `json-invalid` for invalid JSON, a non-object root, and depth above 64; `duplicate-declaration` keeps the first line; `input-key-limit` with no element above the key bound (set low through the test parameter).
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p4-dotnet-config.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P4-T3] Create `L`DocsAnalyzerDotnetApi.psm1 (`Invoke-DocsAnalyzerDotnetApi`) and `T`DocsAnalyzerDotnetApi.Tests.ps1 per spec `### \`dotnet-public-api\``.
  - Tests: public types in file-scoped and block namespaces, nested types by effective accessibility, generics with source-spelled type parameters, a `partial` type split across two in-memory paths (one type element at the ordinally first path, `partial_parts`); overloads with distinct declarations, constructors, indexers, operators and conversion operators, events, constants, enum members, positional record parameters; `accessibility` values; no element for `internal`, `private`, `private protected`, `file`, and explicit interface implementations; codes `duplicate-declaration` (members in `#if` regions), `csharp-declaration-unrecognized`, `csharp-conditional-compilation`.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p4-dotnet-api.<timestamp>.md` records the counts and the module's logical line count (at most 500, else split). CI: `poshqc / PowerShell QC` (Windows shards).

### Phase 5 — Extension-Result Manifest Import

- [ ] [P5-T1] Create `L`DocsAnalyzerExtensionImport.psm1 with `Test-DocsExtensionManifest` (validation steps 1 through 7 of spec `## Extension-Result Manifest Import`, returning `@{ Ok; Diagnostics; Manifest; ResultDocument }`) and `T`DocsAnalyzerExtensionImport.Tests.ps1 (`Context 'validation'`).
  - Behavior: `ConvertFrom-DocsJsonText` parsing; closed key-set and constant checks in PowerShell (no `Test-Json`); `manifest_sha256` recomputation; the first failing check yields exactly one blocking diagnostic at the manifest path; `input_manifest_sha256` carried and not verified; `extension-revision-unverified` when `Selection.revision` is null.
  - Tests: the valid manifest from `New-DocsTestExtensionManifest` returns `Ok` true; one mutation per step yields exactly one blocking diagnostic with that step's code (`extension-manifest-invalid`, `extension-manifest-digest-mismatch`, `extension-repository-mismatch`, `extension-adapter-invalid`, `extension-input-not-captured`, `extension-input-digest-mismatch`, `extension-result-digest-mismatch`, `extension-result-invalid`, `extension-finding-source-mismatch`); a fractional number reports step 1's code.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p5-ext-validation.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P5-T2] Add `Invoke-DocsAnalyzerExtensionImport` (selection, per-manifest validation, step 8 merge as inert data) to `L`DocsAnalyzerExtensionImport.psm1 with the registry-import rule of `## Design Constraints From Existing Tests`, and add `Context 'merge'` to `T`DocsAnalyzerExtensionImport.Tests.ps1.
  - Tests: each mappable finding becomes an element with `analyzer_id` `extension-import`, a recomputed `element_id`, a digest computed from the captured text, and `adapter_id`, `adapter_version`, `classification`, `confidence`, `finding_id` copied unchanged; only `value_type` copied for `config-key` (a distinctive value in another property is absent from the output); `cli-option` with and without `parent_symbol`; one non-blocking `extension-finding-skipped` with counts per reason; analysis method from `docs.analysis-method`, `scanner` when absent (OQ-1); a source-input digest mismatch yields exactly one blocking `extension-input-digest-mismatch` and no element; with `registered_analyzer_ids` absent, a call through 1020 `Invoke-DocsAnalyzer` succeeds twice in a row and `Get-DocsAnalyzerRegistration` stays callable (no re-entry break).
  - Acceptance: 0 failures in the branch-current run of the whole suite; `FEATURE/evidence/regression-testing/p5-ext-merge.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).

### Phase 6 — Registry Rows, Cross-Analyzer Contract, and Push-Down

- [ ] [P6-T1] Insert the seven rows of spec `### Registry rows` into `L`DocsAnalyzerRegistry.psm1, one per line, directly under the anchor literal recorded in [P0-T4] (C6), in the 1020 row form; change no existing line. Create `T`DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1.
  - Existing tests that assert `Get-DocsAnalyzerRegistration` output, found by searching `tests/scripts/claude-lib/docs` for `Get-DocsAnalyzerRegistration`, `DocsAnalyzerRow`, and `900004`: `DocsAnalyzerRegistry.Tests.ps1` empty-row assertion — updated in [P6-T2] unless the C6 row records it already asserts membership; `DocsProfile.Tests.ps1` `DOCS_ANALYZER_UNKNOWN` case — unchanged provided its unknown identifier is none of the seven (verified and recorded); any 1022 suite present on the branch — unchanged, because the epic requires membership assertions. Every match is recorded with its disposition.
  - Tests: the seven identifiers are present with the spec module leaves and functions; none equals `python-cli`, `python-http`, `python-public-api`, `config-files`, or `python-architecture`; `Test-DocsAnalyzerRegistration` returns no finding; in the module text every row with these identifiers lies between the recorded anchor and the next anchor or the closing delimiter, and no other row lies there.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p6-registry-rows.<timestamp>.md` records the counts and the search matches with dispositions. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P6-T2] Update `T`DocsAnalyzerRegistry.Tests.ps1 (only when the [P0-T4] C6 row records the empty-row assertion): the zero-row assertion becomes anchor presence and order plus `Test-DocsAnalyzerRegistration` returning no finding for the committed rows; every other assertion is kept.
  - Acceptance: the suite passes with 0 failures with the appended rows; `FEATURE/evidence/regression-testing/p6-registry-suite.<timestamp>.md` records the counts and either the edit made or `no edit: already amended by 1020`. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P6-T3] Create `T`DocsScannerContract.Tests.ps1 with `Context 'determinism'` and `Context 'bounds'` over all seven analyzers.
  - Tests: two runs over identical captured inputs, and three runs over orders shuffled by `Get-DocsTestShuffled` (seed printed on failure), give byte-identical `ConvertTo-DocsTestOutputText`; per analyzer, an oversize selected input yields one blocking `input-over-bound` under that analyzer's identifier and no element from that path, an undecodable one yields `input-undecodable`; a lexical error in one file leaves another file's elements unchanged; an empty input set and an empty file yield no element and no blocking diagnostic.
  - Acceptance: 0 failures in the branch-current run; `FEATURE/evidence/regression-testing/p6-contract-determinism.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P6-T4] Add `Context 'precision limit'` and `Context 'element contract'` to `T`DocsScannerContract.Tests.ps1.
  - Tests: every `(analyzer_id, code)` row of `Get-DocsScannerPrecisionLimit` is emitted by at least one fixture as a non-blocking diagnostic with the stated consequence, at most once per `(analyzer_id, code, path)`, with the count and first line in the message and no fixture source text; every non-blocking emitted code outside the spec's list of codes that are not precision limits is a table row; every element of the six built-in scanners has analysis method `scanner`, a non-null `line_range`, and passes `ConvertFrom-DocsSurfaceElement`; an edit outside `line_range` keeps the digest, an edit inside changes it, LF and CRLF variants give equal digests.
  - Acceptance: 0 failures in the branch-current run of the whole suite; `FEATURE/evidence/regression-testing/p6-contract-elements.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P6-T5] Create the bundle copies under `B` of every new module and the edited registry with one copy step from a `sh` script under `SCRATCH`.
  - Acceptance: each `B` file's SHA-256 equals its `L` source; `git status --porcelain --untracked-files=all -- extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs` lists each new copy and the modified registry copy; `FEATURE/evidence/other/bundle-mirror.<timestamp>.md` records the listing and per-file digests.
- [ ] [P6-T6] Append each new `.claude/lib/docs/` module path to `paths` in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, each exactly once.
  - Existing tests reading this file assert membership and stay unchanged: `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_claude_pack_selection.py`, `test_discovery_publication_contracts.py` (`_manifest_paths`), the existing `*.Manifest.Tests.ps1` suites under `tests/scripts/claude-lib/`, and 1020 `Docs.Manifest.Tests.ps1`.
  - Acceptance: proven by [P6-T7] and [P6-T8].
- [ ] [P6-T7] Run the existing Pester suites unmodified: `T`Docs.Manifest.Tests.ps1, `T`DocsNeutrality.Tests.ps1, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, and `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`.
  - Acceptance: 0 failures (counts from `artifacts/pester/pester-junit.xml`), no `DynamicInvocation` or `InvokeExpression` finding for any `L` file, and none of these suites is modified; `FEATURE/evidence/regression-testing/p6-existing-suites.<timestamp>.md` records the counts. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P6-T8] Run Pytest (no coverage) over the three push-down contract test files of [P0-T9] plus `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
  - Acceptance: 0 failed, including `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_claude_manifest_powershell_dependency_closure`, and `test_every_psscriptroot_occurrence_is_recognized`; no test file modified; `FEATURE/evidence/regression-testing/p6-pushdown-contracts.<timestamp>.md` records the four fields and counts. CI: `quality-checks7 / Code Quality & Tests (3.10)` through `(3.13)`.

### Phase 7 — Final QA Loop, Isolation, Scope Checks, and Self-Review

- [ ] [P7-T1] Format: a SHA-256 digest listing of every file under `.claude/lib/docs` and `tests/scripts/claude-lib/docs` immediately before and after `Invoke-PoshQCFormat` over those folders.
  - Acceptance: the two listings are identical (the formatter changed nothing); `FEATURE/evidence/qa-gates/qa-poshqc-format.<timestamp>.md` records both. If any file changed, keep the formatted text, re-run the [P6-T5] copy step, and restart from [P7-T1].
- [ ] [P7-T2] Analyze: direct `Invoke-ScriptAnalyzer` (repository settings, recursive) over `.claude/lib/docs` and `tests/scripts/claude-lib/docs`.
  - Acceptance: zero findings; `FEATURE/evidence/qa-gates/qa-pssa.<timestamp>.md` records the four fields and the count. On a finding, fix, re-sync the mirror, restart from [P7-T1].
- [ ] [P7-T3] Test with coverage: `Invoke-PoshQCTest` over `tests/scripts/claude-lib`.
  - Acceptance: `failures` and `errors` are 0; each new production module of `## Artifact Classification` (and any split module) is present in `artifacts/pester/powershell-coverage.xml` with line coverage of at least 85%; `FEATURE/evidence/qa-gates/qa-pester-coverage.<timestamp>.md` records the counts and per-file percentages. On a shortfall, add tests and restart from [P7-T1]. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P7-T4] Re-run [P6-T7] and [P6-T8] on the final tree.
  - Acceptance: both pass with 0 failures; `FEATURE/evidence/qa-gates/qa-existing-gates.<timestamp>.md` records each command and its counts.
- [ ] [P7-T5] Seeded shuffled isolation: three single-process Pester runs over every `*.Tests.ps1` under `T` plus `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, file order shuffled by `[System.Random]` seeds 1033, 20261030, and 7, through a runner script under `SCRATCH`.
  - Acceptance: each run reports 0 failures; `FEATURE/evidence/regression-testing/isolation-shuffled.<timestamp>.md` records each seed, its file order, and its counts. An order dependence is fixed on both sides and every seed is re-run.
- [ ] [P7-T6] Fresh single-process Pester run with coverage over `tests/scripts` through `Invoke-PoshQCTest` (the CI shape).
  - Acceptance: 0 errors; every failing test name, if any, is listed as failing in the [P0-T8] baseline and none is under `T`; `FEATURE/evidence/regression-testing/isolation-single-process.<timestamp>.md` records the counts, the comparison, and the overall line coverage. CI: `poshqc / PowerShell QC` (Windows shards).
- [ ] [P7-T7] Record the coverage delta.
  - Acceptance: `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md` records the baseline overall line coverage ([P0-T8]), the post-change overall line coverage ([P7-T6]), the 1020 module figures before and after, and the per-file coverage of each new module ([P7-T3]), each new figure at least 85; a value below its floor is recorded as remediation-required, not PASS. No branch figure is recorded.
- [ ] [P7-T8] Prove the scope: run `git diff --name-only MERGE_BASE HEAD` and `git status --porcelain --untracked-files=all`.
  - Acceptance: neither listing contains a path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs`, or `.cjs`, or a path under `packages/discovery-runtime/`, `schemas/discovery/`, or `.claude/lib/discovery-validation/`; every listed path outside `FEATURE/` and the [P0-T5] listing appears in `## Artifact Classification`; `FEATURE/evidence/qa-gates/qa-scope.<timestamp>.md` records both listings.
- [ ] [P7-T9] Check test hygiene and file size: a case-insensitive fixed-string `grep -r` (files may be untracked) over `tests/scripts/claude-lib/docs` for each of `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, and `$env:TEMP`, restricted to the files this feature adds or edits; and the logical line count (`@(Get-Content -LiteralPath <path>).Count`) of each new production module under `L`.
  - Acceptance: zero matches for each token; every new production module has at most 500 logical lines; `FEATURE/evidence/qa-gates/qa-hygiene-and-size.<timestamp>.md` records the match counts and per-file line counts.
- [ ] [P7-T10] Scan for the two restricted consumer tokens: over the union of the [P7-T8] listings, a case-insensitive extended-regex `grep` with the patterns `r[g]f` and `fore[c]ast`, each passed through `-e`.
  - Acceptance: zero matches; `FEATURE/evidence/qa-gates/qa-token-scan.<timestamp>.md` records the file count, the two bracket-class patterns, and the match count, never the tokens themselves.
- [ ] [P7-T11] (CI-dependent) After the branch is pushed, read the head-commit conclusions from a `ci.yml` run (pull-request run, or a manual `workflow_dispatch` of `ci.yml` on the branch when none exists, per `execution-environment` `## CI Shape and Required Checks`).
  - Acceptance: `CI full run`, `poshqc / PowerShell QC`, and `quality-checks7 / Code Quality & Tests (3.10)`, `(3.11)`, `(3.12)`, `(3.13)` conclude `success`; `FEATURE/evidence/qa-gates/qa-ci-checks.<timestamp>.md` records the run identifier, the head commit, and each conclusion.
- [ ] [P7-T12] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff from `MERGE_BASE`, every AC of `spec.md` and `user-story.md`, the [P0-T4] reconciliation, and `## Design Constraints From Existing Tests`.
  - Acceptance: `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL, or N/A row per checklist item and per AC. A FAIL row is fixed, the loop is re-run from [P7-T1], and the self-review is rewritten; the plan does not complete with a FAIL row.

## Acceptance Criteria Traceability

Spec ACs are S1..S22 and user-story ACs U1..U12 in document order.

| AC | Tasks | Proving tests or evidence |
|---|---|---|
| S1 (tokenizers) | P2-T1..P2-T3 | `DocsTypeScriptTokens.Tests.ps1`, `DocsTypeScriptJsx.Tests.ps1` (if split), `DocsCSharpTokens.Tests.ps1` |
| S2, U1 (typescript-cli) | P3-T1 | `DocsAnalyzerTypeScriptCli.Tests.ps1` |
| S3, U1 (typescript-http) | P3-T2 | `DocsAnalyzerTypeScriptHttp.Tests.ps1` |
| S4, U1 (typescript-exports) | P3-T3 | `DocsAnalyzerTypeScriptExports.Tests.ps1` |
| S5, U1 (dotnet-http) | P4-T1 | `DocsAnalyzerDotnetHttp.Tests.ps1` |
| S6, U1, U6 (dotnet-config, no values) | P4-T2 | `DocsAnalyzerDotnetConfig.Tests.ps1` |
| S7, U1 (dotnet-public-api) | P4-T3 | `DocsAnalyzerDotnetApi.Tests.ps1` |
| S8, U2, U6 (import merge) | P1-T1, P5-T2 | `DocsAnalyzerExtensionImport.Tests.ps1` |
| S9, U2 (import rejection) | P5-T1, P5-T2 | `DocsAnalyzerExtensionImport.Tests.ps1` |
| S10, U3 (determinism) | P6-T3 | `DocsScannerContract.Tests.ps1` |
| S11, U4 (bounds) | P6-T3 | `DocsScannerContract.Tests.ps1` |
| S12, U4, U8 (precision-limit emission) | P6-T4 | `DocsScannerContract.Tests.ps1` |
| S13, U5 (analysis method, digest) | P1-T2, P6-T4 | `DocsScannerContract.Tests.ps1`, `DocsScannerCommon.Tests.ps1` |
| S14, U7 (registry rows) | P6-T1 | `DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1` |
| S15, U7 (1020 registry suite) | P6-T2 | `DocsAnalyzerRegistry.Tests.ps1` |
| S16, U8 (precision-limit table) | P1-T2 | `DocsScannerCommon.Tests.ps1`, spec `## Scanner Precision Limit` |
| S17, U9 (push-down) | P6-T5..P6-T8 | `Docs.Manifest.Tests.ps1`, `p6-pushdown-contracts` |
| S18 (conventions, 500 lines) | P6-T7, P7-T9 | `ClaudeLibModuleConvention.Tests.ps1`, `qa-hygiene-and-size` |
| S19, U10 (no Python or TypeScript) | P7-T8 | `qa-scope`, `## Artifact Classification` |
| S20, U11 (no temporary files) | P1-T1, P7-T9 | `qa-hygiene-and-size` |
| S21, U11 (coverage) | P7-T3, P7-T7 | `qa-pester-coverage`, `coverage-delta` |
| S22, U12 (CI) | P7-T11 | `qa-ci-checks` |

## Pre-Mortem

- Review checklists: a reviewer flags a consumed 1020 symbol whose name diverges from the merged amendment, a dynamic `&` call, a non-literal `$PSScriptRoot` join, a guessed element, or a configuration value in output. Prevented by [P0-T3] and [P0-T4] (names fixed before any module is written), the static-call and registry-import design in `## Design Constraints From Existing Tests`, one fixture per diagnostic code, value-absence assertions in [P4-T2] and [P5-T2], the scanning suites in [P6-T7], and the template walk in [P7-T12].
- Coverage: tokenizer error paths, JSX states, and rejection steps could leave a module below 85%. Prevented by one test per lexical state, bound, and code; per-file figures read from `artifacts/pester/powershell-coverage.xml` in [P7-T3] and [P7-T7]; no production file excluded; no branch gate for Pester.
- Mirror parity: a module edited after its copy, or a path missing from `core.json`, fails `Docs.Manifest.Tests.ps1` or the push-down contract tests. Prevented by [P6-T5] and [P6-T6] after the last code edit, a re-copy on any formatter or analyzer fix ([P7-T1], [P7-T2]), and [P6-T7], [P6-T8], [P7-T4]. The plan changes no fact stated in the execution-environment brief (no CI job, required context, tool route, or batch-budget rule), so no brief-update task is needed.
- File size: the TypeScript tokenizer, the TypeScript HTTP analyzer, and the .NET API analyzer are the largest candidates. Prevented by the shared helper module, the conditional JSX split in [P2-T2], line counts recorded in [P2-T1], [P3-T2], [P4-T3], the split rule in `## Design Constraints From Existing Tests`, and [P7-T9].
- Test isolation: suites import `Docs*` and `DiscoveryEncoding` modules with `-Force`, and the registry seam imports analyzers, so state can leak across suites. Prevented by `AfterAll` removal of those modules in every suite, no module-scope cache, seeded shuffled file-order runs of the touched Pester suites with three seeds (1033, 20261030, 7) with each seed and order recorded ([P7-T5]), and a fresh single-process run over `tests/scripts` ([P7-T6]). The seeded Jest shuffle and reversed-order Python run are not applicable: no TypeScript or Python test changes.
- CI-only behavior: `.gitattributes` normalizes committed CRLF to LF, and the shards run on `windows-latest`. Prevented by building CRLF, BOM, oversize, and undecodable inputs in code ([P1-T1]), reading no gitignored `artifacts/` state in tests, using no clock, and reading CI results in [P7-T11].
- Evidence: a figure taken from a PoshQC MCP result, a non-canonical path, a plan-time stamp, a host path, or a restricted token fails review. Prevented by counts from the JUnit file and coverage from the PoshQC XML, write-time `<timestamp>` names under `FEATURE/evidence/<kind>/`, the `evidence/coverage/` override recorded in `## Execution Context`, `SCRATCH` tokens only, and the bracket-class scan in [P7-T10].

## Size Justification

- The plan has 42 tasks, above the 40-task guideline (it stays under 400 lines), because the feature creates ten or eleven production modules, each with its own suite and evidence, two contract suites, a registry edit with an existing-test update, the bundle mirror and manifest edit, and the owner-required upstream contract gate and reconciliation tasks; merging module tasks would bundle several binary outcomes into one task.

## Open Questions / Notes

- The epic's `### 900004 - docs-surface-analyzers-typescript-dotnet (wave 1, C4)` names `DocsExtensionImport.psm1`; this plan uses `DocsAnalyzerExtensionImport.psm1` (spec `## Behavior`, module name refinement) because 1020's registration rules reject the epic name. The coordinator records the refinement in the epic; this feature does not edit the epic.
- `DocsAnalyzerRegistry.psm1`, its bundle copy, and `core.json` are shared append points with 1022 and 900011; a conflict is resolved in this feature's remediation loop.
- Spec `## Implementation Strategy` recommends mirroring each module in its own task; this plan mirrors once in [P6-T5] after the last code edit so that one copy step and one digest record cover every file, and re-copies on any later fix.
