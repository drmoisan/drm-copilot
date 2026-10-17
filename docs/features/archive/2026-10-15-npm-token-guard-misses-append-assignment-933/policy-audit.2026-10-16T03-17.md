# Policy Compliance Audit: npm token guard misses append assignment (#933)

---

**Audit Date:** 2026-10-16
**Audit Type:** Remediation cycle 2 re-review (reaudit, feature-vs-base)
**Branch:** `bug/npm-token-guard-misses-append-assignment-933` (HEAD `987161b95518fb0b621910c14a6f93861627b91e`, pushed)
**Base:** `origin/main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Work Mode:** `minor-audit`
**Code Under Test:** 137 changed files (4901 insertions, 13 deletions). Outside the feature folder only two Python test-tree files changed: `M tests/scripts/dev_tools/npm_token_guard_test_support.py` (regex alternative B and the `find_npm_token_assignments` docstring) and `M tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (ten new parametrize rows, one flipped pinned row, two rewritten docstrings). The remaining files are feature-folder documentation and evidence. No production file under `src/` or `scripts/` changed. Remediation cycle 2 (commits `3bc4ee9d1` to `987161b95`) changed one docstring line in each of the two test-tree files and one line of the cycle 1 remediation plan; all other cycle 2 paths are cycle 2 inputs, plan, and evidence (`git diff --stat 6cb038e9e..HEAD`, reviewer rerun).

**Total blocking findings: 0.**

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files (0 production, 2 test-tree) | 7110 collected (full suite); 70 in the guard module | ✅ 7104 passed, 0 failed, 6 skipped (full suite, executor evidence); 70 passed (guard module, reviewer rerun) | 93.80% lines, 88.11% branches (original pre-change baseline) | 93.80% lines, 88.11% branches | PASS: 0 production Python lines added or modified, so no changed production line is uncovered or regressed; the two changed files are test-tree files omitted by the permitted `tests/*` entry; repo-wide 93.80% / 88.11% meets 85% / 75% |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: N/A (no PowerShell file changed on the branch)
- PowerShell post-change coverage artifact: N/A (no PowerShell file changed on the branch)
- Python baseline coverage artifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md (original pre-change) and docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-coverage-reference.2026-10-16T02-57.md (cycle 2 reference)
- Python post-change coverage artifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-pytest-coverage.2026-10-16T03-07.md, docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-coverage-percentages.2026-10-16T03-07.md, docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-coverage-thresholds.2026-10-16T03-07.md
- Python coverage data file inspected by the reviewer: artifacts/python/lcov.info (written 2026-10-16 03:06 UTC by the cycle 2 final full-suite run)
- Per-language comparison summary: section 1.2.1 of this audit and docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-coverage-comparison.2026-10-16T03-08.md

---

## Executive Summary

This is the reaudit after remediation cycle 2, which addressed three non-blocking findings carried from the cycle 1 reaudit (`policy-audit.2026-10-16T02-19.md`): F4 (test docstring of `test_find_npm_token_assignments_ignores_non_matching_text`), F5 (article in the `find_npm_token_assignments` docstring), and F6 (the D6 rationale wording in the cycle 1 plan, which was PA-5 / CR-5).

The reviewer confirmed that no executable line changed in cycle 2: a docstring-stripped AST comparison of both test-tree files between `6cb038e9e` (cycle entry) and HEAD reports the code ASTs equal while the full ASTs differ, so only docstrings changed. The executor's line-level probe (`rc2-changed-lines.2026-10-16T03-09.md`) shows exactly lines 132, 265, and 242 differing in the three edit targets, and the regex digest is unchanged (`rc2-regex-unchanged.2026-10-16T03-09.md`).

The reviewer reran the guard module tests (70 passed), `black --check`, `ruff check --no-fix`, and `pyright` on both changed files (all clean), recomputed repo-wide Python coverage from artifacts/python/lcov.info (16544/17638 lines = 93.7975%, 5611/6368 branches = 88.1124%), ran `validate_evidence_locations.py` (exit 0), and verified that the filename stamp of all 42 cycle 2 evidence files equals its `Timestamp:` row.

