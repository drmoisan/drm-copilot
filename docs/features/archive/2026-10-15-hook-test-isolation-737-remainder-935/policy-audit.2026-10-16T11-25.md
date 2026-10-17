# Policy Compliance Audit: Issue #935 — hook-test-isolation-737-remainder (re-audit after remediation cycle 2)

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T11-25, UTC host clock)
**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Base:** `main`; merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea` (equal to `origin/main` at review time)
**Head reviewed:** `1d364d0c16fa77a1ed38ce16c5506ee55b5bf38c` (pushed; PR #956; merge of `origin/main` on top of `8937eed67`)
**Review scope:** full branch diff `origin/main...HEAD` (18 PowerShell files under `tests/scripts/`, +1767/-572, plus feature-folder Markdown)
**Work mode:** `full-bug` (AC source: `spec.md`, section `## Acceptance Criteria`, AC-1..AC-26)
**Code Under Test:** 18 PowerShell files under `tests/scripts/` (7 created, 11 edited), all test suites or test helpers; no production file changed
**Prior review:** `remediation-inputs.2026-10-16T07-55.md` (verdict REMEDIATION_REQUIRED: COV-1 autonomous; CR-R1..CR-R3); remediation plan `remediation-plan.2026-10-16T07-55.md` (cycle R2)

## Total Blocking Findings: 1

COV-1 (carried, `autonomous`): the PR CI coverage file still shows line coverage below the baseline after remediation cycle 2. The cycle produced no code change for COV-1; its investigation located the trigger inside the spec Write Set.

- CI evidence: the most recent completed `poshqc / PowerShell QC` coverage file is from run 38890188058, head `988ed2210`. Its write-set code is identical to the reviewed head; this review compared the five isolation-guard files and found no difference. It reports 16383 covered / 1787 missed = 90.17% line coverage. The baseline is 90.42% (`adb9aa5f0`) and main at the previous merge-base `b6be46b5e` was 90.44%.
- Attribution: `.claude/lib/worktree-resolution/WorktreeResolution.psm1` is still 112 covered / 32 missed in that CI file (142 / 2 on main).
- AC-24: FAIL.
- Trigger: the cycle-2 isolation runs reproduced the loss locally (127 vs 142 covered for the module). Reverting unit U4 alone restored 142/142 (`evidence/other/r2-cov-iso-u4.2026-10-16T10-50.md`). U4 is the isolation-guard unit: 2 created and 7 edited files, all listed in spec `## Write Set`.
- Why this stays autonomous: the BLOCKED record (`evidence/qa-gates/r2-cov-blocked.2026-10-16T10-52.md`) says "root cause outside the write set". That statement describes the suspected Pester breakpoint mechanism. It does not describe the trigger, which the same record names as U4. The BLOCKED route of the plan meant only that the one pre-specified fix (FIX-U2) did not apply. The next step is narrower bisection inside the nine U4 paths, followed by a change in the identified write-set file. That work is executable without an external decision.

