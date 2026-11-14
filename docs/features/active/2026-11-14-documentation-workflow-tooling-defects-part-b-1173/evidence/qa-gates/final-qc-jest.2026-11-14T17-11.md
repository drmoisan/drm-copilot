# Final QC: Jest Coverage Gate (P7-T6)

Timestamp: 2026-11-14T17-11
Command: sh SCRATCH/issue-1173-jest.sh final (in extensions/drm-copilot: node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary; normal parallel workers); per-file figures read from the json-summary report copied to SCRATCH/issue-1173-jest-final-summary.json
EXIT_CODE: 0
Output Summary:
- Test Suites: 344 passed, 344 total. Tests: 5592 passed, 0 failed, 5592 total.
- Extension coverage: lines 97.18% (64451/66317), branches 93.98% (9906/10540), statements 97.18%, functions 92.19%.
- Per-file coverage of the five docs MCP files (per-file entries of jest.docs-coverage.json):

| File | Lines covered/total | Line % | Branches covered/total | Branch % |
|---|---|---|---|---|
| src/mcp-tool-inputs-docs.ts | 506/508 | 99.60 | 103/105 | 98.09 |
| src/mcp-tool-inputs-docs-ledger-batch.ts (new) | 206/206 | 100 | 55/55 | 100 |
| src/mcp-docs-tool-definitions.ts | 147/147 | 100 | 14/15 | 93.33 |
| src/repo-automation-execute-docs.ts | 188/188 | 100 | 19/19 | 100 |
| src/mcp-handlers/docs-handlers.ts | 55/55 | 100 | 9/9 | 100 |

- Expected failures: none.
