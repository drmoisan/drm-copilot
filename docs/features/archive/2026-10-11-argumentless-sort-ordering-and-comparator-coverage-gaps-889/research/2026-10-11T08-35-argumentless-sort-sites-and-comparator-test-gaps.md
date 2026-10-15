# Research: Argument-less sort sites and comparator test gaps (issue #889)

- Issue: #889 (bug, work mode `minor-audit`)
- Branch: `bug/argumentless-sort-ordering-and-comparator-coverage-gaps-889`
- Tree inspected: worktree HEAD = `origin/main` `2ef8d361e`
- All paths below are relative to the repository root. Line numbers were re-derived from the current tree with Read/Grep.
- Tool note: this research session had Read/Grep/Glob only. No command was executed; every toolchain statement below is derived from configuration files, not from a run.

## 1. Current State: argument-less sort inventory (Q1)

Scope: `extensions/drm-copilot/src/lib/**/*.ts`, excluding `test/`, `out/`, `coverage/`. A repository-wide `src/` search returned no argument-less sort outside `src/lib/`. There are zero `.toSorted(` calls anywhere under `src/`.

Result: **19 argument-less `.sort()` calls in 12 files. This matches the issue's count and line list exactly; there are no differences.**

| # | File:line | Expression | Element type | Output observable with non-ASCII input? |
|---|---|---|---|---|
| 1 | `src/lib/push-down/claude-pack-selection.ts:117` | `[...namesToLoad].sort()` | `string[]` (from `Set<string>`) | Yes. Sets manifest-map insertion order and selects which missing manifest throws first. Names are not validated before this point. |
| 2 | `src/lib/push-down/claude-pack-selection.ts:299` | `[...selectedPackNames].filter(CSHARP_PACK_NAMES.has).sort()` | `string[]` | No. Filtered to the ASCII constants `csharp-modern`/`csharp-legacy` (`:40-43`). |
| 3 | `src/lib/push-down/codex-pack-selection.ts:66` | `${unknown.sort()}` in a `ManifestError` message | `string[]` | Yes. The error message lists the unknown names, comma-joined by `Array.prototype.toString`. |
| 4 | `src/lib/push-down/codex-pack-selection.ts:71` | `[...namesToLoad].sort()` | `string[]` | No. Any name outside `MANIFEST_PACK_NAMES` (ASCII, `:12-19`) throws at `:65-67` before this line. |
| 5 | `src/lib/push-down/codex-pack-selection.ts:100` | `variantSpecific.sort().join(", ")` | `string[]` | No. Filtered to `CSHARP_PACK_NAMES` (ASCII, `:26-29`). |
| 6 | `src/lib/push-down/codex-pack-selection.ts:108` | `${unknown.sort()}` in a `ManifestError` message | `string[]` | Yes. Same shape as #3, in `resolveManifestPackNames`. |
| 7 | `src/lib/push-down/codex-pack-selection.ts:232` | `.filter(CSHARP_PACK_NAMES.has).sort()` | `string[]` | No. ASCII constant set. |
| 8 | `src/lib/subagent-tree/tree-assembler.ts:181` | `models: [...models].sort()` | `readonly string[]` (`types.ts:43,71`) | Yes. `TreeNode.models` is returned from `assembleTree`. |
| 9 | `src/lib/subagent-tree/tree-formatter.ts:29` | `[...node.models].sort()` | `readonly string[]` | Yes. The models are joined into the rendered line. |
| 10 | `src/lib/resolve/file-prompt-transforms.ts:184` | `[...referenced].filter(...).sort()` | `string[]` (from `Set<string>`) | Yes. Sets the order of names in the `Unresolved template variables: ...` error. |
| 11 | `src/lib/resolve/file-prompt-transforms.ts:191` | `for (const key of [...referenced].sort())` | `string[]` | Yes. Substitution order decides success or failure when one variable's value contains another variable's placeholder (see section 3). |
| 12 | `src/lib/validate/codex-topology-resolver.ts:123` | `[...normalized].sort()` | `string[]` (from `Set<string>`) | Yes. Returned in `CodexTopologyReceipt.languages`. |
| 13 | `src/lib/validate/epic-orchestrator-state-core.ts:203` | `[...duplicates].sort()` | `string[]` | Yes. Sets the order of `duplicate features[].feature_folder` errors. |
| 14 | `src/lib/validate/epic-planner-git-integrity.ts:282-284` | `Object.keys(integrity.planHashes).filter(...).sort()` | `string[]` | Yes. Sets the order of `unknown planner path` errors. |
| 15 | `src/lib/validate/orchestrator-state-codex-model-routing.ts:457` | `[...delegated].sort()` | `string[]` | Yes. Sets the order of `missing a receipt for delegated agent` errors. |
| 16 | `src/lib/validate/orchestrator-state-codex-topology.ts:299` | `[...allowedNames].sort().join(", ")` | `string[]` | No. Every member is ASCII: `receipt.logical_agent` must equal a `resolveCodexTopology` output (`"orchestrator"` or a `LANGUAGE_BUDGETS[*].logical_agent`), and deployment names are `${family}-${suffix}` built from `GENERATED_AGENT_FAMILIES` / `BASE_PROFILES` (`orchestrator-state-codex-model-routing.ts:39-95,238-249`). |
| 17 | `src/lib/validate/orchestrator-state-core.ts:247-253` | `Object.keys(receipts).filter(...).sort()` | `string[]` | Yes. Sets the order of `object contains unsupported key` errors. |
| 18 | `src/lib/validate/orchestrator-state-core.ts:281-285` | `Object.keys(promotionReceipts).filter(...).sort()` | `string[]` | Yes. Sets the order of `promotion contains unsupported key` errors. |
| 19 | `src/lib/validate/orchestrator-state-model-routing-existence.ts:64-66` | `[...delegated].filter(...).sort()` | `string[]` | Yes. Sets the order of the returned error messages. |

