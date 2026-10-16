# Policy Compliance Audit: npm token guard misses append assignment (#933)

---

**Audit Date:** 2026-10-16
**Audit Type:** Initial feature review (feature-vs-base)
**Branch:** `bug/npm-token-guard-misses-append-assignment-933` (HEAD `5afda6fc7b0e168a13634f366e8f568bc2f4cd9e`)
**Base:** `origin/main` (`adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`; merge base equals the `origin/main` tip)
**Work Mode:** `minor-audit`
**Code Under Test:** 42 changed files (1883 insertions, 12 deletions). Outside the feature folder only two Python test-tree files changed: `M tests/scripts/dev_tools/npm_token_guard_test_support.py` (regex alternative B and `find_npm_token_assignments` docstring) and `M tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (six new parametrize rows, one flipped pinned row, docstring). The remaining 40 files are feature-folder documentation and evidence. No production file under `src/` or `scripts/` changed.

**Total blocking findings: 0.**

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files (0 production, 2 test-tree) | 7106 collected (full suite); 66 in the guard module | ✅ 7100 passed, 0 failed, 6 skipped (full suite); 66 passed (guard module, reviewer rerun) | 93.80% lines, 88.11% branches | 93.80% lines, 88.13% branches | PASS: 0 production Python lines added or modified, so no changed production line is uncovered or regressed; repo-wide 93.80% / 88.13% meets 85% / 75% |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: N/A (no PowerShell file changed on the branch)
- PowerShell post-change coverage artifact: N/A (no PowerShell file changed on the branch)
- Python baseline coverage artifact: `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-pytest-coverage.2026-10-16T00-18.md` and `evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md`
- Python post-change coverage artifact: `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-pytest-coverage.2026-10-16T00-34.md`, `evidence/qa-gates/final-coverage-percentages.2026-10-16T00-34.md`, `evidence/qa-gates/final-coverage-thresholds.2026-10-16T00-34.md`
- Python coverage data file inspected by the reviewer: `artifacts/python/lcov.info` (written 2026-10-16 00:33 UTC by the final full-suite run)
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/coverage-comparison.2026-10-16T00-36.md`

---

## Executive Summary

The branch resolves issue #933: the workflow npm token guard did not report the append form `NPM_TOKEN+=${{ secrets.X }}`. Alternative B of `_NPM_TOKEN_ASSIGNMENT` in `tests/scripts/dev_tools/npm_token_guard_test_support.py:47` changes from `\bNPM_TOKEN\s*=(?!=)` to `\bNPM_TOKEN\s*\+?=(?!=)`. The test module adds three detection rows (`bash-append-secret-expression`, `shell-export-append`, `powershell-env-append`), two non-regression rows (`longer-name-append`, `arithmetic-increment`), one pinned non-regression row (`accepted-append-double-equals-not-reported`), and flips the #903 pinned row `residual-bash-append-not-reported` to `bash-append-reported` with expectation `[1]`. Reversal of the #845 append non-goal is an operator decision (D1 in `issue.md` line 59) and is not a finding.

The reviewer reran the guard module tests (66 passed), `black --check`, `ruff check --no-fix`, and `pyright` on both changed files (all clean), recomputed repo-wide Python coverage from `artifacts/python/lcov.info` (16544/17638 lines = 93.80%, 5612/6368 branches = 88.13%), ran `validate_evidence_locations.py` (exit 0), and probed the new pattern against 23 inputs in memory (results in section 8). No policy violation was found. Two non-blocking observations are recorded (PA-1, PA-2) and one pending CI item (PA-3).

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- ✅ `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on base; the `tests/` tree falls under the root `.` entry, tier T4)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/python.md` (Python code change and unit test)
- N/A PowerShell: no changed files.
- N/A TypeScript: no changed files.
- N/A C#: no changed files.
- N/A GitHub Actions: no changed workflow files; the `modified-workflow-needs-green-run` rule does not fire.

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed. `git diff --name-only origin/main...HEAD` lists no file under `artifacts/`.
- ✅ No ongoing tooling script was added.
- The reviewer's regex probe script was written to the session scratchpad only; no tracked file other than the review artifacts was written.

---

## Rejected Scope Narrowing

