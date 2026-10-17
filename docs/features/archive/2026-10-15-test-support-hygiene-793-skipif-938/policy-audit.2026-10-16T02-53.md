# Policy Compliance Audit: Test-support hygiene and stale skipif (#938)

---

**Audit Date:** 2026-10-16
**Audit Type:** Re-audit after remediation cycle 2
**Branch:** `bug/test-support-hygiene-793-skipif-938` (reviewed from local alias `bug/test-support-hygiene-793-skipif-c2-938`, HEAD `c8281987b`)
**Base:** `origin/main` (merge base `97559c3e0`)
**Work Mode:** `minor-audit`
**Code Under Test:** 12 non-documentation files changed on the branch: 1 new Python test-support module, 10 modified Python test modules, 1 modified TypeScript test file (comment change only; unchanged in cycle 2). The cycle 2 commit changes four Python test files only. No production Python, TypeScript, PowerShell, or C# file changed.

**Total blocking findings: 0.**

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 11 test files (0 production) | 7099 passed, 6 skipped (full suite); 135 in the ten-file set | PASS: 0 failed | 93.8% lines, 88.1% branches | 93.80% lines (16544/17638), 88.13% branches (5612/6368) | 93.80% lines, 88.13% branches (repo-wide; test files are outside the measured denominator) |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 1 file (test only, comment change, unchanged in cycle 2) | 270 suites, 4002 tests passed (cycle 1 evidence) | PASS: 0 failed | 97.26% lines, 92.28% branches | 97.26% lines, 92.28% branches | 97.26% lines, 92.28% branches (extension-wide; comment-only change in a test file) |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: 97.26% lines, 92.28% branches (`evidence/qa-gates/ts-jest-coverage.2026-10-16T01-42.md`); the change is one comment in a test file, so before and after are the same tree.
- TypeScript post-change coverage artifact: the same evidence file records EXIT_CODE 0 and thresholds 85 and 75 met. The review worktree has no `extensions/drm-copilot/coverage/lcov.info`; the main-checkout copy gives 96.95% lines and 90.91% branches, also above thresholds. The cycle 2 commit does not touch TypeScript.
- Python coverage artifact: `artifacts/python/lcov.info` present; reviewer awk gives LF 17638, LH 16544 (93.80%), BRF 6368, BRH 5612 (88.13%). Cycle 2 term-missing run: `evidence/qa-gates/cycle2-pytest-full-coverage.2026-10-16T02-50.md`, TOTAL 92% (scripts.dev_tools plus src, branch). Defaults of 85% line and 75% branch govern because the root `CLAUDE.md` states none; both are met.
- PowerShell baseline coverage artifact: N/A, no PowerShell file changed
- PowerShell post-change coverage artifact: N/A, no PowerShell file changed
- C#: N/A, no C# file changed.
- Per-language comparison summary: section 1.2.1 of this audit.

---

## Executive Summary

Cycle 2 (commit `c8281987b`) moves `build_valid_orchestrator_state`, `build_valid_policy_audit_text`, and `build_complete_large_orchestrator_state` from `test_validate_orchestration_artifacts.py` into `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py`, repoints the importers, and consolidates the dispatch test's imports onto the support module. Findings RI-2 and RI-3 from `remediation-inputs.2026-10-16T02-07.md` are closed.

