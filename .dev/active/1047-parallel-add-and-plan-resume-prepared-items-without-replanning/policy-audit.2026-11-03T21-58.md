# Policy Compliance Audit: Prepared-Item Admission for /parallel-add and /parallel-plan (#1047)

---

**Audit Date:** 2026-11-03
**Branch:** `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `22af341341ae9845364b6f000871ff0413a53dde`
**Base:** `origin/main` @ `01706c697f3ad4a53b4a771d99d851afc7417ea9` (merge base equals the base head)
**Audit Type:** Remediation re-audit after cycle 2 (`remediation-plan.2026-11-03T21-16.md`); previous review sets `*.2026-11-03T18-43.md` and `*.2026-11-03T21-04.md`
**Code Under Test:**

- PowerShell (new): `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` (modified again in cycle 2), `.claude/lib/parallel-admission/ParallelAdmission.psm1`, `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1`, `.claude/lib/parallel-admission/ParallelAdmissionJson.psm1`, and their byte-equal bundle copies under `extensions/drm-copilot/resources/claude-customizations/`.
- PowerShell (modified): `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` and its bundle copy.
- PowerShell tests (new or modified): six suites under `tests/scripts/claude-lib/parallel-admission/` (`Invoke-ParallelAdmission.Tests.ps1` modified in cycle 2) and `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`.
- Python (modified, test-support only): `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (unchanged since the initial delivery).
- JSON: `.claude/settings.json` (and bundle copy), `pack-manifests/core.json`, five fixtures under `tests/fixtures/parallel_admission/`.
- YAML: `quality-tiers.yml`.
- Markdown: two agents, one rule, three skills (each with bundle copy), feature-folder documents and evidence (`spec.md` edited in cycle 2 outside `## Acceptance Criteria`).
- TypeScript, C#, bash: zero changed files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 5 production (plus 5 bundle copies), 7 test files | 290 touched-suite tests (review re-run at HEAD); 13949 full single-process tests (executor) | PASS for every suite the branch adds or changes: 290 pass, 0 fail (review); full single-process run 13530 pass, 409 fail, all failures pre-existing and outside the diff (see Section 8) | 92.61% repo-wide LINE (21594/1724) and `Invoke-ParallelAdmission.ps1` 96.44% per `evidence/remediation-baseline/pester-coverage-baseline.2026-11-03T21-26.md` | 92.61% repo-wide LINE (21596 covered, 1724 missed), read by this review from `artifacts/pester/powershell-coverage.xml` | 100.00% (ParallelAdmission.psm1), 100.00% (ParallelAdmissionPrecedence.psm1), 100.00% (ParallelAdmissionJson.psm1), 96.48% (Invoke-ParallelAdmission.ps1), helpers file 100.00% |
| Python | 1 test-support file under `tests/` | full suite 16063 passed, 6 skipped (executor, cycle 1, `-n auto --cov --cov-branch`); contract set 419 passed (cycle 2) | PASS | 96.67% line, 93.64% branch per `evidence/remediation-baseline/python-coverage-baseline.2026-11-03T19-32.md` | 96.67% line (LH 32257 / LF 33367), 93.64% branch (BRH 11720 / BRF 12516), read by this review from `artifacts/python/lcov.info` | N/A - no production Python changed; `tests/*` is omitted from measurement by `[tool.coverage.run] omit` |
| JSON | 8 files | contract tests | PASS (push-down and manifest contract tests in the contract set) | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- PowerShell baseline coverage artifact: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/remediation-baseline/pester-coverage-baseline.2026-11-03T21-26.md` (cycle 2 baseline; carries the cycle 1 final figures after a hash match of the script)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` is present (JaCoCo, written 2026-11-03 21:51 UTC by the cycle 2 full-scan run); this review parsed it directly and mapped its missed line numbers onto the committed HEAD content.
- Python baseline coverage artifact: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/evidence/remediation-baseline/python-coverage-baseline.2026-11-03T19-32.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` is present (written 2026-11-03 20:40 UTC); no Python file, coverage configuration, or `pyproject.toml` changed after it was written, so it still describes the branch head. This review summed its LF, LH, BRF, and BRH records.
- Per-language comparison summary: section 1.2.1 below.

---

## Executive Summary

Cycle 2 (commit `22af34134`) delivered the two Minor findings the orchestrator brought in from `code-review.2026-11-03T21-04.md`:

- N1: `Get-ParallelAdmissionUsageError` now rejects a non-empty `-Branch`, `-Main`, or `-Ref` value that begins with `-` (exit 2, message naming the option and the value). Three usage-error rows were added to the parametrized CLI test, which now covers both `assess` and `reuse-edges`.
- N2: the `## Implementation Strategy` section of `spec.md` names `ParallelAdmissionJson.psm1`; no `## Acceptance Criteria` line changed.

