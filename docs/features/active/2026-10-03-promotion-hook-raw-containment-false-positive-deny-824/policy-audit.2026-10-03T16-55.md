# Policy Compliance Audit: Whole-token R2 matcher, fail-closed worktree-gate operands, and source-safe setup script (#824)

---

**Audit Date:** 2026-10-03
**Audit Type:** Reaudit after remediation cycle 2 (review pass 3)
**Code Under Test:** Full branch diff `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5...425772de97a84663d781d2bffeac4b8e4787787f` (364 files; resolved base `origin/main`, merge base committed 2026-10-03T10:09:53-04:00; `origin/main` still equals the merge base after a fresh fetch). Production files outside the feature folder, each mirrored byte-identically under `extensions/drm-copilot/resources/` where a mirror exists:
- PowerShell NEW: `.claude/hooks/hook-command-raw-invocation.ps1`, `.codex/hooks/hook-command-raw-invocation.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`, `scripts/dev-tools/KcovFunctionCoverageGate.ps1` (cycle 2, no mirror)
- PowerShell MODIFIED: `.claude/hooks/hook-command-invocation.ps1`, `.codex/hooks/hook-command-invocation.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/validate-feature-review-coverage.ps1`
- Bash MODIFIED: `.codex/codex-web-setup.sh`
- GitHub Actions MODIFIED: `.github/workflows/_shell-coverage.yml` (cycle 2)
- Markdown policy and skill text MODIFIED (cycles 0-1, unchanged in cycle 2): `.claude/rules/{architecture-boundaries,general-unit-test,quality-tiers}.md`, `.github/instructions/csharp-{code-change,unit-test}.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.claude/agents/feature-review.md`, `.claude/skills/{feature-review-workflow,quota-throttling}/SKILL.md`, `.agents/skills/*`, and the bundled `csharp-legacy` variant skills
- JSON MODIFIED: both `pack-manifests/core.json`

