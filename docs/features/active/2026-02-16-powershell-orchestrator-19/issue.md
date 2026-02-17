# powershell-orchestrator (Issue #19)

- Date captured: 2026-02-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/powershell-orchestrator/ (Issue #19)

- Issue: #19
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/19
- Last Updated: 2026-02-17
## Problem / Why

The repo has multiple agent workflows (direct implementation vs. feature/bug documentation + atomic planning/execution), but there is no single, repeatable orchestration rule to choose the right workflow based on scope.

This creates two failure modes:
- Small PowerShell changes take too long because they are forced through heavyweight feature workflows.
- Larger PowerShell changes get started “directly” and then sprawl, violating change budgets, testability, and quality gates.

We need a PowerShell-specific orchestration feature that:
- Uses a **change budget** (production files + corresponding test files) as the routing signal.
- Ensures minimal, testable changes for small scope.
- Ensures correct documentation/research/planning/execution/audit for larger scope.

## Proposed Behavior

Orchestrate PowerShell development by routing each request into one of two flows based on an explicit **change budget**.

### Definitions
- **Change budget**: maximum allowed touched files for the work item.
	- Production budget is measured as the count of changed `*.ps1`/`*.psm1` (and any other production PowerShell files) required to implement the behavior.
	- “Corresponding test files” means the minimal set of Pester `*.Tests.ps1` files needed to cover the changed production behavior.

### Flow A: Small scope (≤ 2 production files)
If the change budget is **two production files (or fewer)** plus their corresponding test files:
- Plan and execute directly with a single PowerShell agent that combines:
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

## Acceptance Criteria (early draft)

- [ ] The orchestration routes to Flow A when the change budget is ≤ 2 production PowerShell files and only touches those production files plus the minimal corresponding `*.Tests.ps1` files.
- [ ] The orchestration routes to Flow B when the change budget is > 2 production PowerShell files, and it produces the required documentation artifacts (potential → promote → active folder → research → `spec.md`, optional `user-story.md`) before any broad implementation begins.
- [ ] Flow A enforces “thin DI seam” rules: external executables are not mocked directly; they are invoked through a wrapper function that can be mocked in Pester.
- [ ] Flow A and Flow B both enforce zero-regression gates: no new PSScriptAnalyzer findings, no new failing tests, and no coverage regressions for touched files.
- [ ] The orchestrator is deterministic and does not depend on PATH, working directory, profiles, network, or machine-specific state to decide routing.

## Constraints & Risks

- **Scope accounting risk**: “production file count” must be computed consistently (e.g., dot-sourced scripts vs. modules). The rule must be explicit: touched files, not imported dependencies.
- **Test discovery parity risk**: VS Code Test Explorer vs. terminal runs can differ; Flow A must prefer wrapper seams so mocking does not depend on executable resolution.
- **Toolchain contract risk**: PowerShell has formatter/analyzer/test steps but no type-check step; the orchestrator must still run the repo-standard sequence for PowerShell.
- **Workflow friction risk**: Over-triggering Flow B for small changes would slow iteration; under-triggering Flow B would invite scope creep.
- **Coverage tracking risk**: Per-file coverage deltas must be captured for touched files; this requires stable coverage reporting and a consistent baseline method.

## Test Conditions to Consider

- [ ] Flow A: Request that can be implemented by changing 1–2 PowerShell production files and a single `*.Tests.ps1` file; verify it plans + executes directly and runs format/analyze/test gates.
- [ ] Flow A: Request that involves an external executable call; verify it introduces a wrapper function and mocks the wrapper in Pester (not the executable).
- [ ] Flow A: Verify budget enforcement blocks attempts to touch a 3rd production file unless the user explicitly approves a scope expansion.
- [ ] Flow B: Request that would require touching 3+ production files; verify it creates/promotes the potential entry and fills `spec.md` (and `user-story.md` when requested) before implementation.
- [ ] Flow B: Verify delegation order is enforced (planner → validator → executor → audit).
- [ ] Regression: Verify reruns are deterministic across shells/hosts (no dependence on `$PWD`, profiles, PATH, or network).

## Next Step

- [ ] Promote to GitHub issue (feature request template) and include Flow A/Flow B routing rules.
- [ ] Create `docs/features/active/powershell-orchestrator/` folder from the template.
- [ ] Identify the concrete entry point(s) (script, VS Code task, or extension command) that will host this orchestration logic.
- [ ] Confirm which existing agents map to “PowerShell-focused atomic planner/executor” and “feature review agent”, or create them if missing.
