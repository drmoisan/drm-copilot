# parallel-only-test-gates-and-leak-scan — Spec

- **Issue:** #1094
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-06T20-01
- **Status:** Draft
- **Version:** 0.2

## Overview

The repository requires each item to run its test suites several times, in both serial and parallel form. `## Test Isolation Checks` in the `execution-environment` skill requires a fresh single-process Pester run over `tests/scripts`, a concurrent-shard Pester run, seeded shuffled runs of the touched Pester suites, a reversed-order run of changed Python modules, a seeded shuffled Jest run, and a `pytest -n auto` run in addition to the serial runs.

The owner's decision, recorded 2026-11-06: tests run in parallel only. The sequential run existed to detect and fix a leak that has since been fixed, and the overhead of multiple runs and sequential runs is unacceptable.

Measured during Epic #1019:

- An 8-shard `Invoke-PoshQCParallelTest` run took 448 s.
- Single-process runs over `tests/scripts` took between 899 s and 1,504 s, and one item ran several of them in a single cycle.
- CI repeats the suite on every PR as 3 shards, so the local single-process run does not match CI.

Test independence remains policy under `.claude/rules/general-unit-test.md`. Removing the repeated runs removes the current means of detecting leaks, so detection needs to move to a scan that adds no test run. No shuffle step exists in the workflow files under `.github/workflows`.

A text search of the 509 Pester files in `tests/scripts` gives the candidate scale. These are candidates, not confirmed leaks: 30 files write `$env:`, 45 write `$global:`, 2 define global functions, 16 change location, and 2 change the process directory. The research census differs because it uses a stricter location search and includes `.ps1` helpers. These figures are for sizing only. The finding count comes from the first scan run.

Two tests in `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` were reported to fail in single-process runs. That file is one of the two that change the process directory. `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` was reported to fail when the process does not start at the repository root. See Decision 3 for how these tests are identified.

## Behavior

### 1. Parallel-only test gates

- The Pester gate is one `Invoke-PoshQCParallelTest` run. The pytest gate is one `pytest -n auto` run. Jest runs through its normal parallel workers. A suite is re-run only after a fix.
- No plan task or review check requires a single-process, seeded-shuffle, reversed-order, or comparison run.
- A focused run of one test file to debug a specific failure is debugging only. It is never a gate or evidence.
- Remove the single-process, seeded-shuffle, and reversed-order requirements from `## Test Isolation Checks` in the `execution-environment` skill, and remove the phrase "which is the CI shape". The heading `## Test Isolation Checks`, the heading `## CI Shape and Required Checks`, and the frontmatter description stay, because they are pinned or remain accurate.
- Update the other passages of the brief:
  - `## Test Runtime`: delete the clause that makes the serial `poetry run pytest` command the isolation reference.
  - `## CI-Only Failure Classes`: state that files in one shard share a process, so a leak surfaces when shard contents change, and that `Invoke-PoshQCLeakScan` is the check.
  - `## PowerShell Route and PoshQC MCP Limits`: name `Invoke-PoshQCParallelTest` as the branch-current route. State that merged JUnit and coverage exist only after a fully green run, and that failure detail is under `artifacts/pester/parallel/shard-<i>/`.
  - `## CI Shape and Required Checks`: add the leak scan to the stated contents of `poshqc / PowerShell QC static`.
- State in the brief that the parallel gates govern where a policy file names a toolchain test command (Decision 1).
- Update the `atomic-plan-contract` skill, so that the Pre-Mortem `Test isolation` bullet states the parallel gates and the leak scan, and update any other planner, executor, reviewer, or preflight text that requires the removed runs.
- Update every editable surface in table A3 of `research/research.2026-11-06.md`:
  - The `powershell-qa-gate`, `python-qa-gate`, and `feature-review-workflow` skills, in each mirrored copy.
  - `.claude/agents/atomic-executor.md`. Its `tools:` entries are permissions and stay.
  - The `.github/agents` agents listed in the table, and their bundle copies.
  - `.agents/skills/repo-automation-adapter/SKILL.md` and `.github/prompts/remediate-comments.prompt.md`.
  - The `.codex` agents listed in the table. Variants are generated, so only base agents are edited and the generator is run.
  - `scripts/dev_tools/fix_all_branches.py`.