Every one of the 19 receivers is typed `string[]` or `readonly string[]` after spread/filter. **No call sorts non-string values**, so `compareCodePoint` (signature `(string, string) => number`) applies to every site without a type error.

Outside the scope of this issue: four comparator sites use `localeCompare`: `file-system.ts:310`, `new-active-feature-folder/io.ts:123-124`, `validate/orchestration-handoff-contract.ts:352`, `validate/orchestration-handoff-materializer-support.ts:76`. They are not argument-less, so the operator decision does not cover them. They are recorded here only so they are not mistaken for omissions.

## 2. `compareCodePoint` contract and import style (Q2)

- Definition: `extensions/drm-copilot/src/lib/string-ordering.ts:53`, `export function compareCodePoint(left: string, right: string): number`.
- Semantics (`:35-52`): finds the first differing UTF-16 code unit and ranks each unit with a surrogate fix-up (`rankCodeUnit`, `:25-33`). Surrogates `0xD800-0xDFFF` rank above `0xE000-0xFFFF`. A proper prefix sorts first. The function returns exactly -1, 0, or 1, defines a strict total order (including lone surrogates), and equals Unicode code-point order (Python `str` order) for well-formed strings.
- The module has no imports (`:9-12`), so a new import from `validate/` or `resolve/` creates no cycle.
- Existing importers: 26 production files, all using `import { compareCodePoint } from "../string-ordering";`. Examples are `subagent-tree/tree-assembler.ts:1`, `push-down/filesystem-adapter.ts:3`, and `codex-native-converter/validation.ts:14`. The test uses `../../src/lib/string-ordering` (`test/lib/string-ordering.test.ts:7`).
- Import path for every target file: all 12 target files sit exactly one directory below `src/lib/`, so each uses `"../string-ordering"`.
- Already imported: `tree-assembler.ts:1`. The other 11 target files need a new import line. No file under `src/lib/validate/` or `src/lib/resolve/` currently imports it.
- Equivalence for ASCII/BMP input: for strings whose code units are all below `0xD800`, `rankCodeUnit` is the identity, so `compareCodePoint` gives the same order as the default comparator. Orders differ only when a string pair differs first at a code unit `>= 0xD800` against one in `0xE000-0xFFFF`.

## 3. Per-site observable-order test plan (Q3)

Reference pair: `HIGH_BMP = "～"` (U+FF5E FULLWIDTH TILDE) and `SUPPLEMENTARY = "\u{1F600}"` (high surrogate `0xD83D`). Default order puts `SUPPLEMENTARY` first. `compareCodePoint` puts `HIGH_BMP` first. Every test below supplies the pair in insertion order `[SUPPLEMENTARY, HIGH_BMP]` and asserts `[HIGH_BMP, SUPPLEMENTARY]`. Each test therefore fails before the conversion and passes after it.

No test below needs temp files, the real filesystem, or network access. The two filesystem-dependent functions take injected in-memory fakes that already exist.

