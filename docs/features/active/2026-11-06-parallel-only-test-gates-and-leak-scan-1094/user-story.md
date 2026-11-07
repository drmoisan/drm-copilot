# `parallel-only-test-gates-and-leak-scan` — User Story

- Issue: #1094
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-06T20-01

## Story Statement

- As the repository owner, I want each item validated by one parallel Pester run and one parallel pytest run, so that items stop paying for repeated serial and shuffled runs.
- As an agent planning or executing an item, I want the skills, agents, and preflight text to name only the parallel gates, so that no plan task or review check asks for a run that the owner has removed.
- As a maintainer of the test suites, I want a static scan to report state that a test leaves behind, so that test independence is still checked without adding a test run.

## Problem / Why

The repository requires each item to run its test suites several times, in both serial and parallel form. `## Test Isolation Checks` in the `execution-environment` skill requires a fresh single-process Pester run over `tests/scripts`, a concurrent-shard Pester run, seeded shuffled runs of the touched Pester suites, a reversed-order run of changed Python modules, a seeded shuffled Jest run, and a `pytest -n auto` run in addition to the serial runs.

The owner's decision, recorded 2026-11-06: tests run in parallel only. The sequential run existed to detect and fix a leak that has since been fixed, and the overhead of multiple runs and sequential runs is unacceptable.

Measured during Epic #1019:

- An 8-shard `Invoke-PoshQCParallelTest` run took 448 s.
- Single-process runs over `tests/scripts` took between 899 s and 1,504 s, and one item ran several of them in a single cycle.
- CI repeats the suite on every PR as 3 shards, so the local single-process run does not match CI.

Test independence remains policy under `.claude/rules/general-unit-test.md`. Removing the repeated runs removes the current means of detecting leaks, so detection needs to move to a scan that adds no test run. No shuffle step exists in the workflow files under `.github/workflows`.

A text search of the 509 Pester files in `tests/scripts` gives the candidate scale. These are candidates, not confirmed leaks: 30 files write `$env:`, 45 write `$global:`, 2 define global functions, 16 change location, and 2 change the process directory. These figures are for sizing only. The finding count comes from the first scan run.

Two tests in `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` were reported to fail in single-process runs. That file is one of the two that change the process directory. `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` was reported to fail when the process does not start at the repository root. Decision 3 in `spec.md` records how these tests are identified.

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
- Persona: Test-suite maintainer
  - Who: a person or agent who changes Pester tests or their helpers.
  - Cares about: finding a leak at its source, before a shard change exposes it.
  - Constraints: tests create no temporary files, and the scan is static and file-local.
  - Goals and frustrations: wants a precise finding with file, line, and kind, and a controlled way to record a false positive.
  - Context and motivations: files in one shard share a process, so a leak can surface later in an unrelated suite.

- Scenario: Validating a completed item
  - An executing agent finishes the tasks of a plan and reaches the test stage.
  - The brief states the gates, so the agent runs `Invoke-PoshQCParallelTest` and `pytest -n auto`, once each.
  - One Pester test fails. The agent runs that test file alone to debug it, and applies a fix.
  - The agent re-runs the parallel gate, because a suite is re-run only after a fix. The focused run is not recorded as evidence.
  - Both gates report zero failures, and the evidence cites those runs.
- Scenario: A new test leaves state behind
  - A maintainer adds a test that sets `$env:EXAMPLE` and has no restore.
  - The maintainer runs the task `PoshQC: 2c leak scan`, or the fast quality stage runs the scan in CI.
  - The scan reports the file, the line, and the kind `env`, and fails.
  - The maintainer decides whether the finding is a true leak. A true leak is fixed in the leaking suite and in any suite that relies on the leaked state. A false positive is added to `config/poshqc-leak-allowlist.json` with a reason.
  - The scan passes, and no test run was added.
- Scenario: A fix makes an allowlist entry stale
  - A maintainer fixes a finding that has an allowlist entry and leaves the entry in place.
  - The scan fails because the entry matches no raw finding.
  - The maintainer removes the entry, and the scan passes.

## Acceptance Criteria

### Locally verifiable criteria