Tests: 21 Pester suites (6 new, 15 modified) under `tests/scripts/{claude-hooks,codex-hooks,dev-tools,workflows}/`; 1 new bats file `tests/shell/test_codex_web_setup_codex_copy.bats` with one committed fixture directory; 2 Python test files (1 new, 1 modified) under `tests/scripts/dev_tools/`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 10 production (4 new, 6 modified) + mirrors + 21 test files | 6826 in the executor full PoshQC run; 861 in the reviewer run of every suite that targets a changed file | ✅ 6826 total, 0 failures (executor); 861 pass, 0 fail (reviewer) | 84.67% lines repo-wide at the merge base | 85.52% lines repo-wide (13676/15992); every changed or new file at or above 93.58% | 100% of changed lines covered (no uncovered changed line in any of the 10 measured files) |
| Python | 2 test files (0 production) | 6595 executor; 148 reviewer | ✅ 6595 pass (executor); 148 pass (reviewer) | 94% lines repo-wide | 93.63% lines repo-wide (16434/17552), unchanged production code | N/A - no production Python file changed |
| Bash | 1 production (`.codex/codex-web-setup.sh`, modified) + 1 mirror + 1 bats file | 15 bats cases (C824-1..C824-15) | ✅ 15 of 15 pass (reviewer, WSL Ubuntu, Bats 1.13.0) | 0% of the changed functions measured at the merge base (no bats test sourced this copy) | 100% of instrumented lines in each of the 6 changed functions (kcov 43, reviewer) | 100% (47 changed lines, 20 instrumented, 0 uncovered) |
| GitHub Actions YAML | 1 (`_shell-coverage.yml`) | `ShellCoverageWorkflow.Tests.ps1` (Pester) | ✅ pass (reviewer); no workflow run on the branch head | N/A (workflow file) | N/A (workflow file) | N/A |
| JSON | 2 files (`core.json` x2) | N/A | ✅ manifest completeness and resource-contract pytest files pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - zero TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/baseline/coverage.2026-10-03T09-46.md` (merge base) and `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/remediation-baseline/r2-coverage.2026-10-03T15-59.md` (cycle-2 start)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-10-03 16:36 local; reviewer re-parsed) and `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/r2-coverage-delta.2026-10-03T16-38.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (2026-10-03 16:39 local) and `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/r2-pytest.2026-10-03T16-38.md`
- Bash post-change coverage artifact: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/review-p3-ac42-kcov.2026-10-03T16-55.md` (reviewer kcov run recorded by this review)
- Per-language comparison summary: section 1.2.1 below

---

## Executive Summary

Remediation cycle 2 (commit 425772de) closed all three pass-2 blockers as specified:

- G-2 of pass 2 is closed. The R2 classifier is now a whole-token, order-independent presence check, and the four positional-parameter and `xargs` forms are denied on both runtimes.
- G-1 of pass 2 is closed for its listed forms. The three worktree-removal gates no longer allow `NoOperand`, so all seven X forms are denied.
- G-3 of pass 2 is closed. `.codex/codex-web-setup.sh` is safe to source and its changed lines are covered by 15 bats cases. The reviewer measured those lines at 100% with kcov.

Format, analyze, 861 Pester tests, the Python checks, and mirror parity pass in reviewer re-runs.

The reaudit found two blocking findings:

1. **G-1 (code review CR-1, autonomous).** The worktree-removal gates allow an unauthorized removal when the same command also names an authorized worktree. The gate reads one literal operand from the first wrapped segment that classifies. Two cases follow:
   - Within a segment, a second removal whose operand the reader cannot read (redirection, PowerShell subexpression, or `xargs`) contributes nothing, so the authorized operand alone decides the gate.
   - Across segments, later segments are never read.
   
   With a checkpoint that authorizes only `/repo/worktrees/item-b-102`, six commands (W1-W6 in code review CR-1) that also remove `/repo/worktrees/item-a-101` are denied at the merge base and allowed at head on both Claude gates. Four of them were also confirmed on the Codex gate.
2. **G-2 (modified-workflow-needs-green-run, awaiting_ci).** The branch modifies `.github/workflows/_shell-coverage.yml`. The head `425772de` is not pushed, so no workflow run exists against it.

**Policy documents evaluated:**
- ⚠️ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`): fail-fast is incomplete in the gate operand path (G-1)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- ⚠️ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`): toolchain clean; G-1 is a fail-closed defect
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (`.claude/rules/python.md`): test files only
- ✅ Bash (`.claude/rules/shell.md`): syntax, shellcheck, and changed-line coverage pass
- ⚠️ `github-actions.instructions.md`: workflow content reviewed; no green run against the head (G-2)
- ✅ JSON: two manifest entries, validated by the pack-manifest completeness pytest files
- ✅ Canonical policy edits: unchanged in cycle 2 (`git diff 92f5eef9..HEAD` over `.claude/rules`, `.github/instructions`, `.agents`, `.claude/skills`, `.claude/agents` is empty)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; executor step scripts lived in a scratch directory outside the repository
- ✅ No host path appears in any line the branch adds (reviewer scan of the added lines of the full diff)
- The reviewer's probe scripts and kcov output were written to the session scratchpad only; the one reviewer record committed to the feature folder is `evidence/qa-gates/review-p3-ac42-kcov.2026-10-03T16-55.md`

## Rejected Scope Narrowing

None detected in the caller prompt. The caller supplied the base branch, merge base, head SHA, PR-context artifacts, AC source (including the Scope Extension and the cycle 2 additions), and prior-pass artifacts. It did not narrow scope to a plan, task, phase, file subset, or language.

The reviewer did not adopt one executor evidence statement. `evidence/qa-gates/r2-qc-loop-complete.2026-10-03T16-40.md` records shell format and lint as "N/A locally" and bash tests and coverage as CI-dependent. Bash has changed files on the branch, so this audit ran bats, kcov, shellcheck, and shfmt directly. It records an explicit PASS verdict for Bash coverage from that measurement.

## Evidence Location Compliance

- Branch diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: zero files.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`: exit 0, no violations reported.
- All feature evidence is under `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each new `It` and `@test` builds its own inputs; checkpoint seams are mocked per `BeforeEach`; bats `setup` re-sources the script per case. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Unit rows drive one pure function (`Test-CommandLineRawInvocation`, `Get-CommandLineRawInvocationOperand`, `Get-KcovFunctionCoverageReport`, `select_solution_file`); hook rows drive one decision seam. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 861 Pester tests in one reviewer run of a few minutes; 15 bats cases in seconds; 148 pytest cases in 0.53 s. |
| **Determinism** - Consistent results | ✅ PASS | Pure string inputs; bats replaces `nuget` and `pwsh` with shell functions; no clock, RNG, network, or temporary file. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row IDs (A824-X*, A824-WT10/11, P824-D16..D19, R824-P26..P30, C824-*, G824-*) and `-Because` messages. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 84.67% lines at the merge base and 85.46% at cycle-2 start; Python 94%; the changed bash functions had no measurement at the merge base.<br>**Timestamp:** 2026-10-03 09:46 and 15:59 (`evidence/baseline/coverage.2026-10-03T09-46.md`, `evidence/remediation-baseline/r2-coverage.2026-10-03T15-59.md`). |
| **No Coverage Regression** | ✅ PASS | PowerShell 85.52% repo-wide. The three gates lose one covered line each because the covered `NoOperand` allow line was deleted, and no uncovered line was added. The reviewer reproduced 95.5%, 93.58%, and 98.57%. |
| **New Code Coverage** | ✅ PASS | PowerShell: raw-invocation modules 80/80, `KcovFunctionCoverageGate.ps1` 63/63, `feature-review-coverage-thresholds.ps1` 21/21, no uncovered changed line in any hook. Bash: 6 changed functions at 100%, `UNCOVERED-CHANGED=NONE`. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | Line coverage of the operand reader is 100%, but no row combines an authorized and an unauthorized removal in one command (G-1). |
| **Positive Flows** - Valid inputs | ✅ PASS | Deny rows for X1-X10 and Y1-Y5 forms; allow rows with an authorizing record (A824-WT5-1..5); C824-9 and C824-13 drive the solution-present paths. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Reproduction and AC-6 allowed; A824-WT11 denies non-literal operands with a record; C824-8 and C824-12 drive the no-solution paths. |
| **Edge Cases** - Boundary conditions | ❌ FAIL | A command that names an authorized worktree and also removes another worktree, either in the same wrapped segment behind a redirection, subexpression, or `xargs`, or in a later segment, is untested and allowed (G-1). |
| **Error Handling** - Error paths | ✅ PASS | Unbalanced segments remain fail-closed; `KcovFunctionCoverageGate` throws on a missing class or function definition (G824 rows). |
| **Concurrency** - If applicable | N/A | Pure stateless functions. |
| **State Transitions** - If applicable | N/A | No state. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 84.67% lines (merge base) -> Post-change: 85.52% lines. Change: +0.85% lines. New/changed-code coverage: 100% (no uncovered changed line across the 10 measured files; new modules 80/80, 63/63, and 21/21 lines). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/r2-coverage-delta.2026-10-03T16-38.md`.
- Python: Baseline: 94% lines -> Post-change: 93.63% lines (94% as reported by pytest-cov; production Python is unchanged). Change: none attributable to the branch. New/changed-code coverage: no production Python line changed; only test files changed. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/r2-pytest.2026-10-03T16-38.md`.
- Bash: Baseline: 0% of the changed functions (no test sourced `.codex/codex-web-setup.sh` at the merge base) -> Post-change: 100% lines in each of the 6 changed functions (20 of 20 instrumented changed lines). Change: +100% on the changed functions. New/changed-code coverage: 100%, `UNCOVERED-CHANGED=NONE`. Whole-file figure 17.0% (34/200), the pre-existing remainder of the script; see G-4. Disposition: PASS. Evidence: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/review-p3-ac42-kcov.2026-10-03T16-55.md`.

