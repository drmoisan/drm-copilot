# Final QC - Jest Gates - Issue #1228 ([P2-T5])

Timestamp: 2026-11-24T06-58
Command: `sh C:/<item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage`; then `sh C:/<item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh jest` (each through the exit-75 retry wrapper `artifacts/issue-1228/retry.sh`, launched from `artifacts/issue-1228/qa.sh q1`; Node dependencies installed at [P0-T5])
EXIT_CODE: 0
Output Summary:
- jest-extension (`node run-jest.cjs` in `extensions/drm-copilot`, normal parallel workers, coverage): EXIT_CODE 0; Test Suites 412 passed of 412; Tests 6707 passed of 6707; 0 failed. [P0-T5]: 412 suites, 6707 tests, 0 failed.
- jest-extension repo-wide coverage summary: Statements 97.59% (74531/76371); Branches 94.96% (11909/12541); Functions 93.35% (2248/2408); Lines 97.59% (74531/76371). [P0-T5]: identical (97.59%, 94.96%, 93.35%, 97.59%). Not below the baseline.
- jest (root, launcher `jest` suite, integration lane excluded): EXIT_CODE 0; Test Suites 415 passed of 415; Tests 6724 passed of 6724; 0 failed. [P0-T5]: 415 suites, 6724 tests, 0 failed.
- The item changes no TypeScript file, so no per-file figure applies; the `origin/main` merge changed no Jest test count.
- Queue timeouts (not failures): 9 attempts of the jest-extension call and 1 of the root call exited 75 before their runs (2026-11-24T06-40 to 06-58).
- Result: PASS (AC-17).
