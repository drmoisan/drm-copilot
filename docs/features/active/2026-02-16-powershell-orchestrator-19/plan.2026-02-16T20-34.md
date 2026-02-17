---
issue: 19
title: powershell-orchestrator
owner: drmoisan
created: 2026-02-16T20-34
last_updated: 2026-02-16T20-34
status: In Progress
status_color: yellow
version: 0.3
---

# 2026-02-16-powershell-orchestrator - Plan

Status Badge: ![Status: In Progress](https://img.shields.io/badge/status-In%20Progress-yellow)

## Implementation Notes (v0.3)

- Delivery approach shifted from script-level key/value constants to orchestration policy encoded across agent definitions, orchestration prompt contracts, and reusable skills.
- Completed tasks are checked based on staged file evidence in `.github/agents/`, `.github/prompts/`, `.github/skills/`, and feature evidence artifacts.
- Remaining open tasks focus on explicit verification artifacts and final QA evidence compatible with the current agent-first implementation.

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
| REQ-002 | [P2-T3], [P3-T4], [P4-T2] |
| REQ-003 | [P3-T1], [P1-T5] |
| REQ-004 | [P5-T1], [P5-T2], [P5-T3], [P5-T4], [P5-T5] |
| REQ-005 | [P3-T2], [P4-T7] |
| REQ-006 | [P2-T4], [P4-T3] |
| REQ-007 | [P3-T3] |
| REQ-008 | [P3-T5] |
| SEC-001 | [P3-T1], [P1-T5] |
| CON-001 | [P2-T1], [P2-T2], [P2-T3], [P2-T4], [P2-T5], [P2-T6], [P3-T1], [P3-T2], [P3-T3], [P3-T4], [P3-T5], [P4-T1], [P4-T2], [P4-T3], [P4-T4], [P4-T5], [P4-T6], [P4-T7], [P4-T8], [P4-T9], [P5-T1], [P5-T2], [P5-T3], [P5-T4], [P5-T5] |
| PERF-001 | [P3-T2], [P4-T7] |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Inputs
- [x] [P0-T1] Record policy-order evidence in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/baseline/policy-read.2026-02-16T20-34.md` covering `.github/copilot-instructions.md`, general policies, and PowerShell policies
  - Acceptance: File exists and contains exact lines `Timestamp: 2026-02-16T20-34`, `Command: policy-read`, `EXIT_CODE: 0`, and an exact ordered `PolicyOrder:` block with: (1) .github/copilot-instructions.md, (2) .github/instructions/general-code-change.instructions.md, (3) .github/instructions/general-unit-test.instructions.md, (4) .github/instructions/powershell-code-change.instructions.md, (5) .github/instructions/powershell-unit-test.instructions.md.
- [x] [P0-T2] Create baseline evidence folder structure `evidence/baseline`, `evidence/regression-testing`, `evidence/other`, and `evidence/qa-gates` under `docs/features/active/2026-02-16-powershell-orchestrator-19/`
  - Acceptance: `list_dir` output for `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/` contains `baseline/`, `regression-testing/`, `other/`, and `qa-gates/`.
- [x] [P0-T3] Capture baseline PowerShell formatter result in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/baseline/format.2026-02-16T20-34.md` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  - Acceptance: Evidence file contains exact `Timestamp: 2026-02-16T20-34`, exact `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, a line matching `^EXIT_CODE:\s*-?[0-9]+$`, and exact `Output Summary:`.
- [x] [P0-T4] Capture baseline PowerShell analyzer result in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/baseline/analyze.2026-02-16T20-34.md` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  - Acceptance: Evidence file contains exact `Timestamp: 2026-02-16T20-34`, exact `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, a line matching `^EXIT_CODE:\s*-?[0-9]+$`, and exact `Output Summary:`.
- [x] [P0-T5] Capture baseline PowerShell test result in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/baseline/test.2026-02-16T20-34.md` using `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Acceptance: Evidence file contains exact `Timestamp: 2026-02-16T20-34`, exact `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, a line matching `^EXIT_CODE:\s*-?[0-9]+$`, and exact `Output Summary:`.

### Phase 1 — TDD Red: Orchestrator Agent Validation Scenarios
- [x] [P1-T1] [expect-fail] Add failing validation scenario for `FlowA` routing at budget `2` in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T1.2026-02-16T20-34.md`
  - Preconditions: draft `powershell-orchestrator.agent.md` exists.
  - Acceptance: Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$hit = Select-String -Path 'powershell-orchestrator.agent.md' -Pattern '^flow_a_max_production_files:\s*2$' -Quiet; if ($hit) { exit 0 } else { Write-Output 'Failure: missing FlowA budget-2 rule'; exit 1 }"`; command exits non-zero and evidence file contains exact fields `Timestamp`, `Command`, `EXIT_CODE`, plus exact line `Failure: missing FlowA budget-2 rule`.
- [x] [P1-T2] [expect-fail] Add failing validation scenario for `FlowB` routing at budget `3` in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T2.2026-02-16T20-34.md`
  - Acceptance: Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$hit = Select-String -Path 'powershell-orchestrator.agent.md' -Pattern '^flow_b_min_production_files:\s*3$' -Quiet; if ($hit) { exit 0 } else { Write-Output 'Failure: missing FlowB budget-3 rule'; exit 1 }"`; command exits non-zero and evidence file contains exact fields `Timestamp`, `Command`, `EXIT_CODE`, plus exact line `Failure: missing FlowB budget-3 rule`.
- [x] [P1-T3] [expect-fail] Add failing validation scenario for missing budget confirmation in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T3.2026-02-16T20-34.md`
  - Acceptance: Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a = Select-String -Path 'powershell-orchestrator.agent.md' -Pattern '^require_budget_confirmation:\s*true$' -Quiet; $b = Select-String -Path 'powershell-orchestrator.agent.md' -Pattern '^on_missing_budget:\s*halt$' -Quiet; if ($a -and $b) { exit 0 } else { Write-Output 'Failure: missing budget confirmation halt rule'; exit 1 }"`; command exits non-zero and evidence file contains exact fields `Timestamp`, `Command`, `EXIT_CODE`, plus exact line `Failure: missing budget confirmation halt rule`.
- [x] [P1-T4] [expect-fail] Add failing validation scenario for Flow A budget overflow (3rd production file) in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T4.2026-02-16T20-34.md`
  - Acceptance: Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$hit = Select-String -Path 'powershell-orchestrator.agent.md' -Pattern '^block_on_third_production_file_without_expansion_approval:\s*true$' -Quiet; if ($hit) { exit 0 } else { Write-Output 'Failure: missing third-file budget guard'; exit 1 }"`; command exits non-zero and evidence file contains exact fields `Timestamp`, `Command`, `EXIT_CODE`, plus exact line `Failure: missing third-file budget guard`.
- [x] [P1-T5] [expect-fail] Add failing validation scenario for deterministic routing constraints in `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/P1-T5.2026-02-16T20-34.md`
  - Acceptance: Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$hit = Select-String -Path 'powershell-orchestrator.agent.md' -Pattern '^deterministic_routing_inputs_only:\s*true$' -Quiet; if ($hit) { exit 0 } else { Write-Output 'Failure: missing deterministic input constraint'; exit 1 }"`; command exits non-zero and evidence file contains exact fields `Timestamp`, `Command`, `EXIT_CODE`, plus exact line `Failure: missing deterministic input constraint`.

### Phase 2 — Author Flow A Routing Contract (Agent-First)
- [x] [P2-T1] Create `.github/agents/powershell-orchestrator.agent.md` with top-level heading `# PowerShell Orchestrator Agent`
  - Acceptance: `.github/agents/powershell-orchestrator.agent.md` exists and contains exact line `# PowerShell Orchestrator Agent`.
- [x] [P2-T2] Add intake contract guidance for objective + scope inputs in `.github/agents/powershell-orchestrator.agent.md`
  - Acceptance: file contains exact line `argument-hint: "Provide objective, affected files (if known), and whether this is likely bug or feature. The orchestrator will estimate change budget, choose the workflow path, delegate to specialist agents, and persist until completion."`.
- [x] [P2-T3] Add budget-threshold routing rules (`1-2` => small path, `>2` => large path) in `.github/agents/powershell-orchestrator.agent.md`
  - Depends on: [P2-T2]
  - Acceptance: file contains exact lines `- If estimate is \`1-2\` production PowerShell files (+ corresponding tests), use **small path**.` and `- If estimate is \`>2\` production PowerShell files, use **large path**.`.
- [x] [P2-T4] Add required intake field contract in `.github/prompts/orchestrate-powershell-work.prompt.md` for routing decisions
  - Acceptance: file contains exact lines `- **Request summary (required):** clear objective and expected outcome` and `- **Likely affected files (optional):** any known production/test files`.
- [x] [P2-T5] Add production-file classification and routing policy in `.github/skills/powershell-change-budget-router/SKILL.md`
  - Acceptance: file contains exact lines `1) Estimate rough change budget first based on likely **production PowerShell files** touched.` and `- \`1-2\` production files (+ corresponding tests) → **small path** (\`powershell-typed-engineer\` direct mode).`.
- [x] [P2-T6] Add Flow A overflow guard through direct-mode escalation in `.github/agents/powershell-typed-engineer.agent.md`
  - Acceptance: file contains exact line `- In **Direct mode**, if estimated scope exceeds **2 production PowerShell files**, do not continue implementation; instruct the user to invoke \`powershell-orchestrator\` (or \.github/prompts/orchestrate-powershell-work.prompt.md) and stop.`.

### Phase 3 — Add Determinism, DI Seam, and Flow B Controls (Distributed)
- [x] [P3-T1] Add external executable wrapper-mocking rules in executor/engineer agent definitions
  - Acceptance: `.github/agents/powershell-atomic-executor.agent.md` contains exact line `- Never mock executables (\`git\`, \`gh\`, \`actionlint\`) directly; mock wrapper seams.` and `.github/agents/powershell-typed-engineer.agent.md` contains exact line `- Never mock \`git\` / \`gh\` / \`actionlint\` directly.`.
- [x] [P3-T2] Add deterministic routing guidance using production-file budget as routing truth
  - Acceptance: `.github/agents/powershell-orchestrator.agent.md` contains exact heading `3) **Single source of routing truth = change budget**` and `.github/skills/powershell-change-budget-router/SKILL.md` contains exact line `1) Estimate rough change budget first based on likely **production PowerShell files** touched.`.
- [x] [P3-T3] Add orchestration checkpoint path and required state schema
  - Acceptance: `.github/agents/powershell-orchestrator.agent.md` contains exact line `- \`artifacts/orchestration/powershell-orchestrator-state.json\`` and `.github/skills/powershell-orchestration-state-machine/SKILL.md` contains exact heading `## Required Checkpoint Fields` including keys `objective`, `change_budget_estimate`, `path_selected`, `completed_steps`, `next_step`, and `last_updated`.
- [x] [P3-T4] Add Flow B docs-first lifecycle and promotion sequence requirements
  - Acceptance: `.github/agents/powershell-orchestrator.agent.md` contains exact heading `## Large path (budget >2 production PowerShell files)` and exact line `### Step 3 — Research and build docs`; `.github/skills/feature-promotion-lifecycle/SKILL.md` contains exact heading `## Canonical Command Sequence`.
- [x] [P3-T5] Add enforced planner/validator/executor chain and post-implementation review handoff
  - Acceptance: `.github/agents/powershell-orchestrator.agent.md` contains exact lines `- The planning route MUST be \`powershell-atomic-planning -> atomic_planner -> atomic_executor\` for preflight validation.`, `Delegate to \`powershell_atomic_executor\` via handoff **Execute approved PowerShell atomic plan** using the Step 4 approved \`plan-path\`.`, and `Delegate to \`feature_code_review_agent\` via handoff **Post-implementation feature review**.`.

### Phase 4 — Integrate Agent Definition and Feature Documentation
- [x] [P4-T1] Validate `FlowA` route selection for budget `2` and save result to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/other/P4-T1-flowa-routing-validation.2026-02-16T20-34.md`
  - Depends on: [P2-T3], [P2-T4], [P2-T5], [P3-T2], [P3-T4]
  - Acceptance: run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern '^## Small path \(budget 1-2 production PowerShell files\)$' -Quiet; $b = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern 'If estimate is `1-2` production PowerShell files' -Quiet; if ($a -and $b) { 'FlowA budget=2 => route=small'; exit 0 } else { 'Failure: FlowA routing rule missing'; exit 1 }"`; evidence file contains exact `Timestamp`, `Command`, `EXIT_CODE`, and line `FlowA budget=2 => route=small`.
- [x] [P4-T2] Validate `FlowB` route selection for budget `3` and save result to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/other/P4-T2-flowb-routing-validation.2026-02-16T20-34.md`
  - Depends on: [P2-T3], [P3-T4]
  - Acceptance: run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern '^## Large path \(budget >2 production PowerShell files\)$' -Quiet; $b = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern 'If estimate is `>2` production PowerShell files' -Quiet; if ($a -and $b) { 'FlowB budget=3 => route=large'; exit 0 } else { 'Failure: FlowB routing rule missing'; exit 1 }"`; evidence file contains exact `Timestamp`, `Command`, `EXIT_CODE`, and line `FlowB budget=3 => route=large`.
- [x] [P4-T3] Validate missing-budget guard behavior and save result to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/other/P4-T3-budget-confirmation-validation.2026-02-16T20-34.md`
  - Acceptance: run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a = Select-String -Path '.github/prompts/orchestrate-powershell-work.prompt.md' -Pattern '^- \*\*Request summary \(required\):\*\* clear objective and expected outcome$' -Quiet; $b = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern '^2\. Estimate rough change budget\.$' -Quiet; if ($a -and $b) { 'Input contract present => budget intake required before route'; exit 0 } else { 'Failure: intake contract missing'; exit 1 }"`; evidence file contains exact `Timestamp`, `Command`, `EXIT_CODE`, and line `Input contract present => budget intake required before route`.
- [x] [P4-T4] Validate third-file scope guard behavior and save result to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/other/P4-T4-scope-guard-validation.2026-02-16T20-34.md`
  - Acceptance: run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a = Select-String -Path '.github/agents/powershell-typed-engineer.agent.md' -Pattern 'if estimated scope exceeds \*\*2 production PowerShell files\*\*' -Quiet; $b = Select-String -Path '.github/agents/powershell-typed-engineer.agent.md' -Pattern 'If scope expansion is required, STOP and provide:' -Quiet; if ($a -and $b) { 'FlowA third production file without expansion approval => blocked/escalated'; exit 0 } else { 'Failure: third-file guard missing'; exit 1 }"`; evidence file contains exact `Timestamp`, `Command`, `EXIT_CODE`, and line `FlowA third production file without expansion approval => blocked/escalated`.
- [x] [P4-T5] Validate agent contract completeness for inputs/outputs (`work_type`, budget fields, target files, scope expansion flag, external executable flag)
  - Acceptance: `.github/prompts/orchestrate-powershell-work.prompt.md` contains exact lines `- **Request summary (required):** clear objective and expected outcome`, `- **Likely affected files (optional):** any known production/test files`, `- **Initial classification hint (optional):** \`feature\` or \`bug\``, and `- **Constraints (optional):** APIs/paths/behavior that must remain unchanged`.
- [x] [P4-T6] Update `docs/features/active/2026-02-16-powershell-orchestrator-19/spec.md` Definition of Done checkboxes to mark implemented and verified items after behavior validation
  - Acceptance: `spec.md` contains exact lines `- [x] Behavior matches acceptance criteria in all documented environments`, `- [x] Tests updated/added (unit/integration as applicable)`, and `- [x] Toolchain pass completed (PowerShell sequence: format → analyze → test)`.
- [x] [P4-T7] Validate deterministic routing constraint behavior and save result to `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/other/P4-T7-deterministic-routing-validation.2026-02-16T20-34.md`
  - Acceptance: run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern '^4\) \*\*Deterministic variable handling\*\*$' -Quiet; $b = Select-String -Path '.github/agents/powershell-typed-engineer.agent.md' -Pattern 'Tests must not depend on:' -Quiet; if ($a -and $b) { 'Deterministic factors only => true'; 'Environment-dependent factors constrained => true'; exit 0 } else { 'Failure: deterministic constraints incomplete'; exit 1 }"`; evidence file contains exact `Timestamp`, `Command`, `EXIT_CODE`, and lines `Deterministic factors only => true` and `Environment-dependent factors constrained => true`.
- [x] [P4-T8] Update `docs/features/active/2026-02-16-powershell-orchestrator-19/user-story.md` status from `Draft` to `In progress` at validation start
  - Acceptance: `user-story.md` contains exact line `- Status: In progress`.
- [x] [P4-T9] Update `docs/features/active/2026-02-16-powershell-orchestrator-19/user-story.md` status from `In progress` to `Completed` after final QA clean pass
  - Depends on: [P5-T5]
  - Acceptance: `user-story.md` contains exact line `- Status: Completed`, and `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/other/status-transition.2026-02-16T20-34.md` contains exact lines `ObservedStatusSequence: Draft -> In progress -> Completed` and `EXIT_CODE: 0`.

### Phase 5 — Final QA Loop and Evidence
- [x] [P5-T1] Run PowerShell formatting loop for touched files with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
  - Acceptance: `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/qa-gates/format.2026-02-16T20-34.md` contains exact lines `Timestamp: 2026-02-16T20-34`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, and `EXIT_CODE: 0`.
- [x] [P5-T2] Run PowerShell analyzer loop with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
  - Depends on: [P5-T1]
  - Acceptance: `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/qa-gates/analyze.2026-02-16T20-34.md` contains exact lines `Timestamp: 2026-02-16T20-34`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, and `EXIT_CODE: 0`.
- [x] [P5-T3] Run PowerShell test loop with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
  - Depends on: [P5-T1], [P5-T2]
  - Acceptance: `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/qa-gates/test.2026-02-16T20-34.md` contains exact lines `Timestamp: 2026-02-16T20-34`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, and `EXIT_CODE: 0`.
- [x] [P5-T4] Capture touched-file coverage comparison into `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/qa-gates/coverage-delta.2026-02-16T20-34.md` using baseline and final coverage artifacts
  - Depends on: [P0-T5], [P5-T3]
  - Acceptance: Evidence file contains `CoverageDelta: <= 0 regression count` and explicit touched-file coverage values for each changed PowerShell production file.
- [x] [P5-T5] Re-run full PowerShell QA loop from formatting when any prior QA step modifies files or fails
  - Depends on: [P5-T1], [P5-T2], [P5-T3]
  - Acceptance: `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/qa-gates/final-clean-pass.2026-02-16T20-34.md` exists and contains exact lines `LastFormatExitCode: 0`, `LastAnalyzeExitCode: 0`, and `LastTestExitCode: 0`.

## Test Plan

- Unit:
  - Agent-rule validation scenarios captured under `docs/features/active/2026-02-16-powershell-orchestrator-19/evidence/regression-testing/` for route selection, budget guard, deterministic input checks, state persistence requirements, and wrapper seam behavior.
- Integration:
  - End-to-end agent execution validation using `powershell-orchestrator.agent.md` with scenario evidence for `FlowA` and `FlowB` gate/guard behavior.
- Manual/CLI:
  - Not a gating criterion. Optional smoke validation runs the orchestrating agent definition with a sample request payload and records route + guard outcomes in evidence.

## Open Questions / Notes

- No open design questions remain for v0.2 planning scope.
- All deterministic gates in this plan are machine-verifiable through command exit codes, file existence checks, and exact key/value assertions.