| Site(s) | Test file (existing unless marked NEW) | Public entry point and input | Expected observable result |
|---|---|---|---|
| claude-pack 117 | `test/lib/push-down/claude-pack-selection.test.ts` (263 lines). Use `buildInMemoryFileSystem` from `./push-down.test-helpers`. | `loadPackManifests(MANIFEST_DIR, new Set([SUPP, HIGH]), fs)` with `core.json` only. | Throws `Pack manifest is missing for pack '～': ...`. Alternative: seed all three manifests and assert `[...result.keys()]` equals `["core", HIGH, SUPP]`. |
| codex-pack 66 | `test/lib/push-down/codex-pack-selection.test.ts` (184 lines) | `loadPackManifests(dir, new Set([SUPP, HIGH]), anyFakeFs)`. Throws before any read. | Message `Unknown Codex pack name(s): ～,\u{1F600}` (the `toString` join has no space). |
| codex-pack 108 | same file | `resolveManifestPackNames(new Set([SUPP, HIGH]), "modern")` | Same message as above. |
| tree-assembler 181 | `test/lib/subagent-tree/tree-assembler.test.ts` (188 lines) | `assembleTree({ root: { models: [SUPP, HIGH], agentToolUseIds: [] }, subagents: [] })` | `tree.models` equals `[HIGH, SUPP]`. |
| tree-formatter 29 | `test/lib/subagent-tree/tree-formatter.test.ts` (72 lines) | `formatTree({ agentType: "root", description: "", depth: 0, models: [SUPP, HIGH], children: [] })` | Exactly `root · [～,\u{1F600}] · 0 · `. |
| file-prompt 184 | NEW `test/lib/resolve/file-prompt-transforms.test.ts` (mirrors the source path). The only existing coverage is indirect, through the re-export in `test/lib/resolve/file-prompt-variables.test.ts`, which has 416 lines. | `replaceAllVariables("${\u{1F600}}${～}", {})` | Throws `Unresolved template variables: ～, \u{1F600}`. |
| file-prompt 191 | same NEW file | `replaceAllVariables("${～}${\u{1F600}}", { "～": "${\u{1F600}}", "\u{1F600}": "done" })` | Returns `"donedone"`. Under the old order, `\u{1F600}` is substituted first, leaving `${\u{1F600}}` after the `～` pass, so the call throws `Template resolution failed: unresolved placeholders remain`. |
| codex-topology-resolver 123 | `test/lib/validate/codex-topology-resolver.test.ts` (199 lines) | `resolveCodexTopology([SUPP, HIGH], 1, 1, "standalone")` (`toLowerCase` is the identity for both characters) | `receipt.languages` equals `[HIGH, SUPP]`. `routing_reason` is `cross_language`. |
| epic-orch-core 203 | NEW `test/lib/validate/epic-orchestrator-state-core.ordering.test.ts`. The existing file has 475 lines, so adding to it would push it toward the 500-line limit; the `orchestrator-state-core.completion.test.ts` sibling is precedent for a dotted suffix. | `validateEpicOrchestratorStateText(JSON.stringify({ features: [{feature_folder: SUPP}, {feature_folder: SUPP}, {feature_folder: HIGH}, {feature_folder: HIGH}] }))`. The duplicate check runs unconditionally (`:452-456`). | The errors filtered by `"duplicate features[].feature_folder"` end in `HIGH`, then `SUPP`. |
| epic-planner 284 | `test/lib/validate/epic-planner-git-integrity.test.ts` (213 lines). Use the existing `GitStub`, `state()`, `parsed()`, and `HASH`. | `validatePlanningGitIntegrity(state({ plan_hashes: { [SUPP]: HASH, [HIGH]: HASH } }), parsed(), [], new GitStub())`. With `plans = []`, the loop at `:207` does nothing. | The errors filtered by `"unknown planner path"` are, in order, `'～'` then `'\u{1F600}'`. |
| codex-model-routing 457 | `test/lib/validate/orchestrator-state-codex-model-routing.test.ts` (376 lines) | `validateCodexModelRoutingGate({ delegation_receipts: [{agent_name: SUPP}, {agent_name: HIGH}], codex_model_routing_receipts: [] })`. An empty list yields no receipt errors (`:385-403`). | `toEqual` on two messages: `...delegated agent: ～.` then `...delegated agent: \u{1F600}.` |
| orch-core 253 | `test/lib/validate/orchestrator-state-core.test.ts` (381 lines). Use the local `buildValidState()`. | `state.delegation_receipts = { [SUPP]: {}, [HIGH]: {} }` | The `object contains unsupported key:` errors are, in order, `HIGH`, then `SUPP`. |
| orch-core 285 | same file | `state.delegation_receipts = { promotion: { [SUPP]: {}, [HIGH]: {} } }` | The `promotion contains unsupported key:` errors are, in order, `HIGH`, then `SUPP`. |
| existence 66 | NEW `test/lib/validate/orchestrator-state-model-routing-existence.test.ts` (no mirrored file exists; the only coverage is indirect, through `orchestrator-state-core.model-routing.test.ts`) | `validateModelRoutingExistence({ delegation_receipts: [{agent_name: SUPP}, {agent_name: HIGH}] })` | `toEqual` on two messages, with `HIGH` first. |