- Update every mirrored copy of the changed skills: `.claude/skills/`, `.github/skills/`, `.agents/skills/`, and the three bundles under `extensions/drm-copilot/resources/`.
- Replace the contract tests that pin the old wording, `test_brief_test_isolation_requires_seeded_pester_shuffle` in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` and `test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` in `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`. The replacements assert the gates and `Invoke-PoshQCLeakScan`, and carry negative tokens so that reintroducing a removed requirement fails. The contract replacement covers every mirrored copy, not only the copies in `_CONTRACTS`.
- In `.vscode/tasks.json`, `QC: Coverage: All Providers` and `QC: 5 Run All Checks` depend on the parallel tasks, and a new task `PoshQC: 2c leak scan` runs the scan.
- Serial VS Code tasks may remain for debugging a single failure. They are not a validation gate.
- In `scripts/dev_tools/fix_all_branches.py`, add a leak-scan step and replace the `Invoke-PoshQCTest -Root '.'` command with `Invoke-PoshQCParallelTest`, exiting with the result's `ExitCode`.

### 2. Static leak scan

- Add a PowerShell scan to PoshQC, `Invoke-PoshQCLeakScan`, that parses Pester test files and `.ps1` helpers under `tests/`, and reports state changes with no matching restore in the same scope or in `AfterEach`, `AfterAll`, or `finally`. Helpers are included because a process-directory change and a global function definition are located in helpers.
- Detection uses the AST, so here-strings, command strings, and `Mock`-named commands are not reported.
- Findings name the file, the line, and the kind of state changed. They sort by path, then line.
- Run the scan in a fast quality stage and in CI, so it adds no test run. It is a new step in the existing `poshqc-static` job. There is no new job and no new required context.
- Confirmed findings are fixed on both sides, in the leaking suite and in any suite that relies on the leaked state. False positives go in a committed allowlist in which every entry states a reason.

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

- `tests/scripts/powershell/Support/TestHelpers.ps1` defines `Import-ScriptFunction` without `global:`, and `run-actionlint.Tests.ps1` drops its removal of that function.
- `enforce-python-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`, and `enforce-powershell-batch-budget-routing.Tests.ps1` snapshot the environment values they set and restore them, in the form used by `enforce-python-batch-budget-routing.Tests.ps1`, instead of clearing them to `$null`.

### 3. Process-directory independence

- `scripts/dev-tools/DrmCopilotPromptSupport.ps1`: add a `-GetLocationPath` seam to `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath`, defaulting to `{ $PWD.ProviderPath }` so that resolution is unchanged.
- `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`: the tests inject a fixture base and assert against it, with no `Push-Location` and no `[Environment]::CurrentDirectory`. A default-path case compares with `Join-Path $PWD.ProviderPath ...`, so that the wiring stays covered and the regression intent of issue #1067 is preserved.
- `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1`: the omitted-root test applies the `PR10-OMITTED-ROOT-USES-CURRENT-LOCATION` pattern from `PoshQC.ParallelRunner.Tests.ps1`, pinning the location in `try`/`finally` and reading it with `Get-Location`. Every `Set-Variable -Scope 1` capture in the suite is replaced with a holder hashtable.
- `Invoke-PoshQCTest` root resolution needs no production change, because it already uses `$PWD.ProviderPath`.

### 4. Out of scope

- A runtime check that compares session state before and after each test file during the parallel run. The owner agreed to take this as a second step, after this item.
- Adopting Pester `Run.Parallel`, which is experimental.
- Editing `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell`, or `.agents/skills/python` (Decision 1).

## Inputs / Outputs

- Inputs:
  - Files under the configured scan folders that lie beneath `tests/`, with extension `.ps1`.
  - `config/poshqc-leak-allowlist.json`.
- Outputs:
  - One finding per unpaired write, with path, line, kind, and name, through the injected logger.
  - A thrown error on any unallowlisted finding, invalid allowlist, stale entry, or parse error.
  - `Invoke-PoshQCParallelTest` writes per-shard results to `artifacts/pester/parallel/shard-<i>/`, and merged results only when every shard succeeded.
- Config keys and defaults:
  - The default scan folders come from `Get-PoshQCScanConfigFolder`, filtered to those under `tests/`.
  - An absent allowlist file is an empty allowlist. A scan with no test folders is not an error.
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
- The exit is non-zero on any finding, allowlist error, or parse error.

CI step: `Scan Pester tests for leaked state` in `poshqc-static` in `.github/workflows/_poshqc.yml`, after `Analyze PowerShell`, with no `continue-on-error` and no step-level `if`. A throw under `shell: pwsh` fails the step, the job, `poshqc / PowerShell QC`, and `CI Required Gate`.

## Data & State

- Data transformations and invariants: script text becomes an AST, the AST becomes raw findings, exempt names are removed, and the remainder is compared with `entries`. The scan reads only and changes no test or repository state.
- Caching or persistence details: `config/poshqc-leak-allowlist.json` is the only new committed state. The first scan's raw findings are kept under `<FEATURE>/evidence/baseline/`, so that each fix or allowlist entry can be traced.
- Migration or backfill requirements: none. No state model or data migration is involved.

## Constraints & Risks

- Files in the same shard still share a process, so a leak can surface later as a failure when shard contents change. The scan is the mitigation for this, and it is static, so it can miss state changed indirectly through a helper.
- The scan is file-local, so it cannot see a restore in another file, and it does not see state changed by production code under test, such as global functions defined by `DrmCopilotPromptSupport.ps1`. The promoted requirements accept this limit.
- A static scan produces false positives. The allowlist must require a reason so that it does not become a blanket suppression. Expected entries include `run-actionlint.EnvironmentIsolation.Tests.ps1`, which holds a restore in a scriptblock variable that R5 does not follow.
- The default-path case in `Enter-DrmCopilotShell.Tests.ps1` does not separate the PowerShell location from the process directory. The seam case catches production code that ignores the supplied base. A later change to the seam default itself would be covered only where the two directories differ.
- New tooling is PowerShell, not Python. Edits to `fix_all_branches.py` are small changes to existing Python.
- Tests must create no temporary files, and the scan must take file content through a seam so that it can be tested in memory.
- The negative tokens in the contract tests must not match the retained heading `## CI Shape and Required Checks`, the frontmatter description, or the replacement text that states the debugging exception.
- The scan runs on `windows-latest` and compares forward-slash paths, so paths are normalized before matching, and fixtures use no drive letters.
- Allowlist stale detection fails CI if a local fix lands without removing the entry.
- `mcp__drm-copilot__run_poshqc_test` runs without shards, and no MCP tool exposes `Invoke-PoshQCParallelTest`. Executors reach the parallel gate through the `sh` launcher route. Gate evidence comes from `Invoke-PoshQCParallelTest` output and JUnit files, not MCP summaries.
- A failed parallel run can leave older merged files in place, so `ExitCode` is read first.
- More than three production PowerShell files change, bundle copies included, so the item uses the orchestrated large path.
- `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` have pinned hashes and are not edited.
- This item runs alongside Epic #1019. It must not edit the epic's feature folders, and it must itself use the parallel-only gates.

