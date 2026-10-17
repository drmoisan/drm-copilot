# Policy Compliance Audit: Exempt-operand UNC path-leg fix (#937)

---

**Audit Date:** 2026-10-16
**Audit Type:** Initial feature review (full branch diff against the resolved base)
**Branch:** `bug/exempt-operand-unc-path-leg-937` (HEAD `d8ad225b2b05011e45acfe11f3e8df19825ff908`)
**Base:** `origin/main` (tip `97559c3e0`; merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Work Mode:** `full-bug` (AC source: `spec.md` AC-1 to AC-15)
**Code Under Test:** 45 changed files (1968 insertions, 0 deletions). Non-documentation code: 4 production PowerShell files (the canonical `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` and three byte-identical copies under `.codex/hooks/` and the two `extensions/drm-copilot/resources/` bundles), each +7/-0; 3 Pester test files (+82/-0, +3/-0, +3/-0). The remaining 38 files are feature-folder documentation and evidence.

**Total blocking findings: 1** (PA-0, PowerShell canonical coverage artifact below the 85% line floor; remediability `autonomous`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 7 files (4 production incl. 2 bundle mirrors, 3 test) | 10422 Windows testcases (all suites, CI); 6335 Linux hook-suite testcases (CI); 6335 local scoped testcases | Tests PASS: 10412 pass, 0 fail, 10 disabled (Windows); 6335 pass (Linux); 6335 pass (local). Coverage FAIL (PA-0) | 90.42% lines repo-wide (CI run 38833589314); targets copies 99.39% | 66.04% lines repo-wide in canonical `artifacts/pester/powershell-coverage.xml` (scoped two-folder local run; FAIL, below 85%); 90.41% in full-suite CI run 38844097853; targets copies 99.40% | 100% of changed executable lines (3/3 per measured copy: lines 40, 228, 229) |
| Python | 0 files | N/A | N/A (push-down contract tests run for AC-12: 23 passed) | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

PowerShell coverage verdict: **FAIL** (PA-0). The canonical PowerShell coverage artifact named by the feature-review contract, `artifacts/pester/powershell-coverage.xml`, reports 66.04% repo-wide line coverage, below the 85% line floor (default; root `CLAUDE.md` states no threshold). That artifact was produced by the executor's scoped local `run_poshqc_test` (2 test folders, 6335 testcases), not by a full-suite run. The full-suite CI artifact (run 38844097853, 10422 testcases, 203 source files) reports 90.41%, and changed-line coverage is 3/3 on both measured copies. The contract requires a FAIL when the canonical artifact is below the floor, so the reviewer records FAIL and does not substitute the CI figure. Remediation: regenerate the canonical artifact from a full-suite run (see PA-0). Pester measures line coverage only; no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/coverage-baseline.2026-10-16T01-33.md` (CI run 38833589314, `poshqc-test-results` artifact)
- PowerShell post-change coverage artifact: `docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-final.2026-10-16T03-32.md` (CI run 38844097853)
- Per-language comparison summary: `docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-delta.2026-10-16T03-32.md` and section 1.2.1 of this audit
- Reviewer re-verification: this reviewer downloaded the `poshqc-test-results` artifact of both runs independently into the session scratchpad and re-parsed `powershell-coverage.xml` with a standard-library script. The results match the executor's figures: baseline 16381/1735 (90.423%), final 16385/1737 (90.415%); both targets copies 165/166 with lines 40, 228, 229 at `ci` >= 1.
- PowerShell canonical coverage artifact `artifacts/pester/powershell-coverage.xml` (gitignored, local): present, written 2026-10-16 03:03 UTC by the executor's scoped `run_poshqc_test` (`scan_folders` = `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`; local `artifacts/pester/pester-junit.xml` reports 6335 tests). Report LINE counter: covered 8110, missed 4170 = 66.04%. PowerShell coverage verdict on this artifact: FAIL (PA-0). The SubagentStop hook `validate-feature-review-coverage.ps1` reads this path.

---

## Executive Summary

The branch fixes #937. In the R1 path-leg loop of `Get-OrchestrationCommandTarget`, a raw path-leg input with a UNC, extended-length, device, or NT-object prefix (either separator style), or a drive-relative spelling, now returns an unresolved `path-not-local` result. Previously such input resolved to the session root. The production change is two additions (one module-scope pattern and one three-line guard) applied byte-identically to four copies. Tests add 20 unit `It` rows per surface (U27 to U31) and 6 gate rows.

Fail-before (CI run 38838282195) shows exactly the 42 expected testcases failing and the 4 `U28` keep-behavior rows passing. Pass-after (CI run 38844097853, `workflow_dispatch` on `fd138e1ca`) concluded success on all 17 jobs. Commits after `fd138e1ca` (`d8ad225b2`) change only feature-folder paths.

One blocking finding is recorded (PA-0). The canonical PowerShell coverage artifact named by the feature-review contract, `artifacts/pester/powershell-coverage.xml`, reports 66.04% repo-wide line coverage. That is below the 85% floor, so the contract requires FAIL and a remediation trigger. The artifact comes from a scoped local run of the two hook test folders only. The full-suite CI artifact for the same code reads 90.41%, so the expected remediation is to regenerate the canonical artifact from a full-suite run, not to add tests. The finding is classified `autonomous`.

A second coverage observation needed an explicit judgment. The report-level PowerShell line coverage moved from 90.42% to 90.41%. The difference is two lines in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`, a module this branch does not change. Both lines have direct unit tests that passed in both runs, so the cause is variance in the coverage instrument's line attribution, not lost test execution. Measured on the full-suite CI artifact, the governing conditions are met for this observation: repo-wide line coverage is at or above 85%, every changed file is at or above 85%, and no changed line regressed. The observation is therefore recorded as Non-blocking (PA-1).

**Policy documents evaluated:**
- PASS `CLAUDE.md` (tone, policy order)
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` classifies `.claude/hooks`, `.codex/hooks`, and `extensions/drm-copilot` as T3)

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (PowerShell code change and unit test)
- N/A Python, TypeScript, C#, Bash: no changed files.

**Temporary artifacts cleanup:**
- PASS: no temporary script is committed. Executor helper scripts (`junit_status.py`, `jacoco_targets.py`, `jacoco_compare.py`) lived under the session scratchpad (`SCRATCH`) and are not in the branch diff.
- This reviewer wrote one parsing script and two downloaded CI artifacts to the session scratchpad only. The only tracked files this reviewer wrote or changed are the three review artifacts, the AC-14 check-off in `spec.md`, and the regenerated (untracked) `artifacts/pr_context.*.txt`.

---

## Rejected Scope Narrowing

The caller prompt contained a scope statement: "Scope: four byte-identical copies of enforce-orchestration-preimplementation-gate-targets.ps1 (.claude/hooks, .codex/hooks, and the two extensions/drm-copilot/resources mirrors) and three Pester test files under tests/scripts/claude-hooks and tests/scripts/codex-hooks."

Justification: this text describes the code content of the branch rather than narrowing the review. The reviewer confirmed with `git diff --name-only origin/main...HEAD` that the only non-feature-folder files changed are exactly these seven, and audited the full branch diff, including all feature-folder documents and evidence. No language coverage was marked out of scope and no toolchain check was skipped.

## Evidence Location Compliance

- `poetry -C <worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` (run by this reviewer at `d8ad225b2`): exit 0.
- `git diff --name-only origin/main...HEAD -- artifacts/` lists no path. The branch adds nothing under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 35 evidence files sit under `docs/features/active/exempt-operand-unc-path-leg-937/evidence/<kind>/` with kinds `baseline`, `regression-testing`, `qa-gates`, `other`.
- Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entry was needed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | U27 to U31 are pure calls of `Get-OrchestrationCommandTarget` / `Get-OrchestrationPatchMarkerPath` with data-row literals. Gate rows reuse the existing per-row `Set-TargetSeam` / `Set-CodexTargetSeam` arrangement. |
| **Isolation** - Each test targets single behavior | PASS | One spelling per U27/U28 row; U29 (sibling ordering), U30 (dot-segment ordering), and U31 (marker extraction) each test one rule interaction. |
| **Fast Execution** - Tests complete quickly | PASS | Pure string logic; the Linux hook-suite job grew from 6289 to 6335 testcases with all passing. |
| **Determinism** - Consistent results | PASS | No clock, randomness, sleep, network, process, or filesystem use in the added rows. Reviewer grep of the added test lines for `TestDrive`, `New-TemporaryFile`, `Join-Path`, `Resolve-Path`, `Test-Path`, `Split-Path`, and `System.IO.Path` returned 0 matches. |
| **Readability & Maintainability** - Clear structure | PASS | Row keys `U27` to `U31` and `(issue #937)` gate-row names; every assertion carries `-Because`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development):** PowerShell report 90.42% lines; each targets copy 99.39% (CI run 38833589314).<br>**Timestamp:** 2026-10-16T01-33 (`coverage-baseline.2026-10-16T01-33.md`) |
| **No Coverage Regression** | PASS | **Post-change coverage:** report 90.41%; targets copies 99.40% each (CI run 38844097853).<br>**Status:** No changed line regressed (3/3 changed executable lines covered on both measured copies). The report-level -0.01 point difference is attributable to `WorktreeTargetResolution.psm1` lines 116 and 335 in an unchanged module (PA-1, Non-blocking). |
| **Repo-wide PowerShell line coverage, canonical artifact** | FAIL | `artifacts/pester/powershell-coverage.xml` reports 66.04% (8110 / 12280 lines) from a scoped two-folder local run; below the 85% floor. PA-0 (blocking, `autonomous`). The full-suite CI artifact reads 90.41%. |
| **New Code Coverage >=85% (uniform tier rule)** | PASS | No new production file. Both measured modified files are at 99.40%. Changed-line coverage 100%. |
| **Comprehensive Coverage** | PASS | The new branch (`if` line 228, `return` line 229) and the pattern assignment (line 40) are covered on both surfaces. The only uncovered line in each targets copy is the pre-existing line 171 (baseline line 167). |
| **Positive Flows** - Valid inputs | PASS | U28 (bare drive roots `C:\` and `C:/` stay resolved to `C:/`); existing U01 to U05 still pass. |
| **Negative Flows** - Invalid inputs | PASS | U27 (15 non-local spellings), U31 (marker path), and 6 gate deny rows. |
| **Edge Cases** - Boundary conditions | PASS | Bare `\\` and `//`, mixed separators, bare `C:`, and `\\server\share\..\x` (U30). |
| **Error Handling** - Error paths | PASS | Unresolved-result shape (`Resolved`, empty `Targets`, `ReasonCode`, exact `Detail`) is asserted in U27. |
| **Concurrency** - If applicable | N/A | No concurrent code path changed. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% lines repo-wide (16381 covered / 1735 missed) -> Post-change: 90.41% lines repo-wide (16385 / 1737). Change: -0.01 points repo-wide. Targets copies 99.39% -> 99.40%. New/changed-code coverage: 100% (lines 40, 228, 229 on both measured copies). On the full-suite CI artifact, repo-wide and per-file values are above the 85% line floor and no changed line regressed. On the canonical local artifact `artifacts/pester/powershell-coverage.xml`, repo-wide line coverage is 66.04% (scoped two-folder run), below the floor. Disposition: FAIL (PA-0) until the canonical artifact is regenerated from a full-suite run. Evidence: `evidence/baseline/coverage-baseline.2026-10-16T01-33.md`, `evidence/qa-gates/coverage-final.2026-10-16T03-32.md`, `evidence/qa-gates/coverage-delta.2026-10-16T03-32.md`, plus this reviewer's independent re-parse of both CI XML artifacts.
- Bundle mirrors: the two `extensions/drm-copilot/resources/...` copies are outside the coverage population defined by `config/poshqc-coverage.json` (roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`). This branch does not change that configuration and adds no `exclude` entry. The mirrors are byte-identical to the measured canonical copy (`git hash-object` `ef89c7f2e...` for all four; Parity suite passes).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Every new assertion uses `-Because`; fail-before MESSAGE lines name the actual value (`but got $true`, `'allow'`). |
| **Arrange-Act-Assert Pattern** | PASS | U27 to U31 carry `# Arrange`, `# Act`, `# Assert` markers. Gate rows reuse the existing AAA body of the data-driven `It`. |
| **Document Intent** | PASS | Each new `It` references issue #937 in its Arrange comment. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No UNC share, device path, or network is touched; all inputs are string literals. |
| **Use Mocks/Stubs** | PASS | Gate rows use the existing filesystem seams (`Set-TargetSeam`, `Set-CodexTargetSeam`). |
| **Environment Stability** | PASS | No temporary files; no path API receives a UNC string, so behavior is the same on the Linux and Windows CI legs (both green). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit. Outstanding non-blocking items: AC-15 pending PR CI at S9; PA-1 plan-task disposition. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `spec.md` Context, Root Cause Analysis, and Proposed Fix; `research/research.2026-10-15T17-46.md` section 4.3. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.2026-10-16T00-30.md`, `evidence/baseline/inputs-read.2026-10-16T00-30.md`. |
| **Document the plan** | PARTIAL | `plan.2026-10-15T17-45.md`: 49 of 50 tasks checked. P3-T12 is unchecked because its plan-specific condition ("no post-change value below its baseline") was not met for the report row. See PA-1 (Non-blocking). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One regex constant and one guard statement; no new function. |
| **Reusability** | PASS | Reuses `New-OrchestrationTargetResult` and the existing `target-unresolvable` reason code and deny text. |
| **Extensibility** | PASS | Function signature and result shape are unchanged. |
| **Separation of concerns** | PASS | Pure string logic stays in the targets module; no I/O was added. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The change sits in the R1 path-leg loop it fixes. |
| **Under 500 lines** | PASS | Reviewer `wc -l`: targets copies 431; targets test suite 481; Claude EpicScopeTargets suite 152; Codex epic-scope-targets suite 157. |
| **Public vs internal** | PASS | `$script:` scope for the new pattern, matching its sibling patterns. |
| **No circular dependencies** | PASS | No new dot-source or import. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `OrchestrationTargetNonLocalPattern`; rule token `path-not-local`. |
| **Docs/docstrings** | PASS | Two-line comment above the pattern names the prefixes it matches and why it runs before normalization. |
| **Comment why, not what** | PASS | The comment states that the test runs on the raw value before normalization. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` over six folders: ok, seven in-scope hashes identical before and after (`evidence/qa-gates/poshqc-format-final.2026-10-16T02-46.md`). |
| **2. Linting** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`: ok (`poshqc-analyze-final.2026-10-16T02-48.md`). CI log of run 38844097853 reads `PSScriptAnalyzer passed: no findings` on the Windows and Linux legs (reviewer `gh run view --log` grep). |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Architecture-boundary tests** | N/A | No architecture-boundary suite is defined for PowerShell hooks; no new dependency was introduced. |
| **5. Testing** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` ok (`LocalOkBaseline: true`); CI Windows 10422 testcases, 0 failures; CI Linux 6335/6335. |
| **6. Contract checks** | PASS | Push-down resource contract tests: 23 passed (`python-contract-final.2026-10-16T03-05.md`). |
| **7. Integration tests** | PASS | End-to-end gate rows on the Claude (Write) and Codex (`apply_patch`) surfaces pass in CI. |
| **Full toolchain loop** | PASS | `evidence/qa-gates/qa-loop-pass.2026-10-16T03-05.md`: one pass, no rewrite. |
| **Explicit reporting** | PASS | Every stage has a timestamped evidence artifact with `Command:` and `EXIT_CODE:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages and the evidence map `evidence/other/ac-evidence-map.2026-10-16T03-33.md`. |
| **Design choices explained** | PASS | `spec.md` Proposed Fix (option (b), fail closed); option (a) recorded as a non-goal. |
| **Update supporting documents** | PASS | All four copies updated byte-identically; no rule, skill, or changelog documents the rule tokens (`spec.md` Data/API section; reviewer grep for `path-dot-segment` found only the four copies and the test file). |
| **Provide next steps** | PASS | `spec.md` Rollout section names the optional `Resolve-WorktreeOperandTarget` single-feature follow-up. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `run_poshqc_format` and CI `poshqc / PowerShell QC`<br>**Result:** no change; CI success. |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `run_poshqc_analyze` and CI<br>**Result:** no findings. |
| **Fix all findings** | PASS | No suppression was added. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Only `-match` and a .NET regex with a negative lookahead are used; both are available in 5.1 and 7.x. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | No function was added; the edited function keeps `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | PASS | Unchanged. |
| **Avoid global state** | PASS | The new value is a `$script:` constant. |
| **Error handling** | PASS | Fail closed via the existing unresolved-result factory; no silent catch. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 431 lines per copy; every line at or below 120 characters (`targets-size-check.2026-10-16T02-24.md`; Parity suite). |
| **Approved verbs** | PASS | No new function; analyzer clean. |
| **Comment why** | PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | `poshqc-format-final.2026-10-16T02-46.md`; CI success. |
| **Step 2: Analyze** | PASS | `poshqc-analyze-final.2026-10-16T02-48.md`; CI `PSScriptAnalyzer passed: no findings`. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | `poshqc-test-final.2026-10-16T03-05.md`; CI run 38844097853. |
| **Rerun loop if needed** | PASS | One loop pass with no rewrite. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `-ForEach` data rows inside the existing surface-parameterized `Describe`. |
| **Use PoshQC Configuration** | PASS | **Command:** `run_poshqc_test` and CI<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged). |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | Suites pass on the Windows and Linux CI legs. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | One spelling or one rule interaction per row. |
| **Test Behavior Over Implementation** | PASS | Rows assert the result contract (`Resolved`, `Targets`, `ReasonCode`, `Detail`) and gate outcome codes, not regex text. |
| **Mocking Used Sparingly** | PASS | Only the existing gate seams are used. |
| **Organization** | PASS | **Test file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`<br>**Code file:** `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and `.codex/hooks` via the surface `-ForEach`). Follows the existing `tests/scripts/<surface>-hooks/` layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | No new file; existing names end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | Rows appended inside the existing `Describe`. |
| **Logical Grouping** | PASS | U27 to U31 follow U26. |
| **Docstrings/Comments** | PASS | Arrange comments reference #937. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | **Command:** `run_poshqc_test`<br>**Result:** ok; per-row results from CI junit (`ci-pass-after.2026-10-16T03-29.md`: 46/46 issue rows, 29/29 invariant rows, 6335/6335 total). |
| **No Alternative Test Runners** | PASS | Pester through PoshQC and CI only. |

