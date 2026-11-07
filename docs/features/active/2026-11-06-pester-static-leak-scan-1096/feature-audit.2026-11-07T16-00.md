# Feature Audit: pester-static-leak-scan (#1096)

---

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-06-pester-static-leak-scan-1096`
**Base Branch:** `main`
**Head Branch:** `feature/pester-static-leak-scan-1096`
**Work Mode:** `full-feature`
**Audit Type:** First full review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main`; merge base `278bb7047db986bbb0a8652ca323656ce85f8a08`)
- **Head branch/commit:** `feature/pester-static-leak-scan-1096` (commit `c8e2152088bb5c27cbeb8718b5e04c8f1ff9df9c`)
- **Merge base:** `278bb7047db986bbb0a8652ca323656ce85f8a08`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-07 15:49:57 UTC at head `c8e215208`, current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, and reviewer probes at head
- **Feature folder used:** `docs/features/active/2026-11-06-pester-static-leak-scan-1096`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** The audit scope is the full diff against the merge base. Under the owner directive, test gates are one parallel run each, re-run only after a fix, so this review re-ran no suite and read the gate artifacts, which postdate the last code commit.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-06-pester-static-leak-scan-1096/spec.md` — primary
- `docs/features/active/2026-11-06-pester-static-leak-scan-1096/user-story.md` — secondary; the same 37 criteria in the same order

### Acceptance criteria

Locally verifiable (1 to 35) and CI-dependent (36 and 37), numbered in source order:

1. The scan detects each listed state-change kind and does not report a change restored in the same scope or in `AfterEach`, `AfterAll`, or `finally`.
2. The scan reports a change with no restore, a restore of a different name, and a later literal assignment, and does not report text inside strings or `Mock`-named commands.
3. Each finding names the file, line, and kind, and the scan covers `.ps1` helpers under `tests/`.
4. The scan tests supply content through a seam as in-memory text and create no temporary files.
5. `Invoke-PoshQCLeakScan` throws on an unallowlisted finding, a parse error, an invalid allowlist, and a stale entry.
6. Allowlist validation rejects each condition in `Contracts and validation rules`.
7. Default folders: no folder under `tests/` is not an error, and the `Get-PoshQCScanConfigFolder` throw reaches the caller.
8. `poshqc-static` holds the scan step after `Analyze PowerShell` with no `continue-on-error` and no `if`, `PoshQcWorkflow.Tests.ps1` asserts it, no CI job or context is added, and `poshqc-linux-hooks` is unchanged.
9. Every finding in `tests/scripts` is fixed or allowlisted with a reason, and the first scan's raw findings are kept under `evidence/baseline/`.
10. `TestHelpers.ps1` defines no global function, `run-actionlint.Tests.ps1` no longer removes `Import-ScriptFunction`, and `tree.Tests.ps1` loads the helper in `BeforeAll`.
11. The three batch-budget suites restore a snapshot of each environment value they set.
12. The Decision 3 tests no longer depend on the process directory.
13. `Enter-DrmCopilotShell.Tests.ps1` holds no `Push-Location` and no `[Environment]::CurrentDirectory`, covers both functions through the seam, and keeps a default-path case for each.
14. `PoshQC.TestingInvokeConfigPaths.Tests.ps1` holds no `Set-Variable -Scope 1`.
15. Each new PoshQC module has a bundle copy and a `POSHQC_PARITY_PATHS` entry, appears in both export lists in each copy, is in the README, and the parity tests pass.
16. Each new PoshQC module meets the line-coverage threshold in the merged coverage file.
17. `run_python_branch`, `run_preflight_qc_with_capture`, `QCRunner.FULL_TEST`, and `full_test` pass `-n auto`, and `addopts` carries no `-n`.
18. The two prompt texts and `PYTHON_TOOLCHAIN_COMMANDS["pytest"]` state `-n auto`, and `_run_pytest_scoped_with_expectations` is unchanged.
19. `--cov=src/lexile_corpus_tuner` appears in none of the edited commands or text.
20. `fix_all_branches.py` runs `PoshQC: leak scan` between analyze and test, `PoshQC: test` runs `Invoke-PoshQCParallelTest` and fails on a non-zero `ExitCode`, and the `test_fix_all*.py` tests pass.
21. Both aggregate tasks depend on `PoshQC: 4 test (Pester, parallel)` and on no serial test task, asserted by `VT-` cases.
22. Every `dependsOn` name resolves to a task label, asserted by a comment-tolerant `VT-` case.
23. `QC: 4 Pytest: run tests (parallel)` is the `test` default, the serial tasks remain, and `PoshQC: 2c leak scan` exists.
24. `## Test Isolation Checks` names the scan in an appended bullet, existing bullets unchanged, all copies match.
25. The four other brief passages carry the spec changes in every copy, and the three named contract tests pass.
26. Entry 0001 records the serial-command paths, the amended opening sentence, a Revert Block per file, and the `## Stored Patch` statement.
27. Entry 0001 reads the back-filled merge commit, no longer holds `Before #1096 lands`, and no new entry exists.
28. Each `Current` fence of entry 0001 occurs exactly once in its target, shown by a recorded replay.
29. The serial-command edits and the entry update are in a separate `reduction: 0001` commit with no leak-scan change.
30. The diff adds no `.py` file and touches none of the excluded paths.
31. `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.
32. Jest passes with zero failures through `node run-jest.cjs`.
33. Validation evidence cites no single-process, seeded-shuffle, reversed-order, or focused run.
34. Baseline runs of both gates are recorded before any change outside `docs/features/`.
35. Against that record, no new failure and no coverage drop on a measured changed production file.
36. CI-dependent: the scan step ran in `poshqc / PowerShell QC static` on the PR head and passed.
37. CI-dependent: `CI Required Gate` reports success on the final PR head, which also serves as the green run for the modified workflow.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Detects each kind; restores not reported | PASS | `LS-K01`, `LS-R01`, `LS-R02` passed (`LS-K` 38, `LS-R` 31); reviewer probes P01 to P28 matched the spec table and rules | `Get-PoshQCLeakFinding` probes; `pester-parallel.2026-11-07T15-43.md` | Probes covered all five kinds and R1 to R5 |
| 2 | Unpaired, other-name, literal reported; strings and Mock not | PASS | Probes P01, P05, P03 reported; P14, P15 not reported; `LS-R03`, `LS-K02` | Reviewer probes | |
| 3 | File, line, kind; helpers covered | PASS | Finding records carry `Path`, `Line`, `Kind`, `Name`; enumerator takes every `*.ps1`; `LS-R05` | Source read; `LS-R05` | Real scan covers 548 files |
| 4 | In-memory seam, no temp files | PASS | `-ReadText`, `-ReadAllowlist`, `-EnumerateFiles` seams; diff scan found no temp-file API in added test lines | Diff grep | |
| 5 | Throws on four failure classes | PASS | `LI-` 13 passed | `pester-parallel.2026-11-07T15-43.md` | |
| 6 | Allowlist validation conditions | PASS | `LA-` 21 passed; source checks each listed condition | Source read | |
| 7 | Default folder behavior | PASS | `Resolve-PoshQCLeakScanFolder` lets the config throw stand; `LI-` rows | Source read | |
| 8 | CI step placement and invariants | PASS | `_poshqc.yml` diff adds one step; `WF06-LEAK-SCAN-STEP` passed; `LINUX-HOOKS-JOB-UNCHANGED=True` | `scope-check.2026-11-07T15-47.md`; diff | |
| 9 | Every finding fixed or allowlisted | PASS | Reviewer scan at head: 548 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures; raw findings at `evidence/baseline/leak-scan-raw.2026-11-07T14-35.md` | `Invoke-PoshQCLeakScan -Root <worktree>` | |
| 10 | Helper not global; loads moved | PASS | Diff of the three files | `git diff` | All callers verified by grep |
| 11 | Batch-budget suites restore snapshots | PASS | Diffs of the three suites; scan reports no unallowlisted `env` finding in them | `git diff`; scan | |
| 12 | Decision 3 tests independent of process directory | PASS | Titles kept; no `CurrentDirectory` or `SetCurrentDirectory`; omitted-root body reads `(Get-Location)`; all three passed | Diff; JUnit titles in `pester-parallel.2026-11-07T15-43.md` | Proof by construction per Decision 3 |
| 13 | Enter-DrmCopilotShell seam and default cases | PASS | Diff shows seam cases and two default-path cases | `git diff` | |
| 14 | No `Set-Variable -Scope 1` | PASS | Diff replaces all captures with holder hashtables | `git diff` | |
| 15 | Bundle copies, parity, exports, README | PASS | Shared blob ids; `POSHQC_PARITY_PATHS` lists both; both export lists; README line; parity test passed | `git ls-files -s`; pytest JUnit | |
| 16 | New modules meet line threshold | PASS | 98.22% and 95.40% in `artifacts/pester/powershell-coverage.xml` | Reviewer parse of the JaCoCo file | |
| 17 | `-n auto` on four commands; no `-n` in addopts | PASS | Diffs; `ADDOPTS` line in scope gate | `git diff`; `scope-check.2026-11-07T15-47.md` | |
| 18 | Prompt text and literal; scoped run unchanged | PASS | Diffs; `test_run_scoped_runs_all_tools_on_changed_files` passed | pytest JUnit | |
| 19 | Stale `--cov` flag removed | PASS | Diffs of the six files and `tasks.json` | `git diff` | Effect on `FULL_TEST` noted in code review |
| 20 | `fix_all` leak step and parallel test | PASS | `fix_all_branches.py` diff; `test_fix_all*.py` passed | `git diff`; pytest gate | |
| 21 | Aggregates on parallel tasks | PASS | `tasks.json` diff; `VT-AGGREGATES-PARALLEL-ONLY` passed | Pester gate | |
| 22 | `dependsOn` names resolve | PASS | Label corrections in diff; `VT-DEPENDS-ON-RESOLVES` passed | Pester gate | |
| 23 | Default test task; serial tasks kept; scan task | PASS | `VT-DEFAULT-TEST-TASK`, `VT-SERIAL-TASKS-REMAIN`, `VT-LEAK-SCAN-TASK` passed | Pester gate | |
| 24 | Test Isolation bullet appended; copies match | PASS | Six copies share blob `e43b9af24`; named tests passed | `git ls-files -s`; pytest gate | |
| 25 | Four brief passages; three tests pass | PASS | Commits `16fd2f126`, `45e2f0f09`; tests passed in the pytest gate | pytest gate | |
| 26 | Entry 0001 file list, Revert Blocks, patch statement | PASS | 27 Revert Blocks in `## Prior Text`; `## Revert Steps` states the patch excludes the #1096 blocks | Ledger read | |
| 27 | Merge commit and revert signal | PASS | `Merge commit: 278bb7047...`; `Before #1096` absent; no new entry file | Ledger read; scope gate | |
| 28 | Fences occur once | PASS | Reviewer replay at head: 27 of 27 OK; recorded `ledger-fence-replay.2026-11-07T15-26.md` | `Invoke-ProcessReductionRevert` | |
| 29 | Separate reduction commit | PASS | `45e2f0f09` holds no leak-scan module, allowlist, or CI step | `git show --stat` | |
| 30 | No added `.py`; exclusions untouched | PASS | `git diff --diff-filter=A -- '*.py'` empty; exclusion grep empty | `git diff --name-only` | |
| 31 | Both parallel gates pass | PASS | Pester ExitCode 0, 14825 tests, 0 failures; pytest 16152 passed, 0 failures | Gate records; JUnit root counters | |
| 32 | Jest passes | PASS | 328 suites, 5289 tests, 0 failed | `jest.2026-11-07T15-47.md` | |
| 33 | No single-process or focused run cited | PASS | Scope gate token scan; evidence read | `scope-check.2026-11-07T15-47.md` | |
| 34 | Baseline recorded before changes | PASS | `0ccab94a5` adds the baseline records before `dc3d8440b`, the first commit outside `docs/features/` | `git log` | |
| 35 | No new failure; no coverage drop | PASS | `coverage-thresholds.2026-11-07T15-47.md` `NEW-FAILURE: NONE`, every delta PASS or NEW; reviewer re-read the per-file figures | Coverage parse | |
| 36 | CI-dependent: scan step on PR head | PENDING-CI | No run and no PR exist for the branch | `gh run list --branch` | Owned by S9 |
| 37 | CI-dependent: `CI Required Gate` on final head | PENDING-CI | No run exists; also blocks as PA-1 under `modified-workflow-needs-green-run` | `gh run list --branch` | Owned by S9 |

