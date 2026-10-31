# Code Review: pytest-xdist and concurrent Pester test cycle (#1048)

---

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048`
**Feature Folder Selection Rule:** Supplied by the caller; it is the only active feature folder changed on the branch and its suffix matches issue 1048 in the branch name.
**Base Branch:** `main` (merge base `58b81ca577943cd2944b62ee23ff3a3d1d737092`, equal to `origin/main`)
**Head Branch:** `feature/pytest-xdist-parallel-test-cycle-1048` at `d817f4075c4c9f5a69b185173e53987ae8d0dd91` (equal to the remote branch)
**Review Type:** Initial review of the full branch diff (78 files)

---

## Executive Summary

The branch parallelizes both test suites. For pytest it adds `pytest-xdist`, passes `-n auto` in the CI step and in two new VS Code tasks, and keeps `-n` out of `addopts`. For Pester it adds `PoshQC.Parallel.psm1`, which starts one `pwsh` child per shard through the existing `Invoke-PoshQCTest -ShardIndex -ShardCount` path with new per-shard output paths, waits for all children, and merges JUnit (new pure `Merge-PoshQCJunitReport`) and coverage (existing `Merge-PoshQCCoverageReport`) only when every shard succeeded and passed `Test-PoshQCShardCompleteness`. CI shard assignment now reads committed millisecond weights with a median fallback for unlisted files and the size path when the weights file is absent.

The code is small, seam-driven, and well covered. The design keeps all I/O behind injectable script blocks and leaves the pure functions free of file access. No Blocker or Major code defect was found.

**Top 3 risks:**
1. The CI effect is unmeasured: `-n auto` against `-n 4`, the shard spread after the weights change, and the green branch-head run are pending orchestrator step 9 (A1 to A3). `-n auto` counts physical cores and may start fewer workers than the 4 vCPUs on `ubuntu-latest`.
2. `--strict-markers`, `--strict-config`, and `xfail_strict` now apply to every pytest run, including the Python 3.10 to 3.12 legs that were only exercised locally on one version; the CI matrix result is part of A3.
3. If `StartShardProcess` throws partway through the start loop, already started children are neither awaited nor stopped (CR-3, Info).

**PR readiness recommendation:** **Ready after F1 and step 9** — no code defect blocks the PR; the open autonomous item is an acceptance-criterion wording defect (F1, recorded in the policy and feature audits), and the CI-dependent items are owned by step 9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md` | `## Acceptance Criteria`, the `.vscode/tasks.json` items in Part 1 and Part 2 | CR-1 (= F1). Both criteria require that `tasks.json` "passes governed-JSON validation". `validate_json` governs `scripts/**/*.json`, `docs/**/*.json`, and `examples/**/*.json` only, and an explicit call on `tasks.json` exits 1 at `HEAD` and at the merge base because the file is JSONC. | Amend the two criteria to the verifiable condition (JSONC parse succeeds, required labels present, file outside the governed globs), cite `evidence/other/validate-json-tasks.2026-10-31T18-16.md`, and check them off. | The criterion is unsatisfiable for any version of the file, so it can never be checked off as written; the delivered tasks are correct. | `scripts/dev_tools/json_config.py` `GOVERNED_GLOBS`; validator output recorded in the policy audit Section 3D. |
| Minor | `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | `Invoke-PoshQCParallelTest`, the omitted-root and relative-root assignments | CR-2. The two `-Root` fallback assignments are not executed by any test (JaCoCo lines 408 and 411, `ci="0"`). Unlike the wrapper body, they are reachable through the existing seams. | Add one runner case that omits `-Root` and one that passes a relative root, asserting the resolved root in the shard argument list (no process, no file). | Untested path normalization in the public entry point; file coverage is already 96.00%, so this is not a threshold failure. | `artifacts/pester/powershell-coverage.xml`; self-review row 1.2 Comprehensive Coverage. |
| Info | `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | `Invoke-PoshQCParallelTest`, start loop | CR-3. A throw from `ResetShardDirectory` or `StartShardProcess` for shard k leaves shards 1 to k-1 running without a wait; they finish on their own and write only under `artifacts/pester/parallel/`. | Optional: wrap the start loop so already started processes are awaited or stopped before the error propagates. | Merged artifacts are never written on this path, so the no-partial-overwrite contract holds; the cost is orphaned child processes on a local machine. | Function body. |
| Info | `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | `Invoke-PoshQCPwshExe` | CR-4 (deviation D2). The wrapper body (four executable lines) is not executed by unit tests, because `check-powershell-test-purity.ps1` denies `Start-Process` in test files and the rule requires mocking the wrapper. The wrapper takes `-LogPath` in addition to the `-PwshArgs` array and uses `Start-Process` rather than a splatted call. | No action. | An asynchronous child with redirected output needs `Start-Process`; the uncovered lines remain in the coverage denominator (no exclusion), which is the outcome the Coverage Exclusion Policy prescribes for a thin host-bound entry point. The default seam bodies that call it do run in PR09. | JaCoCo lines 263, 264, 266, 267; `evidence/other/execution-deviations.2026-10-31T19-18.md` D2. |
| Info | `.github/workflows/_quality-checks.yml` | `Run tests with Pytest` | CR-5. The step gains only `-n auto`; the name, `--cov`, `--cov-branch`, `--cov-report=xml`, `--cov-report=json:artifacts/python/coverage.json`, and `--cov-report=term-missing` are kept, and the threshold and Codecov steps are unchanged (diff re-read). | Measure against `-n 4` in step 9 (P9-T1 to P9-T3). | The modified workflow needs a green branch-head run before merge (A3). | `git diff <merge-base> HEAD -- .github/workflows/_quality-checks.yml`. |

No Blocker or Major findings. No covered file is at or above 700 logical lines (largest: `PoshQC.Testing.psm1` at 491), so no file-size Warning applies.

---

## Implementation Audit

### Python implementation audit

- `pyproject.toml`: `pytest-xdist = "^3"` under dev dependencies; `addopts` keeps `-ra --cov-report=lcov:artifacts/python/lcov.info` first and appends `--strict-markers --strict-config`; `xfail_strict = true` added as its own key. No `-n`, `--numprocesses`, or `--dist` token.
- `poetry.lock`: one `pytest-xdist` entry plus its `execnet` dependency; zero `psutil` entries at both ends; `poetry check --lock` exits 0.
- Test changes only: the reload leak is removed instead of being ordered around, and the regression test asserts module-object identity after the clipboard tests run. No new Python script exists outside `tests/`.

### PowerShell implementation audit

#### What changed well

- `Merge-PoshQCJunitReport` captures every report's suites before mutating the first document, renumbers `id`, sums counters as `[long]`, parses `time` with the invariant culture, and disables external XML resolution (`XmlResolver = $null`).
- `Invoke-PoshQCParallelMerge` checks exit codes, then output presence, then completeness, then merges, and writes only after all succeed; each failure path logs a specific message and returns 1. This implements the spec's no-partial-overwrite rule.
- The wait seam calls `WaitForExit()` on the held process object, fixing the `Wait-Process -Id` race found by the first concurrent run (D5); reading `Handle` in the wrapper keeps `ExitCode` available after exit.
- Child commands quote paths with single quotes and double embedded quotes; no `Invoke-Expression`.
- `Invoke-PoshQCTest` gained two optional parameters applied before the existing path resolution, so relative overrides resolve against `-Root` and directories are created by the existing seam; omitted parameters leave behavior unchanged (OP03).
- Weights keys are repository-relative forward-slash paths, so every Windows shard computes the same assignment; the parser rejects absolute keys.
- Source and bundled copies of all six PoshQC files are byte-identical (`cmp`, re-run in this review).

#### API and safety notes

- Five functions are exported and listed in both `Export-ModuleMember` and `FunctionsToExport`.
- The runner never calls `exit`; the VS Code task wraps it with `exit (Invoke-PoshQCParallelTest -Root '${workspaceFolder}').ExitCode`.

#### Error handling and logging

- No catch-all handler that swallows errors: each `catch` logs the message and returns exit code 1. A per-shard log and a summary line with worker count and wall-clock are written.

---

## Test Quality Audit

The new suites prove the worker formula, the JUnit merge arithmetic and failure modes, the weights conversion and lookup with all fallbacks, the runner's exit semantics, and the default seams. Fail-before is recorded for the OP, SW, PM, PR, and hard-lock tests.

### Reviewed test and QA artifacts

- `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1` — in-memory file map, queued fake clock, fake process objects; no file, process, or sleep.
- `tests/scripts/powershell/PoshQC/PoshQC.ParallelMerge.Tests.ps1`, `PoshQC.ShardWeights.Tests.ps1`, `PoshQC.TestingOutputPath.Tests.ps1` — in-memory XML and JSON text; `FileInfo` items whose paths are never opened.
- `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` — the `-n` check and its companion negative test.
- `evidence/regression-testing/pester-concurrent-vs-serial.2026-10-31T19-50.md` — 13643 tests, 0 failures in both runs.
- `evidence/qa-gates/pester-coverage.2026-10-31T20-39.md` and `artifacts/pester/powershell-coverage.xml` — counters re-read in this review.

### Quality assessment prompts

- **Determinism:** No real clock, RNG, environment variable, temp file, or process in the new tests (searched in this review).
- **Isolation:** One behavior per `It`; seams rebuilt per case.
- **Speed:** The new suites run in seconds.
- **Diagnostics:** `-Because` texts name the expectation.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | One child command per shard built from quoted paths; no `Invoke-Expression`; external resolution disabled for XML. |
| Input validation at boundaries | ✅ PASS | Weights document validated for version, unit, non-empty map, non-negative integers, and relative keys; JUnit root element checked. |
| Error handling remains explicit | ✅ PASS | Every merge-path failure returns 1 with a logged reason. |
| Configuration / path handling is safe | ✅ PASS | Relative overrides resolved against `-Root`; weights carry no absolute path (re-checked). |

---

## Research Log

No external research was required. Behavior was established from repository sources: `scripts/dev_tools/json_config.py` (`GOVERNED_GLOBS` and the JSONC note), `scripts/dev_tools/validate_json.py` (`collect_targets`), `.claude/hooks/check-powershell-test-purity.ps1` (the `Start-Process` rule), and `quality-tiers.yml` (PoshQC is T3).

---

## Verdict

The implementation meets the spec's behavior and the repository's design, seam, coverage, and determinism rules. CR-1 (F1) is the one item that needs an autonomous remediation, and it is a requirements-wording correction rather than a code change. CR-2 is a small related test addition that can be made in the same cycle. The CI-dependent measurements and the branch-head green run remain with orchestrator step 9.
