# RC2 remediation baseline: Jest selection Set J (P0-T2)

Timestamp: 2026-11-24T18-20
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension "--testPathPatterns=test/lib/validate/(orchestrator-state-[^/]*|orchestration-artifacts)[.]test[.]ts$" --coverage --collectCoverageFrom=src/lib/validate/orchestrator-state-completion.ts --collectCoverageFrom=src/lib/validate/orchestrator-state-child-ci.ts --coverageReporters=json-summary --coverageReporters=lcov --coverageReporters=text-summary '--coverageThreshold={"global":{"lines":85,"branches":75}}' --json --outputFile=SCRATCH/issue-1233-rc2-p0-jest.json (through SCRATCH/issue-1233-rc2-setj.sh and SCRATCH/issue-1233-retry.sh; JSON summary copied to SCRATCH/issue-1233-rc2-p0-jest.coverage-summary.json)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-24T18-19 to 2026-11-24T18-19; first attempt exited 0 (no queue timeout).
- "Test Suites: 28 passed, 28 total" (27 orchestrator-state-*.test.ts files and orchestration-artifacts.test.ts); "Tests: 797 passed, 797 total"; passed=797, failed=0. No pre-existing failure.
- Coverage (selection-scoped, from the JSON summary):
  - src/lib/validate/orchestrator-state-completion.ts: lines 147/157 (93.63%), branches 35/37 (94.59%).
  - src/lib/validate/orchestrator-state-child-ci.ts: lines 146/146 (100%), branches 28/28 (100%).
  - Two-file total: lines 293/303 (96.69%), branches 63/65 (96.92%); run-level threshold 85 lines / 75 branches met.
- jest.config.cjs unchanged; the run-level threshold is passed on the command line only.
