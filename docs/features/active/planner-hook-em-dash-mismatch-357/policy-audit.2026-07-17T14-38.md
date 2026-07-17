# Policy Compliance Audit: planner-hook-em-dash-mismatch-357 (Issue #357)

**Audit Date:** 2026-07-17
**Code Under Test:** `.claude/hooks/validate-planner-output.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`
**Base branch:** `main` (origin/main @ 070b1aaba8c4c312afacf52b75b18050532abe81); merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`
**Head branch:** `drm-copilot-wt-2026-07-17T10-05` @ `f3e159043895305b4d10954aa06162261ba989ef`
**Work Mode:** `minor-audit` (AC source: `issue.md` `## Acceptance Criteria` section only)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 files (1 production, 1 test) | 7 tests | ✅ 7/7 pass, 0 fail | 69.87% lines (109/156 commands), branch not emitted by tooling | 69.87% lines (109/156 commands), branch not emitted by tooling | N/A — no new files; both are modified files |
| Python | 0 files | N/A | N/A | N/A | N/A | N/A |
| TypeScript | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/baseline/poshqc-test-baseline.md` (ad hoc `Invoke-Pester -CodeCoverage` measurement; canonical `artifacts/pester/powershell-coverage.xml` does not include `.claude/hooks/validate-planner-output.ps1` in its `CodeCoverage.Path` allowlist)
- PowerShell post-change coverage artifact: `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/poshqc-test-final.md` and `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/coverage-delta.md`
- Canonical repo coverage artifact inspected directly by this audit: `artifacts/pester/powershell-coverage.xml` (generated 2026-07-17 10:29:57 local) — confirmed by direct XML inspection that no `<class>`/`<sourcefile>` entry for `validate-planner-output.ps1` exists in this file, and that the report-level `LINE` counter (`missed=1954`, `covered=0`) reflects a scoped single-test-file Pester invocation, not a true repo-wide run
- Per-language comparison summary: see `## Coverage Compliance Finding` below

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope. This audit reports those metrics; the metrics show a policy violation (see below), so the overall verdict is **PARTIALLY COMPLIANT**, not PASS.

---

## Rejected Scope Narrowing

None detected. The delegating prompt for this review did not attempt to narrow the audit to a plan/task/phase subset, did not mark any language's coverage as out-of-scope or informational-only, and did not instruct skipping a toolchain or coverage check. The audit below therefore covers the full branch diff (`67c871eb..HEAD`) against the resolved base branch.

Separately, the feature's own execution evidence (`docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/poshqc-test-final.md` and `coverage-delta.md`) states that expanding `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`'s `CodeCoverage.Path` allowlist to include `.claude/hooks/validate-planner-output.ps1` was treated as "out of scope for this plan's 2-file change budget." That is a plan-authoring decision by the executed feature, not a caller instruction to this reviewer, and it is not accepted as a basis for suppressing the coverage finding below — the coverage gate is evaluated against the full uniform threshold in `.claude/rules/quality-tiers.md` regardless of the plan's declared change budget.

---

## Executive Summary

This review covers a minor-audit bugfix: `.claude/hooks/validate-planner-output.ps1`'s `$phasePattern` regex and error-message text were changed from requiring an ASCII hyphen (`### Phase N - <Title>`) to requiring the canonical em dash (`### Phase N — <Title>`, U+2014), matching the atomic-plan-contract and the two other canonical structural validators. `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` fixtures were updated to em dash and one new regression test (`allows termination when phase headings use the canonical em dash (U+2014)`) was added. All format, lint, and functional-test toolchain stages pass cleanly in the final state. The one substantive compliance gap is coverage: the modified production file's line coverage (69.87%) is below the repository's uniform 85%/75% (line/branch) threshold and below the 80% modified-file remediation-trigger floor, and the canonical PowerShell coverage artifact (`artifacts/pester/powershell-coverage.xml`) does not measure this file at all.

**Policy documents evaluated:**
- ✅ `.github/instructions/general-code-change.instructions.md` / `.claude/rules/general-code-change.md`
- ✅ `.github/instructions/general-unit-test.instructions.md` / `.claude/rules/general-unit-test.md`

