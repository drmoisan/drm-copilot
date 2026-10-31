# pytest-xdist-parallel-test-cycle - Plan

- **Issue:** #1048
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31T13-02
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Route:** large, orchestrated (more than three production PowerShell files plus their bundled mirrors)

## Required References

- Requirements: `spec.md`, `user-story.md`, `issue.md`, `owner-decisions.md`, and `research/research.2026-10-31T13-15.md` in this folder. The research `## Recommendation`, `## Files expected to change`, and `## Pre-Mortem` sections are binding.
- Policies: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/quality-tiers.md`.
- Environment: the `execution-environment` skill (brief) owns tool routes, the PowerShell route, launchers, command-text restrictions, the batch budget, hook context, and CI shape. This plan does not restate them; every PowerShell run below uses the brief's PowerShell route, and every scope diff anchors on the merge base of `origin/main` and `HEAD`.

## Terms

- `FEATURE` denotes `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048`.
- `SCRATCH` resolves to `<session scratchpad>/issue-1048/`. Every scratch file, launcher, plugin, staged copy, and downloaded artifact lives under it; artifacts record the literal token `SCRATCH`.
- Evidence files are named `<name>.<timestamp>.md` with the UTC write time; a consumer selects the lexicographically greatest match.
- Constraints carried from the brief and owner decisions: no new Python script in the repository (scratch helpers under `SCRATCH` are permitted); no Python in hooks; `-n` never in `addopts`; no `psutil`; the Pester runner is PowerShell; the shard count stays at three unless the Phase 9 decision requires a further shard.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reading and Baseline Capture

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/ci-workflows.md`, and the execution-environment brief, and write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and every file above by path.
- [ ] [P0-T2] Capture the serial Python baseline: `poetry run pytest --durations=25 --junitxml=SCRATCH/issue-1048-pytest-serial-baseline.xml --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1048-serial-baseline.json --cov`, and write `FEATURE/evidence/baseline/pytest-serial.<timestamp>.md`.
  - Acceptance: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` present; the summary records passed and failed counts, wall-clock seconds, `totals.percent_statements_covered` and `totals.percent_branches_covered` read from the JSON report, and the 25 slowest tests.
- [ ] [P0-T3] Capture the serial Pester baseline by running `Invoke-PoshQCTest -Root <worktree root>` from `scripts/powershell/PoshQC/PoshQC.psd1` through the brief's PowerShell route, then copy `artifacts/pester/pester-junit.xml` to `SCRATCH/issue-1048-pester-serial-baseline.xml`, and write `FEATURE/evidence/baseline/pester-serial.<timestamp>.md`.
  - Acceptance: the four schema fields are present; the summary records `testsuites@tests`, `failures`, `errors`, the root `time`, the `testsuite` element count, and per-file line coverage of `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and `scripts/powershell/PoshQC/PoshQC.Shard.psm1` read from `artifacts/pester/powershell-coverage.xml`.
- [ ] [P0-T4] Capture the PowerShell analyzer baseline with a direct `Invoke-ScriptAnalyzer` run using `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts/powershell/PoshQC`, and write `FEATURE/evidence/baseline/pssa.<timestamp>.md`.
  - Acceptance: the four schema fields are present and the summary records the finding count by severity.
- [ ] [P0-T5] Record the CI baseline from the newest `ci.yml` run on `main` whose `CI full run` job succeeded (read with `gh run list` and `gh run view --json jobs`), and write `FEATURE/evidence/baseline/ci-durations.<timestamp>.md`.
  - Acceptance: the artifact names the run id and records the duration in seconds of `quality-checks7 / Code Quality & Tests (3.13)`, `poshqc / PowerShell QC static`, each of `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3`, and `poshqc / PowerShell hook suites (Linux)`, and the shard spread (longest minus shortest shard).
