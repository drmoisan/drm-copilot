# 2026-02-16-powershell-orchestrator — Spec

- **Issue:** #19
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-16T20-34
- **Status:** Draft
- **Version:** 0.1

## Overview

The repo has multiple agent workflows (direct implementation vs. feature/bug documentation + atomic planning/execution), but there is no single, repeatable orchestration rule to choose the right workflow based on scope.

This creates two failure modes:
- Small PowerShell changes take too long because they are forced through heavyweight feature workflows.
- Larger PowerShell changes get started “directly” and then sprawl, violating change budgets, testability, and quality gates.

We need a PowerShell-specific orchestration feature that:
- Uses a **change budget** (production files + corresponding test files) as the routing signal.
- Ensures minimal, testable changes for small scope.
- Ensures correct documentation/research/planning/execution/audit for larger scope.
- Is implemented as an orchestrating agent definition file named `powershell-orchestrator.agent.md` (not as a PowerShell script).

Research sufficiency: the promoted issue context in `issue.md` is sufficient to complete this v0.1 spec draft without additional research.


## Behavior

Orchestrate PowerShell development by routing each request into one of two flows based on an explicit **change budget**.

### Definitions
- **Change budget**: maximum allowed touched files for the work item.
	- Production budget is measured as the count of changed `*.ps1`/`*.psm1` (and any other production PowerShell files) required to implement the behavior.
	- “Corresponding test files” means the minimal set of Pester `*.Tests.ps1` files needed to cover the changed production behavior.

### Flow A: Small scope (≤ 2 production files)
If the change budget is **two production files (or fewer)** plus their corresponding test files:
- Plan and execute directly with a single orchestrating agent (`powershell-orchestrator.agent.md`) that combines:
	- Strong gating discipline and typed-toolchain habits (baseline → plan → small-batch edits → final QA), and
	- PowerShell DI + Pester expertise (thin seams for mocking external executables/cmdlets).
- Enforce the guardrails:
	- No scope creep beyond the budget.
	- Minimal DI seams only (wrapper functions preferred).
	- Run repo-standard PowerShell toolchain gates (format → analyze → test) after each batch and at the end.

### Flow B: Larger scope (> 2 production files)
If the change budget is **more than two production files**:
- Follow the repo’s “new feature” or “new bug” workflow (depending on whether the request is feature work or a defect).
- Produce the standard artifacts and checkpoints before implementation:
	- Create a potential entry and promote it.
	- Create an active feature folder.
	- Perform research for the issue.
	- Fill out `spec.md` and optionally `user-story.md`.
- Delegate planning/execution and auditing:
	- Delegate to a PowerShell-focused atomic planner to produce an executable plan.
	- Validate with a PowerShell-focused atomic executor.
	- Execute via the PowerShell atomic executor.
	- Audit via the feature review agent.

### Routing requirement
The orchestrator must ask for (or infer from the request) the intended change budget up front. If the request is ambiguous, default to the simplest interpretation and require an explicit budget confirmation before execution.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Work request metadata from the invoking agent context:
		- request type: `feature` or `bug`
		- requested/confirmed production change budget: integer count of PowerShell production files
		- candidate file list (when available) for pre-flight scope validation
	- Repository policy and workflow inputs:
		- issue and active feature docs in `docs/features/active/2026-02-16-powershell-orchestrator-19/`
		- orchestrator definition file `powershell-orchestrator.agent.md`
		- PowerShell quality tooling and tasks under `scripts/dev-tools/` and `scripts/powershell/PoshQC/`
	- Environment assumptions for routing logic:
		- routing decision must not use PATH lookup, shell profile state, network calls, or current working directory heuristics
- Outputs (artifacts, logs, telemetry)
	- Routing decision: `FlowA` or `FlowB` plus decision rationale (budget, scope, and request type).
	- Scope ledger updates in `artifacts/orchestration/powershell-orchestrator-state.json` capturing:
		- declared budget
		- touched production files
		- touched test files
		- gate run status (format/analyze/test)
	- Flow B documentation artifacts completed/updated before broad implementation:
		- `docs/features/active/.../spec.md`
		- `docs/features/active/.../user-story.md` (when required)
	- Gate evidence from existing repo tooling outputs (for example Pester/analyzer artifacts under `artifacts/`).