Reviewer verification: a Grep for `test_validate_orchestration_artifacts import` over `tests/` returns no match, so no test module imports from the old module and no re-export exists. `test_validate_orchestration_artifacts_dispatch.py` imports all four shared builders from the support module only (lines 19 to 24). `test_validate_orchestration_artifacts.py` imports only `build_valid_policy_audit_text` from the support module. The three builders are defined only in the support module within the `test_validate_orchestration_artifacts*` family (same-named builders in `test_validate_orchestrator_state_remediation_loop.py` and `test_validate_policy_audit_artifact.py` pre-date the branch and are separate implementations). Cycle 2 AST evidence (`cycle2-builder-equality`, `cycle2-importer-ast-negative`, `cycle2-importer-ast-positive`, `cycle2-builder-def-negative`) agrees. Line counts: support 285, old module 144, dispatch 278, state_shape 154; all at most 500.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; no project added)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` and `.claude/rules/python-suppressions.md`
- PASS `.claude/rules/typescript.md` (comment-only change; coverage evidence present)
- N/A PowerShell, C#, Bash: no changed files.

**Temporary artifacts cleanup:**
- PASS No temporary script is committed; no `artifacts/` path appears in the branch diff (`git diff --name-only origin/main...HEAD -- artifacts extensions` lists only the TypeScript test file).

---

## Rejected Scope Narrowing

None detected. The caller prompt emphasised the cycle 2 commit but asked for the full branch diff against `main`, which was audited. The plan line `DIRECTIVE: PREFLIGHT VALIDATION ONLY` is a planner handoff directive and is not a defect.

## Evidence Location Compliance

- `python -I scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported path.
- No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appears in the branch diff. All cycle 2 evidence is under `<FEATURE>/evidence/{baseline,remediation-baseline,qa-gates,regression-testing,other}/`.
- Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entries.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Builders are pure functions in a module without state; importers no longer depend on another `test_*.py` module. |
| Isolation | PASS | No test body changed in cycle 2. |
| Fast execution | PASS | Ten-file group: 135 passed in 3.29s. |
| Determinism | PASS | Builders return literals. |
| Readability | PASS | Dispatch module docstring names the support module. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | PASS | `evidence/remediation-baseline/cycle2-pytest-full-coverage.2026-10-16T02-33.md` and `cycle2-pytest-ten-files-coverage.2026-10-16T02-32.md`. |
| No coverage regression | PASS | Ten-file module row equals baseline (149/9/56/5, 92%); full suite 7099 passed, 6 skipped, 0 failed. The plan value 7094 predated tests merged from #940. |
| New code coverage >= 85% | PASS | No production line added; the support module is a test file outside the measured denominator. |
| Positive, negative, edge, error flows | PASS | Unchanged tests cover them. |
| Test file location | PASS | Support module is in `tests/scripts/dev_tools/`; no colocation in `src/`. |
| Coverage exclusion policy | PASS | No `exclude` entry added to any coverage configuration. |
| Temporary files | PASS | None created in tests. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.8% lines, 88.1% branches -> Post-change: 93.80% lines, 88.13% branches. Change: +0.0% lines, +0.0% branches. New/changed-code coverage: 93.80% lines, 88.13% branches (repo-wide figures govern; changed files are test modules outside the measured denominator). Disposition: PASS. Evidence: artifacts/python/lcov.info (reviewer awk), evidence/qa-gates/cycle2-pytest-full-coverage.2026-10-16T02-50.md.
- TypeScript: Baseline: 97.26% lines, 92.28% branches -> Post-change: 97.26% lines, 92.28% branches. Change: +0.0% lines, +0.0% branches. New/changed-code coverage: 97.26% lines, 92.28% branches (extension-wide figures govern; the changed line is a comment in a test file, untouched in cycle 2). Disposition: PASS. Evidence: evidence/qa-gates/ts-jest-coverage.2026-10-16T01-42.md.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear failure messages | PASS | No assertion changed. |
| Arrange-Act-Assert | PASS | No test body changed. |
| Document intent | PASS | Builder docstrings preserved verbatim (`cycle2-docstring-check`). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid external dependencies | PASS | Builders are in-memory literals. |
| Environment stability | PASS | No temporary files introduced. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission review | PASS | This re-audit; no outstanding blocking finding. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity, reusability, separation of concerns | PASS | One shared support module replaces cross-test-module imports. |
| Under 500 lines | PASS | 285, 144, 278, 154 (`evidence/qa-gates/cycle2-line-counts.2026-10-16T02-50.md`, confirmed by reviewer `wc -l`). |
| Naming | PASS | `*_test_support.py` convention. |
| Circular dependencies | PASS | The support module imports no test module. |

