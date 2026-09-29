# Policy Compliance Audit: handoff test independence from archived active directory and ip-address override remediation (#765)

**Audit Date:** 2026-09-29  
**Code Under Test:** `tests/scripts/dev_tools/test_orchestration_handoff_paths.py` (Python, modified, one line); `package.json`, `extensions/drm-copilot/package.json`, `packages/mcp-server/package.json` and their three `package-lock.json` files (JSON, modified, remediation cycle 1)  
**Base:** origin/main 5d0b93a0b0a15633b42559827fd7459d65c0b671 | **Head:** 3310fda705e2c9c2b63f6681637886b4314c29ac | **Work mode:** minor-audit | **Review type:** re-audit after remediation cycle 1

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 file (test only) | 13 tests | ✅ 13 pass, 0 fail | 43% lines (89 stmts, 38 branches; module orchestration_handoff_contract_support.py) | 43% lines (unchanged) | N/A (no production line changed) |
| JSON | 6 files (manifests and lockfiles) | N/A | N/A | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files in the branch diff; supplementary root figure 97.59% lines, 90.72% branches in `evidence/remediation-baseline/baseline-root-coverage.2026-09-29T00-30.md`
- TypeScript post-change coverage artifact: N/A - zero TypeScript files in the branch diff; supplementary root figure 97.59% lines, 90.72% branches in `evidence/qa-gates/final-root-coverage.2026-09-29T00-30.md`, confirmed by `coverage/lcov.info` totals LF 53587, LH 52299, BRF 8186, BRH 7427
- PowerShell baseline coverage artifact: N/A - zero PowerShell files in the branch diff
- PowerShell post-change coverage artifact: N/A - zero PowerShell files in the branch diff
- Per-language comparison summary: section 1.2.1 below; evidence in `evidence/baseline/baseline-pytest-coverage.2026-09-28T19-35.md`, `evidence/qa-gates/final-pytest-coverage.2026-09-28T19-35.md`, and `evidence/qa-gates/coverage-delta.2026-09-29T00-30.md`

**Non-negotiable verdict rule:** Numeric baseline and post-change coverage are reported for Python, the only language with a changed source file.

**Fail-closed rule:** All required baseline, QA, and coverage-comparison artifacts exist in the feature evidence folder.

**Evidence rule:** No evidence was backfilled from inference; each claim cites an artifact or a reviewer command.

## Rejected Scope Narrowing

None. The caller prompt did not narrow scope. It named remediation cycle 1 as context; the audit covers the full branch diff against origin/main, including the remediation commit 3310fda7.

## Evidence Location Compliance

- Branch-diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: zero files found (`git diff origin/main...HEAD --name-only` filtered on those prefixes returned nothing).
- All branch evidence is under `<FEATURE>/evidence/baseline/`, `evidence/remediation-baseline/`, `evidence/qa-gates/`, and `evidence/regression-testing/`, which are canonical kinds.
- `validate_evidence_locations.py --root .` exits non-zero with two violations: `artifacts/research/2026-07-07T19-00-epic-folder-structure-research.md` and `artifacts/research/2026-08-04T09-53-crlf-atomic-plan-validator-434-research.md`. Both are untracked local files, are not in the branch diff, and are not attributable to this branch. Canonical replacement would be `docs/research/`. Recorded as housekeeping, not a branch finding.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred; no caller instruction supplied a non-canonical path.

---

## Executive Summary

The branch has two functional parts. Commit a760a7c1 changes one line in one Python test so that `test_plan_directory_rediscovery_blocks_before_write` passes the tracked directory `tests/fixtures/orchestration-handoff/contract` to `resolve_pinned_plan_path` instead of `docs/features/active`, which no longer exists after PR #759. Commit 3310fda7 (remediation cycle 1) raises the `ip-address` override from `^10.2.0` to `^10.7.2` in three `package.json` files and regenerates the three lockfiles, because two advisories published against `ip-address <=10.5.0` failed the npm audit gate on PR #766. The remaining changed files are feature documentation and evidence. No production source file changed.

