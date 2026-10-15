# argumentless-sort-ordering-and-comparator-coverage-gaps (Issue #889)

- Issue: #889
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/889
- Last Updated: 2026-10-11
- Lifecycle record: docs/features/potential/promoted/2026-10-11-argumentless-sort-ordering-and-comparator-coverage-gaps.md on ref origin/docs/followups-2026-10-11 (cited, not copied)
- Work Mode: minor-audit

## Summary

Production TypeScript under `extensions/drm-copilot/src/lib/` contains 19 argument-less `.sort()` calls in 12 files. `Array.prototype.sort` with no comparator orders strings by UTF-16 code unit. That order differs from Unicode code-point order (the order used by the Python mirrors' `sorted(...)`) when a supplementary-plane character (high surrogate `0xD800`-`0xDBFF`) is compared with a character in `U+E000`-`U+FFFF`. The repository already provides `compareCodePoint` in `extensions/drm-copilot/src/lib/string-ordering.ts:53` for this purpose, and 26 production files already use it.

The issue also records two test gaps in comparator code that already uses `compareCodePoint`:

1. The `?? ""` null-default arm of the source-path/target-path tiebreak in the codex-native-converter modules `reporting-render.ts`, `reporting.ts`, and `validation.ts` is not exercised with a `null` operand at the cited lines.
2. `extensions/drm-copilot/test/lib/codex-native-converter/engine-pipeline.test.ts:45-64` passes the same record twice, so the `targetRole` tiebreak at `engine-pipeline.ts:241` always compares equal values. Removing that line would not fail the test.

Research input: `docs/features/active/2026-10-11-argumentless-sort-ordering-and-comparator-coverage-gaps-889/research/2026-10-11T08-35-argumentless-sort-sites-and-comparator-test-gaps.md` (inspected tree `origin/main` `2ef8d361e`). The research record contains complete `## Numeric Derivation Evidence` for both numeric claims used below (19 sites in 12 files; 14 observable and 5 non-observable). Each claim has two independently constructed derivations with distinct search strategies and identical member sets. The 19 site lines were re-confirmed in this worktree on 2026-10-11 with the search `\.(sort|toSorted)\(\s*\)` over `extensions/drm-copilot/src`, which returned the same 19 file:line pairs.

## Scope

Operator decision (binding):

1. Convert every argument-less `.sort()` call in production TypeScript under `extensions/drm-copilot/src/lib/` (19 sites in 12 files) to `.sort(compareCodePoint)`, imported from `extensions/drm-copilot/src/lib/string-ordering.ts` with `import { compareCodePoint } from "../string-ordering";`. `subagent-tree/tree-assembler.ts` already imports it; the other 11 files need the import.
2. Add observable-order tests that use the reference pair `HIGH_BMP = "～"` (U+FF5E) and `SUPPLEMENTARY = "\u{1F600}"` (U+1F600). Supply them in the insertion order `[SUPPLEMENTARY, HIGH_BMP]` and assert the code-point order `[HIGH_BMP, SUPPLEMENTARY]` for each of the 14 sites whose output order is observable. Record the 5 sites that sort only fixed ASCII constants as not observable, with the reason.
3. Add tests for the `?? ""` null-default arm at the cited tiebreak lines in `reporting-render.ts`, `reporting.ts`, and `validation.ts`.
4. Add a `targetRole` order assertion in `engine-pipeline.test.ts` that fails if the `targetRole` tiebreak is removed.

The 19 sites, all under `extensions/drm-copilot/src/lib/`. Ranges give the full multi-line call expression, and the `.sort()` token is on the last line of the range:

| # | Site | Observable |
|---|---|---|
| 1 | `push-down/claude-pack-selection.ts:117` | Yes |
| 2 | `push-down/claude-pack-selection.ts:299` | No (filtered to ASCII `CSHARP_PACK_NAMES`) |
| 3 | `push-down/codex-pack-selection.ts:66` | Yes |
| 4 | `push-down/codex-pack-selection.ts:71` | No (guarded by ASCII `MANIFEST_PACK_NAMES` at `:62-67`) |
| 5 | `push-down/codex-pack-selection.ts:100` | No (filtered to ASCII `CSHARP_PACK_NAMES`) |
| 6 | `push-down/codex-pack-selection.ts:108` | Yes |
| 7 | `push-down/codex-pack-selection.ts:232` | No (filtered to ASCII `CSHARP_PACK_NAMES`) |
| 8 | `subagent-tree/tree-assembler.ts:181` | Yes |
| 9 | `subagent-tree/tree-formatter.ts:29` | Yes |
| 10 | `resolve/file-prompt-transforms.ts:184` | Yes |
| 11 | `resolve/file-prompt-transforms.ts:191` | Yes |
| 12 | `validate/codex-topology-resolver.ts:123` | Yes |
| 13 | `validate/epic-orchestrator-state-core.ts:203` | Yes |
| 14 | `validate/epic-planner-git-integrity.ts:282-284` | Yes |
| 15 | `validate/orchestrator-state-codex-model-routing.ts:457` | Yes |
| 16 | `validate/orchestrator-state-codex-topology.ts:299` | No (all names derived from ASCII agent families and profiles) |
| 17 | `validate/orchestrator-state-core.ts:247-253` | Yes |
| 18 | `validate/orchestrator-state-core.ts:281-285` | Yes |
| 19 | `validate/orchestrator-state-model-routing-existence.ts:64-66` | Yes |

Cited null-default tiebreak lines, all under `extensions/drm-copilot/src/lib/codex-native-converter/`:

- `reporting-render.ts:83` (translation-trace target path) and `reporting-render.ts:189` (validation-finding target path)
- `reporting.ts:151-152` (source path) and `reporting.ts:157` (target path)
- `validation.ts:364-365` (source path) and `validation.ts:370` (target path)

## Acceptance Criteria

- [x] AC-1: Each of the 19 sites listed in the Scope table calls `.sort(compareCodePoint)` instead of `.sort()`. Each of the 12 containing files imports `compareCodePoint` from `"../string-ordering"`. The search `\.(sort|toSorted)\(\s*\)` over `extensions/drm-copilot/src/lib` (production `.ts` files only, excluding `test/`, `out/`, and `coverage/`) returns zero matches, and the result is recorded in evidence.
- [x] AC-2: For each of the 14 sites marked observable in the Scope table, at least one Jest test calls a public entry point with the pair `"\u{1F600}"` and `"～"` (U+FF5E) in the insertion order `[SUPPLEMENTARY, HIGH_BMP]` and asserts an output order or message order with `"～"` before `"\u{1F600}"`. Evidence maps each of the 14 sites to its test file and test name.
- [x] AC-3: Evidence shows that the AC-2 tests fail when run against the unconverted sources (default UTF-16 order), or records for each test the default-order output that differs from the asserted output.
- [x] AC-4: Evidence lists the 5 non-observable sites (`claude-pack-selection.ts:299`, `codex-pack-selection.ts:71`, `codex-pack-selection.ts:100`, `codex-pack-selection.ts:232`, `orchestrator-state-codex-topology.ts:299`). For each site it names the constant set or guard that restricts the sorted values to ASCII, and it confirms that existing tests execute the changed line.
- [x] AC-5: Jest tests exercise the `?? ""` default with a `null` operand at each cited tiebreak line: `reporting-render.ts:83` and `:189`; `reporting.ts:151-152` and `:157`; `validation.ts:364-365` and `:370`. Each test runs its fixture in both input orders and asserts the concrete resulting order, with the `null`-path record sorting before the non-null record when the preceding keys are equal. At `validation.ts:364-365`, where no public input produces a null and a non-null source path under an equal code, the test supplies `null` on both operands and asserts the order decided by the target path.
- [x] AC-6: A test in `extensions/drm-copilot/test/lib/codex-native-converter/engine-pipeline.test.ts` produces two translation traces that share `sourcePath` and `sectionId` (the preceding sort keys) and differ in `targetRole`. The test asserts the concrete order `["hook", "shared-skill"]` (or the equivalent concrete order for the roles used). Evidence shows that the test fails when the `targetRole` comparison at `engine-pipeline.ts:241` is removed or made to return 0.
- [x] AC-7: From `extensions/drm-copilot/`, `npx prettier --check "src/**/*.ts" "test/**/*.ts"`, `npm run lint`, `npm run typecheck`, and `npm run test:coverage` each exit 0 in a single pass. The output of each command is recorded in evidence.
- [x] AC-8: Each production file changed under AC-1 reports line coverage >= 85% and branch coverage >= 75%. Coverage on changed lines does not drop below the baseline. The per-file figures are recorded in evidence. Any new `jest.config.cjs` per-file threshold entry targets a production file and does not add a production path to a coverage `exclude` list.
- [x] AC-9: No production or test file created or modified for this issue exceeds 500 lines. No new or modified test creates or reads temporary files. New test files are placed under `extensions/drm-copilot/test/` in paths that mirror the production source path.
- [x] AC-10: The change modifies no Python, PowerShell, or fixture files under `tests/fixtures/`. The existing TypeScript parity and corpus tests pass unchanged as part of the AC-7 test run.

## Out of Scope

- The probable null-default gap at `reporting-render.ts:183-184` (validation-finding source path). The issue does not cite these lines.
- Coverage of `pipeline-traces.ts` through a mocked classifier. The issue mentions it for completeness only.
- The four `localeCompare` comparator sites (`file-system.ts:310`, `new-active-feature-folder/io.ts:123-124`, `validate/orchestration-handoff-contract.ts:352`, `validate/orchestration-handoff-materializer-support.ts:76`). They are not argument-less.
- The pre-existing message-format difference between the Python Codex pack messages (list repr) and the TypeScript messages (`Array.toString`).
- Changes to Python or PowerShell implementations, parity corpora, fixtures, bundled payloads, or policy documents.

## Dependencies / Risks

- Production file length: `orchestrator-state-codex-model-routing.ts` (485 lines), `epic-orchestrator-state-core.ts` (491), and `orchestrator-state-core.ts` (458) each gain one import line and stay under 500 lines, with little remaining headroom.
- Test file length: `test/lib/validate/epic-orchestrator-state-core.test.ts` has 475 lines. The research recommends a sibling file, `epic-orchestrator-state-core.ordering.test.ts`. Two new mirrored files are also recommended: `test/lib/resolve/file-prompt-transforms.test.ts` and `test/lib/validate/orchestrator-state-model-routing-existence.test.ts`.
- Formatting: `codex-pack-selection.ts:66` and `:108` will exceed the line width after the change. Run Prettier with `--write` before `--check`.
- Coverage thresholds: 9 of the 12 changed production files have no per-file `jest.config.cjs` entry. Measure each file before adding an entry, because a file already below 85/75 would fail the gate. This is unknown until measured.
- Engine sort call order: V8 does not guarantee which operand position an element takes. Running the null-arm fixtures in both input orders addresses this.
- The `engine-pipeline` `targetRole` test needs two reads of the same path that yield different roles. The research recommends an `InMemoryFileSystem` subclass that returns queued texts, not a module mock.
- Behavior change: order changes only for strings that contain a supplementary-plane character compared against a `U+E000`-`U+FFFF` character. For ASCII and low-BMP input, `compareCodePoint` gives the same order as the default comparator, so parity corpus output (all ASCII for the affected modules) is unchanged.
- Source note: the GitHub issue body could not be retrieved with `gh` in this authoring session. The research artifact reports that its 19-site list matches the issue's count and line list exactly.

## Verification Steps

Run all commands from `extensions/drm-copilot/`.

1. Baseline: before editing, run `npm run test:coverage` and record per-file coverage for the 12 target production files and the three codex-native-converter files.
2. Site check: search `\.(sort|toSorted)\(\s*\)` over `src/lib` and confirm zero matches (AC-1).
3. Targeted tests: run the new and extended test files with `node run-jest.cjs <test paths>` and confirm they pass (AC-2, AC-5, AC-6).
4. Discrimination checks: temporarily revert one converted site and the `engine-pipeline.ts:241` comparison, confirm the corresponding tests fail, and restore the changes (AC-3, AC-6). Record the failing output.
5. Toolchain: `npx prettier --check "src/**/*.ts" "test/**/*.ts"`, `npm run lint`, `npm run typecheck`, `npm run test:coverage`. Restart from step 1 of this sequence if any stage fails or rewrites files (AC-7).
6. Coverage: read per-file line and branch figures for changed files from the coverage output. A scoped run is `node run-jest.cjs --coverage --coverageReporters=text --coverageThreshold="{}" --collectCoverageFrom=<src file> <test file>` (AC-8).
7. Size and hygiene: confirm line counts of changed files are <= 500 and that no test uses temporary files (AC-9).
8. Scope check: `git diff --name-only origin/main...HEAD` shows no Python, PowerShell, or `tests/fixtures/` paths (AC-10).

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
