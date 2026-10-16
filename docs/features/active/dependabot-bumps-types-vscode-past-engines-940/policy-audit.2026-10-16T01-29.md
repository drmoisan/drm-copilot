# Policy Compliance Audit: Issue #940 — Dependabot bumps @types/vscode past engines.vscode (re-audit R4, remediation cycle 2)

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T01-29)
**Branch:** `bug/dependabot-bumps-types-vscode-past-engines-940`
**Base:** `main`; merge-base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
**Head reviewed:** `94f4bd87045bef46e2bed63fe992fcf285eeb717`
**Review scope:** full branch diff `origin/main...HEAD` (81 files, +1901/-0)
**Work mode:** `minor-audit` (AC source: `issue.md`, section `## Acceptance Criteria`)
**Code Under Test:** `.github/dependabot.yml` (modified, +2 lines), `tests/scripts/dev_tools/test_dependabot_config_contract.py` (new, 113 lines)

## Total Blocking Findings: 0

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 (new test module under `tests/`) | 5 new (7099 passed, 6 skipped in full suite) | PASS | 93.8% lines (17638 stmts, 1094 missed) | 93.8% lines, 88.1% branch (5611/6368) | 100.00% (0/0 production statements changed; `tests/*` is in the coverage `omit` list) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| YAML / Markdown | 1 YAML, Markdown feature documents | N/A | N/A | N/A (configuration, documentation) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed on the branch
- Python baseline coverage artifact: `evidence/baseline/pytest-full-coverage-baseline.2026-10-16T00-16.md` and `evidence/remediation-baseline/pytest-full-coverage-reference.2026-10-16T01-16.md` (TOTAL 17638 statements, 1094 missed, 93.8% lines)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (recomputed by this review: lines 16544/17638 = 93.80%, branches 5611/6368 = 88.11%), summarized in `evidence/qa-gates/pytest-full-coverage-final.2026-10-16T01-26.md`
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

