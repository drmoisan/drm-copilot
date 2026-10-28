# Policy Compliance Audit: pr-author issue-link, target derivation, and gh pr view allowlist (#989)

---

**Audit Date:** 2026-10-28
**Audit Type:** Re-audit after remediation cycle 1 (prior audit: `policy-audit.2026-10-28T13-58.md`; cycle inputs: `remediation-inputs.2026-10-28T13-58.md`; cycle plan: `remediation-plan.2026-10-28T13-58.md`)
**Branch:** `bug/pr-author-issue-link-target-derivation-and-view-allowlist-989` at `540819df84031888d4f297a7bf6be421e4e27be1`
**Base:** `main`, merge base `6c6aa4f0e123c25089f6669761d93d426eb4401c` (scope: `git diff 6c6aa4f0e123c25089f6669761d93d426eb4401c..HEAD`, 63 files, 3668 insertions, 64 deletions)
**Code Under Test:**

- PowerShell production (new): `.claude/hooks/enforce-pr-author-skill.current-branch.ps1`
- PowerShell production (modified): `.claude/hooks/enforce-model-routing-receipt.ps1`, `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- PowerShell bundle copies (byte-equal mirrors of the four files above) under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`
- PowerShell tests (new): `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1`, `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1`
- PowerShell tests (modified): `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`
- Markdown prose (and bundle mirrors): `.claude/agents/orchestrator.md`, `.claude/agents/pr-author.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/pr-author/SKILL.md`
- JSON: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one array entry)
- Feature documentation and evidence under `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/` and the promotion record `docs/features/potential/promoted/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist.md`

Cycle 1 delta (`git diff --stat bda84fbf4..HEAD`): 11 files, all under the feature folder (prior review artifacts, remediation inputs and plan, and new evidence records). No production code, test, or coverage configuration changed in cycle 1 (`evidence/qa-gates/scope-check.2026-10-28T14-28.md`; reviewer `git diff --name-status` confirms).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production (+4 bundle mirrors), 6 test files | 11448 (full run, `artifacts/pester/pester-junit.xml`) | PASS: 11448 tests, 0 failures, 0 errors, 10 disabled (pre-existing skips) | helpers 97.37% lines; allowlist 100.00% lines; model-routing 91.78% lines | Repo-wide 92.71% lines (17787/19185); helpers 97.41%; allowlist 100.00%; model-routing 96.43%; current-branch 95.45% | current-branch (new) 95.45% lines; changed lines in the three modified hooks 100% |
| JSON | 1 file | N/A | PASS: manifest completeness and dependency-closure tests (pytest 34 passed; Jest twin 24 passed) | N/A (config file) | N/A (config file) | N/A |
| Markdown | 8 prose files (4 + 4 mirrors) | 9 PC rows + AL-33 to AL-35 | PASS: 58 passed, 0 failed | N/A | N/A | N/A |
| TypeScript | 0 files | N/A | N/A (no changed files) | N/A | N/A | N/A |
| Python | 0 files | N/A | N/A (no changed files) | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A (no changed files) | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/evidence/baseline/pester-gss.2026-10-28T13-06.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (canonical, parsed directly by the reviewer) and `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/evidence/qa-gates/pester-full.2026-10-28T14-26.md`
- Per-language comparison summary: `evidence/qa-gates/coverage-comparison.2026-10-28T13-31.md`; Section 1.2.1 below

Coverage artifact verification (reviewer, direct parse, no coverage command run): `artifacts/pester/powershell-coverage.xml` has report name `Pester (10/28/2026 14:22:01)` and was last written 2026-10-28 14:22:27 UTC, after `evidence/qa-gates/pester-guards.2026-10-28T14-14.md` (14:10:10 UTC). The report-level counters are LINE covered 17787, missed 1398 (92.71%), over 216 source files. The per-file LINE counters are: `enforce-pr-author-skill-helpers.ps1` 113/116 (97.41%), `enforce-pr-author-skill.current-branch.ps1` 21/22 (95.45%), `enforce-pr-author-command-allowlist.ps1` 77/77 (100.00%), and `enforce-model-routing-receipt.ps1` 81/84 (96.43%). `artifacts/pester/pester-junit.xml` (last written 14:25:43 UTC) reports `tests="11448" errors="0" failures="0" disabled="10"`. These figures match the cycle-1 evidence record `pester-full.2026-10-28T14-26.md`. Prior finding PA-B1 is resolved.

