# Policy Compliance Audit: Issue #824 Addendum 2 (issue #823 tier-rule adoption follow-ups)

**Audit Date:** 2026-10-10
**Branch:** `bug/issue-823-tier-rule-adoption-follow-ups-824` @ `1d5b66015`
**Base:** `origin/main` @ `816b5513a` (merge base `816b5513a7e64b574a514ee320ccaef28fc7a597`)
**Feature folder:** `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824` (referred to below as FEATURE)
**Work mode:** `full-bug` (AC source: `spec.md`)
**Template source:** canonical bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` read directly from the worktree because the MCP template resolver tool is not available in this reviewer session.

**Code Under Test:**

- PowerShell production: `.claude/hooks/feature-review-coverage-thresholds.ps1` (new), `.claude/hooks/validate-feature-review-coverage.ps1` (modified), plus byte-identical bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
- PowerShell tests: `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` (new), `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` (new).
- Python tests: `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (new), `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` (modified).
- Bash: `.codex/codex-web-setup.sh` (modified) and its bundle mirror; `tests/shell/test_codex_web_setup_codex_copy.bats` (new); fixture `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt` (new).
- JSON: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one entry added).
- Markdown policy, agent, and skill surfaces (repository copies and bundle mirrors): `.claude/rules/{architecture-boundaries,general-unit-test,quality-tiers}.md`, `.github/instructions/csharp-{code-change,unit-test}.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.claude/agents/feature-review.md`, `.claude/skills/{feature-review-workflow,quota-throttling}/SKILL.md`, `.agents/skills/{architecture-boundaries,csharp,csharp-qa-gate,general-unit-test,quality-tiers}/SKILL.md`, the two `.agents-variants/csharp-legacy/**` bundle files.
- Feature records: `issue.md`, `spec.md`, `plan.2026-10-08T22-16.md`, `research/...`, and 116 evidence files under FEATURE `evidence/` (merge-base range).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files (test-only) | 151 targeted tests; 6776 full suite | PASS 6776 pass, 0 fail | 93.68% lines, 87.1% branches | 93.68% lines, 87.1% branches | no production Python line changed; repo 93.68% |
| PowerShell | 4 files (2 production, 2 test) plus 2 mirrors | 28 new cases; 6780 total | PASS 6780 pass, 0 fail | 88.0% lines repo; hook file 49.52% | 88.63% lines repo; hook file 95.28% | helper 100.0%; hook 95.28%; changed lines 7 of 7 executable covered (100%) |
| TypeScript | 0 files | Jest twin 16 tests | PASS 16 pass, 0 fail | 97.23% lines, 92.01% branches | 97.23% lines, 92.01% branches | no TypeScript file changed; repo 97.23% |
| Bash | 2 files (script and mirror) plus 1 bats file | 15 bats cases | pending CI | N/A (no kcov measurement of `.codex/`) | N/A (no kcov measurement of `.codex/`) | N/A (no kcov measurement) - coverage verdict FAIL |
| JSON | 1 file | none | PASS manifest completeness suites | N/A (config file) | N/A (config file) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `FEATURE/evidence/baseline/jest-coverage.2026-10-09T23-11.md`
- TypeScript post-change coverage artifact: `FEATURE/evidence/qa-gates/jest-coverage.2026-10-10T00-23.md`
- PowerShell baseline coverage artifact: `FEATURE/evidence/baseline/powershell-coverage-values.2026-10-09T23-09.md` (poshqc-test-results of main CI run 38017407907, head `816b5513a`, conclusion success)
- PowerShell post-change coverage artifact: `FEATURE/evidence/qa-gates/powershell-coverage-values.2026-10-10T00-22.md` and `artifacts/orchestration/ci-final-poshqc/powershell-coverage.xml` (branch CI run 38022356096, head `f03407757`, conclusion success)
- Per-language comparison summary: Section 1.2.1 below and `FEATURE/evidence/qa-gates/coverage-comparison.2026-10-10T00-26.md`

---

## Executive Summary

The branch delivers issue #824 Addendum 2: FU-823-1 (governing coverage thresholds in the feature-review hook through a new pure resolver), FU-823-2 (neutral product naming), FU-823-3 (`<solution>.sln` placeholder and runtime solution discovery), FU-823-5 (step 8 trigger wording), review note A (per-metric fallback sentence), and review note B (coverage-context scan in the #823 test). All 17 repository/bundle mirror pairs were verified byte-identical by this reviewer.