Sites justified as not observable (5), from section 1: claude-pack 299, codex-pack 71, codex-pack 100, codex-pack 232, and codex-topology 299. Every value that reaches these sorts is drawn from a fixed ASCII constant set, and those sets contain no code unit at or above `0xD800`. Both comparators therefore produce the same result, and no input can make the two orders differ. These sites still get the conversion for consistency, and their existing tests cover the changed line.

## 4. Test gap (1): the `?? ""` null-default arm (Q4)

Types: `ValidationFinding.sourcePath` and `ValidationFinding.targetPath` are `string | null` (`codex-native-converter/models.ts:148-149`). `TranslationTrace.targetPath` is `string | null` (`models-intermediate.ts:152`). A null comes from `validateRequiredInputs`/`validateGeneratedOutput` (`sourcePath: null`), from mapping records with `targetPath: null`, and from launcher traces when repo prompts are disabled.

Each `a ?? ""` / `b ?? ""` pair is two independent branches, one for the left operand and one for the right. V8's `Array.prototype.sort` does not guarantee which operand position an element takes, so **each test should run the same fixture in both input orders**. That exercises the null arm on both sides regardless of engine call order.

Coverage already present, from reading the tests:
- `test/lib/codex-native-converter/reporting-coverage.test.ts:48-53` puts `sourcePath: null` against `"a.md"`/`"b.md"` under the same code, which exercises some source-path null arms in `reporting.ts:151-152`. No pair has an equal source path with a null target path, so `reporting.ts:157` is never reached with a null.
- `test/lib/codex-native-converter/reporting-render.test.ts:66-70` has its only null `targetPath` trace in a different `targetRole`, so `reporting-render.ts:83` is never reached with a null. Its findings fixture (`:87-92`) has no equal-code pair involving a null, so `reporting-render.ts:183-184` (source path) and `:189` (target path) also appear unexercised for null. Lines `183-184` are not listed in the issue; this research flags them as a probable additional gap of the same kind. Coverage could not be run in this session to confirm.

Tiebreak expressions and drivers:

| Location | Expression | Exported driver | Test file | Concrete input |
|---|---|---|---|---|
| `reporting-render.ts:83` | `compareCodePoint(left.targetPath ?? "", right.targetPath ?? "")`, reached only when `sourcePath`, `sectionId`, and `targetRole` are equal | `renderConversionReport(runOptions, [], [], traces, [])` | `test/lib/codex-native-converter/reporting-render.test.ts` (106 lines; the local `trace(heading, role, targetPath)` helper fits) | `[trace("second", SHARED_SKILL, "a/SKILL.md"), trace("first", SHARED_SKILL, null)]` and the reverse. Assert that the index of `` `first` `` is less than the index of `` `second` ``. |
| `reporting-render.ts:183-184, 189` | source path, then target path, after an equal `code` | same function, `validationFindings` argument | same file (helper `finding(code, src, tgt, msg)`) | Source arm: `[finding("C", "a.md", null, "two"), finding("C", null, null, "one")]` plus the reverse. Target arm: `[finding("C", "a.md", "z.md", "two"), finding("C", "a.md", null, "one")]` plus the reverse. Assert the `- \`C\`:` lines are `one`, then `two`. |
| `reporting.ts:151-152, 157` (`sortFindings`, private) | same as above | `writeConversionReportSet(fs, RUN_OPTIONS, [], [], [], findings, {})` with `InMemoryFileSystem`. Read `fixtures/artifacts/validation-results.json`. | `test/lib/codex-native-converter/reporting-coverage.test.ts` (70 lines) | Same two fixture pairs, both orders. Assert `parsed.map(m => m.message)` equals `["one", "two"]`. |
| `validation.ts:364-365, 370` | same, inside `validateConversionPlan` | `validateConversionPlan(runOptions(), records, [], generatedOutput)` | `test/lib/codex-native-converter/validation.test.ts` (242 lines; helpers `runOptions`, `record`) | Source arms (both null): `generatedOutput = { "z.md": T, "a.md": T }`, where `T = "This output still points at .github/instructions/runtime.instructions.md."` (the trigger used at `:137-138`). This produces two `lingering-source-runtime-reference` findings with `sourcePath: null` on both sides, so `"" vs ""` ties and the target path decides. Expect targets `["a.md", "z.md"]`. Target arm: two records with `sourcePath: "s.md"`, `conversionClass: UNSUPPORTED`, `targetRole: UNSUPPORTED`, and `targetPath` values `".agents/x/SKILL.md"` and `null`, in both orders. Both yield `unsupported-ecosystem` (`:119-135`), the non-null target is not duplicated, and the expected target order is `[null, ".agents/x/SKILL.md"]`. |

