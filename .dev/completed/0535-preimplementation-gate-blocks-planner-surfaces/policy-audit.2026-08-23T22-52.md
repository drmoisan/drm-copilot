# Policy Compliance Audit: Preimplementation Gate Blocks Planner Surfaces (Issue #535)

**Audit Date:** 2026-08-23
**Code Under Test:**
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified, +71/-1)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified, +71/-1, byte-identical mirror)
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified, +72/-1)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified, +72/-1, byte-identical mirror)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (modified, +156/-0)
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (modified, +16/-0)
- Plus 25 Markdown documentation/evidence files under `docs/features/` (no toolchain gate applies to Markdown)

**Baseline:** `main` at merge-base `e96e32e01662035faacec460a12441b253b6f3b2`; head `bug/preimplementation-gate-blocks-planner-surfaces-535` at `d6aece5b8ee10f3f791491311b3d8fa5b9c82840`. Scope is the full branch diff against the resolved base; no caller-supplied scope narrowing was attempted or accepted.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 6 files (4 production hooks, 2 test suites) | 1532 tests | ✅ 1532 pass, 0 fail | 88.37% lines (`.claude` hook), 100.00% lines (`.codex` hook) | 90.00% lines (`.claude` hook), 99.18% lines (`.codex` hook) | 95.83% (46/48 added measurable lines across both canonical hooks) |

PowerShell is the only language with changed production or test files in the branch diff. The Markdown files carry no coverage obligation. Two Python push-down contract suites were executed as verification gates for the bundle mirrors, but zero Python files changed, so Python coverage is N/A (zero changed files).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero TypeScript files changed on this branch)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero TypeScript files changed on this branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/baseline/baseline-pester-claude-hooks.2026-08-23T21-28.md` and `evidence/baseline/baseline-pester-codex-hooks.2026-08-23T21-30.md` (per-file LINE counters from `artifacts/pester/powershell-coverage.xml`)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (re-parsed during this audit: `.claude` hook 99/110 = 90.00%, `.codex` hook 121/122 = 99.18%), summarized in `evidence/qa-gates/final-pester.2026-08-23T22-12.md`
- Per-language comparison summary: section 1.2.1 of this audit, backed by `evidence/qa-gates/coverage-delta.2026-08-23T22-14.md`

**Non-negotiable verdict rule:** This audit reports numeric baseline and post-change coverage for the sole in-scope language (PowerShell) plus changed-code coverage.

**Fail-closed rule acknowledgement:** All required baseline, QA, and coverage-comparison artifacts exist on disk and were inspected; none was synthesized.

---

## Executive Summary

This branch fixes issue #535: the PreToolUse preimplementation gate denied every multi-item planning surface. The fix (a) widens the exempt checkpoint set in `Test-ImplementationPath` from one literal to a seven-literal membership check over `$script:CheckpointPaths`, and (b) adds a field-scoped three-conjunct `Test-PreparationModeDelegation` predicate evaluated before the unchanged whole-payload regex in `Test-ImplementationDelegation`. The identical behavioral change lands in all four hook copies; both canonical/bundle pairs are SHA256 byte-identical (verified independently during this audit: Claude pair `f57fae11...`, Codex pair `e8a2dfc7...`).

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A Python, TypeScript, C#, Bash, JSON: zero changed files in those languages on this branch (the two `.json`-free hook edits and Markdown docs are the whole diff)

Toolchain evidence: PoshQC format clean (no file changed), analyze clean (0 findings), Pester 1532/1532 pass with per-file line coverage 90.00% and 99.18% on the two canonical changed hooks. Fail-before evidence exists (exit 4 with exactly the four new allow cases failing against the unfixed hook). Push-down parity pytest suites pass 12/12.

**Reviewer verification performed independently:** branch diff re-derived with `git diff e96e32e0..HEAD`; hashes recomputed with `sha256sum`; per-file coverage re-parsed from `artifacts/pester/powershell-coverage.xml`; kickoff-marker literals re-checked against `.claude/skills/parallel-plan/SKILL.md:105` and `.claude/skills/epic-plan/SKILL.md:99`; evidence locations re-scanned with `python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0).