The reviewer re-ran the Python module (13 passed), ran `npm ls ip-address` and `npm audit --audit-level=moderate` in all three packages (each resolves `ip-address@10.7.2`, each reports 0 vulnerabilities), and re-derived root TypeScript coverage totals from `coverage/lcov.info`. CI on PR #766 showed the three npm audit jobs passing; other jobs were still pending at review time.

**Policy documents evaluated:**
- ✅ `general-code-change.md`
- ✅ `general-unit-test.md`

**Language-specific policies evaluated:**
- ✅ `python.md` and `python-suppressions.md`
- ✅ JSON configuration policy (manifests and lockfiles)
- N/A PowerShell, Bash, TypeScript, C# (zero changed files in the branch diff)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts were created
- ✅ No ongoing tooling scripts were added
- None created; nothing to dispose

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The changed test uses only the module constants ROOT and FIXTURES; no shared mutable state was added. The change removes the dependency on a directory that other work adds or removes. |
| **Isolation** - Each test targets single behavior | ✅ PASS | The test asserts one behavior: a directory plan path raises `HandoffContractError`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 13 passed in 0.05s (reviewer re-run at head 3310fda7). |
| **Determinism** - Consistent results | ✅ PASS | The argument is a tracked directory; no clock, randomness, or network. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | `FIXTURES.relative_to(ROOT).as_posix()` reuses an existing constant. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Python baseline 43% lines for `scripts/dev_tools/orchestration_handoff_contract_support.py` (`evidence/baseline/baseline-pytest-coverage.2026-09-28T19-35.md`). TypeScript baseline for the remediation: root 97.59% lines and 90.72% branches, extension 96.95% lines and 90.91% branches (`evidence/remediation-baseline/`). |
| **No Coverage Regression** | ✅ PASS | Python post-change 43%, change 0%. Root and extension TypeScript deltas 0.00 for lines and branches (`evidence/qa-gates/coverage-delta.2026-09-29T00-30.md`). |
| **New Code Coverage** | ✅ PASS | No new source files. The changed Python file is test code, which is excluded from coverage measurement by policy; zero production lines changed. Manifest and lockfile edits contain no executable lines. |
| **Comprehensive Coverage** | ✅ PASS | Scenario set of the module is unchanged (13 tests). No untested code introduced. |
| **Positive Flows** - Valid inputs | ✅ PASS | Pre-existing tests in the module; unchanged. |
| **Negative Flows** - Invalid inputs | ✅ PASS | The changed test is the directory-rejection negative flow; retained with `pytest.raises(HandoffContractError)`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Pre-existing traversal fixture tests; unchanged. |
| **Error Handling** - Error paths | ✅ PASS | Error path asserted by the changed test. |
| **Concurrency** - If applicable | N/A | Not applicable; no concurrent behavior. |
| **State Transitions** - If applicable | N/A | Not applicable; stateless resolver. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 43% lines -> Post-change: 43% lines. Change: 0% lines. New/changed-code coverage: N/A - test-only change, no production line changed. Disposition: PASS. Evidence: `evidence/baseline/baseline-pytest-coverage.2026-09-28T19-35.md`, `evidence/qa-gates/final-pytest-coverage.2026-09-28T19-35.md`.
- Repo-wide Python threshold (85% line, 75% branch): `artifacts/python/lcov.info` totals LF 89, LH 45 (50.6% line), BRF 38, BRH 10. LF 89 equals the single module statement count, so the artifact comes from a scoped run and is not a repo-wide measurement. Disposition: FAIL as literally read, advisory and not attributable to this branch (no production line changed); full-repo coverage is enforced by the CI quality-checks job. Not a blocking finding; same disposition as the previous audit round.
- TypeScript, PowerShell, C#: zero changed source files in the branch diff; N/A - out of scope. Supplementary TypeScript figures: root 97.59% lines and 90.72% branches, extension 96.95% lines and 90.91% branches, both unchanged from baseline.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `HandoffContractError` carries a field and reason. A non-raising call would report pytest's "DID NOT RAISE". |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Fixture arranges write denial; one call acts inside `pytest.raises`. |
| **Document Intent** | ✅ PASS | Test name states the behavior. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or process; reads a tracked repository directory via the resolver. |
| **Use Mocks/Stubs** | ✅ PASS | `deny_write_boundaries` fixture retained. |
| **Environment Stability** | ✅ PASS | No temporary files created; the substituted path is tracked content. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document. No outstanding blocking review items. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #765 `issue.md`; remediation objective in `remediation-inputs.2026-09-29T00-30.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-09-28T19-35.md` and `remediation-plan.2026-09-29T00-30.md`. |
| **Document the plan** | ✅ PASS | Both plan files are in the feature folder. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One-line test change; three one-line override edits. |
| **Reusability** | ✅ PASS | Reuses the module constant `FIXTURES`. |
| **Extensibility** | N/A | No API surface changed. |
| **Separation of concerns** | ✅ PASS | Test-only and manifest-only; production source untouched. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | No structural change. |
| **Under 500 lines** | ✅ PASS | Test file diff is +1/-1 lines in an existing file; lockfiles are generated and are not reusable script files. |
| **Public vs internal** | N/A | No public API change. |
| **No circular dependencies** | ✅ PASS | No import added. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Existing names retained. |
| **Docs/docstrings** | N/A | No new function. |
| **Comment why, not what** | N/A | No comment added. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Black: 1 file left unchanged, exit 0 (`evidence/qa-gates/final-black.2026-09-28T19-35.md`). Prettier on the three npm packages: file lists identical to baseline; the existing baseline failures are unrelated fixture files and no changed manifest appears (`evidence/qa-gates/final-root-prettier.2026-09-29T00-30.md`). |
| **2. Linting** | ✅ PASS | Ruff: All checks passed, exit 0. ESLint root and extension exit 0 (`final-root-lint`, `final-extension-lint`). |
| **3. Type checking** | ✅ PASS | Pyright: 0 errors, exit 0. TypeScript typecheck root and extension exit 0 (`final-root-typecheck`, `final-extension-typecheck`). |
| **4. Testing** | ✅ PASS | Pytest: 13 passed (reviewer re-run). Jest root 3171 passed, extension 3154 passed, 0 failed. |
| **Full toolchain loop** | ✅ PASS | All steps exit 0 or match baseline per the QA-gate evidence; the sole non-zero stage (root Prettier exit 2) is byte-identical to baseline. |
| **Explicit reporting** | ✅ PASS | Commands and results are in `evidence/qa-gates/` and `evidence/regression-testing/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 below. |
| **Design choices explained** | ✅ PASS | `issue.md` Proposed Fix; `remediation-inputs.2026-09-29T00-30.md` Cause and Required change. |
| **Update supporting documents** | ✅ PASS | Feature folder and promoted record added. |
| **Provide next steps** | ✅ PASS | Confirm remaining CI jobs on PR #766 complete green. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | Exit 0, no rewrite. |
| **Linting with Ruff** | ✅ PASS | Exit 0. |
| **Type checking with Pyright** | ✅ PASS | 0 errors, 0 warnings. |
| **Testing with Pytest** | ✅ PASS | 13 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Test signature unchanged and annotated; no `Any` added. |
| **Dataclasses for value objects** | N/A | None involved. |
| **Protocols/ABCs for interfaces** | N/A | None involved. |
| **Avoid utility classes** | ✅ PASS | None added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | Test asserts the specific `HandoffContractError`. |
| **Logging over print** | ✅ PASS | No print added. |
| **Invariants at construction** | N/A | No class added. |

Suppressions: the diff adds no `noqa`, `type: ignore`, or `pyright: ignore` (PASS under `python-suppressions.md`).

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Valid JSON, formatter-clean** | ✅ PASS | `npm ls` and `npm audit` parse all six files successfully in the reviewer run; Prettier reports no changed manifest or lockfile. |
| **Dependency pinning discipline** | ✅ PASS | Override moves from `^10.2.0` to `^10.7.2` (patched range) identically in all three manifests; `npm audit fix --force` was not used (`evidence/regression-testing/manifest-*.2026-09-29T00-30.md`). |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Minimal, scoped change** | ⚠️ PARTIAL | The `ip-address` entry moved 10.4.0 to 10.7.2 in each lockfile with the new integrity hash, and the `@modelcontextprotocol/sdk` version stayed 1.30.1. The root and extension lockfiles also dropped 30 lines of `libc` metadata from ten optional `@unrs/resolver-binding-linux-*` entries because npm 11.9.0 on win32 does not re-emit that field (`evidence/regression-testing/lockfile-diff.2026-09-29T00-30.md`). No version changed. Recorded as a Minor finding, non-blocking. |
| **Gate outcome** | ✅ PASS | `npm audit --audit-level=moderate` exits with 0 vulnerabilities in `.`, `extensions/drm-copilot`, and `packages/mcp-server` (reviewer re-run); the audit jobs in CI on PR #766 passed. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Pytest with `pytest.raises` and the `deny_write_boundaries` fixture. |
| **Coverage expectation** | ✅ PASS | 43% before and after for the exercised module; no production lines changed; repo-wide figure discussed in 1.2.1. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Single behavior. |
| **Mocking sparingly** | ✅ PASS | One write-denial fixture, retained. |
| **Organization** | ✅ PASS | Test stays under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_plan_directory_rediscovery_blocks_before_write`. |
| **Docstrings/comments** | N/A | None changed. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `poetry run pytest`, 13 passed. |
| **No Alternative Test Runners** | ✅ PASS | Only Pytest used for Python. |

