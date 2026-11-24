# Reviewer root Jest coverage run (feature review, issue #1233)

Timestamp: 2026-11-24T14-19
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest --coverage --coverageReporters=lcov --coverageReporters=json-summary --coverageReporters=text-summary (run from the item worktree root through a reviewer scratch launcher that retries on exit 75; 20 queue timeouts before the lock was acquired)
EXIT_CODE: 0
Output Summary:
- Head: 0fc83af8b03b74deed2615238faa8c203df942dd (clean tree apart from the review artifacts and two AC checkbox reverts).
- Result: Test Suites 416 passed, 416 total; Tests 6747 passed, 6747 total; 17.264 s.
- Repo-wide (root `coverage/lcov.info`, written 2026-11-24 14:18 UTC): lines 81728/83017 (98.44%), branches 12737/13456 (94.65%).
- extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts: lines 146/146 (100%), branches 28/28 (100%).
- extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts: lines 456/461 (98.91%), branches 77/80 (96.25%).
- Reason for the run: the canonical TypeScript coverage artifact `coverage/lcov.info` was absent because the executor's gate ran the extension-only Jest suite; per-file figures match the executor's extension report exactly.
