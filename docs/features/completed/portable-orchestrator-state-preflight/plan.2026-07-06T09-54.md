# portable-orchestrator-state-preflight - Refactor Plan

- **Issue:** none (tracked locally; no GitHub issue by scope decision)
- **Parent (optional):** none
- **Owner:** orchestrator
- **Last Updated:** 2026-07-06T09-54
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Required References (read, do not restate)

- Spec (authoritative, Option A): `docs/features/active/portable-orchestrator-state-preflight/spec.md`
- Cross-language code change policy: `.claude/rules/general-code-change.md`
- Cross-language unit test policy: `.claude/rules/general-unit-test.md`
- PowerShell standards + toolchain + mocking rules: `.claude/rules/powershell.md`
- Quality tiers / coverage thresholds: `.claude/rules/quality-tiers.md`
- Orchestrator-state invariants: `.claude/rules/orchestrator-state.md`
- Parity reference (PR-creation readiness): `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`
- Parity reference (base required keys / step-status enum): `scripts/dev_tools/validate_orchestrator_state.py`
  (`REQUIRED_STATE_KEYS`, `STEP_STATUS_KEYS`, `VALID_STEP_STATUS`, `VALID_BLOCKED_REASONS`)
- Parity reference (model-routing existence gate): `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`
- Portable-pattern exemplar: `.claude/lib/model-routing/ModelRouting.psm1`
- Manifest-test exemplar: `tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1`

## Strategy

Add a self-contained portable PowerShell module that reproduces the pushed-down-relevant
orchestrator-state checks (PR-creation readiness and the completion-gate presence checks), ship it in
the `core` pack manifest, and rewire the default `$Invoker` in both hooks to capability-detect: use the
authoritative Python CLI when `scripts.dev_tools.validate_orchestration_artifacts` is importable, and
the portable module otherwise. Both paths return the same `{ ExitCode, Output }` shape and both fail
closed. The injectable `$Invoker` seam is preserved; only the DEFAULT scriptblock behavior changes.

Fail-closed evidence rule: every baseline task, final-QA task, and coverage-comparison task below names
its expected artifact path under `docs/features/active/portable-orchestrator-state-preflight/evidence/`.
If a required baseline, QA, or coverage artifact is missing, the verdict is BLOCKED or INCOMPLETE, never
PASS.

Change-budget note (per `.claude/rules/powershell.md`): the change touches four production PowerShell
files (two new modules, two hooks). Phases are batched so no single implementation batch exceeds three
production PowerShell files and three test files. Batch A = the two new modules and their tests; Batch B
= the two hooks and their tests. The manifest JSON edit is not a PowerShell production file.

EVIDENCE_LOCATION_INVARIANT: all evidence artifacts resolve under
`docs/features/active/portable-orchestrator-state-preflight/evidence/{baseline,qa-gates,other}/`.
Non-canonical paths (e.g. `artifacts/baselines/`, `artifacts/qa/`) are rejected.

### Phase 0 — Baseline Capture and Policy Reads

