# pester-static-leak-scan — Spec

- **Issue:** #1096
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07
- **Status:** Ready for planning
- **Version:** 1.0

## Overview

Split from issue #1094 by owner decision on 2026-11-07. #1094 kept the parallel-only test gate change and has merged. This item carries the static leak scan, the test fixes, and the serial commands that #1094 deferred by name.

With parallel-only gates, the repository no longer runs the single-process and shuffled runs that detected state leaking between test files. Test independence remains policy under `.claude/rules/general-unit-test.md`. Files in the same shard still share a process, so a leak can surface later as a failure when shard contents change. Detection needs to move to a scan that adds no test run.

A text search of the 509 Pester files in `tests/scripts` gives the candidate scale. These are candidates, not confirmed leaks: 30 files write `$env:`, 45 write `$global:`, 2 define global functions, 16 change location, and 2 change the process directory. The research census differs because it uses a stricter location search and includes `.ps1` helpers. These figures are for sizing only. The finding count comes from the first scan run.

Two tests in `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` were reported to fail in single-process runs. That file is one of the two that change the process directory. `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` was reported to fail when the process does not start at the repository root. See Decision 3 for how these tests are identified and what can be proved about them.

Requirements come from `issue.md`. `research/research.2026-11-07.md` is the current delta research and overrides older text where they differ. The base research is `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/research/research.2026-11-06.md`.

## Behavior

### 1. Parallel-only test gates

This section covers the serial commands that #1094 deferred. The gate rule itself landed in #1094: the Pester gate is one `Invoke-PoshQCParallelTest` run, the pytest gate is one `pytest -n auto` run, Jest runs through its normal parallel workers, and a suite is re-run only after a fix.

Python commands (Decision 4):

- `run_python_branch` in `scripts/dev_tools/fix_all_branches_extra.py` passes `-n auto`, with and without coverage.
- `run_preflight_qc_with_capture` in `scripts/dev_tools/atomic_executor/cli_preflight.py` passes `-n auto`.
- `QCRunner.FULL_TEST` and the `full_test` command of `run_full_loop_with_artifacts` in `scripts/dev_tools/atomic_executor/qc_runner.py` pass `-n auto`.
- The prompt text of `PromptBuilder.build` in `prompt_builder.py` and of `build_preflight_qc_fix_prompt` in `cli_preflight.py` states `-n auto`.
- The literal `PYTHON_TOOLCHAIN_COMMANDS["pytest"]` in `qc_toolchain.py` carries `-n auto`. It has no reader, and it is updated so that it does not mislead.
- `_run_pytest_scoped_with_expectations` stays as it is, because it runs named files for expected-fail handling and not the suite.
- The stale flag `--cov=src/lexile_corpus_tuner` is removed from each line edited above. See `## Constraints & Risks` for the effect on `QCRunner.FULL_TEST`.
- `-n auto` stays on the command line and is never added to `addopts`.

`fix_all` steps (Decisions 1 and 4):

- In `scripts/dev_tools/fix_all_branches.py`, step `PoshQC: test` runs `Invoke-PoshQCParallelTest` and exits with the result's `ExitCode`. The step name stays.
- A new step `PoshQC: leak scan` follows `PoshQC: analyze` and precedes `PoshQC: test`.

VS Code tasks in `.vscode/tasks.json` (Decision 5):

- `QC: Coverage: All Providers` depends on `QC: 4 Pytest: run tests with coverage (parallel)` and `PoshQC: 4 test (Pester, parallel)`, and on no serial test task.
- `QC: 5 Run All Checks` depends on the same parallel tasks, and on no serial test task.
- The dependency labels of `QC: 5 Run All Checks` that name no task are corrected: `QC: Black: format` to `QC: 1 Black: format`, `QC: Ruff: lint` to `QC: 2 Ruff: lint`, and `QC: Pyright: type-check` to `QC: 3 Pyright: type-check`. `QC: Pytest: run tests with coverage` is replaced by the parallel task.
- The `test` group default moves from `QC: 4 Pytest: run tests` to `QC: 4 Pytest: run tests (parallel)`.
- The serial tasks `QC: 4 Pytest: run tests`, `QC: 4 Pytest: run tests with coverage`, and `PoshQC: 4 test (Pester)` stay for debugging one failure. They are not gates.
- A new task `PoshQC: 2c leak scan` runs the scan.

