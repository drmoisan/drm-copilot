# Research: Parallel-Only Test Gates and Static Leak Scan (Issue #1094)

- **Issue:** #1094
- **Branch:** feature/parallel-only-test-gates-and-leak-scan-1094
- **Inputs:** `docs/features/potential/promoted/2026-11-06-parallel-only-test-gates-and-leak-scan.md`, `.claude/skills/execution-environment/SKILL.md`, the owner directive in the delegation prompt.
- **Method:** static reading and text search only. No test, scan, or PowerShell parser was run. Figures labelled "predicted" are readings of the source, not tool output.

## Summary and Recommendation

- Remove the serial, shuffled, and reversed-order requirements from `## Test Isolation Checks`, the `atomic-plan-contract` Pre-Mortem rule, and three other brief passages. The heading `## Test Isolation Checks` stays, because `test_brief_has_required_headings` pins it.
- Add `Invoke-PoshQCLeakScan` as a new PoshQC sub-module. Attach it as a new step in the existing `poshqc-static` job, with a VS Code task for local use. No job, matrix entry, or required context changes.
- Three decisions belong to the owner; see `## Decisions for the Owner`. The first blocks the first acceptance criterion as drafted.

## Decisions for the Owner

1. **Policy files name serial test commands.** No file under `.claude/rules/` or `.github/instructions/` uses the words serial, single-process, shuffled, or reversed-order as a requirement. Five files do, however, name a serial command as the required test step (`## A. Wording Inventory`, table A3). Those files may not be edited. The first acceptance criterion ("No skill, agent, rule ... requires a serial ... run") cannot be met literally unless the owner authorizes editing them. Alternatives: narrow the criterion to skills, agents, and preflight text, with the brief stating that the parallel gates govern; or authorize the edits in this item.
2. **`$global:LASTEXITCODE`.** Every `$global:` write under `tests/scripts` targets this variable (`## D. Scan Design`). The specification says global writes are detected and every finding is fixed or allowlisted. Issue #1066 treated this variable as a leak in `run-actionlint.Tests.ps1` and restored it. Applying that fix everywhere means changing about 50 files. Recommended: one named, reasoned exemption in the allowlist (`exemptGlobalVariables`), because any native command overwrites the variable and a reader of it after a fake native call receives the fake's own value. The owner should confirm this does not count as the blanket suppression the specification warns against.
3. **Proof for the seventh acceptance criterion.** The failure text of the three tests is not recorded anywhere in the tree, and their root causes could not be established statically (`## E. Root Causes`). The directive forbids comparison runs. The recommended changes remove the dependency by construction. Confirming them directly would need a run of those two files alone from a directory other than the repository root (seconds, not a suite run). The owner should state whether that targeted run is allowed; otherwise proof rests on the parallel gate and on the absence of the constructs in the two files.

## A. Wording Inventory

Excluded: `docs/features/active`, `archive`, `completed`, `epics`, `parallel`, and `docs/features/potential/promoted` (historical records). `.github/prompts`, `.codex`, `packages/` (source), `docs/engineering`, `AGENTS.md`, `CLAUDE.md`, and `scripts/` carry none of the run-requirement terms.

Mirror sets used below:

- **Brief set (six, byte-identical):** `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/...`, `.github/skills/...`, and the three copies under `extensions/drm-copilot/resources/` (`claude-customizations/.claude/`, `codex-and-agents-customizations/.agents/`, `customizations/.github/`).
- **Contract set (six):** the same six locations for `skills/atomic-plan-contract/SKILL.md`.
- **Research set:** `.claude/skills/research-issue/SKILL.md`, `.agents/skills/research-issue/SKILL.md`, `.claude/agents/task-researcher.md`, `.github/agents/task-researcher.agent.md`, and their bundle copies.

### A1. Requirements to change