- [x] [P0-T1] Read the policy files in the required order (`CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/orchestrator-state.md`) and record them in `docs/features/active/portable-orchestrator-state-preflight/evidence/baseline/phase0-instructions-read.md` with fields `Timestamp:`, `Policy Order:`, and an explicit list of files read.
- [x] [P0-T2] Run `mcp__drm-copilot__run_poshqc_format` in check mode across the repository PowerShell surface and write the result to `docs/features/active/portable-orchestrator-state-preflight/evidence/baseline/baseline-format.md` with fields `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P0-T3] Run `mcp__drm-copilot__run_poshqc_analyze` across the PowerShell surface and write the result to `docs/features/active/portable-orchestrator-state-preflight/evidence/baseline/baseline-analyze.md` with fields `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (record analyzer error/warning counts).
- [x] [P0-T4] Run `mcp__drm-copilot__run_poshqc_test` with coverage across the existing PowerShell suite and write the result to `docs/features/active/portable-orchestrator-state-preflight/evidence/baseline/baseline-test.md` with fields `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric baseline line-coverage and branch-coverage headline values for the currently-existing hook and lib suites.

### Phase 1 — Portable Module (Batch A: two new modules + tests)

- [x] [P1-T1] Create `.claude/lib/orchestrator-state/OrchestratorState.psm1` with `Set-StrictMode -Version Latest`, a module header docstring mirroring `.claude/lib/model-routing/ModelRouting.psm1`, and module-scope constants for the base required keys, step-status keys, valid step statuses, and valid blocked reasons pinned to `REQUIRED_STATE_KEYS`/`STEP_STATUS_KEYS`/`VALID_STEP_STATUS`/`VALID_BLOCKED_REASONS` in `scripts/dev_tools/validate_orchestrator_state.py`.
- [x] [P1-T2] Add a private checkpoint-load helper in `.claude/lib/orchestrator-state/OrchestratorState.psm1` that reads `-CheckpointPath`, fails closed with a non-empty error string when the file is missing, and fails closed when the content is not valid JSON, returning a structured `{ Ok; State; Error }` result and never throwing to the caller.
- [x] [P1-T3] Add a private base-presence check in `.claude/lib/orchestrator-state/OrchestratorState.psm1` that returns one error string per missing required key and one per `step5_status`..`step10_status` value outside `VALID_STEP_STATUS`, mirroring the primary-validator base checks.
- [x] [P1-T4] Add advanced function `Test-OrchestratorStatePrCreationReadiness` (`[CmdletBinding()]`, `-CheckpointPath` mandatory) to `.claude/lib/orchestrator-state/OrchestratorState.psm1` that runs the load helper, the base-presence check, and the PR-creation-readiness parity checks (steps 5-8 not `pending`/`blocked`; `blocked_reason` in {`none`, absent}; `local_execution_overrides`/`delegation_bypasses` empty lists when present) per `_orchestrator_state_pr_creation_readiness.py`, and returns `@{ ExitCode = <0|1>; Output = <error text> }` where ExitCode is 1 whenever any error is present.
- [x] [P1-T5] Add `Export-ModuleMember -Function Test-OrchestratorStatePrCreationReadiness` to `.claude/lib/orchestrator-state/OrchestratorState.psm1` and confirm the file is under 500 lines.
- [x] [P1-T6] Create `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` with `Set-StrictMode -Version Latest`, a header docstring, and an `Import-Module` of the sibling `OrchestratorState.psm1` and `.claude/lib/model-routing/ModelRouting.psm1` resolved by `$PSScriptRoot`-relative path.
- [x] [P1-T7] Add advanced function `Test-OrchestratorStateCompletionReadiness` (`[CmdletBinding()]`, `-CheckpointPath` mandatory) to `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` that fails closed on missing file/invalid JSON, runs the base-presence check, and applies the required-once-delegated existence gate (delegated-agent set derived from `delegation_receipts[].agent_name` plus a delegating `next_step`, must be a subset of `model_routing_receipts[].agent`) mirroring `_orchestrator_state_model_routing_gate.py`, emitting error text containing the literal token `model_routing_receipts` for a missing routing receipt so the completion hook maps it to `MODEL_ROUTING_BLOCKED:`.
- [x] [P1-T8] Add `Export-ModuleMember -Function Test-OrchestratorStateCompletionReadiness` to `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`, return `@{ ExitCode = <0|1>; Output = <error text> }` with ExitCode 1 on any error, and confirm the file is under 500 lines.
- [x] [P1-T9] Create `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` (Pester v5) with an `It` asserting a PR-creation-ready checkpoint fixture returns `ExitCode = 0` and empty `Output`, using in-memory checkpoint JSON written by the test setup (no runtime temp files; use module-scope here-string fixtures).
- [x] [P1-T10] Extend `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` with one `It` per rejection condition (missing required key; a step in `pending`; a step in `blocked`; `blocked_reason` set to a non-`none` value; non-empty `local_execution_overrides`; missing checkpoint file; invalid JSON), each asserting `ExitCode = 1` and a non-empty `Output` message.
- [x] [P1-T11] Create `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1` (Pester v5) with an `It` asserting a checkpoint whose delegated-agent set is fully covered by `model_routing_receipts[].agent` returns `ExitCode = 0`, and an `It` asserting an uncovered delegated agent returns `ExitCode = 1` with `Output` containing `model_routing_receipts`.
- [x] [P1-T12] Extend `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1` with fail-closed `It` blocks for a missing checkpoint file, invalid JSON, and an invalid step status, each asserting `ExitCode = 1` and a non-empty `Output`.
- [x] [P1-T13] Run `mcp__drm-copilot__run_poshqc_format` and record the result to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/phase1-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; if it changes files, re-run from this task.
- [x] [P1-T14] Run `mcp__drm-copilot__run_poshqc_analyze` and record the result to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/phase1-analyze.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (0 errors required).
- [x] [P1-T15] Run `mcp__drm-copilot__run_poshqc_test` with coverage scoped to the two new modules and record to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/phase1-test.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric line coverage (>= 85%) and branch coverage (>= 75%) for `OrchestratorState.psm1` and `OrchestratorStateCompletion.psm1`.

### Phase 2 — Hook Capability-Detection Rewiring (Batch B: two hooks + tests)

- [x] [P2-T1] Add a probe seam function `Test-PythonOrchestratorValidatorAvailable` (`[CmdletBinding()]`, `[OutputType([bool])]`) to `.claude/hooks/enforce-pr-author-skill.ps1` that returns `$true` only when `python -c "import scripts.dev_tools.validate_orchestration_artifacts"` exits 0, and returns `$false` on any non-zero exit or error (fail-closed toward the portable path).
- [x] [P2-T2] Rewire the default `$Invoker` of `Invoke-OrchestratorStatePreflight` in `.claude/hooks/enforce-pr-author-skill.ps1` so it calls `Test-PythonOrchestratorValidatorAvailable`; when true it runs the existing `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state $Path --require-pr-creation-ready` invocation byte-for-byte and returns `{ ExitCode, Output }`; when false it dot-imports `.claude/lib/orchestrator-state/OrchestratorState.psm1` and returns `Test-OrchestratorStatePrCreationReadiness -CheckpointPath $Path` as `{ ExitCode, Output }`. Preserve the injectable `$Invoker` parameter and its signature.
- [x] [P2-T3] Add a probe seam function `Test-PythonOrchestratorValidatorAvailable` to `.claude/hooks/validate-orchestrator-output.ps1` with the same contract as P2-T1 (or a shared import if one already exists), returning `$false` fail-closed toward the portable path.
- [x] [P2-T4] Rewire the default `$Invoker` of `Invoke-RoutingContractValidation` in `.claude/hooks/validate-orchestrator-output.ps1` so it calls the probe; when true it runs the existing `python -m scripts.dev_tools.validate_orchestration_artifacts $Type $Path --require-complete --require-model-routing` invocation byte-for-byte; when false it dot-imports `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` and returns `Test-OrchestratorStateCompletionReadiness -CheckpointPath $Path` as `{ ExitCode, Output }`. Preserve the injectable `$Invoker` parameter and its signature.
- [x] [P2-T5] Extend `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` with an `It` mocking `Test-PythonOrchestratorValidatorAvailable` to return `$false` and asserting the default path routes to the portable module and blocks a not-ready checkpoint with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`.
- [x] [P2-T6] Extend `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` with an `It` mocking the probe to return `$true` and asserting the Python-CLI branch is selected (mock the injected `$Invoker`/portable seam, never `python` directly), and an `It` asserting a ready checkpoint on the portable path allows PR creation.
- [x] [P2-T7] Extend `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1` with an `It` mocking the probe to return `$false` and asserting an uncovered delegated agent surfaces `MODEL_ROUTING_BLOCKED:` via the portable path, and an `It` asserting a covered checkpoint on the portable path does not block.
- [x] [P2-T8] Extend `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` with an `It` mocking the probe to return `$true` and asserting the Python-CLI branch is selected and existing block reasons and fail-closed behavior are unchanged.
- [x] [P2-T9] Run `mcp__drm-copilot__run_poshqc_format` and record to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/phase2-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; if it changes files, re-run from this task.
- [x] [P2-T10] Run `mcp__drm-copilot__run_poshqc_analyze` and record to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/phase2-analyze.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (0 errors required).
- [x] [P2-T11] Run `mcp__drm-copilot__run_poshqc_test` with coverage scoped to the two hooks and record to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/phase2-test.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric line and branch coverage for the changed hook branches.

