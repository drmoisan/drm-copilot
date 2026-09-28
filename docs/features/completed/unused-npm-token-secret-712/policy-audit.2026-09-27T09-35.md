# Policy Compliance Audit: unused-npm-token-secret (#712)

---

**Audit Date:** 2026-09-27
**Branch:** `bug/unused-npm-token-secret-712` at `bf4dc2b1` (bf4dc2b103d04cebc615238c60834573eb53bbfe)
**Base:** `origin/main` at `91cffc3b`; merge base `91cffc3bc1794336069649c39132a6c704416eec` (committed 2026-09-27 09:09:58 -0400)
**Diff range:** `origin/main...HEAD` (13 commits, 43 files, 1550 insertions, 1 deletion)
**Work Mode:** `full-bug` (from `issue.md` line 9); AC source `spec.md` only
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`
**Code Under Test:**
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (NEW, Python test module, 263 lines)
- `docs/engineering/npm-token-rotation.runbook.md` (MODIFIED, one line, Markdown)
- Feature-folder documents and evidence under `docs/features/active/unused-npm-token-secret-712/` (Markdown only)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 file (test module under `tests/`) | 17 new tests; 5149 in local full suite | Guard: 17 pass, 0 fail. Local full suite: 5148 pass, 1 fail (issue #510, environmental). CI Linux full suite (3.10-3.13): pass | 92.97% lines, 85.68% branches | 92.97% lines, 85.68% branches | N/A - no production file changed; the test module is omitted by `[tool.coverage.run] omit = tests/*` |
| Markdown | 42 files (1 engineering runbook line, feature-folder docs and evidence) | N/A | N/A (documentation) | N/A (no coverage tooling) | N/A (no coverage tooling) | N/A |

Languages with zero changed files on the branch: TypeScript, PowerShell, C#, Bash, JSON, YAML (verified with `git diff --name-only origin/main...HEAD`; every path ends in `.md` except the one `.py` test module).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Python baseline coverage artifact: `docs/features/active/unused-npm-token-secret-712/evidence/baseline/baseline-pytest-coverage.2026-09-27T09-14.md` (TOTAL row `15841 1114 5760 573 91%`)
- Python post-change coverage artifact: `artifacts/python/lcov.info` and `artifacts/python/coverage.json` (written 2026-09-27 09:20 by the final run), summarized in `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md`
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/coverage-comparison.2026-09-27T09-21.md`

---

## Executive Summary

The branch adds a Python guard test that fails if any YAML file under `.github/` references the `NPM_TOKEN` secret or mentions `NODE_AUTH_TOKEN`, appends one sentence to the superseded notice of `docs/engineering/npm-token-rotation.runbook.md`, and records the operator-owned secret deletion and token revocation as pending. No production code, workflow, configuration, or policy file is changed.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS Python: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`
- N/A PowerShell, TypeScript, C#, Bash, JSON (zero changed files)

Reviewer-run checks at `bf4dc2b1` (check-only): Black `--check` reports `1 file would be left unchanged`; Ruff `--no-fix` reports `All checks passed!`; Pyright reports `0 errors, 0 warnings, 0 informations`; the guard module runs `17 passed`. `git grep -n NPM_TOKEN -- .github` and `git grep -n -i NODE_AUTH_TOKEN -- .github` both exit 1 with no output. The local full suite has one failure, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, verified to be the pre-existing environmental condition tracked by open issue #510 (details in section 7). The CI dispatch run on the branch head passed the full pytest suite and the coverage-threshold step on `ubuntu-latest` for Python 3.10, 3.11, 3.12, and 3.13 (`evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md`).

Overall: compliant. Zero FAIL findings and zero blocking PARTIAL findings.

**Temporary artifacts cleanup:**
- PASS No temporary script was added to the repository by this branch. The reviewer's regex probe script was written to the session scratchpad outside the repository.
- PASS No ongoing tooling script was added.
- The only reviewer-produced repository file other than the three review artifacts is `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md` (canonical evidence path).

---

## Rejected Scope Narrowing

None detected. The caller prompt described the changed scope and asked for the #510 condition to be classified on verified evidence; it did not narrow the audit to a plan, task, phase, or file subset, and it did not mark any language as out of scope or instruct a skipped toolchain or coverage check. The audit scope is the full `origin/main...HEAD` diff (43 files), confirmed against `artifacts/pr_context.summary.txt` regenerated at 2026-09-27 13:30:02 UTC with `Head SHA: bf4dc2b103d04cebc615238c60834573eb53bbfe`.

## Evidence Location Compliance

PASS. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no output. `git diff --name-only origin/main...HEAD | grep -E "^artifacts/"` returned no paths (exit 1). All 36 evidence files on the branch, plus the reviewer-produced CI record, are under `docs/features/active/unused-npm-token-secret-712/evidence/{baseline,other,qa-gates,regression-testing}/`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition applies.

## Workflow Change Rule (modified-workflow-needs-green-run)

N/A. `git diff --name-only origin/main...HEAD -- .github scripts/benchmarks` produced no output, so the rule does not fire. The branch head nevertheless has a green `workflow_dispatch` CI run for all Python jobs (run 36322316826).

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | No fixtures, no shared mutable state. Module constants `REPO_ROOT` and `GITHUB_DIR` are read-only `Path` values. Each tree-scan test enumerates and reads files itself. |
| **Isolation** - Each test targets single behavior | PASS | Seven test functions: two positive and two negative parametrized matrices (one per helper), one non-vacuity test, and two tree-scan tests (one per helper). |
| **Fast Execution** - Tests complete quickly | PASS | `17 passed in 0.05s` (reviewer run); `17 passed in 0.06s` (`evidence/qa-gates/final-pytest-guard.2026-09-27T09-19.md`). |
| **Determinism** - Consistent results | PASS | No clock, randomness, network, subprocess, or git dependency. Enumeration output is sorted by POSIX relative path (`enumerate_github_yaml_files`, line 98). |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive test names, parametrize `id=` labels, Arrange/Act/Assert comments, docstrings on every function. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline:** 92.97% lines (14727/15841), 85.68% branches (4935/5760), combined 91%.<br>**Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`<br>**Timestamp:** 2026-09-27 09:14 (`evidence/baseline/baseline-pytest-coverage.2026-09-27T09-14.md`). The baseline TOTAL row is identical to the post-change row and no production file changed, so the per-metric baseline equals the post-change figures computed from `artifacts/python/coverage.json`. |
| **No Coverage Regression** | PASS | **Post-change:** 92.97% lines, 85.68% branches.<br>**Change:** +0.00% lines, +0.00% branches.<br>**Status:** No regression. Threshold gate `check_python_coverage_thresholds --min-line 85 --min-branch 75` exit 0 locally and `success` in CI on 3.10-3.13. |
| **New Code Coverage >= 85% line / 75% branch** | N/A | No production line was added or changed. The only new Python file is a test module, which the policy-permitted `omit = ["tests/*", ...]` entry in `pyproject.toml` excludes from the denominator. |
| **Comprehensive Coverage** | PASS | `find_npm_token_references` (lines 36-56): 9 parametrized cases plus 1 tree scan. `find_node_auth_token_references` (lines 59-76): 5 parametrized cases plus 1 tree scan. `enumerate_github_yaml_files` (lines 79-98): exercised by 3 tests including the non-vacuity test. |
| **Positive Flows** - Valid inputs | PASS | Dot access, single- and double-quoted bracket access, spaced lowercase dot access, multi-line line-number accuracy, `NODE_AUTH_TOKEN` under another secret name, lowercase `node_auth_token` on line 2. Total positive cases: 7. |
| **Negative Flows** - Invalid inputs | PASS | `secrets.VSCE_PAT`, `secrets.NPM_TOKEN_V2` (word boundary), `# NPM_TOKEN ...` without `secrets` context, `id-token: write`, `MY_NODE_AUTH_TOKENS` (word boundary), empty strings. Total negative cases: 7. |
| **Edge Cases** - Boundary conditions | PASS | Empty input, word boundaries on both helpers, whitespace inside the expression, mixed case, reference on the last line of a multi-line document. Spaced bracket access (`secrets[ 'NPM_TOKEN' ]`) is matched by the regex (reviewer probe) but has no dedicated parametrized case; recorded as a Nit in the code review. |
| **Error Handling** - Error paths | PASS | A wrong repository root or empty enumeration fails `test_github_yaml_enumeration_is_non_vacuous` with a message naming the resolved directory. Decode errors propagate (no `try`/`except`), per spec "fail fast". |
| **Concurrency** - If applicable | N/A | Pure string and read-only file operations; no concurrency. |
| **State Transitions** - If applicable | N/A | Stateless helpers. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.97% lines, 85.68% branches -> Post-change: 92.97% lines, 85.68% branches. Change: +0.00% lines, +0.00% branches (TOTAL row `15841 1114 5760 573 91%` identical before and after). New/changed-code coverage: N/A - no production file changed; the new test module is omitted from measurement by configuration. Disposition: PASS. Evidence: `docs/features/active/unused-npm-token-secret-712/evidence/baseline/baseline-pytest-coverage.2026-09-27T09-14.md`, `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md`, `artifacts/python/lcov.info`, `artifacts/python/coverage.json`, `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md`.

Coverage verdict by language with changed files: Python PASS (repo-wide 92.97% line >= 85%, 85.68% branch >= 75%; no modified or new production file). Markdown has no coverage tooling and no coverage obligation. TypeScript, PowerShell, and C# have zero changed files (N/A).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Parametrized assertions print the input with `!a`, the observed result, and the expected result. Tree-scan assertions list each offender as `<relative-posix-path>:<line>` and state that OIDC trusted publishing needs no token. |
| **Arrange-Act-Assert Pattern** | PASS | Every test carries explicit `# Arrange`, `# Act`, `# Assert` markers. |
| **Document Intent** | PASS | Each test has a docstring stating the scenario and expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, subprocess, git, or `origin/main` dependency. the executor's `grep -n -E` scan for `tempfile`, `tmp_path`, `subprocess`, `origin/main`, `urllib`, and `socket` on the module exits 1 (`evidence/regression-testing/guard-constraint-scan.2026-09-27T09-17.md`); reviewer inspection confirms. The tree scans read repository YAML files, following the precedent `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`. |
| **Use Mocks/Stubs** | N/A | Detection is proven with in-memory strings; nothing needs mocking. |
| **Environment Stability** | PASS | Root derived from `Path(__file__).resolve().parents[3]`; paths compared with `as_posix()`; no Windows-specific path. No temporary files are created. CI on `ubuntu-latest` passed on four Python versions. Enumeration uses filesystem `rglob`, so an untracked YAML file under `.github/` would also be scanned locally; `git status --ignored --porcelain -- .github` is empty today (Nit in the code review). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the policy review for the branch. Outstanding items are non-blocking and listed in section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #712; `spec.md` Context and Root Cause Analysis. |
| **Read existing change plans** | PASS | `plan.2026-09-27T00-23.md`; `evidence/baseline/phase0-instructions-read.md` records the policy reads. |
| **Document the plan** | PASS | Plan with two preflight revisions (commits `2fedde1c`, `4a72f2d4`); operator approval of D1-D6 and P1-P6 supplied 2026-09-26. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Two compiled regexes, three small helpers, line-wise matching; no YAML parser. |
| **Reusability** | PASS | Tree-scan tests reuse the same helpers the parametrized tests prove. |
| **Extensibility** | PASS | New patterns can be added as another compiled regex and helper without changing the enumeration. |
| **Separation of concerns** | PASS | Pure detection helpers take `str`; enumeration takes a `Path`; file reads occur only in the tree-scan tests. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Single-purpose guard module. |
| **Under 500 lines** | PASS | 263 lines (`evidence/regression-testing/guard-root-and-size.2026-09-27T09-17.md`). Markdown files are exempt. |
| **Public vs internal** | PASS | Regex constants are `_`-prefixed; helpers are module-level in a test module and not imported elsewhere. |
| **No circular dependencies** | PASS | Imports only `re`, `pathlib`, `pytest`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `find_npm_token_references`, `enumerate_github_yaml_files`, `test_github_yaml_enumeration_is_non_vacuous`. |
| **Docs/docstrings** | PASS | Module docstring and Google-style `Args:`/`Returns:` on all helpers; docstrings on all tests. |
| **Comment why, not what** | PASS | Each comprehension and loop has an intent comment (lines 51, 71, 90, 213, 230, 234, 251, 255). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/test_workflow_npm_token_guard.py`<br>**Result:** `1 file would be left unchanged.` |
| **2. Linting** | PASS | **Command:** `poetry run ruff check --no-fix tests/scripts/dev_tools/test_workflow_npm_token_guard.py`<br>**Result:** `All checks passed!` |
| **3. Type checking** | PASS | **Command:** `poetry run pyright tests/scripts/dev_tools/test_workflow_npm_token_guard.py`<br>**Result:** `0 errors, 0 warnings, 0 informations` |
| **4. Architecture-boundary tests** | N/A | No production module or import boundary changed. |
| **5. Testing** | PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` -> `17 passed`. Full suite: CI `Run tests with Pytest` = success on 3.10-3.13 at `bf4dc2b1`; local full suite 5148 passed, 1 failed (#510, environmental, section 7). |
| **6. Contract / schema checks** | N/A | No contract or schema changed. |
| **7. Integration tests** | N/A | No adapter changed. |
| **Full toolchain loop** | PASS | Executor recorded one pass without file changes (`evidence/qa-gates/final-loop-single-pass.2026-09-27T09-21.md`); reviewer re-ran steps 1, 2, 3, 5 check-only with no findings. The plan task P5-T8 remains unchecked under the plan's stricter baseline-membership rule (section 8). |
| **Explicit reporting** | PASS | Commands and exit codes recorded under `evidence/qa-gates/` and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages `8d2eca6c`, `b89b2108`, `f823444b`, `1e573760`, `bf4dc2b1`. |
| **Design choices explained** | PASS | `spec.md` D1-D6 with options and rationale. |
| **Update supporting documents** | PASS | Engineering runbook notice points to #712; feature runbook for the human step. |
| **Provide next steps** | PASS | `spec.md` Rollout & Follow-up; `evidence/other/human-action-pending.2026-09-27T09-19.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check <file>`<br>**Result:** unchanged; CI `Check formatting with Black` success. |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check --no-fix <file>`<br>**Result:** no findings; CI `Lint with Ruff` success. No `# noqa` in the file. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <file>`<br>**Result:** 0 errors; CI `Type check with Pyright` success. No `# type: ignore` in the file. |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest <file> -q`<br>**Result:** 17 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Full annotations on helpers and tests (`str`, `list[int]`, `list[Path]`, `-> None`); no `Any`. |
| **Dataclasses for value objects** | N/A | No value objects. |
| **Protocols/ABCs for interfaces** | N/A | Single implementation. |
| **Avoid utility classes** | PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | No exception handling; errors propagate as test errors by design. |
| **Logging over print** | PASS | No `print`. |
| **Invariants at construction** | N/A | No classes. |

Sections 3B (PowerShell), 3C (Bash), and 3D (JSON) are omitted: zero files of those languages changed.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `pytest.mark.parametrize` with `pytest.param(..., id=...)`; no fixtures or plugins. |
| **Coverage expectation** | PASS | Repo-wide 92.97% line, 85.68% branch (>= 85% / 75%). No new production code. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One behavior per test function; matrices via parametrize. |
| **Mocking sparingly** | PASS | No mocks. |
| **Organization** | PASS | `tests/scripts/dev_tools/` alongside the precedent workflow-contract test; basename is unique across the tree (required because the directory has no `__init__.py`). |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_<unit>_<behavior>` names; parametrize ids such as `spaced-lowercase-dot`, `longer-secret-name`. |
| **Docstrings/comments** | PASS | Every test has a docstring. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`<br>**Result:** 17 passed in 0.05s. |
| **No Alternative Test Runners** | PASS | Pytest only. |

---

## 5. Test Coverage Detail

### `find_npm_token_references` (10 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `detects_reintroduced_reference[dot-access]` | Positive | 52-56 | PASS |
| `detects_reintroduced_reference[single-quoted-bracket]` | Positive | 52-56 | PASS |
| `detects_reintroduced_reference[double-quoted-bracket]` | Positive | 52-56 | PASS |
| `detects_reintroduced_reference[spaced-lowercase-dot]` | Edge Case | 52-56 | PASS |
| `detects_reintroduced_reference[third-line-of-three]` | Edge Case | 52-56 | PASS |
| `ignores_non_matching_text[unrelated-secret]` | Negative | 52-56 | PASS |
| `ignores_non_matching_text[longer-secret-name]` | Edge Case | 52-56 | PASS |
| `ignores_non_matching_text[no-secrets-context]` | Negative | 52-56 | PASS |
| `ignores_non_matching_text[empty]` | Edge Case | 52-56 | PASS |
| `test_github_yaml_files_reference_no_npm_token_secret` | Positive (tree scan) | 52-56, 227-242 | PASS |

**Coverage:** the test module is outside the coverage denominator by configuration; all helper lines execute in these tests.

**Not covered:** None.

### `find_node_auth_token_references` (6 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `detects_reference[other-secret-name]` | Positive | 72-76 | PASS |
| `detects_reference[lowercase-second-line]` | Edge Case | 72-76 | PASS |
| `ignores_non_matching_text[oidc-permission]` | Negative | 72-76 | PASS |
| `ignores_non_matching_text[longer-name]` | Edge Case | 72-76 | PASS |
| `ignores_non_matching_text[empty]` | Edge Case | 72-76 | PASS |
| `test_github_yaml_files_reference_no_node_auth_token` | Positive (tree scan) | 72-76, 248-263 | PASS |

**Not covered:** None.

### `enumerate_github_yaml_files` (3 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_github_yaml_enumeration_is_non_vacuous` | Error Handling (wrong root / empty enumeration) | 92-98, 209-221 | PASS |
| `test_github_yaml_files_reference_no_npm_token_secret` | Positive | 92-98 | PASS |
| `test_github_yaml_files_reference_no_node_auth_token` | Positive | 92-98 | PASS |

**Not covered:** the missing-directory path (`rglob` on a non-existent directory returns an empty list) is not exercised directly; the non-vacuity test would fail in that case, which is the intended outcome.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (guard module) | 17 | PASS |
| Tests Passed (guard module) | 17 (100%) | PASS |
| Tests Failed (guard module) | 0 | PASS |
| Local full suite | 5148 passed, 1 failed (#510, environmental), 5 skipped | PASS (classified in section 7) |
| CI Linux full suite, Python 3.10-3.13 | `Run tests with Pytest` success on all four jobs | PASS |
| Execution Time (guard module) | 0.05s | PASS |
| Functions Tested | 3/3 (100%) | PASS |
| Test File Size | 263 lines | PASS |
| Code Coverage (repo-wide Python) | 92.97% lines, 85.68% branches | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | 1 file would be left unchanged | PASS |
| Ruff Linting | `poetry run ruff check --no-fix tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | All checks passed! | PASS |
| Pyright Type Checking | `poetry run pyright tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | 0 errors, 0 warnings, 0 informations | PASS |
| Pytest Tests | `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` | 17 passed | PASS |
| Full suite with coverage | CI `_quality-checks.yml` pytest and threshold steps at `bf4dc2b1` | success on 3.10, 3.11, 3.12, 3.13 | PASS |

**Notes (issue #510 classification):** The single local full-suite failure is `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, failing with `AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.worktree-agent-aeab66e09fb7ca876-451b367f.json`. The reviewer verified the classification as pre-existing and environmental, not introduced by this change:
1. Re-running the node alone reproduces the same assertion (reviewer run, 1 failed in 0.11s).
2. `git check-ignore -v .claude/state/` prints `.gitignore:68:.claude/state/`; the file is gitignored and written by the PreToolUse batch-budget hook.
3. Issue #510 is OPEN with title "Bug: claude-resource-parity-enumerates-gitignored-state".
4. `git diff --name-only origin/main...HEAD -- .claude extensions tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` lists zero paths; the branch changes neither the test, the bundle, nor any `.claude/` file.
5. The same node passes on a fresh CI checkout (all four Linux Python jobs green at `bf4dc2b1`).

The baseline passed because the hook created the state file at 09:15, after the 09:14 baseline run, when the guard module was first written. The failure is therefore attributable to local hook state, not to the branch content.

---

## 8. Gaps and Exceptions

### Identified Gaps

No FAIL-level or blocking gap. Non-blocking items:
- Plan tracking: `plan.2026-09-27T00-23.md` tasks P5-T5, P5-T7, P5-T8, P6-T3, and P6-T8 remain unchecked because the plan's rule admits no exception for a failing node absent from `BaselineFailingNodes:`. The substantive condition (full suite green, thresholds met) is now evidenced by CI. The orchestrator should reconcile the plan checkboxes against `evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md`.
- Guard breadth: the guard does not detect a token-based publish that uses neither the `NPM_TOKEN` secret name nor `NODE_AUTH_TOKEN` (for example `.npmrc` `_authToken=` written from another secret, or `NPM_CONFIG__AUTHTOKEN`). This is within the approved D2/D3 scope; recorded as a Minor follow-up in the code review.
- Feature runbook `runbooks/delete-unused-npm-token-secret.runbook.md` line 136 directs marking AC4 in `issue.md`, while the AC source is `spec.md` and AC4 is already satisfied at the pending stage. `spec.md` records this observation. Minor follow-up.

### Approved Exceptions

- AC4 is satisfied at the pending stage by spec decision D5 (operator-approved 2026-09-26). The secret deletion and token revocation are operator-owned and not required for this branch.
- Fail-before proof by in-memory reintroduction instead of a failing tree-scan run (`evidence/regression-testing/fail-before-exception.2026-09-27T09-18.md`), because editing `.github/` is out of scope and temporary fixture files are prohibited.

### Removed/Skipped Tests

**None.** All seven planned test functions are implemented.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **78cc21f7** - docs(712): create active bug folder for unused-npm-token-secret
2. **3d6c3265** - docs(712): add research and human-exception runbook
3. **9bedd5bc** - docs(712): add spec with design decisions D1-D6
4. **58669e23** - docs(712): add atomic plan
5. **2fedde1c** - docs(712): revise plan per preflight round 1
6. **4a72f2d4** - docs(712): revise plan per preflight round 2
7. **5e5d1387** - docs(712): capture phase 0 policy reads and baseline evidence
8. **8d2eca6c** - test(712): add workflow npm token guard test module
9. **ba210537** - docs(712): record guard detection run and fail-before exception dossier
10. **b89b2108** - docs(712): point superseded npm token runbook notice to issue #712
11. **f823444b** - docs(712): record human secret-deletion action as pending
12. **1e573760** - test(712): run final QC loop for workflow npm token guard
13. **bf4dc2b1** - docs(712): verify acceptance criteria and check off AC1, AC3, AC4

### Files Modified

1. **tests/scripts/dev_tools/test_workflow_npm_token_guard.py** (NEW)
   - Guard test module: two regex helpers, one enumeration helper, 7 test functions (17 nodes).
2. **docs/engineering/npm-token-rotation.runbook.md** (MODIFIED)
   - One sentence appended to the superseded notice: "The unused `NPM_TOKEN` repository secret is being removed under issue #712."
3. **docs/features/active/unused-npm-token-secret-712/** (NEW)
   - `issue.md`, `spec.md`, `plan.2026-09-27T00-23.md`, `research/research.2026-09-27T00-30.md`, `runbooks/delete-unused-npm-token-secret.runbook.md`, and 36 evidence files.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policies pass. Coverage metrics are numeric for the only coverage language with changed files (Python) and show no regression. No FAIL finding and no blocking PARTIAL finding. Non-blocking follow-ups are listed in section 8.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: spec, research, plan, operator approval present.
- PASS Design Principles: small pure helpers, clear I/O boundary.
- PASS Module & File Structure: 263 lines, single purpose.
- PASS Naming, Docs, Comments: docstrings and intent comments complete.
- PASS Toolchain Execution: Black, Ruff, Pyright, pytest clean; CI full suite green.
- PASS Summarize & Document: commits and evidence complete.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline: clean.
- PASS Python Design & Typing: fully typed, no suppressions.
- PASS Error Handling: fail-fast propagation.

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies: no temp files, subprocess, network, or git.
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 17/17 guard tests passing (100%)
- PASS 3/3 helpers tested
- PASS 92.97% line and 85.68% branch repo-wide Python coverage (unchanged)
- PASS Test file placed under `tests/scripts/dev_tools/`, mirroring the precedent workflow-contract test
- PASS All code quality checks passing
- PASS Guard execution time 0.05 seconds

---

### Recommendation

**Ready for merge**, subject to the orchestrator's normal CI-completion gate for the remaining non-Python jobs of run 36322316826 (`poshqc`, `shell-coverage`, which were in progress at review time and are unaffected by this diff). Non-blocking follow-ups are listed in section 8 and in the code review.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[dot-access]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[single-quoted-bracket]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[double-quoted-bracket]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[spaced-lowercase-dot]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[third-line-of-three]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[unrelated-secret]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[longer-secret-name]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[no-secrets-context]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[empty]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_detects_reference[other-secret-name]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_detects_reference[lowercase-second-line]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[oidc-permission]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[longer-name]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[empty]`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_enumeration_is_non_vacuous`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_reference_no_npm_token_secret`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_reference_no_node_auth_token`

---

## Appendix B: Toolchain Commands Reference

**Reviewer-run (check-only) at `bf4dc2b1`:**
```text
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt
poetry run black --check tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run ruff check --no-fix tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pyright tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q -p no:cacheprovider
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" -q -p no:cacheprovider
git grep -n NPM_TOKEN -- .github
git grep -n -i NODE_AUTH_TOKEN -- .github
git diff --name-only origin/main...HEAD -- .github
git check-ignore -v .claude/state/
git status --ignored --porcelain -- .github
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
gh issue view 510 --json state,title
gh run view 36322316826 --json jobs
gh api repos/drmoisan/drm-copilot/actions/jobs/<job-id>
```

**Executor-run (recorded in evidence):**
```text
poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-27
**Policy Version:** Current (as of audit date)