None detected. The caller prompt fixed the diff at `git diff origin/main...HEAD`, which matches the resolved merge base, and did not narrow scope to a plan, phase, task, file subset, or language. The caller statements that `spec.md` and `user-story.md` are absent by design (minor-audit) and that the #845 non-goal reversal is an operator decision are consistent with `issue.md` lines 12 and 59 and are not scope narrowing. The caller instruction to evaluate AC-9 as pending CI is consistent with the CI-dependent criterion protocol in `acceptance-criteria-tracking`.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (run by the reviewer at `5afda6fc7`): exit 0, no output.
- `git diff --name-only origin/main...HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 37 evidence files sit under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`. For every file the filename stamp equals its `Timestamp:` row (reviewer grep), and every stamp precedes the UTC commit time of the commit that added it (test commit `10399c2b0` at 00:28 UTC follows `pass-after.2026-10-16T00-27.md`; QC commit `7a804e47b` at 00:41 UTC follows the latest QC stamp 00-39).
- Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entries were needed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New rows are pure calls of `find_npm_token_assignments` on parametrized in-memory strings; no shared mutable state. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each row asserts the line list for one input string against one finder. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer rerun: 66 passed in 0.29s. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, sleep, network, or process use; reviewer grep for `tmp_path`, `tempfile`, `mkdtemp`, `time.sleep`, `random` in both files returned no match. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Each row has a descriptive `id`; the pinned-residual docstring (`test_workflow_npm_token_guard.py:298-308`) records the #933 reversal. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** Python 93.79748% lines / 88.11244% branches (`evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md`).<br>**Timestamp:** 2026-10-16T00-18 to 00-19 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 93.79748% lines / 88.12814% branches (`evidence/qa-gates/final-coverage-percentages.2026-10-16T00-34.md`); reviewer recomputation from `artifacts/python/lcov.info`: 93.80% / 88.13%.<br>**Status:** No regression. No production line changed. |
| **New Code Coverage ≥85% (uniform tier rule)** | ✅ PASS | No new or modified production file. Both changed files are under `tests/`, which `pyproject.toml` `[tool.coverage.run] omit` (lines 122-127) excludes as permitted non-production paths. |
| **Comprehensive Coverage** | ✅ PASS | The new alternative-B branch (`\+?`) is exercised by positive rows (`+=` forms) and negative rows (`+==`, `NPM_TOKEN_V2+=`, `NPM_TOKEN++`). |
| **Positive Flows** - Valid inputs | ✅ PASS | `test_workflow_npm_token_guard.py:224-228` (three append rows) and line 284 (`bash-append-reported`). |
| **Negative Flows** - Invalid inputs | ✅ PASS | `test_workflow_npm_token_guard.py:256-257` (`longer-name-append`, `arithmetic-increment`) and lines 290-292 (`accepted-append-double-equals-not-reported`). |
| **Edge Cases** - Boundary conditions | ✅ PASS | `+==` boundary pinned; PowerShell spaced `+=` covered. Untested edges recorded as non-blocking (PA-2). |
| **Error Handling** - Error paths | N/A | The finder has no error path; it returns a list. |
| **Concurrency** - If applicable | N/A | No concurrent code. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.79748% lines, 88.11244% branches -> Post-change: 93.79748% lines, 88.12814% branches. Change: +0.0% lines, +0.016% branches (partial branches 505 -> 504 in production paths this change did not touch). New/changed-code coverage: PASS; the branch adds or modifies 0 production Python lines (`git diff --name-only origin/main...HEAD -- src scripts` returns nothing, reviewer rerun), so no changed production line is uncovered or regressed. The two changed Python files are test-tree files omitted from measurement by the permitted `tests/*` exclusion. Repo-wide thresholds 85% line / 75% branch met (root `CLAUDE.md` states no coverage threshold, so the defaults govern). Disposition: PASS. Evidence: `evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md`, `evidence/qa-gates/final-coverage-percentages.2026-10-16T00-34.md`, `evidence/qa-gates/coverage-comparison.2026-10-16T00-36.md`, `artifacts/python/lcov.info`.
- PowerShell, TypeScript, C#: no changed files on the branch. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions report the input and actual result, for example `test_workflow_npm_token_guard.py:315`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | All three affected test functions carry `# Arrange`, `# Act`, `# Assert` markers (lines 235-241, 262-268, 309-315). |
| **Document Intent** | ✅ PASS | Row ids describe intent; the pinned-residual docstring explains the #845 to #933 change. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Unit rows use in-memory strings. The pre-existing tree-scan tests read `.github/` files through `pathlib`; unchanged. |
| **Use Mocks/Stubs** | N/A | No collaborator to mock. |
| **Environment Stability** | ✅ PASS | No temporary file creation (reviewer grep). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit. Outstanding non-blocking item: AC-9 pending PR CI (PA-3). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` lines 57-69 state the adopted approach and AC-1 to AC-9. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-16T00-08.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-15T17-44.md`: 56 checked tasks, 0 unchecked (reviewer grep). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One-token regex change (`\+?`). |
| **Reusability** | ✅ PASS | Reuses `_matching_line_numbers`; no duplication. |
| **Extensibility** | ✅ PASS | No API change; `find_npm_token_assignments` signature unchanged. |
| **Separation of concerns** | ✅ PASS | Pattern and finders remain in the support module; tests remain in the test module. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Changes confined to the guard support module and its test module. |
| **Under 500 lines** | ✅ PASS | Reviewer `wc -l`: support module 180, test module 400. |
| **Public vs internal** | ✅ PASS | `_NPM_TOKEN_ASSIGNMENT` remains private. |
| **No circular dependencies** | ✅ PASS | Import graph unchanged. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Row ids such as `powershell-env-append`, `accepted-append-double-equals-not-reported`. |
| **Docs/docstrings** | ⚠️ PARTIAL | `find_npm_token_assignments` docstring (`npm_token_guard_test_support.py:122-130`) was updated, but its claim that a context read such as `env.NPM_TOKEN` and "a longer or prefixed name" are not reported does not hold for dot- or hyphen-prefixed assignment forms (PA-1, Non-blocking, pre-existing behavior extended to `+=`). |
| **Comment why, not what** | ✅ PASS | Docstrings cite issue #933 as the reason for the change. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check <two files>`<br>**Result:** reviewer rerun "2 files would be left unchanged"; executor `evidence/qa-gates/final-black.2026-10-16T00-30.md`. |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check --no-fix <two files>`<br>**Result:** "All checks passed!" (reviewer rerun). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <two files>`<br>**Result:** 0 errors, 0 warnings (reviewer rerun). |
| **4. Architecture-boundary tests** | N/A | No Python architecture-boundary suite applies to the changed test files. |
| **5. Testing** | ✅ PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`<br>**Result:** 66 passed (reviewer rerun); full suite 7100 passed, 6 skipped, 0 failed (`evidence/qa-gates/final-pytest-coverage.2026-10-16T00-34.md`). |
| **6. Contract / schema checks** | N/A | No contract or schema surface changed. |
| **7. Integration tests** | N/A | No integration surface changed; the tree-scan tests pass. |
| **Full toolchain loop** | ✅ PASS | `evidence/qa-gates/final-loop-single-pass.2026-10-16T00-35.md`: pass 1 reformatted one file and restarted; pass 2 clean in a single pass. |
| **Explicit reporting** | ✅ PASS | Every stage has a timestamped evidence artifact. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `10399c2b0` message and plan check-off. |
| **Design choices explained** | ✅ PASS | `research/research.2026-10-15T17-50.md` and `issue.md` line 59 (D1). |
| **Update supporting documents** | ✅ PASS | Reviewer grep outside `docs/features/` finds no other statement of the append non-goal. |
| **Provide next steps** | ✅ PASS | AC-9 recorded as pending CI (`evidence/qa-gates/ac9-ci-pending.2026-10-16T00-39.md`). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check`<br>**Result:** clean (reviewer rerun). |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check --no-fix`<br>**Result:** clean (reviewer rerun). |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors (reviewer rerun). |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest`<br>**Result:** 66 passed (module); 7100 passed (full suite, executor evidence). |
| **Type hints** | ✅ PASS | No new function; existing signatures fully annotated. |
| **No suppressions added** | ✅ PASS | No `# noqa`, `# type: ignore`, or `# pyright:` comment added (diff read). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `pytest.mark.parametrize` with `pytest.param(..., id=...)`. |
| **Coverage expectation** | ✅ PASS | Repo-wide 93.80% line / 88.13% branch; no production change. |
| **Focused unit tests / organization / naming** | ✅ PASS | Test file at `tests/scripts/dev_tools/`, mirrors the existing layout; `test_` prefix; no colocation in production tree. |
| **No temporary files** | ✅ PASS | Reviewer grep found no `tmp_path`, `tempfile`, or `mkdtemp`. |
| **Property-based tests** | N/A | Tier T4 (root `.` entry in `quality-tiers.yml`); property tests are required only for T1/T2. |

