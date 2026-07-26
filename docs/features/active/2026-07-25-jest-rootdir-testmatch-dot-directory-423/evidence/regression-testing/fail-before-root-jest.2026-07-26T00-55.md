# Fail-Before Witness — Root Jest Discovery (UNFIXED config)

Timestamp: 2026-07-26T00-55

Task: [P0-T3] [expect-fail]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC3 (fail-before evidence, root package)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`
Config under test: `jest.config.cjs` at base state (`<rootDir>`-interpolated `testMatch`, unfixed)
Git state at capture: branch `bug/jest-no-tests-found-dot-directory-worktree`, HEAD `8da72e98`,
`jest.config.cjs` unmodified relative to base `fb483b84`.

Command: `node run-jest.cjs`
EXIT_CODE: 1

## Full Output

```
No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f
  435 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a08c9cf1932159e8f/tests/unit/**/*.test.ts, C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a08c9cf1932159e8f/extensions/drm-copilot/test/**/*.test.ts - 0 matches
  testPathIgnorePatterns: \\node_modules\\, \\out\\ - 435 matches
  testRegex:  - 0 matches
Pattern:  - 0 matches
```

## Defect Confirmation

- `No tests found, exiting with code 1` present.
- `testMatch: ... - 0 matches` present for BOTH root patterns (they are reported as one combined
  `- 0 matches` line covering both entries).
- Files checked: **435** (plan expected ~435; spec recorded 434 at spec-authoring time — the
  difference is the `phase0-instructions-read.md` evidence file added by [P0-T1], which the crawler
  counts).
- The pattern text shows the retained literal backslash in `drm-copilot\.claude` while every other
  separator in the same pattern was normalized to `/`. This is the exact byte pair described in the
  spec Root Cause Analysis: `replacePathSepForGlob`'s negative lookahead
  `/\\(?![$()+.?^{}])/g` protects `\.`, and picomatch then consumes it as an escaped literal dot
  rather than a path separator.
- `testPathIgnorePatterns` matched 435 files, confirming the crawl itself found the tree; the failure
  is in pattern matching, not in file enumeration.

Output Summary: EXPECTED FAILURE (expect-fail task). Root `node run-jest.cjs` exits 1 with
`No tests found, exiting with code 1`, 435 files checked, and `0 matches` for the two
`<rootDir>`-interpolated `testMatch` patterns. The escaped `\.claude` byte pair is visible in the
reported pattern text. Fail-before witness for AC3 captured.
