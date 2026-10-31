# Policy Compliance Audit: pytest-xdist and concurrent Pester test cycle (Issue #1048), re-audit R4

---

**Audit Date:** 2026-10-31
**Code Under Test:**
- PowerShell production: `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` (new), `PoshQC.Shard.psm1`, `PoshQC.Testing.psm1`, `PoshQC.psm1`, `PoshQC.psd1`, and their bundled copies under `extensions/drm-copilot/resources/powershell/PoshQC/` (unchanged by remediation cycle 1)
- PowerShell tests: `tests/scripts/powershell/PoshQC/PoshQC.ParallelMerge.Tests.ps1`, `PoshQC.ParallelRunner.Tests.ps1` (two cases PR10 and PR11 added in cycle 1), `PoshQC.ShardWeights.Tests.ps1`, `PoshQC.TestingOutputPath.Tests.ps1`
- Python tests (modified earlier): `test_quality_checks_workflow_contracts.py`, `test_resolve_hard_lock_prompt.py`, `test_execution_environment_brief_contracts.py`, `test_poshqc_bundled_parity.py`
- Configuration: `pyproject.toml`, `poetry.lock`, `.github/workflows/_quality-checks.yml`, `config/poshqc-shard-weights.json`, `.vscode/tasks.json` (JSONC)
- Feature folder documents: `spec.md` (two criteria reworded and checked in cycle 1) and evidence

