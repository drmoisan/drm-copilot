# Policy Compliance Audit: CI change-scope merge-base fallback for docs-only pull requests (Issue #973)

---

**Audit Date:** 2026-10-17
**Branch:** `bug/ci-docs-only-pr-runs-full-ci-973` @ `e1a6c90eaff39e5da86d46006a1b4459593f8c4f`
**Base:** `main` (merge base `18d6d1ccd455a280ca3b7a47ce4976f162e8803e`)
**Scope:** full branch diff `18d6d1ccd455a280ca3b7a47ce4976f162e8803e..e1a6c90eaff39e5da86d46006a1b4459593f8c4f` (47 files, +2258/-45)
**Code Under Test:** `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`, `.github/workflows/ci.yml`, `config/ci-docs-only-paths.json`; tests `tests/scripts/ci/CiChangeScope.Tests.ps1`, `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` (new), `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`; documentation `.github/workflows/README.md` and six byte-identical copies of the execution-environment brief.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 7 files (2 production, 5 test) | 238 tests in touched suites; 11281 in full run | ✅ 238 pass, 0 fail; full run 11271 pass, 0 fail, 10 skipped | 93.08% lines `CiChangeScope.psm1`; 88.64% lines `Invoke-CiChangeScope.ps1` | 93.57% lines `CiChangeScope.psm1`; 91.15% lines `Invoke-CiChangeScope.ps1`; repo-wide 92.24% lines | 100.00% changed executable lines (55/55) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

Non-coverage file types on the branch: `.github/workflows/ci.yml` (actionlint exit 0, 0 findings) and `config/ci-docs-only-paths.json` (parsed and pinned by exact-string tests). Neither file type has a coverage metric; both are exercised by the workflow and config test suites counted in the PowerShell row above.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/evidence/baseline/ps-tests.2026-10-17T13-08.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (inspected directly by this review) and `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/evidence/qa-gates/ps-tests.2026-10-17T13-39.md`
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/evidence/qa-gates/coverage-delta.2026-10-17T13-39.md`

---

## Rejected Scope Narrowing

None detected. The caller prompt specified the full branch diff against `main` at merge base `18d6d1ccd455a280ca3b7a47ce4976f162e8803e` and did not narrow scope to a plan, task, phase, or file subset.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths.
- `git diff --name-only 18d6d1cc..HEAD` lists no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All branch evidence is under `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Result: PASS. No FAIL-level evidence location finding.

## Tier Classification

`quality-tiers.yml` exists at the repository root. `scripts/ci` is classified `T4` ("CI change-scope decision script and its pure helper module (CI scaffolding)"). No new project was added. Result: PASS.

---

## Executive Summary

The branch adds a merge-base fallback to the issue #962 CI change-scope decision so that a new docs-only pull request into `main` can skip heavy jobs on its first run, and adds three include prefixes to the docs-only allowlist. The production delta is two PowerShell files (+171/-28), two workflow input lines, three JSON prefix values, and documentation. All new failure paths fail closed (`code=true`).

