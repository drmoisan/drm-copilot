# Baseline: Jest gate for extensions/drm-copilot (P0-T6)

Timestamp: 2026-11-24T06-30
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=json-summary --coverageReporters=lcov --coverageReporters=text-summary (run from the item worktree root through SCRATCH/issue-1233-gate-jest.sh and SCRATCH/issue-1233-retry.sh; the suite runs node run-jest.cjs in extensions/drm-copilot with its normal parallel workers)
EXIT_CODE: 0
Output Summary:
- Twenty-four earlier attempts between 05-53 and 06-28 UTC ended with launcher exit 75 (TEST_EXECUTION_QUEUE_TIMEOUT: the machine lock was held by sibling worktrees); each is a queue timeout, not a failure, and the gate was re-run.
- Result: Test Suites 412 passed, 412 total; Tests 6707 passed, 0 failed, 6707 total. Every per-file coverageThreshold passed (exit 0).
- Repo-wide (coverage-summary.json total): lines 74531/76371 (97.59%), branches 11909/12541 (94.96%).
- src/lib/validate/orchestrator-state-core.ts: lines 456/461 (98.91%), branches 77/80 (96.25%).
- src/lib/validate/orchestrator-state-completion.ts: lines 145/157 (92.35%), branches 33/36 (91.66%).
- src/lib/validate/orchestrator-state-child-ci.ts does not exist before this change (no pre-change figure).
- coverage-summary.json and lcov.info were copied to SCRATCH/issue-1233-p0-jest.coverage-summary.json and SCRATCH/issue-1233-p0-jest.lcov.info for the P5-T7 comparison.
