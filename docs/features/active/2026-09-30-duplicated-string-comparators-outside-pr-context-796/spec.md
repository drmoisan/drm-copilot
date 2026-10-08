# 2026-09-30-duplicated-string-comparators-outside-pr-context (Spec)

- **Issue:** #796
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T21-30
- **Status:** Ready for Planning
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md`)
- **Research:** `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/research/research.2026-10-08T21-30.md`
- **Related:** #716, #740 (PR #839)

## Context

The ordinal string comparator `left < right ? -1 : left > right ? 1 : 0` is implemented repeatedly under `extensions/drm-copilot/src/lib/` outside `pr-context/`. #716 consolidated `compareCodePoint` into `pr-context/models.ts`. #740 (merged as PR #839) consolidated the remaining helper duplication inside `pr-context/` and changed `compareCodePoint` from UTF-16 code-unit order to Unicode code-point order. Consolidation into a subsystem-neutral `src/lib/` module was deferred from #740 to this issue.

After PR #839 the copies no longer agree with `compareCodePoint`. The copies use UTF-16 code-unit order; `compareCodePoint` uses code-point order. The two orders differ when the first differing position compares a supplementary character (U+10000 and above) with a BMP character in U+E000..U+FFFF.

The issue comment (2026-10-08) adds two further copies in `subagent-tree/`: `compareByAgentId` in `tree-assembler.ts` and the path tiebreak in `compareCandidates` in `quick-pick-labels.ts`.

Environment:
- OS/version: any
- Python version: n/a (TypeScript)
- Command/flags used: `git grep -n 'left < right ? -1' -- extensions/drm-copilot/src`
- Data source: issue captured at `ae7c7779`; research verified against base `e7d3779b` (includes PR #839)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Maintainability and ordering consistency. Each TypeScript site that has a Python twin currently disagrees with that twin on the supplementary-versus-U+E000..U+FFFF case, because Python `str` ordering is code-point order (research section 5).

## Repro & Evidence

Steps to Reproduce:
1. Run `git grep -n 'left < right ? -1 : left > right ? 1 : 0' -- extensions/drm-copilot/src`.
2. Compare each hit with `compareCodePoint` in `extensions/drm-copilot/src/lib/pr-context/models.ts:355-368` (the issue body cites line 340, which is stale after PR #839).

Expected:
One shared comparator is used for ordinal string ordering, so its contract and tests exist once.

Actual:
The literal grep in step 1 matches only part of the family. The research inventory (research section 1, verified by two independent derivations in its `## Numeric Derivation Evidence`) identifies 24 comparator sites in 15 files outside `pr-context/` (codex-native-converter: 9 files; push-down: 4; subagent-tree: 2), plus one residual site inside `pr-context/`.

Named comparator definitions (6):

| ID | Location | Name / form |
|---|---|---|
| N1 | `codex-native-converter/engine-pipeline.ts:46-48` | `compareStrings` (module-private) |
| N2 | `codex-native-converter/reporting-render.ts:36-38` | `compareStrings` (module-private) |
| N3 | `codex-native-converter/reporting.ts:148-149` | local arrow `compare` in `sortFindings` |
| N4 | `codex-native-converter/validation.ts:359-360` | local arrow `compare` in `validateConversionPlan` |
| N5 | `push-down/claude-blast-radius-derive-manifests.ts:121-123` | `compareOrdinal` (exported; imported by `claude-blast-radius-derive-core.ts:49` and `claude-blast-radius-overlay.ts:29`) |
| N6 | `subagent-tree/tree-assembler.ts:97-105` | `compareByAgentId` (if/if/return form) |

Inline full-ternary copies (16): `codex-native-converter/intermediate-state.ts:53` (I1); `inventory.ts:169, 239, 294` (I2-I4); `models.ts:259` (I5); `pipeline.ts:57, 93` (I6, I7); `reporting.ts:54, 131-135, 230` (I8-I10); `validation.ts:269` (I11); `push-down/filesystem-adapter.ts:142` (I12); `push-down/claude-blast-radius-derive.ts:126` (I13); `push-down/copilot-customizations-engine.ts:170, 291` (I14, I15); `subagent-tree/quick-pick-labels.ts:132` (I16).