This re-audit covers remediation cycle 2. The branch still adds two `@types/vscode` ignore items to `.github/dependabot.yml` (npm entries for `/` and `/extensions/drm-copilot`) and a pytest contract module that parses the real file with `yaml.safe_load`. Cycle 2 changed only the `typescript` retention test in the test module (7 insertions, 1 deletion at lines 100-106): the `items[0]` assertion is now an `any(...)` over all matching items with a descriptive message. `git diff 8c89607ef HEAD` shows no change to `.github/dependabot.yml` since the cycle 1 head. The final toolchain pass records exit code 0 for Black, Ruff, Pyright, and Pytest, and this review re-ran the targeted test, Black, Ruff, and Pyright on the test file with passing results. No blocking finding was identified.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` (Python code change and unit test)
- N/A TypeScript, PowerShell, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (refreshed at HEAD `94f4bd870`), `issue.md`, `plan.2026-10-15T07-42.md`, `remediation-inputs.2026-10-16T01-05.md`, `remediation-plan.2026-10-16T01-05.md`, and the evidence folder.

**Temporary artifacts cleanup:**
- PASS No temporary files are committed. The `SCRATCH/940/` token in evidence artifacts refers to session scratchpad output; no such path appears in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller prompt required the same inputs and scope as the original review with no scope narrowing.

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` exited 0 (no violations).
- The branch file list contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- Evidence is under `evidence/baseline/`, `evidence/remediation-baseline/`, `evidence/qa-gates/`, and `evidence/regression-testing/` (canonical kinds).
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds no project; the new file is a test module inside the existing `tests/` tree. No classification gap arises. Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | All five tests read the same committed file read-only. The only shared state is the process-lifetime `functools.cache` of the parsed entries, which is documented as not to be mutated, and no test mutates it. |
| Isolation | PASS | Three behaviors, each in its own test: ignore shape, `typescript` retention, non-vacuity count. |
| Fast execution | PASS | `5 passed in 0.12s` (this review's run); `5 passed in 0.23s` in `evidence/qa-gates/pytest-targeted-final.2026-10-16T01-26.md`. |
| Determinism | PASS | No clock, RNG, or network use; the repository root is computed from `Path(__file__).resolve()`. |
| Readability | PASS | Descriptive names, docstrings, and assertion messages naming the directory and dependency. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide | PASS | 93.80% (lcov recomputation: 16544/17638). |
| Branch >= 75% repo-wide | PASS | 88.11% (lcov recomputation: 5611/6368). |
| No regression on changed lines | PASS | No production Python line changed; Miss count 1094 baseline and final (`evidence/qa-gates/coverage-delta.2026-10-16T01-26.md`). |
| Positive / negative / edge | PASS | Present-ignore shape, absent-ignore failure demonstrated by the red run, restricted-only item failure path via both `any(...)` assertions, and a non-vacuity count guard. |
| Coverage exclusion policy | PASS | No `omit` or `exclude` entry changed; `pyproject.toml` is not in the diff. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.8% lines -> Post-change: 93.8% lines (branch 88.1%). Change: 0.0 points (population unchanged; 0 production statements added or changed). New/changed-code coverage: 100.00% (0/0 production statements; the only Python change is a test module excluded by the `omit` list). Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/coverage-delta.2026-10-16T01-26.md`, `evidence/baseline/pytest-full-coverage-baseline.2026-10-16T00-16.md`.
- TypeScript: N/A - no changed files on the branch.
- PowerShell: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | Each test separates entry lookup, item selection, and assertions. |
| Actionable assertion messages | PASS | Messages name the directory and the dependency, including the new `no typescript ignore item restricted to` message at lines 103-106. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | The module reads the real file with `read_text`; no `tmp_path` or `tempfile`. |
| Test file location | PASS | `tests/scripts/dev_tools/test_dependabot_config_contract.py`, next to `test_quality_checks_workflow_contracts.py`. |
| File size <= 500 lines | PASS | 113 lines. |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Phase 0 baseline artifacts exist under `evidence/baseline/`, and the cycle 1 and cycle 2 baselines exist under `evidence/remediation-baseline/` (stamps 00-51 and 01-16).

### 2.2 Design Principles

PASS. The I/O and untyped `yaml.safe_load` boundary is isolated in `load_target_npm_entries`; assertions work on narrowed mappings. Cycle 2 does not touch that boundary.

### 2.3 Module & File Structure

PASS. One test module of 113 lines; no production module added.

### 2.4 Naming, Docs, and Comments

PASS. `snake_case` functions, `UPPER_CASE` constants, module and function docstrings.

### 2.5 After Making Changes - Toolchain Execution

PASS. Final pass (cycle 2, stamp 01-26): Black file and repo exit 0 (598 files unchanged), Ruff file and repo exit 0, Pyright file and repo exit 0, targeted and full Pytest exit 0 (7099 passed, 6 skipped), coverage thresholds checker exit 0, and `loop-closure-tree-state.2026-10-16T01-26.md` records no restart and an unchanged tree. Contract and integration stages are unaffected (no API or schema changed).

### 2.6 Summarize and Document

PASS. `issue.md`, the plan, both remediation plans, and the evidence folder document the change.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black | PASS | `black --check .` exit 0, 598 files unchanged; re-run on the test file by this review: 1 file unchanged. |
| Ruff | PASS | `ruff check` exit 0; re-run on the test file by this review: All checks passed. |
| Pyright | PASS | Re-run on the test file by this review: 0 errors, 0 warnings, 0 informations; repo run exit 0 in `evidence/qa-gates/pyright-repo-final.2026-10-16T01-26.md`. |
| Typing of untyped boundary | PASS | `typing.cast` with string-form types on `yaml.safe_load` results; no `Any` and no suppression comments added. |
| Dependencies | PASS | PyYAML is an approved dependency; none added. |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pytest, parametrization | PASS | `pytest.mark.parametrize` with ids `root` and `extension`. |
| Full suite | PASS | 7099 passed, 6 skipped, 0 failed. |
| No mutable global state | PASS | Module constants and one documented read-only cache. |

## 5. Test Coverage Detail

### test_dependabot_config_contract.py (5 tests)

Not measured: `tests/*` is excluded by the `pyproject.toml` coverage `omit` list. The five tests cover both target npm entries for the ignore shape and the `typescript` retention, plus the entry-count guard.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| New tests | 5 passed, 0 failed (0.12 s, this review) |
| Red run before edit | 2 failed, 3 passed (expected) |
| Full suite | 7099 passed, 6 skipped, 0 failed (168.30 s) |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| Black (repo) | exit 0 |
| Ruff (repo) | exit 0 |
| Pyright (repo) | exit 0 |
| Coverage thresholds checker (85/75) | exit 0 |

## 8. Gaps and Exceptions

### Identified Gaps

- The runtime effect of a bare `dependency-name` ignore within a Dependabot group cannot be verified in-repo. `issue.md` records this as a residual risk with a post-merge `@dependabot recreate` check on PRs #832 and #833. It is not an acceptance criterion and not a finding.
- CI status at HEAD is not available (no pull request exists yet). Local toolchain evidence is the verification basis; CI will run on the pull request.

### Approved Exceptions

None.

### Removed/Skipped Tests

None removed. The 6 skipped tests pre-exist on the base.

## 9. Summary of Changes

### Commits in This PR/Branch

- `c39690459` chore(940): record Phase 0 baseline
- `1ee7c0a2b` fix(940): ignore @types/vscode in Dependabot npm entries
- `fe96fd9aa` style(940): apply Black formatting to Dependabot contract test
- `de8ab1498` chore(940): record final QC evidence and check off acceptance criteria
- `430e6a902` docs(940): record feature review artifacts (verdict PASS)
- `198206009` fix(940): cache dependabot config parse and assert any unrestricted types/vscode ignore item
- `8c89607ef` chore(940): record remediation cycle 1 final QC evidence
- `83b69e209` docs(940): record cycle 1 re-audit (PASS) and open remediation cycle 2
- `e1726c964` fix(940): assert any restricted typescript ignore item instead of items[0]
- `94f4bd870` chore(940): record remediation cycle 2 final QC evidence

### Files Modified

- `.github/dependabot.yml` (+2)
- `tests/scripts/dev_tools/test_dependabot_config_contract.py` (new, 113 lines)
- Feature folder documents and evidence (Markdown files)

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

### Policy-by-Policy Summary

- General Unit Test Policy: PASS
- General Code Change Policy: PASS
- Python code change and unit test policy: PASS
- Quality tiers and coverage exclusion policy: PASS
- Tonality: PASS

### Metrics Summary

Lines 93.80%, branches 88.11%, 0 blocking findings.

### Recommendation

Proceed to the pull request. After merge, comment `@dependabot recreate` on PRs #832 and #833 and confirm the regenerated PRs omit `@types/vscode`.

---

## Appendix A: Test Inventory

1. `test_npm_entry_ignores_types_vscode_for_all_update_types[root]`
2. `test_npm_entry_ignores_types_vscode_for_all_update_types[extension]`
3. `test_npm_entry_retains_typescript_major_ignore[root]`
4. `test_npm_entry_retains_typescript_major_ignore[extension]`
5. `test_exactly_two_target_npm_entries_are_checked`

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```
poetry run black --check .
poetry run ruff check
poetry run pyright
poetry run pytest --cov=src --cov=scripts.dev_tools --cov-report=term-missing --cov-branch
```

**Reviewer commands (check-only):** `git diff origin/main...HEAD`, `git diff 8c89607ef HEAD`, `validate_evidence_locations.py --root .`, targeted `pytest`, `black --check`, `ruff check`, and `pyright` on the test file, and an awk summation of `LF/LH/BRF/BRH` records in `artifacts/python/lcov.info`.