Why this discriminates: `""` sorts before every non-empty string, so a null must sort first. If the null default changed (for example to `"￿"`), or a key were dropped, the asserted order would invert.

## 5. Test gap (2): the `targetRole` tiebreak in `buildTranslationTraces` (Q5)

- `engine-pipeline.ts:220-243`: the sort key is `(sourcePath, sectionId, targetRole)`, and `:241` is the final `compareCodePoint(left.targetRole, right.targetRole)`.
- The existing test (`engine-pipeline.test.ts:45-64`) passes the same record twice. The duplicated traces are identical, so the `targetRole` comparison always returns 0. Removing that line would not fail the test.
- Constraint: in the real pipeline, one parse yields at most one trace per `sectionId`. Section ids are `${sourcePath}#${stem}-${startLine}` (`parser.ts:229`), so they never collide with the launcher id `#__launcher__` (`pipeline-traces.ts:73`). The inner `buildPromptTranslationTraces` also pre-sorts by the same key (`pipeline-traces.ts:111-121`). A trace pair that differs only by `targetRole` can therefore come only from two different reads of the same path.
- Recommended construction (injected fake, no module mock): in the test file, define a subclass of `InMemoryFileSystem` (`test/lib/codex-native-converter/in-memory-file-system.ts:17,83`) whose `readTextFile` returns queued texts in sequence for the prompt path. `parseSourceArtifact` reads through `fileSystem.readTextFile` (`parser.ts:60`). Pass `[PROMPT_RECORD, PROMPT_RECORD]` with these texts:
  - First read (shared-skill): `"# P\n\nIntro.\n\n## Gate\n\n1. Collect context.\n2. Run the review.\n"`. The `Gate` heading does not match `PROMPT_WORKFLOW_HEADING_PATTERN`, but two numbered steps give `SHARED_WORKFLOW`, which maps to `shared-skill` (`classifier-claude.ts:228-232`, `pipeline-traces.ts:85-86`).
  - Second read (hook): `"# P\n\nIntro.\n\n## Gate\n\nExecution must not begin until the plan is validated.\n"`. `must not` matches `PROMPT_ENFORCEMENT_PATTERN` (`classifier-claude.ts:33-34`), giving `HOOK_CANDIDATE`, which maps to `hook`.
  - Identical preceding lines give an identical `startLine`, so both traces share `sectionId = ${PROMPT_PATH}#gate-<n>`.
  - The outer sort input for that section id is `[shared-skill, hook]`. The expected output is `[hook, shared-skill]` (`"hook" < "shared-skill"`). If line 241 were removed or returned 0, the stable sort would keep `[shared-skill, hook]` and the test would fail.
- Assertion: filter the result to traces whose `sectionId` ends with `#gate-`, then assert `map(t => t.targetRole)` equals `["hook", "shared-skill"]`.
- Rejected alternative: `jest.mock("…/pipeline-traces")` to return synthetic traces. It works, but it replaces a real module and departs from the injected-fake pattern these tests already use.

## 6. Toolchain, coverage, and parity (Q6)

Commands, run from `extensions/drm-copilot/` (from `package.json:202-213`):

| Stage | Command | Notes |
|---|---|---|
| 1. Format | `npx prettier --check "src/**/*.ts" "test/**/*.ts"`. Fix with `npm run format`. | There is no `format:check` script. `format` writes `src/**/*.ts test/**/*.ts *.json *.cjs`. |
| 2. Lint | `npm run lint`, which runs `eslint --no-error-on-unmatched-pattern src test` | `eslint.config.mjs` uses `eslint.configs.recommended` plus `tseslint.configs.recommended` with `project: false`. `@typescript-eslint/require-array-sort-compare` is not enabled; it is not in `recommended` and needs type information. |
| 3. Type check | `npm run typecheck`, which runs `tsc -p ./ --noEmit` and then `tsc -p tsconfig.jest.json --noEmit` | CI step `_drm-copilot-extension-tests.yml:29-30`. |
| 4. Architecture boundary | Not applicable | No `.dependency-cruiser*` exists anywhere in the repository (verified with Glob). |
| 5. Unit tests | `npm run test`, which runs `node run-jest.cjs` | CI step `_drm-copilot-extension-tests.yml:32-33`. `run-jest.cjs` rejects `--passWithNoTests`, `--onlyChanged`, and `--lastCommit` and rewrites `--testPathPattern` to `--testPathPatterns`. |
| 5b. Coverage | `npm run test:coverage`, which runs `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` | `jest.config.cjs:10-19`: v8 provider, `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`, per-file thresholds only (no `global`). |
| 6. Contract/schema | Not applicable | No contract surface changes. |
| 7. Integration | Covered by the full `npm run test` run | |

