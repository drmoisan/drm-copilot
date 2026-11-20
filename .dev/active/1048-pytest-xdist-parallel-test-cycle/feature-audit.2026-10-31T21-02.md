# Feature Audit: pytest-xdist and concurrent Pester test cycle (#1048)

---

**Audit Date:** 2026-10-31
**Feature Folder:** `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048`
**Base Branch:** `main`
**Head Branch:** `feature/pytest-xdist-parallel-test-cycle-1048`
**Work Mode:** `full-feature`
**Audit Type:** Initial audit of the full branch diff

---

## Scope and Baseline

- **Base branch:** `main` (commit `58b81ca577943cd2944b62ee23ff3a3d1d737092`; `origin/main` equals this commit)
- **Head branch/commit:** `feature/pytest-xdist-parallel-test-cycle-1048` (commit `d817f4075c4c9f5a69b185173e53987ae8d0dd91`, pushed)
- **Merge base:** `58b81ca577943cd2944b62ee23ff3a3d1d737092`
- **Evidence sources:**
  - Primary: `git diff 58b81ca577943cd2944b62ee23ff3a3d1d737092..HEAD` (78 files). The PR context artifacts in this worktree describe another branch (`bug/standalone-orchestration-merge-on-green-997`, 2026-10-29) and no collection tool is available to this reviewer, so the full git diff is the baseline source.
  - Feature evidence: `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/evidence/**`, `evidence/other/execution-deviations.2026-10-31T19-18.md`, `evidence/qa-gates/self-review.2026-10-31T21-00.md`
  - Additional evidence (re-run in this review): `poetry check --lock`, lock and `addopts` greps, `cmp` of six PoshQC pairs, SHA-256 of six brief copies, logical line counts, four modified Python test files (48 passed), JaCoCo and LCOV counter reads, JSONC parse of `.vscode/tasks.json`, `validate_json` on `tasks.json` at `HEAD` and at the merge base, evidence-location validator (exit 0)
