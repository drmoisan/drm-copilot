# compare-code-point-helper-duplicated (Spec)

- **Issue:** #716
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T00-30
- **Status:** Draft
- **Version:** 0.2

## Context

- Summary of the bug and its impact: `compareCodePoint`, a two-line Unicode code-point string comparator, is defined independently in multiple files under `extensions/drm-copilot/src/lib/pr-context/` instead of being defined once and imported. Issue #622 (PR #703) added a further copy in `autoclose.ts`, compounding a pre-existing duplication and violating the reusability principle in `.claude/rules/general-code-change.md` (Design Principles item 2). The duplication creates a risk that the copies drift independently, which would change ordering behavior in PR-context output inconsistently across modules.
- Observed environment(s): any; TypeScript source, no runtime/OS dependency.
- Customer impact and severity: low. No observed behavior defect today — all copies are currently byte-identical — but the duplication is a latent maintenance risk.
- First observed date and version(s) impacted: reported in code review NB-4 for issue #622 (`code-review.2026-09-26T21-25.md`); intake for this issue is 2026-09-27, against `origin/main@2dce111e`.

## Repro & Evidence

- Steps to reproduce: run a search for the regex `^(export )?function compareCodePoint\(` under `extensions/drm-copilot/src/lib/pr-context/`.
- Expected vs actual behavior: expected one definition, exported from a single shared module; actual is eight separate definitions across eight files, two of which (`feature-docs-parsers.ts`, `gh-client-details.ts`) are independently exported without reaching the package's public barrel (`index.ts`).
- Logs/screenshots/error snippets: not applicable — this is a static duplication defect, not a runtime failure.
- Frequency / determinism: deterministic and always present in the current source tree; confirmed by two independent, exhaustive search strategies documented in `docs/features/active/compare-code-point-helper-duplicated-716/research/research.2026-09-27T00-30.md` section 1.1 (Numeric Derivation Evidence).

## Scope & Non-Goals

- In scope: consolidating `compareCodePoint` to a single definition in `extensions/drm-copilot/src/lib/pr-context/models.ts`, updating every consumer under `extensions/drm-copilot/src/lib/pr-context/` to import from it, and removing all other definitions (including the two `export` keywords) within that directory only.
- Out of scope / non-goals: the differently named comparator copies (`compareStrings`, inline `compare`, `compareOrdinal`, and other inline sort comparators) found under `extensions/drm-copilot/src/lib/codex-native-converter/` and `extensions/drm-copilot/src/lib/push-down/` (research section 3). These are a distinct, larger duplication pattern with different function names, in different feature directories, and are recorded here only as a follow-up observation, not remediated by this fix.
- Explicitly excluded systems, integrations, or datasets: no `mcp-server` or `resources/` mirrored copy exists for this function (research sections 1.3 and 6); no cross-language (Python) analog exists (`dev_tools/pr_context/*.py` uses the built-in `sorted()`, not a custom comparator). No file under `docs/features/parallel/` is written by this change.

## Root Cause Analysis

- Current hypothesis or confirmed root cause: confirmed. `compareCodePoint` was never factored into the shared `models.ts` module when the `pr-context/` port was authored, so each module that needed code-unit string ordering defined its own private copy. Issue #622 (PR #703) added a ninth call site's worth of need but, following the existing (defective) local pattern, added a ninth private definition (`autoclose.ts`) instead of importing a shared one, which is what surfaced the pattern in code review.
- Signals/evidence supporting it: research section 1.1 documents eight byte-identical definitions (not the seven the issue text originally estimated) across `collector-core.ts`, `feature-docs-parsers.ts` (exported), `autoclose.ts`, `gh-client-details.ts` (exported), `render-feature-excerpts.ts`, `render.ts`, `render-pr-helpers.ts`, and `verification-evidence.ts`, all with the identical body and JSDoc reproduced in research section 1.2.
- Affected components/modules (paths): the eight files above, plus `feature-docs.ts` (imports and re-exports `compareCodePoint` from `feature-docs-parsers.ts` without itself defining it) and `models.ts` (the designated host module, currently missing the definition).

## Proposed Fix

### Design summary (what changes where):

