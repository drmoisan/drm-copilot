# Fail-Before Witness — Extension Jest Discovery (UNFIXED config)

Timestamp: 2026-07-26T00-56

Task: [P0-T4] [expect-fail]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC3 (fail-before evidence, extension package)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`
Config under test: `extensions/drm-copilot/jest.config.cjs` at base state
(`<rootDir>`-interpolated `testMatch`, unfixed)
Git state at capture: branch `bug/jest-no-tests-found-dot-directory-worktree`, HEAD `8da72e98`,
`extensions/drm-copilot/jest.config.cjs` unmodified relative to base `fb483b84`.
Package version reported by npm: `drm-copilot@1.0.19`

Command: `npm --prefix extensions/drm-copilot run test`
EXIT_CODE: 1

## Full Output

```
> drm-copilot@1.0.19 test
> node run-jest.cjs

No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f\extensions\drm-copilot
  368 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a08c9cf1932159e8f/extensions/drm-copilot/test/**/*.test.ts - 0 matches
  testPathIgnorePatterns: \\node_modules\\, \\out\\ - 368 matches
  testRegex:  - 0 matches
Pattern:  - 0 matches
```

## Defect Confirmation

- `No tests found, exiting with code 1` present.
- `testMatch: ... - 0 matches` present for the single extension pattern.
- Files checked: **368** — matches the count recorded in `spec.md` exactly.
- The reported pattern retains the literal backslash in `drm-copilot\.claude` while every other
  separator is normalized to `/`, identical to the root-package failure mode. The same
  `replacePathSepForGlob` lookahead / picomatch escaped-dot mechanism applies.
- `testPathIgnorePatterns` matched 368 files, confirming the crawl enumerated the tree; the failure
  is in pattern matching, not file enumeration.
- 168 existing test files under `extensions/drm-copilot/test/**` are present on disk and were
  crawled, yet zero matched.

Output Summary: EXPECTED FAILURE (expect-fail task). `npm --prefix extensions/drm-copilot run test`
exits 1 with `No tests found, exiting with code 1`, 368 files checked, and `0 matches` for the single
`<rootDir>`-interpolated `testMatch` pattern. The escaped `\.claude` byte pair is visible in the
reported pattern text. Fail-before witness for AC3 (extension package) captured.