## Decisions

### Decision 1: Policy files are not edited

- **Status:** To be reported to the owner at PR completion.
- **Decision:** `.claude/rules/` and `.github/instructions/` are not edited, by repository hard constraint. Those files use no serial, single-process, seeded-shuffle, or reversed-order wording as a requirement, but they name a toolchain test command (table A3).
- **Measurement:** the first acceptance criterion keeps the promoted wording and is measured as follows. No skill, agent, preflight, or brief text requires such a run or names a serial command as a validation gate, and the brief states that the parallel gates govern where a policy file names a toolchain test command.
- **Scope:** every editable surface in table A3 is in scope. `.agents/skills/powershell` and `.agents/skills/python` follow the policy files and are unchanged.
- **Residual limit:** after this item, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, their bundle copies, and the two `.agents/skills` files still name a command that runs in a single process. The criterion is therefore met by the brief's governing statement, not by removal of those commands. The policy files remain the canonical policy source, and `.claude/rules/powershell.md` still directs agents to the MCP commands. A reader of those files alone sees the old command, and removing it requires a separate change authorized by the owner.

### Decision 2: `$global:LASTEXITCODE` exemption

- **Status:** To be reported to the owner at PR completion. The exemption is listed in the count reported to the owner.
- **Decision:** the allowlist holds one named, reasoned exemption in `exemptGlobalVariables`, restricted to `LASTEXITCODE`. Validation rejects any other name.
- **Reason:** any native command overwrites the variable, and a reader of it after a fake native call receives the fake's own value. Restoring it would mean changing about 50 files for no change in behavior.
- **Effect:** the text search found no other `$global:` name under `tests/scripts`, so every other global variable write is reported. This is a text-search result, and the first scan confirms it.

