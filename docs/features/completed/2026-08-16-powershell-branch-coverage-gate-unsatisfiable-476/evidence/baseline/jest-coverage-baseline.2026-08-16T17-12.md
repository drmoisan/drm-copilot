# Extension Jest Baseline with Coverage (Issue #476)

Timestamp: 2026-08-16T17-12

Command: `npm run test:coverage` (run from `extensions/drm-copilot/`)

EXIT_CODE: 0

## Environment Precondition

The worktree had no `extensions/drm-copilot/node_modules` directory, so the first invocation failed with `Cannot find module 'jest/bin/jest'` (exit code 1). `npm ci` was run from `extensions/drm-copilot/` to install dependencies from the checked-in `package-lock.json` (457 packages added, 0 vulnerabilities, exit code 0). This is environment provisioning from the committed lockfile; it modifies no tracked file (`node_modules/` is not tracked) and changes no dependency version. The command below was then re-run and is the recorded baseline.

## Raw Output

```text
> drm-copilot@1.0.25 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary


=============================== Coverage summary ===============================
Statements   : 96.61% ( 41738/43200 )
Branches     : 89.96% ( 5901/6559 )
Functions    : 90.11% ( 1221/1355 )
Lines        : 96.61% ( 41738/43200 )
================================================================================

Test Suites: 185 passed, 185 total
Tests:       2552 passed, 2552 total
Snapshots:   0 total
Time:        11.177 s
Ran all test suites.
```

## Numeric Coverage Values

| Metric | Covered / Total | Percentage |
| --- | --- | --- |
| Statements | 41738 / 43200 | 96.61% |
| Branches | 5901 / 6559 | 89.96% |
| Functions | 1221 / 1355 | 90.11% |
| Lines | 41738 / 43200 | 96.61% |

Output Summary: 185 test suites passed, 2552 tests passed, 0 failed, exit code 0. Line coverage 96.61%, branch coverage 89.96%, function coverage 90.11%, statement coverage 96.61%. All exceed the repository thresholds of line >= 85% and branch >= 75%. The run includes the pack-completeness twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`. This change modifies no TypeScript source or test file, so the expected post-change delta is zero on every value above.
