# Feature Audit: pytest-xdist and concurrent Pester test cycle (#1048), re-audit R4

---

**Audit Date:** 2026-10-31
**Feature Folder:** `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048`
**Base Branch:** `main`
**Head Branch:** `feature/pytest-xdist-parallel-test-cycle-1048`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit of the full branch diff after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `main` (merge base `58b81ca577943cd2944b62ee23ff3a3d1d737092`)
- **Head branch/commit:** `feature/pytest-xdist-parallel-test-cycle-1048` (commit `522abaadee33779de6b687335bbd4f64f93033f8`, pushed)
- **Merge base:** `58b81ca577943cd2944b62ee23ff3a3d1d737092`
- **Evidence sources:**
  - Primary: the full branch diff against the merge base, plus `git diff 522abaade~1..522abaade --name-status` (23 added files, 2 modified: `spec.md` and `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1`; no production file, no bundle file).
  - Feature evidence: `evidence/other/spec-ac-jsonc-amendment.2026-10-31T21-19.md`, `evidence/qa-gates/pester-poshqc.2026-10-31T21-31.md`, `evidence/regression-testing/pester-shuffle.2026-10-31T21-31.md`, and the earlier records cited in the prior feature audit.
  - Re-verified in this review: the unified diff of `spec.md` and the test file; a fresh JSONC parse of `.vscode/tasks.json`; the JaCoCo per-file counter read; a search of the test file for banned constructs; the checkbox state of `spec.md` and `user-story.md`.
