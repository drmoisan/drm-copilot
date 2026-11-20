# Delta Research: Pester Static Leak Scan (Issue #1096)

- **Issue:** #1096
- **Branch:** feature/pester-static-leak-scan-1096
- **Extends:** `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/research/research.2026-11-06.md` (the base). Its scan design, restore rules, allowlist shape, and rejected alternatives stand and are not repeated.
- **Method:** static reading and text search of the item worktree. No test, scan, or parser was run. Facts that need git or gh are marked `ORCHESTRATOR-CONFIRM:`.

## Summary and Recommendation

- Phases 1 to 3 of the draft hold against the tree, except for the spec dependency in `## 1. Draft Validity`.
- Phase 4 needs changes: the draft's reason for leaving `qc_runner.py` unchanged is inaccurate, and `cli_preflight.py` runs a serial command that the draft does not name.
- Recommended: add `-n auto` to every executed full-suite pytest command in `atomic_executor`, not only to its prompt text. Leave the scoped per-file run as it is.
- The brief accepts the scan line with no token collision. Append it as a new bullet, so that the `Current` fences of ledger entry 0001 stay valid.
- Ledger reading: the serial-command edits are later landings of reduction 0001, so they update entry 0001 in a commit carrying the `reduction: 0001` token. No new entry is needed. The scan itself is an addition and needs no entry.

## 1. Draft Validity

Every file and symbol cited in Phases 1 to 4 was checked. All hold except the items below.

| Draft reference | Current fact | Replacement |
|---|---|---|
| P4-T3: `test_pipeline_runs_steps_in_order` "of `test_fix_all_failure_paths.py`" | The test is in `tests/scripts/dev_tools/test_fix_all.py` only. `test_powershell_test_failure_returns_fail_result` is in `test_fix_all_failure_paths.py`, as the draft says | Name each test with its own file |
| Phase 1 preamble, P1-T3, P1-T4, P2, P3: spec `### 2. Static leak scan`, `Detected kinds`, `## API / CLI Surface`, `Contracts and validation rules`, Decisions 1 to 3 | None of these is in #1096 `spec.md`, which holds the promoted text and template stubs. The #1094 `spec.md` no longer holds them either. They survive only in the session scratchpad copy | Port them into #1096 `spec.md` before planning, because the scratchpad is not durable |
| Draft header, `<FEATURE>`, `SCRATCH`, and branch name | They name issue #1094 | Rewrite for #1096 |
| P4-T4: "`qc_runner.py` and `qc_toolchain.py` ... not stated gates" | `qc_runner.py` runs as a gate of the executor tool; see `## 2. Serial Command Inventory` | Replace the sentence with the disposition in that section |
| P4-T4: "toolchain text in ... `cli_preflight.py`" | That file holds the prompt text and also an executed command | Cover both |
| P3-T5 acceptance: "the omitted-root test reads no `$PWD`" | The title `defaults $Root to $PWD.ProviderPath when -Root is not supplied ...` holds the token and stays, because P6-T4 requires the title | Scope the acceptance to the test body |
| P5-T1 and the Phase 5 text tasks | #1094 landed them. `test_execution_environment_fact_is_unchanged_across_copies` already reads `path.relative_to(REPO_ROOT).parts` | Drop; only the scan-related residue in `## 3. Leak-Scan Text Surfaces` remains |
| P0-T4, P0-T5 waivers | `## Phase 0 Requirements` now states that no test suite runs in Phase 0, so no waiver is needed | Drop, subject to the owner's baseline decision (`## 5. Baselines`) |
| P0-T6, P5-T14 TypeScript stage | The validator change has no owner and is out of scope. P0-T6 falls away | Keep Jest in the final gates, because the bundled resources change and `config-carriage.test-helpers.ts` reads the repository (draft P6-T6) |

Confirmed unchanged:

- `Get-PoshQCScanConfigFolder` returns config-relative strings, so `tests/powershell` and `tests/scripts` filter on the prefix `tests/`. A configured folder that is absent is logged and skipped. `PoshQC.psm1` keeps its `foreach` sub-module list and both export lists, and `POSHQC_PARITY_PATHS` is in place.
- `WF06` is a free tag, because `PoshQcWorkflow.Tests.ps1` ends at `WF05`. Its case `runs the format and analyze gates in the poshqc-static job (issue #953)` forbids only `Invoke-PoshQCTest`. `Analyze PowerShell` is the last step of `poshqc-static`, so the new step appends. `VsCodeQualityTasks.Tests.ps1` does not exist yet.
- The P3-T2 and P3-T3 facts hold: `tree.Tests.ps1` dot-sources at file scope, `$script:describeHadImportScriptFunction` exists, and the three batch-budget suites assign `$null`. `post-codex-worktree-session.Tests.ps1` dot-sources `TestHelpers.ps1` in `BeforeAll` and never calls `Import-ScriptFunction`.

One corner to carry into P1-T4: `Get-PoshQCScanConfigFolder` throws when every configured folder is absent, while the spec says that no test folders is not an error. The default path must apply the filter after a successful read and let that throw stand, or the spec sentence narrows to "no folders under `tests/`".

### The three named tests

**Status: not confirmable statically. The draft gives no failure reason to test.** Spec Decision 3 records that the root cause was not established, and the draft inherits that.

- The constructs are unchanged. Both `Enter-DrmCopilotShell.Tests.ps1` cases still use `Push-Location` and set `[Environment]::CurrentDirectory`, and production still reads `$PWD.ProviderPath`. The omitted-root test still reads `$PWD` on both sides and captures through `Set-Variable -Scope 1`.
- The final #1094 Pester gate (`evidence/qa-gates/pester-parallel.2026-11-07T05-59.md`) records 14584 tests and 0 failures. The three tests therefore passed in shards, at the aggregate level; the evidence names no titles.
- Shard children are started by `Start-Process` with no `-WorkingDirectory`, so they start at the launching location. That is the repository root on the normal routes, which is consistent with the reported condition for the omitted-root test but does not prove it.
- No gate now runs the reported condition, so a before-and-after reproduction is not available. Proof by construction (Decision 3) remains the only route, and base `## E. Root Causes` stands.

## 2. Serial Command Inventory

#1094 deferred these by name (`### 2. Out of scope` of its spec). Search scope: `scripts/`, `.vscode/tasks.json`, `.github/workflows/`, `.devcontainer/`, and the test tree.