| File set | Heading or passage | Kind | Change |
|---|---|---|---|
| Brief set | `## Test Isolation Checks`, the "Before review, run each isolation check" list | Requirement | Replace with the gates and the scan (proposal below) |
| Brief set | `## Test Isolation Checks`, "An order dependence found by any run ... Every seed is then re-run." | Requirement | Keep the two-sided fix; drop the seed clause; extend to scan findings |
| Brief set | `## Test Runtime`, pytest bullet, "the serial `poetry run pytest` command remains the isolation reference" | Requirement by implication | Delete the clause |
| Brief set | `## CI-Only Failure Classes`, "Shard and single-process Pester runs expose ..." | Description that presumes the run | Reword: files in one shard share a process, so a leak surfaces when shard contents change; `Invoke-PoshQCLeakScan` is the check |
| Brief set | `## PowerShell Route and PoshQC MCP Limits`, "Branch-current Pester runs ... call `Invoke-PoshQCTest`" | Route that prescribes the serial entry point | Name `Invoke-PoshQCParallelTest`; state that merged JUnit and coverage exist only after a fully green run, and that failure detail is under `artifacts/pester/parallel/shard-<i>/` |
| Brief set | `## CI Shape and Required Checks`, "`poshqc / PowerShell QC static` (format and analyze ...)" | Fact changed by this item | Add the leak scan; the maintenance rule requires this in the same change |
| Contract set | `## Design-Level Plan Contract (Mandatory)`, **Pre-Mortem**, "The `Test isolation` bullet names the isolation runs ..." | Requirement | Bullet states the parallel gates and the leak scan |

The phrase "which is the CI shape" sits in the first row's list and goes with it.

Proposed `## Test Isolation Checks` content, for the planner to refine:

- Tests create no temporary files (unchanged).
- Test independence is checked statically: `Invoke-PoshQCLeakScan` runs in the fast quality stage and in `poshqc / PowerShell QC static`.
- The Pester gate is one `Invoke-PoshQCParallelTest` run. The pytest gate is one `pytest -n auto` run. Jest runs through its normal workers. Each gate has zero failures and is re-run only after a fix.
- Serial tasks remain for debugging one failure and are not gates.
- A leak is fixed on both sides: the suite that leaves state behind and the suite that assumes it.

### A2. Descriptions that stay accurate (no change)

| File set | Passage | Reason |
|---|---|---|
| Brief set | Frontmatter description, "test-isolation checks" | The heading survives |
| Brief set | Heading `## CI Shape and Required Checks` | Pinned by `_REQUIRED_HEADINGS`; describes CI, not a local run |
| Contract set, `orchestrate` skill (`.claude`, `.agents`, bundles) | "hook context, and CI shape are owned by ..." | Refers to the brief section |
| Contract set (`.claude` copy and its bundle) | "Name the runner and job for a Pester acceptance criterion" | Describes CI jobs |
| Research set | "the CI shape, contract tests, and isolation checks the section accounts for" | Refers to brief sections |
| `.github/agents/atomic_planning`, `atomic_executor`, `orchestrator`, `task-researcher` `.agent.md` and bundles | "test-isolation checks" | Refers to the brief section |
| `.claude/agents/atomic-planner.md`, its bundle | Label list | The label `Test isolation` stays |
| `.claude/hooks/premortem-section.ps1`, its bundle | `Get-PreMortemLabel` | Enforces labels only, never bullet content. No change. There is no `.codex/hooks` twin |
| `docs/features/templates/{bug,feature,refactor}/plan.yyyy-MM-ddTHH-mm.md`, `extensions/drm-copilot/resources/feature-templates/...` | Empty `- Test isolation:` bullet | Label only |

### A3. Serial entry points named as the test step

These hits use no flagged word, but each command is a single-process run. `mcp__drm-copilot__run_poshqc_test` runs `Invoke-PoshQCTest` without shards. No MCP tool exposes `Invoke-PoshQCParallelTest`.

**Policy files (not editable; decision 1):**

| File | Passage | Kind |
|---|---|---|
| `.claude/rules/powershell.md` | `## Toolchain` step 4, `mcp__drm-copilot__run_poshqc_test` | Requirement |
| `.claude/rules/python.md` | `## Toolchain` step 4, `poetry run pytest --cov --cov-branch --cov-report=term-missing` | Requirement |
| `.github/instructions/powershell-unit-test.instructions.md` | Agent execution requirement, `mcp_drmcopilotext_run_poshqc_test` | Requirement |
| `.github/instructions/powershell-code-change.instructions.md` | Toolchain step, the same tool | Requirement |
| `.github/instructions/python-unit-test.instructions.md` | "Approved command: `poetry run pytest --cov=...`" | Requirement |

The bundle copies of these files, and `.agents/skills/powershell/SKILL.md` and `.agents/skills/python/SKILL.md`, follow whatever is decided. Other hits in policy files are not run requirements: "run in any order" in `general-unit-test` is the independence policy, "Seeded RNG" concerns randomness in code, and "Run Flaky Tests in Isolation" in `github-actions-ci-cd-best-practices` is general flaky-test guidance.

**Editable surfaces (update unless decision 1 narrows the criterion):**

