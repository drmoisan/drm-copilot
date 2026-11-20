# Baseline - Jest Phase 0 baseline - [P0-T8]

Timestamp: 2026-11-19T09-15
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (node run-jest.cjs --coverage in extensions/drm-copilot); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest (node run-jest.cjs in the repository root, the `npm run test:unit` runner); all-files totals computed by sh SCRATCH/issue-1049-lcov.sh from extensions/drm-copilot/coverage/lcov.info
EXIT_CODE: 0
Output Summary: Extension run exit 0: 369 suites passed of 369, 6119 tests passed of 6119, 0 failed. Root run exit 0 (first attempt exit 75, queue timeout: the machine test-suite lock was held by another worktree's Pester run; re-run after the holder finished): 372 suites passed of 372, 6136 tests passed of 6136, 0 failed. Jest pre-existing failing set: empty. Extension all-files coverage from lcov.info (274 files): lines 97.42% (68431/70241), branches 94.63% (10597/11198).
