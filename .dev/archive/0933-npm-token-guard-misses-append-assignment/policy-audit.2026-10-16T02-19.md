# Policy Compliance Audit: npm token guard misses append assignment (#933)

---

**Audit Date:** 2026-10-16
**Audit Type:** Remediation cycle 1 re-review (reaudit, feature-vs-base)
**Branch:** `bug/npm-token-guard-misses-append-assignment-933` (HEAD `9421a9b7a4cc4817486976b9023d62ed89a7f71c`, pushed)
**Base:** `origin/main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Work Mode:** `minor-audit`
**Code Under Test:** 90 changed files (3512 insertions, 12 deletions). Outside the feature folder only two Python test-tree files changed: `M tests/scripts/dev_tools/npm_token_guard_test_support.py` (regex alternative B and the `find_npm_token_assignments` docstring) and `M tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (ten new parametrize rows, one flipped pinned row, one rewritten docstring). The remaining 88 files are feature-folder documentation and evidence. No production file under `src/` or `scripts/` changed. Remediation cycle 1 (commits `832573c22` to `9421a9b7a`) changed only the same two test-tree files outside the feature folder (`git diff --name-only 090b24817..HEAD`, reviewer rerun).

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
- Python baseline coverage artifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md (original pre-change) and docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc1-baseline-coverage-percentages.2026-10-16T01-36.md (cycle 1 entry)
- Python post-change coverage artifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-pytest-coverage.2026-10-16T01-47.md, docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-coverage-percentages.2026-10-16T01-47.md, docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-coverage-thresholds.2026-10-16T01-47.md
- Python coverage data file inspected by the reviewer: artifacts/python/lcov.info (written 2026-10-16 01:51 UTC by the executor's diagnostic full-suite rerun on the cycle 1 source)
- Per-language comparison summary: section 1.2.1 of this audit and docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-coverage-comparison.2026-10-16T02-11.md

---

## Executive Summary

This is the reaudit after remediation cycle 1, which addressed the three non-blocking findings of the prior review set (`policy-audit.2026-10-16T00-50.md`): F1 (CR-1/PA-1, docstring accuracy for dot- and hyphen-prefixed assignments plus pinning rows), F2 (CR-2/PA-2, arithmetic compound append and `++=` rows), and F3 (CR-3, pinned-residual docstring wording). Under decision D4 the regex was intentionally left unchanged; the reviewer confirmed the pattern is byte-identical to the cycle-entry pattern (`git diff 090b24817..HEAD` shows no change at `npm_token_guard_test_support.py:47`; executor digest artifact `rc1-regex-unchanged.2026-10-16T02-13.md`).

The reviewer reran the guard module tests (70 passed), `black --check`, `ruff check --no-fix`, and `pyright` on both changed files (all clean), recomputed repo-wide Python coverage from artifacts/python/lcov.info (16544/17638 lines = 93.7975%, 5611/6368 branches = 88.1124%), ran `validate_evidence_locations.py` (exit 0), verified that the filename stamp of all 42 `rc1-*` evidence files equals its `Timestamp:` row, and probed the unchanged pattern in memory against 24 inputs, covering every new row and every claim in the rewritten docstring (0 mismatches; section 8).

F1, F2, and F3 are resolved, and CR-1/PA-1, CR-2/PA-2, and CR-3 are closed. One new non-blocking finding concerns the stated rationale of decision D6 (PA-5); the D6 floor itself is judged sound. AC-9 remains pending CI (PA-3).

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

None detected. The caller prompt fixed the diff at `git diff origin/main...HEAD`, which matches the resolved merge base, and did not narrow scope to a plan, phase, task, file subset, or language. The caller statements that `spec.md` and `user-story.md` are absent by design (minor-audit) and that AC-9 is pending CI are consistent with `issue.md` line 12 and the CI-dependent criterion protocol. The caller's account of decisions D4 and D6 was treated as a claim to verify, not as a verdict; D6 is evaluated on its merits in section 1.2.1 and PA-5.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (reviewer rerun at `9421a9b7a`): exit 0, no output.
- `git diff --name-only origin/main...HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- The 42 cycle 1 evidence files sit under `<FEATURE>/evidence/{other,qa-gates,regression-testing,remediation-baseline}/`. For every one, the filename stamp equals its `Timestamp:` row (reviewer loop). Stamps precede the commits that added them: test commit `c3da25c20` (01:43 UTC) follows `rc1-pass-after.2026-10-16T01-42.md`; `cfad1fe7e` (01:52 UTC) follows the latest final-QC stamp 01-48; `bba389501` (02:16 UTC) follows the latest stamp 02-15.
- Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entries were needed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New rows are pure calls of `find_npm_token_assignments` on parametrized in-memory strings; no shared mutable state. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each row asserts the line list for one input string against one finder. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer rerun: 70 passed in 0.12s. |
| **Determinism** - Consistent results | ✅ PASS | The changed tests use no clock, randomness, sleep, network, or process. The full-suite branch-coverage swing discussed in PA-5 originates outside the changed files. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Each new row has a descriptive `id`; the pinned-residual docstring (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py:302-311`) records the #933 reversal. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** Python 93.79748% lines / 88.11244% branches (docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md); cycle entry 93.79748% / 88.12814% (docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc1-baseline-coverage-percentages.2026-10-16T01-36.md).<br>**Timestamp:** 2026-10-16T00-19 and 2026-10-16T01-36 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 93.79748% lines / 88.11244% branches (docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-coverage-percentages.2026-10-16T01-47.md); reviewer recomputation from artifacts/python/lcov.info: 93.7975% / 88.1124%.<br>**Status:** No regression on changed lines (0 production lines changed). Equal to the original pre-change baseline; one partial branch below the cycle-entry value (D6, PA-5). |
| **New Code Coverage ≥85% (uniform tier rule)** | ✅ PASS | PASS: 0 production lines added or modified. Both changed files are under `tests/`, which `pyproject.toml` `[tool.coverage.run] omit` (lines 122-124) excludes as a permitted non-production path. |
| **Comprehensive Coverage** | ✅ PASS | The alternative-B `\+?` path is exercised by positive rows (seven `+=` forms) and negative rows (`+==`, `++=`, `NPM_TOKEN_V2+=`, `NPM_TOKEN++`). |
| **Positive Flows** - Valid inputs | ✅ PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:224-231` and line 288 (`bash-append-reported`). |
| **Negative Flows** - Invalid inputs | ✅ PASS | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:259-261` and lines 294-296. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Dot and hyphen prefixes (lines 229-230), arithmetic compound append (line 231), `++=` (line 261), `+==` (lines 294-296). |
| **Error Handling** - Error paths | N/A | The finder has no error path; it returns a list. |
| **Concurrency** - If applicable | N/A | No concurrent code. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.79748% lines, 88.11244% branches -> Post-change: 93.79748% lines, 88.11244% branches. Change: +0.0% lines, +0.0% branches (baseline is the original pre-change run, post-change is the cycle 1 final run). Change versus the cycle-entry value 88.12814070351759%: -0.0157% branches (TOTAL partial branches 504 -> 505; statements 17638, missed 1094, and branches 6368 unchanged). New/changed-code coverage: PASS; the branch adds or modifies 0 production Python lines (`git diff --name-only origin/main...HEAD -- src scripts` returns nothing, reviewer rerun), so no changed production line is uncovered or regressed. Repo-wide thresholds 85% line / 75% branch met (root `CLAUDE.md` states no coverage threshold, so the defaults govern). Disposition: PASS. Evidence: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-coverage-comparison.2026-10-16T02-11.md, artifacts/python/lcov.info.
- D6 judgment on its merits: the floor substitution is sound. The policy requirement is no regression on changed lines plus the repo-wide floors; with zero changed production lines, the one-partial-branch difference cannot be a regression caused by this branch, and the post-change value equals the original pre-change baseline exactly. The four recorded runs (505, 504, 504, 505 partial branches) all ran on identical production source. The stated rationale is weaker than the decision: see PA-5.
- PowerShell, TypeScript, C#: no changed files on the branch. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions report the ASCII-escaped input and actual result (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py:244`, `:272`, `:319`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | The three affected test functions carry `# Arrange`, `# Act`, `# Assert` markers (lines 238-244, 266-272, 313-319). |
| **Document Intent** | ✅ PASS | Row ids describe intent; the pinned-residual docstring explains the #845 to #933 change. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Unit rows use in-memory strings. The pre-existing tree-scan tests read `.github/` files through `pathlib`; unchanged. |
| **Use Mocks/Stubs** | N/A | No collaborator to mock. |
| **Environment Stability** | ✅ PASS | No temporary file creation in the changed files (diff read). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit. Outstanding non-blocking items: AC-9 pending PR CI (PA-3) and PA-5. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-inputs.2026-10-16T00-56.md` defines F1-F3, scope, and D4. |
| **Read existing change plans** | ✅ PASS | docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/phase0-instructions-read.2026-10-16T01-29.md. |
| **Document the plan** | ✅ PASS | docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T00-56.md: 52 checked tasks, 0 unchecked (reviewer grep); revision 1.1 records the P2-T9 halt and D6. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Cycle 1 adds rows and rewrites two docstrings; no logic change. |
| **Reusability** | ✅ PASS | Reuses existing parametrized tests; no duplication. |
| **Extensibility** | ✅ PASS | No API change. |
| **Separation of concerns** | ✅ PASS | Pattern and finders remain in the support module; tests remain in the test module. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Changes confined to the guard support module and its test module. |
| **Under 500 lines** | ✅ PASS | Reviewer `wc -l`: support module 184, test module 404. |
| **Public vs internal** | ✅ PASS | `_NPM_TOKEN_ASSIGNMENT` remains private. |
| **No circular dependencies** | ✅ PASS | Import graph unchanged. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Row ids such as `dot-prefixed-append-reported`, `double-plus-equals-not-reported`. |
| **Docs/docstrings** | ✅ PASS | `find_npm_token_assignments` docstring (`tests/scripts/dev_tools/npm_token_guard_test_support.py:122-141`) now states that dot- and hyphen-prefixed `=`/`+=` assignments are reported and that only letter-, digit-, or underscore-extended names are excluded; every claim verified by the reviewer probe (section 8). Longest line 87 characters (reviewer `awk`: no line over 88 in either file). PA-1 closed. |
| **Comment why, not what** | ✅ PASS | Docstrings cite issue #933 and explain the word-boundary reason for prefixed reporting. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check <two files>`<br>**Result:** reviewer rerun "2 files would be left unchanged"; executor docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-black.2026-10-16T01-44.md. |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check --no-fix <two files>`<br>**Result:** "All checks passed!" (reviewer rerun). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <two files>`<br>**Result:** 0 errors, 0 warnings, 0 informations (reviewer rerun). |
| **4. Architecture-boundary tests** | N/A | No Python architecture-boundary suite applies to the changed test files. |
| **5. Testing** | ✅ PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`<br>**Result:** 70 passed (reviewer rerun); full suite 7104 passed, 6 skipped, 0 failed (docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-pytest-coverage.2026-10-16T01-47.md). |
| **6. Contract / schema checks** | N/A | No contract or schema surface changed. |
| **7. Integration tests** | N/A | No integration surface changed; the tree-scan tests pass. |
| **Full toolchain loop** | ✅ PASS | docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-loop-single-pass.2026-10-16T01-48.md: single clean pass, no rerun. |
| **Explicit reporting** | ✅ PASS | Every stage has a timestamped evidence artifact. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `c3da25c20` message and plan check-off. |
| **Design choices explained** | ✅ PASS | D4 in the remediation inputs; D6 in the remediation plan "Plan Deviations" section. |
| **Update supporting documents** | ✅ PASS | `issue.md` unchanged in the cycle (`git diff 090b24817..HEAD -- issue.md` empty, reviewer rerun), as the inputs require. |
| **Provide next steps** | ✅ PASS | AC-9 pending CI; PA-5 recommendation. |

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
| `test_find_npm_token_assignments_detects_assignment[dot-prefixed-append-reported]` | Positive (F1 pin) | 47, 142 | ✅ |
| `test_find_npm_token_assignments_detects_assignment[hyphen-prefixed-append-reported]` | Positive (F1 pin) | 47, 142 | ✅ |
| `test_find_npm_token_assignments_detects_assignment[arithmetic-compound-append]` | Positive (F2 pin) | 47, 142 | ✅ |
| `test_find_npm_token_assignments_ignores_non_matching_text[double-plus-equals-not-reported]` | Negative (F2 pin) | 47, 142 | ✅ |

**Coverage:** PASS. The module is test infrastructure under `tests/`, which the permitted `tests/*` entry omits from production coverage measurement. Every line of the module executes during the guard module run. Repo-wide Python coverage is 93.80% line / 88.11% branch.

**Not covered:** None identified.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | pytest 7110 collected (full suite); 70 in the guard module | ✅ |
| Tests Passed | 7104 (full suite); 70 (guard module) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Full suite 148.60s; guard module 0.12s (reviewer) | ✅ |
| Average Time per Test | Guard module about 2ms | ✅ Fast |
| Discovery Time | Not separately reported | N/A |
| Functions/Classes Tested | `find_npm_token_assignments` (prefixed, arithmetic, `++=` outcomes) | ✅ |
| Test File Size | 404 and 184 lines | ✅ |
| Code Coverage (if applicable) | Python 93.80% line / 88.11% branch | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check <two files>` | 2 files would be left unchanged | ✅ |
| Ruff | `poetry run ruff check --no-fix <two files>` | All checks passed! | ✅ |
| Pyright | `poetry run pyright <two files>` | 0 errors, 0 warnings, 0 informations | ✅ |
| Pytest | `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` | 70 passed | ✅ |

**Notes:**
The characterization probe docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc1-baseline-characterization.2026-10-16T01-37.md records `[1] [1] [1] []` for the four new inputs against the unchanged regex before the rows were added, as F1 and F2 required.

---

## 8. Gaps and Exceptions

### Closure of prior findings

- **PA-1 / CR-1 (F1): Closed.** Docstring at `tests/scripts/dev_tools/npm_token_guard_test_support.py:127-134` is accurate; rows `dot-prefixed-append-reported` and `hyphen-prefixed-append-reported` pin the behavior. Reviewer probe of the unchanged pattern: `env.NPM_TOKEN += x`, `MY-NPM_TOKEN+=x`, `env.NPM_TOKEN = x`, `secrets.NPM_TOKEN = x` reported; `MY_NPM_TOKEN+=x`, `MY_NPM_TOKEN=x`, `MYNPM_TOKEN=x`, `NPM_TOKENX=x`, `NPM_TOKEN_V2+=x`, `${{ secrets.NPM_TOKEN }}`, `if: ${{ env.NPM_TOKEN == '' }}`, `NPM_TOKEN+==x`, `env.NPM_TOKEN: x`, and prose not reported. 0 mismatches against the docstring.
- **PA-2 / CR-2 (F2): Closed.** Rows `arithmetic-compound-append` (`[1]`) and `double-plus-equals-not-reported` (`[]`) present at lines 231 and 261; probe confirms both outcomes.
- **CR-3 (F3): Closed.** The pinned-residual docstring ends "These rows pin the current behavior so a change to any outcome is visible." (lines 310-311); the word "existing" no longer occurs in it (executor probe `rc1-docstring-f3.2026-10-16T02-13.md`, reviewer read).
- **PA-4 (Info): carried, no action.**

### Identified Gaps

- **PA-3 (Non-blocking, pending CI):** AC-9 (`quality-checks7` on the PR head) cannot be verified before the PR CI runs; it is correctly unchecked (`issue.md` line 69). The item's orchestrator run owns the check-off at S9.
- **PA-5 (Non-blocking, Minor): D6 rationale is not supported by a mechanism.** The D6 floor is sound (section 1.2.1). The stated rationale is not: the plan deviation states that the swing "tracks test-file changes only" and that the runs "show identical production source, not nondeterminism". Pytest runs serially here (`pyproject.toml` `addopts` contains no xdist option), `tests/*` is omitted from measurement, and the changed tests are pure in-memory calls, so adding parametrize rows has no identified path to a production branch outcome. The four runs (505, 504, 504, 505) plus one diagnostic rerun are consistent with either a test-content-dependent effect or a nondeterministic production branch elsewhere in the suite. The flipping branch was not identified by file and line. Impact: a future item's coverage comparison against a cycle baseline can halt on the same swing. Recommendation: identify the file whose partial-branch count differs between a 504 run and a 505 run (per-file diff of two `coverage.json` reports) and track the result as a separate determinism follow-up; it is unrelated to the files this item changes. No change to this branch is required.

### Approved Exceptions

- Operator decision D1 (`issue.md` line 59): reversal of the #845 append non-goal. Not a finding.
- Decision D4 (remediation inputs): regex unchanged; over-reporting of prefixed assignments is retained and documented as fail-closed. Not a finding.
- Decision D6 (remediation plan revision 1.1): branch floor set to the original pre-change value. Accepted on its merits; rationale observation recorded as PA-5.

### Removed/Skipped Tests

- No test removed in cycle 1. The six skipped full-suite tests are unchanged in count (rc1-final-pytest-coverage notes).

---

## 9. Summary of Changes

1. **babb2c2a4 to 9bc93aaab** - feature folder, research, acceptance criteria, atomic plan and revisions
2. **4bcdd118f / 10399c2b0 / 7a804e47b / 5afda6fc7** - baseline, regex change and rows, final QC, AC check-off
3. **090b24817** - initial review set (PASS, 0 blocking)
4. **832573c22 / 74443b62e / 3a38bb107** - remediation cycle 1 inputs, plan, baseline evidence
5. **c3da25c20** - test: pin prefixed and arithmetic append outcomes and correct guard docstrings
6. **cfad1fe7e / fca33f15b / 1def55df4 / 7af77eb5a / bba389501 / 9421a9b7a** - partial QC evidence, D6 revision, preflight deltas, final QC evidence, check-off

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

All toolchain stages pass, coverage equals the original pre-change baseline and meets thresholds, file sizes and line widths are within limits, evidence locations and timestamps are compliant, and no production file changed. F1-F3 are resolved. PA-5 is a non-blocking observation about the D6 rationale; PA-3 is a pending CI-dependent criterion.

**Total blocking findings: 0.**

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes / Design / Structure / Toolchain / Documentation: compliant
- ✅ Docs/docstrings: compliant (PA-1 closed)

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

After the PR is open, confirm `quality-checks7` succeeds on the PR head and check off AC-9. Track PA-5 separately.

---

## Appendix A: Test Inventory

1. `test_find_npm_token_assignments_detects_assignment[dot-prefixed-append-reported]` (new, cycle 1)
2. `test_find_npm_token_assignments_detects_assignment[hyphen-prefixed-append-reported]` (new, cycle 1)
3. `test_find_npm_token_assignments_detects_assignment[arithmetic-compound-append]` (new, cycle 1)
4. `test_find_npm_token_assignments_ignores_non_matching_text[double-plus-equals-not-reported]` (new, cycle 1)
5. Cycle 0 rows unchanged: `bash-append-secret-expression`, `shell-export-append`, `powershell-env-append`, `longer-name-append`, `arithmetic-increment`, `bash-append-reported`, `accepted-append-double-equals-not-reported`

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands:**
```bash
git rev-parse HEAD
git merge-base origin/main HEAD
git diff --stat origin/main...HEAD
git diff origin/main...HEAD -- tests/ scripts/ src/
git diff --name-only origin/main...HEAD -- src scripts
git diff --name-only 090b24817..HEAD
git log --format="%h %cd %s" origin/main..HEAD
wc -l tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
awk 'length>88' tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q -p no:cacheprovider
poetry run black --check tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run ruff check --no-fix tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pyright tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
awk -F: '/^LF:/{lf+=$2}/^LH:/{lh+=$2}/^BRF:/{bf+=$2}/^BRH:/{bh+=$2}END{...}' artifacts/python/lcov.info
python -I <scratchpad>/probe933rc1.py tests/scripts/dev_tools/npm_token_guard_test_support.py
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)