### 2. Static leak scan

- Add a PowerShell scan to PoshQC, `Invoke-PoshQCLeakScan`, that parses Pester test files and `.ps1` helpers under `tests/`, and reports state changes with no matching restore in the same scope or in `AfterEach`, `AfterAll`, or `finally`. Helpers are included because a process-directory change and a global function definition are located in helpers.
- The scan is PowerShell only and adds no new Python file. The allowlist is committed at `config/poshqc-leak-allowlist.json`, and every entry states a reason.
- Detection uses the AST, so here-strings, command strings, and `Mock`-named commands are not reported.
- Findings name the file, the line, and the kind of state changed. They sort by path, then line.
- The scan runs as a step in the `poshqc-static` job of `.github/workflows/_poshqc.yml`, in a new VS Code task, and as a `fix_all` step. It adds no test run, no CI job, and no required context.
- Confirmed findings are fixed on both sides, in the leaking suite and in any suite that relies on the leaked state. False positives go in the allowlist.
- Default scan folders come from `Get-PoshQCScanConfigFolder`, filtered to those under `tests/` after a successful read. That function throws when every configured folder is absent, and the scan lets that throw stand. No folders under `tests/` is not an error.

Detected kinds:

| Kind | Forms |
|---|---|
| `env` | Assignment and compound assignment to `$env:X` and `${env:X}`; `Set-Item`, `New-Item`, `Remove-Item`, `Clear-Item` on `Env:X` and `Env:\X`; `[Environment]::SetEnvironmentVariable` and `[System.Environment]::SetEnvironmentVariable` |
| `global-variable` | Assignment to `$global:X`; `Set-Variable`, `New-Variable`, `Remove-Variable` with `-Scope Global` |
| `global-function` | `function global:X`; `New-Item` and `Set-Item` on `Function:\global:X` and `function:global:X` |
| `location` | `Set-Location`, `Push-Location`, and the aliases `cd`, `chdir`, `sl`, `pushd` |
| `process-directory` | Assignment to `[Environment]::CurrentDirectory`; `[IO.Directory]::SetCurrentDirectory`, with and without `System.` |

Names compare case-insensitively. All `env` routes share one key per name. `Function:\global:gh` and `Function:\gh` normalize to one key. `location` and `process-directory` each have one key.

Restore rules. A restore is an operation on the same key: assignment, `Remove-Item`, `Remove-Variable`, or `Set-Item`, and for `location`, `Pop-Location` or `Set-Location`. A write is paired when one of these holds:

| Rule | Condition |
|---|---|
| R1 Enclosing `finally` | The write is in a `try` body whose `finally` holds a restore, at any nesting |
| R2 Following `try` | A later statement of the same block is a `try` whose `finally` holds a restore |
| R3 Same block | A later statement of the same block restores with a variable, member, `$null`, or removal. A literal does not count, so `$env:X='a'; $env:X='b'` is reported |
| R4 Pester cleanup | Any lexical ancestor block, including the file, directly holds `AfterEach` or `AfterAll` whose block contains a restore |
| R5 Cleanup helper | A function defined in the file and called from a cleanup block counts as cleanup. Its operations are restores and are not reported as writes |

Writes located inside a `finally`, `AfterEach`, or `AfterAll` are restores and are never reported. A restore of a different name does not pair. Dynamic names key on the argument's expression text, so `$name` pairs with `$name`.

Fixes known before the first scan:

