# FR-614-005 Materializer Red Test

Timestamp: 2026-09-03T01-58
Command: node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts test/lib/validate/orchestration-handoff-materializer-production.test.ts
Working Directory: `extensions/drm-copilot`
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: The expected red run failed both targeted suites. `Test Suites: 2 failed, 2 total` and `Tests: 3 failed, 48 passed, 51 total`. All three failures are missing independent-context behavior on the transition path. No source, envelope, checkpoint, archive, candidate, destination, or unrelated file changed.

## Expected failure signature

`toReferenceRequest` in `src/lib/validate/orchestration-handoff-materializer.ts` copies only four values (`workspaceRoot`, `handoffEnvelopePath`, `expectedHandoffEnvelopeSha256`, `destinationProvider`) into the reference request handed to the topology and routing authorities, so the ten caller-controlled expected-context values never reach either authority. The production boundary in `orchestration-handoff-materializer-production.ts` builds the authority from a `FileSystem` and a path boundary only and never issues a local checkout observation through the injected `CommandRunner`.

## Observed failing cases (3)

- `FR-614-005 independent-context mismatches block every transition > forwards the entire independent context to both authorities in dry_run mode`
- `FR-614-005 independent-context mismatches block every transition > forwards the entire independent context to both authorities in materialize mode`
- `production independent checkout observation boundary > routes checkout observation through the injected command runner`

Representative diagnostic:

```text
Expected: ObjectContaining {"allowedHeadRelationship": "equal_or_descendant", "expectedBranch": "feature/portable-handoff-614", ...}
Received: {"destinationProvider": "codex", "expectedHandoffEnvelopeSha256": "...", "handoffEnvelopePath": "artifacts/orchestration/handoffs/handoff.json", "workspaceRoot": "C:/workspace"}
```

## Regression-guard cases that already pass

The twelve-row dry-run and materialize matrix (`blocks $code in $mode mode with no dirty evaluation and no write`, covering `HANDOFF_REPOSITORY_MISMATCH`, `HANDOFF_WORKSPACE_MISMATCH`, `HANDOFF_ISSUE_FEATURE_MISMATCH`, `HANDOFF_BRANCH_LINEAGE_MISMATCH`, `HANDOFF_PLAN_PATH_INVALID`, and `HANDOFF_PLAN_HASH_MISMATCH` in both modes) already passes on the current code, because a blocked authority result short-circuits before dirty evaluation and before any write. Those rows are recorded as regression guards, not as red cases: they prove the P2 change does not introduce a dirty-worktree read, an archive-directory creation, an archive or candidate write, a replacement, a routing delegation after a topology failure, or a completed transition for any blocked result. The three production no-write and unavailable-observation rows pass for the same reason and carry the same guard role.

## Changed-path boundary

```text
UNSTAGED PRODUCTION PATHS
(none)
UNSTAGED TEST PATHS
extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts
extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts
extensions/drm-copilot/test/mcp-server.test.ts
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts
UNTRACKED TEST PATHS
extensions/drm-copilot/test/lib/validate/orchestration-handoff-checkout-context.test.ts
extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts
```

Command: git status --porcelain=v1 --untracked-files=all -- extensions/drm-copilot/src
EXIT_CODE: 0
Output Summary: No rows. No production file changed during the red run.

Command: git diff --quiet 541e8d89250bdc9a49f78c4ac4fcb6217799a4dd -- tests/fixtures/
EXIT_CODE: 0
Output Summary: No fixture byte changed.

## File-size compliance

`orchestration-handoff-materializer.test.ts` was 498 lines before this task and could not absorb the new matrices within the 500-line limit. The shared envelope factory, scenario options, and scenario builder were moved verbatim into `test/lib/validate/orchestration-handoff-materializer-test-support.ts`, following the existing convention already used by `parallel-state-test-support.ts`, `epic-planner-launch-evidence-test-support.ts`, and `mcp-server-test-service.ts`. No assertion or case was dropped; the suite still reports its full case count. Resulting sizes: materializer test 334 lines, production test 354 lines, support module 249 lines.
