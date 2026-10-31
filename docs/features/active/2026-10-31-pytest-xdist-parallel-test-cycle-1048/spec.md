# pytest-xdist-parallel-test-cycle — Spec

- **Issue:** #1048
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31T13-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Overview

The repository's two large test suites run slowly, locally and in CI.

**Python (pytest).** The suite runs serially in CI on four Python versions. The `quality-checks7 / Code Quality & Tests (3.13)` job took about 18 minutes on a recent run. Locally there is one `QC: 4 Pytest: run tests` task and no parallel option. A downstream repository measured `pytest-xdist`: on a 2 vCPU runner `-n auto` gave no gain (269 s against 275 s serial), on a 16-core runner it took 43.8 s, and locally 2 workers were 1.75 times faster than 1. The public `ubuntu-latest` runner has 4 vCPUs. Research found that `-n auto` counts physical cores, so a 4 vCPU runner may start fewer workers than vCPUs; the measured result decides what stays.

**Pester (PowerShell).** CI already shards Pester across Windows runners with `Invoke-PoshQCTest -ShardIndex -ShardCount`, but a recent run's shards took 462 s, 290 s and 364 s. Shard weights are UTF-8 byte sizes, which do not predict duration for subprocess-bound suites. Locally there is no way to run shards concurrently on one machine. Pester 5 (the supported range, below 6.0) has no in-process parallel mode, and merged coverage must come from all shards.

This feature adds pytest-xdist parallelism, a local concurrent Pester runner, duration-based shard balancing, and the matching documentation. It introduces no new Python scripts. Enforcement hooks do not invoke Python.

Owner decisions that bind this spec are recorded in `owner-decisions.md` in this folder.

## Behavior

### Part 1: pytest parallelism

1. Add `pytest-xdist = "^3"` to the dev dependencies and regenerate `poetry.lock` with Poetry. `psutil` is not added.
2. Add `-n auto` to the CI step `Run tests with Pytest` in `.github/workflows/_quality-checks.yml`. Keep the step name, `--cov`, `--cov-branch`, the XML and JSON reports, and the threshold step. `-n` never appears in `addopts`, because the VS Code Test Explorer result hook then keys results to the wrong file.
3. Measure `-n auto` against a fixed `-n 4` on the CI runner, record both timings, and keep the faster option in the workflow step.
4. Add parallel tasks to `.vscode/tasks.json` (unit tests with `-n auto`; unit tests with `-n auto` and the lcov report). The `QC: 4 Pytest: run tests` serial task remains. The edited file must pass governed-JSON validation.
5. Fix the `importlib.reload` leak in `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` by restoring module state in the test (leaker and victim), not through ordering. Verify the `isolated_import_state` helper in `test_validate_orchestration_artifacts_invocation.py`. Fix any further leaker or victim that the isolation runs expose.
6. Verify order independence: serial run, repeated `-n auto` runs, a seeded shuffled run with each seed recorded, and a reversed-order run. A shuffle plugin is loaded from scratch with `-p` and `PYTHONPATH`; no shuffle dependency is added to the repository.
7. Confirm merged coverage: `coverage.json` totals under `-n auto` equal the serial totals within rounding, and the threshold check passes on the merged file.
8. Record a separate adopt or defer decision, with the reason, for each strictness option: `--import-mode=importlib`, `--strict-markers`, `--strict-config`, `xfail_strict`, `filterwarnings = ["error"]`. Adopt only options that pass with zero or trivial test edits; record the others as follow-ups. Research expects `--import-mode=importlib` and `filterwarnings = ["error"]` to be deferred; the probes decide.
9. Record the before and after duration of `quality-checks7 / Code Quality & Tests (3.13)`.

### Part 2: Pester parallelism

