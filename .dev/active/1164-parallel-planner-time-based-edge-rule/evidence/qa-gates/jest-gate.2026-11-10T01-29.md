# Final Jest Gate, First Run (P6-T7): Passed with a Coverage Gap

Timestamp: 2026-11-10T01-29
Command: sh SCRATCH/issue-1164-jest-gate.sh (in extensions/drm-copilot: node run-jest.cjs --coverage; normal workers)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-10T01-28 (UTC): Test Suites 341 passed of 341; Tests 5498 passed of 5498 (0 failed); Time 13.369 s. Coverage summary: Lines 97.16% (63964/65830), Branches 93.9% (9783/10418).
- Per-file from the lcov.info the run wrote (copied to SCRATCH/issue-1164-jest-final-lcov.info): src/lib/validate/parallel-state-records.ts line 100.00% (643/643), branch 99.29% (139/140); src/lib/validate/parallel-planner-state-core.ts line 100.00% (468/468), branch 97.96% (48/49); src/lib/validate/parallel-orchestrator-state-core.ts line 99.39% (324/326), branch 92.11% (35/38).
- Gap: parallel-state-records.ts branch fell below its Phase 0 figure (100.00%, 66/66). The only zero-count branch is BRDA 448 (the non-list fallback of reasons in reasonErrors), which no corpus case reached.
- Fix: the corpus case tests/fixtures/parallel_state_scheduling/reject-overlap-reasons-not-a-list.json (a scalar reasons value) was added; Python and TypeScript reproduce its expected error. pytest and Jest are re-run.