Guarded two-way variants (2): `codex-native-converter/pipeline.ts:146-154` (G1) and `codex-native-converter/pipeline-traces.ts:110-121` (G2), of the form `if (a.k !== b.k) return a.k < b.k ? -1 : 1;`.

Residual site inside `pr-context/` (1): `pr-context/collector-output.ts:112-118` in `renderVerificationEvidenceSection`.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Inventory and line numbers: research sections 1.1-1.4 and 7.

## Decisions and Assumptions

The following decisions are recorded verbatim from the orchestration request.

1. OPERATOR DECISION: the single shared comparator uses Unicode code-point ordering, matching compareCodePoint in extensions/drm-copilot/src/lib/pr-context/models.ts after PR #839. Not to be reopened.
2. ORCHESTRATOR ASSUMPTION: the shared comparator must be a consistent strict total order over every JavaScript string, including strings containing unpaired surrogates (Array.prototype.sort requires a consistent comparator). For well-formed strings its result equals Unicode code-point order. The research found the current compareCodePoint is non-transitive on unpaired surrogates (example triple in the research), so the moved implementation is corrected, not moved verbatim. The spec must not prescribe the algorithm beyond this contract, but may note that a code-unit comparison with surrogate fix-up (mapping 0xD800-0xDFFF above 0xE000-0xFFFF) satisfies it.
3. Shared module path: extensions/drm-copilot/src/lib/string-ordering.ts exporting compareCodePoint, with no imports; tests at extensions/drm-copilot/test/lib/string-ordering.test.ts; a per-file entry in extensions/drm-copilot/jest.config.cjs coverage thresholds. pr-context/models.ts no longer defines compareCodePoint; every consumer imports directly from the shared module (no re-export), per research.
4. Scope includes every comparator site the research inventoried (24 sites in 15 files outside pr-context, the two subagent-tree copies, and pr-context/collector-output.ts:112-118), and the pr-context importers that switch their import source. Argument-less .sort() calls in push-down/ and subagent-tree/ are out of scope (recorded as follow-up; no issue filed in this run). Numeric comparators are out of scope.
5. Expected outputs: no existing fixture or expected output changes (research: no fixture contains U+E000..U+FFFF or supplementary characters; Python twins already sort by code point). Existing tests must pass without editing expected values.

Notes on the decisions:
- Decision 1 supersedes the issue body's "keeping the existing sort order" wording for the supplementary-versus-U+E000..U+FFFF case. This is an intended behavior change for that case, not a "no behavior change" refactor. Decision 5 records that no committed expected output depends on that case.
- Decision 2: the research example triple is a = `"\u{10000}"`, b = `"\uD800"`, c = `""`. With the current `compareCodePoint`, compare(a,b) = -1, compare(b,c) = -1, compare(c,a) = -1, which is a cycle. The derivation in the research was by hand and was not executed; the new unit tests in AC-3 execute it.
- Decision 4: the two subagent-tree copies (N6, I16) are counted within the 24 sites.

## Scope & Non-Goals

- In scope:
  - New module `extensions/drm-copilot/src/lib/string-ordering.ts` exporting `compareCodePoint(left: string, right: string): number`, with no import statements.
  - Removal of the definition of `compareCodePoint` from `pr-context/models.ts`; `models.ts` (for `sortedSet`) and the seven pr-context importers (`verification-evidence.ts`, `feature-docs.ts`, `feature-docs-parsers.ts`, `render-pr-helpers.ts`, `render-feature-excerpts.ts`, `collector-core.ts`, `autoclose.ts`) import from `../string-ordering`.
  - Replacement of all 24 inventoried sites (N1-N6, I1-I16, G1, G2) and the pr-context residual site `collector-output.ts:112-118` with calls to the shared comparator.
  - Deletion of `compareStrings` (N1, N2), the local `compare` arrows (N3, N4), and the exported `compareOrdinal` (N5). All in-repo callers of `compareOrdinal` are updated in the same change.
  - Key-projecting wrappers (`compareByAgentId`, `compareCandidates`, `sortBySourcePath`, `sortFindings`, multi-key chains) remain; only their string-comparison core delegates to the shared comparator. Key order in multi-key chains is unchanged.
  - Moving the `compareCodePoint` test suites from `test/lib/pr-context/models.test.ts` to `test/lib/string-ordering.test.ts`, extended with unpaired-surrogate cases.
  - Consumer regression tests per module family and a per-file coverage threshold entry for the new module.
