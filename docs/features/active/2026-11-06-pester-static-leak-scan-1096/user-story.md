# `pester-static-leak-scan` — User Story

- Issue: #1096
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-07T02-06

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

Split from issue #1094 by owner decision on 2026-11-07. #1094 keeps the parallel-only test gate change, so that it can merge first. This item carries the static leak scan and the test fixes.

With parallel-only gates, the repository no longer runs the single-process and shuffled runs that detected state leaking between test files. Test independence remains policy under `.claude/rules/general-unit-test.md`. Files in the same shard still share a process, so a leak can surface later as a failure when shard contents change. Detection needs to move to a scan that adds no test run.

A text search of the 509 Pester files in `tests/scripts` gives the candidate scale. These are candidates, not confirmed leaks: 30 files write `$env:`, 45 write `$global:`, 2 define global functions, 16 change location, and 2 change the process directory.

Two tests in `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` fail in single-process runs, including at merge base `e3e4aa551`. That file is one of the two that change the process directory. `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` fails when the process does not start at the repository root.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] The scan detects each listed state-change kind, and does not report a change that is restored in the same scope or in `AfterEach`, `AfterAll`, or `finally`.
- [ ] The scan runs in CI and fails on an unallowlisted finding.
- [ ] Every finding in `tests/scripts` is fixed or allowlisted with a reason.
- [ ] The two `Enter-DrmCopilotShell.Tests.ps1` tests and the `PoshQC.TestingInvokeConfigPaths.Tests.ps1` test no longer depend on the process directory.
- [ ] `## Test Isolation Checks` in the `execution-environment` skill names the scan, and all mirrored copies match.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.


## Non-Goals

Call out what is explicitly excluded from this feature.
