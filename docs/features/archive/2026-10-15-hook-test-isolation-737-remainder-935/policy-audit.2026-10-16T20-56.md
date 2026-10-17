# Policy Compliance Audit: Issue #935 — hook-test-isolation-737-remainder (final-pass review after the option 1 decision and the main merge)

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T20-56, UTC host clock)
**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Base:** `main`; merge-base `fa27cd5edcb39a5d5f63054c3e38cefef18ab316` (equal to `origin/main`)
**Head reviewed:** `a266488308a85e5febb828ca8cdde7a98a84fa4c` (local; one docs-only commit ahead of the pushed `048d76cd8`, PR #956)
**Review scope:** full branch diff `origin/main...HEAD` (170 paths: 18 PowerShell files under `tests/scripts/`, plus feature-folder Markdown)
**Work mode:** `full-bug` (AC source: `spec.md`, section `## Acceptance Criteria`, AC-1..AC-26, including the AC-24 amendment line)
**Code Under Test:** 18 PowerShell files under `tests/scripts/` (7 created, 11 edited), all test suites or test helpers; no production file changed
**Prior review:** `remediation-inputs.2026-10-16T16-02.md` (verdict HALT_NON_REMEDIABLE: COV-1 `external_dependency`; non-blocking DOC-1, EV-2, SYNC-1)

## Total Blocking Findings: 3

1. COV-2 (autonomous): the on-disk PowerShell coverage file `artifacts/pester/powershell-coverage.xml` (report `Pester (10/16/2026 20:47:22)`) is the output of the 13-suite seeded shuffled run, not a repository-scope run. Its root LINE counter reads covered 1994, missed 16443: 10.82% of 18437 lines. The review contract reads this file as the repo-wide PowerShell figure, and 10.82% is below the 85% line floor (default; the root `CLAUDE.md` states no threshold). Result: FAIL on the coverage row. The prior repo-scope record (94.33%, `evidence/qa-gates/r3-ps-test-repo.2026-10-16T15-50.md`) was overwritten.
2. AC-CHK-1 (autonomous): `spec.md` shows AC-24 checked although its amendment states the criterion is not met as written and its floor clause depends on final-head CI. Detail in the feature audit.
3. TEST-1 (autonomous): missing F-1 edge-case rows required by the spec Test Strategy. Detail in the code review.

COV-1 (prior blocking finding) is dispositioned: `evidence/other/cov1-decision-option1.2026-10-16T20-38.md` accepts the PowerShell line-coverage gap against the 90.42% baseline for AC-24, decoupled from #953 / PR #959 (PR #959 is still open). The general no-regression rule covers changed lines, and no production line changed. The 85% floor still applies to the final PR head.

CI on the pushed head `048d76cd8` (code identical to HEAD): run 38963921545 (pull_request event) concluded `success` at 21:01 UTC during this review; every job succeeded, including `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`. This review downloaded `poshqc-test-results` (report `Pester (10/16/2026 21:00:08)`): Windows JUnit 10793 testcases, 0 failures, 0 errors; root LINE counter covered 16531, missed 1906 = 89.66%, above the 85% floor and below the 90.42% baseline (the baseline clause is accepted under option 1). HEAD `a26648830` is not yet pushed, and the fixes in this pass change code, so the final-head confirmation stays pending-CI (PC-1).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 18 (7 created, 11 edited; all under `tests/scripts/`) | 54 new testcases on the branch; every moved row retained | Seeded shuffled run on the merged tree: 742 / 742 passed (13 suites); CI run 38922641167 (code identical): 10793 testcases, 0 failures; CI run 38963921545 on `048d76cd8` (code identical to HEAD): 10793 testcases, 0 failures; both PoshQC jobs success | 90.42% line coverage (16381/18116, CI run 38730332356 on main `adb9aa5f0`) | PASS against the 85% floor: 89.66% line coverage (16531/18437, CI run 38963921545); below the 90.42% baseline, accepted for AC-24 under option 1. FAIL for the on-disk local file: 10.82% (1994/18437, 13-suite scoped run; COV-2) | 100.00% (0/0 production lines changed; no changed file is in the `config/poshqc-coverage.json` roots) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | feature-folder documents and evidence files | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `evidence/baseline/ci-baseline.2026-10-16T00-11.md` (CI run 38730332356: covered 16381, missed 1735, 90.42% line coverage)
- PowerShell local on-disk coverage file: `artifacts/pester/powershell-coverage.xml`, report stamp `Pester (10/16/2026 20:47:22)`, written by the 13-suite shuffled run: root LINE covered 1994, missed 16443 (10.82%) - FAIL against the 85% line coverage floor as a repo-wide figure (COV-2); it is a scoped run and not a measure of repository coverage
- PowerShell previous repo-scope local record: `evidence/qa-gates/r3-ps-test-repo.2026-10-16T15-50.md` line 14 (covered 11602, missed 697, 94.33%), cycle-3 code, identical to HEAD code
- PowerShell CI post-change coverage, code identical to HEAD: run 38922641167 (head `3ab81c26f`): 89.66% (16531/18437), recorded in `policy-audit.2026-10-16T16-02.md`
- PowerShell post-change coverage artifact: CI `powershell-coverage.xml` from artifact `poshqc-test-results` of run 38963921545, downloaded and read by this review (report `Pester (10/16/2026 21:00:08)`): root LINE covered 16531, missed 1906 (89.66%) - PASS against the 85% floor; root and population (18437) equal to run 38922641167
- PowerShell AC-24 disposition: `evidence/other/cov1-decision-option1.2026-10-16T20-38.md` (baseline clause accepted; 85% floor and no-exclusion clauses retained)
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch delivers the #737 remainder recorded as #903 Operator Follow-ups 4, 5, 6, 10 and 11, entirely inside test infrastructure: F-1/F-2 with R1 and R2, F-3 report-only detection, the four I-3 splits as pure moves, and recorded decisions for N-2 and F-6.

Changes since the prior review (`c208981c6`..`a26648830`):

- `b8eb85631`: option 1 decision record and the AC-24 amendment line in `spec.md`.
- `048d76cd8`: merge of `origin/main` (`fa27cd5ed`); no conflict touched a branch code file.
- `a26648830`: pre-mortem and the seeded shuffled run of the 13 touched and consumer suites (742 / 742).
- PR #956 description refreshed (prior DOC-1 fixed).

Three blocking findings (COV-2, AC-CHK-1, TEST-1) are all within the Write Set and classified `autonomous`. Thirteen non-blocking findings (CR-F1..CR-F8, DOC-2, DOC-3, DOC-4, PLAN-1, EV-3) are listed in the code review and feature audit; the operator ruling requires all of them to be fixed in this pass.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- FAIL `.claude/rules/general-unit-test.md` on Scenario Completeness (TEST-1) and on the repo-wide coverage figure of the on-disk file (COV-2)
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- FAIL `.claude/rules/powershell.md` coverage row (COV-2, on-disk scoped file); code change and test structure PASS with non-blocking consistency findings (CR-F2)
- N/A TypeScript, Python, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-10-16 20:49:16 UTC at HEAD `a26648830`, base `origin/main` @ `fa27cd5ed`), `issue.md`, `spec.md`, `plan.2026-10-15T17-44.md`, the evidence folder (including the three records added since the prior review), the on-disk `artifacts/pester/` files, CI run records 38963921545 and 38928004778, and `gh pr view 956`.