**Temporary artifacts cleanup:**
- ✅ No temporary/one-time scripts remain; working tree is clean at head
- ✅ The transient `.claude/state/powershell-batch-budget.default.json` session state file was removed (documented in `evidence/other/batch-budget-reset.2026-08-23T21-54.md` and `evidence/qa-gates/pushdown-parity.2026-08-23T22-18.md`); it is gitignored and untracked

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 during this audit.
- The branch diff was scanned for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, and `artifacts/coverage/`: zero such files exist in the diff. All 21 evidence artifacts live under the canonical `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/<kind>/` scheme.
- No caller-supplied non-canonical evidence path was received; no override rejection was necessary.
- Verdict: PASS.

## Policy Rule: modified-workflow-needs-green-run

The branch diff contains no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (verified against `git diff --name-status e96e32e0..HEAD`). The rule does not fire. No green-run evidence is required.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | All new cases are pure-seam invocations of `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ... -CheckpointRaw ...`; no shared mutable state between `It` blocks. Deny and allow cases each construct their own payload and checkpoint. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One decision assertion per `It`; the seven-literal allow case iterates a table but asserts one behavior (checkpoint exemption) with a per-literal `-Because` message. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Scoped Claude suite: 35 tests in 0.931s; full two-folder run: 1532 tests in 90.8s (`evidence/qa-gates/final-pester.2026-08-23T22-12.md`). |
| **Determinism** - Consistent results | ✅ PASS | Every new case supplies an explicit `-CheckpointRaw` (not-ready via `ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false`), removing dependence on the on-disk checkpoint. The fail-before artifact records that an earlier draft without `-CheckpointRaw` was environment-dependent and was corrected before evidence capture. No disk I/O, child processes, or temporary files in the new cases. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Two named `Context` blocks (`issue #535 checkpoint write exemptions`, `issue #535 preparation-mode delegation exemption`); descriptive `It` names; `-Because` messages state rationale. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** `.claude` hook 76/86 = 88.37% lines; `.codex` hook 98/98 = 100.00% lines.<br>**Command:** `mcp__drm-copilot__run_poshqc_test` scoped per suite, per-file LINE counters from `artifacts/pester/powershell-coverage.xml`.<br>**Timestamp:** 2026-08-23 21:28 / 21:30. |
| **No Coverage Regression** | ✅ PASS | **Post-change:** `.claude` 99/110 = 90.00% (+1.63 points); `.codex` 121/122 = 99.18% (percentage delta -0.82 points caused solely by 24 new measurable lines entering the denominator).<br>**Changed-line rule:** every line covered at baseline remains covered in both files; covered-line counts rose 76→99 and 98→121. No regression on changed lines. |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** the four hook copies (two canonical measured, two mirrors inherit by byte-identity) and two test suites.<br>**New code coverage:** 46/48 added measurable lines covered = 95.83%.<br>**Calculation method:** per-file added-line accounting in `evidence/qa-gates/coverage-delta.2026-08-23T22-14.md`; the two uncovered lines are the defensive `Write-Debug` in each copy's extraction-failure catch (`.claude` line 157, `.codex` line 174), unreachable through the pure seam without a payload whose property getter throws. |
| **Comprehensive Coverage** | ✅ PASS | `Test-ImplementationPath` widened branch: 7 allow literals x 2 spellings + 2 deny near-misses. `Test-PreparationModeDelegation`: both allow kickoffs plus 5 spoof/near-miss denials plus direct null/one-marker predicate assertions in the codex contract suite. Untested: the two `Write-Debug` catch lines (justified above). |
| **Positive Flows** - Valid inputs | ✅ PASS | 7-literal allow (forward slash), 7-literal allow (backslash), verbatim parallel-plan kickoff allow, verbatim epic-plan kickoff allow, codex-side table-driven allow pair. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Deny: non-checkpoint `.json` under `artifacts/orchestration/`; checkpoint-named file outside the directory; wrong `subagent_type` with both markers; regex-matching prompt without markers; one-marker-only; marker without trailing period; markers in non-`prompt` field. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Backslash-spelling normalization; trailing-period strictness; field-scoping (marker in `description` while `prompt` matches the implementation regex). |
| **Error Handling** - Error paths | ✅ PASS | Pre-existing anomaly contexts re-run green: empty payload, unparseable JSON, flat root shape, malformed `-CheckpointRaw` all deny (`evidence/regression-testing/pass-after-claude.2026-08-23T21-52.md`). Codex suite adds direct `Test-PreparationModeDelegation` null-payload and one-marker false assertions. |
| **Concurrency** - If applicable | N/A | The hook is a stateless per-invocation decision function; no concurrent state. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 88.37% lines (`.claude` canonical hook) and 100.00% lines (`.codex` canonical hook) -> Post-change: 90.00% lines and 99.18% lines. Change: +1.63 points on the `.claude` copy and -0.82 points on the `.codex` copy from denominator growth only, with zero previously covered lines lost in either file. New/changed-code coverage: 95.83% (46/48 added lines). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-delta.2026-08-23T22-14.md`, `evidence/qa-gates/final-pester.2026-08-23T22-12.md`, `artifacts/pester/powershell-coverage.xml` (re-parsed by the reviewer).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `Should -Be 'allow' -Because "<literal> is an orchestration checkpoint, not an implementation file"` and analogous `-Because` clauses identify the failing case inside table-driven loops. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Each `It` arranges payload + checkpoint JSON, acts through the pure seam, asserts the decision (and deny-reason prefix where applicable). |
| **Document Intent** | ✅ PASS | Comments in the new `Context` blocks explain why the explicit not-ready checkpoint is load-bearing for determinism. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | New cases use no network, database, child process, or filesystem I/O; the decision seam takes raw JSON strings. |
| **Use Mocks/Stubs** | ✅ PASS | No mocks needed; the pure seam is the test boundary. Payloads are constructed literals. |
| **Environment Stability** | ✅ PASS | Explicit `-CheckpointRaw` on every new case removes the on-disk checkpoint dependence; no temporary files are created (prohibition upheld). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required policy review for the branch, produced before PR authoring. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #535; `issue.md` carries `- Work Mode: full-bug`; spec.md states scope, non-goals, and root cause. |
| **Read existing change plans** | ✅ PASS | Authoritative research at `research/2026-08-23T20-24-preimplementation-gate-blocks-planner-surfaces-research.md`; plan revised per `preflight-revisions.2026-08-23T21-30.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-08-23T20-40.md` (v1.1) with phase/task structure and evidence accounting; `evidence/baseline/phase0-instructions-read.md` records the policy reads. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One membership check over a literal array; one three-conjunct predicate; no configuration surface, no new module. |
| **Reusability** | ✅ PASS | Reuses `Get-ClaudeHookToolInputString` (Claude copy) and the file-local `Get-StringProperty` (Codex copy); reuses the predicate pattern from `enforce-epic-wave-barrier.ps1`. |
| **Extensibility** | ✅ PASS | A future checkpoint costs one literal plus one test; the literal-set shape composes with the deferred #516 normalization upstream. |
| **Separation of concerns** | ✅ PASS | Path classification, delegation classification, and readiness evaluation remain separate functions; readiness scalar `$script:CheckpointPath` retained distinctly from the exemption set. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | All changes are inside the single hook file per runtime plus its test suites. |
| **Under 500 lines** | ✅ PASS | Reviewer-recounted: 339, 339, 336, 336, 461, 494 lines (matches `evidence/qa-gates/scope-and-size.2026-08-23T22-16.md`). |
| **Public vs internal** | ✅ PASS | New helper is script-internal; the hook's external decision-JSON contract is unchanged. |
| **No circular dependencies** | ✅ PASS | No new imports; the Codex copy deliberately does not import `.claude/lib/hook-payload/HookPayload.psm1`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Test-PreparationModeDelegation` (approved verb), `$script:CheckpointPaths`, `$script:PreparationModeMarkers`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help with `.SYNOPSIS`/`.DESCRIPTION`/`.OUTPUTS` on the new function in both idioms. |
| **Comment why, not what** | ✅ PASS | Comments explain the bookkeeping-not-implementation rationale, the field-scoping spoof defense, and why the catch must never become an exemption. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` (repo scan set)<br>**Result:** exit 0, no file changed on final iteration (`evidence/qa-gates/final-poshqc-format.2026-08-23T22-06.md`). |
| **2. Linting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`<br>**Result:** exit 0, 0 findings on final iteration (`evidence/qa-gates/final-poshqc-analyze.2026-08-23T22-07.md`). |
| **3. Type checking** | N/A | Not applicable for PowerShell per `.claude/rules/powershell.md`. |
| **4. Testing** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` over `tests/scripts/claude-hooks` + `tests/scripts/codex-hooks`<br>**Result:** exit 0, 1532/1532 pass (`evidence/qa-gates/final-pester.2026-08-23T22-12.md`). |
| **Full toolchain loop** | ✅ PASS | Two iterations: iteration 1 surfaced a `.codex` changed-line coverage gap; after a 15-line test remediation the loop restarted from format and passed all stages clean in a single pass (iteration 2). |
| **Explicit reporting** | ✅ PASS | Every stage recorded with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` in `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Three commits with conventional messages (see section 9); spec.md Proposed Fix mirrors the landed design. |
| **Design choices explained** | ✅ PASS | Literal set vs prefix/glob, field-scoped predicate vs whole-payload regex, and retained readiness scalar are each justified in spec.md and in code comments. |
| **Update supporting documents** | ✅ PASS | Feature folder documents complete (issue.md, spec.md, plan, research, preflight revisions, 21 evidence artifacts). |
| **Provide next steps** | ✅ PASS | spec.md Rollout & Follow-up records the post-merge integration retest and the three known deferrals (#516, `git add|commit` gap, monotonicity gap). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format`<br>**Result:** clean at baseline and on the final iteration; no reformat needed. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`<br>**Result:** 0 findings at baseline and on the final iteration. |
| **Fix all findings** | ✅ PASS | No findings arose; no analyzer debt introduced. |
| **PowerShell 7+ compatible** | ✅ PASS | Membership `-contains`, `String.Contains`, and `foreach` are version-stable; PSScriptAnalyzer compatibility rules pass with repo settings. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `Test-PreparationModeDelegation` uses `[CmdletBinding()]`, `[OutputType([bool])]`, mandatory `$ToolInput` with `[AllowNull()]` in both copies. |
| **Parameter validation** | ✅ PASS | Mandatory + `[AllowNull()]` with an explicit null guard as the first conjunct. |
| **Avoid global state** | ✅ PASS | The two new script-scoped variables are write-once constant arrays, consistent with the pre-existing `$script:CheckpointPath` pattern; no mutation after initialization. |
| **Error handling** | ✅ PASS | The try/catch around the exemption probe fails closed: an extraction failure falls through to the stricter whole-payload regex and can never become an exemption. `Write-Debug` records the cause without changing the decision. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 339/339/336/336 production, 461/494 test lines; all under 500. |
| **Approved verbs** | ✅ PASS | `Test-` is the approved diagnostic verb; PSScriptAnalyzer confirms zero findings. |
| **Comment why** | ✅ PASS | Comments carry rationale (bookkeeping exemption, spoof defense, fail-closed catch), not narration. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Clean on the final iteration; `.codex` pair hash re-verified after each format run. |
| **Step 2: Analyze** | ✅ PASS | 0 findings on the final iteration. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 1532/1532 pass with coverage extraction. |
| **Rerun loop if needed** | ✅ PASS | Two iterations; restart-from-format honored after the coverage remediation edit. |

#### Change budget note

Four production PowerShell files exceed the direct-mode cap of 2. The plan settled this up front with two `powershell-typed-engineer` batches of at most 3 production files each, plus the plan-mandated session batch-budget state reset between batches (P2-T9, `evidence/other/batch-budget-reset.2026-08-23T21-54.md`) using the reset mechanism the enforcement hook's own deny message names. Recorded as an approved exception in section 8.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `Describe`/`Context`/`It`, `BeforeAll`, modern `Should` syntax with `-Because` throughout the new blocks. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; both canonical hook files are on the standing `CodeCoverage.Path` allow-list, so no configuration change was needed. |
| **PowerShell 7+ Compatible** | ✅ PASS | Same runner and settings as the rest of the suite; no version-specific constructs added. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 11 new Claude-suite cases across two contexts plus 1 codex-suite table-driven `It`; each targets one classifier behavior. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions target the decision JSON (`permissionDecision`, deny-reason prefix), not internals; the verbatim SKILL.md kickoff lines pin the external contract so marker drift breaks a test. |
| **Mocking Used Sparingly** | ✅ PASS | Zero mocks; the pure seam eliminates the need. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` mirrors **code file:** `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`; codex assertions extend the established `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` per that file's mechanism. Both extended in place; no colocation. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Both files follow the `*.Tests.ps1` convention (pre-existing files, extended in place). |
| **Describe/Context/It Structure** | ✅ PASS | 2 new `Context` blocks, 11 new `It` blocks (Claude suite), 1 new `It` (codex suite). |
| **Logical Grouping** | ✅ PASS | Checkpoint-exemption cases and delegation-exemption cases are grouped in separately named contexts keyed to issue #535. |
| **Docstrings/Comments** | ✅ PASS | Self-documenting `It` names plus intent comments for the determinism-critical checkpoint arguments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | All runs through `mcp__drm-copilot__run_poshqc_test`. |
| **No Alternative Test Runners** | ✅ PASS | Only Pester via PoshQC; the auxiliary pytest invocation exercised the pre-existing push-down contract suites, not PowerShell tests. |

