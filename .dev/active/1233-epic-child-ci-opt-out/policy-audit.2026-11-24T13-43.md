# Policy Compliance Audit: Epic Child CI Opt-Out (#1233)

**Audit Date:** 2026-11-24
**Code Under Test:** merge base `23458fade99f40e81b95ce86ed90805258479782` of the base branch `main` and reviewed head `0fc83af8b03b74deed2615238faa8c203df942dd` (branch `feature/epic-child-ci-opt-out-1233`; no pull request yet); the diff between them lists the changed files (136 files, 7931 insertions, 48 deletions)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 production files in `.claude/` and `.codex/` (child-CI helper x2, epic merge gate x2, completion helpers x2, completion consistency x2, `OrchestratorStateCompletionChecks.psm1`) plus 9 byte-identical bundle copies; 3 new and 4 extended Pester suites | 29521 tests in the final full gate; 2082 in the post-sync targeted run | ✅ 29503 pass, 0 fail, 18 skipped | 96.85% lines repo-wide (47435/48976) | 96.87% lines repo-wide (47664/49204) | 100% of changed executable lines in the child-CI helpers, gates, consistency hooks, and module; 22/23 (95.65%) in the Claude completion-helpers copy |
| Python | 1 production file (`scripts/dev_tools/validate_orchestrator_state.py`) and 2 test files | 17126 passed in the final gate; 52 in the post-sync targeted run | ✅ 17126 pass, 0 fail, 6 skipped | 98.01% lines, 95.47% branches repo-wide | 98.02% lines, 95.48% branches repo-wide | 100% (39/39 changed statements); file 99.52% lines, 99% branches |
| TypeScript | 1 new production file (`orchestrator-state-child-ci.ts`), 1 modified (`orchestrator-state-core.ts`), `jest.config.cjs`, 1 new test file | 6730 in the final extension gate; 6747 in the reviewer root run | ✅ 6730 pass, 0 fail | 97.59% lines, 94.96% branches (extension) | 97.59% lines, 94.98% branches (extension); 98.44% lines, 94.65% branches repo-wide (reviewer root run) | 100% (146/146 lines, 28/28 branches in the new module; 2/2 changed lines in the core module) |
| Markdown and JSON | Skills, rule source and generated rule, brief, template, ledger, feature documents, 19 corpus fixtures | N/A | ✅ generator `-Check` no drift; contract suites pass | N/A (documents and fixtures) | N/A (documents and fixtures) | N/A |

C# and Bash have zero changed files on the branch; their coverage verdicts are N/A for that reason only.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/baseline-jest.2026-11-24T06-30.md`
- TypeScript post-change coverage artifact: `coverage/lcov.info` (reviewer root run, `evidence/qa-gates/review-jest-root.2026-11-24T14-19.md`), `extensions/drm-copilot/coverage/lcov.info` (executor gate, re-parsed), `evidence/qa-gates/final-qc-jest.2026-11-24T13-09.md`
- Python baseline coverage artifact: `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/baseline-pytest.2026-11-24T05-52.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (written 2026-11-24 13:05 UTC, re-parsed), `evidence/qa-gates/final-qc-pytest.2026-11-24T13-06.md`
- PowerShell baseline coverage artifact: `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/baseline-pester.2026-11-24T05-33.md`
- PowerShell post-change coverage artifact: `evidence/qa-gates/final-qc-pester.2026-11-24T13-00.md` (repo-wide), `artifacts/pester/powershell-coverage.xml` (post-sync targeted run, written 2026-11-24 13:35 UTC, re-parsed per file), `evidence/qa-gates/coverage-comparison.2026-11-24T13-09.md`
- Per-language comparison summary: Section 1.2.1

---

## Executive Summary

The branch adds the `child_ci: integration_only` opt-out for epic children: the merge-gate child-CI helper verifies local final-QC evidence and a current concurrent review in place of a green `CI` run when the live base is the recorded integration branch, the completion-consistency hooks and the three completion validators accept `local_qc_gate` in place of `ci_gate`, and the skills, rule, brief, template, and ledger entry `0014` document and record the reduction. Toolchain evidence is clean for PowerShell, Python, and TypeScript, every changed production file meets the coverage thresholds, and all mirrors are byte-identical. One blocking finding was identified: the PowerShell completion validator reads the new keys case-insensitively, so it disagrees with the Python validator on case-variant keys (F1, code review).

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on `main`; reviewer `check_quality_tiers`: `quality-tiers: OK (38 entries, 38 discovered projects)`; no new project folder)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- ✅ `.claude/rules/python.md` and `.claude/rules/python-suppressions.md` (no suppression added)
- ✅ `.claude/rules/typescript.md` and `.claude/rules/typescript-suppressions.md` (no suppression added)
- N/A C# and Bash (no changed files)

Reviewer actions: re-parsed `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, and `extensions/drm-copilot/coverage/lcov.info`; ran one root Jest coverage run because the canonical `coverage/lcov.info` was absent (the executor ran the extension-only Jest gate); compared git blobs of every mirror; ran `validate_evidence_locations.py --root .` (exit 0) and `check_quality_tiers` (exit 0); probed the Python and PowerShell completion validators with a case-variant-key checkpoint and two corpus controls. No full Pester or pytest suite was run by the reviewer, per the owner directive that full suites run only at the baseline and final QC gates.