Threshold note: per the threshold precedence (the root `CLAUDE.md` states no figures), the governing thresholds are 85% line and 75% branch. Pester and kcov measure no branch coverage, so no branch threshold applies to PowerShell or Bash. `artifacts/python/lcov.info` carries no branch records (BRF 0). The branch changes no production Python line, so this does not affect the Python verdict; it is a pre-existing measurement configuration.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` text on new Pester assertions; bats rows assert exact message substrings. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange/Act/Assert comments in new `It` and `@test` blocks. |
| **Document Intent** | ✅ PASS | Synopsis blocks; the bats file header states its determinism constraints. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No `gh`, network, git process, `nuget`, or `pwsh` call in any new test; bats stubs both commands. |
| **Use Mocks/Stubs** | ✅ PASS | Checkpoint and run-target seams mocked; bats shell-function stubs; Cobertura XML supplied as strings in G824 rows. |
| **Environment Stability** | ✅ PASS | No temporary files; the bats suite reads only its own directory and the committed fixture `tests/fixtures/codex_web_setup/populated-packages`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the pass-3 policy audit. Outstanding items: G-1, G-2. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` v0.3 records the cycle 2 design decision, AC-42, and AC-43 before the code change (commit 9dbceb3a precedes 425772de). |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-10-03T13-56.md` (preflight all clear, round 2) and `evidence/remediation-baseline/r2-phase0-instructions-read.2026-10-03T15-49.md`. |
| **Document the plan** | ✅ PASS | Remediation plan committed in bda1982b before the code change. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Classification is now one closed rule (each word present as a whole token), replacing the enumerated sequence grammar for classification. |
| **Reusability** | ✅ PASS | `Test-CommandLineRawWordPresent` is shared by the classifier and the absorption guard; the kcov gate is a reusable script. |
| **Extensibility** | ✅ PASS | The kcov gate takes the function list, threshold, and diff as parameters. |
| **Separation of concerns** | ✅ PASS | Pure decision functions in `KcovFunctionCoverageGate.ps1`; only `Invoke-KcovFunctionCoverageGate` reads files. Setup-script discovery split into functions that take their candidates as input. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Classification and operand reading in `hook-command-raw-invocation.ps1`; the kcov gate in its own script. |
| **Under 500 lines** | ✅ PASS | Largest changed files: `legacy-codex-hook-contracts.Tests.ps1` 497, `hook-command-invocation.ps1` 494, `test_push_down_tier_rule_adoption_gate.py` 493, `enforce-parallel-worktree-removal-gate.ps1` 480, `.codex/codex-web-setup.sh` 405 (reviewer `wc -l` over every changed non-Markdown file). |
| **Public vs internal** | ✅ PASS | Pinned public signatures unchanged (AC-29 pins pass without edits). |
| **No circular dependencies** | ✅ PASS | `hook-command-raw-invocation.ps1` calls `Resolve-CommandLineInvocation` at call time only, as documented. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Test-CommandLineRawWordPresent`, `Get-BashFunctionLineRange`, `resolve_repo_root`, `select_solution_file`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every new PowerShell function; argument comments on each new bash function. |
| **Comment why, not what** | ⚠️ PARTIAL | The gate comment states that a removal is gated on its operand "only when exactly one literal operand is read from it". The reader returns one literal operand even when a second removal in the same command names an operand it cannot read (G-1). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter` check-only with `pssa.settings.psd1` on the 40 changed `.ps1` files including mirrors (reviewer); `shfmt -d -i 2` on the setup script and `shfmt -d -i 4` on the bats file (reviewer).<br>**Result:** 0 drift; shfmt exit 0 for both. |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` (reviewer); `shellcheck -x .codex/codex-web-setup.sh` (reviewer).<br>**Result:** 0 findings; shellcheck exit 0. |
| **3. Type checking** | ✅ PASS | Python test files unchanged in cycle 2; pass-2 reviewer pyright run clean. PowerShell and bash have no type-check stage. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-Pester` on 31 suites that target changed files (reviewer); `bats` (reviewer); `pytest` on 6 files (reviewer).<br>**Result:** 861/861, 15/15, 148/148. Executor: 6826 Pester and 6595 pytest, 0 failures. |
| **Full toolchain loop** | ✅ PASS | One clean executor pass (`evidence/qa-gates/r2-qc-loop-complete.2026-10-03T16-40.md`). |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/qa-gates/` and in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit 425772de message; `evidence/other/containment-path-hook-audit.md` gains a cycle-2 addendum. |
| **Design choices explained** | ✅ PASS | `spec.md` `### Cycle 2 design decision`, including the accepted trades. |
| **Update supporting documents** | ✅ PASS | PR-body callouts recorded in `evidence/other/r2-pr-callouts.2026-10-03T16-43.md` (canonical edits, the Addendum 1 trade). |
| **Canonical policy edits authorized** | ✅ PASS | No canonical policy file changed in cycle 2; the cycle-1 edits remain within owner comment 5970141337 (pass-2 audit section 2.6). |
| **Provide next steps** | ⚠️ PARTIAL | The spec Non-Goals follow-ups are still not filed as potential records (carried advisory). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 drift on 40 changed files (reviewer); executor `Invoke-PoshQCFormat` clean. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings (reviewer and executor). |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | No 7-only syntax in the production modules; `KcovFunctionCoverageGate.ps1` runs under `pwsh` on the Linux runner as invoked. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on every new function. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `ValidateNotNullOrEmpty`, `AllowEmptyString` where needed. |
| **Avoid global state** | ✅ PASS | No new script or global variables. `KcovFunctionCoverageGate.ps1` sets `Set-StrictMode -Version Latest` at file scope, which applies to the dot-sourcing scope (code review CR-4, Info). |
| **Error handling** | ❌ FAIL | Fail-closed handling in the gate operand path is incomplete. A fully literal match with no readable operand contributes nothing to the operand set when another match supplies a literal operand, and later classifying segments are not read (G-1). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 300, 247, 68, and 494 lines for the shared modules and the gate script. |
| **Approved verbs** | ✅ PASS | `Get`, `Test`, `Resolve`, `Invoke`. |
| **Comment why** | ⚠️ PARTIAL | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 3B.1. |
| **Step 2: Analyze** | ✅ PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 6826 total, 0 failures (executor); 861/861 (reviewer). |
| **Rerun loop if needed** | ✅ PASS | Clean in one pass. |

