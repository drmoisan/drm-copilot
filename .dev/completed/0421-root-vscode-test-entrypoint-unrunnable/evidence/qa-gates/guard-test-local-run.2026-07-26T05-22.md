# QA Gate — Guard Test Local Run and Name Proof (#421)

Timestamp: 2026-07-26T05-22

Task: [P2-T2] — AC3, AC4 (local), AC7 evidence.

Command:

```
node run-jest.cjs --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"
node run-jest.cjs --listTests --testMatch "**/tests/unit/**/*.test.ts"
node run-jest.cjs --testMatch "**/tests/unit/**/*.test.ts" --testPathPatterns "vscode-test-removal"
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab68fbeb0ce28fc0d` (repository/worktree root)

EXIT_CODE: 0 (all three commands)

## Command 1 — Full root jest suite (path-independent invocation)

```
$ node run-jest.cjs --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"
Test Suites: 170 passed, 170 total
Tests:       2038 passed, 2038 total
Snapshots:   0 total
Time:        2.386 s, estimated 5 s
Ran all test suites.
```

EXIT_CODE: 0. All 170 suites pass; no suite failed, skipped, or was marked todo.

Delta against the [P0-T9] baseline (169 suites / 2036 tests): **+1 suite, +2 tests** — exactly the new `tests/unit/vscode-test-removal.test.ts` and its two test cases. No pre-existing suite changed state.

## Command 2 — Suite discovery by path (`--listTests`)

```
$ node run-jest.cjs --listTests --testMatch "**/tests/unit/**/*.test.ts"
C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab68fbeb0ce28fc0d\tests\unit\vscode-test-removal.test.ts
C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab68fbeb0ce28fc0d\tests\unit\hello-typescript.test.ts
```

The absolute path of `tests/unit/vscode-test-removal.test.ts` is present in the discovered-test list. This confirms the guard is auto-discovered under the `tests/unit/**/*.test.ts` pattern, which is the same pattern the committed `jest.config.cjs` declares as `<rootDir>/tests/unit/**/*.test.ts`. No jest configuration change was required or made (AC3).

## Command 3 — Guard suite executed by name (`--testPathPatterns`)

```
$ node run-jest.cjs --testMatch "**/tests/unit/**/*.test.ts" --testPathPatterns "vscode-test-removal"
Test Suites: 1 passed, 1 total
Tests:       2 passed, 2 total
Snapshots:   0 total
Time:        0.324 s, estimated 1 s
Ran all test suites matching vscode-test-removal.
```

Both required strings are present: `Test Suites: 1 passed, 1 total` and `Ran all test suites matching vscode-test-removal.` The guard suite is executed and passing, and its two test cases (`no root npm script invokes the vscode-test runner`, `no dead vscode-test config file exists at the repository root`) both pass.

## Note on per-suite `PASS <path>` lines

Per the [P2-T2] task text, a per-suite `PASS <path>` line is not required locally. Jest emits those lines through ANSI cursor-control sequences that do not survive this environment's output capture; this was verified during plan preflight, including with `--verbose`, which still yields only the summary block. Suite-name proof is therefore established by Command 2 (`--listTests` naming the absolute path) plus Command 3 (`Test Suites: 1 passed, 1 total` with `Ran all test suites matching vscode-test-removal.`).

## Verification-constraint note (AC7)

The invocation above is the rootDir-free, path-independent form mandated by the plan's Global Constraint 2. Plain `npm test` / `npm run test:unit` cannot pass in this worktree because the worktree path contains the dot-directory `.claude`, triggering the pre-existing jest `<rootDir>` glob-escape artifact (#414 Condition 3). `jest.config.cjs` and `run-jest.cjs` are forbidden files in this workstream, so that artifact is not repairable here. The authoritative verification of a passing root `npm test` is the Phase 5 CI run on a checkout path without a dot-directory component.

Output Summary: All three commands exited 0. Full root jest suite: **170 suites passed / 170 total, 2038 tests passed / 2038 total** (baseline was 169/2036 — delta is exactly the new guard suite and its 2 tests). `--listTests` names the absolute path of `tests/unit/vscode-test-removal.test.ts`, proving auto-discovery under the existing `testMatch` with no jest configuration change. The name-scoped run reports `Test Suites: 1 passed, 1 total` and `Ran all test suites matching vscode-test-removal.` AC3, AC4 (local half), and AC7 evidence established.