- **Feature folder used:** `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria` are the AC sources; each is tracked independently.
- **Scope note:** No pull request exists yet.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md` - 30 checkbox items (24 checked at review start)
- `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/user-story.md` - 14 checkbox items (11 checked at review start)

Numbering S1 to S30 and U1 to U14 follows file order, as in the prior feature audit (`feature-audit.2026-10-31T21-02.md`).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S1 | Dependency, lock, lock-sync CI step, no `psutil` | PENDING CI | Local part verified at the prior review (unchanged files). | `grep -c`; `poetry check --lock` | Pending-S9 item 3. Unchecked. |
| S2 | CI step uses faster setting; threshold on merged coverage | PENDING CI | Step carries `-n auto` and every prior token. | `git diff -- .github/workflows/_quality-checks.yml` | Pending-S9 item 1. Unchecked. |
| S3 | `-n` absent from `addopts`; serial task remains | PASS | `pyproject.toml` unchanged; serial label present in the fresh JSONC parse. | `grep addopts pyproject.toml`; JSONC parse | Already checked. |
| S4 | Parallel pytest tasks; JSONC parse with every required label | PASS | Fresh parse: 55 tasks; `QC: 4 Pytest: run tests (parallel)` runs `poetry run pytest -n auto`; `QC: 4 Pytest: run tests with coverage (parallel)` adds `--cov-branch`, `--cov-report=lcov:artifacts/python/lcov.info`, `--cov`. Count matches the amendment evidence. | `node` JSONC parse | Checked in cycle 1; verified here. Resolves F1. |
| S5 | Reload leak fixed with regression test | PASS | Unchanged since the prior review. | Prior evidence | Already checked. |
| S6 | Serial, `-n auto`, shuffled, reversed runs pass | PASS | Unchanged. | Prior evidence | Already checked. |
| S7 | Porcelain clean after `-n auto` | PASS | Unchanged. | Prior evidence | Already checked. |
| S8 | Coverage totals equal within rounding | PASS | Unchanged. | Prior evidence | Already checked. |
| S9 | CI timings and before/after duration | PENDING CI | Baseline in `ci-durations.2026-10-31T18-13.md`. | - | Pending-S9 item 1. Unchecked. |
| S10 | Strictness decisions and follow-ups | PASS | Unchanged. | Prior evidence | Already checked. |
| S11 | Workflow contract test asserts `-n` | PASS | Unchanged. | Prior evidence | Already checked. |
| S12 | Output-path parameters with tests | PASS | Unchanged; OP01-OP04. | Prior evidence | Already checked. |
| S13 | Module registered, exported, runner behavior | PASS | Unchanged; PR01, PR02. | Prior evidence | Already checked. |
| S14 | Worker default, cap, override tests | PASS | Unchanged. | Prior evidence | Already checked. |
| S15 | JUnit merge | PASS | Unchanged. | Prior evidence | Already checked. |
| S16 | Merged coverage, completeness, merged file | PASS | Unchanged. | Prior evidence | Already checked. |
| S17 | Exit semantics and no partial overwrite | PASS | Unchanged. | Prior evidence | Already checked. |
| S18 | VS Code Pester parallel task; JSONC parse with every required label | PASS | `PoshQC: 4 test (Pester, parallel)` runs `Invoke-PoshQCParallelTest -Root '${workspaceFolder}'` and exits with its `ExitCode`; `PoshQC: 4 test (Pester)` is present. | `node` JSONC parse | Checked in cycle 1; verified here. Resolves F1. |
| S19 | Concurrent equals serial | PASS | Unchanged. | Prior evidence | Already checked. |
| S20 | Weights file, lookup, fallbacks, malformed | PASS | Unchanged. | Prior evidence | Already checked. |
| S21 | CI shard spread smaller than baseline, or decision | PENDING CI | Projection only; measurement needs a branch-head run. | - | Pending-S9 item 2. Unchecked. |
| S22 | Slow-file profile with follow-ups | PASS | Unchanged. | Prior evidence | Already checked. |
| S23 | Concurrent and seeded shuffled Pester runs | PASS | Unchanged; cycle 1 added seeds 7, 1048, 20261031 over the PoshQC folder, 0 failures. | `pester-shuffle.2026-10-31T21-31.md` | Already checked. |
| S24 | `_poshqc.yml` checks pass; green branch-head run | PENDING CI | `_poshqc.yml` unchanged on the branch. | `git diff --name-status` | Pending-S9 item 3. Unchecked. |
| S25 | Bundled copies, parity path, tests pass | PASS | No source or bundle file in the cycle-1 delta, so parity is unchanged. | `git diff --name-status 522abaade~1..522abaade` | Already checked. |
| S26 | README documents runner | PASS | Unchanged. | Prior evidence | Already checked. |
| S27 | Brief in every copy | PASS | Unchanged. | Prior evidence | Already checked. |
| S28 | No new Python script; no Python hook invocation | PASS | No added `.py` file and no hook path in the cycle-1 delta. | `git diff --name-status` | Already checked. |
| S29 | Linux hook-suite job unchanged; non-required status recorded | PENDING CI | `_poshqc.yml` unchanged; the ruleset observation needs a CI run. | - | Pending-S9 item 3. Unchecked. |
| S30 | File count explanation | PASS | Unchanged. | Prior evidence | Already checked. |
| U1 | Locked dependency, no `psutil` | PASS | Unchanged. | Prior evidence | Already checked. |
| U2 | CI step faster setting; threshold passes | PENDING CI | As S2. | - | Pending-S9 item 1. Unchecked. |
| U3 | Parallel pytest tasks exist | PASS | Fresh JSONC parse. | `node` JSONC parse | Already checked. |
| U4 | Leak fixed; order-independence runs | PASS | Unchanged. | - | Already checked. |
| U5 | Before/after CI duration with both timings | PENDING CI | As S9. | - | Pending-S9 item 1. Unchecked. |
| U6 | Strictness decisions | PASS | Unchanged. | - | Already checked. |
| U7 | Local command and task, merges, exit semantics | PASS | S13 to S19. | - | Already checked. |
| U8 | CI shards from committed weights; before/after Pester wall-clock | PENDING CI | As S21. | - | Pending-S9 item 2. Unchecked. |
| U9 | Slow-file profile | PASS | As S22. | - | Already checked. |
| U10 | Concurrent and shuffled Pester runs | PASS | As S23. | - | Already checked. |
| U11 | Bundled mirrors and parity | PASS | As S25. | - | Already checked. |
| U12 | Brief in every copy | PASS | As S27. | - | Already checked. |
| U13 | Workflow and PoshQC contract tests pass | PASS | Prior full run 0 failures; cycle-1 PoshQC run 229 tests, 0 failures. | - | Already checked. |
| U14 | No new Python script | PASS | As S28. | - | Already checked. |

---

## Summary

**Overall Feature Readiness:** READY_FOR_PR (CI-dependent verification pending at orchestrator step 9)

**Criteria summary:**
- **PASS:** 35 criteria (24 in `spec.md`, 11 in `user-story.md`)
- **PARTIAL:** 0 criteria
- **PENDING CI (Pending-S9):** 9 criteria (S1, S2, S9, S21, S24, S29, U2, U5, U8)
- **FAIL:** 0 criteria

**Remediation cycle 1 verification:**

1. F1 resolved. The `spec.md` diff shows only the two clause replacements and the two checkbox changes. The amendment evidence records 55 tasks and five labels; a fresh JSONC parse in this review returned 55 tasks and all five labels present.
2. CR-2 resolved. PR10 and PR11 exist and use only the existing seams; no `Start-Process`, sleep, `TestDrive`, or temp-path call; `PoshQC.Parallel.psm1` line coverage reads 97.33% (146 of 150) in the existing coverage artifact, at least 97%.
3. No production file and no bundle file changed in the cycle.
4. No CI-dependent criterion was checked off: S1, S2, S9, S21, S24, S29, U2, U5, and U8 are all `[ ]` in the source files (verified by grep).

### Pending-S9 classification (non-blocking, owned by orchestrator step 9)

The following three items were recorded as awaiting-CI findings in the prior review. They require a pull request and a CI run on the final branch head, which cannot exist before the PR is opened. In this re-audit they are classified Pending-S9 (non-blocking) and are deliberately not written as blocking findings, so that the pull request creation gate can open. Orchestrator step 9 owns them, and the item's own orchestrator run checks off the criteria after the CI green gate (S9) records success.

1. **Pending-S9 item 1 (former A1):** the `-n auto` against `-n 4` CI timings, the worker count decision, and the before and after duration of `quality-checks7 / Code Quality & Tests (3.13)` (S2, S9, U2, U5).
2. **Pending-S9 item 2 (former A2):** the CI Pester shard durations before and after the weights change and the spread comparison against the baseline, with a recorded shard-count decision if the spread does not shrink (S21, U8).
3. **Pending-S9 item 3 (former A3):** a green workflow run on the final branch head including the lock-sync step, the Python 3.10 to 3.13 matrix under the strict pytest options, the `_poshqc.yml` merged coverage and completeness checks, and the Linux hook-suite non-required-status observation (S1 CI clause, S24, S29, and the Definition of Done item "Behavior matches acceptance criteria in all documented environments").

**Recommended follow-up verification steps:**

1. Open the pull request.
2. Orchestrator step 9: run the CI comparison, record the evidence, then check off S1, S2, S9, S21, S24, S29, U2, U5, U8 and the Definition of Done item, and re-run the CI green gate against the final head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md`, `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/user-story.md`
- Total AC items: 44 (30 + 14)
- Checked off (delivered): 35 (24 + 11)
- Remaining (unchecked): 9 (6 + 3)
- Items remaining: S1 (dependency and lock-sync CI step), S2 (CI step faster setting and threshold), S9 (CI timings), S21 (CI shard spread), S24 (`_poshqc.yml` and green branch-head run), S29 (Linux hook-suite observation), U2 (CI step faster setting), U5 (before/after CI duration), U8 (balanced CI shards and before/after Pester wall-clock)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md` | 30 | 24 | 6 | all 6 Pending-S9 |
| `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/user-story.md` | 14 | 11 | 3 | all 3 Pending-S9 |

No source-file checkbox change was made in this review: every criterion evaluated PASS was already checked, and every criterion not evaluated PASS was already unchecked.
