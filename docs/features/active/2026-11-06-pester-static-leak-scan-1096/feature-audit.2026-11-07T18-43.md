# Feature Audit: pester-static-leak-scan (#1096)

---

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-11-06-pester-static-leak-scan-1096`
**Base Branch:** `main`
**Head Branch:** `feature/pester-static-leak-scan-1096`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 2

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `c24cbd295ecec1fc759f52a42806ad991aa49478`)
- **Head branch/commit:** `feature/pester-static-leak-scan-1096` (commit `cb8ae3d5cc496bb1e0877aba0ae87661df00d066`)
- **Merge base:** `c24cbd295ecec1fc759f52a42806ad991aa49478`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-07 18:35:58 UTC at head `cb8ae3d5c`, current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, CI run `42400459749`, and reviewer probes at head
- **Feature folder used:** `docs/features/active/2026-11-06-pester-static-leak-scan-1096`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** The audit scope is the full diff against the merge base. Under the owner directive, test gates are one parallel run each, re-run only after a fix, so this review re-ran no suite and read the cycle 2 restart gate artifacts, which postdate the last merge `885c52b2f`. No commit after that merge changes a path outside the feature folder.

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
| 1 | Detects each kind; restores not reported | PASS | `LS-K` 38 and `LS-R` 31 passed in `pester-parallel.2026-11-07T18-26.md`; first-review probes P01 to P28 | Pester gate; `LeakScan.psm1` blob unchanged since cycle 1 | |
| 2 | Unpaired, other-name, literal reported; strings and Mock not | PASS | `LS-R03`, `LS-K02` passed in the restart gate | Pester gate | |
| 3 | File, line, kind; helpers covered | PASS | Finding records carry path, line, kind, name; real scan covers 568 files at head | `Invoke-PoshQCLeakScan -Root <worktree>` | |
| 4 | In-memory seam, no temp files | PASS | Scan suites use `-ReadText`, `-ReadAllowlist`, `-EnumerateFiles`; no temp-file API in added test lines | Diff read | |
| 5 | Throws on four failure classes | PASS | `LI-` 14 passed in the restart gate | Pester gate | |
| 6 | Allowlist validation conditions | PASS | `LA-` 21 passed | Pester gate | |
| 7 | Default folder behavior | PASS | `LI-` rows passed; module unchanged in cycle 2 | Pester gate | |
| 8 | CI step placement and invariants | PASS | `WF06-LEAK-SCAN-STEP` passed; `ci.yml` not in diff; `poshqc-linux-hooks` job text equal to the merge base | Diff of `_poshqc.yml`; `scope-check.2026-11-07T18-32.md` | |
| 9 | Every finding fixed or allowlisted | PASS | Reviewer scan at head: 568 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures; both allowlist entries carry a reason; raw first-scan findings in `evidence/baseline/leak-scan-raw.2026-11-07T14-35.md` | `Invoke-PoshQCLeakScan -Root <worktree>` | |
| 10 | Helper not global; loads moved | PASS | Files unchanged since cycle 1 (blob ids equal) | `git rev-parse` | |
| 11 | Batch-budget suites restore snapshots | PASS | Files unchanged since cycle 1; scan reports no unallowlisted `env` finding | Scan | |
| 12 | Decision 3 tests independent of process directory | PASS | Three titles passed in `pester-parallel.2026-11-07T18-26.md` | JUnit titles | |
| 13 | Enter-DrmCopilotShell seam and default cases | PASS | Unchanged since cycle 1 | `git rev-parse` | |
| 14 | No `Set-Variable -Scope 1` | PASS | Unchanged since cycle 1 | `git rev-parse` | |
| 15 | Bundle copies, parity, exports, README | PASS | Blob ids equal to bundle copies; `test_poshqc_bundled_module_files_match_repo_root_sources` passed in the restart pytest gate | pytest gate | |
| 16 | New modules meet line threshold | PASS | 98.22% and 95.56% in `artifacts/pester/powershell-coverage.xml` written 18:26 UTC | Reviewer parse | |
| 17 | `-n auto` on four commands; no `-n` in addopts | PASS | Production files unchanged since cycle 1; `pyproject.toml` not in diff | `git rev-parse`; scope check | |
| 18 | Prompt text and literal; scoped run unchanged | PASS | Unchanged since cycle 1; `test_run_scoped_runs_all_tools_on_changed_files` in the passing pytest gate | pytest gate | |
| 19 | Stale `--cov` flag removed | PASS | Unchanged since cycle 1 review, which found no `src/lexile_corpus_tuner` in executor production files | `git rev-parse` | |
| 20 | `fix_all` leak step and parallel test | PASS | `test_fix_all*.py` passed in the restart pytest gate | pytest gate | |
| 21 | Aggregates on parallel tasks | PASS | `VT-` 6 passed | Pester gate | |
| 22 | `dependsOn` names resolve | PASS | `VT-DEPENDS-ON-RESOLVES` passed | Pester gate | |
| 23 | Default test task; serial tasks kept; scan task | PASS | `VT-` rows passed | Pester gate | |
| 24 | Test Isolation bullet appended; copies match | PASS | Six copies share blob id `452229bc0`; scan bullet last in the section; `test_brief_copies_are_byte_identical` and `test_brief_test_isolation_states_parallel_gates` passed | `git rev-parse`; pytest gate | |
| 25 | Four brief passages; three tests pass | PASS | `test_brief_passages_state_parallel_gate_facts` and `test_brief_ci_section_names_jobs_and_required_contexts` passed in the restart gate; `test_brief_copies_carry_no_removed_run_tokens` in the same passing run | pytest gate | |
| 26 | Entry 0001 file list, Revert Blocks, patch statement | PASS | `Test-ProcessReductionLedger` valid; 26 blocks in entry 0001; both sides of the merge kept | Reviewer ledger run | |
| 27 | Merge commit and revert signal | PASS | One `Merge commit: 278bb7047...` line; `Before #1096 lands` occurs 0 times; no branch-added entry file | Ledger read; `git diff --name-status` | |
| 28 | Fences occur once | PASS | Reviewer replay at head: 177 of 177 OK, entry 0001 26 of 26; recorded `ledger-fence-replay.2026-11-07T17-51.md` | `Invoke-ProcessReductionRevert` | |
| 29 | Separate reduction commit | PASS | Each of `45e2f0f09`, `07c392826`, `1faa5f00f` adds 0 scan-text lines outside the entry and evidence folder; no cycle 2 commit carries the token | `scope-check.2026-11-07T18-32.md`; `git log` | |
| 30 | No added `.py`; exclusions untouched | PASS | 0 added `.py`; no excluded path in `git diff --name-status c24cbd295..HEAD` | `git diff` | |
| 31 | Both parallel gates pass | PASS | Pester ExitCode 0, 15994 tests, 0 failures; pytest 16213 passed, 6 skipped, 0 failures | Gate records; JUnit root counters | |
| 32 | Jest passes | PASS | 330 suites, 5345 tests, 0 failed | `jest.2026-11-07T18-30.md` | |
| 33 | No single-process or focused run cited | PASS | `scope-check.2026-11-07T18-32.md` evidence scan over 105 files | Evidence read | |
| 34 | Baseline recorded before changes | PASS | `0ccab94a5` (baseline record, 09:21 local) precedes `dc3d8440b` (first change outside `docs/features/`, 09:29 local) | `git log` | |
| 35 | No new failure; no coverage drop | PASS | `coverage-thresholds.2026-11-07T18-31.md`: `NEW-FAILURE: NONE`, every delta PASS or NEW; reviewer per-file parse matches | Coverage parse | |
| 36 | CI-dependent: scan step on PR head | PENDING-CI | Run `42400459749` on PR head `885c52b2f` ran the step to success with 0 failures. The run on the current head `cb8ae3d5c` skips the static job under change scope | `gh run view` | Owned by S9 |
| 37 | CI-dependent: `CI Required Gate` on final head | PENDING-CI | `CI Required Gate` succeeded on `885c52b2f`; run `42401971146` on `cb8ae3d5c` was queued at review time | `gh run list --branch` | Owned by S9 |

---

## Summary

- **Total criteria:** 37 per file
- **PASS:** 35
- **PARTIAL:** 0
- **FAIL:** 0
- **UNVERIFIED:** 0
- **PENDING-CI:** 2

Cycle 2 input MC-2 is closed, and PA-1 of the cycle 1 re-audit is closed by the green run on `885c52b2f` (see `policy-audit.2026-11-07T18-43.md` Section 3C).

**Top gaps preventing PASS:**

1. None blocking. Criteria 36 and 37 await the S9 CI green gate on the final PR head.

**Recommended follow-up verification steps:**

1. At S9, confirm `CI Required Gate` succeeds on the final PR head.
2. Check off criterion 36 from run `42400459749`, because the final-head run skips the static job, and check off criterion 37 from the final-head run.

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