- [ ] No skill, agent, rule, or preflight text in the repository requires a serial, single-process, seeded-shuffle, or reversed-order validation run. Measured as stated in Decision 1 of `spec.md`: no skill, agent, preflight, or brief text requires such a run or names a serial command as a validation gate, and the brief states that the parallel gates govern where a policy file names a toolchain test command.
- [ ] The branch diff changes no file under `.claude/rules/` or `.github/instructions/`, no bundle copy of those files, and neither `.agents/skills/powershell` nor `.agents/skills/python`.
- [ ] `## Test Isolation Checks` states the parallel gates and the leak scan, and all mirrored copies match.
- [ ] The `## Test Runtime`, `## CI-Only Failure Classes`, `## PowerShell Route and PoshQC MCP Limits`, and `## CI Shape and Required Checks` passages of the brief carry the changes listed in `### 1. Parallel-only test gates` of `spec.md`, in every mirrored copy.
- [ ] The Pre-Mortem `Test isolation` bullet of `atomic-plan-contract` states the parallel gates and the leak scan and names no removed run, in every mirrored copy.
- [ ] No plan-contract or review text requires a comparison run, and the brief states that a focused run of one test file is debugging only and is never a gate or evidence.
- [ ] Every editable surface in table A3 of the research no longer names a serial command as a validation gate, and tool-permission entries in those surfaces are unchanged.
- [ ] In `.vscode/tasks.json`, `QC: Coverage: All Providers` and `QC: 5 Run All Checks` depend on no serial test task, a leak-scan task exists, and the serial tasks remain available for debugging.
- [ ] `fix_all_branches.py` runs the leak scan, its Pester step runs `Invoke-PoshQCParallelTest` and fails on a non-zero `ExitCode`, and the `test_fix_all*.py` tests pass.
- [ ] The contract tests pass against the new wording and fail if the removed requirements are reintroduced, in any mirrored copy.
- [ ] The scan detects each listed state-change kind (`env`, `global-variable`, `global-function`, `location`, `process-directory`), and does not report a change that is restored in the same scope or in `AfterEach`, `AfterAll`, or `finally`.
- [ ] The scan reports a change with no restore, a restore of a different name, and a later literal assignment, and does not report text inside strings or `Mock`-named commands.
- [ ] Each finding names the file, the line, and the kind of state changed, and the scan covers `.ps1` helpers under `tests/` as well as `*.Tests.ps1` files.
- [ ] The scan tests supply file content through a seam as in-memory text and create no temporary files.
- [ ] `Invoke-PoshQCLeakScan` throws on an unallowlisted finding, a parse error, an invalid allowlist, and a stale allowlist entry, shown by unit tests that use injected seams.
- [ ] Allowlist validation rejects an entry with a missing or blank reason, and rejects any `exemptGlobalVariables` name other than `LASTEXITCODE`.
- [ ] `poshqc-static` holds the scan step after `Analyze PowerShell` with no `continue-on-error` and no step-level `if`, no job or required context is added, and `PoshQcWorkflow.Tests.ps1` asserts this.
- [ ] Every finding in `tests/scripts` is fixed or allowlisted with a reason, the scan over the repository passes, and the first scan's raw findings are kept under `<FEATURE>/evidence/baseline/`.
- [ ] `TestHelpers.ps1` defines no global function, and `run-actionlint.Tests.ps1` no longer removes `Import-ScriptFunction`.
- [ ] `enforce-python-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`, and `enforce-powershell-batch-budget-routing.Tests.ps1` restore a snapshot of each environment value they set, instead of clearing it to `$null`.
- [ ] The tests named in Decision 3 of `spec.md` no longer depend on the process directory: none of them reads or changes `[Environment]::CurrentDirectory` or calls `[IO.Directory]::SetCurrentDirectory`, and they pass in the parallel gate.
- [ ] `Enter-DrmCopilotShell.Tests.ps1` holds no `Push-Location` and no `[Environment]::CurrentDirectory`, covers `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` through the location seam, and keeps a default-path case for each.
- [ ] `PoshQC.TestingInvokeConfigPaths.Tests.ps1` holds no `Set-Variable -Scope 1`, and its captures use a holder hashtable.
- [ ] Each new PoshQC module has a bundle copy and a `POSHQC_PARITY_PATHS` entry, `Invoke-PoshQCLeakScan` appears in both export lists in each copy, the README describes it, and the parity tests pass.
- [ ] Each new PoshQC module meets the repository line-coverage threshold in the merged `artifacts/pester/powershell-coverage.xml`.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.
- [ ] The validation evidence for this item comes from the parallel gates and the leak scan, and cites no single-process, seeded-shuffle, reversed-order, comparison, or focused run.

### CI-dependent criteria

These criteria require CI on the PR head. They stay unchecked and pending until CI has run. The failure path of the CI step is proven locally by the unit test and the workflow test in the criteria above, because the PR head itself carries no unallowlisted finding.

- [ ] CI-dependent: the step `Scan Pester tests for leaked state` ran in `poshqc / PowerShell QC static` on the PR head and passed.
- [ ] CI-dependent: `CI Required Gate` reports success on the final PR head, which also serves as the green run for the modified workflow.

## Non-Goals

- A runtime check that compares session state before and after each test file during the parallel run. The owner agreed to take this as a second step, after this item.
- Adopting Pester `Run.Parallel`, which is experimental.
- Editing `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell`, or `.agents/skills/python`.
- Removing the serial VS Code tasks, which remain for debugging a single failure.
- Detecting state changed by production code under test, or a restore located in another file.
- Editing the feature folders of Epic #1019.
