# RT-1 Jest Coverage Run (extension project)

Timestamp: 2026-10-11T01-25
Task: [P1-T1]
Working directory: workspace root
Command: npx jest --config extensions/drm-copilot/jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary '--coverageDirectory=<rootDir>/../../coverage'
EXIT_CODE: 1

## Coverage summary (verbatim)

```
=============================== Coverage summary ===============================
Statements   : 97.25% ( 51131/52575 )
Branches     : 92.07% ( 7532/8180 )
Functions    : 91.63% ( 1523/1662 )
Lines        : 97.25% ( 51131/52575 )
================================================================================
```

## Test result lines (verbatim)

```
Test Suites: 267 passed, 267 total
Tests:       3981 passed, 3981 total
```

## Non-zero exit diagnostics

- Output lines containing `coverage threshold`: none.
- Failing test names: none (3981 passed, 0 failed).
- Cause of EXIT_CODE 1: 92 output lines of the form `Jest: Coverage data for ./src/<path>.ts was not found.` (for example `Jest: Coverage data for ./src/lib/pr-context/collector-core.ts was not found.`). These are the per-file `coverageThreshold` keys in `extensions/drm-copilot/jest.config.cjs` (lines 25 onward). `node_modules/@jest/reporters/build/index.js` line 424 resolves each key with `path().resolve(thresholdGroup)`, i.e. against the process working directory. The plan runs Jest from the workspace root, so each `./src/...` key resolves to `<workspace>/src/...`, which is not a key in the coverage map (the measured files are `<workspace>/extensions/drm-copilot/src/...`), and line 511 emits the "not found" error. The exit code therefore reflects threshold-key resolution under the plan's working directory, not a measured coverage shortfall and not a failing test. Per-file figures for the changed set are taken from `coverage/lcov.info` in [P1-T3].

Output Summary: 267/267 suites and 3981/3981 tests passed. Repo-wide Lines 97.25% (51131/52575), Branches 92.07% (7532/8180). EXIT_CODE 1 is caused by 92 per-file threshold keys that do not resolve from the workspace-root working directory; no test failed and no `coverage threshold` line was printed.
