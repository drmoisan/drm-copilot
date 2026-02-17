---
issue: 19
title: powershell-orchestrator
owner: drmoisan
created: 2026-02-16T20-34
last_updated: 2026-02-16T20-34
status: Planned
status_color: blue
version: 0.2
---

# 2026-02-16-powershell-orchestrator - Plan

Status Badge: ![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell Code Change Policy: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test Policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- Atomic Plan Contract Skill: [`.github/skills/atomic-plan-contract/SKILL.md`](../../../../.github/skills/atomic-plan-contract/SKILL.md)
- Evidence Conventions Skill: [`.github/skills/evidence-and-timestamp-conventions/SKILL.md`](../../../../.github/skills/evidence-and-timestamp-conventions/SKILL.md)

## Requirements Traceability

| ID | Type | Requirement |
|---|---|---|
| REQ-001 | Functional | Route to Flow A when production budget is `<= 2` touched PowerShell production files plus corresponding `*.Tests.ps1` files. |
| REQ-002 | Functional | Route to Flow B when production budget is `> 2` and enforce docs-first checkpoints before broad implementation. |
| REQ-003 | Functional | Enforce thin DI seam: external executables are invoked through wrapper functions that are mocked in Pester tests. |
| REQ-004 | Quality Gate | Enforce zero-regression gates: no new analyzer findings, no new failing tests, no coverage regressions for touched files. |
| REQ-005 | Determinism | Compute routing deterministically without PATH, working directory, profile, network, or host-specific dependencies. |
| REQ-006 | Functional | Require explicit budget confirmation when request scope is ambiguous before execution begins. |
| REQ-007 | Functional | Persist routing decision, scope ledger, and gate status in `artifacts/orchestration/powershell-orchestrator-state.json`. |
| REQ-008 | Functional | Enforce Flow B delegation order: planner -> validator -> executor -> audit. |
| SEC-001 | Security | Restrict command execution to wrapper-mediated allowlisted tool invocations; avoid raw executable mocking. |
| CON-001 | Constraint | Keep implementation scoped to PowerShell scripts/tests and feature docs only. |
| PERF-001 | Performance | Keep routing evaluation bounded to local file classification and metadata checks only. |

## REQ-ID Closure

| Requirement ID | Implemented By Tasks |
|---|---|
| REQ-001 | [P2-T3], [P4-T1] |
| REQ-002 | [P2-T3], [P3-T4], [P4-T1] |
| REQ-003 | [P3-T1], [P1-T5] |
| REQ-004 | [P5-T1], [P5-T2], [P5-T3], [P5-T4], [P5-T5] |
| REQ-005 | [P3-T2] |
| REQ-006 | [P2-T4], [P4-T1] |
| REQ-007 | [P3-T3] |
| REQ-008 | [P3-T5] |
| SEC-001 | [P3-T1], [P1-T5] |
| CON-001 | [P2-T1], [P2-T2], [P2-T3], [P2-T4], [P2-T5], [P3-T1], [P3-T2], [P3-T3], [P3-T4], [P3-T5], [P4-T1], [P4-T2], [P4-T3], [P4-T4], [P5-T1], [P5-T2], [P5-T3], [P5-T4], [P5-T5] |
| PERF-001 | [P3-T2] |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Inputs
- [ ] [P0-T1] Record policy-order evidence in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/baseline/policy-read.2026-02-16T20-34.md` covering `.github/copilot-instructions.md`, general policies, and PowerShell policies
  - Acceptance: File exists and contains exact lines `Timestamp: 2026-02-16T20-34`, `Command: policy-read`, `EXIT_CODE: 0`, and an exact ordered `PolicyOrder:` block with: (1) .github/copilot-instructions.md, (2) .github/instructions/general-code-change.instructions.md, (3) .github/instructions/general-unit-test.instructions.md, (4) .github/instructions/powershell-code-change.instructions.md, (5) .github/instructions/powershell-unit-test.instructions.md.
- [ ] [P0-T2] Create baseline evidence folder structure `evidence/baseline`, `evidence/regression-testing`, `evidence/other`, and `evidence/qa-gates` under `docs/features/active/2026-02-16-powershell-orchestrator-19/`
  - Acceptance: `list_dir` output for `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/` contains `baseline/`, `regression-testing/`, `other/`, and `qa-gates/`.
- [ ] [P0-T3] Capture baseline PowerShell formatter result in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/baseline/format.2026-02-16T20-34.md` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  - Acceptance: Evidence file includes `Timestamp: 2026-02-16T20-34`, exact `Command: ...Invoke-PoshQCFormat -Root .`, `EXIT_CODE: <int>`, and `Output Summary:`.
- [ ] [P0-T4] Capture baseline PowerShell analyzer result in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/baseline/analyze.2026-02-16T20-34.md` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  - Acceptance: Evidence file includes `Timestamp: 2026-02-16T20-34`, exact `Command: ...Invoke-PoshQCAnalyze -Root .`, `EXIT_CODE: <int>`, and `Output Summary:`.
- [ ] [P0-T5] Capture baseline PowerShell test result in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/baseline/test.2026-02-16T20-34.md` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Acceptance: Evidence file includes `Timestamp: 2026-02-16T20-34`, exact `Command: ...Invoke-PoshQCTest -Root .`, `EXIT_CODE: <int>`, and `Output Summary:`.

### Phase 1 — TDD Red: Routing and Budget Scenarios
- [ ] [P1-T1] [expect-fail] Add Pester scenario for `Resolve-PowerShellOrchestratorRoute` returning `FlowA` when `budget.production_files = 2` in `tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1`
  - Preconditions: `tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1` exists.
  - Acceptance: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -TestName 'Resolve-PowerShellOrchestratorRoute returns FlowA at budget 2'"` fails; evidence saved to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T1.2026-02-16T20-34.md` with `Timestamp`, `Command`, `EXIT_CODE`.
- [ ] [P1-T2] [expect-fail] Add Pester scenario for `Resolve-PowerShellOrchestratorRoute` returning `FlowB` when `budget.production_files = 3` in `tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1`
  - Acceptance: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -TestName 'Resolve-PowerShellOrchestratorRoute returns FlowB at budget 3'"` fails; evidence saved to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T2.2026-02-16T20-34.md` containing exact lines `Timestamp: 2026-02-16T20-34`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -TestName 'Resolve-PowerShellOrchestratorRoute returns FlowB at budget 3'"`, and `EXIT_CODE: <int>`.
- [ ] [P1-T3] [expect-fail] Add Pester scenario for `Confirm-PowerShellOrchestratorBudget` requiring explicit confirmation when budget is missing in `tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1`
  - Acceptance: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -TestName 'Confirm-PowerShellOrchestratorBudget rejects missing budget'"` fails; evidence saved to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T3.2026-02-16T20-34.md` containing exact lines `Timestamp: 2026-02-16T20-34`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -TestName 'Confirm-PowerShellOrchestratorBudget rejects missing budget'"`, and `EXIT_CODE: <int>`.
- [ ] [P1-T4] [expect-fail] Add Pester scenario for `Assert-FlowABudgetGuard` blocking a third production file without expansion approval in `tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1`
  - Acceptance: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -TestName 'Assert-FlowABudgetGuard blocks third production file'"` fails; evidence saved to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T4.2026-02-16T20-34.md` containing exact lines `Timestamp: 2026-02-16T20-34`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -TestName 'Assert-FlowABudgetGuard blocks third production file'"`, and `EXIT_CODE: <int>`.
- [ ] [P1-T5] [expect-fail] Add Pester scenario for `Invoke-OrchestratorToolWrapper` being the only executable-invocation seam in `tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1`
  - Acceptance: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -TestName 'Invoke-OrchestratorToolWrapper is mock seam for external tools'"` fails; evidence saved to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T5.2026-02-16T20-34.md` containing exact lines `Timestamp: 2026-02-16T20-34`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -TestName 'Invoke-OrchestratorToolWrapper is mock seam for external tools'"`, and `EXIT_CODE: <int>`.

### Phase 2 — Implement Flow A Core Functions
- [ ] [P2-T1] Create `scripts/dev-tools/powershell-orchestrator.ps1` with function `Get-TouchedPowerShellProductionFiles` that classifies touched production files using `*.ps1` and `*.psm1` excluding `*.Tests.ps1`
  - Acceptance: File contains function declaration `function Get-TouchedPowerShellProductionFiles` and Pester test `Get-TouchedPowerShellProductionFiles classifies production files` passes.
- [ ] [P2-T2] Implement `Get-CorrespondingPesterTestFiles` in `scripts/dev-tools/powershell-orchestrator.ps1` to map production paths to minimal `*.Tests.ps1` files under `tests/scripts/`
  - Acceptance: Pester test `Get-CorrespondingPesterTestFiles returns minimal test file set` passes.
- [ ] [P2-T3] Implement `Resolve-PowerShellOrchestratorRoute` in `scripts/dev-tools/powershell-orchestrator.ps1` with threshold constant `FLOW_A_PRODUCTION_FILE_THRESHOLD = 2` to satisfy REQ-001 and REQ-002
  - Depends on: [P2-T1]
  - Acceptance: Pester tests `Resolve-PowerShellOrchestratorRoute returns FlowA at budget 2` and `Resolve-PowerShellOrchestratorRoute returns FlowB at budget 3` pass.
- [ ] [P2-T4] Implement `Confirm-PowerShellOrchestratorBudget` in `scripts/dev-tools/powershell-orchestrator.ps1` to reject execution when budget confirmation is absent
  - Acceptance: Pester test `Confirm-PowerShellOrchestratorBudget rejects missing budget` passes.
- [ ] [P2-T5] Implement `Assert-FlowABudgetGuard` in `scripts/dev-tools/powershell-orchestrator.ps1` to block touches above two production files unless `-ApproveScopeExpansion` is true
  - Acceptance: Pester test `Assert-FlowABudgetGuard blocks third production file` passes.

### Phase 3 — Implement Determinism, DI Seam, and Flow B Controls
- [ ] [P3-T1] Implement `Invoke-OrchestratorToolWrapper` in `scripts/dev-tools/powershell-orchestrator.ps1` as the single external-tool execution seam for formatter/analyzer/test commands
  - Acceptance: Pester test `Invoke-OrchestratorToolWrapper is mock seam for external tools` passes, and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "if (Select-String -Path tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1 -Pattern 'Mock\s+(git|pwsh|powershell|Start-Process|Invoke-Expression)' -CaseSensitive:$false) { exit 1 } else { exit 0 }"` exits `0`.
- [ ] [P3-T2] Implement `Assert-DeterministicRoutingInputs` in `scripts/dev-tools/powershell-orchestrator.ps1` to compute route from request payload and touched-file set only
  - Acceptance: Pester test `Assert-DeterministicRoutingInputs ignores pwd profile path network and host-specific state` passes.
- [ ] [P3-T3] Implement `Write-OrchestratorState` in `scripts/dev-tools/powershell-orchestrator.ps1` to persist route, budget, touched files, and gate status to `artifacts/orchestration/powershell-orchestrator-state.json`
  - Acceptance: Pester test `Write-OrchestratorState writes required state fields` passes and JSON contains keys `route`, `budget`, `touched_production_files`, `touched_test_files`, `gate_status`.
- [ ] [P3-T4] Implement `Assert-FlowBDocumentationPreconditions` in `scripts/dev-tools/powershell-orchestrator.ps1` to require `issue.md`, `spec.md`, and optional `user-story.md` in `docs/features/active/<feature>/` before broad implementation
  - Acceptance: Pester test `Assert-FlowBDocumentationPreconditions enforces docs-first` passes.
- [ ] [P3-T5] Implement `Get-FlowBDelegationSequence` in `scripts/dev-tools/powershell-orchestrator.ps1` returning ordered list `planner`, `validator`, `executor`, `audit`
  - Acceptance: Pester test `Get-FlowBDelegationSequence returns planner-validator-executor-audit` passes.

### Phase 4 — Integrate Entry Point and Feature Documentation
- [ ] [P4-T1] Implement `Invoke-PowerShellOrchestrator` entry point in `scripts/dev-tools/powershell-orchestrator.ps1` that calls `Confirm-PowerShellOrchestratorBudget`, `Resolve-PowerShellOrchestratorRoute`, and route-specific guards
  - Depends on: [P2-T3], [P2-T4], [P2-T5], [P3-T2], [P3-T4]
  - Acceptance: Pester test `Invoke-PowerShellOrchestrator routes and enforces guards by route` passes.
- [ ] [P4-T2] Add script-level parameter contract in `scripts/dev-tools/powershell-orchestrator.ps1` for `-WorkType`, `-ProductionFileBudget`, `-TargetFiles`, `-ApproveScopeExpansion`, and `-RequiresExternalExecutable`
  - Acceptance: Pester test `Invoke-PowerShellOrchestrator parameter contract is strict` passes.
- [ ] [P4-T3] Update `docs/features/active/2026-02-16-powershell-orchestrator-19/spec.md` Definition of Done checkboxes to mark implemented and verified items after code completion
  - Acceptance: `spec.md` contains checked boxes for implemented behavior and references test evidence paths.
- [ ] [P4-T4] Update `docs/features/active/2026-02-16-powershell-orchestrator-19/user-story.md` status from `Draft` to `In progress` when implementation starts and to `Completed` after final QA passes
  - Acceptance: `user-story.md` final status is exactly `Completed`, and evidence file `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/other/status-transition.2026-02-16T20-34.md` exists containing `Timestamp`, `Command`, `EXIT_CODE`, plus exact lines `ObservedStatusSequence: Draft -> In progress -> Completed`.

### Phase 5 — Final QA Loop and Evidence
- [ ] [P5-T1] Run PowerShell formatting loop for touched files with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  - Acceptance: Command exits `0` and evidence saved to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/qa-gates/format.2026-02-16T20-34.md` with required schema.
- [ ] [P5-T2] Run PowerShell analyzer loop with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  - Depends on: [P5-T1]
  - Acceptance: Command exits `0` and evidence saved to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/qa-gates/analyze.2026-02-16T20-34.md` with required schema.
- [ ] [P5-T3] Run PowerShell test loop with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Depends on: [P5-T1], [P5-T2]
  - Acceptance: Command exits `0` and evidence saved to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/qa-gates/test.2026-02-16T20-34.md` with required schema.
- [ ] [P5-T4] Capture touched-file coverage comparison into `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/qa-gates/coverage-delta.2026-02-16T20-34.md` using baseline and final coverage artifacts
  - Depends on: [P0-T5], [P5-T3]
  - Acceptance: Evidence file contains `CoverageDelta: <= 0 regression count` and explicit touched-file coverage values for each changed PowerShell production file.
- [ ] [P5-T5] Re-run full PowerShell QA loop from formatting when any prior QA step modifies files or fails
  - Depends on: [P5-T1], [P5-T2], [P5-T3]
  - Acceptance: Final pass evidence contains consecutive `EXIT_CODE: 0` for format, analyze, and test artifacts generated after the last file-modifying step.

## Test Plan

- Unit:
  - `tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1` for route selection, budget guard, deterministic input checks, state persistence, and wrapper seam behavior.
- Integration:
  - `tests/scripts/dev-tools/powershell-orchestrator.Tests.ps1` scenario `Invoke-PowerShellOrchestrator routes and enforces guards by route` using mocked wrapper seam.
- Manual/CLI:
  - Not a gating criterion. Optional smoke command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/powershell-orchestrator.ps1 -WorkType bug -ProductionFileBudget 2 -TargetFiles scripts/dev-tools/powershell-orchestrator.ps1`.

## Open Questions / Notes

- No open design questions remain for v0.2 planning scope.
- All deterministic gates in this plan are machine-verifiable through command exit codes, file existence checks, and exact key/value assertions.
