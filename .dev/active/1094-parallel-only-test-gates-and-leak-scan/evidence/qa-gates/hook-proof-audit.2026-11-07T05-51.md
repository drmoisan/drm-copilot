# Policy Compliance Audit: hook proof

---

**Audit Date:** filled  
**Code Under Test:** filled

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 files | 1 tests | ✅ 1 pass, 1 fail | N/A - no pre-change run | 90% lines, 90% funcs | 90% |
| TypeScript | 1 files | 1 tests | ✅ 1 pass, 1 fail | N/A - no pre-change run | 90% lines, 90% funcs | 90% |
| PowerShell | 1 files | 1 tests | ✅ 1 pass, 1 fail | N/A - no pre-change run | 90% cmds, 90% funcs | 90% |

**Note:** Delete rows for languages not involved in this change. Add rows if additional languages are used.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no pre-change run
- TypeScript post-change coverage artifact: coverage/lcov.info
- PowerShell baseline coverage artifact: N/A - no pre-change run
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- Per-language comparison summary: Section 1.2.1

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required QA artifact or post-change coverage metric is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

---

## Executive Summary

filled

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (if applicable)
- ✅ `general-unit-test.instructions.md` (if testing)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ Bash: shfmt + shellcheck + bats (if applicable)
- ✅ JSON: format_json + validate_json (if applicable)

**Note:** Check all languages involved in this change. N/A for unused languages.

filled

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies
- filled

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | filled |
| **Isolation** - Each test targets single behavior | ✅ PASS | filled |
| **Fast Execution** - Tests complete quickly | ✅ PASS | filled |
| **Determinism** - Consistent results | ✅ PASS | filled |
| **Readability & Maintainability** - Clear structure | ✅ PASS | filled |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** 90% lines, 90% functions, read from the single gate run<br>**Thresholds:** filled<br>**Status:** filled<br>**Example:** "Post-change: 87.1% against the 85% line threshold ✅ PASS" |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** filled<br>**New code coverage:** 90% (must be ≥90%)<br>**Calculation method:** filled<br>**Example:** "New module `foo.py`: 127/135 lines covered = 94.1% ✅ PASS" |
| **Comprehensive Coverage** | ✅ PASS | **All functions/classes tested:**<br>- `function_name()` (lines X-Y): 1 tests<br>- `ClassName` (lines A-B): 1 tests<br>**Untested code:** filled<br>**Example:**<br>- `parse_config()` (lines 45-67): 3 tests<br>- `ConfigLoader` (lines 100-150): 5 tests<br>- Untested: `__repr__()` (trivial representation, no business logic) |
| **Positive Flows** - Valid inputs | ✅ PASS | **All positive scenarios tested:**<br>- `test_function_with_valid_string`: Tests normal string input → returns expected output<br>- `test_function_with_valid_number`: Tests numeric input in valid range → performs calculation<br>- `test_function_with_default_params`: Tests function with default parameters → uses correct defaults<br>**Total positive tests:** 1 |
| **Negative Flows** - Invalid inputs | ✅ PASS | **All negative scenarios tested:**<br>- `test_function_rejects_none`: Input `None` → raises `ValueError` with message "Input cannot be None"<br>- `test_function_rejects_empty_string`: Input `""` → raises `ValueError` with message "Input cannot be empty"<br>- `test_function_rejects_negative_number`: Input `-5` → raises `ValueError` with message "Value must be positive"<br>- `test_function_rejects_wrong_type`: Input `123` (expected str) → raises `TypeError` with message "Expected string, got int"<br>**Total negative tests:** 1 |
| **Edge Cases** - Boundary conditions | ✅ PASS | **All edge cases tested:**<br>- `test_function_with_empty_list`: Input `filled` → returns empty result<br>- `test_function_with_max_length_string`: Input 255-char string (boundary) → processes correctly<br>- `test_function_with_unicode_chars`: Input `"café ☕"` → handles Unicode correctly<br>- `test_function_with_whitespace`: Input `"  spaces  "` → strips/preserves as designed<br>**Total edge case tests:** 1 |
| **Error Handling** - Error paths | ✅ PASS | **All error scenarios tested:**<br>- `test_function_handles_network_timeout`: Mock network timeout → raises `TimeoutError` after retry<br>- `test_function_handles_file_not_found`: Missing file → raises `FileNotFoundError` with filepath<br>- `test_function_handles_json_parse_error`: Invalid JSON → raises `JSONDecodeError` with line number<br>**Total error handling tests:** 1 |
| **Concurrency** - If applicable | ✅ PASS | filled |
| **State Transitions** - If applicable | ✅ PASS | filled |

### 1.2.1 Per-Language Coverage Comparison

Repeat one bullet per in-scope language that has coverage requirements. Keep the checklist above even when a language is out of scope, but use `N/A - out of scope` for the artifact path.

