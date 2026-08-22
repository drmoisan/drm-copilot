# `claude-runtime` occurrence inventory, TypeScript push-down test tree (Issue #500)

Timestamp: 2026-08-21T23:03:56Z
Issue: #500
Task: [P0-T15]

Command:
```
git grep -n -F "claude-runtime" -- extensions/drm-copilot/test/lib/push-down
```
(working directory: worktree root)

EXIT_CODE: 0

Output Summary: **12** hits across three files. The inventory is reproduced verbatim below.

```
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts:45:      "claude-runtime": [".claude/**"],
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts:137:    expect(Object.keys(modules)).toEqual(["claude-runtime", "config"]);
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts:153:      "claude-runtime",
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts:240:      "claude-runtime": [".claude/**"],
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts:252:      "claude-runtime": [".claude/**"],
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts:338:      "claude-runtime",
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts:474:      "claude-runtime": [".claude/**"],
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts:44:      "claude-runtime": [".claude/**"],
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts:122:      "claude-runtime": [".claude/**"],
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts:292:      "claude-runtime": [".claude/**"],
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts:387:      "claude-runtime": [".claude/**"],
extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts:84:      "claude-runtime": [".claude/**"],
```

## Reconciliation against the twelve occurrences known at plan time

| Expected (plan P0-T15) | Observed | Status |
| --- | --- | --- |
| `blast-radius-derive-core.test.ts` lines 45, 137, 153, 240, 252, 338, 474 | 45, 137, 153, 240, 252, 338, 474 | exact match, 7 of 7 |
| `blast-radius-derive.test.ts` lines 44, 122, 292, 387 | 44, 122, 292, 387 | exact match, 4 of 4 |
| `config-carriage.test-helpers.ts` line 84 | 84 | exact match, 1 of 1 |

**No additional hit was found.** The observed set is exactly the twelve occurrences the plan
enumerates, at exactly the stated line numbers, so no edit target is added to the plan's scope.

This inventory supersedes the research artifact's enumeration, which omitted lines 45, 240, and 252
of `blast-radius-derive-core.test.ts`. Those three are seeded source-document constants and are
handled by task [P2-T3].

## Files deliberately outside this inventory

`extensions/drm-copilot/test/repo-automation-dispatch.test.ts` is NOT in the scanned path and is
not an edit target. Its six occurrences of the string `"C:/workspace/tests/claude-runtime"` (lines
292, 310, 330, 348, 366, 383) are filesystem-path fixtures, not the module name. A blanket rename
would corrupt them.