- `tests/scripts/powershell/Support/TestHelpers.ps1` defines `Import-ScriptFunction` without `global:`, and `run-actionlint.Tests.ps1` drops its removal of that function. `tests/scripts/dev-tools/tree.Tests.ps1` dot-sources the helper at file scope and depends on the `global:` definition, so its dot-source moves into `BeforeAll`.
- `enforce-python-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`, and `enforce-powershell-batch-budget-routing.Tests.ps1` snapshot the environment values they set and restore them, in the form used by `enforce-python-batch-budget-routing.Tests.ps1`, instead of clearing them to `$null`.

### 3. Process-directory independence

- `scripts/dev-tools/DrmCopilotPromptSupport.ps1`: add a `-GetLocationPath` seam to `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath`, defaulting to `{ $PWD.ProviderPath }` so that resolution is unchanged.
- `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`: the tests inject a fixture base and assert against it, with no `Push-Location` and no `[Environment]::CurrentDirectory`. A default-path case compares with `Join-Path $PWD.ProviderPath ...`, so that the wiring stays covered and the regression intent of issue #1067 is preserved.
- `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1`: the omitted-root test applies the `PR10-OMITTED-ROOT-USES-CURRENT-LOCATION` pattern from `PoshQC.ParallelRunner.Tests.ps1`, pinning the location in `try`/`finally` and reading it with `Get-Location`. The `Push-Location` sits where rule R2 pairs it, so that the scan does not report the fix itself. Every `Set-Variable -Scope 1` capture in the suite is replaced with a holder hashtable.
- The titles named in Decision 3 stay. The title of the omitted-root test holds the token `$PWD`, so a check that the test reads no `$PWD` applies to the test body only.
- `Invoke-PoshQCTest` root resolution needs no production change, because it already uses `$PWD.ProviderPath`.

### 4. Execution-environment brief

The `execution-environment` brief changes in all six byte-identical copies listed in `_BRIEF_COPIES`, under these headings (Decision 6):

| Heading | Change |
|---|---|
| `## Test Isolation Checks` | A new bullet naming `Invoke-PoshQCLeakScan` is appended after the last bullet. No existing bullet is reworded, and no bullet is inserted between existing bullets |
| `## CI Shape and Required Checks` | Add the leak scan to the stated contents of `poshqc / PowerShell QC static`, and keep that backticked context |
| `## CI-Only Failure Classes` | Add that `Invoke-PoshQCLeakScan` is the check, and that a stale allowlist entry fails the static job. The existing shard sentence stays |
| `## Test Runtime` | Extend the pytest bullet to the `fix_all` and executor commands that now pass `-n auto` |
| `## PowerShell Route and PoshQC MCP Limits` | State that no MCP tool exposes the scan and that the executor reaches it through the `sh` launcher |

- `Invoke-PoshQCLeakScan` joins the required tokens of `test_brief_test_isolation_states_parallel_gates`, and the scan phrase joins the `## CI-Only Failure Classes` entry of `test_brief_passages_state_parallel_gate_facts`. Both test names stay, because step 5 of `## Revert Steps` in ledger entry 0001 cites them.
- The new text avoids the tokens that `PGW-SWEEP-SURFACES` and `test_brief_copies_carry_no_removed_run_tokens` reject. In particular, the allowlist is not described as a `captured baseline`, a `numeric baseline`, or a `coverage baseline`, and the wording avoids `does not regress`, `compared to baseline`, `regressed from baseline`, and `targeted tests`.
- `atomic-plan-contract` is not edited in this item.

### 5. Process-reduction ledger

The serial-command removals in `### 1. Parallel-only test gates` are later landings of reduction 0001, so they update `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` (Decision 7). No new entry is added. The scan is an addition and needs no entry.

