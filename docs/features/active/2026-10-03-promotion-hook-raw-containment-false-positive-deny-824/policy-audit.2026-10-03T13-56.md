# Policy Compliance Audit: Token-aware R2 matcher, worktree-gate operand resolution, and #823 follow-ups (#824)

---

**Audit Date:** 2026-10-03
**Audit Type:** Reaudit after remediation cycle 1 (review pass 2)
**Code Under Test:** Full branch diff `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5...c7b78cd2ea8c5a0bd010f0424f54498b7802597c` (264 files; resolved base `origin/main`, merge base committed 2026-10-03T10:09:53-04:00). Production files outside the feature folder, each mirrored byte-identically under `extensions/drm-copilot/resources/`:
- PowerShell NEW: `.claude/hooks/hook-command-raw-invocation.ps1`, `.codex/hooks/hook-command-raw-invocation.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`
- PowerShell MODIFIED: `.claude/hooks/hook-command-invocation.ps1`, `.codex/hooks/hook-command-invocation.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/validate-feature-review-coverage.ps1`
- Bash MODIFIED: `.codex/codex-web-setup.sh`
- Markdown policy and skill text MODIFIED: `.claude/rules/{architecture-boundaries,general-unit-test,quality-tiers}.md`, `.github/instructions/csharp-{code-change,unit-test}.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.claude/agents/feature-review.md`, `.claude/skills/{feature-review-workflow,quota-throttling}/SKILL.md`, `.agents/skills/{architecture-boundaries,csharp,csharp-qa-gate,general-unit-test,quality-tiers}/SKILL.md`, and the bundled `csharp-legacy` variant skills
- JSON MODIFIED: both `pack-manifests/core.json`

