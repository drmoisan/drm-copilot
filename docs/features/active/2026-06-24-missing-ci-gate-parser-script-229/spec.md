# missing-ci-gate-parser-script (Spec)

- **Issue:** #229
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T17-34
- **Status:** Draft
- **Version:** 0.1

## Context
The orchestrate skill's Step S9 (CI Green Gate) instructs the orchestrator to parse `gh pr checks` JSON via `scripts/orchestration/Invoke-CiGateParser.ps1`, but that script does not exist in the repository. The S9 contract cannot be executed as written.

Environment:
- OS/version: Windows (Git Bash), repository runtime
- Python version: N/A (PowerShell/orchestration tooling)
- Command/flags used: orchestration S9 CI Green Gate per `.claude/skills/orchestrate/SKILL.md`
- Data source or fixture: `gh pr checks --required --json bucket,name,state,link,workflow`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The orchestrator can derive the CI conclusion directly from the `gh` JSON, so orchestration is not fully blocked, but the documented S9 contract is unexecutable and the parser provides the single source of truth for `ci_gate` derivation.


## Repro & Evidence
Steps to Reproduce:
1. Run an orchestration to the S9 CI Green Gate step.
2. Follow the documented S9 procedure, which calls `scripts/orchestration/Invoke-CiGateParser.ps1` to emit the `ci_gate` object.
3. Attempt to invoke the script.

Expected:
`scripts/orchestration/Invoke-CiGateParser.ps1` exists and parses the `gh pr checks` JSON into the documented `ci_gate` object, deriving `ci_gate.conclusion` as `success` / `failure` / `pending`.

Actual:
The script is absent (`scripts/orchestration/` does not exist). The orchestrator must derive `ci_gate.conclusion` directly from the `gh pr checks` JSON to complete S9, deviating from the documented contract.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `find . -name "Invoke-CiGateParser.ps1"` returns no results; `ls scripts/orchestration/` reports the directory does not exist.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The orchestrate skill references a parser script that was specified but never added to the repository, or was removed without updating the skill text. Files to inspect: `.claude/skills/orchestrate/SKILL.md` (Step S9 section), and the absent `scripts/orchestration/` directory.


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

- [ ] Add `scripts/orchestration/Invoke-CiGateParser.ps1` that consumes `gh pr checks --json` output and emits the documented `ci_gate` object with a derived `conclusion`.
- [ ] Unit coverage: success / failure / pending derivation cases; malformed-JSON handling.
- [ ] Integration scenario to retest: run S9 against a live PR and confirm the parser emits the `ci_gate` object consumed by the checkpoint.
- [ ] Alternative: if the parser is intentionally not provided, update the orchestrate skill to document direct JSON derivation as the contract.

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
