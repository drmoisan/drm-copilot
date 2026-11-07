# `parallel-only-test-gates-and-leak-scan` — User Story

- Issue: #1094
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-06T20-01

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The repository requires each item to run its test suites several times, in both serial and parallel form. `## Test Isolation Checks` in the `execution-environment` skill requires a fresh single-process Pester run over `tests/scripts`, a concurrent-shard Pester run, seeded shuffled runs of the touched Pester suites, a reversed-order run of changed Python modules, a seeded shuffled Jest run, and a `pytest -n auto` run in addition to the serial runs.

The owner's decision, recorded 2026-11-06: tests run in parallel only. The sequential run existed to detect and fix a leak that has since been fixed, and the overhead of multiple runs and sequential runs is unacceptable.

Measured during Epic #1019:

- An 8-shard `Invoke-PoshQCParallelTest` run took 448 s.
- Single-process runs over `tests/scripts` took between 899 s and 1,504 s, and one item ran several of them in a single cycle.
- CI repeats the suite on every PR as 3 shards, so the local single-process run does not match CI. Line 158 of the skill still calls it "the CI shape", while line 148 of the same skill describes sharded CI.

Test independence remains policy under `.claude/rules/general-unit-test.md`. Removing the repeated runs removes the current means of detecting leaks, so detection needs to move to a scan that adds no test run. No shuffle step exists in the workflow files under `.github/workflows`.

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

- [ ] No skill, agent, rule, or preflight text in the repository requires a serial, single-process, seeded-shuffle, or reversed-order validation run.
- [ ] `## Test Isolation Checks` states the parallel gates and the leak scan, and all mirrored copies match.
- [ ] The contract tests pass against the new wording and fail if the removed requirements are reintroduced.
- [ ] The scan detects each listed state-change kind, and does not report a change that is restored in the same scope or in `AfterEach`, `AfterAll`, or `finally`.
- [ ] The scan runs in CI and fails on an unallowlisted finding.
- [ ] Every finding in `tests/scripts` is fixed or allowlisted with a reason.
- [ ] The two `Enter-DrmCopilotShell.Tests.ps1` tests and the `PoshQC.TestingInvokeConfigPaths.Tests.ps1` test no longer depend on the process directory.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.


## Non-Goals

Call out what is explicitly excluded from this feature.
