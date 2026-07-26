# Baseline — Root Jest Suite with Coverage (#421)

Timestamp: 2026-07-26T05-10

Task: [P0-T9] — toolchain stage 5 (unit tests + coverage), baseline.

Command:

```
node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab68fbeb0ce28fc0d` (repository/worktree root)

Invocation rationale (plan Global Constraint 2): the worktree path contains the dot-directory `.claude`, which triggers the pre-existing jest `<rootDir>` glob-escape artifact (#414 Condition 3). Plain `npm test` / `npm run test:unit` therefore reports `No tests found, exiting with code 1` in this worktree. The explicit `--testMatch` arguments above are rootDir-free and path-independent, so they select the same suite set the jest configuration intends without depending on `<rootDir>` interpolation. `jest.config.cjs` and `run-jest.cjs` are forbidden files in this workstream and were not modified.

EXIT_CODE: 0

## Jest Summary Block (verbatim)

```
Test Suites: 169 passed, 169 total
Tests:       2036 passed, 2036 total
Snapshots:   0 total
Time:        6.304 s, estimated 8 s
```

## Coverage Summary (verbatim `All files` row)

```
------------------------------------------------------------|---------|----------|---------|---------|
File                                                        | % Stmts | % Branch | % Funcs | % Lines |
------------------------------------------------------------|---------|----------|---------|---------|
All files                                                   |   97.01 |    89.07 |   89.29 |   97.01 |
```

## Numeric Baseline Values

| Metric | Baseline value | Threshold | Status |
|---|---|---|---|
| Line coverage | 97.01% | >= 85% | PASS |
| Branch coverage | 89.07% | >= 75% | PASS |
| Statement coverage | 97.01% | (no separate threshold) | recorded |
| Function coverage | 89.29% | (no separate threshold) | recorded |
| Test suites | 169 passed / 169 total | all pass | PASS |
| Tests | 2036 passed / 2036 total | all pass | PASS |

Baseline guard-suite state: `tests/unit/vscode-test-removal.test.ts` does not exist at baseline (it is created in [P2-T1]). The baseline suite count of 169 is therefore the pre-guard count; the post-change count is expected to be 170.

Output Summary: Baseline root jest run passed with EXIT_CODE 0. 169 suites passed / 169 total; 2036 tests passed / 2036 total; 0 snapshots. Baseline coverage: line 97.01%, branch 89.07%, statements 97.01%, functions 89.29%. Both mandatory thresholds (line >= 85%, branch >= 75%) pass at baseline.
