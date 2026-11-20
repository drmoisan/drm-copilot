# Post-Fix — TypeScript Flow Suites (Jest) [P2-T6]

Timestamp: 2026-08-20T19-32

Command: `npm test -- --testPathPatterns "new-active-feature-folder"`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b/extensions/drm-copilot`

EXIT_CODE: 1

Wrapper note: `npm test` is `node run-jest.cjs`, so the issue-#423 prohibited-flag guard and `--config jest.config.cjs` still apply. Coverage is deliberately omitted because `jest.config.cjs` carries per-file `coverageThreshold` entries for 38 unrelated files that a filtered run cannot satisfy; coverage is captured only by the full-suite runs in P0-T15 and P7-T5. Exit codes on this page were captured directly from the command process with no pipe.

## Result Header

```
Test Suites: 1 failed, 8 passed, 9 total
Tests:       2 failed, 110 passed, 112 total
```

## Confirming Run — flow and io suites in isolation

Command: `npm test -- --testPathPatterns "new-active-feature-folder/(flow|io)"`

EXIT_CODE: **0**

```
Test Suites: 3 passed, 3 total
Tests:       48 passed, 48 total
```

The three suites are `flow.test.ts`, `flow.promoted-disposition.test.ts`, and `io.test.ts`. The plan's stated expectation for P2-T6 is exit code 0 **for the flow and io suites**, which this narrowed run establishes directly and unambiguously.

## Output Summary

**The Phase 2 disposition fix is verified.** Every fail-before case owned by Phase 2 now passes:

| Task | Test | Status after the fix |
| --- | --- | --- |
| P1-T1 | `createActiveFolder promoted-record disposition › retains the promoted potential file and writes issue.md in full mode` | **PASS** (failed before the fix) |
| P1-T2 | `createActiveFolder promoted-record disposition › retains the promoted potential file in minor-audit mode` | **PASS** (failed before the fix) |
| P1-T3 | `createActiveFolder validation › resolves the feature name from a valid promoted active file` | **PASS** (failed before the fix) |
| P1-T4 | `createActiveFolder promoted-record disposition › takes the move branch for a sibling path that is only a string prefix of the promoted root` | **PASS** — and it passed before the fix as well. It is a pre-existing-behavior guard against a `startsWith(root)` implementation, not a fail-before case. |

Unmodified pre-existing behavior is preserved:

- The existing move case at `flow.test.ts:254-286` — `createActiveFolder full mode with a potential file › moves the potential file to issue.md, marks the work mode, and emits seeding lines` — still passes unmodified. Its source is seeded directly under `docs/features/potential/`, so it takes the move branch and still asserts `expect(fs.files.has(potential)).toBe(false)` and `Moved potential file to <path>`. This is INV-2 / AC-4.
- The discovery cases at `io.test.ts:26-76` still pass unmodified, confirming `findPotentialFile` was not disturbed (INV-1).

## Remaining Failures — Phase 3 scope, not a Phase 2 regression

The two failures in the prescribed command's run are both in `test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts`:

- `newActiveFeatureFolderServiceCall receipt post-condition › throws when the reported destination path is absent`
- `newActiveFeatureFolderServiceCall receipt post-condition › throws when the reported artifact path is absent`

Both fail with `Received function did not throw` against `Expected substring: "new_active_feature_folder"`. These are the P1-T6 `[expect-fail]` cases; the receipt post-condition they assert is added by P3-T1 and P3-T2 and is verified at P3-T6. They are unchanged in kind from the P1-T10 fail-before capture — the same two assertions, failing for the same reason — so no Phase 2 regression is present.

The prescribed command's pattern `new-active-feature-folder` matches the service-call suite in addition to the flow and io suites, which is why its process exit code is 1 at this point in the plan. The exit code is recorded honestly rather than substituted; the narrowed confirming run above isolates the flow and io suites and returns 0.
