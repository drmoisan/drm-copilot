# Final QC — Root Test

Timestamp: 2026-07-26T01-20

Task: [P4-T4]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC15
QC Loop Pass: 1 (single clean pass; no restart required)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command: `node run-jest.cjs`
EXIT_CODE: 0

## Full Output

```
Test Suites: 171 passed, 171 total
Tests:       2061 passed, 2061 total
Snapshots:   0 total
Time:        2.978 s
Ran all test suites.
```

## Counts

| Metric | Value |
|---|---|
| Test suites passed | 171 |
| Test suites total | 171 |
| Test suites failed | 0 |
| Tests passed | 2061 |
| Tests total | 2061 |
| Tests failed | 0 |
| Snapshots | 0 |
| Duration | 2.978 s |

Suite count is stable and reproducible: this run reports the identical 171 suites / 2061 tests as the
[P3-T4] pass-after capture, and matches the on-disk inventory verified there (2 files under
`tests/unit/` + 169 under `extensions/drm-copilot/test/`).

## Note on Root Jest Scope

The root Jest project runs both packages' test files (its `testMatch` covers `tests/unit/**` and
`extensions/drm-copilot/test/**`). The 171 suites here are therefore a superset of the 169 the
extension package runs on its own in [P4-T8]; the extra 2 are the root package's own
`tests/unit/` files. Both new regression test files execute in this run — the root one under
`tests/unit/`, the extension one under `extensions/drm-copilot/test/`.

Known CI gap (recorded in `spec.md`, not fixed here): no CI workflow executes this root entry point,
so `tests/unit/jest-config-resolution.test.ts` has no CI signal. The extension regression test, which
covers the identical mechanism, does run in CI on windows-latest and ubuntu-latest.

Output Summary: PASS. `node run-jest.cjs` exits 0 with **171 test suites passed / 171 total** and
**2061 tests passed / 2061 total**, zero failures, in 2.978 s. Counts are identical to the [P3-T4]
capture and match the on-disk inventory. No loop restart triggered. Root package toolchain (format →
lint → typecheck → test) completed clean in a single uninterrupted pass.