Tests: 19 Pester suites (4 new, 15 modified) under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`; 2 Python test files (1 new, 1 modified) under `tests/scripts/dev_tools/`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 production (3 new, 6 modified) + 9 mirrors + 19 test files | 6753 in the executor full PoshQC run; 486 in the reviewer's 19 changed suites (224 tagged Issue824) | ✅ 6753 total, 0 failures (executor); 486 pass, 0 fail (reviewer) | 84.67% lines repo-wide at the merge base | 85.46% lines repo-wide (13612/15928); every changed or new hook file at or above 93.64% | 100% of changed lines covered (no uncovered changed line in any of the 7 targeted files) |
| Python | 2 test files (0 production) | 6595 executor; 148 reviewer (follow-up, adoption-gate, and four parity files) | ✅ 6595 pass, 6 skipped (executor); 148 pass (reviewer) | 94% lines repo-wide | 93.63% lines repo-wide (16434/17552), unchanged production code | N/A - no production Python file changed |
| Bash | 1 production (`.codex/codex-web-setup.sh`, modified) + 1 mirror | 0 tests exercise the changed lines | ❌ syntax check only | N/A - the file is outside the shell-QC coverage discovery roots, so no kcov figure exists | N/A - no kcov measurement exists for the changed lines | N/A - the new solution-discovery branches have no test |
| JSON | 2 files (`core.json` x2) | N/A | ✅ manifest completeness and resource-contract pytest files pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - zero TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/baseline/coverage.2026-10-03T09-46.md` (merge base) and `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline/r1-coverage.2026-10-03T12-49.md` (cycle-1 start, 079ebb9f)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-10-03 13:39 local; reviewer re-parsed) and `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/r1-coverage-delta.2026-10-03T13-40.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (2026-10-03 13:41 local) and `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/r1-pytest.2026-10-03T13-40.md`
- Bash coverage artifact: none exists for `.codex/codex-web-setup.sh` (see gap G-3)
- Per-language comparison summary: section 1.2.1 below

---

## Executive Summary

Remediation cycle 1 closed the pass-1 blocker for its five reproduced forms (B1-B5 are denied on both runtimes), fixed the pass-1 advisory false positive (an expansion in the command position now needs a token-bounded command word), and delivered the two owner-posted scope extensions: worktree-gate operand resolution (AC-30..AC-33) and the #823 follow-ups (AC-34..AC-41). Format, analyze, all 486 tests in the 19 changed Pester suites, the Python checks, and mirror parity pass in reviewer re-runs.

The reaudit found three blocking findings:

1. **G-1 (code review CR-1).** The cycle adds a new allow branch to the three worktree-removal gates: when the raw operand reader reports `NoOperand`, the gate allows. The reader stops at `(`, `<`, and `>`, and cannot see an operand that `xargs` supplies. As a result, seven real worktree removals that the merge base denies are allowed at head (epic and parallel gates on Claude, and the Codex epic gate).
2. **G-2 (code review CR-2).** The R2 matcher does not recognize positional parameters (`$1`, `$@`, `$*`) or a command word reached through `xargs`. Four wrapped `gh issue create` forms that the merge base denies are allowed at head by the promotion hook on both runtimes.
3. **G-3.** The changed bash file `.codex/codex-web-setup.sh` has new branches with no test and no coverage measurement.

Each was reproduced through the real decision entry points against the merge base and head.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ⚠️ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`): bash changed lines lack tests and coverage
- ✅ `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (`.claude/rules/python.md`): test files only
- ⚠️ Bash (`.claude/rules/shell.md`): syntax clean; changed lines untested and unmeasured
- ✅ JSON: two manifest entries, validated by the pack-manifest completeness pytest files
- ✅ Canonical policy edits: within the owner authorization in issue comment 5970141337 (see section 2.6)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; the executor's step scripts lived in a scratch directory outside the repository
- ✅ Two committed JUnit files that carried host paths were removed in this cycle (`evidence/other/r1-junit-host-path-removal.2026-10-03T12-51.md`)
- The reviewer's probe scripts were written to the session scratchpad only

## Rejected Scope Narrowing

None detected in the caller prompt. The caller supplied the base branch, merge base, head SHA, PR-context artifacts, AC source (including the Scope Extension), and prior-pass artifacts, and did not narrow scope to a plan, task, phase, file subset, or language.

One executor evidence record marks a changed language as not applicable. The reviewer did not adopt it: `evidence/qa-gates/r1-sh-syntax.2026-10-03T13-41.md` states "Bash coverage: N/A - .codex/codex-web-setup.sh is outside the shell-QC discovery roots". Bash has a changed file on the branch, so this audit records an explicit FAIL verdict for Bash coverage (G-3).

## Evidence Location Compliance

- Branch diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: zero files.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`: exit 0, no violations reported.
- All feature evidence is under `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each new `It` builds its own command string or CLAUDE.md text and calls a pure seam; checkpoint seams are mocked per `BeforeEach`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Unit rows drive `Test-CommandLineRawInvocation`, `Get-CommandLineRawInvocationOperand`, or `Get-FeatureReviewCoverageThreshold`; hook rows drive one decision seam with one command each. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The 19 changed suites (486 tests) ran in one reviewer run of a few minutes; the 148 Python cases ran in 0.50 s. |
| **Determinism** - Consistent results | ✅ PASS | Pure string inputs; no clock, RNG, network, child process, or temporary file. The Python file reads committed files only. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row IDs (A824-WT3..WT9, F824-1..9, T824-*, B-rows) and `-Because` messages state the expected behavior. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 84.67% lines at the merge base and 84.72% at cycle start (079ebb9f); Python 94%.<br>**Timestamp:** 2026-10-03 09:46 and 12:49 (`evidence/baseline/coverage.2026-10-03T09-46.md`, `evidence/remediation-baseline/r1-coverage.2026-10-03T12-49.md`). |
| **No Coverage Regression** | ✅ PASS | PowerShell 85.46% repo-wide (+0.79 points over the merge base). Every targeted hook file is at or above its cycle-start figure; `validate-feature-review-coverage.ps1` rose from 49.52% to 95.28%. The reviewer re-parsed the JaCoCo XML and reproduced each figure. |
| **New Code Coverage** | ⚠️ PARTIAL | PowerShell: both raw-invocation modules 78/78 lines, `feature-review-coverage-thresholds.ps1` 21/21, no uncovered changed line. Bash: the new `SOLUTION_FILE` discovery and the two new no-solution branches in `.codex/codex-web-setup.sh` have no test and no measurement (G-3). |
| **Comprehensive Coverage** | ⚠️ PARTIAL | Line coverage of the matcher is 100%, but the bypass forms in G-1 and G-2 are not exercised and are not detected. |
| **Positive Flows** - Valid inputs | ✅ PASS | Deny rows for B1-B5 and the five AC-31 forms on all three gates; allow rows with an authorizing record (A824-WT5-1..5). |
| **Negative Flows** - Invalid inputs | ✅ PASS | Addendum reproduction allowed (A824-WT3) with a containment negative control; CR-2 forms allowed (A824-WT9 and the promotion equivalent). |
| **Edge Cases** - Boundary conditions | ❌ FAIL | Redirection or a PowerShell subexpression before the operand, and `xargs`-supplied operands, are not covered. The gates allow them (G-1). Positional-parameter and `xargs` forms of `gh issue create` are not covered, and the promotion hook allows them (G-2). |
| **Error Handling** - Error paths | ✅ PASS | Unbalanced segments remain fail-closed (`Resolve-CommandLineWrappedInvocationOperand` returns NotApplicable for them). Indeterminate operands keep the structural deny path. |
| **Concurrency** - If applicable | N/A | Pure stateless string functions. |
| **State Transitions** - If applicable | N/A | No state. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 84.67% lines (merge base) -> Post-change: 85.46% lines. Change: +0.79% lines. New/changed-code coverage: 100% (no uncovered changed line across the 7 targeted files; new modules 78/78 and 21/21 lines). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/r1-coverage-delta.2026-10-03T13-40.md`.
- Python: Baseline: 94% lines -> Post-change: 93.63% lines (94% as reported by pytest-cov; production Python is unchanged). Change: none attributable to the branch. New/changed-code coverage: no production Python line changed, so there is no new production code to measure; only test files changed. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/r1-pytest.2026-10-03T13-40.md`.
- Bash: Baseline: N/A - no kcov figure exists. Post-change: N/A - no kcov figure exists. Change: the solution-file discovery logic and two new no-solution branches were added with no test. Disposition: FAIL. Evidence: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/r1-sh-syntax.2026-10-03T13-41.md` (syntax only; `.codex/` is outside the shell-QC discovery roots in `.claude/rules/shell.md`).

