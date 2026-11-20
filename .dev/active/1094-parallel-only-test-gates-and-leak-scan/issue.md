# parallel-only-test-gates-and-leak-scan (Issue #1094)

- Date captured: 2026-11-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-only-test-gates-and-leak-scan/ (Issue #1094)

- Issue: #1094
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1094
- Last Updated: 2026-11-07
- Work Mode: full-feature

## Scope Change

The owner split this item on 2026-11-07. This issue is now the parallel-only test gate change alone, so that it can merge first. The static leak scan and the test fixes moved to #1096, which starts after this issue merges.

## Problem / Why
The repository requires each item to run its test suites several times, in both serial and parallel form. `## Test Isolation Checks` in the `execution-environment` skill requires a fresh single-process Pester run over `tests/scripts`, a concurrent-shard Pester run, seeded shuffled runs of the touched Pester suites, a reversed-order run of changed Python modules, a seeded shuffled Jest run, and a `pytest -n auto` run in addition to the serial runs.

The owner's decision, recorded 2026-11-06: tests run in parallel only. The sequential run existed to detect and fix a leak that has since been fixed, and the overhead of multiple runs and sequential runs is unacceptable.

Measured during Epic #1019:

- An 8-shard `Invoke-PoshQCParallelTest` run took 448 s.
- Single-process runs over `tests/scripts` took between 899 s and 1,504 s, and one item ran several of them in a single cycle.
- CI repeats the suite on every PR as 3 shards, so the local single-process run does not match CI, although the skill calls it "the CI shape".

Test independence remains policy under `.claude/rules/general-unit-test.md`. Removing the repeated runs removes the current means of detecting leaks; #1096 adds a static scan for that purpose.

## Proposed Behavior
- The Pester gate is one `Invoke-PoshQCParallelTest` run. The pytest gate is one `pytest -n auto` run. Jest runs through its normal parallel workers. A suite is re-run only after a fix.
- Remove the single-process, seeded-shuffle, and reversed-order requirements from `## Test Isolation Checks` in the `execution-environment` skill, and remove the "CI shape" wording.
- Update the `atomic-plan-contract` skill and any other planner, executor, reviewer, or preflight text that requires those runs, including the requirement for a pre-change test-suite baseline run.
- Update every mirrored copy of the changed skills: `.claude/skills/`, `.github/skills/`, `.agents/skills/`, and the three bundles under `extensions/drm-copilot/resources/`.
- Update the contract tests that pin the old wording, including `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` and `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`.
- Serial VS Code tasks may remain for debugging a single failure. They are not a validation gate.

## Out of Scope
- The static leak scan, its allowlist, and its CI step: moved to #1096.
- The `Enter-DrmCopilotShell.Tests.ps1` and `PoshQC.TestingInvokeConfigPaths.Tests.ps1` fixes: moved to #1096.
- A runtime check that compares session state before and after each test file during the parallel run.
- Adopting Pester `Run.Parallel`, which is experimental.

## Acceptance Criteria
- [ ] No skill, agent, or preflight text in the repository requires a serial, single-process, seeded-shuffle, or reversed-order validation run.
- [ ] `## Test Isolation Checks` states the parallel gates, names no leak scan, and all mirrored copies match.
- [ ] The contract tests pass against the new wording and fail if the removed requirements are reintroduced.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.

## Constraints & Risks
- Files in the same shard still share a process, so a leak can surface later as a failure when shard contents change. Until #1096 lands, no check covers this.
- This item runs alongside Epic #1019. It must not edit the epic's feature folders, and it must itself use the parallel-only gates.

## Test Conditions
- [ ] Contract tests for the removed wording across all mirrored copies

## Source
From: docs/features/potential/2026-11-06-parallel-only-test-gates-and-leak-scan.md