- [ ] [P0-T6] Record the physical line counts of `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.Shard.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, and `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` (counted with `wc -l`) in `FEATURE/evidence/baseline/file-sizes.<timestamp>.md`.
  - Acceptance: the four schema fields are present with one count per file.

### Phase 1 — pytest-xdist Dependency, CI Step, and Contract Tests

- [ ] [P1-T1] Add `pytest-xdist` with the constraint `^3` to `[tool.poetry.group.dev.dependencies]` in `pyproject.toml` through Poetry, so `poetry.lock` is regenerated by Poetry; do not add `psutil`, and do not edit `[tool.pytest.ini_options]`.
  - Acceptance: `poetry check --lock` exits 0; `poetry.lock` contains a `name = "pytest-xdist"` package entry, and the count of `name = "psutil"` entries (plain `grep -c` on the tracked file) equals the merge-base count; the `addopts` value in `pyproject.toml` is byte-identical to the merge-base value.
- [ ] [P1-T2] Add `test_pytest_step_runs_xdist_workers` to `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`: it shell-splits the `Run tests with Pytest` step with `run_tokens` and asserts that the token after `-n` is `auto` or `4` and that `-n` occurs once.
  - Acceptance: the test exists with an Arrange-Act-Assert docstring; it fails before P1-T4 and passes after it.
- [ ] [P1-T3] Add `test_pyproject_addopts_carries_no_xdist_flag` to the same file: it reads `pyproject.toml` as text (no `tomllib`, because the Python 3.10 matrix leg lacks it), extracts the `addopts` string under `[tool.pytest.ini_options]`, shell-splits it, and asserts no token equals `-n` and no token starts with `--numprocesses` or `--dist`.
  - Acceptance: the test passes on the current tree; a companion test `test_addopts_xdist_check_rejects_injected_flag` feeds an in-memory pyproject text whose `addopts` carries `-n auto` to the same extraction helper and asserts the check reports it, so the check can fail; `pyproject.toml` is not edited.
- [ ] [P1-T4] Add `-n auto` to the `poetry run pytest` command of the `Run tests with Pytest` step in `.github/workflows/_quality-checks.yml`, keeping the step name, `--cov`, `--cov-branch`, `--cov-report=xml`, `--cov-report=json:artifacts/python/coverage.json`, and `--cov-report=term-missing`, and leaving the threshold and Codecov steps unchanged.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py -q` passes with every existing test (`test_workflow_names_no_foreign_coverage_target`, `test_pytest_step_uses_bare_cov_with_branch`, `test_pytest_step_emits_json_coverage_report`, `test_threshold_step_invokes_the_checker_with_both_floors`, `test_threshold_step_runs_on_every_matrix_leg`, `test_codecov_step_uses_the_declared_files_input`) unchanged because the added tokens break none of their assertions, plus the two new tests.
- [ ] [P1-T5] Add two tasks to `.vscode/tasks.json` beside `QC: 4 Pytest: run tests`: `QC: 4 Pytest: run tests (parallel)` running `poetry run pytest -n auto`, and `QC: 4 Pytest: run tests with coverage (parallel)` running `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov`, in the file's existing sorted-key, tab-indented style; keep `QC: 4 Pytest: run tests` and every other task unchanged.
  - Acceptance: `poetry run python -m scripts.dev_tools.validate_json` exits 0; both labels and the unchanged `QC: 4 Pytest: run tests` label are present; neither new task contains `lexile_corpus_tuner`.

### Phase 2 — Python Order Independence, Coverage Equality, and Strictness Decisions

- [ ] [P2-T1] [expect-fail] Add `test_clipboard_tests_leave_module_bindings_intact` to `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`: it calls the three clipboard test functions (`test_copy_to_clipboard_with_pyperclip_success`, `test_copy_to_clipboard_pyperclip_failure_fallback`, `test_copy_to_clipboard_no_mechanism`) in its Act step, then asserts that `sys.modules["scripts.dev_tools.resolve_hard_lock_prompt"].resolve_prompt is resolve_prompt` and `.main is main` (the top-level imports), so a later test in the same process sees the original module objects; run it and record the failing run in `FEATURE/evidence/regression-testing/hard-lock-reload-fail-before.<timestamp>.md`.
  - Acceptance: the artifact carries the four schema fields and `ExpectedExitCode: 1`, and the recorded failure names the identity assertion.