The review read both canonical coverage artifacts directly. PowerShell repo-wide LINE coverage is 92.61%, and every branch production file is at or above 96.48%. The eight missed lines of `Invoke-ParallelAdmission.ps1` (73, 74, 86, 328, 618, 622-624) map to the committed HEAD content (the real git call, the real file read, one defensive return, and the guarded entry body); the cycle 1 numbers shifted by four lines, matching the four added lines. The worktree is clean, so the artifact describes the branch head. Python repo-wide coverage is 96.67% line and 93.64% branch, unchanged.

The review re-ran the touched Pester suites plus `ClaudeLibModuleConvention.Tests.ps1` and `FileSizePolicy.RepoGate.Tests.ps1` on Linux at HEAD (290/290), ran PSScriptAnalyzer and `Invoke-Formatter` over the 17 changed PowerShell files (0 findings, 0 differences), compared 12 primary and bundle pairs (all byte-equal), and invoked the real CLI with option-shaped ref values (exit 2 with the new message) and with a valid ref (exit 0).

The executor's full-tree Pester run on this Linux host reports 409 failures in suites the branch does not add or change; the 97 distinct failure lines are identical to the cycle 1 run, which the previous review found pre-existing at the merge base. Section 8 records the assessment: non-blocking, with `windows-latest` CI authoritative at S9.

