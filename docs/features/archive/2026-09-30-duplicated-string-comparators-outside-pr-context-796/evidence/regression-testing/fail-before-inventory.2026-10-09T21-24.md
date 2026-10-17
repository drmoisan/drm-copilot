# Fail-before: codex-native-converter inventory (P1-T2)

Timestamp: 2026-10-09T21-24
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/codex-native-converter/inventory.test.ts -t "issue #796"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Failing title (verbatim): `normalizeSelectedPaths › issue #796 sorts a supplementary-character path after a U+E000 path by code point`
- Test Suites: 1 failed, 1 total
- Tests:       1 failed, 7 skipped, 8 total   (no "passed" count)
- Received array (pre-change UTF-16 code-unit comparator): [".github/\u{1F600}.md", ".github/\uE000.md"] - the U+1F600 path is first.
- Expected array: [".github/\uE000.md", ".github/\u{1F600}.md"].
- Failure is an assertion failure at inventory.test.ts:177 (no compile error).
(Characters are written as JavaScript escapes; the raw log printed the literal characters.)
- Re-run at 2026-10-09T21-31 after the test source was normalized to JavaScript escape text (the Edit tool had written U+E000 as a literal character; runtime string values were identical): same exit code 1, same failing title, same Tests: line.