---

## 5. Test Coverage Detail

### Test-ImplementationPath widened exemption (4 new tests, Claude suite)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| allows a Write to every exempt checkpoint literal with no ready checkpoint | Positive (x7 literals) | membership check + `$script:CheckpointPaths` | ✅ |
| allows the backslash spelling of every exempt checkpoint literal | Edge Case (x7 literals) | normalization + membership check | ✅ |
| denies a non-checkpoint .json under artifacts/orchestration/ | Negative | membership miss -> extension regex | ✅ |
| denies a checkpoint-named file outside artifacts/orchestration/ | Negative | full-path equality proof | ✅ |

### Test-PreparationModeDelegation (7 new tests, Claude suite; 1 table-driven It + 2 predicate assertions, codex suite)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| allows the verbatim parallel-plan preparation kickoff delegation | Positive | all three conjuncts true | ✅ |
| allows the verbatim epic-plan preparation kickoff delegation | Positive | all three conjuncts true | ✅ |
| denies both markers when subagent_type is not orchestrator | Negative | agent-conjunct rejection | ✅ |
| denies an orchestrator delegation matching the implementation regex without markers | Negative | marker-conjunct rejection -> regex fall-through | ✅ |
| denies an orchestrator delegation carrying only one preparation marker | Negative | marker loop early return | ✅ |
| denies a marker missing its trailing period | Edge Case | literal-match strictness | ✅ |
| denies markers placed in a non-prompt field | Negative | field-scoping proof | ✅ |
| codex: allows exempt checkpoint write and preparation-mode delegation (table) | Positive | codex-idiom decision path | ✅ |
| codex: `Test-PreparationModeDelegation` null payload / one marker return false | Negative | null guard (line 140), marker-missing branch (line 151) | ✅ |