| File set | Passage |
|---|---|
| `.claude/skills/powershell-qa-gate/SKILL.md`, `.agents/...`, bundles | Numbered gate step naming `run_poshqc_test` |
| `.claude/skills/python-qa-gate/SKILL.md`, `.agents/...`, bundles | Numbered gate step naming `poetry run pytest --cov` |
| `.claude/skills/feature-review-workflow/SKILL.md`, `.agents/...`, bundles | Coverage commands for Python and PowerShell |
| `.claude/agents/atomic-executor.md` | Toolchain list. Its `tools:` entries are permissions and stay |
| `.github/agents/atomic_executor`, `atomic_planning`, `powershell-atomic-executor`, `powershell-atomic-planning`, `powershell-typed-engineer`, `python-atomic-executor`, `commentary-remediation` `.agent.md`, bundles | Toolchain text; read each hit in planning |
| `.agents/skills/repo-automation-adapter/SKILL.md`, `.github/prompts/remediate-comments.prompt.md` | Read each hit in planning |
| `.codex/agents/atomic-executor*.toml`, `powershell-atomic-executor.toml`, `.codex/config.toml` | Tool grants. Variants are generated, so edit base agents only and run the generator |
| `scripts/dev_tools/fix_all_branches.py` | Step `PoshQC: test` runs `Invoke-PoshQCTest -Root '.'`; see `## F. Parallel Gates` |

`.claude/agents/atomic-executor.md`, the `.codex` agents, and the `atomic-executor` route interact: `## Tool Routes by Agent` says the executor reaches PowerShell through the MCP tools or an `sh` launcher, so the gate uses the launcher route.

## B. Contract Tests

| Test | Asserts | Disposition |
|---|---|---|
| `test_execution_environment_brief_contracts.py::test_brief_test_isolation_requires_seeded_pester_shuffle` | `## Test Isolation Checks` holds the Jest seed command, reversed-order, seeded shuffle, and "at least three seeds" tokens, plus `concurrent-shard`, `pytest -n auto` | **Replace.** Rename; assert the gates and `Invoke-PoshQCLeakScan`; add negative tokens so reintroduction fails |
| `test_single_pass_preflight_contracts.py::test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` | Three shuffle and reversed phrases in the three `_CONTRACTS` copies | **Replace** the same way |
| `test_execution_environment_brief_contracts.py::test_brief_has_required_headings` | Heading set and order | Unchanged: both pinned headings stay |
| `...::test_brief_test_runtime_section_orders_diagnosis_before_parallelism` | `Test Runtime` tokens, none of them the removed clause | Unchanged |
| `...::test_brief_states_executor_route_and_poshqc_output_limits` | JUnit, coverage, and `Invoke-ScriptAnalyzer` tokens | Unchanged if the route edit keeps them |
| `...::test_brief_ci_section_names_jobs_and_required_contexts` | Job and context tokens | Unchanged: no job or context changes |
| `...::test_brief_copies_are_byte_identical`, `test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies` | Six copies identical | Unchanged; they fail until all six are edited |
| `...::test_brief_has_no_g11_or_g12_findings` | No line or commit citation | Unchanged; the new text must comply |
| `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` | Bundle text equals source | Unchanged; satisfied by updating bundles |
| `test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources` | `POSHQC_PARITY_PATHS` text parity | **Update:** add each new module file |
| `parallel_orchestrator_surface_expectations.py` `PINNED_FROZEN_SURFACE_HASHES` | Hashes of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` | Unchanged. The only hit in the epic skill is the unrelated word "seeded". Do not edit either file |
| `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` | Job set, `poshqc-static` runs format and analyze and not `Invoke-PoshQCTest` | Existing cases unchanged; **add** a case for the scan step with no `continue-on-error` and no step-level `if` |
| `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` | `needs:` set | Unchanged: no new `ci.yml` job |
| `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` | Reads `## Hook Execution Context` | Unchanged |
| `validate-planner-output.Tests.ps1`, `.Reentry.Tests.ps1`, `.Coverage.Tests.ps1` | Fixture bullet `- Test isolation: shuffled.` | Unchanged: the fixture exercises the label. Optional wording tidy only |
| `test_fix_all*.py` | `fix_all` step behavior | Update only if `fix_all_branches.py` changes; read before planning |

The exhaustive search of `tests/` for the removed phrases returned those two test functions only; every other hit (for example `PoshQC.Coverage.Tests.ps1`, the `BlastRadius` and `test_t2_properties.py` hits) concerns data order, not validation runs. The CI-only class line and "isolation reference" are pinned by no test. No PoshQC test pins the export list.

## C. PoshQC