1. **Output-path parameters.** Add `-TestResultPath` and `-CoverageOutputPath` parameters to `Invoke-PoshQCTest` in `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, applied after settings load, so concurrent shards write distinct files. These are the only edits to that existing function; all new logic goes in the new module.
2. **Runner module.** Add `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` with `Invoke-PoshQCParallelTest`. It starts one `pwsh` child process per shard, each running `Invoke-PoshQCTest -ShardIndex i -ShardCount N` with per-shard output directories and a per-shard log, waits for all children, then merges results. Worker count N defaults to half of the logical core count, capped at 8, and is overridable by parameter. Process, file and clock interactions sit behind injectable seams.
3. **Merge.** Add a pure `Merge-PoshQCJunitReport`: concatenate `testsuite` elements, renumber `id`, sum `tests`, `errors`, `failures`, `disabled` on the root, and set the root `time` to the longest shard wall-clock. Reuse `Merge-PoshQCCoverageReport` for coverage and `Test-PoshQCShardCompleteness` for manifests. The merged outputs are one `artifacts/pester/pester-junit.xml` and the existing `artifacts/pester/powershell-coverage.xml` (plus the Koverage copy). The root `time` semantics are documented in the PoshQC README.
4. **Exit semantics.** The runner exits non-zero when any child exits non-zero or any merge or completeness step fails, and zero otherwise, matching a serial run. Merged artifacts are written only when every shard produced outputs; a partial result never replaces a full one.
5. **VS Code task.** Add a task in `.vscode/tasks.json` that imports the PoshQC module and runs `Invoke-PoshQCParallelTest`. The existing `PoshQC: 4 test (Pester)` task remains.
6. **Wiring and mirrors.** Register the new module in `PoshQC.psm1` (sub-module list) and `PoshQC.psd1` (`FunctionsToExport`). Add bundled copies of every changed or new PoshQC file under `extensions/drm-copilot/resources/powershell/PoshQC/` and add the new path to `POSHQC_PARITY_PATHS` in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
7. **Measured shard weights.** Add a committed `config/poshqc-shard-weights.json` (`version`, `unit` in milliseconds, `files` keyed by repo-relative forward-slash path), derived from CI JUnit artifacts, not local ones. `Get-PoshQCShardTestFileWeight` reads it through a seam; files without an entry use the median of known weights. Assignment stays longest-processing-time greedy with `Get-PoshQCShardSlice`, which already accepts `[long[]] -Weight`. The size-based weight remains the path when the weights file is absent. Regeneration uses a PowerShell command documented in the PoshQC README. No CI gate requires fresh weights.
8. **Shard count.** Start with the existing shard count and change weights only. Add a further shard only if the measured balance requires it; in that case the matrix in `_poshqc.yml`, `## CI Shape and Required Checks` in the brief, and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` change together.
9. **Slow-file profile (diagnosis).** Profile the Pester test files whose JUnit `time` is 10 s or more, and record the findings with per-file durations. Fixes beyond trivial ones are recorded as follow-ups.
10. **Concurrent-shard isolation.** Run the Pester suites as concurrent shards and under seeded shuffled file-order runs with at least three seeds, each seed and file order recorded. Fix every leaker and victim found (research suspects include env-nulling in the batch-budget hook suites and global `Invoke-Pester` stubs); never work around by ordering.
11. **Kept as is.** The Linux hook-suite job (`poshqc / PowerShell hook suites (Linux)`) is unchanged; its non-required status is recorded as an observation. Pester 6 `Run.Parallel`, in-process `ForEach-Object -Parallel`, and per-shard generated settings files are rejected.
12. **Test file count.** The difference between the issue's stated count of Pester test files and the local JUnit suite count is explained from the Pester discovery count in the plan; it does not block delivery.

### Documentation

