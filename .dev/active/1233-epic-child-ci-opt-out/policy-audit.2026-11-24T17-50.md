# Policy Compliance Audit: Epic Child CI Opt-Out (#1233)

**Audit Date:** 2026-11-24
**Code Under Test:** merge base `c030729de4703f961ff27489d4890919f6e0587e` of the base branch `main` and reviewed head `502309bcd2de1b549fec6c154c3eee33dd9e402e` (branch `feature/epic-child-ci-opt-out-1233`; no pull request yet); the diff between them lists the changed files (170 files, 9902 insertions, 46 deletions). Re-audit after remediation cycle 1 (`remediation-plan.2026-11-24T14-21.md`) and the main sync that merged #1228 (`71fe3e9a5`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 production files in `.claude/` and `.codex/` plus 9 byte-identical bundle copies; 4 new and 4 extended Pester suites | 29521 in the final full gate; 3589 in the R1 selection; 1012 post-renumber; 216 in the reviewer run | ✅ 0 failures in every run | 96.85% lines repo-wide (47435/48976) | 96.87% lines repo-wide (47664/49204) at the final full gate; R1 added only covered lines | 100% of lines added in R1 (module 30/30; helper 51/51 per copy); 100% of the branch's changed executable lines in the helper, gates, consistency hooks, and module |
| Python | 1 production file (`scripts/dev_tools/validate_orchestrator_state.py`) and 2 test files | 17126 in the final gate; 78 in the R1 selection; 147 post-renumber | ✅ 0 failures | 98.01% lines, 95.47% branches repo-wide | 98.02% lines, 95.48% branches repo-wide | 100% (39/39 changed statements); file 99.52% lines, 99% branches |
| TypeScript | 1 new production file (`orchestrator-state-child-ci.ts`), 1 modified (`orchestrator-state-core.ts`), `jest.config.cjs`, 1 new test file | 6730 in the final extension gate; 27 in the R1 selection | ✅ 0 failures | 97.59% lines, 94.96% branches (extension) | 97.59% lines, 94.98% branches (extension); 98.44% lines, 94.65% branches repo-wide (reviewer root run at `0fc83af8b`) | 100% (146/146 lines, 28/28 branches in the new module; 2/2 changed core lines) |
| Markdown and JSON | Skills, rule source and generated rule, brief, template, ledger `0015`, feature documents, 23 corpus fixtures | N/A | ✅ generator `-Check` no drift; contract suites pass | N/A (documents and fixtures) | N/A (documents and fixtures) | N/A |