**Temporary artifacts cleanup:**
- PASS `git status --porcelain` was empty at review start; no `SCRATCH/` or `artifacts/` path is in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller requested the full feature-review contract over the whole branch diff; the audit covers the full `origin/main...HEAD` diff. The caller's statement that criteria only CI can verify are pending-CI rather than findings is consistent with `acceptance-criteria-tracking` and is not a scope narrowing.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no output.
- The branch file list (170 paths) contains no path under `artifacts/` (none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`).
- The three new records are under `evidence/other/` and `evidence/qa-gates/`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds no project; all changed code is under `tests/scripts/`, covered by the root entry `path: "."` (T4). Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Seeded shuffled run (seed 935) of the 13 touched and consumer suites: 742 / 742 (`evidence/qa-gates/shuffled-suite-run.2026-10-16T20-48.md`). |
| Isolation | PASS | Each row targets one helper or one fixture shape. |
| Fast execution | PASS | In-memory fixtures; no process or file I/O in new rows. |
| Determinism | PASS | Grep over the 18 files for `New-TemporaryFile`, `TestDrive`, `GetTempFileName`, `Get-Date`, `Start-Sleep`, `Start-Process`, `ProcessStartInfo`: matches only in comments, string fixtures and a pre-existing string comparison (`EnforcementHooksNoPythonInvocation.Helpers.ps1` line 394). |
| Readability | PASS | Arrange-Act-Assert comments; non-blocking header gaps CR-F7. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell coverage, on-disk file) | FAIL | `artifacts/pester/powershell-coverage.xml` reads 10.82% because it holds a 13-suite scoped run (COV-2). Regenerate a repository-scope run. |
| Line >= 85% repo-wide (PowerShell coverage, CI) | PASS | Run 38963921545 on `048d76cd8`: 89.66% (16531/18437). Below the 90.42% baseline; that clause of AC-24 is accepted under option 1. |
| Branch >= 75% | Not evaluated | Pester reports no branch metric, so the branch threshold does not apply to this language (`.claude/rules/powershell.md`). |
| No regression on changed lines | PASS | 0 production lines changed. |
| Positive / negative / edge | FAIL | TEST-1: no rows for the `switch`, loop, `trap`, `else` and `elseif` shapes of `Test-EpicStateIsolationConditionalAncestor` that the spec Test Strategy requires. |
| Coverage exclusion policy | PASS | `config/poshqc-coverage.json` is not in the diff; no production path is excluded. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% line coverage (16381/18116, CI run 38730332356 at `adb9aa5f0`). Post-change: 89.66% line coverage (16531/18437, CI run 38963921545 at `048d76cd8`, a pull_request merge build). Change: -0.76 points against the baseline, all in unchanged production modules (per-file detail in `policy-audit.2026-10-16T16-02.md` section 1.2.1; the root and population are unchanged since). Code-identical earlier PR run 38922641167: 89.66% (16531/18437). Local on-disk file: 10.82% (1994/18437, 13-suite scoped run; COV-2). New/changed-code coverage: 100.00% (0/0 production lines). Disposition: PASS for the CI figure against the 85% floor (the baseline clause of AC-24 is accepted under option 1; the floor is re-checked on the final head at P7-T6); FAIL for the on-disk file (COV-2). Evidence: `evidence/baseline/ci-baseline.2026-10-16T00-11.md`, `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`, `evidence/qa-gates/r3-ps-test-repo.2026-10-16T15-50.md`, CI artifact `poshqc-test-results` of run 38963921545, on-disk `artifacts/pester/powershell-coverage.xml`.
- TypeScript: N/A - no changed files on the branch.
- Python: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | New rows carry Arrange, Act and Assert sections. |
| Actionable assertion messages | PASS | `-Because` texts name the fixture case and, in F-3 rows, list the records received. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | Fixtures are in-memory strings; the closure row uses an injected reader. |
| Test file location | PASS | All suites and helpers under `tests/scripts/`. |
| File size <= 500 lines | PASS | `wc -l` at HEAD over all 18 files: maximum 454 (HookReference suite); HookReference helper 448; `EpicStateIsolation.Helpers.ps1` 433. |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Phase 0 and R1-R3 Phase 0 records exist under `evidence/baseline/`.

### 2.2 Design Principles

PASS with non-blocking findings: the shared `HookLiteral` pattern is still inlined once in the Discovery helper (CR-F5).

### 2.3 Module & File Structure

PASS. All 18 changed code files at or below 500 lines; the four I-3 splits are pure moves (multiset comparison of removed and added lines per split).

### 2.4 Naming, Docs, and Comments

PASS with non-blocking findings CR-F1, CR-F3, CR-F6, CR-F7, CR-F8 (header and comment accuracy).

### 2.5 After Making Changes - Toolchain Execution

| Stage | Result | Evidence |
|-------|--------|----------|
| 1 Formatting | PASS | `evidence/qa-gates/r3-ps-format.2026-10-16T15-17.md`; no code change since. |
| 2 Linting | PASS | `evidence/qa-gates/r3-ps-analyze.2026-10-16T15-18.md`; no code change since. |
| 3 Type checking | N/A | Not applicable to PowerShell. |
| 4 Architecture-boundary tests | N/A | No boundary test covers `tests/scripts/`. |
| 5 Unit tests | PASS | `evidence/qa-gates/r3-ps-test-repo.2026-10-16T15-50.md`; shuffled run 742 / 742 on the merged tree; Linux hook-suite job of run 38963921545 success. |
| 6 Contract / schema | N/A | No API or schema changed. |
| 7 Integration tests | N/A | No adapter changed. |

The fixes for TEST-1, CR-F1..CR-F8 change code files, so the full loop must run again after them.

### 2.6 Summarize and Document

PASS with non-blocking findings DOC-2 (PR description residue and stale coverage figure), DOC-3 (`spec.md` metadata), DOC-4 (`issue.md` path) and PLAN-1 (plan P7-T6 and P7-T10 acceptance rules conflict with the option 1 decision).

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| PoshQC format | PASS | R3 format pass with no change; no code change since. |
| PSScriptAnalyzer | PASS | R3 analyze returned without error. |
| Advanced functions (`CmdletBinding()`) | PASS (non-blocking finding) | Rule wording is "Prefer"; twelve new functions lack `[CmdletBinding()]` while six in the same new file have it (CR-F2). |
| `[OutputType()]` and typed parameters | PASS | Every new function declares `[OutputType()]` and typed parameters. |
| No mutable module state | PASS | No new script-scope state in helpers; `$script:EpicStateParseCache` is the documented memo (spec D6). |
| Policy files untouched | PASS | No path under `.claude/` or `.github/` in the diff. |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5 with `#Requires` | PASS | Every new suite starts with `#Requires -Version 7.0` and the Pester 5 module requirement. |
| Data-driven rows | PASS | `-ForEach` tables for R1, F-1, F-3 and CR-R1 rows. |
| Scenario completeness for F-1 | FAIL | TEST-1. |
| Per-row CI results (both jobs) | PASS on `048d76cd8`; final head pending | Run 38963921545: both PoshQC jobs success; Windows JUnit: Branches 16, Predicate 10, legacy guard 25, Discovery 365, HookReference 41, worktree-removal 47 + ManifestBranch 5, TargetResolution 20 + CallTarget 6, command-exemption 60 + Selectors 61, consumers 32 and 54; 0 failures each. |

## 5. Test Coverage Detail

All changed files are test suites or helpers under `tests/scripts/`, outside the coverage roots. No production line changed. The line-coverage difference against the 90.42% baseline seen in earlier PR runs is attribution in unchanged production modules, accepted for AC-24 by the option 1 decision. The on-disk local coverage file is a scoped run and must be replaced by a repository-scope run (COV-2).

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| Seeded shuffled run (merged tree) | 742 testcases, 742 passed (13 suites) |
| Split equations (shuffled run) | 47 + 5 = 52 (baseline 51); 20 + 6 = 26 (baseline 25); 60 + 61 = 121 (baseline 120); consumers 32 = 32, 54 = 54 |
| CI run 38963921545 (`048d76cd8`, Windows JUnit) | 10793 testcases, 0 failures, 0 errors, 10 disabled; split equations 52 / 26 / 121 and consumers 32 / 54 as in the shuffled run; `test-name-uniqueness` 5 and `BlastRadius.HistoricalRuns` 9, 0 failures |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format | No change (R3 pass; no code change since) |
| PoshQC analyze | Returned without error |
| Line counts | All 18 files <= 500 (maximum 454) |
| Determinism grep | 0 executable matches |
| Scope (`.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`, `artifacts/`) | 0 paths |

## 8. Gaps and Exceptions

### Identified Gaps

- COV-2 (blocking, autonomous): on-disk coverage file holds a scoped run.
- AC-CHK-1 (blocking, autonomous): AC-24 checked ahead of verification.
- TEST-1 (blocking, autonomous): F-1 edge-case rows missing.
- Non-blocking: CR-F1..CR-F8, DOC-2, DOC-3, DOC-4, PLAN-1, EV-3.
- PC-1 (pending CI, non-blocking): final-head confirmation of the CI-dependent criteria.

### Approved Exceptions

- AC-24 baseline clause: accepted by `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`. The 85% floor and the no-exclusion clause are not excepted.

### Removed/Skipped Tests

None removed or skipped.

## 9. Summary of Changes

### Commits in This PR/Branch (since the prior review)

- `c208981c6` cycle-3 re-audit artifacts
- `b8eb85631` option 1 decision and AC-24 amendment
- `048d76cd8` merge of `origin/main`
- `a26648830` pre-mortem and seeded shuffled run

### Files Modified

- Since the prior review: `spec.md`, `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`, `evidence/other/pre-mortem.2026-10-16T20-48.md`, `evidence/qa-gates/shuffled-suite-run.2026-10-16T20-48.md`, and the cycle-3 review artifacts. No code file.
- Branch total: the 18 Write Set code paths and feature-folder Markdown.

## 10. Compliance Verdict

### Overall Status: NOT COMPLIANT (3 blocking findings, all autonomous)

### Policy-by-Policy Summary

- General Unit Test Policy: FAIL on Scenario Completeness (TEST-1) and on the on-disk coverage figure (COV-2); other requirements PASS
- General Code Change Policy: PASS with non-blocking findings
- PowerShell code change and unit test policy: FAIL on the on-disk coverage row (COV-2) and the F-1 edge cases (TEST-1); format, analyze and test PASS
- Quality tiers and coverage exclusion policy: PASS
- Evidence location policy: PASS
- Tonality: PASS

### Metrics Summary

- PowerShell coverage: baseline 90.42%; code-identical PR CI 89.66% (run 38922641167); CI on `048d76cd8` 89.66% (run 38963921545); on-disk scoped file 10.82%.
- Changes and findings: 0 production lines changed; 3 blocking findings (autonomous); 13 non-blocking findings; criteria pending final-head CI (PC-1).

### Recommendation

Fix TEST-1, AC-CHK-1 and the non-blocking findings in one remediation pass, re-run the PowerShell toolchain loop including a repository-scope test run (which resolves COV-2), push, and complete Phase 7 (P7-T2..P7-T10) on the new head with the amended P7-T6 and P7-T10 acceptance rules (PLAN-1).

---

## Appendix A: Test Inventory

Unchanged from `policy-audit.2026-10-16T11-25.md` Appendix A; no row was added or removed since cycle 2. TEST-1 adds rows to the `F-1 non-compliant <Branch>` table.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (executor, via MCP):**
```
mcp__drm-copilot__run_poshqc_format
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test   (scan_folders omitted for the repository-scope run that resolves COV-2)
```

**Reviewer commands (check-only):**
```
git merge-base origin/main HEAD; git rev-parse origin/main
git diff --name-only origin/main...HEAD
git diff --stat 5bdf22d0f fa27cd5ed -- <11 edited branch files>
git diff origin/main...HEAD -- <split pairs>   (pure-move multiset comparison in the session scratchpad)
gh run list --branch bug/hook-test-isolation-737-remainder-935; gh run view 38963921545 --json jobs
gh pr view 956 --json body; gh pr view 959 --json state
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
wc -l <18 files>; grep -nE <banned APIs> <18 files>
```