---

## Rejected Scope Narrowing

None detected. The caller prompt states the full branch diff `git diff 6c6aa4f0e123c25089f6669761d93d426eb4401c..HEAD` as the scope. Its instruction to classify AC8 and GEN1 as `awaiting_ci` matches the acceptance-criteria-tracking skill's CI-dependent rule. Its instruction not to run any Pester or coverage command matches the review contract (verify from existing artifacts; do not rerun coverage generation). Neither instruction narrows the audit scope.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths (re-run in this review).
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (`git diff --name-status 6c6aa4f0e..HEAD` inspected; no `artifacts/` path is present).
- All evidence lives under `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/evidence/{baseline,qa-gates,regression-testing,other}/`, including the cycle-1 records `pester-guards.2026-10-28T14-14.md`, `pester-full.2026-10-28T14-26.md`, `scope-check.2026-10-28T14-28.md`, `self-review.2026-10-28T14-30.md`, and `phase0-instructions-read.2026-10-28T14-11.md`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root on the base commit. `.claude/hooks` is classified T3 and `extensions/drm-copilot` is classified T3, so the new sibling hook is covered by the existing path entry. T3 gates: no property-test density requirement, no mutation-score requirement, contract-bump rule not applicable. Verdict: PASS.

---

## Executive Summary

The branch fixes three defects in the orchestration and pr-author tooling: (1) a new Agent PreToolUse check in `enforce-model-routing-receipt.ps1` requires the `Author-asserted autoclose issues: #<issue-num>` line in `Agent(pr-author)` delegations; (2) `Resolve-PrAuthorWorktreeTarget` falls back to the current checked-out branch through a new never-throwing git seam in `enforce-pr-author-skill.current-branch.ps1`, and the `TARGET_WORKTREE_NOT_DERIVABLE` guidance names the accepted create and edit forms; (3) the pr-author allowlist permits exactly `gh pr view <N> --json closingIssuesReferences,body`, and the agent and skill require that verification after each create or edit.

