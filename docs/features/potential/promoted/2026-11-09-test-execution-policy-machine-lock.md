# Test-execution policy: no local integration or golden suites, one suite at a time (Issue #1158)

- Date captured: 2026-11-09
- Author: Dan Moisan (owner request), captured by Claude
- Status: Promoted -> docs/features/active/Test-execution_policy_no_local_integration_or_golden_suites_one_suite_at_a_time/ (Issue #1158)

- Issue: #1158
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1158
- Last Updated: 2026-11-09
## Problem / Why

- Several features ran full test suites at the same time on one machine, each with one worker per core, each including the slow integration and golden (snapshot or baseline) suites under coverage.
- Machine load reached about 4-5x the core count; individual suite runs took over 100 minutes, where the same suite alone takes a few minutes.
- Agents also ran suites through scratch wrapper scripts, which hid them from process-based checks.

## Proposed Behavior

- Configurable test-execution policy read by the skills and gates, with harness defaults:
  - Local runs exclude the integration lane and the golden or baseline lane (marker or command names configurable per repository). Those lanes are CI-only evidence.
  - At most one test suite runs on a machine at a time, using a machine-wide lock (an OS advisory lock outside every worktree). A queued suite waits up to a bounded time below the tool-call timeout, then exits with a documented retry code that names the lock holder. The parallel worker count of the running suite is not reduced.
  - Suites run under a recognizable test command line (no hidden wrapper scripts).
- Plans cite CI integration and golden lanes as evidence, record a non-blocking deviation when a step would run them locally, and follow the queue.
- A gate or hook denies starting a local integration, golden, or second concurrent suite, with a message naming the policy.

## Acceptance Criteria (early draft)

- [ ] Test-execution policy configuration is documented and validated; defaults exclude integration and golden lanes locally and enforce one suite per machine (defaults change by design for this workstream).
- [ ] A machine-wide advisory lock outside every worktree serializes suites; a queued suite waits a bounded time below the tool-call timeout, then exits with a documented retry code naming the holder; the running suite's worker count is not reduced.
- [ ] Pure lock-decision and lane-classification logic has unit tests with injected clock and process seams (no real waits, no temp files).
- [ ] A gate or hook denies a local integration, golden, or second concurrent suite, and denies hidden wrapper-script suite launches, with a message naming the policy.
- [ ] execution-environment, atomic-plan-contract, python-qa-gate, invoke-python-engineer and the equivalent skills for other languages are updated (CI lanes as evidence, non-blocking deviation record, queue).

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