Reviewer-run checks (check-only): Black, Ruff, and Pyright on both changed Python files (clean); 151 tests across the two issue tests and the four parity/manifest suites (all pass); evidence-location validator (exit 0); mirror byte-parity script (17 of 17 identical); hard-exclusion scan of the branch diff (no match); recomputation of the CI PowerShell coverage report (repo 88.63%, helper 100.0%, hook 95.28%, 179 source files) and of the local Python LCOV (93.68% line, 87.10% branch).

Blocking findings: **1**. Bash coverage verdict is FAIL: the changed script `.codex/codex-web-setup.sh` (and its mirror) is outside the kcov include roots, so no coverage artifact exists for the changed bash lines. This is a pre-existing measurement gap documented in the spec, and the remedy (extending shell-coverage roots) is excluded from this item's scope, so it is classified `human_decision_required`. Python coverage verdict: PASS. PowerShell coverage verdict: PASS.

Pending items that are not findings (operator constraint OPS-1, recorded as PENDING-CI in evidence): `sh -n` syntax checks and the bats suite `tests/shell/test_codex_web_setup_codex_copy.bats` on the PR head; AC-6 and AC-13 depend on that CI; AC-15 depends on PR authoring.

**Policy documents evaluated:**

- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**

- PASS Python: `.claude/rules/python.md` (test files only)
- PASS PowerShell: `.claude/rules/powershell.md`
- FAIL Bash: `.claude/rules/shell.md` (coverage measurement absent for the changed script; shfmt/shellcheck not applied because `.codex/` is outside shell-qc discovery; bats pending CI)
- PASS JSON: pack manifest consumed by the manifest completeness suites (Python and Jest twin)

**Temporary artifacts cleanup:**

- PASS No temporary script is committed. Reviewer helper scripts were written to the session scratchpad outside the repository.
- PASS No new tooling script was added to the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Pester cases mock `Get-ArtifactFileContent` per case; Python tests read committed files only; bats cases re-source the script in `setup()` and set globals per case. No shared mutable state. |
| **Isolation** | PASS | Resolver rows target `Get-FeatureReviewCoverageThreshold` only; hook cases F824-1..3 target the threshold path; Python tests are one assertion family per test. |
| **Fast Execution** | PASS | 151 Python tests ran in 0.63 s (reviewer run). Pester total suite reported 6780 cases with 0 failures. |
| **Determinism** | PASS | No clock, randomness, network, or temporary file. F824-9 reads its own test file and probes an absent path (read-only). bats stubs `nuget`/`pwsh` as shell functions. |
| **Readability & Maintainability** | PASS | Case IDs (T824-n, F824-n, C824-n), AAA comments, `-Because` messages. Repeated mock switch blocks are noted as a non-blocking maintainability item in the code review. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | PowerShell 88.0% repo line (CI run 38017407907); Python 93.68% line / 87.1% branch; TypeScript 97.23% / 92.01%. Evidence under `FEATURE/evidence/baseline/`. |
| **No Coverage Regression** | PASS (PowerShell, Python, TypeScript); FAIL (Bash, not measurable) | PowerShell +0.63; Python 0.00; TypeScript 0.00. Hook changed lines: CHANGED_LINES 20, EXECUTABLE_CHANGED 7, UNCOVERED_CHANGED NONE. Bash changed lines have no measurement at baseline or post-change. |
| **New/Modified Code Coverage >= 85% line** | PASS (PowerShell); FAIL (Bash) | Helper 100.0%, hook 95.28% (recomputed by reviewer from `artifacts/orchestration/ci-final-poshqc/powershell-coverage.xml`). `.codex/codex-web-setup.sh` has no kcov figure. |
| **Comprehensive Coverage** | PASS | Resolver: 11 rows (absent, no figures, both lower, line-only, branch-only, decimal, >100, prose without comparator, combined limitation, minimum phrase, two statements on one line). Hook: F824-1..3 plus parsing and artifact-validation paths. |
| **Positive Flows** | PASS | T824-3..6, T824-10, T824-11; F824-1; C824-4, C824-5, C824-9, C824-13. |
| **Negative Flows** | PASS | T824-7 (out of range), T824-8 (prose), T824-9 (combined); F824-2, F824-3; F824-V1..V8; C824-12, C824-14. |
| **Edge Cases** | PASS | Decimal figure, figure above 100, combined phrase, C-order selection among several solutions (C824-6), populated packages fixture (C824-10). |
| **Error Handling** | PASS | Hook payload errors (F824-V1..V3), no-solution restore warning (C824-8), no-solution verify failure (C824-12), nuget unavailable (C824-11). |
| **Concurrency** | PASS | Not relevant: pure string resolver and single-threaded hook. |
| **State Transitions** | PASS | Not relevant: no stateful component added. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.68% lines, 87.1% branches -> Post-change: 93.68% lines, 87.1% branches. Change: +0.00% lines, +0.00% branches. New/changed-code coverage: no production Python line changed (repo-wide 93.68%). Disposition: PASS. Evidence: `FEATURE/evidence/baseline/python-coverage-values.2026-10-09T22-55.md`; `FEATURE/evidence/qa-gates/python-coverage-values.2026-10-10T00-15.md`; `artifacts/python/lcov.info` recomputed by reviewer (93.68% line, 87.10% branch).
- PowerShell: Baseline: 88.0% lines repo-wide (hook file 49.52%) -> Post-change: 88.63% lines repo-wide (hook file 95.28%). Change: +0.63% lines repo-wide. New/changed-code coverage: helper 100.0%, hook 95.28%, 7 of 7 executable changed lines covered (100%). Disposition: PASS. Evidence: `FEATURE/evidence/baseline/powershell-coverage-values.2026-10-09T23-09.md`; `FEATURE/evidence/qa-gates/powershell-coverage-values.2026-10-10T00-22.md`; `artifacts/orchestration/ci-final-poshqc/powershell-coverage.xml` recomputed by reviewer.
- TypeScript: Baseline: 97.23% lines, 92.01% branches -> Post-change: 97.23% lines, 92.01% branches. Change: +0.00%. New/changed-code coverage: no TypeScript file changed (repo-wide 97.23%). Disposition: PASS. Evidence: `FEATURE/evidence/baseline/jest-coverage.2026-10-09T23-11.md`; `FEATURE/evidence/qa-gates/jest-coverage.2026-10-10T00-23.md`.
- Bash: Baseline: no kcov figure exists for `.codex/` -> Post-change: no kcov figure exists for `.codex/`. Change: not measurable. New/changed-code coverage: not measurable; the 15 bats cases exercise every new function and both branches of each new guard by inspection. Disposition: FAIL. Evidence: `.claude/rules/shell.md` (kcov include roots are `tools/`, `scripts/`, `.claude/lib/bash/`, `.claude/skills/`); `FEATURE/evidence/qa-gates/coverage-comparison.2026-10-10T00-26.md` (records the Bash row as not measured); spec Risks and Rollout sections.