- Out of scope / non-goals:
  - Argument-less `.sort()` calls in `push-down/` and `subagent-tree/` (and under `validate/`, `resolve/`). Recorded as a follow-up; no issue is filed in this run.
  - Numeric comparators (research section 1.5).
  - `localeCompare` callbacks (different, locale-sensitive contract).
  - The inline `sortedSet` equivalents in `feature-docs.ts:309-311` and `autoclose.ts:210`, which already use `compareCodePoint` (#740 decision D3).
  - Changes to Python twins, fixtures, or committed expected outputs.
- Explicitly excluded systems, integrations, or datasets:
  - `extensions/drm-copilot/resources/**` (contains no `.ts` mirrors) and `packages/mcp-server` build outputs (research section 6).

## Root Cause Analysis

The converter, push-down, and subagent-tree modules were written independently of `pr-context/`, and each inlined its own ordinal comparator. `compareCodePoint` was consolidated only within `pr-context/`, and importing it from there would create the first cross-subsystem dependency edge among `pr-context/`, `push-down/`, and `codex-native-converter/` (research section 3). With no neutral location available, the copies persisted, and PR #839 changed the contract of one copy only, so the copies now diverge.

## Proposed Fix

### Design summary (what changes where):

A single dependency-free module `src/lib/string-ordering.ts` owns the ordinal string comparator. Every string-ordering comparator site in the inventory calls it. `pr-context/models.ts` no longer defines it, and no module re-exports it.

### Boundaries and invariants to preserve:

- `string-ordering.ts` contains no import statements, so it cannot introduce a cycle or a cross-subsystem edge.
- `test/lib/subagent-tree/module-boundary.test.ts` (no `vscode` import under `src/lib/subagent-tree`) continues to pass.
- Multi-key comparison chains keep their key order and their `?? ""` defaults.
- The comparator returns exactly -1, 0, or 1.

### Dependencies or blocked work:

- PR #839 (#740) is merged into the base `e7d3779b`; no other blocking work.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production (research "Files Expected to Be Written"):
- New: `extensions/drm-copilot/src/lib/string-ordering.ts`.
- pr-context: `models.ts`, `verification-evidence.ts`, `feature-docs.ts`, `feature-docs-parsers.ts`, `render-pr-helpers.ts`, `render-feature-excerpts.ts`, `collector-core.ts`, `autoclose.ts`, `collector-output.ts`.
- codex-native-converter: `engine-pipeline.ts`, `reporting-render.ts`, `reporting.ts`, `validation.ts`, `intermediate-state.ts`, `inventory.ts`, `models.ts`, `pipeline.ts`, `pipeline-traces.ts`.
- push-down: `claude-blast-radius-derive-manifests.ts`, `claude-blast-radius-derive-core.ts`, `claude-blast-radius-overlay.ts`, `claude-blast-radius-derive.ts`, `filesystem-adapter.ts`, `copilot-customizations-engine.ts`.
- subagent-tree: `tree-assembler.ts`, `quick-pick-labels.ts`.

Tests:
- New: `extensions/drm-copilot/test/lib/string-ordering.test.ts`.
- Updated: `test/lib/pr-context/models.test.ts` (remove moved `compareCodePoint` blocks; keep `sortedSet` tests).
- Consumer regression tests in files with headroom under 500 lines, for example `test/lib/codex-native-converter/inventory.test.ts`, `test/lib/push-down/blast-radius-derive-manifests.test.ts`, `test/lib/subagent-tree/tree-assembler.test.ts`, `test/lib/subagent-tree/quick-pick-labels.test.ts`, and a new `test/lib/pr-context/collector-output-ordering.test.ts` (because `collector-output.test.ts` is at 485 lines).

Config:
- `extensions/drm-copilot/jest.config.cjs`.

#### Functions/classes/CLI commands impacted:

- Added: `compareCodePoint` in `string-ordering.ts`.
- Removed: `compareCodePoint` from `pr-context/models.ts`; `compareStrings` (two module-private copies); local `compare` arrows in `sortFindings` and `validateConversionPlan`; exported `compareOrdinal`.
- Body changes only: `compareByAgentId`, `compareCandidates`, `sortBySourcePath`, `sortFindings`, `renderVerificationEvidenceSection`, `sortKeysDeep` (two modules), `normalizeSelectedPaths`, `iterSupportedArtifacts`, `discoverSourceArtifacts`, `sourceArtifactToJson`, `validateConversionPlan`, `RealPushDownFileSystem.listFiles`, `realDirectoryLister`, `enumerateSourceFiles`, `stringifySorted`, and the sort callbacks in `pipeline.ts` and `pipeline-traces.ts`.
- No CLI command changes.

#### Data flow and validation changes:

None, other than the ordering change described under Backward-compatibility expectations.

#### Error handling and logging updates:

None. The comparator is total and does not throw.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. Rollback is a revert of the change set.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

`compareCodePoint(left: string, right: string): number` satisfies all of the following for every pair of JavaScript strings, including strings containing unpaired surrogates:

- Returns exactly -1, 0, or 1.
- Returns 0 if and only if `left === right`.
- Antisymmetric: `compareCodePoint(a, b) === -compareCodePoint(b, a)`.
- Transitive: a consistent strict total order suitable for `Array.prototype.sort`.
- A proper prefix sorts before the longer string.
- For well-formed strings, the result equals Unicode code-point order (the order Python applies to `str`).

The spec does not prescribe the algorithm. A UTF-16 code-unit comparison with surrogate fix-up (mapping code units 0xD800-0xDFFF above 0xE000-0xFFFF before comparing) is one approach that satisfies this contract.

#### Required configuration keys and defaults:

`jest.config.cjs` `coverageThreshold` gains `"./src/lib/string-ordering.ts": { lines: 85, branches: 75 }`. Whether the 12 changed files that currently lack a per-file entry (research section 4) receive entries is a plan decision based on a captured coverage baseline.

#### Backward-compatibility expectations:

- Intended ordering change: at sites that previously used UTF-16 code-unit order, a supplementary character now sorts after a BMP character in U+E000..U+FFFF at the first differing position. All other inputs, including ASCII and BMP below U+D800, produce the same sign as before.
- For pr-context sites, behavior on well-formed strings is unchanged; behavior on strings with unpaired surrogates becomes consistent.
- Removal of exported `compareOrdinal` is a breaking change to an in-repo-only symbol; every in-repo caller is updated in the same change.
- No committed fixture or expected output changes (Decision 5).

#### Performance constraints (latency/throughput/memory):

No new constraint. The comparator remains a single linear pass without allocation.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - Inputs reaching these comparators (file paths, JSON keys, agent IDs) are well-formed in practice; the unpaired-surrogate contract exists for sort consistency, not because such inputs are known to occur.
  - Line numbers are from base `e7d3779b`; a concurrent merge may shift them.
- Constraints (budget, performance, compatibility):
  - No file exceeds 500 lines. `models.test.ts`, `collector-output.test.ts`, `blast-radius-derive.test.ts`, and `claude-blast-radius-overlay.test.ts` are within 52 lines of the cap.
  - Tests for this extension live under `extensions/drm-copilot/test/` (`jest.config.cjs` `testMatch: ["**/test/**/*.test.ts"]`), mirroring `src/`.
  - Temporary files in tests are prohibited; sites reachable only through the real filesystem (I12, I13) are covered by the structural search in AC-1 rather than by order tests.
  - `extensions/drm-copilot` is T3 in `quality-tiers.yml`; property-test density is not required, and `fast-check` is not a dependency. The enumerative fixed-domain property style from `models.test.ts` is reused.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact

- User-facing or API changes: ordering of converter reports, push-down manifests and overlays, and subagent-tree views changes only for the supplementary-versus-U+E000..U+FFFF case, bringing TypeScript into agreement with the Python twins.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): `compareOrdinal` export removed (in-repo only).

