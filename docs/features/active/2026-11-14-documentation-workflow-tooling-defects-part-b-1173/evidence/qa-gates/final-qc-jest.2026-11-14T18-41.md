# Final QC: Jest Coverage Gate, Remediation Cycle 1 (P2-T2)

Timestamp: 2026-11-14T18-41
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary --json --outputFile=SCRATCH/issue-1173-c1-final.json (normal parallel workers); per-file figures from coverage/coverage-summary.json copied to SCRATCH/issue-1173-c1-jest-final-summary.json and read by SCRATCH/issue-1173-c1-jestsum.ps1
EXIT_CODE: 0
Output Summary:
- Test Suites: 344 passed, 0 failed, 344 total. Tests: 5681 passed, 0 failed, 5681 total. No launcher queue timeout.
- Extension-wide coverage: lines 97.19% (64780/66650), branches 94.00% (9998/10636), statements 97.19%, functions 92.27%. The per-file thresholds of jest.docs-coverage.json are met (exit 0).

| File | Lines covered/total | Line % | Uncovered lines | Branches covered/total | Branch % | Uncovered branches |
|---|---|---|---|---|---|---|
| src/mcp-tool-inputs-docs.ts | 405/407 | 99.50 | 2 | 102/103 | 99.02 | 1 |
| src/mcp-tool-inputs-docs-grammar.ts (new) | 139/139 | 100 | 0 | 17/17 | 100 | 0 |
| src/mcp-tool-inputs-docs-ledger-batch.ts | 206/206 | 100 | 0 | 55/55 | 100 | 0 |
| src/mcp-docs-tool-definitions.ts | 147/147 | 100 | 0 | 14/15 | 93.33 | 1 |
| src/repo-automation-execute-docs.ts | 188/188 | 100 | 0 | 19/19 | 100 | 0 |
| src/mcp-handlers/docs-handlers.ts | 55/55 | 100 | 0 | 9/9 | 100 | 0 |

- Expected failures: none.
