# 500-Line Limit (AC-11) (#623)

Timestamp: 2026-09-30T08-56
Command: grep -c "" <path> for blast-radius rows 1 and 3-10 (row 10 included because P6-T2 recorded DECISION: ADDED)
EXIT_CODE: 0
Output Summary: Every count is at most 500. Largest is potential-to-issue-service-call.test.ts at 434. Row 2 (scripts/dev_tools/potential_to_issue.py, 559 lines) is excluded by the task definition; it is pre-existing over-limit debt tracked by #406, and AC-10 verifies that it did not grow.

| Row | Path | Lines |
| --- | --- | --- |
| 1 | extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts | 450 |
| 3 | scripts/dev_tools/potential_to_issue_filesystem.py | 101 |
| 4 | extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts | 194 |
| 5 | extensions/drm-copilot/test/lib/potential-to-issue/promotion.move-verification.test.ts | 91 |
| 6 | extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts | 160 |
| 7 | extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts | 434 |
| 8 | tests/scripts/dev_tools/test_potential_to_issue_move_verification.py | 308 |
| 9 | tests/scripts/dev_tools/test_potential_to_issue_filesystem.py | 235 |
| 10 | extensions/drm-copilot/jest.config.cjs | 361 |