- `## Summary`: `Merge commit:` is back-filled with 278bb7047db986bbb0a8652ca323656ce85f8a08.
- `## Files Changed`: each changed path is added, and the opening sentence, which bounds the list to the #1094 branch diff, is amended.
- `## Stored Patch`: the patch stays and the section states that the patch does not hold these edits.
- `## Prior Text`: a Revert Block is added for each changed file.
- `## Revert Signals`: the bullet that begins `Before #1096 lands` is reworded, for example to a leak that the scan misses.
- The serial-command edits and the entry update land in a separate commit whose subject carries `reduction: 0001`.

### 6. Out of scope

- A runtime check that compares session state before and after each test file, which remains a later step.
- Adopting Pester `Run.Parallel`, which is experimental.
- New Python files. Edits to existing Python files and existing Python test files are in scope.
- Editing `atomic-plan-contract`, in any copy.
- Editing any Epic #1019 feature folder.
- Editing `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell`, or `.agents/skills/python` (Decision 1).
- Changing `poshqc / PowerShell hook suites (Linux)` (Decision 8).

## Inputs / Outputs

- Inputs:
  - Files under the configured scan folders that lie beneath `tests/`, with extension `.ps1`.
  - `config/poshqc-leak-allowlist.json`.
- Outputs:
  - One finding per unpaired write, with path, line, kind, and name, through the injected logger.
  - A thrown error on any unallowlisted finding, invalid allowlist, stale entry, or parse error.
  - `Invoke-PoshQCParallelTest` writes per-shard results to `artifacts/pester/parallel/shard-<i>/`, and merged results only when every shard succeeded. This behavior already exists.
- Config keys and defaults:
  - The default scan folders come from `Get-PoshQCScanConfigFolder`, filtered to those under `tests/`. The throw from that function when every configured folder is absent stands.
  - An absent allowlist file is an empty allowlist. No folders under `tests/` is not an error.
- Versioning or backward-compatibility constraints:
  - `Invoke-PoshQCSuite` and `Invoke-PoshQCAnalyze` are unchanged, because both ship to consumers whose repositories have no allowlist.
  - The allowlist `version` is 1.

## API / CLI Surface

Public function, exported through both `Export-ModuleMember` in `PoshQC.psm1` and `FunctionsToExport` in `PoshQC.psd1`:

```powershell
Invoke-PoshQCLeakScan -Root <path> [-ScanFolders <string[]>] [-ReadText <scriptblock>] [-ReadAllowlist <scriptblock>] [-EnumerateFiles <scriptblock>] [-Logger <scriptblock>]
```

Pure core, which uses `[System.Management.Automation.Language.Parser]::ParseInput` and never `ParseFile`:

```powershell
Get-PoshQCLeakFinding -Content <string> -Path <repository-relative path>
```

Example invocations:

- `Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCLeakScan -Root .` returns without error when every finding is exempt or allowlisted.
- The same call throws, naming each finding's path, line, and kind, when an unallowlisted finding exists.

Allowlist shape:

```json
{
  "version": 1,
  "exemptGlobalVariables": [
    { "name": "LASTEXITCODE", "reason": "..." }
  ],
  "entries": [
    { "path": "tests/scripts/dev-tools/example.Tests.ps1", "kind": "env", "name": "EXAMPLE", "reason": "..." }
  ]
}
```

Contracts and validation rules:

- `path` is repository-relative with forward slashes and compares ordinally. Entries carry no line number.
- Validation throws and names the file for: wrong version, bad JSON, unknown `kind`, blank field, blank `reason`, absolute path, `..` segment, duplicate entry, or an `exemptGlobalVariables` name other than `LASTEXITCODE`.
- An item in `entries` that matches no raw finding is stale and fails the scan, so a fixed finding forces removal of its entry.
- A parse error is a failure, never a skip.
- A file read failure is a separate failure, reported with kind `read-error`, and the file is not parsed.
- The exit is non-zero on any finding, allowlist error, read failure, or parse error.

