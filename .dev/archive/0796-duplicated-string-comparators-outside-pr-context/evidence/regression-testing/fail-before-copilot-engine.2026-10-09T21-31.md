# Fail-before: push-down copilot-customizations-engine stringifySorted (P1-T6)

Timestamp: 2026-10-09T21-31
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/push-down/copilot-customizations-engine.test.ts -t "issue #796"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Failing title (verbatim): `stringifySorted › issue #796 emits a U+E000 key before a supplementary-character key`
- Test Suites: 1 failed, 1 total
- Tests:       1 failed, 11 skipped, 12 total   (no "passed" count)
- Received (pre-change comparator): '{"\u{1F600}":1,"\uE000":2}' - the supplementary-character key is first.
- Expected: '{"\uE000":2,"\u{1F600}":1}'.
- Assertion failure at copilot-customizations-engine.test.ts:256 (no compile error).
(Characters written as JavaScript escapes.)