**Language-specific policies evaluated:**
- N/A Python (no Python files changed)
- ✅ PowerShell: `.claude/rules/powershell.md` (functional toolchain PASS, coverage threshold FAIL)
- N/A TypeScript (no TypeScript files changed)
- N/A C# (no C# files changed)

**Temporary artifacts cleanup:**
- ✅ No temporary/one-time scripts were created during this change; the diff is limited to the two in-scope files plus feature-folder documentation/evidence.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | ✅ PASS | Each `It` block uses its own `Mock -CommandName Get-PlanFileContent` and independent fixture data; no shared mutable state between tests (`tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`). |
| Isolation | ✅ PASS | Each test targets one behavior of `Invoke-PlannerOutputValidation`/`Get-PlanStructureValidationReport` (empty input, missing preflight signal, missing plan file, missing Phase 0, missing explicit path, well-formed plan, em-dash plan). |
| Fast execution | ✅ PASS | 7 tests complete via in-process Pester run with mocked filesystem boundary (`Get-PlanFileContent`); no network or real filesystem I/O in the test body. |
| Determinism | ✅ PASS | No wall-clock, RNG, or sleep usage; all inputs are literal fixture strings. |
| Readability & maintainability | ⚠️ PARTIAL | See code-review finding: the new `It 'allows termination when phase headings use the canonical em dash (U+2014)'` (lines 107–128) is now a byte-for-byte duplicate of the pre-existing `It 'allows termination when the plan satisfies the structural contract'` (lines 84–105), because P2-T4 updated the older fixture to em dash as well. The regression intent (fail-before/pass-after) was captured correctly in evidence, but the merged test suite carries a redundant test case. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | `evidence/baseline/poshqc-test-baseline.md`: 69.87% line/command coverage (109/156), branch coverage not emitted by Pester 5.6.1's coverage engine, captured 2026-07-17T10:18 local. |
| No coverage regression | ✅ PASS (no regression) / ❌ FAIL (absolute threshold) | `evidence/qa-gates/coverage-delta.md`: line coverage unchanged at 69.87% (0.00 pp delta), identical 47 uncovered line set before/after. No regression occurred, but the absolute level remains below both the 85% uniform-tier requirement (`.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`) and the 80% modified-file remediation-trigger floor. See `## Coverage Compliance Finding` below. |
| New code coverage >= 90% | N/A | No new files were added in this change; both changed files are modified pre-existing files. |
| Comprehensive coverage | ⚠️ PARTIAL | Line 121 (`$phasePattern`) is exercised (unconditional assignment). Line 137 (fixed error-message text) remains uncovered before and after the change — no fixture exercises the malformed-phase-heading error branch, per `evidence/qa-gates/coverage-delta.md`. |
| Positive flows | ✅ PASS | `allows termination when the plan satisfies the structural contract`, `allows termination when phase headings use the canonical em dash (U+2014)`. |
| Negative flows | ✅ PASS | `blocks when CLAUDE_HOOK_INPUT is empty`, `blocks when the output is missing an exact preflight signal`, `blocks when the advertised plan-path does not exist on disk`, `blocks when Phase 0 baseline and policy-read tasks are missing`, `blocks when a task omits an explicit path`. |
| Edge cases | ⚠️ PARTIAL | No test targets the malformed-phase-heading error branch (line 137) specifically; only the "missing Phase 0"/"missing explicit path" edge cases are covered. |
| Error handling | ✅ PASS | JSON-parse failure and empty-payload paths are exercised in `Invoke-PlannerOutputValidation`. |
| Concurrency | N/A | Hook is single-invocation, synchronous; no concurrency surface. |
| State transitions | N/A | No stateful component in scope. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline 69.87% lines (109/156 commands) -> Post-change 69.87% lines (109/156 commands). Change: 0.00 pp. New/changed-code coverage: N/A (modified file only; changed lines 17, 121, 137 — line 121 covered both before/after, line 137 uncovered both before/after, line 17 is a non-executable docstring). Disposition: **FAIL** (absolute level below the uniform 85% line / 75% branch threshold, and below the 80% modified-file remediation floor; also not present in the canonical `artifacts/pester/powershell-coverage.xml` allowlist). Evidence: `evidence/baseline/poshqc-test-baseline.md`, `evidence/qa-gates/poshqc-test-final.md`, `evidence/qa-gates/coverage-delta.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear failure messages | ✅ PASS | `Should -BeTrue`/`Should -BeFalse`/`Should -Match` assertions with specific regex patterns per test (e.g. `Should -Match 'PREFLIGHT: ALL CLEAR'`). |
| Arrange-Act-Assert | ✅ PASS | Each `It` mocks the boundary (Arrange), calls `Invoke-PlannerOutputValidation` (Act), and asserts on `$result` (Assert). |
| Document intent | ✅ PASS | Test names are descriptive full sentences (e.g. `allows termination when phase headings use the canonical em dash (U+2014)`). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid external dependencies | ✅ PASS | No network, database, or external process calls in the test file. |
| Use mocks/stubs | ✅ PASS | `Get-PlanFileContent` (the filesystem boundary) is mocked in every structural-validation test, consistent with the hook's `.NOTES` design intent ("Filesystem reads go through Get-PlanFileContent so tests can mock the boundary without writing temporary files"). |
| Environment stability | ✅ PASS | No temporary files created or referenced by the test suite; confirmed via diff inspection. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission review | ✅ PASS | This document constitutes the required pre-submission policy review for issue #357. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | ✅ PASS | `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md` states the problem, implementation intent, and acceptance criteria against issue #357. |
| Read existing change plans | ✅ PASS | `evidence/baseline/phase0-instructions-read.md` records the read order (CLAUDE.md, general-code-change.md, general-unit-test.md, powershell.md) at 2026-07-17T14-17. |
| Document the plan | ✅ PASS | `docs/features/active/planner-hook-em-dash-mismatch-357/plan.2026-07-17T10-11.md` documents Phase 0–3 with all tasks checked off. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | The fix is a minimal two-line regex/message change plus a docstring update; no new abstractions introduced. |
| Reusability | N/A | No new reusable logic introduced; existing `Get-PlanStructureValidationReport` function reused as-is. |
| Extensibility | N/A | Not applicable to a targeted regex fix. |
| Separation of concerns | ✅ PASS | The fix stays within the existing `Get-PlanStructureValidationReport` function; no new I/O or cross-cutting concerns introduced. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | ✅ PASS | Single-purpose hook script unchanged in structure. |
| Under 500 lines | ✅ PASS | `.claude/hooks/validate-planner-output.ps1`: 288 lines. `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`: 130 lines. Both well under the 500-line limit. |
| Public vs internal | N/A | Script-scoped functions only; no public API surface change. |
| No circular dependencies | ✅ PASS | No new dependency edges introduced. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | ✅ PASS | No naming changes; existing names (`Get-PlanStructureValidationReport`, `Invoke-PlannerOutputValidation`) are unchanged and descriptive. |
| Docs/docstrings | ✅ PASS | `.DESCRIPTION` comment-based help updated (line 17) to reference the corrected em-dash heading form, keeping documentation consistent with the enforced regex. |
| Comment why, not what | N/A | No new comments added beyond the docstring correction. |

### 2.5 After Making Changes — Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| 1. Formatting | ✅ PASS | `mcp__drm-copilot__run_poshqc_format`, baseline exit 0 (`evidence/baseline/poshqc-format-baseline.md`), final exit 0 after a BOM-add restart (`evidence/qa-gates/poshqc-format-final.md`). |
| 2. Linting | ✅ PASS | `mcp__drm-copilot__run_poshqc_analyze`, baseline exit 0 (`evidence/baseline/poshqc-analyze-baseline.md`). Final run: first pass exit 1 (`PSUseBOMForUnicodeEncodedFile`), remediated by adding a UTF-8 BOM, restarted from format per the required-restart rule, second pass exit 0 (`evidence/qa-gates/poshqc-analyze-final.md`). |
| 3. Type checking | N/A | Not applicable for PowerShell per `.claude/rules/powershell.md`. |
| 4. Testing | ✅ PASS | `mcp__drm-copilot__run_poshqc_test`, 7/7 tests passing post-fix (`evidence/qa-gates/poshqc-test-final.md`). |
| Full toolchain loop | ✅ PASS | The loop correctly restarted from format when analyze surfaced the BOM warning after the em-dash edit, per `.claude/rules/general-code-change.md`'s "restart from step 1" rule; second pass completed clean. |
| Explicit reporting | ✅ PASS | Every command, exit code, and output summary is recorded in the `evidence/` artifacts with timestamps. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | ✅ PASS | `issue.md` and `plan.2026-07-17T10-11.md` document the change; commit `f3e15904` message: `fix(planner-hook): use em-dash in phase heading regex pattern for #357`. |
| Design choices explained | ✅ PASS | `issue.md` explains why the em dash is canonical (matches `atomic-plan-contract`, `atomic-planner` agent instructions, and both other structural validators). |
| Update supporting documents | ✅ PASS | `docs/features/potential/promoted/2026-07-17-planner-hook-em-dash-mismatch.md` (bug intake doc) is present and consistent with `issue.md`. |
| Provide next steps | ⚠️ PARTIAL | See `## Coverage Compliance Finding` and remediation-inputs artifact for the outstanding coverage gap that must be addressed before merge. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Invoke-Formatter | ✅ PASS | `evidence/qa-gates/poshqc-format-final.md`: exit 0, no diff after final pass. |
| Linting with PSScriptAnalyzer | ✅ PASS | `evidence/qa-gates/poshqc-analyze-final.md`: exit 0 on final pass, zero findings. |
| Fix all findings | ✅ PASS | The single `PSUseBOMForUnicodeEncodedFile` warning triggered by the new em-dash character was remediated by adding a UTF-8 BOM; confirmed by diff (`git diff` shows only the BOM byte added, no content change). |
| PowerShell 7+ compatible | ✅ PASS | No version-specific syntax introduced; `#Requires -Version 7.0` retained in the test file header. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| Advanced functions | N/A | No new functions added; existing `[CmdletBinding()]` functions unchanged in signature. |
| Parameter validation | N/A | No parameter changes. |
| Avoid global state | ✅ PASS | Fix is contained to local regex/string literals; no new script-scoped state. |
| Error handling | N/A | No error-handling logic changed; only the regex pattern and message text. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive and under 500 lines | ✅ PASS | 288 and 130 lines respectively. |
| Approved verbs | N/A | No new function names introduced. |
| Comment why | ✅ PASS | `.DESCRIPTION` block kept in sync with the enforced regex form. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| Step 1: Format | ✅ PASS | See 2.5 above. |
| Step 2: Analyze | ✅ PASS | See 2.5 above. |
| Step 3: Type check | N/A | Not applicable for PowerShell. |
| Step 4: Test | ✅ PASS | 7/7 tests passing. |
| Rerun loop if needed | ✅ PASS | One restart cycle (format -> analyze BOM finding -> format -> analyze clean) is documented and correctly executed. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pester v5.x | ✅ PASS | `Describe`/`Context`/`It` structure with `Mock -CommandName`, consistent with Pester 5.x idioms. |
| Use PoshQC configuration | ✅ PASS | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` used for the MCP-wrapped run; an ad hoc `Invoke-Pester -CodeCoverage` run was used in parallel specifically to measure `.claude/hooks/validate-planner-output.ps1`, which is outside the shared settings' `CodeCoverage.Path` allowlist. |
| PowerShell 7+ compatible | ✅ PASS | `#Requires -Version 7.0` header present. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Focused unit tests | ✅ PASS | Each `It` targets one branch of `Invoke-PlannerOutputValidation`/`Get-PlanStructureValidationReport`. |
| Test behavior over implementation | ✅ PASS | Assertions check `$result.Ok`/`$result.Message`, not internal implementation details. |
| Mocking used sparingly | ✅ PASS | Only the designated filesystem boundary (`Get-PlanFileContent`) is mocked. |
| Organization | ✅ PASS | Test file: `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`; code file: `.claude/hooks/validate-planner-output.ps1`. Structure mirrors `tests/scripts/claude-hooks/` <-> `.claude/hooks/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| File naming — `*.Tests.ps1` | ✅ PASS | `validate-planner-output.Tests.ps1`. |
| Describe/Context/It structure | ✅ PASS | 1 `Describe`, 2 `Context` blocks, 7 `It` blocks. |
| Logical grouping | ✅ PASS | `payload validation` and `plan structure validation` contexts group related tests. |
| Docstrings/comments | ⚠️ PARTIAL | See 1.1 duplicate-test finding — the new em-dash `It` name does not distinguish itself from the pre-existing "satisfies the structural contract" `It` once both fixtures use em dash. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use PoshQCTest command | ✅ PASS | `mcp__drm-copilot__run_poshqc_test` used at baseline and final. |
| No alternative test runners | ✅ PASS | Only Pester (via MCP wrapper and ad hoc `Invoke-Pester` for per-file coverage) is used. |

---

## 5. Test Coverage Detail

### `Get-PlanStructureValidationReport` / `Invoke-PlannerOutputValidation` (7 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| blocks when CLAUDE_HOOK_INPUT is empty | Negative | ✅ |
| blocks when the output is missing an exact preflight signal | Negative | ✅ |
| blocks when the advertised plan-path does not exist on disk | Negative | ✅ |
| blocks when Phase 0 baseline and policy-read tasks are missing | Edge case | ✅ |
| blocks when a task omits an explicit path | Edge case | ✅ |
| allows termination when the plan satisfies the structural contract | Positive | ✅ |
| allows termination when phase headings use the canonical em dash (U+2014) | Positive (regression, now duplicate of the row above) | ✅ |

**Coverage:** 69.87% of `.claude/hooks/validate-planner-output.ps1` (109/156 analyzed commands), unchanged from baseline. Branch coverage not measurable with the current Pester 5.6.1 coverage engine (no `BRANCH` counter type emitted), per `evidence/qa-gates/coverage-delta.md`.

**Not covered:** Line 137 (the fixed error-message text for malformed phase headings) — no fixture in this suite constructs a plan with a genuinely malformed `### Phase` heading (missing dash/em-dash entirely, or wrong format) that would exercise this specific error-message line. Lines 45–288 (partial list per `evidence/baseline/poshqc-test-baseline.md`) remain uncovered from baseline, unrelated to this change.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 7 | ✅ |
| Tests Passed | 7 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Functions/Classes Tested | 2/2 (`Get-PlanStructureValidationReport`, `Invoke-PlannerOutputValidation`) | ✅ |
| Test File Size | 130 lines | ✅ Maintainable |
| Code Coverage | 69.87% lines, branch not emitted by tooling | ❌ FAIL against 85%/75% uniform threshold |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | exit 0 (final) | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | exit 0 (final, after BOM remediation) | ✅ |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` | 7/7 pass | ✅ |

**Notes:** The one analyzer finding encountered (`PSUseBOMForUnicodeEncodedFile`) was a direct, expected consequence of introducing a literal em-dash character into a previously ASCII-only file, and was correctly remediated within the same toolchain loop per policy.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **Coverage Compliance Finding (Blocking).** `.claude/hooks/validate-planner-output.ps1` line coverage is 69.87% (109/156 commands), below both the uniform 85% line / 75% branch threshold defined in `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`, and below the 80% modified-file remediation-trigger floor used by this workflow's coverage-verification procedure. The canonical PowerShell coverage artifact, `artifacts/pester/powershell-coverage.xml`, does not include this file in its `CodeCoverage.Path` allowlist at all (confirmed by direct XML inspection — no `validate-planner-output.ps1` entry present), so the repository's canonical coverage gate cannot currently verify this file's coverage in the normal toolchain run. This is a pre-existing condition (coverage was identical at baseline, 69.87%, before this change), but the change touches this file's regex/message/docstring lines without bringing it into compliance, and the feature's own evidence acknowledges the gap without remediating it. **This is a FAIL finding requiring remediation** (see `remediation-inputs.2026-07-17T14-38.md`).
2. **Duplicate test (Minor).** After `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` P2-T4 updated the "satisfies the structural contract" fixture to use the em dash, the newly added "allows termination when phase headings use the canonical em dash (U+2014)" test (lines 107–128) became a byte-for-byte duplicate of it (lines 84–105). Both exercise the identical fixture and identical assertions. This does not violate any Blocking policy rule but is a maintainability/readability gap under `general-unit-test.md`'s "avoid copy-paste" and "readability and maintainability" principles. See code-review finding.
3. **Unfixed vendored copy (Informational).** `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` contains the same pre-fix ASCII-hyphen `$phasePattern` regex (confirmed via `grep`) and is not touched by this branch diff. This file was not in scope per `issue.md`'s explicit two-file change budget, so it is not a policy violation of this minor-audit's scope, but the same functional defect persists in this packaged/bundled resource copy of the hook wherever it is distributed. Recommend a follow-up issue to determine whether this resource copy is auto-synced from `.claude/hooks/` at build/release time or requires a manual parallel fix.

### Approved Exceptions

**None.** No exceptions have been granted for the coverage gap identified above.

### Removed/Skipped Tests

**None.** All planned tests (per `plan.2026-07-17T10-11.md`) were implemented.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **f3e15904** - `fix(planner-hook): use em-dash in phase heading regex pattern for #357`

