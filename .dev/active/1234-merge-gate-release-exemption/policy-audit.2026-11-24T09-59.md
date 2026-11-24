# Policy Compliance Audit: Release Merge Leg of the Epic Merge Gates (#1234)

**Audit Date:** 2026-11-24
**Code Under Test:** merge base `a4ebf96688106d9bcd0baf51d237a6b77c055560` of the base branch `main` and reviewed head `134a59879b50418db4e8aabb4e376b1753779aac` (branch `feature/merge-gate-release-exemption-1234`, PR #1236); the diff between them lists the changed files (71 files, 4244 insertions, 22 deletions)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 6 production hook files (3 new: Claude leg, Codex leg, Codex copy of the pure file; 3 edited: both gates and the Claude pure file header) plus 6 byte-identical bundle copies; 5 new Pester suites and 2 edited suites | 29483 cases (58 It blocks in the 5 new suites, many data-driven) | ✅ 29461 pass, 0 fail, 22 disabled | 96.85% lines repo-wide (47435/48976) | 96.87% lines repo-wide (47655/49197) | 100% (95/95 lines in each leg copy; 26/27 in the new Codex pure-file copy; every executable added gate line covered) |
| JSON | 2 files (both `pack-manifests/core.json`) | N/A | ✅ manifest completeness and dependency-closure tests pass in the executor pytest gate | N/A (config files) | N/A (config files) | N/A |
| Markdown | Rule source, two `.agents/skills/` sources, their generated targets, and bundle copies, plus feature-folder documents | N/A | ✅ `Invoke-HarnessGeneration.ps1 -Check`: no drift (reviewer run) | N/A | N/A | N/A |

Python, TypeScript, C#, and Bash have zero changed files on the branch; their coverage verdicts are N/A for that reason only.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (no TypeScript file changed)
- TypeScript post-change coverage artifact: N/A - out of scope (no TypeScript file changed)
- PowerShell baseline coverage artifact: `.dev/active/1234-merge-gate-release-exemption/evidence/baseline/pester.2026-11-24T05-02.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-11-24T09-35 UTC, re-parsed by the reviewer), `.dev/active/1234-merge-gate-release-exemption/evidence/qa-gates/pester.2026-11-24T09-35.md`, `.dev/active/1234-merge-gate-release-exemption/evidence/qa-gates/coverage-delta.2026-11-24T09-38.md`
- Per-language comparison summary: Section 1.2.1

---

## Executive Summary

The branch adds a release merge leg, `Get-EpicMergeGateReleaseDecision` in `enforce-epic-merge-gate-release.ps1`, to both the Claude and Codex epic merge gates. Keyed on the destination-owned `.claude/release-commit-allowance.json`, it admits a checkpoint-free `gh pr merge <N> --match-head-commit <sha>` when the head branch and every changed path are covered by one allowance, the live head equals the pinned SHA, and the newest `CI` run on that head is a successful `pull_request` run. The implementation is PowerShell only, byte-identical across `.claude/hooks/`, `.codex/hooks/`, and both bundle trees, listed in both `core.json` manifests, and documented through the harness-generation sources. No blocking policy finding was identified.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on `main`; `.claude/hooks` and `.codex/hooks` are covered by the existing classification; no tier-dependent gate is affected by this change)

**Language-specific policies evaluated:**
- N/A `python.md` (no Python file changed)
- ✅ `.claude/rules/powershell.md`
- N/A Bash (no shell file changed)
- ✅ JSON: both `core.json` diffs inspected; manifest completeness and dependency-closure tests reported passing

The reviewer re-parsed `artifacts/pester/powershell-coverage.xml` and confirmed the executor's figures exactly: repo-wide 47655 covered / 1542 missed (96.87%); `.claude/hooks/enforce-epic-merge-gate-release.ps1` 95/95; `.codex/hooks/enforce-epic-merge-gate-release.ps1` 95/95; `.claude/hooks/enforce-epic-merge-gate.ps1` 147/149; `.codex/hooks/enforce-epic-merge-gate.ps1` 182/183; `.claude/hooks/hook-release-pull-request-context.ps1` 27/27; `.codex/hooks/hook-release-pull-request-context.ps1` 26/27. The reviewer also ran `Invoke-HarnessGeneration.ps1 -Check` (exit 0, `harness-generation: no drift`) and `validate_evidence_locations.py --root .` (exit 0). No full test suite was run by the reviewer; the full suite runs only at the baseline and final QA gates per the owner directive.

**Temporary artifacts cleanup:**
- ✅ Executor scripts are under the session scratch directory, outside the worktree; `git status --porcelain` is clean at the reviewed head.
- ✅ No ongoing tooling script was added.
- Reviewer scripts: one check script written to the session scratch directory; not in the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Mocks are registered per row in `BeforeEach` and per-row fixture helpers; the suites passed in the 8-worker parallel Pester gate (`evidence/qa-gates/pester.2026-11-24T09-35.md`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `It` per code or data row; unit rows call `Get-EpicMergeGateReleaseDecision` directly; decision rows drive `Invoke-EpicMergeGateDecision` and `Invoke-CodexEpicMergeDecision`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | No waits; all process seams mocked; per-suite times recorded in task-check evidence. |
| **Determinism** - Consistent results | ✅ PASS | Synthetic roots under `/synthetic-worktrees/`; fixed run timestamps; no clock, network, or live process. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange/Act/Assert comments; row names state the code and end with `(#1234)`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 96.85% lines repo-wide, from the `Phase 0 baseline` artifact; new files `N/A - no pre-change run`<br>**Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` (one `Invoke-PoshQCParallelTest` run)<br>**Artifact:** `evidence/baseline/pester.2026-11-24T05-02.md`<br>**Timestamp:** 2026-11-24 05:02 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.87% lines repo-wide, read from the single gate run<br>**Change:** +0.02% lines against the `Phase 0 baseline`<br>**Status:** No regression. Edited files: Claude gate 98.64% to 98.66%; Codex gate 99.45% to 99.45%; Claude pure file 100% to 100%. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest changed production file 96.3% lines (`.codex/hooks/hook-release-pull-request-context.ps1`)<br>**Thresholds:** 85% line (default; root `CLAUDE.md` states none); no branch threshold for PowerShell<br>**Status:** All changed files meet the threshold. |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** both leg copies 95/95; Codex pure-file copy 26/27; added executable gate lines 3/3 per gate<br>**New code coverage:** 100% of the leg<br>**Calculation method:** per-file JaCoCo LINE counters from `artifacts/pester/powershell-coverage.xml`; changed-line mapping in `evidence/qa-gates/coverage-delta.2026-11-24T09-38.md`. |
| **Comprehensive Coverage** | ✅ PASS | Every leg function is exercised: `Get-EpicMergeGateReleaseNotAppliedResult`, `Get-EpicMergeGateReleasePullRequest`, `Get-EpicMergeGateReleasePullRequestViolation`, `Get-EpicMergeGateReleaseChangedPath`, `Get-EpicMergeGateReleaseCiFailure`, `Get-EpicMergeGateReleaseDecision`. Untested code: none. |
| **Positive Flows** - Valid inputs | ✅ PASS | Allow rows for `--merge`, `--squash`, `--rebase`, a 64-character head, and decision-level allow rows in both gates (AC-01, AC-02). |
| **Negative Flows** - Invalid inputs | ✅ PASS | At least one row per `RELEASE_MERGE_*` code (17 codes), run against both tree copies through `-ForEach` over the trees. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `changedFiles` 100 versus 101; `PrNumber` null, 0, -1; blank root; 39-character and uppercase heads; `open` versus `OPEN`; `..` in a branch; two allowances not combined. |
| **Error Handling** - Error paths | ✅ PASS | AC-20 row: an unexpected error returns an empty suffix and a `Write-Debug` record containing `EPIC_MERGE_GATE_RELEASE_LEG_ERROR`. |
| **Concurrency** - If applicable | N/A | The leg is stateless per call; a head change after lookup is handled by the required `--match-head-commit`, which `gh` enforces. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.85% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.87% lines. Change: +0.02% lines. New/changed-code coverage: 100% for both leg copies; 96.3% for the new Codex pure-file copy. Disposition: PASS. Evidence: `evidence/baseline/pester.2026-11-24T05-02.md`, `evidence/qa-gates/coverage-delta.2026-11-24T09-38.md`, `artifacts/pester/powershell-coverage.xml` (re-parsed by the reviewer). No branch figure exists for PowerShell and no branch threshold applies.
- Python: zero changed files. The executor's pytest gate (`evidence/qa-gates/pytest.2026-11-24T09-45.md`) reports 17104 passed and a TOTAL of 98.01% lines, identical to baseline. Disposition: N/A (no changed files).
- TypeScript, C#, Bash: zero changed files. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Allow rows pass the suffix or reason to `-Because`; code rows assert the exact code and detail. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment markers in every inspected row. |
| **Document Intent** | ✅ PASS | Row names state behavior and AC, for example `keeps the checkpoint-free release-shaped deny text byte-identical (#1234)`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | `Invoke-DocsOnlyGhExe` and `Invoke-DocsOnlyGitExe` are mocked with parameter filters; allowance seams are injected scriptblocks or mocks. |
| **Use Mocks/Stubs** | ✅ PASS | Wrapper seams only; no executable is mocked directly. |
| **Environment Stability** | ✅ PASS | Reviewer search for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `Start-Sleep`, and `Get-Date` in the five new suites: no match. Leak scan: 0 failures (`evidence/qa-gates/powershell-static.2026-11-24T09-20.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit and the authoritative executor self-review `evidence/qa-gates/self-review.2026-11-24T09-49.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1234; `spec.md` v0.2 decisions D1 to D3; research `research/research.2026-11-24T04-03.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-23T22-54.md` (preflight-cleared), 23 of 23 tasks checked. |
| **Document the plan** | ✅ PASS | Task-check evidence per task under `evidence/other/`; phase gates under `evidence/qa-gates/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One linear first-failure-wins function; each gate gains one dot-source, one call line, and one suffix term. |
| **Reusability** | ✅ PASS | Reuses `Get-ReleasePullRequestConfigState`, `Get-ReleasePullRequestPathDecision`, `Get-DocsOnlyMergeShapeViolation`, `Invoke-DocsOnlyGhExe`, `Test-CommandLineFlag`, `Get-CommandLineFlagValue`, `Get-EpicMergeGateChildCiRunList`, `Select-EpicMergeGateChildCiRun`, `Test-EpicMergeGateChildCiObjectId`, and `Get-EpicMergeGateChildCiProperty`; no parser, matcher, tokenizer, invoker, or run selector is redefined. |
| **Extensibility** | ✅ PASS | `ConfigReader` and `ContainerProbe` are injectable scriptblocks with defaults. |
| **Separation of concerns** | ✅ PASS | I/O runs only through `Invoke-DocsOnlyGhExe` and the two allowance seams; validation helpers are pure. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The leg file holds only the release merge decision and its helpers. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts of every added or modified covered file: Claude gate 500; Codex gate 456; leg 303 (four copies); pure file 119 (four copies); suites 434, 282, 246, 233, 189, 176, 85. No file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | One entry function; helpers share the `EpicMergeGateRelease` noun prefix. |
| **No circular dependencies** | ✅ PASS | The leg dot-sources only `enforce-orchestration-preimplementation-gate-release.ps1` and `hook-release-pull-request-context.ps1`; neither loads a merge gate. All call-time dependencies exist in `.codex/hooks/` and are loaded by the Codex gate (reviewer inspection). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs; nouns name the step. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function; the file header lists steps, codes, process calls, and dependencies. |
| **Comment why, not what** | ✅ PASS | Comments state fail-closed handling and the policy-level-control disclosure. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` over the 19 new and changed `.ps1` files<br>**Result:** 0 files changed (`evidence/qa-gates/powershell-static.2026-11-24T09-20.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings |
| **3. Type checking** | N/A | **Command:** none<br>**Result:** N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`<br>**Result:** 29483 tests, 0 failures, 0 errors, 22 disabled (`evidence/qa-gates/pester.2026-11-24T09-35.md`) |
| **Full toolchain loop** | ✅ PASS | The first final Pester gate failed 5 tests caused by this branch; causes fixed on the branch (`evidence/other/final-qa-remediation.2026-11-24T09-16.md`) and the loop restarted from format; the restarted pass was clean. |
| **Explicit reporting** | ✅ PASS | Each command and exit code is recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `134a59879` message; executor self-review. |
| **Design choices explained** | ✅ PASS | Spec Decisions D1 to D3; file headers. |
| **Update supporting documents** | ✅ PASS | Orchestrator-state rule, execution-environment brief, and pr-author skill changed through `scripts/harness-generation/sources/rules/orchestrator-state.md` and `.agents/skills/`; reviewer `-Check`: no drift. |
| **Provide next steps** | ✅ PASS | Pending CI jobs on PR #1236 (Section CI Cross-check). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` via PoshQC settings<br>**Result:** 0 changes |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | `PSUseOutputTypeCorrectly` (leg) and `PSReviewUnusedParameter` / `PSUseShouldProcessForStateChangingFunctions` (test helpers) fixed during task checks. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Hooks target PowerShell 7+ per `.claude/rules/powershell.md`; `ConvertFrom-Json -NoEnumerate` matches the existing child-CI helper. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every new function has `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowNull`, `AllowEmptyString`, `AllowEmptyCollection`, and `Nullable[int]`. |
| **Avoid global state** | ✅ PASS | The leg defines no script-scope or global variable. |
| **Error handling** | ✅ PASS | One whole-body `try/catch`; the catch writes `Write-Debug` and declines, so the gate's deny stands (fail closed, per spec). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | See Section 2.3. |
| **Approved verbs** | ✅ PASS | `Get-` only in the leg. |
| **Comment why** | ✅ PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 changes after the loop restart. |
| **Step 2: Analyze** | ✅ PASS | 0 findings after the loop restart. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 29483 tests, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | One restart after remediation; final pass clean. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | N/A | `core.json` files are pack manifests; three string entries inserted into the existing `paths` arrays in the existing style. |
| **Schema validation** | ✅ PASS | Both pack-manifest completeness tests and `test_push_down_pack_manifest_dependency_closure.py` passed in the executor pytest gate (17104 passed, 0 failed). |
| **Required $schema** | N/A | `core.json` is not a governed schema file. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | The diff shows quoted strings with commas inside the arrays only. |
| **Deterministic key order** | N/A | No key added. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Pester 6.2.0 through `Invoke-PoshQCParallelTest`; `Should -Invoke ... -Exactly`, `-ForEach` data rows. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through the launcher<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged) |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7+ per the repository rule. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 20 / 12 / 9 / 8 / 9 It blocks across the five new suites, expanded by `-ForEach` data rows and by tree. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions target decisions, exact suffix text, and the seam-call counts the spec names (AC-19, AC-21, AC-22). |
| **Mocking Used Sparingly** | ✅ PASS | Only process and file seams are mocked; parsers and predicates run unmocked. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/<hook>.Tests.ps1` and `tests/scripts/codex-hooks/<hook>.Tests.ps1`<br>**Code file:** `.claude/hooks/<hook>.ps1` and `.codex/hooks/<hook>.ps1`<br>Follows the established hook-suite layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All five suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | `Describe` per tree or gate, `Context` per step band. |
| **Logical Grouping** | ✅ PASS | Steps 1-12, steps 13-17, Claude decision level, Codex decision level, parity. |
| **Docstrings/Comments** | ✅ PASS | Suite headers describe isolation and mocked seams. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` (8 workers)<br>**Result:** 29483 tests, 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### enforce-epic-merge-gate-release.ps1 (both trees)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Steps 1-12 rows: declines with no I/O, absent file, `RELEASE_MERGE_CONFIG_INVALID` (3), `CHECKPOINT_PRESENT`, `COMMAND_NOT_MODELLED` (7), `MATCH_HEAD_MISSING` (4), `PR_UNRESOLVED` (9), argument list, `PR_NOT_OPEN`, `CROSS_REPOSITORY`, `HEAD_MISMATCH`, `FILES_TRUNCATED` (2), step-10 pass at 100, `CHANGE_NOT_MODELLED` (3), step-11 pass, `BRANCH_NOT_MATCHED`, `EMPTY_DIFF`, `PATH_NOT_ALLOWED`, no combination | Positive/Negative/Edge Case | 60-174, 240-294 | ✅ |
| Steps 13-17 rows: allow per method, 64-character head, `CI_UNREADABLE`, `CI_MISSING`, `--commit` binding, `CI_EVENT_NOT_ALLOWED`, `CI_NOT_GREEN` (2), first-failure-only, call-count bands, caught error | Positive/Negative/Error Handling | 176-205, 296-302 | ✅ |

**Coverage:** 100% (95/95 lines per copy). **Not covered:** None.

### enforce-epic-merge-gate.ps1 (Claude and Codex)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Absent-file exact deny text and process counts (AC-21, AC-22) | Edge Case | wiring and final deny line | ✅ |
| Allow without review-guard process call (AC-01, AC-02, AC-25); `CHECKPOINT_PRESENT` (AC-05); suffix order (AC-23); docs-only and epic-child precedence (AC-24) | Positive/Negative | wiring and final deny line | ✅ |

**Coverage:** Claude 98.66% (147/149), Codex 99.45% (182/183); every added executable line covered. **Not covered:** two pre-existing Claude lines and one pre-existing Codex line, outside the changed hunks.

### release-merge.Parity.Tests.ps1 (9 tests)

Copy parity across the four leg copies and four pure-file copies, function-set and token checks, `core.json` listings, and the absence of `python` and `poetry` text in each leg copy (AC-29 to AC-31, AC-39).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 29483 | ✅ |
| Tests Passed | 29461 (22 disabled, unchanged from baseline) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 763.03 s wall-clock, 8 workers | ✅ |
| Average Time per Test | about 26 ms | ✅ Fast |
| Discovery Time | Not recorded by the executor artifact | ✅ |
| Functions/Classes Tested | 6/6 new functions (100%) | ✅ |
| Test File Size | 85 to 434 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 96.87% lines repo-wide; no PowerShell branch figure | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` (PoshQC settings) | 0 changes | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 29483 tests, 0 failures | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan -Root` | 0 failures | ✅ |

**For Python (no changed files; regression gate only):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Pytest Tests | `run-test-suite.sh pytest --cov-report=term-missing --cov` | 17104 passed, 0 failed; totals identical to baseline | ✅ |

**Notes:** The first final Pester gate failed 5 tests caused by this branch (discovery-guard baseline mocks in two new suites, an AL-34 command span in the pr-author source, and a `core.json` insertion point that changed ledger hunk context). Each was fixed on the branch without editing any ledger record, and the loop restarted from format.

---

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 formatter changes, 0 analyzer findings | 134a59879 | `evidence/qa-gates/powershell-static.2026-11-24T09-20.md` |
| poshqc / PowerShell QC shard 1-6 | pass | 29483 tests, 0 failures | 134a59879 | `evidence/qa-gates/pester.2026-11-24T09-35.md` |
| poshqc / PowerShell hook suites (Linux) | pass | 0 failures (local Windows run) | 134a59879 | `evidence/qa-gates/pester.2026-11-24T09-35.md` |
| quality-checks7 / Python 3.13 coverage | pass | 98.01% lines (Python totals unchanged) | 134a59879 | `evidence/qa-gates/pytest.2026-11-24T09-45.md` |
| docs-validation / Documentation Validation | pass | generator `-Check` no drift | 134a59879 | reviewer run of `Invoke-HarnessGeneration.ps1 -Check` |

At review time (`gh pr view 1236 --json statusCheckRollup`), Change scope, CI full run, docs-validation, build-check, security-scan, extension tests, root TypeScript tests, Publish to Marketplace, and npm audit had passed; the poshqc, quality-checks7, and shell-coverage jobs were in progress. `Enforce Python coverage thresholds` runs inside quality-checks7 and had no result yet. The review relies on local evidence; the orchestrator compares these claims with CI at head `134a59879` at the CI green gate.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All executor evidence is under `.dev/active/1234-merge-gate-release-exemption/evidence/<kind>/`, and every evidence file on the branch is newly added. Superseded artifacts (`self-review.2026-11-24T09-47.md`, `self-review.2026-11-24T09-48.md`, `powershell-static.2026-11-24T08-42.md`) are kept unchanged, and timestamp irregularities are disclosed append-only in `evidence/other/evidence-timestamp-disclosure.2026-11-24T09-49.md`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Vendored Coverage Exemptions

No `vendored-coverage-exemptions.json` beside the coverage output, no coverage-exclusion entry added, and no `.push-down-manifest.json` change on the branch.

## Rejected Scope Narrowing

None. The caller prompt named the full branch range (merge base `a4ebf966` to head `134a5987`) and did not narrow scope, files, languages, or checks.

---

## 8. Gaps and Exceptions

### Identified Gaps
**None.** All policy requirements are met. Non-blocking observations are recorded in the code review.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
**None.** All planned tests implemented; the disabled count (22) is unchanged from baseline.

---

## 9. Summary of Changes

The branch lets a destination that commits `.claude/release-commit-allowance.json` merge a release pull request without an orchestration checkpoint, through one fail-closed leg evaluated last in the explicit-number block of each merge gate. Without the allowance file, both gates keep their deny text and process calls unchanged.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All required baseline, post-change, and coverage-comparison artifacts exist and were cross-checked. PowerShell coverage is PASS; no other coverage language has changed files.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present
- ✅ Design Principles: reuse of the #1201, #1231, docs-only, and child-CI helpers
- ✅ Module & File Structure: largest changed file 500 lines
- ✅ Naming, Docs, Comments: comment-based help in each function
- ✅ Toolchain Execution: clean final pass after one restart
- ✅ Summarize & Document: generated docs changed through sources

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyzer clean
- ✅ PowerShell Design & Safety: advanced functions, fail-closed catch
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: final pass clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: isolated, deterministic
- ✅ Coverage & Scenarios: 100% leg coverage
- ✅ Test Structure: Arrange/Act/Assert
- ✅ External Dependencies: all seams mocked, no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester through PoshQC
- ✅ Test Style & Structure: one behavior per row
- ✅ Naming & Readability: names carry AC and issue
- ✅ Toolchain: parallel gate green

### Metrics Summary

- ✅ 29461/29483 tests passing (0 failed, 22 disabled)
- ✅ 6/6 new functions tested
- ✅ 96.87% repo-wide PowerShell line coverage; 100% on the leg
- ✅ Test files under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`
- ✅ Format, analyzer, leak-scan, and generator checks clean
- ✅ 763.03 s wall-clock for the full parallel Pester gate

### Recommendation

**Ready for merge**, subject to the in-progress poshqc, quality-checks7, and shell-coverage CI jobs on PR #1236 completing green at head `134a59879`.

---

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/enforce-epic-merge-gate-release.Tests.ps1` (20 It blocks, run per tree)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate-release.Ci.Tests.ps1` (12 It blocks, run per tree)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Release.Tests.ps1` (9 It blocks)
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-release.Tests.ps1` (8 It blocks)
- `tests/scripts/claude-hooks/release-merge.Parity.Tests.ps1` (9 It blocks)
- Edited: `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`

---

## Appendix B: Toolchain Commands Reference

```powershell
# Reviewer: coverage parse (grep/awk over artifacts/pester/powershell-coverage.xml)
# Reviewer: generator drift check
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check
# Reviewer: evidence locations
env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# Executor: Pester gate
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-24
**Policy Version:** Current (as of audit date)
