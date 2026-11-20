# QA Gate — TypeScript Tests and Coverage ([P6-T4])

Timestamp: 2026-08-25T10-14
Command: npm --prefix extensions/drm-copilot run test:coverage
EXIT_CODE: 0

## Output Summary

197 of 197 test suites passed and 2677 of 2677 tests passed, with 0 failed, 0 skipped, and 0
snapshots. Overall line coverage is **96.69%** and overall branch coverage is **90.12%**. No value
below is a placeholder.

| Metric | Percentage | Hit / Found |
| --- | --- | --- |
| Statements | 96.69% | 43349 / 44831 |
| Branches | 90.12% | 6158 / 6833 |
| Functions | 89.78% | 1266 / 1410 |
| Lines | 96.69% | 43349 / 44831 |

## Verbatim Reporter Output

```
=============================== Coverage summary ===============================
Statements   : 96.69% ( 43349/44831 )
Branches     : 90.12% ( 6158/6833 )
Functions    : 89.78% ( 1266/1410 )
Lines        : 96.69% ( 43349/44831 )
================================================================================

Test Suites: 197 passed, 197 total
Tests:       2677 passed, 2677 total
Snapshots:   0 total
Time:        10.775 s
Ran all test suites.
```

## Why EXIT_CODE 0 Carries the Per-File Threshold Result

`extensions/drm-copilot/jest.config.cjs` uses per-changed-file coverage thresholds with no global
key. [P4-T6] added entries of 85 lines and 75 branches for
`./src/lib/potential-to-issue/gh-client.ts`, `./src/lib/potential-to-issue/repo-slug.ts`, and
`./src/lib/potential-to-issue/potential-to-issue-service-call.ts`. Jest fails the run and exits
non-zero when any configured per-path threshold is unmet, so an exit code of 0 is the gate result for
all three entries simultaneously. The measured per-file figures are recorded in the [P6-T5]
coverage-delta artifact.

## Method Note

The script pins `--coverageReporters=lcov --coverageReporters=text-summary`. The `text-summary`
reporter emits whole-project totals only and no per-file rows, so the per-file figures used by
[P6-T5] are read from the `lcov` reporter output of this same run rather than from a separate
coverage execution. No additional test run was performed.

The gate did not rewrite any file, so the phase did not restart.