Threshold note: per the threshold precedence (the root `CLAUDE.md` states no figures), the governing thresholds are 85% line and 75% branch. PowerShell repo-wide is now 85.46%, so the pass-1 gap G-2 (84.72%) is closed. Pester emits no BRANCH counter, so no branch threshold applies to PowerShell. `artifacts/python/lcov.info` carries no branch records (BRF 0), so no Python branch percentage is available. The branch changes no production Python line, so this does not affect the Python verdict. It is a pre-existing measurement configuration.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | New assertions carry `-Because` text; Python assertions carry f-string messages naming the file and the offending token. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New `It` blocks and pytest functions carry Arrange/Act/Assert comments. |
| **Document Intent** | ✅ PASS | Suite synopsis blocks and the Python module docstring describe purpose and the no-I/O constraints. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No `gh`, network, git process, or filesystem write in any new test. |
| **Use Mocks/Stubs** | ✅ PASS | Checkpoint-reader and run-target seams are mocked; the feature-review hook tests supply CLAUDE.md text and coverage XML as strings. |
| **Environment Stability** | ✅ PASS | No temporary files; no environment variable reads in tests. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the pass-2 policy audit. Outstanding items: G-1, G-2, G-3. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` (AC-1..AC-29) plus the `## Scope Extension` section (AC-30..AC-41), copied verbatim from owner comments 5970085575 and 5970141337 (reviewer fetched both through `gh api`; author `drmoisan`). |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-10-03T10-30.md` (preflight all clear, round 4) and `evidence/remediation-baseline/phase0-instructions-read.md`. |
| **Document the plan** | ✅ PASS | Remediation plan committed in 079ebb9f before the code change. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ⚠️ PARTIAL | The matcher now has two forms (sequence and absorption) plus an operand reader. Each added form fixes a reproduced case, but the result is still a list of recognized spellings rather than a closed rule (see code review CR-1, CR-2). |
| **Reusability** | ✅ PASS | `Resolve-CommandLineWrappedInvocationOperand` is shared by all three gates; `Get-FeatureReviewCoverageThreshold` is a reusable pure module. |
| **Extensibility** | ✅ PASS | Pattern construction is parameterized by command word, subcommand path, and absorption index. |
| **Separation of concerns** | ✅ PASS | Pure string logic in its own modules; the hook supplies the CLAUDE.md text to the threshold resolver. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Raw-text matching and operand reading in `hook-command-raw-invocation.ps1`; threshold resolution in `feature-review-coverage-thresholds.ps1`. |
| **Under 500 lines** | ✅ PASS | Largest changed files: `test_push_down_tier_rule_adoption_gate.py` 493, `hook-command-invocation.ps1` 491, `enforce-parallel-worktree-removal-gate.ps1` 481, `validate-feature-review-coverage.ps1` 471, `.codex/codex-web-setup.sh` 394, `hook-command-raw-invocation.ps1` 298 (`r1-line-counts.2026-10-03T13-41.md`, spot-checked by the reviewer). |
| **Public vs internal** | ✅ PASS | Pinned public signatures unchanged (AC-29 pin tests pass without edits). `Test-LanguageCoverageRow` gains two optional parameters with defaults equal to the previous constants. |
| **No circular dependencies** | ✅ PASS | `hook-command-raw-invocation.ps1` calls `Resolve-CommandLineInvocation` at call time only; the dependency is documented in its synopsis. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs; `Get-CommandLineRawInvocationOperand`, `Resolve-CommandLineWrappedInvocationOperand`, `Get-FeatureReviewCoverageThreshold`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every new function; the hook docstring now states the precedence and per-metric fallback (AC-34). |
| **Comment why, not what** | ⚠️ PARTIAL | The gate comment says "a wrapped match that names no operand removes nothing and is allowed". The probe shows this does not hold when the operand follows a redirection or subexpression, or comes from `xargs` (G-1). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter` check-only with `pssa.settings.psd1` on the 28 changed non-mirror `.ps1` files (reviewer); `black --check` on the 2 Python files (reviewer).<br>**Result:** 0 drift; "2 files would be left unchanged". |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1 -Severity Error, Warning, Information` (reviewer); `ruff check` (reviewer).<br>**Result:** 0 findings; "All checks passed!". |
| **3. Type checking** | ✅ PASS | **Command:** `pyright` on the 2 Python files (reviewer).<br>**Result:** 0 errors, 0 warnings. PowerShell has no type-check stage. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-Pester` on the 19 changed suites (reviewer); `pytest` on 6 files (reviewer); executor `Invoke-PoshQCTest -Root .` and full `pytest`.<br>**Result:** 486/486 and 148/148 (reviewer); 6753 and 6595 pass, 0 failures (executor). |
| **Full toolchain loop** | ✅ PASS | Two executor loop passes; pass 2 clean (`evidence/qa-gates/r1-qc-loop-complete.2026-10-03T13-42.md`). |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/qa-gates/` and in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit c7b78cd2 message; `evidence/other/containment-path-hook-audit.md` updated for the gate change. |
| **Design choices explained** | ✅ PASS | `remediation-plan.2026-10-03T10-30.md` and the module synopsis. |
| **Update supporting documents** | ✅ PASS | Follow-ups file marks FU-823-1, -2, -3, -5 resolved and FU-823-4 open (AC-40). |
| **Canonical policy edits authorized** | ✅ PASS | `.github/instructions/csharp-*.instructions.md` (FU-823-3, explicitly authorized), `.claude/rules/architecture-boundaries.md` (FU-823-2, listed), and `.claude/rules/{quality-tiers,general-unit-test}.md` (review note A, "Apply the wording in every surface that carries it"). Each edit is limited to the named lines (`evidence/other/r1-canonical-edit-callout.2026-10-03T13-44.md`). The PR body must carry the callout. |
| **Provide next steps** | ⚠️ PARTIAL | The six spec Non-Goals follow-ups are still not filed as potential records (pass-1 advisory A3). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 drift on 28 changed files (reviewer); executor `Invoke-PoshQCFormat` clean on pass 2. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings (reviewer and executor). |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | `[regex]`, `StringBuilder`, `HashSet[string]`, and `NumberStyles` are available in both editions; no 7-only syntax in the production modules. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every new function uses `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `ValidateNotNullOrEmpty`, `ValidateRange(-1, 64)`, `AllowEmptyString`/`AllowNull` where needed. |
| **Avoid global state** | ✅ PASS | No new script or global variables. |
| **Error handling** | ❌ FAIL | Fail-closed handling is incomplete in the gates. The operand reader reports `NoOperand` for a present but unparsed operand, and the gates allow on `NoOperand`. This converts "cannot read the operand" into "no removal" (G-1). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 298, 68, and 491 lines for the shared modules. |
| **Approved verbs** | ✅ PASS | `Get`, `Test`, `Resolve`. |
| **Comment why** | ⚠️ PARTIAL | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 3B.1. |
| **Step 2: Analyze** | ✅ PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 6753 total, 0 failures (executor); 486/486 (reviewer). |
| **Rerun loop if needed** | ✅ PASS | Loop restarted once after a ruff finding; pass 2 clean. |

### Section 3A: Python Code Change Policy Compliance (test files only)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting (Black)** | ✅ PASS | 2 files unchanged (reviewer). |
| **Linting (Ruff)** | ✅ PASS | All checks passed; one `S105` suppression on a test-fixture constant with a justification comment. |
| **Type checking (Pyright)** | ✅ PASS | 0 errors. |
| **Typed signatures** | ✅ PASS | All functions annotated, `from __future__ import annotations`. |

### Section 3C: Bash Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Syntax** | ✅ PASS | `bash -n` exit 0 on both copies (`r1-sh-syntax.2026-10-03T13-41.md`). |
| **Strict mode preserved** | ✅ PASS | `set -euo pipefail` unchanged; `compgen -G` is inside an `if !` test and the `find` pipeline exits 0 on an empty result. |
| **Tests for changed behavior** | ❌ FAIL | No bats test drives `SOLUTION_FILE` discovery or the two new no-solution branches. The existing `tests/shell/test_codex_web_setup_*.bats` source `.github/codex/codex-web-setup.sh`, a separate copy (G-3). |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | `evidence/qa-gates/r1-manifest-json.2026-10-03T13-41.md`. |
| **Schema validation** | ✅ PASS | Pack-manifest completeness pytest files pass (reviewer). |
| **Required $schema** | N/A | Pack manifests are not schema-governed files. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | No comments or trailing commas. |
| **Deterministic key order** | ✅ PASS | Path lists remain alphabetical. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules Pester 5.0.0`; `-ForEach` data rows. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .` (executor, direct module invocation after the MCP route).<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; the new modules appear in the canonical artifact. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Test files declare `#Requires -Version 7.0`, matching the existing hook suites. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Unit rows per module plus hook-level rows. |
| **Test Behavior Over Implementation** | ✅ PASS | Tests assert decisions, classifications, and resolved thresholds. |
| **Mocking Used Sparingly** | ✅ PASS | Only checkpoint, run-target, and artifact seams. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`<br>**Code file:** `.claude/hooks/feature-review-coverage-thresholds.ps1`<br>Follows the established hook test-tree convention. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | New Contexts per addendum and authorization state. |
| **Logical Grouping** | ✅ PASS | "no authorizing record" and "authorizing record present" Contexts. |
| **Docstrings/Comments** | ✅ PASS | Synopsis blocks and row labels. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** 6753 total, 0 failures. |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | ✅ PASS | Parametrized pytest functions; 148 pass (reviewer). |
| **No temporary files** | ✅ PASS | The module reads committed files only. |
| **Discriminating checks** | ✅ PASS | `test_consuming_product_detection_flags_a_reintroduced_name` and `test_retired_threshold_scan_reads_coverage_context_only` prove the scans can fail. |

---

## 5. Test Coverage Detail

### hook-command-raw-invocation.ps1 (both runtimes)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| R824-P*, R824-N* and cycle-1 absorption rows | Positive, negative, edge | 43-194 | ✅ |
| Operand reader rows and gate rows A824-WT3..WT9 | Operand, NoOperand, Indeterminate | 196-298 | ✅ |

**Coverage:** 78/78 lines on each runtime.

**Not covered (behavior):** redirection or a subexpression before the operand, `xargs`-supplied operands, positional parameters, and `xargs`-led command words (G-1, G-2).

### validate-feature-review-coverage.ps1 and feature-review-coverage-thresholds.ps1

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| F824-1..F824-3 | Lower figures, no figures, line-only figure | precedence path | ✅ |
| F824-4..F824-9, F824-V* | Coverage parsing and audit-row rules | validation path | ✅ |
| T824-* | Threshold resolver rows | 18-68 | ✅ |

**Coverage:** 202/212 and 21/21 lines.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 6753 Pester and 6595 pytest (executor); 486 Pester and 148 pytest (reviewer) | ✅ |
| Tests Passed | 100% of enabled tests | ✅ |
| Tests Failed | 0 | ✅ |
| Issue824-tagged tests | 224 (reviewer count across the 19 changed suites) | ✅ |
| Execution Time | a few minutes for the 19 suites; 0.50 s for pytest | ✅ Fast |
| Test File Size | max 493 lines | ✅ Maintainable |
| Code Coverage (if applicable) | PowerShell 85.46% repo-wide, 100% changed lines; Bash changed lines not measured | ⚠️ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | check-only with `pssa.settings.psd1` | 0 of 28 files drift | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with `pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `Invoke-Pester` on 19 changed suites | 486/486 | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check` | 2 unchanged | ✅ |
| Ruff | `poetry run ruff check` | All checks passed | ✅ |
| Pyright | `poetry run pyright` | 0 errors | ✅ |
| Pytest | `poetry run pytest` on 6 files | 148 passed | ✅ |

**Notes:** Mirror parity: all 24 changed canonical files under `.claude`, `.codex`, `.agents`, and `.github` are byte-identical to their bundled mirrors. Each of the four `hook-command-raw-invocation.ps1` and `hook-command-invocation.ps1` copies yields one distinct SHA-256. No PR exists for the branch, so CI (AC-27) has not run.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **G-1 (Blocking, autonomous) - worktree-removal gates allow real removals through the new NoOperand branch.** Reviewer probe, no authorizing record (checkpoint names a different worktree), merge base `f6ef5b2f` versus head `c7b78cd2`, through `Invoke-EpicWorktreeRemovalGateDecision` and `Invoke-ParallelWorktreeRemovalGateDecision`: seven commands are denied at base and allowed at head on both Claude gates. Three of them were also confirmed on `Invoke-CodexWorktreeRemovalDecision`. The control `bash -c "git worktree remove <path>"` is denied at both commits. See code review CR-1 and remediation inputs R1.
- **G-2 (Blocking, autonomous) - R2 matcher misses positional-parameter and xargs-led invocations.** Four `gh issue create` forms are denied at base and allowed at head through `Invoke-PromotionMcpOnlyDecision` on both runtimes. The same shared helper serves every R2 caller. See code review CR-2 and remediation inputs R2.
- **G-3 (Blocking, autonomous) - Bash changed lines untested and unmeasured.** `.codex/codex-web-setup.sh` gains `SOLUTION_FILE` discovery and two new failure or skip branches with no test. Bash coverage verdict: FAIL. See remediation inputs R3.
- **G-4 (Non-blocking) - policy conflict on bash coverage scope.** The shell-QC discovery roots in `.claude/rules/shell.md` exclude `.codex/`, while the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` admits no excluded production file. Resolving this needs a policy decision by the owner. Recommended as a follow-up record.
- **G-5 (Non-blocking) - residual product names outside the FU-823-2 set.** `.claude/rules/typescript.md` line 57 still refers to "the No-COM architecture assertions" in `architecture-boundaries.md`, whose heading this branch renamed to "Host-Neutral Architecture Rules". `.claude/rules/csharp.md` lines 5 and 10 name No-COM. The bundled copies of both files match. Neither file is in the owner's listed set, and rule edits beyond it are not authorized, so these are follow-up items.
- **G-6 (Non-blocking) - Codex feature-review coverage hook unchanged.** `.codex/hooks/validate-feature-review-coverage.ps1` still compares against a fixed 80% floor (lines 23-24, 195, 200, 280) and does not apply the threshold precedence. FU-823-1 named only the `.claude` hook. Recommended as a follow-up record.
- **G-7 (Non-blocking) - spec Non-Goals follow-ups not filed** (carried from pass 1).

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None.** No test was removed or skipped; the disabled-test count matches the baseline.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **d058a196** - docs(824): add promoted potential record and active feature folder scaffold
2. **ff807f73** - docs(824): add research and spec for raw-containment false-positive deny
3. **c348e494** - docs(824): add approved atomic plan (preflight all clear, round 2)
4. **90566dd4** - fix(824): replace R2 raw containment with a token-aware sequence matcher
5. **cab81581** - docs(824): add feature-review pass 1 artifacts and spec scope extension
6. **079ebb9f** - docs(824): add remediation cycle 1 plan (preflight all clear, round 4)
7. **c7b78cd2** - fix(824): restore wrapped-bypass detection and extend to removal gates