F4, F5, and F6 are resolved; PA-5 (as far as this item's own wording) and CR-6 are closed. AC-9 remains pending CI (PA-3). One new Info observation concerns the cycle 2 plan header (PA-6).

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
- The reviewer's AST comparison script was written to the session scratchpad only; no tracked file other than the review artifacts was written.

---

## Rejected Scope Narrowing

None detected. The caller prompt fixed the diff at `git diff origin/main...HEAD`, which matches the resolved merge base, and did not narrow scope to a plan, phase, task, file subset, or language. The caller statements that `spec.md` and `user-story.md` are absent by design (minor-audit) and that AC-9 is pending CI are consistent with `issue.md` line 12 and the CI-dependent criterion protocol. The caller instruction to treat UF-1 and UF-2 as unrelated follow-ups was checked against the item: neither was worsened by the branch (the cycle 2 final run recorded 505 partial branches, equal to the original pre-change run). One caller statement was corrected by evidence: the caller described the cycle 2 plan as 52/52; the reviewer count is 50 checked tasks and 0 unchecked (`grep -c` on the plan), all of which are complete.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (reviewer rerun at `987161b95`): exit 0, no output.
- `git diff --name-only origin/main...HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- The 42 cycle 2 evidence files sit under `<FEATURE>/evidence/{remediation-baseline,qa-gates}/`. For every one, the filename stamp equals its `Timestamp:` row (reviewer loop). Stamps precede the commits that added them: `c254d0f9f` (02:58 UTC) follows the latest baseline stamp 02-57; `3da42a36d` (03:02 UTC) follows `rc2-after-edit.2026-10-16T03-01.md`; `e0f28fea5` (03:11 UTC) follows the latest final-QC stamp 03-10.
- Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entries were needed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Rows are pure calls of `find_npm_token_assignments` on parametrized in-memory strings; no shared mutable state. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each row asserts the line list for one input string against one finder. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer rerun: 70 passed in 0.14s. |
| **Determinism** - Consistent results | ✅ PASS | The changed tests use no clock, randomness, sleep, network, or process. The full-suite branch-coverage variance (UF-2) originates outside the changed files and is tracked separately. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | The non-matching test docstring (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py:265`) now describes every row it hosts (F4). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** Python 93.79748% lines / 88.11244% branches (docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md); cycle 2 reference docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-coverage-reference.2026-10-16T02-57.md.<br>**Timestamp:** 2026-10-16T00-19 and 2026-10-16T02-57 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 93.79748% lines / 88.11244% branches (docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-coverage-percentages.2026-10-16T03-07.md); reviewer recomputation from artifacts/python/lcov.info: 93.7975% / 88.1124%.<br>**Status:** No regression on changed lines (0 production lines changed). Equal to the original pre-change baseline (D6 floor). |
| **New Code Coverage ≥85% (uniform tier rule)** | ✅ PASS | PASS: 0 production lines added or modified. Both changed files are under `tests/`, which `pyproject.toml` `[tool.coverage.run] omit` excludes as a permitted non-production path. |
| **Comprehensive Coverage** | ✅ PASS | Cycle 2 changes no row; the alternative-B `\+?` path remains exercised by positive rows (seven `+=` forms) and negative rows (`+==`, `++=`, `NPM_TOKEN_V2+=`, `NPM_TOKEN++`). |
| **Positive Flows** - Valid inputs | ✅ PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:224-231` and line 288 (`bash-append-reported`). |
| **Negative Flows** - Invalid inputs | ✅ PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:250-261` and lines 294-296. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Dot and hyphen prefixes (lines 229-230), arithmetic compound append (line 231), `++=` (line 261), `+==` (lines 294-296). |
| **Error Handling** - Error paths | N/A | The finder has no error path; it returns a list. |
| **Concurrency** - If applicable | N/A | No concurrent code. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.79748% lines, 88.11244% branches -> Post-change: 93.79748% lines, 88.11244% branches. Change: +0.0% lines, +0.0% branches (baseline is the original pre-change run, post-change is the cycle 2 final run; TOTAL statements 17638, missed 1094, branches 6368, partial branches 505 in both). New/changed-code coverage: PASS; the branch adds or modifies 0 production Python lines (`git diff --name-only origin/main...HEAD -- src scripts` returns nothing, executor evidence rc2-coverage-comparison and reviewer AST check), so no changed production line is uncovered or regressed. Repo-wide thresholds 85% line / 75% branch met (root `CLAUDE.md` states no coverage threshold, so the defaults govern). Disposition: PASS. Evidence: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-coverage-comparison.2026-10-16T03-08.md, artifacts/python/lcov.info.
- D6 floor: the post-change values equal the original pre-change baseline exactly (line 93.79748270779, branch 88.11243718592965). The full-suite partial-branch count has now been recorded as 505, 504, 504, 505, 505 on identical production source; the responsible branch is unidentified and is tracked outside this item as UF-2.
- PowerShell, TypeScript, C#: no changed files on the branch. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions report the ASCII-escaped input and actual result (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py:272`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Markers present (lines 266-272 for the non-matching test). |
| **Document Intent** | ✅ PASS | F4 docstring covers every non-matching row; the pinned-residual docstring explains the #845 to #933 change. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Unit rows use in-memory strings. The pre-existing tree-scan tests read `.github/` files through `pathlib`; unchanged. |
| **Use Mocks/Stubs** | N/A | No collaborator to mock. |
| **Environment Stability** | ✅ PASS | No temporary file creation in the changed files (diff read). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit. Outstanding non-blocking items: AC-9 pending PR CI (PA-3) and PA-6 (Info). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-inputs.2026-10-16T02-27.md` defines F4-F6, scope, and the D4/D6 constraints. |
| **Read existing change plans** | ✅ PASS | docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/phase0-instructions-read.2026-10-16T02-55.md. |
| **Document the plan** | ✅ PASS | docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T02-27.md: 50 checked tasks, 0 unchecked (reviewer grep). Header status is stale (PA-6). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Cycle 2 changes two docstring lines and one plan-deviation entry; no logic change. |
| **Reusability** | ✅ PASS | No new code. |
| **Extensibility** | ✅ PASS | No API change. |
| **Separation of concerns** | ✅ PASS | Pattern and finders remain in the support module; tests remain in the test module. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Changes confined to the guard support module and its test module. |
| **Under 500 lines** | ✅ PASS | 184 and 404 lines (`rc2-line-count.2026-10-16T03-09.md`; line counts unchanged in cycle 2 per the reviewer AST/line check). |
| **Public vs internal** | ✅ PASS | `_NPM_TOKEN_ASSIGNMENT` remains private. |
| **No circular dependencies** | ✅ PASS | Import graph unchanged. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Row ids unchanged in cycle 2. |
| **Docs/docstrings** | ✅ PASS | F4: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:265` reads "Text with no assignment operator applied to ``NPM_TOKEN`` is not reported." (84 characters); it is accurate for all twelve rows at lines 250-261 (context reads and prose carry no operator; `==`/`!=` are comparisons; `:`/`+=` in `NPM_TOKEN_V2`/`MY_NPM_TOKEN` rows apply to a different name; `++` is listed in the bash manual as an increment operator, separate from the assignment operators; `NPM_TOKEN++=x` is not a valid shell assignment). F5: `tests/scripts/dev_tools/npm_token_guard_test_support.py:132` reads "a ``+==`` sequence". Reviewer check: no line over 88 characters in either file. |
| **Comment why, not what** | ✅ PASS | Docstrings cite issue #933 and explain the word-boundary reason for prefixed reporting. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check <two files>`<br>**Result:** reviewer rerun "2 files would be left unchanged."; executor docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-black.2026-10-16T03-03.md. |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check --no-fix <two files>`<br>**Result:** "All checks passed!" (reviewer rerun). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <two files>`<br>**Result:** 0 errors, 0 warnings, 0 informations (reviewer rerun). |
| **4. Architecture-boundary tests** | N/A | No Python architecture-boundary suite applies to the changed test files. |
| **5. Testing** | ✅ PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`<br>**Result:** 70 passed (reviewer rerun); full suite 7104 passed, 6 skipped, 0 failed (docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-pytest-coverage.2026-10-16T03-07.md). |
| **6. Contract / schema checks** | N/A | No contract or schema surface changed. |
| **7. Integration tests** | N/A | No integration surface changed; the tree-scan tests pass. |
| **Full toolchain loop** | ✅ PASS | docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-loop-single-pass.2026-10-16T03-08.md: single clean pass, no rerun. |
| **Explicit reporting** | ✅ PASS | Every stage has a timestamped evidence artifact. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `3da42a36d` message and plan check-off. |
| **Design choices explained** | ✅ PASS | D7 wording rationale in the cycle 2 plan "Exact Text for Phase 1"; D8 attribution change in the cycle 2 plan "Plan Deviations". |
| **Update supporting documents** | ✅ PASS | `issue.md` unchanged in the cycle (`rc2-issue-unchanged.2026-10-16T03-09.md`); AC-9 still unchecked. |
| **Provide next steps** | ✅ PASS | AC-9 pending CI. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check`<br>**Result:** clean (reviewer rerun). |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check --no-fix`<br>**Result:** clean (reviewer rerun). |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors (reviewer rerun). |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest`<br>**Result:** 70 passed (module); 7104 passed (full suite, executor evidence). |
| **Type hints** | ✅ PASS | No new function; existing signatures fully annotated. |
| **No suppressions added** | ✅ PASS | No `# noqa`, `# type: ignore`, or `# pyright:` comment added (diff read). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `pytest.mark.parametrize` with `pytest.param(..., id=...)`. |
| **Coverage expectation** | ✅ PASS | Repo-wide 93.80% line / 88.11% branch; no production change. |
| **Focused unit tests / organization / naming** | ✅ PASS | Test file at `tests/scripts/dev_tools/`; `test_` prefix; no colocation in the production tree. |
| **No temporary files** | ✅ PASS | No `tmp_path`, `tempfile`, or `mkdtemp` in the diff. |
| **Property-based tests** | N/A | Tier T4 (root `.` entry in `quality-tiers.yml`); property tests are required only for T1/T2. |