Result: zero blocking findings. Verdict PASS.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (mirrored by `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (mirrored by `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists on the base; `.claude/lib/parallel-admission` is classified T3)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (test-support module only)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no bash file changed
- ✅ JSON: strict JSON confirmed by contract tests

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; executor helper scripts ran from the session scratchpad and are not in the diff. The review's probe scripts ran from its own scratchpad.
- ✅ No new ongoing tooling script outside the delivered helper.

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The audit covers the full branch diff against the merge base `01706c697f3ad4a53b4a771d99d851afc7417ea9` (168 files).

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0 with no reported path.
- The branch diff contains no path under `artifacts/` at all, and therefore none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All cycle 2 evidence records are under `<FEATURE>/evidence/<kind>/`.
- Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Seeded shuffled file-order runs with seeds 11, 23, 47 (217 tests each, 0 failures, executed order equals seeded order, `evidence/regression-testing/pester-shuffle.2026-11-03T21-30.md`); cycle 1 reversed, serial, and `-n auto` pytest runs stand because no Python changed. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each parametrized row asserts one exit code and one exact usage line. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 290 touched Pester tests in 11.7 s in one review process. |
| **Determinism** - Consistent results | ✅ PASS | The new rows run before any git seam call; the usage error returns before dispatch. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | It name `exits 2 on <Subcommand> <Name> <Value>` expands to a readable row label. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** repo-wide 92.61%; `Invoke-ParallelAdmission.ps1` 96.44%; Python 96.67% line, 93.64% branch<br>**Command:** hash comparison plus carried figures (`pester-coverage-baseline.2026-11-03T21-26.md`)<br>**Timestamp:** 2026-11-03 21:26 |
| **No Coverage Regression** | ✅ PASS | Read from the canonical artifact: repo-wide 92.61% to 92.61% (21594 to 21596 covered, 1724 missed unchanged); `Invoke-ParallelAdmission.ps1` 96.44% to 96.48%; the two new executable lines (192-193) are covered. |
| **New Code Coverage (governing threshold 85% line)** | ✅ PASS | `ParallelAdmission.psm1` 100.00% (141/0), `ParallelAdmissionPrecedence.psm1` 100.00% (179/0), `ParallelAdmissionJson.psm1` 100.00% (55/0), `Invoke-ParallelAdmission.ps1` 96.48% (219/8), helpers 100.00% (97/0). |
| **Comprehensive Coverage** | ✅ PASS | Missed lines 73-74 (real git call), 86 (real file read), 328 (defensive return), 618 and 622-624 (guarded entry body). The review exercised the guarded entry body through `pwsh -File` (Section 2.5). |
| **Positive Flows** - Valid inputs | ✅ PASS | Existing `reuse-edges` and `assess` cases with valid refs still pass (81/81); the review's CLI call with `-Ref origin/main` returned exit 0. |
| **Negative Flows** - Invalid inputs | ✅ PASS | New rows: `assess -Branch --upload-pack=x`, `assess -Main --output=x`, `reuse-edges -Ref -p`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Empty values skip the check (`IsNullOrEmpty`); the comparison is ordinal. |
| **Error Handling** - Error paths | ✅ PASS | Exact message `-<name> must not begin with '-'; got '<value>'.` asserted with `-BeExactly`. |
| **Concurrency** - If applicable | N/A | Single-process CLI with no shared state. |
| **State Transitions** - If applicable | ✅ PASS | Unchanged from the previous review. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.61% repo-wide LINE -> Post-change: 92.61% repo-wide LINE. Change: +0.00% (21594 to 21596 covered, 1724 missed unchanged). New/changed-code coverage: 96.48% (Invoke-ParallelAdmission.ps1, the lowest branch production file; the other four are 100.00%). Branch threshold not applicable (Pester measures no branch coverage). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` parsed by this review; `evidence/qa-gates/pester-coverage.2026-11-03T21-51.md`; `evidence/remediation-baseline/pester-coverage-baseline.2026-11-03T21-26.md`.
- Python: Baseline: 96.67% line, 93.64% branch -> Post-change: 96.67% line, 93.64% branch. Change: +0.00% line, +0.00% branch. New/changed-code coverage: N/A - the only changed Python file is under `tests/`, which `[tool.coverage.run] omit` excludes. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (LF 33367, LH 32257, BRF 12516, BRH 11720) summed by this review; `evidence/qa-gates/python-coverage.2026-11-03T20-40.md`.
- TypeScript: zero changed files. Disposition: N/A.
- C#: zero changed files. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-BeExactly` on the full usage line, including the prefix. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Row data arranges; one CLI call acts; two assertions follow. |
| **Document Intent** | ✅ PASS | Production comment on line 191 states why the check exists. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The new rows return before any git call; no live git, network, or GitHub call in any suite. |
| **Use Mocks/Stubs** | ✅ PASS | Seams mocked: git, JSON file read, clock. |
| **Environment Stability** | ✅ PASS | The cycle 2 test diff adds no file write, temporary path, or environment mutation. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, `code-review.2026-11-03T21-58.md`, and `feature-audit.2026-11-03T21-58.md` form the review set. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-11-03T21-16.md` items N1 and N2. |
| **Read existing change plans** | ✅ PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-03T21-25.md`. |
| **Document the plan** | ✅ PASS | `remediation-plan.2026-11-03T21-16.md` with preflight fixes `evidence/other/preflight-fixes.2026-11-03T21-24.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One three-line loop over the three ref-shaped option names. |
| **Reusability** | ✅ PASS | Placed in the existing single validation function used by every subcommand. |
| **Extensibility** | ✅ PASS | Another ref option is added by extending the name list. |
| **Separation of concerns** | ✅ PASS | Validation stays in `Get-ParallelAdmissionUsageError`; seams unchanged. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Unchanged module split. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical lines (`@(Get-Content -LiteralPath).Count`, review): `Invoke-ParallelAdmission.ps1` 625, `ParallelAdmission.psm1` 508, `ParallelAdmissionPrecedence.psm1` 508, `ParallelAdmissionJson.psm1` 141, `enforce-parallel-cohort-barrier-helpers.ps1` 344, `Invoke-ParallelAdmission.Tests.ps1` 695, `enforce-parallel-cohort-barrier.Tests.ps1` 537, `ParallelAdmission.Tests.ps1` 418, `ParallelAdmissionPrecedence.Tests.ps1` 392, `Invoke-ParallelAdmission.Integration.Tests.ps1` 229, `ParallelAdmissionJson.Tests.ps1` 129, `ParallelAdmission.Manifest.Tests.ps1` 81, `parallel_orchestrator_surface_expectations.py` 421; bundle copies equal their primaries. No file is at or above 700 lines; `config/file-size-baseline.json` is not in the diff. `FileSizePolicy.RepoGate.Tests.ps1` 5/5 at HEAD. |
| **Public vs internal** | ✅ PASS | Export lists unchanged. |
| **No circular dependencies** | ✅ PASS | Import graph unchanged in cycle 2. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | No new function. |
| **Docs/docstrings** | ✅ PASS | `spec.md` `## Implementation Strategy` now lists all four helper files (N2). |
| **Comment why, not what** | ✅ PASS | Line 191: a ref value is passed to git as a bare argument, so a leading `-` would be read as a git option. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter -ScriptDefinition` with `pssa.settings.psd1` over 17 changed PowerShell files (review)<br>**Result:** 0 differences (review); `poshqc-format.2026-11-03T21-28.md` |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over 17 files (review)<br>**Result:** 0 findings (review); `poshqc-analyze.2026-11-03T21-28.md` |
| **3. Type checking** | ✅ PASS | No Python change since cycle 1 (`pyright-final.2026-11-03T20-31.md` stands); N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** review re-run of the touched suites plus module-convention and file-size suites (290/290); executor targeted run 228/228 (`pester-targeted.2026-11-03T21-29.md`); contract set 419 passed (`pytest-contracts.2026-11-03T21-52.md`)<br>**Result:** every suite the branch adds or changes passes. The full-tree Linux run carries pre-existing host failures outside the diff (Section 8, non-blocking). |
| **Full toolchain loop** | ✅ PASS | One loop pass, clean on every stage. |
| **Explicit reporting** | ✅ PASS | Every gate has a timestamped evidence file with command and exit code. |

Review probe of the real CLI (`pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`), run read-only against the item worktree: `reuse-edges -Slug no-such-run-xyz -IssueNum 1047 -PlanHash abc -Ref:-p` exited 2 with `parallel admission usage error: -Ref must not begin with '-'; got '-p'.`; `-Ref --output=x` exited 2 with the matching message; `assess -Branch:--upload-pack=x -FeatureFolder docs/x` exited 2 with `-Branch must not begin with '-'; got '--upload-pack=x'.`; `-Ref origin/main` exited 0 with `{action: recompute, edges: [], reason: record_missing}`. A bare `-Ref -p` is rejected earlier by the PowerShell parameter binder (ambiguous parameter name), exit 1.

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `22af34134`; self-review `evidence/qa-gates/self-review.2026-11-03T21-53.md` (no FAIL row). |
| **Design choices explained** | ✅ PASS | `remediation-plan.2026-11-03T21-16.md`. |
| **Update supporting documents** | ✅ PASS | `spec.md` design bullet; bundle copy of the script. |
| **Provide next steps** | ✅ PASS | CI-dependent criterion S14 named in `self-review.2026-11-03T21-53.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`<br>**Result:** exit 0 (`black-final.2026-11-03T20-31.md`; file unchanged since) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check <same file>`<br>**Result:** exit 0 |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright <same file>`<br>**Result:** exit 0 |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -p no:cacheprovider -q <27 contract modules>`<br>**Result:** 419 passed (cycle 2); full suite 16063 passed in cycle 1 |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Constants annotated `tuple[str, ...]`; no Python change in cycles 1 or 2. |
| **Dataclasses for value objects** | N/A | No value object added. |
| **Protocols/ABCs for interfaces** | N/A | No interface added. |
| **Avoid utility classes** | ✅ PASS | Module-level constants only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No executable logic added. |
| **Logging over print** | N/A | No executable logic added. |
| **Invariants at construction** | N/A | No class added. |