- [ ] [P2-T2] Remove the three `importlib.reload(resolve_hard_lock_prompt)` calls and their imports from the clipboard tests in `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`; `copy_to_clipboard` in `scripts/dev_tools/resolve_hard_lock_prompt.py` imports `pyperclip` at call time, so `patch.dict("sys.modules", ...)` alone supplies the mock and no module state is replaced.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -q` passes, including `test_clipboard_tests_leave_module_bindings_intact` and the three clipboard tests with their assertions unchanged; no `importlib.reload` occurrence remains in the file.
- [ ] [P2-T3] Read the `isolated_import_state` helper in `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`, confirm that it restores `sys.path` and every `scripts.*` entry of `sys.modules` in a `finally` block, and record the finding in `FEATURE/evidence/other/isolated-import-state-review.<timestamp>.md`; if restoration is incomplete, fix the helper in that test file in this task.
  - Acceptance: the artifact states `RESTORES-ON-EXIT: yes` or names the fix made and the test node ids that pass after it.
- [ ] [P2-T4] Create `SCRATCH/issue-1048-plugins/order_plugin.py`, a pytest plugin whose `pytest_collection_modifyitems` either reverses the items or shuffles them with `random.Random(seed)` from the environment variable `ISSUE_1048_ORDER_SEED`, printing the mode and seed in the session header; it is a scratch helper, not a repository file.
  - Acceptance: a collect-only run with the plugin loaded through `-p order_plugin` and `PYTHONPATH` set to `SCRATCH/issue-1048-plugins` prints the mode and seed; `git status --porcelain` shows no new file outside `FEATURE`.
- [ ] [P2-T5] Run the full suite reversed in one process and record `FEATURE/evidence/regression-testing/pytest-reversed.<timestamp>.md`.
  - Acceptance: four schema fields; zero failures; the summary records the mode line printed by the plugin.
- [ ] [P2-T6] Run the full suite shuffled in one process with seeds `1048`, `20261031`, and `7`, and record `FEATURE/evidence/regression-testing/pytest-shuffled.<timestamp>.md` with one row per seed.
  - Acceptance: each row carries its seed, the command, the exit code, and zero failures.
- [ ] [P2-T7] Run the full suite three times with `-n auto` and once with `-n 4`, then run `git status --porcelain`, and record `FEATURE/evidence/regression-testing/pytest-xdist-runs.<timestamp>.md`.
  - Acceptance: one row per run with the worker count printed in the xdist header, wall-clock seconds, and zero failures; the porcelain output lists no path outside `FEATURE` (no file written by tests).
- [ ] [P2-T8] Fix every leaker and victim exposed by P2-T5 through P2-T7 in test code only (never by ordering, markers, or `-p no:` exclusions), then re-run each failing configuration with the same seed; record `FEATURE/evidence/regression-testing/pytest-isolation-fixes.<timestamp>.md`.
  - Acceptance: the artifact lists each fix with leaker file, victim file, and the re-run result, or states `NONE FOUND`; every re-run has zero failures.
- [ ] [P2-T9] Run `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1048-xdist.json --cov`, then `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report SCRATCH/issue-1048-xdist.json --min-line 85 --min-branch 75`, and record `FEATURE/evidence/regression-testing/pytest-coverage-equality.<timestamp>.md`.
  - Acceptance: the artifact records `totals.percent_statements_covered` and `totals.percent_branches_covered` from this report and from the P0-T2 baseline report, their differences (each within 0.1 percentage point), and the checker exit code 0.
- [ ] [P2-T10] Probe each strictness option in a separate full serial run (`--strict-markers`, `--strict-config`, `-o xfail_strict=true`, `-W error`, `--import-mode=importlib`), and record `FEATURE/evidence/other/pytest-strictness-probes.<timestamp>.md` with one row per option.
  - Acceptance: five rows, each with the command, exit code, failure count, and the first failing node id when one fails.
- [ ] [P2-T11] Write `FEATURE/evidence/other/pytest-strictness-decisions.<timestamp>.md` with an `ADOPT` or `DEFER` decision and reason per option (adopt only an option whose probe failed with zero tests or needs only trivial test edits), and write each deferral as an entry in `FEATURE/evidence/other/follow-ups.<timestamp>.md`.
  - Acceptance: five decisions; one follow-up entry per `DEFER`.
- [ ] [P2-T12] Apply every `ADOPT` decision to `[tool.pytest.ini_options]` in `pyproject.toml` (`xfail_strict = true` as its own key; a command-line flag appended after the existing `addopts` tokens), together with any trivial test edit the decision names; when no option is adopted, the file stays unchanged and the decision record states so.
  - Acceptance: `poetry run pytest -q` exits 0; `test_pyproject_addopts_carries_no_xdist_flag` passes; the existing `-ra --cov-report=lcov:artifacts/python/lcov.info` tokens remain first in `addopts`.

### Phase 3 — Invoke-PoshQCTest Output-Path Parameters

- [ ] [P3-T1] Create `tests/scripts/powershell/PoshQC/PoshQC.TestingOutputPath.Tests.ps1` with in-memory seams modeled on `PoshQC.TestingShard.Tests.ps1` (`$script:NewSeams`, no file read or written) and cases `OP01-TESTRESULT-PATH-OVERRIDES-SETTINGS`, `OP02-COVERAGE-PATH-OVERRIDES-SETTINGS`, `OP03-OMITTED-PATHS-KEEP-SETTINGS`, and `OP04-RELATIVE-OVERRIDE-RESOLVED-AGAINST-ROOT`; the `BuildConfiguration` seam returns `TestResult` and `CodeCoverage` objects whose `OutputPath` values the `InvokePester` seam captures.
  - Acceptance: OP01, OP02, and OP04 fail before P3-T2 (unknown parameter); OP03 passes before and after.
- [ ] [P3-T2] Add optional `[string] $TestResultPath` and `[string] $CoverageOutputPath` parameters to `Invoke-PoshQCTest` in `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, with comment-based help, applied immediately after the `BuildConfiguration` seam call and before the `EnsureResultPath` and `ExpandCoveragePaths` seams so the existing relative-to-root resolution and directory creation apply to them; when a parameter is omitted or blank the settings value is unchanged. No other edit is made to the function.
  - Acceptance: `PoshQC.TestingOutputPath.Tests.ps1` passes all four cases; the existing suites that assert `Invoke-PoshQCTest` behavior (`PoshQC.TestingShard.Tests.ps1`, `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, `PoshQC.TestingInvokeSummary.Tests.ps1`, `PoshQC.TestingCoveragePruning.Tests.ps1`, `PoshQC.TestingSeamDefaults.Tests.ps1`, `PoshQC.TestingCommands.Tests.ps1`, `PoshQC.Comprehensive.Tests.ps1`) pass unchanged because omitted parameters keep the existing behavior; the file stays at or below 800 lines.

### Phase 4 — Measured Shard Weights in PoshQC.Shard.psm1

- [ ] [P4-T1] Create `tests/scripts/powershell/PoshQC/PoshQC.ShardWeights.Tests.ps1` (in-memory weights text through an injected `ReadWeightsText` seam, `FileInfo` items whose paths are never opened, `InModuleScope PoshQC`) with cases `SW01-LISTED-FILES-USE-MILLISECONDS`, `SW02-UNLISTED-FILE-USES-MEDIAN`, `SW03-ABSENT-FILE-FALLS-BACK-TO-SIZE`, `SW04-MALFORMED-FILE-THROWS` (invalid JSON, wrong `version`, `unit` other than `ms`, empty `files`, negative value), `SW05-NO-ROOT-KEEPS-SIZE-PATH`, and `SW06-SELECT-PASSES-ROOT-AND-READER`, plus a case `SW07-DEFAULT-READER-RETURNS-TEXT-OR-NULL` that mocks `Test-Path` and `Get-Content` by name and asserts the default reader returns the mocked text when the file exists and `$null` when it does not.
  - Acceptance: SW01, SW02, SW04, SW06, and SW07 fail before P4-T2; SW03 and SW05 pass before and after.
- [ ] [P4-T2] Extend `Get-PoshQCShardTestFileWeight` in `scripts/powershell/PoshQC/PoshQC.Shard.psm1` with optional `-RootPath` and `-ReadWeightsText` (default: returns `Get-Content -Raw` of `<RootPath>/config/poshqc-shard-weights.json` when `Test-Path` finds it, otherwise `$null`) and a non-exported parser `ConvertFrom-PoshQCShardWeightJson` that validates `version` 1, `unit` `ms`, and a non-empty `files` map of non-negative integers keyed by repository-relative forward-slash paths, throwing a message that names `poshqc-shard-weights.json` otherwise; when weights are present, a listed file weighs its milliseconds and an unlisted file weighs the median of all listed values; without `-RootPath` or without the file the existing size path runs. `Select-PoshQCShardTestFile` passes `-RootPath` and an optional `-ReadWeightsText` through. `Get-PoshQCShardSlice` is unchanged.
  - Acceptance: `PoshQC.ShardWeights.Tests.ps1` passes; `PoshQC.Shard.Tests.ps1` (`SH14-WEIGHT-IGNORES-LINE-ENDINGS` calls without `-RootPath`; `SH15-SELECT-WEIGHS-CHECKED-IN-FILES-BY-NORMALIZED-TEXT` uses the root `/shard-root`, which holds no weights file) and `PoshQC.TestingShard.Tests.ps1` (`TS01` through `TS06` use `/shard-root`) pass unchanged for the same reason; the file stays at or below 800 lines.

### Phase 5 — PoshQC.Parallel.psm1 Runner, JUnit Merge, and Weight Export

- [ ] [P5-T1] Create `tests/scripts/powershell/PoshQC/PoshQC.ParallelMerge.Tests.ps1` with in-memory XML strings and cases `PM01-WORKER-DEFAULT-HALF-LOGICAL`, `PM02-WORKER-CAP-EIGHT`, `PM03-WORKER-FLOOR-ONE`, `PM04-JUNIT-SUMS-AND-RENUMBERS`, `PM05-JUNIT-ROOT-TIME-IS-LONGEST-SHARD`, `PM06-JUNIT-FAILING-SHARD-COUNTS-FAILURES`, `PM07-JUNIT-EMPTY-SHARD-CONTRIBUTES-ZERO`, `PM08-JUNIT-MALFORMED-THROWS`, `PM09-WEIGHTS-NORMALIZE-ABSOLUTE-PATHS`, `PM10-WEIGHTS-SORTED-INTEGER-MILLISECONDS`, and `PM11-EXPORT-WRITES-THROUGH-SEAM`.
  - Acceptance: the file exists and every case fails before P5-T3 because the functions do not exist.
- [ ] [P5-T2] Create `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1` with injected seams for process start, wait, directory reset, file read, file write, and clock, and cases `PR01-STARTS-ONE-PROCESS-PER-SHARD` (argument list carries `-ShardIndex`, `-ShardCount`, `-ShardFileListPath`, `-TestResultPath`, `-CoverageOutputPath`, `-DisableKoverageCopy` and a per-shard directory and log), `PR02-ALL-PASS-MERGES-AND-EXITS-ZERO`, `PR03-FAILED-SHARD-EXITS-NONZERO`, `PR04-MISSING-SHARD-OUTPUT-WRITES-NO-MERGED-ARTIFACT`, `PR05-INCOMPLETE-MANIFESTS-EXIT-NONZERO`, `PR06-MERGE-FAILURE-EXITS-NONZERO`, `PR07-WORKERCOUNT-OVERRIDE`, `PR08-SUMMARY-LOGS-WORKERS-AND-WALLCLOCK`, and `PR09-DEFAULT-SEAMS` (inside `InModuleScope PoshQC`, mocks `Start-Process`, `Wait-Process`, `Remove-Item`, `New-Item`, `Get-Content`, and `Set-Content` by name so each default seam body runs with no process started and no file touched).
  - Acceptance: the file exists and every case fails before P5-T4.
- [ ] [P5-T3] Create `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` with the pure functions `Get-PoshQCParallelWorkerCount` (`-LogicalProcessorCount`; returns the floor of half, at least 1, at most 8), `Merge-PoshQCJunitReport` (`-JunitText [string[]]`; concatenates `testsuite` elements, renumbers `id` from 0, sums `tests`, `errors`, `failures`, and `disabled` on the root, sets the root `time` to the largest shard root `time`, throws on malformed XML), `ConvertTo-PoshQCShardWeight` (`-JunitText [string[]]`; maps each `testsuite@name` to a repository-relative forward-slash path anchored at its first `tests` or `scripts` segment, sums seconds per file, and returns the version-1 `ms` document with sorted keys and rounded integer values), and `Export-PoshQCShardWeight` (`-JunitPath`, `-OutputPath`, `ReadText` and `WriteText` seams), each with comment-based help.
  - Acceptance: `PoshQC.ParallelMerge.Tests.ps1` passes all eleven cases.
- [ ] [P5-T4] Add `Invoke-PoshQCParallelTest` to `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` (`-Root`, optional `-WorkerCount` validated at 1 or more, default from `Get-PoshQCParallelWorkerCount` with `[Environment]::ProcessorCount`, seams `ResetShardDirectory`, `StartShardProcess`, `WaitShardProcess`, `ReadText`, `WriteText`, `Clock`, `Logger`): it resets `artifacts/pester/parallel/shard-<i>/` per shard, starts one `pwsh -NoLogo -NoProfile` child per shard that imports the PoshQC module and runs `Invoke-PoshQCTest` with the per-shard paths, waits for all, and only when every child exited 0 and every shard wrote its JUnit, coverage, and manifest files does it check `Test-PoshQCShardCompleteness`, merge with `Merge-PoshQCJunitReport` and `Merge-PoshQCCoverageReport`, write `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`, and write the Koverage copy with `Convert-PoshQCCoverageToRelative`; it returns an object with `ExitCode` (0 only on full success), `WorkerCount`, `WallClockSeconds`, and per-shard exit codes and logs, and never calls `exit`.
  - Acceptance: `PoshQC.ParallelRunner.Tests.ps1` passes all nine cases; `PoshQC.Parallel.psm1` stays at or below 800 lines.
- [ ] [P5-T5] Register `PoshQC.Parallel.psm1` in the sub-module list of `scripts/powershell/PoshQC/PoshQC.psm1` (after `PoshQC.CoverageMerge.psm1`, before `PoshQC.Testing.psm1`) and add `Get-PoshQCParallelWorkerCount`, `Merge-PoshQCJunitReport`, `ConvertTo-PoshQCShardWeight`, `Export-PoshQCShardWeight`, and `Invoke-PoshQCParallelTest` to `FunctionsToExport` in `scripts/powershell/PoshQC/PoshQC.psd1`.
  - Acceptance: `PoshQC.ModuleCoverage.Tests.ps1` (`MC05-SUBMODULE-CACHE-MISS-IMPORT`, which requires every `*.psm1` in the folder to be cached) passes unchanged once the module is registered; `Get-Command -Module PoshQC` after import lists the five new functions.

### Phase 6 — Bundled Mirrors, Parity Test, VS Code Task, and README

- [ ] [P6-T1] Copy `PoshQC.Parallel.psm1`, `PoshQC.Shard.psm1`, `PoshQC.Testing.psm1`, `PoshQC.psm1`, and `PoshQC.psd1` from `scripts/powershell/PoshQC/` byte-for-byte to `extensions/drm-copilot/resources/powershell/PoshQC/`.
  - Acceptance: each pair has an equal SHA-256 hash, recorded in `FEATURE/evidence/other/poshqc-mirror-hashes.<timestamp>.md`.
- [ ] [P6-T2] Add `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` and `scripts/powershell/PoshQC/README.md` to `POSHQC_PARITY_PATHS` in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` passes `test_poshqc_bundled_module_files_match_repo_root_sources` after P6-T4.
- [ ] [P6-T3] Add the task `PoshQC: 4 test (Pester, parallel)` to `.vscode/tasks.json`, running `pwsh` with `& { Import-Module '${workspaceFolder}/scripts/powershell/PoshQC'; exit (Invoke-PoshQCParallelTest -Root '${workspaceFolder}').ExitCode }`, in the file's existing style; `PoshQC: 4 test (Pester)` stays unchanged.
  - Acceptance: `poetry run python -m scripts.dev_tools.validate_json` exits 0; both labels are present.
- [ ] [P6-T4] Update `scripts/powershell/PoshQC/README.md` (runner and worker default, the output-path parameters, the merged JUnit root `time` as the longest shard wall-clock, the weights file format with median fallback and size fallback, and the `Export-PoshQCShardWeight` regeneration command from CI JUnit artifacts), replace the sentence that weights test files by UTF-8 size in bytes with the weights-first rule, and copy the file byte-for-byte to `extensions/drm-copilot/resources/powershell/PoshQC/README.md`.
  - Acceptance: the README contains `Invoke-PoshQCParallelTest`, `-TestResultPath`, `-CoverageOutputPath`, `poshqc-shard-weights.json`, and `Export-PoshQCShardWeight`; the parity test passes.

### Phase 7 — Weights File, Concurrent-Run Comparison, Pester Isolation, and Diagnosis

- [ ] [P7-T1] Download the `poshqc-test-results-shard-1`, `poshqc-test-results-shard-2`, and `poshqc-test-results-shard-3` artifacts of the P0-T5 run into `SCRATCH/issue-1048-ci-junit/` with `gh run download`, run `Export-PoshQCShardWeight` over the `pester-junit.xml` file in each shard directory, write `config/poshqc-shard-weights.json`, and record `FEATURE/evidence/other/shard-weights-generation.<timestamp>.md`.
  - Acceptance: the four schema fields; the summary records the run id, the number of files listed, and that `PoshQC.ShardWeights.Tests.ps1` passes; the weights file parses through `ConvertFrom-PoshQCShardWeightJson` without error and lists no absolute path (no entry begins with `/` or contains `:`).
- [ ] [P7-T2] Record the shard assignment the committed weights produce: run `Select-PoshQCShardTestFile` for shards 1 to 3 over the test files the default enumeration returns for the scan folders of `config/poshqc-scan.json`, and sum each shard's weights, in `FEATURE/evidence/other/shard-balance-projection.<timestamp>.md`.
  - Acceptance: three rows with file count and projected milliseconds, and the projected spread compared with the P0-T5 measured spread.
- [ ] [P7-T3] Run a fresh serial `Invoke-PoshQCTest` and then `Invoke-PoshQCParallelTest` on the same tree, and record `FEATURE/evidence/regression-testing/pester-concurrent-vs-serial.<timestamp>.md`.
  - Acceptance: rows for both runs with `testsuites@tests`, `failures`, `errors`, wall-clock seconds, worker count, and exit code; the totals and the pass/fail outcome are equal; the merged `artifacts/pester/powershell-coverage.xml` exists after the concurrent run.
- [ ] [P7-T4] Run the touched Pester suites (`tests/scripts/powershell/PoshQC/*.Tests.ps1` and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`) in one process with a seeded shuffled file order for seeds `1048`, `20261031`, and `7`, and record `FEATURE/evidence/regression-testing/pester-shuffled.<timestamp>.md`.
  - Acceptance: one row per seed with the seed, the file order, the failure count read from the JUnit file, and zero failures.
- [ ] [P7-T5] Fix every Pester leaker and victim exposed by P7-T3 or P7-T4 in test code (never by ordering), re-run every seed and the concurrent run, and record `FEATURE/evidence/regression-testing/pester-isolation-fixes.<timestamp>.md`.
  - Acceptance: each fix is listed with leaker and victim file, or the artifact states `NONE FOUND`; every re-run has zero failures.
- [ ] [P7-T6] Profile every Pester test file whose JUnit `time` is 10 seconds or more in the P0-T3 local JUnit or the P7-T1 CI JUnit: list its duration in each source, its five slowest test cases, and its cost driver (process spawns, repository scans, module re-imports) from reading the file; write `FEATURE/evidence/other/pester-slow-file-profile.<timestamp>.md` and add one entry per non-trivial fix to the follow-ups record of P2-T11.
  - Acceptance: one row per file at or above 10 seconds; each non-trivial fix has a follow-up entry.
- [ ] [P7-T7] Explain the difference between the 482 files stated in the issue and the 436 suites in the local JUnit: count `*.Tests.ps1` files under the scan folders of `config/poshqc-scan.json` with the default enumeration (excluded directories applied), count `testsuite` elements in the P7-T3 JUnit, and record `FEATURE/evidence/other/pester-file-count.<timestamp>.md`.
  - Acceptance: both counts and a one-paragraph explanation of the difference are recorded.

### Phase 8 — Execution-Environment Brief Update

- [ ] [P8-T1] Extend the token tuple of `test_brief_test_runtime_section_orders_diagnosis_before_parallelism` in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` with `Parallel workers`, `-n auto`, `addopts`, `physical cores`, `Pester 5`, `Invoke-PoshQCParallelTest`, and `testsuite`, and the tuple of `test_brief_test_isolation_requires_seeded_pester_shuffle` with `concurrent-shard` and `pytest -n auto`.
  - Acceptance: both tests fail before P8-T2 and every existing token remains in the tuples.
- [ ] [P8-T2] Edit `## Test Runtime` in `.claude/skills/execution-environment/SKILL.md`: rename `Parallel shards` to `Parallel workers` in the wall-clock bullet (keeping `wall-clock time only`), add the pytest bullet (pass `-n auto` on the command line of the CI step and the parallel tasks, never in `addopts`; `-n auto` counts physical cores; measure against an explicit count; pytest-cov combines worker coverage; the serial command remains the isolation reference) and the Pester bullet (Pester 5 has no in-process parallel mode; process-per-shard through `Invoke-PoshQCTest -ShardIndex -ShardCount` on CI or `Invoke-PoshQCParallelTest` locally; read per-file `time` from the JUnit `testsuite` elements before changing shard counts or weights in `config/poshqc-shard-weights.json`), and add to `## Test Isolation Checks` a bullet requiring a concurrent-shard Pester run and a `pytest -n auto` run in addition to the serial runs.
  - Acceptance: both P8-T1 tests pass; `test_brief_has_no_g11_or_g12_findings` and `test_brief_has_required_headings` pass.
- [ ] [P8-T3] Copy the edited brief byte-for-byte to `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and the three bundled copies under `extensions/drm-copilot/resources/` (`claude-customizations/.claude/skills/...`, `codex-and-agents-customizations/.agents/skills/...`, `customizations/.github/skills/...`).
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q` passes, including `test_brief_copies_are_byte_identical`.

### Phase 9 — CI-Dependent Measurements (owned by orchestrator step 9)

These tasks need branch CI runs. The executor does not execute them and continues to Phase 10; the orchestrator performs and checks them in step 9 after the branch is pushed, and the Phase 10 self-review records their rows as pending step 9.

- [ ] [P9-T1] On a full CI run of the branch head with `-n auto`, record `FEATURE/evidence/qa-gates/ci-timing-n-auto.<timestamp>.md` with the run id, the duration of `quality-checks7 / Code Quality & Tests (3.13)`, the xdist worker count read from that job's log, the coverage-threshold step result, and the durations of the three Pester shards.
  - Acceptance: every value is present and the run's `CI full run` job succeeded.
- [ ] [P9-T2] Commit a change of the pytest step token from `-n auto` to `-n 4` in `.github/workflows/_quality-checks.yml`, push, and record `FEATURE/evidence/qa-gates/ci-timing-n-4.<timestamp>.md` with the same fields as P9-T1.
  - Acceptance: every value is present and `test_pytest_step_runs_xdist_workers` passes on the commit.
- [ ] [P9-T3] Write `FEATURE/evidence/qa-gates/xdist-worker-decision.<timestamp>.md` comparing P0-T5, P9-T1, and P9-T2 durations and keeping the faster setting; when `-n auto` is faster, commit the step back to `-n auto`.
  - Acceptance: the record names the kept setting and the before and after duration of `quality-checks7 / Code Quality & Tests (3.13)`, and the workflow carries the kept token.
- [ ] [P9-T4] Write `FEATURE/evidence/qa-gates/pester-shard-balance.<timestamp>.md` comparing the shard spread of P0-T5 with the newest branch-head run; when the spread is not smaller, record the decision on a further shard, and when the decision adds one, run a remediation cycle that updates the `_poshqc.yml` matrix, `## CI Shape and Required Checks` in all six brief copies, and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` together.
  - Acceptance: both spreads and the comparison are recorded, with a decision line when the spread is not smaller.
- [ ] [P9-T5] Record a green full CI run on the final branch head in `FEATURE/evidence/qa-gates/branch-head-green-run.<timestamp>.md`, including `poshqc / PowerShell QC` (merged coverage and completeness) and every required context, and record, from a read-only `gh api repos/drmoisan/drm-copilot/rulesets/15241672` call, that `poshqc / PowerShell hook suites (Linux)` is unchanged and is not a required context.
  - Acceptance: the run id, the head ref, each required context with `success`, the `CI full run` job result, and the Linux-job observation are recorded.

### Phase 10 — Final QA Loop and Self-Review

- [ ] [P10-T1] Run `poetry run black --check .` and record `FEATURE/evidence/qa-gates/black.<timestamp>.md`.
  - Acceptance: exit 0 and the summary records the printed line containing `would be left unchanged`; on a failure, run Black in write mode, restart from P10-T1.
- [ ] [P10-T2] Run `poetry run ruff check .` and record `FEATURE/evidence/qa-gates/ruff.<timestamp>.md`.
  - Acceptance: exit 0 and the summary records `All checks passed!`.
- [ ] [P10-T3] Run `poetry run pyright` and record `FEATURE/evidence/qa-gates/pyright.<timestamp>.md`.
  - Acceptance: exit 0 and the summary records `0 errors`.
- [ ] [P10-T4] Run `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1048-final.json --cov` and the threshold checker over that report, and record `FEATURE/evidence/qa-gates/pytest-coverage.<timestamp>.md`.
  - Acceptance: zero failures; checker exit 0; the summary records the totals line and branch percentages from the JSON report and their delta against P0-T2 (no regression).
- [ ] [P10-T5] Run the PoshQC format check through `mcp__drm-copilot__run_poshqc_format` and confirm with `git status --porcelain` that no PowerShell file changed; record `FEATURE/evidence/qa-gates/poshqc-format.<timestamp>.md`.
  - Acceptance: the porcelain output before and after the format call is identical; a changed file restarts the loop from P10-T1.
- [ ] [P10-T6] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts/powershell/PoshQC` and the new test files, and record `FEATURE/evidence/qa-gates/pssa.<timestamp>.md`.
  - Acceptance: zero findings, or no finding beyond the P0-T4 baseline in an unchanged file.
- [ ] [P10-T7] Run the full Pester suite with coverage through `Invoke-PoshQCTest`, and record `FEATURE/evidence/qa-gates/pester-coverage.<timestamp>.md`.
  - Acceptance: zero failures read from `artifacts/pester/pester-junit.xml`; per-file line coverage read from `artifacts/pester/powershell-coverage.xml` is at least 85% for `PoshQC.Parallel.psm1`, `PoshQC.Shard.psm1`, and `PoshQC.Testing.psm1`, and not below the P0-T3 value for the latter two.
- [ ] [P10-T8] Run the fresh single-process Pester run over `tests/scripts` (the CI shape) and record `FEATURE/evidence/regression-testing/pester-single-process.<timestamp>.md`.
  - Acceptance: zero failures read from the JUnit file.
- [ ] [P10-T9] Verify the scope constraints against the merge base of `origin/main` and `HEAD`: `git diff --name-status <merge-base> HEAD` together with `git status --porcelain` shows no added `.py` file outside `tests/`, no changed file under `.claude/hooks/` or `.codex/hooks/`, no change to `.github/workflows/_poshqc.yml` unless the P9-T4 decision record adds a shard, and every changed file at or below 800 lines; record `FEATURE/evidence/qa-gates/scope-check.<timestamp>.md`.
  - Acceptance: each of the four checks is recorded as PASS with the listed files.
- [ ] [P10-T10] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item, marking Phase 9 rows as pending step 9.
  - Acceptance: no FAIL row; a FAIL is fixed and the loop re-run from P10-T1 before the self-review is rewritten.

## Pre-Mortem

- Review checklists: `modified-workflow-needs-green-run` is met by P9-T5; the workflow edit adds tokens to a `poetry run` command only, so no `pwsh` step and no leaked `$LASTEXITCODE` is introduced (`.claude/rules/ci-workflows.md`); the brief update is P8-T2 and P8-T3; P10-T10 walks all three templates.
- Coverage: `PoshQC.Parallel.psm1` is in the coverage denominator through the `scripts` root of `config/poshqc-coverage.json`; every process, file, and clock interaction is a seam, and `PR09-DEFAULT-SEAMS` runs each default seam body under named-cmdlet mocks rather than replacing the seams, so the per-file floor of P10-T7 measures executed lines. Python changes are test-only; P10-T4 checks totals against P0-T2, and P2-T9 checks `-n auto` totals against serial totals.
- Mirror parity: P6-T1 and P6-T4 mirror every changed PoshQC file and the README, P6-T2 adds the new paths to `POSHQC_PARITY_PATHS`; the brief fact changes (`## Test Runtime`, `## Test Isolation Checks`) are made in all six copies by P8-T2 and P8-T3; a further shard would change `## CI Shape and Required Checks`, which P9-T4 routes through a remediation cycle that edits all six copies.
- File size: `PoshQC.Testing.psm1` starts near the 500-line guidance, so P3-T2 adds only two parameters and their help; all new logic goes into `PoshQC.Parallel.psm1` and four new test files; P10-T9 enforces the 800-line limit on every changed file; Markdown is exempt.
- Test isolation: Python reversed-order run (P2-T5), seeded shuffled runs with seeds `1048`, `20261031`, `7` (P2-T6), repeated `-n auto` runs (P2-T7); seeded shuffled file-order Pester runs of the touched suites with the same three seeds and each file order recorded (P7-T4), a concurrent-shard run (P7-T3), and a fresh single-process run over `tests/scripts` (P10-T8). No Jest file is touched, so no Jest run is needed. New tests create no temporary files.
- CI-only behavior: `-n auto` may start fewer workers than vCPUs, which P9-T1 and P9-T2 measure on the runner; the Python 3.10 leg has no `tomllib`, so P1-T3 parses `addopts` as text; the weights file stores repository-relative forward-slash paths so Windows shard runners compute one assignment; a docs-only run proves nothing, so P9 evidence uses runs whose `CI full run` job succeeded.
- Evidence: every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` under `FEATURE/evidence/<kind>/`; PowerShell pass counts and coverage come from the JUnit and coverage files, not from PoshQC MCP results; weights come only from CI JUnit artifacts (P7-T1); scratch locations are recorded as `SCRATCH`.

## Size Justification

The issue joins two independent parts (pytest parallelism and a Pester runner with measured shard weights) plus a six-copy brief update and five CI-dependent measurements that the owner decisions require in this item. Each task is a single binary outcome, and splitting the item would duplicate Phase 0 baselines and the final QA loop for both languages.

## Test Plan

- Unit: `test_pytest_step_runs_xdist_workers`, `test_pyproject_addopts_carries_no_xdist_flag`, `test_clipboard_tests_leave_module_bindings_intact`, the extended brief token tests, the parity test; Pester `OP01`-`OP04`, `SW01`-`SW07`, `PM01`-`PM11`, `PR01`-`PR09`.
- Integration: local concurrent versus serial Pester run (P7-T3); CI runs in Phase 9.
- Coverage evidence: baseline `FEATURE/evidence/baseline/pytest-serial.*.md` and `pester-serial.*.md`; post-change `FEATURE/evidence/qa-gates/pytest-coverage.*.md` and `pester-coverage.*.md`; equality `FEATURE/evidence/regression-testing/pytest-coverage-equality.*.md`.

## Open Questions / Notes

- None open. Owner decisions are recorded in `owner-decisions.md`.