Per-file coverage threshold entries that already exist for target files: `src/lib/validate/orchestrator-state-core.ts` (`jest.config.cjs:94-97`), `src/lib/subagent-tree/tree-assembler.ts` (`:190-193`), and `src/lib/subagent-tree/tree-formatter.ts` (`:194-197`). The other 9 production files changed here have no entry; issue #305 established the convention of adding per-file entries for changed files. Measure each file before adding an entry, because a file already below 85/75 would fail the gate. The `codex-native-converter` files get test-only changes, so their production code does not change.

Scoped coverage run (example):

```
node run-jest.cjs --coverage --coverageReporters=text --coverageThreshold="{}" --collectCoverageFrom=src/lib/validate/codex-topology-resolver.ts test/lib/validate/codex-topology-resolver.test.ts
```

Add one `--collectCoverageFrom=<src file>` per file under test, and pass the matching test file paths as positional patterns. The `--coverageThreshold="{}"` override is recommended because the config's per-file threshold keys would otherwise refer to files not collected in a scoped run, and Jest reports "Coverage data for <path> was not found" as a threshold failure. This is expected Jest behavior and was not executed in this session; confirm it on the first run. A successful run prints `Test Suites: N passed, N total`, `Tests: M passed, M total`, and a text table with `% Stmts | % Branch | % Funcs | % Lines` per collected file. The `text-summary` reporter prints a `Coverage summary` block with `Statements`, `Branches`, `Functions`, and `Lines`.

Python and PowerShell mirrors:
- The Python ports sort with `sorted(...)`, which uses code-point order: `push_down_claude_pack_selection.py:171,400`, `push_down_codex_pack_selection.py:61,65,89,94,207`, `resolve_codex_topology.py:116`, `resolve_file_prompt.py:495,502`, `validate_epic_orchestrator_state.py:211`, `epic_planner_git_integrity.py:267`, `_orchestrator_state_codex_model_routing.py:178`, `_orchestrator_state_codex_topology.py:226`, `validate_orchestrator_state.py:184,213`, `_orchestrator_state_model_routing_gate.py:266`. The conversion moves the TypeScript ports toward their Python mirrors. No Python change is required.
- PowerShell modules exist under `.claude/lib/orchestrator-state/` and `.claude/lib/codex-routing/`. They are separate implementations, are outside this TypeScript-only scope, and need no change.
- Observed but out of scope: the Python Codex pack messages format the list as a Python list repr (`['a', 'b']`, `push_down_codex_pack_selection.py:61`), while TypeScript uses `Array.toString` (`a,b`, `codex-pack-selection.ts:66`). This is a pre-existing difference that the operator decision does not cover.

Parity corpora: the TypeScript parity and corpus tests read `tests/fixtures/orchestrator_state_*`, `epic_wave_barrier/`, `push_down/`, `parallel_cohort_barrier/`, `orchestration-handoff/contract`, `blast_radius*`, and `codex_native_converter/`. A non-ASCII search over `tests/fixtures` found no non-ASCII bytes in any `orchestrator_state*`, `epic_wave_barrier`, `push_down`, or `parallel_cohort_barrier` fixture. The non-ASCII hits are in `blast_radius/`, `parallel_lane_assertion/`, `orchestration-handoff/taskmaster-469/*/plan*.md`, and others, and none of those feed the 12 target modules. For all-ASCII input, `compareCodePoint` gives the same order as the default comparator (section 2), so **converting the TypeScript sites does not change the byte output of any parity corpus**.

## 7. Bundled or mirrored copies (Q7)

None. Glob found exactly one copy of each target file, under `extensions/drm-copilot/src/lib/`. There is no tracked `extensions/drm-copilot/out/` or `resources/` JS/TS payload. `out/` is esbuild output produced by `npm run compile` (`package.json:203-206`) and is not in the worktree. There is no `.claude/` TypeScript mirror. The Python and PowerShell implementations are independent ports (section 6), not copies.

## 8. Risks (Q8)

- Non-string sorts: none (section 1).
- Lint rule `require-array-sort-compare`: not enabled (section 6). The change introduces no lint exposure.
- Formatting: after the change, `codex-pack-selection.ts:66,108` (`throw new ManifestError(\`Unknown Codex pack name(s): ${unknown.sort(compareCodePoint)}\`);`) will exceed 80 columns. Prettier will reflow the call arguments, so run stage 1 with `--write` before `--check`.
- 500-line limit:
  - Production: `orchestrator-state-codex-model-routing.ts` 485 → 486, `epic-orchestrator-state-core.ts` 491 → 492, `orchestrator-state-core.ts` 458 → 459 (one import line each). These stay under the limit but leave little headroom.
  - Tests: `epic-orchestrator-state-core.test.ts` has 475 lines; put the new test in a sibling file (section 3). `parallel-orchestrator-state-core.test.ts` (455) is untouched. `file-prompt-variables.test.ts` (416), `reporting.test.ts` (400), `orchestrator-state-codex-model-routing.test.ts` (376), and `orchestrator-state-core.test.ts` (381) can each absorb roughly 20-40 lines.
