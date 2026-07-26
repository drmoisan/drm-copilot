# Phase 5 [P5-T3] — TypeScript fail-before (expect-fail)

Timestamp: 2026-07-25T18-31

Task: [P5-T3] [expect-fail] — run the new Phase 5 Jest cases before the
`orchestrator-state-core.ts` production change.

Working directory for both invocations: `extensions/drm-copilot/`

## Invocation 1 — planned command (as written in the plan)

Command: `node run-jest.cjs test/lib/validate/orchestrator-state-core.test.ts test/lib/validate/orchestrator-state-core.completion.test.ts`

EXIT_CODE: 1

Output Summary:

```
No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a682ed107a9c0c585\extensions\drm-copilot
  371 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a682ed107a9c0c585/extensions/drm-copilot/test/**/*.test.ts - 0 matches
  testPathIgnorePatterns: \\node_modules\\, \\out\\ - 371 matches
  testRegex:  - 0 matches
Pattern: test/lib/validate/orchestrator-state-core.test.ts|test/lib/validate/orchestrator-state-core.completion.test.ts - 0 matches
```

## Environmental explanation (Jest discovery override, Plan Conventions)

This worktree is located under the dot-directory `.claude`. `jest.config.cjs`
declares `testMatch: ["<rootDir>/test/**/*.test.ts"]`; when `<rootDir>` is
expanded, the leading dot of `.claude` is emitted as the escaped literal `\.`
inside the glob (visible verbatim in the `testMatch:` line above), so the
resulting pattern matches nothing and every Jest invocation reports
`No tests found` and exits 1. The reported `371 files checked` /
`testPathIgnorePatterns ... 371 matches` confirms Jest walked the tree and
found the files but could not match them against the escaped glob.

This condition is environmental. It is not caused by this branch and does not
affect CI, where the checkout is not under a dot-directory.
`extensions/drm-copilot/jest.config.cjs` MUST NOT be modified (plan Hard
Constraint 12), so the gate is evaluated using the rootDir-relative override
`--testMatch "**/test/**/*.test.ts"` at invocation time. This is an override,
not a skip: the override run below executes all 168 suites.

## Invocation 2 — discovery override (authoritative for this task)

Command: `node run-jest.cjs --testMatch "**/test/**/*.test.ts" test/lib/validate/orchestrator-state-core.test.ts test/lib/validate/orchestrator-state-core.completion.test.ts`

EXIT_CODE: 1 (expected: this is an `[expect-fail]` task)

Output Summary:

```
Test Suites: 2 failed, 166 passed, 168 total
Tests:       2 failed, 2033 passed, 2035 total
Snapshots:   0 total
Time:        3.975 s
Ran all test suites.
```

Failing tests — both are new Phase 5 cases, and only new Phase 5 cases fail:

1. `test/lib/validate/orchestrator-state-core.test.ts`
   → `validateOrchestratorStateText per-step-key status vocabulary ›
      accepts each per-key extra status on its owning step key` ([P5-T1] case a)
   Actual: `["Checkpoint has invalid step9_status: passed"]`, expected `[]`.
   Pre-fix defect: the shared `VALID_STEP_STATUS` set is the only vocabulary,
   so the documented per-key values are rejected on their owning keys.

2. `test/lib/validate/orchestrator-state-core.completion.test.ts`
   → `validateOrchestratorStateText completion gates ›
      rejects each documented failure step status under requireComplete`
      ([P5-T2] case a)
   Actual completion errors contain no
   `Checkpoint completion validation failed: step9_status is failed_remediation_required.`
   Pre-fix defect: the completion check only tests
   `value === "pending" || value === "blocked"`.

New cases that already pass pre-fix (expected, no production change needed for
them to hold — they assert behavior that must be preserved):

- `rejects each per-key extra status on every non-owning step key` ([P5-T1]
  case b) — passes because the pre-fix validator rejects every extra value on
  every key; it must continue to reject them on non-owning keys after the fix.
- `does not block completion on step9_status passed` ([P5-T2] case b) — passes
  because `passed` is not in the pre-fix `{pending, blocked}` set; it must not
  be added to the blocking set by the fix.

Pre-existing suites: 166 of 168 pass; 2033 of 2035 tests pass. No pre-existing
test was modified (`git diff --stat` on both test files shows insertions only:
49 and 35 lines, 0 deletions).

Acceptance ([P5-T3]): met on the override run — only the new cases fail.
