# parallel-only-test-gates-and-leak-scan (Issue #1094)

- Date captured: 2026-11-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-only-test-gates-and-leak-scan/ (Issue #1094)

- Issue: #1094
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1094
- Last Updated: 2026-11-07
- Work Mode: full-feature

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

## Proposed Behavior

### 1. Parallel-only test gates

- The Pester gate is one `Invoke-PoshQCParallelTest` run. The pytest gate is one `pytest -n auto` run. Jest runs through its normal parallel workers. A suite is re-run only after a fix.
- Remove the single-process, seeded-shuffle, and reversed-order requirements from `## Test Isolation Checks` in the `execution-environment` skill, and remove the "CI shape" wording.
- Update the `atomic-plan-contract` skill and any other planner, executor, reviewer, or preflight text that requires those runs.
- Update every mirrored copy of the changed skills: `.claude/skills/`, `.github/skills/`, `.agents/skills/`, and the three bundles under `extensions/drm-copilot/resources/`.
- Update the contract tests that pin the old wording, including `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` and `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`.
- Serial VS Code tasks may remain for debugging a single failure. They are not a validation gate.

### 2. Static leak scan

- Add a PowerShell scan to PoshQC that parses Pester test files and reports state changes with no matching restore in the same scope or in `AfterEach`, `AfterAll`, or `finally`.
- Detect at least writes to `$env:`, writes to `$global:`, global function definitions, `Set-Location` and `Push-Location`, and changes to the process directory.
- Findings name the file, the line, and the kind of state changed.
- Run the scan in a fast quality stage and in CI, so it adds no test run.
- Confirmed findings are fixed on both sides, in the leaking suite and in any suite that relies on the leaked state. False positives go in a committed allowlist in which every entry states a reason.

### 3. Out of scope

- A runtime check that compares session state before and after each test file during the parallel run. The owner agreed to take this as a second step, after this item.
- Adopting Pester `Run.Parallel`, which is experimental.

## Acceptance Criteria (early draft)

- [ ] No skill, agent, rule, or preflight text in the repository requires a serial, single-process, seeded-shuffle, or reversed-order validation run.
- [ ] `## Test Isolation Checks` states the parallel gates and the leak scan, and all mirrored copies match.
- [ ] The contract tests pass against the new wording and fail if the removed requirements are reintroduced.
- [ ] The scan detects each listed state-change kind, and does not report a change that is restored in the same scope or in `AfterEach`, `AfterAll`, or `finally`.
- [ ] The scan runs in CI and fails on an unallowlisted finding.
- [ ] Every finding in `tests/scripts` is fixed or allowlisted with a reason.
- [ ] The two `Enter-DrmCopilotShell.Tests.ps1` tests and the `PoshQC.TestingInvokeConfigPaths.Tests.ps1` test no longer depend on the process directory.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.

## Constraints & Risks

- Files in the same shard still share a process, so a leak can surface later as a failure when shard contents change. The scan is the mitigation for this, and it is static, so it can miss state changed indirectly through a helper.
- A static scan produces false positives. The allowlist must require a reason so that it does not become a blanket suppression.
- New tooling is PowerShell, not Python.
- Tests must create no temporary files, and the scan must take file content through a seam so that it can be tested in memory.
- This item runs alongside Epic #1019. It must not edit the epic's feature folders, and it must itself use the parallel-only gates.

## Test Conditions to Consider

- [ ] Unit coverage for each detected state-change kind, positive and negative, using in-memory script text
- [ ] Restore recognised in `AfterEach`, `AfterAll`, `finally`, and the same scope; restore absent; restore of a different variable
- [ ] Allowlist entries: valid, missing reason, and stale
- [ ] Contract tests for the removed wording across all mirrored copies
- [ ] CI step failure on an unallowlisted finding

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-only-test-gates-and-leak-scan/` folder from the template
