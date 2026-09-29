# 2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding (Spec)

- **Issue:** #543
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T16-06
- **Status:** Draft
- **Version:** 0.1

## Context
`scripts/dev_tools/validate_epic_planner_state.py` carries the same structural defect that issue #524 fixes on the epic-orchestrator side, one layer up: under `require_ready_for_execution` it demands Codex-only launch evidence that no Claude-runtime producer ever writes, so the gate cannot pass on the Claude runtime. The defect is latent because no Claude surface passes that flag today.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `validate_epic_planner_state_text(text, require_ready_for_execution=True)`, reachable via the `epic-planner-state` artifact type with `--require-ready-for-execution`
- Data source or fixture: any Claude-prepared epic planner checkpoint at `artifacts/orchestration/epic-planner-state.json`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Latent today. A repository-wide search across `.claude/**` for `require_ready_for_execution` returns matches only for the parallel planner (`validate_parallel_planner_state.py`, documented in `.claude/rules/parallel-orchestration.md` and `.claude/skills/parallel-plan/SKILL.md`). No Claude surface passes the flag for the `epic-planner-state` artifact type, so the gate never runs on the Claude runtime. It becomes live the moment any Claude skill, agent, hook, or MCP call starts passing it.


## Repro & Evidence
Steps to Reproduce:
1. Prepare an epic on the Claude runtime so that `artifacts/orchestration/epic-planner-state.json` records a fully prepared feature set.
2. Validate that checkpoint with `require_ready_for_execution=True`.
3. Observe launch-binding errors for every feature, none of which any Claude agent can satisfy.

Expected:
The ready gate validates the structural readiness properties it owns, and requires per-feature launch evidence only when the caller is asserting a Codex enforcement flag or when the feature actually carries launch path keys — matching the correction landed for the epic-orchestrator gate in #524.

Actual:
Inside the `require_ready_for_execution` block (`validate_epic_planner_state.py:320`), the call at line 331 is unconditional:

```python
    if require_ready_for_execution:
        ...
        errors.extend(validate_epic_planner_child_launch_bindings(features))
```

`validate_epic_planner_child_launch_bindings` calls `_validate_launch_bindings` with `skip_not_started=False` and `require_generated_orchestrator=True`, which produces two independent failures:

1. Every feature must carry `launch_receipt_path` and `launch_status_path` under `artifacts/orchestration/epic-child-launches/`. The sole production writer of that evidence is `.codex/scripts/launch-epic-child-wave.ps1` on the Codex runtime; the Claude runtime has no producer. This is the identical unsatisfiable-gate shape recorded in #524.
2. `require_generated_orchestrator=True` restricts `delegation_receipt.agent_name` to the five Codex-generated persona names `orchestrator-c1`, `orchestrator-c2`, `orchestrator-c3`, `orchestrator-c3-elevated`, and `orchestrator-c4` (`_GENERATED_ORCHESTRATOR_AGENTS`). None exists in the Claude runtime, which delegates preparation to the single `orchestrator` agent. Even a checkpoint that somehow carried launch paths would still fail this check.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: the error family is the same one #524 reproduced against the orchestrator gate, of the form `Epic planner checkpoint features[N] launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.`


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The planner gate was authored against the Codex runtime, where the launcher writes the evidence and the generated orchestrator personas exist. The generic readiness flag was then admitted into an activation set that is Codex-specific in practice — the same category of error as #524, where the generic `require_complete` flag was admitted into a Codex-specific activation set.

Files to inspect:

- `scripts/dev_tools/validate_epic_planner_state.py` (lines 320-332)
- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` (`validate_epic_planner_child_launch_bindings`, `_GENERATED_ORCHESTRATOR_AGENTS`)
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (the parity twin, governed by a TypeScript/Python parity test)


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

- [x] Unit coverage areas: `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` and its Jest twin
- [x] Integration scenario to retest: validate a Claude-prepared epic planner checkpoint with `require_ready_for_execution=True` and confirm zero launch-binding errors, while a Codex-shaped checkpoint keeps its existing behaviour
- [x] Manual verification notes: the `require_launch_paths` keyword added to `_validate_launch_bindings` by #524 already provides the seam. `validate_epic_planner_child_launch_bindings` currently passes `require_launch_paths=False` explicitly, so the planner path was left unchanged by that fix and this issue decides its final behaviour.

Separately, decide whether `require_generated_orchestrator=True` should remain unconditional or become Codex-flag-scoped. That is a policy question about whether the epic planner surface is Codex-only by design, and it should be answered explicitly rather than inherited.

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