**Coverage:** `.claude` hook 90.00% (99/110 lines); `.codex` hook 99.18% (121/122 lines).

**Not covered:** one defensive `Write-Debug` line per canonical copy (`.claude` 157, `.codex` 174) inside the extraction-failure catch; reaching it requires a payload whose property getter throws, which also breaks the subsequent `ConvertTo-Json`, so it is unreachable through the pure seam without a determinism-risk construct. Documented in `evidence/qa-gates/coverage-delta.2026-08-23T22-14.md`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (final two-folder run) | 1532 | ✅ |
| Tests Passed | 1532 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 90.8s total (two-folder run); 0.931s scoped Claude suite | ✅ Fast |
| Fail-before run | 35 tests, 4 expected failures (exit 4, expected 4) | ✅ |
| Codex contract suite | 43 tests, 0 failures | ✅ |
| Push-down parity pytest | 12 passed in 0.18s | ✅ |
| Test File Sizes | 461 and 494 lines | ✅ Maintainable |
| Code Coverage (changed canonical hooks) | 90.00% and 99.18% lines (no branch metric exists for Pester) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | exit 0, no file changed (final iteration) | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | exit 0, 0 findings (final iteration) | ✅ |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` (`tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`) | exit 0, 1532/1532 pass | ✅ |
| Push-down contracts | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | 12 passed | ✅ |
| Byte-identity (reviewer re-check) | `sha256sum` over the four hook copies | Claude pair equal (`f57fae11...`), Codex pair equal (`e8a2dfc7...`) | ✅ |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | ✅ |

**Notes:**
The push-down parity suite failed once on a transient gitignored `.claude/state/` session file that predated the run and is outside the diff; it was removed and the re-run passed 12/12 (`evidence/qa-gates/pushdown-parity.2026-08-23T22-18.md`). No pre-existing failures remain.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Repo-wide PowerShell aggregate is not measurable from the available artifact.** `artifacts/pester/powershell-coverage.xml` was produced by the plan-mandated scoped run over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`; instrumented files whose suites were outside that selection report zero execution, so the artifact's raw aggregate (61.83%) is a scoped-run artifact, not a repository-wide measurement, and supports no repo-wide claim in either direction. The gates this diff is subject to — per-changed-file line coverage >= 85% and no regression on changed lines — are fully evidenced and met (90.00%, 99.18%, zero lost lines). The full-suite repo-wide figure is produced by CI, which is not reachable from this environment (GitHub CLI unavailable). This is a measurement-scope limitation, not an observed threshold violation; no evidence indicates any repo-wide regression, since the diff only adds covered lines to two instrumented files.

