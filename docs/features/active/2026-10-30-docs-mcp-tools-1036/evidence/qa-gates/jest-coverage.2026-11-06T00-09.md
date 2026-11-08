# Final QA Jest Coverage ([P8-T4])

Timestamp: 2026-11-06T00-09
Command: node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=lcov (working directory extensions/drm-copilot, through a sh launcher under SCRATCH)
EXIT_CODE: 0
Output Summary:
- Test Suites: 334 passed, 334 total
- Tests: 5333 passed, 0 failed, 5333 total
- Failing tests: none; no coverage threshold failure reported (the five new per-file 85/75 entries in `jest.docs-coverage.json` are enforced in this run).
- Suite totals (All files): % Lines 97.1, % Branch 93.76
- Stage 7 integration: the `InMemoryTransport` suite `test/mcp-server.docs.test.ts` ran in this pass and passed.

Per-file rows from the Jest `text` reporter (`% Lines` / `% Branch`):

| File | Kind | % Lines | % Branch | Gate (85 / 75) |
|---|---|---|---|---|
| `src/docs-command-envelope.ts` | new | 100 | 98.41 | pass |
| `src/mcp-tool-inputs-docs.ts` | new | 99.59 | 98.03 | pass |
| `src/repo-automation-execute-docs.ts` | new | 100 | 100 | pass |
| `src/mcp-docs-tool-definitions.ts` | new | 100 | 92.85 | pass |
| `src/mcp-handlers/docs-handlers.ts` | new | 100 | 100 | pass |
| `src/mcp-tools.ts` | edited | 95.98 | 92 | pass |
| `src/repo-automation-tool-names.ts` | edited | 100 | 100 | pass |
| `src/mcp-repo-automation-tool-definitions.ts` | edited | 100 | 100 | pass |
| `src/mcp-tool-definitions.ts` | edited | 100 | 100 | pass |
| `src/repo-automation-service.ts` | edited | 98.31 | 93.33 | pass |
