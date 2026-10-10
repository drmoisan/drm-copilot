# Fail-before: push-down claude-blast-radius-derive-manifests (P1-T4)

Timestamp: 2026-10-09T21-26
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/push-down/blast-radius-derive-manifests.test.ts -t "issue #796"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Failing title (verbatim): `issue #796: module path ordering › issue #796 sorts a supplementary-character module path after a U+E000 module path`
- Test Suites: 1 failed, 1 total
- Tests:       1 failed, 11 skipped, 12 total   (no "passed" count)
- Received modulePaths (pre-change compareOrdinal): ["\u{1F600}", "\uE000"] - the U+1F600 entry is first.
- Expected: ["\uE000", "\u{1F600}"].
- Assertion failure at blast-radius-derive-manifests.test.ts:198 (no compile error).
(Characters written as JavaScript escapes.)
- Re-run at 2026-10-09T21-31 after the test source was normalized to JavaScript escape text (the Edit tool had written U+E000 as a literal character; runtime string values were identical): same exit code 1, same failing title, same Tests: line.
