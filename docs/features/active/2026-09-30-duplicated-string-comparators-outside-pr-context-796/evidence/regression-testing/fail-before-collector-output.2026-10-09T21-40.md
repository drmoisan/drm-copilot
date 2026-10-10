# Fail-before: pr-context collector-output renderVerificationEvidenceSection (P1-T12)

Timestamp: 2026-10-09T21-40
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/pr-context/collector-output-ordering.test.ts -t "issue #796"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Failing title (verbatim): `renderVerificationEvidenceSection ordering › issue #796 renders a U+E000 evidence source before a supplementary-character evidence source`
- Test Suites: 1 failed, 1 total
- Tests:       1 failed, 1 total   (no "passed" count)
- Received source lines (pre-change inline ternary): ["  - Source: docs/features/active/f/evidence/qa-gates/U+1F600.md", "  - Source: docs/features/active/f/evidence/qa-gates/U+E000.md"] - the supplementary-character path is first.
- Expected: the U+E000 path first, then the U+1F600 path.
- Assertion failure at collector-output-ordering.test.ts:39 (no compile error).
- After this run, a whitespace-only Prettier line wrap was applied at line 19 of the test file (no semantic change); the assertion now sits at line 40.