### Phase 3 — Push-down Manifest Membership

- [x] [P3-T1] Add `.claude/lib/orchestrator-state/OrchestratorState.psm1` and `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` to the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, each appearing exactly once.
- [x] [P3-T2] Create `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` mirroring `tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1`, asserting both new module paths are present in `core.json` `paths` and each appears exactly once.
- [x] [P3-T3] Run `mcp__drm-copilot__run_poshqc_test` scoped to the manifest test and record to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/phase3-manifest-test.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.

### Phase 4 — Final QA Loop and Coverage Comparison

- [x] [P4-T1] Run `mcp__drm-copilot__run_poshqc_format` across the full PowerShell surface and record to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/final-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; if it changes files, restart the loop at P4-T1.
- [x] [P4-T2] Run `mcp__drm-copilot__run_poshqc_analyze` across the full PowerShell surface and record to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/final-analyze.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (0 errors required); if it fails or changes files, restart at P4-T1.
- [x] [P4-T3] Run `mcp__drm-copilot__run_poshqc_test` with coverage across the full PowerShell suite and record to `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/final-test.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including post-change numeric line coverage (>= 85%) and branch coverage (>= 75%); if it fails or changes files, restart at P4-T1.
- [x] [P4-T4] Write `docs/features/active/portable-orchestrator-state-preflight/evidence/qa-gates/coverage-comparison.md` reporting baseline coverage (from `evidence/baseline/baseline-test.md`), post-change coverage (from `final-test.md`), and changed-file coverage for `OrchestratorState.psm1`, `OrchestratorStateCompletion.psm1`, `enforce-pr-author-skill.ps1`, and `validate-orchestrator-output.ps1`, with fields `Timestamp:` and an explicit no-regression determination (BLOCKED if any threshold is unmet).
- [x] [P4-T5] Verify each spec acceptance criterion AC1–AC7 against on-disk evidence and record the mapping (AC to evidence artifact path) in `docs/features/active/portable-orchestrator-state-preflight/evidence/other/ac-verification.md` with `Timestamp:`; mark the outcome BLOCKED if any AC lacks backing evidence.

## Test Plan

- Unit (portable module): `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` and `OrchestratorStateCompletion.Tests.ps1` cover the ready-pass path plus every rejection and fail-closed condition (missing keys, step `pending`/`blocked`, `blocked_reason` set, non-empty override list, missing file, invalid JSON, uncovered delegated agent).
- Manifest: `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` asserts both module paths ship in `core.json`.
- Hook routing: extended tests under `tests/scripts/claude-hooks/` assert capability detection routes to the portable path when the probe reports unavailable, to the Python path when available, and preserves `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` and `MODEL_ROUTING_BLOCKED:` fail-closed behavior. Mock the probe/invoker seam only; never mock `python`.
- Tooling: PoshQC format -> analyze -> test per `.claude/rules/powershell.md`, restarting on any failure or auto-format change.
- Coverage evidence: baseline `evidence/baseline/baseline-test.md`; post-change `evidence/qa-gates/final-test.md`; comparison `evidence/qa-gates/coverage-comparison.md`. Thresholds: line >= 85%, branch >= 75% on changed files, no regression.

## Rollback / Contingency

Revert the two hook default-`$Invoker` edits to restore the Python default; the new modules, manifest
entries, and tests are additive and can be removed independently. Blast radius is limited to the two
hooks and the `core` pack contents.

## Open Questions / Notes

- Change-budget batching: implementation must respect the per-batch cap of three production PowerShell
  files. Batch A (Phase 1) creates the two modules; Batch B (Phase 2) edits the two hooks. If the
  executor's change-budget router requires it, split further, but do not merge Batch A and Batch B into
  a single over-budget batch.
- Deep routing-contract receipt correctness that genuinely requires full Python authority remains a
  documented Non-Goal for the portable path (spec Non-Goals); the portable completion function performs
  the presence-level existence gate and reuses `ModelRouting.psm1` formulas where practical, and still
  fails closed on missing file, invalid JSON, invalid step status, or an uncovered delegated agent.
- The probe uses a Python module-import check; any probe error routes to the portable path, which itself
  blocks bad checkpoints, so fail-closed semantics hold in both branches.
