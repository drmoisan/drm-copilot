# Phase 0 — TypeScript Test and Coverage Baseline (Issue #412)

Task: [P0-T13]

Status: **RECORDED WITH PRE-EXISTING FAILURE — task NOT checked off in the plan.**

Timestamp: 2026-07-25T17-36

Command: `cd extensions/drm-copilot && npm run test:coverage` (= `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`; workspace root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`)

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

The planned command **fails**: Jest resolves zero test files and exits 1. No coverage report
is produced, so the planned command cannot supply the numeric line/branch values this task's
acceptance requires. Per the baseline-honesty rule the real exit code is recorded, the
pre-existing failure is not fixed, and Phase 0 continues.

## Root Cause (diagnosed, not fixed)

`extensions/drm-copilot/jest.config.cjs` line 4 declares:

```js
testMatch: ["<rootDir>/test/**/*.test.ts"],
```

`<rootDir>` expands to the worktree path
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585/extensions/drm-copilot`.
That path contains the dot-prefixed directory `.claude`. Jest's reported effective pattern is

```
C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/.../test/**/*.test.ts
```

— the leading dot of `.claude` has been escaped to `\.`, and on Windows the backslash is also
a path separator, so the glob matches nothing. All 368 candidate files are checked and
discarded.

Confirmation that the test files themselves are present and resolvable — the same config with
a `<rootDir>`-relative pattern lists them correctly:

```
cd extensions/drm-copilot && npx jest --config jest.config.cjs --testMatch "**/test/**/*.test.ts" --listTests
```

```
...\extensions\drm-copilot\test\extension.workflow-commands.test.ts
...\extensions\drm-copilot\test\subagent-tree-command.test.ts
...\extensions\drm-copilot\test\lib\validate\epic-planner-readiness-integrity.test.ts
...\extensions\drm-copilot\test\lib\validate\epic-orchestrator-state-core.test.ts
(and further files)
```

This is an environment-specific pre-existing defect triggered by running the extension's Jest
suite from a worktree located beneath a dot-prefixed directory. It is not introduced by this
branch, is not caused by any Phase 0 action, and is **not** remediated here.

## Supplementary Coverage Figures (NOT the planned command)

To give the orchestrator usable baseline numbers, the same coverage invocation was repeated
once with a `<rootDir>`-relative `testMatch` override. **These figures do not come from the
planned command and do not satisfy [P0-T13]'s acceptance criteria.** They are recorded as
informational context only.

Supplementary command:

```
cd extensions/drm-copilot && node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --testMatch "**/test/**/*.test.ts"
```

Supplementary EXIT_CODE: 0

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

| Metric | Value |
|---|---|
| Line coverage | 96.33% (37643 / 39074) |
| Branch coverage | 89.21% (5201 / 5830) |
| Function coverage | 89.50% (1100 / 1229) |
| Test suites | 168 passed / 168 total |
| Tests | 2031 passed / 2031 total, 0 failed |

Per-file figures for the Phase 5 target, read from `extensions/drm-copilot/coverage/lcov.info`
(`SF:src\lib\validate\orchestrator-state-core.ts`), a tool output rather than an evidence
artifact:

| File | Lines hit/found | Line % | Branches hit/found | Branch % |
|---|---|---|---|---|
| `src/lib/validate/orchestrator-state-core.ts` | 399 / 406 | 98.28% | 65 / 69 | 94.20% |

Both clear the per-file `coverageThreshold` gate that `jest.config.cjs` sets for this file
(lines 85, branches 75).

Note that under this override every test in the extension passes, so the failure recorded
above is purely a test-discovery failure, not a test-correctness failure.

## Impact and Escalation

- [P0-T13] is left **unchecked** in the plan: its acceptance requires numeric coverage values
  produced by `npm run test:coverage`, and that command produces none in this environment.
- Phase 5 ([P5-T1] onward) and the final QA loop both depend on running the extension's Jest
  suite in this worktree. Unless the discovery failure is addressed or the runs are performed
  in a checkout that is not under a dot-prefixed directory, those tasks will report
  `No tests found` and exit 1 rather than exercising the new cases.
- Remediating this is outside the scope of issue #412 and is not attempted here. The
  orchestrator should decide whether it blocks Phase 5.