| Surface | Serial command | Existing tests that assert it | Test change | In draft |
|---|---|---|---|---|
| `fix_all_branches.py`, `run_powershell_branch`, step `PoshQC: test` | `Invoke-PoshQCTest -Root '.'` | None assert the command text. Step names: the `powershell` dictionaries of `test_fix_all.py`, `test_fix_all_failure_paths.py`, `test_fix_all_branches.py`, `test_fix_all_json_cancel.py`; `test_pipeline_runs_steps_in_order`; `test_powershell_test_failure_returns_fail_result` (own dictionary and list); `test_pipeline_succeeds_when_black_writes_to_stderr` (last step) | Dictionaries and the two ordered lists gain `PoshQC: leak scan`. The last-step test, the format-failure case, and the analyze-failure case are unchanged | P4-T3 |
| `fix_all_branches_extra.py`, `run_python_branch` | `poetry run pytest`, plus `--cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | None assert argv. Step names: `test_pipeline_stops_on_pytest_failure`, `test_pipeline_runs_steps_in_order` | Unchanged; one new case | P4-T4 |
| `prompt_builder.py`, `PromptBuilder.build` text | `python -m poetry run pytest` with the same flags | `test_build_includes_toolchain_instructions` (REQ-001), substring only | Stays valid; gains `-n auto` | P4-T4 |
| `cli_preflight.py`, `build_preflight_qc_fix_prompt` text | `poetry run pytest --cov=...` | `test_build_preflight_qc_fix_prompt_includes_workspace`, substring only | Stays valid; gains `-n auto` | P4-T4 |
| `cli_preflight.py`, `run_preflight_qc_with_capture`, **executed** | `poetry run pytest --color=no --cov=... --cov-report=term-missing` | `test_run_preflight_qc_with_capture_*` and `test_preflight_expected_*` in `test_cli_part3.py` match `"pytest" in cmd` | Unaffected | **No** |
| `qc_runner.py`, `QCRunner.FULL_TEST`, **executed** by `run_full` | `poetry run pytest --color=no --cov=src/lexile_corpus_tuner --cov-report=xml --cov-report=term-missing` | `test_run_full_runs_all_tools_on_entire_codebase` pins the exact list; `test_phase_expected_fail_tolerates_pytest_failures` and `test_phase_unexpected_fail_raises_on_pytest_failures` use membership | Exact list updated; others unaffected | **No** (excluded) |
| `qc_runner.py`, `run_full_loop_with_artifacts`, `full_test`, **executed** | `poetry run pytest --cov=... --cov-report=term-missing` | `test_full_loop_completes_when_black_changes_nothing`, membership | Unaffected | **No** (excluded) |
| `qc_runner.py`, `_run_pytest_scoped_with_expectations` | `poetry run pytest <files>` | `test_run_scoped_runs_all_tools_on_changed_files` pins it | None; keep | Excluded, correctly |
| `qc_toolchain.py`, `PYTHON_TOOLCHAIN_COMMANDS["pytest"]` | Same flags | None. No reader exists: `TOOLCHAIN_COMMANDS` is indexed only with `QCToolchain.TYPESCRIPT` | None | Excluded |
| `.vscode/tasks.json`, `QC: Coverage: All Providers` | Depends on `QC: 4 Pytest: run tests with coverage` and `PoshQC: 4 test (Pester)` | No test or production file reads these labels | New `VT-` cases | P4-T2 |
| `.vscode/tasks.json`, `QC: 5 Run All Checks` | Depends on `QC: Pytest: run tests with coverage` (no such label) and `PoshQC: 4 test (Pester)` | None | New `VT-` cases | P4-T2 |
| `.vscode/tasks.json`, `QC: 4 Pytest: run tests`, `QC: 4 Pytest: run tests with coverage`, `PoshQC: 4 test (Pester)` | Serial tasks | None | Stay for debugging | P4-T2 |

**Disposition of `qc_runner.py` and `qc_toolchain.py`.** `cli.py` calls `run_full` after a phase, `cli_task_runtime.py` calls `run_preflight_qc_with_capture` and `run_full_loop_with_artifacts`, and the task `Atomic Executor: Execute (prompted)` launches that CLI. These commands decide pass or fail inside that tool, so "not stated gates" does not describe them. With P4-T4 as drafted, the tool would tell an agent to run `-n auto` while running serial itself.

- Recommended: add `-n`, `auto` to `run_preflight_qc_with_capture`, `FULL_TEST`, and `full_test`. The cost is one exact-list assertion.
- Keep `_run_pytest_scoped_with_expectations`: it runs named files for expected-fail handling, not the suite, and `-n auto` adds no value there.
- `PYTHON_TOOLCHAIN_COMMANDS["pytest"]` has no reader. Update it in the same edit, so that the literal does not mislead.
- `PYTHON_QC_STEP_PATTERNS` matches `poetry\s+run\s+pytest\b`, so plan detection is unaffected.
- `FAILED_NODEID_RE` reads the `FAILED <nodeid>` summary lines that `-ra` in `addopts` requests. Their form under xdist was not observed. The first gate that exercises this path should confirm that expected-fail handling still matches.

**Gaps in P4-T2 to P4-T4.** They do not cover everything:

1. The three executed commands above.
2. `QC: 4 Pytest: run tests`, the serial task, holds `"isDefault": true` in the `test` group, so the default test task stays serial. Move the flag to `QC: 4 Pytest: run tests (parallel)`.
3. `QC: 5 Run All Checks` also names `QC: Black: format`, `QC: Ruff: lint`, and `QC: Pyright: type-check`. The real labels are `QC: 1 Black: format`, `QC: 2 Ruff: lint`, and `QC: 3 Pyright: type-check`. P4-T2 corrects only the pytest entry and leaves the aggregate naming missing tasks. Fix all three, and add a `VT-` case that every `dependsOn` name resolves to a label.
4. `.vscode/tasks.json` carries full-line `//` comments, so `VT-` parsing must allow them (the #1048 check stripped them first).

**Side effects to record.**