### Section 3A: Python Code Change Policy Compliance (test files only)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting (Black)** | ✅ PASS | Executor `r2-black.2026-10-03T16-26.md`; files unchanged since the pass-2 reviewer check. |
| **Linting (Ruff)** | ✅ PASS | Executor `r2-ruff.2026-10-03T16-28.md`. |
| **Type checking (Pyright)** | ✅ PASS | Executor `r2-pyright.2026-10-03T16-28.md`. |
| **Typed signatures** | ✅ PASS | All functions annotated. |

### Section 3C: Bash Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Syntax** | ✅ PASS | `bash -n` exit 0 on the setup script (reviewer) and on both copies (executor `r2-sh-syntax.2026-10-03T16-02.md`). |
| **Strict mode preserved** | ✅ PASS | `set -euo pipefail` unchanged; the `find` call in `list_root_solution_files` exits 0 on an empty result. |
| **Source safety** | ✅ PASS | Last line is the `BASH_SOURCE` guard; C824-1 pins it; sourcing in bats `setup` does not run `main`. |
| **Lint (shellcheck)** | ✅ PASS | Setup script: no finding. The bats file reports SC2034 and SC2329 for variables and stubs consumed through `run`, a known bats false-positive pattern; `.bats` files are outside the shell-QC discovery roots (code review CR-5, Info). |
| **Tests for changed behavior** | ✅ PASS | C824-1..C824-15 drive every changed function, including both no-solution branches. |