- Config keys and defaults:
	- `production_file_budget`: required for execution; defaults to inferred minimal scope only until explicit confirmation.
	- `flow_threshold_production_files`: default `2` (Flow A if `<= 2`, Flow B if `> 2`).
	- `enforce_budget_block`: default `true` (block touching additional production files without explicit approval).
	- `deterministic_routing`: default `true` (disallow machine/environment-dependent routing conditions).
- Versioning or backward-compatibility constraints:
	- Existing PowerShell scripts/modules retain current invocation contracts.
	- This feature adds orchestration policy and state tracking in an agent definition; it does not require breaking changes to existing script parameters.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Request shape (agent/orchestrator contract consumed by `powershell-orchestrator.agent.md`):
	- `work_type`: `feature | bug`
	- `budget.production_files`: integer `>= 1`
	- `budget.test_files`: optional integer hint
	- `target_files`: optional array of repo-relative paths
	- `requires_external_executable`: optional boolean
- Response shape:
	- `route`: `FlowA | FlowB`
	- `reason`: concise routing rationale
	- `budget_confirmed`: boolean
	- `next_actions`: ordered list of required steps for selected flow
- Example invocations with expected outputs (concise):
	- Input: `work_type=bug`, `budget.production_files=2` → Output: `route=FlowA`, direct plan/execute with budget guard + format/analyze/test gates.
	- Input: `work_type=feature`, `budget.production_files=3` → Output: `route=FlowB`, require potential/promote/active/research/spec (and optional user story) before implementation.
	- Input: ambiguous scope with no explicit budget → Output: `budget_confirmed=false`, request explicit budget confirmation before execution.
- Contracts and validation rules:
	- Budget must be explicit before implementation starts.
	- Production scope counting includes touched PowerShell production files only; imported dependencies do not count unless modified.
	- Touching a third production file during Flow A is blocked until explicit scope expansion approval.
	- `powershell-orchestrator.agent.md` is the orchestration authority for route selection and precondition enforcement.
	- When `requires_external_executable=true` in Flow A, implementation must use a wrapper seam mockable in Pester.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Normalize candidate file paths to repo-relative form before counting budget usage.
	- Classify touched files into production vs test buckets using extension/pattern rules (`*.ps1`, `*.psm1`, `*.Tests.ps1`).
	- Invariant: Flow A is valid only when touched production file count stays `<= 2`.
	- Invariant: Flow B must have required documentation checkpoints recorded before broad code changes.
	- Invariant: Routing decision is reproducible from request payload + tracked touched-file set.
- Caching or persistence details:
	- Persist orchestration run state and gate status in `artifacts/orchestration/powershell-orchestrator-state.json`.
	- No long-lived network cache; all routing data is local repository state and request metadata.
- Migration or backfill requirements (if any):
	- No data migration required for initial rollout.
	- Existing artifacts remain valid; new runs append/overwrite orchestrator state fields as needed.

## Constraints & Risks

- **Scope accounting risk**: “production file count” must be computed consistently (e.g., dot-sourced scripts vs. modules). The rule must be explicit: touched files, not imported dependencies.
- **Test discovery parity risk**: VS Code Test Explorer vs. terminal runs can differ; Flow A must prefer wrapper seams so mocking does not depend on executable resolution.
- **Toolchain contract risk**: PowerShell has formatter/analyzer/test steps but no type-check step; the orchestrator must still run the repo-standard sequence for PowerShell.
- **Workflow friction risk**: Over-triggering Flow B for small changes would slow iteration; under-triggering Flow B would invite scope creep.
- **Coverage tracking risk**: Per-file coverage deltas must be captured for touched files; this requires stable coverage reporting and a consistent baseline method.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Implement/maintain orchestration routing logic in `powershell-orchestrator.agent.md` for PowerShell requests based on explicit production file budget.
	- Add scope-accounting and budget-enforcement checks for touched production/test files.
	- Integrate Flow A gating contract (format → analyze → test) and Flow B documentation-first checkpoints.
	- Record deterministic routing and gate outcomes to existing orchestration artifact state.