1. Update `## Test Runtime` in the execution-environment brief in every copy: replace `Parallel shards` with `Parallel workers` in the wall-clock bullet (keeping `wall-clock time only`), add the pytest bullet (`-n auto` on the command line, never in `addopts`, physical-core caveat, measure against an explicit count, serial command remains the isolation reference) and the Pester bullet (Pester 5 has no in-process parallel mode; process-per-shard on CI runners or the local runner; read per-file JUnit `time` before changing shard counts or weights).
2. Add to `## Test Isolation Checks` a bullet requiring a concurrent-shard Pester run and a `-n auto` pytest run in addition to the serial runs, preserving all existing pinned tokens.
3. Keep every token pinned by `test_execution_environment_brief_contracts.py`. All copies, including bundled copies, change byte-for-byte; the mirror contract tests pass.
4. Update `scripts/powershell/PoshQC/README.md` (runner, output-path parameters, JUnit root `time`, weights file and regeneration).

### Out of scope

- Classifying pytest tests into `architecture`, `contract` and `integration` markers and sharding integration tests in CI (follow-up).
- A VS Code Test Explorer workspace settings file.
- Pester 6 adoption, narrowing or merging the Linux hook-suite job, and a `psutil` dependency.
- The `QC: 5 Run All Checks` label mismatch and the `src/lexile_corpus_tuner` path in the coverage task (recorded as follow-ups unless trivial).

## Inputs / Outputs

- Inputs:
  - pytest: `-n auto` or `-n 4` on the command line (CI step, VS Code tasks).
  - Pester runner: `-Root`, a worker-count parameter (default half the logical cores, cap 8), existing `Invoke-PoshQCTest` options, `config/poshqc-shard-weights.json`.
  - `Invoke-PoshQCTest`: new `-TestResultPath`, `-CoverageOutputPath`.
- Outputs:
  - pytest: unchanged `coverage.xml`, `artifacts/python/coverage.json`, lcov report.
  - Pester runner: per-shard directories and logs; merged `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`; process exit code.
  - Recorded evidence under `evidence/` in this folder: timings, isolation runs, strictness decisions, profile findings.
- Config keys and defaults: `addopts` unchanged. Worker default for the Pester runner is half the logical core count, capped at 8.
- Versioning or backward-compatibility constraints: the new `Invoke-PoshQCTest` parameters are optional; existing callers (CI shards, the serial task) are unaffected. Pester stays in the `>= 5.9.0, < 6.0.0` range.

## API / CLI Surface

- `poetry run pytest -n auto ...` (CI and parallel tasks); `poetry run pytest` (serial, unchanged).
- `Invoke-PoshQCParallelTest -Root <path> [-WorkerCount <int>]` (parameter names to be finalized in the plan); VS Code task wraps it with `Import-Module scripts/powershell/PoshQC`.
- `Invoke-PoshQCTest ... -TestResultPath <path> -CoverageOutputPath <path>`.
- `Merge-PoshQCJunitReport` takes shard JUnit documents and returns one document.
- Contracts: exit code 0 only when every shard, completeness check and merge succeeds; merged files are not written on partial shard output.

## Data & State

- Data transformations and invariants: merged JUnit totals equal the sum of shard totals; the union of shard manifests equals the discovered file set with disjoint shards; coverage lines are merged by maximum hit count over an identical line set.
- Caching or persistence details: `config/poshqc-shard-weights.json` is committed so every CI shard computes the same assignment. Stale or missing entries affect wall-clock time only, because completeness and test-count checks still guard coverage of every file. JUnit `name`/`package` hold absolute paths and are normalized to repo-relative forward-slash paths when weights are generated.
- Migration or backfill requirements: initial weights are generated once from CI JUnit artifacts of the newest full green run.

## Constraints & Risks

- Any test that depends on order, on shared global state or on a shared temp file fails under xdist or concurrent shards. Fix the leaker and the victim; never work around by ordering or sharding.
- A 2 vCPU runner gave no pytest gain downstream. The measured CI result decides whether the pytest change stays.
- Pester coverage must be merged from all shards; a partial run must never overwrite the merged artifact.
- A workflow change needs a green workflow run on the branch head before merge (rule `modified-workflow-needs-green-run`); a docs-only run proves nothing.
- No new Python scripts; enforcement hooks do not invoke Python.
- New PowerShell must stay within coverage and file-size policy: `PoshQC.Testing.psm1` is near the 500-line guidance, so only parameters are added there. The new module is in the coverage denominator, so process and file interactions use seams.
- The local per-file durations come from a gitignored local artifact and may not match CI; weights come from CI artifacts only.
- Weekly model quota is tight; choose the smallest plan that meets the scope. The number of changed PowerShell files exceeds the direct-mode batch cap, so the orchestrated large route applies.

