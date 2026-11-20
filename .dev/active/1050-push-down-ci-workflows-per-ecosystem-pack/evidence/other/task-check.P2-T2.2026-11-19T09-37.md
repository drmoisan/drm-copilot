# Task Check P2-T2

Timestamp: 2026-11-19T09-37
Command: sh SCRATCH/issue-1050-tscheck.sh src/lib/push-down/push-down-ci-layer.ts src/lib/push-down/push-down-layer.ts src/lib/push-down/push-down-pipeline.ts src/lib/push-down/push-down-harness.ts test/lib/push-down/push-down-ci-layer.test.ts test/lib/push-down/push-down-harness.ci-workflows.test.ts jest.config.cjs; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down/push-down-ci test/lib/push-down/push-down-harness test/lib/push-down/push-down-pipeline.test.ts test/lib/push-down/push-down-apply.test.ts test/lib/push-down/push-down-ecosystem-registry.test.ts test/lib/push-down/push-down-service-call.test.ts test/push-down-wrapper-compatibility.test.ts test/mcp-tool-inputs.push-down test/repo-automation-service.push-down
EXIT_CODE: 0
Output Summary: Prettier check exit 0, ESLint exit 0, typecheck exit 0. Jest selection: 14 suites, 171 tests passed, 0 failed; the three CI suites alone (`push-down-ci-workflows`, `push-down-ci-layer`, `push-down-harness.ci-workflows`) 46 passed. Every edited file is at most 800 physical lines.

Changed files and physical line counts:
- `PD/push-down-ci-layer.ts` (new, 218)
- `PD/push-down-layer.ts` (optional `unmanagedProtectedPaths` on `PushDownLayer`, 131)
- `PD/push-down-pipeline.ts` (protected paths classified with `overwriteUnmanaged` false in `planPayloadFile`, 512)
- `PD/push-down-harness.ts` (optional `ciWorkflows`; explicit mode wins, else `inferCiWorkflowsMode`; selection union of the run's layers and recorded selections of other ecosystems; contribution merged into the shared layer; collision lines appended to `warnings` in dry-run and apply results, 287)
- `PDT/push-down-ci-layer.test.ts` (new, 156), `PDT/push-down-harness.ci-workflows.test.ts` (new, 378; in-memory POSIX roots, CRLF built in code, CI bundle text read read-only from the tracked `resources/ci-workflows/`)
- `extensions/drm-copilot/jest.config.cjs` (entry `./src/lib/push-down/push-down-ci-layer.ts`, 637)

Selection rule: mirrored tests of the new and edited push-down modules plus every #1029 suite listed in `## Existing Test Dispositions` that imports the edited harness, pipeline, or layer modules. `push-down-harness.integration.test.ts` matches the selection path but is in the integration lane, which the launcher excludes locally (CI-only).

Harness cases present: `plans no CI path when ci_workflows is omitted and no data-file entry exists`, `explicit off plans no CI file`, `reuses recorded reference mode`, `reuses recorded copy mode`, `explicit off after a delivery leaves the CI files in place as orphaned`, `rejects a selection union holding both C# variants` (write log empty), `reference mode plans no drm-copilot copy`, `copy mode writes selected copies with shared-layer manifest entries`, `delivers Set-CiRequiredChecks.ps1 byte-equal with layer shared and pack core in reference and copy modes` (one case per mode), `writes the data file exactly in reference, copy, and withheld-caller runs`, `second identical apply reports every CI file unchanged`, `dry run writes no file and no manifest`, `a payload_version change reports an unedited caller update and rewrites it`, `reports unmanaged-conflict at a CI path even with overwriteUnmanaged true` (data file and caller), `keeps an edited managed caller as conflict`, `writes no workflows path other than the caller and selected copies`, `withholds the caller when another workflow is named CI, including in a dry run`.
