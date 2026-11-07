# `pester-static-leak-scan` — User Story

- Issue: #1096
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-11-07

## Story Statement

- As the repository owner, I want a static scan to detect test state that leaks between Pester files, so that test independence stays checked with no added test run.
- As an agent or maintainer running a quality command, I want every full-suite command and aggregate task to use the parallel gates, so that no tool runs a serial suite while the rules state that gates are parallel.
- As a reviewer, I want each scan finding fixed or allowlisted with a reason, and each process reduction recorded in the ledger, so that a suppression or a removed run can be traced and reverted.

## Problem / Why

Split from issue #1094 by owner decision on 2026-11-07. #1094 kept the parallel-only test gate change and has merged. This item carries the static leak scan, the test fixes, and the serial commands that #1094 deferred by name.

With parallel-only gates, the repository no longer runs the single-process and shuffled runs that detected state leaking between test files. Test independence remains policy under `.claude/rules/general-unit-test.md`. Files in the same shard still share a process, so a leak can surface later as a failure when shard contents change. Detection needs to move to a scan that adds no test run.

A text search of the 509 Pester files in `tests/scripts` gives the candidate scale. These are candidates, not confirmed leaks: 30 files write `$env:`, 45 write `$global:`, 2 define global functions, 16 change location, and 2 change the process directory. These figures are for sizing only. The finding count comes from the first scan run.

Two tests in `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` were reported to fail in single-process runs. That file is one of the two that change the process directory. `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` was reported to fail when the process does not start at the repository root. No gate reproduces the reported condition, so the fix is proved by construction, as spec Decision 3 states.

## Personas & Scenarios

- Persona: Repository owner
  - Owns the test policy and the quality gates of this repository.
  - Cares about test independence and about the time that repeated test runs cost.
  - Is constrained by the decision that test gates are parallel only.
  - Wants leak detection to survive the removal of the serial runs, and is frustrated by a run that adds time without adding detection.
- Persona: Executor agent
  - Implements plan tasks through the toolchain and the `atomic_executor` tool.
  - Cares that the commands it is told to run match the commands the tool runs.
  - Has no PowerShell tool and no MCP route to the scan, so it reaches the scan through the `sh` launcher.
  - Wants a finding that names the file, the line, and the kind of state changed.
- Persona: Feature reviewer
  - Checks a branch against the acceptance criteria and the review checklists.
  - Cares that an allowlist entry states a reason and that a reduction has a ledger entry.
  - Works from committed files and recorded evidence.
  - Wants a stale entry or a missing entry to fail visibly.

- Scenario: A new test leaves an environment variable set
  - A contributor adds a Pester test that writes `$env:EXAMPLE` with no restore.
  - The contributor runs the task `PoshQC: 2c leak scan`, or `QC: 0 Fix All`.
  - The scan fails and names the file, the line, and the kind `env`.
  - The contributor adds a restore in `AfterEach`, and the scan passes. A contributor who skips the local scan sees `poshqc / PowerShell QC static` fail in CI instead.
- Scenario: A finding is a false positive
  - The scan reports a write whose restore it cannot follow, such as a restore held in a scriptblock variable.
  - The contributor adds an entry to `config/poshqc-leak-allowlist.json` with the path, kind, name, and a reason.
  - The scan passes. An entry with a blank reason fails validation.
  - When the test later changes and the finding goes away, the stale entry fails the scan until it is removed.
- Scenario: An agent runs the executor tool
  - The executor tool reaches a phase gate and runs its full-suite pytest command.
  - The command passes `-n auto`, matching the prompt text the tool gives the agent.
  - A scoped run of named files stays as it is, for expected-fail handling.
- Scenario: A maintainer starts the default test task
  - The maintainer runs the default VS Code test task, or `QC: 5 Run All Checks`.
  - The parallel tasks run. Every dependency name resolves to a task.
  - The serial tasks stay available for debugging one failure and are not gates.
- Scenario: A reviewer traces the reduction
  - The reviewer reads ledger entry 0001 and finds the serial-command paths, a Revert Block for each changed file, and the back-filled merge commit.
  - The reviewer finds the edits in a separate commit whose subject carries `reduction: 0001`.

## Acceptance Criteria

Test gates are parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. The baseline run before any change is the one run of each gate for that state.

### Locally verifiable criteria