### Approved Exceptions

- **Change budget (4 production PowerShell files > direct-mode cap of 2):** settled at planning time per the spec's explicit requirement, executed as two `powershell-typed-engineer` batches of <= 3 production files each with the plan-authorized session batch-budget reset between batches (P2-T9), using the reset mechanism named by the enforcement hook's own deny message. Evidence: `plan.2026-08-23T20-40.md` preamble, `evidence/other/batch-budget-reset.2026-08-23T21-54.md`.
- **One uncovered defensive line per canonical hook copy:** the `Write-Debug` in the extraction-failure catch, justified and documented in `evidence/qa-gates/coverage-delta.2026-08-23T22-14.md`; both files remain above the 85% threshold with no changed-line regression.

### Removed/Skipped Tests

**None.** No existing test was removed or weakened; the diff shows zero deletions in either test file (`git diff --numstat`: +156/-0 and +16/-0).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **fc68159f** - fix(hooks): exempt orchestration checkpoints and preparation kickoffs (Claude copies)
2. **192cb484** - fix(hooks): exempt orchestration checkpoints and preparation kickoffs (Codex copies)
3. **d6aece5b** - docs(535): add feature documentation and evidence for preimplementation-gate hook fix

### Files Modified

1. **`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`** (MODIFIED)
   - Added `$script:CheckpointPaths` (seven repo-relative literals) and replaced the single-literal equality with one `-contains` membership check; added `$script:PreparationModeMarkers` and `Test-PreparationModeDelegation`, called first in `Test-ImplementationDelegation` with a fail-closed catch.
