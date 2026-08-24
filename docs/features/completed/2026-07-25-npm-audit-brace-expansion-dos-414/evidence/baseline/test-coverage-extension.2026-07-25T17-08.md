# Baseline Coverage — `extensions/drm-copilot` (#414, [P0-T13])

Timestamp: 2026-07-25T17-08

[P0-T13] requires BOTH invocations. Both were executed in `extensions/drm-copilot` BEFORE any manifest edit and are recorded below.

Command: (a) `npm run test:coverage` (working directory: `extensions/drm-copilot`, BEFORE any manifest edit)
EXIT_CODE: 1

Command: (b) `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --testMatch "**/test/**/*.test.ts"` (rootDir-free invocation of the same jest binary and config, working directory: `extensions/drm-copilot`, BEFORE any manifest edit)
EXIT_CODE: 0

## Invocation (a) — Verbatim Output

```text
> drm-copilot@1.0.19 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5\extensions\drm-copilot
  368 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/extensions/drm-copilot/test/**/*.test.ts - 0 matches
  testPathIgnorePatterns: \\node_modules\\, \\out\\ - 368 matches
  testRegex:  - 0 matches
Pattern:  - 0 matches
```

## Baseline Acceptance Status

The plan's acceptance for [P0-T13] (plan v0.3, revised after the Phase 0 gate-baseline escalation was dispositioned on 2026-07-25) is: numeric baseline line and branch coverage captured from invocation (b) meeting >=85% line / >=75% branch; `EXIT_CODE:` recorded truthfully for both invocations; the worktree-path artifact explanation present.

Status: **MET**. Invocation (a) `EXIT_CODE: 1` and invocation (b) `EXIT_CODE: 0` are both recorded above. Invocation (b) yields line 96.33% and branch 89.21%, both above threshold. The worktree-path artifact explanation is in the section below.

The earlier version of this artifact recorded the acceptance as `EXIT_CODE: 0` on invocation (a) alone and marked it NOT MET. That acceptance was superseded by the orchestrator disposition of Condition B; the underlying measurements are unchanged.

## Cause Isolation of invocation (a)'s exit 1 (identical to [P0-T11]; pre-existing, environment-scoped, unrelated to #414)

This is the same `<rootDir>` glob-expansion artifact recorded for the repository root in [P0-T11]. The worktree absolute path

```text
C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5
```

contains the `.claude` dot-directory component. After `<rootDir>` substitution jest emits the separator preceding `.claude` as a backslash, which the glob matcher consumes as an escape rather than a path separator, so `testMatch` reports `0 matches` even though `368 files checked` confirms jest walked the tree and the test files are present.

### Invocation (b) — rootDir-free run, verbatim output

The identical invocation with the same pattern expressed without the `<rootDir>` prefix passes, which both proves the cause and supplies the numeric coverage this task accepts on:

Command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --testMatch "**/test/**/*.test.ts"`
EXIT_CODE: 0

```text
=============================== Coverage summary ===============================
Statements   : 96.33% ( 37643/39074 )
Branches     : 89.21% ( 5201/5830 )
Functions    : 89.5% ( 1100/1229 )
Lines        : 96.33% ( 37643/39074 )
================================================================================

Test Suites: 168 passed, 168 total
Tests:       2031 passed, 2031 total
Snapshots:   0 total
Time:        8.468 s
Ran all test suites.
```

Same jest binary, same config, same installed dependency tree — only the `<rootDir>` prefix differs. No remediation is applied: the extension's jest configuration is outside the four-file change set authorized by `spec.md`, and editing it would violate the change-set acceptance criteria for #414. The condition is identical before and after the #414 change.

## Numeric Baseline Coverage

| Metric | Baseline value | Absolute counts | Policy threshold | Status |
|---|---|---|---|---|
| Line coverage | 96.33% | 37643/39074 | >= 85% | PASS |
| Branch coverage | 89.21% | 5201/5830 | >= 75% | PASS |
| Statement coverage | 96.33% | 37643/39074 | n/a | — |
| Function coverage | 89.50% | 1100/1229 | n/a | — |

Test totals at baseline: 168 suites passed / 168 total; 2031 tests passed / 2031 total; 0 failures.

Output Summary: Invocation (a) `npm run test:coverage` exits 1 in `extensions/drm-copilot` at baseline for the same pre-existing, environment-scoped `<rootDir>` glob artifact documented in [P0-T11]; jest reports `0 matches` from a worktree path containing `.claude`; invocation (b) the rootDir-free equivalent exits 0. The suite itself is green: the rootDir-free equivalent exits 0 with 168/168 suites and 2031/2031 tests passing. Numeric baseline coverage is line 96.33% (37643/39074), branch 89.21% (5201/5830), statements 96.33%, functions 89.50% (1100/1229), all above the >=85% line / >=75% branch policy thresholds. This baseline value is the comparison basis for [P5-T5] and [P5-T6].
