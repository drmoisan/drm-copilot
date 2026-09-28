# pr-context-helper-duplication-and-vacuous-tests (Issue #740)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-context-helper-duplication-and-vacuous-tests/ (Issue #740)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #740
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/740
- Last Updated: 2026-09-27
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
