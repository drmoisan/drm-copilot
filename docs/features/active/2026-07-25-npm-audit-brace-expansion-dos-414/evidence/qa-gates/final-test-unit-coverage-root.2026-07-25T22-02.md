# Final QA Gate — Post-Change Coverage, Repository Root (#414, [P4-T5])

Timestamp: 2026-07-25T22-02

[P4-T5] requires BOTH invocations. Both were executed in the repository root AFTER the manifest edit, lockfile regeneration, and [P4-T1] `npm ci`.

Command: (a) `npm run test:unit:coverage` (working directory: repository root)
EXIT_CODE: 1

Command: (b) `node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"` (rootDir-free invocation of the same jest binary and config, working directory: repository root)
EXIT_CODE: 0

## Invocation (a) — Verbatim Output

```text
> drm-copilot@1.0.0 test:unit:coverage
> node run-jest.cjs --coverage

No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5
  443 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/tests/unit/**/*.test.ts, C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/extensions/drm-copilot/test/**/*.test.ts - 0 matches
  testPathIgnorePatterns: \\node_modules\\, \\out\\ - 441 matches
  testRegex:  - 0 matches
Pattern:  - 0 matches
```

## Worktree-Path Artifact — Cause of Invocation (a)'s Exit 1

This is the same condition recorded at baseline in [P0-T11] and dispositioned by the orchestrator as Condition B. It is an artifact of the worktree location, **not a repository defect and not a #414 regression**.

This execution runs in the git worktree

```text
C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5
```

whose absolute path contains the dot-directory component `.claude`. `jest.config.cjs` declares `testMatch` as `<rootDir>/tests/unit/**/*.test.ts` and `<rootDir>/extensions/drm-copilot/test/**/*.test.ts`. After `<rootDir>` substitution jest emits the separator preceding `.claude` as a backslash, as the resolved pattern in the output above shows:

```text
C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/tests/unit/**/*.test.ts
```

The glob matcher consumes that backslash as an escape rather than a path separator, so the pattern can never match a real path and reports `0 matches`. The test files themselves are present and `443 files checked` confirms jest walked the tree. The condition would not reproduce on a CI runner or in a checkout whose path has no dot-directory component, and it is identical before and after the #414 change (invocation (a) returned the same exit 1 with the same message at the [P0-T11] baseline, before any manifest edit).

No remediation is applied: `jest.config.cjs` is outside the four-file change set authorized by `spec.md`, and editing it would violate the change-set acceptance criteria for #414. The condition is recorded for separate filing in [P6-T6] (Condition C).

## Invocation (b) — rootDir-free run, results

The identical invocation with the same two patterns expressed without the `<rootDir>` prefix passes. Same jest binary, same config file, same coverage provider, run against the regenerated dependency tree:

```text
All files                                                   |      97 |    89.06 |   89.28 |      97 |

Test Suites: 169 passed, 169 total
Tests:       2032 passed, 2032 total
Snapshots:   0 total
Time:        7.21 s
Ran all test suites.
```

Column order in the jest text reporter is `% Stmts | % Branch | % Funcs | % Lines`.

## Numeric Post-Change Coverage

| Metric | Post-change value | Policy threshold | Status |
|---|---|---|---|
| Line coverage | 97.00% | >= 85% | PASS |
| Branch coverage | 89.06% | >= 75% | PASS |
| Statement coverage | 97.00% | n/a | — |
| Function coverage | 89.28% | n/a | — |

Test totals post-change: 169 suites passed / 169 total; 2032 tests passed / 2032 total; 0 failures.

## Significance for the Forced `minimatch` 9→10 Bump

This run is the primary exercise of the forced bump. Jest 30.4.x loads `glob@10.5.0` through its reporters, config resolution, and runtime, and `test-exclude@7.0.2` consumes `minimatch` directly for coverage include/exclude matching. Both now resolve `minimatch@10.2.5` instead of `minimatch@9.0.9`. All 2032 tests pass and coverage instrumentation produces complete numbers, so neither the module-resolution change nor the `brace-expansion` export-shape change caused a failure on this path.

## QA Loop Disposition

Acceptance for this task rests on the numeric values from invocation (b), which pass. No file was changed by either invocation. The Phase 4 loop continues to [P4-T6].

Output Summary: Invocation (a) `npm run test:unit:coverage` exits 1 in the repository root; invocation (b) the rootDir-free equivalent exits 0. Invocation (a)'s failure is the pre-existing, environment-scoped `<rootDir>` glob artifact of running from a worktree path containing the `.claude` dot-directory — jest resolves `testMatch` to a pattern with an escaped separator and reports `0 matches`. It is not a repository defect and not a #414 regression; the identical failure was recorded pre-edit at [P0-T11]. The suite is green under invocation (b): 169/169 suites and 2032/2032 tests passing. Numeric post-change coverage is line 97.00%, branch 89.06% (statements 97.00%, functions 89.28%), both above the >=85% line / >=75% branch policy thresholds. These values are compared against the [P0-T11] baseline in [P4-T7].
