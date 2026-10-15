# Research: duplicated string comparators outside pr-context (Issue #796)

- Issue: #796 (bug, work mode full-bug)
- Branch: `bug/duplicated-string-comparators-outside-pr-context-796` (base `origin/main` `e7d3779b`, includes PR #839)
- Timestamp: 2026-10-08T21-30
- Requirements sources: `issue.md` in this folder; the issue #796 comment (2026-10-08T07:40:06Z, drmoisan), read through the GitHub REST API (`/repos/drmoisan/drm-copilot/issues/796/comments`) because `gh` was not available to this agent.
- All line numbers below were read from the working tree at the base commit.

## Operator Decision (fixed, not re-opened)

The single shared comparator uses Unicode code-point ordering, matching `compareCodePoint` in `extensions/drm-copilot/src/lib/pr-context/models.ts` after PR #839. The existing copies use UTF-16 code-unit ordering (`left < right ? -1 : left > right ? 1 : 0`). Observable order changes only when the first differing position compares a supplementary character (U+10000+) against a BMP character in U+E000..U+FFFF.

Consequence for the issue body: the issue's "Proposed Fix" bullets "keeping the existing sort order" and "existing golden or parity suites must pass without modification" remain satisfiable for all committed test data (section 5), but the comparator contract itself changes for the supplementary-vs-U+E000..U+FFFF case. The spec should state this as an intended behavior change, not as "no behavior change".

## 1. Complete Inventory

Scope: `extensions/drm-copilot/src/**` outside `src/lib/pr-context/`. Family: every named comparator definition and every inline comparator expression that orders strings with the relational operators `<`/`>` (any whitespace, parenthesization, line-wrapping, or operand naming), including the `!==`-guarded two-way form. Comparators over numbers, `localeCompare` callbacks, and argument-less `.sort()` calls are excluded (see Exclusions).

### 1.1 Named comparator definitions (6)

| ID | Location | Name / form | Call sites |
|---|---|---|---|
| N1 | `src/lib/codex-native-converter/engine-pipeline.ts:46-48` | `compareStrings` (module-private) | 88, 148, 183, 201, 243, 247, 251, 304 |
| N2 | `src/lib/codex-native-converter/reporting-render.ts:36-38` | `compareStrings` (module-private) | 71, 74, 78, 81, 85, 89, 93, 188, 192, 199 |
| N3 | `src/lib/codex-native-converter/reporting.ts:148-149` | local arrow `compare` in `sortFindings` | 151, 155, 159 |
| N4 | `src/lib/codex-native-converter/validation.ts:359-360` | local arrow `compare` in `validateConversionPlan` | 362, 366, 370 |
| N5 | `src/lib/push-down/claude-blast-radius-derive-manifests.ts:121-123` | `compareOrdinal` (exported) | manifests:199; `claude-blast-radius-derive-core.ts:249, 276` (import at :49); `claude-blast-radius-overlay.ts:200` (import at :29) |
| N6 | `src/lib/subagent-tree/tree-assembler.ts:97-105` | `compareByAgentId` (if/if/return form over `a.meta.agentId`) | 63, 124 |

### 1.2 Inline full-ternary copies (16)

| ID | Location (expression line) | Operands |
|---|---|---|
| I1 | `codex-native-converter/intermediate-state.ts:53` | `left`/`right` (object keys in `sortKeysDeep`) |
| I2 | `codex-native-converter/inventory.ts:168-170` (169) | `normalizeSelectedPaths` |
| I3 | `codex-native-converter/inventory.ts:238-240` (239) | `iterSupportedArtifacts` |
| I4 | `codex-native-converter/inventory.ts:293-295` (294) | `discoverSourceArtifacts` |
| I5 | `codex-native-converter/models.ts:258-260` (259) | frontmatter keys in `sourceArtifactToJson` |
| I6 | `codex-native-converter/pipeline.ts:57` | `left[1]`/`right[1]` string tiebreak after numeric position (line 55) |
| I7 | `codex-native-converter/pipeline.ts:93` | `knownDestinationPaths` |
| I8 | `codex-native-converter/reporting.ts:54` | object keys in `sortKeysDeep` |
| I9 | `codex-native-converter/reporting.ts:130-136` (131-135) | `left.sourcePath` (line-wrapped variant in `sortBySourcePath`) |
| I10 | `codex-native-converter/reporting.ts:229-231` (230) | proposed-tree target paths |
| I11 | `codex-native-converter/validation.ts:268-270` (269) | `conflictingTargets` |
| I12 | `push-down/filesystem-adapter.ts:141-143` (142) | `RealPushDownFileSystem.listFiles` result |
| I13 | `push-down/claude-blast-radius-derive.ts:125-127` (126) | `left.name` in `realDirectoryLister` |
| I14 | `push-down/copilot-customizations-engine.ts:170` | `leftRel`/`rightRel` in `enumerateSourceFiles` |
| I15 | `push-down/copilot-customizations-engine.ts:289-292` (291) | `leftKey`/`rightKey` in `stringifySorted` |
| I16 | `subagent-tree/quick-pick-labels.ts:132` | `left.path` tiebreak in `compareCandidates` (numeric part at 121-130 is out of scope) |

### 1.3 Guarded two-way variants (2)

| ID | Location | Form |
|---|---|---|
| G1 | `codex-native-converter/pipeline.ts:146-154` | `if (a.k !== b.k) return a.k < b.k ? -1 : 1;` for `sourcePath` (148), `destinationPath` (151) |
| G2 | `codex-native-converter/pipeline-traces.ts:110-121` | same form for `sourcePath` (112), `sectionId` (115), `targetRole` (118) |

Each G-form key comparison is equivalent to the ternary comparator on that key (for unequal keys it returns the same sign; equal keys fall through, matching a 0 result).

### 1.4 Corrections to the issue body and comment

- All issue-body line numbers outside `pr-context/` are confirmed: engine-pipeline.ts:46, reporting-render.ts:36, reporting.ts:148, validation.ts:359, derive-manifests.ts:121, intermediate-state.ts:53, inventory.ts:169/239/294, models.ts:259, pipeline.ts:93, reporting.ts:54/230, validation.ts:269, filesystem-adapter.ts:142.
- `pr-context/models.ts:340` is stale: after PR #839, `compareCodePoint` is at `models.ts:355` (doc comment 344-354).
- Comment correction: `compareByAgentId` spans `tree-assembler.ts:97-105` (the comment says 97-104; line 105 is the closing brace). The path tiebreak is at `quick-pick-labels.ts:132` (the comment says 131; line 131 closes the numeric branch).
- Not listed by the issue or comment, but in the family: I6 (pipeline.ts:57), I9 (reporting.ts:130-136), I13 (claude-blast-radius-derive.ts:126), I14 (copilot-customizations-engine.ts:170), I15 (copilot-customizations-engine.ts:291), G1 (pipeline.ts:146-154), G2 (pipeline-traces.ts:110-121). The issue's literal `git grep` misses these because their operands are not named `left`/`right` or the expression is wrapped or guarded.
- The "12 files" in the issue snippet is the count for the literal grep only; the full family spans 15 files outside pr-context (codex-native-converter: 9; push-down: 4; subagent-tree: 2).

### 1.5 Exclusions (verified, out of scope)

- Numeric comparators: `pipeline.ts:55`; `tree-assembler.ts:121-123`; `quick-pick-labels.ts:123-130`; `validate/parallel-state-shared.ts:413`; `validate/parallel-state-structures.ts:278-279, 288-289, 461-462`; `pr-context/summary-helpers.ts:278-279`.
- `localeCompare` (locale-sensitive, different contract): `src/poshqc-scan-config.ts:188`, `src/pr-context-branches.ts:100, 177`, `src/poshqc-folder-picker.ts:123`, `src/lib/file-system.ts:310`, `src/lib/new-active-feature-folder/io.ts:124`, `src/lib/validate/orchestration-handoff-contract.ts:352`, `src/lib/validate/orchestration-handoff-materializer-support.ts:76`.
- Argument-less `.sort()` (default UTF-16 code-unit order, no comparator copy) in the in-scope subsystems: `subagent-tree/tree-assembler.ts:186`, `subagent-tree/tree-formatter.ts:29`, `push-down/claude-pack-selection.ts:117, 299`, `push-down/codex-pack-selection.ts:66, 71, 100, 108, 232`; plus seven sites under `validate/` and `resolve/`. These sort ASCII identifiers in practice. They are not comparator duplicates and are recommended as a separate follow-up if code-point order is wanted repository-wide.

## 2. `compareCodePoint` Today

- Definition: `extensions/drm-copilot/src/lib/pr-context/models.ts:355-368`. Doc comment 344-354 states: compare by Unicode code point, matching Python `str` comparison; differs from `<` (UTF-16 code units) where a surrogate pair sorts before U+E000..U+FFFF under `<` but after it here; locate the first differing UTF-16 code unit and compare `codePointAt` at that index; proper prefix sorts first; returns exactly -1, 0, or 1.
- Implementation: loop over `Math.min(left.length, right.length)` comparing `charCodeAt`; at the first difference return `codePointAt(index)` comparison as -1/1; otherwise compare lengths (equal gives 0).
- Export surface: named export from `pr-context/models.ts` only. Module header (models.ts:19-21) lists it among shared pr-context helpers. `models.ts` imports only `../subprocess-runner` (type-only, line 26).
- Barrel: `src/lib/pr-context/index.ts:12-32` re-exports selected `models` members; `compareCodePoint` and `sortedSet` are not among them. No other `index.ts` under `src/` exports `compareCodePoint` or `compareOrdinal`. `jest.config.cjs:407-411` records that no module imports the pr-context barrel. There are no external callers to preserve.
- Importers (7 production files, all inside pr-context): `verification-evidence.ts:23` (use :105); `feature-docs.ts:23` (:103, :310); `feature-docs-parsers.ts:20` (:182, :278); `render-pr-helpers.ts:20` (:153, :204); `render-feature-excerpts.ts:21` (:365); `collector-core.ts:22` (:201-203); `autoclose.ts:26` (:210, :214). Internal use: `models.ts:379` (`sortedSet`).
- Tests: `extensions/drm-copilot/test/lib/pr-context/models.test.ts` (486 lines):
  - `describe("compareCodePoint")` 153-177: identical strings, a<b, b>a, empty first, case-sensitive, prefix first.
  - `describe("compareCodePoint - enumerative properties over a fixed domain")` 179-273: reflexive, antisymmetric, transitive, returns only -1/0/1 over an 11-value domain including U+1F600, U+E000, U+FFFF.
  - `describe("compareCodePoint issue #740 code-point order")` 275-372: D1-D4, S1, A1-A4.
- `compareOrdinal` has no direct test importer (grep across `extensions/` found only production references).

Recommendation on re-export: do not re-export. Move the definition to the shared module and change the seven pr-context importers plus `models.ts` (for `sortedSet`) to import from `../string-ordering`. Rationale: there is no barrel or external consumer, the importer edits are single import-line changes, and a re-export would leave two import paths for one symbol, which is the drift pattern this issue removes. Update the `models.ts` header (lines 19-21) to drop `compareCodePoint`.

## 3. Shared-Module Location

- No dependency-cruiser configuration exists (`**/.dependency-cruiser*` returns no files). `extensions/drm-copilot/eslint.config.mjs` applies only `eslint` and `typescript-eslint` recommended rule sets, with no `no-restricted-imports` or boundary rule. The #740 evidence `evidence/qa-gates/ts-architecture.2026-10-08T02-38.md` recorded the architecture stage as "NOT APPLICABLE" for the same reason.
- The only boundary test touching a consumer is `test/lib/subagent-tree/module-boundary.test.ts:23-39`, whose rule is: "src/lib/subagent-tree pure-module boundary ... contains no `vscode` import statements in any source file" (pattern `from\s+["']vscode["']|require\(\s*["']vscode["']\s*\)`). A dependency-free module imported from `../string-ordering` does not violate it.
- Precedent: `src/lib/` root already holds subsystem-neutral modules imported by three of the four consumers, for example `../file-system` from `codex-native-converter/engine-pipeline.ts:18`, `pr-context/collector-core.ts:19`, and `subagent-tree/index.ts:1`. `push-down/` currently imports no `src/lib/` root module, but it already imports upward to `src/` root modules (`push-down/push-down-service-call.ts:19-20`), and no rule restricts it from importing `../string-ordering`. No module under `pr-context/`, `push-down/`, or `codex-native-converter/` imports another of those subsystems (#740 research section 1.5), so placing the comparator in `pr-context/` would create the first cross-subsystem edge.

Recommended path: `extensions/drm-copilot/src/lib/string-ordering.ts`, exporting `compareCodePoint(left: string, right: string): number`, with no imports. Keeping the name `compareCodePoint` preserves the contract name established by #716/#740 and limits pr-context edits to import paths. Cycle risk: none, because the module imports nothing.

## 4. Test Layout and Gates

- Test root for this extension is `extensions/drm-copilot/test/` (not `tests/`): `jest.config.cjs:4` `testMatch: ["**/test/**/*.test.ts"]`. Mirrored path for the new module: `extensions/drm-copilot/test/lib/string-ordering.test.ts` (precedent: `test/lib/markdown-label-formatter.test.ts`, `test/lib/file-system.test.ts`).
- Coverage: `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` (jest.config.cjs:17); thresholds are per-file only with no `global` key (20-24). A new production file without an entry is ungated (comments at 106-108, 294-296), so `"./src/lib/string-ordering.ts": { lines: 85, branches: 75 }` must be added.
- Changed files that already have per-file entries: pr-context `collector-core.ts`, `collector-output.ts`, `autoclose.ts`, `models.ts`, `feature-docs-parsers.ts`, `render-feature-excerpts.ts`, `render-pr-helpers.ts`, `verification-evidence.ts`; push-down `claude-blast-radius-derive-core.ts`, `claude-blast-radius-derive-manifests.ts`, `claude-blast-radius-overlay.ts`, `copilot-customizations-engine.ts`; subagent-tree `tree-assembler.ts`, `quick-pick-labels.ts`.
- Changed files without entries: all nine codex-native-converter files (`engine-pipeline.ts`, `reporting-render.ts`, `reporting.ts`, `validation.ts`, `intermediate-state.ts`, `inventory.ts`, `models.ts`, `pipeline.ts`, `pipeline-traces.ts`), push-down `filesystem-adapter.ts` and `claude-blast-radius-derive.ts`, and pr-context `feature-docs.ts`. #740 added entries for changed files lacking one (jest.config.cjs:67-81). Whether those 12 files currently meet 85/75 is not verified here (coverage was not executed); the plan should capture a baseline before deciding to add entries.
- Property-based tests: `fast-check` is not a declared dependency (`package.json` devDependencies; the only `package-lock.json` hit is a funding URL). `quality-tiers.yml:7-9` classifies `extensions/drm-copilot` as T3, for which property-test density is "none". The repository convention for this comparator is the enumerative fixed-domain property block in `models.test.ts:179-273`; reuse it in the new test file.
- Existing tests per affected module: codex-native-converter `test/lib/codex-native-converter/{engine,reporting,validation,inventory,intermediate-state,models,pipeline}.test.ts` (no test file for `engine-pipeline.ts`, `reporting-render.ts`, `pipeline-traces.ts`; they are exercised through engine/reporting/pipeline tests); push-down `blast-radius-derive-manifests.test.ts` (183 lines), `blast-radius-derive-core.test.ts`, `blast-radius-derive.test.ts` (484), `claude-blast-radius-overlay.test.ts` (448), `claude-blast-radius-overlay-parity.test.ts`, `filesystem-adapter.test.ts` (212), `copilot-customizations-engine.test.ts` (244); subagent-tree `tree-assembler.test.ts` (167), `quick-pick-labels.test.ts` (206); pr-context `models.test.ts` (486), `collector-output.test.ts` (485).
- File-size constraint: `models.test.ts`, `collector-output.test.ts`, `blast-radius-derive.test.ts`, and `claude-blast-radius-overlay.test.ts` are within 52 lines of the 500-line cap; consumer regression tests should go in smaller files (see section 8).

## 5. Output-Stability Risk

- Search: the regex `[\x{E000}-\x{FFFF}\x{10000}-\x{10FFFF}]|\\u\{1[0-9A-Fa-f]{4}\}|\\u[EeFf][0-9A-Fa-f]{3}|\\u[Dd][89A-Fa-f][0-9A-Fa-f]{2}` (literal characters and escape spellings) was validated against `test/lib/pr-context/models.test.ts` (20 hits) and then run over:
  - `extensions/drm-copilot/test/` in full: hits only in `pr-context/models.test.ts` (20), `push-down/claude-exclusion-manifest.test.ts` (2: `﻿` BOM at :102, `�` at :158), and `subprocess-runner.test.ts` (1). None of these exercise an in-scope comparator (`claude-exclusion-manifest.ts`/`claude-exclusion-filter.ts` contain no sort or compare call), and a lone U+FEFF/U+FFFD only changes order against a supplementary character, which those tests do not contain.
  - `tests/fixtures/blast_radius_overlay/` (6 corpus files used by `claude-blast-radius-overlay-parity.test.ts`), `tests/fixtures/codex_native_converter/` (15 files), `tests/fixtures/push_down/`, `tests/fixtures/push_down_exclusions/`: no hits.
- No Jest snapshot or golden suite exists in the affected test directories (`toMatchSnapshot|toMatchInlineSnapshot|golden` returned no matches). `engine.test.ts:20` holds inline content mirroring `tests/fixtures/codex_native_converter/github_copilot`, which has no hits.
- Conclusion: no committed expected output depends on the supplementary-vs-U+E000..U+FFFF case; existing suites are expected to pass unchanged. This is derived from the search, not from executing the suites.

Cross-language twins (all verified by reading the sort call):

| TS site | Twin | Twin order |
|---|---|---|
| overlay `composeModules` (N5 use at overlay:200) | `scripts/dev_tools/push_down_claude_blast_radius_overlay.py:188` `sorted(merged)`; shared corpus `tests/fixtures/blast_radius_overlay/` asserted by `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py` | Python `str`: code point |
| derive-manifests :199, derive-core :249/:276, derive.ts :126 | `push_down_claude_blast_radius_derive_manifests.py:236`, `..._derive_core.py:142, 156`, `..._derive.py:94` | code point |
| filesystem-adapter :142; copilot-customizations-engine :170 | `push_down_copilot_customizations_filesystem.py:107` `sorted(files)`; `push_down_copilot_customizations.py:176` | code point |
| copilot-customizations-engine :291 `stringifySorted` | `json.dumps(..., sort_keys=True)` (doc comment at :276) | code point |
| codex-native-converter (all sites) | `scripts/dev_tools/codex_native_converter/{engine,inventory,pipeline,_pipeline_traces,reporting,validation,intermediate_state}.py` `sorted(...)` / `sort_keys=True` | code point |
| pr-context `collector-output.ts:112-118` | `scripts/dev_tools/pr_context/collector_documents.py:97` `sorted(..., key=lambda item: item.source_file)` | code point |
| subagent-tree (N6, I16) | none found (no `subagent_tree`/`agentToolUseIds` match under `scripts/`, `.claude/lib/`, `.claude/hooks/`, `.codex/`) | n/a |

No bash or PowerShell twin of the derive, overlay, or converter ordering exists (no manifest-vocabulary match under `.claude/lib/` or `.claude/hooks/`). Every TypeScript site with a twin currently disagrees with its Python twin on the supplementary-vs-U+E000..U+FFFF case; the change brings them into agreement.

## 6. Bundled Mirrors

- No `.ts` file exists under `extensions/drm-copilot/resources/**`.
- A repository-wide search for `compareStrings|compareOrdinal|compareCodePoint|compareByAgentId|compareCandidates` outside `src/`, `test/`, and `docs/` found only `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json:766`, which is issue text in a blast-radius corpus, not code.
- `packages/mcp-server` commits only `esbuild-mcp-server.cjs` and `prepack.cjs`; bundles are build outputs, not committed mirrors.
- Conclusion: no bundled or mirrored copy must change together with these files.

## 7. Coordination with #740 (PR #839)

- #839 consolidated, inside `pr-context/`, the helpers `sortedSet`, `escapeRegExp`, `splitLines` (models.ts) and `relativeToPosix` (feature-docs-parsers.ts:305), and changed `compareCodePoint` to code-point order (evidence `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/evidence/qa-gates/helper-definitions.2026-10-08T02-38.md` and `models-doc-and-imports.2026-10-08T02-38.md`). Plan decision D3 left the inline `sortedSet` equivalents in `feature-docs.ts:309-311` and `autoclose.ts:210` unchanged; both already use `compareCodePoint`, so they are not comparator duplicates.
- Residual duplicate inside pr-context: `src/lib/pr-context/collector-output.ts:112-118` (`renderVerificationEvidenceSection`, exported at :73) sorts `parseableRecords` with the line-wrapped UTF-16 ternary on `sourceFile`. #839 did not touch it, and it is the only remaining relational-operator string comparator in `pr-context/` (other `? -1` hits there are `models.ts:361, 367` inside `compareCodePoint`). It is outside the issue's stated "outside pr-context" scope but inside the objective "one shared comparator". Recommendation: include it (one-line change; Python twin already uses code point; `collector-output.ts` has a per-file threshold entry).

## Numeric Derivation Evidence

Numeric claim A: the family outside pr-context has 24 comparator sites (6 named, 16 inline, 2 guarded) in 15 files.

- Complete Family: named comparator definitions and inline comparator expressions that order strings with `<`/`>` in `extensions/drm-copilot/src/**`, excluding `src/lib/pr-context/`.
- Exhaustive Search Scope: every `.ts` file under `extensions/drm-copilot/src/` (including `src/` root files outside `lib/`).
- Inclusion Rules: a site is a definition (named function/arrow) or an inline expression in a sort callback that returns -1/1 based on `<`/`>` over string operands; line-wrapped and `!==`-guarded forms included; a named comparator counts once regardless of call-site count.
- Exclusion Rules: numeric operands; `localeCompare`; argument-less `.sort()`; call sites of a named comparator; anything under `src/lib/pr-context/`.
- Primary Search Strategy or Query Expression: ripgrep `(\?\s*1\s*:\s*-1|return\s+-1|\?\s*-1\b)` over `extensions/drm-copilot/src`, plus multiline `if\s*\([^()]*\s<\s[^()]*\)\s*\{?\s*return\s+-1`; each hit opened and classified.
- Primary Member Set: N1 engine-pipeline:47; N2 reporting-render:37; N3 reporting:149; N4 validation:360; N5 derive-manifests:122; N6 tree-assembler:98-99; I1 intermediate-state:53; I2 inventory:169; I3 inventory:239; I4 inventory:294; I5 models:259; I6 pipeline:57; I7 pipeline:93; I8 reporting:54; I9 reporting:132; I10 reporting:230; I11 validation:269; I12 filesystem-adapter:142; I13 derive:126; I14 copilot-customizations-engine:170; I15 copilot-customizations-engine:291; I16 quick-pick-labels:132; G1 pipeline:148,151; G2 pipeline-traces:112,115,118.
- Primary Count: 24.
- Cross-check Search Strategy or Query Expression: ripgrep `\.sort\(|\.toSorted\(` over `extensions/drm-copilot/src` (every sort call site), each comparator argument resolved to its definition or inline body; plus ripgrep `\s>\s[\w.\[\]"']+\s*\?\s*1\b|\s>\s[\w.\[\]"']+\s*$` over `src/lib` to catch the `>` half of wrapped ternaries.
- Cross-check Member Set: intermediate-state:52 -> I1; engine-pipeline:87,147,183,200,242,304 -> N1; inventory:168,238,293 -> I2,I3,I4; models:258 -> I5; reporting-render:70,73,80,187 -> N2; pipeline-traces:110 -> G2; pipeline:53 -> I6, :93 -> I7, :146 -> G1; reporting:53 -> I8, :130 -> I9, :150 -> N3, :229 -> I10; validation:268 -> I11, :361 -> N4; derive-core:249,276, overlay:200, derive-manifests:199 -> N5; derive:125 -> I13; filesystem-adapter:141 -> I12; copilot-customizations-engine:167 -> I14, :289 -> I15; quick-pick-labels:101 -> `compareCandidates` -> I16; tree-assembler:63,118 -> N6. The `>`-half query independently returned the expression lines of I2-I7, I9 (:133), I10-I15, N1-N5 and I16, and no additional string site outside pr-context.
- Cross-check Count: 24.
- Member-set Comparison: normalized sets {N1-N6, I1-I16, G1, G2} are identical in both records; no duplicates; no member present in only one record. Assertion supported.

Numeric claim B: one residual relational string comparator remains inside `src/lib/pr-context/` (`collector-output.ts:112-118`).

- Complete Family: same as claim A, restricted to `src/lib/pr-context/`, excluding the body of `compareCodePoint` itself.
- Exhaustive Search Scope: every `.ts` file under `extensions/drm-copilot/src/lib/pr-context/`.
- Inclusion Rules / Exclusion Rules: as in claim A; `models.ts:361, 367` (inside `compareCodePoint`) and numeric `summary-helpers.ts:278-279` excluded.
- Primary Search Strategy or Query Expression: the claim A primary query, filtered to `pr-context/`.
- Primary Member Set: collector-output.ts:114.
- Primary Count: 1.
- Cross-check Search Strategy or Query Expression: the claim A `.sort(` enumeration filtered to `pr-context/`, each argument resolved.
- Cross-check Member Set: collector-output.ts:112 (inline ternary); collector-core:201-203, autoclose:210,214, feature-docs-parsers:182,277, feature-docs:103,309, models:379, render-feature-excerpts:365, render-pr-helpers:153,204, verification-evidence:105 -> `compareCodePoint` (not members); summary-helpers:278 -> numeric (not a member).
- Cross-check Count: 1.
- Member-set Comparison: both records name only `collector-output.ts:112-118`. Assertion supported.

## Candidate Approaches

1. Selected: new dependency-free module `src/lib/string-ordering.ts` exporting `compareCodePoint` (moved verbatim from pr-context/models.ts), all consumers import it directly, tests moved to `test/lib/string-ordering.test.ts`. Advantages: one definition and one test suite; no cross-subsystem coupling; matches `src/lib/` neutral-module precedent; no barrel to maintain. Limitation: touches 7 pr-context files for import-path changes only.
2. Rejected: keep `compareCodePoint` in `pr-context/models.ts` and import it from converter, push-down, and subagent-tree. Creates the first cross-subsystem dependency into pr-context, which the issue explicitly warns against.
3. Rejected: new module plus a re-export from `pr-context/models.ts`. Smaller diff, but leaves two import paths for one symbol with no external consumer to justify it.
4. Rejected: keep `compareOrdinal` name and rename pr-context usages. Discards the established contract name and enlarges the diff.

## Behavior Semantics

- Contract: `compareCodePoint(left, right)` returns exactly -1, 0, or 1; 0 iff the strings are identical; a proper prefix sorts first; otherwise the order of the code points at the first differing UTF-16 index.
- Observable change versus current copies: only when the first differing position compares a supplementary character with a BMP character in U+E000..U+FFFF. All other inputs, including all ASCII and all BMP below U+D800, produce the same sign.
- Wrapper functions that project a key (`compareByAgentId`, `compareCandidates`, `sortBySourcePath`, `sortFindings`, multi-key chains) remain; only their string-comparison core delegates to `compareCodePoint`. `compareByAgentId` becomes `return compareCodePoint(a.meta.agentId, b.meta.agentId);`.
- Multi-key chains keep their key order (for example code, sourcePath, targetPath with `?? ""`).

## Recommended Implementation Approach

1. Create `extensions/drm-copilot/src/lib/string-ordering.ts` with `compareCodePoint` and its doc comment moved from `pr-context/models.ts:344-368`; add a module header stating it is the single ordinal string comparator for the extension (#796).
2. `pr-context/models.ts`: remove the definition, import `compareCodePoint` from `../string-ordering` for `sortedSet`, update header lines 19-21.
3. Change the import of `compareCodePoint` to `../string-ordering` in `verification-evidence.ts`, `feature-docs.ts`, `feature-docs-parsers.ts`, `render-pr-helpers.ts`, `render-feature-excerpts.ts`, `collector-core.ts`, `autoclose.ts`.
4. `pr-context/collector-output.ts:112-118`: replace the ternary with `compareCodePoint(left.sourceFile, right.sourceFile)`.
5. codex-native-converter: delete N1-N4; replace I1-I11, G1, G2 with `compareCodePoint`; add the import to each of the nine files.
6. push-down: delete `compareOrdinal` (N5) and import `compareCodePoint` in `claude-blast-radius-derive-manifests.ts`, `claude-blast-radius-derive-core.ts` (replace the `compareOrdinal` import at :49), `claude-blast-radius-overlay.ts` (:29); replace I12-I15. Removing the exported `compareOrdinal` is a breaking change to an in-repo-only symbol; all in-repo callers are updated in the same change.
7. subagent-tree: N6 and I16 delegate to `compareCodePoint`.
8. Tests: move the three `compareCodePoint` describe blocks from `test/lib/pr-context/models.test.ts:153-372` to `test/lib/string-ordering.test.ts` with the import changed; keep `sortedSet` tests in `models.test.ts`.
9. `jest.config.cjs`: add the `string-ordering.ts` entry; add entries for changed files lacking one if the baseline shows they meet 85/75.
10. Structural gate: after the change, the claim A primary query restricted to `src/lib` should return only the two `return ... ? -1 : 1` lines inside `string-ordering.ts` (plus the excluded numeric/other lines enumerated in 1.5).

## Testing Implications

- Fail-first regression (Phase 2): consumer-level tests that assert code-point order with a `"￿"` versus `"\u{1F600}"` (or `""` versus `"\u{10000}"`) pair. Under the current code-unit copies these return the supplementary value first; after the fix it sorts last. Suggested placement in files with headroom under 500 lines:
  - `test/lib/codex-native-converter/inventory.test.ts` (168 lines): `normalizeSelectedPaths` ordering.
  - `test/lib/codex-native-converter/validation.test.ts` (242): `validateConversionPlan` finding order, or `test/lib/codex-native-converter/models.test.ts` (358): `sourceArtifactToJson` frontmatter key order.
  - `test/lib/push-down/blast-radius-derive-manifests.test.ts` (183): `classifyProjectDirectories` module-path order.
  - `test/lib/push-down/copilot-customizations-engine.test.ts` (244): `stringifySorted` key order or `enumerateSourceFiles` order.
  - `test/lib/subagent-tree/quick-pick-labels.test.ts` (206): equal-mtime path tiebreak; `test/lib/subagent-tree/tree-assembler.test.ts` (167): orphan `agentId` order.
  - pr-context `renderVerificationEvidenceSection`: `collector-output.test.ts` is at 485 lines; place the case in a new `test/lib/pr-context/collector-output-ordering.test.ts` or omit and rely on the structural gate.
- Sites that only run on the real filesystem (I12 `RealPushDownFileSystem.listFiles`, I13 `realDirectoryLister`) cannot be order-tested without real files; temporary files are prohibited in tests. Cover them with the structural grep gate.
- New module tests: the moved suites (unit, enumerative properties, D/S/A cases). Keep the enumerative domain to well-formed strings unless the operator decides on the lone-surrogate question below.
- Toolchain: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:coverage` in `extensions/drm-copilot`; architecture stage not applicable (no configuration). Existing parity suites to run unchanged: `claude-blast-radius-overlay-parity.test.ts` and Python `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py`.

## Risks and Open Assumptions

- Lone surrogates (open question for the operator, does not reopen the decision): derived by hand from the ECMAScript `codePointAt` definition and not executed, the current `compareCodePoint` is not transitive for ill-formed UTF-16 input. With a = `"𐀀"` (U+10000), b = `"\uD800"` (lone high surrogate, then U+E000), c = `""`: compare(a,b) = -1 (index 1: 0xDC00 < 0xE000), compare(b,c) = -1 (0xD800 < 0xE000), compare(c,a) = -1 (0xE000 < 0x10000), a cycle. Python orders b < c < a and b < a. The current code-unit copies are transitive for all inputs. Inputs that reach these comparators (file paths from `readdirSync`, JSON keys, agent IDs) are well-formed in practice; JSON `\uD800` escapes are the plausible source of ill-formed keys. Options: accept and document "defined for well-formed strings", or adjust the algorithm to step back to the shared high surrogate when the first differing unit is a low surrogate. Either is consistent with "code-point ordering"; the second changes the moved implementation.
- Coverage entries for the 12 changed files lacking thresholds may fail if those files are below 85/75 at baseline; not measured here.
- Default `.sort()` sites in push-down and subagent-tree keep UTF-16 code-unit order after the change, so mixed orderings coexist in those subsystems (identifiers are ASCII in practice). Recommend a follow-up issue rather than expanding scope.
- Line numbers are from base `e7d3779b`; a concurrent merge touching these files would shift them.
- The issue comment was read through the REST API summary; its file/line references were then verified directly in the tree.

## Files Expected to Be Written

Production:
extensions/drm-copilot/src/lib/string-ordering.ts
extensions/drm-copilot/src/lib/pr-context/models.ts
extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts
extensions/drm-copilot/src/lib/pr-context/feature-docs.ts
extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts
extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts
extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts
extensions/drm-copilot/src/lib/pr-context/collector-core.ts
extensions/drm-copilot/src/lib/pr-context/autoclose.ts
extensions/drm-copilot/src/lib/pr-context/collector-output.ts
extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts
extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts
extensions/drm-copilot/src/lib/codex-native-converter/reporting.ts
extensions/drm-copilot/src/lib/codex-native-converter/validation.ts
extensions/drm-copilot/src/lib/codex-native-converter/intermediate-state.ts
extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts
extensions/drm-copilot/src/lib/codex-native-converter/models.ts
extensions/drm-copilot/src/lib/codex-native-converter/pipeline.ts
extensions/drm-copilot/src/lib/codex-native-converter/pipeline-traces.ts
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts
extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts
extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts
extensions/drm-copilot/src/lib/subagent-tree/tree-assembler.ts
extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts

Tests:
extensions/drm-copilot/test/lib/string-ordering.test.ts
extensions/drm-copilot/test/lib/pr-context/models.test.ts
extensions/drm-copilot/test/lib/codex-native-converter/inventory.test.ts
extensions/drm-copilot/test/lib/codex-native-converter/validation.test.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts
extensions/drm-copilot/test/lib/push-down/copilot-customizations-engine.test.ts
extensions/drm-copilot/test/lib/subagent-tree/quick-pick-labels.test.ts
extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts
extensions/drm-copilot/test/lib/pr-context/collector-output-ordering.test.ts (optional; see Testing Implications)

Config:
extensions/drm-copilot/jest.config.cjs