CI step: `Scan Pester tests for leaked state` in `poshqc-static` in `.github/workflows/_poshqc.yml`, after `Analyze PowerShell`, with no `continue-on-error` and no step-level `if`. A throw under `shell: pwsh` fails the step, the job, `poshqc / PowerShell QC`, and `CI Required Gate`.

VS Code task: `PoshQC: 2c leak scan`. `fix_all` step: `PoshQC: leak scan`. No MCP tool exposes the scan.

## Data & State

- Data transformations and invariants: script text becomes an AST, the AST becomes raw findings, exempt names are removed, and the remainder is compared with `entries`. The scan reads only and changes no test or repository state.
- Caching or persistence details: `config/poshqc-leak-allowlist.json` is the only new committed state. The first scan's raw findings are kept under `<FEATURE>/evidence/baseline/`, so that each fix or allowlist entry can be traced. The scan is a static tool and runs no suite. The baseline gate results and per-file coverage of Decision 9 are kept in the same folder.
- Migration or backfill requirements: none for data. Ledger entry 0001 is back-filled as stated in `### 5. Process-reduction ledger`.

## Constraints & Risks

- Files in the same shard still share a process, so a leak can surface later as a failure when shard contents change. The scan is the mitigation for this, and it is static, so it can miss state changed indirectly through a helper.
- The scan is file-local, so it cannot see a restore in another file, and it does not see state changed by production code under test, such as global functions defined by `DrmCopilotPromptSupport.ps1`. The promoted requirements accept this limit.
- A static scan produces false positives. The allowlist must require a reason so that it does not become a blanket suppression. Expected entries include `run-actionlint.EnvironmentIsolation.Tests.ps1`, which holds a restore in a scriptblock variable that R5 does not follow.
- The default-path case in `Enter-DrmCopilotShell.Tests.ps1` does not separate the PowerShell location from the process directory. The seam case catches production code that ignores the supplied base. A later change to the seam default itself would be covered only where the two directories differ.
- New tooling is PowerShell, not Python. Edits to the existing Python files in `### 1. Parallel-only test gates` are small changes.
- Tests must create no temporary files, and the scan must take file content through a seam so that it can be tested in memory.
- This item must not edit Epic #1019 feature folders.
- The scan runs on `windows-latest` and compares forward-slash paths, so paths are normalized before matching, and fixtures use no drive letters.
- Allowlist stale detection fails CI if a local fix lands without removing the entry.
- `.vscode/tasks.json` carries full-line `//` comments, so a test that reads it must allow them.
- **`QCRunner.FULL_TEST` keeps a coverage source after the merge with PR #1108.** The merge of `origin/main` (PR #1108, issue #1106) gives `FULL_TEST` the source `--cov=scripts/dev_tools` in place of the removed `--cov=src/lexile_corpus_tuner`, so its two report flags, `--cov-report=xml` and `--cov-report=term-missing`, have a source. `test_run_full_runs_all_tools_on_entire_codebase` in `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` pins the full command list, including `--cov=scripts/dev_tools`. Decision 4 is unchanged: this specification still removes the stale flag only, and the source comes from the merged main side.
- `FAILED_NODEID_RE` reads the `FAILED <nodeid>` summary lines that `-ra` in `addopts` requests. Their form under xdist was not observed. The first gate that exercises this path confirms that expected-fail handling still matches.
- `run_fix_all` starts its branches on threads, so `Invoke-PoshQCParallelTest` (up to 8 shard processes) and `pytest -n auto` run at the same time as Jest. No test can show the resource effect, and timing can change.
- Merged Pester results exist only after a green run, so a failing `QC: Coverage: All Providers` no longer refreshes the Koverage source. A failed parallel run can leave older merged files in place, so `ExitCode` is read first.
- `mcp__drm-copilot__run_poshqc_test` runs without shards, and no MCP tool exposes `Invoke-PoshQCParallelTest` or the scan. Executors reach both through the `sh` launcher route. Gate evidence comes from `Invoke-PoshQCParallelTest` output and JUnit files, not MCP summaries.
- Each `Current` fence in ledger entry 0001 must occur exactly once in its target, and `Invoke-ProcessReductionRevert` throws otherwise. No test enforces this, because `PRL-REAL-LEDGER-AGREES` checks structure only, so a broken fence fails silently until a revert. An appended bullet keeps the `## Test Isolation Checks` fence valid; rewording or inserting between bullets breaks it.
- A reduction with no ledger entry is a Blocking finding under `.claude/skills/feature-review-workflow/SKILL.md`.
- Serial entry points that are not gates stay unchanged: `scripts/dev-tools/run-pester.ps1`, `run-poshqc-suite.ps1` and its bundled template, `Invoke-PoshQCSuite`, and MCP `run_poshqc_suite` and `run_poshqc_test`.
- More than three production PowerShell files change, bundle copies included, so the item uses the orchestrated large path.
- `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` have pinned hashes and are not edited.

