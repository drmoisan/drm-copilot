# Receipt and Validator Seam Baseline

Timestamp: `2026-08-10T22-45`

## Discovery command

Command: `rg -n 'schema_version|runtime|surface|mutation|drift|cohort|launch|model.routing|topology|worktree|completion' scripts/dev_tools extensions/drm-copilot/src tests extensions/drm-copilot/test`

EXIT_CODE: `0`

Output Summary: The search resolved the current shared parallel-state validators, mutation and drift validators, cohort/barrier validation, MCP dispatch, topology/model-routing validators, and the existing Python and TypeScript fixture owners. The command returned 7,183 matching lines.

## Placement decision

The Codex-specific launch receipt will be a versioned external record referenced by guarded per-item `launch_receipt_path` and `launch_status_path` fields. It will not add `schema_version`, `runtime`, or `surface` as required top-level fields in the existing shared parallel-orchestrator checkpoint.

The external launch record owns Codex-only launch identity and provenance, including `schema_version`, `surface: parallel`, item/cohort/batch identity, `base_branch: main`, head branch, worktree path, resolved agent/model/reasoning identity, topology and model-routing receipt paths, launch-status path, and launch-spec SHA-256. The shared checkpoint references are presence-gated for backward compatibility and become required only at the Codex readiness/completion validation boundaries defined by later tasks.

Compatibility basis:

- The current shared required-key contract does not require `schema_version`, `runtime`, or `surface`.
- Existing optional receipt arrays (`delegation_receipts`, `skill_receipts`, and `mcp_call_receipts`) are presence-gated in both runtimes.
- Existing TypeScript validation documents absent optional receipt arrays as backward-compatible.
- Existing delivered fixtures contain the shared mutation and drift collections but no Codex launch fields.
- The existing epic runtime uses referenced `launch_receipt_path` and `launch_status_path` values, providing an established repository seam for external launch evidence.

## Validation owners

Python owners:

- `scripts/dev_tools/validate_parallel_orchestrator_state.py` — public CLI entry point.
- `scripts/dev_tools/_parallel_state_structures.py` — shared structure and optional-receipt validation.
- `scripts/dev_tools/_parallel_state_records.py` — state-record validation helpers.
- `scripts/dev_tools/_parallel_state_common.py` — shared validation utilities.
- `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` — mutation validation.
- `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` — mode-completion validation.
- `scripts/dev_tools/_parallel_orchestrator_state_drift.py` — drift validation.
- `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` — cohort/barrier validation.
- `scripts/dev_tools/parallel_mutation_protocol.py` — mutation protocol ownership.
- `scripts/dev_tools/parallel_drift_detection.py` and its helper modules — drift detection ownership.
- `scripts/dev_tools/validate_parallel_planner_state.py` — planner-state entry point.
- `scripts/dev_tools/validate_orchestration_artifacts.py` — aggregate artifact CLI dispatch.

TypeScript owners:

- `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` — shared orchestrator-state entry point.
- `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts` — shared structures and optional receipts.
- `extensions/drm-copilot/src/lib/validate/parallel-state-records.ts` — state records.
- `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-cohort-barrier.ts` — cohort/barrier validation.
- `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts` — planner-state validation.
- `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` — kickoff validation.
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` — MCP artifact dispatch.
- `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts` — service-call validation boundary.
- `extensions/drm-copilot/src/lib/validate/build-validate-orchestration-service-call-input.ts` — MCP input shaping.

The TypeScript MCP dispatch currently routes `parallel-orchestrator-state` through `validateParallelOrchestratorStateText`; the Python aggregate CLI routes the same artifact class through `validate_orchestration_artifacts.py`.

## Compatibility verification

Python command:

`poetry run pytest -q tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_completion.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`

Result: `PASS` — 270 tests passed in 0.48 seconds.

Initial TypeScript command result: `FAIL` before test execution because `extensions/drm-copilot/node_modules` was absent and `jest/bin/jest` could not be resolved.

Prerequisite command: `npm --prefix extensions/drm-copilot ci`

Result: `PASS` — 457 packages installed; 0 vulnerabilities reported.

TypeScript command:

`npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-orchestrator-state-core.test.ts test/lib/validate/parallel-orchestrator-state-structures.test.ts test/lib/validate/parallel-orchestrator-state-completion.test.ts test/lib/validate/parallel-orchestrator-state-cohort-barrier.test.ts test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts --runInBand`

Result: `PASS` — 5 suites passed; 208 tests passed; 0 snapshots.

The delivered Claude/shared fixture corpus therefore remains valid in both validator runtimes before the additive Codex receipt work begins.
