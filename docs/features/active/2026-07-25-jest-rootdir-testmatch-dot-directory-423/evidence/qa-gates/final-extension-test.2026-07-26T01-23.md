# Final QC — Extension Test

Timestamp: 2026-07-26T01-23

Task: [P4-T8]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC16
QC Loop Pass: 1 (single clean pass; no restart required)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command: `npm --prefix extensions/drm-copilot run test`
Resolved script: `node run-jest.cjs`
EXIT_CODE: 0

## Full Output

```
> drm-copilot@1.0.19 test
> node run-jest.cjs


Test Suites: 169 passed, 169 total
Tests:       2046 passed, 2046 total
Snapshots:   0 total
Time:        2.999 s
Ran all test suites.
```

## Counts

| Metric | Value |
|---|---|
| Test suites passed | 169 |
| Test suites total | 169 |
| Test suites failed | 0 |
| Tests passed | 2046 |
| Tests total | 2046 |
| Tests failed | 0 |
| Snapshots | 0 |
| Duration | 2.999 s |

Suite count is stable and reproducible: identical to the [P3-T5] pass-after capture (169 suites /
2046 tests) and to the verified on-disk inventory of 169 `*.test.ts` files under
`extensions/drm-copilot/test/`.

## Cross-Run Consistency

| Run | Suites | Tests |
|---|---|---|
| Extension package ([P4-T8], this run) | 169 | 2046 |
| Root package ([P4-T4]) | 171 | 2061 |
| Difference | +2 (`tests/unit/` files) | +15 (14 from the new root regression test + 1 from `hello-typescript.test.ts`) |

The two runs reconcile exactly, confirming both Jest projects discover the same extension test set
and that no file is double-counted or missing.

## Type-Check Note

This run also constitutes the type-check evidence for
`extensions/drm-copilot/test/jest-config-resolution.test.ts`: ts-jest compiles it under
`tsconfig.jest.json` (which extends the strict `tsconfig.json` and adds `test/**/*.ts` to `include`)
on every run. A type error in that file would fail this run. See [P4-T7] for the full explanation.

Output Summary: PASS. `npm --prefix extensions/drm-copilot run test` exits 0 with **169 test suites
passed / 169 total** and **2046 tests passed / 2046 total**, zero failures, in 2.999 s. Counts are
identical to the [P3-T5] capture, match the on-disk inventory, and reconcile exactly with the root
run. No loop restart triggered.