Remediation cycle 1 regenerated the canonical PowerShell coverage artifact with one final full `tests/scripts` run. The reviewer parsed the artifact directly: repo-wide line coverage is 92.71%, and each changed hook file is at or above 95.45%. PA-B1 is resolved. No code changed in the cycle.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- PASS `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- PASS `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python changed)
- PASS `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A Bash (no shell scripts changed)
- PASS JSON: one manifest entry, verified by the manifest contract tests

Local evidence shows a clean seven-stage loop: format (0 rewrites), lint (0 findings), type check (PowerShell has no type-check stage), architecture guards (636 passed; guard suites re-run in cycle 1 before the final full run, `pester-guards.2026-10-28T14-14.md`), unit (full single-process run 11448 tests, 0 failures, 10 pre-existing skips), contract (pytest 34, Jest 24, Codex generator `--check` exit 0), and seeded shuffled order (3 seeds, 111 tests each, 0 failures). The remaining obligation is CI confirmation on the PR head (AC8, GEN1), which cannot run before the pull request exists.

**Temporary artifacts cleanup:**
- PASS No temporary script is committed on the branch; the executor's helper scripts (`SCRATCH/issue-989-*.sh`, `*.ps1`) ran from the session scratchpad outside the repository.
- N/A No ongoing tooling script was added.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Three seeded shuffled file orders (seeds 11, 23, 37) over the six touched suites, 111 tests each, 0 failures (`evidence/regression-testing/pester-shuffle.2026-10-28T13-32.md`). Mocks are registered per `It` in the new suites. |
| **Isolation** - Each test targets single behavior | PASS | One behavior per row: AA-01 to AA-12 (author-asserted check), CB-01 to CB-16 (git seam, branch reader, fallback, guidance, skill gate allow), AL-39 to AL-49 (view clause), PC-01 to PC-07 (prose contracts). |
| **Fast Execution** - Tests complete quickly | PASS | The new unit rows start no process and run no git. The full run (11448 tests) completed in 682.53 s per `pester-junit.xml`. |
| **Determinism** - Consistent results | PASS | No real git: `GitInvoker` stand-ins (CB-01 to CB-06) and `Get-PrAuthorCurrentBranch` mocks; the two pre-existing rows that would otherwise read the real checkout branch are neutralized. Synthetic `/synthetic-worktrees/...` roots; no clock reads. |
| **Readability & Maintainability** - Clear structure | PASS | Row IDs in `It` names, comment-based help per suite, Arrange/Act/Assert comments in the new suites. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline:** helpers 97.37% (111/114), allowlist 100.00% (75/75), model-routing 91.78% (67/73) lines.<br>**Command:** `Invoke-PoshQCTest -ScanFolders <GSS files>` with coverage via `pester.runsettings.psd1`.<br>**Timestamp:** 2026-10-28T13-06 (`evidence/baseline/pester-gss.2026-10-28T13-06.md`). |
| **No Coverage Regression** | PASS | **Post-change (canonical artifact):** helpers 97.41% (113/116), allowlist 100.00% (77/77), model-routing 96.43% (81/84).<br>**Status:** No regression on any changed file; the missed lines are pre-existing statements, shifted (`evidence/qa-gates/coverage-comparison.2026-10-28T13-31.md`). |
| **Repo-wide Coverage (PowerShell)** | PASS | Canonical artifact `artifacts/pester/powershell-coverage.xml` report-level LINE counter: 17787 covered, 1398 missed = 92.71%, at or above the 85% line floor (default; root `CLAUDE.md` states no threshold). Parsed directly by the reviewer. No branch gate applies to PowerShell. Prior finding PA-B1 resolved. |
| **New Code Coverage** (governing default: >= 85% lines; no branch gate for PowerShell) | PASS | **New file** `enforce-pr-author-skill.current-branch.ps1`: 21/22 lines = 95.45% (canonical artifact). The one missed line is the default `GitInvoker` scriptblock body, which runs only against the real executable.<br>**Changed lines** in the three modified hooks: 100% covered. |
| **Comprehensive Coverage** | PASS | `Invoke-PrAuthorCurrentBranchGitExe`: CB-01, CB-02. `Get-PrAuthorCurrentBranch`: CB-03 to CB-06. `Resolve-PrAuthorCurrentBranchTarget`: CB-07 to CB-13, CB-15. `Get-PrAuthorTargetGuidanceText`: CB-14. `Get-ModelRoutingAuthorAssertedReason` and its call site: AA-01 to AA-12. `Test-PrAuthorAllowlistForm` view clause: AL-39 to AL-48; form text: AL-49. |
| **Positive Flows** - Valid inputs | PASS | AA-01, AA-06, AA-07, AA-10, AA-11, CB-03, CB-07, CB-08, AL-39, CB-16. |
| **Negative Flows** - Invalid inputs | PASS | AA-02, AA-03, AA-08, AL-40 to AL-48. |
| **Edge Cases** - Boundary conditions | PASS | AA-04 and AA-05 (digit-prefix collisions), AA-09 (mid-line text), CB-04 (detached `HEAD`), CB-06 (empty output), CB-09 (ambiguous derived branch), CB-12, CB-13. |
| **Error Handling** - Error paths | PASS | CB-02 (invoker throws; wrapper returns ExitCode -1), CB-05 (non-zero exit), AA-12 (receipt-missing reason takes precedence). |
| **Concurrency** - If applicable | N/A | Hook decisions are single-invocation and stateless. |
| **State Transitions** - If applicable | N/A | No stateful component was added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: helpers 97.37%, allowlist 100.00%, model-routing 91.78% lines -> Post-change: helpers 97.41%, allowlist 100.00%, model-routing 96.43% lines (canonical artifact). Change: +0.04, 0.00, +4.65 percentage points. New/changed-code coverage: new sibling 95.45% lines; changed lines 100%. Repo-wide: 92.71% lines (17787/19185, 216 files), above the 85% line floor. Branch coverage: no gate (Pester measures no branch coverage). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (reviewer parse), `artifacts/pester/pester-junit.xml`, `evidence/baseline/pester-gss.2026-10-28T13-06.md`, `evidence/qa-gates/pester-full.2026-10-28T14-26.md`, `evidence/qa-gates/coverage-comparison.2026-10-28T13-31.md`.
- TypeScript: N/A - out of scope (zero changed files).
- Python: N/A - out of scope (zero changed files).
- C#: N/A - out of scope (zero changed files).

Coverage exclusion check: the branch adds no coverage `exclude` entry and changes no coverage configuration. Verdict: PASS.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `.Contains(...) | Should -BeTrue -Because $reason` carries the full reason text into the failure message. The expect-fail run shows actionable messages per row (`evidence/regression-testing/expect-fail.2026-10-28T13-12.md`). |
| **Arrange-Act-Assert Pattern** | PASS | Comment-delimited Arrange/Act/Assert sections in the CB and AA rows. |
| **Document Intent** | PASS | Descriptive `It` names with row IDs; suite `.DESCRIPTION` blocks state what is and is not mocked. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, no git process, no process start in the new rows. The pre-existing real-pwsh row in `OrchestratorStatePreflight.Tests.ps1` keeps its subprocess and now redefines `Get-PrAuthorCurrentBranch` to return `$null`. |
| **Use Mocks/Stubs** | PASS | Mocked seams: `Resolve-WorktreeItemTarget` (ParameterFilter on `$Text`), `Get-PrAuthorCurrentBranch`, `Resolve-PrAuthorWorktreeTarget`, `Get-PrContextArtifactExistence`, `Resolve-ModelRoutingWorktreeTarget`, `Get-ModelRoutingCheckpoint`. |
| **Environment Stability** | PASS | No `TestDrive`, `New-TemporaryFile`, or temp-path use in the new suites. Fake invokers set `$global:LASTEXITCODE` explicitly. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit, plus the executor self-reviews `evidence/qa-gates/self-review.2026-10-28T13-52.md` and `self-review.2026-10-28T14-30.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #989; `spec.md` Context and Root Cause Analysis. |
| **Read existing change plans** | PASS | `research/research.2026-10-28T12-10.md`; `evidence/baseline/phase0-instructions-read.2026-10-28T13-02.md` and `phase0-instructions-read.2026-10-28T14-11.md` (cycle 1). |
| **Document the plan** | PASS | `plan.2026-10-28T07-38.md`; `remediation-plan.2026-10-28T13-58.md` (all tasks checked). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The fallback is one guarded re-resolution; the allowlist clause is one exact token comparison; the author-asserted check is one regex. |
| **Reusability** | PASS | The derived branch re-enters `Resolve-WorktreeItemTarget` as a `branch: <name>` signal; the issue number is normalized through `ConvertTo-WorktreeItemIssueNumber`. |
| **Extensibility** | PASS | `GitInvoker` is an injectable scriptblock; guidance text is a separate builder. |
| **Separation of concerns** | PASS | The git process call is isolated in `Invoke-PrAuthorCurrentBranchGitExe`; resolution and text building are separate functions. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The new sibling holds only current-branch derivation and the no-target guidance text. |
| **Under 500 lines** | PASS | model-routing 349, allowlist 285, helpers 443, current-branch 149; tests 267, 202, 247, 137, 425, 148 (`evidence/qa-gates/file-size.2026-10-28T13-50.md`; unchanged in cycle 1). |
| **Public vs internal** | PASS | Dot-sourced hook functions following the existing sibling pattern. |
| **No circular dependencies** | PASS | Architecture guard rows pass (`evidence/qa-gates/architecture-guards.2026-10-28T13-28.md`, `pester-guards.2026-10-28T14-14.md`). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Get-PrAuthorCurrentBranch`, `Resolve-PrAuthorCurrentBranchTarget`, `Get-PrAuthorTargetGuidanceText`, `Get-ModelRoutingAuthorAssertedReason`. |
| **Docs/docstrings** | PASS | Comment-based help on every new function. |
| **Comment why, not what** | PASS | Comments state reasons (never-throw because exit 1 is non-blocking for PreToolUse; property presence tested first under strict mode). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file.<br>**Result:** 14 files, 0 rewritten (`evidence/qa-gates/powershell-format.2026-10-28T13-28.md`). |
| **2. Linting** | PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file.<br>**Result:** 0 findings across 14 files (`evidence/qa-gates/powershell-analyze.2026-10-28T13-28.md`). |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Architecture boundary** | PASS | 636 passed, 0 failed (`architecture-guards.2026-10-28T13-28.md`); guard suites re-run with coverage disabled in cycle 1 (`pester-guards.2026-10-28T14-14.md`). |
| **5. Testing** | PASS | **Command:** `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts`.<br>**Result:** 11448 tests, 0 failures, 0 errors, 10 pre-existing skips (`artifacts/pester/pester-junit.xml`; `evidence/qa-gates/pester-full.2026-10-28T14-26.md`). |
| **6. Contract** | PASS | pytest 34 passed; Jest twin 24 passed; Codex generator `--check` exit 0 (`evidence/qa-gates/contract-final.2026-10-28T13-50.md`). |
| **7. Integration** | PASS | No separate integration suite applies to these hooks; the end-to-end real-pwsh row in `OrchestratorStatePreflight.Tests.ps1` passes in the full run. |
| **Full toolchain loop** | PASS | Local single clean pass. The CI re-confirmation on the PR head is tracked as the pending-CI feature-audit item FA-B1 (AC8) and is not counted again here. |
| **Explicit reporting** | PASS | Commands, exit codes, and counts are recorded in each evidence artifact. |

Reviewer re-verification performed in this review (check-only; no Pester or coverage command run): direct parse of `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`; `git hash-object` on all eight source/bundle pairs returned identical object IDs; `validate_evidence_locations.py --root .` exited 0; `scripts.dev_tools.pr_context.collector` regenerated `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` for head `540819df8`.

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages `bda84fbf4`, `540819df8`; Section 9 below. |
| **Design choices explained** | PASS | `spec.md` Proposed Fix and Residual limits; plan design decisions. |
| **Update supporting documents** | PASS | Orchestrate skill, orchestrator agent, pr-author skill and agent updated and mirrored (`evidence/other/prose-contracts.2026-10-28T13-25.md`). |
| **Provide next steps** | PASS | Open the PR; confirm CI on the PR head; check off AC8 and GEN1 at S9. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | 0 rewrites across 14 files. |
| **Linting with PSScriptAnalyzer** | PASS | 0 findings across 14 files. |
| **Fix all findings** | PASS | No findings to fix. |
| **PowerShell 7+ compatibility** | PASS | `#Requires -Version 7.0` in the new suites, per `.claude/rules/powershell.md`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]` and `[OutputType()]` on all new functions. |
| **Parameter validation** | PASS | `Mandatory`, `ValidateNotNull` on `GitInvoker`, `AllowNull`, `AllowEmptyString` where appropriate. |
| **Avoid global state** | PASS | No new script-scoped variable; the existing `$script:PrAuthorAllowlistFormText` string is extended. |
| **Error handling** | PASS | The git seam catches and returns `ExitCode -1` by design; every failure path maps to the original NoTarget deny. Deny reasons carry reason codes. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | Largest production file 443 lines (helpers). |
| **Approved verbs** | PASS | `Invoke`, `Get`, `Resolve`; PSSA approved-verb rule clean. |
| **Comment why** | PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | 0 rewrites. |
| **Step 2: Analyze** | PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | Full run 11448 tests, 0 failures. |
| **Rerun loop if needed** | PASS | One pass; no auto-fix triggered a restart. Cycle 1 changed no code. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | PASS | One string entry inserted in sorted position with existing indentation. |
| **Schema validation** | PASS | Manifest completeness, dependency-closure, and Jest twin tests pass. |
| **Required $schema** | N/A | `core.json` is a pack manifest outside the governed-JSON set; the change adds no key. |
| **Strict JSON only** | PASS | No comments or trailing commas introduced. |
| **Deterministic key order** | PASS | Array entry placed alphabetically between `artifact-root` and `docs-only`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`. |
| **Use PoshQC Configuration** | PASS | `Invoke-PoshQCTest` with `pester.runsettings.psd1`; direct `Invoke-Pester` used only for the seeded shuffle runs and the coverage-disabled guard re-run. |
| **PowerShell 7+** | PASS | `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | AA 12 rows, CB 16 rows, AL 11 new rows, PC 9 instances. |
| **Test Behavior Over Implementation** | PASS | Rows assert permission decisions, reason text, and resolution status; `Should -Invoke` only proves whether the git seam is reached, which is the specified behavior. |
| **Mocking Used Sparingly** | PASS | Mocks limited to I/O and resolver seams (see 1.4). |
| **Organization** | PASS | **Test files:** `tests/scripts/claude-hooks/*.Tests.ps1` and `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1`.<br>**Code files:** `.claude/hooks/*.ps1` and `.claude` prose.<br>The location follows the established repository convention for hook suites. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | All new suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | One `Describe` per suite; row-ID `It` blocks. |
| **Logical Grouping** | PASS | Allow and deny rows grouped in `BeforeDiscovery` arrays; CB rows ordered seam -> reader -> fallback -> message -> gate. |
| **Docstrings/Comments** | PASS | Suite DESCRIPTION and NOTES state what is mocked. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts`: 11448 tests, 0 failures. |
| **No Alternative Test Runners** | PASS | Pester only. |

---

## 5. Test Coverage Detail

### enforce-pr-author-skill.current-branch.ps1 (CB-01 to CB-16)

| Test Name | Scenario Type | Function | Status |
|-----------|--------------|----------|--------|
| CB-01 | Positive | `Invoke-PrAuthorCurrentBranchGitExe` | PASS |
| CB-02 | Error Handling | `Invoke-PrAuthorCurrentBranchGitExe` | PASS |
| CB-03 | Positive | `Get-PrAuthorCurrentBranch` | PASS |
| CB-04, CB-05, CB-06 | Edge Case / Error Handling | `Get-PrAuthorCurrentBranch` | PASS |
| CB-07 to CB-13, CB-15 | Positive / Edge Case | `Resolve-PrAuthorCurrentBranchTarget` via `Resolve-PrAuthorWorktreeTarget` | PASS |
| CB-14 | Positive | `Get-PrAuthorTargetGuidanceText` | PASS |
| CB-16 | Positive | skill gate allow of the view form | PASS |

**Coverage:** 95.45% (21/22 lines, canonical artifact). **Not covered:** the default `GitInvoker` scriptblock body.

### enforce-model-routing-receipt.ps1 (AA-01 to AA-12)

**Coverage:** 96.43% (81/84, canonical artifact). **Not covered:** pre-existing script entry tail statements after the dot-source guard.

### enforce-pr-author-command-allowlist.ps1 (AL-39 to AL-49)

**Coverage:** 100.00% (77/77). **Not covered:** None.

### enforce-pr-author-skill-helpers.ps1

**Coverage:** 97.41% (113/116). **Not covered:** three pre-existing receipt-check returns, unchanged by this branch.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full run) | 11448 | PASS |
| Tests Passed | 11438 | PASS |
| Tests Failed | 0 | PASS |
| Skipped | 10 (pre-existing, outside this change) | PASS |
| Execution Time (full run) | 682.53 s | PASS |
| Shuffled-order runs | 3 seeds x 111 tests, 0 failures | PASS |
| Repo-wide PowerShell line coverage | 92.71% (17787/19185) | PASS |
| Code Coverage (changed files) | 95.45% to 100% lines; no branch gate for PowerShell | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` per file with PoshQC settings | 0 rewrites | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` per file with PoshQC settings | 0 findings | PASS |
| Pester Tests | `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts` | 11448 tests, 0 failures | PASS |

**Notes:** The 10 skipped tests are pre-existing skip conditions in suites outside this change. The canonical coverage XML is the final full run (report time 14:22:01 UTC), written after the coverage-disabled guard re-run.

---

## 8. Gaps and Exceptions

### Identified Gaps

- PA-B1 (prior cycle): resolved. The canonical artifact now reports 92.71% repo-wide line coverage and 95.45% to 100% on the four changed hook files.
- AC8 (CI confirmation of mirrors and the seven-stage toolchain on the PR head) and GEN1 (repro behavior in all documented environments, including the Linux hook-suite CI job) are CI-dependent. The pull request is not open, so these cannot be verified in this review. They are recorded as blocking findings FA-B1 and FA-B2 in the feature audit, remediability `awaiting_ci`. Owner: the item's orchestrator run at S9.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented. The optional `enforce-pr-author-skill.Tests.ps1` allow row named in the spec was implemented as CB-16 in the CurrentBranch suite instead.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **82af0bb9a** - docs: issue 989 promotion, research, and spec
2. **786015391** - docs(issue-989): atomic plan and preflight clearance
3. **bda84fbf4** - fix(pr-author): derive edit target from current branch, allow gh pr view, require author-asserted autoclose (#989)
4. **540819df8** - docs(issue-989): feature review and remediation cycle 1 evidence

### Files Modified

1. **`.claude/hooks/enforce-pr-author-skill.current-branch.ps1`** (NEW) - git seam, branch reader, fallback, guidance text.
2. **`.claude/hooks/enforce-pr-author-skill-helpers.ps1`** (MODIFIED) - dot-source the sibling; fallback call; guidance in the NoTarget deny.
3. **`.claude/hooks/enforce-model-routing-receipt.ps1`** (MODIFIED) - `Get-ModelRoutingAuthorAssertedReason` and its pr-author call site.
4. **`.claude/hooks/enforce-pr-author-command-allowlist.ps1`** (MODIFIED) - exact six-token view clause; form text.
5. **`.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`** (MODIFIED) - `Bash(gh pr view *)`, Closing-Reference Verification, delegation-prompt Closes source, `gh pr edit` target forms.
6. **`.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`** (MODIFIED) - required author-asserted delegation line.
7. **Bundle mirrors and `pack-manifests/core.json`** (MODIFIED/NEW) - byte-equal copies; manifest entry.
8. **Tests** (NEW/MODIFIED) - as listed under Code Under Test.
9. **Feature folder** - review artifacts, remediation inputs and plan, and cycle-1 evidence records.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT (local policy checks pass; CI confirmation pending)

All policy checks that can be evaluated before the pull request exists pass, including PowerShell repo-wide and per-file coverage verified from the canonical artifact. The policy audit raises no blocking finding. The two CI-dependent acceptance criteria (AC8, GEN1) are tracked in the feature audit as `awaiting_ci`.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution (local; CI leg tracked as FA-B1)
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

### Metrics Summary

- PASS 11438/11448 tests passing in the full run (0 failed; 10 pre-existing skips)
- PASS Repo-wide PowerShell line coverage 92.71% in the canonical artifact (PA-B1 resolved)
- PASS New-file line coverage 95.45%; changed-line coverage 100%
- PASS Bundle parity 8/8 object IDs equal (re-verified by the reviewer)
- PASS Format 0 rewrites, lint 0 findings

### Recommendation

**Approve pending CI.** Open the pull request through `Agent(pr-author)` with the line `Author-asserted autoclose issues: #989`, let CI run on the PR head (`poshqc / PowerShell QC` shards and `poshqc / PowerShell hook suites (Linux)`), and check off AC8 and GEN1 at S9 when CI succeeds.

