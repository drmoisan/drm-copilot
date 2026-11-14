# Jest Phase 0 Baseline (P0-T6)

Timestamp: 2026-11-14T07-20
Command: sh SCRATCH/issue-1173-jest.sh baseline (in extensions/drm-copilot: node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary; normal parallel workers); per-file figures read from coverage/coverage-summary.json (copied to SCRATCH) by SCRATCH/issue-1173-jestsum.ps1
EXIT_CODE: 0
Output Summary:
- Test Suites: 342 passed, 342 total. Tests: 5554 passed, 0 failed, 5554 total.
- Repo-wide (extension) coverage: lines 97.17% (64214/66080), branches 93.94% (9845/10479).
- Per-file coverage of the docs MCP files (the new src/mcp-tool-inputs-docs-ledger-batch.ts has no pre-change run):

| File | Lines covered/total | Line % | Branches covered/total | Branch % |
|---|---|---|---|---|
| src/mcp-tool-inputs-docs.ts | 490/492 | 99.59 | 100/102 | 98.03 |
| src/mcp-docs-tool-definitions.ts | 135/135 | 100 | 13/14 | 92.85 |
| src/repo-automation-execute-docs.ts | 185/185 | 100 | 17/17 | 100 |
| src/mcp-handlers/docs-handlers.ts | 55/55 | 100 | 9/9 | 100 |
| src/docs-command-envelope.ts (not edited; recorded for reference) | 243/243 | 100 | 62/63 | 98.41 |