**Layout.** `scripts/powershell/PoshQC/`: root `PoshQC.psm1`, manifest `PoshQC.psd1`, sub-modules `FileDiscovery`, `ScanConfig`, `Coverage`, `Analyzer`, `Shard`, `CoverageMerge`, `Parallel`, `Testing`, plus `settings/pester.runsettings.psd1`, `settings/pssa.settings.psd1`, `convert-poshqc-coverage.ps1`, `README.md`.

**Adding a sub-module requires** four edits per copy: the `foreach` list of sub-module names in `PoshQC.psm1` (each is parsed once and dot-sourced, which keeps the file association coverage needs), `Export-ModuleMember` in `PoshQC.psm1`, `FunctionsToExport` in `PoshQC.psd1` (CI imports the `.psm1`, `.vscode/tasks.json` imports the folder, so both lists matter), and `README.md`.

**Mirror.** `extensions/drm-copilot/resources/powershell/PoshQC/` is a text-identical copy held by `test_poshqc_bundled_parity.py`. It has no pack manifest; `test_push_down_*_pack_manifest_completeness.py` cover `.claude`, `.agents`, and `.codex` content. `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts` names only `PoshQC.psd1`.

**Coverage.** `config/poshqc-coverage.json` lists `scripts` as a root and `Get-PoshQCCoverageFileSet` enumerates `.ps1` and `.psm1` beneath it, so a new module enters the population with no configuration edit. The bundle is outside the roots. `quality-tiers.yml` classifies `scripts/powershell/PoshQC` as a path, so no new entry is needed.

**Tests.** `tests/scripts/powershell/PoshQC/*.Tests.ps1`, each using the module-collision guard in `BeforeAll`. New suites get a shard automatically.

**Fast quality stage.** `poshqc-static` in `_poshqc.yml` (install, format, analyze; `windows-latest`). Locally: VS Code tasks `PoshQC: 1 format` and `PoshQC: 2 analyze`, and `fix_all_branches.py` steps. `Invoke-PoshQCAnalyze` signals findings by `throw`.

**Recommended attachment.**

- New public function `Invoke-PoshQCLeakScan`, which throws on any unallowlisted finding, invalid allowlist, or parse error, matching `Invoke-PoshQCAnalyze`. It needs only the PowerShell parser, not PSScriptAnalyzer or Pester.
- CI: a step `Scan Pester tests for leaked state` in `poshqc-static` after `Analyze PowerShell`. A throw under `shell: pwsh` fails the step, the job, `poshqc / PowerShell QC` (which requires static success), and `CI Required Gate`. No `continue-on-error`.
- Local: a VS Code task `PoshQC: 2c leak scan`, a `fix_all_branches.py` step (a small edit to existing Python, not new Python), and the `sh`-launched route in the brief for executors.
- Leave `Invoke-PoshQCSuite` and `Invoke-PoshQCAnalyze` unchanged: both ship to consumers, whose repositories have no allowlist.

**CI facts.** Job names, matrix, and required contexts do not change. The `poshqc-static` job is skipped at job level on a docs-only run, so the scan skips too, which is correct because no test file changed. One brief fact changes: the static job's stated contents (table A1). `.github/workflows/README.md` describes that job only in the docs-only table, so it needs no edit. The rule `modified-workflow-needs-green-run` applies, and the pull-request run satisfies it.

**Rejected alternatives.**

- Inside `Invoke-PoshQCAnalyze`: changes a shipped contract and would fail consumers.
- A PSScriptAnalyzer custom rule: per-file diagnostics suit neither cross-block pairing nor a stale-entry check, and it would also analyze production files.
- A repository-gate Pester file like `FileSizePolicy.RepoGate.Tests.ps1`: adds no run, but reports only after the full suite instead of in the fast stage.

## D. Scan Design

### Census (sizing only; text search, not scan output)

