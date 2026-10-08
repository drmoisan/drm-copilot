# Feature Audit: pr-context helper consolidation and code-point ordering (#740)

**Audit Date:** 2026-10-08
**Feature Folder:** `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740`
**Base Branch:** `main`
**Head Branch:** `bug/pr-context-helper-duplication-and-vacuous-tests-740`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `6dac65b0930b299dc7b3c3925a607735a05fca35`)
- **Head branch/commit:** `bug/pr-context-helper-duplication-and-vacuous-tests-740` (commit `0c3f5aab4300b0bb07c1a1c92c8af939b7ac4699`, pushed)
- **Merge base:** `6dac65b0930b299dc7b3c3925a607735a05fca35` (confirmed with `git merge-base HEAD origin/main`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-08 06:59:55 UTC at head `0c3f5aab`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/evidence/**` (index: `evidence/other/small-audit-handoff.2026-10-08T02-38.md`)
  - Additional evidence: reviewer re-runs of Prettier, ESLint, TypeScript, and pr-context Jest at HEAD; reviewer parse of `extensions/drm-copilot/coverage/lcov.info`; reviewer Node evaluation of the pre-fix comparator.
- **Feature folder used:** `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740`
- **Requirements source:** `issue.md` (`## Acceptance Criteria`, AC-1..AC-14)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: minor-audit`; the explicit `## Acceptance Criteria` section is present.
- **Scope note:** Full branch diff (48 files: 11 code/config, 37 Markdown). The local `main` ref is behind `origin/main`; the caller-supplied merge-base `6dac65b0` matches `origin/main` and was used throughout.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/issue.md` — only source (minor-audit)

### Acceptance criteria

Paths are relative to `extensions/drm-copilot/`. In AC-2, AC-3, and AC-5 the source file contains raw U+FFFF and U+E000 characters; they are written below as `\uFFFF` and `\uE000`.

1. AC-1: `compareCodePoint` in `src/lib/pr-context/models.ts` orders strings by Unicode code point (matching Python `str` comparison), and its JSDoc states that contract. New fixed-order tests in `test/lib/pr-context/models.test.ts` fail against the pre-fix UTF-16 code-unit implementation and pass after the fix.
2. AC-2: `test/lib/pr-context/models.test.ts` asserts literal expected results for the non-BMP disagreement pairs `"\uFFFF"` vs `"\u{1F600}"`, `"\uE000"` vs `"\u{10000}"`, and a shared-prefix pair, plus agreement pairs for lead-surrogate and trail-surrogate differences.
3. AC-3: `test/lib/pr-context/models.test.ts` contains a fixed-order sort test whose expected array is a literal (`["", "A", "a", "ab", "b", "é", "\uE000", "\uFFFF", "\u{1F600}"]`) and is not derived from the `<` or `>` operators.
4. AC-4: The two vacuous tests ("agrees with the native < and > operators..." and "produces the same order as native comparison via Array.prototype.sort...") are removed, and no test in `test/lib/pr-context/models.test.ts` derives its expected value from the string `<` or `>` operators.
5. AC-5: The antisymmetry and transitivity tests report the offending pair(s) on failure (violations array or `it.each` titles), and the enumerative domain includes `"\uE000"` and `"\uFFFF"`.
6. AC-6: Each of `sortedSet`, `relativeToPosix`, `escapeRegExp`, and `splitLines` is defined exactly once under `src/lib/pr-context/`: `sortedSet`, `escapeRegExp`, and `splitLines` exported from `models.ts`, and `relativeToPosix` exported from `feature-docs-parsers.ts`. All former private copies are removed and their callers import the canonical definition.
7. AC-7: `test/lib/pr-context/models.test.ts` has direct tests for `sortedSet`, `escapeRegExp`, and `splitLines`; `test/lib/pr-context/feature-docs.test.ts` has direct tests for `relativeToPosix`, including a Windows-style root and a path outside the root.
8. AC-8: The `splitLines` JSDoc states the supported terminators (`\r\n`, `\r`, `\n`) and that they are a subset of the Python `str.splitlines()` boundaries.
9. AC-9: The `models.ts` header comment lists `splitLines`, `compareCodePoint`, `sortedSet`, and `escapeRegExp`.
10. AC-10: `src/lib/pr-context/gh-client-details.ts` imports from `./models` in a single statement.
11. AC-11: All pre-existing tests under `test/lib/pr-context/` pass without changes to their expected outputs, demonstrating unchanged PR-context output for existing inputs.
12. AC-12: Prettier check, ESLint (`npm run lint`), and TypeScript (`npm run typecheck`) exit 0 from `extensions/drm-copilot/`.
13. AC-13: `npm run test:coverage` exits 0; every changed production file meets 85% line and 75% branch coverage, and `jest.config.cjs` carries a per-file threshold entry for each changed production file.
14. AC-14: No changed file exceeds 500 lines, and no file under `src/lib/codex-native-converter/`, `src/lib/push-down/`, or `src/lib/subagent-tree/` is modified.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 code-point order, JSDoc, fail-before/pass-after | PASS | `models.ts` lines 344-368: JSDoc "Compare two strings by Unicode code point, matching Python `str` comparison" and explanation of the UTF-16 difference; implementation compares `codePointAt` at the first differing unit. Fail-before 5 failed/4 passed (`evidence/regression-testing/ts-fail-before...`); pass-after 9 passed. Reviewer Node check: pre-fix `<`/`>` comparator returns `1` for D1-D4 (expected `-1`) and sorts U+1F600 before U+E000/U+FFFF in S1. | `git diff 6dac65b..HEAD -- .../models.ts`; `node -e "<pre-fix comparator on D1-D4, S1>"`; `npm --prefix extensions/drm-copilot run test -- test/lib/pr-context` | Fail-before evidence is executor-recorded; reviewer reproduced the discriminating inputs independently. |
| 2 | AC-2 literal disagreement and agreement pairs | PASS | D1 (`"\uFFFF"` vs `"\u{1F600}"`, both orders), D2 (`"\uE000"` vs `"\u{10000}"`), D4 (`"a\uFFFD"` vs `"a\u{1F600}"`, shared prefix), A2 (U+1F600 vs U+1F601, trail-surrogate difference), A3 (U+1F600 vs U+20000, lead-surrogate difference); all assert literal `-1`/`1`. | `git diff 6dac65b..HEAD -- .../models.test.ts` | D3 (U+FF5E) and A1/A4 are additional. |
| 3 | AC-3 literal fixed-order sort test | PASS | S1 expects `["", "A", "a", "ab", "b", "\u00E9", "\uE000", "\uFFFF", "\u{1F600}"]` as a literal array, matching the AC list (code points confirmed by reviewer Node inspection of `issue.md`). | Diff inspection | |
| 4 | AC-4 vacuous tests removed; no operator-derived expectations | PASS | Both titles absent; grep for `[a-z] < [a-z]`, `[a-z] > [a-z]`, `? -1 :`, and the two titles matches only a comment (line 245) and a violation-message template (line 255) in the transitivity test. | `grep -n -E "agrees with the native\|same order as native\|[a-z] < [a-z]\|[a-z] > [a-z]\|\? -1 :" .../models.test.ts` | |
| 5 | AC-5 diagnostics and domain | PASS | Antisymmetry and transitivity collect `violations` with `U+XXXX` descriptions and assert `toEqual([])`; `DOMAIN` contains `"\uE000"` and `"\uFFFF"` (11 elements). | Diff inspection | |
| 6 | AC-6 single definitions | PASS | Reviewer grep finds exactly four definitions: `models.ts:226 splitLines`, `models.ts:378 sortedSet`, `models.ts:389 escapeRegExp`, `feature-docs-parsers.ts:305 relativeToPosix`. All eight private copies removed in the diff; callers import from `./models` or `./feature-docs-parsers`. | `grep -rn "function (sortedSet\|relativeToPosix\|escapeRegExp\|splitLines)\b\|const (...)\b" extensions/drm-copilot/src/lib/pr-context` | Baseline had 12 definitions (`evidence/baseline/helper-definitions...`). |
| 7 | AC-7 direct helper tests | PASS | `models.test.ts`: `sortedSet` (5), `escapeRegExp` (3), `splitLines` (7). `feature-docs.test.ts`: `relativeToPosix` (5), including `C:\\repo\\` root and `/other/x.md` outside `/repo`. | `npm --prefix extensions/drm-copilot run test -- test/lib/pr-context` (409 passed) | |
| 8 | AC-8 `splitLines` JSDoc | PASS | "Supported terminators: `\r\n`, `\r`, and `\n`. These are a subset of the Python `str.splitlines()` line boundaries". | Diff inspection of `models.ts` | |
| 9 | AC-9 `models.ts` header | PASS | Header bullet: "Provide the shared pure helpers `splitLines`, `compareCodePoint`, `sortedSet`, and `escapeRegExp` (issue #740)". | Diff inspection | |
| 10 | AC-10 single `./models` import | PASS | `gh-client-details.ts` lines 18-23: one `import { findUserStoryLink, sortedSet, type IssueDetails, type PullRequestDetails } from "./models";`. | Diff inspection | |
| 11 | AC-11 pre-existing tests unchanged in expectations and passing | PASS | Reviewer run: 22 suites, 409 tests passed. `feature-docs.test.ts` diff is additive (43 added, 0 deleted). In `models.test.ts` the only pre-existing tests changed are the two removed by AC-4 and the antisymmetry/transitivity tests restructured by AC-5 (same property asserted); all other pre-existing tests are untouched. No other file under `test/lib/pr-context/` changed. | `npm --prefix extensions/drm-copilot run test -- test/lib/pr-context`; `git diff --name-only 6dac65b..HEAD` | The AC-4/AC-5 edits are required by those criteria and do not change PR-context output expectations. |
| 12 | AC-12 Prettier, ESLint, TypeScript exit 0 | PASS | Reviewer re-runs: Prettier "All matched files use Prettier code style!" (exit 0); `npm run lint` exit 0; `npm run typecheck` exit 0. | `npx --prefix extensions/drm-copilot prettier --check extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/package.json`; `npm --prefix extensions/drm-copilot run lint`; `npm --prefix extensions/drm-copilot run typecheck` | |
| 13 | AC-13 coverage run, per-file thresholds, threshold entries | PASS | Executor `test:coverage`-equivalent run exit 0, 3879 passed, no threshold failure (`evidence/qa-gates/ts-jest-coverage...`). Reviewer parse of `extensions/drm-copilot/coverage/lcov.info`: models 100/100, collector-core 98.43/92.31, render 99.73/92.31, gh-client-details 96.04/91.36, render-pr-helpers 87.08/94.29, verification-evidence 99.23/93.94, render-feature-excerpts 97.91/89.66, feature-docs-parsers 98.08/91.23 (lines%/branches%). `jest.config.cjs` has entries for all eight files (lines 33, 51, 55, 59, 63, 70, 74, 78). | `node <scratch>/lcov.cjs extensions/drm-copilot/coverage/lcov.info ...`; `grep -n "pr-context/" extensions/drm-copilot/jest.config.cjs` | Coverage not regenerated by the reviewer, per the review contract; artifact postdates the last production change. |
| 14 | AC-14 file sizes and excluded directories | PASS | Largest changed files: `models.test.ts` 486, `jest.config.cjs` 470, `render-feature-excerpts.ts` 430. No path under `codex-native-converter/`, `push-down/`, or `subagent-tree/` in the branch diff. | `wc -l <changed files>`; `git diff --name-only 6dac65b..HEAD` | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the CI run for the PR is green (CI status was not available in the PR-context summary because no PR exists yet).
2. File the follow-up issue for the out-of-scope comparator consolidation and Python parity port recorded in `issue.md`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All fourteen items were already checked (`- [x]`) by the executor in commit `0c3f5aab`. The reviewer independently evaluated each as PASS, so the existing check marks are confirmed. No source-file change was made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/issue.md`
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/issue.md` | 14 | 14 | 0 | Checkbox-backed; all previously checked and confirmed by this review |