### Section 3E: GitHub Actions Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Static validity** | ✅ PASS | Executor actionlint and YAML parse clean (`r2-shell-qc.2026-10-03T16-39.md`); `ShellCoverageWorkflow.Tests.ps1` passes (reviewer). |
| **Behavior verified locally** | ✅ PASS | The reviewer ran the two kcov invocations and the gate call from the new steps with the same arguments; gate exit 0. |
| **Green run against branch head** | ❌ FAIL | Head `425772de` is not on any remote branch (`git branch -r --contains HEAD` is empty) and no PR exists, so no run of `ci.yml` / `shell-coverage` exists against it (G-2). |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | Unchanged in cycle 2; `evidence/qa-gates/r1-manifest-json.2026-10-03T13-41.md`. |
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
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .` (executor).<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; the reviewer measured `scripts/dev-tools/KcovFunctionCoverageGate.ps1` with a scoped `CodeCoverage.Path`, because the standing artifact covers hook paths. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Test files declare `#Requires -Version 7.0`, matching existing suites. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Unit rows per module plus hook-level rows. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert decisions, classifications, operand outcomes, and gate messages. |
| **Mocking Used Sparingly** | ✅ PASS | Only checkpoint and run-target seams. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1`<br>**Code file:** `scripts/dev-tools/KcovFunctionCoverageGate.ps1`<br>Mirrors the production tree. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Cycle-2 Contexts per authorization state. |
| **Logical Grouping** | ✅ PASS | "without an authorizing record" and "with an authorizing record" Contexts. |
| **Docstrings/Comments** | ✅ PASS | Synopsis blocks and row labels. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** 6826 total, 0 failures. |
| **No Alternative Test Runners** | ✅ PASS | Pester for PowerShell; bats for bash. |

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | ✅ PASS | 148 pass (reviewer). |
| **No temporary files** | ✅ PASS | Committed files only. |
| **Discriminating checks** | ✅ PASS | Self-tests prove the scans can fail (pass-2 finding, unchanged). |

---

## 5. Test Coverage Detail

### hook-command-raw-invocation.ps1 (both runtimes)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| R824-P*, R824-N*, R824-P26..P30 | Positive, negative, order independence | classifier and pattern builder | ✅ |
| Operand rows, A824-X*, A824-WT6/10/11 | Operand, NoOperand, Indeterminate | operand reader and resolver | ✅ |

**Coverage:** 80/80 lines on each runtime (reviewer).

**Not covered (behavior):** a command that combines an authorized literal operand with a second, unreadable or later-segment removal (G-1).

### KcovFunctionCoverageGate.ps1

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| G824 rows | Pass, below threshold, missing class, missing function, diff parsing | all functions | ✅ |

**Coverage:** 63/63 lines (reviewer).

### .codex/codex-web-setup.sh

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| C824-1..C824-15 | Guard, discovery, restore, verification, notes | 6 changed functions | ✅ |

**Coverage:** 20/20 instrumented changed lines (reviewer kcov).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 6826 Pester and 6595 pytest (executor); 861 Pester, 15 bats, 148 pytest (reviewer) | ✅ |
| Tests Passed | 100% of enabled tests | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | a few minutes for 31 Pester suites; seconds for bats | ✅ Fast |
| Test File Size | max 497 lines | ✅ Maintainable |
| Code Coverage (if applicable) | PowerShell 85.52% repo-wide, 100% changed lines; Bash 100% of changed functions | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | check-only with `pssa.settings.psd1` | 0 of 40 files drift | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with `pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `Invoke-Pester` on 31 suites with scoped coverage | 861/861 | ✅ |

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Syntax | `bash -n .codex/codex-web-setup.sh` | exit 0 | ✅ |
| shellcheck | `shellcheck -x .codex/codex-web-setup.sh` | exit 0 | ✅ |
| shfmt | `shfmt -d -i 2` (setup), `shfmt -d -i 4` (bats) | exit 0 | ✅ |
| bats | `bats tests/shell/test_codex_web_setup_codex_copy.bats` | 15/15 | ✅ |
| kcov gate | `Invoke-KcovFunctionCoverageGate` on the reviewer kcov report | exit 0 | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Pytest | `poetry run python -m pytest` on 6 files | 148 passed | ✅ |

