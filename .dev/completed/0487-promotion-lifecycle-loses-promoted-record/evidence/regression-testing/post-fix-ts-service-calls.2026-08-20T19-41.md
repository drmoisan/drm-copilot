# Post-Fix — TypeScript Service Calls and Lifecycle Sequence (Jest) [P3-T6]

Timestamp: 2026-08-20T19-41

Command: `npm test -- --testPathPatterns "service-call|promotion-lifecycle-sequence"`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b/extensions/drm-copilot`

EXIT_CODE: 0

Wrapper note: `npm test` is `node run-jest.cjs`, so the issue-#423 prohibited-flag guard and `--config jest.config.cjs` still apply. Coverage is deliberately omitted because `jest.config.cjs` carries per-file `coverageThreshold` entries for 38 unrelated files that a filtered run cannot satisfy; coverage is captured only by the full-suite runs in P0-T15 and P7-T5. The exit code was captured directly from the command process with no pipe.

## Result Header

```
Test Suites: 11 passed, 11 total
Tests:       59 passed, 59 total
```

## Output Summary

**All Phase 1 fail-before cases owned by Phase 3 now pass, and every unrelated service-call suite in the filtered set stays green.**

| Task | Test | Before the fix | After the fix |
| --- | --- | --- | --- |
| P1-T5 | `promotion lifecycle sequence › retains the promoted record across potential_to_issue then new_active_feature_folder` | FAIL | **PASS** |
| P1-T6 | `newActiveFeatureFolderServiceCall receipt post-condition › throws when the reported destination path is absent` | FAIL | **PASS** |
| P1-T6 | `newActiveFeatureFolderServiceCall receipt post-condition › throws when the reported artifact path is absent` | FAIL | **PASS** |
| P1-T7 | `potentialToIssueServiceCall receipt post-condition › throws when the promoted destination is absent` | FAIL | **PASS** |

## Both Arms of Each New Failure Branch Are Exercised

The post-condition added by P3-T2 and P3-T4 introduces a new conditional in each service call. Each has a failure arm and a success arm, and both are covered:

| Service call | Failure arm (throws) | Success arm (returns the enriched record) |
| --- | --- | --- |
| `newActiveFeatureFolderServiceCall` — `result.target` | `throws when the reported destination path is absent` | `returns the enriched record when every reported path exists` (asserts `destinationPath` is `/ws/docs/features/active/notes-feature`) |
| `newActiveFeatureFolderServiceCall` — `result.potentialIssuePath` | `throws when the reported artifact path is absent` | `returns the enriched record when every reported path exists` (asserts `artifacts` is `["/ws/docs/features/active/notes-feature/issue.md"]`) |
| `potentialToIssueServiceCall` — `outcome.destination` | `throws when the promoted destination is absent` | `returns the enriched record when the destination exists` (asserts `destinationPath` and `artifacts`) |

The null/undefined arms are also covered by pre-existing cases: `returns the preserved tool, workspaceRoot, summary, and destinationPath` runs with no potential file, so `result.potentialIssuePath` is null and the artifact check is correctly skipped.

Each failing-arm test asserts twice against a freshly built filesystem: once that the message names the tool (`new_active_feature_folder` / `potential_to_issue`) and once that it names the absent path. Both are required by the plan so a receipt failure is diagnosable from the message alone. `toFailureToolResult` (`extensions/drm-copilot/src/mcp-tools.ts:110-123`) renders a thrown `Error` as `ok: false` with the message as `summary`, so the MCP surface reports the failure rather than a partially populated `ok: true` receipt.

## Correction Made During This Task

The first execution of this command returned exit code 1 with one failure: `throws when the reported destination path is absent` threw `Template folder not found: /ws/templates/feature` instead of the receipt message. The cause was a defect in the P1-T6 test setup, not in the production change — the second `expect` in that case constructed a bare `BlockedPathFolderFileSystem` without seeding the template tree, so the workflow failed earlier than the post-condition. The test was corrected to build a seeded filesystem for each of the two assertions, matching the pattern already used by the artifact case. The production post-condition was not altered in response. The rerun returned exit code 0, recorded above.

## Scope Verification (P3-T5)

`extensions/drm-copilot/src/mcp-tools.ts` is unmodified: `git diff --stat` on that path returns no output. `toMcpToolResult` (`:88-108`) and `toFailureToolResult` (`:110-123`) keep their current shape. No MCP tool signature, no `artifact_type`, and no orchestrator-state field changed (INV-7).
