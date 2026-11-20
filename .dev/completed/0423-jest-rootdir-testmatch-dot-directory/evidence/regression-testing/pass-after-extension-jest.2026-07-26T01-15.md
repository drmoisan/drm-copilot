# Pass-After Evidence — Extension Jest Discovery (FIXED config)

Timestamp: 2026-07-26T01-15

Task: [P3-T5]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC4, AC10

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`
(unchanged from the fail-before capture — the same dot-prefixed `\.claude\worktrees\` path)
Config under test: `extensions/drm-copilot/jest.config.cjs` with `testMatch: ["**/test/**/*.test.ts"]`

Command: `npm --prefix extensions/drm-copilot run test`
EXIT_CODE: 0

## Full Output

```
> drm-copilot@1.0.19 test
> node run-jest.cjs


Test Suites: 169 passed, 169 total
Tests:       2046 passed, 2046 total
Snapshots:   0 total
Time:        2.395 s, estimated 7 s
Ran all test suites.
```

## Discovered Suite Count Reconciliation

Observed: **169 test suites**, all passing. **2046 tests**, all passing.

On-disk inventory verified by direct enumeration:

| Command | Result |
|---|---|
| `find extensions/drm-copilot/test -name "*.test.ts" -not -path "*/node_modules/*" \| wc -l` | 169 |

Discovered count equals the on-disk inventory exactly: 169 = 169. The inventory is 168 pre-existing
test files plus `jest-config-resolution.test.ts` (new, [P3-T2]). This matches the spec's expectation
of 169 test suites exactly.

The 169 suites here are the same 169 the root run discovered under
`extensions/drm-copilot/test/**`; the root run adds the 2 files under `tests/unit/` for its total of
171. The 2046 tests here plus the root package's 15 (14 from the new
`tests/unit/jest-config-resolution.test.ts` + 1 from `tests/unit/hello-typescript.test.ts`) equal the
root run's 2061, confirming the two runs are consistent.

## Before / After Comparison

| Metric | Fail-before ([P0-T4]) | Pass-after ([P3-T5]) |
|---|---|---|
| Exit code | 1 | 0 |
| testMatch matches | 0 | 169 |
| Test suites run | 0 | 169 passed |
| Tests run | 0 | 2046 passed |
| Files checked / diagnostic | 368 files checked, `No tests found, exiting with code 1` | `Ran all test suites.` |

The only change between the two runs is the `testMatch` value in
`extensions/drm-copilot/jest.config.cjs` (see `evidence/other/config-diff.2026-07-26T01-03.md`).
`testPathIgnorePatterns`, `collectCoverageFrom`, `coverageThreshold`, `coverageDirectory`, and the
ts-jest `tsconfig` reference are byte-identical to base.

## Over-Match Check

169 discovered suites equals the 169-file inventory, so the relative `**/test/**/*.test.ts` pattern
did not pick up anything under `node_modules` or `out`. Note this pattern is broader in form than the
root's — it anchors on any `test/` directory — but `testPathIgnorePatterns` and the haste map bound
it, and the exact inventory match confirms the bound holds in practice.

Output Summary: PASS. `npm --prefix extensions/drm-copilot run test` exits 0 with **169 test suites
passed / 169 total** and **2046 tests passed / 2046 total** in 2.395 s. The discovered suite count
matches the on-disk inventory exactly (168 pre-existing + 1 new), confirming neither under- nor
over-matching. AC4 (extension half) and AC10 satisfied. Combined with [P3-T4], AC4 is fully
satisfied.