### Files Modified

1. Shared helper and raw-invocation module (both runtimes): absorption form, command-position guard, operand reader, wrapped-operand resolver.
2. Epic and parallel worktree-removal gates (Claude) and the Codex epic gate: wrapped operand lookup and the NoOperand allow branch.
3. `validate-feature-review-coverage.ps1` and the new `feature-review-coverage-thresholds.ps1`: threshold precedence (FU-823-1).
4. Rule, skill, agent, and instruction text for FU-823-2, FU-823-3, FU-823-5, and review note A; `.codex/codex-web-setup.sh` solution discovery.
5. Bundled mirrors and both pack manifests.
6. 19 Pester suites and 2 Python test files.
7. Feature folder documents and evidence.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain, PowerShell and Python coverage, structure, parity, canonical-edit authorization, and evidence-location requirements are met. Three blocking findings (G-1, G-2, G-3) require remediation before the branch is ready for a PR.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, scope extension, and preflighted remediation plan present
- ⚠️ Design Principles: matcher growth by enumerated spellings
- ✅ Module & File Structure: every file at or below 493 lines
- ⚠️ Naming, Docs, Comments: the NoOperand comment overstates what the reader proves
- ✅ Toolchain Execution: clean loop
- ⚠️ Summarize & Document: Non-Goals follow-ups not filed

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean
- ❌ PowerShell Design & Safety: NoOperand allow is not fail-closed (G-1)
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: clean