- `run_fix_all` starts its branches on threads, so `Invoke-PoshQCParallelTest` (up to 8 shard processes) and `pytest -n auto` would run at the same time as Jest. No test can show the resource effect.
- Merged Pester results exist only after a green run, so a failing `QC: Coverage: All Providers` no longer refreshes the Koverage source.
- `src/lexile_corpus_tuner` does not exist (`src/` holds one TypeScript file). That `--cov` flag is stale in every row above. It is pre-existing and is a one-token removal in the lines being edited.

**Other surfaces.**

| Surface | Disposition |
|---|---|
| `_poshqc.yml`, `poshqc-linux-hooks` | **Yes, a serial run acting as a gate:** one `Invoke-Pester` process over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on Linux, pinned by `PoshQcWorkflow.Tests.ps1`. It supplies Linux coverage and repeats no local work. Leave unchanged and report it to the owner |
| `_poshqc.yml`, `poshqc-shard` | `Invoke-PoshQCTest` with shard arguments, one process per matrix entry: the parallel CI shape |
| `scripts/dev-tools/run-pester.ps1` | Serial, no caller; its path appears only as fixture text in `PoshQC.Coverage.Tests.ps1`. Not a gate |
| `run-poshqc-suite.ps1`, its bundled template, `Invoke-PoshQCSuite`, MCP `run_poshqc_suite` | Serial consumer entry points. No file under `.claude/skills` or `.claude/agents` names the tool. Unchanged, per base `## C. PoshQC` |
| MCP `run_poshqc_test`, policy rule files | Spec Decision 1; `repo-automation-adapter` states the tool is not a validation gate |
| `.devcontainer/post-create.sh`, preimplementation-gate hook patterns, `shell-qc.sh test` (Bats) | Not gates under the rule: a `--version` probe and echoed hint; patterns that run nothing; a suite outside the Pester, pytest, and Jest rule |

## 3. Leak-Scan Text Surfaces

**Collision result: none, for wording that avoids the tokens below.** `parallel-gate-wording.Tests.ps1` has no per-file row for the brief. Two checks reach it:

- `PGW-SWEEP-SURFACES` reads the brief copies through `.claude/skills`, `.agents/skills`, `.github/skills`, and the resource roots, against the 38 tokens of `$script:SweepToken`, case-insensitively, after whitespace collapse. The tokens a scan sentence could reach by accident are `captured baseline`, `numeric baseline`, `coverage baseline`, `compared to baseline`, `regressed from baseline`, `does not regress`, and `targeted tests`. Do not describe the allowlist with any of these.
- `test_brief_copies_carry_no_removed_run_tokens` rejects `single-process`, `seeded`, `shuffled`, `reversed-order`, `--randomize`, `at least three seeds`, `which is the CI shape`, `isolation reference`, and `in addition to the serial runs`. A sentence such as "`Invoke-PoshQCLeakScan` runs in `poshqc / PowerShell QC static` and adds no test run" holds none of them.

**`atomic-plan-contract`.** The `PLAN-*` rows forbid `baseline test-step`, `baseline and final-QC coverage`, `delta/threshold verification`, and `baseline coverage`. `test_contract_premortem_test_isolation_states_parallel_gates` rejects `seeded shuffled`, `reversed-order run`, `at least three seeds`, `file-order run`, and `isolation runs`, and requires the current sentence's phrases. An added scan sentence does not collide if it avoids "isolation runs". The #1096 acceptance criteria do not require this edit. The full-scope spec did, and #1094 explicitly left it out. Recommended: add one sentence directly after the existing one, in all six copies, so that a plan names the scan. Those six copies are not byte-identical.

**Six byte-identical brief copies (`_BRIEF_COPIES`):** `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and under `extensions/drm-copilot/resources/`: `claude-customizations/.claude/skills/execution-environment/SKILL.md`, `codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, and `customizations/.github/skills/execution-environment/SKILL.md`.

**Brief facts the item changes (one task, all six copies, named in the `Mirror parity` bullet):**

