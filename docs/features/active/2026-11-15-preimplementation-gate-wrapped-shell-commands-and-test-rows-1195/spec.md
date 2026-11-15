# 2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows (Spec)

- **Issue:** #1195
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-15T17-03
- **Status:** Draft
- **Version:** 0.1

## Context
Two gaps remain in the preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and its Codex mirror) after #1188:

1. Test or lint commands wrapped in `sh -c "..."` or `pwsh -Command "..."` are not classified by the gate at all. This is present on `main`, and it belongs to the #1160 second-stage classification design.
2. #1188's final review finding R3 was accepted as a non-blocking deviation at its remediation loop limit. Six regression test rows are missing for the cycle-3 checks (commands that start with an assignment, such as `FOO=$(pwd) npm ...`). The behaviour is correct, but four regression paths would not fail any test.

Environment:
- OS/version: Windows 11 and Linux CI, Claude Code and Codex runtimes
- Python version: not applicable
- Command/flags used: `sh -c "poetry run pytest ..."`, `pwsh -Command "Invoke-Pester ..."`, and the assignment-prefixed forms from #1188 cycle 3
- Data source or fixture: #1188 (PR #1191) remediation-inputs record for R3, and the #1188 orchestrator summary

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. From a worktree with no ready checkpoint, run a test command wrapped as `sh -c "<test command>"`.
2. Observe that the gate allows it without classifying the inner command.
3. For R3, remove one of the cycle-3 assignment-prefix checks and observe that no existing test fails.

Expected:
The gate classifies the inner command of a `sh -c` or `pwsh -Command` wrapper in the same way as the bare command. This stays at the policy-level standard (#1160 OD-1: deliberately obfuscated commands are out of scope). Each cycle-3 check also has a test row that fails when the check is removed.

Actual:
Wrapped commands pass unclassified, and the cycle-3 checks have no regression rows.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: see the #1188 feature folder `remediation-inputs.2026-11-15T21-47.md` (R3) and PR #1191 (DEV-R3).


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The second-stage classifier from #1160 inspects top-level command segments only. Wrapper payloads are opaque strings. Keep the #1160 policy-level standard: a quoted payload is parsed only for the literal, unobfuscated forms. The Codex gate is at its 500-line limit, so new logic goes into a sibling file.


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

- [ ] Classify the literal `sh -c "<payload>"`, `bash -c`, and `pwsh -Command "<payload>"` / `-c` payloads with the existing stage-two rules, in both the Claude and Codex gates, plus the bundles
- [ ] Add the six missing R3 regression rows; each one must fail when its check is removed
- [ ] Pester rows for wrapped test, lint and allowed commands, including the obfuscated forms that stay out of scope

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
