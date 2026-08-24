# Pass-After Evidence — Root Jest Discovery (FIXED config)

Timestamp: 2026-07-26T01-14

Task: [P3-T4]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC4, AC9

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`
(unchanged from the fail-before capture — the same dot-prefixed `\.claude\worktrees\` path)
Config under test: `jest.config.cjs` with `testMatch: ["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]`

Command: `node run-jest.cjs`
EXIT_CODE: 0

## Full Output

```
Test Suites: 171 passed, 171 total
Tests:       2061 passed, 2061 total
Snapshots:   0 total
Time:        2.906 s, estimated 3 s
Ran all test suites.
```

## Discovered Suite Count Reconciliation

Observed: **171 test suites**, all passing. **2061 tests**, all passing.

On-disk inventory verified by direct enumeration:

| Command | Result |
|---|---|
| `find tests/unit -name "*.test.ts" -not -path "*/node_modules/*" \| wc -l` | 2 |
| `find extensions/drm-copilot/test -name "*.test.ts" -not -path "*/node_modules/*" \| wc -l` | 169 |
| Total | **171** |

Discovered count equals the on-disk inventory exactly: 171 = 171. No file was missed and no file was
over-matched. The inventory decomposes as recorded in the spec:

- `tests/unit/` — 2 files: `hello-typescript.test.ts` (pre-existing) +
  `jest-config-resolution.test.ts` (new, [P3-T1]).
- `extensions/drm-copilot/test/` — 169 files: 168 pre-existing +
  `jest-config-resolution.test.ts` (new, [P3-T2]).

This matches the spec's expectation of 171 test suites exactly.

## Before / After Comparison

| Metric | Fail-before ([P0-T3]) | Pass-after ([P3-T4]) |
|---|---|---|
| Exit code | 1 | 0 |
| testMatch matches | 0 | 171 |
| Test suites run | 0 | 171 passed |
| Tests run | 0 | 2061 passed |
| Diagnostic | `No tests found, exiting with code 1` | `Ran all test suites.` |

The only change between the two runs is the `testMatch` value in `jest.config.cjs` (see
`evidence/other/config-diff.2026-07-26T01-03.md`). The worktree path, the file tree, and every other
configuration key are identical. The fix is therefore isolated to the pattern change.

## Over-Match Check

The relative `**/`-anchored patterns did not over-match. If they had picked up test files under
`node_modules` or `out`, the discovered count would exceed the 171-file inventory. It does not. The
`testPathIgnorePatterns: ["/node_modules/", "/out/"]` entries remain in force (unchanged from base),
and the haste map does not retain `node_modules`.

Output Summary: PASS. Root `node run-jest.cjs` exits 0 with **171 test suites passed / 171 total**
and **2061 tests passed / 2061 total** in 2.906 s. The discovered suite count matches the on-disk
inventory exactly (2 under `tests/unit/` + 169 under `extensions/drm-copilot/test/`), confirming
neither under- nor over-matching. AC4 (root half) and AC9 satisfied.