**For Python:** ✅ test files clean under Black, Ruff, Pyright

**For Bash:** ❌ changed branches untested (G-3)

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, deterministic
- ❌ Coverage & Scenarios: bypass edge cases (G-1, G-2) and bash changed lines (G-3)
- ✅ Test Structure: AAA and `-Because` messages
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC
- ✅ Test Style & Structure: behavior-focused rows
- ✅ Naming & Readability: row IDs and labels
- ✅ Toolchain: 6753 total, 0 failures

---

### Metrics Summary

- ✅ 6753 Pester and 6595 pytest tests, 0 failures (executor); 486 and 148 (reviewer)
- ✅ PowerShell 85.46% repo-wide; 100% of changed PowerShell lines covered
- ✅ Format, analyze, type-check, and parity checks pass
- ❌ Seven worktree-removal regressions on each Claude gate, three confirmed on the Codex gate (G-1)
- ❌ Four promotion-hook regressions on each runtime (G-2)
- ❌ Bash changed lines unmeasured (G-3)

---

### Recommendation

**Needs revision**

Remediate R1-R3 in `remediation-inputs.2026-10-03T13-56.md`. Make the gate operand reader fail closed. Extend the R2 matcher to positional parameters and `xargs`-led command words. Add bats tests and a recorded kcov measurement for the changed bash lines. Add deny rows for every reproduced form on every runtime, then re-run the toolchain and request a reaudit.