### 2.2 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| 1. Formatting | PASS | `cycle2-black-check.2026-10-16T02-50.md`: 4 files unchanged. |
| 2. Linting | PASS | `cycle2-ruff-check.2026-10-16T02-50.md`: all checks passed. |
| 3. Type checking | PASS | `cycle2-pyright.2026-10-16T02-50.md`: 0 errors. The earlier 02-41 run recorded 18 errors caused by missing `.venv` dependencies; the 02-50 rerun after `poetry install` is clean. |
| 4. Testing | PASS | 7099 passed, 6 skipped, no failures. |
| Full toolchain loop | PASS | `cycle2-final-loop-single-pass.2026-10-16T02-51.md`: no file changed during the pass. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black / Ruff / Pyright | PASS | Exit 0 on all four cycle 2 files. |
| Pytest | PASS | 7099 passed, 6 skipped (pre-existing skips). |
| Suppressions | PASS | The cycle 2 diff adds no `noqa`, `type: ignore`, or `pyright: ignore`. |

### Section 3E: TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| Prettier / ESLint / tsc / Jest | PASS | Exit 0 in cycle 1 evidence; file untouched in cycle 2. |
| Coverage artifact | PASS | 97.26% line, 92.28% branch recorded. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | PASS | All tests run under pytest. |
| Coverage expectation | PASS | 93.80% line / 88.13% branch repo-wide. |
| Organization | PASS | Support module mirrors the production tree under `tests/`. |

---

## 5. Test Coverage Detail

### `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Importer suites (epic state, merge status, orchestration artifacts, dispatch, plan gates, parallel dispatch, state shape, discovery dispatch, pr-creation readiness) | Positive | All five builders (exercised by 135 tests in the ten-file group) | PASS |

**Coverage:** test file; outside the measured denominator by configuration. **Not covered:** not measured.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | pytest 7105 (full); 135 in the ten-file set | PASS |
| Tests Passed | 7099; 135 | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Ten-file set 3.29s; full suite 133.99s | PASS |
| Test File Size | All under 500 lines | PASS |
| Code Coverage | Python 93.80% / 88.13%; TypeScript 97.26% / 92.28% | PASS |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check` | exit 0 | PASS |
| Ruff | `poetry run ruff check` | exit 0 | PASS |
| Pyright | `poetry run pyright` | exit 0 | PASS |
| Pytest | `poetry run pytest` | 7099 passed | PASS |

---

## 8. Gaps and Exceptions

### Identified Gaps

- None open. RI-2 and RI-3 are closed.
- Non-blocking: the remediation-input baseline of 7094 passed differs from the cycle 2 result of 7099 because tests from #940 merged from `origin/main`; the difference is explained in the evidence note and is not a regression.

### Approved Exceptions

- None.

### Removed/Skipped Tests

- No test removed in cycle 2.

---

## 9. Summary of Changes

1. **91044a5b7** - test: move shared validator builders to a support module and drop stale skipif (#938)
2. **653a2b709** - test: consolidate read-text stubs onto shared builder and record TS coverage evidence (#938)
3. **c8281987b** - test(938): move remaining orchestration test builders to the shared support module

---

## 10. Compliance Verdict

### Overall Status: PASS

All toolchain stages pass in a single pass, file-size and evidence-location checks pass, and Python and TypeScript coverage meet thresholds with no regression.

**Total blocking findings: 0.**

---

### Policy-by-Policy Summary

- PASS General Code Change Policy
- PASS General Unit Test Policy
- PASS Python code change and unit test policy
- PASS TypeScript code change policy (unchanged in cycle 2)

### Metrics Summary

- PASS pytest 7099 passed, 0 failed
- PASS Python 93.80% line / 88.13% branch
- PASS TypeScript 97.26% line / 92.28% branch

### Recommendation

**Ready to proceed.** No remediation required.

---

## Appendix A: Test Inventory

1. Ten-file validator set: 135 collected and passed, equal to the cycle 2 baseline.
2. Named dispatch and policy-audit tests: 6 passed (`cycle2-pytest-named-tests.2026-10-16T02-50.md`).

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands:**
```bash
git diff --stat HEAD~1 HEAD
git diff --name-only origin/main...HEAD -- artifacts extensions
awk -F: '/^LF:/{lf+=$2}/^LH:/{lh+=$2}/^BRF:/{bf+=$2}/^BRH:/{bh+=$2}' artifacts/python/lcov.info
python -I scripts/dev_tools/validate_evidence_locations.py --root .
```

**For Python:**
```bash
poetry run black --check <files>
poetry run ruff check <files>
poetry run pyright <files>
poetry run pytest
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)
