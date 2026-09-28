# FR-614-005 Authority and Checkout-Context Red Test

Timestamp: 2026-09-03T01-32
Command: node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-authority-service.test.ts test/lib/validate/orchestration-handoff-checkout-context.test.ts
Working Directory: `extensions/drm-copilot`
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: The expected red run failed both targeted suites. Of 28 tests, 14 passed and 14 failed. `Test Suites: 2 failed, 2 total` and `Tests: 14 failed, 14 passed, 28 total`. Every failure is attributable to the tautological authority context or to the absent injectable local-Git observation boundary. No filesystem write, no Git mutation, and no production-file change occurred.

## Expected failure signature

The current `resolvePortableHandoffAuthority` builds `HandoffValidationContext` from the envelope it is validating (`envelope.binding.repositoryId`, `envelope.binding.branch`, `envelope.identity.*`, `envelope.plan.path`) and hard-codes `sourceHeadRelationshipValid: true`. A mutated but internally self-consistent envelope therefore validates itself for repository, branch, issue, feature, and work mode, and no HEAD relationship is ever evaluated. The new cases hold the independent expected context and the injected observation fixed and change exactly one envelope field per case, so each case fails on the current implementation.

`test/lib/validate/orchestration-handoff-checkout-context.test.ts` fails to run at all because the module it names does not exist yet:

```text
Cannot find module '../../../src/lib/validate/orchestration-handoff-checkout-context' from 'test/lib/validate/orchestration-handoff-checkout-context.test.ts'
```

## Observed failing cases (14)

Envelope-mutation matrix (independent context fixed, one envelope field changed per case):

- `blocks a self-consistent envelope whose binding.repository_id contradicts the independent context`
- `blocks a self-consistent envelope whose binding.branch contradicts the independent context`
- `blocks a self-consistent envelope whose identity.issue_number contradicts the independent context`
- `blocks a self-consistent envelope whose identity.feature_folder contradicts the independent context`
- `blocks a self-consistent envelope whose identity.work_mode contradicts the independent context`

Observation-side matrix (envelope and expected context fixed, observation changed):

- `blocks when the observed checkout repository contradicts the independent context`
- `blocks when the observed checkout workspace contradicts the independent context`
- `blocks when the observed checkout branch contradicts the independent context`

HEAD relationship, availability, precedence, and no-write cases:

- `blocks an equal_or_descendant relationship the boundary reports as unrelated`
- `blocks an equal relationship whose observed HEAD differs from the expected source HEAD`
- `delegates relationship validity to the boundary using only independent values`
- `fails closed when the checkout observation is unavailable`
- `selects registry-order precedence when several bindings are invalid at once`
- `performs no filesystem write and no Git mutation while validating`

Plus one `Test suite failed to run` for the absent checkout-context module.

## Cases that already pass on the current implementation

Three envelope-mutation cases pass today and are recorded so the red set is not overstated: `binding.workspace_root`, `plan.path`, and `plan.sha256`. The current implementation already compares those three against a value that does not originate from the same envelope field (the request workspace root, the resolved plan path, and the raw plan bytes), so they are not tautological before the change. They remain in the matrix to prove the new implementation does not regress them.

## Changed-path boundary

```text
UNSTAGED PRODUCTION PATHS
(none)
UNSTAGED TEST PATHS
extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts
extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts
extensions/drm-copilot/test/mcp-server.test.ts
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts
UNTRACKED TEST PATHS
extensions/drm-copilot/test/lib/validate/orchestration-handoff-checkout-context.test.ts
```

Command: git diff --quiet 541e8d89250bdc9a49f78c4ac4fcb6217799a4dd -- tests/fixtures/
EXIT_CODE: 0
Output Summary: No fixture byte changed during the red run.

## File-size compliance

`test/lib/validate/orchestration-handoff-authority-service.test.ts` is 493 lines and `test/lib/validate/orchestration-handoff-checkout-context.test.ts` is 317 lines, both within the 500-line limit. The authority suite was compacted during this task by replacing repeated six-line Act blocks with a single `resolve(kind)` helper and by merging two near-duplicate blocked-plan-path cases into one `it.each` over both authority kinds; no assertion was dropped.