Repo-wide per-language verdicts: Python coverage PASS (93.68% line >= 85, 87.1% branch >= 75). PowerShell coverage PASS (88.63% line >= 85; Pester measures no branch figure, so no branch gate applies). Bash coverage FAIL (artifact absent for the changed script). TypeScript has zero changed files; its figures are reported for completeness.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Pester `-Because` text; Python f-string assertion messages naming the offending path; bats assertions on exact message fragments. |
| **Arrange-Act-Assert Pattern** | PASS | Explicit `# Arrange`, `# Act`, `# Assert` comments in all new Pester, Python, and bats cases. |
| **Document Intent** | PASS | File-level docstrings state purpose and determinism; each test has a descriptive name and docstring. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or process dependency. The bats suite replaces `nuget` and `pwsh` with shell functions. |
| **Use Mocks/Stubs** | PASS | `Get-ArtifactFileContent` mocked in Pester; `nuget`/`pwsh` stubbed in bats; PATH narrowed in C824-11. |
| **Environment Stability** | PASS | No temporary files created. The bats suite uses the committed fixture `tests/fixtures/codex_web_setup/populated-packages`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the policy review for the branch. One blocking item is open (Section 8). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `spec.md` (issue #824 Addendum 2) with RCA and AC-1..AC-15. |
| **Read existing change plans** | PASS | `FEATURE/evidence/baseline/phase0-instructions-read.md`; research document under `FEATURE/research/`. |
| **Document the plan** | PASS | `plan.2026-10-08T22-16.md`, 126 of 126 tasks checked; OPS-3 revision recorded in `FEATURE/evidence/other/plan-revision-ops3.2026-10-10T00-09.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Resolver is a single 77-line pure function; hook changes are parameter threading and reason-string interpolation. |
| **Reusability** | PASS | Hook reuses the existing `Get-ArtifactFileContent` seam for `CLAUDE.md`. |
| **Extensibility** | PASS | `Test-LanguageCoverageRow` gains `-LineFloor`/`-BranchFloor` with defaults 85.0/75.0, preserving existing callers. |
| **Separation of concerns** | PASS | Pure parsing (resolver) is separated from file I/O (hook). Bash discovery logic is split into argument-driven functions. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | New helper is single-purpose and dot-sourced. |
| **Under 500 lines** | PASS | Reviewer `wc -l`: hook 471, helper 77, Issue824 Pester 274, resolver Pester 51, follow-ups pytest 356, tier-gate pytest 493, bats 187, setup script 413. |
| **Public vs internal** | PASS | One new public function `Get-FeatureReviewCoverageThreshold`; new bash functions are file-local. |
| **No circular dependencies** | PASS | Hook dot-sources helper; helper has no dependency. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Get-FeatureReviewCoverageThreshold`, `list_root_solution_files`, `select_solution_file`, `resolve_repo_root`, `coverage_threshold_context`. |
| **Docs/docstrings** | PASS | Comment-based help on the helper, including the combined-phrase limitation; hook docstring corrected (no 80 percent figure); bash functions carry argument comments. |
| **Comment why, not what** | PASS | Setup script comment explains the `/tmp` copy behavior motivating the fallback. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Black `--check` clean (reviewer); PoshQC format listings unchanged (`FEATURE/evidence/qa-gates/poshqc-format.2026-10-10T00-12.md`); Prettier clean. |
| **2. Linting** | PASS | Ruff clean (reviewer); PoshQC analyze ok (MCP) and CI `PoshQC (reusable)` run 38022356096 success; ESLint clean. |
| **3. Type checking** | PASS | Pyright 0 errors on changed Python files (reviewer); TSC clean. |
| **4. Testing** | PASS | Pytest 6776 pass; Pester 6780 pass, 0 failures; Jest twin 16 pass. bats pending CI (OPS-1). |
| **Full toolchain loop** | PASS | `FEATURE/evidence/qa-gates/qc-loop-complete.2026-10-10T00-24.md`: clean on iteration 1, two items pending CI. |
| **Explicit reporting** | PASS | Commands and exit codes recorded per evidence file; Appendix B lists reviewer commands. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages per phase; Section 9. |
| **Design choices explained** | PASS | Spec design summary; comparator requirement and combined-phrase limitation documented in the helper. |
| **Update supporting documents** | PASS | `issue.md` status marks (FU-823-1/2/3/5 resolved, FU-823-4 open). |
| **Provide next steps** | PASS | `FEATURE/evidence/other/pr-body-callouts.2026-10-09T23-55.md`; this note does not yet list the OPS-3 `parallel-orchestration.md` follow-up (non-blocking PA-2). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

Only test files changed; production Python is unchanged.

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check <2 files>`: "2 files would be left unchanged." |
| **Linting with Ruff** | PASS | `poetry run ruff check <2 files>`: "All checks passed!" |
| **Type checking with Pyright** | PASS | `poetry run pyright <2 files>`: "0 errors, 0 warnings, 0 informations". |
| **Testing with Pytest** | PASS | 151 passed in the six targeted modules (reviewer); 6776 passed in the full run (evidence). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | All helpers annotated; `frozenset[str]` and `tuple[tuple[str, str], ...]` constants; no `Any`. |
| **Dataclasses for value objects** | PASS | No value object introduced. |
| **Protocols/ABCs for interfaces** | PASS | No interface introduced. |
| **Avoid utility classes** | PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | No exception handling added; file reads fail loudly. |
| **Logging over print** | PASS | No print statements. |
| **Invariants at construction** | PASS | `EXPECTED_LISTED_COPY_COUNT` pins the listed-copy count. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | MCP `run_poshqc_format` over `.claude/hooks` and `tests/scripts/claude-hooks`; git status listings identical before and after. |
| **Linting with PSScriptAnalyzer** | PASS | MCP `run_poshqc_analyze` ok=true; the MCP result carries no finding text, so the CI `PoshQC (reusable)` run 38022356096 (success) is the corroborating evidence. |
| **Fix all findings** | PASS | No finding reported by CI. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Helper uses only 5.1-compatible constructs (`[ordered]`, `[pscustomobject]`, `[regex]::Matches`, `[double]::TryParse`). Test files declare `#Requires -Version 7.0`, consistent with the existing hook suites. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]` and `[OutputType([pscustomobject])]` on the helper. |
| **Parameter validation** | PASS | `[Parameter(Mandatory)][AllowNull()][AllowEmptyString()][string]`. |
| **Avoid global state** | PASS | No global or script-scope writes in production code. |
| **Error handling** | PASS | Out-of-range and non-numeric figures ignored per metric; missing `CLAUDE.md` gives defaults. An unreadable `CLAUDE.md` raises (fail closed) rather than applying defaults; noted as non-blocking CR-4 in the code review. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | Hook 471, helper 77. |
| **Approved verbs** | PASS | `Get-` (approved), singular noun. |
| **Comment why** | PASS | Helper help text explains comparator requirement and the stricter-direction fallback. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | See 3B.1. |
| **Step 2: Analyze** | PASS | See 3B.1. |
| **Step 3: Type check** | PASS | No type-check stage exists for PowerShell under `.claude/rules/powershell.md`. |
| **Step 4: Test** | PASS | Pester 6780 cases, 0 failures, 0 errors (`FEATURE/evidence/qa-gates/poshqc-test.2026-10-10T00-22.md`). |
| **Rerun loop if needed** | PASS | Single clean iteration. |

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | FAIL (pre-existing, non-blocking) | `.codex/` is outside shell-qc discovery roots, so shfmt does not run on the script; the script uses 2-space indentation rather than shfmt tabs. Recorded as a spec follow-up. |
| **Linting with shellcheck** | FAIL (pre-existing, non-blocking) | Same discovery gap; shellcheck does not run on `.codex/codex-web-setup.sh`. |
| **Testing with bats** | PENDING-CI | `tests/shell/test_codex_web_setup_codex_copy.bats` (15 cases) runs under `.github/workflows/_shell-coverage.yml` on the PR head (OPS-1). The suite sources the script, so a syntax error would fail it. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | PASS | `#!/usr/bin/env bash`. |
| **Error handling** | PASS | `set -euo pipefail` retained; restore warns and skips without a solution; MSBuild verification fails with an explicit message without a solution. |
| **Under 500 lines** | PASS | 413 lines. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON / deterministic order** | PASS | One alphabetically placed entry `.claude/hooks/feature-review-coverage-thresholds.ps1` in the Claude core manifest; Python and Jest manifest completeness suites pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `pytest.mark.parametrize` over listed copies. |
| **Coverage expectation** | PASS | No production Python changed; repo-wide 93.68% line, 87.1% branch. |
| **Focused unit tests** | PASS | One behavior per test; synthetic helper tests prove the checks can fail (`test_consuming_product_detection_flags_a_reintroduced_name`, `test_retired_threshold_scan_reads_coverage_context_only`). |
| **Mocking sparingly** | PASS | No mocks; committed-file reads only. |
| **Organization** | PASS | Files under `tests/scripts/dev_tools/`, consistent with existing push-down contract suites. |
| **Naming conventions** | PASS | `test_<subject>_<expectation>`. |
| **No Alternative Test Runners** | PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `BeforeAll`, `Describe/Context/It`, `-ForEach` data rows, `Should -Be`/`-Match`. |
| **Use PoshQC Configuration** | PASS | Full suite run through the PoshQC MCP runner and CI `_poshqc.yml`. |
| **Focused Unit Tests** | PASS | 11 resolver rows, 17 hook cases. |
| **Mocking Used Sparingly** | PASS | Only the file-read seam `Get-ArtifactFileContent` is mocked. |
| **Organization** | PASS | `tests/scripts/claude-hooks/` mirrors `.claude/hooks/` per the existing hook-test layout. |
| **File Naming** | PASS | `*.Tests.ps1`. |
| **No Alternative Test Runners** | PASS | Pester only. |

---

## 5. Test Coverage Detail

### Get-FeatureReviewCoverageThreshold (11 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| T824-1 no root CLAUDE.md text | Edge Case | 48-56, 68-76 | PASS |
| T824-2 text without figures | Negative | 48-58, 68-76 | PASS |
| T824-3 lower line and branch figures | Positive | 48-76 | PASS |
| T824-4 line-only figure | Positive | 48-76 | PASS |
| T824-5 branch-only figure | Positive | 48-76 | PASS |
| T824-6 decimal figure | Edge Case | 48-76 | PASS |
| T824-7 figure above 100 | Negative | 57-66 | PASS |
| T824-8 prose figure without comparator | Negative | 57-58 | PASS |
| T824-9 combined line-and-branch limitation | Edge Case | 57-58 | PASS |
| T824-10 minimum phrase | Positive | 57-66 | PASS |
| T824-11 two statements on one line | Positive | 57-66 | PASS |

**Coverage:** 100.0% of the helper (CI run 38022356096).

### validate-feature-review-coverage.ps1 threshold path (F824-1..3) and support paths (F824-4..9, F824-V1..V8)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| F824-1 lower stated thresholds allow | Positive | threshold resolution and `Test-LanguageCoverageRow` floors | PASS |
| F824-2 defaults apply without figures | Negative | 85% line floor reason string | PASS |
| F824-3 line-only figure keeps branch default | Negative | 75% branch floor reason string | PASS |
| F824-4..F824-8 parsing and row checks | Error Handling | JaCoCo/LCOV parsers, narrowing, mention checks | PASS |
| F824-9 file read seam | Positive | `Get-ArtifactFileContent` | PASS |
| F824-V1..V8 payload and artifact validation | Error Handling | payload parse and artifact location branches | PASS |

**Coverage:** hook file 95.28%; changed lines 7 of 7 executable covered.

### .codex/codex-web-setup.sh changed functions (15 bats tests, pending CI)

Cases C824-1..C824-15 exercise the source guard, `resolve_repo_root` (both branches), `select_solution_file` (empty, single, several), `list_root_solution_files` (empty directory only), the restore guard, nuget-unavailable path, populated-packages skip, the verify guard (both branches and tooling failure), and the notes placeholder. No kcov figure exists for this file.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (Pester) | 6780 | PASS |
| Total Tests (Pytest full) | 6776 | PASS |
| Tests Failed | 0 (Pester), 0 (Pytest), 0 (Jest twin) | PASS |
| Targeted Python execution time | 0.63 s for 151 tests (reviewer) | PASS |
| bats suite | 15 cases | PENDING-CI |
| Repo line coverage | Python 93.68%, PowerShell 88.63%, TypeScript 97.23% | PASS |

---

## 7. Code Quality Checks

**Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check <2 changed files>` | 2 unchanged | PASS |
| Ruff | `poetry run ruff check <2 changed files>` | All checks passed | PASS |
| Pyright | `poetry run pyright <2 changed files>` | 0 errors | PASS |
| Pytest | `poetry run pytest -q --no-cov <6 modules>` | 151 passed | PASS |

**PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | MCP `run_poshqc_format` | listings unchanged | PASS |
| PSScriptAnalyzer | MCP `run_poshqc_analyze`; CI run 38022356096 | ok; CI success | PASS |
| Pester Tests | MCP `run_poshqc_test`; JUnit read | 6780 tests, 0 failures | PASS |

**Notes:** Bash format, lint, and coverage stages do not reach `.codex/` (pre-existing). bats and shell syntax are PENDING-CI per OPS-1.

---

## 8. Gaps and Exceptions

### Identified Gaps

| ID | Classification | Finding | Remediability |
|----|----------------|---------|---------------|
| PA-1 | **Blocking** | Bash coverage verdict FAIL. `.codex/codex-web-setup.sh` and its bundle mirror changed (new functions `resolve_repo_root`, `select_solution_file`, `list_root_solution_files`, guards in two functions), but `.codex/` is outside the kcov include roots defined in `.claude/rules/shell.md`, so no coverage artifact exists for the changed lines. `.claude/rules/general-unit-test.md` applies the 85% line threshold to bash (kcov) and requires every production file to be in the coverage denominator; the review contract requires an explicit PASS or FAIL for every language with changed files and treats an absent artifact as FAIL. The gap predates this branch and is recorded in spec Risks and Rollout. | `human_decision_required`: the remedy (extending shell-qc/kcov roots to `.codex/`) falls under the spec's hard exclusion of shell-coverage work. Options: a recorded maintainer waiver for this item, or a scheduled follow-up that brings `.codex/` under shell-qc discovery and kcov. |
| PA-2 | Non-blocking | `FEATURE/evidence/other/pr-body-callouts.2026-10-09T23-55.md` predates OPS-3 and does not list `.claude/rules/parallel-orchestration.md` (and its Claude bundle copy) as an out-of-scope `TaskMaster` occurrence held in the AC-5 exception set. | `autonomous`: add the item to the PR body during PR authoring (AC-15). |
| PA-3 | Non-blocking | The policy template's Bash row convention ("N/A (no coverage)") conflicts with `.claude/rules/general-unit-test.md`, which applies the bash (kcov) line threshold. | Maintainer awareness; no change in this item (policy files are not edited by review). |
| PA-4 | Non-blocking | PowerShell analyze evidence from the MCP runner carries no finding text; the CI `PoshQC (reusable)` success at `f03407757` is the substantive evidence. No PowerShell path changed after `f03407757` (reviewer `git diff --name-only f03407757 HEAD`: only the follow-ups pytest module and feature docs). | None required. |
| PA-5 | Non-blocking | shfmt and shellcheck do not run on `.codex/codex-web-setup.sh` because `.codex/` is outside shell-qc discovery; the script keeps 2-space indentation rather than shfmt tabs. Pre-existing; listed in the spec Rollout follow-ups. | Same follow-up as PA-1; no change in this item. |

Pending (not findings): `sh -n` on both script copies and the bats suite on the PR head (OPS-1); AC-6, AC-13, AC-15.

### Approved Exceptions

- Policy-file edits authorized for this item: `.claude/rules/architecture-boundaries.md`, `.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md` (issue #824 Addendum 2, plan PD1); `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` plus bundle copies (operator approval for this run). The branch diff edits no other file under `.claude/rules/` or `.github/instructions/`. Verified with `git diff --name-only 816b5513a..HEAD`.
- OPS-2: PowerShell coverage from CI artifacts. Reviewer confirmed runs 38017407907 (main, `816b5513a`, CI, success) and 38022356096 (branch, `f03407757`, PoshQC reusable, success) with `gh run view` and recomputed the branch figures from the downloaded report.
- OPS-3: `PRE_EXISTING_NAME_EXCEPTIONS` includes `.claude/rules/parallel-orchestration.md` and its Claude bundle copy. Reviewer confirmed line 411 (`src/TaskMaster.Domain`) was introduced by `b94dbc303` (#797) on main, is present at the merge base, and is not modified by this branch. This matches AC-5's "pre-existing out-of-scope occurrences held in an explicit exception set guarded against staleness"; the staleness guard `test_name_exceptions_still_name_a_consuming_product` covers both new entries. Assessed as consistent with AC-5. The exception granularity is per file (see code review CR-5).

### Removed/Skipped Tests

**None.** All planned tests are implemented.

---

## Rejected Scope Narrowing

- Caller text: "review the change set `git diff b50df12b6467789d67118c994a5fd56a2fc8db81..HEAD` (equivalently the merge-base diff against origin/main)".
- Justification: the two ranges are not equivalent. The merge base with `origin/main` is `816b5513a`, and `b50df12b6` is a merge commit on the branch. The full merge-base diff (`816b5513a..HEAD`) was audited. It adds only feature-folder documents relative to the caller's range (`research/2026-10-09T02-25-...-research.md` and the initial content of `issue.md`, `spec.md`, `plan.2026-10-08T22-16.md` from `d7055fa37`); the production, test, and mirror file set is identical.
- The caller's description of shell syntax and bats as PENDING-CI was accepted as a pending state, not as a coverage exemption. Bash coverage is evaluated explicitly (PA-1).

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0.
- Branch-diff scan for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: no file. All 116 evidence files in the merge-base range are under `FEATURE/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Git-ignored working files under `artifacts/orchestration/` (CI report download, hunk diffs) are not committed and are not evidence paths.
- Result: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event.

---

## 9. Summary of Changes

### Commits in This Branch (merge base `816b5513a`)

1. `d7055fa37` docs(824): prepare addendum 2 feature folder, research, spec, and plan
2. `86578820f` docs(824): record Phase 0 policy reads and baseline evidence
3. `004c42a27` test(824): add regression tests for issue 823 follow-ups
4. `b2270c353` docs(824): record Phase 2 expect-fail evidence
5. `97acfe8b7` fix(824): apply governing coverage thresholds in feature-review hook
6. `a2b53782a` docs(824): neutralize consuming-product names in pushed architecture files
7. `1efb7ee01` fix(824): replace hard-coded TaskMaster.sln with a solution placeholder
8. `6776c760e` docs(824): state per-metric threshold fallback and governing review trigger
9. `f03407757` docs(824): mark follow-up statuses and record PR-body callouts
10. `cdc7f01ce` test(824): record pass-after verification and hold #797 occurrence as exception
11. `2eb6398dd` docs(824): record final QA loop evidence
12. `7e55acb3f` docs(824): record coverage comparison and scope verification
13. `1d5b66015` docs(824): check off verified acceptance criteria
14. `b50df12b6` merge of `origin/main` into the branch

### Files Modified

1. `.claude/hooks/feature-review-coverage-thresholds.ps1` (NEW) - pure resolver for governing line/branch thresholds.
2. `.claude/hooks/validate-feature-review-coverage.ps1` (MODIFIED) - dot-sources resolver, reads root `CLAUDE.md`, passes floors, interpolates figures, corrected docstring.
3. `.codex/codex-web-setup.sh` (MODIFIED) - runtime root `*.sln` discovery, restore and verify guards, `<solution>.sln` notes, `BASH_SOURCE` guard.
4. Policy, agent, and skill Markdown surfaces listed under Code Under Test (MODIFIED) - naming neutralization, `<solution>.sln`, fallback sentence, step 8 wording.
5. Bundle mirrors (MODIFIED/NEW) - byte copies; core manifest entry added.
6. Tests and fixture (NEW/MODIFIED) - two Pester files, two pytest modules, one bats suite, one fixture.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Total blocking findings in this artifact: **1** (PA-1, `human_decision_required`). Non-blocking findings: 4 (PA-2, PA-3, PA-4, PA-5).

Python coverage verdict: PASS. PowerShell coverage verdict: PASS. Bash coverage verdict: FAIL.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution (bats pending CI)
- PASS Summarize & Document (PA-2 open for PR body)

#### Language-Specific Code Change Policy (Section 3)

- PASS Python (test files)
- PASS PowerShell
- FAIL Bash (coverage measurement absent; shfmt/shellcheck not applied, pre-existing)

#### General Unit Test Policy (Section 1)

- PASS Core Principles
- PARTIAL Coverage & Scenarios (Bash not measured)
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

- PASS Python
- PASS PowerShell

### Metrics Summary

- PASS 6780/6780 Pester, 6776/6776 Pytest, 16/16 Jest twin
- PASS Repo line coverage: Python 93.68%, PowerShell 88.63%, TypeScript 97.23%
- PASS New/changed PowerShell: helper 100.0%, hook 95.28%, changed lines fully covered
- FAIL Bash changed script: no coverage figure
- PASS 17/17 bundle mirrors byte-identical

### Recommendation

**Blocked (HALT_NON_REMEDIABLE, human decision required)**

Next steps: (1) maintainer decides PA-1 (record a waiver for `.codex/codex-web-setup.sh` coverage in this item, or schedule shell-qc/kcov coverage of `.codex/`); (2) confirm the bats suite and shell syntax pass in CI on the PR head; (3) add the `parallel-orchestration.md` follow-up to the PR body (PA-2).

---

## Appendix A: Test Inventory

### Pester

1. feature-review-coverage-thresholds (issue #824) > T824-1 .. T824-11 (11 data rows)
2. validate-feature-review-coverage.ps1 (issue #824) > governing coverage thresholds (FU-823-1) > F824-1, F824-2, F824-3
3. validate-feature-review-coverage.ps1 (issue #824) > coverage parsing paths > F824-4 .. F824-9
4. validate-feature-review-coverage.ps1 (issue #824) > review artifact validation paths > F824-V1 .. F824-V8

### Pytest

- `test_push_down_issue_824_follow_ups.py`: `test_every_follow_up_copy_exists`, `test_listed_copy_names_no_consuming_product[6]`, `test_surface_does_not_hard_code_solution_file[14]`, `test_pushed_roots_carry_no_hard_coded_solution_file`, `test_review_workflow_step_eight_uses_governing_thresholds[2]`, `test_precedence_copy_states_per_metric_fallback[14]`, `test_consuming_product_detection_flags_a_reintroduced_name`, `test_step_eight_extraction_stops_at_step_nine`, `test_pushed_rule_and_skill_scan_covers_the_listed_copies`, `test_pushed_rule_and_skill_files_name_no_consuming_product`, `test_name_exceptions_still_name_a_consuming_product`
- `test_push_down_tier_rule_adoption_gate.py`: added `test_retired_threshold_scan_reads_coverage_context_only`; modified `test_review_agent_copy_uses_governing_thresholds`

### bats

- `tests/shell/test_codex_web_setup_codex_copy.bats`: C824-1 .. C824-15

---

## Appendix B: Toolchain Commands Reference

Commands run by this reviewer (worktree root):

```bash
git diff --name-status 816b5513a..HEAD
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main
poetry run black --check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py
poetry run ruff check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py
poetry run pyright tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py
poetry run pytest -q -p no:cacheprovider --no-cov tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
gh run view 38022356096 --repo drmoisan/drm-copilot --json headSha,conclusion,workflowName,headBranch
gh run view 38017407907 --repo drmoisan/drm-copilot --json headSha,conclusion,workflowName,headBranch
git log --oneline -S"TaskMaster.Domain" -- .claude/rules/parallel-orchestration.md
git diff --name-only f03407757 HEAD
```

Reviewer scratch scripts (session scratchpad, not committed): mirror byte-parity comparison of 17 pairs; LCOV and JaCoCo recomputation of `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, and `artifacts/orchestration/ci-final-poshqc/powershell-coverage.xml`.

Executor-recorded commands (PowerShell, via MCP under OPS-1): `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-10
**Policy Version:** Current (as of audit date)