### Files Modified

1. **`.claude/hooks/validate-planner-output.ps1`** (MODIFIED)
   - Line 17: `.DESCRIPTION` comment updated to reference the em-dash heading form.
   - Line 121: `$phasePattern` regex changed from ASCII hyphen to em dash (U+2014).
   - Line 137: phase-heading error message updated to reference the em-dash form.
   - UTF-8 BOM added (required by `PSUseBOMForUnicodeEncodedFile` after introducing a non-ASCII character).

2. **`tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`** (MODIFIED)
   - Three pre-existing fixtures updated from ASCII hyphen to em dash (U+2014).
   - One new `It` case added: `allows termination when phase headings use the canonical em dash (U+2014)`.

3. **13 documentation/evidence files** (NEW) — `issue.md`, `plan.2026-07-17T10-11.md`, `docs/features/potential/promoted/2026-07-17-planner-hook-em-dash-mismatch.md`, and 10 files under `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/`.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The functional fix is correct, minimal, and well-evidenced: the regex/message/docstring change matches the canonical em-dash contract, the toolchain (format/analyze/test) passes cleanly in its final state, and the required restart-on-file-change loop was correctly followed when the BOM finding surfaced. The blocking gap is coverage: the modified production file's line coverage (69.87%) is below the repository's uniform 85%/75% threshold and below the 80% modified-file remediation floor, and the canonical coverage artifact does not measure this file at all. This is a pre-existing condition not introduced by this change (no regression occurred), but it remains an open policy violation that must be remediated or explicitly excepted before this change can be marked fully compliant.