The CI run on the reviewed head (run 38893096135) was in progress at review time. Every other CI-dependent criterion passed in run 38890188058 (see the feature audit). Confirmation on the final head is a pending-CI item (PC-1, non-blocking).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 18 (7 created, 11 edited; all under `tests/scripts/`) | 54 new testcases on the branch (41 HookReference, 6 Branches, 4 Discovery, 3 probe rows); every moved row retained | PASS in CI run 38890188058 (head `988ed2210`, 10537 testcases, 0 failures, both PoshQC jobs success); final-head run 38893096135 in progress | 90.42% line coverage (16381/18116, CI run 38730332356 on main `adb9aa5f0`); main at `b6be46b5e` 90.44% (16425/18162) | FAIL: 90.17% line coverage (16383/18170, CI run 38890188058), below the baseline; `WorktreeResolution.psm1` 112/144 against 142/144 on main (COV-1). On-disk local artifact 65.96% (8113/12299, three-folder run) is also below the 85% floor | 100.00% (0/0 production lines changed; no changed file is in the `config/poshqc-coverage.json` roots) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | feature-folder documents and evidence files | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `evidence/baseline/ci-baseline.2026-10-16T00-11.md` (CI run 38730332356: covered 16381, missed 1735, 90.42% line coverage); main at `b6be46b5e` 90.44% (quoted in `remediation-inputs.2026-10-16T07-55.md`)
- PowerShell post-change coverage artifact: CI `powershell-coverage.xml` from artifact `poshqc-test-results` of run 38890188058 (head `988ed2210`), downloaded and read by this review: root LINE covered 16383, missed 1787 (90.17%); `WorktreeResolution.psm1` LINE covered 112, missed 32 - FAIL against the baseline (COV-1)
- PowerShell local on-disk coverage file: `artifacts/pester/powershell-coverage.xml`, report stamp `Pester (10/16/2026 11:18:41)`: LINE covered 8113, missed 4186 (65.96%) from the R2 three-folder run - FAIL against the 85% line floor; scoped run, so it is not the AC-24 figure
- PowerShell cycle-2 attribution investigation: `evidence/other/r2-cov-investigation.2026-10-16T10-51.md` (trigger unit U4, inside the Write Set)
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch delivers the #737 remainder recorded as #903 Operator Follow-ups 4, 5, 6, 10 and 11, entirely inside test infrastructure:

- F-1/F-2 reapplied from `4e8d9f92d` and refined by R1 and R2. The hook-reference functions live in the new `EpicStateIsolation.HookReference.Helpers.ps1`.
- F-3 report-only detection of variable-built hook loads (Discovery row `AC-5b`).
- I-3: four 500-line files split by moving code without changing it.
- N-2 and F-6 closed by recorded decisions (spec D5, D6).

Remediation cycle 2 (commits `b61ce2de2`..`8937eed67`) results:

- CR-R1 fixed. `Test-EpicStateIsolationSeparateValue` now lists the value-taking common parameters, and eight direct edge-case rows were added. The fail-before record is `evidence/regression-testing/r2-cr-r1-fail-before.2026-10-16T09-20.md`.
- CR-R2 fixed. The new `Test-EpicStateIsolationExcludedHookName`, `Get-EpicStateIsolationJoinPathCommand` and `Get-EpicStateIsolationVariableNode` replace the repeated inline predicates in the HookReference helper.
- CR-R3 fixed. The no-op `.Replace('__SPAWN__', ...)` was removed.
- COV-1 was investigated through repo-scope isolation runs. Outcome: `REPRODUCED-U2-DOES-NOT-RESTORE`, trigger U4. No code fix was applied, and the CI figure is unchanged in kind (90.17%).

One blocking finding remains (COV-1, `autonomous`). New non-blocking observations are listed in the code review and feature audit.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- FAIL `.claude/rules/general-unit-test.md` on the coverage requirement only (COV-1)
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- FAIL `.claude/rules/powershell.md` coverage gate (COV-1); code change and unit test structure otherwise PASS
- N/A TypeScript, Python, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-10-16 11:21:20 UTC at HEAD `1d364d0c1`), `issue.md`, `spec.md`, `plan.2026-10-15T17-44.md`, `remediation-plan.2026-10-16T03-40.md`, `remediation-plan.2026-10-16T07-55.md`, the `evidence/` folder, the on-disk `artifacts/pester/` files, CI run 38890188058 artifacts, and `gh pr checks 956`.