---

## 5. Test Coverage Detail

### `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and `.codex/hooks` copy)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| U27 gives path-not-local for `<Label>` (15 rows) | Negative / Edge Case | 40, 228, 229 | PASS |
| U28 keeps a bare drive root path-leg input (2 rows) | Positive | 228 (no match), 231-236 | PASS |
| U29 denies a non-local input with a valid sibling | Negative | 228, 229 | PASS |
| U30 path-not-local before path-dot-segment | Edge Case | 228, 229 | PASS |
| U31 non-local apply_patch marker path | Negative | 86-89, 228, 229 | PASS |

**Coverage:** 99.40% (165 covered, 1 missed) per copy; baseline 99.39%.

**Not covered:** line 171 (pre-existing; baseline line 167).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Pester 10422 (Windows, all suites); 6335 (Linux hook suites) | PASS |
| Tests Passed | 10412 + 10 disabled (Windows); 6335 (Linux) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Pester Windows 839.2s (CI junit) | PASS |
| Average Time per Test | About 80ms (Windows, all suites) | PASS |
| Discovery Time | Not separately reported | N/A |
| Functions/Classes Tested | `Get-OrchestrationCommandTarget` (R1 path-leg loop), `Get-OrchestrationPatchMarkerPath`, epic-scope gate decisions on both surfaces | PASS |
| Test File Size | 481, 152, 157 lines (all under 500) | PASS |
| Code Coverage (if applicable) | PowerShell canonical artifact 66.04% lines repo-wide (scoped local run); full-suite CI 90.41%; targets copies 99.40% | FAIL (PA-0) |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `run_poshqc_format` / CI | ok / no change | PASS |
| PSScriptAnalyzer | `run_poshqc_analyze` / CI | no findings | PASS |
| Pester Tests | `run_poshqc_test` / CI | 0 failed | PASS |