## Test Strategy

Seeded from issue (status after research):

- [ ] Coordinate with #740 so one shared comparator and one contract statement cover `pr-context/` and the modules above. (Addressed by Decisions 1-3; #740 merged as PR #839.)
- [ ] Replace the named copies and inline expressions with the shared comparator, keeping the existing sort order. (Superseded for the supplementary-versus-U+E000..U+FFFF case by Decision 1.)
- [ ] Keep converter and push-down output unchanged; existing golden or parity suites must pass without modification. (Retained as Decision 5 and AC-6.)

- Regression tests to add or update: consumer-level tests per module family asserting that a value beginning with a supplementary character (for example `"\u{1F600}"` or `"\u{10000}"`) sorts after a value beginning with a BMP character in U+E000..U+FFFF (for example `""` or `"￿"`). These fail under the code-unit copies and pass after the change.
- Unit tests for the fixed behavior and boundaries (Jest): moved `compareCodePoint` suites (unit cases, enumerative reflexive/antisymmetric/transitive/range properties, #740 D/S/A cases) plus new cases for unpaired surrogates, including the research triple.
- Edge cases and negative scenarios: empty strings, proper prefixes, equal strings, lone high surrogate, lone low surrogate, high surrogate followed by U+E000, surrogate pair versus U+FFFF.
- Error handling and logging verification: not applicable (no error paths).
- Coverage impact and targets for changed lines/modules: line >= 85% and branch >= 75% on `string-ordering.ts` and on every changed production file; no coverage regression on changed lines.
- Toolchain commands to run (format, lint, type-check, test), from `extensions/drm-copilot`: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:coverage`. The architecture-boundary stage is not applicable (no dependency-cruiser configuration); `module-boundary.test.ts` runs within Jest.
- Parity suites run unchanged: `test/lib/push-down/claude-blast-radius-overlay-parity.test.ts` and `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py`.
- Manual validation steps: none.

## Acceptance Criteria

- [ ] AC-1: Single definition. `extensions/drm-copilot/src/lib/string-ordering.ts` exists, exports `compareCodePoint(left: string, right: string): number`, and contains no `import` statement. Verified by: (a) `git grep -nE "function compareCodePoint|const compareCodePoint" -- extensions/drm-copilot/src` returns exactly one match, in `string-ordering.ts`; (b) `git grep -nE "\bcompareStrings\b|\bcompareOrdinal\b" -- extensions/drm-copilot/src` returns no matches; (c) `git grep -nE "^\s*import\b" -- extensions/drm-copilot/src/lib/string-ordering.ts` returns no matches.
- [ ] AC-2: No remaining ordinal string comparator copies. The research primary query `rg -n "(\?\s*1\s*:\s*-1|return\s+-1|\?\s*-1\b)" extensions/drm-copilot/src`, together with the multiline query `rg -nU "if\s*\([^()]*\s<\s[^()]*\)\s*\{?\s*return\s+-1" extensions/drm-copilot/src`, returns matches only in `src/lib/string-ordering.ts` or at the numeric-comparator sites enumerated in research section 1.5. Each of the 24 inventoried sites (N1-N6, I1-I16, G1, G2) and `pr-context/collector-output.ts:112-118` calls `compareCodePoint` imported from the shared module.
- [ ] AC-3: Direct imports, no re-export. Every production import of `compareCodePoint` under `extensions/drm-copilot/src` resolves to `string-ordering` (`git grep -n "compareCodePoint" -- extensions/drm-copilot/src` shows every `import` line referencing a `string-ordering` path), `pr-context/models.ts` neither defines nor re-exports it, and the `models.ts` module header no longer lists it.
- [ ] AC-4: Shared comparator unit tests. `extensions/drm-copilot/test/lib/string-ordering.test.ts` passes and contains named tests covering: equal strings (returns 0); empty and proper-prefix strings (prefix sorts first); BMP-only ordering; a supplementary character versus U+E000 and versus U+FFFF (supplementary sorts last); results restricted to -1, 0, 1; antisymmetry; and enumerative reflexive/antisymmetric/transitive checks over a fixed domain that includes a lone high surrogate, a lone low surrogate, a high surrogate followed by U+E000, U+E000, U+FFFF, and a supplementary character. The domain includes the research triple `"\u{10000}"`, `"\uD800"`, `""` and the transitivity check passes on it. A test also asserts that, for well-formed strings in the domain, the result equals the order of their code-point sequences.
- [ ] AC-5: Consumer regression tests. At least one named test per consumer module family passes and asserts code-point order on a supplementary-versus-U+E000..U+FFFF input through the consumer's own function: codex-native-converter (for example `normalizeSelectedPaths` in `test/lib/codex-native-converter/inventory.test.ts`), push-down (for example `classifyProjectDirectories` in `test/lib/push-down/blast-radius-derive-manifests.test.ts` or `stringifySorted` in `test/lib/push-down/copilot-customizations-engine.test.ts`), subagent-tree (`compareByAgentId` via `test/lib/subagent-tree/tree-assembler.test.ts` and the `compareCandidates` path tiebreak via `test/lib/subagent-tree/quick-pick-labels.test.ts`), and pr-context (`renderVerificationEvidenceSection` in a test file with headroom, for example `test/lib/pr-context/collector-output-ordering.test.ts`). Fail-first evidence showing each new consumer test failing against the pre-change code is recorded under the feature folder's `evidence/` tree.
- [ ] AC-6: No expected-output changes. All pre-existing Jest tests in `extensions/drm-copilot` pass, and `git diff <base>...HEAD -- extensions/drm-copilot/test tests/fixtures` shows no modified expected value in any pre-existing assertion or fixture; the only removals are the `compareCodePoint` describe blocks moved out of `test/lib/pr-context/models.test.ts`. `test/lib/push-down/claude-blast-radius-overlay-parity.test.ts` and `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py` pass unchanged.
- [ ] AC-7: Coverage configuration. `extensions/drm-copilot/jest.config.cjs` `coverageThreshold` contains `"./src/lib/string-ordering.ts": { lines: 85, branches: 75 }`.
- [ ] AC-8: Full TypeScript toolchain passes in a single pass from `extensions/drm-copilot`: `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:coverage` complete without errors and without auto-fixing files.
- [ ] AC-9: Coverage targets. The `npm run test:coverage` report shows line coverage >= 85% and branch coverage >= 75% for `src/lib/string-ordering.ts` and for every changed production file, and no changed file's line or branch coverage is lower than its baseline captured before the change.
- [ ] AC-10: File size and test location. No production or test file added or changed by this work exceeds 500 lines (verified by a line count over `git diff --name-only <base>...HEAD -- extensions/drm-copilot/src extensions/drm-copilot/test`), and every added test file is under `extensions/drm-copilot/test/`, mirroring the `src/` path of the module under test.

## Risks & Mitigations

- Technical or operational risks:
  - The corrected algorithm could change pr-context ordering on well-formed strings. Mitigation: the moved #740 D/S/A cases and the well-formed equivalence check in AC-4.
  - Changed files without per-file coverage entries may be below 85/75 at baseline. Mitigation: capture a coverage baseline before changes; the plan decides on entries from that baseline.
  - Default `.sort()` sites in push-down and subagent-tree keep UTF-16 code-unit order, so two orderings coexist in those subsystems. Inputs are ASCII identifiers in practice. Mitigation: recorded as a follow-up.
  - Line-number drift from concurrent merges. Mitigation: AC-1 and AC-2 are search-based, not line-based.
- Mitigations and rollbacks: revert the change set; no data or configuration migration is involved.

## Rollout & Follow-up

- Release/rollout steps: ships with the next extension build; no staged rollout.
- Post-fix monitoring or clean-up tasks:
  - Follow-up (no issue filed in this run): decide whether argument-less `.sort()` calls in `push-down/` (`claude-pack-selection.ts:117, 299`; `codex-pack-selection.ts:66, 71, 100, 108, 232`), `subagent-tree/` (`tree-assembler.ts:186`, `tree-formatter.ts:29`), and the seven sites under `validate/` and `resolve/` should use `compareCodePoint`.
- Links: issue #796; related #716, #740 (PR #839); research `research/research.2026-10-08T21-30.md`.
