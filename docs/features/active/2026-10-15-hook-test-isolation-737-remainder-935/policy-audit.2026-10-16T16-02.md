# Policy Compliance Audit: Issue #935 — hook-test-isolation-737-remainder (re-audit after remediation cycle 3)

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T16-02, UTC host clock)
**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Base:** `main`; merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea` (`origin/main` is now `d72ec6a10`, ahead of the merge-base)
**Head reviewed:** `ddadd0835e302f3e45cd60808356e7cb5872ca3e` (pushed; PR #956)
**Review scope:** full branch diff `origin/main...HEAD` (18 PowerShell files under `tests/scripts/`, plus feature-folder Markdown)
**Work mode:** `full-bug` (AC source: `spec.md`, section `## Acceptance Criteria`, AC-1..AC-26)
**Code Under Test:** 18 PowerShell files under `tests/scripts/` (7 created, 11 edited), all test suites or test helpers; no production file changed
**Prior review:** `remediation-inputs.2026-10-16T11-25.md` (verdict REMEDIATION_REQUIRED: COV-1 autonomous; non-blocking DOC-1, EV-1, CR-R4, CR-R5); remediation plan `remediation-plan.2026-10-16T11-25.md` (cycle R3)

## Total Blocking Findings: 1

COV-1 (carried, now `external_dependency`): the PR CI coverage file still shows line coverage below the baseline. Cycle 3 found no change inside the Write Set that restores the attribution, and the human decision recorded in `evidence/other/cov1-decision.2026-10-16T15-56.md` selects Pester profiler mode, delivered by issue #953 / PR #959 outside this item. PR #959 is treated as not yet merged; `git log 5bdf22d0f..origin/main` contains no #953 or #959 commit. AC-24 cannot be settled until that merge and the re-measurement it requires.

- CI evidence on the current code: run 38922641167 (pull_request event, head `3ab81c26f`; `git diff --stat 3ab81c26f HEAD` over `tests`, `.claude`, `.codex`, `.github`, `scripts`, `config` and `extensions` is empty). Its `poshqc-test-results` coverage file (report `Pester (10/16/2026 15:28:57)`), downloaded and read by this review: root LINE covered 16531, missed 1906 = 89.66%. Runs 38915587310 (`af4672b7d`) and 38914467202 (`d81de8ac8`) report the same root and per-file counters.
- Baseline: 90.42% (`evidence/baseline/ci-baseline.2026-10-16T00-11.md`, run 38730332356 at `adb9aa5f0`). Main at the merge-base `5bdf22d0f` (run 38885440106): 16434 / 18170 = 90.45%.
- Same-population comparison: main at `5d2d9a972` (run 38911869997) has the same 18437-line population as the PR run and reports 16636 / 18437 = 90.23%. The PR run is 105 covered lines lower. A per-file diff of the two files locates all 105 lines in unchanged production modules:
  - `.claude/lib/orchestrator-state/`: `OrchestratorStateCompletionChecks.psm1` 74 vs 99, `OrchestratorStateEpicWaveBarrier.psm1` 97 vs 108, `OrchestratorStateIssueAdoption.psm1` 96 vs 116, `OrchestratorStateModelReceipts.psm1` 70 vs 91, `OrchestratorStateReceipts.psm1` 96 vs 117, `OrchestratorStateRoutingContract.psm1` 94 vs 99, `OrchestratorStateUnconditional.psm1` 26 vs 27.
  - `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`: 89 vs 90.