| Kind | Text search | Reading | Predicted unpaired |
|---|---|---|---|
| `$env:` and `Env:` writes | 111 sites in 30 files, restores included | Densest: `enforce-python-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`, `HookPayload.Tests.ps1`, `activate.Tests.ps1`, `PoshQC.ScanFolders.Tests.ps1`, `run-actionlint.Tests.ps1`, `enforce-epic-wave-barrier.Coverage.Tests.ps1` | None seen in the sampled files |
| `$global:` writes | 116 sites in 50 files, including `Set-Variable -Scope Global` | **All name `LASTEXITCODE`.** An inverse search for any other `$global:` name found none. Densest: `link-parent-child`, `codex-detached-head-transport`, the `hook-docs-only-diff` suites, `run-actionlint`, `enforce-pr-author-skill.CurrentBranch`, `.DocsOnly` | Most, unless exempted (decision 2) |
| Global functions | 3 `function global:` definitions, 1 `New-Item Function:\global:` | `TestHelpers.ps1`, `PoshQC.TestingSeamDefaults.Tests.ps1`, `link-feature-docs.Tests.ps1`, helper in `activate.Tests.ps1` | 1: `tests/scripts/powershell/Support/TestHelpers.ps1` |
| `Set-Location`, `Push-Location` | 51 text hits in 17 files, but 7 files hold real calls | Real: `PoshQC.Coverage`, `PoshQC.ParallelRunner`, `Enter-DrmCopilotShell`, `HostBootstrapWorkspace`, `Invoke-ParallelDriftDetection`, `legacy-codex-hook-contracts`, `WorktreeResolutionFixture.Helpers.ps1`. The rest are `Mock`, `Should -Invoke`, or command strings | None |
| Process directory | 5 sites in 3 files | `Enter-DrmCopilotShell` (2), `HostBootstrapWorkspace` (2), `WorktreeResolutionFixture.Helpers.ps1` (1), all restored in `finally`. `[IO.Directory]::SetCurrentDirectory`: none | None |

The specification's scale figures differ because it counted `*.Tests.ps1` only and used a looser location search. The third process-directory file and the third global-function file are helpers. **The scan must therefore cover `.ps1` helpers under `tests/`, not only `*.Tests.ps1`.**

### Constructs to detect

All through the AST, so here-strings and command strings are ignored (for example the `pwsh -Command 'Set-Location ...'` strings in `hook-command-invocation.Issue824Regression.Tests.ps1`, and `$env:GIT_DIR=` inside a string in `enforce-orchestration-preimplementation-gate-targets.Tests.ps1`).

| Kind | Forms |
|---|---|
| `env` | Assignment and compound assignment to `$env:X` and `${env:X}`; `Set-Item`, `New-Item`, `Remove-Item`, `Clear-Item` on `Env:X` and `Env:\X`; `[Environment]::SetEnvironmentVariable` and `[System.Environment]::...` |
| `global-variable` | Assignment to `$global:X`; `Set-Variable`, `New-Variable`, `Remove-Variable` with `-Scope Global` |
| `global-function` | `function global:X`; `New-Item` and `Set-Item` on `Function:\global:X` and `function:global:X` |
| `location` | `Set-Location`, `Push-Location`, and aliases `cd`, `chdir`, `sl`, `pushd` |
| `process-directory` | Assignment to `[Environment]::CurrentDirectory`; `[IO.Directory]::SetCurrentDirectory`, both with and without `System.` |

