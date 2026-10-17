# Policy Compliance Audit: Exempt-operand bypass, per-segment epic-scope targets, trailer documentation, and Codex shell finding (#732, bundles #738, #745, #735; epic #852 child C1b)

---

**Audit Date:** 2026-10-09
**Audit Type:** S6 feature review (initial review of the branch).
**Code Under Test:** Branch `bug/exempt-operand-bypass-brace-and-dot-segments-exec-732` (local `c1b-732-resume`, head `d7b0d524ffe51819243946e632cb34eec0a36521`) against `origin/epic/enforcement-hook-precision-integration` (tip `5d9d88469f62327688aec48c182e40aebb71eb6d`; merge base `497cb504ad9a4e5435dc8946333ebc28baea50c4`). Scope: `git diff origin/epic/enforcement-hook-precision-integration...HEAD`, 117 files: 7 canonical PowerShell production hook files (3 under `.claude/hooks/`, 4 under `.codex/hooks/`, including the 2 new targets files) and their 7 byte-identical bundled mirrors (14 production `.ps1` paths), 15 Pester test files, 6 skill Markdown files (3 canonical, 3 mirrors), 2 `pack-manifests/core.json` files, and 80 feature-folder documents and evidence artifacts.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 29 files (14 production including bundled mirrors, 15 test files) | 7807 tests (executor full suite, QC pass 3); 1042 tests (reviewer run at HEAD, 30 files) | Executor: 7795 pass, 2 fail (pre-existing B_FULL), 10 skipped. Reviewer at HEAD: 1042 pass, 0 fail | Changed canonical files at baseline: helpers 98.26%, Claude epic-scope 100.00%, Codex epic-scope 100.00%, Codex gate 100.00% lines (targets file new) | 85.89% lines repo-wide (14643/17048); changed canonical files 98.11%-100.00% lines | 100.00% of instrumented changed lines (0 changed lines missed across 7 measured files); targets file 100.00% |
| JSON | 2 files | N/A | PASS: both manifests list the new targets file; push-down and manifest-closure pytest suites 32 passed (reviewer rerun at HEAD) | N/A (config files) | N/A (config files) | N/A |
| Markdown | 86 files (3 skill docs, 3 mirrors, 80 feature docs and evidence) | N/A | N/A (documentation) | N/A (no coverage) | N/A (no coverage) | N/A |

Languages with zero changed files on the branch: TypeScript, Python, C#, Bash. No coverage verdict applies to them.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/baseline/p0-coverage.md` and `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/baseline/p0-pester-full.md` (package-join parse of the baseline PoshQC coverage XML)
- PowerShell post-change coverage artifact: `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/qa-gates/final-coverage.md`, `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/qa-gates/final-pester-full.md`, `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/qa-gates/final-coverage-delta.md`
- Per-language comparison summary: Section 1.2.1 of this audit and `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/qa-gates/final-coverage-delta.md`

**Coverage artifact binding note.** `artifacts/pester/powershell-coverage.xml` is gitignored and is not present in this review worktree. The reviewer located the executor's copy in the executor worktree; its LastWriteTime (2026-10-09T04:53:09.5766768Z) equals `POSHQC_COVERAGE_LAST_WRITE_UTC` in `final-pester-full.md`. The report-level `LINE` counter of that file is `missed=2405 covered=14643`, which is 85.89% repo-wide. The reviewer spot-checked the per-file `sourcefile` entries for the targets file on both surfaces. Binding to HEAD: `final-hash-object.md` (2026-10-09T04-58) records blob `2d617a94` for all four targets copies and `6064dfb2` for all four helpers copies; `git hash-object` at HEAD returns the same values, and the only commits after the coverage run (`6370c414`, `d7b0d524`) change feature documents only. Coverage generation was not rerun, per the reviewer contract. A repo-wide baseline percentage was not recorded at Phase 0; the baseline is per file.

---

## Executive Summary

The branch closes the #732 exempt-operand bypass by replacing the prefix check with a case-sensitive ASCII allowlist (`^[A-Za-z0-9._/-]+$`), denying a backslash anywhere in the command text and `{ } , ( ) @` outside quotes (#735 shell-agnostic rule). It adds a pure, byte-identical targets file that resolves every command segment and path to an absolute target using the merged C1a API (#738), and rewires both epic-scope decisions to evaluate every target. It documents the admitted commit forms and the new quoting rules (#745), and records the #735 finding in hook headers.

