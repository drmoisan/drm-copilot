# Policy Compliance Audit: pr-author issue-link, target derivation, and gh pr view allowlist (#989)

---

**Audit Date:** 2026-10-28
**Branch:** `bug/pr-author-issue-link-target-derivation-and-view-allowlist-989` at `bda84fbf45da8c0c27c660e62ebb71d2ca3262d3`
**Base:** `main`, merge base `6c6aa4f0e123c25089f6669761d93d426eb4401c` (scope: `git diff 6c6aa4f0e123c25089f6669761d93d426eb4401c..HEAD`, 52 files, 2627 insertions, 64 deletions)
**Code Under Test:**

- PowerShell production (new): `.claude/hooks/enforce-pr-author-skill.current-branch.ps1`
- PowerShell production (modified): `.claude/hooks/enforce-model-routing-receipt.ps1`, `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- PowerShell bundle copies (byte-equal mirrors of the four files above) under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`
- PowerShell tests (new): `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1`, `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1`
- PowerShell tests (modified): `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`
- Markdown prose (and bundle mirrors): `.claude/agents/orchestrator.md`, `.claude/agents/pr-author.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/pr-author/SKILL.md`
- JSON: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one array entry)
- Feature documentation and evidence under `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/` and the promotion record `docs/features/potential/promoted/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production (+4 bundle mirrors), 6 test files | 454 (GSS); 11448 (full run) | PASS: GSS 454 passed, 0 failed; full run 11438 passed, 0 failed, 10 pre-existing skips | helpers 97.37% lines; allowlist 100.00% lines; model-routing 91.78% lines | helpers 97.41%; allowlist 100.00%; model-routing 92.86% (GSS) / 96.43% (full run); current-branch 95.45% | current-branch (new) 95.45% lines; changed lines in the three modified hooks 100% |
| JSON | 1 file | N/A | PASS: manifest completeness and dependency-closure tests (pytest 34 passed; Jest twin 24 passed) | N/A (config file) | N/A (config file) | N/A |
| Markdown | 8 prose files (4 + 4 mirrors) | 9 PC rows + AL-33 to AL-35 | PASS: 58 passed, 0 failed | N/A | N/A | N/A |
| TypeScript | 0 files | N/A | N/A (no changed files) | N/A | N/A | N/A |
| Python | 0 files | N/A | N/A (no changed files) | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A (no changed files) | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/evidence/baseline/pester-gss.2026-10-28T13-06.md`
- PowerShell post-change coverage artifact: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/evidence/qa-gates/pester-gss.2026-10-28T13-31.md` and `evidence/qa-gates/pester-full.2026-10-28T13-48.md`
- Per-language comparison summary: `evidence/qa-gates/coverage-comparison.2026-10-28T13-31.md`; Section 1.2.1 below

Coverage artifact note: the canonical PowerShell coverage artifact `artifacts/pester/powershell-coverage.xml` (gitignored, last written 2026-10-28T13-50 UTC) reports PowerShell repo-wide line coverage of 0% (0 covered of 19185 lines over 216 files). It was overwritten by the later architecture-guard run (636 tests, `evidence/qa-gates/contract-final.2026-10-28T13-50.md`), whose scan folders contain no hook suite. Under the review contract, the reviewer verifies coverage from the existing artifact and does not rerun coverage generation. The artifact is below the 85% line floor, so the PowerShell repo-wide coverage verdict is FAIL (finding PA-B1, remediability `autonomous`). The per-file figures in the table above come from the feature-folder evidence records of the GSS and full runs. They are consistent with the artifact's per-file line totals (current-branch 22, model-routing 84, allowlist 77, helpers 116), but the current artifact cannot reproduce them. A full single-process coverage run that leaves the artifact in place resolves the finding.

---

## Rejected Scope Narrowing

None detected. The caller prompt states the full branch diff from merge base `6c6aa4f0e123c25089f6669761d93d426eb4401c` to `HEAD` as the scope. Its instruction to classify AC8 and GEN1 as pending-CI matches the acceptance-criteria-tracking skill's CI-dependent rule. Its note that PowerShell has no branch-coverage gate matches `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md`. Neither instruction narrows the audit scope.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (`git diff --name-only 6c6aa4f0e..HEAD` inspected; no `artifacts/` path is present).
- All evidence lives under `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root on the base commit. `.claude/hooks` is classified T3 and `extensions/drm-copilot` is classified T3, so the new sibling hook is covered by the existing path entry. T3 gates: no property-test density requirement, no mutation-score requirement, contract-bump rule not applicable. Verdict: PASS.

