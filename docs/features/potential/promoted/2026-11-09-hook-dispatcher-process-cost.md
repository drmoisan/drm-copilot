# Hook process cost: one dispatcher per tool call (Issue #1159)

- Date captured: 2026-11-09
- Author: Dan Moisan (owner request), captured by Claude
- Status: Promoted -> docs/features/active/Hook_process_cost_one_dispatcher_per_tool_call/ (Issue #1159)

- Issue: #1159
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1159
- Last Updated: 2026-11-09
## Problem / Why

Every Bash tool call starts 12-15 separate PowerShell hook processes, each using roughly a third to half of a core for about a second. With about ten agents active, hook start-up alone kept machine load high even when no tests were running.

## Proposed Behavior

- Measure per-tool-call hook cost: process count, CPU seconds, wall time.
- Consolidate the PreToolUse hooks for each tool into a single dispatcher process per call that loads the shared modules once and evaluates every check in it; alternatively move cheap pattern checks into a lightweight front filter that starts PowerShell only when a check needs it.
- Keep each hook's decision logic and deny codes unchanged, with a parity suite showing identical decisions before and after.

## Acceptance Criteria (early draft)

- [ ] A repeatable measurement of per-tool-call hook cost (process count, CPU seconds, wall time) exists and is run before and after.
- [ ] PreToolUse hooks per tool run in one dispatcher process (or behind a front filter) that loads shared modules once.
- [ ] Each hook's decision logic and deny codes are unchanged, proven by a parity test suite comparing decisions before and after across the existing hook test corpus.
- [ ] The PR reports before and after cost.
- [ ] settings.json hook registration, hook documentation, and the push-down payload are updated consistently.

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
