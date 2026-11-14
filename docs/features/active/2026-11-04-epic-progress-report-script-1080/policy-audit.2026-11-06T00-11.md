# Policy Compliance Audit: Get-EpicProgressReport (Issue #1080), Re-audit after Remediation Cycle 1

**Audit Date:** 2026-11-06
**Branch:** `feature/epic-progress-report-script` @ `79d4e3de07731e97e8dcd9e52c44d08a116bab8d`
**Base:** `main`; merge base `02fb8aada3b10aaf3ac6812e29400c2302a3b372` (equal to the origin/main tip after `git fetch origin main`)
**Work Mode:** minor-audit (AC source: `issue.md` `## Acceptance Criteria`)
**Prior review:** `policy-audit.2026-11-05T23-23.md`, `code-review.2026-11-05T23-23.md`, `feature-audit.2026-11-05T23-23.md`; remediation inputs `remediation-inputs.2026-11-05T23-27.md`; remediation plan `remediation-plan.2026-11-05T23-27.md` (all tasks checked)
**Code Under Test:**
- `scripts/dev-tools/Get-EpicProgressReport.ps1` (NEW, 474 logical lines)
- `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (NEW, 661 logical lines)
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (NEW, 455 logical lines)
- `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` (NEW, 601 logical lines)
- Documentation and evidence only: 56 files under `docs/features/active/2026-11-04-epic-progress-report-script-1080/` and `docs/features/potential/promoted/2026-11-04-epic-progress-report-script.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 production, 2 test | 96 new; 14394 tree-wide | 96 pass, 0 fail (reviewer); 14394 run, 0 fail (executor R1 P2-T7) | 93.80% lines repo-wide (derived; both new files absent at baseline) | 93.85% lines repo-wide (derived, see 1.2.1); 91.18% and 100% lines per new file | 91.18% (Get-EpicProgressReport.ps1), 100% (Get-EpicProgressReport.Logic.ps1) |
| Python | 0 files | N/A | N/A | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