- Python: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS. Evidence: artifacts/python/lcov.info.
- PowerShell: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml.
- TypeScript: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS. Evidence: coverage/lcov.info.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | filled |
| **Arrange-Act-Assert Pattern** | ✅ PASS | filled |
| **Document Intent** | ✅ PASS | filled |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | filled |
| **Use Mocks/Stubs** | ✅ PASS | filled |
| **Environment Stability** | ✅ PASS | filled |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | filled |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | filled |
| **Read existing change plans** | ✅ PASS | filled |
| **Document the plan** | ✅ PASS | filled |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | filled |
| **Reusability** | ✅ PASS | filled |
| **Extensibility** | ✅ PASS | filled |
| **Separation of concerns** | ✅ PASS | filled |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | filled |
| **At or below the 800-line hard limit** | ✅ PASS | filled |
| **Public vs internal** | ✅ PASS | filled |
| **No circular dependencies** | ✅ PASS | filled |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | filled |
| **Docs/docstrings** | ✅ PASS | filled |
| **Comment why, not what** | ✅ PASS | filled |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `filled`<br>**Result:** filled |
| **2. Linting** | ✅ PASS | **Command:** `filled`<br>**Result:** filled |
| **3. Type checking** | ✅ PASS | **Command:** `filled`<br>**Result:** filled |
| **4. Testing** | ✅ PASS | **Command:** `filled`<br>**Result:** filled |
| **Full toolchain loop** | ✅ PASS | filled |
| **Explicit reporting** | ✅ PASS | filled |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | filled |
| **Design choices explained** | ✅ PASS | filled |
| **Update supporting documents** | ✅ PASS | filled |
| **Provide next steps** | ✅ PASS | filled |

---

## 3. Language-Specific Code Change Policy Compliance

**Instructions:** Complete one section per language involved in this change. Delete sections for languages not used.

---

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black .`<br>**Result:** filled |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** filled |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** filled |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto`<br>**Result:** filled |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | filled |
| **Dataclasses for value objects** | ✅ PASS | filled |
| **Protocols/ABCs for interfaces** | ✅ PASS | filled |
| **Avoid utility classes** | ✅ PASS | filled |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | filled |
| **Logging over print** | ✅ PASS | filled |
| **Invariants at construction** | ✅ PASS | filled |

---

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .`<br>**Result:** filled |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** filled |
| **Fix all findings** | ✅ PASS | filled |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | filled |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | filled |
| **Parameter validation** | ✅ PASS | filled |
| **Avoid global state** | ✅ PASS | filled |
| **Error handling** | ✅ PASS | filled |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | filled |
| **Approved verbs** | ✅ PASS | filled |
| **Comment why** | ✅ PASS | filled |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | filled |
| **Step 2: Analyze** | ✅ PASS | filled |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | filled |
| **Rerun loop if needed** | ✅ PASS | filled |

---

### Section 3C: Bash Script Policy Compliance (if applicable)

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** `bash scripts/bash/shell-qc.sh format`<br>**Result:** filled |
| **Linting with shellcheck** | ✅ PASS | **Command:** `bash scripts/bash/shell-qc.sh check`<br>**Result:** filled |
| **Testing with bats** | ✅ PASS | **Command:** `bash scripts/bash/shell-qc.sh test`<br>**Result:** filled |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | filled |
| **Error handling** | ✅ PASS | filled |
| **At or below the 800-line hard limit** | ✅ PASS | filled |

---

### Section 3D: JSON Configuration Policy Compliance (if applicable)

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | **Command:** `poetry run python -m scripts.dev_tools.format_json`<br>**Result:** filled |
| **Schema validation** | ✅ PASS | **Command:** `poetry run python -m scripts.dev_tools.validate_json`<br>**Result:** filled |
| **Required $schema** | ✅ PASS | filled |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | filled |
| **Deterministic key order** | ✅ PASS | filled |

---

## 4. Language-Specific Unit Test Policy Compliance

**Instructions:** Complete one section per language with tests. Delete sections for languages not used or not tested.

---

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | filled |
| **Coverage expectation** | ✅ PASS | filled |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | filled |
| **Mocking sparingly** | ✅ PASS | filled |
| **Organization** | ✅ PASS | filled |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | filled |
| **Docstrings/comments** | ✅ PASS | filled |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto`<br>**Result:** filled |
| **No Alternative Test Runners** | ✅ PASS | filled |

