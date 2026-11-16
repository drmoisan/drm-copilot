# Code Review: PowerShell six-shard QC and Python 3.13 two-shard coverage (#1190), reaudit after remediation cycle 1

---

**Review Date:** 2026-11-15
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190`
**Feature Folder Selection Rule:** Supplied by the caller; it is the only active feature folder changed on the branch and its suffix matches issue 1190.
**Base Branch:** `main` (resolved `origin/main`, merge base `11c6ecde2e3080722c90bc63289bc160bf9596ea`)
**Head Branch:** `feature/ci-shard-powershell-and-python` at `7bda5fe2bc599be5be8460823b5171411d8e9d42`
**Review Type:** Full review of the branch diff against the merge base (reaudit after remediation cycle 1)

---

## Executive Summary

The implementation is sound. `_poshqc.yml` changes one matrix literal to six shards. `_quality-checks.yml` moves Python 3.13 into a static job, a two-shard coverage job, and a combine job named `Code Quality & Tests (3.13)` that runs under `if: always()`, fails in its first step unless both upstream jobs succeeded, verifies completeness, combines coverage, and then runs the unchanged 85 line and 75 branch threshold step and Codecov upload. The new PowerShell helper reuses `PoshQC.Shard.psm1` unchanged, takes every boundary through an injected seam, weighs files by LF-normalized byte size, and has 89.86% line coverage. No Python script or dependency was added. Brief and plan-contract copies are byte-identical. CI run 43736520255 succeeded on every job, including `CI Required Gate`, and the first-run risks named in the spec (COVERAGE_FILE under xdist, hidden-file upload, combine path match, Linux module loading) all passed.

Remediation cycle 1 regenerated `config/poshqc-shard-weights.json` from run 43736520255 timings (data-only: 819 listed files, version 1, unit ms; the weights tests and the final Pester gate pass with 26885 tests and 0 failures). CI run 43749104502 on code head `26217c890` succeeded on every job including `CI Required Gate`; the reviewed head adds only feature-folder documents. The PowerShell shards now measure 8.4 to 12.7 minutes (longest 12.7; before 13.6; baseline 16.9) and the Python 3.13 path 10.5 minutes (baseline 16.4). One regeneration moved the imbalance (shard 1 now longest) instead of removing it; the projected per-file balance is 1.000, so the residual is per-shard fixed cost, which the weights do not model.

**Top risks:**
1. CR-1 (non-blocking, documented trade-off): the longest PowerShell shard is 12.7 minutes against about 11; the spread (8.4 to 12.7) is above the plan's 20 percent trigger. The plan permits one regeneration and instructs recording the residual without altering the criterion; the shard count is an owner input.
2. CR-2: Python shards are size-balanced, not time-balanced (5.6 and 8.4 minutes); the leg meets the target, so this is informational.
3. CR-3: Runner contention under concurrent PRs is reasoned but not measured at load.

**PR readiness recommendation:** **Ready for pull request.** No blocking finding; no code defect was found.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `config/poshqc-shard-weights.json` | file (weights consumed by `Select-PoshQCShardTestFile` for the `poshqc-shard` matrix) | CR-1. After the regeneration (commit `cde1c4a3e`, data-only) the six PowerShell shards measured 12.7, 10.2, 10.0, 8.4, 9.9 and 10.4 minutes in run 43749104502. The longest (12.7) is 15 percent above the about 11 minute target and the spread is 51 percent of the shortest shard. The earlier run measured 7.4 to 13.6. The longest shard fell from 13.6 to 12.7 minutes against a 16.9 minute baseline (25 percent cut), and every shard but shard 1 is at or below 10.4 minutes. | No further regeneration in this cycle: the plan permits one. If a stricter figure is wanted, raise the shard count (an owner decision) or model per-shard fixed cost in the weights as a follow-up. | The projected per-file balance is 1.000 for the new weights, so the residual is per-shard fixed cost (module import, instrumentation, artifact upload) and run-to-run runner variance of about 1 to 3 minutes, which the weights do not capture. The issue's own wording targets a material cut of the long legs and the user story says "toward 11 minutes". | `evidence/other/ci-measurement.2026-11-15T19-10.md`; `evidence/other/shard-weights-regeneration.2026-11-15T17-52.md`. |
| Info | `scripts/ci/Select-PythonTestShard.ps1` | `Get-PythonTestShardSelection` weighting | CR-2. Python files are weighed by byte size, so shard 1 ran 6.0 minutes and shard 2 ran 9.4 minutes. The Python critical path (11.3 minutes, start to combine end) meets the target. | No action now. If the Python leg later exceeds the target, a Python weights file through the existing `ReadWeightsText` seam is the tuning option. | The helper intentionally passes a null weights reader so the PowerShell millisecond weights file is never read (test SH07). | `ci-measurement` record; SH07. |
| Info | `.github/workflows/_quality-checks.yml` | `python-coverage-combine` | CR-3. The combine job installs the full Poetry environment only to run `coverage combine`, `coverage xml`, `coverage json`, the threshold checker, and `pytest --collect-only`. The step is correct and cached; the cost is within the measured 1.8 minutes. | No action. | The threshold checker and the collect-only count need the project environment. | Workflow diff; measurement. |
| Info | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | whole file | CR-4. The file is 532 logical lines; the plan expected it to stay under 500. It is under the 700-line advisory tier, so no Warning applies. | No action. | The 500-line tier is guidance only. | `awk 'END{print NR}'` count. |
| Info | `.github/workflows/_quality-checks.yml` | combine first step | CR-5. The first step reads `needs.<job>.result` through expression interpolation into a shell script. Only fixed enumeration values flow in, so there is no injection path. | No action. | The pattern is the standard way to fail a combine job on upstream failure. | Workflow diff. |

No finding requires action before the pull request; CR-1 is non-blocking. No file at or above 700 logical lines exists among the added or modified covered files, so no file-size Warning row applies; the largest is 532.

---

## Implementation Audit

### Python implementation audit

No production Python changed. The contract tests load jobs by id from the YAML and pin the matrices (`["3.11", "3.12"]` and `[1, 2]`), the shard count wiring (`-ShardCount ${{ strategy.job-total }}`), the non-dot `COVERAGE_FILE`, the per-shard upload artifact, the combine job name, `needs`, and `always()`, the first step's requirement on both results, the ordering of `coverage combine` before the threshold and Codecov steps, and the completeness verify step. They are deterministic reads of repository files with no temp file.

### PowerShell implementation audit

#### What changed well

- The helper orders files by ordinal root-relative forward-slash path and weighs by LF-normalized UTF-8 byte count, so a CRLF checkout and an LF checkout produce one assignment (SH03).
- Every boundary (enumeration, read, write, search) is an injected seam with a default implementation, and the entry call is guarded so dot-sourcing in tests runs nothing.
- `Write-PythonShardFileText` supports ShouldProcess and writes with `-NoNewline` and UTF-8 without a BOM.
- Verify mode reuses `Test-PoshQCShardCompleteness` and `Test-PoshQCShardTestCount`, so the missing, duplicate, and JUnit-sum checks are shared with the PowerShell legs.
- Select mode throws for an empty shard and Verify mode throws when the collect output has no summary line, so a malformed run fails the job.

#### API and safety notes

- `Invoke-PythonTestShardEntry` maps any throw to exit code 1 and writes the message to the error stream; both paths are tested (SH10).
- The six-shard PowerShell matrix is written only in `_poshqc.yml`; the aggregator reads the count from the shard manifest, as the plan stated, and run 43736520255 confirms the completeness check, coverage merge, and discovery count comparison pass.

#### Error handling and logging

- Fail-fast and explicit: no broad catch-all other than the entry function, which converts the throw to an exit code with the original message.

### Workflow audit

- `python-coverage-shard` uses `fail-fast: false`, uploads with `always()`, and `if-no-files-found: error`, so a failing shard still publishes its data and a shard that wrote nothing fails.
- `python-coverage-combine` has `if: always()` at job level and every step gated on `inputs.run-heavy`, so a docs-only run reports success, while a code run with any failed shard fails in the first step and fails `CI Required Gate` (the gate depends on the `quality-checks7` caller, whose result includes every job of the called workflow).
- The coverage file name has no leading dot, avoiding the `upload-artifact` hidden-file skip.
- Compatibility legs (3.11 and 3.12) keep their contexts and keep the no-coverage step.

---

## Test Quality Audit

The helper tests cover balanced assignment, deterministic order (repeat and reversed enumeration), CRLF equals LF, size weighting against all-one and median alternatives, empty shard, manifest write, weights-file isolation, collect-count parsing, completeness pass, absent file, duplicate file, JUnit-sum mismatch, and entry exit codes. Fixtures are in-memory text served through seams, so no temp file exists. The parallel-only standing rule holds: the gates ran `pytest -n auto` and one parallel Pester run, and `--collect-only` executes no test.

### Reviewed test and QA artifacts

- `tests/scripts/ci/Select-PythonTestShard.Tests.ps1`
- `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
- `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, `test_execution_environment_brief_contracts.py`, `test_host_environment_contracts.py`
- `evidence/qa-gates/final-pester.2026-11-15T01-16.md`, `final-pytest.2026-11-15T01-16.md`, `final-qc-static-powershell.2026-11-15T01-16.md`, `final-qc-static-python.2026-11-15T01-16.md`
- `evidence/other/ci-measurement.2026-11-15T17-20.md`

### Quality assessment prompts

- **Determinism:** No clock, RNG, or environment write.
- **Isolation:** Seams only; no shared state.
- **Speed:** No process start or sleep.
- **Diagnostics:** Workflow tests carry `-Because` texts.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspected. |
| No unsafe subprocess or command construction | PASS | The shard step reads the file list with `mapfile` and passes it quoted as `"${shard_files[@]}"`. |
| Input validation at boundaries | PASS | `ValidateSet` on `Mode`; the collect text is parsed with an anchored regex. |
| Error handling remains explicit | PASS | Throws map to exit code 1. |
| Configuration / path handling is safe | PASS | No absolute path is written into any artifact; evidence uses repository-relative paths and run identifiers. |

---

## Research Log

No external research was required. Evidence came from the branch diff, the persisted QA records, the CI measurement record for run 43736520255, and byte comparison of the mirrored copies.

---

## Verdict

The implementation meets the spec's behavior and the repository's design, seam, coverage, and determinism rules, and the weights regeneration is a clean data-only change with green CI. One documented trade-off remains (CR-1, non-blocking): the longest PowerShell shard is 12.7 minutes against about 11. No code defect was found.