2. **`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`** (MODIFIED)
   - Byte-identical mirror of the canonical Claude copy.
3. **`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`** (MODIFIED)
   - Same two behavioral exemptions in the Codex idiom (`Get-StringProperty` field reads; Codex transport and exit-code contract unchanged).
4. **`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`** (MODIFIED)
   - Byte-identical mirror of the canonical Codex copy, landed in the same commit.
5. **`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`** (MODIFIED, +156)
   - Two new `Context` blocks covering research groups 1-10 through the pure seam.
6. **`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`** (MODIFIED, +16)
   - One table-driven `It` for the two exemptions plus two direct predicate assertions; byte-identity `It` untouched.
7. **25 Markdown files** under `docs/features/` (NEW)
   - Feature folder documents (issue.md, spec.md, plan, research, preflight revisions), 21 evidence artifacts, and the promoted lifecycle record `docs/features/potential/promoted/2026-08-23-preimplementation-gate-blocks-planner-surfaces.md`.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All applicable policy gates for the sole in-scope language (PowerShell) pass on inspected evidence: clean single-pass toolchain (format, analyze, 1532/1532 tests), per-changed-file line coverage 90.00% and 99.18% against the uniform >= 85% threshold, no changed-line coverage regression, fail-before evidence with expected exit code, byte-identical canonical/bundle pairs re-verified by the reviewer, all files under 500 lines, canonical evidence locations, and no out-of-scope changes. The single documented limitation (no full-suite repo-wide aggregate in the scoped artifact) is a measurement-scope note, not an observed violation, and does not block PR readiness.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objective, research, and plan documented
