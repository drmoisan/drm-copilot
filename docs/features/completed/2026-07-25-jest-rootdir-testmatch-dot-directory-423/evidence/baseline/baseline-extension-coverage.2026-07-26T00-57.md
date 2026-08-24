# Baseline — Extension Coverage (UNFIXED config, expect-fail)

Timestamp: 2026-07-26T00-57

Task: [P0-T5] [expect-fail]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`
Config under test: `extensions/drm-copilot/jest.config.cjs` at base state (unfixed)

Command: `npm --prefix extensions/drm-copilot run test:coverage`
Resolved script: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`
EXIT_CODE: 1

## Full Output

```
> drm-copilot@1.0.19 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f\extensions\drm-copilot
  368 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a08c9cf1932159e8f/extensions/drm-copilot/test/**/*.test.ts - 0 matches
  testPathIgnorePatterns: \\node_modules\\, \\out\\ - 368 matches
  testRegex:  - 0 matches
Pattern:  - 0 matches
```

WhyNumericBaselineUnavailable: The defect under repair (issue #423) causes zero test discovery in
this dot-prefixed worktree, so Jest exits with `No tests found, exiting with code 1` before any test
executes and before the coverage reporter emits a text-summary. No statements, branches, functions,
or lines percentages are produced — not zero values, but no values at all. Numeric baseline coverage
is therefore structurally unobtainable pre-fix, and this expect-fail artifact IS the pre-fix coverage
baseline of record.

## Coverage Comparison Basis for Phase 4

Because no numeric pre-fix coverage exists, the Phase 4 coverage verification ([P4-T9], [P4-T10])
establishes correctness by absolute threshold satisfaction rather than by delta:

- `extensions/drm-copilot/jest.config.cjs` declares `collectCoverage`, `collectCoverageFrom`
  (`src/**/*.ts` less `src/**/*.d.ts`), and per-file `coverageThreshold` entries.
- Jest exits non-zero if ANY configured per-file threshold is unmet. A post-change exit code of 0
  from `test:coverage` therefore proves every configured threshold entry passed.
- The six files changed by this fix are Jest config / entry-point scaffolding and new test files
  under `test/`, none of which fall inside `collectCoverageFrom` (`src/**`). The production coverage
  denominator is unchanged by this fix, so no coverage regression is mechanically possible from
  these edits.

Output Summary: EXPECTED FAILURE (expect-fail task). `npm --prefix extensions/drm-copilot run
test:coverage` exits 1 with `No tests found, exiting with code 1`, 368 files checked, 0 testMatch
matches. No coverage summary emitted. Numeric baseline coverage is structurally unobtainable pre-fix;
this artifact is the recorded pre-fix coverage baseline.