## Implementation Strategy

- Implementation scope: pytest dependency, CI step, tasks; one test-isolation fix plus whatever the isolation runs expose; Pester output-path parameters, new runner/merge module, weights lookup, weights file, tasks, mirrors, brief, README.
- New functions/commands: `Invoke-PoshQCParallelTest`, `Merge-PoshQCJunitReport`, a weights-regeneration command (PowerShell), a weights lookup in `Get-PoshQCShardTestFileWeight`.
- Dependency changes: add `pytest-xdist` (dev). No `psutil`. No new Python scripts.
- Logging/telemetry additions: per-shard log files under the runner's output directory; a summary line with worker count and wall-clock.
- Rollout plan: land the pytest change with before/after CI timing; keep `-n auto` only if the measured result beats serial, otherwise use the fixed count or revert the step to serial and record the result. The serial pytest task and serial Pester task remain as fallbacks.
- Tests: extend `test_quality_checks_workflow_contracts.py` (assert `-n` in the pytest step and absent from `addopts`); new Pester tests for the runner, JUnit merge and weights lookup using in-memory seams and no temp files; update `PoshQC.TestingShard.Tests.ps1` and `PoshQC.Shard.Tests.ps1` for the weight unit; extend brief contract tokens; update the parity test.

## Acceptance Criteria

### Part 1: pytest

- [ ] `pytest-xdist = "^3"` is in the dev dependencies and `poetry.lock` contains it, regenerated by Poetry (the lock-sync CI step passes); no `psutil` dependency is added.
- [ ] The CI step `Run tests with Pytest` runs with `-n auto` or the fixed `-n 4` (whichever measured faster), keeps its name and all existing coverage options, and the coverage threshold step passes on the merged `artifacts/python/coverage.json`.
- [x] `-n` does not appear in `addopts` in `pyproject.toml`, and the serial `QC: 4 Pytest: run tests` task remains.
- [x] `.vscode/tasks.json` contains a parallel unit-test task with `-n auto` and a parallel task with coverage and the lcov report, and parses as JSONC (full-line comments removed) with every required label present; the file is outside the governed-JSON globs, so `validate_json` does not apply (evidence: `evidence/other/spec-ac-jsonc-amendment.2026-10-31T21-19.md`).
- [x] `test_resolve_hard_lock_prompt.py` restores module state after each `importlib.reload` use, with a regression test showing a later test in the same process sees the real module, not the patched one.
- [x] The Python suite passes serially, in repeated `-n auto` runs, in a seeded shuffled run (each seed recorded), and in a reversed-order run, with no order dependence; every leaker and victim found is fixed in test code.
- [x] The `git status --porcelain` check after an `-n auto` run shows no files written by tests.
- [x] `totals.percent_statements_covered` and `totals.percent_branches_covered` under `-n auto` match the serial run within rounding, and the result is recorded.
- [ ] Both the `-n auto` and `-n 4` CI timings are recorded, and the before and after duration of `quality-checks7 / Code Quality & Tests (3.13)` is recorded in evidence.
- [x] Each strictness option (`--import-mode=importlib`, `--strict-markers`, `--strict-config`, `xfail_strict`, `filterwarnings = ["error"]`) has a recorded adopt or defer decision with the reason, and each deferral has a follow-up record.
- [x] `test_quality_checks_workflow_contracts.py` asserts `-n` in the pytest step and absent from `addopts`, and passes.

### Part 2: Pester