- **Feature folder used:** `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria` are the AC sources; each is tracked independently.
- **Scope note:** No PR exists yet. CI-dependent criteria (Phase 9: P9-T1 to P9-T5) are owned by orchestrator step 9 and are recorded here as pending CI, not as failures. The plan carries five Phase 9 tasks.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md` — 30 checkbox items (22 checked at review start)
- `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/user-story.md` — 14 checkbox items (11 checked at review start)

### spec.md acceptance criteria (S1 to S30, in file order)

S1 `pytest-xdist` dependency, lock regenerated, lock-sync CI step passes, no `psutil`. S2 CI step uses the faster of `-n auto` / `-n 4`, keeps name and coverage options, threshold step passes on merged coverage. S3 `-n` not in `addopts`; serial task remains. S4 parallel pytest tasks in `tasks.json`, which passes governed-JSON validation. S5 reload leak fixed with regression test. S6 serial, `-n auto`, shuffled, reversed runs pass. S7 porcelain clean after `-n auto`. S8 coverage totals equal within rounding. S9 `-n auto` and `-n 4` CI timings and before/after duration recorded. S10 strictness decisions with follow-ups. S11 workflow contract test asserts `-n`. S12 output-path parameters with tests. S13 `PoshQC.Parallel.psm1` registered, exported, runner behavior. S14 worker default, cap, override tests. S15 JUnit merge. S16 merged coverage and completeness. S17 exit semantics and no partial overwrite. S18 VS Code Pester parallel task; `tasks.json` passes governed-JSON validation. S19 concurrent equals serial. S20 weights file and lookup with fallbacks. S21 CI shard spread before/after. S22 slow-file profile. S23 concurrent and shuffled Pester runs. S24 `_poshqc.yml` checks pass; green branch-head run recorded. S25 bundled copies and parity. S26 README. S27 brief in every copy. S28 no new Python script; no Python hook invocation. S29 Linux hook-suite job unchanged; non-required status recorded. S30 test file count explanation.

### user-story.md acceptance criteria (U1 to U14, in file order)

U1 locked dependency, no `psutil`. U2 CI step parallel with faster setting, `-n` not in `addopts`, serial task, threshold passes. U3 parallel pytest tasks exist. U4 reload leak fixed; order-independence runs. U5 before/after CI duration with both timings. U6 strictness decisions. U7 local command and task, new module, output paths, merges, same artifacts and exit semantics. U8 CI shards balanced from committed weights; before/after Pester wall-clock recorded. U9 slow-file profile. U10 concurrent and shuffled Pester runs. U11 bundled mirrors and parity. U12 brief in every copy. U13 workflow and PoshQC contract tests pass. U14 no new Python script.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S1 | Dependency, lock, lock-sync CI step, no `psutil` | PENDING CI | Local part verified: `pytest-xdist = "^3"` in dev dependencies; one `pytest-xdist` lock entry; `psutil` count 0 at merge base and `HEAD`; `poetry check --lock` exit 0. | `grep -c`; `poetry check --lock` | The lock-sync CI step result is part of A3 (P9-T5). Unchecked. |
| S2 | CI step uses faster setting; threshold step on merged coverage | PENDING CI | Step carries `-n auto` and every prior token (diff re-read). | `git diff -- .github/workflows/_quality-checks.yml` | A1 (P9-T1 to P9-T3). Unchecked. |
| S3 | `-n` absent from `addopts`; serial task remains | PASS | `addopts` has no `-n`, `--numprocesses`, `--dist`; `QC: 4 Pytest: run tests` present. | `grep addopts pyproject.toml`; JSONC parse | Already checked. |
| S4 | Parallel pytest tasks; governed-JSON validation | PARTIAL | Both tasks present with the planned arguments (JSONC parse, 55 tasks). `validate_json` cannot read `tasks.json`: it is outside `GOVERNED_GLOBS`, and an explicit call exits 1 at `HEAD` and at the merge base because the file is JSONC. | `node` JSONC parse; `poetry run python -m scripts.dev_tools.validate_json .vscode/tasks.json` | D1: AC wording defect, finding F1 (autonomous). Unchecked. |
| S5 | Reload leak fixed with regression test | PASS | `hard-lock-reload-fail-before`; no `importlib.reload` remains; test passes (re-run). | `pytest test_resolve_hard_lock_prompt.py` | Already checked. |
| S6 | Serial, `-n auto`, shuffled, reversed runs pass | PASS | `pytest-serial`, `pytest-xdist-runs`, `pytest-shuffled` (three seeds), `pytest-reversed`; `pytest-isolation-fixes`. | Evidence records | Already checked. |
| S7 | Porcelain clean after `-n auto` | PASS | `pytest-xdist-runs`. | Evidence record | Already checked. |
| S8 | Coverage totals equal within rounding | PASS | `pytest-coverage-equality`; LCOV re-read 96.6940 / 93.6378. | LCOV sums | Already checked. |
| S9 | CI timings and before/after duration | PENDING CI | Baseline in `ci-durations.2026-10-31T18-13.md`. | — | A1. Unchecked. |
| S10 | Strictness decisions and follow-ups | PASS | `pytest-strictness-probes`, `pytest-strictness-decisions`, `follow-ups`; three adopted options present in `pyproject.toml`. | `git diff -- pyproject.toml` | Already checked. |
| S11 | Workflow contract test asserts `-n` | PASS | Test file passes (re-run). | `pytest test_quality_checks_workflow_contracts.py` | Already checked. |
| S12 | Output-path parameters with tests | PASS | OP01-OP04; lines 338-339 executed. | JaCoCo | Already checked. |
| S13 | Module registered, exported, runner behavior | PASS | `PoshQC.psm1` sub-module list and `Export-ModuleMember`; `PoshQC.psd1` `FunctionsToExport`; PR01, PR02. | `git diff` | Already checked. |
| S14 | Worker default, cap, override tests | PASS | PM01-PM03, PR07. | Suite inspection | Already checked. |
| S15 | JUnit merge | PASS | PM04-PM07; function body reviewed. | Suite and code inspection | Already checked. |
| S16 | Merged coverage, completeness, merged file | PASS | PR02, PR05; `pester-concurrent-vs-serial` (merged file present, totals equal serial). | Evidence record | Already checked. |
| S17 | Exit semantics and no partial overwrite | PASS | PR03-PR06; `Invoke-PoshQCParallelMerge` writes only after every check. | Code inspection | Already checked. |
| S18 | VS Code Pester parallel task; governed-JSON validation | PARTIAL | `PoshQC: 4 test (Pester, parallel)` present and runs `Invoke-PoshQCParallelTest`; `PoshQC: 4 test (Pester)` present. Validation clause as in S4. | JSONC parse | D1, finding F1. Unchecked. |
| S19 | Concurrent equals serial | PASS | 13643 tests, 0 failures, 485 suites in both; exit codes 0. | Evidence record | Already checked. |
| S20 | Weights file, lookup, fallbacks, malformed | PASS | `shard-weights-generation` (CI run 41209645365); SW01-SW07; no absolute key (re-checked). | `grep` on weights file | Already checked. |
| S21 | CI shard spread smaller than baseline, or decision | PENDING CI | Projection in `shard-balance-projection`; measurement needs a branch-head run. | — | A2 (P9-T4). Unchecked. |
| S22 | Slow-file profile with follow-ups | PASS | `pester-slow-file-profile`; FU-3 to FU-7. | Evidence record | Already checked. |
| S23 | Concurrent and seeded shuffled Pester runs | PASS | `pester-concurrent-vs-serial`, `pester-shuffled` (seeds 1048, 20261031, 7), `pester-isolation-fixes`. | Evidence records | Already checked. |
| S24 | `_poshqc.yml` checks pass; green branch-head run | PENDING CI | `_poshqc.yml` unchanged on the branch. | `git diff --name-status` | A3 (P9-T5). Unchecked. |
| S25 | Bundled copies, parity path, tests pass | PASS | `cmp` identical for six pairs (re-run); two paths added to `POSHQC_PARITY_PATHS`; parity test passes (re-run). | `cmp`; pytest | Already checked. |
| S26 | README documents runner, parameters, root time, regeneration | PASS | README diff carries `Invoke-PoshQCParallelTest`, `-TestResultPath`, `-CoverageOutputPath`, root `time`, `Export-PoshQCShardWeight`. | `git diff -- scripts/powershell/PoshQC/README.md` | Already checked. |
| S27 | Brief in every copy; mirror contract tests pass | PASS | Six copies share SHA-256 `1fa5f0b0019e47f0...` (re-computed); `Parallel workers`, pytest bullet, Pester bullet, isolation bullet present; brief contract tests pass (re-run). | `sha256sum`; pytest | Already checked. |
| S28 | No new Python script; no Python hook invocation | PASS | No added `.py` file; no path under `.claude/hooks/` or `.codex/hooks/` changed. | `git diff --name-status --diff-filter=A` | Already checked. |
| S29 | Linux hook-suite job unchanged; non-required status recorded | PENDING CI | `_poshqc.yml` unchanged; the ruleset observation is a P9-T5 deliverable not yet recorded. | — | A3. Unchecked. |
| S30 | File count explanation | PASS | `pester-file-count.2026-10-31T19-53.md`. | Evidence record | Already checked. |
| U1 | Locked dependency, no `psutil` | PASS | As S1 local part (this criterion has no CI clause). | `grep -c`; `poetry check --lock` | Already checked. |
| U2 | CI step faster setting; threshold passes | PENDING CI | As S2. | — | A1. Unchecked. |
| U3 | Parallel pytest tasks exist | PASS | Both tasks present (this criterion has no validation clause). | JSONC parse | Already checked. |
| U4 | Leak fixed; order-independence runs | PASS | As S5 and S6. | — | Already checked. |
| U5 | Before/after CI duration with both timings | PENDING CI | As S9. | — | A1. Unchecked. |
| U6 | Strictness decisions | PASS | As S10. | — | Already checked. |
| U7 | Local command and task, merges, same artifacts and exit semantics | PASS | S13 to S19. | — | Already checked. |
| U8 | CI shards from committed weights; before/after Pester wall-clock | PENDING CI | Weights committed and read (S20); the before/after measurement is P9-T4. | — | A2. Unchecked. |
| U9 | Slow-file profile | PASS | As S22. | — | Already checked. |
| U10 | Concurrent and shuffled Pester runs | PASS | As S23. | — | Already checked. |
| U11 | Bundled mirrors and parity | PASS | As S25. | — | Already checked. |
| U12 | Brief in every copy | PASS | As S27. | — | Already checked. |
| U13 | Workflow and PoshQC contract tests pass | PASS | Workflow contract test passes (re-run); full Pester 0 failures. | — | Already checked. |
| U14 | No new Python script | PASS | As S28. | — | Already checked. |

---

## Summary

**Overall Feature Readiness:** NEEDS_WORK

**Criteria summary:**
- **PASS:** 33 criteria (22 in `spec.md`, 11 in `user-story.md`)
- **PARTIAL:** 2 criteria (S4, S18)
- **UNVERIFIED:** 9 criteria, all pending CI and owned by orchestrator step 9 (S1, S2, S9, S21, S24, S29, U2, U5, U8)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. F1 (autonomous): S4 and S18 require "governed-JSON validation" of `.vscode/tasks.json`. That validation does not exist for this JSONC file (`validate_json` governs only `scripts/`, `docs/`, and `examples/` and rejects `tasks.json` at the merge base as well). Verdict on deviation D1: an AC wording defect, not a genuine gap and not a policy hold. The tasks are delivered and parse as JSONC. Remedy: amend the clause in both criteria to the verifiable form, citing `evidence/other/validate-json-tasks.2026-10-31T18-16.md`, then check S4 and S18 off.
2. A1 to A3 (awaiting CI): the `-n auto` / `-n 4` timings and decision, the shard-spread comparison, and the green branch-head run with the ruleset observation (P9-T1 to P9-T5).

**Definition of Done note (outside the AC section):** the unchecked item "Behavior matches acceptance criteria in all documented environments" depends on the CI matrix and is part of A3.

**Recommended follow-up verification steps:**

1. Remediation cycle: amend S4 and S18 wording with the D1 evidence and check them off; optionally add the two `-Root` fallback runner cases (code review CR-2).
2. Orchestrator step 9: P9-T1 to P9-T5, then check off S1, S2, S9, S21, S24, S29, U2, U5, U8 and the Definition of Done item.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md`, `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/user-story.md`
- Total AC items: 44 (30 + 14)
- Checked off (delivered): 33 (22 + 11)
- Remaining (unchecked): 11 (8 + 3)
- Items remaining: S1 (dependency and lock-sync CI step), S2 (CI step faster setting and threshold), S4 (parallel pytest tasks and governed-JSON validation), S9 (CI timings), S18 (Pester parallel task and governed-JSON validation), S21 (CI shard spread), S24 (`_poshqc.yml` and green branch-head run), S29 (Linux hook-suite observation), U2 (CI step faster setting), U5 (before/after CI duration), U8 (balanced CI shards and before/after Pester wall-clock)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md` | 30 | 22 | 8 | 6 pending CI, 2 PARTIAL (F1) |
| `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/user-story.md` | 14 | 11 | 3 | all 3 pending CI |

No source-file checkbox change was made in this review: every criterion evaluated PASS was already checked, and every criterion not evaluated PASS was already unchecked.