### Decision 3: Proof by construction for the named tests

- **Status:** To be reported to the owner at PR completion.
- **Decision:** proof is by construction. After the change, the named tests neither read nor change the process directory, shown by the absence of those constructs and by the parallel gate. No single-process confirmation run is performed.
- **Identification:** the tests are identified by inspection, because recorded evidence does not name them. They are the tests named in section E of the research:
  - `resolves a relative path against the PowerShell location, not the process directory`
  - `resolves a relative virtual environment path against the PowerShell location, not the process directory`
  - the test whose title begins `defaults $Root to $PWD.ProviderPath when -Root is not supplied`
- **Residual limit:** the root cause of the reported failures was not established. The changes remove the candidate dependencies whatever the cause, but the original failures are not reproduced before or after the change.

## Implementation Strategy

- Implementation scope:
  - Skill, agent, prompt, and contract-test text as listed in `### 1. Parallel-only test gates`.
  - The leak scan, its allowlist, the CI step, and the VS Code task.
  - `fix_all_branches.py`. The step name `PoshQC: test` stays, so the step-name fixtures in `test_fix_all*.py` remain valid. The new step `PoshQC: leak scan` follows `PoshQC: analyze`, and the ordered step assertions in those tests are updated.
  - Test and helper fixes from the first scan, and `DrmCopilotPromptSupport.ps1`.
- New classes/functions/commands to add or update:
  - `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1` (AST and pairing) and `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1` (validation and comparison). The split keeps each file within the size guidance.
  - Each new module is added to the sub-module list in `PoshQC.psm1`, and the public function to both export lists and `README.md`, in the repository copy and in `extensions/drm-copilot/resources/powershell/PoshQC/`.
  - `POSHQC_PARITY_PATHS` in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` gains each new module file.
  - `tests/scripts/powershell/PoshQC/PoshQC.LeakScan.Tests.ps1` and `PoshQC.LeakAllowlist.Tests.ps1`, using in-memory script text only.
  - `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` gains a case for the scan step.
- Dependency changes: none. The scan needs only the PowerShell parser.
- Logging/telemetry additions and locations: findings and allowlist errors go through the injected `-Logger`. No telemetry is added.
- Rollout plan: no feature flag. The scan fails CI from the merge of this item. An absent allowlist is empty, so consumers of the bundled module are unaffected. Fallback is reverting the CI step.

## Acceptance Criteria

### Locally verifiable criteria

- [ ] No skill, agent, rule, or preflight text in the repository requires a serial, single-process, seeded-shuffle, or reversed-order validation run. Measured as stated in Decision 1: no skill, agent, preflight, or brief text requires such a run or names a serial command as a validation gate, and the brief states that the parallel gates govern where a policy file names a toolchain test command.
- [ ] The branch diff changes no file under `.claude/rules/` or `.github/instructions/`, no bundle copy of those files, and neither `.agents/skills/powershell` nor `.agents/skills/python`.
- [ ] `## Test Isolation Checks` states the parallel gates and the leak scan, and all mirrored copies match.
- [ ] The `## Test Runtime`, `## CI-Only Failure Classes`, `## PowerShell Route and PoshQC MCP Limits`, and `## CI Shape and Required Checks` passages of the brief carry the changes listed in `### 1. Parallel-only test gates`, in every mirrored copy.
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
- [ ] The tests named in Decision 3 no longer depend on the process directory: none of them reads or changes `[Environment]::CurrentDirectory` or calls `[IO.Directory]::SetCurrentDirectory`, and they pass in the parallel gate.
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
- [ ] Contract tests for the removed wording across all mirrored copies
- [ ] CI step failure on an unallowlisted finding