**Policy documents evaluated:**
- ✅ `CLAUDE.md` and `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `.claude/rules/powershell.md` (`powershell-code-change` and `powershell-unit-test` instructions)
- ✅ `github-actions.instructions.md` (one `ci.yml` env change)
- N/A Bash (no shell file changed)
- ✅ JSON: `config/ci-docs-only-paths.json` remains strict JSON, schema unchanged

Toolchain evidence (format, analyze, Pester with coverage, actionlint, Python contract tests for the brief copies, seeded shuffled isolation runs, fresh full `tests/scripts` run) is recorded under the feature evidence folder and is consistent with direct inspection by this review. Line coverage for both changed production files is above 85% and changed-line coverage is 100%. No blocking finding was identified.

**Temporary artifacts cleanup:**
- ✅ The helper scripts used during execution were kept in the session scratch directory (`SCRATCH/issue-973-*.sh|ps1|py`) and are not part of the branch diff.
- ✅ No new tooling script was added to the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Three seeded shuffled file-order runs (seeds 973, 9731, 97301) of the six touched suites passed (208/208 each); `evidence/regression-testing/isolation-shuffle-seed-*.md`. Scenario state is built per row by `Get-TestScenario`. |
| **Isolation** | ✅ PASS | One `It` per behavior group; `-ForEach` rows vary one input. The new suite isolates `Resolve-CiChangeScopeDecision` steps 5 to 8 through injected fakes. |
| **Fast Execution** | ✅ PASS | All rows run in-memory with fake invokers; no process, network, or file write. |
| **Determinism** | ✅ PASS | Fixed SHA literals (`'a' * 40` etc.), no clock, no randomness, no environment reads (`Get-CiChangeScopeContext` uses an injected reader). |
| **Readability & Maintainability** | ✅ PASS | Row names state the scenario and the expected reason and cite `(#973)`; assertions carry `-Because` text. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `CiChangeScope.psm1` 93.08% (121/130); `Invoke-CiChangeScope.ps1` 88.64% (78/88); recorded 2026-10-17T13-08 before changes (`evidence/baseline/ps-tests.2026-10-17T13-08.md`). |
| **No Coverage Regression** | ✅ PASS | Post-change 93.57% (131/140) and 91.15% (103/113), verified by this review in `artifacts/pester/powershell-coverage.xml` class counters. Change: +0.49 and +2.51 points. |
| **New/Changed Code Coverage >= 85%** | ✅ PASS | Changed executable lines: 10/10 in the module, 45/45 in the entry script (100.00%); `evidence/qa-gates/coverage-delta.2026-10-17T13-39.md`. |
| **Repo-wide Coverage >= 85%** | ✅ PASS | Report total LINE counter: 17645 covered, 1485 missed = 92.24%. |
| **Positive Flows** | ✅ PASS | M1 (docs-only merge-base skip), M4 (each new prefix with committed config), M6 (fallback from BASE_NOT_PRESENT and BASE_NOT_ANCESTOR), U2 (valid SHA forms). |
| **Negative Flows** | ✅ PASS | M2 (non-allowlisted path), M3 (rename both directions), M7 (non-main base refs), M8 (terminal RUN_LIST_FAILED, JOB_LIST_FAILED), U3 (eight invalid merge-base outputs). |
| **Edge Cases** | ✅ PASS | Case-sensitive `Main`, empty base ref, 64-character SHA, one versus two trailing LFs, leading and trailing spaces. |
| **Error Handling** | ✅ PASS | M5 covers seven `MERGE_BASE_UNRESOLVED` causes; M9 covers `DIFF_FAILED` and `EMPTY_DIFF` on the merge-base diff. |
| **Concurrency** | N/A | Single-threaded decision script. |
| **State Transitions** | ✅ PASS | Decision order steps 4 to 8 are exercised transition by transition (primary reason, applicability, resolution, diff). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.08% lines (`CiChangeScope.psm1`), 88.64% lines (`Invoke-CiChangeScope.ps1`) -> Post-change: 93.57% lines, 91.15% lines; repo-wide 92.24% lines. Change: +0.49 and +2.51 percentage points, no regression. New/changed-code coverage: 100.00% (55 of 55 changed executable lines). Disposition: PASS. Evidence: `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/evidence/qa-gates/coverage-delta.2026-10-17T13-39.md`, `artifacts/pester/powershell-coverage.xml`.

Branch coverage: no branch threshold applies to PowerShell (Pester does not measure branch coverage). TypeScript, Python, and C# have zero changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `Should -BeExactly` on full log lines plus `-Because` text naming the scenario. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Each row builds a scenario, invokes once (`$null = Invoke-TestScenario`), then asserts. |
| **Document Intent** | ✅ PASS | Header comment in the new suite states that no cmdlet is mocked and no file, process, environment, or network effect occurs. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | gh and git are replaced by closures passed as `-GhInvoker` and `-GitInvoker`. |
| **Use Mocks/Stubs** | ✅ PASS | Fakes, not `Mock`; calls are recorded in in-memory lists. |
| **Environment Stability** | ✅ PASS | No temporary files; no environment variable changes. M4 reads the committed `config/ci-docs-only-paths.json` by design (pins the committed allowlist); this is a read of a tracked file, not a temporary file. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, the code review, and the feature audit with the same timestamp form the review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #973, `spec.md` (full-bug), root cause and decisions D1 to D8. |
| **Read existing change plans** | ✅ PASS | `research/research.2026-10-17T12-25.md`; `evidence/baseline/phase0-instructions-read.2026-10-17T13-04.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-17T08-16.md` (preflight-cleared). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Fallback is a linear sequence of three git calls with one pure validation step. |
| **Reusability** | ✅ PASS | `Get-CiChangeScopeDiffDecision` is extracted and shared by the green-run and merge-base paths, removing the duplicated diff-and-classify block. |
| **Extensibility** | ✅ PASS | `-DocsOnlyReasonPrefix` parameter allows the shared helper to serve both reason families. |
| **Separation of concerns** | ✅ PASS | Pure helpers (`Test-CiMergeBaseFallbackApplicable`, `ConvertFrom-CiMergeBaseOutput`) live in the I/O-free module; the module-structure row pins the ban on git, gh, and file commands. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | No new production file; additions placed in the existing module and entry script. |
| **Under 500 lines** | ✅ PASS | `wc -l` by this review: 395, 365, 389, 110, 272, 258, 340; unchanged `Invoke-CiChangeScope.Tests.ps1` 411. |
| **Public vs internal** | ✅ PASS | `Export-ModuleMember` lists the two new pure functions explicitly. |
| **No circular dependencies** | ✅ PASS | Entry script imports the module; the module imports nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs `Test-`, `ConvertFrom-`, `Find-`, `Get-`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on all four new functions; `.DESCRIPTION` of the entry script updated. |
| **Comment why, not what** | ✅ PASS | Comments state why `\z` is used and why primary reasons are retained for fallback. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Non-writing Invoke-Formatter comparison: 0 of 7 files differ (`evidence/qa-gates/ps-format.2026-10-17T13-37.md`). |
| **2. Linting** | ✅ PASS | PSScriptAnalyzer with repository settings: 0 findings across 7 files; actionlint 0 findings on `ci.yml`. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Architecture boundary** | ✅ PASS | Module-structure Pester row (pure-module ban list) passes. |
| **5. Unit tests** | ✅ PASS | 238/238 touched suites; full `tests/scripts` 11271 pass, 0 fail, 10 skipped. |
| **6. Contract tests** | ✅ PASS | Brief and push-down contract tests: 53 passed, 0 failed; `test_brief_copies_are_byte_identical` passed. |
| **7. Integration** | ✅ PASS (pre-merge scope) | Live CI behavior is covered by the S9 CI-dependent criteria, not by this review. |
| **Full toolchain loop** | ✅ PASS | Phase 4 pass 1 completed without auto-fixes. |
| **Explicit reporting** | ✅ PASS | Commands and exit codes recorded in each evidence file. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `e1a6c90ea` and the spec design summary. |
| **Design choices explained** | ✅ PASS | Spec D1 to D8 and Security and Trust Analysis. |
| **Update supporting documents** | ✅ PASS | `.github/workflows/README.md` change-scope section and six brief copies (sha256 prefix `052d873ce29473a9` for all six, verified by this review). |
| **Provide next steps** | ✅ PASS | Spec Rollout section lists S9 and post-merge criteria. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 files differ. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings. |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 7 compatible** | ✅ PASS | The script runs under `pwsh` in the `changes` job; constructs used (`-ccontains`, `-cmatch`, `[StringComparison]::Ordinal`) are also valid in 5.1. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on all four new functions. |
| **Parameter validation** | ✅ PASS | `Mandatory` and `AllowEmptyString` used deliberately. |
| **Avoid global state** | ✅ PASS | No script or global variables added in production code. |
| **Error handling** | ✅ PASS | Every resolution failure returns `MERGE_BASE_UNRESOLVED`; the existing envelope maps any throw to `UNEXPECTED_ERROR`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 395 and 365 lines. |
| **Approved verbs** | ✅ PASS | `Test`, `ConvertFrom`, `Find`, `Get`. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 2.5. |
| **Step 2: Analyze** | ✅ PASS | See 2.5. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | See 2.5. |
| **Rerun loop if needed** | ✅ PASS | One pass. |

### Section 3D: JSON Configuration

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Three string values added to an existing array; parsed by `ConvertFrom-CiDocsOnlyPathConfig` in tests. |
| **Ordinal ordering** | ✅ PASS | `include_prefixes` is in ordinal order, pinned by the exact-string row. |

### Section 3E: GitHub Actions

| Requirement | Status | Evidence |
|------------|--------|----------|
| **actionlint clean** | ✅ PASS | 0 findings. |
| **No untrusted expression in run script** | ✅ PASS | `BASE_SHA` and `BASE_REF` are passed through `env:`, not interpolated into `run:`. |
| **Event-field allowlist test updated** | ✅ PASS | `CiWorkflow.Tests.ps1` allowlist extended by exactly the two new lines. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `Describe`/`Context`/`It`, `BeforeAll`, `-ForEach`, modern `Should`. |
| **Use PoshQC Configuration** | ✅ PASS | `Invoke-PoshQCTest` through the self-hosted module. |
| **Compatibility** | ✅ PASS | Run under PowerShell 7. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 28 new rows in the merge-base suite, 26 in `CiChangeScope.Tests.ps1`, 3 config rows, 1 workflow row. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions target log, output, and summary text and invoker call records. |
| **Mocking Used Sparingly** | ✅ PASS | No `Mock`; closure fakes only. |
| **Organization** | ✅ PASS | `tests/scripts/ci/` mirrors `scripts/ci/`; `tests/scripts/workflows/` covers `.github/workflows/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | ✅ PASS | `Invoke-CiChangeScopeMergeBase.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe, 2 Contexts, 12 It groups in the new suite. |
| **Logical Grouping** | ✅ PASS | `merge-base decisions` and `event gates and context`. |
| **Docstrings/Comments** | ✅ PASS | Helper functions carry purpose comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | See 2.5. |
| **No Alternative Test Runners** | ✅ PASS | Isolation runs use `Invoke-Pester` directly only to control file order; the gate runs use PoshQC. |

---

## 5. Test Coverage Detail

### `Test-CiMergeBaseFallbackApplicable` (10 rows)

Truth table: three trigger reasons with `main` give true; `development`, `epic/x`, empty, `Main` give false; three terminal reasons with `main` give false. Coverage: all lines covered (changed-line report 10/10 for the module).

### `ConvertFrom-CiMergeBaseOutput` (11 rows)

Three accepted forms and eight rejected forms. All lines covered.

### `Find-CiChangeScopeMergeBase` (via 7 M5 rows plus M1)

Each early-return branch (blank SHA, cat-file failure, merge-base failure, invalid output) and the success path is exercised.

### `Get-CiChangeScopeDiffDecision` (via green-run rows and M1 to M4, M9, M10)

Diff failure, invalid NUL output (existing rows), empty diff, rejected path, and docs-only success on both paths.

### `Resolve-CiChangeScopeDecision` steps 5 to 8 (M6 to M11)

Fallback triggers, non-main refs, terminal reasons, and event gates.

**Not covered:** pre-existing lines outside the diff only (process boundary `Invoke-CiChangeScopeNative`, default readers and invokers, CI entry guard, some parser validation branches), as listed in `coverage-delta.2026-10-17T13-39.md`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Touched-suite tests | 238 (238 passed) | ✅ |
| Full `tests/scripts` run | 11281 (11271 passed, 0 failed, 10 skipped) | ✅ |
| Isolation runs | 3 seeds, 208/208 each | ✅ |
| Python contract tests | 53 passed, 0 failed | ✅ |
| Line coverage (changed production files) | 93.57% and 91.15% | ✅ |
| Repo-wide PowerShell line coverage | 92.24% | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | non-writing comparison, 7 files | 0 differ | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -ScanFolders tests/scripts/ci,tests/scripts/workflows` | 238 passed | ✅ |

**For GitHub Actions:** actionlint via `scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml`: exit 0.

**Notes:** CI status for the head commit is not yet available (no pull request exists). The CI-dependent acceptance criteria are owned by the S9 gate.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None.** All policy requirements in scope are met. Three acceptance criteria are CI-dependent or post-merge by design and are tracked in the feature audit, not as policy gaps.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented. `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` was intentionally left unmodified per spec, and `git diff --exit-code` against the merge base confirms it is unchanged.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **702141621** - docs(973): add active feature folder for ci-docs-only-pr-runs-full-ci
2. **70d018fe6** - docs(973): add research for docs-only merge-base fallback
3. **e35334e62** - docs(973): add spec for docs-only merge-base fallback
4. **0d955d988** - docs(973): add preflight-cleared plan for docs-only merge-base fallback
5. **e1a6c90ea** - fix(ci): fall back to merge base for docs-only change scope

### Files Modified

1. **scripts/ci/CiChangeScope.psm1** (MODIFIED) - two pure helpers added and exported.
2. **scripts/ci/Invoke-CiChangeScope.ps1** (MODIFIED) - `BASE_SHA`/`BASE_REF` read; `Find-CiChangeScopeMergeBase` and `Get-CiChangeScopeDiffDecision` added; fallback inserted into `Resolve-CiChangeScopeDecision`.
3. **.github/workflows/ci.yml** (MODIFIED) - two env lines on step `scope`.
4. **config/ci-docs-only-paths.json** (MODIFIED) - three include prefixes.
5. **tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1** (NEW) and four modified test files.
6. **.github/workflows/README.md** and six execution-environment brief copies (MODIFIED).
7. Feature folder documents and evidence under `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/` and the promoted record `docs/features/potential/promoted/2026-10-17-ci-docs-only-pr-runs-full-ci.md` (NEW).

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All in-scope policy requirements are met with direct evidence. Numeric baseline, post-change, and changed-line coverage exist for PowerShell, the only coverage language with changed files.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plan present
- ✅ Design Principles: shared diff helper, pure helpers separated
- ✅ Module & File Structure: all files at most 411 lines
- ✅ Naming, Docs, Comments: approved verbs, comment-based help
- ✅ Toolchain Execution: format, analyze, tests, contract tests clean
- ✅ Summarize & Document: README and brief updated

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: fail-closed, no I/O in module
- ✅ Structure & Naming: compliant
- ✅ Toolchain: one pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: shuffle-verified independence
- ✅ Coverage & Scenarios: 100% changed-line coverage
- ✅ Test Structure: AAA, `-Because` diagnostics
- ✅ External Dependencies: closure fakes only
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 via PoshQC
- ✅ Test Style & Structure: focused rows
- ✅ Naming & Readability: descriptive names
- ✅ Toolchain: clean

### Metrics Summary

- ✅ 238/238 touched-suite tests passing; 11271 passed, 0 failed in the full run
- ✅ 93.57% and 91.15% line coverage on changed production files; 92.24% repo-wide
- ✅ 100.00% changed-line coverage
- ✅ All code quality checks passing

### Recommendation

**Ready for merge** after the S9 CI-dependent criteria are verified on the pull request.

---

## Appendix A: Test Inventory

New suite `Invoke-CiChangeScope.ps1 merge-base fallback (issue #973)`:

1. merge-base decisions › decides code=false DOCS_ONLY_SINCE_MERGE_BASE with the merge base in the summary when no green run exists and the base ref is main (#973)
2. merge-base decisions › decides NON_ALLOWLISTED_PATH on the merge-base diff when one path is outside the allowlist (#973)
3. merge-base decisions › decides NON_ALLOWLISTED_PATH on the merge-base diff for a rename <Direction> the allowlist (#973) (2 rows)
4. merge-base decisions › reaches DOCS_ONLY_SINCE_MERGE_BASE for a Markdown path under <Prefix> with the committed allowlist (#973) (3 rows)
5. merge-base decisions › decides MERGE_BASE_UNRESOLVED with base none when <Case> (#973) (7 rows)
6. merge-base decisions › falls back to the merge base when the primary reason is <PrimaryReason> and the base ref is main (#973) (2 rows)
7. merge-base decisions › keeps NO_FULL_GREEN_RUN without a bare merge-base call when the base ref is <BaseRef> (#973) (2 rows)
8. merge-base decisions › keeps <Reason> without a merge-base resolution call when the base ref is main (#973) (2 rows)
9. merge-base decisions › decides <Reason> when the merge-base diff <Case> (#973) (2 rows)
10. merge-base decisions › passes the unchanged diff flag list with the merge base and the head to git diff (#973)
11. event gates and context › decides <Reason> before any invoker call for <Case> with base ref main (#973) (4 rows)
12. event gates and context › Get-CiChangeScopeContext reads BASE_SHA and BASE_REF through the injected reader (#973)

Rows added to existing suites: U1 to U5 in `CiChangeScope.Tests.ps1`, the per-prefix row in `CiDocsOnlyPathsConfig.Tests.ps1`, the env-line row in `CiChangeScopeWorkflow.Tests.ps1`; updated rows: module structure (ten functions), exact include-prefix string, event-field allowlist.

---

## Appendix B: Toolchain Commands Reference

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1
Invoke-PoshQCTest -ScanFolders tests/scripts/ci,tests/scripts/workflows
Invoke-PoshQCTest -ScanFolders tests/scripts
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
./scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml
```

```bash
poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py -q --no-cov
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-17
**Policy Version:** Current (as of audit date)
