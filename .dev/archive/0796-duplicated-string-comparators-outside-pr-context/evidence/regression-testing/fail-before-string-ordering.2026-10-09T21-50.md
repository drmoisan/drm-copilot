# Fail-before: shared comparator unit tests against the moved, uncorrected implementation (P2-T3)

Timestamp: 2026-10-09T21-50
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/string-ordering.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Test Suites: 1 failed, 1 total
- Tests:       2 failed, 21 passed, 23 total
- Failing title 1 (verbatim): `compareCodePoint - enumerative properties over a fixed domain › is transitive for every ordered triple in the domain`
- Failing title 2 (verbatim): `compareCodePoint issue #796 unpaired surrogates › issue #796 orders the research triple without a cycle`
- The transitivity violations output lists 9 triples, including "[U+10000] <= [U+D800 U+E000] <= [U+E000] but a > c" (the research triple U+10000, U+D800 U+E000, U+E000), plus "[U+D800 U+E000] <= [U+E000] <= [U+10000] but a > c" and "[U+E000] <= [U+10000] <= [U+D800 U+E000] but a > c".
- The cycle test received `true` for the cycle predicate (expected `false`).
- This executes the cycle that spec Decision 2 records as derived by hand. No compile error.
