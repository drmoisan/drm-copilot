# Policy Compliance Audit: pester-adapter-id-collision (Issue #198)

**Audit Date:** 2026-06-17
**Code Under Test:**
- `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` (NEW, PowerShell test, +495/-0)
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (MODIFIED, PowerShell test, +10/-16)
- Docs (non-code): `spec.md`, `issue.md`, `plan.2026-06-17T21-05.md`, `evidence/qa-gates/2026-06-18T01-11/qa-gate.md`

**Base branch:** `main` (merge-base `fb05bbea85d5efcf7f2f4d5b311ced644c607d9d`)
**Head:** `fix/pester-adapter-id-collision-198` (`9eb40c16c355ecd9f50b0e6ca5501956d1037dd4`)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 files (both `*.Tests.ps1`, test-only) | 5 new guard tests; full scan-folder suite 294 | ✅ 294 pass, 0 fail, 2 skip | 96.8% lines (repo-wide PS, pre-change) | 96.8% lines (275/284), repo-wide PS | N/A — both changed files are test files, excluded from the coverage denominator per `general-unit-test.md` |

**Note:** Only PowerShell has changed files in the branch diff. Python, TypeScript, C#, and Bash have zero changed files on this branch and are therefore N/A.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (no TypeScript files changed on this branch).
- TypeScript post-change coverage artifact: N/A - out of scope (no TypeScript files changed on this branch).
- PowerShell baseline coverage artifact: `artifacts/pester/powershell-coverage.xml` (repo-wide production line coverage 96.8%; test-only change, no production lines modified, so the pre-change repo-wide value is the baseline).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (repo-wide line coverage 275 covered / 9 missed = 96.8%).
- Per-language comparison summary: Section 1.2.1 below.
- Branch coverage: the Pester JaCoCo report emits no `BRANCH` counter (a documented PowerShell/Pester limitation). Branch coverage is recorded UNVERIFIED for this reason; it is not a regression because no production branches were added or modified.

**Coverage verdict (PowerShell):** PASS. Repo-wide line coverage 96.8% (>= 85%). Both changed files are test files (correctly excluded from the coverage denominator); no production code was added or modified, so no new-code or modified-file coverage threshold applies to production source.

---

## Rejected Scope Narrowing

None. The caller prompt did not attempt to narrow scope to a plan, task, phase, or file subset, and did not mark any language as out-of-scope or informational-only. The audit was performed against the full branch diff `fb05bbe..9eb40c1`.

---

## Evidence Location Compliance

The branch diff `fb05bbe..9eb40c1` was scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.

- Branch-diff result: **zero** such files. All feature evidence in this branch is written to the canonical `docs/features/active/2026-06-17-pester-adapter-id-collision-198/evidence/qa-gates/...` path.
- `validate_evidence_locations.py --root .` reports VIOLATION entries under `artifacts/evidence/baseline/**` and `artifacts/evidence/post-change/**`. These are pre-existing **untracked working-tree files** (`git ls-files artifacts/evidence` returns empty) belonging to an unrelated prior feature; none of them appear in this branch's diff (`git diff --name-only fb05bbe..9eb40c1 | grep artifacts/evidence` returns nothing).

**Disposition:** PASS for this feature. No evidence-location violation is introduced by this branch. The validator's working-tree findings are out of scope for this feature-vs-base audit and are recorded here for transparency only.

---

## Executive Summary

This is a test-only change addressing issue #198, in which the VS Code `pspester.pester-test` adapter folds discovered Pester test IDs to uppercase, causing sibling Describe/Context/It names (including `-ForEach`/`-TestCases` expansions) that differ only by letter case to collide to a single adapter ID and be dropped/misreported.

Two PowerShell test files changed and no production code changed:
1. `Invoke-FullRelease.Tests.ps1` — the two case-sensitivity confirmation-token `It` cases were merged into one `-ForEach` block carrying a non-case `CaseLabel` (`uppercase`/`titlecase`) included in the `It` name, so the uppercased adapter IDs differ. Both assertions (exit code 2 for a non-`yes` token) are preserved.
2. `test-name-uniqueness.Tests.ps1` (new) — a deterministic regression guard that AST-parses every `*.Tests.ps1` under `tests/` and asserts that no two sibling test names — and no two literal `-ForEach`/`-TestCases` expansions — collide case-insensitively.

