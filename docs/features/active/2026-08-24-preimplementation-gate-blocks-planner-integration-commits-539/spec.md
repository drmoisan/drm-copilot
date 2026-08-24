# preimplementation-gate-blocks-planner-integration-commits (Spec)

- **Issue:** #539
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-24T09-18
- **Status:** Draft
- **Version:** 0.1

## Context
`Test-ImplementationCommand` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` denies every `git add` and `git commit` by command pattern, with no path-based or planner-surface exemption and no epic-shaped readiness source. The epic-planner and parallel-planner contracts require committing planning artifacts (`epic.md`, per-feature fan-ins, the kickoff artifact, the run manifest), so `/epic-plan` and `/parallel-plan` remain blocked at their commit steps even after the #535 fix exempted checkpoint writes and preparation-mode delegations.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (PowerShell hook)
- Command/flags used: `/epic-plan` (TaskMaster destination repo, 2026-08-24, pushed-down hook copy); leg reproduced by inspection of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` at `main` post-PR #536
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/settings.json` PreToolUse matchers (Bash, Write|Edit, Agent)

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. With no ready `artifacts/orchestration/orchestrator-state.json` present, invoke the hook with a Bash payload whose `command` is `git add docs/features/epics/<slug>/epic.md` (or any `git commit`). `Test-ImplementationCommand` matches `(^|\s)git\s+(add|commit)\b` and the decision is `deny` with `PREIMPLEMENTATION_GATE_BLOCKED`.
2. Observe that the `docs/features/active/` and `CheckpointPaths` exemptions exist only on the `file_path` branch of `Invoke-OrchestrationPreimplementationGateDecision`; the command branch has no exemption, so a docs-only or checkpoint-only commit is denied exactly like a production-code commit.
3. Observe that `Test-OrchestrationReady` accepts only the single-feature checkpoint shape: one `issue-num`, a `feature-folder` under `docs/features/active/`, `route_id`, and truthy `lifecycle_ready`. An epic (integration-branch commits, artifacts under `docs/features/epics/<slug>/`, many issues) and a parallel run (artifacts under `docs/features/parallel/<slug>/`) can never truthfully satisfy it, so the gate is structurally unsatisfiable for planner integration commits.

Expected:
- The planner and orchestrator surfaces can stage and commit their own contract-mandated artifacts (epic folder documents, parallel run manifests, kickoff artifacts, checkpoint files) without a single-feature-ready `orchestrator-state.json`, since committing planning output is orchestration bookkeeping, not implementation.
- The gate stays fail-closed for genuine implementation commits (production source, tests) made before orchestration readiness exists.

Actual:
- Every `git add` / `git commit` is denied unless the single-feature checkpoint is ready. A TaskMaster `/epic-plan` run on 2026-08-24 was halted before scaffolding: the integration-branch commit of `epic.md`, every fan-in commit, and the durable kickoff copy were all denied. The same exposure applies to `/parallel-plan` planner commits and was previously recorded as a standing finding (housekeeping commits require a manual user commit).

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:

  ```text
  PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require
  artifacts/orchestration/orchestrator-state.json to contain issue number,
  feature folder, route metadata, lifecycle readiness, and checkpoint state
  before implementation begins.
  ```


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
- `Test-ImplementationCommand` (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:79-103`) classifies by command pattern only; it never inspects the paths being staged or the committing surface.
- Issue #535 / PR #536 fixed the other two gate legs (checkpoint writes via `CheckpointPaths`, preparation-mode delegations via `Test-PreparationModeDelegation`) and deliberately left this leg out of scope; the #535 potential doc records it as a "related standing finding".
- The hook is push-down-owned: the fix must land in drm-copilot and both push-down resource copies (`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `.../codex-and-agents-customizations/.codex/hooks/`), then reach destination repos via push-down.
- Related but distinct: #516 (absolute checkpoint path rejected on the `file_path` branch).


## Proposed Fix

### Design summary (what changes where):

### Boundaries and invariants to preserve:

### Dependencies or blocked work:

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:

#### Functions/classes/CLI commands impacted:

#### Data flow and validation changes:

#### Error handling and logging updates:

#### Rollback/feature-flag considerations (if applicable):

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

#### Required configuration keys and defaults:

#### Backward-compatibility expectations:

#### Performance constraints (latency/throughput/memory):

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
- Constraints (budget, performance, compatibility):
- External dependencies (services, libraries, releases):

## Data / API / Config Impact
- User-facing or API changes:
- Data or migration considerations:
- Logging/telemetry updates (if any):
- Compatibility notes (CLI flags, config schemas, versioning):

## Test Strategy
Seeded from issue:

- Candidate remedies (choose at spec time): exempt a `git add`/`git commit` whose staged pathspec arguments all fall within orchestration-bookkeeping trees (`docs/features/epics/**`, `docs/features/parallel/**`, `docs/features/active/**`, `artifacts/orchestration/**`); or accept `epic-planner-state.json` / `parallel-planner-state.json` as alternative readiness sources for the command branch; or scope the command-branch gate to sessions whose route is an implementation route.
- Keep the gate fail-closed: a commit that stages any production source or test path must still require the ready checkpoint, and pathspec parsing failures must deny.
- [ ] Unit coverage areas: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (positive: epic/parallel docs commit allowed without checkpoint; negative: mixed pathspec including a `.ps1`/`.py` production path denied; negative: bare `git commit` with unparseable pathspec denied)
- [ ] Integration scenario to retest: `/epic-plan` end-to-end in a destination repo after push-down — integration-branch commit of `epic.md` succeeds; `/parallel-plan` manifest and kickoff commits succeed
- [ ] Manual verification notes: dot-source the hook and drive `Invoke-OrchestrationPreimplementationGateDecision` with constructed Bash payloads for allowed and denied cases

- Regression tests to add or update:
- Unit tests (pytest) for the fixed behavior and boundaries:
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
- Error handling and logging verification:
- Coverage impact and targets for changed lines/modules:
- Toolchain commands to run (format → lint → type-check → test):
- Manual validation steps (if required):


## Acceptance Criteria
- [ ] Repro steps now produce the expected behavior in all documented environments.
- [ ] Regression test(s) added and passing (list file path and test name).
- [ ] Edge cases and invalid inputs are handled with correct errors or fallbacks.
- [ ] No unintended behavior changes outside the defined scope.
- [ ] Required logs/telemetry updated and validated (if applicable).
- [ ] Performance constraints met or explicitly waived with rationale.
- [ ] Full toolchain pass completed (format → lint → type-check → test).
- [ ] Docs/config references updated to match the new behavior.

## Risks & Mitigations
- Technical or operational risks:
- Mitigations and rollbacks:

## Rollout & Follow-up
- Release/rollout steps:
- Post-fix monitoring or clean-up tasks:
- Links: issue, PRs, related docs
