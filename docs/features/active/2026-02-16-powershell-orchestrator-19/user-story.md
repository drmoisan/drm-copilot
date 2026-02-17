# `2026-02-16-powershell-orchestrator` — User Story

- Issue: #19
- Owner: drmoisan
- Status: Completed
- Last Updated: 2026-02-16T20-34

## Story Statement

- As a repository maintainer, I want PowerShell work requests routed by an explicit change budget, so that small fixes ship quickly and larger changes follow the full documentation/planning/audit path.
- As a contributor implementing PowerShell changes, I want deterministic routing and enforced guardrails, so that I can deliver minimal, testable updates without accidental scope creep.

## Problem / Why

The repo has multiple agent workflows (direct implementation vs. feature/bug documentation + atomic planning/execution), but there is no single, repeatable orchestration rule to choose the right workflow based on scope.

This creates two failure modes:
- Small PowerShell changes take too long because they are forced through heavyweight feature workflows.
- Larger PowerShell changes get started “directly” and then sprawl, violating change budgets, testability, and quality gates.

We need a PowerShell-specific orchestration feature that:
- Uses a **change budget** (production files + corresponding test files) as the routing signal.
- Ensures minimal, testable changes for small scope.
- Ensures correct documentation/research/planning/execution/audit for larger scope.
- Is defined in `powershell-orchestrator.agent.md` as an orchestrating agent (not as a PowerShell script).


## Personas & Scenarios

- Persona: PowerShell workflow maintainer
  - Maintains repository automation, CI quality gates, and agent workflow consistency.
  - Cares about predictable routing, bounded scope, and reliable regression protection.
  - Must support contributors on different machines and shells without environment-dependent behavior.
  - Wants fast execution for small tasks while preserving planning rigor for broader changes.
  - Is frustrated when ad hoc decisions bypass documentation and later create rework.
- Persona: PowerShell contributor
  - Implements PowerShell production/test updates under orchestrator routing and associated Pester coverage.
  - Cares about quick feedback loops and clear rules for when direct execution is allowed.
  - Is constrained by analyzer/test/coverage quality gates and limited change budgets.
  - Wants to avoid spending feature-level process overhead on tiny edits.
  - Needs explicit escalation when a request exceeds two production files.
- Scenario: Small-scope maintenance fix (Flow A)
  - A contributor receives a request to update behavior in one module and one script plus matching tests.
  - The request is routed through `powershell-orchestrator.agent.md` before implementation.
  - The orchestrator captures a change budget of two production PowerShell files and validates that the scope fits Flow A.
  - The contributor implements changes through thin DI seams, mocking wrapper functions in Pester rather than external executables.
  - During execution, the orchestrator blocks any attempt to touch a third production file unless budget expansion is explicitly approved.
  - The contributor completes format/analyze/test gates and ships a minimal, deterministic change.
- Scenario: Broader enhancement (Flow B)
  - A maintainer receives a request that clearly requires three or more production PowerShell files.
  - The orchestrator routes to Flow B before implementation and requires potential→promote→active folder→research→spec/user story artifacts.
  - Planning and execution are delegated through planner/validator/executor/audit stages.
  - The maintainer reviews generated artifacts and gating evidence before implementation proceeds.
  - The expected outcome is documented scope control and traceable quality checks for the larger change.


## Acceptance Criteria

- [x] The orchestration routes to Flow A when the change budget is ≤ 2 production PowerShell files and only touches those production files plus the minimal corresponding `*.Tests.ps1` files.
- [x] The orchestration routes to Flow B when the change budget is > 2 production PowerShell files, and it produces the required documentation artifacts (potential → promote → active folder → research → `spec.md`, optional `user-story.md`) before any broad implementation begins.
- [x] Route selection and guard enforcement are driven by `powershell-orchestrator.agent.md` as the orchestration authority.
- [x] Flow A enforces “thin DI seam” rules: external executables are not mocked directly; they are invoked through a wrapper function that can be mocked in Pester.
- [x] Flow A and Flow B both enforce zero-regression gates: no new PSScriptAnalyzer findings, no new failing tests, and no coverage regressions for touched files.
- [x] The orchestrator is deterministic and does not depend on PATH, working directory, profiles, network, or machine-specific state to decide routing.


## Non-Goals

- Replacing or redesigning the repository’s existing feature/bug documentation templates.
- Changing non-PowerShell orchestration behavior (TypeScript/Python flows are out of scope).
- Introducing new CI systems, external services, or network-dependent routing logic.
- Auto-approving scope expansion when requests exceed the declared production file budget.
- Reworking repository-wide coverage infrastructure beyond capturing touched-file regression signals.

## Acceptance Criteria Evidence (partial, as of 2026-02-16T21-16)

| Criterion | Evidence | Verification command(s) |
|---|---|---|
| Route/guard rules are currently missing and captured via red tests | `evidence/regression-testing/P1-T1.2026-02-16T20-34.md` through `P1-T5.2026-02-16T20-34.md` include expected failure messages and non-zero exit codes | Commands embedded in each `P1-T*` evidence artifact under `Command:` |
| Orchestration authority file exists in agent directory | `.github/agents/powershell-orchestrator.agent.md` exists | `Test-Path ".github/agents/powershell-orchestrator.agent.md"` |
| Baseline quality-gate captures for this run exist | `evidence/baseline/format.2026-02-16T20-34.md`, `analyze.2026-02-16T20-34.md`, `test.2026-02-16T20-34.md` with `EXIT_CODE: 0` | `Invoke-PoshQCFormat -Root .`; `Invoke-PoshQCAnalyze -Root .`; `Invoke-PoshQCTest -Root .` |

Open criteria:
- Flow A success behavior (not red-fail capture) is not yet evidenced.
- Flow B docs-first behavior and delegation-order success are not yet evidenced.
- Zero-regression final gates and coverage-delta criteria are not yet evidenced.
- Deterministic runtime routing success is not yet evidenced.