| Heading | Current text | Change |
|---|---|---|
| `## Test Isolation Checks` | Names no scan | New bullet after the last one. Do not reword the bullets above it (`## 4. Process-Reduction Ledger`) |
| `## CI Shape and Required Checks` | `poshqc / PowerShell QC static` (format and analyze on `windows-latest`) | Add the leak scan. Keep the backticked context, which `test_brief_ci_section_names_jobs_and_required_contexts` pins. `.github/workflows/README.md` needs no edit, per the base |
| `## CI-Only Failure Classes` | "Files in one shard share a process, so a leak surfaces when shard contents change." | Add that `Invoke-PoshQCLeakScan` is the check, and that a stale allowlist entry fails the static job. Both phrases pinned by `test_brief_passages_state_parallel_gate_facts` stay |
| `## Test Runtime`, pytest bullet | `-n auto` on the command line of the CI step `Run tests with Pytest` and of the parallel VS Code tasks | Extend to `fix_all` and the executor commands, if they change |
| `## PowerShell Route and PoshQC MCP Limits` | No scan route | State that no MCP tool exposes the scan and that the executor reaches it through the `sh` launcher |

**Contract tests.** Add `Invoke-PoshQCLeakScan` to the required tokens of `test_brief_test_isolation_states_parallel_gates`, and the scan phrase to the `## CI-Only Failure Classes` entry of `test_brief_passages_state_parallel_gate_facts`. Keep both names. The draft's `..._and_leak_scan` names do not exist in the tree, and renaming the tests would make step 5 of entry 0001's `## Revert Steps` stale. The #1094 spec left the token out of these tests because the scan did not exist yet, so this item adds it. `execution-environment` is not in `PINNED_FROZEN_SURFACE_HASHES`.

## 4. Process-Reduction Ledger

**Reading: update entry 0001. Do not add a new entry.**

Basis:

- `README.md` covers "every reduction of evidence, plan tasks, gates, or review process", and states that when wording for a reduction lands in a later commit, that commit also updates the reduction's entry.
- Entry 0001's Summary already states the outcome: the gates are one parallel run each, and the local serial runs are gone. #1094 deferred these edits by name. They finish that reduction and add no new one, because the same suites still run once.
- The prompt text in `prompt_builder.py` and `cli_preflight.py` is wording in the literal sense. The executed commands and task dependencies are not, so applying the rule to them is my interpretation. The alternative, a new entry, would split one decision across two reverts.
- "Neither" is the one reading to avoid: `.claude/skills/feature-review-workflow/SKILL.md` makes a reduction with no entry a Blocking finding.

What the update touches:

- `## Files Changed`: add each path, and amend its opening sentence, which bounds the list to the #1094 branch diff.
- `## Prior Text`: add a Revert Block per changed file, because the stored patch is the #1094 diff and does not hold these edits. Leave the patch and state that in `## Stored Patch`.
- Commit: `### Process-reduction ledger` in the review skill requires the `reduction: NNNN` token in the subject of the reduction's own commit, so these edits take a separate commit with `reduction: 0001`.

**The scan needs no entry and restores nothing recorded in 0001.** It adds a gate. No removed run, evidence, or task returns, and the status stays Active. It replaces the detection that entry says was lost (`## Reason and Evidence`: "#1096 adds a static scan for that purpose"), which remains true. The first `## Revert Signals` bullet, "Before #1096 lands", goes inert on merge; reword it in the same update, for example to a leak that the scan misses.

**`Current` fence constraint.** `README.md` requires each `Current` to occur exactly once in its target, and `Invoke-ProcessReductionRevert` throws otherwise. No test enforces this: `PRL-REAL-LEDGER-AGREES` checks structure only. So a broken fence fails silently until a revert.

- Brief: the `Current` fence is the whole bullet list of `## Test Isolation Checks`. A bullet added after the last line keeps it valid. Rewording "A leak found by a gate" or inserting between bullets breaks it, and the fence must then be rewritten in the same commit.
- `atomic-plan-contract`: the `Current` fence is one sentence, and a following sentence keeps it valid.
- The stored patch's `git apply -R --check` can fail once the context moves. Entry 0001 already handles this by directing the reader to the blocks.

`ORCHESTRATOR-CONFIRM:` entry 0001 still reads `Merge commit: pending (PR #1102)` in this tree. Confirm the merge identifier with git and whether another branch has already back-filled it. The same update can carry the back-fill.

## 5. Baselines

Facts only; no recommendation. **Entry 0001 is the ledger entry that covers this:** "plans capture static baselines with no test-suite baseline".

**What a scan-based gate has:**

