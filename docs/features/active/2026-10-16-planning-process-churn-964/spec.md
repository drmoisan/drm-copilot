# 2026-10-16-planning-process-churn (Spec)

- **Issue:** #964
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T18-10
- **Status:** Draft
- **Version:** 0.1

## Context
The research, planning, preflight and remediation process produces large, literal-heavy plans. It then spends most of its agent budget on planner/preflight round trips instead of execution. In parallel run `bug-burndown-2026-10-15`:

| Item | Agents | Execution runs | Planner/preflight agents | Preflight rounds before remediation |
|---|---|---|---|---|
| #953 | 46 | 5 | 35 | 8 |
| #952 | 40 | 4 | 31 | |
| #935 | about 34 | 4 | about 24 | |

#962's plan is 1,754 lines with 99 tasks for one CI decision job, and it took six preflight rounds. No bug PR merged for about 4.5 hours while nearly three accounts' worth of usage went into these loops. The process should produce a plan that passes preflight in one round and review the first time.

Environment:
- OS/version: Windows 11 host; agent-isolated git worktrees; GitHub Actions CI
- Python version: n/a
- Command/flags used: orchestrate, parallel-plan and parallel-run skills; the atomic-planner and atomic-executor (preflight and execute) agents; feature-review
- Data source or fixture: run `bug-burndown-2026-10-15`, items #935, #952, #953 and #962 (agent tree for session 0f6aac23-6ea2-4759-9a9b-c826039d3306)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Prepare an item through preparation mode, or open a remediation cycle.
2. Observe the atomic-planner writing a plan that pins line numbers, commit SHAs, literal success tokens, inline awk programs and per-command shell wrappers.
3. Observe preflight rejecting it for a few stale or inexact literals per round. A fresh planner then applies a delta of 4 to 23 lines, and a fresh preflight re-reads everything, repeated over 3 to 8 rounds.
4. Observe main moving through parallel merges, which invalidates the cited line numbers and SHAs and forces re-derivation and more preflight rounds.
5. Observe review finding issues the plan never anticipated, which triggers remediation cycles that repeat steps 2 to 4.

Expected:
- Plans are design-level: files, behavior, tests and acceptance criteria. They are robust to main moving, and they clear preflight in one round.
- Execution-environment constraints are known before planning.
- Review and CI concerns are anticipated in research and planning, through a pre-mortem, so the first review passes.
- At most one correction pass is needed for a genuinely unforeseen problem.

Actual:
Each item needs 3 to 8 preflight rounds and 2 to 4 remediation cycles. Most agent spend goes into plan-literal maintenance.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:
  - #962 plan revision diffs: round 6 changed 4 lines, round 5 11, round 3 23.
  - #952: "re-derive plan after #928/#929 merge"; #962: "revise plan for concurrent #952/#953 composition" (514 lines).
  - Repeated rediscovery of the same constraints: the worktree guard denies `pwsh`/`bash`/`wsl` command text, the executor has no PowerShell tool (hence the "Tool route" wrappers), the batch-budget cap, and contract tests such as `test_quality_checks_workflow_contracts.py`.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
1. **Literal-transcript plans.** `.claude/rules/plan-acceptance-gates.md` (the checkable-literal guards), the atomic-plan-contract skill and the plan validators push plans toward exact literals, line numbers and SHAs. Each literal is a preflight failure point and goes stale when main moves.
2. **No shared execution-environment brief.** Hook constraints, the tool route, the batch budget, CI shape (Linux suites, PoshQC shards, required-check contexts, merge_group), contract tests, evidence and docs-validation rules are rediscovered by every plan.
3. **Ping-pong between cold-start agents.** Preflight reports a subset of defects, and trivial plan defects go back to a new planner instead of being fixed in place.
4. **No pre-mortem.** Research and planning do not systematically anticipate review checklists, per-file coverage, mirror parity, the 500-line limit, test isolation (seeded shuffle), CI-only behavior or evidence completeness. So review finds them later.
5. **Heavyweight remediation.** A one-line fix goes through the full plan/preflight/execute/review pipeline.


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

- [x] **Execution-environment brief.** A single maintained document, read first by task-researcher, atomic-planner and atomic-executor. It lists hook constraints, the tool route, the batch budget, CI shape, contract tests, and evidence/docs rules. Mirror it to the bundled, .github and .codex surfaces.
- [x] **Design-level plan contract.**
  - Tasks name files, symbols, behavior, tests and acceptance.
  - No line numbers or commit SHAs; anchor on symbols or headings.
  - Literals only where they are the actual assertion.
  - A plan size guideline, with a justification required above it.
  - Update `plan-acceptance-gates.md`, the plan validators (the G1 to G9 gates) and the planner hooks consistently.
- [x] **Single-pass preflight.**
  - Report every defect in one pass.
  - Classify each as trivial or substantive. The executor fixes trivial defects (stale anchors, citations, typos) in place and records them; only substantive defects return to the planner.
  - At most one return.
- [x] **Mandatory pre-mortem.** Research and plan carry a pre-mortem section covering the review checklists, coverage, parity, size limits, isolation/shuffle, CI-only behavior and evidence. Before the first review push, the executor or orchestrator runs a self-review with the feature-review checklists.
- [x] **Proportionate remediation.** A remediation that fixes review findings runs as one executor pass with pre-mortem and self-review, without a multi-round preflight loop, unless it changes the design.
- [x] **Validation.**
  - Tests for the updated validators and hooks.
  - Re-run the planner on one historical item, for example #962's spec, and show a plan that is a fraction of the size and clears preflight in one round.

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
