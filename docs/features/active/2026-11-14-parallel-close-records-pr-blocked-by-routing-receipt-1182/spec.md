# 2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt (Spec)

- **Issue:** #1182
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14T05-32
- **Status:** Draft
- **Version:** 0.1

## Context
At Run Closing, the parallel-orchestrator cannot open the run-records pull request. Its `Agent(pr-author)` delegation is denied by `enforce-model-routing-receipt.ps1` with `MODEL_ROUTING_RECEIPT_BLOCKED`. The receipt check reads the orchestrator checkpoint of the resolved worktree. The coordinator root of a parallel run deliberately holds only `parallel-orchestrator-state.json` and no `orchestrator-state.json`, so the receipt can never be found. The `parallel-orchestrator` agent definition authorizes `Agent(pr-author)` for exactly this Run Closing records PR, so the documented path cannot be completed.

Environment:
- OS/version: Windows 11 (local), Claude Code runtime
- Python version: not applicable
- Command/flags used: parallel-orchestrator Run Closing: `Agent(pr-author)` with the branch label `parallel/<slug>-plan`
- Data source or fixture: run harness-learnings-2026-11-09, coordinator branch `parallel/harness-learnings-2026-11-09-plan` (head c295f89d1), closing state recorded as deferral LV3

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run a parallel run to completion, so that every item is merged.
2. At Run Closing, delegate `Agent(pr-author)` from the parallel-orchestrator for the records PR of the `parallel/<slug>-plan` branch.
3. Observe the denial: `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint`.

Expected:
The Run Closing records PR is delegable. The model-routing receipt gate looks up the receipt in the parallel checkpoint, in the same way that epic scope (issue #663) looks it up in the epic checkpoint. Alternatively, a narrowly scoped leg, matching the cleanup-consolidation leg (#1026) and the docs-estate leg (#1169), admits the records PR when the branch label equals the parallel run's plan branch and the diff is limited to `docs/features/parallel/<slug>/`.

Actual:
The delegation is denied, and the run ends with its records unmerged on the coordinator branch. The post-merge worktree cleanup report is also deferred, because it runs only after the records PR merges.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating.`


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The receipt gate in `.claude/hooks/enforce-model-routing-receipt.ps1` has an epic-scope branch (`Resolve-EpicScopeCheckpoint`), a cleanup leg (`Test-ModelRoutingCleanupDelegation`) and a docs-estate leg (`Get-ModelRoutingDocsEstateDecision`), but no parallel-scope branch. The `pr-author` preflight hook (`enforce-pr-author-skill.ps1`) and the merge gate may have the same gap for the records PR; check them together. Mirrors: the Codex hooks and the push-down bundles.


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

- [ ] Add a parallel-scope resolution: a prompt whose branch label equals the `parallel/<slug>-plan` branch of the session-root `parallel-orchestrator-state.json` reads `model_routing_receipts` from that checkpoint; the parallel-orchestrator records a pr-author receipt there at Run Closing
- [ ] Verify that the pr-author preflight and the records-PR merge path work end to end for the same scope
- [ ] Pester coverage for allow and deny, including a non-plan branch label, a missing receipt, and an epic label unaffected
- [ ] After merge, open the pending records PR for harness-learnings-2026-11-09 through the fixed path

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
