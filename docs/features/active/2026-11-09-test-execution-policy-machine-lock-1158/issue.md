# Feature: Test-execution policy: no local integration or golden suites, one suite at a time

- Issue: #1158
- URL: https://github.com/drmoisan/drm-copilot/issues/1158
- Work Mode: full-feature
- Source: GitHub issue #1158 body, read with gh issue view on 2026-11-09 (the issue was filed before orchestration; the potential file it names was not present in the tree at branch creation).

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

## Acceptance Criteria
- [ ] Test-execution policy configuration is documented and validated; defaults exclude integration and golden lanes locally and enforce one suite per machine (defaults change by design for this workstream).
- [ ] A machine-wide advisory lock outside every worktree serializes suites; a queued suite waits a bounded time below the tool-call timeout, then exits with a documented retry code naming the holder; the running suite's worker count is not reduced.
- [ ] Pure lock-decision and lane-classification logic has unit tests with injected clock and process seams (no real waits, no temp files).
- [ ] A gate or hook denies a local integration, golden, or second concurrent suite, and denies hidden wrapper-script suite launches, with a message naming the policy.
- [ ] execution-environment, atomic-plan-contract, python-qa-gate, invoke-python-engineer and the equivalent skills for other languages are updated (CI lanes as evidence, non-blocking deviation record, queue).

## Constraints & Risks
(not provided in potential file)

## Test Conditions
(not provided in potential file)

## Source
From: docs/features/potential/2026-11-09-test-execution-policy-machine-lock.md
