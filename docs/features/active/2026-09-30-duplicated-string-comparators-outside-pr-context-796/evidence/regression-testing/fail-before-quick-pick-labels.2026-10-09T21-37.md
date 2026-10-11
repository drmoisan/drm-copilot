# Fail-before: subagent-tree quick-pick-labels compareCandidates path tiebreak (P1-T10)

Timestamp: 2026-10-09T21-37
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/subagent-tree/quick-pick-labels.test.ts -t "issue #796"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Failing title (verbatim): `buildRootSessionPickEntries › issue #796 breaks an equal-timestamp tie with a U+E000 path before a supplementary-character path`
- Test Suites: 1 failed, 1 total
- Tests:       1 failed, 18 skipped, 19 total   (no "passed" count)
- Received paths (pre-change tiebreak): ["/s/U+1F600.jsonl", "/s/U+E000.jsonl"] - the supplementary-character path is first.
- Expected: ["/s/U+E000.jsonl", "/s/U+1F600.jsonl"].
- Assertion failure at quick-pick-labels.test.ts:219 (no compile error).
