# Jest Final Gate, QA loop re-run — [P6-T6]

Timestamp: 2026-11-14T04-12
Command: sh SCRATCH/issue-1156-jest-final.sh (in extensions/drm-copilot: node run-jest.cjs --coverage --coverageReporters=json-summary --coverageReporters=text-summary --coverageReporters=lcov; normal parallel workers)
EXIT_CODE: 0
Output Summary: re-run after the [P6-T8] coverage tests and the merge of origin/main (#1174). Test Suites 342 passed, 342 total; Tests 5559 passed, 5559 total; 0 failed; Jest "Time: 10.03 s"; coverage/coverage-summary.json written by this run. Global coverage: Statements 97.17% (64214/66080), Branches 93.94% (9845/10479), Functions 92.17% (1919/2082), Lines 97.17% (64214/66080), against the Phase 0 baseline of 97.15%, 93.87%, 92.11%, and 97.15%; no metric is lower. `orchestrator-state-remediation-loop-parity.test.ts` loads every `.json` file of `tests/fixtures/orchestrator_state_remediation_loop/`, including the two new fixtures, and passed (see `jest-final.2026-11-14T03-44.md` for the enumeration). No production TypeScript file changed.