---

## Executive Summary

The branch fixes three defects in the orchestration and pr-author tooling: (1) a new Agent PreToolUse check in `enforce-model-routing-receipt.ps1` requires the `Author-asserted autoclose issues: #<issue-num>` line in `Agent(pr-author)` delegations; (2) `Resolve-PrAuthorWorktreeTarget` falls back to the current checked-out branch through a new never-throwing git seam in `enforce-pr-author-skill.current-branch.ps1`, and the `TARGET_WORKTREE_NOT_DERIVABLE` guidance names the accepted create and edit forms; (3) the pr-author allowlist permits exactly `gh pr view <N> --json closingIssuesReferences,body`, and the agent and skill require that verification after each create or edit.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- PASS `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- PASS `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python changed)
- PASS `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A Bash (no shell scripts changed)
- PASS JSON: one manifest entry, verified by the manifest contract tests

Local evidence shows a clean seven-stage loop: format (0 rewrites), lint (0 findings), type check (not applicable to PowerShell), architecture guards (636 passed), unit (GSS 454 passed; full single-process run 11438 passed, 0 failed), contract (pytest 34, Jest 24, Codex generator `--check` exit 0), and seeded shuffled order (3 seeds, 111 tests each, 0 failures). The one remaining obligation is CI confirmation on the PR head (AC8, GEN1), which cannot run before the pull request exists.

**Temporary artifacts cleanup:**
- PASS No temporary script is committed on the branch; the executor's helper scripts were run from the session scratchpad (`SCRATCH/issue-989-*.sh`, `*.ps1`) and are outside the repository.
- N/A No ongoing tooling script was added.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Three seeded shuffled file orders (seeds 11, 23, 37) over the six touched suites, 111 tests each, 0 failures (`evidence/regression-testing/pester-shuffle.2026-10-28T13-32.md`). Mocks are registered per `It` in the new suites. |
| **Isolation** - Each test targets single behavior | PASS | One behavior per row: AA-01 to AA-12 (author-asserted check), CB-01 to CB-16 (git seam, branch reader, fallback, guidance, skill gate allow), AL-39 to AL-49 (view clause), PC-01 to PC-07 (prose contracts). |
| **Fast Execution** - Tests complete quickly | PASS | The GSS (25 files, 454 tests) completed in one process; the new unit rows start no process and run no git. The one pre-existing real-pwsh row is unchanged in cost. |
| **Determinism** - Consistent results | PASS | No real git: `GitInvoker` stand-ins (CB-01 to CB-06) and `Get-PrAuthorCurrentBranch` mocks; the two pre-existing rows that would otherwise read the real checkout branch are neutralized (file-level mock in WorktreeResolution; inline redefinition in the OrchestratorStatePreflight real-pwsh row). Synthetic `/synthetic-worktrees/...` roots; no clock reads. |
| **Readability & Maintainability** - Clear structure | PASS | Row IDs in `It` names, comment-based help per suite, Arrange/Act/Assert comments in the new suites. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline:** helpers 97.37% (111/114), allowlist 100.00% (75/75), model-routing 91.78% (67/73) lines.<br>**Command:** `Invoke-PoshQCTest -ScanFolders <GSS files>` with coverage via `pester.runsettings.psd1`.<br>**Timestamp:** 2026-10-28T13-06 (`evidence/baseline/pester-gss.2026-10-28T13-06.md`). |
| **No Coverage Regression** | PASS | **Post-change:** helpers 97.41% (+0.04), allowlist 100.00% (0.00), model-routing 92.86% (+1.08) in the GSS run.<br>**Status:** No regression; the missed lines are the same pre-existing statements, shifted (`evidence/qa-gates/coverage-comparison.2026-10-28T13-31.md`). |
| **Repo-wide Coverage (PowerShell)** | FAIL | Canonical artifact `artifacts/pester/powershell-coverage.xml` reports PowerShell repo-wide line coverage 0% (0/19185 lines, 216 files), below the 85% line floor (default). The artifact was overwritten by the 636-test architecture-guard run. The full-run evidence (`evidence/qa-gates/pester-full.2026-10-28T13-48.md`, 91.95% aggregate command coverage) cannot be reproduced from the artifact. Finding PA-B1. |
| **New Code Coverage** (governing default: >= 85% lines; no branch gate for PowerShell) | PASS | **New file** `enforce-pr-author-skill.current-branch.ps1`: 21/22 lines = 95.45%. The one missed line is the default `GitInvoker` scriptblock body, which runs only against the real executable.<br>**Changed lines** in the three modified hooks: 100% covered. |
| **Comprehensive Coverage** | PASS | `Invoke-PrAuthorCurrentBranchGitExe`: CB-01, CB-02. `Get-PrAuthorCurrentBranch`: CB-03 to CB-06. `Resolve-PrAuthorCurrentBranchTarget`: CB-07 to CB-13, CB-15. `Get-PrAuthorTargetGuidanceText`: CB-14. `Get-ModelRoutingAuthorAssertedReason` and its call site: AA-01 to AA-12. `Test-PrAuthorAllowlistForm` view clause: AL-39 to AL-48; form text: AL-49. |
| **Positive Flows** - Valid inputs | PASS | AA-01 (line present), AA-06 (no issue-num), AA-07 (epic_mode true), AA-10 (other subagent), AA-11 (epic scope), CB-03, CB-07, CB-08, AL-39, CB-16. |
| **Negative Flows** - Invalid inputs | PASS | AA-02 (line absent), AA-03 (wrong number), AA-08 (epic_mode false), AL-40 to AL-48 (bare view, `--web`, `--json body`, `--jq`, missing number, non-numeric number, `-R` global option, redirection, reordered fields). |
| **Edge Cases** - Boundary conditions | PASS | AA-04 and AA-05 (digit-prefix collisions in both directions), AA-09 (mid-line text), CB-04 (detached `HEAD`), CB-06 (empty output), CB-09 (ambiguous derived branch), CB-12 (signal matching no worktree does not trigger the fallback), CB-13 (issue line suppresses the fallback). |
| **Error Handling** - Error paths | PASS | CB-02 (invoker throws; wrapper returns ExitCode -1), CB-05 (non-zero exit), AA-12 (receipt-missing reason takes precedence). |
| **Concurrency** - If applicable | N/A | Hook decisions are single-invocation and stateless. |
| **State Transitions** - If applicable | N/A | No stateful component was added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: helpers 97.37%, allowlist 100.00%, model-routing 91.78% lines -> Post-change: helpers 97.41%, allowlist 100.00%, model-routing 92.86% lines (GSS); 96.43% for model-routing in the full run. Change: +0.04, 0.00, +1.08 percentage points. New/changed-code coverage: new sibling 95.45% lines; changed lines 100%. Repo-wide: the canonical artifact `artifacts/pester/powershell-coverage.xml` reports 0% PowerShell line coverage (0/19185), below the 85% line floor. The full-run evidence record states 91.95% aggregate command coverage, but the artifact cannot reproduce that figure. Branch coverage: no gate (Pester measures no branch coverage). Disposition: FAIL for PowerShell repo-wide coverage (PA-B1); PASS for per-file and changed-line coverage based on the evidence records. Evidence: `evidence/baseline/pester-gss.2026-10-28T13-06.md`, `evidence/qa-gates/pester-gss.2026-10-28T13-31.md`, `evidence/qa-gates/pester-full.2026-10-28T13-48.md`, `evidence/qa-gates/coverage-comparison.2026-10-28T13-31.md`.
- TypeScript: N/A - out of scope (zero changed files).
- Python: N/A - out of scope (zero changed files).
- C#: N/A - out of scope (zero changed files).

Coverage exclusion check: the branch adds no coverage `exclude` entry and changes no coverage configuration. Verdict: PASS.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `.Contains(...) | Should -BeTrue -Because $reason` carries the full reason text into the failure message (CB-14, AL-49, AA rows). The expect-fail run shows actionable messages per row (`evidence/regression-testing/expect-fail.2026-10-28T13-12.md`). |
| **Arrange-Act-Assert Pattern** | PASS | Comment-delimited Arrange/Act/Assert sections in the CB and AA rows. |
| **Document Intent** | PASS | Descriptive `It` names with row IDs; suite `.DESCRIPTION` blocks state what is and is not mocked. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, no git process, no process start in the new rows. The pre-existing real-pwsh row in `OrchestratorStatePreflight.Tests.ps1` keeps its subprocess and now redefines `Get-PrAuthorCurrentBranch` to return `$null` so it does not read the real checkout. |
| **Use Mocks/Stubs** | PASS | Mocked seams: `Resolve-WorktreeItemTarget` (ParameterFilter on `$Text`), `Get-PrAuthorCurrentBranch`, `Resolve-PrAuthorWorktreeTarget`, `Get-PrContextArtifactExistence`, `Resolve-ModelRoutingWorktreeTarget`, `Get-ModelRoutingCheckpoint`, and the checkpoint-text readers in the worktree-resolution modules. |
| **Environment Stability** | PASS | No `TestDrive`, `New-TemporaryFile`, or temp-path use in the new suites (searched). The PC suite reads committed documents only. Fake invokers set `$global:LASTEXITCODE` explicitly so the wrapper reads a defined value. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit, plus the executor self-review `evidence/qa-gates/self-review.2026-10-28T13-52.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #989; `spec.md` Context and Root Cause Analysis. |
| **Read existing change plans** | PASS | `research/research.2026-10-28T12-10.md`; `evidence/baseline/phase0-instructions-read.2026-10-28T13-02.md`. |
| **Document the plan** | PASS | `plan.2026-10-28T07-38.md`; preflight fixes in `evidence/other/preflight-fixes.*.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The fallback is one guarded re-resolution; the allowlist clause is one exact token comparison; the author-asserted check is one regex. |
| **Reusability** | PASS | The derived branch re-enters `Resolve-WorktreeItemTarget` as a `branch: <name>` signal, reusing ambiguity handling and SessionRoot/OtherWorktree labelling. The issue number is normalized through the existing `ConvertTo-WorktreeItemIssueNumber`. |
| **Extensibility** | PASS | `GitInvoker` is an injectable scriptblock; guidance text is a separate builder. |
| **Separation of concerns** | PASS | The git process call is isolated in `Invoke-PrAuthorCurrentBranchGitExe`; resolution and text building are separate functions. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The new sibling holds only current-branch derivation and the no-target guidance text. |
| **Under 500 lines** | PASS | model-routing 349, allowlist 285, helpers 443, current-branch 149; tests 267, 202, 247, 137, 425, 148 (`evidence/qa-gates/file-size.2026-10-28T13-50.md`; current-branch confirmed by the coverage denominator and diff). |
| **Public vs internal** | PASS | Dot-sourced hook functions following the existing sibling pattern (`artifact-root`, `docs-only`). |
| **No circular dependencies** | PASS | Architecture guard S4 rows pass; the sibling imports nothing (`evidence/qa-gates/architecture-guards.2026-10-28T13-28.md`). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Get-PrAuthorCurrentBranch`, `Resolve-PrAuthorCurrentBranchTarget`, `Get-PrAuthorTargetGuidanceText`, `Get-ModelRoutingAuthorAssertedReason`. |
| **Docs/docstrings** | PASS | Comment-based help (SYNOPSIS, DESCRIPTION, PARAMETER, OUTPUTS) on every new function; file header updated in helpers and model-routing hooks. |
| **Comment why, not what** | PASS | Comments state reasons: never-throw because exit 1 is non-blocking for PreToolUse; assign-before-count for `Find-WorktreeItemIssueSignal`; property presence tested first under strict mode. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file.<br>**Result:** 14 files, 0 rewritten (`evidence/qa-gates/powershell-format.2026-10-28T13-28.md`). |
| **2. Linting** | PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file.<br>**Result:** 0 findings across 14 files (`evidence/qa-gates/powershell-analyze.2026-10-28T13-28.md`). |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Architecture boundary** | PASS | `hook-dependency-guard-completeness`, `enforcement-hooks-no-python-invocation`, `claude-architecture-doc`: 636 passed, 0 failed. |
| **5. Testing** | PASS | **Command:** `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts`.<br>**Result:** 11438 passed, 0 failed, 10 pre-existing skips (`evidence/qa-gates/pester-full.2026-10-28T13-48.md`). |
| **6. Contract** | PASS | pytest bundle-equality and manifest tests 34 passed; Jest twin 24 passed; Codex generator `--check` exit 0 (`evidence/qa-gates/contract-final.2026-10-28T13-50.md`). |
| **7. Integration** | PASS | No separate integration suite applies to these hooks; the end-to-end real-pwsh row in `OrchestratorStatePreflight.Tests.ps1` passes in the full run. |
| **Full toolchain loop** | PASS | Single clean pass (loop pass 1) recorded across P6-T1 to P6-T7. CI re-confirmation on the PR head is pending (AC8). |
| **Explicit reporting** | PASS | Commands, exit codes, and counts are recorded in each evidence artifact. |

