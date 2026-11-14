# 2026-11-14-ci-shard-powershell-and-python-coverage — Spec

- **Issue:** #1190
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14T17-45
- **Status:** Draft
- **Version:** 0.2

## Overview

CI wall-clock time is dominated by two jobs. Measured on the main push run of 2026-11-14 19:24Z:

- The three PowerShell QC shards (`.github/workflows/_poshqc.yml`, `shard: [1, 2, 3]`, windows-latest) took 13.3, 16.7 and 16.9 minutes. The Test PowerShell step was about 16.3 minutes of each.
- Python 3.13 "Code Quality & Tests" (`.github/workflows/_quality-checks.yml`) took 16.4 minutes. Its pytest coverage step was 13.6 minutes.

On PR runs, shards also waited for runners when several PRs ran CI at once, so PR CI reached about 30 minutes. The owner requested more shards on 2026-11-14. The shard counts (6 and 2) are owner-specified inputs, not derived populations. Research: `research/2026-11-14T22-50-ci-sharding-research.md`.

## Behavior

- PowerShell QC runs 6 shards. The matrix literal in `_poshqc.yml` is the only place the count is written; `strategy.job-total`, the aggregator loops, completeness verification, and coverage merge follow it.
- Python 3.13 moves out of the `quality-checks7` matrix (which becomes `["3.11", "3.12"]`) into three jobs:
  - a static job (lock check, black, ruff, pyright, Codex check, tier check);
  - a 2-shard coverage job running `pytest -n auto --cov --cov-branch` on that shard's files, with per-shard `COVERAGE_FILE` data, JUnit output, and a manifest uploaded as an artifact;
  - a combine job named `Code Quality & Tests (3.13)` (context `quality-checks7 / Code Quality & Tests (3.13)`) that requires the static and shard jobs to succeed, checks completeness, runs `coverage combine`, produces `coverage.xml` and `artifacts/python/coverage.json`, then runs the unchanged threshold step (85% line, 75% branch) and the unchanged Codecov upload.
- The split is deterministic and balanced, implemented in a new PowerShell helper (`scripts/ci/Select-PythonTestShard.ps1`) that reuses the existing longest-processing-time logic in `scripts/powershell/PoshQC/PoshQC.Shard.psm1`. No new Python and no new plugin dependency.
- Completeness: every `tests/**/test_*.py` is in exactly one shard (`Test-PoshQCShardCompleteness` throws on a missing or duplicate file), and the sum of shard JUnit test counts equals the `pytest --collect-only` count (`Test-PoshQCShardTestCount`).
- 3.11 and 3.12 compatibility runs, `ci.yml`, and `CI Required Gate` are unchanged. On a docs-only run the combine job still reports success (`if: always()` with every step gated on `inputs.run-heavy`).

## Inputs / Outputs

- Inputs: `-ShardIndex`, `-ShardCount` (from `matrix.shard` and `strategy.job-total`), repository root; optional weights file through the existing `-ReadWeightsText` seam.
- Outputs: `artifacts/python/shard-files.json` (manifest), `artifacts/python/shard-files.txt` (this shard's files), per-shard coverage data and JUnit, artifacts named `python-coverage-shard-<n>`.
- Versioning: PoshQC module unchanged; its mirror copies stay unchanged.

## Data & State

- Coverage data per shard is named without a leading dot so `upload-artifact` does not skip it; fallback is `include-hidden-files: true`.
- All jobs run on ubuntu-latest in the same workspace path, so `coverage combine` needs no path remapping.
- Weights are LF-normalized byte size, so line endings do not change assignment.

## Constraints & Risks

- Avoid new Python. Parallel-only test policy applies; no serial run is introduced (`--collect-only` runs no tests).
- Runner contention: 3 more windows jobs and about 3 more ubuntu jobs per run raise total runner minutes (setup overhead of about 0.5 to 1.5 minutes per job) while lowering wall-clock; concurrent PR runs may queue longer. Reported as evidence.
- CI-only behavior to verify in the first run: `COVERAGE_FILE` override under xdist, hidden-file skip, combine path match.
- Order-dependent tests may surface when shard contents change; fix leaker and victim, never pin order.

## Implementation Strategy

- Edit `_poshqc.yml` (matrix) and `_quality-checks.yml` (restructure); add the helper and a Pester test at `tests/scripts/ci/Select-PythonTestShard.Tests.ps1`.
- Update pinned tests: `PoshQcWorkflow.Tests.ps1`, `CiChangeScopeWorkflow.Tests.ps1`, `test_execution_environment_brief_contracts.py`, `test_quality_checks_workflow_contracts.py`, `test_host_environment_contracts.py`, `test_ruff_config_alignment.py` as needed.
- Update the `execution-environment` SKILL.md (all byte-identical copies) and `.github/workflows/README.md`; add shards 4-6 and the Python job contexts to the required-contexts lists.
- Rollout fallback: a third Python shard is a matrix edit; regenerate weights only if shard spread exceeds about 20%.

## Acceptance Criteria

- [ ] `_poshqc.yml` declares the owner-specified PowerShell shard count stated in Behavior; the completeness check, coverage merge, and Pester discovery count comparison pass in a CI run.
- [ ] Primary-version Python coverage runs in the owner-specified shard count stated in Behavior using `Select-PythonTestShard.ps1`, which is deterministic (identical output across repeated calls) and balanced (no new Python, no new dependency).
- [ ] Each Python shard uploads its coverage data, JUnit, and manifest as a per-shard artifact.
- [ ] A combine job that keeps the existing required context name given in Behavior combines coverage, then runs the unchanged line and branch threshold step and the Codecov upload on the combined data; no threshold is lowered.
- [ ] A completeness check fails when a test file is missing or duplicated across shards and when the shard JUnit total differs from the collect-only count.
- [ ] The Python compatibility runs other than the primary version are unchanged and keep their contexts.
- [ ] `CI Required Gate` still blocks when any PowerShell or Python shard fails, and the combine job reports success on a docs-only run.
- [ ] actionlint passes on `_poshqc.yml` and `_quality-checks.yml`.
- [ ] Pester tests for the helper cover balanced assignment, deterministic order, a missing file detected, and a duplicate detected; the helper meets the coverage thresholds.
- [ ] Workflow-pinning tests are updated and pass.
- [ ] The `execution-environment` brief (every byte-identical copy), `_REQUIRED_CONTEXTS`, and `.github/workflows/README.md` list the new shards and job contexts.
- [ ] A measured CI run after the change shows the PowerShell and primary-version Python legs each at or below the duration target stated in the issue, recorded under `evidence/` with run URL, per-job durations, and the runner-queue trade-off.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Pester or bats tests for any new split or completeness helper: balanced assignment, deterministic order, a missing file detected, a duplicate detected
- [ ] actionlint passes on the changed workflows
- [ ] One real CI run on the PR proves the timings
