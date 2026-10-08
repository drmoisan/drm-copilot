# 2026-09-27-exempt-operand-bypass-brace-and-dot-segments (Spec)

- **Issue:** #732
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T13-53
- **Status:** Draft
- **Version:** 0.1

## Context
The preimplementation gate's exempt-path check (`Test-ExemptOrchestrationOperand` in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its three byte-identical copies) can be bypassed. Two confirmed operand shapes resolve outside the exempt `docs/features/active/` tree but are treated as exempt.

Environment:
- OS/version: any
- Python version: n/a (PowerShell hooks, Claude and Codex surfaces)
- Command/flags used: a staging or implementation command whose operand uses brace expansion or `.\.` segments
- Data source or fixture: none

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

An enforcement bypass. Both predate the PRs that found them.


## Repro & Evidence
Steps to Reproduce:
1. Brace expansion (CR-2, found in the #713 review): an operand `docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts` expands in the shell to a path outside the exempt tree, but the gate evaluates the literal string as exempt.
2. Dot segments (#710 decision D7, `evidence/other/follow-up-d7-operand-gap.md`): `docs/features/active/.\./.\./.\./src/x.ps1` is still exempt.

Expected:
An operand is exempt only when its fully resolved path, after shell expansion and normalisation, lies inside the exempt tree. Otherwise it fails closed.

Actual:
Both shapes are treated as exempt, so a production-file change can bypass the preimplementation readiness gate.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: #713 `code-review.2026-09-27T06-40.md` CR-2; #710 `evidence/other/follow-up-d7-operand-gap.md`.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The operand check prefix-matches the raw string. It does not reject shell-expansion metacharacters (`{`, `}`, `*`, `?`, `[`) and does not normalise `.`/`..` segments, including the mixed `.\.` form.


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

- [ ] Unit coverage areas: fail closed on any operand containing brace, glob or bracket metacharacters. Normalise `/` and `\`, collapse `.` and `..`, then require that the normalised path stays under the exempt root. Add Pester deny cases for both shapes and allow cases for ordinary exempt paths. Keep the four copies byte-identical and within the 500-line cap.
- [ ] Integration scenario to retest: the documented exempt workflows (feature docs, checkpoint writes) still pass.
- [ ] Manual verification notes: grep the other gates for the same prefix-match idiom.

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
