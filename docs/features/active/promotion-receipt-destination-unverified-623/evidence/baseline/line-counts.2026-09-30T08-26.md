# Baseline Line Counts (#623)

Timestamp: 2026-09-30T08-26
Command: grep -c "" <path> (for each of six paths); git diff --quiet 6e6ccd62792e0838bee7459a2b468de83ad5d408 -- "scripts/dev_tools/potential_to_issue.py"
EXIT_CODE: 0
Output Summary: Six physical line counts recorded; the Python module is unchanged against BASE_SHA (git diff --quiet exit 0). PY_BASE_LINES = 639.

| Path | Lines |
| --- | --- |
| extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts | 443 |
| scripts/dev_tools/potential_to_issue.py | 639 |
| extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts | 171 |
| extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts | 149 |
| extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts | 397 |
| extensions/drm-copilot/jest.config.cjs | 356 |

git diff --quiet BASE_SHA -- "scripts/dev_tools/potential_to_issue.py": EXIT_CODE 0

PY_BASE_LINES: 639