Define `compareCodePoint` exactly once, exported, in `extensions/drm-copilot/src/lib/pr-context/models.ts`, placed among its other exported pure string helpers. Remove all eight existing private/exported definitions (and their preceding JSDoc comments) from `collector-core.ts`, `autoclose.ts`, `feature-docs-parsers.ts`, `gh-client-details.ts`, `render.ts`, `render-pr-helpers.ts`, `render-feature-excerpts.ts`, and `verification-evidence.ts`. Update each file's import list to bring in `compareCodePoint` from `./models` (seven of the eight files already import from `./models`; `verification-evidence.ts` gains a new `./models` import). Update `feature-docs.ts` to import `compareCodePoint` from `./models` instead of `./feature-docs-parsers`, and remove its now-orphaned re-export of `compareCodePoint`.

### Boundaries and invariants to preserve:

- The comparator's body, JSDoc text, and return values (-1, 0, 1) are preserved byte-for-byte (research section 1.2). No localeCompare substitution, no whitespace/case normalization, no signature change.
- No import cycle is introduced: `models.ts` imports only `{ type CommandResult }` from `../subprocess-runner`, none of the eight consumer files, so adding the reverse edges from those files to `models.ts` cannot create a cycle (research section 2.1).
- The package's public barrel (`extensions/drm-copilot/src/lib/pr-context/index.ts`) does not currently re-export `compareCodePoint` and continues not to; this change does not alter the package's public API surface.

### Dependencies or blocked work:

