# R3 Atomic-Replace Recovery — Green Run — Issue #614 Remediation

Timestamp: 2026-09-07T02-19
Cycle: 2026-09-06T23-30
Task: [P3-T4]
EXIT_CODE: 0

## 1. Production correction applied

In `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts`:

- Added the private method `discardCandidate(candidatePath: string): void` immediately
  after `stageMaterialization`. It calls `this.dependencies.fileSystem.removeFile` and
  swallows a removal failure under the existing comment
  `The blocked result names the retained candidate for explicit cleanup.`
- Replaced the inline try/catch cleanup on the candidate re-validation failure path with a
  call to `discardCandidate`.
- Added a `discardCandidate` call to the atomic-replace failure path and changed that
  path's `affectedPaths` from `[preparation.destinationPath]` to
  `[preparation.candidatePath]`, so an operator recovering from a failed rename is told
  which file remains. The destination checkpoint is untouched on that path.

Both paths keep `HANDOFF_VALIDATOR_UNAVAILABLE`. No other failure code, condition, or
ordering changed.

## 2. Jest run

Command: `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts` run from `extensions/drm-copilot`
EXIT_CODE: 0

```
Test Suites: 1 passed, 1 total
Tests:       41 passed, 41 total
Snapshots:   0 total
Time:        0.352 s, estimated 1 s
```

Passed: 41. Failed: 0. P3-T1 recorded 34, so the count is exactly seven greater.

## 3. Line count

Command: `(Get-Content -LiteralPath extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts).Count` run from the workspace root

```
444
```

444 is at most 500. The module grew by five lines from the 439 recorded in P0-T3.

## 4. Failure-code inventory

Command: `Select-String -LiteralPath extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts -Pattern 'HANDOFF_[A-Z_]+' -AllMatches -CaseSensitive | ForEach-Object { $_.Matches.Value } | Group-Object | Sort-Object Name | ForEach-Object { "$($_.Name) $($_.Count)" }`

```
HANDOFF_DIRTY_WORKTREE 1
HANDOFF_HISTORY_INVALID 1
HANDOFF_PLAN_PATH_INVALID 3
HANDOFF_PROVIDER_ROUTING_UNAVAILABLE 1
HANDOFF_SOURCE_HASH_MISMATCH 3
HANDOFF_UNSUPPORTED_VERSION 1
HANDOFF_VALIDATOR_UNAVAILABLE 10
HANDOFF_WORKSPACE_MISMATCH 1
```

This is identical, name for name and count for count, to the inventory recorded in P0-T3.
The correction therefore changes which file a failure names, not which failure any
condition returns.

Output Summary: The correction makes the seventh test pass; the suite exits 0 with 41
passed and 0 failed, seven more than the 34 recorded in P3-T1. The module stands at 444
lines and its failure-code inventory is unchanged from the P0-T3 baseline.