**Temporary artifacts cleanup:**
- ✅ Executor scripts are under the session scratch directory, outside the worktree; `git status --porcelain` was clean at the reviewed head before this review.
- ✅ No ongoing tooling script was added.
- Reviewer scripts: probe and launcher scripts in the session scratch directory; not in the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Per-row state is reset by `Initialize-OptOutRow` or `BeforeEach` mocks; all suites passed in the 8-worker parallel Pester gate and in `pytest -n auto`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One stage condition per deny row; one corpus case per parametrized row. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | No waits; process seams mocked; corpus rows read committed fixtures. |
| **Determinism** - Consistent results | ✅ PASS | Fixed heads and timestamps; `Invoke-DocsOnlyGhExe`, `Invoke-DocsOnlyGitExe`, and checkpoint reads mocked by name. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row ids (`OPT-*`, `CLAUDE-OPT-*`, `OCC-*`) and Arrange/Act/Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 96.85% lines; Python 98.01% lines and 95.47% branches; TypeScript 97.59% lines and 94.96% branches, from the `Phase 0 baseline` artifacts<br>**Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh` with `pester`, `pytest --cov --cov-branch`, and `jest-extension --coverage`<br>**Artifact:** `evidence/baseline/baseline-pester.2026-11-24T05-33.md`, `baseline-pytest.2026-11-24T05-52.md`, `baseline-jest.2026-11-24T06-30.md`<br>**Timestamp:** 2026-11-24 05:33, 05:52, 06:30 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 96.87%; Python 98.02% / 95.48%; TypeScript 97.59% / 94.98% (extension), read from the single gate run per language<br>**Change:** +0.02% PowerShell lines; +0.01% Python lines and branches; 0.00% TypeScript lines, +0.02% branches<br>**Status:** No per-file or repo-wide drop (`evidence/qa-gates/coverage-comparison.2026-11-24T13-09.md`). |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest changed PowerShell file 93.33% lines (`.claude/hooks/enforce-completion-helpers.ps1`); Python file 99.52% / 99%; TypeScript 98.91% / 96.25% and 100% / 100%<br>**Thresholds:** 85% line, 75% branch (defaults; root `CLAUDE.md` states none); no branch threshold for PowerShell<br>**Status:** All changed files meet the thresholds. |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** every changed file has at least 95.65% changed-line coverage<br>**New code coverage:** 100% in the new TypeScript module and the Python changes; 77/77 changed lines in each child-CI helper copy<br>**Calculation method:** per-file counters from the coverage reports mapped onto `git diff -U0` hunks (`coverage-comparison.2026-11-24T13-09.md`), confirmed by reviewer re-parse. |
| **Comprehensive Coverage** | ✅ PASS | Every new function in the helper, completion helpers, module, Python validator, and TypeScript module is exercised. The one uncovered changed line (line 196 of the Claude completion-helpers copy) runs in the Codex helper suite against the byte-identical Codex copy. |
| **Positive Flows** - Valid inputs | ✅ PASS | Allow rows with 40- and 64-character heads; corpus `opt-out-accepted`; completion DONE-allowed rows. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Deny rows for every stage B, R, L1, L2, L3 condition; 17 failing corpus cases; completion deny rows. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Case variants of base, head, conclusion value, and `child_ci` value; first `EXIT_CODE:` 1 then 0; empty review list; non-object last entry. A case-variant key case is absent (F1). |
| **Error Handling** - Error paths | ✅ PASS | `gh` non-zero and unparseable output; `cat-file` non-zero; existing catch converts errors into a deny. |
| **Concurrency** - If applicable | N/A | No concurrent code path. |
| **State Transitions** - If applicable | N/A | No stateful component beyond the checkpoint read. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.85% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.87% lines. Change: +0.02% lines. New/changed-code coverage: 100% of changed executable lines except 22/23 (95.65%) in the Claude completion-helpers copy. Disposition: PASS. Evidence: `evidence/baseline/baseline-pester.2026-11-24T05-33.md`, `evidence/qa-gates/final-qc-pester.2026-11-24T13-00.md`, `evidence/qa-gates/coverage-comparison.2026-11-24T13-09.md`, reviewer parse of `artifacts/pester/powershell-coverage.xml`. No branch figure exists for PowerShell and no branch threshold applies.
- Python: Baseline: 98.01% lines, 95.47% branches -> Post-change: 98.02% lines, 95.48% branches. Change: +0.01% lines, +0.01% branches. New/changed-code coverage: 100% (39/39 changed statements). Disposition: PASS. Evidence: `evidence/baseline/baseline-pytest.2026-11-24T05-52.md`, `evidence/qa-gates/final-qc-pytest.2026-11-24T13-06.md`, reviewer parse of `artifacts/python/lcov.info` (35411/36128 lines, 13119/13740 branches; file 209/210 and 99/100).
- TypeScript: Baseline: 97.59% lines, 94.96% branches -> Post-change: 97.59% lines, 94.98% branches. Change: +0.00% lines, +0.02% branches. New/changed-code coverage: 100% (146/146 lines and 28/28 branches in the new module; 2/2 changed core lines). Disposition: PASS. Evidence: `evidence/baseline/baseline-jest.2026-11-24T06-30.md`, `evidence/qa-gates/final-qc-jest.2026-11-24T13-09.md`, reviewer parse of `extensions/drm-copilot/coverage/lcov.info`, reviewer root run `evidence/qa-gates/review-jest-root.2026-11-24T14-19.md` (98.44% lines, 94.65% branches repo-wide).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Corpus rows assert the joined expected and actual error lists with `Should -BeExactly`; merge-gate rows assert the exact reason text. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment markers in every inspected row. |
| **Document Intent** | ✅ PASS | Suite headers state the issue, isolation, and mocked seams; row names state the stage and outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | `Invoke-DocsOnlyGhExe`, `Invoke-DocsOnlyGitExe`, and checkpoint read seams are mocked; the corpus is read in place. |
| **Use Mocks/Stubs** | ✅ PASS | Wrapper seams only. |
| **Environment Stability** | ✅ PASS | No temporary files; leak scan 0 failures (`evidence/qa-gates/final-qc-powershell-static.2026-11-24T12-54.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit and the executor self-review `evidence/qa-gates/self-review.2026-11-24T13-11.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1233; `spec.md` v0.2 decisions D1 to D7; research `research/research.2026-11-24T04-02.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-23T22-42.md`: 33 of 33 tasks checked. |
| **Document the plan** | ✅ PASS | Task-check evidence per task under `evidence/other/`; phase gates under `evidence/qa-gates/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One predicate and one linear stage function inserted after stage 1; one selector per validator runtime. |
| **Reusability** | ✅ PASS | Reuses `Test-EpicMergeGateChildCiObjectId`, `Get-EpicMergeGateChildCiProperty`, `Test-EpicMergeGateReviewModeConcurrent`, `Get-EpicMergeGateLastReviewOutcome`, `Test-EpicMergeGateReviewFeatureFolder`, `Invoke-DocsOnlyGhExe`, `Invoke-DocsOnlyGitExe`, `missingObjectKeys`, and `validateCompletionCiGate`. |
| **Extensibility** | ✅ PASS | `-GitRoot` is optional with a default; the key is a string enum with a default. |
| **Separation of concerns** | ✅ PASS | Pure predicates and path checks are separate from the two process seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The opt-out lives in the child-CI helper; the TypeScript port is its own module. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts: `jest.config.cjs` 689; `enforce-completion-consistency.Tests.ps1` 588; child-CI helper 581 (four copies); completion-checks module 555 (two copies); Python validator 536. No covered file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | Python helpers are private; the TypeScript module exports only the predicate, the validator, and the selector. |
| **No circular dependencies** | ✅ PASS | `orchestrator-state-child-ci.ts` imports only `orchestrator-state-completion`, which does not import it back (reviewer grep). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs; names carry `ChildCi` or `LocalQc`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help, Python docstrings, and TSDoc on every new function. |
| **Comment why, not what** | ✅ PASS | Comments state the fail-closed rule and the self-declared-key bound. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat`, `black --check .`, `prettier --check`<br>**Result:** 0 changes (`final-qc-*-static.2026-11-24T12-54.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze`, `ruff check .`, `eslint src test`<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`; `tsc -p ./ --noEmit`; `tsc -p tsconfig.jest.json --noEmit`<br>**Result:** 0 errors |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester`, `pytest`, `jest-extension`<br>**Result:** 29521, 17126, 6730 tests; 0 failures |
| **Full toolchain loop** | ✅ PASS | Two restarts after remediation (`final-qa-remediation.2026-11-24T11-53.md`, `12-54.md`); the final pass was clean. After the main sync, targeted Pester (2082 tests) and pytest (52 tests) passed. |
| **Explicit reporting** | ✅ PASS | Each command and exit code is recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages carry `(reduction: 0014)`; executor self-review. |
| **Design choices explained** | ✅ PASS | Spec decisions D1 to D7; helper header. |
| **Update supporting documents** | ✅ PASS | Rule and brief changed through their sources; generator `-Check` no drift after the main sync. |
| **Provide next steps** | ✅ PASS | F1 remediation; pull request `CI` at S9. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | `black --check .`: 1071 files unchanged |
| **Linting with Ruff** | ✅ PASS | `ruff check .`: all checks passed |
| **Type checking with Pyright** | ✅ PASS | 0 errors, 0 warnings |
| **No new Python module** | ✅ PASS | Inline, key-gated change in one existing file, as the spec requires |

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 files formatted; one operator-spacing regression (`$ciGate =(`) is outside the enabled formatter rules (code review Nit) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings |
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on every new function |
| **Cross-runtime parity** | ❌ FAIL | `Get-OrchestratorStateCompletionLocalQcGateError` reads new keys case-insensitively; diverges from Python on case-variant keys (F1) |

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | All matched files use Prettier code style |
| **Linting with ESLint** | ✅ PASS | 0 findings |
| **Type checking with TSC** | ✅ PASS | 0 errors in both projects |
| **Architecture boundary** | ✅ PASS | No dependency-cruiser configuration exists in the repository; no cycle introduced (reviewer grep) |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS | pytest with parametrized corpus rows in `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py` |
| **Location** | ✅ PASS | Under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/` |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Pester through `Invoke-PoshQCParallelTest` |
| **Organization** | ✅ PASS | `tests/scripts/claude-hooks/`, `tests/scripts/codex-hooks/`, `tests/scripts/claude-lib/orchestrator-state/`, `tests/scripts/claude-runtime/` |
| **File Naming** | ✅ PASS | All suites end in `.Tests.ps1` |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS | Jest; `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts` mirrors `src/lib/validate/` |
| **Per-file threshold** | ✅ PASS | New `coverageThreshold` entry (85 lines, 75 branches) met at 100% / 100% |

---

## 5. Test Coverage Detail

### enforce-epic-merge-gate-child-ci.ps1 (Claude and Codex)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Allow rows, deny rows per stage, base and pattern fallbacks, default rows, call-count rows | Positive/Negative/Edge Case | Claude 158/158; Codex 156/158 | ✅ |

**Coverage:** Claude 100%, Codex 98.73%. **Not covered:** Codex lines 241 and 495, both pre-existing.

### Completion hooks and module

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Completion-consistency opt-out rows; helper rows; corpus rows | Positive/Negative | consistency 155/161 and 164/164; helpers 84/90 and 90/90; module 145/147 | ✅ |

**Coverage:** every file at or above 93.33%. **Not covered:** pre-existing lines, plus line 196 of the Claude helpers copy (covered through the identical Codex copy).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 29521 Pester, 17126 pytest, 6730 Jest (final gates) | ✅ |
| Tests Passed | All except 18 Pester and 6 pytest skipped (unchanged from baseline) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Pester 756.54 s (8 workers); pytest 190.41 s | ✅ |
| Functions/Classes Tested | All new functions | ✅ |
| Code Coverage (if applicable) | PowerShell 96.87%; Python 98.02% / 95.48%; TypeScript 97.59% / 94.98% | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PowerShell static | `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCLeakScan` | 0 changes, 0 findings, 0 failures | ✅ |
| Python static | `black --check`, `ruff check`, `pyright` | 0 findings | ✅ |
| TypeScript static | `prettier --check`, `eslint`, `tsc --noEmit` (two projects) | 0 findings | ✅ |
| Generator | `Invoke-HarnessGeneration.ps1 -Check`; Codex generator `--check` | no drift; exit 0 | ✅ |
| Quality tiers | `check_quality_tiers` (reviewer) | OK, 38 entries | ✅ |

---

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 formatter changes, 0 analyzer findings | 55a6c517e (content unchanged in `.ps1` except a comment-only fix at 16022bae3) | `evidence/qa-gates/final-qc-powershell-static.2026-11-24T12-54.md` |
| poshqc / PowerShell QC shards | pass | 29521 tests, 0 failures; 2082 targeted post-sync | 55a6c517e; post-sync 16022bae3 | `final-qc-pester.2026-11-24T13-00.md`; `post-sync-check.2026-11-24T13-36.md` |
| quality-checks7 / Enforce Python coverage thresholds | pass | 98.02% lines, 95.48% branches | 55a6c517e (no `.py` change after) | `final-qc-pytest.2026-11-24T13-06.md`; reviewer parse of `artifacts/python/lcov.info` |
| extension tests / Jest | pass | 6730 tests; 97.59% lines | 55a6c517e (no `.ts` change after) | `final-qc-jest.2026-11-24T13-09.md` |
| root TypeScript tests | pass | 98.44% lines, 94.65% branches repo-wide | 0fc83af8b | `evidence/qa-gates/review-jest-root.2026-11-24T14-19.md` |
| docs-validation / generator drift | pass | no drift | 16022bae3 | `post-sync-check.2026-11-24T13-36.md` |

No pull request exists for the branch, so no CI result is available; every row relies on local evidence, and the orchestrator compares these claims with CI at the pull request head at the CI green gate.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All executor evidence is under `.dev/active/1233-epic-child-ci-opt-out/evidence/<kind>/`. The reviewer's root Jest record is written to `evidence/qa-gates/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Vendored Coverage Exemptions

No `vendored-coverage-exemptions.json` beside any coverage output, no coverage-exclusion entry added (the `jest.config.cjs` change adds a threshold entry only), and no `.push-down-manifest.json` change on the branch.

## Rejected Scope Narrowing

None. The caller prompt named the full branch range (merge base `23458fade` to head `0fc83af8b`) and did not narrow scope, files, languages, or checks.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. F1 (blocking): PowerShell completion-validator parity on case-variant keys. See `remediation-inputs.2026-11-24T13-43.md`.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None.** Skipped counts (18 Pester, 6 pytest) are unchanged from baseline.

### Assumptions

- Repo-wide PowerShell coverage is taken from the final full gate at 55a6c517e (96.87%). The current `artifacts/pester/powershell-coverage.xml` is the executor's post-sync targeted run (root 10.94%, not repo-wide). Files changed after the final gate (both epic merge gates, through the main sync and the comment-only fix) are re-read from the current report, which ran every merge-gate suite: Claude gate 147/149, Codex gate 180/183, with every branch-changed line covered.
- The reviewer ran a root Jest coverage run because the canonical `coverage/lcov.info` was absent; this is a reviewer run, not a rerun of the executor's gate.

---

## 9. Summary of Changes

The branch lets an epic opt its children out of per-child `CI` with `child_ci: integration_only`, replacing the child `CI` merge condition with local final-QC evidence bound to a current concurrent review, while the integration pull request into `main` still requires a full green `CI` run.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain, coverage, mirror, generator, evidence-location, and file-size requirements are met for PowerShell, Python, and TypeScript. One blocking cross-runtime parity finding (F1) requires remediation.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plan present
- ✅ Design Principles: reuse of existing helpers
- ✅ Module & File Structure: largest covered file 689 lines
- ✅ Toolchain Execution: clean final pass after two restarts

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python: inline, key-gated, static clean
- ❌ PowerShell: parity defect F1
- ✅ TypeScript: static clean, own threshold

#### General Unit Test Policy (Section 1)
- ✅ Core Principles and coverage thresholds met

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Pester, pytest, and Jest suites in mirrored locations

### Metrics Summary

- ✅ 0 failing tests across 29521 Pester, 17126 pytest, 6730 Jest tests
- ✅ PowerShell 96.87%; Python 98.02% / 95.48%; TypeScript 97.59% / 94.98%
- ✅ All 21 changed bundle copies identical to their sources

### Recommendation

**Remediate F1** (light path), then re-review.

---

## Appendix A: Test Inventory

- New: `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`, `tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`, corpus `tests/fixtures/orchestrator_state_child_ci/` (19 files)
- Extended: `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`, `tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1`, `tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1`, `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`

---

## Appendix B: Toolchain Commands Reference

```text
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest --coverage   (reviewer root run)
python scripts/dev_tools/validate_evidence_locations.py --root .
python -m scripts.dev_tools.check_quality_tiers
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-24
**Policy Version:** Current (as of audit date)
