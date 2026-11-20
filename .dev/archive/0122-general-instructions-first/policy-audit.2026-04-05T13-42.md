# Policy Compliance Audit: general-instructions-first (Issue #122)

**Audit Date:** 2026-04-05  
**Base Branch:** `development`  
**Feature Folder:** `docs/features/active/2026-04-05-general-instructions-first-122`  
**Code Under Test:** No live diff relative to `development`; feature-scoped validation references `scripts/dev-tools/sync-agents-from-instructions.ps1`, `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`, `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`, and generated `AGENTS.md` evidence already captured in the feature folder.

**Feature-folder selection rule:** The user explicitly identified `docs/features/active/2026-04-05-general-instructions-first-122` as the active folder, so this audit treats that folder as authoritative even though the refreshed PR context against `development` is a no-op range.

**Coverage Metrics by Language:**

| Language | Files Changed vs `development` | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|-------------------------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 0 in live diff; 2 production + 1 test + 1 generated file in feature evidence | Pester | [✅] 240 pass, 0 fail, 7 skip | 47.57% commands | 47.86% commands | Not isolated numerically in stored evidence |

## Executive Summary

Relative to `development`, the current branch is already fully merged: refreshed PR context reports `origin/development` and `HEAD` at the same commit (`f720ff7fae4e11e62b61d62b3072d03c84a2307b`) with an empty comparison range and zero changed files. For this review, policy compliance is therefore assessed as a no-op branch check plus feature-folder validation. The minor-audit integrity rules hold: `issue.md` contains the exact `## Acceptance Criteria` section, all five items are already checked, and `spec.md` / `user-story.md` are absent. Existing feature evidence also shows the PowerShell quality loop passed, the regression-first ordering tests passed, bundled parity holds, and `AGENTS.md` regenerates with the expected general-first ordering.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md`
- [✅] `powershell-unit-test.instructions.md`

**Temporary artifacts cleanup:**
- [✅] No temporary throwaway scripts were required for this feature review.
- [✅] Existing feature evidence remains in canonical feature-folder locations.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | [✅] [PASS] | The added Pester ordering scenarios use mocks and do not rely on external mutable state; see `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` and `evidence/qa-gates/final-poshqc-test.2026-04-05T13-26.md`. |
| Isolation | [✅] [PASS] | The regression scenarios each target one ordering contract: grouped discovery order and generated output order. |
| Fast Execution | [✅] [PASS] | Final Pester evidence reports `247` discovered tests completed in `9.96s`. |
| Determinism | [✅] [PASS] | Tests mock discovery results and assert explicit ordinal positions, eliminating filesystem-order variance. |
| Readability & Maintainability | [✅] [PASS] | Test names explicitly describe the ordering rule they protect. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | [✅] [PASS] | `evidence/baseline/baseline-poshqc-test.2026-04-05T13-19.md` records `47.57%` command coverage. |
| No Coverage Regression | [✅] [PASS] | Final evidence records `47.86%` command coverage, which is higher than baseline. |
| New Code Coverage ≥90% | [N/A] [N/A] | Relative to `development`, the refreshed branch comparison is empty, so there is no live changed-code slice to measure in this review run. Feature-scoped regression evidence still covers the ordering behavior. |
| Comprehensive Coverage | [✅] [PASS] | Both helper-level and generated-output ordering behavior are covered. |
| Positive Flows | [✅] [PASS] | `evidence/qa-gates/final-agents-regeneration.2026-04-05T13-27.md` confirms successful grouped regeneration. |
| Negative Flows | [✅] [PASS] | `evidence/regression-testing/regression-general-first-order.2026-04-05T13-23.md` captures the expected pre-fix failure. |
| Edge Cases | [✅] [PASS] | Group-internal deterministic order is explicitly asserted in the new Pester scenario. |
| Error Handling | [✅] [PASS] | The regression artifact records the exact failing ordering assertion before the fix. |
| Concurrency | [N/A] [N/A] | Not applicable to this synchronous generation workflow. |
| State Transitions | [N/A] [N/A] | No stateful component was changed. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear Failure Messages | [✅] [PASS] | The red-run artifact records `Expected the actual value to be less than 92, but got 152.` |
| Arrange-Act-Assert Pattern | [✅] [PASS] | The added Pester cases arrange mocked inputs, invoke the target function, and assert explicit order relationships. |
| Document Intent | [✅] [PASS] | The new test names describe the behavior under review without ambiguity. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid External Dependencies | [✅] [PASS] | The reviewed tests use mocks only; no network or temp-file dependency is introduced. |
| Use Mocks/Stubs | [✅] [PASS] | `Test-Path`, `Get-ChildItem`, `Get-InstructionFileData`, and `Get-InstructionsBody` are mocked to isolate ordering behavior. |
| Environment Stability | [✅] [PASS] | Deterministic mocked `C:\repo` paths avoid dependence on actual path enumeration. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission Review | [✅] [PASS] | This audit, plus the companion `code-review` and `feature-audit`, provides the requested branch review record for `development`. |

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | [✅] [PASS] | `issue.md` defines the ordering bug and the required grouped `general*` precedence. |
| Read existing change plans | [✅] [PASS] | `plan.2026-04-05T13-13.md` exists in the feature folder and records the scoped workflow. |
| Document the plan | [✅] [PASS] | The plan captures the regression-first approach and final QC loop. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | [✅] [PASS] | The implementation adds one small sort-key helper instead of restructuring the script. |
| Reusability | [✅] [PASS] | The helper centralizes grouping behavior instead of duplicating basename checks. |
| Extensibility | [✅] [PASS] | The grouped sort-key preserves deterministic ordering within each bucket. |
| Separation of concerns | [✅] [PASS] | Discovery logic, verification tests, and generated output remain cleanly separated. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | [✅] [PASS] | The feature-scoped files remain limited to the sync-agents workflow and its mirror/tests. |
| Under 500 lines | [✅] [PASS] | The reviewed PowerShell script/test remain within the repository file-size limit, as already assessed in the feature evidence set. |
| Public vs internal | [✅] [PASS] | The added helper remains internal to the script. |
| No circular dependencies | [✅] [PASS] | No new dependency edges are introduced. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | [✅] [PASS] | `Get-InstructionSortKey` describes the new behavior directly. |
| Docs/docstrings | [✅] [PASS] | Existing script conventions remain intact and the new helper is self-explanatory. |
| Comment why, not what | [✅] [PASS] | Existing comments continue to explain deterministic-order intent. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| 1. Formatting | [✅] [PASS] | `evidence/qa-gates/final-poshqc-format.2026-04-05T13-26.md` reports a clean formatter pass. |
| 2. Linting | [✅] [PASS] | `evidence/qa-gates/final-poshqc-analyze.2026-04-05T13-26.md` reports no analyzer findings. |
| 3. Type checking | [N/A] [N/A] | Not applicable for PowerShell per repo policy. |
| 4. Testing | [✅] [PASS] | `evidence/qa-gates/final-poshqc-test.2026-04-05T13-26.md` reports `240 passed, 0 failed, 7 skipped`. |
| Full toolchain loop | [✅] [PASS] | Feature evidence shows the intentional red regression capture followed by a clean final pass. |
| Explicit reporting | [✅] [PASS] | Exact commands, timestamps, and exit codes are recorded in the feature evidence artifacts. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | [✅] [PASS] | `issue.md`, `plan.2026-04-05T13-13.md`, and QA evidence summarize the scoped fix. |
| Design choices explained | [✅] [PASS] | The helper-based ordering strategy is evident in the diff and tests. |
| Update supporting documents | [✅] [PASS] | `AGENTS.md` regeneration evidence is present and the feature folder contains the supporting artifacts. |
| Provide next steps | [✅] [PASS] | Relative to `development`, no remediation is required; the only operational note is that the branch is already at the base commit. |

## 3. PowerShell Code Change Policy Compliance

### 3.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Invoke-Formatter | [✅] [PASS] | Final formatter evidence passed with no edits required. |
| Linting with PSScriptAnalyzer | [✅] [PASS] | Final analyzer evidence reports `no findings under .`. |
| Fix all findings | [✅] [PASS] | No findings remained in the clean final pass. |
| PowerShell 7+ compatible | [✅] [PASS] | The script passed the repository’s PoshQC/Pester workflow under the current PowerShell 7 environment. |

### 3.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| Advanced functions | [✅] [PASS] | The helper follows the existing advanced-function pattern with `CmdletBinding()`. |
| Parameter validation | [✅] [PASS] | The helper takes a mandatory `[string]$RelativePath` parameter. |
| Avoid global state | [✅] [PASS] | The added ordering logic is pure and local. |
| Error handling | [✅] [PASS] | The feature preserves explicit failures for unsupported discovery scenarios. |

### 3.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive and under 500 lines | [✅] [PASS] | The touched script/test remain feature-focused and within the repo size limits. |
| Approved verbs | [✅] [PASS] | The new helper uses the approved `Get` verb. |
| Comment why | [✅] [PASS] | Deterministic-order rationale remains documented in existing comments. |

### 3.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| Step 1: Format | [✅] [PASS] | Clean final pass recorded. |
| Step 2: Analyze | [✅] [PASS] | Clean final pass recorded. |
| Step 3: Type check | [N/A] [N/A] | Not applicable. |
| Step 4: Test | [✅] [PASS] | Clean final Pester pass recorded. |
| Rerun loop if needed | [✅] [PASS] | Red/green evidence is present in the feature folder. |

## 4. PowerShell Unit Test Policy Compliance

### 4.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pester v5.x | [✅] [PASS] | Tests run through `Invoke-PoshQCTest -Root .` and the final evidence records Pester discovery/results. |
| Use PoshQC Configuration | [✅] [PASS] | The recorded commands use the repository-standard PoshQC entrypoints. |
| PowerShell 7+ Compatible | [✅] [PASS] | The final Pester run succeeded in the current workspace environment. |

### 4.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Focused Unit Tests | [✅] [PASS] | The added tests separately validate grouped discovery order and generated output order. |
| Test Behavior Over Implementation | [✅] [PASS] | Assertions focus on observable ordering in output, not incidental list mutation. |
| Mocking Used Sparingly | [✅] [PASS] | Only discovery seams are mocked. |
| Organization | [✅] [PASS] | Test location mirrors the script under test. |

### 4.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| File Naming - *.Tests.ps1 | [✅] [PASS] | `sync-agents-from-instructions.Tests.ps1` follows policy. |
| Describe/Context/It Structure | [✅] [PASS] | The ordering scenarios are grouped into dedicated `Context` blocks. |
| Logical Grouping | [✅] [PASS] | Helper-ordering and generated-output ordering are separated cleanly. |
| Docstrings/Comments | [✅] [PASS] | Self-documenting Pester names communicate the scenarios clearly. |

### 4.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use PoshQCTest Command | [✅] [PASS] | The feature evidence uses `Invoke-PoshQCTest -Root .`. |
| No Alternative Test Runners | [✅] [PASS] | No alternate PowerShell test runner was introduced. |

## 5. Test Coverage Detail

### `scripts/dev-tools/sync-agents-from-instructions.ps1` ordering behavior

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `Get-DiscoveredInstructionFile preserves deterministic ordering within the general and language-specific groups` | Edge case / deterministic ordering | [✅] |
| `emits general instruction files before language-specific instruction files in generated AGENTS.md output` | Positive behavior / generated output ordering | [✅] |
| `Bundled sync-agents template matches the repo-root script exactly` | Contract / parity | [✅] |

**Not covered numerically:** Exact changed-line coverage percentage was not isolated in the stored evidence.

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 247 discovered | [✅] |
| Tests Passed | 240 | [✅] |
| Tests Failed | 0 | [✅] |
| Tests Skipped | 7 | [✅] |
| Execution Time | 9.96s total | [✅] |
| Code Coverage | 47.86% commands / 0% branches | [✅] No regression |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PR context refresh | `poetry run python -m scripts.dev_tools.pr_context.collector --base development` | Passed; refreshed summary shows `HEAD == origin/development` and zero changed files | [✅] |
| Diff check | `git diff --name-only origin/development...HEAD` | Passed; no files listed | [✅] |
| Invoke-Formatter | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` | Passed in feature evidence | [✅] |
| PSScriptAnalyzer | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` | Passed in feature evidence | [✅] |
| Pester Tests | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` | Passed in feature evidence | [✅] |
| Sync Regeneration | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/sync-agents-from-instructions.ps1` | Passed in feature evidence | [✅] |

## 8. Gaps and Exceptions

### Identified Gaps

**None.** Relative to `development`, this review found no remaining policy gaps that require remediation.

### Approved Exceptions

**None.** No policy exceptions were used.

### Removed/Skipped Tests

**None.** No feature-specific tests were removed or skipped during this review.

## 9. Summary of Changes

### Files Modified (feature scope, already present in `development`)

1. `scripts/dev-tools/sync-agents-from-instructions.ps1` (MODIFIED)
   - Added grouped sort-key ordering so `general*.instructions.md` basenames come first.
2. `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` (MODIFIED)
   - Preserved byte-identical bundled parity.
3. `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` (MODIFIED)
   - Added ordering regression coverage.
4. `AGENTS.md` (MODIFIED / generated)
   - Regenerated with the general-first grouped order.

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

Relative to `development`, the branch is a no-op diff and the requested minor-audit feature is already present in the base branch. The feature-folder evidence confirms the scoped fix satisfied its acceptance criteria and passed the recorded PowerShell quality loop. The ready-to-merge gate therefore passes relative to `development`, with the practical note that opening a PR would produce no code changes.

### Policy-by-Policy Summary

- [✅] General code change policy: satisfied for the feature-scoped implementation and no-op branch range.
- [✅] PowerShell code change policy: satisfied by recorded formatter/analyzer/test evidence.
- [✅] General unit test policy: regression-first evidence and deterministic tests are present.
- [✅] PowerShell unit test policy: Pester/PoshQC structure and execution are compliant.
- [✅] Branch readiness relative to `development`: passes because `HEAD` already equals `origin/development`.

### Metrics Summary

- [✅] Refreshed comparison range: empty (`origin/development...HEAD`)
- [✅] Final Pester result: 240 passed, 0 failed, 7 skipped
- [✅] Coverage: 47.57% baseline → 47.86% final
- [✅] Bundled parity: verified
- [✅] General-first order: verified

### Recommendation

**Ready for merge**

The gate passes relative to `development`. No remediation is required for this feature relative to that base branch. Operationally, the branch is already merged into `development`, so any new PR to that base would be a no-op.

## Appendix A: Test Inventory

- `sync-agents-from-instructions.ps1 › Get-DiscoveredInstructionFile › Get-DiscoveredInstructionFile preserves deterministic ordering within the general and language-specific groups`
- `sync-agents-from-instructions.ps1 › Get-AgentContent ordering › emits general instruction files before language-specific instruction files in generated AGENTS.md output`
- `sync-agents-from-instructions.ps1 › Bundled parity › Bundled sync-agents template matches the repo-root script exactly`

## Appendix B: Toolchain Commands Reference

```powershell
# Refresh PR context against the requested base
poetry run python -m scripts.dev_tools.pr_context.collector --base development

# Confirm live diff is empty
git diff --name-only origin/development...HEAD

# Feature-scoped PowerShell evidence commands already recorded in the feature folder
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/sync-agents-from-instructions.ps1
```

**Audit Completed By:** GitHub Copilot  
**Policy Version:** Current as of 2026-04-05
