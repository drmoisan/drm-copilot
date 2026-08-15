# Cycle 1 Orchestration Preservation Gate

Timestamp: `2026-08-15T00:31:22.3686319-04:00`

Plan task: `[P5-T15]`

## Exact commands and results

1. Command: `poetry run pytest -q tests/scripts/dev_tools -k 'parallel or codex_topology or codex_deployment'`
   - EXIT_CODE: `0`
   - Output Summary: `1,554 passed`, `5 skipped`, and `2,329 deselected` in `1.64s`.
2. Command: `poetry run pytest -q tests/scripts/dev_tools -k 'codex and (push_down or pack or parity or publisher)'`
   - EXIT_CODE: `0`
   - Output Summary: `66 passed` and `3,822 deselected` in `0.82s`.
3. Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/repo-automation-orchestration-validation.test.ts test/mcp-server-parallel-validation.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts test/lib/validate/parallel-codex-readiness-filesystem.test.ts test/lib/validate/parallel-kickoff-artifact.test.ts test/lib/validate/parallel-planner-state-core.test.ts test/lib/validate/parallel-orchestrator-state-completion.test.ts test/lib/validate/parallel-orchestrator-state-completion-receipts.test.ts test/lib/validate/parallel-orchestrator-state-mutation-receipts.test.ts test/lib/validate/parallel-orchestrator-state-resume-truth.test.ts test/lib/validate/parallel-orchestrator-state-receipt-cohort.test.ts`
   - EXIT_CODE: `0`
   - Output Summary: `12/12` suites and `252/252` tests passed; `0` snapshots.
4. Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-mutation-parity.test.ts test/lib/validate/parallel-drift-parity.test.ts test/lib/validate/parallel-cohort-barrier-parity.test.ts`
   - EXIT_CODE: `0`
   - Output Summary: `3/3` suites and `71/71` tests passed; `0` snapshots.
5. Command: `npm --prefix extensions/drm-copilot run test -- --runInBand test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-pack-selection.test.ts test/lib/push-down/codex-portable-assets.test.ts test/lib/push-down/codex-routing-merge.test.ts test/lib/push-down/claude-config-carriage.test.ts test/repo-automation-service.push-down-codex.test.ts`
   - EXIT_CODE: `0`
   - Output Summary: `6/6` suites and `56/56` tests passed; `0` snapshots.
6. Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25"` and `scan_folders=["tests/scripts/codex-hooks"]`.
   - EXIT_CODE: `0`
   - Output Summary: MCP returned `ok=true`; JUnit records `701/701` passing tests, `0` failures, `0` errors, and `0` disabled tests.
   - JUnit SHA-256: `63ECE403E6789D89F97D1EACCAE905E15008B887ACCE311A051514C73C44D208`.
7. Command: `wsl.exe -d Ubuntu --cd C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25 -- bash -lc "bats tests/shell/parallel_payload_only.bats tests/shell/parallel_manifest_validate.bats tests/shell/parallel_cohorts.bats tests/shell/parallel_cohorts_parity.bats tests/shell/parallel_bash_manifest_membership.bats"`
   - EXIT_CODE: `0`
   - Output Summary: TAP plan `1..77`; `77/77` tests passed.

## Preserved invariants

| Contract group | Evidence result |
|---|---|
| Architecture boundaries and forced surfaces | Python surface, permission, topology, and deployment owners passed in the 1,554-test selector; public TypeScript dispatch remained green. |
| Contract and schema compatibility | Python planner/orchestrator validators and the TypeScript service/MCP/artifact dispatch group passed without a reopened diagnostic. |
| Integration, authority, and kickoff identity | Injected readiness, authority/delegation receipt, canonical kickoff, and completion owners passed in both Python and TypeScript. |
| Graph, cohort, and bounded batch semantics | Python parallel tests, the TypeScript cohort parity owner, and five-owner Bats selection passed. |
| Native-hook transport | The registered Codex hook scan passed `701/701` through the repository PoshQC MCP boundary. |
| Mutation, drift, and resume | Python parallel owners passed; TypeScript mutation, drift, cohort, receipt, and resume owners passed. |
| Publisher parity and additive routing | Python `66/66` and TypeScript `56/56` focused publisher/pack/routing tests passed. |
| Payload portability | The restricted-path payload and portable Bash membership selection passed `77/77`. |

Reopened invariants: `0`.

Acceptance result: `PASS`. Every exact preservation command exited zero and no named issue-467 orchestration invariant reopened.