---

## Appendix A: Test Inventory

- `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`: baseline mock interception probe; AA-01 to AA-12.
- `enforce-pr-author-skill.CurrentBranch.Tests.ps1`: baseline mock interception probe; CB-01 to CB-16.
- `pr-author-issue-link-contract.Tests.ps1`: PC-01 to PC-04, PC-05 (skill, agent), PC-06 (skill, agent), PC-07.
- `enforce-pr-author-command-allowlist.Tests.ps1`: AL-01 to AL-38 (existing), AL-39 to AL-49 (new).
- `enforce-pr-author-skill.WorktreeResolution.Tests.ps1`: file-level `Get-PrAuthorCurrentBranch` mock added.
- `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`: real-pwsh row redefines `Get-PrAuthorCurrentBranch`.

---

## Appendix B: Toolchain Commands Reference

```powershell
# Formatting and linting (per file, PoshQC settings)
Invoke-Formatter -ScriptDefinition <content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing (executor; the reviewer did not run it)
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts
```

```bash
# Contract stage
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:randomly --no-cov
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check

# Reviewer check-only commands
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python -m scripts.dev_tools.pr_context.collector --base 6c6aa4f0e123c25089f6669761d93d426eb4401c
git hash-object <source> <bundle>   # eight pairs
python -I -c "<xml.etree parse of artifacts/pester/powershell-coverage.xml report and per-file LINE counters>"
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-28
**Policy Version:** Current (as of audit date)
