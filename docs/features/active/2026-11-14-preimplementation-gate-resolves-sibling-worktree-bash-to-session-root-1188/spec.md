# 2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root (Spec)

- **Issue:** #1188
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14T13-12
- **Status:** Draft
- **Version:** 0.1

## Context
In the sibling-worktree topology (a non-isolated agent working in an item worktree under `.claude/worktrees/`), the preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`) resolves some Bash commands to the session root instead of the item worktree. The session root has no orchestrator checkpoint, so the gate denies with `PREIMPLEMENTATION_GATE_BLOCKED`. The #1158 executor could run its pytest gate only through scratch `sh` scripts. The same gate also resolves commands that carry the worktree path only in a shell variable (`git -C $W ...`) to the session root.

Environment:
- OS/version: Windows 11, Claude Code runtime, PowerShell 7
- Python version: not applicable
- Command/flags used: a direct test-runner command from a sibling item worktree, for example `env -u VIRTUAL_ENV poetry -C <abs worktree> run pytest <abs test path>`
- Data source or fixture: reported by the #1158 run (PR #1184 body, ORCH-D8)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. In a session whose root has no orchestrator checkpoint, work in a sibling item worktree that has a ready checkpoint.
2. Run the item's test gate with a direct command that names the worktree through `poetry -C <abs>` (or `git -C <abs>`) and absolute test paths.
3. Observe `PREIMPLEMENTATION_GATE_BLOCKED` naming the missing checkpoint, although the named worktree's checkpoint is ready.

Expected:
The gate resolves the target worktree from the command operands it already supports (`git -C`, `poetry -C`/`--directory`, `npm --prefix`, absolute paths) for every command family it gates, and allows the command when that worktree's checkpoint is ready. Unresolvable commands keep failing closed.

Actual:
Direct commands are denied, and agents fall back to scratch `sh` scripts, which hide the command from every text-based hook. That weakens enforcement rather than strengthening it.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: see PR #1184, `## Decisions` (ORCH-D8) and `## Follow-ups`.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The resolver (`Resolve-HookTargetWorktree` / the CommandOperand source) likely recognises the worktree operand only for some command shapes, so other shapes fall back to the payload cwd, which is the session root. Shell-variable operands cannot be resolved from text and are expected to fail closed; the brief already tells agents to write paths literally.


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

- [ ] Extend operand resolution to every command family the gate gates (poetry -C/--directory, npm --prefix, absolute script and test paths) with byte-identical behaviour in the Codex mirror
- [ ] Pester rows: each operand form resolving to a ready sibling worktree is allowed; the same form naming a not-ready worktree is denied; a shell-variable operand still denies
- [ ] Re-check the execution-environment brief text on sibling-worktree command shapes

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