- `WorktreeResolution.psm1` is 112 / 144 in both the PR run and main at `5d2d9a972`. On main it fell from 142 (`3fc83c8c3`, run 38907131337) to 112 (`5d2d9a972`) with no #935 change, so the attribution loss that COV-1 originally tracked now also appears on main.
- AC-24: FAIL. The finding is not executable inside the item: the selected fix changes `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, which AC-21 and the coordinator directive keep out of #935.

The CI run on the reviewed head (run 38928004778) was queued at review time. Every other CI-dependent criterion passed in run 38922641167 on code identical to HEAD (see the feature audit). Confirmation on the final head is pending-CI item PC-1 (non-blocking).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 18 (7 created, 11 edited; all under `tests/scripts/`) | 54 new testcases on the branch; every moved row retained | PASS in CI run 38922641167 (head `3ab81c26f`, code identical to HEAD; 10793 testcases, 0 failures; both PoshQC jobs success); final-head run 38928004778 queued | 90.42% line coverage (16381/18116, CI run 38730332356 on main `adb9aa5f0`); main at merge-base `5bdf22d0f` 90.45% (16434/18170) | FAIL: 89.66% line coverage (16531/18437, CI run 38922641167), below the baseline and 105 lines below main `5d2d9a972` at the same population (COV-1). Local repo-scope run 94.33% (11602/12299, `artifacts/pester/powershell-coverage.xml`, report `Pester (10/16/2026 15:47:40)`) | 100.00% (0/0 production lines changed; no changed file is in the `config/poshqc-coverage.json` roots) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | feature-folder documents and evidence files | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `evidence/baseline/ci-baseline.2026-10-16T00-11.md` (CI run 38730332356: covered 16381, missed 1735, 90.42% line coverage); main at merge-base `5bdf22d0f` 90.45% (run 38885440106, read by this review)
- PowerShell post-change coverage artifact: CI `powershell-coverage.xml` from artifact `poshqc-test-results` of run 38922641167 (head `3ab81c26f`), downloaded and read by this review: root LINE covered 16531, missed 1906 (89.66%) - FAIL against the baseline (COV-1)
- PowerShell same-population reference: CI `powershell-coverage.xml` of main run 38911869997 (`5d2d9a972`): root LINE covered 16636, missed 1801 (90.23%); per-file diff against the PR run in section 1.2.1
- PowerShell local on-disk coverage file: `artifacts/pester/powershell-coverage.xml`, report stamp `Pester (10/16/2026 15:47:40)` (R3 P4-T4 repo-scope run): LINE covered 11602, missed 697 (94.33%), above the 85% floor; local population, so it is not the AC-24 figure
- PowerShell cycle-3 attribution investigation: `evidence/other/r3-cov-bisection.2026-10-16T14-13.md` (terminal `T-U4-NO-LONGER`), `evidence/qa-gates/r3-cov-status.2026-10-16T15-15.md` (`human_decision_required`), decision record `evidence/other/cov1-decision.2026-10-16T15-56.md`
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch delivers the #737 remainder recorded as #903 Operator Follow-ups 4, 5, 6, 10 and 11, entirely inside test infrastructure:

- F-1/F-2 reapplied from `4e8d9f92d` and refined by R1 and R2. The hook-reference functions live in `EpicStateIsolation.HookReference.Helpers.ps1`.
- F-3 report-only detection of variable-built hook loads (Discovery row `AC-5b`).
- I-3: four 500-line files split by moving code without changing it.
- N-2 and F-6 closed by recorded decisions (spec D5, D6).

Remediation cycle 3 (commits `848c207f7`..`ddadd0835`) results:

- CR-R4 fixed. `Get-EpicStateHookLiteral` now calls `Test-EpicStateIsolationExcludedHookName`, and the Discovery helper header names the dependency.
- CR-R5 fixed. `$seen = [System.Collections.Generic.HashSet[string]]::new(...)`.
- EV-1 fixed. `evidence/other/r3-ev1-correction.2026-10-16T15-16.md` and `r3-cov-status.2026-10-16T15-15.md` state the trigger and the mechanism on separate lines.
- COV-1 bisected through nodes N0-N5. After the `origin/main` merge at `1d364d0c1`, reverting all nine U4 paths no longer restores 142 (`T-U4-NO-LONGER`), and fix trials FX-1, FX-2 and FX-23 each left 127. Status `human_decision_required`; the decision (option 2, profiler mode via #953 / PR #959) is recorded.

One blocking finding remains (COV-1, `external_dependency`). Non-blocking observations are listed in the code review and feature audit.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- FAIL `.claude/rules/general-unit-test.md` on the coverage requirement only (COV-1)
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- FAIL `.claude/rules/powershell.md` coverage gate (COV-1); code change and unit test structure otherwise PASS
- N/A TypeScript, Python, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-10-16 15:57:17 UTC at HEAD `ddadd0835`), `issue.md`, `spec.md`, `plan.2026-10-15T17-44.md`, the three remediation plans, the `evidence/` folder, the on-disk `artifacts/pester/` files, CI artifacts of runs 38922641167, 38915587310, 38914467202, 38911869997, 38907131337 and 38885440106, and `gh pr view 956`.

**Temporary artifacts cleanup:**
- PASS `git status --porcelain` was empty at review start; no `SCRATCH/` or `artifacts/` path is in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller requested the full feature-review contract over the whole branch; the audit covers the full `origin/main...HEAD` diff.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no output.
- The branch file list contains no path under `artifacts/` (none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`).
- Cycle-3 evidence is under `evidence/baseline/`, `evidence/qa-gates/` and `evidence/other/`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds no project; all changed code is under `tests/scripts/`, covered by the root entry `path: "."` (T4). Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Cycle 3 added no row; the CR-R4 edit is inside a pure helper. |
| Isolation | PASS | Unchanged from the prior review. |
| Fast execution | PASS | Unchanged. |
| Determinism | PASS | `evidence/qa-gates/r3-determinism-search.2026-10-16T15-52.md` (6 matches, none executable); the cycle-3 code delta is two lines with no banned API. |
| Readability | PASS | Unchanged. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell coverage) | FAIL | CI 89.66% is above the 85% floor but below the 90.42% baseline that AC-24 and the no-regression rule require. COV-1 (`external_dependency`). The local repo-scope file reads 94.33%. |
| Branch >= 75% | Not evaluated | Pester reports no branch metric, so the branch threshold does not apply to this language (`.claude/rules/powershell.md`). |
| No regression on changed lines | PASS | 0 production lines changed; the loss is attribution in unchanged production modules (COV-1). |
| Positive / negative / edge | PASS | Unchanged from the prior review; cycle 3 added no behaviour. |
| Coverage exclusion policy | PASS | `config/poshqc-coverage.json` is not in the diff; no production path is excluded. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% line coverage (16381/18116, CI run 38730332356 at `adb9aa5f0`); main at merge-base `5bdf22d0f` 90.45% (16434/18170, run 38885440106). Post-change: 89.66% line coverage (16531/18437, CI run 38922641167 at `3ab81c26f`, a pull_request merge build). Same-population main `5d2d9a972`: 90.23% (16636/18437, run 38911869997). Change: -0.76 points against the baseline; -105 covered lines against main at the same population, all in unchanged production modules (orchestrator-state -104: CompletionChecks -25, EpicWaveBarrier -11, IssueAdoption -20, ModelReceipts -21, Receipts -21, RoutingContract -5, Unconditional -1; EpicScopeResolution -1). `WorktreeResolution.psm1` 112/144 in both. New/changed-code coverage: 100.00% (0/0 production lines). Disposition: FAIL (COV-1, `external_dependency`; settlement waits for #953 / PR #959). Evidence: `evidence/baseline/ci-baseline.2026-10-16T00-11.md`, `evidence/other/cov1-decision.2026-10-16T15-56.md`, `evidence/qa-gates/r3-cov-status.2026-10-16T15-15.md`, CI artifacts `poshqc-test-results` of runs 38922641167 and 38911869997.
- TypeScript: N/A - no changed files on the branch.
- Python: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | Unchanged from the prior review. |
| Actionable assertion messages | PASS | Unchanged. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | Fixtures are in-memory strings. |
| Test file location | PASS | All suites and helpers under `tests/scripts/`. |
| File size <= 500 lines | PASS | Recomputed by this review with `wc -l` over all 18 files: maximum 454 (HookReference suite); HookReference helper 448; `EpicStateIsolation.Helpers.ps1` 433; Discovery helper 292. |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. R3 Phase 0 artifacts exist (`evidence/baseline/r3-*.md`: instructions read, branch state, comparison tree, coverage mode, token counts, format, analyze, test).

### 2.2 Design Principles

PASS. CR-R4 removed the last duplicate of the hook-name exclusion; the rule now lives only in `Test-EpicStateIsolationExcludedHookName`.

### 2.3 Module & File Structure

PASS. All 18 changed code files at or below 500 lines.

### 2.4 Naming, Docs, and Comments

PASS. The Discovery helper header names the functions it now calls from the HookReference helper and the dot-source order required.

### 2.5 After Making Changes - Toolchain Execution

| Stage | Result | Evidence |
|-------|--------|----------|
| 1 Formatting | PASS | `evidence/qa-gates/r3-ps-format.2026-10-16T15-17.md` (before and after porcelain empty). |
| 2 Linting | PASS | `evidence/qa-gates/r3-ps-analyze.2026-10-16T15-18.md`. |
| 3 Type checking | N/A | Not applicable to PowerShell. |
| 4 Architecture-boundary tests | N/A | No boundary test covers `tests/scripts/`. |
| 5 Unit tests | PASS | `evidence/qa-gates/r3-ps-test.2026-10-16T15-32.md`, `r3-ps-test-repo.2026-10-16T15-50.md`; CI run 38922641167 JUnit 10793 testcases, 0 failures. |
| 6 Contract / schema | N/A | No API or schema changed. |
| 7 Integration tests | N/A | No adapter changed. |

The R3 loop closed in one pass (`evidence/qa-gates/r3-loop-status.2026-10-16T15-50.md`).

### 2.6 Summarize and Document

PASS. `evidence/qa-gates/r3-findings-status.2026-10-16T15-53.md` lists COV-1, CR-R4, CR-R5, EV-1 and DOC-1 with their dispositions, and the COV-1 decision is recorded. The PR #956 description still covers cycle 1 only and describes COV-1 as a denominator mismatch (non-blocking DOC-1, carried; orchestrator-owned).

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| PoshQC format | PASS | R3 format pass with no change; CR-R5 spacing fixed. |
| PSScriptAnalyzer | PASS | R3 analyze returned without error. |
| `[OutputType()]` and typed parameters | PASS | `Test-EpicStateIsolationExcludedHookName` (`[bool]`, mandatory `[string] $Name`). |
| No mutable module state | PASS | No new script-scope state. |
| Fail-fast error handling | PASS | Pure helper with a mandatory typed parameter. |
| Policy files untouched | PASS | No path under `.claude/` or `.github/` in the diff. |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5 with `#Requires` | PASS | Unchanged suite headers. |
| Data-driven rows | PASS | Unchanged. |
| Behaviour equivalence for CR-R4 | PASS | `evidence/qa-gates/r3-p2-ps-test.2026-10-16T14-24.md`; the shared predicate skips the same names as the two replaced ordinal checks, so the closure stays literal-seeded (AC-13). Discovery suite 365 testcases, 0 failures in run 38922641167. |
| Per-row CI results (both jobs) | PASS at `3ab81c26f`; final head pending | Run 38922641167 success for `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`; run 38928004778 on `ddadd0835` queued (PC-1). |

## 5. Test Coverage Detail

All changed files are test suites or helpers under `tests/scripts/`, outside the coverage roots. No production line changed. The coverage loss is attribution in unchanged production modules. The modules affected differ between runs with different suite sets: `WorktreeResolution.psm1` lost 30 lines on main between `3fc83c8c3` and `5d2d9a972` without any #935 change, and the PR run now loses 104 lines in `.claude/lib/orchestrator-state/` relative to main at the same population. This is consistent with the suspected Pester breakpoint-binding mechanism that the profiler-mode decision targets. The mechanism is not experimentally verified.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| CI run 38922641167 (Windows JUnit) | 10793 testcases, 0 failures, 0 errors |
| CI post-split counts (run 38922641167) | worktree-removal-gate 47 + ManifestBranch 5 = 52 (baseline 51); TargetResolution 20 + CallTarget 6 = 26 (baseline 25); command-exemption 60 + Selectors 61 = 121 (baseline 120); `enforcement-hooks-no-python-invocation` 32 (baseline 32); epic-scope 54 (baseline 54) |
| Guard suites (run 38922641167) | HookReference 41, Branches 16, Predicate 10, legacy guard 25, Discovery 365; 0 failures each |
| Final-head CI | Run 38928004778 queued (PC-1) |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format | No change (R3 pass) |
| PoshQC analyze | Returned without error |
| PoshQC test | Returned without error; CI 0 failures |
| Line counts | All 18 files <= 500 (maximum 454) |
| Determinism grep | 0 executable matches |
| Scope (`.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`, `artifacts/`) | 0 paths |

## 8. Gaps and Exceptions

### Identified Gaps

- COV-1 (`external_dependency`): PR CI line coverage 89.66% is below the 90.42% baseline. Settlement requires PR #959 (issue #953, profiler mode) to merge, `origin/main` to be merged into the branch, and the final-head PR CI coverage file to be compared at root level against the baseline and main at the same population, with a per-file diff. If the figure stays below the baseline under profiler mode, the decision record's option-1 fallback (accept the attribution loss) applies.
- PC-1 (pending CI, non-blocking): final-head confirmation of AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23 on run 38928004778 or the post-merge head.
- DOC-1 (non-blocking): the PR description does not describe cycles 2 and 3 or the current COV-1 state.
- EV-2 (non-blocking): the decision record's re-measurement procedure names only `WorktreeResolution.psm1` and TARGET 142, which main's own CI no longer reaches; see the code review and feature audit.

### Approved Exceptions

None. The decision record authorizes a path to settle AC-24; it does not grant an exception yet.

### Removed/Skipped Tests

None removed or skipped.

## 9. Summary of Changes

### Commits in This PR/Branch (since the prior review)

- `c2106a0ab` cycle-2 re-audit artifacts
- `848c207f7`, `8fa61b3c7`, `8ea92f625` remediation cycle 3 plan and preflight revisions
- `8b82782d3`, `d81de8ac8` R3 phase 0 and COV-1 bisection evidence
- `af4672b7d` test(935): CR-R4, CR-R5
- `3ab81c26f`, `7a09a91a8`, `20d7cba3c` COV-1 human-decision record, final QA evidence, findings status
- `ddadd0835` COV-1 decision record

### Files Modified

- Cycle 3 code: `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` (header and one call), `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` (one spacing fix).
- Branch total: the 18 Write Set code paths and feature-folder Markdown.

## 10. Compliance Verdict

### Overall Status: NOT COMPLIANT (COV-1, external_dependency; awaiting #953 / PR #959)

### Policy-by-Policy Summary

- General Unit Test Policy: FAIL on the coverage no-regression requirement (COV-1); all other requirements PASS
- General Code Change Policy: PASS
- PowerShell code change and unit test policy: FAIL on the coverage gate (COV-1); format, analyze and test PASS
- Quality tiers and coverage exclusion policy: PASS
- Evidence location policy: PASS
- Tonality: PASS

### Metrics Summary

- PowerShell coverage: baseline 90.42%; PR CI 89.66% at `3ab81c26f`; main at the same population 90.23%.
- Changes and findings: 0 production lines changed; 1 blocking finding (COV-1, `external_dependency`); criteria pending final-head CI (PC-1); CR-R4, CR-R5, EV-1 fixed.

### Recommendation

Hold the item until PR #959 merges. Then merge `origin/main` into the branch, let PR CI run on the new head, and decide AC-24 from that coverage file using a root-level comparison against the baseline and against main at the same population, plus a full per-file diff. Record PASS if the root figure meets the baseline; otherwise record the option-1 acceptance with the per-file evidence and report the attribution loss as a follow-up.

---

## Appendix A: Test Inventory

Unchanged from `policy-audit.2026-10-16T11-25.md` Appendix A; cycle 3 added and removed no rows.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (executor, via MCP; R3):**
```
mcp__drm-copilot__run_poshqc_format   (R3 P4-T1)
mcp__drm-copilot__run_poshqc_analyze  (R3 P4-T2)
mcp__drm-copilot__run_poshqc_test     (R3 P1 bisection nodes and P3 trials with scan_folders omitted; P4-T3 three folders; P4-T4 repo scope)
```

**Reviewer commands (check-only):**
```
git merge-base origin/main HEAD
git log --oneline 1d364d0c1..HEAD
git diff 1d364d0c1 HEAD -- tests
git diff --stat 3ab81c26f HEAD -- tests .claude .codex .github scripts config extensions
git log --oneline 5bdf22d0f..origin/main
gh run list --branch bug/hook-test-isolation-737-remainder-935; gh run list --branch main --workflow ci.yml
gh run view 38922641167 --json event,headSha,conclusion,jobs
gh run download <run> -n poshqc-test-results -D <scratchpad>  (runs 38922641167, 38915587310, 38914467202, 38911869997, 38907131337, 38885440106)
grep -o / awk over the downloaded powershell-coverage.xml and pester-junit.xml files
gh pr view 956 --json body
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```