Reviewer verification at HEAD:
- Pester, 30 files (all 15 changed suites, every preimplementation-gate suite named in the spec, legacy Codex contracts, and all `tests/scripts/claude-lib/worktree-resolution/*.Tests.ps1`): 1042 passed, 0 failed.
- PSScriptAnalyzer with the PoshQC settings on the 5 canonical changed production files: 0 findings. `Invoke-Formatter` round trip: no change on all 5.
- pytest push-down, manifest-completeness, and manifest-closure suites: 32 passed.
- SHA-256 parity: helpers, targets, Codex gate, both epic-scope files, and all 3 skill documents are identical to their mirrors.
- `validate_evidence_locations --root .`: exit 0, no reported path.
- `git merge-tree --write-tree HEAD origin/epic/enforcement-hook-precision-integration`: clean (no conflict) although the base advanced 35 commits after the merge base.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- ✅ `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- ✅ `.claude/rules/quality-tiers.md` (`.claude/hooks` and `.codex/hooks` are T3 in `quality-tiers.yml`)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A Bash: no shell file changed
- ✅ JSON: two pack manifests changed; validated by the manifest-completeness and closure suites

No Blocking finding was identified. Non-blocking items are listed in Section 8 and in the code review.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed on the branch; executor scripts ran from the session scratchpad.
- ✅ No new ongoing tooling script was added.
- Reviewer scripts (`review732.ps1`, `probe732.ps1`) were written to the session scratchpad only and are not part of the branch.

---

## Rejected Scope Narrowing

No scope narrowing was detected. The caller prompt directed the review to `git diff origin/epic/enforcement-hook-precision-integration...HEAD`, which is the full feature-vs-base diff for this epic-child PR. The statement "AC source: spec.md only (bundled issues 738, 745, 735 are covered by spec.md)" matches the `full-bug` work mode in `issue.md` and does not remove any file or language from scope. "Do not commit" is consistent with the reviewer contract.

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (from the worktree root) - exit 0, no reported path.
- `git diff --name-only origin/epic/enforcement-hook-precision-integration...HEAD -- artifacts` lists no file. The branch adds nothing under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- Evidence is under the canonical kinds `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, and `evidence/other/`.