**Notes:** Mirror parity: each four-copy group of `hook-command-raw-invocation.ps1` and `hook-command-invocation.ps1`, and the two setup-script copies, yields one SHA-256. No PR exists for the branch, so CI (AC-27) has not run.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **G-1 (Blocking, autonomous) - worktree-removal gates authorize a whole command from one literal operand.** Reviewer probe, merge base `f6ef5b2f` versus head `425772de`, through `Invoke-EpicWorktreeRemovalGateDecision` and `Invoke-ParallelWorktreeRemovalGateDecision`. The checkpoint authorizes only `/repo/worktrees/item-b-102`. Six commands (W1-W6 in code review CR-1) that also remove `/repo/worktrees/item-a-101` are denied at base and allowed at head on both Claude gates. Four of them were also confirmed on `Invoke-CodexWorktreeRemovalDecision`. The controls behave as expected: `bash -c "git worktree remove /repo/worktrees/item-a-101"` is denied at both commits, and `bash -c "git worktree remove /repo/worktrees/item-b-102"` is allowed at head. See code review CR-1 and remediation inputs R1.
- **G-2 (Blocking, awaiting_ci) - modified workflow without a green run against the head.** `.github/workflows/_shell-coverage.yml` gains three steps. No run of the `ci.yml` reusable `shell-coverage` job exists for `425772de`. See remediation inputs R2.
- **G-3 (Non-blocking) - pre-existing first-segment-only reading on the structural path.** `git worktree remove /repo/worktrees/item-b-102 && git worktree remove /repo/worktrees/item-a-101` is allowed at both the merge base and head. This is not a regression. The remediation of G-1 may close it with the same change. Otherwise, record it as a follow-up.
- **G-4 (Non-blocking, carried) - shell-QC discovery roots exclude `.codex/`.** The policy conflict with the Coverage Exclusion Policy is recorded in the spec Non-Goals and still needs an owner decision. The whole-file kcov figure for the setup script is 17.0%.
- **G-5 (Non-blocking, carried) - residual No-COM names in `.claude/rules/typescript.md` and `.claude/rules/csharp.md`; fixed 80% floor in `.codex/hooks/validate-feature-review-coverage.ps1`; spec Non-Goals follow-ups not filed.**

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None.** The `A824-WT6` expected decision changed from allow to deny, as specified by the cycle 2 design decision. The change is recorded in `spec.md` and is not an assertion edit made to pass a failing test.

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
8. **92f5eef9** - docs(824): add feature-review pass 2 artifacts (3 blocking, autonomous)
9. **9dbceb3a** - docs(824): amend spec for whole-token matching and fail-closed removal operands
10. **bda1982b** - docs(824): add remediation cycle 2 plan (preflight all clear, round 2)
11. **425772de** - fix(824): harden hook raw-invocation gates and add kcov coverage gate

