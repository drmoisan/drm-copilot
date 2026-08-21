# Fail-Before — TypeScript (Jest) [P1-T10]

Timestamp: 2026-08-20T19-16

Command: `npm test -- --testPathPatterns "new-active-feature-folder|potential-to-issue|promotion-lifecycle-sequence"`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b/extensions/drm-copilot`

EXIT_CODE: 1 (expected non-zero — this is the fail-before capture)

Wrapper note: `npm test` is `node run-jest.cjs`, so the issue-#423 prohibited-flag guard and `--config jest.config.cjs` still apply. Coverage is deliberately omitted: `jest.config.cjs` carries per-file `coverageThreshold` entries for 38 unrelated files that a filtered run cannot satisfy. Coverage is captured only by the full-suite runs in P0-T15 and P7-T5. The exit code was captured directly from the command process with no pipe.

## Result Header

```
Test Suites: 5 failed, 12 passed, 17 total
Tests:       7 failed, 217 passed, 224 total
```

## Output Summary

Seven tests fail before the fix. Each is listed below with the task that authored it and the assertion that failed.

| Task | Suite | Failing test | Assertion that failed |
| --- | --- | --- | --- |
| P1-T1 | `test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts` | `createActiveFolder promoted-record disposition › retains the promoted potential file and writes issue.md in full mode` | `expect(fs.files.has(promoted)).toBe(true)` — `Expected: true, Received: false`. The full branch at `flow.ts:346` moved the promoted source instead of copying it. |
| P1-T2 | `test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts` | `createActiveFolder promoted-record disposition › retains the promoted potential file in minor-audit mode` | `expect(fs.files.has(promoted)).toBe(true)` — the minor-audit branch at `flow.ts:283` moved the promoted source instead of copying it. |
| P1-T3 | `test/lib/new-active-feature-folder/flow.test.ts` | `createActiveFolder validation › resolves the feature name from a valid promoted active file` | `expect(fs.files.has(promoted)).toBe(true)` — the added retention assertion on the pre-existing auto-resolve case. |
| P1-T5 | `test/lib/promotion-lifecycle-sequence.test.ts` | `promotion lifecycle sequence › retains the promoted record across potential_to_issue then new_active_feature_folder` | `expect(fs.files.has(PROMOTED_PATH)).toBe(true)` after the second call — the record `promotePotential` created was removed by `createActiveFolder`. |
| P1-T6 | `test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` | `newActiveFeatureFolderServiceCall receipt post-condition › throws when the reported destination path is absent` | `expect(...).toThrow("new_active_feature_folder")` — `Received function did not throw`. No post-condition exists yet. |
| P1-T6 | `test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` | `newActiveFeatureFolderServiceCall receipt post-condition › throws when the reported artifact path is absent` | `expect(...).toThrow("new_active_feature_folder")` — `Received function did not throw`. |
| P1-T7 | `test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` | `potentialToIssueServiceCall receipt post-condition › throws when the promoted destination is absent` | `expect(...).toThrow("potential_to_issue")` — `Received function did not throw`. No post-condition exists yet. |

**P1-T4 passed.** `createActiveFolder promoted-record disposition › takes the move branch for a sibling path that is only a string prefix of the promoted root` is not in the failing set. It is a pre-existing-behavior guard against a `startsWith(root)` implementation, not a fail-before case, and is therefore not tagged `[expect-fail]`. It must continue to pass after the fix (re-verified at P2-T6).

**P1-T6 third case passed.** `returns the enriched record when every reported path exists` passes before the fix as well; it is the success arm of the new failure branch and exists so both arms are exercised. The same applies to the P1-T7 case `returns the enriched record when the destination exists`.

The five failing suites are exactly the five files this change touches or adds. The 12 passing suites in the filtered set are unmodified and remain green.