- The committed allowlist behaves as the baseline for findings. It is the accepted set that the gate compares against, as `config/file-size-baseline.json` is for file size. Stale detection makes it one-directional: a fixed finding forces removal of its entry, as `Compare-FileSizeBaselineEntry` does for a shrunken file.
- It differs from that baseline in two ways. Each entry states a reason, and entries key on path, kind, and name with no line, so a second write of the same key in the same file is not separately reported. The draft's group rule exists for that case.
- The first scan's raw findings (`evidence/baseline/leak-scan-raw.<timestamp>.md`, P2-T1) are the pre-remediation record. It comes from a static tool and runs no suite. It cannot run in Phase 0, because the module is built in Phase 1.
- The contract's static baseline list names format, lint, type check, and analyzer findings. The scan is not listed by name.

**If a test-suite baseline task returned to Phase 0:**

| Area | Difference |
|---|---|
| Phase 0 | Gains one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run with `evidence/baseline/` artifacts |
| Phases 1 to 4 | No change. No task reads a suite baseline |
| Phase 6 | No gate needs it: `## Coverage and File-Size Gates` states that no earlier figure is compared |
| Failure attribution | Pre-existing failures would surface before Phase 1, rather than first at the final gates, which is the draft's stated cost |
| The three named tests | No help: the same parallel form already passed in the #1094 run, so it would not reproduce the reported condition |
| Contract | Conflicts with `## Phase 0 Requirements` ("no test suite runs in it") and with the delegation's rule of one run per gate, re-run only after a fix. No test blocks it, because `PGW-SWEEP-SURFACES` reads surfaces and not feature folders |
| Ledger | One plan's task leaves 0001 standing as a one-off. Restoring it as a general rule is a revert of part of 0001, through its `## Revert Steps` |
| Draft wording | The `Parallel gates only` rule and the Phase 0 preamble would need rewording; P6-T8 forbids `comparison run` in evidence prose |

## Rejected Alternatives

A new ledger entry for the serial commands splits one reduction across two reverts. Leaving `qc_runner.py` serial, as drafted, leaves the executor tool contradicting its own prompt to save one test edit. `-n auto` on the scoped pytest run adds nothing, because it runs named files only.

## Testing Implications

- Gates: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. Jest runs through its normal workers, because bundled resources change.
- Add to the draft's Phase 4 tests: `test_run_full_runs_all_tools_on_entire_codebase` updated; one case asserting that `run_preflight_qc_with_capture` passes `-n auto`; one case for `full_test`; one `VT-` case for label resolution and one for the default test task. Scan unit tests are unchanged from the base.

## Numeric Derivation Evidence

No numeric count is proposed for an approved `spec.md` acceptance criterion. Counts here describe the tree or pinned test facts, and the finding count comes from the first scan run.

## Pre-Mortem

- Review checklists: A reviewer can treat the serial-command edits as a reduction with no entry, which is Blocking. The plan carries the entry 0001 update in its own `reduction: 0001` commit. Spec Decisions 1 to 3 must be ported, or the self-review has nothing to cite.
- Coverage: The new modules enter the population automatically, and the Python edits touch files already measured. Read per-file figures from the single gate run; merged Pester coverage exists only after a green run.
- Mirror parity: The brief changes in six byte-identical copies, the contract sentence in six non-identical copies, and new modules in the bundle with `POSHQC_PARITY_PATHS`. The `Mirror parity` bullet must name the brief-update task, because the static job's stated contents change.
- File size: `fix_all_branches.py` and `test_execution_environment_brief_contracts.py` grow by small amounts. Scan logic stays split across two modules under the 500-line guidance. New fix-all tests go to `test_fix_all_branches.py`.
- Test isolation: The plan uses the parallel gates only. `fix_all` will start shard processes alongside pytest and Jest, which can change timing. The P3-T5 `Push-Location` must sit where rule R2 pairs it, or the scan reports the fix itself.
- CI-only behavior: `poshqc-static` runs on `windows-latest`, so paths normalize before matching. A stale allowlist entry fails only there if the local scan was skipped. A new `VT-` suite reads a tracked JSONC file and must allow `//` comment lines.
- Evidence: Scan and gate values come from files and direct runs, never MCP summaries. The ledger `Current` check has no test, so the plan records a replay of each 0001 block in evidence after the brief edit. Evidence stays under `<FEATURE>/evidence/<kind>/`.
