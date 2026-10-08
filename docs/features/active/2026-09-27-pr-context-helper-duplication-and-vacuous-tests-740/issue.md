# pr-context-helper-duplication-and-vacuous-tests (Issue #740)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-context-helper-duplication-and-vacuous-tests/ (Issue #740)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #740
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/740
- Last Updated: 2026-09-27
- Work Mode: minor-audit

## Summary

#716 (PR #720) consolidated `compareCodePoint` into `pr-context/models.ts`. Review found that its contract is mis-documented, two of its property tests cannot fail, and other helpers remain duplicated.

## Environment

- OS/version: any
- Python version: n/a (TypeScript, Jest)
- Command/flags used: Jest for `extensions/drm-copilot`
- Data source or fixture: #716 final report

## Steps to Reproduce

1. The `compareCodePoint` JSDoc says it sorts by Unicode code point, but it compares UTF-16 code units. The two orders differ for characters outside the BMP.
2. Two property tests compare the function against its own `<` and `>` operators, so they cannot detect a regression.
3. The antisymmetry test does not report which pair failed.
4. Duplicated helpers remain in `extensions/drm-copilot/src/lib/pr-context/`: `sortedSet` (3 copies), `relativeToPosix` (3), `escapeRegExp` (2), `splitLines` (3). Comparators under other names (`compareStrings`, `compare`, `compareOrdinal`) exist in `codex-native-converter/` and `push-down/`.
5. Nits: the `models.ts` header does not list `compareCodePoint`, and `gh-client-details.ts` imports from `./models` in two statements.

## Expected Behavior

The documentation matches the ordering contract, the property tests assert a fixed expected order, and each helper exists once.

## Actual Behavior

As above.

## Acceptance Criteria

Source: issue body (Steps to Reproduce 1-5, Expected Behavior) and `research/research.2026-09-29T22-25.md` section 8. Paths are relative to `extensions/drm-copilot/`.

- [x] AC-1: `compareCodePoint` in `src/lib/pr-context/models.ts` orders strings by Unicode code point (matching Python `str` comparison), and its JSDoc states that contract. New fixed-order tests in `test/lib/pr-context/models.test.ts` fail against the pre-fix UTF-16 code-unit implementation and pass after the fix.
- [x] AC-2: `test/lib/pr-context/models.test.ts` asserts literal expected results for the non-BMP disagreement pairs `"￿"` vs `"\u{1F600}"`, `""` vs `"\u{10000}"`, and a shared-prefix pair, plus agreement pairs for lead-surrogate and trail-surrogate differences.
- [x] AC-3: `test/lib/pr-context/models.test.ts` contains a fixed-order sort test whose expected array is a literal (`["", "A", "a", "ab", "b", "é", "", "￿", "\u{1F600}"]`) and is not derived from the `<` or `>` operators.
- [x] AC-4: The two vacuous tests ("agrees with the native < and > operators..." and "produces the same order as native comparison via Array.prototype.sort...") are removed, and no test in `test/lib/pr-context/models.test.ts` derives its expected value from the string `<` or `>` operators.
- [x] AC-5: The antisymmetry and transitivity tests report the offending pair(s) on failure (violations array or `it.each` titles), and the enumerative domain includes `""` and `"￿"`.
- [x] AC-6: Each of `sortedSet`, `relativeToPosix`, `escapeRegExp`, and `splitLines` is defined exactly once under `src/lib/pr-context/`: `sortedSet`, `escapeRegExp`, and `splitLines` exported from `models.ts`, and `relativeToPosix` exported from `feature-docs-parsers.ts`. All former private copies are removed and their callers import the canonical definition.
- [x] AC-7: `test/lib/pr-context/models.test.ts` has direct tests for `sortedSet`, `escapeRegExp`, and `splitLines`; `test/lib/pr-context/feature-docs.test.ts` has direct tests for `relativeToPosix`, including a Windows-style root and a path outside the root.
- [x] AC-8: The `splitLines` JSDoc states the supported terminators (`\r\n`, `\r`, `\n`) and that they are a subset of the Python `str.splitlines()` boundaries.
- [x] AC-9: The `models.ts` header comment lists `splitLines`, `compareCodePoint`, `sortedSet`, and `escapeRegExp`.
- [x] AC-10: `src/lib/pr-context/gh-client-details.ts` imports from `./models` in a single statement.
- [x] AC-11: All pre-existing tests under `test/lib/pr-context/` pass without changes to their expected outputs, demonstrating unchanged PR-context output for existing inputs.
- [x] AC-12: Prettier check, ESLint (`npm run lint`), and TypeScript (`npm run typecheck`) exit 0 from `extensions/drm-copilot/`.
- [x] AC-13: `npm run test:coverage` exits 0; every changed production file meets 85% line and 75% branch coverage, and `jest.config.cjs` carries a per-file threshold entry for each changed production file.
- [x] AC-14: No changed file exceeds 500 lines, and no file under `src/lib/codex-native-converter/`, `src/lib/push-down/`, or `src/lib/subagent-tree/` is modified.

## Out of Scope

- Consolidating comparators in `codex-native-converter/`, `push-down/`, and `subagent-tree/` into a neutral `src/lib/` module (research section 7.1); deferred to a follow-up issue.
- Python parity port changes (research section 7.2).
- `splitLines` terminator-set behavior parity with Python, and larger pr-context duplications (research section 7.3).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #716 follow-ups 1-8.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Earlier modules copied helpers to avoid import cycles and to stay under the 500-line cap.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: decide between code-point and UTF-16 ordering (code point is the safer choice for determinism across runtimes), document it, and pin it with fixed-order tests including non-BMP cases; deduplicate the listed helpers into shared modules; fix the nits.
- [ ] Integration scenario to retest: PR-context golden output is unchanged, or changes only in intentional non-BMP ordering.
- [ ] Manual verification notes: check the Python parity port for the same issues.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
