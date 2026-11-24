# Policy Compliance Audit: Epic Child CI Opt-Out (#1233)

**Audit Date:** 2026-11-24
**Code Under Test:** merge base `11b2c598652eb6cf6c3a3ccb1e7ea4340dda57d2` of the base branch `main` (equal to `origin/main` after a fetch) and reviewed head `9ad75122a69296f69938e5fb64d80a35ede5eb38` (branch `feature/epic-child-ci-opt-out-1233`, pushed; no pull request yet); the diff between them lists the changed files (200 files, 11246 insertions, 48 deletions). Re-audit after remediation cycle 2 (`remediation-plan.2026-11-24T17-59.md`) and the main sync that merged #1240 (`4fadc01eb`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 production files in `.claude/` and `.codex/` plus 9 byte-identical bundle copies (none changed in cycle 2); 4 new and 4 extended Pester suites; cycle 2 extended the contract suite only | 29521 in the final full gate; 917 in the RC2 selection; 482 post-sync | ✅ 0 failures in every run | 96.85% lines repo-wide (47435/48976) | 96.87% lines repo-wide (47664/49204) at the final full gate; no PowerShell production change since cycle 1 | 100% of the branch's changed executable lines in the helper, gates, consistency hooks, and module (cycle 1 figures; unchanged in cycle 2) |
| Python | 1 production file (`scripts/dev_tools/validate_orchestrator_state.py`) and 2 test files; no Python change in cycle 2 | 17126 in the final gate; 226 in the RC2 selection; 35 in the reviewer run | ✅ 0 failures | 98.01% lines, 95.47% branches repo-wide | 98.02% lines, 95.48% branches repo-wide | 100% (39/39 changed statements); file 99.52% lines, 99% branches |
| TypeScript | 1 new production file (`orchestrator-state-child-ci.ts`), 2 modified (`orchestrator-state-core.ts`, and in cycle 2 `orchestrator-state-completion.ts`), `jest.config.cjs`, 1 new and 1 extended test file | 6730 in the final extension gate; 801 in the RC2 selection; 42 in the reviewer run | ✅ 0 failures | 97.59% lines, 94.96% branches (extension) | 97.59% lines, 94.98% branches (extension) at the final gate, a lower bound at head (cycle 2 adds 1 covered line and covers 11 lines and 2 branches that the root run left uncovered) | 100% (new module 146/146 lines, 28/28 branches; `orchestrator-state-completion.ts` 158/158 lines, 37/37 branches; added `null` condition hit) |
| Markdown and JSON | Skills, rule source and generated rule, brief, template, ledger `0015`, feature documents, 25 corpus fixtures | N/A | ✅ generator `-Check` no drift; contract suites pass | N/A (documents and fixtures) | N/A (documents and fixtures) | N/A |