Names compare case-insensitively. `Function:\global:gh` and `Function:\gh` normalize to one key, because `Remove-Item` ignores the `global:` qualifier (comment in `link-feature-docs.Tests.ps1`; issue #392 note in `PoshQC.Testing.psm1`). All `env` routes share one key per name, so `$env:X` pairs with `Remove-Item Env:\X`. `location` and `process-directory` each have one key.

### Restore rule, derived from the samples

A write is paired when one of these holds. A *restore* is an operation on the same key: assignment, `Remove-Item`, `Remove-Variable`, `Set-Item`; for `location`, `Pop-Location` or `Set-Location`.

| Rule | Sample | Condition |
|---|---|---|
| R1 Enclosing `finally` | `new-potential-entry.Tests.ps1`, `HookPayload.Tests.ps1`, `WorktreeResolutionFixture.Helpers.ps1` | The write is in a `try` body whose `finally` holds a restore, at any nesting (the `if`/`else` form in `link-feature-docs` and `foreach` form in `codex-epic-child-launch-attestation.Coverage` both count) |
| R2 Following `try` | `Push-Location` before `try` in `PoshQC.ParallelRunner`, `Enter-DrmCopilotShell`; `SetEnvironmentVariable` before `try` in `codex-detached-head-transport` | A later statement of the same block is a `try` whose `finally` holds a restore. **Enclosing-only matching would report all of these** |
| R3 Same block | Specification's "same scope" | A later statement of the same block restores with a variable, member, `$null`, or removal. A literal does not count, so `$env:X='a'; $env:X='b'` is reported |
| R4 Pester cleanup | `run-actionlint.Tests.ps1` (write in `It`, `AfterEach` on the outer `Describe`), `PoshQC.ScanFolders.Tests.ps1` (write in a `Mock` body), `link-parent-child.Tests.ps1` (file-level `BeforeAll` and `AfterAll`), `activate.Tests.ps1` | Any lexical ancestor block, including the file, directly holds `AfterEach` or `AfterAll` whose block contains a restore |
| R5 Cleanup helper | `activate.Tests.ps1` `Restore-GlobalPrompt`, called from `AfterEach` | A function defined in the file and called from a cleanup block counts as cleanup: its operations are restores, and are not reported as writes |

Writes located inside a `finally`, `AfterEach`, or `AfterAll` are restores and are never reported. A restore of a different name does not pair. **Dynamic names** (`foreach ($name in ...) { [Environment]::SetEnvironmentVariable($name, ...) }`) key on the argument's expression text, so `$name` pairs with `$name`; `("Function:\{0}" -f $functionName)` likewise.

### Expected false positives and limits

- `run-actionlint.EnvironmentIsolation.Tests.ps1` stores a restore in `$script:restoreEnvironment`, a scriptblock held in a variable; R5 does not follow it. Allowlist with a reason. Its nested `New-PesterContainer` blocks write `LASTEXITCODE` on purpose.
- `run-actionlint.Tests.ps1` removes `Import-ScriptFunction` through `$ExecutionContext.SessionState.InvokeProvider.Item.Remove`, because `Remove-Item` is mocked there. The scan does not model that route.
- A file-local scan cannot see restores in another file. `TestHelpers.ps1` defines `function global:Import-ScriptFunction`, which only `run-actionlint.Tests.ps1` removes; `new-potential-entry.Tests.ps1`, `post-codex-worktree-session.Tests.ps1`, and `tree.Tests.ps1` also load it. This looks like a true leak. Fix: define it without `global:` and drop the removal, subject to the parallel gate.
- **Known false negatives.** State changed by production code under test (`DrmCopilotPromptSupport.ps1` defines global functions and sets the prompt, and `Add-DirectoryToPath` writes `PATH`). The specification accepts this limit.
- **Clear versus restore.** `enforce-python-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`, and `enforce-powershell-batch-budget-routing.Tests.ps1` set `CLAUDE_SESSION_ID` and similar to `$null` in `AfterEach` with no snapshot. R4 accepts this, matching the acceptance wording, but a value present before the suite is lost. `enforce-python-batch-budget-routing.Tests.ps1` shows the snapshot form. Recommend fixing these three in this item; they are cheap and related.

### Allowlist

`config/poshqc-leak-allowlist.json`:

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

- `path` is repository-relative with forward slashes and compares ordinally. Entries carry no line number, because lines move.
- Validation throws and names the file, as `Get-PoshQCCoverageConfigRoot` does, for: wrong version, bad JSON, unknown `kind`, blank field, blank `reason`, absolute path, `..` segment, or duplicate entry.
- **Stale detection:** an entry matching no raw finding fails the scan, so a fixed finding forces removal of its entry. This follows `Compare-FileSizeBaselineEntry`, which rejects a shrunken baseline until tightened.
- An absent file is an empty allowlist, so consumers of the bundled module are unaffected. A scan with no test folders is not an error.
- Precedents: `config/file-size-baseline.json` (`schemaVersion`, `files` map, currently empty) with `.claude/lib/file-size-policy/FileSizePolicy.psm1`; `config/poshqc-coverage.json` with its validator.

### Content seam

Follow the seam style of `Get-PoshQCCoverageConfigRoot` and `Export-PoshQCShardWeight`.

- Pure core: `Get-PoshQCLeakFinding -Content <string> -Path <relative path>` uses `[System.Management.Automation.Language.Parser]::ParseInput`, never `ParseFile`, and returns objects with path, line, kind, name.
- Pure allowlist logic: takes findings plus allowlist text, returns unallowed findings and allowlist errors.
- `Invoke-PoshQCLeakScan -Root -ScanFolders -ReadText -ReadAllowlist -EnumerateFiles -Logger` is the only I/O. Default folders come from `Get-PoshQCScanConfigFolder`, filtered to those under `tests/`.
- A parse error is a failure, never a skip.

Estimated size exceeds the 500-line guidance if held in one file; plan `PoshQC.LeakScan.psm1` (AST) and `PoshQC.LeakAllowlist.psm1` (validation and comparison). Finding output should carry the file, line, and kind, per the specification.

## E. Root Causes

**Status: not established.** No artifact in the tree records the failure text, and the specification does not name the tests. The session log holding them is outside the tree. **Orchestrator to confirm the test names** from the Epic #1019 run output.

Evidence read:

- The two tests in `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` that touch the process directory, and so the likely subjects, are `resolves a relative path against the PowerShell location, not the process directory` (Context `Get-DrmCopilotNormalizedPath`) and `resolves a relative virtual environment path against the PowerShell location, not the process directory` (Context `Resolve-DrmCopilotActivationScriptPath`). Each does `Push-Location $PSScriptRoot`, sets `[Environment]::CurrentDirectory` to the drive root, and compares with `Should -BeExactly` against a `$PSScriptRoot`-derived path.
- Production (`scripts/dev-tools/DrmCopilotPromptSupport.ps1`) already resolves through `$PWD.ProviderPath`. As written, it does not read the process directory.
- The same test shape exists twice in `HostBootstrapWorkspace.Tests.ps1`, with the same production expression, and is not reported as failing. The structural difference is that `DrmCopilotPromptSupport.ps1` is dot-sourced and defines `function global:` functions, while `HostBootstrapWorkspace` is a module.
- A single-process run dated 2026-11-05 (`.../2026-11-04-devcontainer-current-baseline-1082/evidence/regression-testing/powershell-final-single-process.2026-11-05T06-38.md`) reports 14288 passed and 0 failed, and three seeded shuffles of `tests/scripts/dev-tools` in the #1080 evidence show 0 failed. So the failure is conditional on something those runs lacked, such as the start directory, suite predecessors, or path spelling.
- `Should -BeExactly` is case-sensitive, and `Set-Location` may correct path casing while `$PSScriptRoot` keeps the spelling it was given. That is a candidate, unverified, and the `HostBootstrapWorkspace` tests argue against it.
- In `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, only `defaults $Root to $PWD.ProviderPath when -Root is not supplied` reads the location, and it reads `$PWD` on both sides. The other four pass rooted `-Root` values and inject their seams. **Static reading found no dependence on the start directory.** A second candidate: the first three tests capture through `Set-Variable -Scope 1`, whose target depends on whether the test code and the `Invoke-PoshQCTest` instance share a session state, which the comment on `$InvokePester` in `PoshQC.Testing.psm1` says can vary. A failure of this kind would read as `$null`. Unverified.

**Recommended changes, which remove the dependency whatever the cause:**

- `DrmCopilotPromptSupport.ps1`: add a location seam to `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath`, defaulting to `{ $PWD.ProviderPath }`, following the existing `-GetLocationPath` parameters in that file. The file has one copy, no mirror.
- `Enter-DrmCopilotShell.Tests.ps1`: inject a fixture base and assert against it, with no `Push-Location` and no `[Environment]::CurrentDirectory`. Keep one default-path case comparing with `Join-Path $PWD.ProviderPath ...`, so the wiring remains covered and issue #1067's regression intent survives.
- `PoshQC.TestingInvokeConfigPaths.Tests.ps1`: apply the `PR10-OMITTED-ROOT-USES-CURRENT-LOCATION` pattern from `PoshQC.ParallelRunner.Tests.ps1` (pin the location in `try`/`finally`, read it with `Get-Location`), and replace `Set-Variable -Scope 1` with a holder hashtable.
- **Production change for `Invoke-PoshQCTest` root resolution: none indicated.** It already uses `$PWD.ProviderPath`.

## F. Parallel Gates

**`Invoke-PoshQCParallelTest`** exists in `PoshQC.Parallel.psm1` and is exported from both lists.

- Parameters: `-Root` (default current location; relative is resolved against it), `-WorkerCount` (default `Get-PoshQCParallelWorkerCount`: half the logical processors, between 1 and 8), and seams `ResetShardDirectory`, `StartShardProcess`, `WaitShardProcess`, `ReadText`, `WriteText`, `Clock`, `Logger`.
- Output: an object with `ExitCode`, `WorkerCount`, `WallClockSeconds`, `Shards` (`ShardIndex`, `ExitCode`, `LogPath`). It never calls `exit`, so a launcher must exit with `.ExitCode`, as the VS Code task does.
- Artifacts: per shard under `artifacts/pester/parallel/shard-<i>/` (`pester-junit.xml`, `powershell-coverage.xml`, `shard-files.json`, `shard.log`). Merged `artifacts/pester/pester-junit.xml` and coverage are written **only when every shard succeeded**; a failed run can leave older merged files in place, so read `ExitCode` first.

**`pytest -n auto`** (`## Test Runtime`): on the command line only, never in `addopts`; `-n auto` counts physical cores; pytest-cov combines workers. `_quality-checks.yml` already uses it.

**VS Code tasks.**

| Label | Role |
|---|---|
| `PoshQC: 4 test (Pester, parallel)`, `QC: 4 Pytest: run tests (parallel)`, `QC: 4 Pytest: run tests with coverage (parallel)` | Gates |
| `PoshQC: 4 test (Pester)`, `QC: 4 Pytest: run tests`, `QC: 4 Pytest: run tests with coverage` | Serial; keep for debugging |
| `QC: Coverage: All Providers`, `QC: 5 Run All Checks` | Aggregates depending on serial tasks. **Point them at the parallel tasks.** Several `dependsOn` names of `QC: 5 Run All Checks` (for example `QC: Black: format`) match no current label; pre-existing, and the same lines are being edited |

`QC: 0 Fix All` reaches `Invoke-PoshQCTest -Root '.'` through `fix_all_branches.py`. Replacing it needs an exit-code wrapper around `Invoke-PoshQCParallelTest` and `test_fix_all*.py` review. Include it: it is a serial run in a quality command, though not named by the specification.

## Requirements Mapping

| Criterion | Design |
|---|---|
| No text requires the runs | Tables A1 and A3, subject to decision 1 |
| Section states gates and scan; mirrors match | One edit copied to six; byte-identity tests |
| Contract tests pass and fail on reintroduction | Two replaced tests with negative tokens |
| Scan detects each kind; no report when restored | `## D. Scan Design`, rules R1 to R5 |
| Runs in CI, fails on unallowlisted finding | `poshqc-static` step; unit test for the throw; workflow test for the step |
| Every finding fixed or allowlisted | Run the scan once, then classify; decision 2 sets the `LASTEXITCODE` handling |
| Three tests independent of process directory | `## E. Root Causes`; decision 3 |
| Gates pass with zero failures | One run each, re-run only after a fix |

No state model or data migration is involved. Behavior: findings sort by path, then line; exit is non-zero on any finding, allowlist error, or parse error.

## Testing Implications

- `tests/scripts/powershell/PoshQC/PoshQC.LeakScan.Tests.ps1` and `PoshQC.LeakAllowlist.Tests.ps1`, in-memory script text only. Scan fixtures held in strings are invisible to the scan itself.
- Table-driven cases: each kind positive and negative; R1 to R5; restore absent; restore of a different name; literal in R3; dynamic names; strings ignored; `Mock`-named commands ignored; parse error.
- Allowlist: valid, missing reason, stale, duplicate, unknown kind, absent file.
- `Invoke-PoshQCLeakScan` throws through injected seams. Workflow step asserted in `PoshQcWorkflow.Tests.ps1`.
- Line coverage of at least 85% per new module, read from merged `artifacts/pester/powershell-coverage.xml`.

## Numeric Derivation Evidence

No numeric count is proposed for an approved `spec.md` acceptance criterion. The census figures are for sizing and must not be copied into a criterion. Any finding count comes from running the scan.

## Pre-Mortem

- **Review checklists:** A reviewer may treat the policy-file hits as unresolved against the first criterion, or a scan exemption as a blanket suppression. The plan records decisions 1 and 2 and walks the review templates in the self-review task.
- **Coverage:** New modules below 85% per file would block. They enter the population automatically, so the plan reads per-file coverage from the merged report, which exists only after a green gate. The default I/O wrapper must stay thin so the pure core carries the lines.
- **Mirror parity:** The brief and contract each have six copies, and the new modules need bundle copies, `POSHQC_PARITY_PATHS` entries, and both export lists. `.codex` variants are generated. Because the item changes facts the brief states, the plan's `Mirror parity` bullet names the brief-update task.
- **File size:** One module for AST and allowlist logic could pass 500 lines, so the plan splits it. `PoshQC.Testing.psm1` is untouched. `test_execution_environment_brief_contracts.py` gains only a little text.
- **Test isolation:** The item uses the parallel gates only and no shuffle or single-process run. New tests use in-memory text. Removing `Push-Location` from `Enter-DrmCopilotShell.Tests.ps1` lowers process-state use, and a default-path case keeps the wiring covered.
- **CI-only behavior:** The scan runs on `windows-latest` while paths are compared with forward slashes, so normalize before matching, and use no drive letters in fixtures. Allowlist stale detection fails on CI if a local fix lands without the entry removal. `.gitattributes` makes fixtures LF. The batch budget needs the large path, since more than three production PowerShell files change, bundle copies included.
- **Evidence:** Gate artifacts must come from `Invoke-PoshQCParallelTest` output and JUnit files, not MCP summaries, which carry no output. Pester and pytest evidence goes under `<FEATURE>/evidence/`, with the first scan's raw findings kept as baseline so that each fix or allowlist entry can be traced.
