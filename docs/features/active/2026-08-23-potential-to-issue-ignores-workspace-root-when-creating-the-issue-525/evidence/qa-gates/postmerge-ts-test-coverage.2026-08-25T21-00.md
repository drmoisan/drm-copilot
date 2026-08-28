# Post-Merge QA Gate — TypeScript Test and Coverage

- Timestamp: 2026-08-25T21-00
- Command: `npm --prefix extensions/drm-copilot run test:coverage`
- EXIT_CODE: 0

## Context

This artifact re-verifies the [P6-T4] test-and-coverage gate against the
post-merge tree, run immediately after the type-check gate above passed
cleanly in this same pass. The full toolchain loop (format, lint, typecheck,
test:coverage) completed in a single pass with no restart triggered by a
failing or file-rewriting step; the only interruption in the overall exercise
was a one-time `npm ci` dependency install, required because this freshly
created worktree had no `node_modules` directory, run before the loop's first
iteration and producing no change to any git-tracked file.

## Output Summary

```
Test Suites: 197 passed, 197 total
Tests:       2677 passed, 2677 total
Snapshots:   0 total

Statements   : 96.69% ( 43349/44831 )
Branches     : 90.12% ( 6158/6833 )
Functions    : 89.78% ( 1266/1410 )
Lines        : 96.69% ( 43349/44831 )
```

197 of 197 test suites passed; 2677 of 2677 tests passed; 0 failures. Overall
line coverage 96.69% (43349/44831); overall branch coverage 90.12%
(6158/6833). Both figures are consistent with the pre-merge Phase 6 baseline
recorded in `evidence/qa-gates/ts-test-coverage.2026-08-23T23-23.md`.
`EXIT_CODE: 0`.