C# and Bash have zero changed files on the branch; their coverage verdicts are N/A for that reason only.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/baseline-jest.2026-11-24T06-30.md`, `evidence/remediation-baseline/rc2-jest-selection.2026-11-24T18-20.md`
- TypeScript post-change coverage artifact: `coverage/lcov.info` (reviewer root selection run at head, written 2026-11-24 19:22 UTC, `evidence/qa-gates/review-jest-root-selection.2026-11-24T19-22.md`), `extensions/drm-copilot/coverage/lcov.info` (RC2 final selection, written 2026-11-24 18:58 UTC), `evidence/qa-gates/final-qc-jest.2026-11-24T13-09.md`, `evidence/qa-gates/rc2-final-jest-selection.2026-11-24T18-58.md`
- Python baseline coverage artifact: `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/baseline-pytest.2026-11-24T05-52.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (final gate, 2026-11-24 13:05 UTC), `evidence/qa-gates/final-qc-pytest.2026-11-24T13-06.md`
- PowerShell baseline coverage artifact: `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/baseline-pester.2026-11-24T05-33.md`
- PowerShell post-change coverage artifact: `evidence/qa-gates/final-qc-pester.2026-11-24T13-00.md` (repo-wide), `evidence/qa-gates/r1-coverage-comparison.2026-11-24T17-23.md` (per file)
- Per-language comparison summary: Section 1.2.1

---

## Executive Summary

Remediation cycle 2 closed F2 of the 2026-11-24T17-50 review. `missingObjectKeys` in `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts` now counts JSON `null` as missing, so the TypeScript `local_qc_gate`, `ci_gate`, and `pr_gate` completion checks match Python `_missing_object_keys` and `_missing_pr_gate_keys`. Two corpus fixtures (`local-qc-gate-null-fields.json`, `local-qc-gate-null-heads.json`) and two TypeScript completion rows pin the change, with a fail-before record naming exactly the four new rows. The whitespace-set Minor is recorded as a known limitation in the issue #1233 rule section and pinned by two contract rows, as the orchestrator note decided. Ledger `0015` records every new span. The main sync `4fadc01eb` is neutral for every branch path.

The reviewer found no new blocking finding. A three-runtime probe of 16 checkpoint variants (null fields, null heads, non-string values, blank strings, non-object gates, and `ci_gate` null cases) returned identical error lists from Python, TypeScript, and PowerShell. Spec S19 remains pending the pull request's own `CI` run and is owned by the item orchestrator at S9.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; no new project folder in cycle 2; cycle-1 reviewer `check_quality_tiers` reported 38 entries, 38 discovered projects)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- ✅ `.claude/rules/python.md` and `.claude/rules/python-suppressions.md` (no suppression added)
- ✅ `.claude/rules/typescript.md` and `.claude/rules/typescript-suppressions.md` (no suppression added)
- N/A C# and Bash (no changed files)

Reviewer actions: compared the cycle diff (`502309bcd..9ad75122a`) with the remediation plan; checked merge neutrality of `4fadc01eb` by per-path numstat (branch against `c030729de` at `3abe730f4` equals branch against `11b2c5986` at `9ad75122a`, except the post-sync record); traced every caller of `missingObjectKeys`; ran a 16-variant probe through the Python, TypeScript (esbuild bundle of the branch module), and PowerShell validators; ran the 25-fixture corpus against the head bundle and against a mutant with the `null` clause removed; replayed the three new ledger revert blocks against the merge-base blobs; compared rule copies by git blob; measured logical line counts of all 35 covered changed files; ran one targeted Jest selection (2 suites, 42 tests) and one targeted pytest selection (35 tests) through the launcher without coverage; ran `validate_evidence_locations.py --root .` (exit 0). No full suite was run by the reviewer.

**Temporary artifacts cleanup:**
- ✅ Executor scripts are under the session scratch directory, outside the worktree.
- ✅ No ongoing tooling script was added.
- Reviewer scripts: probe generator, runners, bundles, and outputs in the session scratch directory; `git status --porcelain` was empty before the review artifacts were written.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New Jest rows build state in memory; corpus rows read committed fixtures read-only; the RC2 selections ran under parallel workers (Jest workers, 8 Pester workers, 24 pytest workers). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One gate per new completion row; one changed condition per new fixture. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer Jest selection of 42 tests and pytest selection of 35 tests each finished in seconds. |
| **Determinism** - Consistent results | ✅ PASS | Literal heads and timestamps in fixtures; no clock or random input. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row names state the gate and the null condition; Arrange/Act/Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 96.85% lines; Python 98.01% lines and 95.47% branches; TypeScript 97.59% lines and 94.96% branches (`Phase 0 baseline`); RC2 selection baseline for `orchestrator-state-completion.ts` 147/157 lines and 35/37 branches<br>**Command:** launcher `run-test-suite.sh` with `pester`, `pytest`, `jest-extension`<br>**Artifact:** `evidence/baseline/` and `evidence/remediation-baseline/rc2-jest-selection.2026-11-24T18-20.md`<br>**Timestamp:** 2026-11-24 05:33 to 18:20 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** `orchestrator-state-completion.ts` 158/158 lines, 37/37 branches (was 147/157, 35/37); `orchestrator-state-child-ci.ts` 146/146, 28/28 (unchanged)<br>**Change:** no per-file drop<br>**Status:** `rc2-final-jest-selection.2026-11-24T18-58.md`; reviewer parse of `extensions/drm-copilot/coverage/lcov.info` confirms the figures. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest changed PowerShell file 93.33% lines (`.claude/hooks/enforce-completion-helpers.ps1`, unchanged in cycle 2); Python 99.52% / 99%; TypeScript 100% / 100% for both cycle-2-relevant modules and 98.91% / 96.25% for `orchestrator-state-core.ts`<br>**Thresholds:** 85% line, 75% branch (defaults; root `CLAUDE.md` states none); no branch threshold for PowerShell<br>**Status:** All changed files meet the thresholds. |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** cycle-2 added production line (`item === null ||`, line 74) covered<br>**New code coverage:** LCOV `DA:74,136` and `BRDA:74,10,0,123` in the RC2 final selection<br>**Calculation method:** LCOV line and branch records of the changed line, confirmed by reviewer parse. |
| **Comprehensive Coverage** | ✅ PASS | The corpus now holds null-field and null-head cases; the reviewer probe adds non-string, blank, and non-object variants with identical output in all three runtimes. |
| **Positive Flows** - Valid inputs | ✅ PASS | Corpus `opt-out-accepted`; probe `accepted` and `ci_ok`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | 24 failing corpus cases; null `ci_gate` and `pr_gate` rows. |
| **Edge Cases** - Boundary conditions | ✅ PASS | JSON `null` fields and heads, case-variant keys and values, non-object gates. |
| **Error Handling** - Error paths | ✅ PASS | Unchanged from cycle 1: `gh` and `cat-file` failures deny. |
| **Concurrency** - If applicable | N/A | No concurrent code path. |
| **State Transitions** - If applicable | N/A | No stateful component beyond the checkpoint read. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.85% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.87% lines. Change: +0.02% lines at the final full gate; cycle 2 changed no PowerShell production file (only `child-ci-opt-out-skill-contract.Tests.ps1`). New/changed-code coverage: 100% of the branch's changed executable lines (cycle 1 per-file comparison). Disposition: PASS. Evidence: `evidence/baseline/baseline-pester.2026-11-24T05-33.md`, `evidence/qa-gates/final-qc-pester.2026-11-24T13-00.md`, `evidence/qa-gates/r1-coverage-comparison.2026-11-24T17-23.md`. No branch figure exists for PowerShell and no branch threshold applies.
- Python: Baseline: 98.01% lines, 95.47% branches -> Post-change: 98.02% lines, 95.48% branches. Change: +0.01% lines, +0.01% branches; no Python change after the final gate. New/changed-code coverage: 100% (39/39 changed statements). Disposition: PASS. Evidence: `evidence/baseline/baseline-pytest.2026-11-24T05-52.md`, `evidence/qa-gates/final-qc-pytest.2026-11-24T13-06.md`, `artifacts/python/lcov.info`.
- TypeScript: Baseline: 97.59% lines, 94.96% branches -> Post-change: 97.59% lines, 94.98% branches. Change: +0.00% lines, +0.02% branches at the final gate; cycle 2 can only raise the figure, because the full root run left 10 lines and 2 branches of `orchestrator-state-completion.ts` uncovered (147/157, 35/37) and the RC2 selection covers all 158 lines and 37 branches. New/changed-code coverage: 100% (new module 146/146 lines, 28/28 branches; changed completion line hit). Disposition: PASS. Evidence: `evidence/baseline/baseline-jest.2026-11-24T06-30.md`, `evidence/qa-gates/final-qc-jest.2026-11-24T13-09.md`, `evidence/qa-gates/rc2-final-jest-selection.2026-11-24T18-58.md`, `coverage/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Jest rows assert the exact error string with `toContain`; corpus rows compare full error lists. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment markers in all four new rows (two Jest, two `X-LIMIT`). |
| **Document Intent** | ✅ PASS | Each fixture `notes` field states the case; Jest Arrange comment states the Python parity reason. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | In-memory state; committed fixtures. |
| **Use Mocks/Stubs** | ✅ PASS | No new seam. |
| **Environment Stability** | ✅ PASS | Leak scan 0 failures (`rc2-final-powershell-static.2026-11-24T18-57.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit; executor self-review `evidence/qa-gates/self-review.2026-11-24T19-04.md` and `evidence/other/pre-push-review.RC2.2026-11-24T19-04.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Remediation inputs and orchestrator note of 2026-11-24T17-50. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-24T17-59.md`: 18 of 18 tasks checked. |
| **Document the plan** | ✅ PASS | Task-check, fail-before, and QA evidence per task. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One added condition at the shared root rather than a child-CI-only workaround. |
| **Reusability** | ✅ PASS | The fix serves all three gate checks through the shared helper. |
| **Extensibility** | ✅ PASS | Error strings and order unchanged. |
| **Separation of concerns** | ✅ PASS | Pure helper; no I/O change. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Change confined to the shared presence helper. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts of all 35 covered changed files: largest `jest.config.cjs` 689; child-CI helper 629 (four copies); completion-checks module 592; `orchestrator-state-completion.ts` 158; `orchestrator-state-core.completion.test.ts` 279; contract suite 261. No covered file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | No export added. |
| **No circular dependencies** | ✅ PASS | No import change in cycle 2. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Fixture stems state their case. |
| **Docs/docstrings** | ✅ PASS | TSDoc summary of `missingObjectKeys` names JSON `null`. |
| **Comment why, not what** | ✅ PASS | Inline comment states the missing-value rule. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** Prettier in check mode over four TypeScript files; `Invoke-PoshQCFormat` non-writing seam<br>**Result:** 0 findings (`rc2-final-typescript-static.2026-11-24T18-53.md`, `rc2-final-powershell-static.2026-11-24T18-57.md`) |
| **2. Linting** | ✅ PASS | **Command:** ESLint; `Invoke-PoshQCAnalyze`<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `tsc --noEmit` for the extension and Jest projects<br>**Result:** 0 errors |
| **4. Testing** | ✅ PASS | **Command:** launcher `jest-extension`, `pester -TestPath`, `pytest` selections<br>**Result:** 801, 917, 226 tests; 0 failures; post-sync 482 Pester and 54 pytest, 0 failures |
| **Full toolchain loop** | ✅ PASS | Owner rule O1 (targeted selections after the final full gate); clean single pass recorded. |
| **Explicit reporting** | ✅ PASS | Every command and exit code recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `61702e988` body lists every change. |
| **Design choices explained** | ✅ PASS | Plan `## Notes` decisions (O6). |
| **Update supporting documents** | ✅ PASS | Rule source, generated rule, bundle copy (blob `7405bfaed` in both generated copies), ledger `0015`. |
| **Provide next steps** | ✅ PASS | Pull request `CI` at S9; ledger merge-commit back-fill at the records stage. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | Final gate: 0 changes; no Python change since |
| **Linting with Ruff** | ✅ PASS | Final gate: all checks passed |
| **Type checking with Pyright** | ✅ PASS | 0 errors |
| **No new Python module** | ✅ PASS | No added `.py` file (`rc2-contract-check.2026-11-24T19-03.md`) |

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 files formatted |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings |
| **Advanced functions** | ✅ PASS | No new function in cycle 2 |
| **Cross-runtime parity** | ✅ PASS | Reviewer probe: 16 of 16 variants identical to Python |

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | All matched files use Prettier code style |
| **Linting with ESLint** | ✅ PASS | 0 findings |
| **Type checking with TSC** | ✅ PASS | 0 errors in both projects |
| **Cross-runtime parity** | ✅ PASS | F2 closed: 16 of 16 probe variants identical to Python and PowerShell; the null-clause mutant fails exactly the two new fixtures |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS | pytest corpus rows read the two new fixtures |
| **Location** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/` |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Pester through `Invoke-PoshQCParallelTest` |
| **Organization** | ✅ PASS | `X-LIMIT` rows in the existing contract suite |
| **File Naming** | ✅ PASS | No new suite |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS | Jest rows in `orchestrator-state-core.completion.test.ts` and corpus rows in `orchestrator-state-child-ci.test.ts` |
| **Per-file threshold** | ✅ PASS | `coverageThreshold` entry of the new module met at 100% / 100%; `jest.config.cjs` unchanged in cycle 2 |

---

## 5. Test Coverage Detail

### orchestrator-state-completion.ts

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Completion rows (null `ci_gate`, null `pr_gate`, and pre-existing rows), corpus rows | Positive/Negative/Edge Case | 158/158 (RC2 selection) | ✅ |

**Coverage:** 100% lines, 100% branches. **Not covered:** none.

### orchestrator-state-child-ci.ts

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Corpus rows (25 fixtures), `requireComplete` rows | Positive/Negative/Edge Case | 146/146 (RC2 selection) | ✅ |

**Coverage:** 100% lines, 100% branches.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | RC2: 801 Jest, 917 Pester, 226 pytest; post-sync: 482 Pester, 54 pytest; reviewer: 42 Jest, 35 pytest | ✅ |
| Tests Passed | All | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | RC2 Pester 166.32 s (8 workers); pytest 5.49 s | ✅ |
| Functions/Classes Tested | All changed functions | ✅ |
| Code Coverage (if applicable) | PowerShell 96.87% repo-wide at the final gate; Python 98.02% / 95.48%; TypeScript 97.59% / 94.98% (lower bound at head) | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| TypeScript static | Prettier check, ESLint, `tsc --noEmit` (two projects) | 0 findings | ✅ |
| PowerShell static | `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCLeakScan` | 0 changes, 0 findings, 0 failures | ✅ |
| Generator | `Invoke-HarnessGeneration.ps1 -Check`; Codex generator `--check` | no drift; exit 0 (RC2 and post-sync) | ✅ |
| Ledger chain | `ProcessReductionChain*`, `ProcessReductionLedger*` on the committed tree; reviewer replay of the three new revert blocks | pass; each `Current` occurs once and the replay restores the merge-base bytes | ✅ |
| Mirrors | git blob comparison at head | generated rule and bundle copy both `7405bfaed` | ✅ |

---

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| extension tests / Jest | pass | 801 selection tests, 0 failures; completion module 100% lines and branches | 61702e988 (no `.ts` change after) | `rc2-final-jest-selection.2026-11-24T18-58.md` |
| extension tests / Jest (reviewer root selection) | pass | 801 selection tests, 0 failures; three branch modules at or above 96% lines and branches | 9ad75122a | `review-jest-root-selection.2026-11-24T19-22.md` |
| extension static / Prettier, ESLint, TSC | pass | 0 findings | 61702e988 | `rc2-final-typescript-static.2026-11-24T18-53.md` |
| poshqc / PowerShell QC static | pass | 0 formatter changes, 0 analyzer findings | 61702e988 (no `.ps1` change after) | `rc2-final-powershell-static.2026-11-24T18-57.md` |
| poshqc / PowerShell QC shards | pass | 917 selection tests, 0 failures; 482 post-sync | 61702e988; post-sync 4fadc01eb | `rc2-final-pester-selection.2026-11-24T19-01.md`; `post-sync-check.2026-11-24T19-10.md` |
| quality-checks7 / Enforce Python coverage thresholds | pass | 98.02% lines, 95.48% branches | 55a6c517e (no `.py` change after) | `final-qc-pytest.2026-11-24T13-06.md` |
| docs-validation / generator drift | pass | no drift | 4fadc01eb | `post-sync-check.2026-11-24T19-10.md` |

No pull request exists for the branch and `gh run list` returns no run for it, so no CI result is available; every row relies on local evidence. The pull request's own `CI` run at S9 is the cross-check.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All executor evidence is under `.dev/active/1233-epic-child-ci-opt-out/evidence/<kind>/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Vendored Coverage Exemptions

No `vendored-coverage-exemptions.json`, no coverage-exclusion entry, and no `.push-down-manifest.json` change on the branch.

## Rejected Scope Narrowing

None. The caller named the full branch range (merge base `11b2c5986` to head `9ad75122a`) and did not narrow scope, files, languages, or checks.

---

## 8. Gaps and Exceptions

### Identified Gaps

None blocking. Spec S19 (the pull request's own `CI` run) is pending CI and is checked off by the item orchestrator at S9.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None.**

### Assumptions

- Repo-wide PowerShell and Python figures are taken from the final full gates; neither language has a production change after them.
- The TypeScript repo-wide figure at head is bounded below by the final-gate figure: cycle 2 adds one covered line and covers lines and branches that the full root run reported uncovered, and changes no other production file.
- The coverage stop hook reported the root `coverage/lcov.info` (14:18 UTC) as older than the main-sync merge `4fadc01eb` (19:07:15 UTC), which touched TypeScript files. The reviewer re-ran the branch's TypeScript selection through the launcher `jest` suite with coverage of the three branch modules (801 tests, 0 failures; run-scope `selection`, 19:22:30Z to 19:22:35Z). The new report gives `orchestrator-state-child-ci.ts` 146/146 and 28/28, `orchestrator-state-completion.ts` 158/158 and 37/37, and `orchestrator-state-core.ts` 456/461 and 74/77 (96.10% branches). Evidence: `evidence/qa-gates/review-jest-root-selection.2026-11-24T19-22.md`. Its root totals are selection-scoped and are not used as a repo-wide figure.
- The reviewer's first Jest and pytest runs used no coverage and did not rewrite `extensions/drm-copilot/coverage/lcov.info` or `artifacts/python/lcov.info` (modification times unchanged). They did rewrite `artifacts/test-execution/run-scope.jest-extension.json` and `run-scope.pytest.json` with the reviewer's selection windows, so the selection window recorded for the RC2 extension coverage file (18:58 UTC) is no longer the one on disk; that file holds only the two measured modules at 100% lines and branches.
- The TypeScript probe bundled the branch module with esbuild from the worktree's `node_modules`; the Python probe imported the worktree module; the PowerShell probe imported the worktree module. All three read the same 16 variants built from `opt-out-accepted.json`.

---

## 9. Summary of Changes

The branch lets an epic opt its children out of per-child `CI` with `child_ci: integration_only`, replacing the child `CI` merge condition with local final-QC evidence bound to a current concurrent review, while the integration pull request into `main` still requires a full green `CI` run. Cycle 2 makes the TypeScript completion checks count JSON `null` as a missing field, in line with Python and PowerShell, and records the whitespace-set difference as a known limitation.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

F2 is closed with fail-before evidence, a mutant check, and a 16-variant three-runtime probe. No blocking finding remains; S19 is pending CI.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation plan fully checked
- ✅ Design Principles: root-cause fix in the shared helper
- ✅ Module & File Structure: largest covered file 689 lines
- ✅ Toolchain Execution: clean targeted pass

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python: no change since the final gate
- ✅ PowerShell: no production change in cycle 2
- ✅ TypeScript: parity restored

#### General Unit Test Policy (Section 1)
- ✅ Corpus covers null-valued fields

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Suites in mirrored locations

### Metrics Summary

- ✅ 0 failing tests across every RC2, post-sync, and reviewer run
- ✅ PowerShell 96.87%; Python 98.02% / 95.48%; TypeScript 97.59% / 94.98% (lower bound)
- ✅ Generated rule and bundle copy identical

### Recommendation

**Proceed to pull request creation**; confirm the pull request's own `CI` run at S9.

---

## Appendix A: Test Inventory

- New: `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1`, `tests/scripts/codex-hooks/enforce-completion-helpers.OrdinalKeys.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`, `tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`, corpus `tests/fixtures/orchestrator_state_child_ci/` (25 files)
- Extended: `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`, `tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1`, `tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1`, `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts`

---

## Appendix B: Toolchain Commands Reference

```text
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension "--testPathPatterns=test/lib/validate/(orchestrator-state-child-ci|orchestrator-state-core[.]completion)[.]test[.]ts$"   (reviewer)
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py   (reviewer)
python scripts/dev_tools/validate_evidence_locations.py --root .
esbuild src/lib/validate/orchestrator-state-child-ci.ts --bundle --platform=node   (reviewer probe)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-24
**Policy Version:** Current (as of audit date)