Result: PASS. No FAIL-level evidence-location finding.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New suites dot-source the unit in `BeforeAll` per surface (`-ForEach` over `.claude/hooks` and `.codex/hooks`) and register seam mocks per `It` (for example `Set-TargetSeam` in `EpicScopeTargets.Tests.ps1`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | Helper-level rows call `Test-ExemptOrchestrationStagingCommand`; targets rows call `Get-OrchestrationCommandTarget` or `Resolve-OrchestrationEpicTargetVerdict`; gate-level rows call `Invoke-OrchestrationPreimplementationGateDecision`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer run of 1042 tests across 30 files completed within one tool call (under 10 minutes including analyzer). |
| **Determinism** - Consistent results | ✅ PASS | Pure string logic; no clock read, sleep, or temporary path in any changed test (reviewer search for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `Set-Content`, `Out-File`, `Start-Sleep`, `New-Item`: the only hits are pre-existing patch-text fixtures in `legacy-codex-hook-contracts.Tests.ps1`). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row names state the command and expected decision; each new suite carries a header stating scope and that it creates no file and starts no process. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** helpers 98.26%, Claude epic-scope 100.00%, Codex epic-scope 100.00%, Codex gate 100.00% lines; targets NEW_FILE.<br>**Command:** `Invoke-PoshQCTest -Root $root` (R-FULL script A) plus package-join parse.<br>**Artifacts:** `evidence/baseline/p0-pester-full.md`, `evidence/baseline/p0-coverage.md`. |
| **No Coverage Regression** | ✅ PASS | **Post-change:** helpers 98.11% (156/159), targets 100.00% (123/123), Claude epic-scope 98.72% (77/78), Codex epic-scope 100.00% (60/60), Codex gate 100.00% (165/165). 85.89% lines repo-wide.<br>**Changed lines:** CHANGED_MISSED 0 on every row (`final-coverage-delta.md`). The helpers and Claude epic-scope percentages fall slightly (0.15 and 1.28 points) because the denominators changed; no changed line is uncovered. |
| **New Code Coverage ≥90%** | ✅ PASS | Targets file (new): 100.00% on both surfaces. |
| **Comprehensive Coverage** | ✅ PASS | Every public function of the targets file has unit rows (84 rows in `enforce-orchestration-preimplementation-gate-targets.Tests.ps1`, 10 in `C1bCoverage.Tests.ps1`). |
| **Positive Flows** - Valid inputs | ✅ PASS | Allow rows for each of the five exempt trees, a `.` segment inside an exempt tree, single-quoted messages containing `{ , ( @`, all-targets-ready epic allow. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Deny rows for both #732 shapes, backslash forms, brace forms, comma, `@name`, parentheses, globs, leading `/` and `//`, `..`, drive letter, `~ % ^ ! = +`, non-ASCII look-alike; #738 relative, unresolvable, `cd`, wrapper-led, mixed, ambiguous, not-ready rows. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Repeated `-C`, missing `-C` value, trailing-slash session root, bare roots, empty token arrays, `apply_patch` markers. |
| **Error Handling** - Error paths | ✅ PASS | Each unresolved rule token (`segment-unbalanced`, `directory-change`, `wrapper-git`, `git-relocation`, `git-option-unmodeled`, `selector-*`, `path-dot-segment`, `session-root-not-absolute`) has a row. |
| **Concurrency** - If applicable | N/A | Stateless single-invocation classifiers. |
| **State Transitions** - If applicable | N/A | No stateful component added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 98.26% helpers, 100.00% Claude epic-scope, 100.00% Codex epic-scope, 100.00% Codex gate (lines; targets file new) -> Post-change: 98.11% helpers, 98.72% Claude epic-scope, 100.00% Codex epic-scope, 100.00% Codex gate, 100.00% targets (lines); 85.89% lines repo-wide. Change: no changed line uncovered (CHANGED_MISSED 0 on all 7 measured files); the two small per-file percentage decreases are denominator changes, not uncovered changed lines. New/changed-code coverage: 100.00% of instrumented changed lines. Disposition: PASS. Evidence: `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/baseline/p0-coverage.md`, `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/qa-gates/final-coverage.md`, `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/qa-gates/final-pester-full.md`, `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/qa-gates/final-coverage-delta.md`.

PowerShell branch coverage: Pester does not measure branch coverage; no branch threshold applies (`.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`). Thresholds applied: line >= 85% for each new and modified file and repo-wide, and no regression on changed lines. All are met. PowerShell coverage verdict: **PASS**.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions use `-Because` with the row label (for example `Should -Be 'deny' -Because "$Name in epic scope"`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New suites carry explicit `# Arrange`, `# Act`, `# Assert` sections. |
| **Document Intent** | ✅ PASS | Suite headers cite the issue and the plan section; rows name the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The targets file performs no disk, process, network, or environment access. Gate-level suites mock `Find-WorktreeResolutionRoot`, `Get-EpicScopeCheckpointText`, `Get-EpicScopeWorktreeHeadBranch`, `Test-EpicScopeMergeInProgress`, and `Resolve-WorktreeEpicTarget`. |
| **Use Mocks/Stubs** | ✅ PASS | Seam mocks with synthetic `/synthetic-worktrees/...` roots. |
| **Environment Stability** | ✅ PASS | No temporary files; no ambient checkpoint dependence in the changed suites. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the S6 policy audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` (FR-1 to FR-6, decisions D1 to D8) and `research/research.2026-10-08T14-00.md`. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md`, `evidence/baseline/p0-feature-inputs-read.md`, `evidence/baseline/p0-issue-comments.md`, `evidence/other/upstream-merge-verification.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-08T13-53.md`: 129 of 129 tasks checked; three preflight clearances recorded. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The operand check shrinks from 40 lines to 12 (allowlist, rooted check, `..` check, prefix loop). |
| **Reusability** | ⚠️ PASS (Non-blocking note) | Target resolution lives in one shared file consumed by both surfaces. The readiness loop and the session-root deny string in `Get-OrchestrationEpicScopeDecision` are duplicated between the Claude and Codex epic-scope files (code review CR-3). |
| **Extensibility** | ✅ PASS | Scope resolution is injected as a scriptblock (`-ScopeResolver`), so each surface keeps its own `Resolve-EpicScopeCheckpoint` signature. |
| **Separation of concerns** | ✅ PASS | The targets file is pure string logic; worktree I/O stays in `EpicScopeResolution.psm1` and the Codex resolution sibling. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | New logic in a new file rather than in the near-cap helpers or gate files. |
| **Under 500 lines** | ✅ PASS | Reviewer `wc -l` at HEAD: helpers 470, targets 328, Codex gate 496, Claude CommandExemption suite 493, Codex command-exemption suite 496, legacy contracts 497; no changed file exceeds 500. |
| **Public vs internal** | ✅ PASS | Internal helpers are named per verb-noun and documented. |
| **No circular dependencies** | ✅ PASS | The targets file dot-sources nothing; the epic-scope files dot-source it. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ⚠️ PASS (Non-blocking note) | `Get-OrchestrationTargetResult` constructs an object; the `Get-` verb was chosen to satisfy `PSUseShouldProcessForStateChangingFunctions` (code review CR-5). |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every public function; issue and rule references inline. |
| **Comment why, not what** | ✅ PASS | Header comments state the #735 reasoning (undetermined shell, fail closed). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** PoshQC format (MCP) with snapshot diff.<br>**Result:** FORMAT_CHANGED_COUNT 0 (`qa-gates/final-poshqc-format.md`). Reviewer `Invoke-Formatter` round trip on 5 canonical files: no change. |
| **2. Linting** | ✅ PASS | **Command:** PoshQC analyze.<br>**Result:** ANALYZE_ISSUE_COUNT 0 (`qa-gates/final-poshqc-analyze.md`). Reviewer `Invoke-ScriptAnalyzer`: 0 findings on 5 files. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Architecture-boundary tests** | ✅ PASS | Scope-boundary check: no copy of the modes, invocation, or scanner files changed (`qa-gates/final-scope-boundary.md`; reviewer `git diff --name-only` confirms). |
| **5. Unit tests** | ✅ PASS | ALL-SCOPED 1604 passed, 0 failed (`qa-gates/final-pester-scoped.md`); full suite 7795 passed, 2 pre-existing failures. Reviewer rerun 1042/1042. |
| **6. Contract checks** | ✅ PASS | pytest contracts 32 passed (`qa-gates/final-pytest-contracts.md`; reviewer rerun 32 passed). |
| **7. Integration tests** | ✅ PASS | Gate-level suites invoke the full gate decision on both surfaces. |
| **Full toolchain loop** | ✅ PASS | Pass 3 clean after two recorded failed passes (`qa-gates/final-toolchain-loop.md`). |
| **Explicit reporting** | ✅ PASS | Each gate has a timestamped artifact with command, exit code, and output summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ⚠️ PASS (Non-blocking note) | Commit subjects are scoped per issue. Commit `8918b5c0` (`docs(732): record final QA evidence`) also carries a production rename in all four targets copies and a new test suite (Section 8, G-2). |
| **Design choices explained** | ✅ PASS | Decisions D1 to D8 in `spec.md`; D2a and D3 intended reversals recorded in `evidence/other/d3-intended-changes.md`. |
| **Update supporting documents** | ✅ PASS | Plan checklist complete; spec AC checked; follow-ups recorded in `evidence/other/follow-ups.md`. |
| **Provide next steps** | ✅ PASS | FU-1 to FU-5 recorded; Section 8 adds reviewer recommendations. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 drift (executor and reviewer). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings (executor and reviewer). |
| **Fix all findings** | ✅ PASS | Pass-1 finding (`PSUseShouldProcessForStateChangingFunctions`) fixed by rename; no suppression added in production code. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Hooks are PowerShell 7+ by existing design (`.NOTES` of each file). |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on every new function. |
| **Parameter validation** | ✅ PASS | Typed parameters with `Mandatory`, `AllowEmptyString`, `AllowEmptyCollection`, `AllowNull` as needed. |
| **Avoid global state** | ✅ PASS | Only `$script:` constants. |
| **Error handling** | ✅ PASS | Every unmodeled form returns an unresolved result (fail closed); `Write-Debug` records the rule token. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | See Section 2.3. |
| **Approved verbs** | ✅ PASS | PSScriptAnalyzer reports no unapproved verb. |
| **Comment why** | ✅ PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 drift. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 1604/1604 scoped; reviewer 1042/1042. |
| **Rerun loop if needed** | ✅ PASS | Three passes; pass 3 clean. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | One line added per manifest, in sorted position with the existing indentation. |
| **Schema validation** | ✅ PASS | **Command:** `poetry run pytest -q` over the five push-down and manifest suites.<br>**Result:** 32 passed (reviewer rerun at HEAD). |
| **Required $schema** | N/A | Pack manifests are not schema-governed. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Manifest suites parse both files. |
| **Deterministic key order** | ✅ PASS | No object key added; array entry inserted in sorted order. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root $root` (executor full run). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Suites declare `#Requires -Version 7.0`, consistent with the hooks' host. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One decision per row. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert decisions, reason codes, and the deny prefix. |
| **Mocking Used Sparingly** | ✅ PASS | Mocks replace worktree read seams only. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-hooks/*.Tests.ps1`, `tests/scripts/codex-hooks/*.Tests.ps1`<br>**Code files:** `.claude/hooks/*.ps1`, `.codex/hooks/*.ps1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All 15 changed test files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per unit and surface. |
| **Logical Grouping** | ⚠️ PASS (Non-blocking note) | `enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1` is named for the process step (coverage remediation) rather than the unit; its rows belong with the targets suite (code review CR-8). |
| **Docstrings/Comments** | ✅ PASS | Suite headers document scope and determinism. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root $root` (executor); see Section 6. |
| **No Alternative Test Runners** | ✅ PASS | Pester only; the reviewer confirmation run used `Invoke-Pester` with an explicit path list and no coverage. |

---

## 5. Test Coverage Detail

### Helpers (`enforce-orchestration-preimplementation-gate-helpers.ps1`, four copies)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| OperandNormalization (76 rows, both surfaces) | Positive / Negative / Edge Case | allowlist, rooted, `..`, prefix, command-text deny set | ✅ |
| ChainEscape (38 rows) | Negative | escaped-semicolon reversal | ✅ |
| CommandExemption, both surfaces (119 rows each) | Positive / Negative | D4 row 18 and LACS allow 3 reversals | ✅ |
| AttributionTrailer (84 rows) | Positive / Negative | `--trailer --` admit and deny; U+201A, U+201B, U+201E deny | ✅ |
| Parity (2 rows) | Static | SHA-256 identity and line cap | ✅ |

**Coverage:** 98.11% (156/159) on each canonical copy; CHANGED_MISSED 0.

**Not covered:** 3 pre-existing lines outside the changed set.

---

### Targets (`enforce-orchestration-preimplementation-gate-targets.ps1`, four copies) and epic-scope decisions

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| targets.Tests (84 rows, both surfaces) | Positive / Negative / Error Handling | R0 to R7 and V1 to V7 | ✅ |
| C1bCoverage (10 rows) | Edge Case | trailing-slash and bare-root normalization | ✅ |
| targets.Parity (2 rows) | Static | SHA-256 identity and line cap | ✅ |
| EpicScopeTargets, Claude (12 rows) | Integration (gate level) | mixed, relative, unresolvable, `cd`, wrapper, Write path, repeated `-C`, allow, single-feature unchanged, ambiguous | ✅ |
| epic-scope-targets, Codex (13 rows) | Integration (gate level) | same plus `apply_patch` marker and no-`-C` session root | ✅ |
| OperandBypass, both surfaces (2 rows each) | Integration (gate level) | both #732 shapes deny | ✅ |

**Coverage:** targets 100.00% (123/123); Claude epic-scope 98.72% (77/78); Codex epic-scope 100.00% (60/60); Codex gate 100.00% (165/165).

**Not covered:** 1 pre-existing line in the Claude epic-scope file outside the changed set.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 1042 (reviewer run at HEAD, 30 files); 7807 (executor full suite, pass 3) | ✅ |
| Tests Passed | 1042 (reviewer); 7795 (executor full suite) | ✅ |
| Tests Failed | 0 (reviewer); 2 (executor full suite; both B_FULL, recorded at baseline) | ✅ |
| Execution Time | about 8 minutes (executor full suite, 04:47 to 04:55 UTC) | ✅ |
| Average Time per Test | not recorded by the reviewer run | ✅ |
| Discovery Time | not reported separately | ✅ |
| Functions/Classes Tested | all new public functions | ✅ |
| Test File Size | maximum 497 lines | ✅ Maintainable |
| Code Coverage (if applicable) | 85.89% lines repo-wide; changed canonical files 98.11%-100.00% lines; branch coverage not measured by Pester | ✅ |

CI has not run: no pull request exists for this branch yet (`artifacts/pr_context.summary.txt`: "no PR exists yet for this branch").

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | PoshQC format (executor); `Invoke-Formatter` round trip (reviewer, 5 files) | 0 drift | ✅ |
| PSScriptAnalyzer | PoshQC analyze (executor); `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (reviewer, 5 files) | 0 findings | ✅ |
| Pester Tests | ALL-SCOPED (executor); `Invoke-Pester` over 30 files (reviewer) | 1604/1604; 1042/1042 | ✅ |

**Notes:**
- Pre-existing failures (B_FULL), present at baseline (`evidence/baseline/p0-pester-full.md` lines 320-321) and unchanged at pass 3: `enforce-pr-author-skill.Tests.ps1` (`allows gh pr create --body-file artifacts/pr_body_12.md when context exists`) and `codex-pretooluse-integration.Tests.ps1` (`allows every registered handler for every tool name its own matcher admits`). Neither suite touches a file changed on this branch. Not a regression.
- Bundled mirrors under `extensions/drm-copilot/resources/` are not in the PoshQC coverage denominator (the reviewer found no `extensions` package in the coverage XML). This is repository configuration that predates the branch; the branch adds no exclusion entry. Each mirror is byte-identical to a measured canonical copy.

---

## 8. Gaps and Exceptions

### Identified Gaps

All gaps below are Non-blocking.

- **G-1 Branch currency.** The integration branch advanced 35 commits after the merge base (`git log HEAD..origin/epic/enforcement-hook-precision-integration`). `git merge-tree` reports a clean merge; the only file changed on both sides is the Claude `pack-manifests/core.json`. Merge the integration branch before opening the PR so the PR CI runs on the merged tree.
- **G-2 Commit hygiene.** `8918b5c0` (`docs(732): record final QA evidence`) carries the `New-` to `Get-OrchestrationTargetResult` rename in all four targets copies and the new `C1bCoverage` suite. The PR description should state that this commit contains code.
- **G-3 Repo-wide baseline.** Phase 0 recorded per-file baseline coverage only; the repo-wide baseline percentage is not available. Per-file and changed-line evidence is sufficient for the thresholds that apply.
- **G-4 Path-leg UNC spellings.** Reviewer probe: a Write `file_path` of `\\localhost\C$\wt\other\src\x.ps1` or `\\?\C:\wt\other\src\x.ps1` resolves to the session root, not to its own worktree (code review CR-1). See the feature audit for the FR-3 assessment.

### Approved Exceptions

**None.** The fail-before exception for the targets unit and parity suites (`evidence/regression-testing/fail-before-exception.2026-10-09T04-01.md`) is a planned exception: the unit did not exist at the base SHA (`git cat-file -e` exit 128).

### Removed/Skipped Tests

**None removed.** Changed assertions are limited to the D2a reversals (D4 row 18, LACS allow 3, ChainEscape escaped semicolon) and the two D3 intended changes recorded in `evidence/other/d3-intended-changes.md`.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **01f84ffa** - docs(732): record wave-transition hook-load parse check
2. **95261799** - docs(732): record phase 0 evidence and C1a API blocker at P0-T9
3. **17b1ebfe** - docs(732): revise plan for merged C1a matcher API and exec branch
4. **8ec4b706** - docs(732): apply preflight round-5 plan deltas
5. **cd5b1d59** - docs(732): record round-6 preflight clearance for plan v1.5
6. **d379899e** - docs(732): record phase 0 evidence and R-FULL coverage blocker at P0-T17
7. **fe26ce26** - docs(732): revise R-FULL coverage matching to package-join rule
8. **ded64d68** - docs(732): apply preflight round-7 plan deltas
9. **993cbf52** - docs(732): record round-8 preflight clearance for plan v1.7
10. **eaa6d2b9** - docs(732): record phase 0 baselines and upstream verification
11. **ac649618** - test(732): add fail-before rows for exempt-operand bypass and intended reversals
12. **64a9ac52** - fix(732): deny shell-divergent operands with an ASCII allowlist
13. **901933c0** - test(738): add fail-before rows for per-segment epic-scope targets
14. **22c31355** - feat(738): add per-segment target resolver for the preimplementation gate
15. **4dd2231d** - fix(738): resolve every segment target in epic-scope decisions
16. **7d1fea62** - docs(745): document admitted commit forms and shell-divergent denials
17. **8918b5c0** - docs(732): record final QA evidence
18. **6370c414** - docs(732): check off verified acceptance criteria and record follow-ups
19. **d7b0d524** - docs(732): record P8-T33 completion and commit log entry

### Files Modified

1. **`enforce-orchestration-preimplementation-gate-helpers.ps1`** (MODIFIED, 4 copies) - backslash-anywhere deny, extended outside-quote set, allowlist operand check, #735 header.
2. **`enforce-orchestration-preimplementation-gate-targets.ps1`** (NEW, 4 copies) - per-segment target resolver, verdict, and deny-reason builder.
3. **`enforce-orchestration-preimplementation-gate-epic-scope.ps1`** (MODIFIED, Claude and Codex plus mirrors) - every-target epic-scope decision.
4. **`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`** (MODIFIED, plus mirror) - #735 and D4 header only.
5. **Skill documents** - Integration Commit Form section (`.agents/skills/epic-plan/SKILL.md`) and quoting-rule paragraph (3 canonical, 3 mirrors).
6. **`pack-manifests/core.json`** (2) and **`legacy-codex-hook-contracts.Tests.ps1`** - registration of the targets file.
7. **Tests** - 8 new suites, 7 modified suites.
8. **Feature folder** - plan, spec AC check-off, evidence.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All toolchain stages pass, coverage thresholds are met with no uncovered changed line, every changed file is within 500 lines, mirrors are byte-identical, and evidence is in canonical locations. Four Non-blocking gaps are listed in Section 8.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is absent. All required artifacts for this branch are present.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plan, and Phase 0 evidence present.
- ✅ Design Principles: allowlist simplification; pure shared resolver; one duplication note.
- ✅ Module & File Structure: maximum 497 lines.
- ✅ Naming, Docs, Comments: one verb-choice note.
- ✅ Toolchain Execution: pass 3 clean.
- ✅ Summarize & Document: one commit-subject note.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: 0 drift, 0 findings.
- ✅ PowerShell Design & Safety: fail-closed resolution.
- ✅ Structure & Naming: under 500 lines.
- ✅ Toolchain: clean final pass.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: deterministic, seam-mocked rows.
- ✅ Coverage & Scenarios: 0 uncovered changed lines; 85.89% repo-wide.
- ✅ Test Structure: AAA with descriptive names.
- ✅ External Dependencies: none; no temporary files.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC.
- ✅ Test Style & Structure: behavior-focused.
- ✅ Naming & Readability: `*.Tests.ps1`; one process-named suite.
- ✅ Toolchain: executor and reviewer runs recorded.

---

### Metrics Summary

- ✅ 1042/1042 reviewer-run tests passing at HEAD
- ✅ All new public functions tested
- ✅ 85.89% repo-wide PowerShell line coverage; changed canonical files 98.11%-100.00%; 0 uncovered changed lines
- ✅ Proper file organization: tests under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`
- ✅ All code quality checks passing

---

### Recommendation

**Ready for PR into the integration branch after merging the current integration tip (G-1).** No policy remediation is required. Blocking findings in this audit: 0.

---

## Appendix A: Test Inventory

### Complete Test List

New suites:

1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1` (76)
2. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` (84)
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` (2)
4. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1` (2)
5. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` (12)
6. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1` (10)
7. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1` (2)
8. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` (13)

Modified suites: `...-helpers.ChainEscape` (38), `.AttributionTrailer` (84), `.CommandExemption` (119), `.EpicScope` (21), Codex `-command-exemption` (119), Codex `-epic-scope` (53), `legacy-codex-hook-contracts` (43).

Regression suites in the reviewer run: `.OperandResolution` (10), `.WorktreeResolution` (15), gate `.Tests` (35), `-helpers.Parity` (2), Codex `-epic-resolution` (48), and 10 `claude-lib/worktree-resolution` suites (254).

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands (check-only):**
```bash
git diff --name-status origin/epic/enforcement-hook-precision-integration...HEAD
git log --oneline HEAD..origin/epic/enforcement-hook-precision-integration
git merge-tree --write-tree --name-only HEAD origin/epic/enforcement-hook-precision-integration
git hash-object <targets, helpers, epic-scope canonical paths>
sha256sum <every mirrored hook and skill file pair or quad>
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/enforcement-hook-precision-integration
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run pytest -q tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py
sh <SCRATCHPAD>/review732.sh   # Invoke-Pester over 30 files; Invoke-ScriptAnalyzer and Invoke-Formatter on 5 files
sh <SCRATCHPAD>/probe732.sh    # behavioral probes of Get-OrchestrationCommandTarget and Test-ExemptOrchestrationOperand
```

**For PowerShell (executor toolchain):**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-10-09
**Policy Version:** Current (as of audit date)