## Decisions

Decisions 1 to 3 keep the numbering of the full-scope specification. Decisions 4 to 8 record the scope added after #1094 merged. Decision 9 records the owner's baseline decision of 2026-11-07. The scan attachment and the default-folder rule are settled and stated in `### 2. Static leak scan`.

### Decision 1: Policy files are not edited

- **Status:** Settled. To be reported to the owner at PR completion.
- **Decision:** `.claude/rules/` and `.github/instructions/` are not edited, by repository hard constraint. `.agents/skills/powershell` and `.agents/skills/python` follow the policy files and are unchanged.
- **Residual limit:** after this item, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, their bundle copies, and the two `.agents/skills` files still name a command that runs in a single process. The brief's governing statement, which #1094 landed, covers this. Removing those commands requires a separate change authorized by the owner.

### Decision 2: `$global:LASTEXITCODE` exemption

- **Status:** Settled. To be reported to the owner at PR completion. The exemption is listed in the count reported to the owner.
- **Decision:** the allowlist holds one named, reasoned exemption in `exemptGlobalVariables`, restricted to `LASTEXITCODE`. Validation rejects any other name.
- **Reason:** any native command overwrites the variable, and a reader of it after a fake native call receives the fake's own value. Restoring it would mean changing about 50 files for no change in behavior.
- **Effect:** the text search found no other `$global:` name under `tests/scripts`, so every other global variable write is reported. This is a text-search result, and the first scan confirms it.

### Decision 3: Proof by construction for the named tests

- **Status:** Settled. To be reported to the owner at PR completion.
- **Decision:** the named tests are fixed by removing the process-directory dependency. Proof is by construction: after the change, the named tests neither read nor change the process directory, shown by the absence of those constructs and by the parallel gate. No single-process confirmation run is performed.
- **Reason:** no gate reproduces the reported condition. The final #1094 Pester gate recorded zero failures at the aggregate level, and shard children start at the launching location.
- **Identification:** the tests are identified by inspection, because recorded evidence does not name them. They are the tests named in section E of the base research:
  - `resolves a relative path against the PowerShell location, not the process directory`
  - `resolves a relative virtual environment path against the PowerShell location, not the process directory`
  - the test whose title begins `defaults $Root to $PWD.ProviderPath when -Root is not supplied`
- **Residual limit:** the root cause of the reported failures was not established. The changes remove the candidate dependencies whatever the cause, but the original failures are not reproduced before or after the change. This item claims no before-and-after reproduction.

### Decision 4: Serial commands

- **Status:** Settled.
- **Decision:** every executed full-suite pytest command gains `-n auto`, as listed in `### 1. Parallel-only test gates`. The scoped per-file run stays. `fix_all` step `PoshQC: test` runs `Invoke-PoshQCParallelTest`. The stale `--cov=src/lexile_corpus_tuner` flag is removed from the lines being edited.
- **Reason:** the commands in `qc_runner.py` and `cli_preflight.py` decide pass or fail inside the executor tool, so leaving them serial would have that tool contradict its own prompt.

