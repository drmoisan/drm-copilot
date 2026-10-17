# Failure-Cause Suite Baseline Counts (P0-T11)

Timestamp: 2026-10-09T03-04
Task: [P0-T11]
Working directory: extensions/drm-copilot

## Command 1

Command: npx jest --config jest.config.cjs test/lib/validate/orchestration-handoff-failure-cause.test.ts
EXIT_CODE: 0
Output (verbatim):

    Test Suites: 1 passed, 1 total
    Tests:       28 passed, 28 total

## Command 2

Command: npx jest --config jest.config.cjs test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts
EXIT_CODE: 0
Output (verbatim):

    Test Suites: 1 passed, 1 total
    Tests:       6 passed, 6 total

FAILURE_CAUSE_BASELINE: 28
AUTHORITY_CAUSE_BASELINE: 6 (expected 6, rows A1-A6)

Output Summary: Pass. Both suites exit 0; 28 and 6 tests passed respectively.