Repository rule check: `git diff --name-only 01706c697 HEAD -- '*.py' pyproject.toml config` lists only `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, last changed in `519686b6a`, before the Python artifact was written. No Python leg in any hook. PASS.

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter -ScriptDefinition` with `pssa.settings.psd1`<br>**Result:** 0 differences over 17 files (review) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings over 17 files (review) |
| **Fix all findings** | ✅ PASS | No open finding. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | `String.StartsWith(string, StringComparison)` exists in both .NET Framework and .NET; the helper remains pwsh-only by design. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Unchanged. |
| **Parameter validation** | ✅ PASS | `-Branch`, `-Main`, and `-Ref` now reject a leading `-` (N1). The receipt-supplied `base_commit` is not format-checked; see the Minor finding in the code review. |
| **Avoid global state** | ✅ PASS | Script-scoped constants only. |
| **Error handling** | ✅ PASS | Usage errors exit 2 before any git call. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest production file 625 logical lines; largest test file 695. |
| **Approved verbs** | ✅ PASS | No new function. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `poshqc-format.2026-11-03T21-28.md`; review re-check |
| **Step 2: Analyze** | ✅ PASS | `poshqc-analyze.2026-11-03T21-28.md`; review re-check |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `pester-targeted.2026-11-03T21-29.md`; review re-run 290/290 |
| **Rerun loop if needed** | ✅ PASS | One pass, clean. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | No JSON change in cycle 2; contract tests pass. |
| **Schema validation** | ✅ PASS | Fixtures unchanged since the initial delivery. |
| **Required $schema** | N/A | The changed JSON files are not `$schema`-governed. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Parsed by `System.Text.Json` and by the Python contract tests. |
| **Deterministic key order** | ✅ PASS | Unchanged. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | The pins are consumed by `test_parallel_orchestrator_surface_contracts.py`. |
| **Coverage expectation** | ✅ PASS | `artifacts/python/lcov.info` present; repo-wide 96.67% line and 93.64% branch. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Two parametrized obligation cases. |
| **Mocking sparingly** | ✅ PASS | No mock added. |
| **Organization** | ✅ PASS | Pins beside existing fragment tuples. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `KICKOFF_PLAN_HASH_FRAGMENTS`, `MERGE_ON_GREEN_TURN_GAP_FRAGMENTS`. |
| **Docstrings/comments** | ✅ PASS | Issue-referenced comments. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -p no:cacheprovider -q <27 contract modules>`<br>**Result:** 419 passed, exit 0 (`pytest-contracts.2026-11-03T21-52.md`) |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester 5.9.1. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>`config/poshqc-coverage.json` not in the branch diff. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | See 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 56 / 51 / 81 / 12 / 12 / 5 tests across the six admission suites; 62 in the hook suite. |
| **Test Behavior Over Implementation** | ✅ PASS | The new rows assert exit code and stderr only. |
| **Mocking Used Sparingly** | ✅ PASS | Only the I/O seams are mocked. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-lib/parallel-admission/*.Tests.ps1`<br>**Code files:** `.claude/lib/parallel-admission/*`<br>Mirrors the production layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | The rows sit in `Describe 'Usage errors'`. |
| **Logical Grouping** | ✅ PASS | Usage rows grouped in one parametrized It. |
| **Docstrings/Comments** | ✅ PASS | Suite header comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts`<br>**Result:** coverage artifact written; branch suites pass (full-tree host failures in Section 8) |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC; the review re-run used `Invoke-Pester` with coverage disabled so the canonical artifact was not overwritten. |

---

## 5. Test Coverage Detail

### Invoke-ParallelAdmission.ps1 (81 unit + 12 integration tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| exits 2 on assess -Branch / assess -Main / reuse-edges -Ref (new in cycle 2) | Negative | 191-194 | ✅ |
| exits 2 on reuse-edges -IssueNum / -Slug (existing rows, now parametrized by subcommand) | Negative | 176-217 | ✅ |
| reuse-edges and assess with valid refs | Positive | 290-295, 380-440, 545-602 | ✅ |

**Coverage:** 96.48% (219/227), read from the artifact.

**Not covered:** lines 73-74 (real git call), 86 (real file read), 328 (defensive return in `Get-ParallelAdmissionPlannerItem`), 618, 622-624 (guarded entry body).

### ParallelAdmission.psm1, ParallelAdmissionPrecedence.psm1, ParallelAdmissionJson.psm1, enforce-parallel-cohort-barrier-helpers.ps1

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Unchanged in cycle 2; suites 56, 51, 12, and 62 tests | Positive / Negative / Edge Case | all executable lines | ✅ |

**Coverage:** 100.00% (141/141), 100.00% (179/179), 100.00% (55/55), 100.00% (97/97), read from the artifact.

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 290 touched Pester including module-convention and file-size suites (review); 13949 Pester full (executor); 419 pytest contract set (executor) | ✅ |
| Tests Passed | 290 (100%); 13530 of 13949 full-tree on this Linux host; 419 (100%) | ✅ |
| Tests Failed | 0 in branch suites; 409 full-tree single-process, all pre-existing host failures outside the diff | ⚠️ non-blocking |
| Execution Time | 11.7 s touched Pester (review); 5.81 s contract set | ✅ Fast |
| Average Time per Test | not measured by the review | N/A |
| Discovery Time | not measured by the review | N/A |
| Functions/Classes Tested | every exported function and every subcommand | ✅ |
| Test File Size | largest 695 logical lines | ✅ PASS |
| Code Coverage (if applicable) | PowerShell 92.61% repo-wide; Python 96.67% line, 93.64% branch | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <py>` | exit 0 (cycle 1; file unchanged) | ✅ |
| Ruff Linting | `poetry run ruff check <py>` | exit 0 (cycle 1; file unchanged) | ✅ |
| Pyright Type Checking | `poetry run pyright <py>` | exit 0 (cycle 1; file unchanged) | ✅ |
| Pytest Tests | `poetry run pytest <contract set>` | 419 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` with `pssa.settings.psd1` | 0 differences (review) | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` | 0 findings (review) | ✅ |
| Pester Tests | `Invoke-Pester` touched suites (review) | 290 pass | ✅ |

