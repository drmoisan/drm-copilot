# `parallel-only-test-gates-and-leak-scan` — User Story

- Issue: #1094
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-07T02-09

## Story Statement

- As the repository owner, I want each item validated by one parallel Pester run and one parallel pytest run, so that items stop paying for repeated serial and shuffled runs.
- As an agent planning or executing an item, I want the skills, agents, and templates to name only the parallel gates, so that no plan task or review check asks for a run that the owner has removed.

## Problem / Why

The repository requires each item to run its test suites several times, in both serial and parallel form. `## Test Isolation Checks` in the `execution-environment` skill requires a fresh single-process Pester run over `tests/scripts`, a concurrent-shard Pester run, seeded shuffled runs of the touched Pester suites, a reversed-order run of changed Python modules, a seeded shuffled Jest run, and a `pytest -n auto` run in addition to the serial runs.

The owner's decision, recorded 2026-11-06: tests run in parallel only. The sequential run existed to detect and fix a leak that has since been fixed, and the overhead of multiple runs and sequential runs is unacceptable.

Measured during Epic #1019:

- An 8-shard `Invoke-PoshQCParallelTest` run took 448 s.
- Single-process runs over `tests/scripts` took between 899 s and 1,504 s, and one item ran several of them in a single cycle.
- CI repeats the suite on every PR as 3 shards, so the local single-process run does not match CI, although the skill calls it "the CI shape".

Test independence remains policy under `.claude/rules/general-unit-test.md`. Removing the repeated runs removes the current means of detecting leaks. #1096 adds a static scan for that purpose.

The owner split this item on 2026-11-07. #1094 is the parallel-only test gate change alone, and it is text and contract tests only. The static leak scan and the test fixes moved to #1096, which starts after #1094 merges.

## Personas & Scenarios

- Persona: Repository owner
  - Who: the maintainer who sets repository policy and reviews completed items.
  - Cares about: the time and cost of each item, and trust in the validation result.
  - Constraints: policy files under `.claude/rules/` and `.github/instructions/` are not edited in this item.
  - Goals and frustrations: wants one run per suite. Single-process runs took between 899 s and 1,504 s, against 448 s for an 8-shard run.
  - Context and motivations: the repeated runs were added to detect a leak that has since been fixed.
- Persona: Planning or executing agent
  - Who: an agent that writes or carries out an atomic plan and reads the `execution-environment` brief.
  - Cares about: a single, unambiguous statement of which test runs count as gates.
  - Constraints: reaches PowerShell through MCP tools or an `sh` launcher, and no MCP tool exposes `Invoke-PoshQCParallelTest`.
  - Goals and frustrations: wants plans that pass preflight and review without runs that the owner has removed. Serial commands in skills and agents currently conflict with that aim.
  - Context and motivations: follows the brief and the plan contract, so stale text produces stale plans.

- Scenario: Validating a completed item
  - An executing agent finishes the tasks of a plan and reaches the test stage.
  - The brief states the gates, so the agent runs `Invoke-PoshQCParallelTest` and `pytest -n auto`, once each.
  - One Pester test fails. The agent runs that test file alone to debug it, and applies a fix.
  - The agent re-runs the parallel gate, because a suite is re-run only after a fix. The focused run is not recorded as evidence.
  - Both gates report zero failures, and the evidence cites those runs.
- Scenario: Planning an item with no test-suite baseline
  - A planning agent writes Phase 0 of a plan.
  - The plan contract requires static tool baselines, so Phase 0 captures format, lint, type-check, and analyzer results, and runs no test suite.
  - The final QA tasks read coverage from the single gate run and compare each changed file with the thresholds.
  - The policy audit records its retained baseline fields as `N/A - no pre-change run`, and the audit validators accept it.
- Scenario: A removed requirement is reintroduced
  - A contributor adds a seeded shuffle requirement to one mirrored copy of the brief.
  - The contract test finds the negative token in that copy and fails.
  - The contributor removes the text, and the test passes.

## Acceptance Criteria

### Locally verifiable criteria

- [ ] No skill, agent, or template text in the repository requires a serial, single-process, seeded-shuffle, reversed-order, comparison, or pre-change test-suite baseline run. Measured as stated in Decision 1 of `spec.md`: no skill, agent, or template text requires such a run or names a serial command as a validation gate, and the brief states that the parallel gates govern where a policy file names a toolchain test command. The residual limit in `## Constraints & Risks` of `spec.md` applies: the deferred Python tools and VS Code aggregates still invoke a serial command until #1096.
- [x] The branch diff changes no file under `.claude/rules/` or `.github/instructions/`, no bundle copy of those files, and neither `.agents/skills/powershell` nor `.agents/skills/python`.
- [x] The branch diff changes no file under `.github/workflows/` or `scripts/powershell/PoshQC/`, and does not change `.vscode/tasks.json`, the Python tools named in `### 2. Out of scope` of `spec.md`, or the policy-audit validators.
- [x] `## Test Isolation Checks` states the parallel gates, names no leak scan, and all mirrored copies match.
- [x] The `## Test Runtime`, `## CI-Only Failure Classes`, and `## PowerShell Route and PoshQC MCP Limits` passages of the brief carry the changes listed in `### 1. Parallel-only test gates` of `spec.md`, in every mirrored copy, and `## CI-Only Failure Classes` names no scan.
- [x] The Pre-Mortem `Test isolation` bullet of `atomic-plan-contract` states the parallel gates, names no leak scan, and names no removed run, in every mirrored copy.
- [x] No plan-contract or review text requires a comparison run, and the brief states that a focused run of one test file is debugging only and is never a gate or evidence.
- [x] Static tool baselines remain required, and skill, agent, and template text reads coverage from the single gate run against the thresholds, in every mirrored copy.
- [x] The policy-audit template requires no pre-change run, its retained baseline fields record `N/A - no pre-change run`, and a contract test shows that an audit filled in that way passes the unchanged policy-audit validators.
- [x] Every editable surface in table A3 of the research, except `scripts/dev_tools/fix_all_branches.py`, no longer names a serial command as a validation gate, and tool-permission entries in those surfaces are unchanged.
- [x] The contract tests pass against the new wording and fail if the removed requirements are reintroduced, in any mirrored copy.
- [x] `test_execution_environment_fact_is_unchanged_across_copies` filters on the parts relative to `REPO_ROOT` and passes in a checkout under `.claude/worktrees/`.
- [x] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.
- [x] The validation evidence for this item comes from the parallel gates, and cites no single-process, seeded-shuffle, reversed-order, comparison, or focused run.

### CI-dependent criteria

These criteria require CI on the PR head. They stay unchecked and pending until CI has run.

- [ ] CI-dependent: `CI Required Gate` reports success on the final PR head.

## Non-Goals

- The static leak scan, its allowlist, its CI step, and its PoshQC modules, which moved to #1096.
- All test fixes, including `Enter-DrmCopilotShell.Tests.ps1`, `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, `TestHelpers.ps1`, and the batch-budget suites, which moved to #1096.
- The `.vscode/tasks.json` aggregates and the serial command edits in `fix_all_branches.py`, `fix_all_branches_extra.py`, `scripts/dev_tools/atomic_executor/prompt_builder.py`, and `cli_preflight.py`, which moved to #1096. These still invoke a serial command until #1096.
- Any CI change, and any code change to the policy-audit validators.
- A runtime check that compares session state before and after each test file during the parallel run.
- Adopting Pester `Run.Parallel`, which is experimental.
- Editing `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell`, or `.agents/skills/python`.
- Removing the serial VS Code tasks, which remain for debugging a single failure.
- Editing the feature folders of Epic #1019.