- ✅ Design Principles: minimal enumerated exemptions over unchanged deny logic
- ✅ Module & File Structure: six files, all under 500 lines
- ✅ Naming, Docs, Comments: approved verbs, comment-based help, rationale comments
- ✅ Toolchain Execution: clean single pass on iteration 2
- ✅ Summarize & Document: complete feature folder and commit trail

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format/analyze clean at baseline and final
- ✅ PowerShell Design & Safety: advanced function, fail-closed catch, constant script scope
- ✅ Structure & Naming: cohesive, size-compliant, analyzer-clean
- ✅ Toolchain: MCP commands only, loop restarted correctly

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: deterministic pure-seam tests with explicit checkpoints
- ✅ Coverage & Scenarios: 13 case groups; thresholds met; no regression
- ✅ Test Structure: AAA with diagnostic `-Because` messages
- ✅ External Dependencies: none; no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester v5 via PoshQC settings
- ✅ Test Style & Structure: behavior-focused, mirrored locations, zero mocks
- ✅ Naming & Readability: named issue-#535 contexts, self-documenting `It` names
- ✅ Toolchain: PoshQC test runner only

---

### Metrics Summary

- ✅ 1532/1532 tests passing (100%)
- ✅ `.claude` hook 90.00% line coverage (baseline 88.37%); `.codex` hook 99.18% (baseline 100.00%, zero covered lines lost, denominator +24)
- ✅ Changed-code coverage 95.83% (46/48 added lines)
- ✅ 0 analyzer findings; formatter clean
- ✅ Byte-identity holds for both canonical/bundle pairs (reviewer re-verified)
- ✅ Fail-before evidence: exit 4 with exactly the four new allow cases failing pre-fix
- ✅ All six code files under 500 lines

---

### Recommendation

**Ready for merge** — every applicable gate passes on inspected evidence; no remediation triggers fired. Post-merge follow-up (already recorded in spec.md): integration retest that `/parallel-plan` reaches preparation fan-out, and the three known deferrals (#516 normalization, `git add|commit` housekeeping gap, non-standard checkpoint monotonicity).

---

## Appendix A: Test Inventory

New tests added by this branch (existing suites re-run unmodified):

1. enforce-orchestration-preimplementation-gate.ps1 › issue #535 checkpoint write exemptions › allows a Write to every exempt checkpoint literal with no ready checkpoint
2. enforce-orchestration-preimplementation-gate.ps1 › issue #535 checkpoint write exemptions › allows the backslash spelling of every exempt checkpoint literal
3. enforce-orchestration-preimplementation-gate.ps1 › issue #535 checkpoint write exemptions › denies a non-checkpoint .json under artifacts/orchestration/ (literal set, not directory prefix)
4. enforce-orchestration-preimplementation-gate.ps1 › issue #535 checkpoint write exemptions › denies a checkpoint-named file outside artifacts/orchestration/ (full-path equality)
5. enforce-orchestration-preimplementation-gate.ps1 › issue #535 preparation-mode delegation exemption › allows the verbatim parallel-plan preparation kickoff delegation with no ready checkpoint
6. enforce-orchestration-preimplementation-gate.ps1 › issue #535 preparation-mode delegation exemption › allows the verbatim epic-plan preparation kickoff delegation with no ready checkpoint
7. enforce-orchestration-preimplementation-gate.ps1 › issue #535 preparation-mode delegation exemption › denies both markers when subagent_type is not orchestrator
8. enforce-orchestration-preimplementation-gate.ps1 › issue #535 preparation-mode delegation exemption › denies an orchestrator delegation whose prompt matches the implementation regex without the markers
9. enforce-orchestration-preimplementation-gate.ps1 › issue #535 preparation-mode delegation exemption › denies an orchestrator delegation carrying only one preparation marker
10. enforce-orchestration-preimplementation-gate.ps1 › issue #535 preparation-mode delegation exemption › denies an orchestrator delegation whose first marker is missing its trailing period
11. enforce-orchestration-preimplementation-gate.ps1 › issue #535 preparation-mode delegation exemption › denies markers placed in a non-prompt field while prompt matches the implementation regex
12. Legacy Codex hooks use native lifecycle contracts › allows exempt checkpoint writes and preparation-mode delegations (issue #535)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (all via MCP):**
```text
mcp__drm-copilot__run_poshqc_format    # formatting (Invoke-Formatter via PoshQC)
mcp__drm-copilot__run_poshqc_analyze   # linting (PSScriptAnalyzer with repo settings)
mcp__drm-copilot__run_poshqc_test      # Pester v5 with standing CodeCoverage.Path allow-list
```

**Auxiliary verification:**
```bash
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
python scripts/dev_tools/validate_evidence_locations.py --root .
git diff --name-status e96e32e0..HEAD
sha256sum <the four hook copies>
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-08-23
**Policy Version:** Current (as of audit date)