- [x] The scan detects each listed state-change kind (`env`, `global-variable`, `global-function`, `location`, `process-directory`), and does not report a change that is restored in the same scope or in `AfterEach`, `AfterAll`, or `finally`, shown by unit cases for each row of the `Detected kinds` table and each restore rule.
- [x] The scan reports a change with no restore, a restore of a different name, and a later literal assignment, and does not report text inside strings or `Mock`-named commands.
- [x] Each finding names the file, the line, and the kind of state changed, and the scan covers `.ps1` helpers under `tests/` as well as `*.Tests.ps1` files.
- [x] The scan tests supply file content through a seam as in-memory text and create no temporary files.
- [x] `Invoke-PoshQCLeakScan` throws on an unallowlisted finding, a parse error, an invalid allowlist, and a stale allowlist entry, shown by unit tests that use injected seams.
- [x] Allowlist validation rejects each condition in `Contracts and validation rules`, including an entry with a missing or blank reason and any `exemptGlobalVariables` name other than `LASTEXITCODE`.
- [x] With the default folders, a successful read that yields no folder under `tests/` is not an error, and the throw from `Get-PoshQCScanConfigFolder` when every configured folder is absent reaches the caller, shown by unit tests that use injected seams.
- [x] `poshqc-static` holds the step `Scan Pester tests for leaked state` after `Analyze PowerShell` with no `continue-on-error` and no step-level `if`, `PoshQcWorkflow.Tests.ps1` asserts this, the branch adds no CI job and no required context, and the `poshqc-linux-hooks` job is unchanged.
- [x] Every finding in `tests/scripts` is fixed or allowlisted with a reason: `Invoke-PoshQCLeakScan -Root .` over the repository returns without error, every item in `config/poshqc-leak-allowlist.json` has a non-blank reason, and the first scan's raw findings are kept under `<FEATURE>/evidence/baseline/`.
- [x] `TestHelpers.ps1` defines no global function, `run-actionlint.Tests.ps1` no longer removes `Import-ScriptFunction`, and `tree.Tests.ps1` loads the helper in `BeforeAll`.
- [x] `enforce-python-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`, and `enforce-powershell-batch-budget-routing.Tests.ps1` restore a snapshot of each environment value they set, instead of clearing it to `$null`.
- [x] The tests named in Decision 3 no longer depend on the process directory: their titles remain, none of them reads or changes `[Environment]::CurrentDirectory` or calls `[IO.Directory]::SetCurrentDirectory`, the body of the omitted-root test reads no `$PWD`, and they pass in the parallel gate.
- [x] `Enter-DrmCopilotShell.Tests.ps1` holds no `Push-Location` and no `[Environment]::CurrentDirectory`, covers `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` through the location seam, and keeps a default-path case for each.
- [x] `PoshQC.TestingInvokeConfigPaths.Tests.ps1` holds no `Set-Variable -Scope 1`, and its captures use a holder hashtable.
- [x] Each new PoshQC module has a bundle copy and a `POSHQC_PARITY_PATHS` entry, `Invoke-PoshQCLeakScan` appears in both export lists in each copy, the README describes it, and the parity tests pass.
- [x] Each new PoshQC module meets the repository line-coverage threshold in the merged `artifacts/pester/powershell-coverage.xml`.
- [x] `run_python_branch`, `run_preflight_qc_with_capture`, `QCRunner.FULL_TEST`, and `full_test` each pass `-n auto`, shown by tests that assert the command, and `addopts` carries no `-n` flag.
- [x] The prompt text of `PromptBuilder.build` and `build_preflight_qc_fix_prompt`, and the literal `PYTHON_TOOLCHAIN_COMMANDS["pytest"]`, state `-n auto`, and `_run_pytest_scoped_with_expectations` is unchanged, shown by `test_run_scoped_runs_all_tools_on_changed_files`.
- [x] `--cov=src/lexile_corpus_tuner` appears in none of the commands or text named in `### 1. Parallel-only test gates` of the spec.
- [x] `fix_all_branches.py` runs `PoshQC: leak scan` between `PoshQC: analyze` and `PoshQC: test`, its step `PoshQC: test` runs `Invoke-PoshQCParallelTest` and fails on a non-zero `ExitCode`, and the `test_fix_all*.py` tests pass.
- [x] In `.vscode/tasks.json`, `QC: Coverage: All Providers` and `QC: 5 Run All Checks` depend on `PoshQC: 4 test (Pester, parallel)` and on no serial test task, and `VT-` cases assert this.
- [x] Every `dependsOn` name in `.vscode/tasks.json` resolves to a task label, and a `VT-` case that tolerates full-line `//` comments asserts this.
- [x] `QC: 4 Pytest: run tests (parallel)` is the default of the `test` group and `QC: 4 Pytest: run tests` is not, the serial tasks remain available for debugging, and the task `PoshQC: 2c leak scan` exists.
- [x] `## Test Isolation Checks` in the `execution-environment` skill names the scan in a bullet appended after the last bullet, its existing bullets are unchanged, and all mirrored copies match, shown by `test_brief_test_isolation_states_parallel_gates` and `test_brief_copies_are_byte_identical`.
- [x] The `## CI Shape and Required Checks`, `## CI-Only Failure Classes`, `## Test Runtime`, and `## PowerShell Route and PoshQC MCP Limits` passages of the brief carry the changes in `### 4. Execution-environment brief` of the spec in every mirrored copy, and `test_brief_passages_state_parallel_gate_facts`, `test_brief_ci_section_names_jobs_and_required_contexts`, and `test_brief_copies_carry_no_removed_run_tokens` pass.
- [x] Entry 0001 records the serial-command paths in `## Files Changed` with its opening sentence amended, a Revert Block for each changed file in `## Prior Text`, and the statement in `## Stored Patch` that the patch does not hold these edits.
- [x] Entry 0001 reads `Merge commit: 278bb7047db986bbb0a8652ca323656ce85f8a08`, its `## Revert Signals` no longer holds `Before #1096 lands`, and no new entry exists under `docs/engineering/process-reductions/` for this item.
- [x] Each `Current` fence of entry 0001 occurs exactly once in its target after the brief edit, shown by a replay of each block recorded in evidence.
- [x] The serial-command edits and the entry 0001 update are in a separate commit whose subject carries `reduction: 0001`, and that commit holds no leak-scan change.
- [x] The branch diff adds no `.py` file, and changes no copy of `atomic-plan-contract`, no feature folder of Epic #1019, no file under `.claude/rules/` or `.github/instructions/`, no bundle copy of those files, and neither `.agents/skills/powershell` nor `.agents/skills/python`.
- [x] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.
- [x] Jest passes with zero failures through `node run-jest.cjs` in `extensions/drm-copilot/`, because the bundled resources change.
- [x] The validation evidence for this item comes from the parallel gates and the leak scan, and cites no single-process, seeded-shuffle, reversed-order, or focused run.
- [x] Before any change outside `docs/features/`, one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run are recorded under `<FEATURE>/evidence/baseline/`, each with its exit code, each failing test, and the line coverage of each existing production file the plan names for coverage, with branch coverage for a Python file, and the commit that adds that record precedes every branch commit that changes a path outside `docs/features/`.
- [x] Against that record, every test that fails in the final `Invoke-PoshQCParallelTest` or `pytest -n auto` run also failed in the baseline run, and every existing production file the plan names for coverage, which is each changed production file that the Pester or pytest coverage report measures, has final line coverage, and for a Python file final branch coverage, at or above its baseline figure, as recorded per file in evidence.

### CI-dependent criteria

These criteria require CI on the PR head. They stay unchecked and pending until CI has run. The failure path of the CI step is proven locally by the unit test and the workflow test in the criteria above, because the PR head itself carries no unallowlisted finding.

- [ ] CI-dependent: the scan runs in CI and fails on an unallowlisted finding: the step `Scan Pester tests for leaked state` ran in `poshqc / PowerShell QC static` on the PR head and passed.
- [ ] CI-dependent: `CI Required Gate` reports success on the final PR head, which also serves as the green run for the modified workflow.

## Non-Goals

- A runtime check that compares session state before and after each test file, which remains a later step.
- Adopting Pester `Run.Parallel`, which is experimental.
- New Python files.
- Editing `atomic-plan-contract`.
- Editing any Epic #1019 feature folder.
- Changing `poshqc / PowerShell hook suites (Linux)`, which stays a single-process CI job with a Linux purpose.
- Editing policy files under `.claude/rules/` or `.github/instructions/`.
- Reproducing the reported failures of the named tests. Proof is by construction.