Scope: full branch diff `58b81ca577943cd2944b62ee23ff3a3d1d737092..522abaadee33779de6b687335bbd4f64f93033f8` (base `main`, resolved with the pr-base-branch-merge-base procedure; the merge base equals the prior review's merge base and the branch is current with `main`). Cycle-1 delta verified by command: `git diff 522abaade~1..522abaade --name-status` lists 23 added files and 2 modified files. The two modified files are `spec.md` and `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1`. The added files are the prior review set, the remediation plan, and evidence under `evidence/`. No file under `scripts/`, `extensions/`, `.github/`, `.claude/`, `.codex/`, `config/`, or `.vscode/` is in the delta, so no production file and no bundle file changed.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 5 production modules (plus 5 bundled copies), 4 new test files | 13643 tests at the last full run plus PoshQC folder run of 229 tests with 2 new cases | 0 failures, 0 errors | `PoshQC.Testing.psm1` 93.60% lines; `PoshQC.Shard.psm1` 100% lines | `PoshQC.Parallel.psm1` 97.33% (146/150); `PoshQC.Testing.psm1` 93.66%; `PoshQC.Shard.psm1` 100%; repo-wide 93.57% at the last full run | `PoshQC.Parallel.psm1` 97.33% (146/150), up from 96.00% |
| Python | 4 test files, `pyproject.toml`, `poetry.lock`; no production Python | 15875 passed, 6 skipped (`-n auto`) | 0 failures | 96.6940% lines, 93.6298% branches (serial) | 96.6940% lines, 93.6378% branches | No production Python changed; repo-wide figures above the 85% / 75% floors |
| JSON | `config/poshqc-shard-weights.json`, `.vscode/tasks.json` | N/A | weights parsed by SW suites; `tasks.json` JSONC parse succeeds (55 tasks) | N/A (config files) | N/A (config files) | N/A |
| YAML (workflow) | `.github/workflows/_quality-checks.yml` | `test_quality_checks_workflow_contracts.py` | passes; branch-head CI run pending | N/A | N/A | N/A |

Languages with zero changed files on the branch: TypeScript, C#, Bash. Coverage verdicts for those languages are N/A.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- TypeScript post-change coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/evidence/baseline/pester-serial.2026-10-31T18-13.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, report name 2026-10-31 21:14:45, written after PR10 and PR11 were authored), plus the full-run summary `evidence/qa-gates/pester-coverage.2026-10-31T20-39.md`
- Python baseline coverage artifact: `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/evidence/baseline/pytest-serial.2026-10-31T17-47.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info`, summarized in `evidence/qa-gates/pytest-coverage.2026-10-31T19-58.md`; cycle 1 changed no Python file
- Per-language comparison summary: Section 1.2.1 below

The JaCoCo file on disk was written by the scoped PoshQC-folder run of cycle 1, so its report-wide LINE counter (860 covered, 21838 missed) is not a repo-wide figure and is not used as one. Its per-file counters are valid. Re-read in this review: `PoshQC.Parallel.psm1` `LINE missed="4" covered="146"` with missed lines 263, 264, 266, 267 (the `Invoke-PoshQCPwshExe` body); lines 408 and 411 now read `ci="1"`. The repo-wide PowerShell figure comes from the last full run, 21115 of 22566 lines (93.57%). Cycle 1 added two covered lines to the numerator and changed no production line, so the repo-wide figure cannot have fallen; it is derived as at least 93.58% (21117/22566 if the two newly covered lines are counted once), well above the 85% line threshold. Assumption recorded: no full Pester rerun was performed in this review, because the worktree isolation guard refuses `pwsh` launches and a full run takes about 16 minutes.

---

## Executive Summary

Remediation cycle 1 is verified by command. The delta touches no production or bundle file. Finding F1 is resolved: the two reworded `.vscode/tasks.json` criteria (S4, S18) are verifiable and checked. Code-review item CR-2 is resolved: PR10 and PR11 exist, use only existing seams, and raise `PoshQC.Parallel.psm1` line coverage from 96.00% to 97.33%. No CI-dependent criterion was checked off.

No new defect was found. The former awaiting-CI items A1 to A3 are classified Pending-S9 (non-blocking, owned by orchestrator step 9) in the feature audit because they need a pull request and a CI run that cannot exist before the PR is opened. They are not written as blocking findings in this review.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` classifies `scripts/powershell/PoshQC` as T3; no property-test or mutation obligation applies)
- PENDING `.claude/rules/ci-workflows.md` (`modified-workflow-needs-green-run`: pending S9, tracked as Pending-S9 item 3)

**Language-specific policies evaluated:**
- PASS Python (test-only changes)
- PASS PowerShell
- N/A Bash: no shell file changed
- PASS JSON: weights file verified; `tasks.json` parses as JSONC with all five labels (this review)

**Temporary artifacts cleanup:**
- PASS All temporary scripts were kept outside the repository (executor helpers are cited as `SCRATCH/issue-1048-*`; the branch diff contains none)
- PASS No tooling script was added
- Scripts created during development: `SCRATCH/issue-1048-*`, outside the worktree; none committed.

---

## Rejected Scope Narrowing

The caller prompt does not narrow the audit to a plan, phase, file subset, or language, and it asks for no toolchain or coverage check to be skipped. It does direct that three CI-dependent items be classified as Pending-S9 rather than blocking. That is a classification of verification timing, not a scope narrowing: the audit still covers the full branch diff against `main`, and the classification is stated explicitly in the feature audit. No scope narrowing was detected.

---

## Evidence Location Compliance

`git diff --name-status 522abaade~1..522abaade` shows every added evidence file under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`. No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` is in the cycle delta. The earlier full-branch scan (`validate_evidence_locations --root .`) exited 0 and the cycle added no path that could change that result. Result: PASS, no violations.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Seeded shuffled file-order runs (seeds 7, 1048, 20261031) over the PoshQC folder plus `PoshQcWorkflow.Tests.ps1`: 237 passed, 0 failed each (`evidence/regression-testing/pester-shuffle.2026-10-31T21-31.md`). PR10 and PR11 restore the process location in `finally`. |
| **Isolation** | PASS | PR10 and PR11 each assert one behavior (omitted root, relative root). |
| **Fast Execution** | PASS | New cases start no process; searched the file for `Start-Process`, `Start-Sleep`, `TestDrive`, `New-TemporaryFile`, `GetTempPath`: zero matches. |
| **Determinism** | PASS | Expected roots are computed from `Get-Location` inside the same `Push-Location` block that the code under test reads; no clock, RNG, or environment write. |
| **Readability & Maintainability** | PASS | Case ids in `It` names; Arrange, Act, Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | PowerShell `PoshQC.Parallel.psm1` 96.00% at the prior review; Testing 93.60%, Shard 100% (`evidence/baseline/pester-serial.2026-10-31T18-13.md`); Python 96.6940% lines and 93.6298% branches (`evidence/baseline/pytest-serial.2026-10-31T17-47.md`). |
| **No Coverage Regression** | PASS | `PoshQC.Parallel.psm1` 96.00% to 97.33% (+1.33); Testing and Shard unchanged; no production line changed in cycle 1. |
| **New Code Coverage** | PASS | `PoshQC.Parallel.psm1` is a new file at 97.33% (146/150) against the 85% line threshold (root `CLAUDE.md` states none, so defaults govern). No branch threshold applies to PowerShell. The four unexecuted lines are the `Invoke-PoshQCPwshExe` body (deviation D2); no coverage exclusion was added. |
| **Comprehensive Coverage** | PASS | PR10 and PR11 close the CR-2 gap (lines 408 and 411 now executed). |
| **Positive Flows** | PASS | PM04, PM05, PR02, SW01, OP01. |
| **Negative Flows** | PASS | PM08, SW04, PR07. |
| **Edge Cases** | PASS | PM02, PM03, PM07, SW02, SW03, PR10, PR11. |
| **Error Handling** | PASS | PR03 to PR06. |
| **Concurrency** | PASS | PR01; the 8-worker local run matched serial totals. |
| **State Transitions** | N/A | Covered by PR01 to PR08. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: `PoshQC.Parallel.psm1` 96.00% lines at the prior review (new file); `PoshQC.Testing.psm1` 93.60%; `PoshQC.Shard.psm1` 100% -> Post-change: `PoshQC.Parallel.psm1` 97.33%; Testing 93.66%; Shard 100%. Change: +1.33 percentage points on the Parallel module. Repo-wide: 93.57% at the last full run, not lower after cycle 1 (see assumption above). New/changed-code coverage: 97.33%. Branch coverage: not applicable to PowerShell (Pester measures none). Disposition: PASS. Evidence: `evidence/qa-gates/pester-poshqc.2026-10-31T21-31.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 96.6940% lines, 93.6298% branches -> Post-change: 96.6940% lines, 93.6378% branches. Change: +0.0000 and +0.0080 percentage points. New/changed-code coverage: 100% (no production Python line changed; the changed files are tests). Cycle 1 changed no Python file, so the prior verified artifacts stand. Disposition: PASS. Evidence: `evidence/baseline/pytest-serial.2026-10-31T17-47.md`, `evidence/qa-gates/pytest-coverage.2026-10-31T19-58.md`, `artifacts/python/lcov.info`.
- TypeScript, C#, Bash: zero changed files on the branch. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | PR10 uses `-Because 'the shard directories live under the current location'`. |
| **Arrange-Act-Assert Pattern** | PASS | Both new cases carry the three sections. |
| **Document Intent** | PASS | Case ids state the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, process, or temp file. `Push-Location -LiteralPath $PSScriptRoot` changes the in-process location only and is restored in `finally`. |
| **Use Mocks/Stubs** | PASS | Only the existing `NewState` and `NewSeams` helpers; the `Root` seam key is removed for PR10 and set to a relative path for PR11. No new seam was introduced. |
| **Environment Stability** | PASS | No environment variable written. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit; executor self-review `evidence/qa-gates/self-review.2026-10-31T21-31.md`, re-verified by command rather than relied on. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #1048; `spec.md`; `user-story.md`; `owner-decisions.md`. |
| **Read existing change plans** | PASS | `plan.2026-10-31T13-02.md` and `plan.remediation-cycle-1.2026-10-31T21-30.md`. |
| **Document the plan** | PASS | Phase 9 remains owned by orchestrator step 9. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Cycle 1 added two test cases and two wording changes. |
| **Reusability** | PASS | The new cases reuse `NewState` and `NewSeams`. |
| **Extensibility** | PASS | No API changed. |
| **Separation of concerns** | PASS | No production change. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **At or below the 800-line hard limit** | PASS | `PoshQC.ParallelRunner.Tests.ps1` is 302 logical lines (awk `NR`, re-measured). Other changed covered files measured at the prior review (largest 491) were not touched by cycle 1. No covered file is at or above 700 lines. `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | PASS | No export change. |
| **No circular dependencies** | PASS | No production change. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `PR10-OMITTED-ROOT-USES-CURRENT-LOCATION`, `PR11-RELATIVE-ROOT-RESOLVES-AGAINST-CURRENT-LOCATION`. |
| **Docs/docstrings** | PASS | Unchanged. |
| **Comment why, not what** | PASS | Unchanged. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `evidence/qa-gates/poshqc-format.2026-10-31T21-31.md`. |
| **2. Linting** | PASS | `evidence/qa-gates/pssa.2026-10-31T21-31.md`. |
| **3. Type checking** | N/A | PowerShell has no type-check stage; no Python file changed in cycle 1. |
| **4. Testing** | PASS | PoshQC folder run: 229 tests, 0 failures, 0 errors (`pester-poshqc.2026-10-31T21-31.md`); single-process run (`pester-single-process.2026-10-31T21-31.md`). |
| **Full toolchain loop** | PASS | Cycle-1 gate records carry timestamp 21-31 for format, lint, tests, shuffle, and file size. |
| **Explicit reporting** | PASS | Each gate has an evidence file with `Command:` and `EXIT_CODE:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `522abaade` message states the two test cases and the two criteria corrections. |
| **Design choices explained** | PASS | `evidence/other/spec-ac-jsonc-amendment.2026-10-31T21-19.md`; deviation D1. |
| **Update supporting documents** | PASS | `spec.md` reworded. |
| **Provide next steps** | PASS | Pending-S9 items listed in the feature audit. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black / Ruff / Pyright** | PASS | Cycle 1 changed no Python file; prior records stand. |
| **No new Python script** | PASS | No added `.py` file in the cycle-1 delta. |
| **Dependencies** | PASS | `pyproject.toml` and `poetry.lock` are not in the cycle-1 delta. |
| **`addopts` constraint** | PASS | `pyproject.toml` unchanged in cycle 1. |

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | `poshqc-format.2026-10-31T21-31.md`. |
| **Linting with PSScriptAnalyzer** | PASS | `pssa.2026-10-31T21-31.md`. |
| **Wrapper seam for external executables** | PASS | No `Start-Process` in the test file; the wrapper is mocked through the existing seams. |
| **Running the toolchain** | PASS | See Section 2.5. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **`config/poshqc-shard-weights.json`** | PASS | Unchanged in cycle 1. |
| **`.vscode/tasks.json` (former D1)** | PASS | Re-run in this review: JSONC parse (full-line comments removed, then `JSON.parse`) succeeds with 55 tasks. Present labels: `QC: 4 Pytest: run tests`, `QC: 4 Pytest: run tests (parallel)`, `QC: 4 Pytest: run tests with coverage (parallel)`, `PoshQC: 4 test (Pester)`, `PoshQC: 4 test (Pester, parallel)`. The parallel pytest task runs `poetry run pytest -n auto`; the coverage task adds `--cov-branch`, `--cov-report=lcov:artifacts/python/lcov.info`, and `--cov`; the Pester task calls `Invoke-PoshQCParallelTest`. The file is outside `GOVERNED_GLOBS`, so `validate_json` does not apply. The count 55 equals the count recorded in `evidence/other/spec-ac-jsonc-amendment.2026-10-31T21-19.md`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | PASS | No change in cycle 1. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | Unchanged. |
| **Use PoshQC Configuration** | PASS | `Invoke-PoshQCTest -ScanFolders tests/scripts/powershell/PoshQC` with the repository run settings. |
| **Focused Unit Tests** | PASS | 33 new cases across four files after PR10 and PR11 (OP 4, SW 7, PM 11, PR 11). |
| **File Naming and Structure** | PASS | `*.Tests.ps1` under the mirrored `tests/scripts/powershell/PoshQC/` path. |

---

## 5. Test Coverage Detail

### PoshQC.Parallel.psm1 (22 tests: PM01-PM11, PR01-PR11)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| PM01-PM03 | Positive / Edge Case | `Get-PoshQCParallelWorkerCount` | PASS |
| PM04-PM08 | Positive / Negative | `Merge-PoshQCJunitReport` | PASS |
| PM09-PM11 | Positive | `ConvertTo-PoshQCShardWeight`, `Export-PoshQCShardWeight` | PASS |
| PR01-PR09 | Positive / Error Handling | `Invoke-PoshQCParallelTest`, `Invoke-PoshQCParallelMerge` | PASS |
| PR10 | Edge Case | omitted-root fallback (line 408) | PASS |
| PR11 | Edge Case | relative-root fallback (line 411) | PASS |

**Coverage:** 97.33% (146/150).

**Not covered:** lines 263, 264, 266, 267 (`Invoke-PoshQCPwshExe` body; D2).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | PoshQC folder run 229; last full Pester run 13643; pytest 15881 | PASS |
| Tests Failed | 0 | PASS |
| Test File Size | largest cycle-1 file 302 logical lines | PASS at or below 800 lines |
| Code Coverage | Parallel 97.33%; Python 96.69% lines, 93.64% branches | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | PoshQC format | 0 files changed | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with `pssa.settings.psd1` | 0 findings | PASS |
| Pester Tests | `Invoke-PoshQCTest -ScanFolders tests/scripts/powershell/PoshQC` | 229 tests, 0 failures | PASS |

**Notes:** The toolchain was executed by the executor. This review re-ran by command: `git diff --name-status 522abaade~1..522abaade`; the unified diff of `spec.md` and the test file; the JSONC parse of `.vscode/tasks.json`; a search of the test file for banned constructs; the JaCoCo per-file counter read; the logical line count; and a grep of the checkbox state of both AC files. PowerShell was not re-run because the worktree isolation guard refuses command text that launches `pwsh`; the persisted cycle-1 artifacts were inspected instead.

---

## 8. Gaps and Exceptions

### Identified Gaps

- None blocking. Three CI-dependent verification groups remain Pending-S9 (non-blocking, owned by orchestrator step 9) and are described in the feature audit.

### Approved Exceptions

**None.** No coverage exclusion, suppression, or skipped test was introduced.

### Removed/Skipped Tests

**None.**

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. Commits 973df98b2 to d817f4075 as listed in the prior policy audit (15 commits).
2. **522abaade** - test(poshqc): cover the -Root fallbacks and correct two tasks.json acceptance criteria (#1048)

### Files Modified

1. `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1` - PR10 and PR11.
2. `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md` - S4 and S18 reworded and checked.
3. Feature folder review set, remediation plan, and evidence.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT (pending CI at step 9)

Toolchain, coverage, file size, evidence location, mirror parity, determinism, and dependency requirements are met. F1 and CR-2 are resolved. The CI-dependent items are Pending-S9 and non-blocking for the pull request creation gate.

**Fail-closed reminder:** every required baseline artifact, QA artifact, coverage metric, and coverage-comparison artifact is present.

### Metrics Summary

- PASS 0 Pester failures in the cycle-1 PoshQC run; shuffled runs for three seeds clean
- PASS `PoshQC.Parallel.psm1` 97.33% line coverage
- PASS no production or bundle file changed in cycle 1
- PENDING CI-dependent checks at orchestrator step 9

### Recommendation

**Ready to proceed to pull request creation**

Open the pull request; orchestrator step 9 then completes the Pending-S9 items and the check-off of the CI-dependent criteria.

---

## Appendix A: Test Inventory

1. PoshQC.ParallelRunner › PR01-PR11
2. PoshQC.ParallelMerge › PM01-PM11
3. PoshQC.ShardWeights › SW01-SW07
4. PoshQC.TestingOutputPath › OP01-OP04

---

## Appendix B: Toolchain Commands Reference

**Commands run during this review (read-only):**
```bash
git diff --name-status 522abaade~1..522abaade
git diff 522abaade~1..522abaade -- spec.md tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1
node (JSONC parse of .vscode/tasks.json and label check)
awk 'END{print NR}' tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1
node (JaCoCo per-file counter read for PoshQC.Parallel.psm1)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-31
**Policy Version:** Current (as of audit date)