---

## Appendix A: Test Inventory

### Complete Test List

1. hook-command-raw-invocation (both runtimes): positive, negative, absorption, command-position, and operand rows
2. hook-command-invocation (both runtimes): N824-1 negative control; renamed token-aware sequence test
3. enforce-promotion-mcp-only trigger scoping (both runtimes): P824-A*, P824-D*, B1-B4 deny rows, CR-2 allow row
4. enforce-pr-author-skill trigger scoping: A824-PR1
5. enforce-epic-worktree-removal-gate trigger scoping (both runtimes): A824-WT1..WT9, A824-WT4-1..5, A824-WT5-1..5, B5
6. enforce-parallel-worktree-removal-gate trigger scoping: same rows as the epic gate
7. validate-bash trigger scoping (both runtimes): A824-VB1
8. enforce-orchestration-preimplementation-gate trigger scoping (both runtimes): A824-PI1
9. enforce-epic-merge-gate trigger scoping (both runtimes): A824-MG1
10. validate-feature-review-coverage.Issue824: F824-1..F824-9, F824-V*
11. feature-review-coverage-thresholds: T824-*
12. legacy-codex-hook-contracts: SharedModuleNames row
13. test_push_down_issue_824_follow_ups.py: 40 cases; test_push_down_tier_rule_adoption_gate.py: coverage-context narrowing

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting (check-only, reviewer)
Invoke-Formatter -ScriptDefinition (Get-Content <file> -Raw) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting (reviewer)
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information

# Tests (reviewer, the 19 changed suites)
$c = New-PesterConfiguration; $c.Run.Path = <19 suite paths>; Invoke-Pester -Configuration $c

# Base-versus-head decision probe (reviewer)
git archive f6ef5b2f .claude/hooks .claude/lib .codex   # extracted into the session scratchpad
Invoke-EpicWorktreeRemovalGateDecision / Invoke-ParallelWorktreeRemovalGateDecision / Invoke-CodexWorktreeRemovalDecision / Invoke-PromotionMcpOnlyDecision

# Full PoshQC loop (executor)
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

**For Python:**
```bash
poetry run black --check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py
poetry run ruff check <same files>
poetry run pyright <same files>
poetry run pytest -p no:cacheprovider <the two files plus the four push-down parity files>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

**For Bash:**
```bash
bash -n .codex/codex-web-setup.sh   # executor, syntax only
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-03
**Policy Version:** Current (as of audit date)