### Files Modified

1. Raw-invocation module (both runtimes and mirrors): whole-token classifier; sequence and absorption grammar kept for operand extraction only.
2. Three worktree-removal gates: `NoOperand` allow removed; only a single literal operand replaces the structural path.
3. `hook-command-invocation.ps1` (both runtimes): contract comments.
4. `.codex/codex-web-setup.sh` (and mirror): discovery functions and the source guard.
5. `.github/workflows/_shell-coverage.yml` and the new `scripts/dev-tools/KcovFunctionCoverageGate.ps1`.
6. New tests: bats suite and fixture, kcov gate and workflow Pester suites, cycle-2 gate and promotion rows.
7. Feature folder documents and evidence.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain, coverage for every changed language, structure, parity, canonical-edit authorization, and evidence-location requirements are met. One autonomous blocking finding (G-1) and one awaiting-CI finding (G-2) remain.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec v0.3 and a preflighted remediation plan precede the code change
- ✅ Design Principles: classification is one closed rule
- ✅ Module & File Structure: every file at or below 497 lines
- ⚠️ Naming, Docs, Comments: the gate comment overstates what the operand reader proves
- ✅ Toolchain Execution: clean loop
- ⚠️ Summarize & Document: Non-Goals follow-ups not filed

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean
- ❌ PowerShell Design & Safety: gate operand path not fail-closed for multi-removal commands (G-1)
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: clean

**For Bash:** ✅ syntax, shellcheck, shfmt, bats, and changed-line coverage pass

**For GitHub Actions:** ❌ no green run against the head (G-2)