---

## 5. Test Coverage Detail

### test_plan_directory_rediscovery_blocks_before_write (1 test)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_plan_directory_rediscovery_blocks_before_write | Negative / Error Handling | `resolve_pinned_plan_path` lines 46-53 (raises at the `is_file()` check) | ✅ |

**Coverage:** the resolver raises at line 53 for a directory argument.

**Not covered:** None attributable to this change.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 13 (Python module) | ✅ |
| Tests Passed | 13 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 0.05s total | ✅ Fast |
| Average Time per Test | about 4ms | ✅ Fast |
| Discovery Time | not separately reported | N/A |
| Functions/Classes Tested | 1 changed test of 13 in module | ✅ |
| Test File Size | under 500 lines | ✅ Maintainable |
| Code Coverage (if applicable) | 43% lines for the exercised Python module (scoped run); TypeScript root 97.59% and extension 96.95% lines, unchanged | ✅ no regression |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | 1 file unchanged | ✅ |
| Ruff Linting | `poetry run ruff check tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | 13 passed | ✅ |

**For npm packages (remediation cycle 1):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Audit root | `npm audit --audit-level=moderate` | 0 vulnerabilities | ✅ |
| Audit extension | `npm audit --audit-level=moderate --prefix extensions/drm-copilot` | 0 vulnerabilities | ✅ |
| Audit mcp-server | `npm audit --audit-level=moderate --prefix packages/mcp-server` | 0 vulnerabilities | ✅ |
| Resolved version | `npm ls ip-address` in each package | ip-address@10.7.2 in all three | ✅ |

**Notes:**
The evidence-location scan result is recorded under Evidence Location Compliance above. The audit gate level `moderate` matches the workflow input used by the failing jobs. No workflow file is in the diff, so the workflow green-run requirement does not apply.

---

## 8. Gaps and Exceptions

### Identified Gaps
- Repo-wide Python coverage artifact is a scoped run (see 1.2.1); advisory, not blocking.
- Lockfile `libc` metadata removal in two lockfiles (see 3D.2); Minor, non-blocking.
- `evidence/qa-gates/no-production-change.2026-09-28T19-35.md` predates the remediation commit; `evidence/qa-gates/scope-check.2026-09-29T00-30.md` covers the manifest edits. Neither shows a source file change.
- `issue.md` Status line cites a folder path without the date prefix or issue suffix. Cosmetic.
- CI on PR #766 had jobs pending at review time; final CI result is not part of this audit.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
**None.** No tests removed or skipped.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **a760a7c1** - test(handoff): remove dependency on archived active features directory
2. **59aa6255** - docs(features): add feature-review artifacts for #765
3. **3310fda7** - fix(deps): raise ip-address override to ^10.7.2 for npm audit gate

### Files Modified

1. **tests/scripts/dev_tools/test_orchestration_handoff_paths.py** (MODIFIED)
   - Replaces the literal `docs/features/active` argument with `FIXTURES.relative_to(ROOT).as_posix()`.
2. **package.json, extensions/drm-copilot/package.json, packages/mcp-server/package.json** (MODIFIED)
   - `ip-address` override raised to `^10.7.2`.
3. **package-lock.json, extensions/drm-copilot/package-lock.json, packages/mcp-server/package-lock.json** (MODIFIED)
   - `ip-address` resolved to 10.7.2; libc metadata drift in the first two.
4. **docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/** (NEW)
   - `issue.md`, plans, review artifacts, remediation inputs, and evidence files.
5. **docs/features/potential/promoted/2026-09-28-handoff-test-depends-on-archived-active-dir.md** (NEW)
   - Promoted lifecycle record.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

The test change is minimal and passes the Python toolchain. The remediation is limited to the override floor and lockfile regeneration, and the audit gate now reports 0 vulnerabilities in all three packages. Two non-blocking observations remain (scoped Python coverage artifact, lockfile libc metadata drift). Blocking findings: 0.

**Fail-closed reminder:** No required baseline, QA, or coverage-comparison artifact is absent.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objective and plans documented
- ✅ Design Principles: minimal edits
- ✅ Module & File Structure: no structural change
- ✅ Naming, Docs, Comments: unchanged
- ✅ Toolchain Execution: all exit 0 or match baseline
- ✅ Summarize & Document: complete

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright clean
- ✅ Python Design & Typing: no change
- ✅ Error Handling: specific exception asserted

**For JSON:**
- ✅ Tooling: valid and audit-clean
- ⚠️ Structure: libc metadata drift, Minor

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: satisfied
- ⚠️ Coverage & Scenarios: no regression on changed lines; repo-wide Python artifact is a scoped run (advisory)
- ✅ Test Structure: satisfied
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest
- ✅ Test Style & Structure: focused
- ✅ Naming & Readability: satisfied
- ✅ Toolchain: Pytest only

---

### Metrics Summary

- ✅ 13/13 Python tests passing (100%)
- ✅ 43% line coverage of the exercised Python module before and after
- ✅ TypeScript coverage unchanged: root 97.59% lines and 90.72% branches
- ✅ npm audit: 0 vulnerabilities in three packages
- ✅ Test file location mirrors source

---

### Recommendation

**Ready for merge** once the remaining CI jobs on PR #766 complete green. CI status was partly pending at review time.

---

## Appendix A: Test Inventory

### Complete Test List

- tests/scripts/dev_tools/test_orchestration_handoff_paths.py::test_plan_directory_rediscovery_blocks_before_write (changed)
- Twelve other tests in the same module (unchanged; 13 collected in total)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
poetry run black tests/scripts/dev_tools/test_orchestration_handoff_paths.py
poetry run ruff check tests/scripts/dev_tools/test_orchestration_handoff_paths.py
poetry run pyright tests/scripts/dev_tools/test_orchestration_handoff_paths.py
poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py --cov=scripts.dev_tools.orchestration_handoff_contract_support --cov-branch --cov-report=term-missing --cov-fail-under=0
```

**For npm packages:**
```bash
npm audit --audit-level=moderate
npm audit --audit-level=moderate --prefix extensions/drm-copilot
npm audit --audit-level=moderate --prefix packages/mcp-server
npm ls ip-address
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-09-29  
**Policy Version:** Current (as of audit date)