- Coverage thresholds: adding per-file entries for the 9 ungated files could fail if any file is already below 85/75. This is unknown until measured.
- Engine sort call order: covered by running the null-arm fixtures in both input orders (section 4).
- Behavior change for real users: only strings containing supplementary-plane characters next to U+E000-U+FFFF characters change order. Package names, agent names, and plan paths in practice are ASCII.

## Numeric Derivation Evidence

### Claim A: 19 argument-less sort calls in production TypeScript under `src/lib/`

- Complete Family: every call of `Array.prototype.sort` or `Array.prototype.toSorted` with zero arguments in `extensions/drm-copilot/src/lib/**/*.ts`, including `[...x].sort()`, `x.sort()`, chained `.filter(...).sort()`, multi-line call shapes, and template-literal embeddings.
- Exhaustive Search Scope: `extensions/drm-copilot/src/lib` (all `.ts`), plus a confirmatory search over `extensions/drm-copilot/src`.
- Inclusion Rules: a `.sort(` or `.toSorted(` call whose argument list is empty or whitespace-only.
- Exclusion Rules: calls with a comparator argument, whether inline, on the next line, or a named function. Test files, build output, and comments are excluded; `string-ordering.ts:48` mentions `Array.prototype.sort` in a doc comment only.
- Primary Search Strategy or Query Expression: ripgrep `\.(sort|toSorted)\(\s*\)` over `src/lib`. The same pattern over `src` returned the same 19 lines.
- Primary Member Set: claude-pack-selection.ts:117, 299; codex-pack-selection.ts:66, 71, 100, 108, 232; tree-assembler.ts:181; tree-formatter.ts:29; file-prompt-transforms.ts:184, 191; codex-topology-resolver.ts:123; epic-orchestrator-state-core.ts:203; epic-planner-git-integrity.ts:284; orchestrator-state-codex-model-routing.ts:457; orchestrator-state-codex-topology.ts:299; orchestrator-state-core.ts:253, 285; orchestrator-state-model-routing-existence.ts:66.
- Primary Count: 19.
- Cross-check Search Strategy or Query Expression: three steps. (a) Enumerate every `\.(sort|toSorted)\(` occurrence in `src/lib` (count mode: 79 occurrences across 44 files) and classify each by reading the call plus one following line (`-A 1`). (b) Separately search `toSorted|sort\(\s*$` to catch multi-line argument lists: 14 matches, all with a comparator on the next line, and zero `toSorted`. (c) Search `\.sort\b[^(]|sort\.call` for non-call references: only the doc comment.
- Cross-check Member Set: of the 79 occurrences, the 60 with comparators are: file-system.ts:310; intermediate-state.ts:53; engine-pipeline.ts:77, 137, 173, 190, 232, 294; inventory.ts:169, 237, 290; codex-native-converter/models.ts:259; pipeline-traces.ts:111; reporting-render.ts:60, 63, 70, 177; pipeline.ts:54, 94, 147; reporting.ts:54, 131, 145, 227; validation.ts:269, 358; quick-pick-labels.ts:103; new-active-feature-folder/io.ts:123; feature-docs.ts:99, 305; feature-docs-parsers.ts:178, 273; collector-output.ts:113; autoclose.ts:210, 214; collector-core.ts:201, 202, 203; claude-blast-radius-derive-manifests.ts:191; claude-blast-radius-derive.ts:126; claude-blast-radius-overlay.ts:200; pr-context/models.ts:354; claude-blast-radius-derive-core.ts:247, 274; render-feature-excerpts.ts:365; tree-assembler.ts:64, 113; render-pr-helpers.ts:153, 204; orchestration-handoff-contract.ts:352; orchestration-handoff-materializer-support.ts:76; summary-helpers.ts:278; copilot-customizations-engine.ts:168, 290; verification-evidence.ts:106; filesystem-adapter.ts:142; parallel-state-shared.ts:413; parallel-state-structures.ts:278, 288, 461. The residual set with no comparator is: claude-pack-selection.ts:117, 299; codex-pack-selection.ts:66, 71, 100, 108, 232; tree-assembler.ts:181; tree-formatter.ts:29; file-prompt-transforms.ts:184, 191; codex-topology-resolver.ts:123; epic-orchestrator-state-core.ts:203; epic-planner-git-integrity.ts:284; orchestrator-state-codex-model-routing.ts:457; orchestrator-state-codex-topology.ts:299; orchestrator-state-core.ts:253, 285; orchestrator-state-model-routing-existence.ts:66.
- Cross-check Count: 79 - 60 = 19. The per-file count-mode totals agree: claude-pack 2/2, codex-pack 5/5, tree-assembler 1/3, tree-formatter 1/1, file-prompt-transforms 2/2, codex-topology-resolver 1/1, epic-orchestrator-state-core 1/1, epic-planner-git-integrity 1/1, codex-model-routing 1/1, codex-topology 1/1, orchestrator-state-core 2/2, model-routing-existence 1/1.
- Member-set Comparison: the normalized primary set and the cross-check residual set are identical (19 = 19, same file:line pairs, no extras, no omissions). Both also match the issue's list exactly. The assertion "19 sites in 12 files" is supported.