---

## 5. Test Coverage Detail

### `tests/scripts/dev_tools/npm_token_guard_test_support.py`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_find_npm_token_assignments_detects_assignment[*]` | Positive | 47, 142 | ✅ |
| `test_find_npm_token_assignments_ignores_non_matching_text[*]` | Negative | 47, 142 | ✅ |
| `test_find_npm_token_assignments_pins_documented_residuals[*]` | Pinned residuals | 47, 142 | ✅ |

**Coverage:** PASS. The module is test infrastructure under `tests/`, which the permitted `tests/*` entry omits from production coverage measurement. Every line of the module executes during the guard module run. Repo-wide Python coverage is 93.80% line / 88.11% branch.

**Not covered:** None identified.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | pytest 7110 collected (full suite); 70 in the guard module | ✅ |
| Tests Passed | 7104 (full suite); 70 (guard module) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Full suite 156.30s; guard module 0.14s (reviewer) | ✅ |
| Average Time per Test | Guard module about 2ms | ✅ Fast |
| Discovery Time | Not separately reported | N/A |
| Functions/Classes Tested | `find_npm_token_assignments` | ✅ |
| Test File Size | 404 and 184 lines | ✅ |
| Code Coverage (if applicable) | Python 93.80% line / 88.11% branch | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check <two files>` | 2 files would be left unchanged. | ✅ |
| Ruff | `poetry run ruff check --no-fix <two files>` | All checks passed! | ✅ |
| Pyright | `poetry run pyright <two files>` | 0 errors, 0 warnings, 0 informations | ✅ |
| Pytest | `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` | 70 passed | ✅ |

**Notes:**
Reviewer AST check (scratchpad script, `python -I`): with module, class, and function docstrings removed, the ASTs of both test-tree files at `6cb038e9e` and HEAD are equal; with docstrings retained they differ. Cycle 2 therefore changed no executable line, regex, parametrize row, test id, or assertion.

---

## 8. Gaps and Exceptions

### Closure of prior findings

- **F4 (CR-6, test docstring): Resolved.** Line 265 wording per D7; executor probe `rc2-docstring-f4.2026-10-16T03-09.md` prints `False True True`; reviewer read confirms accuracy for every row (section 2.4).
- **F5 (CR-6, article): Resolved.** Line 132 reads "a ``+==`` sequence"; executor probe `rc2-docstring-f5.2026-10-16T03-09.md` prints `False True True`; reviewer read.
- **F6 / PA-5 (D6 rationale): Closed as far as this item's own wording.** The cycle 1 plan revision 1.1 entry now states that identical production source produced both branch values across the four runs (505, 504, 504, 505), that the responsible branch is not identified, and that the D6 floor does not depend on its cause. The phrases "tracks test-file changes" and "not nondeterminism" are absent from the cycle 1 plan (reviewer grep for `swing|nondetermin|test-file change|not attributable` returns no match; executor `rc2-f6-old.2026-10-16T03-09.md`). The field name `SourceIdenticalRunsEvidence:` remains (count 3, `rc2-f6-field.2026-10-16T03-09.md`). Identifying the responsible branch is UF-2, outside this item.
- **CR-6: Closed** (F4 and F5 together).
- **PA-4 / CR-4 (Info): carried, no action.**

### Identified Gaps

- **PA-3 (Non-blocking, pending CI):** AC-9 (`quality-checks7` on the PR head) cannot be verified before the PR CI runs; it is correctly unchecked (`issue.md` line 69). The item's orchestrator run owns the check-off at S9.
- **PA-6 (Non-blocking, Info): cycle 2 plan header is stale.** `remediation-plan.2026-10-16T02-27.md` line 8 still reads `Status: Authored; awaiting preflight` although all 50 tasks are checked, and the "Plan Deviations" section records a revision 1.2 while line 9 reads `Version: 1.0`. Decision D9 accepts the Version value; the Status value is not covered by D9. Impact: a reader of the header alone would misjudge the plan's state. Recommendation: optionally update the Status line to a completed state; no code or evidence change is involved.

### Approved Exceptions

- Operator decision D1 (`issue.md` line 59): reversal of the #845 append non-goal. Not a finding.
- Decision D4: regex unchanged; verified again in cycle 2. Not a finding.
- Decision D6: coverage floor at the original pre-change baseline; met exactly. Not a finding.
- Decision D7: F4 wording "no assignment operator applied to" in place of "does not assign a value to". The reviewer agrees: `(( NPM_TOKEN++ ))` changes the value, so the suggested wording would have been inaccurate.
- Decision D8: commits `3bc4ee9d1`, `1463ba0e2`, and `141bfe985` carry a `Claude-Session:` line; the four later cycle 2 commits end with the `Co-Authored-By:` line only (reviewer `git log`). History is not rewritten. Not a finding.
- Decision D9: cycle 2 plan Version left at 1.0. Not a finding (see PA-6 for the separate Status line).
- The cycle 1 plan's verbatim-text section (`remediation-plan.2026-10-16T00-56.md` line 106) still quotes "an ``+==`` sequence" as the cycle 1 target text. It is a historical record of the text applied in cycle 1 and is outside F5's scope. Not a finding.

### Unrelated Follow-ups (not item findings)

- UF-1: prd-feature / spec.md residual of minor-audit routing. Not affected by this branch.
- UF-2: identifying the production branch behind the 504/505 partial-branch variance. Not worsened by this branch; the cycle 2 final run recorded 505, equal to the original pre-change run.

### Removed/Skipped Tests

- No test removed in cycle 2. The six skipped full-suite tests are unchanged in count (`rc2-final-pytest-coverage.2026-10-16T03-07.md`).

---

## 9. Summary of Changes

1. **babb2c2a4 to 9bc93aaab** - feature folder, research, acceptance criteria, atomic plan and revisions
2. **4bcdd118f / 10399c2b0 / 7a804e47b / 5afda6fc7** - baseline, regex change and rows, final QC, AC check-off
3. **090b24817** - initial review set (PASS, 0 blocking)
4. **832573c22 to 9421a9b7a** - remediation cycle 1 (F1-F3)
5. **6cb038e9e** - cycle 1 reaudit set (PASS, 0 blocking)
6. **3bc4ee9d1 / 1463ba0e2 / 141bfe985 / 1f8dd4dc2 / c254d0f9f** - cycle 2 inputs, plan, preflight delta, attribution revision, baseline evidence
7. **3da42a36d** - docs: correct guard test docstrings and cycle 1 D6 deviation wording (F4-F6)
8. **e0f28fea5 / 987161b95** - cycle 2 final QC evidence and check-off

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

All toolchain stages pass, coverage equals the original pre-change baseline and meets thresholds, file sizes and line widths are within limits, evidence locations and timestamps are compliant, no production file changed, and no executable line changed in cycle 2. F4-F6 are resolved. PA-3 is a pending CI-dependent criterion; PA-6 is an Info observation.

**Total blocking findings: 0.**

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes / Design / Structure / Toolchain / Documentation: compliant
- ✅ Docs/docstrings: compliant (F4, F5 resolved)

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python: compliant

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ✅ Coverage & Scenarios: no regression on changed lines; equal to the original baseline
- ✅ Test Structure / External Dependencies: compliant

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python: compliant

---

### Metrics Summary

- ✅ pytest 7104 passed, 0 failed, 6 skipped (full suite); 70/70 (guard module)
- ✅ Python 93.80% line / 88.11% branch (original baseline 93.80% / 88.11%)
- ✅ Changed files 184 and 404 lines; longest lines 87 and 88 characters

---

### Recommendation

**Ready for PR**

After the PR is open, confirm `quality-checks7` succeeds on the PR head and check off AC-9.

---

## Appendix A: Test Inventory

1. `test_find_npm_token_assignments_detects_assignment[*]` (unchanged in cycle 2)
2. `test_find_npm_token_assignments_ignores_non_matching_text[*]` (docstring reworded in cycle 2; rows unchanged)
3. `test_find_npm_token_assignments_pins_documented_residuals[*]` (unchanged in cycle 2)

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands:**
```bash
git log --oneline origin/main..HEAD
git diff --stat origin/main...HEAD -- . ':!docs'
git diff --stat 6cb038e9e..HEAD
git diff 6cb038e9e..HEAD -- . ':!docs'
git diff 6cb038e9e..HEAD -- <cycle 1 plan> <issue.md>
git log --format="==%h %cI%n%B" 6cb038e9e..HEAD
git diff --shortstat origin/main...HEAD
poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q -p no:cacheprovider --no-cov
poetry run black --check tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run ruff check --no-fix tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pyright tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
awk -F: '/^LF:/{lf+=$2}/^LH:/{lh+=$2}/^BRF:/{bf+=$2}/^BRH:/{bh+=$2}END{...}' artifacts/python/lcov.info
python -I <scratchpad>/ast933rc2.py <worktree> 6cb038e9e <two test-tree files>
grep -c '^- \[x\]' <cycle 2 plan>
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)
