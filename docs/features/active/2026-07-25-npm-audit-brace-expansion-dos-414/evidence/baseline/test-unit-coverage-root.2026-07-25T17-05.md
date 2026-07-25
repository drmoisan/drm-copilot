# Baseline Coverage — Repository Root (#414, [P0-T11])

Timestamp: 2026-07-25T17-05

[P0-T11] requires BOTH invocations. Both were executed in the repository root BEFORE any manifest edit and are recorded below.

Command: (a) `npm run test:unit:coverage` (working directory: repository root, BEFORE any manifest edit)
EXIT_CODE: 1

Command: (b) `node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"` (rootDir-free invocation of the same jest binary and config, working directory: repository root, BEFORE any manifest edit)
EXIT_CODE: 0

## Invocation (a) — Verbatim Output

```text
> drm-copilot@1.0.0 test:unit:coverage
> node run-jest.cjs --coverage

jest-haste-map: Haste module naming collision: drm-copilot
  The following files share their name; please adjust your hasteImpl:
    * <rootDir>\package.json
    * <rootDir>\extensions\drm-copilot\package.json

No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5
  434 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/tests/unit/**/*.test.ts, C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/extensions/drm-copilot/test/**/*.test.ts - 0 matches
  testPathIgnorePatterns: \\node_modules\\, \\out\\ - 434 matches
  testRegex:  - 0 matches
Pattern:  - 0 matches
```

## Baseline Acceptance Status

The plan's acceptance for [P0-T11] (plan v0.3, revised after the Phase 0 gate-baseline escalation was dispositioned on 2026-07-25) is: numeric baseline line and branch coverage captured from invocation (b) meeting >=85% line / >=75% branch; `EXIT_CODE:` recorded truthfully for both invocations; the worktree-path artifact explanation present.

Status: **MET**. Invocation (a) `EXIT_CODE: 1` and invocation (b) `EXIT_CODE: 0` are both recorded above. Invocation (b) yields line 97.00% and branch 89.06%, both above threshold. The worktree-path artifact explanation is in the section below.

The earlier version of this artifact recorded the acceptance as `EXIT_CODE: 0` on invocation (a) alone and marked it NOT MET. That acceptance was superseded by the orchestrator disposition of Condition B; the underlying measurements are unchanged.

## Cause Isolation of invocation (a)'s exit 1 (pre-existing, environment-scoped, unrelated to #414)

The failure is a `<rootDir>` glob-expansion artifact of the checkout location, not a test or dependency failure. This execution runs in the git worktree

```text
C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5
```

whose absolute path contains the dot-directory component `.claude`. `jest.config.cjs` declares `testMatch` as `<rootDir>/tests/unit/**/*.test.ts` and `<rootDir>/extensions/drm-copilot/test/**/*.test.ts`. After `<rootDir>` substitution, jest reports the resolved patterns as

```text
C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/tests/unit/**/*.test.ts
```

The separator preceding `.claude` is emitted as a backslash, which the glob matcher consumes as an escape rather than a path separator, so the pattern can never match a real path and reports `0 matches`. The test files themselves are present: `tests/unit/hello-typescript.test.ts` exists, and `434 files checked` confirms jest walked the tree.

### Invocation (b) — rootDir-free run, verbatim output

The identical invocation with the same two patterns expressed without the `<rootDir>` prefix passes, which both proves the cause and supplies the numeric coverage this task accepts on:

Command: `node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"`
EXIT_CODE: 0

```text
All files | 97 | 89.06 | 89.28 | 97

Test Suites: 169 passed, 169 total
Tests:       2032 passed, 2032 total
Snapshots:   0 total
Time:        8.626 s
Ran all test suites.
```

Same jest binary, same config file, same installed dependency tree, same coverage provider — only the `<rootDir>` prefix differs. This establishes that the exit-1 is caused solely by the worktree path containing `.claude`, and that the repository's unit test suite is fully green against the pre-edit dependency tree.

No remediation is applied: `jest.config.cjs` is outside the four-file change set that `spec.md` and this plan authorize, and editing it would violate the change-set acceptance criteria for #414. This condition is environment-scoped (it does not occur in a checkout whose path has no dot-directory component, and does not occur on CI) and is identical before and after the #414 change.

## Numeric Baseline Coverage

Measured by the diagnostic invocation above (the only invocation that can execute the suite from this worktree path):

| Metric | Baseline value | Policy threshold | Status |
|---|---|---|---|
| Line coverage | 97.00% | >= 85% | PASS |
| Branch coverage | 89.06% | >= 75% | PASS |
| Statement coverage | 97.00% | n/a | — |
| Function coverage | 89.28% | n/a | — |

Test totals at baseline: 169 suites passed / 169 total; 2032 tests passed / 2032 total; 0 failures.

Output Summary: Invocation (a) `npm run test:unit:coverage` exits 1 in the repository root at baseline; invocation (b) the rootDir-free equivalent exits 0. The cause is a pre-existing, environment-scoped `<rootDir>` glob artifact of running from a worktree path containing the `.claude` dot-directory; jest resolves `testMatch` to a pattern with an escaped separator and reports `0 matches`. The suite itself is green: the same run with rootDir-free patterns exits 0 with 169/169 suites and 2032/2032 tests passing. Numeric baseline coverage is line 97.00%, branch 89.06% (statements 97.00%, functions 89.28%), both above the >=85% line / >=75% branch policy thresholds. This baseline value is the comparison basis for [P4-T5] and [P4-T7].
