# orchestration-test-cadence-targeted-per-task (Spec)

- **Issue:** #1167
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-11T19-25
- **Status:** Draft
- **Version:** 0.1

## Context
The harness text reads as a full toolchain run (including the whole unit suite) after every atomic-plan task. The owner rule is: "The rule for an orchestration is a full test after every phase and only targeted tests after every task". The executor should run targeted checks per task and the full toolchain loop only at each phase gate and in the final QA loop.

Environment:
- OS/version: Windows 11 host and Linux CI; any destination repository that receives the push-down
- Python version: 3.13
- Command/flags used: `/orchestrate` and `/execute-hard-lock` atomic execution
- Data source or fixture: downstream repository iar-migration, issue #145, 2026-11-11 (about 10,400 unit tests)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run an orchestration whose atomic plan has many tasks in a repository with a large unit suite.
2. Observe the atomic executor follow the per-task toolchain loop wording (for example R3 in `.claude/skills/orchestrate/SKILL.md`, "Mandatory Toolchain Loop" in `.claude/rules/general-code-change.md`).
3. Observe the full unit suite run after every task.

Expected:
After each task: format, lint, and type check scoped to the changed files, plus only the tests that cover the changed modules (mirrored test paths under `tests/` and tests that import the changed modules), with the selection recorded in the task evidence. At each phase gate: the full toolchain loop, restarting from step 1 on a failure or auto-fix. Final QA loop unchanged. The cadence is defined once (likely in the `atomic-plan-contract` skill) and referenced from every other surface.

Actual:
Executors run the full unit suite after each task. Downstream observation: about 10 tasks per hour across a 68-task plan, with most task time spent in the full suite, and a second orchestration on the same machine queued behind each run under the single-suite rule.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: R3: "Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping."


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Surfaces to inspect: `.claude/skills/orchestrate/SKILL.md` (R3 and executor delegation guidance), `.claude/rules/general-code-change.md`, `.claude/skills/atomic-plan-contract/SKILL.md` (Final QA Loop, Pre-Mortem "Test isolation" bullet, per-task test gate wording), the atomic-executor agent, the execute-hard-lock and atomic-plan prompt templates, the execution-environment brief (six copies), the language rules and QA-gate skills, and the Copilot (`.github/`), Codex (`.codex/`, `.agents/`), and push-down (`extensions/drm-copilot/resources/`) mirrors. Any plan validator that requires a full-suite command in every task.


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

- [ ] Unit coverage areas: a Pester test pinning the canonical cadence wording, and a sweep test that fails when any harness surface prescribes a full-suite run per task; parity tests for every mirror.
- [ ] Integration scenario to retest: plan validator accepts targeted per-task test commands and requires a full-toolchain gate task at the end of every phase.
- [ ] Manual verification notes: coverage rules, Phase 0 baseline comparison, the no-SKIPPED rule, the final QA loop, and the single-suite pseudo-queue rule are unchanged. Destinations receive the change after the extension rebuild and push-down.

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