**For Python:** ✅ test files clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, deterministic
- ⚠️ Coverage & Scenarios: multi-removal edge case untested (G-1)
- ✅ Test Structure: AAA and `-Because` messages
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC
- ✅ Test Style & Structure: behavior-focused rows
- ✅ Naming & Readability: row IDs and labels
- ✅ Toolchain: 6826 total, 0 failures

---

### Metrics Summary

- ✅ 6826 Pester and 6595 pytest tests, 0 failures (executor); 861 Pester, 15 bats, 148 pytest (reviewer)
- ✅ PowerShell 85.52% repo-wide; 100% of changed PowerShell lines covered
- ✅ Bash: 100% of the changed functions, no uncovered changed line
- ✅ Format, analyze, shellcheck, and parity checks pass
- ❌ Six worktree removals allowed at head that the merge base denies when the command also names an authorized worktree (G-1)
- ❌ No workflow run against the head for the modified workflow (G-2)

---

### Recommendation

**Needs revision**

Remediate R1 in `remediation-inputs.2026-10-03T16-55.md`. Make the wrapped-operand resolution fail closed when any removal in the command does not yield the same literal operand, and when more than one segment classifies. Add deny rows for each probed command on all three gates. Then push the branch and obtain a green `shell-coverage` run on the head to satisfy R2.

---

## Appendix A: Test Inventory

### Complete Test List

1. hook-command-raw-invocation (both runtimes): classifier, order-independence, operand, and resolver rows
2. hook-command-invocation (both runtimes): N824-1 negative control; renamed whole-token test
3. enforce-promotion-mcp-only trigger scoping (both runtimes): P824-A*, P824-D1..D19
4. enforce-pr-author-skill trigger scoping: A824-PR1
5. enforce-epic-worktree-removal-gate trigger scoping (both runtimes): A824-WT1..WT11, A824-X1..X10
6. enforce-parallel-worktree-removal-gate trigger scoping: same rows as the epic gate
7. validate-bash, preimplementation-gate, epic-merge-gate trigger scoping (both runtimes)
8. validate-feature-review-coverage.Issue824 and feature-review-coverage-thresholds
9. KcovFunctionCoverageGate.Tests.ps1 and ShellCoverageWorkflow.Tests.ps1
10. legacy-codex-hook-contracts: SharedModuleNames row
11. test_codex_web_setup_codex_copy.bats: C824-1..C824-15
12. test_push_down_issue_824_follow_ups.py and test_push_down_tier_rule_adoption_gate.py

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting (check-only, reviewer)
Invoke-Formatter -ScriptDefinition (Get-Content <file> -Raw) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting (reviewer)
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Tests with scoped coverage (reviewer, 31 suites that target changed files)
$c = New-PesterConfiguration; $c.Run.Path = <suite paths>; $c.CodeCoverage.Enabled = $true; $c.CodeCoverage.Path = <10 changed production files>; Invoke-Pester -Configuration $c

# Base-versus-head decision probe (reviewer)
git archive f6ef5b2f .claude/hooks .claude/lib .codex/hooks   # extracted into the session scratchpad
Invoke-EpicWorktreeRemovalGateDecision / Invoke-ParallelWorktreeRemovalGateDecision / Invoke-CodexWorktreeRemovalDecision / Invoke-PromotionMcpOnlyDecision

# Full PoshQC loop (executor)
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

**For Bash (reviewer, WSL Ubuntu):**
```bash
bash -n .codex/codex-web-setup.sh
shellcheck -x .codex/codex-web-setup.sh
shfmt -d -i 2 .codex/codex-web-setup.sh
bats tests/shell/test_codex_web_setup_codex_copy.bats
kcov --include-pattern=<worktree>/.codex/codex-web-setup.sh <scratch>/run "$(command -v bats)" tests/shell/test_codex_web_setup_codex_copy.bats
kcov --merge <scratch>/merged <scratch>/run
git diff --unified=0 f6ef5b2f HEAD -- .codex/codex-web-setup.sh
```

**For Python:**
```bash
poetry run python -m pytest -q -p no:cacheprovider <the two #824 test files plus the four push-down parity files>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-03
**Policy Version:** Current (as of audit date)