C# and Bash have zero changed files on the branch; their coverage verdicts are N/A for that reason only.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/baseline-jest.2026-11-24T06-30.md`
- TypeScript post-change coverage artifact: `coverage/lcov.info` (reviewer root run, `evidence/qa-gates/review-jest-root.2026-11-24T14-19.md`), `evidence/qa-gates/final-qc-jest.2026-11-24T13-09.md`, `evidence/qa-gates/r1-final-jest-selection.2026-11-24T17-22.md`
- Python baseline coverage artifact: `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/baseline-pytest.2026-11-24T05-52.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (final gate, 2026-11-24 13:05 UTC), `evidence/qa-gates/final-qc-pytest.2026-11-24T13-06.md`, `evidence/qa-gates/r1-final-pytest-selection.2026-11-24T17-22.md`
- PowerShell baseline coverage artifact: `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/baseline-pester.2026-11-24T05-33.md`, `evidence/remediation-baseline/r1-pester-selection.2026-11-24T15-07.md`
- PowerShell post-change coverage artifact: `evidence/qa-gates/final-qc-pester.2026-11-24T13-00.md` (repo-wide), `evidence/qa-gates/r1-final-pester-selection.2026-11-24T17-08.md`, `evidence/qa-gates/r1-coverage-comparison.2026-11-24T17-23.md`, reviewer targeted run (per-file, see Assumptions)
- Per-language comparison summary: Section 1.2.1

---

## Executive Summary

Remediation cycle 1 closed F1 and the three related observations of the 2026-11-24T13-43 review: the PowerShell completion validator now reads every key of the local-QC check ordinally (new private `Get-MissingOrdinalGateKey`), the merge-gate opt-out reads its checkpoint and `gh` keys through the new ordinal accessor `Get-EpicMergeGateChildCiOrdinalProperty`, the `$ciGate = (` spacing is restored, and the Codex gate header has its blank line. Four case-variant-key fixtures and 27 new merge-gate rows pin the change, each with recorded fail-before evidence. The main sync (`71fe3e9a5`) is neutral for every branch path (per-path numstat identical before and after), and the ledger entry was renumbered to `0015` after #1228 took `0014`; the chain and ledger suites pass on the committed tree.

One new blocking finding was identified by a reviewer cross-runtime probe: the TypeScript validator accepts an opted-out checkpoint whose `local_qc_gate.evidence_path` and `verified_at` are JSON `null`, while the Python and PowerShell validators report them as missing fields (F2). The cause is the shared TypeScript helper `missingObjectKeys`, which treats only `undefined` as absent.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; reviewer `check_quality_tiers`: `quality-tiers: OK (38 entries, 38 discovered projects)`)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- ✅ `.claude/rules/python.md` and `.claude/rules/python-suppressions.md` (no suppression added)
- ⚠️ `.claude/rules/typescript.md` and `.claude/rules/typescript-suppressions.md` (static clean; cross-runtime parity defect F2)
- N/A C# and Bash (no changed files)

Reviewer actions: compared the cycle diff (`0fc83af8b..502309bcd`) with the remediation plan; checked merge neutrality of `71fe3e9a5` by per-path numstat; compared git blobs of every mirror at head; ran one targeted Pester selection through the launcher (five suites, 216 tests, 0 failures) with the canonical coverage and JUnit files snapshotted and restored; probed the Python, TypeScript (esbuild bundle of the branch module), and PowerShell validators with nine checkpoint variants; ran `validate_evidence_locations.py --root .` (exit 0) and `check_quality_tiers` (exit 0). No full suite was run by the reviewer.

**Temporary artifacts cleanup:**
- ✅ Executor scripts are under the session scratch directory, outside the worktree.
- ✅ No ongoing tooling script was added.
- Reviewer scripts: probe, launcher, and coverage copies in the session scratch directory; `git status --porcelain` lists only the S7 and U7 check-off reversals and the review artifacts.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New rows parse literal JSON in memory and reset mocks per row; all suites passed in the 8-worker R1 selection and the 5-worker reviewer run. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One case-variant key per `OPT-ORD-*` and `CLAUDE-OPT-ORD-*` row; one fixture per corpus row. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer run of 216 tests: 5.34 s of test time. |
| **Determinism** - Consistent results | ✅ PASS | Fixed heads; process seams mocked by name. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row ids name the key and stage; Arrange/Act/Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 96.85% lines; Python 98.01% lines and 95.47% branches; TypeScript 97.59% lines and 94.96% branches (`Phase 0 baseline`); R1 per-file selection baseline in `r1-pester-selection.2026-11-24T15-07.md`<br>**Command:** launcher `run-test-suite.sh` with `pester`, `pytest`, `jest-extension`<br>**Artifact:** `evidence/baseline/` and `evidence/remediation-baseline/`<br>**Timestamp:** 2026-11-24 05:33 to 15:14 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** module 151/153 (98.69%, was 98.64%); Claude helper 166/166 (100%); Codex helper 164/166 (98.8%, was 98.73%)<br>**Change:** no per-file drop<br>**Status:** `r1-coverage-comparison.2026-11-24T17-23.md`; reviewer run confirms every R1-added line covered. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest changed PowerShell file 93.33% lines (`.claude/hooks/enforce-completion-helpers.ps1`, unchanged in R1); Python 99.52% / 99%; TypeScript 98.91% / 96.25% and 100% / 100%<br>**Thresholds:** 85% line, 75% branch (defaults; root `CLAUDE.md` states none); no branch threshold for PowerShell<br>**Status:** All changed files meet the thresholds. |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** R1-added lines 100% covered<br>**New code coverage:** module lines 153 to 245 30/30; helper lines 252 to 358 25/25 and 474 to 512 26/26 per copy<br>**Calculation method:** JaCoCo per-line counters mapped onto the cycle hunks (executor), confirmed by reviewer parse of the reviewer run. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | Every new function is exercised, but no fixture holds a JSON `null` value in a `local_qc_gate` field, so the TypeScript acceptance of null fields was not detected (F2). |
| **Positive Flows** - Valid inputs | ✅ PASS | Allow rows and corpus `opt-out-accepted`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Deny rows per stage, including case-variant keys; 22 failing corpus cases. |
| **Edge Cases** - Boundary conditions | ⚠️ PARTIAL | Case-variant keys and values are covered; null-valued fields are absent from the corpus (F2). |
| **Error Handling** - Error paths | ✅ PASS | `gh` non-zero and unparseable output; `cat-file` non-zero; catch converts errors into a deny. |
| **Concurrency** - If applicable | N/A | No concurrent code path. |
| **State Transitions** - If applicable | N/A | No stateful component beyond the checkpoint read. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.85% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.87% lines. Change: +0.02% lines at the final full gate; R1 added only covered lines (module 151/153 against 145/147; helpers 166/166 and 164/166 against 158/158 and 156/158). New/changed-code coverage: 100% of R1-added lines. Disposition: PASS. Evidence: `evidence/baseline/baseline-pester.2026-11-24T05-33.md`, `evidence/qa-gates/final-qc-pester.2026-11-24T13-00.md`, `evidence/qa-gates/r1-coverage-comparison.2026-11-24T17-23.md`, reviewer targeted run (module lines 150 to 245 without a missed line). No branch figure exists for PowerShell and no branch threshold applies.
- Python: Baseline: 98.01% lines, 95.47% branches -> Post-change: 98.02% lines, 95.48% branches. Change: +0.01% lines, +0.01% branches; no Python production change after the final gate. New/changed-code coverage: 100% (39/39 changed statements). Disposition: PASS. Evidence: `evidence/baseline/baseline-pytest.2026-11-24T05-52.md`, `evidence/qa-gates/final-qc-pytest.2026-11-24T13-06.md`, `artifacts/python/lcov.info`.
- TypeScript: Baseline: 97.59% lines, 94.96% branches -> Post-change: 97.59% lines, 94.98% branches. Change: +0.00% lines, +0.02% branches; no TypeScript production change after the final gate. New/changed-code coverage: 100% (146/146 lines, 28/28 branches). Disposition: PASS. Evidence: `evidence/baseline/baseline-jest.2026-11-24T06-30.md`, `evidence/qa-gates/final-qc-jest.2026-11-24T13-09.md`, `evidence/qa-gates/review-jest-root.2026-11-24T14-19.md`, `coverage/lcov.info`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Corpus rows assert the joined error lists with `Should -BeExactly`; merge-gate rows assert the stage prefix. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment markers in every inspected new row. |
| **Document Intent** | ✅ PASS | `enforce-completion-helpers.OrdinalKeys.Tests.ps1` header states what it pins and why. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Literal JSON parsed in memory; seams mocked. |
| **Use Mocks/Stubs** | ✅ PASS | Wrapper seams only. |
| **Environment Stability** | ✅ PASS | Leak scan 0 failures (`r1-final-powershell-static.2026-11-24T16-54.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit; executor self-review `evidence/qa-gates/self-review.2026-11-24T17-25.md` and `evidence/other/pre-push-review.R1.2026-11-24T17-25.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Remediation inputs and orchestrator note of 2026-11-24T13-43. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-24T14-21.md`: 18 of 18 tasks checked. |
| **Document the plan** | ✅ PASS | Task-check, fail-before, and QA evidence per task. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One ordinal accessor per runtime file; pre-#1233 accessors left untouched. |
| **Reusability** | ✅ PASS | `Get-CheckpointObjectOrdinalMember` reused in the module. |
| **Extensibility** | ✅ PASS | New helpers are private and mirror existing contracts. |
| **Separation of concerns** | ✅ PASS | Pure accessors; process seams unchanged. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Accessors live beside their callers. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts: `jest.config.cjs` 689; child-CI helper 629 (four copies); completion-checks module 592 (two copies); `enforce-completion-consistency.Tests.ps1` 588. No covered file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | New PowerShell helpers are not exported. |
| **No circular dependencies** | ✅ PASS | No import change in this cycle. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-MissingOrdinalGateKey`, `Get-EpicMergeGateChildCiOrdinalProperty`, `Get-EpicMergeGateChildLocalQcReviewedHead`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every new function. |
| **Comment why, not what** | ✅ PASS | Help text states the ordinal-match reason. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` (non-writing seam)<br>**Result:** 0 changes over 11 files (`r1-final-powershell-static.2026-11-24T16-54.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze`<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | Not applicable to PowerShell; no Python or TypeScript change in R1 (final-gate results stand) |
| **4. Testing** | ✅ PASS | **Command:** launcher `pester -TestPath`, `pytest`, `jest-extension` selections<br>**Result:** 3589, 78, 27 tests; 0 failures; post-renumber 1012 Pester and 147 pytest, 0 failures |
| **Full toolchain loop** | ✅ PASS | Owner rule O1 (targeted selections after the final full gate); clean single pass recorded. |
| **Explicit reporting** | ✅ PASS | Every command and exit code recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `282b8f50c` body lists every change; renumber commit `fa8963062` explains `0015`. |
| **Design choices explained** | ✅ PASS | Plan `## Notes` decisions (O6). |
| **Update supporting documents** | ✅ PASS | Rule source, generated rule, bundle copy, spec D7, ledger, and README row name `0015`; no stale `0014` reference to this entry outside commit history and evidence. |
| **Provide next steps** | ✅ PASS | F2 remediation; pull request `CI` at S9. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | Final gate: 0 changes; no Python change since |
| **Linting with Ruff** | ✅ PASS | Final gate: all checks passed |
| **Type checking with Pyright** | ✅ PASS | 0 errors |
| **No new Python module** | ✅ PASS | No added `.py` file (`r1-contract-check.2026-11-24T17-22.md`) |

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 files formatted; `$ciGate = (` spacing restored |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings |
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on the three new functions |
| **Cross-runtime parity** | ✅ PASS | F1 closed: the reviewer probe of nine variants matches Python on case-variant keys and null fields; the remaining whitespace-set difference is a pre-existing non-blocking observation (code review) |

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | Final gate: all files use Prettier style |
| **Linting with ESLint** | ✅ PASS | 0 findings |
| **Type checking with TSC** | ✅ PASS | 0 errors in both projects |
| **Cross-runtime parity** | ❌ FAIL | `validateCompletionLocalQcGate` accepts `null` `evidence_path` and `verified_at` through `missingObjectKeys`; Python and PowerShell report them as missing (F2) |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS | pytest corpus rows read the four new fixtures |
| **Location** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/` |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Pester through `Invoke-PoshQCParallelTest` |
| **Organization** | ✅ PASS | New suite under `tests/scripts/codex-hooks/` beside `enforce-completion-helpers.Tests.ps1` |
| **File Naming** | ✅ PASS | `enforce-completion-helpers.OrdinalKeys.Tests.ps1` |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS | Jest corpus rows read the four new fixtures (27 tests) |
| **Per-file threshold** | ✅ PASS | `coverageThreshold` entry met at 100% / 100% |

---

## 5. Test Coverage Detail

### enforce-epic-merge-gate-child-ci.ps1 (Claude and Codex)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Opt-out allow, deny, fallback, default, and `OPT-ORD-*` / `CLAUDE-OPT-ORD-*` case-variant rows | Positive/Negative/Edge Case | Claude 166/166; Codex 164/166 (R1 selection) | ✅ |

**Coverage:** Claude 100%, Codex 98.8%. **Not covered:** Codex lines 242 and 543, both pre-existing (shifted from 241 and 495).

### OrchestratorStateCompletionChecks.psm1

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `OCC-CORPUS-*` rows (23 fixtures), completion suites | Positive/Negative/Edge Case | 151/153 (R1 selection) | ✅ |

**Coverage:** 98.69%. **Not covered:** lines 472 and 473, pre-existing in `Get-OrchestratorStatePhaseCompletenessError`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | R1: 3589 Pester, 78 pytest, 27 Jest; post-renumber: 1012 Pester, 147 pytest; reviewer: 216 Pester | ✅ |
| Tests Passed | All | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | R1 Pester 467.77 s (8 workers); reviewer 147.02 s (5 workers) | ✅ |
| Functions/Classes Tested | All new functions | ✅ |
| Code Coverage (if applicable) | PowerShell 96.87% repo-wide at the final gate; Python 98.02% / 95.48%; TypeScript 97.59% / 94.98% | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PowerShell static | `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCLeakScan` | 0 changes, 0 findings, 0 failures | ✅ |
| Generator | `Invoke-HarnessGeneration.ps1 -Check`; Codex generator `--check` | no drift; exit 0 (R1 and post-renumber) | ✅ |
| Ledger chain | `ProcessReductionChain*`, `ProcessReductionLedger*` on the committed tree | pass (post-renumber run) | ✅ |
| Quality tiers | `check_quality_tiers` (reviewer) | OK, 38 entries | ✅ |
| Mirrors | git blob comparison at head | helper `551012393` and completion helpers `2573b573a` in four locations each; every changed bundle copy equals its source | ✅ |

---

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 formatter changes, 0 analyzer findings | 282b8f50c (no `.ps1` change after) | `evidence/qa-gates/r1-final-powershell-static.2026-11-24T16-54.md` |
| poshqc / PowerShell QC shards | pass | 3589 selection tests, 0 failures; 1012 post-renumber | 282b8f50c; post-renumber fa8963062 | `r1-final-pester-selection.2026-11-24T17-08.md`; `post-sync-renumber-check.2026-11-24T17-38.md` |
| quality-checks7 / Enforce Python coverage thresholds | pass | 98.02% lines, 95.48% branches | 55a6c517e (no `.py` change after) | `final-qc-pytest.2026-11-24T13-06.md` |
| extension tests / Jest | pass | 27 selection tests, 0 failures | a1608a009 (no `.ts` change after 55a6c517e) | `r1-final-jest-selection.2026-11-24T17-22.md` |
| docs-validation / generator drift | pass | no drift | fa8963062 | `post-sync-renumber-check.2026-11-24T17-38.md` |

No pull request exists for the branch and `gh run list` returns no run for it, so no CI result is available; every row relies on local evidence. The repo-wide figures predate the main sync; CI at the pull request head is the cross-check at S9.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All executor evidence is under `.dev/active/1233-epic-child-ci-opt-out/evidence/<kind>/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Vendored Coverage Exemptions

No `vendored-coverage-exemptions.json`, no coverage-exclusion entry, and no `.push-down-manifest.json` change on the branch.

## Rejected Scope Narrowing

None. The caller named the full branch range (merge base `c030729de` to head `502309bcd`) and did not narrow scope, files, languages, or checks.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. F2 (blocking): the TypeScript local-QC validator accepts `null` field values that Python and PowerShell reject. See `remediation-inputs.2026-11-24T17-50.md`.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None.**

### Assumptions

- Repo-wide PowerShell coverage is taken from the final full gate at `55a6c517e` (96.87%). R1 changed only the module and the helper, adding fully covered lines, so the ratio cannot fall below that figure for the branch's files; the main sync added #1228's files, whose coverage is measured by main's CI.
- The canonical `artifacts/pester/powershell-coverage.xml` is now the reviewer's five-suite targeted selection run (216 tests, 0 failures, written 2026-11-24 17:58:49 UTC inside the `scope: selection` window of `artifacts/test-execution/run-scope.pester.json`). Its root counter is selection-scoped and is not a repo-wide figure. It replaced the executor's post-renumber targeted run (18 suites, 17:37 UTC), which did not run the corpus suite. A first reviewer run restored the executor's file afterwards. The restored copy was written 0.11 s after the reviewer's selection window closed, so the coverage stop hook graded it as a full report. The reviewer therefore re-ran the same selection and left its report and run-scope record in place. In that selection the module reads 63/153 with lines 150 to 245 fully covered, and both helper copies read 148/166 with every R1-added line covered.
- The TypeScript probe bundled the branch module with esbuild from the worktree's `node_modules`; the Python probe called `validate_completion_gate_evidence` from the worktree; the PowerShell probe imported the worktree module. All three read the same nine variants built from `opt-out-accepted.json`.

---

## 9. Summary of Changes

The branch lets an epic opt its children out of per-child `CI` with `child_ci: integration_only`, replacing the child `CI` merge condition with local final-QC evidence bound to a current concurrent review, while the integration pull request into `main` still requires a full green `CI` run. Cycle 1 made every #1233-added PowerShell key read ordinal and renumbered the ledger entry to `0015`.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

F1 and the related observations are closed with fail-before evidence. One blocking cross-runtime parity finding (F2, TypeScript null fields) requires remediation.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation plan fully checked
- ✅ Design Principles: pre-#1233 accessors untouched
- ✅ Module & File Structure: largest covered file 689 lines
- ✅ Toolchain Execution: clean targeted pass

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python: no change since the final gate
- ✅ PowerShell: F1 closed
- ❌ TypeScript: parity defect F2

#### General Unit Test Policy (Section 1)
- ⚠️ Corpus lacks a null-field case (F2)

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Suites in mirrored locations

### Metrics Summary

- ✅ 0 failing tests across every R1, post-renumber, and reviewer run
- ✅ PowerShell 96.87%; Python 98.02% / 95.48%; TypeScript 97.59% / 94.98%
- ✅ Every changed bundle copy identical to its source

### Recommendation

**Remediate F2**, then re-review.

---

## Appendix A: Test Inventory

- New: `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1`, `tests/scripts/codex-hooks/enforce-completion-helpers.OrdinalKeys.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`, `tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`, corpus `tests/fixtures/orchestrator_state_child_ci/` (23 files)
- Extended: `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`, `tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1`, `tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1`, `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`

---

## Appendix B: Toolchain Commands Reference

```text
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <five opt-out and corpus suites>   (reviewer)
python scripts/dev_tools/validate_evidence_locations.py --root .
python -m scripts.dev_tools.check_quality_tiers
esbuild src/lib/validate/orchestrator-state-child-ci.ts --bundle --platform=node   (reviewer probe)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-24
**Policy Version:** Current (as of audit date)