---

## 5. Test Coverage Detail

### `tests/scripts/dev_tools/npm_token_guard_test_support.py`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_find_npm_token_assignments_detects_assignment[bash-append-secret-expression]` | Positive | 47, 138 | ✅ |
| `test_find_npm_token_assignments_detects_assignment[shell-export-append]` | Positive | 47, 138 | ✅ |
| `test_find_npm_token_assignments_detects_assignment[powershell-env-append]` | Positive | 47, 138 | ✅ |
| `test_find_npm_token_assignments_ignores_non_matching_text[longer-name-append]` | Negative | 47, 138 | ✅ |
| `test_find_npm_token_assignments_ignores_non_matching_text[arithmetic-increment]` | Negative | 47, 138 | ✅ |
| `test_find_npm_token_assignments_pins_documented_residuals[bash-append-reported]` | Positive (flipped pin) | 47, 138 | ✅ |
| `test_find_npm_token_assignments_pins_documented_residuals[accepted-append-double-equals-not-reported]` | Edge Case | 47, 138 | ✅ |

**Coverage:** PASS. The module is test infrastructure under `tests/`, which the permitted `tests/*` entry omits from production coverage measurement. Every line of the module executes during the guard module run. Repo-wide Python coverage is 93.80% line / 88.13% branch.

