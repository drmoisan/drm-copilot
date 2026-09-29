# 2026-09-29-orchestrator-remediation-loop-control (Spec)

- **Issue:** #484
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T17-35
- **Status:** Draft
- **Version:** 0.1

## Context
The orchestration state machine treats every non-PASS review as actionable remediation, including external runtime incompatibilities and unavailable coverage metrics. This causes unnecessary remediation plans, commits, re-reviews, inconsistent cycle numbering, and cycle consumption when no corrective candidate was applied.

Environment:
- OS/version: Windows 11 / PowerShell workspace
- Python version: 3.13.12 through Poetry
- Node/npm version: Node 24.14.0 / npm 11.9.0
- Command/flags used: Codex `orchestrate` workflow with authoritative MCP orchestration validation
- Data source or fixture: issue #467 checkpoint, review artifacts, published `@danmoisan/drm-copilot-mcp@1.0.24`, and repository-local validators

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run a feature review that returns a blocker which cannot be changed by repository remediation, such as an immutable MCP runtime mismatch or unavailable source-attributable coverage metric.
2. Observe that the reviewer can return only `PASS` or `REMEDIATION_REQUIRED` and that the orchestrator unconditionally enters R1-R5 for `REMEDIATION_REQUIRED`.
3. Let remediation execution return an external/runtime failure with no candidate applied and the checkpoint restored byte-for-byte.
4. Observe that the outer workflow still stages evidence, commits, re-reviews, increments the pass counter, and consumes a remediation cycle.
5. Compare repository-local and published MCP routing inventories when a new Codex agent family was added after the package version was published.

Expected:
The reviewer classifies whether a blocking condition is autonomously remediable. External runtime mismatches, policy decisions, awaiting-CI states, and human-decision requirements halt or wait without creating a remediation plan or consuming a remediation cycle. Cycle accounting counts completed remediation attempts consistently, and runtime capability/version incompatibility is detected before execution.

Actual:
The binary review contract forced every blocker into remediation. The pass counter alternated between current and completed semantics, an unexecuted pass occupied a number, and pass 7 was consumed after `PRE_R5_STATUS: ACTIVE_RUNTIME_INCOMPATIBILITY` with `candidate_applied: false`. The published MCP 1.0.24 validator rejected valid repository `commit-steward` routing receipts, while an unrelated legacy routing gate also generated missing-receipt diagnostics.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: issue #467 records seven audit rounds, six completed remediation re-reviews, eight execution/resume delegations, one unexecuted numbered pass, and no pass 8. The final candidate passed the repository validator but could not change the immutable published MCP resolver.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The review contract in `.agents/skills/` and `.claude/skills/orchestrate/SKILL.md` (`## Post-Review Outcome Evaluation`, `## Remediation Loop (R1–R5)`) defines only a binary outcome and increments `remediation_pass` unconditionally at R5.


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

- [ ] Unit coverage areas: verdict-class validation and cycle-accounting invariants in all three validator runtimes, with shared parity fixtures.
- [ ] Integration scenario to retest: a checkpoint recording a non-remediable halt validates without a remediation cycle entry.
- [ ] Manual verification notes: none.

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