**Fail-closed reminder honored:** this audit does not report the coverage requirement as PASS or N/A; it reports FAIL with numeric evidence per section 5 and the Gaps section above.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: fully documented.
- ✅ Design Principles: minimal, simple fix.
- ✅ Module & File Structure: both files well under 500 lines.
- ✅ Naming, Docs, Comments: docstring kept in sync.
- ✅ Toolchain Execution: format/analyze/test all pass, restart loop correctly followed.
- ⚠️ Summarize & Document: documented, but outstanding coverage gap noted as next step.

#### Language-Specific Code Change Policy (Section 3 — PowerShell)
- ✅ Tooling & Baseline: format/analyze pass.
- ✅ PowerShell Design & Safety: no design changes beyond literal/regex fix.
- ✅ Structure & Naming: compliant.
- ✅ Toolchain: compliant, with one documented remediation cycle.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independence/isolation/speed/determinism all pass; readability has a minor duplicate-test finding.
- ❌ Coverage & Scenarios: coverage below threshold (69.87% < 85%/80%).
- ✅ Test Structure: AAA pattern, clear names.
- ✅ External Dependencies: properly mocked, no temp files.
- ✅ Policy Audit: this document satisfies the requirement.

#### Language-Specific Unit Test Policy (Section 4 — PowerShell)
- ✅ Framework & Scope: Pester v5.x, PoshQC config used.
- ✅ Test Style & Structure: focused, behavior-oriented.
- ⚠️ Naming & Readability: duplicate test naming/content issue noted.
- ✅ Toolchain: PoshQC-only, no alternative runners.