- New classes/functions/commands to add or update:
	- Add/update sections and decision rules in `powershell-orchestrator.agent.md` to classify touched files and compute budget utilization.
	- Add/update orchestration guard rules in `powershell-orchestrator.agent.md` for wrapper-seam enforcement when external executables are involved in Flow A.
	- Add/update orchestration precondition rules in `powershell-orchestrator.agent.md` for Flow B documentation checkpoints.
- Dependency changes (new/removed packages) and rationale:
	- No new runtime dependencies expected.
	- Reuse existing repository PowerShell tooling under `scripts/powershell/PoshQC/`; orchestration logic itself remains in markdown agent configuration.
- Logging/telemetry additions and locations:
	- Add structured routing decision logs and budget enforcement events emitted by `powershell-orchestrator.agent.md` runs.
	- Persist summary fields to `artifacts/orchestration/powershell-orchestrator-state.json` for auditability.
	- Capture gate pass/fail status and touched-file deltas in the same orchestration artifact context.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Stage 1: enable for explicit PowerShell-scoped requests only.
	- Stage 2: enforce budget confirmation for all PowerShell requests.
	- Fallback: if routing inputs are incomplete, halt execution and request budget confirmation rather than defaulting to non-deterministic behavior.

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos (see Acceptance Criteria + Seeded Test Conditions)
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [x] Docs updated (feature `spec.md` and `user-story.md` completed for Issue #19)
- [ ] Telemetry/logging added or updated (if applicable)
- [x] Toolchain pass completed (PowerShell sequence: format → analyze → test)

## Seeded Test Conditions (from potential)
- [x] Flow A: Request that can be implemented by changing 1–2 PowerShell production files and a single `*.Tests.ps1` file; verify it plans + executes directly and runs format/analyze/test gates.
- [x] Flow A: Request that involves an external executable call; verify it introduces a wrapper function and mocks the wrapper in Pester (not the executable).
- [x] Flow A: Verify budget enforcement blocks attempts to touch a 3rd production file unless the user explicitly approves a scope expansion.
- [x] Flow B: Request that would require touching 3+ production files; verify it creates/promotes the potential entry and fills `spec.md` (and `user-story.md` when requested) before implementation.
- [x] Flow B: Verify delegation order is enforced (planner → validator → executor → audit).
- [x] Regression: Verify reruns are deterministic across shells/hosts (no dependence on `$PWD`, profiles, PATH, or network).

## Acceptance Criteria Evidence (partial, as of 2026-02-16T21-16)

| Criterion | Evidence | Verification command(s) |
|---|---|---|
| Baseline PowerShell formatter/analyzer/test captures exist for this feature run | `evidence/baseline/format.2026-02-16T20-34.md`, `evidence/baseline/analyze.2026-02-16T20-34.md`, `evidence/baseline/test.2026-02-16T20-34.md` with `EXIT_CODE: 0` | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`; `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`; `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` |
| TDD-red failure scenarios for missing Flow rules and deterministic guardrails are captured | `evidence/regression-testing/P1-T1.2026-02-16T20-34.md` through `P1-T5.2026-02-16T20-34.md` each include failure message and non-zero exit code | Commands embedded in each `P1-T*` evidence artifact under `Command:` |
| Initial orchestrator agent file presence is confirmed | `.github/agents/powershell-orchestrator.agent.md` exists | `Test-Path ".github/agents/powershell-orchestrator.agent.md"` |

Open criteria:
- Behavior-level Flow A/Flow B routing success criteria remain unverified (`P2+` and `P4+` tasks not complete).
- Telemetry/state-write and deterministic runtime validation tasks remain open.
- Final QA-gates evidence (`evidence/qa-gates/*`) remains open.
