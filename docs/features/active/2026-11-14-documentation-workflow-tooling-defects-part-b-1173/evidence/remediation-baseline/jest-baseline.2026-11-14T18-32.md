# Remediation Cycle 1 Phase 0 Baseline: Jest Coverage (P0-T2)

Timestamp: 2026-11-14T18-31
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary (normal parallel workers); per-file figures from coverage/coverage-summary.json copied to SCRATCH/issue-1173-c1-jest-baseline-summary.json and read by SCRATCH/issue-1173-c1-jestsum.ps1
EXIT_CODE: 0
Output Summary:
- Test Suites: 342 passed, 0 failed, 342 total. Tests: 5654 passed, 0 failed, 5654 total.
- Extension-wide coverage: lines 97.19% (64742/66612), branches 93.98% (9982/10621), statements 97.19%, functions 92.22%.
- Per-file coverage:

| File | Lines covered/total | Line % | Uncovered lines | Branches covered/total | Branch % | Uncovered branches |
|---|---|---|---|---|---|---|
| src/mcp-tool-inputs-docs.ts | 506/508 | 99.60 | 2 | 103/105 | 98.09 | 2 |
| src/mcp-tool-inputs-docs-ledger-batch.ts | 206/206 | 100 | 0 | 55/55 | 100 | 0 |
| src/mcp-docs-tool-definitions.ts | 147/147 | 100 | 0 | 14/15 | 93.33 | 1 |
| src/repo-automation-execute-docs.ts | 188/188 | 100 | 0 | 19/19 | 100 | 0 |
| src/mcp-handlers/docs-handlers.ts | 55/55 | 100 | 0 | 9/9 | 100 | 0 |
| src/docs-command-envelope.ts (reference) | 243/243 | 100 | 0 | 62/63 | 98.41 | 1 |

- Note: the suite count (342) is lower than the earlier final gate (344) because the launcher excludes the integration and golden lanes by file-name suffix; the earlier gate ran node run-jest.cjs directly.