### Decision 5: VS Code tasks

- **Status:** Settled.
- **Decision:** both aggregate tasks depend on parallel test tasks only, the `test` group default moves to `QC: 4 Pytest: run tests (parallel)`, the `QC: 5 Run All Checks` dependency labels that name no task are corrected, and the serial tasks stay for debugging and are not gates.

### Decision 6: Brief text

- **Status:** Settled.
- **Decision:** the brief changes in all six byte-identical copies, under the headings in `### 4. Execution-environment brief`. The scan bullet is appended after the last bullet of `## Test Isolation Checks`, with no existing bullet reworded. `atomic-plan-contract` is not edited in this item. This overrides the recommendation in the delta research to add a sentence to that skill.

### Decision 7: Ledger

- **Status:** Settled.
- **Decision:** the serial-command removals update entry 0001 in a separate commit whose subject carries `reduction: 0001`, as `## 4. Process-Reduction Ledger` of the delta research states. The same update back-fills `Merge commit:` and rewords the `Before #1096 lands` revert signal. The scan is an addition and needs no entry.

### Decision 8: Linux hook suites stay single-process

- **Status:** Settled. Confirmed by the owner on 2026-11-07.
- **Decision:** `poshqc / PowerShell hook suites (Linux)` stays unchanged. It is a single-process CI job with a Linux purpose.

### Decision 9: Baseline test runs

- **Status:** Settled. Owner decision, 2026-11-07.
- **Decision:** before any production or test change, the plan runs one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run and records their results and per-file coverage under `<FEATURE>/evidence/baseline/`. The final gates are compared with that record. A new failure is a test that fails at the final gate and did not fail in the baseline run. A coverage drop is a production file that the branch changes, that existed before the change, and that the Pester or pytest coverage report measures, whose final line coverage, or branch coverage for a Python file, is below its baseline figure. A changed file that neither report measures, such as a bundle copy under `extensions/drm-copilot/resources/powershell/PoshQC/` or `scripts/powershell/PoshQC/PoshQC.psd1`, has no coverage figure and is outside this comparison.
- **Interplay:** the baseline run is the one run of each gate for the state before the change, and a gate is re-run only after a fix. The criterion that both gates pass with zero failures still holds. Before any change, every baseline failure lies outside the branch, so the plan's existing rule for such failures applies: the failure is recorded, not waived, and execution stops for the orchestrator. Merged Pester results exist only after a fully green run, so a baseline run that is not green takes its figures from the per-shard results under `artifacts/pester/parallel/shard-<i>/`.
- **Scope:** issue #1097 is restoring the baseline comparison as the general rule. This item applies it to its own plan only and edits neither `atomic-plan-contract` nor the `execution-environment` brief.

## Implementation Strategy

- Implementation scope:
  - The leak scan, its allowlist, the CI step, the VS Code task, and the `fix_all` step.
  - Test and helper fixes from the first scan, and `DrmCopilotPromptSupport.ps1`.
  - The serial-command edits, the VS Code task corrections, the brief edits, and the ledger update.