None. No new npm dependency is added (see Design Decisions, D4).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- `extensions/drm-copilot/src/lib/pr-context/models.ts` — add the exported `compareCodePoint` function (host module).
- `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` — remove the private definition; import `compareCodePoint` from `./models`.
- `extensions/drm-copilot/src/lib/pr-context/autoclose.ts` — remove the private definition; import `compareCodePoint` from `./models`.
- `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts` — remove the exported definition and its `export` keyword; import `compareCodePoint` from `./models`.
- `extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts` — remove the exported definition and its `export` keyword; import `compareCodePoint` from `./models`.
- `extensions/drm-copilot/src/lib/pr-context/render.ts` — remove the private definition; import `compareCodePoint` from `./models`.
- `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts` — remove the private definition; import `compareCodePoint` from `./models`.
- `extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts` — remove the private definition; import `compareCodePoint` from `./models`.
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` — remove the private definition; add a new `./models` import for `compareCodePoint`.
- `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts` — change its `compareCodePoint` import source from `./feature-docs-parsers` to `./models`; remove its unused re-export of `compareCodePoint`.
- `extensions/drm-copilot/test/lib/pr-context/models.test.ts` — add a `describe("compareCodePoint", ...)` block covering the moved function.

No other file is written by this change. No file under `docs/features/parallel/` is touched.

#### Functions/classes/CLI commands impacted:

- `compareCodePoint(left: string, right: string): number` — relocated, not behaviorally changed. All call sites (`.sort(compareCodePoint)` and equivalent usages) are unaffected because the imported binding has the identical name and signature.

#### Data flow and validation changes:

None. This is a structural (location-of-definition) change with no change to inputs, outputs, or control flow of any caller.

#### Error handling and logging updates:

None. `compareCodePoint` has no error paths today and none are introduced.

#### Rollback/feature-flag considerations (if applicable):

Not applicable. The change is a pure refactor (move + import redirection) with an identical function body; rollback is a straightforward revert of the commit(s).

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

`compareCodePoint(left: string, right: string): number` returns `-1` when `left < right`, `1` when `left > right`, and `0` otherwise, using JavaScript's native `<`/`>` string comparison (UTF-16 code-unit order). Unchanged from today.

#### Required configuration keys and defaults:

None.

#### Backward-compatibility expectations:

No external or in-repo importer of the two currently-exported copies (`feature-docs-parsers.ts`, `gh-client-details.ts`) exists today (research section 1.3): the package barrel `index.ts` does not re-export `compareCodePoint`, and no test file imports it directly. Removing both `export` keywords therefore breaks no known caller. `feature-docs.ts`'s existing re-export of `compareCodePoint` also has no consumer and is removed; if a consumer is discovered during implementation, that consumer's import is updated to `./models` instead.

#### Performance constraints (latency/throughput/memory):

None applicable; the function is unchanged and O(1) per comparison.

## Design Decisions

1. **D1 — Host module.** Options considered: (a) `extensions/drm-copilot/src/lib/pr-context/models.ts`; (b) a new dedicated module (e.g., `pr-context/compare.ts`); (c) keep the definition in one of the two currently-exporting files (`feature-docs-parsers.ts` or `gh-client-details.ts`). Adopted: (a) `models.ts`. Rationale: `models.ts` already states its purpose as holding "the structured records and pure string helpers shared across the pr-context port" and already exports seven other pure functions; 7 of the 8 files that currently define `compareCodePoint` already import from `models.ts`, so consolidating there widens an existing edge rather than adding a new one for all but `verification-evidence.ts`; it introduces no import cycle (`models.ts` only imports from `../subprocess-runner`); and it matches the issue's own suggested location. A new dedicated module would require every consumer to open a new import edge and would duplicate `models.ts`'s stated role, contrary to `.claude/rules/general-code-change.md` Design Principle 1 (simplicity first). Keeping the function in `feature-docs-parsers.ts` or `gh-client-details.ts` is a poor conceptual fit for unrelated render/collector consumers and would route them through a GitHub-CLI-specific or feature-doc-parsing-specific file for no domain reason.

2. **D2 — Function body.** Options considered: (a) keep the existing body byte-identical (`<`/`>` code-unit comparison, returning -1/1/0); (b) replace with `String.prototype.localeCompare`; (c) otherwise alter comparison semantics. Adopted: (a). Rationale: this is a duplication-removal fix, not a behavior change. PR-context output ordering depends on the exact current code-unit semantics; `localeCompare` or any other semantic change would alter sort order for non-ASCII input and is out of scope for this issue.

3. **D3 — Former exporters.** Options considered: (a) remove the definitions and the `export` keyword from `feature-docs-parsers.ts` and `gh-client-details.ts`, replacing them with an import from `models.ts`; (b) keep the definitions in place as re-exports of the `models.ts` implementation. Adopted: (a). Rationale: research found no external importer of either export and confirmed the package barrel `index.ts` does not re-export `compareCodePoint`, so a re-export shim would add indirection with no consumer to serve, contrary to simplicity-first design. `feature-docs.ts` is updated to import `compareCodePoint` from `models.ts` directly, and its own unused re-export of `compareCodePoint` is removed. If a consumer of either removed export or the `feature-docs.ts` re-export is found during implementation, that consumer's import is updated to source `compareCodePoint` from `models.ts` instead.

4. **D4 — Property-based test dependency.** Options considered: (a) add `fast-check` as a new devDependency of `extensions/drm-copilot` (the researcher's recommendation, since `.claude/rules/typescript.md` and `.claude/rules/general-unit-test.md` name `fast-check` as the repository's designated TypeScript property-testing library); (b) write a deterministic enumerative property test using plain Jest over a fixed, generated domain, adding no new dependency. Adopted: (b). Rationale: `.claude/rules/general-code-change.md` ("Dependencies") requires using only already-approved libraries unless explicitly told to add more, and `fast-check` is not currently installed anywhere in this repository (confirmed by an exhaustive grep of `package.json` files and the full worktree). Adding it here would also change `package.json`/`package-lock.json`, widening the change's blast radius and creating lockfile merge-order coupling with sibling in-flight items in the same parallel run (issues #706-#716 touching overlapping files per research section 7). The enumerative test instead asserts, over all ordered pairs and triples drawn from a fixed list of strings (including the empty string, ASCII strings, case variants, prefix relationships, a BMP non-ASCII character, and an astral surrogate-pair character), the properties: reflexivity (`compare(a, a) === 0`), antisymmetry (`sign(compare(a, b)) === -sign(compare(b, a))`), transitivity, result-set membership in `{-1, 0, 1}`, and agreement with JavaScript's native `<`/`>` operators; and separately asserts that `Array.prototype.sort` using `compareCodePoint` yields code-unit order for a mixed sample of the fixed domain.

5. **D5 — Test location.** Options considered: (a) add a `describe("compareCodePoint", ...)` block to the existing `extensions/drm-copilot/test/lib/pr-context/models.test.ts`, following its existing Arrange-Act-Assert style; (b) create a new standalone test file. Adopted: (a). Rationale: `models.test.ts` already groups one `describe`/`it` block per pure function exported from `models.ts` using plain Jest and Arrange-Act-Assert structure; adding `compareCodePoint` there follows the established per-file test convention rather than introducing a new file for a single function.

6. **D6 — Scope.** Options considered: (a) limit remediation to `extensions/drm-copilot/src/lib/pr-context/`; (b) also consolidate the differently named comparator copies (`compareStrings`, inline `compare`, `compareOrdinal`, and other inline sort comparators) found under `codex-native-converter/` and `push-down/`. Adopted: (a). Rationale: issue #716's scope, spec header, and draft acceptance criteria are explicitly limited to `pr-context/`; the other copies use different function names, live in different feature directories, and were not part of the reported defect. They are recorded in this spec's Scope & Non-Goals section as a follow-up observation only, not remediated here.

7. **D7 — Merge-order independence.** Options considered: (a) locate every source edit by line number; (b) locate every source edit by text anchor (the full `function compareCodePoint` signature/body text for removals, and existing import-statement text for additions). Adopted: (b). Rationale: `extensions/drm-copilot/src/lib/pr-context/` files are concurrently edited by several other active features (research section 7: issues touching `autoclose.ts`, `render-pr-helpers.ts`, `render.ts`, `collector-core.ts`, `models.ts`, and the `gh-client-*` family). Anchoring removals on the full, byte-identical function-body text and anchoring import edits on existing `from "./models"` import blocks (or, for `verification-evidence.ts`, on its sole existing import line) ensures each edit applies correctly regardless of line-number drift from a sibling branch. A file found to no longer contain a private copy of `compareCodePoint` at execution time (because a sibling branch already consolidated it) is treated as already satisfied for that file, not as an execution failure.

8. **D8 — Count discrepancy.** Options considered: (a) treat only the seven copies the issue text originally reported as in scope; (b) treat all copies found by exhaustive search at execution time as in scope. Adopted: (b). Rationale: the issue's draft count of seven is superseded by two independent, exhaustive search strategies documented in the research record (section 1.1: a declaration-anchored regex search and a JSDoc-comment-anchored search, both returning the identical 8-file member set: `collector-core.ts`, `autoclose.ts`, `feature-docs-parsers.ts`, `gh-client-details.ts`, `render-pr-helpers.ts`, `render.ts`, `render-feature-excerpts.ts`, `verification-evidence.ts`). This spec treats all eight as in scope rather than anchoring to the issue's original, superseded estimate.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access): the eight definitions remain byte-identical at implementation time, consistent with research section 1.2. If a sibling in-flight branch has altered one copy's body before this fix lands, the discrepancy is resolved in favor of the currently-merged body at implementation time, and the divergence is noted in the PR description.
- Constraints (budget, performance, compatibility): no new npm dependency (D4); no change to the package's public API surface (`index.ts` barrel unaffected); no file exceeds the 500-line cap (research section 5 confirms all affected files remain well under the limit after this change).
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact

- User-facing or API changes: none. `compareCodePoint` is not part of the package's public barrel (`index.ts`) today and remains excluded from it.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): none. `package.json` and `package-lock.json` for `extensions/drm-copilot` are unchanged by this fix.

## Test Strategy

- Regression tests to add or update: add a `describe("compareCodePoint", ...)` block to `extensions/drm-copilot/test/lib/pr-context/models.test.ts` (D5) covering hand-picked boundary cases (equal strings, single-character ordering, empty-string comparisons, case sensitivity) plus the deterministic enumerative property test described in D4 (reflexivity, antisymmetry, transitivity, result-set membership in `{-1, 0, 1}`, agreement with native `<`/`>`, and `Array.prototype.sort` code-unit ordering over a fixed domain including a BMP non-ASCII character and an astral surrogate-pair character).
- Unit tests for the fixed behavior and boundaries: covered by the `models.test.ts` additions above; no other new test files are added.
- Edge cases and negative scenarios: empty string vs. non-empty string, identical strings, case-variant strings, prefix-relationship strings (e.g., `"a"` vs. `"ab"`), a BMP non-ASCII character, and an astral (surrogate-pair) character — all included in the fixed domain used by the enumerative property test (D4).
- Error handling and logging verification: not applicable; `compareCodePoint` has no error paths.
- Coverage impact and targets for changed lines/modules: `models.ts` already carries a per-file `coverageThreshold` entry in `jest.config.cjs` (`lines: 85, branches: 75`); the added function and its tests must keep `models.ts` at or above that threshold. The seven other source files lose lines (a net decrease) and must not regress their existing measured coverage. `verification-evidence.ts` has no per-file threshold today; its measured coverage must not regress as a result of removing its private copy and adding an import.
- Toolchain commands to run (format → lint → type-check → test): run Prettier, ESLint, `tsc`, then Jest with coverage, in that order, per `.claude/rules/typescript.md` and the seven-stage toolchain loop in `.claude/rules/general-code-change.md`. Dependency-cruiser (architecture-boundary stage) has no configuration file anywhere in this repository (research section 4); this is a pre-existing, previously documented gap (per the #622 code review's NB-9 finding) and not something this fix introduces or must remediate.
- Manual validation steps (if required): none beyond the automated toolchain; run the full existing `extensions/drm-copilot/test/lib/pr-context/` suite as regression evidence that PR-context output ordering is unchanged.

## Acceptance Criteria

- [ ] A search for `function compareCodePoint` under `extensions/drm-copilot/src/lib/pr-context/` returns exactly one match, in `extensions/drm-copilot/src/lib/pr-context/models.ts`, and it is exported.
- [ ] Every module under `extensions/drm-copilot/src/lib/pr-context/` that uses `compareCodePoint` (`collector-core.ts`, `autoclose.ts`, `feature-docs-parsers.ts`, `gh-client-details.ts`, `render.ts`, `render-pr-helpers.ts`, `render-feature-excerpts.ts`, `verification-evidence.ts`, `feature-docs.ts`) imports it from `./models`; no private copy or independent `export` of `compareCodePoint` remains outside `models.ts`.
- [ ] The shared helper's body is byte-identical to the pre-existing implementation (code-unit ordering, returning -1, 0, or 1 via `<`/`>` comparison, no `localeCompare` substitution).
- [ ] `compareCodePoint` is covered by a unit test in `extensions/drm-copilot/test/lib/pr-context/models.test.ts`, including a deterministic enumerative property test (no new npm dependency added) verifying reflexivity, antisymmetry, transitivity, result-set membership in `{-1, 0, 1}`, agreement with native `<`/`>` operators, and correct `Array.prototype.sort` ordering, over a fixed domain including empty string, ASCII, case variants, prefix relationships, a BMP non-ASCII character, and an astral surrogate-pair character.
- [ ] The existing `extensions/drm-copilot/test/lib/pr-context/` Jest test suites pass unmodified, with no changes to expected output (PR-context output ordering is unchanged).
- [ ] `tsc` (TypeScript type-check) passes with zero errors.
- [ ] ESLint passes with zero errors.
- [ ] Prettier formatting check passes with no reformatting required.
- [ ] Jest coverage for `models.ts` meets its configured per-file threshold in `jest.config.cjs` (`lines: 85, branches: 75`), with no coverage regression on changed lines in any of the eight files losing their private definition.
- [ ] `extensions/drm-copilot/package.json` and `extensions/drm-copilot/package-lock.json` are unchanged by this fix (no new dependency added, per Design Decision D4).

## Risks & Mitigations

- Technical or operational risks: a sibling in-flight branch (research section 7: issues touching `autoclose.ts`, `render-pr-helpers.ts`, `render.ts`, `collector-core.ts`, `models.ts`, `gh-client-details.ts`, `gh-client-core.ts`) may modify one of the eight affected files concurrently, shifting line numbers or altering surrounding code before this fix merges.
- Mitigations and rollbacks: every edit is anchored on stable text (the full function-body text for removals, existing import-statement text for additions), not line numbers, per Design Decision D7. If a file no longer contains a private `compareCodePoint` copy at implementation time because a sibling branch already consolidated it, that file is treated as already satisfied, not as a failure. Rollback is a straightforward revert, since the function body itself is unchanged.

## Rollout & Follow-up

- Release/rollout steps: standard PR merge; no feature flag, migration, or staged rollout is required for this internal refactor.
- Post-fix monitoring or clean-up tasks: none required by this fix. A separate follow-up issue may be filed to consolidate the differently named comparator copies (`compareStrings`, inline `compare`, `compareOrdinal`, and other inline sort comparators) under `extensions/drm-copilot/src/lib/codex-native-converter/` and `extensions/drm-copilot/src/lib/push-down/` (research section 3); this spec does not create that issue.
- Links: issue #716; code review NB-4 for issue #622 (`code-review.2026-09-26T21-25.md`); research record `docs/features/active/compare-code-point-helper-duplicated-716/research/research.2026-09-27T00-30.md`.