**Policy documents evaluated:**
- ✅ `general-code-change.md`
- ✅ `general-unit-test.md`

**Language-specific policies evaluated:**
- N/A `python-*` — no Python files changed.
- ✅ `powershell.md` (`powershell-code-change` + `powershell-unit-test` equivalents) — applies.
- N/A `typescript-*`, `csharp-*`, Bash, JSON — no files changed.

Toolchain evidence (from `evidence/qa-gates/2026-06-18T01-11/qa-gate.md`): format EXIT 0 (no changes), analyze EXIT 0 (0 findings), Pester EXIT 0 (294 passed / 0 failed / 2 pre-existing skips on the scan folders; new guard file 5/5 passing). The MCP PoshQC tools were unavailable in the executor environment; the repository PoshQC module functions those tools wrap were invoked directly with identical settings.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts were created by this change.
- ✅ The new guard file is a permanent, tested regression artifact compliant with repo policy.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | The guard tests share no mutable state; each `It` builds its own in-memory fixture string or enumerates files freshly. The suite-scan `It` reads files via `Get-Content -Raw` with no ordering dependency. |
| **Isolation** | ✅ PASS | Each in-memory fixture `It` targets one detection behavior (case-only sibling collision, `-ForEach` data-value collision, disambiguated rows, non-literal skip). The suite-scan `It` targets the repository-wide invariant. |
| **Fast Execution** | ✅ PASS | AST parsing of in-memory strings and file content; no external process, network, or sleep. qa-gate records the scan-folder suite (296 total) completing within a normal Pester run. |
| **Determinism** | ✅ PASS | No randomness, no wall-clock reads, no network. `tests/` root is resolved by walking up from `$PSScriptRoot`, making the scan CWD-independent (Terminal and Test Explorer parity). |
| **Readability & Maintainability** | ✅ PASS | Descriptive `It` names, comment-based help on every helper, AAA comments in each fixture test. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Repo-wide PowerShell production coverage (`.claude/hooks` package) is 96.8% lines per `artifacts/pester/powershell-coverage.xml`. Test-only change; no production baseline regression possible. |
| **No Coverage Regression** | ✅ PASS | No production lines modified. Post-change repo-wide PS line coverage 96.8% (275/284). |
| **New Code Coverage** | N/A | The new file is a test file, excluded from the coverage denominator. The guard's helper `Get-AdapterIdCollision` and supporting functions are exercised by the 5 in-file tests (positive, negative, and suite-scan paths). |
| **Comprehensive Coverage** | ✅ PASS | The detection helper is exercised through positive collision detection (sibling `It`, `-ForEach` data-value), negative cases (disambiguated `-ForEach`, non-literal skip), and the repository-wide scan. |
| **Positive Flows** | ✅ PASS | "detects two sibling It names that differ only by letter case"; "detects a literal -ForEach whose rows differ only by data-value case". |
| **Negative Flows** | ✅ PASS | "reports no collision when a literal -ForEach disambiguates rows with a distinct data key"; "skips a non-literal -ForEach argument without raising a collision". |
| **Edge Cases** | ✅ PASS | Three literal array shapes handled (`Get-LiteralHashtableElement`); non-literal `-ForEach` argument is skipped rather than failing (documented limitation). |
| **Error Handling** | ✅ PASS | `tests/` root resolution throws a clear message when the root cannot be found; collision messages name the source label and folded discriminator. |
| **Concurrency** | N/A | No concurrent behavior under test. |
| **State Transitions** | N/A | No stateful component under test. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.8% lines (repo-wide production, `.claude/hooks` package). Post-change: 96.8% lines (275 covered / 9 missed). Change: 0% (test-only change, no production lines modified). New/changed-code coverage: N/A (both changed files are test files, excluded from the denominator). Branch coverage: not measurable from this artifact because the Pester JaCoCo report emits no BRANCH counter; no production branches were added or modified, so there is no branch regression. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/2026-06-18T01-11/qa-gate.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Suite-scan asserts `Should -Be 0 -Because ($allCollisions -join "`n")`, so a failure prints every colliding file and discriminator. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Each fixture `It` is labeled Arrange / Act / Assert. |
| **Document Intent** | ✅ PASS | Test names are self-documenting; the file header explains the adapter mechanism and the guard's purpose. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Pure AST parsing and file reads; no network, DB, or external process. |
| **Use Mocks/Stubs** | ✅ PASS | `Invoke-FullRelease.Tests.ps1` mocks the wrapper seams (`Invoke-NpmExe`, `Invoke-PublishScript`, `Invoke-GitExe`, `Write-StderrLine`) per the wrapper-seam mocking rule; the guard file needs no mocks. |
| **Environment Stability** | ✅ PASS | No temporary files created. `tests/` root resolved from `$PSScriptRoot`, not CWD or PATH. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, plus the feature folder qa-gate, constitute the required review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Objective documented in `issue.md` and `spec.md` (issue #198). |
| **Read existing change plans** | ✅ PASS | `plan.2026-06-17T21-05.md` present with completed P0–P4 tasks. |
| **Document the plan** | ✅ PASS | Plan and spec recorded in the feature folder. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The disambiguation merges two near-identical `It` blocks into one `-ForEach`, reducing duplication. |
| **Reusability** | ✅ PASS | `Get-AdapterIdCollision` is a single detection path exercised by both fixtures and the suite scan. |
| **Extensibility** | ✅ PASS | Helpers are decomposed (`Get-LiteralArgumentValue`, `ConvertTo-LiteralHashtableRow`, `Get-LiteralHashtableElement`, `ConvertTo-LiteralDataRow`, `Get-BlockDiscriminator`). |
| **Separation of concerns** | ✅ PASS | AST literal extraction, data-row conversion, discriminator computation, and collision detection are separate functions. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The new file is a single cohesive regression guard. |
| **Under 500 lines** | ✅ PASS | `test-name-uniqueness.Tests.ps1` is 495 lines (< 500). `Invoke-FullRelease.Tests.ps1` net -6 lines, remains under limit. |
| **Public vs internal** | ✅ PASS | Helpers are defined inside `BeforeAll` scope, not exported. |
| **No circular dependencies** | ✅ PASS | No module imports; self-contained AST logic. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved-verb function names; descriptive nouns. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every helper function. |
| **Comment why, not what** | ✅ PASS | Comments explain the adapter folding mechanism and the literal-only limitation rationale. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | `Invoke-PoshQCFormat` EXIT 0, no files changed (qa-gate). |
| **2. Linting** | ✅ PASS | `Invoke-PoshQCAnalyze` EXIT 0, 0 findings (qa-gate). |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | Pester EXIT 0, 294 passed / 0 failed / 2 skipped on scan folders (qa-gate). |
| **Full toolchain loop** | ✅ PASS | format -> analyze -> test completed clean in a single pass (qa-gate). |
| **Explicit reporting** | ✅ PASS | Commands and results recorded in `evidence/qa-gates/2026-06-18T01-11/qa-gate.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Spec "Proposed Fix" and qa-gate document the change. |
| **Design choices explained** | ✅ PASS | Spec documents the `CaseLabel` disambiguation and AST guard design. |
| **Update supporting documents** | ✅ PASS | spec.md, issue.md, plan.md, qa-gate.md all present. |
| **Provide next steps** | ✅ PASS | AC6 (CI green on PR head) documented as pending PR creation. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | `Invoke-PoshQCFormat` EXIT 0 (qa-gate). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | `Invoke-PoshQCAnalyze` EXIT 0, 0 findings. Two transient warnings (PSUseBOMForUnicodeEncodedFile, PSReviewUnusedParameter) were resolved before the gate. |
| **Fix all findings** | ✅ PASS | 0 residual findings. |
| **PowerShell 7+ compatible** | ✅ PASS | Uses `[System.Management.Automation.Language.Parser]`, generic collections, invariant-culture upper; PS7-compatible. PSSA settings enforce 7+. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | N/A (test file) | Helpers are local `param()` functions inside `BeforeAll`; advanced-function/CmdletBinding expectations apply to production functions, not in-test helpers. Parameters use `[Parameter(Mandatory)]` and `[AllowNull()]` where appropriate. |
| **Parameter validation** | ✅ PASS | Mandatory and typed parameters on each helper. |
| **Avoid global state** | ✅ PASS | Only `$script:TestsRoot` is script-scoped, required for `BeforeAll`-to-`It` sharing of the resolved root; no mutable global state. |
| **Error handling** | ✅ PASS | `throw` with a clear message when the `tests/` root cannot be resolved; non-literal data returns `$null` and is skipped rather than silently mis-detected. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 495 lines. |
| **Approved verbs** | ✅ PASS | `Get-LiteralArgumentValue`, `ConvertTo-LiteralHashtableRow`, `Get-LiteralHashtableElement`, `ConvertTo-LiteralDataRow`, `Get-BlockDiscriminator`, `Get-AdapterIdCollision` — all use approved verbs (Get, ConvertTo). |
| **Comment why** | ✅ PASS | Comments explain rationale, not mechanics. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | EXIT 0 (qa-gate). |
| **Step 2: Analyze** | ✅ PASS | EXIT 0, 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | EXIT 0. |
| **Rerun loop if needed** | ✅ PASS | Single clean pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, `Describe`/`Context`/`It`, modern `Should` syntax; Pester 5.6.1. |
| **Use PoshQC Configuration** | ✅ PASS | Run via repository PoshQC module functions with `pester.runsettings.psd1`/`pssa.settings.psd1`. |
| **PowerShell 7+ Compatible** | ✅ PASS | PS7 AST and collection APIs. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Test Behavior Over Implementation** | ✅ PASS | Tests assert collision presence/absence, not internal data structures. |
| **Mocking Used Sparingly** | ✅ PASS | Guard file uses no mocks; `Invoke-FullRelease.Tests.ps1` mocks only the wrapper seams. |
| **Organization** | ✅ PASS | `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` lives under the `tests/` tree (not colocated with production source). `Invoke-FullRelease.Tests.ps1` mirrors `scripts/dev-tools/Invoke-FullRelease.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming - *.Tests.ps1** | ✅ PASS | Both files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe, 2 Context, 5 It in the guard file. |
| **Logical Grouping** | ✅ PASS | "detection logic (in-memory fixtures)" vs "repository suite scan". |
| **Docstrings/Comments** | ✅ PASS | Self-documenting names plus comment-based help. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | Pester run via PoshQC module; EXIT 0. |
| **No Alternative Test Runners** | ✅ PASS | Only Pester used. |

---

## 5. Test Coverage Detail

### test-name-uniqueness adapter-ID collision guard (5 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| detects two sibling It names that differ only by letter case | Positive | ✅ |
| detects a literal -ForEach whose rows differ only by data-value case | Positive | ✅ |
| reports no collision when a literal -ForEach disambiguates rows with a distinct data key | Negative | ✅ |
| skips a non-literal -ForEach argument without raising a collision | Negative/Edge | ✅ |
| reports zero folded adapter-ID collisions across all tests/**/*.Tests.ps1 | Negative (suite scan) | ✅ |

**Coverage:** Detection helper and supporting AST functions are exercised across positive, negative, edge, and repository-wide paths.

**Not covered:** Non-literal `-ForEach` data arguments are intentionally skipped (documented limitation in spec Risks & Mitigations).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (scan folders) | 296 (294 passed, 2 skipped) | ✅ |
| Tests Passed | 294 (99.3% of non-skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| New guard file tests | 5 passed / 0 failed | ✅ |
| Test File Size | 495 lines | ✅ Maintainable |
| Code Coverage (repo-wide PS production) | 96.8% lines (275/284); branches UNVERIFIED (no BRANCH counter) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -ScanFolders tests/scripts/claude-runtime, tests/scripts/dev-tools` | EXIT 0, no changes | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -ScanFolders tests/scripts/claude-runtime, tests/scripts/dev-tools` | EXIT 0, 0 findings | ✅ |
| Pester Tests | `Invoke-Pester -Path tests/scripts/claude-runtime, tests/scripts/dev-tools` | EXIT 0, 294/0/2 | ✅ |

**Notes:** The MCP `mcp__drm-copilot__*` PoshQC tools were unavailable in the executor environment; the wrapped repository module functions were invoked directly with identical settings (`scripts/powershell/PoshQC/settings/pssa.settings.psd1`). The 2 skips are pre-existing and unrelated to this change.

---

## 8. Gaps and Exceptions

### Identified Gaps
- **Branch coverage metric:** UNVERIFIED for PowerShell because the Pester JaCoCo report emits no `BRANCH` counter (a documented PowerShell/Pester limitation). This is not a regression: the change adds no production branches and modifies no production code. Not remediation-triggering.

### Approved Exceptions
- **None.** No exceptions needed.

### Removed/Skipped Tests
- **None.** The two original case-sensitivity `It` blocks were merged into one `-ForEach` block; both assertions are preserved (not removed).

---

## 9. Summary of Changes

### Files Modified

1. **`tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`** (NEW)
   - Deterministic AST-based regression guard for case-insensitive sibling-name collisions, plus 4 in-memory fixture tests and 1 repository suite-scan test. 495 lines.

2. **`tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`** (MODIFIED, +10/-16)
   - Merged the two confirmation-token case-sensitivity `It` cases into one `-ForEach` block carrying a non-case `CaseLabel`, disambiguating the uppercased adapter IDs. Both exit-code-2 assertions preserved.

3. Docs (NEW): `spec.md`, `issue.md`, `plan.2026-06-17T21-05.md`, `evidence/qa-gates/2026-06-18T01-11/qa-gate.md`.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

This is a test-only change with no production code modified. The PowerShell toolchain (format -> analyze -> test) passes clean. Coverage is satisfied: both changed files are test files (correctly excluded from the coverage denominator), and repo-wide PowerShell production line coverage is 96.8% (>= 85%). The `modified-workflow-needs-green-run` rule does not fire (no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths in the diff). No evidence-location violation is introduced by this branch.

**modified-workflow-needs-green-run:** NOT TRIGGERED. The branch diff contains no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes / Design Principles / Module & File Structure / Naming / Toolchain / Summarize & Document.

#### Language-Specific Code Change Policy (Section 3 — PowerShell)
- ✅ Tooling & Baseline / Design & Safety / Structure & Naming / Toolchain.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles / Coverage & Scenarios / Test Structure / External Dependencies / Policy Audit.

#### Language-Specific Unit Test Policy (Section 4 — PowerShell)
- ✅ Framework & Scope / Test Style & Structure / Naming & Readability / Toolchain.

### Metrics Summary
- ✅ 294/294 non-skipped tests passing on scan folders; new guard 5/5.
- ✅ 96.8% repo-wide PowerShell production line coverage.
- ✅ File organization mirrors the `tests/` tree.
- ✅ All PowerShell code-quality checks passing.
- ⚠️ Branch coverage UNVERIFIED (no Pester BRANCH counter) — not a regression, not remediation-triggering.

### Recommendation

**Ready for merge** (subject to AC6: CI required checks green on the PR head, which is pending PR creation and the S9 CI gate). No blocking policy findings.

---

## Appendix A: Test Inventory

1. test-name-uniqueness adapter-ID collision guard › detection logic (in-memory fixtures) › detects two sibling It names that differ only by letter case
2. ... › detection logic (in-memory fixtures) › detects a literal -ForEach whose rows differ only by data-value case
3. ... › detection logic (in-memory fixtures) › reports no collision when a literal -ForEach disambiguates rows with a distinct data key
4. ... › detection logic (in-memory fixtures) › skips a non-literal -ForEach argument without raising a collision
5. ... › repository suite scan › reports zero folded adapter-ID collisions across all tests/**/*.Tests.ps1
6. Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded › is case-sensitive: ConfirmToken '<ConfirmToken>' (<CaseLabel>) is rejected with code 2 [×2 expansions: uppercase, titlecase]

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -ScanFolders tests/scripts/claude-runtime, tests/scripts/dev-tools

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -ScanFolders tests/scripts/claude-runtime, tests/scripts/dev-tools

# Testing
Invoke-Pester -Path tests/scripts/claude-runtime, tests/scripts/dev-tools
Invoke-Pester -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
```

**Evidence-location scan:**
```bash
git diff --name-only fb05bbea85d5efcf7f2f4d5b311ced644c607d9d..9eb40c16c355ecd9f50b0e6ca5501956d1037dd4 | grep -E 'artifacts/(baselines|qa|evidence|coverage)/'
python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent (Claude Opus 4.8)
**Audit Date:** 2026-06-17
**Policy Version:** Current (as of audit date)
