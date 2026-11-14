# Pre-implementation gate false positives (Issue #1160)

- Date captured: 2026-11-09
- Author: Dan Moisan (owner request), captured by Claude
- Status: Promoted -> docs/features/active/Pre-implementation_gate_false_positives/ (Issue #1160)

- Issue: #1160
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1160
- Last Updated: 2026-11-09
## Problem / Why

- The gate blocks `git add` and `git commit` in a coordinator checkout that holds no orchestrator checkpoint, even for agent-memory files, forcing commits through git plumbing commands.
- It classifies commands by keyword: the bare word for the test runner inside a process listing or a grep pattern triggers it.

## Proposed Behavior

- Parse the command into invocations (reuse the harness's existing token-aware matchers) and classify only real test-runner or staging invocations.
- Exempt staging and committing paths limited to the agent-memory tree and other declared bookkeeping paths, alongside the existing orchestration-bookkeeping exemption.

## Acceptance Criteria (early draft)

- [ ] The gate classifies only real test-runner or staging invocations using the existing token-aware matchers; the test-runner word inside a process listing or grep pattern no longer triggers it.
- [ ] Staging and committing limited to the agent-memory tree and declared bookkeeping paths is exempt, alongside the existing orchestration-bookkeeping exemption; the declared paths are configurable with a safe default.
- [ ] Regression tests cover both false positives and every existing denial.

## General Constraints (all harness-learnings workstreams)

- Keep pure logic (calculations, classification, scheduling, parsing) in host-neutral modules with unit tests; keep I/O (git, gh, filesystem, process inspection) in thin adapters.
- Inject clocks, randomness, filesystem and process seams; no temporary files and no wall-clock waits in tests.
- Every new configuration knob has a safe default that preserves today's behavior unless this entry states otherwise.
- Update the skill and agent documentation that describes each changed behavior, and keep the push-down payload consistent with it.
- New pushed-down code (skills, hooks, libs) is PowerShell or bash; TypeScript only for MCP or extension commands; no new Python.
- Existing gate decisions are unchanged except where this entry explicitly changes them, shown by parity or regression tests.
- New configuration keys are documented, validated, and default to today's behavior.
- The push-down payload carries every changed skill, agent, hook, and script.
- Delivered as its own issue and PR with unit tests for the pure logic, updated skill and agent documentation, and fully green CI.

## Source

Owner request of 2026-11-09: observations from a multi-feature epic with five features running in parallel on one shared development machine.