Reviewer re-verification performed in this review (check-only): `git hash-object` on all eight source/bundle pairs returned identical object IDs; `validate_evidence_locations.py --root .` exited 0; `scripts.dev_tools.pr_context.collector` regenerated `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` for head `bda84fbf4`.

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `bda84fbf4` message; Section 9 below. |
| **Design choices explained** | PASS | `spec.md` Proposed Fix and Residual limits; plan design decisions. |
| **Update supporting documents** | PASS | Orchestrate skill, orchestrator agent, pr-author skill and agent updated and mirrored. A search for other pr-author tool lists found none (`evidence/other/prose-contracts.2026-10-28T13-25.md`). |
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
| **PowerShell 7+ compatibility** | PASS | Hooks and tests target PowerShell 7 (`#Requires -Version 7.0` in the new suites), per `.claude/rules/powershell.md`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]` and `[OutputType()]` on all four new functions and on `Get-ModelRoutingAuthorAssertedReason`. |
| **Parameter validation** | PASS | `Mandatory`, `ValidateNotNull` on `GitInvoker`, `AllowNull`, `AllowEmptyString` where null or empty inputs are legitimate. |
| **Avoid global state** | PASS | No new script-scoped variable; the existing `$script:PrAuthorAllowlistFormText` string is extended. |
| **Error handling** | PASS | The git seam catches and returns `ExitCode -1` by design (documented: an uncaught hook error exits 1, which PreToolUse treats as non-blocking); every failure path maps to the original NoTarget deny. Deny reasons are explicit and carry reason codes. |

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
| **Step 4: Test** | PASS | GSS 454/0; full 11438/0. |
| **Rerun loop if needed** | PASS | One pass; no auto-fix triggered a restart. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | PASS | One string entry inserted in sorted position with existing indentation (diff inspected). |
| **Schema validation** | PASS | `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and the Jest manifest-completeness twin pass. |
| **Required $schema** | N/A | `core.json` is a pack manifest outside the governed-JSON set; the change adds no key. |
| **Strict JSON only** | PASS | No comments or trailing commas introduced. |
| **Deterministic key order** | PASS | Array entry placed alphabetically between `artifact-root` and `docs-only`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; BeforeAll/Describe/It; `Should -Invoke`. |
| **Use PoshQC Configuration** | PASS | `Invoke-PoshQCTest` with `pester.runsettings.psd1`; direct `Invoke-Pester` used only for the seeded shuffle runs. |
| **PowerShell 7+** | PASS | `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | AA 12 rows, CB 16 rows, AL 11 new rows, PC 9 instances. |
| **Test Behavior Over Implementation** | PASS | Rows assert permission decisions, reason text, and resolution status; `Should -Invoke` is used only to prove that the git seam is or is not reached, which is the specified behavior. |
| **Mocking Used Sparingly** | PASS | Mocks limited to I/O and resolver seams (see 1.4). |
| **Organization** | PASS | **Test files:** `tests/scripts/claude-hooks/*.Tests.ps1` and `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1`.<br>**Code files:** `.claude/hooks/*.ps1` and `.claude` prose.<br>The location follows the established repository convention for hook suites (existing suites for the same hooks live in `tests/scripts/claude-hooks/`). |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | All new suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | One `Describe` per suite; row-ID `It` blocks. |
| **Logical Grouping** | PASS | Allow and deny rows grouped in `BeforeDiscovery` arrays (allowlist); CB rows ordered seam -> reader -> fallback -> message -> gate. |
| **Docstrings/Comments** | PASS | Suite DESCRIPTION and NOTES state what is mocked and the no-file, no-process rule. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts`: 11438 passed, 0 failed. |
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
| CB-14 | Positive | `Get-PrAuthorTargetGuidanceText` via `Get-PrAuthorTargetCheckpointResolution` | PASS |
| CB-16 | Positive | skill gate allow of the view form | PASS |

**Coverage:** 95.45% (21/22 lines). **Not covered:** the default `GitInvoker` scriptblock body, which starts the real git executable.

### enforce-model-routing-receipt.ps1 (AA-01 to AA-12)

**Coverage:** 92.86% (GSS), 96.43% (full run). **Not covered:** pre-existing script entry tail statements after the dot-source guard.

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
| Execution Time (full run) | 714.87 s | PASS |
| GSS Tests | 454 passed, 0 failed | PASS |
| Shuffled-order runs | 3 seeds x 111 tests, 0 failures | PASS |
| Code Coverage (changed files) | 95.45% to 100% lines; no branch gate for PowerShell | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` per file with PoshQC settings | 0 rewrites | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` per file with PoshQC settings | 0 findings | PASS |
| Pester Tests | `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts` | 11438 passed, 0 failed | PASS |

**Notes:** The 10 skipped tests are pre-existing skip conditions in suites outside this change. The on-disk coverage XML is a later subset run; see the Coverage artifact note above.

---

## 8. Gaps and Exceptions

### Identified Gaps

- PA-B1 (Blocking, remediability `autonomous`): PowerShell repo-wide coverage FAIL. The canonical artifact `artifacts/pester/powershell-coverage.xml` reports 0% line coverage because a later subset run overwrote it. Remedy: run the full single-process `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts` with coverage enabled as the last coverage-producing run. Then record the repo-wide and per-file line figures read from that artifact under `evidence/qa-gates/`, and do not run another coverage-enabled subset afterwards.
- AC8 (CI confirmation of mirrors and the seven-stage toolchain on the PR head) and GEN1 (repro behavior in all documented environments, including the Linux hook-suite CI job) are CI-dependent and pending-CI. The pull request is not open, so these cannot be verified in this review. Remediability: `awaiting_ci`. Owner: the item's orchestrator run at S9.

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

### Files Modified

1. **`.claude/hooks/enforce-pr-author-skill.current-branch.ps1`** (NEW) - git seam, branch reader, fallback, guidance text.
2. **`.claude/hooks/enforce-pr-author-skill-helpers.ps1`** (MODIFIED) - dot-source the sibling; fallback call; guidance in the NoTarget deny.
3. **`.claude/hooks/enforce-model-routing-receipt.ps1`** (MODIFIED) - `Get-ModelRoutingAuthorAssertedReason` and its pr-author call site.
4. **`.claude/hooks/enforce-pr-author-command-allowlist.ps1`** (MODIFIED) - exact six-token view clause; form text.
5. **`.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`** (MODIFIED) - `Bash(gh pr view *)`, Closing-Reference Verification, delegation-prompt Closes source, `gh pr edit` target forms.
6. **`.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`** (MODIFIED) - required author-asserted delegation line.
7. **Bundle mirrors and `pack-manifests/core.json`** (MODIFIED/NEW) - byte-equal copies; manifest entry.
8. **Tests** (NEW/MODIFIED) - as listed under Code Under Test.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT (PowerShell repo-wide coverage artifact FAIL; CI confirmation pending)

The code, tests, toolchain stages, and per-file coverage evidence pass. One blocking finding remains: PA-B1, PowerShell repo-wide coverage FAIL, because the canonical coverage artifact reports 0% after a subset run overwrote it (remediability `autonomous`). The two CI-dependent acceptance criteria (AC8, GEN1) remain `awaiting_ci`.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: issue, research, spec, and plan present.
- PASS Design Principles: reuse of the existing resolver; isolated git seam.
- PASS Module & File Structure: all files at most 443 lines.
- PASS Naming, Docs, Comments: comment-based help on every new function.
- PARTIAL Toolchain Execution: local seven-stage loop clean; CI on the PR head pending.
- PASS Summarize & Document: prose and mirrors updated.

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
- PASS New-file line coverage 95.45%; changed-line coverage 100%
- FAIL Repo-wide PowerShell line coverage in the canonical artifact: 0% (artifact overwritten; evidence record states 91.95% command coverage) - PA-B1
- PASS Bundle parity 8/8 object IDs equal (re-verified by the reviewer)
- PASS Format 0 rewrites, lint 0 findings

### Recommendation

**Needs revision (evidence only).** Regenerate the full-run PowerShell coverage artifact and record its figures (PA-B1); no code change is required. Then open the pull request, let CI run on the PR head (`poshqc / PowerShell QC` shards and `poshqc / PowerShell hook suites (Linux)`), and check off AC8 and GEN1 at S9 when CI succeeds.

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

# Testing
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts
```

```bash
# Contract stage
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:randomly --no-cov
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check

# Reviewer check-only commands
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python -m scripts.dev_tools.pr_context.collector --base 6c6aa4f0e123c25089f6669761d93d426eb4401c
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-28
**Policy Version:** Current (as of audit date)