**Not covered:** None identified.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | pytest 7106 collected (full suite); 66 in the guard module | ✅ |
| Tests Passed | 7100 (full suite); 66 (guard module) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Full suite 155.72s; guard module 0.29s (reviewer) | ✅ |
| Average Time per Test | Guard module about 4ms | ✅ Fast |
| Discovery Time | Not separately reported | N/A |
| Functions/Classes Tested | `find_npm_token_assignments` (new `+=` branch, positive and negative) | ✅ |
| Test File Size | 400 and 180 lines | ✅ |
| Code Coverage (if applicable) | Python 93.80% line / 88.13% branch | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check <two files>` | 2 files would be left unchanged | ✅ |
| Ruff | `poetry run ruff check --no-fix <two files>` | All checks passed! | ✅ |
| Pyright | `poetry run pyright <two files>` | 0 errors, 0 warnings, 0 informations | ✅ |
| Pytest | `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` | 66 passed | ✅ |

**Notes:**
The fail-before evidence (`evidence/regression-testing/fail-before.2026-10-16T00-25.md` lines 59-61, 75, 291-295) shows exactly the four AC-1/AC-2 rows failing (4 failed, 62 passed) against the unmodified pattern; `evidence/regression-testing/pass-after.2026-10-16T00-27.md` shows 66 passed.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (Non-blocking, Minor):** `tests/scripts/dev_tools/npm_token_guard_test_support.py:47`. Alternative B uses `\b` rather than the `(?<![\w.-])` lookbehind that alternative A uses, so a `.` or `-` prefix is accepted. Reviewer probe: `env.NPM_TOKEN += x` and `MY-NPM_TOKEN+=x` are reported by the new pattern. The same inputs with `=` were already reported before this branch, so the behavior is pre-existing and the branch extends it to `+=`. The rewritten docstring at lines 127-130 states that a context read (`env.NPM_TOKEN`) and "a longer or prefixed name" are not reported, which is inaccurate for these assignment forms. The deviation over-reports (fails closed) and no file under `.github/` matches today (tree-scan rows pass). Recommendation: either narrow the docstring wording (for example "a longer name or a letter-, digit-, or underscore-prefixed name") or align alternative B with the alternative A lookbehind and add pinning rows.
- **PA-2 (Non-blocking, Nit):** Untested accepted outcomes of the new pattern. Reviewer probe: `(( NPM_TOKEN += 1 ))` (bash arithmetic compound assignment) and `NPM_TOKEN +=x` (space before `+`, which bash parses as a command, not an assignment) are reported; `NPM_TOKEN+ =x` and `NPM_TOKEN++=x` are not. None of these is pinned by a test row. Recommendation: add an `arithmetic-compound-append` row expecting `[1]` so the arithmetic case is characterized next to `arithmetic-increment`.
- **PA-3 (Non-blocking, pending CI):** AC-9 (`quality-checks7` on the PR head) cannot be verified before the PR exists; it is correctly unchecked (`issue.md` line 69, `evidence/qa-gates/ac9-ci-pending.2026-10-16T00-39.md`). The item's orchestrator run owns the check-off at S9.
- **PA-4 (Info):** The MCP template resolver `resolve_policy_audit_template_asset` is not in this agent's tool allowlist. The artifact structure follows the canonical headings listed in `policy-audit-template-usage` and the previously validated review set for #903.

### Approved Exceptions

- Operator decision D1 (`issue.md` line 59): the #845 spec non-goal that classed bash `NPM_TOKEN+=x` as an unreported residual is reversed. Not a finding.

### Removed/Skipped Tests

- No test removed. The pinned row `residual-bash-append-not-reported` was renamed to `bash-append-reported` with a flipped expectation (AC-2). The six skipped full-suite tests are identical to baseline (`final-pytest-coverage.2026-10-16T00-34.md` notes).

---

## 9. Summary of Changes

1. **babb2c2a4 / 8878ebb96** - feature folder, research, minor-audit acceptance criteria
2. **26f0660a2 / a9568e6e4 / 9bc93aaab** - atomic plan and two preflight revisions
3. **4bcdd118f** - phase 0 baseline evidence
4. **10399c2b0** - test: report `NPM_TOKEN` append assignments in the npm token guard (regex, rows, docstrings)
5. **7a804e47b / 5afda6fc7** - final QC evidence, AC check-off, plan check-off

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

All toolchain stages pass, coverage is at or above baseline and thresholds, file sizes are within limits, evidence locations and timestamps are compliant, and no production file changed. PA-1 and PA-2 are non-blocking documentation and test-characterization observations; PA-3 is a pending CI-dependent criterion.

**Total blocking findings: 0.**

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes / Design / Structure / Toolchain / Documentation: compliant
- ⚠️ Docs/docstrings: PARTIAL (PA-1, non-blocking)

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python: compliant

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ✅ Coverage & Scenarios: no regression
- ✅ Test Structure / External Dependencies: compliant

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python: compliant

---

### Metrics Summary

- ✅ pytest 7100 passed, 0 failed, 6 skipped (full suite); 66/66 (guard module)
- ✅ Python 93.80% line / 88.13% branch (baseline 93.80% / 88.11%)
- ✅ Changed files 180 and 400 lines

---

### Recommendation

**Ready for PR**

Optionally address PA-1 and PA-2 inside this item before opening the PR. After the PR is open, confirm `quality-checks7` succeeds on the PR head and check off AC-9.

---

## Appendix A: Test Inventory

1. `test_find_npm_token_assignments_detects_assignment[bash-append-secret-expression]` (new)
2. `test_find_npm_token_assignments_detects_assignment[shell-export-append]` (new)
3. `test_find_npm_token_assignments_detects_assignment[powershell-env-append]` (new)
4. `test_find_npm_token_assignments_ignores_non_matching_text[longer-name-append]` (new)
5. `test_find_npm_token_assignments_ignores_non_matching_text[arithmetic-increment]` (new)
6. `test_find_npm_token_assignments_pins_documented_residuals[bash-append-reported]` (renamed from `residual-bash-append-not-reported`, expectation flipped)
7. `test_find_npm_token_assignments_pins_documented_residuals[accepted-append-double-equals-not-reported]` (new)

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands:**
```bash
git rev-parse HEAD
git merge-base origin/main HEAD
git diff --stat origin/main...HEAD
git diff origin/main...HEAD -- tests/
git diff --name-only origin/main...HEAD -- src scripts
git diff --name-status origin/main...HEAD -- . ":!docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933"
git log --format="%h %cd %s" origin/main..HEAD
wc -l tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q
poetry run black --check tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run ruff check --no-fix tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pyright tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
awk -F: '/^LF:/{lf+=$2}/^LH:/{lh+=$2}/^BRF:/{bf+=$2}/^BRH:/{bh+=$2}END{...}' artifacts/python/lcov.info
python -I <scratchpad>/probe933.py   # in-memory comparison of the old and new patterns over 23 inputs
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)