---

## Summary

- **Total criteria:** 37 per file
- **PASS:** 35
- **PARTIAL:** 0
- **FAIL:** 0
- **UNVERIFIED:** 0
- **PENDING-CI:** 2

**Top gaps preventing PASS:**

1. No CI run exists for the branch head. The modified workflow `_poshqc.yml` needs a green run (PA-1, `awaiting_ci`), and criteria 36 and 37 need CI on the PR head.

**Recommended follow-up verification steps:**

1. Run `ci.yml` against the branch head, by `workflow_dispatch` or through the PR, and confirm the step `Scan Pester tests for leaked state` and `CI Required Gate` succeed.
2. Bring the branch up to date with `origin/main` before the PR; a trial merge shows no conflict.
3. Check off criteria 36 and 37 at S9.

---

## Acceptance Criteria Check-off

Criteria 1 to 35 were already checked in `spec.md` and `user-story.md`, and this audit confirms each as PASS. No checkbox changed in this review. Criteria 36 and 37 are pending CI and stay unchecked.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-06-pester-static-leak-scan-1096/spec.md`, `docs/features/active/2026-11-06-pester-static-leak-scan-1096/user-story.md`
- Total AC items: 37 per file
- Checked off (delivered): 35 per file
- Remaining (unchecked): 2 per file
- Items remaining: criterion 36 (scan step on the PR head) and criterion 37 (`CI Required Gate` on the final PR head)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 37 | 35 | 2 | Checkbox-backed |
| `user-story.md` | 37 | 35 | 2 | Checkbox-backed |
