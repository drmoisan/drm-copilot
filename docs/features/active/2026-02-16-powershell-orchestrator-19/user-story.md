# `2026-02-16-powershell-orchestrator` — User Story

- Issue: #19
- Owner: drmoisan
- Status: Draft
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


## Personas & Scenarios

- Persona: PowerShell workflow maintainer
  - Maintains repository automation, CI quality gates, and agent workflow consistency.
  - Cares about predictable routing, bounded scope, and reliable regression protection.
  - Must support contributors on different machines and shells without environment-dependent behavior.
  - Wants fast execution for small tasks while preserving planning rigor for broader changes.
  - Is frustrated when ad hoc decisions bypass documentation and later create rework.
- Persona: PowerShell contributor
  - Implements script/module updates and associated Pester coverage.
  - Cares about quick feedback loops and clear rules for when direct execution is allowed.
  - Is constrained by analyzer/test/coverage quality gates and limited change budgets.
  - Wants to avoid spending feature-level process overhead on tiny edits.
  - Needs explicit escalation when a request exceeds two production files.
- Scenario: Small-scope maintenance fix (Flow A)
  - A contributor receives a request to update behavior in one script and one module plus matching tests.
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

- [ ] The orchestration routes to Flow A when the change budget is ≤ 2 production PowerShell files and only touches those production files plus the minimal corresponding `*.Tests.ps1` files.
- [ ] The orchestration routes to Flow B when the change budget is > 2 production PowerShell files, and it produces the required documentation artifacts (potential → promote → active folder → research → `spec.md`, optional `user-story.md`) before any broad implementation begins.
- [ ] Flow A enforces “thin DI seam” rules: external executables are not mocked directly; they are invoked through a wrapper function that can be mocked in Pester.
- [ ] Flow A and Flow B both enforce zero-regression gates: no new PSScriptAnalyzer findings, no new failing tests, and no coverage regressions for touched files.
- [ ] The orchestrator is deterministic and does not depend on PATH, working directory, profiles, network, or machine-specific state to decide routing.


## Non-Goals

- Replacing or redesigning the repository’s existing feature/bug documentation templates.
- Changing non-PowerShell orchestration behavior (TypeScript/Python flows are out of scope).
- Introducing new CI systems, external services, or network-dependent routing logic.
- Auto-approving scope expansion when requests exceed the declared production file budget.
- Reworking repository-wide coverage infrastructure beyond capturing touched-file regression signals.
