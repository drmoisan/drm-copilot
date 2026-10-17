# Policy Compliance Audit: Issue #935 — hook-test-isolation-737-remainder, cycle R4 pre-push full-diff review

---

**Audit Date:** 2026-10-17 (timestamp 2026-10-17T02-00, UTC host clock)
**Branch:** `bug/hook-test-isolation-737-remainder-935-r4` (follow-on PR branch; no PR yet)
**Base:** `main`; merge-base `cdc7bbc9945263f791c5627fea339e31ab53b21f` (the PR #956 merge). `origin/main` has moved to `b8fcd77905a51284cfbca54226a2da2a7916a836`; the review diff is the three-dot `git diff origin/main...HEAD`.
**Head reviewed:** `e93227f7584e79837334fe3d463fafcf11159993` (local, not pushed; the pushed remote branch is at `538a78c9a`). The working tree also holds one uncommitted edit: the P5-T12 check-off in `remediation-plan.2026-10-16T20-56.md`.
**Review scope:** full branch diff `origin/main...HEAD`: 54 paths, 8 PowerShell files under `tests/scripts/claude-hooks/` (all edited, none created on this branch) and 46 feature-folder Markdown paths.
**Work mode:** `full-bug` (AC source: `spec.md` `## Acceptance Criteria`, AC-1..AC-26)
**Code under test:** 8 PowerShell test suites and test helpers; no production file changed.
**Prior review:** `remediation-inputs.2026-10-16T20-56.md` (verdict REMEDIATION_REQUIRED: TEST-1, AC-CHK-1, COV-2; 13 non-blocking findings), closed by `remediation-plan.2026-10-16T20-56.md` Phases 0-5 together with the operator items PERF-1..PERF-5.

## Total Blocking Findings: 1

1. AC-CHK-2 (autonomous): commit `c5e9a77d3` checked AC-1..AC-23 and AC-26 in `spec.md` from CI run 38963921545 on the former PR #956 head `048d76cd8`. Cycle R4 then changed the suites and helpers that 17 of these criteria name (Branches, HookReference and Discovery suites, the four EpicStateIsolation helpers). The plan states that CI on the follow-on PR head supplies the final-head confirmations (orchestrator note (1)), so these items are checked ahead of verification on the final change. `acceptance-criteria-tracking` rule 4 and `### CI-Dependent Criteria` require them to stay unchecked until S9. Detail and fix in the feature audit.

All three prior blocking findings are fixed: TEST-1 (six F-1 rows), AC-CHK-1 (AC-24 unchecked with the S9 amendment sentence) and COV-2 (the on-disk coverage file holds a repository-scope run at 89.67%). The 13 prior non-blocking findings are fixed except DOC-2, which the plan assigns to the orchestrator after S9.

This review records 14 new non-blocking findings (code review and feature audit). The operator ruling requires all findings to be fixed before the single push.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 8 (0 created, 8 edited; all under `tests/scripts/claude-hooks/`) | 13 new testcases (6 TEST-1 rows, 1 CR-F4 row, 6 PERF rows); every existing row retained | Local repository-scope run (report `Pester (10/17/2026 01:37:47)`): 10806 testcases, 0 failures, 0 errors; co-run of 8 suites and isolated Branches and HookReference runs all passed (`evidence/qa-gates/r4-order-check.2026-10-17T01-27.md`); CI for this branch head has not run (no PR) | CI 90.42% line coverage (16381/18116, run 38730332356 on `adb9aa5f0`); local repository-scope control at the cycle start 89.67% (16532/18437, `evidence/baseline/r4-ps-test-repo.2026-10-17T00-12.md`) | PASS against the 85% floor: on-disk `artifacts/pester/powershell-coverage.xml` 89.67% line coverage (16532/18437, repository-scope run); equal to the local cycle-start control; CI figure for the final head is pending S9 (P7-T6) | 100.00% (0/0 production lines changed; no changed file is in the `config/poshqc-coverage.json` roots) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 46 feature-folder documents and evidence files | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `evidence/baseline/ci-baseline.2026-10-16T00-11.md` (CI run 38730332356: covered 16381, missed 1735, 90.42% line coverage); local repository-scope control `evidence/baseline/r4-ps-test-repo.2026-10-17T00-12.md` (covered 16532, missed 1905, 89.67%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, report stamp `Pester (10/17/2026 01:37:47)`, written by the repository-scope run recorded in `evidence/qa-gates/r4-ps-test-repo.2026-10-17T01-40.md`; this review read the root LINE counter directly: missed 1905, covered 16532 (89.67%) - PASS against the 85% line coverage floor
- PowerShell on-disk file provenance: file time 21:38 local (01:38 UTC) and `pester-junit.xml` 21:40 local, both after the last scoped run of the cycle (P5-T4 at 01:27 UTC); the JUnit file reports 10806 testcases, so it is the repository-scope run and not a scoped run
- PowerShell latest CI figure (former PR #956 head `048d76cd8`): run 38963921545, 89.66% (16531/18437); the CI figure for this branch head is pending S9 (P7-T6)
- PowerShell AC-24 disposition: `evidence/other/cov1-decision-option1.2026-10-16T20-38.md` (baseline clause accepted; 85% floor and no-exclusion clauses retained); AC-24 is unchecked pending S9
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

Cycle R4 fixes the findings of the 2026-10-16T20-56 review and implements the operator performance request for the Discovery suite:

- `f96b623ea`: six F-1 conditional-construct rows (TEST-1) and the balanced-brace `ExpandableLeaf` pattern with the `R1 does not identify unbalanced brace` row (CR-F4; fail-before recorded).
- `08130a03e`: twelve `[CmdletBinding()]` attributes, the shared `HookLiteral` pattern in `Get-EpicStateHookLiteral`, element emission in `Get-EpicStateVariableHookLoad`, and header corrections (CR-F1..CR-F3, CR-F5..CR-F8).
- `306c798de`: AC-24 unchecked with the S9 sentence, spec and issue metadata, and the main-plan P7-T6/P7-T10 option 1 rules (AC-CHK-1, EV-3, DOC-3, DOC-4, PLAN-1).
- `58a355c8a`: census, closure-node and reader memos; discovery data and probe seams passed from BeforeDiscovery; one Describe-level variable-load report; six PERF rows (PERF-1..PERF-4). Local Discovery suite time under the MCP runner fell from 222.758 s to 78.931 s with the row-name hash unchanged (PERF-5, relative figures).
- `e93227f75`: final QA evidence.

One blocking finding (AC-CHK-2, autonomous) and 14 non-blocking findings remain.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md` (non-blocking findings CR-G1, CR-G2)
- PASS `.claude/rules/general-unit-test.md` (non-blocking findings TEST-2, TEST-3, TEST-4 on scenario completeness of new code)
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`
- FAIL `acceptance-criteria-tracking` skill rule 4 (AC-CHK-2)

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md`, with non-blocking findings CR-G3 (case-insensitive parse memo under the new ordinal memos) and CR-G7 (advanced-function consistency)
- N/A TypeScript, Python, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-10-17 01:49:28 UTC at HEAD `e93227f75`, base `origin/main` @ `b8fcd7790`, merge-base `cdc7bbc99`), `issue.md`, `spec.md`, `plan.2026-10-15T17-44.md`, `remediation-plan.2026-10-16T20-56.md`, every `r4-*` evidence record, `evidence/other/ac24-checkbox-note.2026-10-17T00-47.md`, `evidence/regression-testing/r4-cr-f4-fail-before.2026-10-17T00-23.md`, `evidence/qa-gates/s9-ac-verification.2026-10-16T21-46.md`, and the on-disk `artifacts/pester/` files.

**Temporary artifacts cleanup:**
- PASS: no `SCRATCH/` or `artifacts/` path is in the branch file list. `git status --porcelain` lists only the uncommitted P5-T12 check-off in `remediation-plan.2026-10-16T20-56.md` (PLAN-2).

---

## Rejected Scope Narrowing

None detected. The caller requested the full feature-review contract over `git diff origin/main...HEAD`, which this audit covers. The caller's statement that AC-24 is intentionally unchecked pending S9 is consistent with `acceptance-criteria-tracking` and is not a narrowing.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no output.
- The branch file list (54 paths) contains no path under `artifacts/` (none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`).
- Every cycle-R4 record is under `evidence/baseline/`, `evidence/qa-gates/`, `evidence/other/` or `evidence/regression-testing/`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds no project; all changed code is under `tests/scripts/`, covered by the root entry (T4). Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Co-run of the eight touched and consumer suites and isolated runs of Branches (22) and HookReference (42) give equal counts (`r4-order-check.2026-10-17T01-27.md`). The six PERF rows use distinct paths (`perf-a` to `perf-d`) or fresh reader instances. The direct seeded shuffle was refused by the worktree guard (`r4-perf-shuffled-run.2026-10-17T01-10.md`); orchestrator note (7) runs it. Non-vacuity of one PERF assertion depends on Describe order (TEST-4, non-blocking). |
| Isolation | PASS (non-blocking finding) | The variable-load report moved into the Describe BeforeAll; a throw there now fails every row of `discovery guard (both hook surfaces)` instead of the AC-5b and F-3 rows, and the AC-5b `Should -Not -Throw` wraps only a hashtable read (CR-G1). The supersession record documents the change (`evidence/other/r4-perf-cr-n4-supersession.2026-10-17T00-55.md`). |
| Fast execution | PASS | Discovery suite 222.758 s before and 78.931 s after under the MCP runner with coverage (`r4-perf-timing-before`, `r4-perf-timing-after`); 91.929 s in the repository-scope JUnit. |
| Determinism | PASS | `grep -n -E 'New-TemporaryFile|TestDrive|GetTempFileName|Get-Date|Start-Sleep|Start-Process|ProcessStartInfo'` over the eight files, re-run by this review: six matches, all comments, detection tokens or string fixtures, at the lines recorded in `r4-determinism-search.2026-10-17T01-42.md`. No new clock read, process start or temporary file. |
| Readability | PASS | Arrange-Act-Assert comments in every new row; non-blocking wording findings CR-G4, CR-G5, CR-G6. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell coverage, on-disk file) | PASS | `artifacts/pester/powershell-coverage.xml`, repository-scope run `Pester (10/17/2026 01:37:47)`: 16532/18437 = 89.67%. |
| Line >= 85% (PowerShell coverage, CI on the final head) | PASS on the latest CI figure; final head pending S9 | Run 38963921545 on `048d76cd8`: 89.66%. This branch head has no CI yet; P7-T6 records the final-head figure. |
| Branch >= 75% | Not evaluated | Pester reports no branch metric, so the branch threshold does not apply to this language (`.claude/rules/powershell.md`). |
| No regression on changed lines | PASS | 0 production lines changed. |
| Positive / negative / edge | PASS (non-blocking findings) | TEST-1 rows present and passing. Gaps in new code: no positive row for the braced `ExpandableLeaf` alternative (TEST-2); no row for the reader memo identity, the `LibraryDirectory` part of the successor key, or `Get-EpicStateProbeFinding -Seam` (TEST-3). |
| Coverage exclusion policy | PASS | `config/poshqc-coverage.json` is not in the diff; no production path is excluded. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% line coverage (16381/18116, CI run 38730332356 at `adb9aa5f0`); local repository-scope control at the cycle start 89.67% (16532/18437). Post-change: 89.67% line coverage (16532/18437, on-disk repository-scope run, report `Pester (10/17/2026 01:37:47)`). Change: 0.00 points against the local control; the latest CI figure (89.66%, run 38963921545 on the former PR #956 head) is below the CI baseline, which AC-24 accepts under option 1. New/changed-code coverage: 100.00% (0/0 production lines). Disposition: PASS against the 85% floor for the on-disk repository-scope file; the final-head CI figure is pending S9 (P7-T6). Evidence: `evidence/baseline/ci-baseline.2026-10-16T00-11.md`, `evidence/baseline/r4-ps-test-repo.2026-10-17T00-12.md`, `evidence/qa-gates/r4-ps-test-repo.2026-10-17T01-40.md`, `evidence/qa-gates/r4-coverage-delta.2026-10-17T01-41.md`, `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`, on-disk `artifacts/pester/powershell-coverage.xml`.
- TypeScript: N/A - no changed files on the branch.
- Python: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | New rows carry Arrange, Act and Assert comments. |
| Actionable assertion messages | PASS (non-blocking finding) | `-Because` texts name the case; the shared `R1 does not identify <Case>` text is inaccurate for the new `unbalanced brace` case (CR-G6). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | All new fixtures are in-memory strings or in-memory reader tables. The row `PERF memo starts empty when the helper is dot-sourced` dot-sources a committed helper located from `$PSScriptRoot`, which the suite header allows. |
| Test file location | PASS | All suites and helpers under `tests/scripts/claude-hooks/`. |
| File size <= 500 lines | PASS | `wc -l` at HEAD: Branches 438, HookReference helper 456, HookReference suite 466, Helpers 435, Discovery helper 373, Compliance helper 227, ManifestBranch 92, Discovery suite 458. The fixes for TEST-3, TEST-4, CR-G1 and CR-G3 add rows to the Discovery suite; the fix text in the code review keeps the total at or below 500. |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Cycle R4 Phase 0 records exist under `evidence/baseline/` (`r4-branch-state`, `r4-phase0-instructions-read`, `r4-token-counts`, `r4-ps-format`, `r4-ps-analyze`, `r4-ps-test`, `r4-ps-test-repo`, `r4-coverage-mode`).

### 2.2 Design Principles

PASS with non-blocking findings. The memo layer is small and separated from I/O (the reader stays the only file boundary). CR-G2: the new `-Seam` path of `Get-EpicStateProbeFinding` bypasses the error guard of the scan path. CR-G3: the pre-existing parse memo uses case-insensitive keys under the new ordinal memos.

### 2.3 Module & File Structure

PASS. All eight changed code files at or below 500 lines.

### 2.4 Naming, Docs, and Comments

PASS with non-blocking findings CR-G4, CR-G5, CR-G6 (header and comment accuracy), DOC-5 and DOC-6 (spec).

### 2.5 After Making Changes - Toolchain Execution

| Stage | Result | Evidence |
|-------|--------|----------|
| 1 Formatting | PASS | `evidence/qa-gates/r4-ps-format.2026-10-17T01-12.md`: porcelain empty before and after the call. |
| 2 Linting | PASS | `evidence/qa-gates/r4-ps-analyze.2026-10-17T01-12.md`: call returned (the runner raises on any finding). |
| 3 Type checking | N/A | Not applicable to PowerShell. |
| 4 Architecture-boundary tests | N/A | No boundary test covers `tests/scripts/`. |
| 5 Unit tests | PASS | `r4-ps-test.2026-10-17T01-22.md` (three folders), `r4-order-check.2026-10-17T01-27.md`, `r4-ps-test-repo.2026-10-17T01-40.md` (repository scope, 10806 testcases, 0 failures in the on-disk JUnit). |
| 6 Contract / schema | N/A | No API or schema changed. |
| 7 Integration tests | N/A | No adapter changed. |

The fixes for the findings of this review change code files, so the full loop must run again after them, ending with a repository-scope run.

### 2.6 Summarize and Document

PASS with non-blocking findings DOC-5 (spec does not record the PERF design), PLAN-2 (P5-T12/P6-T1 wording and plan status) and EV-4 (plan validation not recorded). DOC-2 (the PR description) is assigned to the orchestrator after S9 by the plan.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| PoshQC format | PASS | R4 P5-T1 no change. |
| PSScriptAnalyzer | PASS | R4 P5-T2 returned; P2-T7 analyze directly after the CR-F2 edits returned. |
| Advanced functions (`CmdletBinding()`) | PASS (non-blocking finding) | The twelve CR-F2 functions and the three new memo functions are advanced. Five functions edited in this cycle remain non-advanced (CR-G7). |
| `[OutputType()]` and typed parameters | PASS | Every new function declares `[OutputType()]` and typed parameters. |
| No mutable module state | PASS (non-blocking finding) | Three new script-scope memos (`$script:EpicStateCensusCache`, `$script:EpicStateClosureNodeCache`, `$script:EpicStateReaderCache`) extend the documented test-session memo exception of `$script:EpicStateParseCache` by operator direction (PERF-1); each is reset at every dot-source of the Discovery helper. The spec does not yet record the extension (DOC-5). |
| Policy files untouched | PASS | No path under `.claude/` or `.github/` in the diff. |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5 with `#Requires` | PASS | All changed suites start with `#Requires -Version 7.0` and the Pester 5 module requirement. |
| Data-driven rows | PASS | TEST-1 rows extend the `F-1 non-compliant <Branch>` table; the CR-F4 row extends `R1 does not identify <Case>`. |
| Scenario completeness for F-1 | PASS | Rows for `switch`, `foreach`, `while`, `trap`, `else` and `elseif` added; each reaches a branch of `Test-EpicStateIsolationConditionalAncestor` (Helpers lines 120-124) because the Mock's ancestor chain passes a `StatementBlockAst` under the named construct. |
| Per-row CI results (both jobs) | Pending S9 | No CI on this branch head; orchestrator note (4) records the 13 new rows from the Linux JUnit and P7-T3/P7-T4 record the rest. |

## 5. Test Coverage Detail

All changed files are test suites or helpers under `tests/scripts/`, outside the coverage roots. No production line changed. The on-disk repository-scope figure (89.67%) equals the local cycle-start control, so the cycle changed no production coverage.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| Local repository-scope run (`Pester (10/17/2026 01:37:47)`) | 10806 testcases, 0 failures, 0 errors, 10 disabled |
| Co-run (8 suites) | Discovery 371, Branches 22, HookReference 42, Predicate 10, legacy guard 25, ManifestBranch 5, no-python-invocation 32, epic-scope 54; all passed |
| Discovery suite row set | 365 pre-existing names, hash `e79dd612...` before and after; 371 total after (365 + 6 PERF rows) |
| Discovery suite time (MCP runner, coverage on; relative) | 222.758 s before, 78.931 s after |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format | No change |
| PoshQC analyze | Returned without error |
| Line counts | All 8 files <= 500 (maximum 466) |
| Determinism grep | 0 executable matches |
| Scope (`.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`, `artifacts/`) | 0 paths |

## 8. Gaps and Exceptions

### Identified Gaps

- AC-CHK-2 (blocking, autonomous): AC items checked against the former PR #956 head after cycle R4 changed the files they name.
- Non-blocking: CR-G1..CR-G7, TEST-2, TEST-3, TEST-4, DOC-5, DOC-6, PLAN-2, EV-4.
- PC-1 (pending CI, no finding): final-head confirmation on the follow-on PR (P7-T2..P7-T10, orchestrator notes (2), (4), (6), (7)).
- PC-2 (pending before the push, no finding): `origin/main` moved from `cdc7bbc99` to `b8fcd7790` and adds hook suites (for example `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`) and the PoshQC shard and coverage-merge changes of PR #959. P6-T2 merges `origin/main`, re-runs the Discovery suite and repeats the repository-scope run; the local evidence in this cycle predates that merge.

### Approved Exceptions

- AC-24 baseline clause: accepted by `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`. The 85% floor and the no-exclusion clause are not excepted.
- PERF-3 supersession of the CR-N4 disposition: operator direction recorded in `evidence/other/r4-perf-cr-n4-supersession.2026-10-17T00-55.md`.

### Removed/Skipped Tests

None removed or skipped.

## 9. Summary of Changes

### Commits in This PR/Branch

- Re-base and planning: `841ce4b29`, `cbf1b26d9`, `8f3ef885b`, `e71972999`, `c5e9a77d3` (AC check-off from run 38963921545), `eb4844b37`, `7b09e102d`, `769f65864`, `198f88108`, `0b649b632`, `538a78c9a`
- Execution: `ff61c4dd5`, `f96b623ea`, `08130a03e`, `306c798de`, `58a355c8a`, `e93227f75`

### Files Modified

- Code: the eight `CODE8` paths of the remediation plan.
- Documents: `spec.md`, `issue.md`, `plan.2026-10-15T17-44.md`, `remediation-plan.2026-10-16T20-56.md`, the 2026-10-16T20-56 review artifacts and the evidence records listed above.

## 10. Compliance Verdict

### Overall Status: NOT COMPLIANT (1 blocking finding, autonomous)

### Policy-by-Policy Summary

- General Unit Test Policy: PASS with non-blocking findings (TEST-2, TEST-3, TEST-4, CR-G1)
- General Code Change Policy: PASS with non-blocking findings
- PowerShell code change and unit test policy: PASS with non-blocking findings (CR-G3, CR-G7)
- Quality tiers and coverage exclusion policy: PASS
- Evidence location policy: PASS
- Acceptance-criteria tracking: FAIL (AC-CHK-2)
- Tonality: PASS

### Metrics Summary

- PowerShell coverage: CI baseline 90.42%; latest CI 89.66% (former PR #956 head); on-disk repository-scope 89.67%.
- Changes and findings: 0 production lines changed; 1 blocking finding (autonomous); 14 non-blocking findings; PC-1 and PC-2 pending.

### Recommendation

Fix AC-CHK-2 and the 14 non-blocking findings in a revision of `remediation-plan.2026-10-16T20-56.md` inserted before P6-T1, re-run the PowerShell toolchain loop ending with a repository-scope run, then resume at P6-T1 (main merge check, single push) and complete S9.

---

## Appendix A: Test Inventory (rows added in cycle R4)

- Branches suite, `F-1 non-compliant <Branch>`: `ESR mock inside switch`, `ESR mock inside foreach`, `ESR mock inside while`, `ESR mock inside trap`, `ESR mock inside a matching Get-Command guard with else`, `ESR mock inside a matching Get-Command guard with elseif`.
- HookReference suite, `R1 does not identify <Case>`: `unbalanced brace`.
- Discovery suite, Describe `issue #935 PERF memo`: `PERF census memo returns the cached records for a repeated file`, `PERF census memo recomputes for changed text`, `PERF census memo keys by path as well as text`, `PERF closure memo reads each file once for a repeated closure`, `PERF closure memo recomputes for a reader with changed text`, `PERF memo starts empty when the helper is dot-sourced`.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (executor, via MCP):**
```
mcp__drm-copilot__run_poshqc_format
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test   (scan_folders omitted for the final repository-scope run)
```

**Reviewer commands (check-only):**
```
git merge-base origin/main HEAD; git rev-parse origin/main
git diff --name-only origin/main...HEAD; git diff origin/main...HEAD -- tests/
git diff HEAD   (uncommitted P5-T12 check-off)
git log --oneline cdc7bbc99..origin/main; git diff --stat cdc7bbc99 origin/main -- tests/scripts .claude/hooks .codex/hooks config scripts/powershell/PoshQC
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
wc -l <8 files>; grep -n -E <banned APIs> <8 files>
grep -oE '<counter type="LINE"...' artifacts/pester/powershell-coverage.xml; grep -oE '<testsuites ...' artifacts/pester/pester-junit.xml
mcp__drm-copilot__validate_orchestration_artifacts (artifact_type plan) on plan.2026-10-15T17-44.md and remediation-plan.2026-10-16T20-56.md: ok true for both
```
