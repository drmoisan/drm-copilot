# Plan — Skip heavy CI steps for evidence-only commits (#962), design-level replan

- Requirements source: `docs/features/active/2026-10-16-planning-process-churn-964/evidence/other/replan-962/spec.md` (snapshot of the #962 spec, Work Mode `full-bug`; its `## Acceptance Criteria` AC-1 to AC-38 are the only AC source; no `user-story.md`).
- Purpose of this file: validation step O1 of issue #964 (attempt 2). The plan is authored cold from the spec and the tree and is not executed.
- Execution branch: `bug/ci-skip-evidence-only-commits-962`. `<FEATURE>` is `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962`.
- SCRATCH is `<session scratchpad>/issue-962/`; scratch file names begin `issue-962-`. The execution issue is #962, so the namespace uses it.
- "The merge base" means the merge base of `origin/main` and `HEAD`. Every scope comparison anchors on it, never on `origin/main` itself.
- Environment: tool routes, launchers, the PoshQC MCP output limit, the batch budget, hook context, CI shape and the isolation procedure are owned by `.claude/skills/execution-environment/SKILL.md` and are not restated. Pester counts come from `artifacts/pester/pester-junit.xml`, PowerShell line coverage from `artifacts/pester/powershell-coverage.xml`, physical line counts by the brief's method.
- Evidence: every artifact is `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md`, stamped with the UTC write time, and carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`. A consuming task reads the lexicographically greatest `<name>.*.md`.
- Tree state at authoring: `.github/workflows/ci.yml` already declares `merge_group` (#952) and `.github/workflows/_poshqc.yml` already has the sharded job set of #953 (`poshqc-static`, `poshqc-shard`, `poshqc`, `poshqc-linux-hooks`). The `_poshqc.yml` tasks therefore target the sharded shape of D5; P0-T2 re-confirms it on the execution branch.

## Design Contracts

- `scripts/ci/CiChangeScope.psm1` holds only the eight pure functions named in the spec (`## Proposed Fix`, Functions section). It has no `gh`, `git`, file or network call.
- `scripts/ci/Invoke-CiChangeScope.ps1` defines the entry function `Invoke-CiChangeScope`. Parameters `-EventName`, `-HeadSha`, `-HeadRef`, `-HeadRepo`, `-Repository` and `-RunId` default to the D2 environment variables. `-ConfigJson` defaults to the text of `config/ci-docs-only-paths.json`, resolved from `$PSScriptRoot`.
- `-GhInvoker` and `-GitInvoker` take one argument array and return an object with `ExitCode` (int) and `Output` (string). Their production defaults call `gh` and `git`.
- `-OutputWriter` takes `-Target` (`Output`, `Summary`, `Log`, `Warning`) and `-Text`. The production default appends to `$env:GITHUB_OUTPUT` and `$env:GITHUB_STEP_SUMMARY`, writes the log line to the host, and writes the `::warning::` annotation.
- The decision always ends in exactly one `Output` write of `code=true` or `code=false` and one `Log` write of `code=<value> reason=<REASON>`.
- The dot-source guard runs the entry function and calls `exit 0` only when the script is not dot-sourced. Tests dot-source the script, pass every parameter explicitly, inject recording script blocks, and import the real module without mocking it.
- The reusable-workflow input is `run-heavy` (`type: boolean`, `default: true`), declared under both `workflow_call.inputs` and `workflow_dispatch.inputs`, following `.github/workflows/_npm-audit-gate.yml`.

### Phase 0 — Policy Reads and Baseline Capture

- [ ] [P0-T1] Read the policy files in the `policy-compliance-order` order: root `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/shell.md`, `.claude/rules/ci-workflows.md` and `.claude/rules/quality-tiers.md`. Then read the brief `.claude/skills/execution-environment/SKILL.md`. Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:` and every file listed.
- [ ] [P0-T2] Record the dependency composition (AC-30, D5) before any edit to `.github/workflows/ci.yml` or `.github/workflows/_poshqc.yml`. Record five facts:
  - the `origin/main` commit;
  - the head refs of the PR that closed #952 and of PR #959 (#953), read through `gh`;
  - whether #952 is present in `origin/main`, where present means `ci.yml` declares a `merge_group` trigger;
  - whether #953 is present in `origin/main`, where present means `_poshqc.yml` defines a `poshqc-shard` job;
  - the outcome of bringing `origin/main` in with `git merge origin/main`: a merge commit, or the "Already up to date." message. No rebase and no force push is performed.

  Both dependencies are in the authoring tree and `origin/main` cannot lose them. The AC-30 re-integration branch is therefore recorded as not triggered unless one of them is absent at execution start. If one is absent, stop and return to the planner, because P3-T7 targets the sharded shape. Acceptance: `<FEATURE>/evidence/other/dependency-composition.<timestamp>.md` holds the five facts. The test 'declares exactly the poshqc, poshqc-linux-hooks, poshqc-shard, and poshqc-static jobs' in `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` passes.
- [ ] [P0-T3] Capture the PowerShell static baseline for the existing files this plan edits (`tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`). Run `Invoke-PoshQCFormat` from a branch-current import, with the porcelain status captured before and after. If the status differs, list the reformatted files and restore them to `HEAD`, so the baseline describes the committed state. Then run a direct `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. Acceptance: `<FEATURE>/evidence/baseline/powershell-format.<timestamp>.md` records both porcelain observations and any drift. `<FEATURE>/evidence/baseline/powershell-analyze.<timestamp>.md` records the finding count for each file.
- [ ] [P0-T4] Capture the Pester baseline: one fresh single-process `Invoke-PoshQCTest` run over `tests/scripts` with coverage, from a branch-current import of `scripts/powershell/PoshQC/PoshQC.psd1`. Acceptance: `<FEATURE>/evidence/baseline/pester.<timestamp>.md` records:
  - the total, passed and failed counts;
  - the outcome of each touched existing suite: `CiWorkflow.Tests.ps1`, `PoshQcWorkflow.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` and `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`;
  - the overall PowerShell line-coverage percentage, as a number;
  - that `scripts/ci/` is absent.
- [ ] [P0-T5] Capture the Python baseline for `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, `tests/scripts/dev_tools/test_ruff_config_alignment.py` and `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`. Run Black in check mode, Ruff check, Pyright, Pytest on the three modules, and `scripts/dev_tools/check_quality_tiers.py` in module form. Acceptance: one artifact per step under `<FEATURE>/evidence/baseline/` (`python-format`, `python-lint`, `python-typecheck`, `python-test`, `tier-check`), each with its pass or diagnostic count. No production Python file changes, so no Python coverage target applies; the artifact records this.
- [ ] [P0-T6] Capture the bash baseline for `scripts/bash/shell_qc_lib.sh` and `tests/shell/test_shell_qc_commands.bats`. Run `scripts/bash/shell-qc.sh` with `check` and then with `test` through the brief's `sh` launcher route. The baseline bash line coverage is the `Bash coverage (lines)` percentage printed by the `shell-coverage / Shell Coverage (Bats + kcov)` job of the most recent successful `push` run of `ci.yml` on `main`, read through `gh`. Acceptance: these artifacts exist:
  - `<FEATURE>/evidence/baseline/bash-check.<timestamp>.md`;
  - `<FEATURE>/evidence/baseline/bash-test.<timestamp>.md`, with the bats pass count;
  - `<FEATURE>/evidence/baseline/bash-coverage.<timestamp>.md`, with the run id and the numeric percentage.
- [ ] [P0-T7] Capture the actionlint baseline: run `scripts/dev-tools/run-actionlint.ps1` over `.github/workflows/ci.yml` and the six gated reusable workflows. Acceptance: `<FEATURE>/evidence/baseline/actionlint.<timestamp>.md` records the finding count for each of the seven files.

### Phase 1 — Allowlist Config and Pure Decision Module

- [ ] [P1-T1] Create `config/ci-docs-only-paths.json` with the D3 content: `version` 1, the four include prefixes, the two exclude prefixes and the five extensions. Create `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`. It reads the committed file, creates no file, and has one `It` per AC-15 bullet, each tagged `(AC-15)`:
  - every include prefix starts with `docs/`;
  - no include prefix covers `docs/features/templates/`, `docs/engineering/` or `docs/discovery/`;
  - both exclusions are present;
  - no configured extension is in the AC-15 code-extension list.

  Acceptance: the suite reports 4 passed and 0 failed.
- [ ] [P1-T2] Create `scripts/ci/CiChangeScope.psm1` with four path functions, exported through `Export-ModuleMember`:
  - `ConvertFrom-CiDocsOnlyPathConfig` parses JSON text. It throws a distinct message for malformed JSON, for `version` not equal to 1, for an empty or missing `include_prefixes`, and for an extension without a leading `.`.
  - `Test-CiDocsOnlyPath` rejects a `..` segment, a backslash and a leading `/`. Prefix matching is case-sensitive, extension matching is case-insensitive, and an exclusion overrides an inclusion.
  - `ConvertFrom-CiNulPathList` splits NUL-terminated output and throws on non-empty output without a trailing NUL.
  - `Get-CiChangeScopePathDecision` returns `EMPTY_DIFF` for an empty set, `NON_ALLOWLISTED_PATH: <first non-allowlisted path>` for a set with any non-allowlisted path, and a docs-only result otherwise.

  Add data-driven tests (`-ForEach`) to `tests/scripts/ci/CiChangeScope.Tests.ps1`. Build NUL fixtures in memory with `[char]0`. Tag each test with its AC:
  - AC-9: the empty set;
  - AC-10: the set `docs/features/active/x/evidence/a.md` plus `scripts/ci/CiChangeScope.psm1`;
  - AC-12: each include prefix, each extension, and `docs/features/active/x/evidence/RUN.MD`;
  - AC-13: each of the ten negative cases in the spec;
  - AC-14: the four throw cases;
  - AC-8: non-NUL-terminated output throws.

  Acceptance: every tagged test passes.
- [ ] [P1-T3] Add four functions to `scripts/ci/CiChangeScope.psm1`:
  - `Test-CiChangeScopeEventEligible` returns true only for `pull_request`.
  - `Select-CiGreenBaseCandidates` drops the run whose `id` equals the run id, runs whose `head_repository.full_name` differs from the repository, and runs whose `conclusion` is not `success`. It orders the rest by `run_number`, descending.
  - `Test-CiFullRunMarker` returns true only for a job named `CI full run` with conclusion `success`.
  - `New-CiChangeScopeDecision` returns Code, Reason, BaseSha, and the output and log strings of `## Design Contracts`.

  Add tests to `tests/scripts/ci/CiChangeScope.Tests.ps1`, tagged by AC:
  - AC-1: false for `merge_group`, `push` and `workflow_dispatch`; true for `pull_request`;
  - AC-5: current-run exclusion, foreign-head-repository exclusion, and an unsorted fixture;
  - AC-6: true for `success`; false for `skipped`, for `failure`, and when the job is absent.

  Add the test 'imports no I/O command into the pure module (AC-17)'. It parses the module with the PowerShell AST parser and asserts that no command is named `gh`, `git`, `Get-Content`, `Set-Content`, `Add-Content`, `Out-File`, `Invoke-WebRequest`, `Invoke-RestMethod` or `Start-Process`. Acceptance: every tagged test passes, and the module exports exactly the eight spec functions.

### Phase 2 — Entry Script and Tier Classification

- [ ] [P2-T1] Create `scripts/ci/Invoke-CiChangeScope.ps1` to the `## Design Contracts` interface. Its dot-source guard takes the form used by `scripts/dev-tools/Invoke-FullRelease.ps1`, which compares `$MyInvocation.InvocationName` with `.`. Implement four steps of the decision:
  - the event gate;
  - the fork gate;
  - run listing: one `gh api` call to the runs endpoint of `ci.yml`, filtered by branch, event `pull_request` and status `success`, with `per_page=50`;
  - marker lookup: one jobs call per candidate with `per_page=100`, newest first; the first qualifying candidate is the base.

  Add tests to `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, tagged by AC:
  - AC-1: each of the three events writes `code=true` with `EVENT_NOT_PULL_REQUEST`, and both invokers record zero calls;
  - AC-2: `FORK_PULL_REQUEST` with zero calls;
  - AC-3: a non-zero exit and invalid JSON each give `RUN_LIST_FAILED`;
  - AC-4: `JOB_LIST_FAILED`;
  - AC-6: `NO_FULL_GREEN_RUN` for a page whose only successful run has a skipped marker.

  Acceptance: every tagged test passes, and the recording invokers are the only `gh` and `git` route used in the suite.
- [ ] [P2-T2] Extend `scripts/ci/Invoke-CiChangeScope.ps1` with four further steps:
  - ancestry:
    - `cat-file -e` on the base commit failing gives `BASE_NOT_PRESENT`;
    - `merge-base --is-ancestor` exiting 1 gives `BASE_NOT_ANCESTOR`;
    - any other non-zero exit gives `ANCESTRY_CHECK_FAILED`;
  - the diff call: it carries `--name-only`, `-z`, `--no-renames`, `--no-color`, `--no-ext-diff`, `--no-relative`, the base and the head. A non-zero exit or non-NUL-terminated output gives `DIFF_FAILED`;
  - classification through `Get-CiChangeScopePathDecision`;
  - the three writes of `## Design Contracts`, with the reason and base SHA sent to the `Summary` target.

  Add tests, tagged by AC:
  - AC-6: an older qualifying candidate is chosen over a newer non-qualifying one. The recording `-GitInvoker` shows the older candidate's head SHA as the base in the ancestry call;
  - AC-7: the three ancestry outcomes;
  - AC-8: the argument set, and each of the two failure forms;
  - AC-9: `EMPTY_DIFF` through the entry function;
  - AC-11: a docs-only run writes `code=false` to `Output`, writes `code=false reason=DOCS_ONLY_SINCE_` followed by the base to `Log`, and writes the reason and base to `Summary`.

  Acceptance: these tests and the P2-T1 tests pass in one run.
- [ ] [P2-T3] Wrap the flow of `scripts/ci/Invoke-CiChangeScope.ps1` in an error envelope. Any exception, including an invalid `-ConfigJson`, writes a `::warning::` annotation to `Warning` and writes `code=true` with `UNEXPECTED_ERROR`, and the guard still exits 0. Add tests, tagged by AC:
  - AC-14: an invalid config gives `UNEXPECTED_ERROR` and a warning;
  - AC-16: a throwing `-GitInvoker` gives `UNEXPECTED_ERROR` and a warning, and the call does not rethrow.

  The guard's `exit 0` is verified by inspection in P5-T9, because no test starts a process. Acceptance: the tagged tests pass. All three `tests/scripts/ci/` suites pass in one run. Each of the five new files under `scripts/ci/` and `tests/scripts/ci/` is 500 physical lines or fewer.
- [ ] [P2-T4] Add an entry to `quality-tiers.yml` with `path: "scripts/ci"`, `tier: T4` and a rationale naming the CI change-scope decision (AC-29). Stage `scripts/ci/` first, because `discover_projects` in `scripts/dev_tools/quality_tiers_contract.py` reads tracked paths (rule R3). Existing tests that read `quality-tiers.yml` are `test_committed_quality_tiers_yml_matches_live_tree` and `test_committed_quality_tiers_yml_assigns_spec_tiers` in `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`. Both stay unchanged: the new entry names an existing folder, the spec-row check is a subset check, and T4 is not an elevated tier. Acceptance: `scripts/dev_tools/check_quality_tiers.py` in module form exits 0 and both named tests pass. The result is recorded in `<FEATURE>/evidence/qa-gates/tier-check.<timestamp>.md`.

### Phase 3 — Workflow Regression Suite and Workflow Gating

- [ ] [P3-T1] [expect-fail] Create `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`. It partitions workflows into job and step blocks as text, as `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` does, with no YAML module, no process and no temporary file. Its `It` blocks are tagged by AC:
  - AC-18: the `changes` and `full-run-marker` jobs, with every D2 key AC-18 lists;
  - AC-19: the six required callers, the two non-required callers, and `docs-validation`;
  - AC-20, for each of the six files:
    - the `run-heavy` declaration under both triggers;
    - per-step gating in every job that produces a required context;
    - the research §2.3 combined conditions;
    - `always() && inputs.run-heavy` for any `always()` step in a job without a job-level gate;
    - unchanged step conditions inside job-gated jobs;
  - AC-21: the sharded `_poshqc.yml` shape;
  - AC-36: the export-plugin step, `shell: bash`, and the single `continue-on-error`.

  Run the suite before any workflow edit. Acceptance: at least one test per AC tag fails, because the `changes` job and the `run-heavy` input are missing. `<FEATURE>/evidence/regression-testing/workflow-suite-fail-before.<timestamp>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` and the failed test names from the JUnit file (AC-23).
- [ ] [P3-T2] Add the `changes` job (name `Change scope`) and the `full-run-marker` job (name `CI full run`) to `.github/workflows/ci.yml`, as D2 specifies. Do not touch the `on:` block. Existing tests in `tests/scripts/workflows/CiWorkflow.Tests.ps1`:
  - 'reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph' fails, because the `changes` job reads `github.event.pull_request.head.sha`, `github.event_name`, `github.head_ref` and the PR head repository. Update it (D6): the event-field check skips the `changes` job block of `ci.yml`, and a new assertion in the same `It` requires every such read in `ci.yml` to be inside that block. The path-filter check is unchanged. The reads are safe on `merge_group` because the decision fails closed for every non-PR event.
  - 'lists main, development, and epic/** in the pull_request branch filter', 'keeps the push branch filter exactly main and development' and 'declares merge_group with types checks_requested and no branch or path filter' stay unchanged, because they read only the `on:` block.

  Acceptance: the AC-18 tests pass and all four `CiWorkflow.Tests.ps1` tests pass. The assertion change and its reason are recorded in `<FEATURE>/evidence/other/d6-existing-test-changes.<timestamp>.md`.
- [ ] [P3-T3] In `.github/workflows/_quality-checks.yml`, declare `run-heavy` and give every step `if: ${{ inputs.run-heavy }}`, with two exceptions:
  - `Install dependencies` takes `inputs.run-heavy && steps.cached-poetry-dependencies.outputs.cache-hit != 'true'`;
  - `Upload coverage to Codecov` takes `inputs.run-heavy && matrix.python-version == '3.13'`.

  Existing tests:
  - `test_threshold_step_runs_on_every_matrix_leg` in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` asserts that the threshold step has no `if` key. Update it: it asserts that the condition is exactly `${{ inputs.run-heavy }}` and references no `matrix.` value. This keeps its intent, which is that the step is not conditioned onto one matrix leg.
  - These stay unchanged, because none reads a step condition: `test_workflow_names_no_foreign_coverage_target`, `test_pytest_step_uses_bare_cov_with_branch`, `test_pytest_step_emits_json_coverage_report`, `test_threshold_step_invokes_the_checker_with_both_floors`, `test_codecov_step_uses_the_declared_files_input`, and `test_quality_checks_workflow_still_runs_a_ruff_lint_step` in `tests/scripts/dev_tools/test_ruff_config_alignment.py`.
  - 'reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph' in `tests/scripts/workflows/CiWorkflow.Tests.ps1` reads this file and stays as P3-T2 leaves it, because this task adds no event-field read and no path filter.

  Acceptance: the AC-20 tests for this file pass and both Python modules pass under Pytest. The update is appended to the D6 record.
- [ ] [P3-T4] In `.github/workflows/_security-scan.yml`, declare `run-heavy`. Add a step `Install the Poetry export plugin` that runs `poetry self add poetry-plugin-export`, directly before `Check for security vulnerabilities`. Give the scan step `shell: bash`, and keep its `continue-on-error: true` as the only one in the job (AC-36, D14-b). Gate every step on `inputs.run-heavy`. The only existing test that reads this workflow is 'reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph' in `tests/scripts/workflows/CiWorkflow.Tests.ps1`; it stays as P3-T2 leaves it, because this task adds no event-field read and no path filter. Acceptance: the AC-20 and AC-36 tests for this file pass.
- [ ] [P3-T5] In `.github/workflows/_build-check.yml` and `.github/workflows/_drm-copilot-extension-tests.yml`, declare `run-heavy` and gate every step with `if: ${{ inputs.run-heavy }}`. Existing test: 'extension tests workflow runs the typecheck script before tests' in `extensions/drm-copilot/test/package-typecheck-script.test.ts` stays unchanged, because it reads command order and one step name, and neither changes. 'reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph' in `tests/scripts/workflows/CiWorkflow.Tests.ps1` reads both files and stays as P3-T2 leaves it, because this task adds no event-field read and no path filter. Acceptance: the AC-20 tests for both files pass, and that Jest test passes when run alone through the brief's Jest route.
- [ ] [P3-T6] In `.github/workflows/_shell-coverage.yml`, declare `run-heavy` and gate every step. `Build kcov from source` takes `inputs.run-heavy && steps.cache-kcov.outputs.cache-hit != 'true'`. Gating `Upload shell coverage artifacts` keeps its `if-no-files-found: error` from running on a docs-only run. The only existing test that reads this workflow is 'reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph' in `tests/scripts/workflows/CiWorkflow.Tests.ps1`; it stays as P3-T2 leaves it, because this task adds no event-field read and no path filter. Acceptance: the AC-20 tests for this file pass.
- [ ] [P3-T7] In `.github/workflows/_poshqc.yml` (sharded shape, D5), declare `run-heavy`. Add a job-level `if: ${{ inputs.run-heavy }}` to `poshqc-static`, `poshqc-shard` and `poshqc-linux-hooks`, and leave their step conditions unchanged. Keep `if: always()` on `poshqc`, and add `if: ${{ inputs.run-heavy }}` to each of its seven steps, including `Require the static and shard jobs to succeed`. Existing tests in `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`:
  - `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE` fails, because `$script:GetResultGateViolation` reports any step-level `if:` on the gate step. Update it (D6): the helper accepts exactly `if: ${{ inputs.run-heavy }}` and still reports any other condition.
  - `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS` stays unchanged, because its four mutations are still reported.
  - These stay unchanged, because they read lines this task does not edit:
    - 'declares exactly the poshqc, poshqc-linux-hooks, poshqc-shard, and poshqc-static jobs';
    - 'keeps the poshqc job as the PowerShell QC merge job on windows-latest after the static and shard jobs';
    - the five `poshqc-linux-hooks` tests;
    - the two `poshqc-shard` tests, including the shard upload `always()` pattern;
    - 'runs the format and analyze gates in the poshqc-static job (issue #953)';
    - `WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS`, because one job-level `always()` remains;
    - `WF04-SHARD-COUNT-FROM-MATRIX`;
    - `WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT`;
    - `RS07-WORKFLOW-LINUX-PESTER-RANGE` in `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`;
    - 'reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph' in `tests/scripts/workflows/CiWorkflow.Tests.ps1`, as P3-T2 leaves it, because this task adds no event-field read and no path filter.

  Acceptance: the AC-21 tests pass, and `PoshQcWorkflow.Tests.ps1` and `PoshQC.RunSettings.Tests.ps1` pass. The helper change is appended to the D6 record.
- [ ] [P3-T8] Edit the callers in `.github/workflows/ci.yml`:
  - `quality-checks7`, `security-scan`, `build-check`, `poshqc`, `shell-coverage` and `drm-copilot-extension-tests` each get `needs: changes`, `if: ${{ !cancelled() }}` and `with: run-heavy: ${{ needs.changes.outputs.code != 'false' }}`;
  - `root-typescript-tests` and `npm-audit-gate` get `needs: changes` and `if: ${{ !cancelled() && needs.changes.outputs.code != 'false' }}`, and `npm-audit-gate` keeps `audit-level`;
  - `docs-validation` is unchanged.

  The four `CiWorkflow.Tests.ps1` tests receive no further change after P3-T2, because the `uses:` lines and the `on:` block do not change and the caller lines add no event-field read. Acceptance: the AC-19 tests pass and `CiWorkflow.Tests.ps1` passes.
- [ ] [P3-T9] Run the whole `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` suite after the edits. Acceptance: 0 tests fail. `<FEATURE>/evidence/regression-testing/workflow-suite-pass-after.<timestamp>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` and the pass count (AC-23).

### Phase 4 — Workflow README and Shell QC Follow-Ups

- [ ] [P4-T1] Make the D14-a corrections in `.github/workflows/README.md` (AC-35):
  - the opening paragraph says `ci.yml` composes "nine reusable per-stage workflows";
  - the `## Per-Stage Dispatch` table gains a `_npm-audit-gate.yml` row;
  - the sentence in `## Scope of This Refactor` that begins "All seven jobs in" now begins "The seven jobs it extracted from".

  Acceptance: apart from the P4-T2 section, the README diff from the merge base changes only these three places. The result is recorded in `<FEATURE>/evidence/qa-gates/readme-check.<timestamp>.md`.
- [ ] [P4-T2] Append a section `## Change-Scope Decision (Docs-Only Runs)` at the end of `.github/workflows/README.md` (AC-24, D9). It documents:
  - the decision and its thirteen reason codes;
  - `config/ci-docs-only-paths.json` and its rules;
  - the fail-closed cases;
  - `run-heavy` and its default;
  - the D1 table of the 11 required contexts.

  Acceptance: the section is the last heading of the file and names all 11 contexts and all thirteen reason codes. The `## Triggers` section is identical to the merge base. Both facts are appended to the readme-check record.
- [ ] [P4-T3] Make the D14-c change (AC-37): `run_test` and `run_test_coverage` in `scripts/bash/shell_qc_lib.sh` pass `--recursive` to bats, before the directory. The `test [--coverage]` usage text in `scripts/bash/shell-qc.sh` says that bats runs recursively. Add two tests to `tests/shell/test_shell_qc_commands.bats`:
  - 'test passes --recursive to bats for each test directory': the recording `bats` stub output contains `--recursive tests/shell`;
  - 'test --coverage passes --recursive to bats under kcov': the `kcov` stub output contains `--recursive tests/shell`. It asserts on output only, because P4-T4 changes this path's exit status.

  Existing tests:
  - 'test fails when a bats child sources a nounset library inside bash -c' asserts `nounset-stub ran: tests/shell`, and 'test passes when a bats child resets nounset after sourcing' asserts `nounset-reset-stub ran: tests/shell`. Both strings come from the argv of `tests/fixtures/shell_qc/stub-bin/bats-nounset-source` and `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset`. Update both to the same prefix followed by `--recursive tests/shell`, because the flag now leads the argv. The stubs are unchanged.
  - 'test --coverage builds the kcov argv and merges the runs' stays unchanged in this task, because its `tests/shell` match still holds.
  - The `tests/shell/test_shell_qc_discovery.bats` tests stay unchanged, because `find_bats_test_dirs` does not change.
  - '--help prints usage and exits 0', 'help subcommand prints usage and exits 0' and 'an unknown subcommand prints usage and exits 2' read the usage text and stay unchanged, because they match only the `Usage: shell-qc.sh` line, which this task does not edit.

  Acceptance: the two new tests and the two updated tests pass through the brief's `sh` launcher route. The number of tests bats reports equals the number of `@test` lines under `tests/shell/`, recorded in `<FEATURE>/evidence/qa-gates/bash-recursive.<timestamp>.md`.
- [ ] [P4-T4] Make the D14-d change (AC-38): add `check_coverage_threshold` to `scripts/bash/shell_qc_lib.sh`.
  - Its argument is the `cov.xml` path. The minimum comes from `SHELL_QC_MIN_LINE_COVERAGE`, default 85.
  - A minimum that is not an integer from 0 to 100 returns 2 with a message. A missing or unparseable report returns 1.
  - The percentage comes from `extract_cobertura_line_rate`. On success the function prints `Bash coverage <NN.N>% meets the minimum line coverage of <min>%.`; below the minimum it prints `Bash coverage <NN.N>% is below the minimum line coverage of <min>%.` and returns 1.
  - `run_test_coverage` calls it after `print_coverage_summary` and returns its status.
  - The usage text in `scripts/bash/shell-qc.sh` documents the variable.

  Add six tests to `tests/shell/test_shell_qc_commands.bats`, run against `tests/fixtures/shell_qc/cov/cov.xml` (75.0%):
  - minimum 80: status 1;
  - minimum 75: status 0, and the output is `Bash coverage 75.0% meets the minimum line coverage of 75%.`;
  - minimum 70: status 0;
  - minimum `8.5`: status 2;
  - minimum 101: status 2;
  - a missing report path: status 1.

  Existing tests:
  - 'test --coverage builds the kcov argv and merges the runs' expects status 0. The recording stub `tests/fixtures/shell_qc/stub-bin/kcov` writes no `cov.xml`, so the threshold now fails closed. Update the test to expect status 1 and the missing-report message, and leave its argv assertions unchanged. Correct the stub's header comment, which says the exit stays 0; the stub's behavior does not change.
  - These stay unchanged, because they return before the threshold or do not call it: 'print_coverage_summary formats the fixture line-rate to one decimal percent', 'extract_cobertura_line_rate reads the fixture line-rate', and the two `exits 127` tests.
  - '--help prints usage and exits 0', 'help subcommand prints usage and exits 0' and 'an unknown subcommand prints usage and exits 2' stay unchanged, because the usage-text addition leaves the `Usage: shell-qc.sh` line they match unchanged.

  Acceptance: the six new tests and the updated test pass. `scripts/bash/shell_qc_lib.sh`, `scripts/bash/shell-qc.sh` and `tests/shell/test_shell_qc_commands.bats` are each 500 physical lines or fewer.

### Phase 5 — Final QA and Self-Review

- [ ] [P5-T1] Run the PowerShell static gate (AC-26) over `scripts/ci/` and the changed suites under `tests/scripts/`:
  - `Invoke-PoshQCFormat` over the repository, with the porcelain status captured before and after;
  - a direct `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` on every new or changed `.ps1`, `.psm1` and `.Tests.ps1` file. The file list is the name-only diff from the merge base together with the untracked files from the porcelain status.

  Acceptance: `<FEATURE>/evidence/qa-gates/powershell-format.<timestamp>.md` shows identical before and after status. `<FEATURE>/evidence/qa-gates/powershell-analyze.<timestamp>.md` shows 0 findings for each file. A change or a finding restarts Phase 5 at this task.
- [ ] [P5-T2] Run one fresh single-process `Invoke-PoshQCTest` over `tests/scripts` with coverage, which is the CI shape. Acceptance: `<FEATURE>/evidence/qa-gates/pester.<timestamp>.md` records 0 failed, and every suite under `tests/scripts/ci/` and `tests/scripts/workflows/` passes, as do `PoshQC.RunSettings.Tests.ps1` and `Invoke-CiGateParser.Tests.ps1`. `<FEATURE>/evidence/qa-gates/powershell-coverage.<timestamp>.md` records the overall percentage and the per-file line coverage of `scripts/ci/CiChangeScope.psm1` and `scripts/ci/Invoke-CiChangeScope.ps1`; each file is at least 85% (AC-27, D8).
- [ ] [P5-T3] Write the coverage delta. Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` records:
  - the PowerShell baseline overall percentage from P0-T4;
  - the PowerShell post-change overall percentage from P5-T2, which is not lower than the baseline;
  - the new-file values from P5-T2;
  - the bash baseline from P0-T6, with the note that post-change bash coverage is read from the PR run at S9 (AC-38).

  A missing number makes the outcome remediation-required.
- [ ] [P5-T4] Run the Python loop: Black in check mode, Ruff check and Pyright on `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, then Pytest on that module, `tests/scripts/dev_tools/test_ruff_config_alignment.py` and `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`. Acceptance: one artifact per step under `<FEATURE>/evidence/qa-gates/` (`python-format`, `python-lint`, `python-typecheck`, `python-test`) shows a clean check and 0 failed. A failure restarts the loop.
- [ ] [P5-T5] Run the bash loop: `scripts/bash/shell-qc.sh` with `check` and then with `test`, through the brief's `sh` launcher route. Acceptance: `<FEATURE>/evidence/qa-gates/bash-check.<timestamp>.md` records exit 0, and `<FEATURE>/evidence/qa-gates/bash-test.<timestamp>.md` records 0 failed bats tests.
- [ ] [P5-T6] Run `scripts/dev-tools/run-actionlint.ps1` over `.github/workflows/ci.yml` and the six changed reusable workflows (AC-25). Acceptance: `<FEATURE>/evidence/qa-gates/actionlint.<timestamp>.md` records 0 findings for each file.
- [ ] [P5-T7] Run the isolation checks of `## Test Isolation Checks` in `.claude/skills/execution-environment/SKILL.md`:
  - a seeded, shuffled file-order, single-process Pester run of the touched suites, with three seeds. The suites are the three `tests/scripts/ci/` suites, `CiChangeScopeWorkflow.Tests.ps1`, `CiWorkflow.Tests.ps1`, `PoshQcWorkflow.Tests.ps1` and `PoshQC.RunSettings.Tests.ps1`;
  - a reversed-order run of `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`.

  Acceptance: `<FEATURE>/evidence/regression-testing/isolation-pester.<timestamp>.md` records each seed, its file order and 0 failures. `<FEATURE>/evidence/regression-testing/isolation-python.<timestamp>.md` records 0 failures. An order dependence is fixed on both sides, and every seed is then re-run.
- [ ] [P5-T8] Verify the unchanged surfaces (AC-22, AC-28, D4). The name-only diff from the merge base, together with the porcelain status, lists none of the seven AC-22 paths. The `on:` block of `.github/workflows/ci.yml` and the `## Triggers` section of `.github/workflows/README.md` are identical to the merge base. The edits to `CiWorkflow.Tests.ps1` and `PoshQcWorkflow.Tests.ps1` are exactly those in the D6 record. `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` passes unchanged, including 'returns success when a check is skipping (skipping is non-blocking)' and 'returns pending for an empty check array with -RequireWorkflow CI'. Acceptance: `<FEATURE>/evidence/qa-gates/scope-surfaces.<timestamp>.md` holds one PASS row per check, with both test names recorded.
- [ ] [P5-T9] Verify structure and evidence location (AC-17, AC-31) for `scripts/ci/` and `tests/scripts/ci/`, by inspection and by the passing suites:
  - the purity test of P1-T3 passes;
  - `scripts/ci/Invoke-CiChangeScope.ps1` exposes the three seams and the guard;
  - the tests are in the three AC-17 files;
  - those files contain no `New-TemporaryFile`, `TestDrive`, `GetTempFileName` or `Start-Process`, and no direct `gh` or `git` call;
  - no `.py` or `.sh` file is added under `scripts/ci/`;
  - every new or changed production and test file is 500 physical lines or fewer;
  - every artifact this plan wrote is under `<FEATURE>/evidence/<kind>/`.

  Acceptance: `<FEATURE>/evidence/qa-gates/structure.<timestamp>.md` holds one PASS row per check.
- [ ] [P5-T10] Record Proof Procedure step P0 and the CI-dependent handoff under `<FEATURE>/evidence/regression-testing/` and `<FEATURE>/evidence/other/`.
  - Run `gh run view 38896898318 --repo drmoisan/drm-copilot --json createdAt,updatedAt,conclusion,headSha`. Record the output and the duration (`updatedAt - createdAt`) in `<FEATURE>/evidence/regression-testing/proof-p0.<timestamp>.md`.
  - Write `<FEATURE>/evidence/other/ci-dependent-handoff.<timestamp>.md`. It assigns these checks to the item orchestrator at S9, with outputs recorded under `<FEATURE>/evidence/regression-testing/`:
    - AC-32: steps P1.1 to P1.3;
    - AC-33: steps P2.1 to P2.7;
    - AC-34: step P3;
    - AC-36: a non-vacuous scan, and a `security-scan` job concluding success;
    - AC-37: the bats test count against the `@test` count;
    - AC-38: the threshold log line.

  Acceptance: both files exist. The P0 record holds `createdAt`, `updatedAt` and the computed duration.
- [ ] [P5-T11] Run the final QA self-review. Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `docs/features/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` and `docs/features/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff from the merge base. Write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL or N/A row per checklist item. For a FAIL row: fix the defect, re-run Phase 5 from P5-T1, and rewrite the self-review. Acceptance: the self-review has no FAIL row.

## Pre-Mortem

- **Review checklists:** P5-T11 walks all three templates against the merge-base diff before review. The D6 record (P3-T2, P3-T3, P3-T7) records every edit to an existing test, with its reason, so no edit to a protected suite goes unrecorded. The README check and the scope-surfaces record give each AC-22, AC-24 and AC-35 claim its own record.
- **Coverage:** The two new PowerShell files are measured per file from `artifacts/pester/powershell-coverage.xml` in a fresh single-process run (P5-T2), with a floor of 85% each. The entry tests use the real module and in-memory seams, not blanket mocks, so measured lines are lines that ran. No production file is excluded. The bash threshold function is covered by six bats tests that kcov measures in CI. No production Python or TypeScript file changes.
- **Mirror parity:** No mirrored or bundled file is edited. The parser bundle mirror and both skill files are confirmed unchanged in P5-T8. The brief's CI-shape list is not edited, because adding two non-required jobs is not a refresh trigger under its Refresh rule, so no push-down contract test is affected.
- **File size:** Each new production and test file (the two `scripts/ci/` files, the three `tests/scripts/ci/` suites and `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`), `scripts/bash/shell_qc_lib.sh`, `scripts/bash/shell-qc.sh` and `tests/shell/test_shell_qc_commands.bats` is checked against the 500-line limit in P2-T3, P4-T4 and P5-T9. The Pester suites use `-ForEach` data tables so that the three AC-17 suites stay within the limit.
- **Test isolation:** P5-T7 runs a seeded, shuffled file-order Pester run of the touched suites with three seeds, recording each seed and file order, and a reversed-order run of the changed Python module. A seeded shuffled Jest run does not apply: no TypeScript file changes, and the one unchanged Jest test is run alone in P3-T5 only to confirm that it is unaffected. P5-T2 adds a fresh single-process run over `tests/scripts`. No test writes a temporary file or mutates environment variables, because parameters are passed explicitly.
- **CI-only behavior:** Several facts are observable only on the PR: the API responses, the partial-clone checkout, the skipped-step success reporting, check-run names, the `poetry export` scan, and real kcov. These are AC-32 to AC-34 and AC-36 to AC-38, handed to S9 in P5-T10. `_shell-coverage.yml` checks out at depth one, and no new test diffs against `origin/main`. NUL fixtures are built in memory, so the `eol=lf` attribute cannot alter them. The new suites run in the Windows shards, and they still use `Join-Path` and forward-slash relative paths.
- **Evidence:** Every artifact path is `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md`, stamped with the UTC write time and carrying the four required fields. Scratch locations are recorded as the token `SCRATCH`, and no artifact records a host path. Consumers read the greatest matching file. The expect-fail run of P3-T1 has its own regression-testing record.

## Scope Notes

- Out of scope, per the spec's `## Out of Scope`:
  - a CI actionlint job;
  - a ruleset change;
  - merge-queue enablement;
  - Candidates A and C, and the B-variant;
  - allowlist growth beyond D3;
  - any change to `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, its bundle mirror, `.claude/skills/orchestrate/SKILL.md` and `.claude/skills/parallel-orchestrate/SKILL.md`.
- Batch budget: the plan edits two production PowerShell files, both under `scripts/ci/`, which is within the brief's cap.
