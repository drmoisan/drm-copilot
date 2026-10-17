# Policy Compliance Audit: Issue #935 — hook-test-isolation-737-remainder, cycle R4 confirming pre-push full-diff review

---

**Audit Date:** 2026-10-17 (timestamp 2026-10-17T04-42, UTC host clock)
**Branch:** `bug/hook-test-isolation-737-remainder-935-r4` (follow-on PR branch; not pushed since Phase 5; no PR yet)
**Base:** `main`; merge-base `7516050be5d03293f8964eb54e7bea9951d726ab` (the P6-T2 merge `009f7d0c7` brought `origin/main` in). `origin/main` has since moved to `87f3d8996745029d93b16c19751e5a55dca1b919` (PR #968, three commits); the review diff is the three-dot `git diff origin/main...HEAD`.
**Head reviewed:** `ae0d3a03b8c26879bb7ab67be37a149930f7669a` (local). The working tree also holds one uncommitted edit: the P6-T30 check-off in `remediation-plan.2026-10-16T20-56.md`, which P7-T1/P7-T3 commit by plan.
**Review scope:** full branch diff `origin/main...HEAD`: 78 paths, 9 PowerShell files under `tests/scripts/claude-hooks/` (1 created: `enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1`; 8 edited) and 69 feature-folder Markdown paths.
**Work mode:** `full-bug` (AC source: `spec.md` `## Acceptance Criteria`, AC-1..AC-26)
**Code under test:** 9 PowerShell test suites and test helpers; no production file changed.
**Prior review:** `remediation-inputs.2026-10-17T02-00.md` (verdict REMEDIATION_REQUIRED: blocking AC-CHK-2; 14 non-blocking findings), closed by Phase 6 of `remediation-plan.2026-10-16T20-56.md` (revision 7).

## Total Blocking Findings: 0

All 15 findings of the prior review are fixed at HEAD (verification table in the code review and in section 8 below). DOC-2 remains assigned to the orchestrator after S9.

This review records 8 new non-blocking findings (CR-H1, CR-H2, TEST-5, TEST-6 in the code review; DOC-7, DOC-8, DOC-9, EV-5 in the feature audit). The operator ruling requires every finding, blocking and non-blocking, to be fixed before the single push; under orchestrator note (5) of the remediation plan these findings return to the planner before P7-T1.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 (1 created, 8 edited; all under `tests/scripts/claude-hooks/`) | 19 new testcases on the branch since the PR #956 merge (6 TEST-1 rows, 1 CR-F4 row, 2 TEST-2 rows, 10 rows in the new Memo suite, of which 6 moved from the Discovery suite) plus one Discovery `AC-4` row for the Memo suite | Local repository-scope run (report `Pester (10/17/2026 04:22:37)`): 11149 testcases, 0 failures, 0 errors, 10 disabled (on-disk `artifacts/pester/pester-junit.xml`, read by this review); co-run of nine suites and isolated Discovery, HookReference and Memo runs all passed (`evidence/qa-gates/r4-rf-order-check.2026-10-17T04-12.md`); CI for this head has not run (no PR) | CI 90.42% line coverage (16381/18116, run 38730332356 on `adb9aa5f0`); local merged-tree control before the review fixes 89.65% (17025/18990, `evidence/qa-gates/r4-rf-merged-tree-test.2026-10-17T03-41.md`) | PASS against the 85% floor: on-disk `artifacts/pester/powershell-coverage.xml` 89.61% line coverage (17017/18990, repository-scope run, read by this review); CI figure for the final head is pending S9 (P7-T6) | 100.00% (0/0 production lines changed; no changed file is in the `config/poshqc-coverage.json` roots) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 69 feature-folder documents and evidence files | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `evidence/baseline/ci-baseline.2026-10-16T00-11.md` (CI run 38730332356: covered 16381, missed 1735, 90.42% line coverage); local merged-tree control `evidence/qa-gates/r4-rf-merged-tree-test.2026-10-17T03-41.md` (covered 17025, missed 1965, 89.65%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, report stamp `Pester (10/17/2026 04:22:37)`, written by the repository-scope run recorded in `evidence/qa-gates/r4-ps-test-repo.2026-10-17T04-25.md`; this review read the root LINE counter directly: missed 1973, covered 17017 (89.61%) - PASS against the 85% line coverage floor
- PowerShell on-disk file provenance: coverage file time 00:23 local (04:23 UTC), JUnit file time 00:25 local, both after the last scoped run of the cycle (P6-T23 at 04:12 UTC); the JUnit file reports 11149 testcases, so it is the repository-scope run and not a scoped run
- PowerShell latest CI figure (former PR #956 head `048d76cd8`): run 38963921545, 89.66% (16531/18437); the CI figure for this branch head is pending S9 (P7-T6)
- PowerShell AC-24 disposition: `evidence/other/cov1-decision-option1.2026-10-16T20-38.md` (baseline clause accepted; 85% floor and no-exclusion clauses retained); AC-24 is unchecked pending S9
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

Phase 6 fixed the 15 findings of the 2026-10-17T02-00 review:

- `009f7d0c7`: merge of `origin/main` at `7516050be` (no conflict; no Write Set path changed by `main`).
- `496e7e622`: AC-CHK-2 (17 AC lines unchecked), CR-G1 (per-surface error capture for the variable-load report), CR-G2 (error guard on the `-Seam` path), CR-G3 (ordinal parse memo with a fail-before record), TEST-2 (two braced `ExpandableLeaf` rows), TEST-3 and TEST-4 (memo rows, placed in the new `enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1`, which also receives the six moved PERF rows), DOC-5 and DOC-6 (spec D7 and D6), CR-G4 to CR-G7 (headers, help texts, message, five `[CmdletBinding()]` attributes), EV-4 (validation record).
- `ae0d3a03b`: Phase 6 QA evidence and findings ledger.

No blocking finding remains. Eight non-blocking findings (two Low, six Info) remain; the operator ruling requires them to be fixed before the push.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md` (non-blocking finding TEST-5, fixture copy in the new Memo suite)
- PASS `.claude/rules/general-unit-test.md` (non-blocking finding TEST-6)
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`
- PASS `acceptance-criteria-tracking` skill (8 checked AC re-verified at this head; 18 unchecked pending S9)

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md`, with non-blocking findings CR-H1 (memo-writer help texts) and CR-H2 (comment reflow)
- N/A TypeScript, Python, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated at HEAD `ae0d3a03b`, base `origin/main` @ `87f3d8996`, merge-base `7516050be`), `issue.md`, `spec.md`, `plan.2026-10-15T17-44.md`, `remediation-plan.2026-10-16T20-56.md` (revision 7), every `r4-rf-*` evidence record, `evidence/qa-gates/r4-findings-status.2026-10-17T04-27.md`, `evidence/qa-gates/r4-ps-test-repo.2026-10-17T04-25.md`, `evidence/qa-gates/r4-plan-validation.2026-10-17T03-55.md`, `evidence/other/r4-ac-recheck-note.2026-10-17T03-42.md`, `evidence/regression-testing/r4-rf-cr-g3-fail-before.2026-10-17T03-46.md`, and the on-disk `artifacts/pester/` files.

**Temporary artifacts cleanup:**
- PASS: no `SCRATCH/` or `artifacts/` path is in the branch file list. `git status --porcelain` lists only the uncommitted P6-T30 check-off in `remediation-plan.2026-10-16T20-56.md`, which the plan assigns to P7-T1/P7-T3.

---

## Rejected Scope Narrowing

None detected. The caller requested the full feature-review contract over `git diff origin/main...HEAD`, which this audit covers. The caller's statement that 18 criteria are intentionally unchecked pending S9 is consistent with `acceptance-criteria-tracking` (`### CI-Dependent Criteria`) and is not a narrowing.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no output.
- The branch file list (78 paths) contains no path under `artifacts/` (none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`).
- Every Phase 6 record is under `evidence/qa-gates/`, `evidence/other/` or `evidence/regression-testing/`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds no project; all changed code is under `tests/scripts/`, covered by the root entry (T4). Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Co-run of the nine touched and consumer suites and isolated runs of Discovery (372), HookReference (44) and Memo (10) give equal per-suite counts (`r4-rf-order-check.2026-10-17T04-12.md`). This review traced each Memo row for order dependence: every row builds its own inputs (distinct census paths `perf-a` to `perf-e`, a fresh reader instance per row, or a fresh memo set after the reset row), the CR-G3 row parses both texts within the row, and the TEST-4 row populates all four memos in its own Arrange. No row reads a memo entry written by another row. The runner does not randomise order within a container (limitation recorded in the order-check record); the direct seeded shuffle stays with orchestrator note (7). |
| Isolation | PASS | CR-G1: the Describe BeforeAll catches a report-build throw per surface and records the message; the `AC-5b` row of that surface asserts on it, and every other row of the Describe still runs (spec D7 records the semantics, including the `F-3 non-vacuity` row reading an empty report). |
| Fast execution | PASS | Discovery suite 222.758 s before PERF and 78.931 s after under the MCP runner (relative figures); the Memo suite is in-memory only. |
| Determinism | PASS | `grep -n -E 'New-TemporaryFile|TestDrive|GetTempFileName|Get-Date|Start-Sleep|Start-Process|ProcessStartInfo|Get-Random'` over the nine code files, re-run by this review: six matches, at the lines and with the classifications recorded in `r4-rf-determinism-search.2026-10-17T04-26.md` (comments, one detection token, string fixtures); none in the Memo suite. |
| Readability | PASS | Arrange-Act-Assert comments in every new row; non-blocking finding TEST-6 on one assertion. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell coverage, on-disk file) | PASS | `artifacts/pester/powershell-coverage.xml`, repository-scope run `Pester (10/17/2026 04:22:37)`: 17017/18990 = 89.61%. |
| Line >= 85% (PowerShell coverage, CI on the final head) | PASS on the latest CI figure; final head pending S9 | Run 38963921545 on `048d76cd8`: 89.66%. This branch head has no CI yet; P7-T6 records the final-head figure. |
| Branch >= 75% | Not evaluated | Pester reports no branch metric, so the branch threshold does not apply to this language (`.claude/rules/powershell.md`). |
| New-file and modified-file thresholds | PASS | The new file and the eight modified files are test suites and test helpers under `tests/`, which the coverage configuration keeps out of the denominator by policy; 0 production lines changed. |
| No regression on changed lines | PASS | 0 production lines changed. |
| Positive / negative / edge | PASS | TEST-2 braced rows, TEST-3 rows (a) to (d), TEST-4 precondition, CR-G3 letter-case row and the CR-G2 missing-suite case are present and passing. Non-blocking TEST-6 asks to pin one scanned finding's text. |
| Coverage exclusion policy | PASS | `config/poshqc-coverage.json` is not in the diff; no production path is excluded. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% line coverage (16381/18116, CI run 38730332356 at `adb9aa5f0`); local merged-tree control before the review fixes 89.65% (17025/18990). Post-change: 89.61% line coverage (17017/18990, on-disk repository-scope run, report `Pester (10/17/2026 04:22:37)`). Change: -0.04 points (8 lines) against the local control with no production file changed, which matches the attribution variation recorded in earlier cycles; the latest CI figure (89.66%, run 38963921545 on the former PR #956 head) is below the CI baseline, which AC-24 accepts under option 1. New/changed-code coverage: 100.00% (0/0 production lines). Disposition: PASS against the 85% floor for the on-disk repository-scope file; the final-head CI figure is pending S9 (P7-T6). Evidence: `evidence/baseline/ci-baseline.2026-10-16T00-11.md`, `evidence/qa-gates/r4-rf-merged-tree-test.2026-10-17T03-41.md`, `evidence/qa-gates/r4-ps-test-repo.2026-10-17T04-25.md`, `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`, on-disk `artifacts/pester/powershell-coverage.xml`.
- TypeScript: N/A - no changed files on the branch.
- Python: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | New rows carry Arrange, Act and Assert comments. |
| Actionable assertion messages | PASS | CR-G6 corrected the shared `R1 does not identify <Case>` message; new rows carry case-specific `-Because` texts. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | All new fixtures are in-memory strings or in-memory reader tables. The TEST-4 row dot-sources a committed helper located from `$PSScriptRoot`; `Get-EpicStateSourceReader` for `/synthetic-worktrees/other` creates a reader without reading a file. |
| Test file location | PASS | All suites and helpers under `tests/scripts/claude-hooks/`. |
| File size <= 500 lines | PASS | `wc -l` at HEAD: Branches 438, HookReference helper 456, HookReference suite 478, Helpers 435, Discovery helper 381, Compliance helper 229, ManifestBranch 92, Discovery suite 368, Memo suite 206. The fixes proposed by this review add at most about +3 lines to any file (TEST-6 +1; TEST-5 removes about 30 lines from the Memo suite). |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Phase 6 records the pre-state (`r4-rf-prestate`), the merge (`r4-rf-merge`), the merged-tree runner facts (`r4-rf-runner`) and a green merged tree before any fix (`r4-rf-merged-tree-test`).

### 2.2 Design Principles

PASS with non-blocking finding TEST-5: the Memo suite copies the `Get-FixtureReader` function and four fixture values of the Discovery suite verbatim (about 30 lines). The CR-G2 and CR-G3 fixes are minimal and keep the reader as the only file boundary.

### 2.3 Module & File Structure

PASS. All nine changed code files at or below 500 lines; the new suite is listed in spec `## Write Set` (Create).

### 2.4 Naming, Docs, and Comments

PASS with non-blocking findings CR-H1 (four help texts still read "Pure" for functions that write memos directly or through callees), CR-H2 (ragged comment wrapping left by the header edits), DOC-7, DOC-8, DOC-9 (spec text).

### 2.5 After Making Changes - Toolchain Execution

| Stage | Result | Evidence |
|-------|--------|----------|
| 1 Formatting | PASS | `evidence/qa-gates/r4-rf-ps-format.2026-10-17T03-56.md`: porcelain empty before and after the call. |
| 2 Linting | PASS | `evidence/qa-gates/r4-rf-ps-analyze.2026-10-17T03-56.md` and `r4-rf-cr-g7-analyze.2026-10-17T03-48.md`: calls returned (the runner raises on any finding). |
| 3 Type checking | N/A | Not applicable to PowerShell. |
| 4 Architecture-boundary tests | N/A | No boundary test covers `tests/scripts/`. |
| 5 Unit tests | PASS | `r4-rf-ps-test.2026-10-17T04-06.md` (three folders), `r4-rf-order-check.2026-10-17T04-12.md`, `r4-ps-test-repo.2026-10-17T04-25.md` (repository scope, 11149 testcases, 0 failures in the on-disk JUnit). |
| 6 Contract / schema | N/A | No API or schema changed. |
| 7 Integration tests | N/A | No adapter changed. |

The fixes for CR-H1, CR-H2, TEST-5 and TEST-6 change code files, so the full loop must run again after them, ending with a repository-scope run.

### 2.6 Summarize and Document

PASS with non-blocking findings DOC-7, DOC-8, DOC-9 (spec) and EV-5 (validation record names revision 5). DOC-2 (the PR description) is assigned to the orchestrator after S9 by the plan.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| PoshQC format | PASS | P6-T20 no change. |
| PSScriptAnalyzer | PASS | P6-T16 and P6-T21 returned. |
| Advanced functions (`CmdletBinding()`) | PASS | The five CR-G7 functions are advanced; `Get-EpicStateHookLiteral` emits elements, and its three callers iterate or wrap in `@(...)` (Discovery helper lines 240, 328, 341). |
| `[OutputType()]` and typed parameters | PASS | Every function edited in Phase 6 declares `[OutputType()]` and typed parameters. |
| No mutable module state | PASS | The four memos are the documented test-session exception (spec D6, D7); all use ordinal keys after CR-G3 and are reset at every dot-source of the Discovery helper. Non-blocking CR-H1 on help-text wording. |
| Policy files untouched | PASS | No path under `.claude/` or `.github/` in the diff. |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5 with `#Requires` | PASS | The new Memo suite and all changed suites start with `#Requires -Version 7.0` and the Pester 5 module requirement. |
| Data-driven rows | PASS | TEST-2 rows extend the `R1 identifies <Case>` table. |
| Fail-before for the CR-G3 fix | PASS | `evidence/regression-testing/r4-rf-cr-g3-fail-before.2026-10-17T03-46.md`: the Memo suite ran with the hashtable parse memo and the only failing testcase was `PERF parse memo keeps texts that differ only in letter case apart`. |
| Per-row CI results (both jobs) | Pending S9 | No CI on this branch head; orchestrator notes (2) and (4) record the 19 new rows and the Memo-suite `AC-4` row. |

## 5. Test Coverage Detail

All changed files are test suites or helpers under `tests/scripts/`, outside the coverage roots. No production line changed. The on-disk repository-scope figure (89.61%) is 8 covered lines below the merged-tree control (89.65%) with no production change, which is consistent with the Pester attribution variation recorded in earlier cycles; both are above the 85% floor.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| Local repository-scope run (`Pester (10/17/2026 04:22:37)`) | 11149 testcases, 0 failures, 0 errors, 10 disabled |
| Co-run (9 suites) | Discovery 372, HookReference 44, Branches 22, Memo 10, Predicate 10, legacy guard 25, ManifestBranch 5, no-python-invocation 32, epic-scope 54; all passed |
| Isolated runs | Discovery 372, HookReference 44, Memo 10; each equal to the co-run |
| Merged-tree run before the fixes | 11142 testcases, 0 failures (difference of 7: two TEST-2 rows, four new Memo rows, one Discovery `AC-4` row for the Memo suite) |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format | No change |
| PoshQC analyze | Returned without error |
| Line counts | All 9 files <= 500 (maximum 478) |
| Determinism grep | 0 executable matches |
| Scope (`.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`, `artifacts/`) | 0 paths |
| Plan validation | `mcp__drm-copilot__validate_orchestration_artifacts` (artifact_type `plan`) re-run by this review on `remediation-plan.2026-10-16T20-56.md` (revision 7, working tree with the P6-T30 check-off) and `plan.2026-10-15T17-44.md`: `ok: true` for both |

## 8. Gaps and Exceptions

### Identified Gaps

- Blocking: none.
- Non-blocking: CR-H1, CR-H2, TEST-5, TEST-6 (code review); DOC-7, DOC-8, DOC-9, EV-5 (feature audit).
- Prior findings: AC-CHK-2, CR-G1, CR-G2, CR-G3, TEST-2, TEST-3, TEST-4, DOC-5, DOC-6, CR-G4, CR-G5, CR-G6, CR-G7, PLAN-2, EV-4 verified fixed at HEAD.
- PC-1 (pending CI, no finding): final-head confirmation on the follow-on PR (main-plan P7-T2..P7-T10, orchestrator notes (2), (4), (6), (7), (8)).
- PC-3 (pending before the push, no finding): `origin/main` moved from `7516050be` to `87f3d8996` (PR #968: evidence and plan documents of issue #962 and one comment line in `scripts/ci/CiChangeScope.psm1`; no path under `tests/scripts/`, `.claude/hooks/` or `.codex/hooks/`). P7-T2 merges it and repeats the Discovery and repository-scope runs before the push.

### Approved Exceptions

- AC-24 baseline clause: accepted by `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`. The 85% floor and the no-exclusion clause are not excepted.
- PERF-3 supersession of the CR-N4 disposition, amended by CR-G1: operator direction recorded in `evidence/other/r4-perf-cr-n4-supersession.2026-10-17T00-55.md` and spec D7.

### Removed/Skipped Tests

None removed or skipped. Six rows moved from the Discovery suite to the Memo suite with names unchanged.

## 9. Summary of Changes

### Commits in This PR/Branch

- Re-base and planning: `841ce4b29`, `cbf1b26d9`, `8f3ef885b`, `e71972999`, `c5e9a77d3`, `eb4844b37`, `7b09e102d`, `769f65864`, `198f88108`, `0b649b632`, `538a78c9a`, plan revisions 5 to 7 (`ecc68c0b7`, `d48f58cf8` and predecessors)
- Execution Phases 0-5: `ff61c4dd5`, `f96b623ea`, `08130a03e`, `306c798de`, `58a355c8a`, `e93227f75`
- Phase 6: `009f7d0c7` (merge), `496e7e622`, `ae0d3a03b`

### Files Modified

- Code: the nine `CODE9` paths of the remediation plan.
- Documents: `spec.md`, `issue.md`, `plan.2026-10-15T17-44.md`, `remediation-plan.2026-10-16T20-56.md`, the 2026-10-16T20-56 and 2026-10-17T02-00 review artifacts and the evidence records listed above.

## 10. Compliance Verdict

### Overall Status: COMPLIANT (0 blocking findings; 8 non-blocking findings that the operator ruling requires to be fixed before the push)

### Policy-by-Policy Summary

- General Unit Test Policy: PASS with non-blocking finding TEST-6
- General Code Change Policy: PASS with non-blocking finding TEST-5
- PowerShell code change and unit test policy: PASS with non-blocking findings CR-H1, CR-H2
- Quality tiers and coverage exclusion policy: PASS
- Evidence location policy: PASS
- Acceptance-criteria tracking: PASS
- Tonality: PASS

### Metrics Summary

- PowerShell coverage: CI baseline 90.42%; latest CI 89.66% (former PR #956 head); on-disk repository-scope 89.61%.
- Changes and findings: 0 production lines changed; 0 blocking findings; 8 non-blocking findings; PC-1 and PC-3 pending.

### Recommendation

Under orchestrator note (5) and the operator ruling, return the 8 non-blocking findings to the planner, add their fix tasks before P7-T1, re-run the PowerShell toolchain loop ending with a repository-scope run, run the confirming review again, then resume at P7-T1 (main-movement merge, single push) and complete S9.

---

## Appendix A: Test Inventory (rows added or moved in Phase 6)

- HookReference suite, `R1 identifies <Case>`: `expandable braced bound by assignment`, `expandable braced scoped bound by assignment`.
- Memo suite, Describe `issue #935 PERF memo`: moved unchanged from the Discovery suite: `PERF census memo returns the cached records for a repeated file`, `PERF census memo recomputes for changed text`, `PERF census memo keys by path as well as text`, `PERF closure memo reads each file once for a repeated closure` (assertion now exact, TEST-3 (d)), `PERF closure memo recomputes for a reader with changed text`, `PERF memo starts empty when the helper is dot-sourced` (precondition widened, TEST-4); added: `PERF parse memo keeps texts that differ only in letter case apart`, `PERF reader memo returns one reader per repository root`, `PERF closure memo keys by library directory`, `PERF probe finding with supplied seams`.
- Discovery suite: `AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1 complies with the baseline isolation form for every closure seam` (discovered row).

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
git merge-base origin/main HEAD; git log --oneline HEAD..origin/main; git diff --stat HEAD...origin/main
git diff --name-only origin/main...HEAD; git diff origin/main...HEAD -- tests/; git diff 009f7d0c7 HEAD -- tests
git diff   (uncommitted P6-T30 check-off)
python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
wc -l <9 files>; Grep <banned APIs> over the 9 files
grep -oE '<counter type="LINE"...' artifacts/pester/powershell-coverage.xml; grep -c '<testcase ' and '<failure' artifacts/pester/pester-junit.xml
mcp__drm-copilot__validate_orchestration_artifacts (artifact_type plan) on plan.2026-10-15T17-44.md and remediation-plan.2026-10-16T20-56.md: ok true for both
```
