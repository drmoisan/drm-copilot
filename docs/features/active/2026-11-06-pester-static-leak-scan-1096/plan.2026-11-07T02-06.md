# pester-static-leak-scan - Plan

- **Issue:** #1096
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T02-06
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Branch:** feature/pester-static-leak-scan-1096

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- Python: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md), [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- Requirements: `spec.md` and `user-story.md` in this folder, then `research/research.2026-11-07.md`. Spec `## Decisions` are settled.

**All work must comply with these policies; do not duplicate their content here.** Tool routes, launchers, command-text restrictions, the batch budget, and CI shape are owned by the `execution-environment` skill and are not restated.

## Execution Rules

Terms: `<FEATURE>` is `docs/features/active/2026-11-06-pester-static-leak-scan-1096`. `SCRATCH` resolves to `<session scratchpad>/issue-1096/`, and every scratch file, step script, JUnit file, coverage report, and log lives under it. Evidence records the token, never a host path.

These rules apply to every task:

- **Commit and push.** Each task ends with one commit and one push of that commit to `feature/pester-static-leak-scan-1096`. Tags are never pushed. The task stages only the paths it names, the evidence it writes, and this plan file with its checkbox, which is checked after verification and before the commit. There are two exceptions: the P4-T2 commit and any P5-T2 fence-correction commit hold no plan file, so those checkboxes are committed by the next task's commit. `.claude/agent-memory` is never staged.
- **Git location.** The executor runs from the main checkout's process directory, so every git command carries a literal `-C` to the item worktree, whose path arrives in the delegation prompt. That path is recorded as `<item worktree>` and appears in no plan or evidence file.
- **`testResults.xml`.** This tracked file is rewritten by Pester runs and is restored before staging.
- **Poetry.** Do not run an unqualified `poetry install` from the item worktree, because the shared `.venv` would be repointed at it. The worktree holds no `.venv`: `poetry run` from it uses the main checkout's environment through the inherited `VIRTUAL_ENV`, and creates no `.venv` there.
- **Parallel gates only.** The Pester gate is one `Invoke-PoshQCParallelTest` run, the pytest gate is one `pytest -n auto` run, and Jest runs through its normal workers from `extensions/drm-copilot/`. A suite is re-run only after a fix. A focused run of one test file is debugging only: it is never a gate, an acceptance condition, or evidence, and it is not recorded.
- **Test proof.** A task that adds or changes a test is accepted on the named test's presence. Its pass is proved at the Phase 6 gates.
- **Failure on the branch.** A gate failure whose test file or subject is in the diff from the merge base of `origin/main` and `HEAD` is fixed, and the failed gate is re-run.
- **Failure outside the branch.** A gate failure whose test file and subject are both absent from that diff is not waived. The executor names the test, lists the diff as proof, keeps `EXIT_CODE:` non-zero, leaves the task unchecked, and stops for the orchestrator.
- **PoshQC mirror.** A task that edits a file under `scripts/powershell/PoshQC/` copies it byte-for-byte to `extensions/drm-copilot/resources/powershell/PoshQC/` in the same task.
- **Tooling.** New tooling is PowerShell, and no `.py` file is added. Pester counts and coverage come from files, never from PoshQC MCP summaries. Branch-current Pester uses the `sh` launcher route of the `execution-environment` skill.
- **Evidence.** Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The recorded `EXIT_CODE:` goes non-zero when the task's asserted value fails. Filename stamps are the write time in UTC.
- **Scope.** Do not edit `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell/`, `.agents/skills/python/`, any `atomic-plan-contract` copy, `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, or any Epic #1019 folder. This plan has no PR, CI-monitoring, or merge task: the orchestrator owns those.

## Finding Classification Rule

Remediation is a derivation from the first scan. The input is every `FINDING:` row of the lexicographically greatest `<FEATURE>/evidence/baseline/leak-scan-raw.*.md`, read against the tree at the commit of that artifact. Rows are grouped by the allowlist key (`path`, `kind`, `name`). Apply the classes in order; the first match decides.

| Class | Result | Predicate on the file text | Disposition |
|---|---|---|---|
| C1 | Exempt | `kind` is `global-variable` and `name` is `LASTEXITCODE` | Covered by the single `exemptGlobalVariables` entry (spec Decision 2), counted, with no per-row action |
| C2 | False positive | The same file restores the same key in a `finally`, `AfterEach`, or `AfterAll` block that runs after the write, through a route rules R1 to R5 do not follow: a scriptblock held in a variable and invoked from that block, `$ExecutionContext.SessionState.InvokeProvider`, or a function reached from a cleanup block through another function | Allowlist entry whose reason names the route and the cleanup block |
| C3 | False positive | The write sits in a scriptblock passed to `Start-Job` or handed to a child `pwsh` process, so it never runs in the test process | Allowlist entry whose reason names the child process |
| C4 | False positive | The write is in a named function in a `.ps1` helper that is not a `*.Tests.ps1` file, and every call of that function under `tests/` sits inside an R1 to R4 position for the same key in the calling file | Allowlist entry whose reason names the helper and states that callers restore |
| T | True leak | None of the above | Fixed on both sides |

- **Group rule.** If any row of a key group is class T, every row of that group is class T, and no allowlist entry is written for it, because an entry has no line and would hide the leak.
- **Leaking side.** Snapshot the prior value before the write and restore it in `finally`, `AfterEach`, or `AfterAll`, in the form used by `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`.
- **Relying side.** Search `tests/scripts` for the key's name. A file that reads the key and neither sets it nor is the writer is changed to set its own state. The search and its result are recorded in the row. Dynamic keys record `DYNAMIC`, and the search covers the writer's file only.
- **Known cases.** The rule, not this list, decides them. `tests/scripts/powershell/Support/TestHelpers.ps1` `global-function` `Import-ScriptFunction` is expected to be T, because its only removal is in another file. `tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1` rows are expected to be C2 through `$script:restoreEnvironment`, or C1.
- **Stop condition.** A `PARSE-ERROR:` row is corrected in the file when the file is not an intentional fixture. An intentional unparseable fixture under `tests/` stops the run for the orchestrator, because spec `## API / CLI Surface` makes a parse error a failure.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reading and Baseline Capture

Phase 0 follows `## Phase 0 Requirements` in `atomic-plan-contract` as it stands.

- [ ] [P0-T1] Read the policy files in the `policy-compliance-order` order, including `.claude/rules/powershell.md`, `.claude/rules/python.md`, and `.claude/rules/ci-workflows.md`, then `<FEATURE>/spec.md`, and write `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the list of files read, and `git branch --show-current` through `-C` prints `feature/pester-static-leak-scan-1096`.
- [ ] [P0-T2] Capture the static baselines in `<FEATURE>/evidence/baseline/powershell-format.<timestamp>.md`, `powershell-analyze.<timestamp>.md`, `python-black.<timestamp>.md`, `python-ruff.<timestamp>.md`, and `python-pyright.<timestamp>.md`, in the same folder.
  - PowerShell format runs check-only through a no-op `-WriteFile` seam on the branch-current module. Analyzer findings come from a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the `.ps1` and `.psm1` files of the `Get-PoshQCFileList -Root` file set, the filter `Invoke-PoshQCAnalyze` applies. Black runs in check mode.
  - Acceptance: each `Output Summary:` states a numeric count, and `git status --porcelain` shows no tracked file changed by the step.

### Phase 1 — Leak Scan and Allowlist

The kinds and rules are in spec `### 2. Static leak scan` and `## API / CLI Surface`. Sub-modules are dot-sourced into the PoshQC module, so internal functions are tested in module scope. Tests follow the module-collision guard in `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, use single-quoted in-memory script text, create no temporary files, and hold `-ForEach` tables inline. Every `It` title starts with its tag, and sibling titles stay unique when case is folded, as `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` requires.

- [ ] [P1-T1] Create `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1` with AST write detection, restore pairing, and `Get-PoshQCLeakFinding`, create `tests/scripts/powershell/PoshQC/PoshQC.LeakScan.Tests.ps1`, and register the module in `scripts/powershell/PoshQC/PoshQC.psm1` and in `POSHQC_PARITY_PATHS` of `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
  - Behavior: parse with `[System.Management.Automation.Language.Parser]::ParseInput`, never `ParseFile`. Each form of the `Detected kinds` table yields one write with `Path`, `Line`, `Kind`, and `Name`, keyed as the spec states. Rules R1 to R5 pair writes with restores. A write inside `finally`, `AfterEach`, or `AfterAll` is a restore. Output sorts by path, then line. A parse error throws and names the path.
  - Tests, tag `LS-K`: every form of every kind, including the aliases and both `Environment` spellings; here-strings, command strings, and `Mock`-named commands are not detected; exact `Line` and `Name` values.
  - Tests, tag `LS-R`: one positive case per rule; restore absent; restore of a different name; a later literal assignment is reported; `$name` pairs with `$name`; `Pop-Location` and `Set-Location` restore `location`; a parse error throws; a `.ps1` helper path behaves as a `*.Tests.ps1` path.
  - The module is added to the sub-module list after `PoshQC.ScanConfig.psm1`. `test_poshqc_bundled_module_files_match_repo_root_sources` is the asserting parity test and is otherwise unchanged.
  - Acceptance: every `LS-K` and `LS-R` case exists, the bundle copy exists, and the module stays at or below 500 logical lines. If the test file would pass 700 lines, the `LS-R` cases go to `tests/scripts/powershell/PoshQC/PoshQC.LeakScanPairing.Tests.ps1`.
- [ ] [P1-T2] Create `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1` with allowlist validation, comparison, and public `Invoke-PoshQCLeakScan`, create `tests/scripts/powershell/PoshQC/PoshQC.LeakAllowlist.Tests.ps1`, and register, export, and document it in `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/PoshQC.psd1`, `scripts/powershell/PoshQC/README.md`, and `POSHQC_PARITY_PATHS`.
  - Behavior: validation throws and names the file for each condition in spec `Contracts and validation rules`. Absent or blank input is an empty allowlist. Comparison removes exempt names and returns unallowed findings and stale entries, with paths normalized to forward slashes and compared ordinally.
  - `Invoke-PoshQCLeakScan` has the spec signature and is the only I/O in the scan; its seam defaults are one line each. Default folders are the `Get-PoshQCScanConfigFolder` result filtered to the prefix `tests/` after a successful read. That function's throw reaches the caller, and no folder under `tests/` is not an error. Only `.ps1` files are read. Each finding, stale entry, and parse error goes to `-Logger` as one `path | line | kind | name` message, and any of them ends in one `throw`. `Invoke-PoshQCSuite` and `Invoke-PoshQCAnalyze` are unchanged.
  - Tests, tag `LA-`: a valid file; absent and blank input; wrong version; bad JSON; unknown `kind`; blank field; missing and blank `reason`; absolute path; `..` segment; duplicate entry; a rejected exempt name; exempt removal; an allowlisted finding; an unallowed finding; a stale entry. Fixtures hold no drive letter.
  - Tests, tag `LI-`, through injected seams: passes when every finding is exempt or allowlisted; throws on an unallowlisted finding, a parse error, an invalid allowlist, and a stale entry; the thrown text names path, line, and kind; helper `.ps1` files are enumerated; folders outside `tests/` are ignored; no folder under `tests/` passes; the `Get-PoshQCScanConfigFolder` throw reaches the caller; an absent allowlist is empty. The spec signature has no folder seam, so the default-folder cases replace `Get-PoshQCScanConfigFolder` with `Mock` inside `InModuleScope PoshQC`, in the form `PoshQC.TestingInvokeConfigPaths.Tests.ps1` uses, because `Mock -ModuleName` from test code is not honored in a PoshQC-hosted run.
  - Acceptance: every `LA-` and `LI-` case exists, and `Invoke-PoshQCLeakScan` is in `Export-ModuleMember`, `FunctionsToExport`, and README `## Functions` in the repository copy and the bundle copy.

### Phase 2 — First Repository Scan

- [ ] [P2-T1] Run `Invoke-PoshQCLeakScan` over the repository with `config/poshqc-leak-allowlist.json` absent, write `<FEATURE>/evidence/baseline/leak-scan-raw.<timestamp>.md`, then classify every row under `## Finding Classification Rule` in `<FEATURE>/evidence/other/leak-scan-classification.<timestamp>.md`.
  - The step script collects logger messages through `-Logger`, catches the expected throw, and writes one `FINDING: <path> | <line> | <kind> | <name>` row per finding and one `PARSE-ERROR:` row per parse error, sorted by path, then line. It exits 1 only when the throw occurred and at least one row was written, and 255 otherwise. The raw artifact declares `ExpectedExitCode: 1`, and its `Output Summary:` states the count per kind and the `LASTEXITCODE` count.
  - The classification holds one row per raw finding, with its class, the matched predicate text, and its disposition, plus the relying-side search for a class T row. Its header states `EXEMPT-COUNT:`, the count reported to the owner under spec Decision 2.
  - Acceptance: `EXIT_CODE: 1`, the classification row count equals the raw `FINDING:` count, and no key group mixes T with another class.

### Phase 3 — Remediation

- [ ] [P3-T1] Apply the known leak fixes in `tests/scripts/powershell/Support/TestHelpers.ps1`, `tests/scripts/dev-tools/tree.Tests.ps1`, `tests/scripts/dev-tools/run-actionlint.Tests.ps1`, `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`, `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`.
  - `TestHelpers.ps1` defines `Import-ScriptFunction` without `global:`. `tree.Tests.ps1` runs that dot-source at file scope, during discovery, and reaches its `BeforeAll` only through the global definition, so the `$scriptRoot` assignment and the dot-source move into `BeforeAll`, ahead of the first call.
  - `run-actionlint.Tests.ps1` drops `$script:describeHadImportScriptFunction`, the removal in its `AfterAll`, and the comment text about that helper. Its Archive module cleanup stays.
  - Disposition of the other files that load the helper: `new-potential-entry.Tests.ps1` and `post-codex-worktree-session.Tests.ps1` dot-source it inside `BeforeAll`, so they are unaffected and unchanged. These four are the only files that load it, and only three call `Import-ScriptFunction`.
  - Each `$env:` name a batch-budget suite assigns is captured in `BeforeEach` and restored in `AfterEach`, in the `$script:Prior...` form of `enforce-python-batch-budget-routing.Tests.ps1`. The classification artifact marks each row these fixes close.
  - Acceptance: `TestHelpers.ps1` holds no `global:` token, `run-actionlint.Tests.ps1` holds no `Function:\Import-ScriptFunction` path, `tree.Tests.ps1` has no dot-source outside `BeforeAll`, and no `AfterEach` in the three batch-budget suites assigns a literal `$null` to an `$env:` name.
- [ ] [P3-T2] Remove the process-directory dependency in `scripts/dev-tools/DrmCopilotPromptSupport.ps1`, `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`, and `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1`.
  - Production: `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` gain a `-GetLocationPath` parameter defaulting to `{ $PWD.ProviderPath }`, which replaces the direct read, so default resolution is unchanged. The callers in that file keep their calls, `scripts/dev-tools/Enter-DrmCopilotShell.ps1` calls neither function and is unchanged, and the existing `GetLocationPath` delegates of `Set-DrmCopilotPrompt` and `Start-DrmCopilotPromptSession` keep their defaults.
  - `Enter-DrmCopilotShell.Tests.ps1`: the cases `resolves a relative path against the PowerShell location, not the process directory` and `resolves a relative virtual environment path against the PowerShell location, not the process directory` keep their titles, inject a fixture base, and assert against it. Each of the Contexts `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` gains a default-path case comparing with `Join-Path $PWD.ProviderPath ...`. All other cases are unaffected and unchanged.
  - `PoshQC.TestingInvokeConfigPaths.Tests.ps1`: the test whose title begins `defaults $Root to $PWD.ProviderPath when -Root is not supplied` keeps its title and applies the `PR10-OMITTED-ROOT-USES-CURRENT-LOCATION` pattern: `Push-Location`, then a `try` whose `finally` pops, so that rule R2 pairs it, reading the location with `Get-Location`. All five `Set-Variable -Scope 1` captures become writes to a holder hashtable. `Invoke-PoshQCTest` needs no production change.
  - Acceptance: `Enter-DrmCopilotShell.Tests.ps1` holds no `Push-Location` and no `[Environment]::CurrentDirectory`, and each of its two Contexts has one seam case and one default-path case; `PoshQC.TestingInvokeConfigPaths.Tests.ps1` holds no `Set-Variable -Scope 1`, and the body of the omitted-root test reads no `$PWD`.
- [ ] [P3-T3] Fix every remaining class T row from the latest `<FEATURE>/evidence/other/leak-scan-classification.*.md`, on both sides, in the files under `tests/scripts/` that those rows name.
  - The file set is derived from the rows, and each changed test keeps its assertions. A row closed by P3-T1 or P3-T2 is marked with that task. When no row remains, the artifact records `NONE`.
  - Acceptance: every class T row in the artifact names its fix and its relying-side result.
- [ ] [P3-T4] Create `config/poshqc-leak-allowlist.json` from the classification, run `Invoke-PoshQCLeakScan -Root` with it, and write `<FEATURE>/evidence/regression-testing/leak-scan-remediated.<timestamp>.md`.
  - `version` is 1. `exemptGlobalVariables` holds the one `LASTEXITCODE` entry with the spec Decision 2 reason. `entries` holds one item per C2, C3, or C4 key group, with a reason that names the class route and no line number. A reported finding or stale entry goes back to the class that owns it, and this task repeats.
  - Acceptance: `EXIT_CODE: 0` from the launcher's exit on no throw, the entry count equals the false-positive key-group count, and no entry key belongs to a class T group.

### Phase 4 — Wiring and Serial-Command Reduction

P4-T1 lands every leak-scan addition. P4-T2 is the only commit that removes a serial command, so spec criterion AC-29 holds and each `Prior` fence keeps the scan additions. The CI step follows remediation because it fails while findings remain.

- [ ] [P4-T1] Add the scan to `.github/workflows/_poshqc.yml`, `.vscode/tasks.json`, and `scripts/dev_tools/fix_all_branches.py`, with `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, a new `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`, and `tests/scripts/dev_tools/test_fix_all.py`, `test_fix_all_failure_paths.py`, `test_fix_all_branches.py`, and `test_fix_all_json_cancel.py`.
  - CI: the step `Scan Pester tests for leaked state` follows `Analyze PowerShell` in `poshqc-static`, imports the module, and calls `Invoke-PoshQCLeakScan -Root` with the workspace, under `shell: pwsh`, with no `continue-on-error` and no step-level `if`. No job, matrix entry, or required context changes.
  - `.vscode/tasks.json`: add `PoshQC: 2c leak scan` after `PoshQC: 2b autofix (PSSA -Fix)`. `QC: 5 Run All Checks` gains it after `PoshQC: 2 analyze`. Its entries `QC: Black: format`, `QC: Ruff: lint`, and `QC: Pyright: type-check` become `QC: 1 Black: format`, `QC: 2 Ruff: lint`, and `QC: 3 Pyright: type-check`. These label corrections remove nothing, so they stay out of the reduction.
  - `fix_all_branches.py`: `run_powershell_branch` runs step `PoshQC: leak scan` between `PoshQC: analyze` and `PoshQC: test`, step numbers run in order, and the docstring names four steps.
  - Tests: `WF06-LEAK-SCAN-STEP` asserts order after `Analyze PowerShell`, the call, and both absences on the step's own body. `VT-LEAK-SCAN-TASK` asserts the task exists and calls `Invoke-PoshQCLeakScan`, parsing `.vscode/tasks.json` with full-line `//` comments allowed. New cases in `test_fix_all_branches.py` assert that the leak-scan command calls `Invoke-PoshQCLeakScan` and that a leak-scan failure stops before `PoshQC: test`.
  - Existing tests: `runs the format and analyze gates in the poshqc-static job (issue #953)` forbids only `Invoke-PoshQCTest`, and the job-set case and `poshqc-linux-hooks` cases are unaffected, so all are unchanged. The fake runner raises on an unconfigured step, so the `powershell` dictionaries of the four `test_fix_all*.py` files gain `PoshQC: leak scan`, and the ordered lists and own dictionary of `test_pipeline_runs_steps_in_order` in `test_fix_all.py` and `test_powershell_test_failure_returns_fail_result` in `test_fix_all_failure_paths.py` gain the step. `test_pipeline_succeeds_when_black_writes_to_stderr` still ends on `PoshQC: test`, and the format-failure and analyze-failure cases stop earlier, so they are unchanged.
  - Acceptance: the named new cases exist, `poshqc-static` has exactly one new step, and the staged diff holds no change to the `PoshQC: test` command and no `-n` argument.
- [ ] [P4-T2] Land the serial-command removals and the update of `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` in one commit whose subject carries `reduction: 0001`, across the files listed here, with no leak-scan change.
  - `scripts/dev_tools/fix_all_branches.py`: step `PoshQC: test` runs `exit (Invoke-PoshQCParallelTest -Root '.').ExitCode` after the module import. The step name stays.
  - `-n`, `auto` join `pytest_command` in `run_python_branch` of `scripts/dev_tools/fix_all_branches_extra.py`, the pytest step of `run_preflight_qc_with_capture` and the text of `build_preflight_qc_fix_prompt` in `scripts/dev_tools/atomic_executor/cli_preflight.py`, `QCRunner.FULL_TEST` and `full_test` in `scripts/dev_tools/atomic_executor/qc_runner.py`, the text of `PromptBuilder.build` in `scripts/dev_tools/atomic_executor/prompt_builder.py`, and `PYTHON_TOOLCHAIN_COMMANDS["pytest"]` in `scripts/dev_tools/atomic_executor/qc_toolchain.py`. `--cov=src/lexile_corpus_tuner` goes from each. `_run_pytest_scoped_with_expectations` and `addopts` are unchanged.
  - `.vscode/tasks.json`: `QC: Coverage: All Providers` and `QC: 5 Run All Checks` depend on `QC: 4 Pytest: run tests with coverage (parallel)` and `PoshQC: 4 test (Pester, parallel)` in place of their serial and unresolved entries. `"isDefault": true` moves from `QC: 4 Pytest: run tests` to `QC: 4 Pytest: run tests (parallel)`. `--cov=src/lexile_corpus_tuner` also goes from the args of the serial task `QC: 4 Pytest: run tests with coverage`, because `### 1. Parallel-only test gates` names that task and AC-19 covers what it names. The serial tasks stay.
  - The brief: the pytest bullet of `## Test Runtime` extends to the `fix_all` and executor commands, in all six `_BRIEF_COPIES`, edited in `.claude/skills/execution-environment/SKILL.md` and copied byte-for-byte. It lands here because it is wording of this reduction, and it holds no scan text. Every token of `test_brief_test_runtime_section_orders_diagnosis_before_parallelism` stays.
  - Tests: `test_run_full_runs_all_tools_on_entire_codebase` updates its exact list, because the command changes. New cases in `tests/scripts/dev_tools/test_fix_all_branches.py` assert that the test command holds `Invoke-PoshQCParallelTest` and `ExitCode` and no `Invoke-PoshQCTest`, and that `run_python_branch` passes `-n` and `auto` with and without coverage. New cases in `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` and `test_qc_runner.py` assert `-n` and `auto` in `run_preflight_qc_with_capture`, `full_test`, and `PYTHON_TOOLCHAIN_COMMANDS["pytest"]`. `test_build_includes_toolchain_instructions` in `test_prompt_builder.py` and `test_build_preflight_qc_fix_prompt_includes_workspace` in `test_cli_part3.py` each gain an `-n auto` assertion. `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1` gains `VT-AGGREGATES-PARALLEL-ONLY`, `VT-DEPENDS-ON-RESOLVES`, `VT-DEFAULT-TEST-TASK`, and `VT-SERIAL-TASKS-REMAIN`.
  - Tests unchanged, because they match by membership or pin the scoped run: `test_run_preflight_qc_with_capture_*`, `test_preflight_expected_*`, `test_phase_expected_fail_tolerates_pytest_failures`, `test_phase_unexpected_fail_raises_on_pytest_failures`, `test_full_loop_completes_when_black_changes_nothing`, `test_run_scoped_runs_all_tools_on_changed_files`, `test_pipeline_stops_on_pytest_failure`, and `test_pipeline_runs_steps_in_order`.
  - Entry `## Summary`: `Merge commit:` takes the full identifier that spec criterion AC-27 states, which is the merge commit of PR #1102 on `origin/main`.
  - Entry `## Files Changed`: each path this commit changes is added, and the opening sentence is amended so that it no longer bounds the list to the #1094 branch diff. `## Stored Patch`: the patch stays, and a sentence states that it does not hold these edits.
  - Entry `## Prior Text`: every changed file takes a Revert Block, except a byte-identical brief copy, which step 2 re-copies. `Get-ProcessReductionRevertBlock` reads only the first fence per label, so a file with separate hunks takes one block per hunk under the same path, and the section's opening sentences state this. An added test takes an empty `Prior` fence. Each `Prior` keeps the P4-T1 scan additions, so a revert does not remove the scan.
  - Entry `## Revert Steps`: the six labels stay in order. Step 1 states that the blocks of this later landing apply whether or not the patch check passes, because the patch does not hold them. Steps 5 and 6 name the tests this commit adds or changes, and step 5 also names the `## Test Runtime` entry that P5-T1 adds to `test_brief_passages_state_parallel_gate_facts`, because a revert of the bullet would otherwise fail that test. The names `test_brief_test_isolation_states_parallel_gates` and `test_contract_premortem_test_isolation_states_parallel_gates` stay.
  - Entry `## Revert Signals`: the bullet beginning `Before #1096 lands` becomes one about a leak that `Invoke-PoshQCLeakScan` misses. No new entry and no index row is added, and `docs/engineering/process-reductions/README.md` is unchanged.
  - Acceptance: the commit subject carries `reduction: 0001`, the named new cases exist, `git diff --name-only HEAD~1 HEAD` through `-C` lists the entry and only the paths this task names plus their brief copies, `git status --porcelain` through `-C` is empty after the commit, and the lines this commit adds outside the entry hold neither `LeakScan` nor `leak scan`.

### Phase 5 — Brief and Ledger Replay

- [ ] [P5-T1] Update the remaining brief passages in `.claude/skills/execution-environment/SKILL.md`, copy it to the other five paths of `_BRIEF_COPIES`, and extend `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`.
  - `## Test Isolation Checks`: append one bullet naming `Invoke-PoshQCLeakScan` after the last bullet. No existing bullet is reworded, and none is inserted between them, so the entry 0001 `Current` fence stays valid.
  - `## CI Shape and Required Checks`: add the leak scan to the stated contents of `poshqc / PowerShell QC static`, keeping that backticked context. `## CI-Only Failure Classes`: add that `Invoke-PoshQCLeakScan` is the check and that a stale allowlist entry fails the static job, keeping the existing shard sentence. `## PowerShell Route and PoshQC MCP Limits`: state that no MCP tool exposes the scan and that the executor reaches it through the `sh` launcher.
  - The new text uses none of the tokens of `test_brief_copies_carry_no_removed_run_tokens` or `PGW-SWEEP-SURFACES`, including `captured baseline`, `numeric baseline`, `coverage baseline`, `compared to baseline`, `regressed from baseline`, `does not regress`, and `targeted tests`.
  - Tests: `test_brief_test_isolation_states_parallel_gates` gains the required token `Invoke-PoshQCLeakScan`. `test_brief_passages_state_parallel_gate_facts` gains the scan phrase under `## CI-Only Failure Classes`, the scan token under `## PowerShell Route and PoshQC MCP Limits`, and a `## Test Runtime` entry for `fix_all`. `test_brief_ci_section_names_jobs_and_required_contexts` gains the leak-scan token. All names stay, because step 5 of the entry's `## Revert Steps` cites them. `test_brief_has_required_headings`, `test_brief_copies_are_byte_identical`, and `test_brief_has_no_g11_or_g12_findings` are unchanged.
  - Acceptance: the six files have one hash, and the bullets of `## Test Isolation Checks` that precede the new one are unchanged in a diff against the merge base of `origin/main` and `HEAD`.
- [ ] [P5-T2] Replay every Revert Block of `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` against the tree through `scripts/dev-tools/ProcessReductionLedger.psm1`, and write `<FEATURE>/evidence/other/ledger-fence-replay.<timestamp>.md`.
  - A step script takes the blocks from `Get-ProcessReductionSection` and `Get-ProcessReductionRevertBlock`, passes each target's text to `Invoke-ProcessReductionRevert`, and discards the result, so no file changes. It writes one row per block with its path and result, and `Test-ProcessReductionLedger` runs on the ledger read by `Read-ProcessReductionLedger`. A failed fence is corrected in the entry in a commit whose subject carries `reduction: 0001`, and this task repeats.
  - Acceptance: `EXIT_CODE: 0` from a script that exits non-zero on any throw or invalid ledger, the row count equals the block count, and `git status --porcelain` lists no replayed target.

### Phase 6 — Final QA Toolchain and Self-Review

Cheap stages run first. A fix re-runs the static stage and the gate that failed; another gate re-runs only when the fix changes a file it exercises. Each pass writes new artifacts.

- [ ] [P6-T1] Run the static stage on the branch-current `scripts/powershell/PoshQC/PoshQC.psd1` and write `powershell-format.<timestamp>.md`, `powershell-analyze.<timestamp>.md`, `python-black.<timestamp>.md`, `python-ruff.<timestamp>.md`, `python-pyright.<timestamp>.md`, and `leak-scan.<timestamp>.md` under `<FEATURE>/evidence/qa-gates/`.
  - Format output carries `Already formatted:` and `Formatted:` lines, counted case-sensitively from the line start, because a case-insensitive search for `Formatted:` also matches `Already formatted:`. A `Formatted:` line means a file changed: commit it and repeat this task. Analyzer findings come from the direct run over the `.ps1` and `.psm1` files of the `Get-PoshQCFileList -Root` file set. Black runs in check mode. The scan is `Invoke-PoshQCLeakScan -Root` over the repository with the committed allowlist.
  - Acceptance: zero `Formatted:` lines, a non-zero `Already formatted:` count, zero analyzer findings, and each `EXIT_CODE:` is 0.
- [ ] [P6-T2] Run the Pester gate with one background `Invoke-PoshQCParallelTest` run and write `<FEATURE>/evidence/qa-gates/pester-parallel.<timestamp>.md`.
  - The launcher exits with the returned `ExitCode`, which is read first. Counts come from merged `artifacts/pester/pester-junit.xml`. On a non-zero `ExitCode`, merged files can be stale, so failure detail comes from `artifacts/pester/parallel/shard-<i>/` and the failure rules in `## Execution Rules` apply.
  - Acceptance: `EXIT_CODE: 0`, zero failed tests, and the JUnit file holds testcases tagged `LS-K`, `LS-R`, `LA-`, `LI-`, `VT-`, and `WF06-LEAK-SCAN-STEP` plus each title named in spec Decision 3, with the tag counts listed in the artifact.
- [ ] [P6-T3] Run the pytest gate with one background `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov` run, with JSON coverage and JUnit output under `SCRATCH`, and write `<FEATURE>/evidence/qa-gates/pytest-parallel.<timestamp>.md`.
  - `PYTHONPATH` is set for this one command to the worktree `packages/discovery-runtime/src`, as the final #1094 gate did, so that coverage measures the worktree copy, and it is recorded as `<worktree>/packages/discovery-runtime/src`.
  - Worktree exclusion: no known failure applies. `test_execution_environment_fact_is_unchanged_across_copies` filters on `path.relative_to(REPO_ROOT).parts` in this tree, and the final #1094 gate ran from a worktree with zero failures. Any failure, including that test, follows `## Execution Rules`.
  - Acceptance: `EXIT_CODE: 0`, zero failures and errors, and `test_poshqc_bundled_module_files_match_repo_root_sources`, `test_brief_copies_are_byte_identical`, and `test_run_scoped_runs_all_tools_on_changed_files` pass in the JUnit file, with total line and branch percentages from the JSON report recorded.
- [ ] [P6-T4] Run Jest once through its normal workers in `extensions/drm-copilot/` and write `<FEATURE>/evidence/qa-gates/jest.<timestamp>.md`.
  - The suite is required because bundled resources change and `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` reads the repository. Item worktrees have no `node_modules`, so when `extensions/drm-copilot/node_modules/jest/package.json` is absent, `npm ci` runs in that folder first, writing only gitignored output. A denied install stops the task for the orchestrator.
  - Acceptance: `EXIT_CODE: 0` from `node run-jest.cjs` and zero failed tests.
- [ ] [P6-T5] Write per-file coverage to `<FEATURE>/evidence/qa-gates/coverage-thresholds.<timestamp>.md` from merged `artifacts/pester/powershell-coverage.xml` and the P6-T3 JSON report.
  - PowerShell files: `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1`, `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, and `scripts/dev-tools/DrmCopilotPromptSupport.ps1`. Python files: `scripts/dev_tools/fix_all_branches.py`, `scripts/dev_tools/fix_all_branches_extra.py`, and `cli_preflight.py`, `qc_runner.py`, `prompt_builder.py`, and `qc_toolchain.py` under `scripts/dev_tools/atomic_executor/`. Figures are read from the single gate run, and no earlier figure is compared.
  - Acceptance: the step exits non-zero unless each PowerShell file reaches 85% line coverage and each Python file reaches 85% line and 75% branch coverage. A shortfall is closed with tests, and Phase 6 repeats from P6-T1.
- [ ] [P6-T6] Check scope, the reduction commit, and evidence content in `<FEATURE>/evidence/qa-gates/scope-check.<timestamp>.md`, then check off `<FEATURE>/spec.md` and `<FEATURE>/user-story.md`.
  - Scope uses `git diff --name-status` from the merge base of `origin/main` and `HEAD`, with `git status --porcelain` as its companion. They list no added `.py` file, no path named under `Scope` in `## Execution Rules`, no `.github/workflows/ci.yml`, no `pyproject.toml`, and no new file under `docs/engineering/process-reductions/`. The `addopts` value holds no `-n`, and the `poshqc-linux-hooks` job text matches the merge base.
  - Every branch commit with `reduction: 0001` in its subject adds no line outside the entry that holds `LeakScan` or `leak scan`, and at least one such commit exists. A case-insensitive scan of `<FEATURE>/evidence/`, with tokens assembled at run time so the artifact cannot match itself, finds no host path and none of `single-process`, `seeded`, `shuffled`, `reversed-order`, and `focused run`.
  - Each box is checked only when the evidence in `## Acceptance Criteria Traceability` exists and passes. Both `CI-dependent:` criteria stay unchecked.
  - Acceptance: `EXIT_CODE: 0` from a step that exits non-zero on any match, every locally verifiable box is checked in both files, and both CI-dependent boxes are unchecked.
- [ ] [P6-T7] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`.
  - The artifact has one PASS, FAIL, or N/A row per checklist item, and it uses none of the tokens P6-T6 scans for. It lists spec Decisions 1, 2, and 3 for the owner report, including `EXEMPT-COUNT:`. A FAIL row is fixed, the QA loop re-runs from P6-T1, and the self-review is rewritten.
  - Acceptance: the artifact holds no FAIL row.

## Acceptance Criteria Traceability

IDs follow the order of `spec.md` `## Acceptance Criteria`.

| ID | Criterion (short form) | Tasks | Proof |
|---|---|---|---|
| AC-01 | Detects each kind; restored writes silent | P1-T1 | `LS-K`, `LS-R` |
| AC-02 | No restore, other name, literal; strings ignored | P1-T1 | `LS-K`, `LS-R` |
| AC-03 | Finding fields; `.ps1` helpers | P1-T1, P1-T2 | `LS-K`, `LS-R`, `LI-` |
| AC-04 | In-memory seam | P1-T1, P1-T2 | Test files, self-review |
| AC-05 | Scan throws in four cases | P1-T2 | `LI-` |
| AC-06 | Allowlist validation | P1-T2 | `LA-` |
| AC-07 | Default folders | P1-T2 | `LI-` |
| AC-08 | CI step shape | P4-T1 | `WF06-LEAK-SCAN-STEP`, `scope-check` |
| AC-09 | Every finding fixed or allowlisted | P2-T1, P3-T3, P3-T4 | `leak-scan-raw`, `leak-scan-classification`, `leak-scan` |
| AC-10 | `TestHelpers.ps1` | P3-T1 | `pester-parallel` |
| AC-11 | Batch-budget snapshots | P3-T1 | `pester-parallel` |
| AC-12 | Decision 3 tests | P3-T2 | `pester-parallel` titles |
| AC-13 | `Enter-DrmCopilotShell.Tests.ps1` | P3-T2 | `pester-parallel` |
| AC-14 | `PoshQC.TestingInvokeConfigPaths.Tests.ps1` | P3-T2 | `pester-parallel` |
| AC-15 | Bundle, parity, exports, README | P1-T1, P1-T2 | `test_poshqc_bundled_module_files_match_repo_root_sources` |
| AC-16 | New module coverage | P6-T5 | `coverage-thresholds` |
| AC-17 | Commands pass `-n auto`; `addopts` clean | P4-T2 | P4-T2 new cases, `scope-check` |
| AC-18 | Prompts and literal; scoped run unchanged | P4-T2 | P4-T2 cases, `test_run_scoped_runs_all_tools_on_changed_files` |
| AC-19 | Stale `--cov` flag gone | P4-T2 | `test_run_full_runs_all_tools_on_entire_codebase`, P4-T2 cases |
| AC-20 | `fix_all` steps | P4-T1, P4-T2 | `test_fix_all*.py` |
| AC-21 | Aggregates parallel only | P4-T2 | `VT-AGGREGATES-PARALLEL-ONLY` |
| AC-22 | Every `dependsOn` resolves | P4-T1, P4-T2 | `VT-DEPENDS-ON-RESOLVES` |
| AC-23 | Default test task; serial tasks; scan task | P4-T1, P4-T2 | `VT-DEFAULT-TEST-TASK`, `VT-SERIAL-TASKS-REMAIN`, `VT-LEAK-SCAN-TASK` |
| AC-24 | `## Test Isolation Checks` and mirrors | P5-T1 | `test_brief_test_isolation_states_parallel_gates`, `test_brief_copies_are_byte_identical` |
| AC-25 | Four other brief passages | P4-T2, P5-T1 | `test_brief_passages_state_parallel_gate_facts`, `test_brief_ci_section_names_jobs_and_required_contexts`, `test_brief_copies_carry_no_removed_run_tokens` |
| AC-26 | Entry paths, blocks, patch statement | P4-T2 | `PRL-REAL-LEDGER-AGREES`, `ledger-fence-replay` |
| AC-27 | Merge commit; revert signal; no new entry | P4-T2 | `PRL-REAL-LEDGER-AGREES`, `scope-check` |
| AC-28 | Each `Current` occurs once | P5-T2 | `ledger-fence-replay` |
| AC-29 | Separate `reduction: 0001` commit | P4-T2 | `scope-check` |
| AC-30 | Branch scope | P6-T6 | `scope-check` |
| AC-31 | Gates at zero failures | P6-T2, P6-T3 | `pester-parallel`, `pytest-parallel` |
| AC-32 | Jest at zero failures | P6-T4 | `jest` |
| AC-33 | Evidence cites only the gates and the scan | P6-T6 | `scope-check` |
| CI-01 | Scan step ran on the PR head | P4-T1 | Orchestrator; stays unchecked |
| CI-02 | `CI Required Gate` green | All | Orchestrator; stays unchecked |

## Pre-Mortem

- Review checklists: A reviewer could read the serial-command edits as a reduction with no entry, which is Blocking, or read the `LASTEXITCODE` exemption as a blanket suppression. P4-T2 carries the entry update in its own token-bearing commit, P6-T6 proves that commit holds no scan change, and P6-T7 lists Decisions 1, 2, and 3 and `EXEMPT-COUNT:` for the owner report.
- Coverage: The new modules enter the population automatically, so a thin suite would fail late. The pure core holds the logic and seam defaults stay one line. `DrmCopilotPromptSupport.ps1` last measured 86.84% in #1067 evidence, so P3-T2 adds a default-path case per seam to keep the new default lines covered. P6-T5 reads each changed file from the single gate run, and a shortfall fails its step.
- Mirror parity: P5-T1 is the brief-update task, in all six byte-identical copies, and P4-T2 carries the `## Test Runtime` bullet to the same six copies. The `PoshQC mirror` rule keeps `test_poshqc_bundled_module_files_match_repo_root_sources` green per task, and P1-T1 and P1-T2 add `POSHQC_PARITY_PATHS` entries. No pack manifest or extension source lists PoshQC sub-modules, as a search of `extensions/drm-copilot/` confirmed.
- File size: `PoshQC.LeakScan.psm1` is held to the 500-line guidance, with a named overflow test file. `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` is near 700 lines, so it gains one assertion only. `test_qc_runner.py` is near 670 lines, so its new cases stay short. New fix-all cases go to `test_fix_all_branches.py`. No file nears the 800-line block.
- Test isolation: The gates are one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix, with `Invoke-PoshQCLeakScan` as the static check. New tests use in-memory text and no temporary files. P3-T1 moves the `tree.Tests.ps1` dot-source, because removing `global:` would otherwise break a discovery-scope load. The P3-T2 `Push-Location` sits where R2 pairs it, or the scan would report the fix itself.
- CI-only behavior: The scan runs on `windows-latest` while paths compare with forward slashes, so paths normalize first and fixtures hold no drive letter. A stale allowlist entry fails the static job, so P3-T4 and P6-T1 run the same scan first. The batch-budget suites also run in the Linux hook job, and their snapshots use no paths. The checkpoint in the item worktree must select the large route, because more than three production PowerShell files and more than three production Python files change, and a `POWERSHELL_LARGE_PATH_REQUIRED` or `PYTHON_LARGE_PATH_REQUIRED` denial stops the executor for the orchestrator.
- Evidence: Scan and gate values come from files and direct runs, never MCP summaries. The ledger `Current` check has no test, so P5-T2 records a replay after the brief edit. Runner output stays under `SCRATCH` because it holds host paths, and P6-T6 scans `<FEATURE>/evidence/` for host paths and excluded run citations. Raw findings stay in `evidence/baseline/`, so each fix or entry traces to a row.

## Test Plan

- Unit: `PoshQC.LeakScan.Tests.ps1` and `PoshQC.LeakAllowlist.Tests.ps1` hold the scan cases, in memory, through seams. `Enter-DrmCopilotShell.Tests.ps1` holds the location seam cases.
- Integration: the scan over the repository (P2-T1, P3-T4, P6-T1), `test_fix_all*.py` for the pipeline order, `PoshQcWorkflow.Tests.ps1`, and `VsCodeQualityTasks.Tests.ps1`.
- Manual/CLI: the ledger fence replay (P5-T2).
- Coverage evidence: `evidence/qa-gates/pester-parallel.<timestamp>.md`, `pytest-parallel.<timestamp>.md`, and per-file thresholds in `coverage-thresholds.<timestamp>.md`.

## Open Questions / Notes

- Execution is on hold for an owner decision recorded in spec `## Open Questions`. Phase 0 task numbering can be extended after P0-T2.
- Premise correction: `test_execution_environment_fact_is_unchanged_across_copies` is already fixed in this tree, so the pytest gate names no expected failure (P6-T3).
- Premise correction: `## Prior Text` in the ledger README asks for one block per canonical file, while the parser reads one fence per label and accepts repeated paths. P4-T2 uses one block per hunk, because a single span across `QCRunner.FULL_TEST` and `full_test` would copy most of `qc_runner.py` into the entry.
- Interpretation for the orchestrator to confirm: P4-T2 places the `## Test Runtime` bullet in the reduction commit, and it removes the stale `--cov` flag from a serial task that spec `### 1. Parallel-only test gates` names but Decision 4 does not list as an edited command.
- Interpretation for the orchestrator to confirm: P4-T2 amends `## Revert Steps` of the entry, which spec `### 5. Process-reduction ledger` does not list, because step 1 would otherwise skip the new blocks whenever the patch check passes.
- Reported without a task: `FAILED_NODEID_RE` under xdist is not exercised by these gates, because none of them runs the executor tool with an expected failure. `QCRunner.FULL_TEST` is expected to collect no coverage after the flag removal, as the spec records.
- Decisions 1, 2, and 3 and the Linux hook suites are reported to the owner at PR completion. The orchestrator owns that report, the PR, CI monitoring, and merge.
