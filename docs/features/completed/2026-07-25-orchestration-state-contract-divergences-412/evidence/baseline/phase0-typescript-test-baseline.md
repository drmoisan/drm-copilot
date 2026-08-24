# Phase 0 — TypeScript Test and Coverage Baseline (Issue #412)

Task: [P0-T13]

Status: **COMPLETE — acceptance judged on the discovery-override run (Invocation 2).**

Timestamp: 2026-07-25T18-40 (artifact revised to record both invocations per the revised
[P0-T13] task text; the measurements themselves were taken at 2026-07-25T17-36, before any
Phase 1–5 production change)

Working directory: `extensions/drm-copilot/`
(workspace root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`)

## Invocation 1 — planned command (as written in the plan)

Timestamp: 2026-07-25T17-36

Command: `npm run test:coverage` (= `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`)

EXIT_CODE: 1

Output Summary:

```
> drm-copilot@1.0.19 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a682ed107a9c0c585\extensions\drm-copilot
  368 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a682ed107a9c0c585/extensions/drm-copilot/test/**/*.test.ts - 0 matches
  testPathIgnorePatterns: \\node_modules\\, \\out\\ - 368 matches
  testRegex:  - 0 matches
Pattern:  - 0 matches
```

The planned command resolves zero test files and exits 1. It produces no coverage report, so it
cannot supply the numeric line/branch values this task requires. The real exit code is recorded
verbatim; the condition is not fixed.

## Environmental explanation (Jest discovery override, Plan Conventions)

`extensions/drm-copilot/jest.config.cjs` line 4 declares:

```js
testMatch: ["<rootDir>/test/**/*.test.ts"],
```

`<rootDir>` expands to the worktree path
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585/extensions/drm-copilot`,
which contains the dot-prefixed directory `.claude`. Jest's reported effective pattern is

```
C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/.../test/**/*.test.ts
```

— the leading dot of `.claude` is emitted as the escaped literal `\.`, and on Windows the
backslash is also a path separator, so the glob matches nothing. All 368 candidate files are
walked and discarded by the ignore patterns, confirming that the test files are present and only
the glob match fails.

This condition is environmental. It is not caused by this branch and does not affect CI, where
the checkout is not located under a dot-prefixed directory. `extensions/drm-copilot/jest.config.cjs`
MUST NOT be modified (plan Hard Constraint 12), so the baseline is measured using the
rootDir-relative override `--testMatch "**/test/**/*.test.ts"`. This is an override, not a skip:
the override run executes all 168 suites and all 2031 tests, and the `jest.config.cjs` per-file
`coverageThreshold` is still enforced by Jest.

## Invocation 2 — discovery override (authoritative baseline)

Timestamp: 2026-07-25T17-36

Command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --testMatch "**/test/**/*.test.ts"`

(equivalently `npm run test:coverage -- --testMatch "**/test/**/*.test.ts"`)

EXIT_CODE: 0

Output Summary:

```
=============================== Coverage summary ===============================
Statements   : 96.33% ( 37643/39074 )
Branches     : 89.21% ( 5201/5830 )
Functions    : 89.5% ( 1100/1229 )
Lines        : 96.33% ( 37643/39074 )
================================================================================

Test Suites: 168 passed, 168 total
Tests:       2031 passed, 2031 total
Snapshots:   0 total
Time:        9.139 s
```

## Stated pre-change baseline figures (authoritative for comparison)

These are the figures measured under the override at 2026-07-25T17-36, **before** any Phase 1–5
production change. `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` has since
been modified by [P5-T4], so these values are recorded here as the stated pre-change baseline and
must not be re-derived from the current tree.

| Metric | Pre-change baseline |
|---|---|
| Line coverage (repo-wide) | 96.33% (37643 / 39074) |
| Branch coverage (repo-wide) | 89.21% (5201 / 5830) |
| Statement coverage (repo-wide) | 96.33% (37643 / 39074) |
| Function coverage (repo-wide) | 89.50% (1100 / 1229) |
| Test suites | 168 passed / 168 total |
| Tests | 2031 passed / 2031 total, 0 failed |

Per-file figures for the Phase 5 target, read at the same time from
`extensions/drm-copilot/coverage/lcov.info` (record `SF:src\lib\validate\orchestrator-state-core.ts`):

| File | Line % | Branch % |
|---|---|---|
| `src/lib/validate/orchestrator-state-core.ts` | 98.28% (399 / 406) | 94.20% (65 / 69) |

Both clear the per-file `coverageThreshold` that `jest.config.cjs` sets for this file
(lines 85, branches 75). `jest.config.cjs` deliberately declares no `global` threshold key.

## Acceptance

Acceptance ([P0-T13]) is judged on Invocation 2, per the Jest discovery override in Plan
Conventions. The artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`
for both invocations, the environmental explanation, the repo-wide numeric line and branch
coverage values, and the per-file numbers for `src/lib/validate/orchestrator-state-core.ts`.
Under the override every test in the extension passes, so the Invocation 1 failure is a
test-discovery failure only, not a test-correctness failure.
