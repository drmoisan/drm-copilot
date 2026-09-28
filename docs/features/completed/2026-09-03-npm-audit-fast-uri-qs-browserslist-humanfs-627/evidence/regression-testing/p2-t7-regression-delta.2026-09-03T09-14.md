# P2-T7 — Regression Delta (All 3 Workspaces)

- Timestamp: 2026-09-03T09-14

## Root (`.`) — P0-T8 vs P2-T4

| Metric | Baseline (P0-T8) | Final (P2-T4) | Regression? |
|---|---|---|---|
| Test Suites passed | 206/206 | 206/206 | No |
| Tests passed | 2752/2752 | 2752/2752 | No |
| Statements % | 97.34 | 97.34 | No |
| Branch % | 90 | 90 | No |
| Functions % | 89.85 | 89.85 | No |
| Lines % | 97.34 | 97.34 | No |

## `extensions/drm-copilot/` — P0-T9 vs P2-T5

| Metric | Baseline (P0-T9) | Final (P2-T5) | Regression? |
|---|---|---|---|
| Test Suites passed | 203/203 | 203/203 | No |
| Tests passed | 2735/2735 | 2735/2735 | No |
| Statements % | 96.72 | 96.72 | No |
| Branch % | 90.17 | 90.17 | No |
| Functions % | 89.93 | 89.93 | No |
| Lines % | 96.72 | 96.72 | No |

## `packages/mcp-server/` — P0-T11 vs P2-T6 (build exit code only; no test suite exists per AC5 scoping note)

| Metric | Baseline (P0-T11) | Final (P2-T6) | Regression? |
|---|---|---|---|
| Build EXIT_CODE | 0 | 0 | No |
| Test-script absence | confirmed absent (P0-T10) | confirmed absent (P2-T6) | No change |

No production or test source lines were changed by this plan (confirmed by P1-T6/P2-T11), so no "new/changed-code coverage" figure applies; the comparison is baseline-total vs. final-total only, per the plan's stated scope.

## Output Summary

All three workspaces show zero regression: root and `extensions/drm-copilot` have identical pass counts and identical coverage percentages (statements/branch/functions/lines) between baseline and final runs; `packages/mcp-server` has an identical build exit code (0) between baseline and final, with its test-script absence unchanged. Zero regression is confirmed across all three workspaces.
