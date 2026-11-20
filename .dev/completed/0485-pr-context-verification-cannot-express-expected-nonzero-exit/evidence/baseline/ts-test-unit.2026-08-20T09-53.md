# Baseline — TypeScript unit tests (Jest)

Timestamp: 2026-08-20T09-53

Task: [P0-T14]

Command: (from `extensions/drm-copilot`) npm run test:unit    # node run-jest.cjs
EXIT_CODE: 0

## Result

```
Test Suites: 185 passed, 185 total
Tests:       2558 passed, 2558 total
Snapshots:   0 total
Time:        4.714 s
```

- Suites passed: 185 of 185
- Suites failed: 0
- Tests passed: 2558 of 2558
- Tests failed: 0

Discovery confirms the SC10 note that the hazard was tool AVAILABILITY, not corpus scope: Jest
`rootDir` resolves to this worktree's `extensions/drm-copilot`, and all 185 suites were found and
run.

Output Summary: Jest passes at baseline with exit code 0 — 185 of 185 suites and 2558 of 2558 tests
passing, 0 failures.