---

### Metrics Summary

- ✅ 7/7 tests passing (100%)
- ✅ 2/2 functions tested (100%)
- ❌ 69.87% line coverage (below 85% uniform threshold and 80% modified-file floor)
- ✅ Proper file organization (test mirrors production path)
- ✅ Format/lint checks passing in final state
- ✅ Fast test execution (in-process Pester run, mocked I/O)

---

### Recommendation

**Needs revision (coverage remediation required before merge).**

Next steps:
1. Bring `.claude/hooks/validate-planner-output.ps1` into the canonical `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` allowlist so the repository's canonical coverage artifact measures this file (this requires a change outside the currently declared 2-file budget; the change-budget constraint does not exempt the file from the coverage gate).
2. Add or extend a Pester test that exercises the malformed-phase-heading branch (line 137) to raise measured coverage and close the "not covered" gap identified in Section 5.
3. Re-run the full PowerShell toolchain (format -> analyze -> test with coverage) after the above changes and confirm line coverage >= 85% (branch coverage measurement is a known tooling limitation, not fixable within this change).
4. Consider deduplicating the newly added em-dash regression test against the pre-existing "satisfies the structural contract" test (Minor, non-blocking).

See `remediation-inputs.2026-07-17T14-38.md` for the structured remediation trigger list.

