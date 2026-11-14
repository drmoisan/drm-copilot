# Coverage Comparison: Remediation Cycle 1 (P2-T3)

Timestamp: 2026-11-14T18-41
Command: comparison of evidence/qa-gates/final-qc-jest.2026-11-14T18-41.md (final gate) with evidence/remediation-baseline/jest-baseline.2026-11-14T18-32.md (Phase 0 baseline) and evidence/qa-gates/final-qc-jest.2026-11-14T17-11.md (earlier final gate), from SCRATCH/issue-1173-c1-jest-final-summary.json and SCRATCH/issue-1173-c1-jest-baseline-summary.json
EXIT_CODE: 0
Output Summary:
- Result: PASS.

D-5 uncovered-count rule (input modules):

| Check | Phase 0 baseline | Earlier final gate (17-11) | Final gate | Result |
|---|---|---|---|---|
| Uncovered lines: mcp-tool-inputs-docs.ts (+ grammar after) | 2 | 2 | 2 + 0 = 2 | PASS (2 <= 2) |
| Uncovered branches: mcp-tool-inputs-docs.ts (+ grammar after) | 2 | 2 | 1 + 0 = 1 | PASS (1 <= 2) |
| Uncovered lines: mcp-tool-inputs-docs-ledger-batch.ts | 0 | 0 | 0 | PASS |
| Uncovered branches: mcp-tool-inputs-docs-ledger-batch.ts | 0 | 0 | 0 | PASS |

Thresholds (85% line, 75% branch) per docs file in the final gate:

| File | Line % | Branch % | Result |
|---|---|---|---|
| src/mcp-tool-inputs-docs.ts | 99.50 | 99.02 | PASS |
| src/mcp-tool-inputs-docs-grammar.ts | 100 | 100 | PASS |
| src/mcp-tool-inputs-docs-ledger-batch.ts | 100 | 100 | PASS |
| src/mcp-docs-tool-definitions.ts | 100 | 93.33 | PASS |
| src/repo-automation-execute-docs.ts | 100 | 100 | PASS |
| src/mcp-handlers/docs-handlers.ts | 100 | 100 | PASS |

Other docs files against the Phase 0 baseline (uncovered lines / branches, baseline -> final): mcp-docs-tool-definitions.ts 0/1 -> 0/1; repo-automation-execute-docs.ts 0/0 -> 0/0; mcp-handlers/docs-handlers.ts 0/0 -> 0/0; docs-command-envelope.ts 0/1 -> 0/1. No increase. PASS.

Test counts: Phase 0 baseline 342 suites and 5654 tests, 0 failed; final gate 344 suites and 5681 tests, 0 failed. New tests: mcp-tool-inputs-docs.import-graph.test.ts (4) and mcp-tool-inputs-docs-grammar.test.ts (23) = 2 suites and 27 tests; 5654 + 27 = 5681 and 342 + 2 = 344. No new failing test. PASS.

Extension-wide: lines 97.19% -> 97.19% (64742/66612 -> 64780/66650), branches 93.98% -> 94.00% (9982/10621 -> 9998/10636). No drop.

Note on the earlier final gate: it ran node run-jest.cjs directly (344 suites, 5592 tests) with the integration-lane files included, while both launcher runs of this cycle exclude the three integration-lane test files; its test count is therefore not compared, and only its per-file docs figures are used above.
