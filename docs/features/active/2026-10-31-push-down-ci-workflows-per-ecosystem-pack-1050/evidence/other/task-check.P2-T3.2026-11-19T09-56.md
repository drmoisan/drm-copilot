# Task Check P2-T3

Timestamp: 2026-11-19T09-56
Command: sh SCRATCH/issue-1050-tscheck.sh (Prettier write then check, ESLint on the .ts files, npm run typecheck) over the changed files; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/mcp-tool-inputs test/mcp-repo-automation-tool-definitions.test.ts test/mcp-tools.push-down-claude.test.ts test/lib/push-down/push-down-harness test/lib/push-down/push-down-pipeline.test.ts test/lib/push-down/push-down-apply.test.ts test/lib/push-down/push-down-ecosystem-registry.test.ts test/lib/push-down/push-down-service-call.test.ts test/push-down-wrapper-compatibility.test.ts test/repo-automation-service.push-down
EXIT_CODE: 0
Output Summary: Prettier check exit 0, ESLint exit 0, typecheck exit 0. Jest selection: 30 suites, 402 tests passed, 0 failed (final run after the rule-K fix below).

Changed files:
- `extensions/drm-copilot/src/mcp-push-down-schema-properties.ts`: optional `ci_workflows` (string, enum `off`, `reference`, `copy`) in the shared run properties, so all three selection-property objects carry it.
- `extensions/drm-copilot/src/mcp-tool-inputs-push-down.ts`: `ci_workflows` parsed in the shared run-option resolver of the three resolvers through `parseCiWorkflowsMode` (error `Field 'ci_workflows' must be one of off, reference, copy when provided; received '<value>'.`), spread only when present.
- `extensions/drm-copilot/src/repo-automation-service-contract.ts`, `src/repo-automation-service-push-down.ts`, `src/lib/push-down/push-down-service-call.ts`: optional `ciWorkflows` on the three inputs, forwarded only when present to `pushDownHarness`.
- `extensions/drm-copilot/test/mcp-tool-inputs.push-down-ci-workflows.test.ts` (new): both definition surfaces expose the property; each resolver accepts the three values, omits the field when absent, rejects `on` naming the value; forwarding through the service options and from the service call to the harness.
- Rule-K updates: `test/mcp-repo-automation-tool-definitions.test.ts` `keeps Copilot push-down schemas to the documented optional fields` (key set gains `ci_workflows`); `test/push-down-wrapper-compatibility.test.ts` `keeps tool names and existing schema properties` (the `added` key set gains `ci_workflows`).

Selection rule: the new test file and every file of the first three rows of `## Existing Test Dispositions` that imports a changed module.

Iterations within this task:
1. Queue timeouts: five launcher runs exited 75 (`TEST_EXECUTION_QUEUE_TIMEOUT:`, lock held by pester suites of other worktrees); each re-run after the holder finished.
2. The first run that obtained the lock failed one test: `push-down-wrapper-compatibility.test.ts` `keeps tool names and existing schema properties`, which compares the full push-down schemas against frozen copies after removing a set of added keys. It is a rule-K case (exact schema key set) that the P0-T2 inventory did not list, because its search pattern (`Object.keys` / `toEqual` over properties) did not match this filter-then-compare shape. Disposition per rule K: the `added` set gains `ci_workflows` (reason: spec `## Scope` item 4). A repository search for other push-down schema comparisons (`push_down_` with `inputSchema` or `properties` under `extensions/drm-copilot/test`, `packages`, and `tests`) found no further case. The P0-T2 artifact is left unchanged (append-only); this record supplements it.
