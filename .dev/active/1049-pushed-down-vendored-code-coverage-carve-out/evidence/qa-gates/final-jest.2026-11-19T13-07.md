# Final QC - Jest - [P4-T6]

Timestamp: 2026-11-19T13-07
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (node run-jest.cjs --coverage in extensions/drm-copilot); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest (root runner of npm run test:unit); both as step T6 of sh SCRATCH/issue-1049-final.sh issue-1049-final1; all-files totals from extensions/drm-copilot/coverage/lcov.info by sh SCRATCH/issue-1049-lcov.sh; git diff --exit-code BASE -- extensions/drm-copilot/src (BASE = merge base of origin/epic/shared-agent-harness-layer-integration and HEAD); git status --porcelain -- extensions/drm-copilot/src
EXIT_CODE: 0
Output Summary: Extension run exit 0: 371 suites passed, 6142 tests passed, 0 failed. Root run exit 0 (attempt 1 exit 75 queue timeout): 374 suites passed, 6159 tests passed, 0 failed. No failing test outside the [P0-T8] pre-existing set, which is empty. All-files line 97.42% (68431/70241) and branch 94.63% (10598/11199), against 97.42% and 94.63% at [P0-T8]: no drop. The configured coverageThreshold passes (the coverage run exits 0 and prints no threshold failure). Per-file TypeScript coverage: NOT APPLICABLE (no TypeScript production file changed): the BASE diff of extensions/drm-copilot/src exits 0 with no output and its porcelain status is empty.

| Run | Suites | Tests passed | Failed | Phase 0 baseline |
| --- | --- | --- | --- | --- |
| extensions/drm-copilot (coverage) | 371 | 6142 | 0 | 369 suites, 6119 tests, 0 failed |
| repository root | 374 | 6159 | 0 | 372 suites, 6136 tests, 0 failed |

The increase of 2 suites and 23 tests in each run is the two new Jest files of [P1-T2] (21 tests) and [P1-T3] (2 tests).

CI evidence: `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` and `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`.
