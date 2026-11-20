# Final QC: Jest (advisory-fix plan, P2-T3)

Timestamp: 2026-11-19T13-39
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (node run-jest.cjs in extensions/drm-copilot, normal parallel workers, integration lane excluded by the launcher)
EXIT_CODE: 0
Output Summary: Test Suites 374 passed of 374; Tests 6184 passed, 0 failed. Coverage: lines 97.44% (69097/70909), branches 94.66% (10720/11324), statements 97.44%, functions 92.86%. Phase 0 baseline (`baseline-jest.2026-11-19T08-55.md`): 369 suites, 6119 tests, lines 97.42%, branches 94.63%. No drop. Attempts 1-8 exited 75 (queue timeout, lock held by other worktrees); attempt 9 is the run recorded here.

- Every `destination CI contract` test passed: `push-down-ci-contract.test.ts` is one of the 374 suites and no suite or test failed (the run's reporter prints the summary only). The new negative case is inside `harness workflows are destination-generic`, so the test count is unchanged from the P1 gate.
- No production TypeScript file changed in this plan; only `test/lib/push-down/push-down-ci-contract.test-helpers.ts` and `push-down-ci-contract.test.ts`, which are outside the coverage population.
