# Fail-before: subagent-tree tree-assembler compareByAgentId (P1-T8)

Timestamp: 2026-10-09T21-35
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/subagent-tree/tree-assembler.test.ts -t "issue #796"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Failing title (verbatim): `assembleTree › issue #796 orders orphans with a U+E000 agentId before a supplementary-character agentId`
- Test Suites: 1 failed, 1 total
- Tests:       1 failed, 6 skipped, 7 total   (no "passed" count)
- Received descriptions (pre-change compareByAgentId): ["U+1F600 description", "U+E000 description"] - the supplementary-character entry is first.
- Expected: ["U+E000 description", "U+1F600 description"].
- Assertion failure at tree-assembler.test.ts:183 (no compile error).