---

## Appendix A: Test Inventory

1. `validate-planner-output.ps1` › `payload validation` › `blocks when CLAUDE_HOOK_INPUT is empty`
2. `validate-planner-output.ps1` › `payload validation` › `blocks when the output is missing an exact preflight signal`
3. `validate-planner-output.ps1` › `plan structure validation` › `blocks when the advertised plan-path does not exist on disk`
4. `validate-planner-output.ps1` › `plan structure validation` › `blocks when Phase 0 baseline and policy-read tasks are missing`
5. `validate-planner-output.ps1` › `plan structure validation` › `blocks when a task omits an explicit path`
6. `validate-planner-output.ps1` › `plan structure validation` › `allows termination when the plan satisfies the structural contract`
7. `validate-planner-output.ps1` › `plan structure validation` › `allows termination when phase headings use the canonical em dash (U+2014)`

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
mcp__drm-copilot__run_poshqc_format (scan_folders: [".claude/hooks/validate-planner-output.ps1", "tests/scripts/claude-hooks/validate-planner-output.Tests.ps1"])

# Linting
mcp__drm-copilot__run_poshqc_analyze (scan_folders: [".claude/hooks/validate-planner-output.ps1", "tests/scripts/claude-hooks/validate-planner-output.Tests.ps1"])

# Testing (MCP wrapper, PoshQC settings)
mcp__drm-copilot__run_poshqc_test (scan_folders: ["tests/scripts/claude-hooks/validate-planner-output.Tests.ps1"], using scripts/powershell/PoshQC/settings/pester.runsettings.psd1)

# Testing with per-file coverage (ad hoc, no repo files modified)
Invoke-Pester -Configuration <PesterConfiguration with Run.Path, CodeCoverage.Path = '.claude/hooks/validate-planner-output.ps1'>
```

---

**Audit Completed By:** feature-review (Claude Code subagent)
**Audit Date:** 2026-07-17
**Policy Version:** Current (as of audit date; MCP template resolution tool `mcp__drm-copilot__resolve_policy_audit_template_asset` was not available in this agent's tool set — the bundled template at `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` was read directly from disk and used as the structural source instead. This is a documented best-effort assumption per this agent's operating constraints.)