- [x] `Invoke-PoshQCTest` accepts `-TestResultPath` and `-CoverageOutputPath`, and unit tests show that omitting them leaves the settings-file paths unchanged.
- [x] `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` exists, is registered in `PoshQC.psm1` and exported from `PoshQC.psd1`, and `Invoke-PoshQCParallelTest` starts one process per shard, waits for all, and merges results.
- [x] The worker count defaults to half the logical core count capped at 8 and is overridable by parameter, with unit tests for the default, the cap and the override.
- [x] `Merge-PoshQCJunitReport` produces one JUnit document with summed `tests`, `errors`, `failures`, `disabled`, root `time` equal to the longest shard wall-clock, and unit tests cover passing, failing and empty-shard inputs.
- [x] The merged coverage uses `Merge-PoshQCCoverageReport`, shard manifests pass `Test-PoshQCShardCompleteness`, and the merged `artifacts/pester/powershell-coverage.xml` is produced.
- [x] The runner exits non-zero when any shard fails or any merge or completeness step fails, exits zero otherwise, and never overwrites merged artifacts when a shard produced no output; unit tests cover each case.
- [x] A VS Code task runs `Invoke-PoshQCParallelTest`, the existing `PoshQC: 4 test (Pester)` task remains, and `tasks.json` parses as JSONC (full-line comments removed) with every required label present; the file is outside the governed-JSON globs, so `validate_json` does not apply (evidence: `evidence/other/spec-ac-jsonc-amendment.2026-10-31T21-19.md`).
- [x] A local concurrent run and a serial run on the same tree produce the same total test count and pass/fail outcome, with the comparison recorded in evidence.
- [x] `config/poshqc-shard-weights.json` is committed with millisecond weights derived from CI JUnit artifacts, `Get-PoshQCShardTestFileWeight` uses it with a median fallback for unlisted files, and the size-based path still works when the file is absent; tests cover all three cases and a malformed file.
- [ ] The CI Pester shard durations before and after the weights change are recorded, and the spread between the longest and shortest shard is smaller than the baseline spread; if it is not, a recorded decision states whether a further shard is added (with the matrix, brief and `PoshQcWorkflow.Tests.ps1` updated together).
- [x] The slow-file profile of Pester test files at or above 10 s is recorded, with per-file durations and follow-up records for non-trivial fixes.
- [x] Pester suites pass as concurrent shards and under seeded shuffled file-order runs with at least three seeds (each seed and file order recorded), and every leaker and victim found is fixed without ordering workarounds.
- [ ] The merged coverage and completeness checks in `_poshqc.yml` continue to pass, and a green workflow run on the branch head is recorded.
- [x] Every changed or new PoshQC file has a bundled copy under `extensions/drm-copilot/resources/powershell/PoshQC/`, the new path is in `POSHQC_PARITY_PATHS`, and `test_poshqc_bundled_parity.py` and the PoshQC and workflow Pester tests pass.
- [x] `scripts/powershell/PoshQC/README.md` documents the runner, the output-path parameters, the JUnit root `time` semantics, and weights regeneration.

### Documentation and constraints

- [x] `## Test Runtime` is updated in every copy of the execution-environment brief for both runners, retaining all pinned tokens, and `## Test Isolation Checks` gains the concurrent-run bullet; the mirror contract tests pass.
- [x] No new Python script is added, and the changed files include no Python enforcement-hook invocation.
- [ ] The Linux hook-suite job is unchanged and its non-required status is recorded as an observation.
- [x] The explanation of the Pester test file count difference is recorded from the discovery count.

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [x] Edge cases and error handling covered by tests
- [x] Docs updated (README, brief, docs/features/active/... links)
- [x] Telemetry/logging added or updated (per-shard logs)
- [x] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Unit coverage areas: the Python suite serially and under `-n auto`; the workflow contract test; the shard assignment with measured weights; the result and coverage merge for concurrent shards.
- [x] Integration scenarios: a full CI run with the changed steps comparing durations and coverage totals; a local concurrent Pester run compared with a serial run.
- [x] CLI/API examples