**Notes:** Mirrors: 12 primary and bundle pairs compared with `cmp -s` by the review, all byte-equal, including the cycle 2 script; `ParallelAdmission.Manifest.Tests.ps1` 5/5.

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap.

Non-blocking observation (assessed per the caller's request): full-tree Pester failures on this Linux host.

- Evidence: `evidence/qa-gates/pester-coverage.2026-11-03T21-51.md` (cycle 2 single process, 13949 tests, 409 failed, 97 distinct failure lines, normalized diff against the cycle 1 final run empty, 0 failure lines naming a parallel-admission, module-convention, or file-size suite); `evidence/regression-testing/pester-full.2026-11-03T20-57.md` and `pester-parallel-shards.2026-11-03T20-39.md` (cycle 1); `policy-audit.2026-11-03T21-04.md` Section 8 (merge-base comparison of the 17 failing sharded suites).
- Attribution checks performed by this review at HEAD `22af34134`: (1) `git diff --name-only 01706c697 HEAD -- tests/scripts/dev-tools scripts/dev-tools tests/scripts/powershell scripts/powershell scripts/dev_tools config` is empty; (2) the PATH-leak source exists at the merge base: `tests/scripts/dev-tools/run-actionlint.Tests.ps1` line 497 assigns `$env:PATH = '/existing'`; (3) every suite the branch adds or changes passes in the review re-run (290/290); (4) cycle 2 changed only one validation loop in the CLI, three test rows, and one spec line, none of which any failing suite imports.
- Assessment: the failure set is unchanged from cycle 1, where it was shown to be pre-existing at the merge base (Windows-host fixtures plus order-dependent victims of the PATH leak). None is attributable to this branch. The authoritative host for these suites is `windows-latest` (`.github/workflows/_poshqc.yml` shard jobs); the CI green gate at S9 reports that result.
- Classification: not a review finding against this branch. If CI on `windows-latest` failed in these suites, the condition would be awaiting CI, not autonomous remediation in this item. The PATH leak is a pre-existing test-isolation defect in an unrelated suite and should be filed separately.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **ee983c672** through **49c54e3de** - initial delivery, QA loop, main merges, review evidence, and cycle 1 (listed in `policy-audit.2026-11-03T21-04.md` Section 9)
2. **64e8cfe91** - docs(1047): record the cycle 1 re-audit (verdict PASS)
3. **278166698** - docs(1047): open remediation cycle 2 for the two Minor re-audit findings
4. **17193681c** - docs(1047): add the remediation plan for cycle 2
5. **22af34134** - fix(parallel-admission): reject option-shaped ref arguments

### Files Modified

1. **`.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`** (MODIFIED in cycle 2) - leading-dash check for `-Branch`, `-Main`, `-Ref`.
2. **`extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`** - byte-equal copy.
3. **`tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1`** (MODIFIED in cycle 2) - parametrized usage It takes a subcommand; three rows added.
4. **`docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/spec.md`** (MODIFIED in cycle 2) - implementation-strategy bullet names `ParallelAdmissionJson.psm1`.
5. Earlier files are unchanged in cycle 2 and described in the previous policy audits.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

Code, tests, mirrors, scope, and coverage comply. Both cycle 2 items are delivered and verified by the review. The full-tree Linux host failures are pre-existing and outside the diff (non-blocking, Section 8).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation plan and preflight fixes recorded
- ✅ Design Principles: one validation loop in the existing function
- ✅ Module & File Structure: largest production file 625 lines
- ✅ Naming, Docs, Comments: why-comment and spec design bullet
- ✅ Toolchain Execution: one clean loop pass
- ✅ Summarize & Document: commit and self-review

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: no Python change since the initial delivery; tools clean
- ✅ Python Design & Typing: annotated constants only
- ✅ Error Handling: N/A (no logic)

**For PowerShell:**
- ✅ Tooling & Baseline: formatter and analyzer clean (review re-check)
- ✅ PowerShell Design & Safety: ref options validated
- ✅ Structure & Naming: unchanged
- ✅ Toolchain: branch suites pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: seeded shuffle runs passed
- ✅ Coverage & Scenarios: canonical artifacts present and above thresholds
- ✅ Test Structure: AAA and exact assertions
- ✅ External Dependencies: seams mocked, no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest; coverage 96.67% line, 93.64% branch
- ✅ Test Style & Structure: parametrized obligation cases
- ✅ Naming & Readability: issue-referenced comments
- ✅ Toolchain: contract set passes

**For PowerShell:**
- ✅ Framework & Scope: Pester 5.9.1 through PoshQC
- ✅ Test Style & Structure: seam mocks only
- ✅ Naming & Readability: `*.Tests.ps1`, Describe per function
- ✅ Toolchain: 290 touched tests passing at HEAD

---

### Metrics Summary

- ✅ 290/290 touched Pester tests passing on Linux at HEAD (review re-run, includes 5/5 file-size gate and 6/6 module convention)
- ✅ 419 pytest contract tests passing (executor, cycle 2)
- ✅ Coverage: PowerShell 92.61% repo-wide, branch files 96.48% to 100.00%; Python 96.67% line, 93.64% branch
- ✅ Proper file organization: tests mirror `.claude/lib/` under `tests/scripts/claude-lib/`
- ✅ All static quality checks passing

---

### Recommendation

**Ready for PR**

Proceed to the PR creation gate. At the CI green gate, confirm the `windows-latest` PoshQC shards and the `poshqc / PowerShell hook suites (Linux)` job, then check off spec criterion S14.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1` - 56 tests
- `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1` - 51 tests
- `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1` - 12 tests
- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` - 81 tests (3 usage rows added in cycle 2)
- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1` - 12 tests
- `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1` - 5 tests
- `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` - 62 tests
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` - two parametrized obligation cases from the fragment pins

---

## Appendix B: Toolchain Commands Reference

Commands run by this review (check-only):

```bash
git -C <worktree> diff --stat 01706c697f3ad4a53b4a771d99d851afc7417ea9 HEAD
git -C <worktree> diff 64e8cfe91 HEAD -- .claude <FEATURE>/spec.md tests/scripts
git -C <worktree> show HEAD:.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1   # missed-line mapping
cmp -s <primary> extensions/drm-copilot/resources/claude-customizations/<primary>   # 12 pairs
poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
awk '/^LF:/{...} /^LH:/{...} /^BRF:/{...} /^BRH:/{...}' artifacts/python/lcov.info
python3 -I <scratch>/cov.py artifacts/pester/powershell-coverage.xml <five files>    # JaCoCo LINE counters and missed lines
pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 reuse-edges ... -Ref:-p
```

```powershell
$c = New-PesterConfiguration
$c.Run.Path = @('tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1', 'tests/scripts/claude-lib/parallel-admission', 'tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1', 'tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1')
$c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $false; $c.Run.PassThru = $true
Invoke-Pester -Configuration $c
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
@(Get-Content -LiteralPath <file>).Count
```

Commands recorded by the executor and inspected by this review:

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-03
**Policy Version:** Current (as of audit date)