**Notes:**
CI run 38844097853 is a `workflow_dispatch` run on `fd138e1ca`. The one later commit (`d8ad225b2`) changes only feature-folder evidence. AC-15 names the PR head and is checked off by the orchestrator at S9. The S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE. The branch is 23 commits behind `origin/main`, none of which touch an in-scope file (`git merge-tree --write-tree origin/main HEAD` exit 0). Rebase before the PR is opened.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-0 (Blocking; remediability `autonomous`): canonical PowerShell coverage artifact below the 85% line floor.**
  - Observation: `artifacts/pester/powershell-coverage.xml` (the contract's canonical PowerShell artifact, read by the SubagentStop hook `validate-feature-review-coverage.ps1`) reports LINE covered 8110, missed 4170 = 66.04% repo-wide. The paired local `artifacts/pester/pester-junit.xml` reports 6335 tests, 0 failures. Both were written at 2026-10-16 03:03 UTC by the executor's P3-T3 `run_poshqc_test` with `scan_folders` limited to `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`.
  - Cause: the coverage population (`config/poshqc-coverage.json` roots) spans all PowerShell production roots, while only the hook test folders ran, so production code exercised by other suites (`tests/scripts/claude-lib`, `tests/scripts/powershell`, and others) is counted as missed. The full-suite CI artifact for the same code (run 38844097853, 10422 testcases, 203 source files) reads 90.41%.
  - Rule: the feature-review contract requires FAIL and a remediation trigger when the canonical artifact's repo-wide line coverage is below the governing floor (85%, default). The reviewer does not substitute a different artifact for the canonical one.
  - Required remediation: produce a full-suite PowerShell coverage artifact at `artifacts/pester/powershell-coverage.xml`. For example, run `mcp__drm-copilot__run_poshqc_test` without the two-folder `scan_folders` restriction, so that every suite under `tests/scripts` and `tests/powershell` runs. Record its LINE counter in a new `evidence/qa-gates/` artifact and confirm repo-wide >= 85% and lines 40, 228, 229 covered on both measured copies. Then request a re-review. No production or test change is expected.
- **PA-1 (Non-blocking): report-level PowerShell line coverage 90.42% -> 90.41%; plan task P3-T12 unchecked.**
  - Observation: two lines in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (116, a `throw`; 335, an early `return`) are `ci` 1 in the baseline XML and `ci` 0 in the final XML. The reviewer re-parsed both XMLs and reproduced this. The module is unchanged on the branch.
  - The direct tests for both lines (`refuses a resolved Status without a WorktreeRoot` and `join composes an absolute path from a blank remainder` in `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1`) report `status="Passed"` in the Windows junit of both runs. The lines therefore executed in the final run, and the coverage instrument did not attribute the hits. This is the same class of attribution variance recorded as #903 PA-2.
  - Policy evaluation: the governing thresholds are met. Repo-wide 90.41% >= 85%; each changed file 99.40% >= 85%; changed lines 3/3 covered, no changed-line regression. `.claude/rules/general-unit-test.md` scopes the no-regression rule to "the lines that were changed". The plan's P3-T12 condition ("no post-change value is below its baseline", applied to the report row) is stricter than policy, and the shortfall it detects is outside this branch's diff.
  - Classification: **Non-blocking** for this item. If it were treated as blocking, it would not be autonomously remediable inside this item: the cause lies in an unchanged module and the coverage instrument, and a CI rerun would only re-sample the variance.
  - Recommended disposition: the orchestrator records P3-T12 as an accepted deviation, citing this audit. The attribution variance on `WorktreeTargetResolution.psm1` is unrelated to the #937 change surface. Raise it as a separate follow-up issue, or attach it to an existing #903 PA-2 attribution follow-up if one is open.
- **PA-2 (Non-blocking): AC-15 pending PR CI** at S9 (CI-dependent by design).
- **PA-3 (Non-blocking): branch behind `origin/main` by 23 commits** with no in-scope overlap and no merge conflict. Rebase before opening the PR.

### Approved Exceptions

- None required. The pre-existing uncovered line 171 in each targets copy is unchanged by this branch.

### Removed/Skipped Tests

- No test was removed or skipped. The 10 disabled Windows testcases are pre-existing platform skips; the Linux job reports 0 skipped.

---

## 9. Summary of Changes

1. **e137102c1 / f7191869f / f8fa81273 / 2312a56b7 / f7f35287a / c7f4ce8c6** - feature folder, research, spec, plan, and plan revisions
2. **2fe046995 / 1a2b7ed66** - Phase 0 and CI baseline evidence
3. **01fdeaf6a** - test: path-not-local regression rows (expect-fail)
4. **62f42c659** - fail-before evidence
5. **553433761** - fix: deny non-local path-leg spellings as path-not-local (four copies)
6. **fd138e1ca / d8ad225b2** - final QA, CI pass-after, and coverage evidence

---

## 10. Compliance Verdict

### Overall Status: NON-COMPLIANT (remediation required)

All toolchain stages pass locally and in CI. File-size, line-length, mirror-parity, scope, and evidence-location checks pass. Every changed production file is at or above 85% line coverage, and no changed line regressed. One blocking coverage finding remains: the canonical PowerShell coverage artifact reads 66.04% repo-wide (PA-0). It is autonomously remediable by regenerating that artifact from a full-suite run. Remaining items are Non-blocking.

**Total blocking findings: 1.**

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS: Before Making Changes (plan deviation PA-1 Non-blocking) / Design / Structure / Naming / Toolchain / Documentation

#### Language-Specific Code Change Policy (Section 3)
- PASS: PowerShell format, analyze, and test

#### General Unit Test Policy (Section 1)
- PASS: Core Principles
- FAIL: Coverage & Scenarios (PA-0 canonical PowerShell coverage artifact 66.04%; PA-1 Non-blocking)
- PASS: Test Structure / External Dependencies

#### Language-Specific Unit Test Policy (Section 4)
- PASS: PowerShell

---

### Metrics Summary

- PASS: Pester 10412 non-disabled passing (Windows), 6335/6335 (Linux)
- PASS: Push-down contract tests 23 passed
- FAIL: PowerShell canonical coverage artifact 66.04% lines repo-wide (scoped run); full-suite CI 90.41%; targets copies 99.40%
- PASS: PowerShell changed lines 3/3 covered per measured copy; 0 regressed

---

### Recommendation

**Not ready for PR: remediation required (PA-0, `autonomous`).** Regenerate `artifacts/pester/powershell-coverage.xml` from a full-suite PoshQC test run and record it as evidence, then re-review. After that: rebase on `origin/main`, record the P3-T12 deviation disposition (PA-1), open the PR, and check off AC-15 at S9 against the PR head. Remediation inputs: `remediation-inputs.2026-10-16T03-39.md`.

---

## Appendix A: Test Inventory

1. preimplementation gate targets (`<Surface>`) > U27 gives path-not-local for `<Label>` (15 labels x 2 surfaces)
2. preimplementation gate targets (`<Surface>`) > U28 keeps a bare drive root path-leg input as its own target (2 labels x 2 surfaces)
3. preimplementation gate targets (`<Surface>`) > U29 denies a non-local path-leg input even when a sibling path is valid (x 2)
4. preimplementation gate targets (`<Surface>`) > U30 reports path-not-local before path-dot-segment for a UNC dot-dot path (x 2)
5. preimplementation gate targets (`<Surface>`) > U31 gives path-not-local for a non-local apply_patch marker path (x 2)
6. Claude EpicScopeTargets: three Write deny rows (UNC, extended-length, drive-relative) `(issue #937)`
7. Codex epic-scope-targets: three `apply_patch` deny rows (UNC, extended-length, drive-relative) `(issue #937)`

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands:**
```bash
git -C <worktree> log --oneline origin/main..HEAD
git -C <worktree> diff --stat origin/main...HEAD
git -C <worktree> diff origin/main...HEAD -- .claude .codex extensions tests
git -C <worktree> diff --name-only origin/main...HEAD -- artifacts/
git -C <worktree> rev-list --count adb9aa5f0..origin/main
git -C <worktree> merge-tree --write-tree origin/main HEAD
PYTHONPATH=<worktree> poetry -C <worktree> run python -m scripts.dev_tools.pr_context.collector --base origin/main --repo-root <worktree>
poetry -C <worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
gh run download 38844097853 -R drmoisan/drm-copilot -n poshqc-test-results -D <scratchpad>/dl-final
gh run download 38833589314 -R drmoisan/drm-copilot -n poshqc-test-results -D <scratchpad>/dl-base
poetry run python -I <scratchpad>/cov.py <dl-base>/powershell-coverage.xml <dl-final>/powershell-coverage.xml
gh run view 38844097853 -R drmoisan/drm-copilot --log | grep "PSScriptAnalyzer passed"
wc -l <targets copy> <three test files>
```

**For PowerShell:**
```powershell
# Through the PoshQC MCP tools (executor): run_poshqc_format, run_poshqc_analyze, run_poshqc_test
# CI: ci.yml poshqc jobs (baseline 38833589314, fail-before 38838282195, final 38844097853)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)