Branch coverage: PowerShell is exempt from the branch threshold (Pester emits no branch counter; `.claude/rules/powershell.md`). No branch-capable language has changed files.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files in the branch diff
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files in the branch diff
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-04-epic-progress-report-script-1080/evidence/baseline/coverage-baseline.2026-11-04T20-39.md` (both new files COVERAGE-ABSENT) and `evidence/remediation-baseline/coverage-baseline.2026-11-05T23-41.md` (cycle-1 baseline: 90.82% and 100%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (R1 P2-T4 scoped run, 2026-11-05 23:47 UTC) plus `evidence/qa-gates/coverage-final.2026-11-05T23-47.md` and a reviewer re-measurement at HEAD
- Per-language comparison summary: section 1.2.1 of this audit

---

## Executive Summary

This is the re-audit after remediation cycle 1. The remediation changed only the four change-set code files: it pinned the inclusive 2-minute recent-velocity boundary, clamped elapsed hours at zero for a future start, made kickoff-row parsing tolerate cell whitespace and raise a clear error for a non-numeric wave cell, and added a warning when `git fetch` exits non-zero through a new `Get-EpicProgressLastExitCode` seam. `issue.md` and `config/` are unchanged by the remediation.

The reviewer independently re-ran format, analyze, and test at HEAD (PowerShell 7, Windows host): formatter differences 0 and PSSA findings 0 on all four files; 96 of 96 tests passed; scoped JaCoCo coverage 91.18% (93/102) and 100% (213/213). The reviewer ran six mutants on a scratch copy of the change set (one per remediated behavior plus an always-warn mutant); all six were killed by exactly the intended new test. All four remediation findings are resolved.

The reviewer also ran the kickoff parser over all nine `docs/features/epics/*/epic-kickoff.md` files in the repository. Three of them (`cleanup-merged-worktrees-hardening`, `orchestrator-state-contract-correctness`, `worktree-scoped-state-resolution`) contain a wave-summary table (`| wave | features | width |`) whose rows have a numeric first cell; the parser treats each such row as a feature row (issue `0`, `1`, `2`; the `width` value read as the wave; empty plan path). The behavior is identical at the prior head `52224c60c` and at HEAD, so the remediation did not introduce it, but it was not detected by the prior review. A stubbed end-to-end run against the `cleanup-merged-worktrees-hardening` kickoff reports 11 features instead of 8, three phantom Pending features, a phantom wave 4, and a wave-parallel estimate of 8 h 45 min instead of 7 h 30 min. This is recorded as one Blocking finding (CR-1, autonomous) because the tool's stated purpose is a correct report for any epic, and the defect reproduces on a third of the repository's own kickoff files.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ⚠️ `.claude/rules/general-unit-test.md` (scenario completeness gap: non-feature numeric table rows untested; see section 8)
- ✅ `.claude/rules/quality-tiers.md` (`scripts/dev-tools` is classified T4 in `quality-tiers.yml`)

**Language-specific policies evaluated:**
- N/A Python (no changed files; confirmed no `.py` file added)
- ✅ `.claude/rules/powershell.md`
- N/A Bash, JSON, TypeScript, C#

**Temporary artifacts cleanup:**
- ✅ `git status --porcelain` is empty at HEAD and after every reviewer probe.
- ✅ Reviewer probe scripts, the mutation copy, and the reviewer coverage XML were written outside the repository (session scratchpad and the user temporary directory); the mutation copy was deleted after the run.

---

## Rejected Scope Narrowing

None. The caller prompt stated "no scope narrowing" and did not attempt to narrow the audit. The caller's note that a stop-hook message about the main checkout's coverage data is unrelated to this branch does not narrow scope; it was taken into account only in that no artifact was altered in response to such a message. The audit covers the full diff `02fb8aada..79d4e3de0`.

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exit code: 0, no output.
- The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (`git diff --name-only <merge-base> HEAD` filtered for `^artifacts/` returned no rows).
- All evidence is under `docs/features/active/2026-11-04-epic-progress-report-script-1080/evidence/{baseline,remediation-baseline,qa-gates,regression-testing,other}/`.
- Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Mocks registered in `BeforeEach`; the new fetch exit code is fixture state (`$script:fetchExitCode` reset to 0 in `BeforeEach`). Executor evidence: seeded shuffles 1080, 2026, 7 (`isolation-shuffle.2026-11-05T23-50.md`, 818 tests each, 0 failed) and a fresh single-process run over `tests/scripts` (`isolation-fresh-tests-scripts.2026-11-06T00-01.md`, 14394 tests, 0 failed). |
| **Isolation** | ✅ PASS | Each new `It` asserts one behavior. |
| **Fast Execution** | ✅ PASS | Reviewer run of both suites completes in a few seconds; no sleeps or waits. |
| **Determinism** | ✅ PASS | Clock and exit code mocked in the report tests; `Get-EpicProgressLastExitCode` is mocked so the ambient `$LASTEXITCODE` never decides a report test. |
| **Readability & Maintainability** | ✅ PASS | Behavior-stating `It` names; the boundary test carries a comment explaining why 120 s equals 2/60 h exactly. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Original baseline `evidence/baseline/coverage-baseline.2026-11-04T20-39.md`; cycle baseline `evidence/remediation-baseline/coverage-baseline.2026-11-05T23-41.md` (90.82%, 100%). |
| **No Coverage Regression** | ✅ PASS | Main script 90.82% -> 91.18%; logic 100% -> 100%. Changed-line coverage is 100%: no missed line lies in any remediated statement (reviewer missed-line list: 201, 215, 229, 290, 302, 466-472). |
| **New Code Coverage** | ✅ PASS | 91.18% and 100% line coverage, both at or above the 85% governing threshold (root `CLAUDE.md` states no threshold, so the 85% default governs). |
| **Comprehensive Coverage** | ✅ PASS | Uncovered lines are the three executable wrappers, the clock seam, the `Set-Content` arm under `-WhatIf`, and the entry-point block. |
| **Positive Flows** | ✅ PASS | Whitespace-tolerant row, 120 s interval counted, no warning on successful fetch. |
| **Negative Flows** | ✅ PASS | Non-numeric wave cell throws; failed fetch warns. |
| **Edge Cases** | ⚠️ PARTIAL | Boundary (120 s) and future start are now pinned. Not covered: a kickoff that contains a second table with a numeric first column (wave-summary table). Three real kickoff files have one, and the parser returns phantom feature rows for them (finding CR-1). |
| **Error Handling** | ✅ PASS | Clear terminating error for a non-numeric wave cell; warning on fetch failure. |
| **Concurrency** | N/A | Single-threaded command-line tool. |
| **State Transitions** | ✅ PASS | Unchanged from the prior audit. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.80% lines (repo-wide, derived; new files absent at baseline) -> Post-change: 93.85% lines. Change: +0.05% lines. New/changed-code coverage: 91.18% (Get-EpicProgressReport.ps1), 100% (Get-EpicProgressReport.Logic.ps1). Disposition: PASS. Evidence: `evidence/baseline/coverage-baseline.2026-11-04T20-39.md`, `evidence/qa-gates/coverage-final.2026-11-05T23-47.md`, `artifacts/pester/powershell-coverage.xml`, reviewer scoped re-measurement at HEAD.
- Python: N/A - zero changed Python files in the branch diff. Disposition: N/A.
- TypeScript: N/A - zero changed TypeScript files in the branch diff. Disposition: N/A.
- C#: N/A - zero changed C# files in the branch diff. Disposition: N/A.

Derivation of the repo-wide post-change figure: the standing `artifacts/pester/powershell-coverage.xml` now holds the cycle-1 P2-T4 run, which ran only `tests/scripts/dev-tools` against the full `scripts` denominator, so its root counter (2422/24680, 9.81%) reflects test scope, not a regression. The prior audit's merged repo-wide figure was 23154/24673 (93.84%). Between the prior head and HEAD only the two new production files changed executable lines: +4 covered in `Get-EpicProgressReport.ps1` (89/98 -> 93/102) and +3 covered in `Get-EpicProgressReport.Logic.ps1` (210/210 -> 213/213), with no new missed line. The repo-wide figure is therefore 23161/24680 = 93.85%. The two per-file figures in that artifact (93/9 and 213/0) match the reviewer measurement at HEAD.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-ExpectedMessage` names the issue and cell; warning text matched with a prefix pattern. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New tests separate arrange, act, and assert by blank lines. |
| **Document Intent** | ✅ PASS | Comments explain the boundary arithmetic and why the exit code is fixture-controlled. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No new test starts git, gh, or cswap. `returns the last native exit code` reads `$LASTEXITCODE` without assigning it. |
| **Use Mocks/Stubs** | ✅ PASS | Nine seams mocked, including the new `Get-EpicProgressLastExitCode`. |
| **Environment Stability** | ✅ PASS | No TestDrive or temporary files; no global state written. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit plus `evidence/qa-gates/self-review.2026-11-06T00-03.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-11-05T23-27.md` lists four findings. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-05T23-27.md`, all tasks checked. |
| **Document the plan** | ✅ PASS | Per-task commits R1 P0-T1 through R1 P2-T9. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Each remediation is a few lines in the existing function. |
| **Reusability** | ✅ PASS | No duplication introduced. |
| **Extensibility** | ✅ PASS | The exit-code read is a named seam, mockable like the other seams. |
| **Separation of concerns** | ✅ PASS | `$LASTEXITCODE` is read in the I/O file only; the logic file remains I/O-free (AST constraint tests still pass). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Still two production files. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts (`@(Get-Content).Count`, reviewer): 474, 661, 455, 601. None at or above 700, so no Warning. `config/file-size-baseline.json` is unchanged and has no entry for these files. |
| **Public vs internal** | ✅ PASS | Unchanged. |
| **No circular dependencies** | ✅ PASS | Unchanged. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-EpicProgressLastExitCode` follows the existing prefix and verb pattern. |
| **Docs/docstrings** | ✅ PASS | Help for `ConvertFrom-EpicProgressKickoffRow`, `Get-EpicProgressSummary`, `Invoke-EpicProgressReport`, and the script `-StartUtc` parameter updated to state the new behavior. |
| **Comment why, not what** | ✅ PASS | The kickoff help explains why a bad wave cell throws instead of being skipped. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Reviewer: `Invoke-Formatter -Settings pssa.settings.psd1` comparison on 4 files: 0 differences. |
| **2. Linting** | ✅ PASS | Reviewer: `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` on 4 files: 0 findings. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | Reviewer: 96/96 passed. Executor R1 P2-T7: 14394 tests tree-wide, 0 failed. |
| **Architecture boundary / contract / integration** | N/A | No such suite applies to a dev-tools script; the AST constraint tests serve as the I/O-boundary check and pass. |
| **Full toolchain loop** | ✅ PASS | Clean in a single pass at HEAD. |
| **Explicit reporting** | ✅ PASS | Cycle-1 evidence under the feature `evidence/` tree. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Per-task commit messages. |
| **Design choices explained** | ✅ PASS | Clamp chosen over rejection, documented in help. |
| **Update supporting documents** | ✅ PASS | Comment-based help updated. |
| **Provide next steps** | ✅ PASS | Remediation of CR-1, then PR and CI. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 differences (reviewer and `format.2026-11-05T23-45.md`). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings (reviewer and `pssa.2026-11-05T23-45.md`). |
| **Fix all findings** | ✅ PASS | No open analyzer findings. |
| **PowerShell 7+ compatible** | ✅ PASS | Tests ran on PowerShell 7 on Windows. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `Get-EpicProgressLastExitCode` has `[CmdletBinding()]` and `[OutputType([int])]`. |
| **Parameter validation** | ✅ PASS | Unchanged. |
| **ShouldProcess for state change** | ✅ PASS | Unchanged; the new seam is read-only. |
| **Wrapper seams** | ✅ PASS | Reviewer composed the real `Invoke-GitExe` with `Get-EpicProgressLastExitCode`: a failing local `git rev-parse --verify` returned 1 and a succeeding call returned 0, so the seam reads the wrapper's exit code. |
| **Avoid global state** | ✅ PASS | `$LASTEXITCODE` is read, not written. |
| **Error handling** | ✅ PASS | Clear `throw` for a non-numeric wave cell; `Write-Warning` for a failed fetch. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 474 and 661 logical lines. |
| **Approved verbs** | ✅ PASS | `Get` for the new seam. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 differences. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 96/96 (scoped), 14394/0 failed (tree, executor). |
| **Rerun loop if needed** | ✅ PASS | No rerun needed at HEAD. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `-WarningVariable` capture, `Should -Throw -ExpectedMessage`, `Mock`. |
| **Use PoshQC Configuration** | ✅ PASS | Executor coverage via `Invoke-PoshQCTest` from the worktree module (R1 P2-T4). |
| **PowerShell 7+ Compatible** | ✅ PASS | See 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 64 logic tests, 32 script tests. |
| **Test Behavior Over Implementation** | ✅ PASS | Reviewer mutation probe on a scratch copy: M1 `-ge`->`-gt`, M2 clamp removed, M3 row regex reverted, M4 wave check removed, M5 warning removed, M6 warning always emitted; 6 of 6 killed, each by exactly one intended test. |
| **Mocking Used Sparingly** | ✅ PASS | Only I/O seams mocked. |
| **Organization** | ✅ PASS | Mirrored layout unchanged. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | ✅ PASS | `*.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | New tests placed in the `Describe` of the function under test. |
| **Logical Grouping** | ✅ PASS | As above. |
| **Docstrings/Comments** | ✅ PASS | See 1.3. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | Executor R1 P2-T3/P2-T4. Reviewer used scoped `Invoke-Pester` with coverage output outside the repository. |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### Get-EpicProgressReport.Logic.ps1 (64 tests)

**Coverage:** 100% (213 of 213 lines). New tests: `parses a feature row with variable whitespace around cells` (line 52), `throws a clear error for a non-numeric wave cell` (line 62), `counts a pair exactly two minutes apart` (line 338), `clamps elapsed time at zero when the start is after now` (line 590).

**Not covered:** None.

### Get-EpicProgressReport.ps1 (32 tests)

**Coverage:** 91.18% (93 of 102 lines). New tests: `returns the last native exit code` (line 85), `warns when git fetch fails` (line 212), `does not warn when git fetch succeeds` (line 224).

- Lines 201, 215, 229: executable wrappers (tests must not start git, gh, or cswap).
- Line 302: real UTC clock seam.
- Lines 466-472: entry-point block, skipped when dot-sourced.
- Line 290: `Set-Content` arm not executed under `-WhatIf`.

**Not covered:** the seams above, by design.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (new suites) | 96 | ✅ |
| Tests Passed | 96 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Tree-wide run (executor R1 P2-T7) | 14394 tests, 0 failed, 10 skipped | ✅ |
| Seeded shuffles (executor R1 P2-T6) | 3 seeds x 818 tests, 0 failed | ✅ |
| Reviewer mutants | 6 of 6 killed | ✅ |
| Test File Size | 455 and 601 logical lines | ✅ PASS |
| Code Coverage | 91.18% and 100% lines (branch: not measured by Pester) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | Formatter comparison with `pssa.settings.psd1` on the 4 files | 0 differences | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` on the 4 files | 0 findings | ✅ |
| Pester Tests | Scoped `Invoke-Pester` with JaCoCo coverage | 96 passed, 0 failed | ✅ |
| Kickoff corpus probe | Old (`52224c60c`) and new parser over 9 repository kickoff files | 3 files yield 3 phantom rows each, identical before and after remediation | ❌ (CR-1) |

**Notes:** CI has not yet run on this head because no PR exists; no acceptance criterion depends on CI.

---

## 8. Gaps and Exceptions

### Identified Gaps

Remediation verification (all four cycle-1 findings resolved):

- Finding 1 (2-minute boundary): RESOLVED. Test at Logic.Tests line 338; mutant `-ge`->`-gt` at logic line 349 killed (reviewer M1 and executor `mutant-boundary-ge-gt.2026-11-05T23-42.md`).
- Finding 2 (future start): RESOLVED by clamping (logic line 525, `[math]::Max(0.0, ...)`), documented in function and script help; test at Logic.Tests line 590; mutant M2 killed.
- Finding 3 (kickoff whitespace and non-numeric wave): RESOLVED (logic lines 49, 51-54); tests at Logic.Tests lines 52 and 62; mutants M3 and M4 killed.
- Finding 4 (fetch failure): RESOLVED (main lines 305-315 seam, 376-379 warning); tests at Tests lines 212 and 224; mutants M5 and M6 killed; real-seam composition verified.

New finding from this re-audit:

- CR-1 (Blocking): `ConvertFrom-EpicProgressKickoffRow` (logic lines 29-57) accepts any table row with a numeric first cell anywhere in the kickoff, so the wave-summary table present in 3 of 9 repository kickoff files yields phantom features and an extra open wave. Pre-existing (identical output at `52224c60c`), not introduced by the remediation. Details and reproduction in `code-review.2026-11-06T00-11.md`.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** The two suites have no skipped tests.

---

## 9. Summary of Changes

### Commits in This PR/Branch

51 non-merge commits from `749691a1c` to `79d4e3de0`, plus merge `a67ae96d7` of origin/main. Remediation-cycle code commits: `9abead65e` (boundary test), `ca49dcfc7` (clamp), `72f307b63` (kickoff row parsing), `85fe72bf3` (fetch warning), `79d4e3de0` (help). The other cycle-1 commits are documentation and evidence.

### Files Modified

1. **scripts/dev-tools/Get-EpicProgressReport.ps1** (NEW) - adds `Get-EpicProgressLastExitCode` and the fetch warning in this cycle.
2. **scripts/dev-tools/Get-EpicProgressReport.Logic.ps1** (NEW) - kickoff row parsing and elapsed clamp changed in this cycle.
3. **tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1** (NEW) - three tests added in this cycle.
4. **tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1** (NEW) - four tests added in this cycle.
5. Feature folder documentation and evidence (NEW), and the promoted lifecycle record (NEW).

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIAL - one Blocking finding (CR-1)

All toolchain, coverage, file-size, and evidence-location gates pass. The four cycle-1 findings are resolved and their tests discriminate. One Blocking correctness finding (CR-1, autonomous) remains: phantom feature rows from non-feature kickoff tables. Tier classification: `scripts/dev-tools` is T4, so no property-test, mutation, or golden-test obligation applies.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation plan present
- ✅ Design Principles: seam pattern preserved
- ✅ Module & File Structure: 474 and 661 lines
- ✅ Naming, Docs, Comments: help updated
- ✅ Toolchain Execution: clean single pass
- ✅ Summarize & Document: per-task commits

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: 0 format differences, 0 findings
- ✅ PowerShell Design & Safety: seams, ShouldProcess
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent and deterministic
- ⚠️ Coverage & Scenarios: 91.18% and 100%; edge case of non-feature numeric table rows untested (CR-1)
- ✅ Test Structure: AAA
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5
- ✅ Test Style & Structure: mirrored layout; 6 of 6 mutants killed
- ✅ Naming & Readability: descriptive names
- ✅ Toolchain: PoshQC routes

### Metrics Summary

- ✅ 96/96 change-set tests passing; 14394 tree-wide, 0 failed
- ✅ 91.18% and 100% line coverage on new files; 93.85% repo-wide (derived)
- ✅ All code quality checks passing
- ❌ Kickoff parser returns phantom rows for 3 of 9 repository kickoff files

### Recommendation

**Not ready for merge.** Remediate CR-1 (restrict feature-row parsing to the feature-summary table and add a fixture with a wave-summary table), then re-review.

---

## Appendix A: Test Inventory

### Get-EpicProgressReport.Logic.Tests.ps1 (64 tests)

- Prior 60 tests unchanged (see `policy-audit.2026-11-05T23-23.md` Appendix A).
- Added: variable-whitespace row, non-numeric wave cell throws, 120-second pair counted, future start clamps elapsed to zero.

### Get-EpicProgressReport.Tests.ps1 (32 tests)

- Prior 29 tests unchanged.
- Added: last native exit code seam, warns on failed fetch, no warning on successful fetch.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (reviewer, from the worktree root, outputs outside the repository):**
```powershell
Invoke-Formatter -ScriptDefinition (Get-Content -LiteralPath <file> -Raw) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
$cfg = New-PesterConfiguration
$cfg.Run.Path = @('tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1','tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1')
$cfg.CodeCoverage.Enabled = $true
$cfg.CodeCoverage.Path = @('scripts/dev-tools/Get-EpicProgressReport.ps1','scripts/dev-tools/Get-EpicProgressReport.Logic.ps1')
$cfg.CodeCoverage.OutputPath = Join-Path $env:TEMP 'claude-1080-cov.xml'
Invoke-Pester -Configuration $cfg
```

**Mutation probe:** the four change-set files copied to a scratch tree with the same relative layout; each mutant applied by exact string replacement; both suites run per mutant; scratch tree removed afterwards.

**Kickoff corpus probe:** `ConvertFrom-EpicProgressKickoffRow` from `git show 52224c60c:<logic file>` and from HEAD, each run over every `docs/features/epics/*/epic-kickoff.md`.

**Evidence-location scan:** `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` (exit 0).

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-06
**Policy Version:** Current (as of audit date)