- New classes/functions/commands to add or update:
  - `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1` (AST and pairing) and `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1` (validation and comparison). The split keeps each file within the size guidance.
  - Each new module is added to the sub-module list in `PoshQC.psm1`, and the public function to both export lists and `README.md`, in the repository copy and in `extensions/drm-copilot/resources/powershell/PoshQC/`.
  - `POSHQC_PARITY_PATHS` in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` gains each new module file.
  - `tests/scripts/powershell/PoshQC/PoshQC.LeakScan.Tests.ps1` and `PoshQC.LeakAllowlist.Tests.ps1`, using in-memory script text only.
  - `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` gains a case for the scan step, tagged `WF06`, which is free.
  - `VsCodeQualityTasks.Tests.ps1` is new and holds the `VT-` cases, including label resolution and the default test task.
- Existing tests that change:
  - The `powershell` step dictionaries in `test_fix_all.py`, `test_fix_all_failure_paths.py`, `test_fix_all_branches.py`, and `test_fix_all_json_cancel.py` gain `PoshQC: leak scan`.
  - The ordered lists in `test_pipeline_runs_steps_in_order` in `test_fix_all.py` and `test_powershell_test_failure_returns_fail_result` in `test_fix_all_failure_paths.py` gain the step. `test_pipeline_succeeds_when_black_writes_to_stderr` and the format-failure and analyze-failure cases are unchanged.
  - `test_run_full_runs_all_tools_on_entire_codebase` updates its exact list. `test_run_scoped_runs_all_tools_on_changed_files` is unchanged.
  - New cases assert that `run_python_branch`, `run_preflight_qc_with_capture`, and `full_test` pass `-n auto`. New fix-all tests go to `test_fix_all_branches.py`.
- Dependency changes: none. The scan needs only the PowerShell parser.
- Logging/telemetry additions and locations: findings and allowlist errors go through the injected `-Logger`. No telemetry is added.
- Rollout plan: no feature flag. The scan fails CI from the merge of this item. An absent allowlist is empty, so consumers of the bundled module are unaffected. Fallback is reverting the CI step.

## Open Questions

No question remains open.

- **Baselines (settled 2026-11-07).** The owner decided the question that #1102 raised by removing the test-suite baseline. Decision 9 records the decision, and the last two locally verifiable acceptance criteria cover it.
- **Linux hook suites (confirmed by the owner 2026-11-07).** `poshqc / PowerShell hook suites (Linux)` remains a single `Invoke-Pester` process over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`. It is a serial run acting as a gate, and it supplies Linux coverage that repeats no local work. It stays unchanged under Decision 8, which the owner confirmed.

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
- [x] `--cov=src/lexile_corpus_tuner` appears in none of the commands or text named in `### 1. Parallel-only test gates`.
- [x] `fix_all_branches.py` runs `PoshQC: leak scan` between `PoshQC: analyze` and `PoshQC: test`, its step `PoshQC: test` runs `Invoke-PoshQCParallelTest` and fails on a non-zero `ExitCode`, and the `test_fix_all*.py` tests pass.
- [x] In `.vscode/tasks.json`, `QC: Coverage: All Providers` and `QC: 5 Run All Checks` depend on `PoshQC: 4 test (Pester, parallel)` and on no serial test task, and `VT-` cases assert this.
- [x] Every `dependsOn` name in `.vscode/tasks.json` resolves to a task label, and a `VT-` case that tolerates full-line `//` comments asserts this.
- [x] `QC: 4 Pytest: run tests (parallel)` is the default of the `test` group and `QC: 4 Pytest: run tests` is not, the serial tasks remain available for debugging, and the task `PoshQC: 2c leak scan` exists.
- [x] `## Test Isolation Checks` in the `execution-environment` skill names the scan in a bullet appended after the last bullet, its existing bullets are unchanged, and all mirrored copies match, shown by `test_brief_test_isolation_states_parallel_gates` and `test_brief_copies_are_byte_identical`.
- [x] The `## CI Shape and Required Checks`, `## CI-Only Failure Classes`, `## Test Runtime`, and `## PowerShell Route and PoshQC MCP Limits` passages of the brief carry the changes in `### 4. Execution-environment brief` in every mirrored copy, and `test_brief_passages_state_parallel_gate_facts`, `test_brief_ci_section_names_jobs_and_required_contexts`, and `test_brief_copies_carry_no_removed_run_tokens` pass.
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

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage for each detected state-change kind, positive and negative, using in-memory script text
- [ ] Restore recognised in `AfterEach`, `AfterAll`, `finally`, and the same scope; restore absent; restore of a different variable
- [ ] Allowlist entries: valid, missing reason, and stale
- [ ] CI step failure on an unallowlisted finding