---

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | filled |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>filled |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | filled |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | filled |
| **Test Behavior Over Implementation** | ✅ PASS | filled |
| **Mocking Used Sparingly** | ✅ PASS | filled |
| **Organization** | ✅ PASS | **CRITICAL:** Test file location must mirror code file location.<br>**Test file:** `filled`<br>**Code file:** `filled`<br>filled |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | filled.Tests.ps1`] |
| **Describe/Context/It Structure** | ✅ PASS | filled |
| **Logical Grouping** | ✅ PASS | filled |
| **Docstrings/Comments** | ✅ PASS | filled |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Result:** filled |
| **No Alternative Test Runners** | ✅ PASS | filled |

---

## 5. Test Coverage Detail

**Instructions:** Create one subsection for each function/class/module under test. Use tables to show test names, scenario types, lines covered, and status.

### filled (1 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| filled | filled | filled | ✅ |
| filled | filled | filled | ✅ |
| filled | filled | filled | ✅ |

**Coverage:** 90% of filled (lines filled-filled)

**Detailed line-by-line coverage (optional):**
- Line 1: ✅ Covered (filled)
- Lines filled: ✅ Covered (filled)
- Line 1: ❌ Not covered (filled)

**Not covered:** filled

---

### filled (1 tests)

filled

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 1 | ✅ |
| Tests Passed | 1 (90%) | ✅ |
| Tests Failed | 1 | ✅ |
| Execution Time | filleds total | ✅ Fast/Slow |
| Average Time per Test | filledms | ✅ Fast/Slow |
| Discovery Time | filledms | ✅ |
| Functions/Classes Tested | 1/filled (90%) | ✅ |
| Test File Size | 1 logical lines | ✅ PASS at or below 800 lines, FAIL above 800 without a baseline entry; note a non-blocking Warning at or above 700 lines |
| Code Coverage (if applicable) | 90% lines, 90% branches | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black .` | filled | ✅ |
| Ruff Linting | `poetry run ruff check` | filled | ✅ |
| Pyright Type Checking | `poetry run pyright` | filled | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | filled | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | filled | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | filled | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest -Root .` | filled | ✅ |

**Notes:**
filled

---

## 8. Gaps and Exceptions

### Identified Gaps
filled

**Example:**
- filled: filled

### Approved Exceptions
filled

**Example:**
- filled: filled

### Removed/Skipped Tests
filled

**Example:**
1. **"filled"** - Removed in commit filled
   - **Reason:** filled
   - **Impact:** filled
   - **Justification:** filled

---

## 9. Summary of Changes

### Commits in This PR/Branch

filled

**Example:**
1. **filled** - filled
2. **filled** - filled
3. **filled** - filled

### Files Modified

filled

**Example:**

1. **filled** (NEW/MODIFIED/DELETED)
   - filled
   - filled

2. **filled** (NEW/MODIFIED/DELETED)
   - filled
   - filled

3. **filled** (NEW/MODIFIED/DELETED)
   - filled
   - filled

---

## 10. Compliance Verdict

### Overall Status: ✅

filled

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required QA artifact or post-change coverage metric is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: filled
- ✅ Design Principles: filled
- ✅ Module & File Structure: filled
- ✅ Naming, Docs, Comments: filled
- ✅ Toolchain Execution: filled
- ✅ Summarize & Document: filled

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: filled
- ✅ Python Design & Typing: filled
- ✅ Error Handling: filled

**For PowerShell:**
- ✅ Tooling & Baseline: filled
- ✅ PowerShell Design & Safety: filled
- ✅ Structure & Naming: filled
- ✅ Toolchain: filled

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: filled
- ✅ Coverage & Scenarios: filled
- ✅ Test Structure: filled
- ✅ External Dependencies: filled
- ✅ Policy Audit: filled

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: filled
- ✅ Test Style & Structure: filled
- ✅ Naming & Readability: filled
- ✅ Toolchain: filled

**For PowerShell:**
- ✅ Framework & Scope: filled
- ✅ Test Style & Structure: filled
- ✅ Naming & Readability: filled
- ✅ Toolchain: filled

---

### Metrics Summary

filled

**Example:**
- ✅ 1/filled tests passing (90%)
- ✅ 1/filled functions/classes tested (90%)
- ✅ 90% line coverage
- ✅ Proper file organization: filled
- ✅ All code quality checks passing
- ✅ Test execution time: filled seconds (filled)

---

### Recommendation

**filled**

filled

---

## Appendix A: Test Inventory

### Complete Test List

filled

**Example format:**

1. filled › filled › filled
2. filled › filled › filled
3. filled › filled › filled
...

**Alternative flat format:**

- filled
- filled
- filled
...

---

## Appendix B: Toolchain Commands Reference

filled

**For Python:**
```bash
# Formatting
poetry run black .

# Linting
poetry run ruff check
poetry run ruff check --fix  # auto-fix

# Type checking
poetry run pyright

# Testing
poetry run pytest -n auto
poetry run pytest -n auto --cov=src/filled --cov-report=term-missing
```

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
```

---

**Audit Completed By:** filled  
**Audit Date:** filled  
**Policy Version:** Current (as of audit date)