### Claim B: 14 sites observable with a supplementary/high-BMP pair, 5 not observable

- Complete Family: the 19 sites of Claim A.
- Exhaustive Search Scope: the 12 target files. Each site was read together with its upstream data flow.
- Inclusion Rules: observable means some public-function input lets a supplementary-plane string and a U+E000-U+FFFF string both reach the sorted array, and the sorted order shows up in a return value or thrown message.
- Exclusion Rules: not observable means every value reaching the sort is restricted to a fixed ASCII constant set.
- Primary Search Strategy or Query Expression: forward reading from each exported entry point to the sort (sections 1 and 3).
- Primary Member Set: observable: claude-pack 117; codex-pack 66, 108; tree-assembler 181; tree-formatter 29; file-prompt 184, 191; codex-topology-resolver 123; epic-orch-core 203; epic-planner 284; codex-model-routing 457; orch-core 253, 285; existence 66. Not observable: claude-pack 299; codex-pack 71, 100, 232; codex-topology 299.
- Primary Count: 14 + 5 = 19.
- Cross-check Search Strategy or Query Expression: backward reading from each sort to the constraining filter or guard. Grep for `CSHARP_PACK_NAMES`, `MANIFEST_PACK_NAMES`, `GENERATED_AGENT_FAMILIES`, `LANGUAGE_BUDGETS`, and `modelDeployments` to confirm which arrays are constrained by constant sets.
- Cross-check Member Set: constrained: claude-pack 299 (`CSHARP_PACK_NAMES` filter, `:298`); codex-pack 71 (`MANIFEST_PACK_NAMES` guard, `:62-67`); codex-pack 100 (`CSHARP_PACK_NAMES` filter, `:94-96`); codex-pack 232 (`CSHARP_PACK_NAMES` filter, `:231`); codex-topology 299 (`allowedNames` from validated receipts, `:293-294`, with deployments derived at `codex-model-routing.ts:238-249`). Unconstrained: the other 14.
- Cross-check Count: 5 constrained, 14 unconstrained.
- Member-set Comparison: identical sets in both directions.

## Automation Feasibility

No step needs human interaction. Every change is a source edit (import line plus comparator argument), every new or extended test is a deterministic Jest test with in-memory fakes, and every verification step is a non-interactive CLI command (`npx prettier --check`, `npm run lint`, `npm run typecheck`, `npm run test`, `npm run test:coverage`). There are no credentials, no network calls, and no GUI steps.

## Recommendations

1. In all 19 sites across the 12 files, replace `.sort()` with `.sort(compareCodePoint)`. Add `import { compareCodePoint } from "../string-ordering";` to the 11 files that lack it (`tree-assembler.ts` already has it).
2. Add the 14 observable-order tests listed in section 3, using the `"\u{1F600}"` / `"～"` pair with supplementary-first insertion. Create three new mirrored files: `test/lib/resolve/file-prompt-transforms.test.ts`, `test/lib/validate/orchestrator-state-model-routing-existence.test.ts`, and `test/lib/validate/epic-orchestrator-state-core.ordering.test.ts`. Extend the existing files for the other sites.
3. Record the 5 non-observable sites (claude-pack 299; codex-pack 71, 100, 232; codex-topology 299) in the plan with the constraint evidence from section 1. They need no ordering test.
4. Gap (1): add null-arm tests in `reporting-render.test.ts`, `reporting-coverage.test.ts`, and `validation.test.ts` with the inputs in section 4. Run each fixture in both input orders. Include `reporting-render.ts:183-184`, which appears to have the same gap.
5. Gap (2): replace or extend `engine-pipeline.test.ts:45-64` with the sequenced-read fake from section 5, asserting `["hook", "shared-skill"]` for one shared section id.
6. Run the seven-stage loop from section 6 (stage 4 and stage 6 not applicable). Measure per-file coverage for the 9 ungated production files before deciding whether to add `jest.config.cjs` threshold entries.
7. No Python, PowerShell, fixture, bundle, or mirror changes are required.
