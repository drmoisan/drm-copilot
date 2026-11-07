# parallel-only-test-gates-and-leak-scan - Plan

- **Issue:** #1094
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-06T20-01
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Branch:** feature/parallel-only-test-gates-and-leak-scan-1094

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- Python: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md), [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- Requirements: `spec.md`, `user-story.md`, and `research/research.2026-11-06.md` in this folder. Spec `## Decisions` are settled.

**All work must comply with these policies; do not duplicate their content here.** Tool routes, launchers, command-text restrictions, and CI shape are owned by the `execution-environment` skill and are not restated.

## Execution Rules

Terms: `<FEATURE>` is `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`. `SCRATCH` resolves to `<session scratchpad>/issue-1094/`, and every scratch file, helper, JUnit file, coverage report, and log lives under it. Evidence records the token, never a host path.

These rules apply to every task:

- **Commit and push.** Each task ends with one commit and one push of that commit to `feature/parallel-only-test-gates-and-leak-scan-1094`. The executor stages only the paths the task names, with worktree git and no `git -C`. Evidence the task writes is staged with it. `.claude/agent-memory` is never staged.
- **`testResults.xml`.** This tracked file is rewritten by Pester runs. Restore it with `git checkout -- testResults.xml` before staging.
- **Poetry.** Do not run an unqualified `poetry install` from the item worktree: the shared `.venv` would be repointed at it.
- **Parallel gates only (owner directive, overriding the skill text current at plan time).** The Pester gate is one `Invoke-PoshQCParallelTest` run. The pytest gate is one `pytest -n auto` run. Jest runs through its normal workers. A suite is re-run only after a fix. No task requires a single-process, seeded-shuffle, reversed-order, or comparison run. A focused run of one test file to debug a specific failure is debugging only: it is never a gate, an acceptance condition, or evidence, and it is not recorded.
- **Test proof.** A task that adds or changes a test is accepted on the named test's presence and content. Its pass result is proved once, by the gates in Phase 6.
- **Gate failures.** No condition waives a failure. A failure is fixed and the failed gate is re-run. A failure that traces to the live gitignored `artifacts/orchestration/orchestrator-state.json` is fixed by test isolation in that suite when the suite is in this plan's file set. Otherwise the executor stops and returns to the orchestrator, naming the test and the state it read.
- **PoshQC mirror.** A task that edits any file under `scripts/powershell/PoshQC/` copies that file byte-for-byte to `extensions/drm-copilot/resources/powershell/PoshQC/` in the same task, so `test_poshqc_bundled_parity.py` never sits red between tasks.
- **Text mirrors.** A task that edits a mirrored text surface edits every copy it names and its contract test in the same task, so no mirror test sits red between tasks.
- **Evidence.** Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The recorded `EXIT_CODE:` must go non-zero when the task's asserted value fails. Filename stamps are the write time in UTC.
- **Scope.** Do not edit `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell/`, `.agents/skills/python/`, or any Epic #1019 folder. This plan contains no PR, CI-monitoring, or merge task: the orchestrator owns those.

## Finding Classification Rule

Remediation is a derivation from the first scan. The input is every `FINDING:` row of the lexicographically greatest `<FEATURE>/evidence/baseline/leak-scan-raw.*.md`. Each row is read against the tree at the commit of that artifact. Rows are grouped by the allowlist key (`path`, `kind`, `name`). Apply the classes below in order to each row; the first match decides.

| Class | Result | Predicate on the file text | Disposition |
|---|---|---|---|
| C1 | Exempt | `kind` is `global-variable` and `name` is `LASTEXITCODE` | Covered by the single `exemptGlobalVariables` entry (spec Decision 2). Counted, with no per-row action |
| C2 | False positive | The same file restores the same key in a `finally`, `AfterEach`, or `AfterAll` block that runs after the write, through a route rules R1 to R5 do not follow: a scriptblock held in a variable and invoked from that block, `$ExecutionContext.SessionState.InvokeProvider`, or a function reached from a cleanup block through another function | Allowlist entry. The reason names the route and the cleanup block |
| C3 | False positive | The write sits in a scriptblock passed to `Start-Job`, or in a script block handed to a child `pwsh` process, so it never runs in the test process | Allowlist entry. The reason names the child process |
| C4 | False positive | The write is in a named function in a `.ps1` helper that is not a `*.Tests.ps1` file, and every call of that function under `tests/` sits inside an R1 to R4 position for the same key in the calling file | Allowlist entry. The reason names the helper and states that callers restore |
| T | True leak | None of the above | Fixed on both sides, as below |

- **Group rule.** If any row of a key group is class T, every row of that group is treated as T. No allowlist entry is written for the group, because an entry has no line and would hide the leak.
- **Leaking side.** Snapshot the prior value before the write and restore it in `finally`, `AfterEach`, or `AfterAll`, in the form used by `enforce-python-batch-budget-routing.Tests.ps1`.
- **Relying side.** Search `tests/scripts` for the key's name. A file that reads the key and neither sets it nor is the writer is changed to set its own state. The search and its result are recorded in the row. Dynamic keys record `DYNAMIC` and the search is over the writer's file only.
- **Known cases.** The research predicts these, and the rule, not this list, decides them: `tests/scripts/powershell/Support/TestHelpers.ps1` `global-function` `Import-ScriptFunction` is T, because the only removal is in another file; `tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1` rows are C2 through `$script:restoreEnvironment`, or C1 for `LASTEXITCODE`. A row the research did not predict is classified the same way.
- **Stop condition.** A `PARSE-ERROR:` row is corrected in the file when the file is not an intentional fixture. An intentional unparseable fixture under `tests/` stops the run for the orchestrator, because spec `## API / CLI Surface` makes a parse error a failure.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reading and Baseline Capture

No full-suite baseline run is performed. The owner directive permits one run per gate, re-run only after a fix, so a pre-change suite run is a comparison run and is waived. The waiver overrides `## Coverage Evidence Contract (Mandatory when policy requires coverage)` for the baseline half only: the final figures in P6-T7 are still numeric and still gate.

- [ ] [P0-T1] Read the policy files in the `policy-compliance-order` order, including `.claude/rules/powershell.md`, `.claude/rules/python.md`, and `.claude/rules/ci-workflows.md`, then read `<FEATURE>/spec.md`, and write `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the list of files read.
- [ ] [P0-T2] Capture the PowerShell static baseline in `<FEATURE>/evidence/baseline/powershell-format.<timestamp>.md` and `<FEATURE>/evidence/baseline/powershell-analyze.<timestamp>.md`.
  - Format runs check-only through a no-op `-WriteFile` seam on the branch-current module, so no tracked file changes. Analyzer findings come from a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
  - Acceptance: `Output Summary:` states the would-format count and the analyzer finding count as numbers, and `git status --porcelain` shows no tracked file changed by the step.
- [ ] [P0-T3] Capture the Python static baseline in `<FEATURE>/evidence/baseline/python-black.<timestamp>.md`, `<FEATURE>/evidence/baseline/python-ruff.<timestamp>.md`, and `<FEATURE>/evidence/baseline/python-pyright.<timestamp>.md`.
  - Black runs in check mode.
  - Acceptance: each artifact records the tool's real exit code and a numeric finding count.
- [ ] [P0-T4] Write `<FEATURE>/evidence/baseline/pester-baseline-waiver.<timestamp>.md` recording that no Pester baseline run is performed, by owner directive. No suite runs in this task.
  - Acceptance: the artifact carries `Timestamp:`, `Command: none`, `EXIT_CODE: 0`, and an `Output Summary:` that states the waiver and names `scripts/powershell/PoshQC/PoshQC.psm1` and `scripts/dev-tools/DrmCopilotPromptSupport.ps1` as the changed files gated in P6-T7.
- [ ] [P0-T5] Write `<FEATURE>/evidence/baseline/pytest-baseline-waiver.<timestamp>.md` recording that no pytest baseline run is performed, by owner directive. No suite runs in this task.
  - Acceptance: the artifact carries `Timestamp:`, `Command: none`, `EXIT_CODE: 0`, and an `Output Summary:` that states the waiver and names `scripts/dev_tools/fix_all_branches.py`, `scripts/dev_tools/fix_all_branches_extra.py`, `scripts/dev_tools/atomic_executor/prompt_builder.py`, and `scripts/dev_tools/atomic_executor/cli_preflight.py` as the changed files gated in P6-T7.

### Phase 1 — Leak Scan and Allowlist

The kinds and rules are defined in spec `### 2. Static leak scan` (`Detected kinds` and the restore rule table) and `## API / CLI Surface`. Tests follow the module-collision guard in `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, use single-quoted in-memory script text, create no temporary files, and hold `-ForEach` tables inline. Every `It` title starts with the stated tag, and sibling titles stay unique when case is folded, as `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` requires.

- [ ] [P1-T1] Create `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1` with AST write detection, and `tests/scripts/powershell/PoshQC/PoshQC.LeakScan.Tests.ps1`, and register the module in `scripts/powershell/PoshQC/PoshQC.psm1`.
  - Behavior: an internal function parses with `[System.Management.Automation.Language.Parser]::ParseInput`, never `ParseFile`, and returns one object per write of each form in the `Detected kinds` table, with `Path`, `Line`, `Kind`, and `Name`. Names compare case-insensitively, all `env` routes share one key per name, `Function:\global:X` and `Function:\X` normalize to one key, and dynamic names key on the argument's expression text.
  - Register `PoshQC.LeakScan.psm1` in the `foreach` sub-module list of `PoshQC.psm1`. Add it to `POSHQC_PARITY_PATHS` in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. `test_poshqc_bundled_module_files_match_repo_root_sources` is the asserting test and stays otherwise unchanged.
  - Tests, tag `LS-K`: each form of each kind is detected; aliases `cd`, `chdir`, `sl`, and `pushd`; both `Environment` spellings; here-strings, command strings, and `Mock`-named commands are not detected; `Line` and `Name` values are exact.
  - Acceptance: the `LS-K` cases cover every row of the `Detected kinds` table, the module imports without error, and the bundle copy exists.
- [ ] [P1-T2] Add restore pairing and `Get-PoshQCLeakFinding -Content <string> -Path <repository-relative path>` to `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1`, with tests in `tests/scripts/powershell/PoshQC/PoshQC.LeakScan.Tests.ps1`.
  - Behavior: rules R1 to R5 apply as the spec states. A write inside `finally`, `AfterEach`, or `AfterAll` is a restore and is never reported, and an R5 cleanup helper's operations are restores. Output sorts by path, then line. A parse error throws and names the path.
  - Tests, tag `LS-R`: one positive case per rule; restore absent; restore of a different name; a later literal assignment is reported; a `$name` write pairs with a `$name` restore; `Pop-Location` and `Set-Location` restore `location`; a parse error throws; a `.ps1` helper path behaves as a `*.Tests.ps1` path.
  - Acceptance: every `LS-R` case exists, and `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1` stays at or below 500 logical lines. If the test file would pass 700 lines, the `LS-R` cases move to `tests/scripts/powershell/PoshQC/PoshQC.LeakScanPairing.Tests.ps1`.
- [ ] [P1-T3] Create `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1` with pure allowlist validation and comparison, and `tests/scripts/powershell/PoshQC/PoshQC.LeakAllowlist.Tests.ps1`, and register the module in `scripts/powershell/PoshQC/PoshQC.psm1` and `POSHQC_PARITY_PATHS`.
  - Behavior: validation throws and names the file for each condition in spec `Contracts and validation rules`, including any `exemptGlobalVariables` name other than `LASTEXITCODE`. Blank or absent input is an empty allowlist. Comparison takes raw findings and returns unallowed findings and stale entries. `path` compares ordinally after backslashes normalize to forward slashes.
  - Tests, tag `LA-`: a valid file; absent and blank input; wrong version; bad JSON; unknown `kind`; blank field; missing and blank `reason`; absolute path; `..` segment; duplicate entry; a rejected exempt name; exempt removal; an allowlisted finding; an unallowed finding; a stale entry.
  - Acceptance: every listed `LA-` case exists, and the fixtures hold no drive letter.
- [ ] [P1-T4] Add public `Invoke-PoshQCLeakScan` to `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1`, export it from `scripts/powershell/PoshQC/PoshQC.psm1` and `scripts/powershell/PoshQC/PoshQC.psd1`, and describe it in `scripts/powershell/PoshQC/README.md`.
  - Behavior: the signature in spec `## API / CLI Surface`. It is the only I/O in the scan, and its seam defaults are one-line scriptblocks. Default folders are the `Get-PoshQCScanConfigFolder` result filtered to those under `tests/`; an absent folder is skipped, and no folders is not an error. Only `.ps1` files are read. Each finding, stale entry, and parse error goes to `-Logger` as one message with `path | line | kind | name` fields, repository-relative. Any of them ends in one `throw`. `Invoke-PoshQCSuite` and `Invoke-PoshQCAnalyze` are unchanged.
  - The README `## Functions` list gains the function, and its day-to-day guidance names `Invoke-PoshQCParallelTest` as the gate.
  - Tests, tag `LI-`, in `tests/scripts/powershell/PoshQC/PoshQC.LeakAllowlist.Tests.ps1` through injected seams only: passes when every finding is exempt or allowlisted; throws on an unallowlisted finding, a parse error, an invalid allowlist, and a stale entry; the thrown text names path, line, and kind; helper `.ps1` files are enumerated; folders outside `tests/` are ignored; an absent allowlist file is empty.
  - Acceptance: `Get-Command Invoke-PoshQCLeakScan` resolves after importing each of `PoshQC.psm1` and `PoshQC.psd1`, and every `LI-` case exists.

### Phase 2 — First Repository Scan

- [ ] [P2-T1] Run `Invoke-PoshQCLeakScan` over the repository with `config/poshqc-leak-allowlist.json` absent, and write the raw findings to `<FEATURE>/evidence/baseline/leak-scan-raw.<timestamp>.md`.
  - The step script collects logger messages through the `-Logger` seam, catches the expected throw, and writes one `FINDING: <path> | <line> | <kind> | <name>` row per finding and one `PARSE-ERROR:` row per parse error, sorted by path, then line. It exits 1 only when the throw occurred and at least one row was written, and 255 otherwise. The artifact declares `ExpectedExitCode: 1`.
  - Acceptance: `EXIT_CODE: 1`, the artifact holds at least one `FINDING:` row, `Output Summary:` states the count per kind and the count of `LASTEXITCODE` rows, and every row path is repository-relative.

### Phase 3 — Remediation

- [ ] [P3-T1] Classify every row of the latest `<FEATURE>/evidence/baseline/leak-scan-raw.*.md` under `## Finding Classification Rule` and write `<FEATURE>/evidence/other/leak-scan-classification.<timestamp>.md`.
  - One row per raw finding carries path, line, kind, name, class, the predicate text that matched, and the planned disposition. For a class T row, it also carries the relying-side search and its result. The header states `EXEMPT-COUNT:`, the count reported to the owner under spec Decision 2.
  - Acceptance: the row count equals the raw `FINDING:` count, every row has one class, and no key group mixes T with another class.
- [ ] [P3-T2] Define `Import-ScriptFunction` without `global:` in `tests/scripts/powershell/Support/TestHelpers.ps1`, and update `tests/scripts/dev-tools/tree.Tests.ps1` and `tests/scripts/dev-tools/run-actionlint.Tests.ps1`.
  - `tree.Tests.ps1` dot-sources the helper at file scope, which runs during discovery and reaches `BeforeAll` only because the function is global. Move the `$scriptRoot` assignment and the dot-source into its `BeforeAll`, ahead of the first `Import-ScriptFunction` call.
  - `run-actionlint.Tests.ps1` drops `$script:describeHadImportScriptFunction`, its `AfterAll` removal block, and the comment text about that helper. Its Archive module cleanup stays.
  - Disposition of other callers: `new-potential-entry.Tests.ps1` and `post-codex-worktree-session.Tests.ps1` already dot-source inside `BeforeAll`, so they are unchanged.
  - Acceptance: `TestHelpers.ps1` holds no `global:` token, `run-actionlint.Tests.ps1` holds no `Function:\Import-ScriptFunction` path, and `tree.Tests.ps1` has no dot-source outside `BeforeAll`.
- [ ] [P3-T3] Snapshot and restore each set environment value in `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`, `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`.
  - Each `$env:` name a file assigns is captured in `BeforeEach` and restored in `AfterEach` in the `$script:Prior...` form of `enforce-python-batch-budget-routing.Tests.ps1`.
  - Acceptance: no `AfterEach` in the three files assigns a literal `$null` to an `$env:` name, and each assigned name has one snapshot.
- [ ] [P3-T4] Add a `-GetLocationPath` seam to `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` in `scripts/dev-tools/DrmCopilotPromptSupport.ps1`, and rewrite the two process-directory tests in `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`.
  - Production: the parameter defaults to `{ $PWD.ProviderPath }` and replaces the direct `$PWD.ProviderPath` read, so default resolution is unchanged. Callers `Get-DrmCopilotPromptPath`, `Set-DrmCopilotPrompt`, and `Start-DrmCopilotPromptSession` keep their calls, and the existing delegates named `GetLocationPath` on the last two keep their defaults.
  - Tests: the cases `resolves a relative path against the PowerShell location, not the process directory` and `resolves a relative virtual environment path against the PowerShell location, not the process directory` keep their titles, inject a fixture base through the seam, and assert against it. Each Context gains a default-path case that compares with `Join-Path $PWD.ProviderPath ...`. All other cases in the file are unaffected and unchanged.
  - Acceptance: `Enter-DrmCopilotShell.Tests.ps1` holds no `Push-Location` and no `[Environment]::CurrentDirectory`, and each of the two Contexts has one seam case and one default-path case.
- [ ] [P3-T5] Pin the location and replace captures in `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1`.
  - The test whose title begins `defaults $Root to $PWD.ProviderPath when -Root is not supplied` applies the `PR10-OMITTED-ROOT-USES-CURRENT-LOCATION` pattern from `PoshQC.ParallelRunner.Tests.ps1`: pin the location in `try`/`finally` and read it with `Get-Location`. Every `Set-Variable -Scope 1` capture becomes a write to a holder hashtable declared in the test. `Invoke-PoshQCTest` needs no production change.
  - Acceptance: the file holds no `Set-Variable -Scope 1`, and the omitted-root test reads no `$PWD`.
- [ ] [P3-T6] Fix every class T row of kind `env` from the latest `<FEATURE>/evidence/other/leak-scan-classification.*.md`, on both sides, in the test files those rows name under `tests/scripts/`.
  - The file set is derived from the rows. A row already fixed by P3-T2 to P3-T5 is marked with that task. When no such row exists, the task records `NONE` in the classification artifact.
  - Acceptance: the classification artifact is updated so every `env` class T row names its fix and its relying-side result.
- [ ] [P3-T7] Fix every class T row of kind `global-variable`, `global-function`, `location`, and `process-directory` from the latest `<FEATURE>/evidence/other/leak-scan-classification.*.md`, on both sides, in the test files those rows name under `tests/scripts/`.
  - The same derivation applies as in P3-T6.
  - Acceptance: the classification artifact is updated so every such row names its fix and its relying-side result.
- [ ] [P3-T8] Create `config/poshqc-leak-allowlist.json` from the classification.
  - `version` is 1. `exemptGlobalVariables` holds the one `LASTEXITCODE` entry with the spec Decision 2 reason. `entries` holds one item per C2, C3, or C4 key group, with a reason that names the class route. No entry carries a line number.
  - Acceptance: the entry count equals the count of false-positive key groups in the classification artifact, and no entry key belongs to a class T group.
- [ ] [P3-T9] Run `Invoke-PoshQCLeakScan` with the committed `config/poshqc-leak-allowlist.json` and write `<FEATURE>/evidence/regression-testing/leak-scan-remediated.<timestamp>.md`.
  - A reported finding or stale entry returns to the class that owns it. It is fixed, and this task is repeated.
  - Acceptance: `EXIT_CODE: 0`, from the launcher's exit on no throw.

### Phase 4 — Quality-Stage Wiring

The CI step follows remediation because the step fails while findings remain.

- [ ] [P4-T1] Add the step `Scan Pester tests for leaked state` to `poshqc-static` in `.github/workflows/_poshqc.yml`, after `Analyze PowerShell`, and add its case to `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`.
  - The step imports the module and calls `Invoke-PoshQCLeakScan -Root` with the workspace, under `shell: pwsh`, with no `continue-on-error` and no step-level `if`. No job, matrix entry, or required context changes.
  - Tests: a new case tagged `WF06-LEAK-SCAN-STEP` asserts order after `Analyze PowerShell`, the call, and both absences on the step's own body. `runs the format and analyze gates in the poshqc-static job (issue #953)` and the job-set cases are unaffected and unchanged. `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` is unaffected, because `ci.yml` does not change.
  - Acceptance: `WF06-LEAK-SCAN-STEP` exists, and `poshqc-static` has exactly one new step.
- [ ] [P4-T2] Add the task `PoshQC: 2c leak scan` to `.vscode/tasks.json`, point `QC: Coverage: All Providers` and `QC: 5 Run All Checks` at the parallel tasks, and add `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`.
  - In `QC: Coverage: All Providers`, `dependsOn` names `QC: 4 Pytest: run tests with coverage (parallel)` and `PoshQC: 4 test (Pester, parallel)`. In `QC: 5 Run All Checks`, the Pytest entry and the Pester entry become the same two tasks, and `PoshQC: 2c leak scan` follows `PoshQC: 2 analyze`. The serial tasks stay for debugging.
  - Tests, tag `VT-`: the leak-scan task exists and calls `Invoke-PoshQCLeakScan`; neither aggregate depends on `PoshQC: 4 test (Pester)` or `QC: 4 Pytest: run tests with coverage`; those two serial tasks still exist.
  - Acceptance: every `VT-` case exists.
- [ ] [P4-T3] Add step `PoshQC: leak scan` after `PoshQC: analyze` in `scripts/dev_tools/fix_all_branches.py`, and make `PoshQC: test` run `Invoke-PoshQCParallelTest` and exit with its `ExitCode`.
  - The step name `PoshQC: test` stays, and step numbers run in order. The function docstring names the new step.
  - Existing tests, updated because the fake runner raises on an unconfigured step: add a `PoshQC: leak scan` response to the `powershell` dictionaries in `tests/scripts/dev_tools/test_fix_all.py`, `tests/scripts/dev_tools/test_fix_all_failure_paths.py`, `tests/scripts/dev_tools/test_fix_all_branches.py`, and `tests/scripts/dev_tools/test_fix_all_json_cancel.py`. Update the ordered lists in `test_pipeline_runs_steps_in_order` and in the Pester-failure case of `test_fix_all_failure_paths.py`. The format-failure and analyze-failure cases stop before the new step and are unchanged.
  - New tests in `tests/scripts/dev_tools/test_fix_all_branches.py`: the leak-scan command calls `Invoke-PoshQCLeakScan`, a leak-scan failure stops before `PoshQC: test`, and the test command holds `Invoke-PoshQCParallelTest`, `ExitCode`, and no `Invoke-PoshQCTest`.
  - Acceptance: the three new tests exist, and all four dictionaries carry the step.
- [ ] [P4-T4] Add `-n auto` to the pytest command in `scripts/dev_tools/fix_all_branches_extra.py` and to the toolchain text in `scripts/dev_tools/atomic_executor/prompt_builder.py` and `scripts/dev_tools/atomic_executor/cli_preflight.py`.
  - These are small edits to existing Python. Spec `### 1. Parallel-only test gates` covers any other executor or preflight text, and `QC: 0 Fix All` runs the first file. The runner commands in `scripts/dev_tools/atomic_executor/qc_runner.py` and `qc_toolchain.py` are unchanged, because they are code paths of that legacy tool and not stated gates.
  - Tests: the REQ-001 assertions in `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` and `test_build_preflight_qc_fix_prompt_includes_workspace` in `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` stay valid and each gains an assertion for `-n auto`. A new case in `tests/scripts/dev_tools/test_fix_all_branches.py` asserts the pytest command carries `-n` and `auto`.
  - Acceptance: the three assertions exist.

### Phase 5 — Contract Text and Contract Tests

Negative tokens must not match the retained headings `## Test Isolation Checks` and `## CI Shape and Required Checks`, the frontmatter description, or the sentence that states the debugging exception. Replacement text therefore avoids the negative tokens below.

- [ ] [P5-T1] Fix `test_execution_environment_fact_is_unchanged_across_copies` in `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`.
  - The filter tests absolute `path.parts`, so any checkout under `.claude/worktrees/` finds zero copies. Test `path.relative_to(REPO_ROOT).parts` instead. The asserted count stays six, and the exclusion set is unchanged.
  - Acceptance: the filter reads the parts relative to `REPO_ROOT`.
- [ ] [P5-T2] Update the brief in all six copies of `execution-environment/SKILL.md`, and replace `test_brief_test_isolation_requires_seeded_pester_shuffle` in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`.
  - Edit `.claude/skills/execution-environment/SKILL.md`, then copy its bytes to the other five paths in `_BRIEF_COPIES`.
  - `## Test Isolation Checks`: the heading stays. The body states that tests create no temporary files; that `Invoke-PoshQCLeakScan` runs in the fast quality stage and in `poshqc / PowerShell QC static`; one `Invoke-PoshQCParallelTest` run; one `pytest -n auto` run; Jest through its normal workers; each gate reaches zero failures and is re-run only after a fix; a focused run of one test file is debugging only and is never a gate or evidence; serial tasks remain for debugging one failure and are not gates; a leak is fixed on both sides; and the parallel gates govern where a policy file names a toolchain test command.
  - `## Test Runtime`: delete the clause that makes the serial pytest command the isolation reference.
  - `## CI-Only Failure Classes`: replace the shard bullet with the statement that files in one shard share a process, so a leak surfaces when shard contents change, and that `Invoke-PoshQCLeakScan` is the check.
  - `## PowerShell Route and PoshQC MCP Limits`: name `Invoke-PoshQCParallelTest` as the branch-current route. State that merged JUnit and coverage exist only after a fully green run, that `ExitCode` is read first, and that failure detail is under `artifacts/pester/parallel/shard-<i>/`. The tokens of `test_brief_states_executor_route_and_poshqc_output_limits` stay.
  - `## CI Shape and Required Checks`: add the leak scan to the stated contents of `poshqc / PowerShell QC static`. The tokens of `test_brief_ci_section_names_jobs_and_required_contexts` stay.
  - `## Contract Tests That Pin Mirrored Files`: add `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
  - Tests: `test_brief_test_isolation_states_parallel_gates_and_leak_scan` requires `Invoke-PoshQCParallelTest`, `pytest -n auto`, `Invoke-PoshQCLeakScan`, `normal workers`, `re-run only after a fix`, `debugging only`, `never a gate or evidence`, and `parallel gates govern`. `test_brief_copies_carry_no_removed_run_tokens` reads all of `_BRIEF_COPIES` and rejects, case-insensitively, `single-process`, `seeded`, `shuffled`, `reversed-order`, `--randomize`, `at least three seeds`, `which is the CI shape`, `isolation reference`, and `in addition to the serial runs`. `test_brief_passages_state_parallel_gate_facts` covers the four other passages in every copy. The other tests of the file are unaffected, and `test_brief_has_required_headings` proves both headings stay.
  - Acceptance: the three named tests exist, the old test name is gone, and the six files have one hash.
- [ ] [P5-T3] Replace the `Test isolation` sentence in all six copies of `atomic-plan-contract/SKILL.md`, and replace `test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` in `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`.
  - The six copies are `.claude/skills/`, `.agents/skills/`, `.github/skills/`, and `extensions/drm-copilot/resources/` under `claude-customizations/.claude/skills/`, `codex-and-agents-customizations/.agents/skills/`, and `customizations/.github/skills/`. They are not byte-identical, so only that sentence changes in each. The new sentence states one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, Jest through its normal workers, and `Invoke-PoshQCLeakScan`.
  - Tests: `test_contract_premortem_test_isolation_states_parallel_gates_and_leak_scan` iterates a new `_CONTRACT_COPIES` tuple of all six paths. It requires those tokens and rejects `seeded shuffled`, `reversed-order run`, `at least three seeds`, `file-order run`, and `isolation runs`. `_CONTRACTS` and the tests that use it are unaffected and unchanged.
  - Acceptance: the new test exists, the old test name is gone, and `_CONTRACT_COPIES` holds six paths.
- [ ] [P5-T4] Update the test step in every copy of `.claude/skills/powershell-qa-gate/SKILL.md` and `.claude/skills/python-qa-gate/SKILL.md`, and create `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
  - The copies are `.claude/skills/`, `.agents/skills/`, and the `claude-customizations` and `codex-and-agents-customizations` bundles; neither skill has a `.github` copy. PowerShell step 3 names one `Invoke-PoshQCParallelTest` run through the route in the `execution-environment` brief. Python step 4 is `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`. The `Targeted runs are allowed mid-batch` sentence in each `## Prohibited Shortcuts` becomes the debugging-only statement.
  - Tests: the new suite reads each surface from its path and holds an inline `-ForEach` table with tag `PGW-`, one row per file, each with required and forbidden tokens. Rows here forbid `run_poshqc_test` in the PowerShell gate copies, `Targeted runs are allowed` in all eight copies, and the old Python step text, which has no `-n auto`, in the Python gate copies.
  - Acceptance: all eight copies have a `PGW-` row.
- [ ] [P5-T5] Update the coverage commands in every copy of `.claude/skills/feature-review-workflow/SKILL.md` that holds them, and add `PGW-` rows to `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
  - The copies are `.claude/skills/`, `.agents/skills/`, and their two bundles; the `.github` copy and its bundle hold no such command and are unchanged. Python becomes `poetry run pytest -n auto --cov-report=term-missing --cov` and PowerShell becomes `Invoke-PoshQCParallelTest`, with the same artifacts. `Run the smallest relevant subset first` becomes the debugging-only statement, because a review check may not rest on a focused run.
  - Acceptance: the four copies have a `PGW-` row that forbids `run_poshqc_test` and `smallest relevant subset`.
- [ ] [P5-T6] Update the toolchain list in `.claude/agents/atomic-executor.md`, `.codex/agents/atomic-executor.toml`, and `.codex/agents/powershell-atomic-executor.toml`, with their bundle copies, then run `scripts/dev_tools/generate_codex_agent_variants.py` in write mode.
  - `## Toolchain Commands`: Python names `poetry run pytest -n auto`. PowerShell keeps the format, analyze, and autofix MCP tools and names one `Invoke-PoshQCParallelTest` run as the Pester gate through the `sh` launcher route. The heading stays for `tests/scripts/dev_tools/test_scratch_location_contracts.py`.
  - The `tools:` entries stay, so `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` and `.codex/config.toml` are unchanged. The `powershell-atomic-executor.toml` description replaces the test tool with `Invoke-PoshQCParallelTest`, and its bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/` is edited the same way, because it is not a generated family.
  - Tests: add `PGW-` rows for `.claude/agents/atomic-executor.md`, its bundle, and both `.codex` base agents, forbidding the `**PowerShell**: MCP server functions` list form that names the test tool.
  - Acceptance: the generator's `--check` mode exits 0 after the write, and the `tools:` entries are unchanged in a diff against the merge base of `origin/main` and `HEAD`.
- [ ] [P5-T7] Update the remaining text surfaces in `.github/agents/`, `.github/prompts/remediate-comments.prompt.md`, and `.agents/skills/repo-automation-adapter/SKILL.md`, with their bundle copies, and add `PGW-` rows to `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
  - `atomic_executor`, `powershell-atomic-executor`, and `powershell-typed-engineer`: the test step names `Invoke-PoshQCParallelTest`, and the `mcp_drmcopilotext_run_poshqc_test` token goes.
  - `python-atomic-executor`, `commentary-remediation`, and `remediate-comments.prompt.md`: the test step names `poetry run pytest -n auto`.
  - `atomic_planning` and `powershell-atomic-planning`: the `[expect-fail]` example acceptance stops naming a `-k` focused run and names the `pytest -n auto` gate. The `Good:` example about adding a regression test for the MCP tool stays, because it names the tool under test and not a gate.
  - `repo-automation-adapter`: the tool lists stay, and one sentence after the `Required tools:` list states that `run_poshqc_test` is not a validation gate and that the Pester gate is one `Invoke-PoshQCParallelTest` run.
  - Acceptance: each listed file and its bundle copy has a `PGW-` row, and no `.github/agents` file holds `-k slug_extraction`.

### Phase 6 — Final QA Toolchain and Self-Review

Cheap stages run first, so that a suite is not re-run for a formatting change. A fix re-runs the static stages and the gate that failed. The other gate re-runs only when the fix changes a file that gate exercises. Each pass writes new artifacts.

- [ ] [P6-T1] Run format and analyze on the branch-current `scripts/powershell/PoshQC/PoshQC.psd1` and write `<FEATURE>/evidence/qa-gates/powershell-format.<timestamp>.md` and `<FEATURE>/evidence/qa-gates/powershell-analyze.<timestamp>.md`.
  - Format output carries `Already formatted:` and `Formatted:` lines. A `Formatted:` line means a file changed: commit it and repeat this task. Analyzer findings come from the direct run, not an MCP summary.
  - Acceptance: zero `Formatted:` lines, a non-zero `Already formatted:` count, and zero analyzer findings, with `EXIT_CODE:` carrying both.
- [ ] [P6-T2] Run Black in check mode, Ruff, and Pyright and write `<FEATURE>/evidence/qa-gates/python-black.<timestamp>.md`, `<FEATURE>/evidence/qa-gates/python-ruff.<timestamp>.md`, and `<FEATURE>/evidence/qa-gates/python-pyright.<timestamp>.md`.
  - Acceptance: each `EXIT_CODE:` is 0.
- [ ] [P6-T3] Run `Invoke-PoshQCLeakScan -Root` over the repository and `scripts/dev_tools/generate_codex_agent_variants.py` in `--check` mode, and write `<FEATURE>/evidence/qa-gates/leak-scan.<timestamp>.md` and `<FEATURE>/evidence/qa-gates/codex-generator.<timestamp>.md`.
  - Acceptance: both `EXIT_CODE:` values are 0.
- [ ] [P6-T4] Run the Pester gate with one background `Invoke-PoshQCParallelTest` run and write `<FEATURE>/evidence/qa-gates/pester-parallel.<timestamp>.md`.
  - The launcher exits with `.ExitCode`. Counts come from merged `artifacts/pester/pester-junit.xml`, never from an MCP summary.
  - Acceptance: `EXIT_CODE: 0`, zero failed tests, and the JUnit file holds testcases tagged `LS-K`, `LS-R`, `LA-`, `LI-`, `VT-`, `PGW-`, and `WF06-LEAK-SCAN-STEP`, plus each title named in spec Decision 3. The artifact lists the tag counts.
- [ ] [P6-T5] Run the pytest gate with one background `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov` run, with JSON coverage and JUnit output under `SCRATCH`, and write `<FEATURE>/evidence/qa-gates/pytest-parallel.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0`, zero failures and errors, and `test_execution_environment_fact_is_unchanged_across_copies`, `test_poshqc_bundled_module_files_match_repo_root_sources`, and the replacement tests of P5-T2 and P5-T3 all pass in the JUnit file. Total line and branch percentages from the JSON report are recorded.
- [ ] [P6-T6] Run the Jest suite with `node run-jest.cjs` in `extensions/drm-copilot/`, through its normal workers, and write `<FEATURE>/evidence/qa-gates/jest.<timestamp>.md`.
  - This run is required because the branch changes bundled resources under `extensions/drm-copilot/resources/`, and `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` reads the real repository. The worktree has no `extensions/drm-copilot/node_modules`; when it is absent, `npm ci` runs in that folder first. That writes only gitignored output.
  - Acceptance: `EXIT_CODE: 0` and zero failed tests.
- [ ] [P6-T7] Write per-file coverage to `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` from merged `artifacts/pester/powershell-coverage.xml` and the P6-T5 JSON report.
  - PowerShell files: `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1`, `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, and `scripts/dev-tools/DrmCopilotPromptSupport.ps1`. Python files: the four named in P0-T5. No baseline comparison is made, because the baseline runs are waived.
  - Acceptance: the step exits non-zero unless each new file reaches 85% line coverage, each changed PowerShell file reaches 85% line coverage, and each changed Python file reaches 85% line and 75% branch coverage. A shortfall is closed with tests, and Phase 6 repeats from P6-T1.
- [ ] [P6-T8] Check branch scope and evidence content and write `<FEATURE>/evidence/qa-gates/scope-check.<timestamp>.md`.
  - Scope uses `git diff --name-only` from the merge base of `origin/main` and `HEAD`, with `git status --porcelain` as its companion. Neither may list `.claude/rules/`, `.github/instructions/`, a bundle copy of either, `.agents/skills/powershell/`, `.agents/skills/python/`, `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, an Epic #1019 folder, `.github/workflows/ci.yml`, or a job or required-context change.
  - Evidence: a scan of `<FEATURE>/evidence/`, with tokens assembled at run time so the artifact cannot match itself, finds no host path and no citation of a removed or focused run.
  - Acceptance: `EXIT_CODE: 0`, from a step that exits non-zero on any match.
- [ ] [P6-T9] Check the locally verifiable criteria in `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/spec.md` and `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/user-story.md` against the evidence.
  - Each box is checked only when the evidence named in `## Acceptance Criteria Traceability` exists and passes. Both `CI-dependent:` criteria stay unchecked.
  - Acceptance: every locally verifiable box is checked in both files, and both CI-dependent boxes are unchecked.
- [ ] [P6-T10] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`.
  - The artifact has one PASS, FAIL, or N/A row per checklist item. It lists the spec Decisions to be reported to the owner, including `EXEMPT-COUNT:`. A FAIL row is fixed, the QA loop re-runs from P6-T1, and the self-review is rewritten.
  - Acceptance: the artifact holds no FAIL row.

## Acceptance Criteria Traceability

IDs follow the order of `spec.md` `## Acceptance Criteria`.

| ID | Criterion (short form) | Tasks | Proof |
|---|---|---|---|
| AC-01 | No text requires a removed run | P4-T4, P5-T2 to P5-T7 | `PGW-` rows, P5-T2 and P5-T3 tests |
| AC-02 | Policy files unchanged | P6-T8 | `scope-check` |
| AC-03 | `## Test Isolation Checks` and mirrors | P5-T2 | `test_brief_test_isolation_states_parallel_gates_and_leak_scan`, `test_brief_copies_are_byte_identical` |
| AC-04 | Four other brief passages | P5-T2 | `test_brief_passages_state_parallel_gate_facts` |
| AC-05 | Pre-Mortem bullet in every copy | P5-T3 | `test_contract_premortem_test_isolation_states_parallel_gates_and_leak_scan` |
| AC-06 | No comparison run; debugging statement | P5-T2, P5-T4, P5-T5 | Same tests, `PGW-` rows |
| AC-07 | Table A3 surfaces | P4-T4, P5-T4 to P5-T7 | `PGW-` rows, `tools:` diff in P5-T6 |
| AC-08 | `.vscode/tasks.json` | P4-T2 | `VT-` cases |
| AC-09 | `fix_all_branches.py` | P4-T3 | `test_fix_all*.py` |
| AC-10 | Contract tests fail on reintroduction | P5-T2, P5-T3, P5-T4 to P5-T7 | `test_brief_copies_carry_no_removed_run_tokens`, P5-T3 test, `PGW-` rows |
| AC-11 | Detects each kind; restored writes silent | P1-T1, P1-T2 | `LS-K`, `LS-R` |
| AC-12 | No restore, other name, literal; strings ignored | P1-T1, P1-T2 | `LS-K`, `LS-R` |
| AC-13 | Finding fields; `.ps1` helpers | P1-T1, P1-T2, P1-T4 | `LS-K`, `LS-R`, `LI-` |
| AC-14 | In-memory seam | P1-T1 to P1-T4 | Test files, self-review |
| AC-15 | Scan throws in four cases | P1-T4 | `LI-` |
| AC-16 | Allowlist validation | P1-T3 | `LA-` |
| AC-17 | CI step shape | P4-T1 | `WF06-LEAK-SCAN-STEP`, `scope-check` |
| AC-18 | Every finding fixed or allowlisted | P2-T1, P3-T1, P3-T6 to P3-T9 | `leak-scan-raw`, `leak-scan-classification`, `leak-scan` |
| AC-19 | `TestHelpers.ps1` | P3-T2 | P6-T4 gate |
| AC-20 | Batch-budget snapshots | P3-T3 | P6-T4 gate |
| AC-21 | Decision 3 tests | P3-T4, P3-T5 | P6-T4 titles |
| AC-22 | `Enter-DrmCopilotShell.Tests.ps1` | P3-T4 | P6-T4 gate |
| AC-23 | `PoshQC.TestingInvokeConfigPaths.Tests.ps1` | P3-T5 | P6-T4 gate |
| AC-24 | Bundle, parity, exports, README | P1-T1, P1-T3, P1-T4 | `test_poshqc_bundled_module_files_match_repo_root_sources` |
| AC-25 | New module coverage | P6-T7 | `coverage-delta` |
| AC-26 | Gates at zero failures | P6-T4, P6-T5 | `pester-parallel`, `pytest-parallel` |
| AC-27 | Evidence cites only the parallel gates and the scan | P6-T8 | `scope-check` |
| CI-01 | Scan step ran on the PR head | P4-T1 | Orchestrator, stays unchecked |
| CI-02 | `CI Required Gate` green | All | Orchestrator, stays unchecked |

## Pre-Mortem

- Review checklists: A reviewer could read the policy-file commands as an unmet first criterion, or read the `LASTEXITCODE` exemption as a blanket suppression. P6-T10 walks all three templates and lists spec Decisions 1, 2, and 3 and `EXEMPT-COUNT:` for the owner report. P5-T2 carries the governing statement that Decision 1 relies on.
- Coverage: The new modules enter the coverage population automatically, so a thin suite would fail at the end. The pure core carries the logic, seam defaults stay one line, and neither module has an entry block. The baseline runs are waived by owner directive, and P6-T7 gates each file with a failing exit, reading merged XML that exists only after a green gate.
- Mirror parity: The brief changes facts it states, so P5-T2 is the brief-update task for all six byte-identical copies. P5-T3 covers the six non-identical contract copies. Rule `PoshQC mirror` keeps `POSHQC_PARITY_PATHS` green per task. `.codex` variants come from the generator in P5-T6, and `powershell-atomic-executor.toml` is hand-edited because it is not a generated family.
- File size: `PoshQC.LeakScan.psm1` is capped at the 500-line guidance by P1-T2, and the logic is split across two modules. `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` starts near 500 lines and grows past that guidance tier, which fails no gate, and stays far below 700. `tests/scripts/dev_tools/test_fix_all_failure_paths.py` gains only dictionary entries, so new fix-all tests go to `test_fix_all_branches.py`.
- Test isolation: The gates are one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal workers, re-run only after a fix, with `Invoke-PoshQCLeakScan` as the independence check. The seeded and reversed runs are waived by owner directive, and no single-process or comparison run is performed. New tests use in-memory text and no temporary files. P3-T2 moves the `tree.Tests.ps1` dot-source into `BeforeAll`, because removing `global:` would otherwise break a discovery-scope load. Spec Decision 3 states the limit of proof by construction.
- CI-only behavior: The scan runs on `windows-latest` while paths compare with forward slashes, so paths normalize first and fixtures hold no drive letter. A stale allowlist entry fails the static job, so P3-T9 and P6-T3 run the same scan locally first. The batch-budget suites also run in the Linux hook job, and their snapshots use no paths. The checkpoint in the item worktree must select the large route, because more than three production PowerShell files change: a `POWERSHELL_LARGE_PATH_REQUIRED` denial stops the executor for the orchestrator. The final-head CI result stays with the orchestrator.
- Evidence: Gate values come from `Invoke-PoshQCParallelTest` output and JUnit files, never MCP summaries. Runner output stays under `SCRATCH`, because it holds host paths, and P6-T8 scans `<FEATURE>/evidence/` for host paths and removed-run citations. Raw findings are kept in `evidence/baseline/` so that each fix or entry traces to a row.

## Test Plan

- Unit: `PoshQC.LeakScan.Tests.ps1` and `PoshQC.LeakAllowlist.Tests.ps1` hold the scan cases, in memory, through seams. `Enter-DrmCopilotShell.Tests.ps1` holds the location seam cases.
- Contract: `test_execution_environment_brief_contracts.py`, `test_single_pass_preflight_contracts.py`, `parallel-gate-wording.Tests.ps1`, `PoshQcWorkflow.Tests.ps1`, `VsCodeQualityTasks.Tests.ps1`, and `test_poshqc_bundled_parity.py`.
- Integration: the leak scan over the repository (P2-T1, P3-T9, P6-T3), and `test_fix_all*.py` for the pipeline order.
- Gates: P6-T4, P6-T5, and P6-T6, once each, and again only after a fix.
- Coverage evidence: baseline waivers in `evidence/baseline/`; post-change figures in `evidence/qa-gates/pester-parallel.<timestamp>.md` and `pytest-parallel.<timestamp>.md`; per-file thresholds in `evidence/qa-gates/coverage-delta.<timestamp>.md`.

## Open Questions / Notes

- Premise corrections against the tree: `tests/scripts/dev-tools/tree.Tests.ps1` depends on the `global:` definition that spec `### 2. Static leak scan` removes, so P3-T2 includes it. `scripts/dev_tools/fix_all_branches_extra.py`, `prompt_builder.py`, and `cli_preflight.py` are outside research table A3 but hold a serial pytest command in a quality step or in executor and preflight text, so P4-T4 includes them.
- The Phase 0 suite baselines are waived by owner directive: a pre-change suite run is a comparison run. Pre-existing failures therefore surface first at the Phase 6 gates. The orchestrator changed P0-T4, P0-T5, and P6-T7 after planning for this reason.
- Decisions 1, 2, and 3 are reported to the owner at PR completion. The orchestrator owns that report, the PR, CI monitoring, and merge.