**Temporary artifacts cleanup:**
- PASS `git status --porcelain` was empty at review start; no `SCRATCH/` or `artifacts/` path is in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller requested the full feature-review contract over the whole branch; the audit covers the full `origin/main...HEAD` diff.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no output.
- The branch file list contains no path under `artifacts/` (none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`).
- Cycle-2 evidence is under `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/` and `evidence/other/`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds no project; all changed code is under `tests/scripts/`, covered by the root entry `path: "."` (T4). Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | The CR-R1 rows parse their own in-memory command AST per row; no shared state. |
| Isolation | PASS | Each CR-R1 row targets `Test-EpicStateIsolationSeparateValue` with one element index. |
| Fast execution | PASS | One-line sources parsed with the existing fixture helper. |
| Determinism | PASS | `evidence/qa-gates/r2-determinism-search.2026-10-16T11-07.md`; this review's grep found no new banned API in the cycle-2 delta. |
| Readability | PASS | Arrange-Act-Assert comments; `-Because` names the element index, source and case. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell coverage) | FAIL | CI 90.17% is above the 85% floor but below the 90.42% baseline that AC-24 and the no-regression rule require. The on-disk local artifact reads 65.96% from a scoped three-folder run. COV-1. |
| Branch >= 75% | Not evaluated | Pester reports no branch metric, so the branch threshold does not apply to this language (`.claude/rules/powershell.md`). |
| No regression on changed lines | PASS | 0 production lines changed; the regression is an attribution loss in an unchanged production module (COV-1). |
| Positive / negative / edge | PASS | CR-R1 rows cover six negative cases (last element, followed by parameter, attached argument, abbreviated name, non-parameter) and three positive cases (named value parameter, `-ErrorAction`, `-OutVariable`). |
| Coverage exclusion policy | PASS | `config/poshqc-coverage.json` is not in the diff; no production path is excluded. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% line coverage (16381/18116, CI run 38730332356 at main `adb9aa5f0`); main at `b6be46b5e` 90.44% (16425/18162). Post-change: 90.17% line coverage (16383/18170, CI run 38890188058 at `988ed2210`); prior PR head `da4ccf4f0` 90.27%. Change: -0.25 points against the baseline; `WorktreeResolution.psm1` -30 covered lines. New/changed-code coverage: 100.00% (0/0 production lines). Disposition: FAIL (COV-1, `autonomous`; trigger unit U4 inside the Write Set). Evidence: `evidence/baseline/ci-baseline.2026-10-16T00-11.md`, `evidence/other/r2-cov-investigation.2026-10-16T10-51.md`, `evidence/other/r2-cov-iso-u4.2026-10-16T10-50.md`, CI artifact `poshqc-test-results` of run 38890188058.
- TypeScript: N/A - no changed files on the branch.
- Python: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | `Describe 'issue #935 CR-R1 separate-value edge cases'` (HookReference suite lines 431-454). |
| Actionable assertion messages | PASS | `-Because "element $Index of '$Source' ($Case)"`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | Fixtures are in-memory strings. |
| Test file location | PASS | All suites and helpers under `tests/scripts/`. |
| File size <= 500 lines | PASS | Recomputed by this review: maximum 454 (`enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`); HookReference helper 448; `EpicStateIsolation.Helpers.ps1` 433. |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. R2 Phase 0 artifacts exist (`evidence/baseline/r2-*.md`: instructions read, branch state, comparison tree, token counts, coverage baseline, format, analyze, test).

### 2.2 Design Principles

PASS. CR-R2 removed the repeated predicates in the HookReference helper. One pre-existing copy of the hook-name exclusion remains in `Get-EpicStateHookLiteral` (Discovery helper), recorded as non-blocking CR-R4 in the code review.

### 2.3 Module & File Structure

PASS. All 18 changed code files at or below 500 lines.

### 2.4 Naming, Docs, and Comments

PASS. The three new helper functions use approved verbs, `[CmdletBinding()]`, `[OutputType()]`, typed parameters and a header comment that names the finding they address.

### 2.5 After Making Changes - Toolchain Execution

| Stage | Result | Evidence |
|-------|--------|----------|
| 1 Formatting | PASS | `evidence/qa-gates/r2-ps-format.2026-10-16T10-53.md`. |
| 2 Linting | PASS | `evidence/qa-gates/r2-ps-analyze.2026-10-16T10-53.md`. |
| 3 Type checking | N/A | Not applicable to PowerShell. |
| 4 Architecture-boundary tests | N/A | No boundary test covers `tests/scripts/`. |
| 5 Unit tests | PASS | `evidence/qa-gates/r2-ps-test.2026-10-16T11-05.md`; CI run 38890188058 JUnit 10537 testcases, 0 failures. |
| 6 Contract / schema | N/A | No API or schema changed. |
| 7 Integration tests | N/A | No adapter changed. |

The R2 loop closed in one pass (`evidence/qa-gates/r2-loop-status.2026-10-16T11-05.md`).

### 2.6 Summarize and Document

PASS. `evidence/qa-gates/r2-findings-status.2026-10-16T11-08.md` lists COV-1 and CR-R1..CR-R3 with their dispositions. The PR #956 description has not been updated for cycle 2. It still describes COV-1 as a denominator mismatch, and the CI evidence supersedes that description. This is recorded as non-blocking DOC-1.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| PoshQC format | PASS | R2 format pass with no change. One cycle-2 line (`$seen =[System.Collections.Generic.HashSet[string]]::new(...)`, HookReference helper line 434) lacks a space after `=`; the formatter settings did not flag it (non-blocking CR-R5). |
| PSScriptAnalyzer | PASS | R2 analyze returned without error. |
| `[OutputType()]` and typed parameters | PASS | `Test-EpicStateIsolationExcludedHookName` (`[bool]`), `Get-EpicStateIsolationJoinPathCommand` (`CommandAst`), `Get-EpicStateIsolationVariableNode` (`VariableExpressionAst`). |
| No mutable module state | PASS | No new script-scope state. |
| Fail-fast error handling | PASS | Mandatory typed parameters; pure functions. |
| Policy files untouched | PASS | No path under `.claude/` or `.github/` in the diff. |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5 with `#Requires` | PASS | Unchanged suite headers. |
| Data-driven rows | PASS | CR-R1 rows use `-ForEach` with a `<Case>` name. |
| Fail-before for CR-R1 | PASS | `evidence/regression-testing/r2-cr-r1-fail-before.2026-10-16T09-20.md`. |
| Per-row CI results (both jobs) | PASS at `988ed2210`; final head pending | Run 38890188058 success for `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`; run 38893096135 on `1d364d0c1` in progress (PC-1). |

## 5. Test Coverage Detail

All changed files are test suites or helpers under `tests/scripts/`, outside the coverage roots. No production line changed. The coverage loss is an attribution loss in `.claude/lib/worktree-resolution/WorktreeResolution.psm1`. The cycle-2 local runs credited all 30 lines when the module's own suites ran without the U4 changes (`r2-cov-lib-only`, `r2-cov-iso-u4`). The lines therefore execute. Under the U4 changes they are not credited, which is consistent with Pester breakpoint binding to a different compiled module instance. The specific U4 file and statement that change the binding have not been identified.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| New testcases on the branch | 54 (HookReference 41, Branches 6, Discovery 4, probe rows 3) |
| CI run 38890188058 (Windows JUnit) | 10537 testcases, 0 failures, 0 errors |
| CI post-split counts (run 38890188058) | worktree-removal-gate 47 + ManifestBranch 5 = 52 (baseline 51); TargetResolution 20 + CallTarget 6 = 26 (baseline 25); command-exemption 60 + Selectors 61 = 121 (baseline 120); `enforcement-hooks-no-python-invocation` 32 (baseline 32); epic-scope 54 (baseline 54) |
| Final-head CI | Run 38893096135 in progress (PC-1) |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format | No change (R2 pass) |
| PoshQC analyze | Returned without error |
| PoshQC test | Returned without error; CI 0 failures |
| Line counts | All 18 files <= 500 (maximum 454) |
| Determinism grep | 0 executable matches |
| Scope (`.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`, `artifacts/`) | 0 paths |

## 8. Gaps and Exceptions

### Identified Gaps

- COV-1 (`autonomous`): PR CI line coverage 90.17% is below the 90.42% baseline. The loss is located in `WorktreeResolution.psm1` attribution, and the cycle-2 investigation located the trigger in Write Set unit U4. Remediation: bisect the nine U4 paths, identify the file and construct that change the module's compile or breakpoint binding, and change it inside the Write Set. If no Write Set change restores the attribution, escalate as a human decision (accept the attribution loss against AC-24, or authorize a change outside the Write Set).
- PC-1 (pending CI, non-blocking): final-head confirmation of AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23 on run 38893096135.
- DOC-1 (non-blocking): the PR description does not describe cycle 2 or the current COV-1 state.

### Approved Exceptions

None.

### Removed/Skipped Tests

None removed or skipped.

## 9. Summary of Changes

### Commits in This PR/Branch (since the prior review)

- `b61ce2de2`..`988ed2210` cycle-2 code and investigation evidence (CR-R1, CR-R2, CR-R3; COV-1 isolation runs and BLOCKED record)
- `2048ea2f6` docs(935): R2 final QA evidence
- `8937eed67` docs(935): R2 findings status
- `1d364d0c1` merge of `origin/main` (merge-base now `5bdf22d0f`; no change to `.claude/lib/worktree-resolution`, PoshQC settings or `config/`)

### Files Modified

- Cycle 2 code: `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`.
- Branch total: the 18 Write Set code paths and feature-folder Markdown.

## 10. Compliance Verdict

### Overall Status: NOT COMPLIANT (COV-1, autonomous)

### Policy-by-Policy Summary

- General Unit Test Policy: FAIL on the coverage no-regression requirement (COV-1); all other requirements PASS
- General Code Change Policy: PASS
- PowerShell code change and unit test policy: FAIL on the coverage gate (COV-1); format, analyze and test PASS
- Quality tiers and coverage exclusion policy: PASS
- Evidence location policy: PASS
- Tonality: PASS

### Metrics Summary

- PowerShell coverage: baseline 90.42%; PR CI 90.17% at `988ed2210`.
- `WorktreeResolution.psm1`: 112/144 covered in PR CI against 142/144 on main.
- Changes and findings: 0 production lines changed; 1 blocking finding (COV-1, `autonomous`); criteria pending final-head CI (PC-1); CR-R1..CR-R3 fixed.

### Recommendation

Run a remediation cycle 3 for COV-1:

1. Bisect U4 into its components and repeat the D-ISO isolation per component. The components are: the HookReference helper and its dot-source line; the HookReference suite; the Discovery suite rows; and the fixture-binding edits in the Branches, Predicate and legacy guard suites.
2. Change the identified write-set file so that `WorktreeResolution.psm1` attribution returns to 142/144.
3. Confirm the result from the PR CI coverage file.

Fold DOC-1, CR-R4 and CR-R5 into the same cycle.

---

## Appendix A: Test Inventory

1. `R1 identifies <Case>` (11) and `R1 does not identify <Case>` (3) — HookReference suite
2. `R2 (a)`..`R2 (d)` — HookReference suite
3. `F-3 detects <Form>` (5), `F-3 ignores a Join-Path used only by <Reader>` (3), `F-3 process-spawning report includes a variable-built hook path`, `F-3 closure stays literal-seeded` — HookReference suite
4. `CR-N3 ...` rows (5) — HookReference suite
5. `CR-R1 separate value: <Case>` (8) — HookReference suite (new in cycle 2)
6. `F-1 non-compliant <Branch>` (3), `F-1 compliant <Branch>` (2), `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` — Branches suite
7. `AC-5b variable-built hook-load report <Surface>` (2), `F-3 non-vacuity <Surface> reports at least one variable-built hook load` (2) — Discovery suite
8. `baseline mock interception probe` — ManifestBranch, CallTarget, Selectors suites

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (executor, via MCP; R2):**
```
mcp__drm-copilot__run_poshqc_format   (R2 P4-T1)
mcp__drm-copilot__run_poshqc_analyze  (R2 P4-T2)
mcp__drm-copilot__run_poshqc_test     (R2 P2 isolation runs with scan_folders omitted; R2 P4-T3 three folders)
```

**Reviewer commands (check-only):**
```
git merge-base origin/main HEAD
git diff --stat origin/main...HEAD -- tests
git diff b8d8a16b0 8937eed67 -- <HookReference helper and suite>
git diff --stat 988ed2210 HEAD -- <isolation-guard files>
git log --oneline b6be46b5e..5bdf22d0f
gh pr checks 956
gh run view 38868578476 --json conclusion,headSha,jobs
gh run download 38890188058 -n poshqc-test-results -D <scratchpad>
grep / awk over the downloaded powershell-coverage.xml and pester-junit.xml
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```
