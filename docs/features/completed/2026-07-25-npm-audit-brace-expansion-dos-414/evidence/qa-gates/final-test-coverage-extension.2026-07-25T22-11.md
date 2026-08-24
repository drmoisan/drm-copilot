# Final QA Gate — Post-Change Coverage, `extensions/drm-copilot` (#414, [P5-T5])

Timestamp: 2026-07-25T22-11

[P5-T5] requires BOTH invocations. Both were executed in `extensions/drm-copilot` AFTER the manifest edit, lockfile regeneration, and [P5-T1] `npm ci`.

Command: (a) `npm run test:coverage` (working directory: `extensions/drm-copilot`)
EXIT_CODE: 1

Command: (b) `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --testMatch "**/test/**/*.test.ts"` (rootDir-free invocation of the same jest binary and config, working directory: `extensions/drm-copilot`)
EXIT_CODE: 0

## Invocation (a) — Verbatim Output

```text
> drm-copilot@1.0.19 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5\extensions\drm-copilot
  373 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/extensions/drm-copilot/test/**/*.test.ts - 0 matches
  testPathIgnorePatterns: \\node_modules\\, \\out\\ - 371 matches
  testRegex:  - 0 matches
Pattern:  - 0 matches
```

## Worktree-Path Artifact — Cause of Invocation (a)'s Exit 1

This is the same condition recorded at baseline in [P0-T13] and [P0-T11], dispositioned by the orchestrator as Condition B. It is an artifact of the worktree location, **not a repository defect and not a #414 regression**.

The worktree absolute path

```text
C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5
```

contains the dot-directory component `.claude`. After `<rootDir>` substitution jest emits the separator preceding `.claude` as a backslash, as the resolved pattern in the output above shows:

```text
C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/extensions/drm-copilot/test/**/*.test.ts
```

The glob matcher consumes that backslash as an escape rather than a path separator, so the pattern reports `0 matches` even though `373 files checked` confirms jest walked the tree and the test files are present. The condition would not reproduce on a CI runner or in a checkout whose path has no dot-directory component, and it is identical before and after the #414 change (invocation (a) returned the same exit 1 with the same message at the [P0-T13] baseline, before any manifest edit).

No remediation is applied: the extension's jest configuration is outside the four-file change set authorized by `spec.md`, and editing it would violate the change-set acceptance criteria for #414. The condition is recorded for separate filing in [P6-T6] (Condition C).

## Invocation (b) — rootDir-free run, verbatim output

The identical invocation with the same pattern expressed without the `<rootDir>` prefix passes. Same jest binary, same config, same coverage reporters, run against the regenerated dependency tree:

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
Time:        6.866 s
Ran all test suites.
```

## Numeric Post-Change Coverage

| Metric | Post-change value | Absolute counts | Policy threshold | Status |
|---|---|---|---|---|
| Line coverage | 96.33% | 37643/39074 | >= 85% | PASS |
| Branch coverage | 89.21% | 5201/5830 | >= 75% | PASS |
| Statement coverage | 96.33% | 37643/39074 | n/a | — |
| Function coverage | 89.50% | 1100/1229 | n/a | — |

Test totals post-change: 168 suites passed / 168 total; 2031 tests passed / 2031 total; 0 failures.

## Significance for the Forced `minimatch` 9→10 Bump

Jest 30.4.x loads `glob@10.5.0` through its reporters, config resolution, and runtime, and `test-exclude@7.0.2` consumes `minimatch` directly for coverage include/exclude matching. Both now resolve `minimatch@10.2.5` instead of `minimatch@9.0.9` in the extension tree. All 2031 tests pass and coverage instrumentation produces complete numbers with unchanged absolute counts, so neither the module-resolution change nor the `brace-expansion` export-shape change caused a failure on this path.

## QA Loop Disposition

Acceptance for this task rests on the numeric values from invocation (b), which pass. No file was changed by either invocation. The Phase 5 loop continues to [P5-T6].

Output Summary: Invocation (a) `npm run test:coverage` exits 1 in `extensions/drm-copilot`; invocation (b) the rootDir-free equivalent exits 0. Invocation (a)'s failure is the pre-existing, environment-scoped `<rootDir>` glob artifact of running from a worktree path containing the `.claude` dot-directory — jest reports `0 matches`. It is not a repository defect and not a #414 regression; the identical failure was recorded pre-edit at [P0-T13]. The suite is green under invocation (b): 168/168 suites and 2031/2031 tests passing. Numeric post-change coverage is line 96.33% (37643/39074), branch 89.21% (5201/5830), statements 96.33%, functions 89.50% (1100/1229), all above the >=85% line / >=75% branch policy thresholds. These values are compared against the [P0-T13] baseline in [P5-T6].
