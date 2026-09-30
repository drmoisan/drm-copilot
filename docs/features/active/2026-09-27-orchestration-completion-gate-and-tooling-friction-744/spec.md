# 2026-09-27-orchestration-completion-gate-and-tooling-friction (Spec)

- **Issue:** #744
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-30T03-18
- **Status:** Draft
- **Version:** 0.1

## Context
Friction points in the orchestration tooling recurred across the three parallel runs of 2026-09-25 to 27. Each one cost a remediation or relay step. Consolidated here for one pass.

Environment:
- OS/version: Windows 11, Claude Code
- Python version: repo default
- Command/flags used: `validate_orchestration_artifacts.py`, the MCP tools, and the parallel-orchestrator merge gate
- Data source or fixture: the followups-2026-09-27 completion report; coordinator observations

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. The completion check requires `ci_gate.verified_at`, which the orchestration skill never mentions (#709).
2. The strict completion check demands promotion receipts from items taken in by issue number, which were never promoted in-run (#710).
3. CI-dependent AC check-offs pushed after the parent's merge never reach main. #710's AC-8 commit `81726a3b` was stranded, and the parent cannot commit from the coordinator root. Mitigated in-prompt ("the child owns CI-dependent check-offs and pushes them before reporting done"); not yet codified in the skill.
4. The MCP `run_poshqc_test` tool overwrites the coverage file using the INSTALLED extension's settings, so newly registered files drop out; it takes no settings argument (#707 CR-3).
5. The `feature-review` agent has no MCP artifact validator (#714).
6. `collect_pr_context` pairs a file's last command with its first expected exit code, so intentional fail-before evidence is labelled "fail" (#708). It also listed `#AC-1`..`#AC-4` as auto-close issues (#706 FU-706-8). The installed extension may predate #622's fix; verify after a rebuild.
7. Local and CI coverage report different missed-line counts (1114 vs 1129), not investigated (#712).
8. The batch-budget hook needs a reset between batches (#709 CR-9).
9. Evidence timestamps run 4-18 minutes later than the commits that contain them (#706 FU-706-6).

Expected:
Documented, validator-consistent completion requirements; tools that respect the repository's own configuration; evidence labelled correctly.

Actual:
As above.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: the followups-2026-09-27 parallel-orchestrator completion report; `.claude/agent-memory/parallel-orchestrator/` notes.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Validator requirements drifted ahead of the skill documentation. Related memory notes: orchestrator-checkpoint-completion-gate-gotchas and mcp-poshqc-test-reads-installed-extension-settings.


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

- [ ] Unit coverage areas: document `ci_gate.verified_at` and the receipt requirements in the skills, or relax them for issue-intake items; codify child ownership of CI-dependent check-offs in the parallel-orchestrate and orchestrate skills; add a settings argument to `run_poshqc_test` (or read the repository config); add a feature-review validator; fix the exit-code pairing in `collect_pr_context`; after an extension rebuild, verify the `#AC-n` behaviour.
- [ ] Integration scenario to retest: a parallel item completes with no relay-only steps.
- [ ] Manual verification notes: may split into several PRs.

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
