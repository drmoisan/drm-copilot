# Policy Compliance Audit: documentation-estate template and onboarding (#1038)

---

**Audit Date:** 2026-11-07
**Code Under Test:** `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1`; `tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1`; `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1`; `tests/scripts/claude-lib/docs/DocumentationEstateFixture.TestSupport.psm1`; `tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1`; `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` and `README.md`; `docs/engineering/documentation-estate/{README,architecture,consumer-onboarding,command-reference,workflow}.md`; feature-folder documents and evidence (47 paths in total).

**Scope:** full branch diff `d395d5140f3822eeef453f2055d4ac539656d629..f668e4254135715cce4901e9b6f6d152cacb8d35`. Base: `origin/epic/documentation-estate-tooling-integration` (PR base; merge-base timestamp 2026-11-07 15:16:09 -0500). Head: `feature/documentation-estate-template-and-onboarding-1038-r2` at `f668e4254`. PR context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were generated at 2026-11-07 22:04:41 UTC for head `f668e4254` and are current.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 5 files (3 Pester suites, 2 test-support modules; no production file) | 41 new tests (18 + 13 + 10); 19341 in the gate run | PASS: 19331 passed, 0 failed, 10 skipped | 95.45% lines repo-wide (34368/36005) | 95.45% lines repo-wide (34368/36005) | 100.00% (0 of 0 changed production lines; vacuous, because no production PowerShell line was added or changed); changed-line coverage of `.claude/lib/docs/` unchanged (0.00 delta on 72 files); the five changed files are test files, outside the coverage denominator by policy |
| Markdown | 7 deliverable pages and template files, plus feature documents | N/A | N/A | N/A | N/A | N/A |
| Python | 0 files | N/A | N/A | N/A | N/A | N/A |
| TypeScript | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero changed TypeScript files on the branch)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero changed TypeScript files on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/evidence/baseline/pester-coverage.2026-11-07T21-04.md` (Phase 0 baseline, one `Invoke-PoshQCParallelTest` run)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-11-07 16:48 -0500, after the last code commit `4ea6d64d2` at 16:26 -0500), summarized in `evidence/regression-testing/pester-coverage.2026-11-07T21-55.md`
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-11-07T21-55.md` and section 1.2.1 below

Baseline coverage is read from the plan's `Phase 0 baseline` artifact. Every commit after `4ea6d64d2` changes only paths inside the active feature folder (`git diff --name-only 4ea6d64d2 HEAD` lists feature-folder documents only), so the post-change artifact reflects the head code.

---

## Executive Summary

This child adds one epic template pair, five onboarding pages, three Pester suites and two Pester test-support modules. It adds no production PowerShell, Python, TypeScript or C# file and edits no file under `.claude/`, `extensions/drm-copilot/src/` or `extensions/drm-copilot/resources/claude-customizations/`.

**Policy documents evaluated:**
- PASS `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- PASS `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists on the base; the branch adds no project, so no classification change is required)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (zero changed Python files)
- PASS `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- N/A Bash (zero changed shell files)
- N/A JSON (zero changed JSON files)

Toolchain: the reviewer re-ran `Invoke-Formatter` (check form) and `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the five new PowerShell files under PowerShell 7.6.9: 0 formatting differences, 0 analyzer findings. The executor's single parallel Pester gate (`Invoke-PoshQCParallelTest`) reports 19341 tests, 0 failures and 0 errors in `artifacts/pester/pester-junit.xml`; the three new suites report 13, 18 and 10 tests with 0 failures. Repo-wide Pester line coverage was re-parsed by the reviewer from `artifacts/pester/powershell-coverage.xml` (root `LINE` counter missed 1637, covered 34368 = 95.45%).

One blocking finding: spec acceptance criterion SAC-12 ("with Python 3.10 or later") is checked off although the delivered page states Python 3.11 or later. The page is correct for the merged code (`FLOOR = (3, 11)` in `.claude/lib/docs/python/run_docs_python_native.py`), but the spec carries no erratum. The criterion text, spec lines 149 and 324, and plan task P2-T3 still state 3.10. The spec's own Phase 0 rule requires a divergence to be routed as a plan revision rather than adapted in delivery. The D-1 finding-code divergence on the same branch was handled that way, with a spec erratum, and this one was not. Section 8 records the details.

**Temporary artifacts cleanup:**
- PASS No temporary or one-time script was committed; the executor's helper scripts live under the session scratch directory (`SCRATCH/issue-1038-*.sh`) and are not in the branch diff.
- PASS No tooling script was added to the repository.
- The reviewer's own check script was written to the session scratchpad and is not committed.

---

## Rejected Scope Narrowing

None. The caller prompt does not narrow the audit scope, does not exclude a language, and does not mark any coverage check out of scope. The caller's owner decisions of 2026-11-07 change the test-run procedure (one parallel run per gate; seeded-shuffle and single-process runs waived), not the audit scope. Those decisions are binding on this run, and the merged process-reduction entry `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` (`reduction: 0001`) records the same procedure repository-wide.

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. Every evidence file is under `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/evidence/<kind>/`. Result: PASS.

## Workflow Rule

`modified-workflow-needs-green-run`: the branch diff modifies no path under `.github/workflows/**`, `scripts/benchmarks/**` or `.github/actions/**`. The rule does not fire.

## Process-Reduction Ledger

`docs/engineering/process-reductions/` exists. The branch diff contains no change to evidence rules, plan tasks, gates or review process: it waives plan tasks [P4-T5] (seeded shuffle runs) and the single-process clause for this item only, by owner directive, and records the waiver in `evidence/regression-testing/pester-shuffle.2026-11-07T21-55.md`. A one-off waiver for a single item is not a ledger entry. Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | The end-to-end suite builds a fresh in-memory context per `It` through `Invoke-EstateScenario` (D-3), so no state crosses tests. The template suite reads the template once in `BeforeAll` and mutates copies only. Each suite removes its imported modules in `AfterAll`. Order-variation runs are waived by owner directive (decision 1); the parallel gate ran the suites across 8 shard processes with 0 failures. |
| **Isolation** - Each test targets single behavior | PASS | One assertion group per `It`: e.g. `reports DOCS_STALE_PAGE with the stale page path and the changed command's declaration`, `fails with EPIC_MANIFEST_SELF_EDGE for a self-dependency`. |
| **Fast Execution** - Tests complete quickly | PASS (advisory noted) | Template suite 0.388 s, onboarding suite 0.702 s. The end-to-end suite takes 211.119 s for 10 tests because each test replays the scenario from the start; recorded as a non-blocking Medium row in the code review. |
| **Determinism** - Consistent results | PASS | Fixed 40-hex revisions, fixed `UtcNow` (2026-03-01T12:00:00Z), `-AnalysisMethod scanner` so the process seam is never called, and an asserted empty `ProcessCallLog`. No random input. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `It` names, Arrange/Act/Assert comments, `-Because` clauses on assertions. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline:** 95.45% lines repo-wide (34368/36005), read from the `Phase 0 baseline` artifact<br>**Command:** `Invoke-PoshQCParallelTest` (one run of the gate)<br>**Artifact:** `evidence/baseline/pester-coverage.2026-11-07T21-04.md`<br>**Timestamp:** 2026-11-07 21:04 UTC |
| **No Coverage Regression** | PASS | **Post-change coverage:** 95.45% lines repo-wide (34368/36005), read from the single gate run<br>**Change:** 0.00 points; 72 files under `.claude/lib/docs/` compared, every per-file delta 0.00<br>**Status:** No regression. No production line changed. |
| **Changed Files Meet Thresholds** | PASS | **Post-change coverage:** 95.45% lines repo-wide<br>**Thresholds:** root `CLAUDE.md` states no coverage threshold, so the defaults govern: line >= 85%; no PowerShell branch threshold (Pester measures no branch coverage)<br>**Status:** No production file was added or modified; the five changed PowerShell files are test files, which the coverage denominator excludes by policy. |
| **New Code Coverage ≥90%** | N/A | No new production code. The template governs new-file coverage at the policy default (85% lines); no production file was added. |
| **Comprehensive Coverage** | PASS | Every exported function of `EpicManifest.TestSupport.psm1` (`ConvertFrom-EpicManifestFrontmatter`, `Get-EpicManifestSchemaFinding`, `Get-EpicManifestWave`, `Get-EpicPlannedWave`) and of `DocumentationEstateFixture.TestSupport.psm1` is exercised by the suites. |
| **Positive Flows** - Valid inputs | PASS | Template conformance (7 tests), waves (5 tests), baseline and fixed docs-complete passes, page membership and statement checks (10 tests). |
| **Negative Flows** - Invalid inputs | PASS | Positive controls: two-node cycle, unresolved `depends_on`, duplicate `issue_num`, self-edge, flow mapping outside the subset; an in-memory command reference missing `inventory`; a synthetic consumer identifier. |
| **Edge Cases** - Boundary conditions | PASS | Unpinned snapshot (`inventory` without `-Revision`) yields `DOCS_SNAPSHOT_UNPINNED`; a line change inside a declaration range without a declaration change yields `DOCS_STALE_PAGE` with `digest-changed`. |
| **Error Handling** - Error paths | PASS | `EPIC_MANIFEST_UNSUPPORTED` throw asserted with `Should -Throw -ExpectedMessage`; `Invoke-EstateCommand` throws with the finding list when an exit code differs. |
| **Concurrency** - If applicable | N/A | No concurrent behavior is under test. |
| **State Transitions** - If applicable | PASS | The end-to-end scenario walks Baseline, Defects, Fixed and Unpinned states and asserts each. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.45% lines (34368/36005, from the `Phase 0 baseline` artifact `evidence/baseline/pester-coverage.2026-11-07T21-04.md`) -> Post-change: 95.45% lines (34368/36005). Change: 0.00 points. New/changed-code coverage: 100.00% (0 of 0 changed production lines; vacuous, because all five changed PowerShell files are test files); every per-file delta under `.claude/lib/docs/` is 0.00. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (reviewer re-parse of the root `LINE` counter), `evidence/qa-gates/coverage-delta.2026-11-07T21-55.md`.
- Python: zero changed files on the branch. Disposition: N/A. (The repo-wide pytest figures, 52.47% lines and 49.15% branches, are unchanged from the baseline and are recorded for information only.)
- TypeScript: zero changed files on the branch. Disposition: N/A.
- C#: zero changed files on the branch. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `-Because` clauses name the step, element or statement; the exit-code guard in `Invoke-EstateCommand` throws with every finding code and message. |
| **Arrange-Act-Assert Pattern** | PASS | `# Arrange`, `# Act`, `# Assert` comments in every `It`. |
| **Document Intent** | PASS | Each file has a comment-based `.SYNOPSIS`/`.DESCRIPTION` naming the scenario and the issue number. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, no process start (asserted through `ProcessCallLog.Count -eq 0`), no Python invocation. The suites read committed repository files (template, pages, entry script, tool-definitions file) read-only. |
| **Use Mocks/Stubs** | PASS | The in-memory command context from `Docs.TestSupport.psm1` (`New-DocsTestContext`) replaces file I/O and the process seam. |
| **Environment Stability** | PASS | Reviewer scan of the five new files for `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `env:TEMP`, `Start-Process`, `Set-Content`, `Out-File` and `New-Item`: no match. Paths are resolved from `$PSScriptRoot`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit is the required policy review; the executor's self-review is `evidence/qa-gates/self-review.2026-11-07T22-02.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `spec.md` `## Problem` and `## Scope`; issue #1038, epic #1019. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.2026-11-07T20-27.md`. |
| **Document the plan** | PASS | `plan.2026-10-30T18-59.md`, all tasks checked; D-1 revision committed as `53ce763d4`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Pure manifest parser bounded to the YAML subset the template uses; fail-closed on any other construct. |
| **Reusability** | PASS | The end-to-end fixture reuses `New-DocsTestContext` from `Docs.TestSupport.psm1` instead of a second in-memory context. |
| **Extensibility** | PASS | Membership checks derive expected names from `Get-DocsCommandTable` and from `mcp-docs-tool-definitions.ts`, so a new subcommand or tool fails the suite until documented. |
| **Separation of concerns** | PASS | Fixture text and the context factory live in support modules; suites hold scenario logic and assertions. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | `EpicManifest.TestSupport.psm1` (parser, schema, waves); `DocumentationEstateFixture.TestSupport.psm1` (fixture text, context). |
| **At or below the 800-line hard limit** | PASS | Logical lines (reviewer, `@(Get-Content).Count`): `EpicManifest.TestSupport.psm1` 302; `DocumentationEstateEpicTemplate.Tests.ps1` 218; `DocumentationEstateOnboarding.Tests.ps1` 251; `DocumentationEstateFixture.TestSupport.psm1` 163; `EndToEndDocumentationEstate.Tests.ps1` 271. None at or above 700; none above 500. `config/file-size-baseline.json` is not in the branch diff. |
| **Public vs internal** | PASS | `Export-ModuleMember` limits each support module to its consumed functions and variables. |
| **No circular dependencies** | PASS | `DocumentationEstateFixture.TestSupport.psm1` imports `Docs.TestSupport.psm1`; no module imports a suite. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Approved verbs (`Get-`, `ConvertFrom-`, `ConvertTo-`, `New-`, `Test-`, `Format-`, `Find-`, `Invoke-`, `Add-`). |
| **Docs/docstrings** | PASS | Comment-based help on every support-module function. |
| **Comment why, not what** | PASS | Comments explain choices, e.g. why the schema texts are seeded into the in-memory map and why `-AnalysisMethod scanner` is pinned. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file (reviewer re-run)<br>**Result:** 0 of 5 files differ. Executor record: `evidence/qa-gates/pwsh-format.2026-11-07T21-27.md`. |
| **2. Linting** | PASS | **Command:** `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (reviewer re-run)<br>**Result:** 0 findings. Executor record: `evidence/qa-gates/pssa.2026-11-07T21-27.md`. |
| **3. Type checking** | N/A | Not applicable for PowerShell; no Python or TypeScript file changed. |
| **4. Testing** | PASS | **Command:** `Invoke-PoshQCParallelTest -Root <worktree>` (one parallel run)<br>**Result:** 19341 tests, 0 failures, 0 errors, 10 skipped; baseline 19300 tests, 0 failures. No new failure against the baseline (owner decision 2). |
| **Full toolchain loop** | PASS | `evidence/qa-gates/toolchain-loop.2026-11-07T22-00.md`: single pass with no file changed. |
| **Explicit reporting** | PASS | Commands and results are recorded in the evidence artifacts and in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit subjects describe each step; section 9 below. |
| **Design choices explained** | PASS | Spec `## Design`; plan decisions D-1 to D-8. |
| **Update supporting documents** | PARTIAL | `spec.md` carries the D-1 erratum but no erratum for the Python floor; the SAC-12 text, spec lines 149 and 324, and plan task P2-T3 still state Python 3.10. See section 8, gap G-1. |
| **Provide next steps** | PASS | `evidence/qa-gates/ci-pending.2026-11-07T22-00.md` records the CI-dependent clause of SAC-24 for the S9 gate. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | Reviewer re-run: 0 differences across the five files. |
| **Linting with PSScriptAnalyzer** | PASS | Reviewer re-run: 0 findings. Baseline `evidence/baseline/pssa.2026-11-07T20-51.md`. |
| **Fix all findings** | PASS | No findings to fix. One justified suppression: `PSUseShouldProcessForStateChangingFunctions` on `New-DocumentationEstateFixtureContext`, which builds in-memory objects only. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | The repository requires PowerShell 7+; the suites declare `#Requires -Version 7.0` and the support modules note 7.4. Verified under 7.6.9. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | Support-module functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | PASS | `Mandatory`, `AllowEmptyString`, `AllowEmptyCollection`, `ValidateSet` on `Invoke-EstateScenario -Through`. |
| **Avoid global state** | PASS | No global scope use; module-scope state is limited to two exported constant revisions. |
| **Error handling** | PASS | `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` in both modules; explicit `throw` with a coded message. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | PASS | Maximum 302 logical lines. |
| **Approved verbs** | PASS | PSScriptAnalyzer `PSUseApprovedVerbs` reports no finding. |
| **Comment why** | PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | 0 differences. |
| **Step 2: Analyze** | PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | One parallel gate run, 0 failures. |
| **Rerun loop if needed** | PASS | Single pass; no restart. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` (minimum); executed by PoshQC with `BeforeAll`, `AfterAll`, `Describe`/`Context`/`It` and `Should` syntax. |
| **Use PoshQC Configuration** | PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>No configuration change; `config/poshqc-scan.json` already scans `tests/scripts`. |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | PowerShell 7+ only, as the repository requires. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 18 template tests, 13 onboarding tests, 10 end-to-end tests. |
| **Test Behavior Over Implementation** | PASS | The end-to-end suite drives the real dispatch through `Invoke-DocsCommandCli` and asserts envelopes, codes and receipt fields. |
| **Mocking Used Sparingly** | PASS | No `Mock`; the in-memory context is the only test double. |
| **Organization** | PASS | **Test files:** `tests/scripts/claude-lib/docs/*.Tests.ps1`<br>**Code under test:** `.claude/lib/docs/Invoke-DocsCommand.ps1` (entry and dispatch); the suites sit beside the existing `.claude/lib/docs` suites. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | All three suites end in `.Tests.ps1`; support modules end in `.TestSupport.psm1`. |
| **Describe/Context/It Structure** | PASS | Template: 3 `Describe`, 18 `It`. Onboarding: 2 `Describe`, 1 `Context`, 13 `It`. End-to-end: 1 `Describe`, 10 `It`. |
| **Logical Grouping** | PASS | Manifest, waves and positive controls are separate `Describe` blocks. |
| **Docstrings/Comments** | PASS | File-level comment-based help in each suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Result:** 19341 tests, 0 failures. |
| **No Alternative Test Runners** | PASS | Only Pester through PoshQC. |

---

## 5. Test Coverage Detail

### `EpicManifest.TestSupport.psm1` through `DocumentationEstateEpicTemplate.Tests.ps1` (18 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| parses the frontmatter within the supported subset | Positive | parser, lines 54-139 | PASS |
| has unique integer issue_num values and unique feature_folder values | Positive | schema checks, lines 153-204 | PASS |
| computes waves equal to the Planned Waves list | Positive | lines 206-300 | PASS |
| fails with EPIC_MANIFEST_CYCLE for a two-node cycle | Negative | cycle path, lines 220-225, 270-274 | PASS |
| fails with EPIC_MANIFEST_SELF_EDGE for a self-dependency | Negative | line 263 | PASS |
| fails with EPIC_MANIFEST_UNSUPPORTED for a flow mapping | Error Handling | lines 94, 42-52 | PASS |

**Coverage:** test-support code; excluded from the coverage denominator by policy.

**Not covered:** the non-integer `issue_num` branch (line 196) has no positive control; recorded as a Low row in the code review.

### `EndToEndDocumentationEstate.Tests.ps1` (10 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| passes docs-complete at revision R1 after inventory, ledger and generation | Positive | dispatch through `Invoke-DocsCommandCli` | PASS |
| reports DOCS_LEDGER_MISSING_DISPOSITION with the new command's element identifier and declaration | Negative | 1023 ledger rules | PASS |
| reports DOCS_STALE_PAGE with the stale page path and the changed command's declaration | Negative | 1023 staleness | PASS |
| fails closed with DOCS_SNAPSHOT_UNPINNED when inventory ran without a revision | Edge Case | 1023 pin rule | PASS |

**Coverage:** production coverage is unchanged (every `.claude/lib/docs/` per-file delta 0.00).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 19341 (41 new) | PASS |
| Tests Passed | 19331 (99.95%; 10 skipped, pre-existing) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Gate 1038.264 s total; new suites 0.388 s, 0.702 s, 211.119 s | PASS (end-to-end suite slow; advisory) |
| Average Time per Test | End-to-end 21.1 s; template 21.6 ms; onboarding 54.0 ms | PASS (advisory) |
| Discovery Time | Not separately reported by the merged JUnit report | N/A |
| Functions/Classes Tested | 4/4 exported manifest functions; 3/3 exported fixture functions | PASS |
| Test File Size | 163 to 302 logical lines | PASS |
| Code Coverage (if applicable) | 95.45% lines repo-wide (PowerShell) | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (5 files) | 0 differences | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (5 files) | 0 findings | PASS |
| Pester Tests | `Invoke-PoshQCParallelTest -Root .` | 19341 tests, 0 failures | PASS |

**Notes:** The reviewer did not re-run the Pester gate. Owner decision 1 allows one parallel run, re-run only after a fix, and the executor's run postdates the last code commit. The pytest gate (16486 tests, 0 failures, identical to the baseline) is recorded in `evidence/qa-gates/coverage-delta.2026-11-07T21-55.md`; no Python file changed.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **G-1 (PARTIAL, blocking): SAC-12 checked off against a criterion the delivery does not state; no spec erratum.** SAC-12 requires `consumer-onboarding.md` to state that the python pack, "with Python 3.10 or later", enables the native analyzer. The page states "Python 3.11 or later" (lines 15-19), which matches the merged helper (`FLOOR = (3, 11)`, `.claude/lib/docs/python/run_docs_python_native.py:18`) and the 1031 owner decision of 2026-11-04. The executor recorded the deviation in `evidence/qa-gates/ac-verification.2026-11-07T22-00.md` and checked the criterion off. The spec was not amended: the SAC-12 text, `spec.md` line 149 (Design, consumer-onboarding) and line 324 (contract table, "Python 3.10 floor") still state 3.10, and plan task [P2-T3] still states 3.10. The spec's `## Cross-Child Contract Dependencies` rule says a divergence found in delivery is routed as one plan revision and is not adapted silently. The D-1 finding-code divergence on this branch followed that rule (commit `53ce763d4` added a spec erratum and edited the criterion text); this divergence did not. `acceptance-criteria-tracking` rule 4 says to leave a criterion unchecked when it is not met as written. Required correction: add a `Python floor (erratum, 2026-11-07)` entry to `spec.md` `## Corrections to the Research` citing the 1031 owner decision and the merged `FLOOR`, update SAC-12, line 149 and line 324 to 3.11, and update the [P2-T3] text, in one commit. No page or test change is needed.

### Approved Exceptions

- **Seeded-shuffle and single-process test runs (SAC-24 clause, plan task [P4-T5]):** waived by owner directive of 2026-11-07, decision 1, recorded in `evidence/regression-testing/pester-shuffle.2026-11-07T21-55.md`. Isolation is evidenced instead by the parallel gate and the per-test fresh context.
- **Test-baseline comparison:** owner decision 2; satisfied by the `## Test-baseline comparison` table in `evidence/qa-gates/coverage-delta.2026-11-07T21-55.md` (no new failures in Pester or pytest).

### Removed/Skipped Tests

**None.** All planned tests implemented; the 10 skipped tests in the gate are pre-existing and present in the baseline.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **263362a08** - docs(features): record #1038 Phase 0 bindings and block at P0-T5
2. **53ce763d4** - docs(features): apply the #1038 D-1 finding-code revision to spec and plan
3. **74ad86784** - docs(features): record #1038 Phase 0 bindings P0-T5 to P0-T8
4. **07209f8d0** - docs(features): record #1038 Phase 0 baselines
5. **f0d3ece12** - docs(features): record #1038 Phase 0 baselines
6. **28fcb89b2** - docs(features): check off #1038 Phase 1 tasks P1-T1 to P1-T6
7. **3ded0a143** - docs(engineering): add the documentation-estate onboarding pages (#1038)
8. **4ea6d64d2** - test(docs): add the documentation-estate end-to-end suite (#1038)
9. **24e23678b** - docs(features): record #1038 final format and analyzer gates
10. **bd17a5a10** - docs(features): record #1038 final parallel gates and coverage delta
11. **cb72ab109** - docs(features): record #1038 scans and check off acceptance criteria
12. **f668e4254** - docs(features): record #1038 self-review and complete the plan

### Files Modified

1. **extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md** (NEW) - epic manifest template: 11 children, waves 0/1/2.
2. **extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/README.md** (NEW) - manual-copy usage.
3. **docs/engineering/documentation-estate/*.md** (NEW, 5 pages) - onboarding.
4. **tests/scripts/claude-lib/docs/*.Tests.ps1** (NEW, 3 suites) and **\*.TestSupport.psm1** (NEW, 2 modules).
5. **docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/** (spec, user story, plan MODIFIED; 32 evidence files NEW).

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

The code, tests, toolchain, coverage and evidence locations comply. One documentation-governance gap (G-1) remains: a checked acceptance criterion whose text the delivery does not meet, with no spec erratum.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PARTIAL Summarize & Document (G-1)

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

---

### Metrics Summary

- PASS 19331/19341 tests passing (0 failures; 10 pre-existing skips)
- PASS 41/41 new tests passing
- PASS 95.45% PowerShell line coverage repo-wide, 0.00 change
- PASS File organization: suites beside the existing `.claude/lib/docs` suites
- PASS Format and analyzer clean (reviewer re-run)
- Advisory: end-to-end suite 211 s

---

### Recommendation

**Needs revision**

Apply the spec erratum described in G-1 (documentation-only; no code or test change). The CI-dependent clause of SAC-24 remains for the orchestrator's S9 gate.

---

## Appendix A: Test Inventory

### Complete Test List

1. documentation-estate epic template manifest › ships epic.md and README.md and no epic-status.md
2. documentation-estate epic template manifest › parses the frontmatter within the supported subset
3. documentation-estate epic template manifest › declares the documentation-estate epic and its integration branch
4. documentation-estate epic template manifest › has a valid created_at timestamp
5. documentation-estate epic template manifest › has an intent block that meets the schema rules
6. documentation-estate epic template manifest › has unique integer issue_num values and unique feature_folder values
7. documentation-estate epic template manifest › resolves every depends_on entry to another features entry
8. documentation-estate epic template waves › has no self-edge and no cycle
9. documentation-estate epic template waves › places every foundation child in wave 0
10. documentation-estate epic template waves › places every page-family child in wave 1
11. documentation-estate epic template waves › places the exit-gate child alone in the final wave depending on every page-family child
12. documentation-estate epic template waves › computes waves equal to the Planned Waves list
13. documentation-estate epic template positive controls › fails with EPIC_MANIFEST_CYCLE for a two-node cycle
14. documentation-estate epic template positive controls › fails with EPIC_MANIFEST_UNRESOLVED_DEPENDENCY for an unknown depends_on entry
15. documentation-estate epic template positive controls › fails with EPIC_MANIFEST_DUPLICATE_ISSUE_NUM for a repeated issue_num
16. documentation-estate epic template positive controls › fails with EPIC_MANIFEST_SELF_EDGE for a self-dependency
17. documentation-estate epic template positive controls › fails with EPIC_MANIFEST_UNSUPPORTED for a flow mapping
18. documentation-estate epic template positive controls › states placement, paired fields, the /epic-plan invocation and that no command copies the template
19. documentation-estate onboarding pages › has the five onboarding pages
20. documentation-estate onboarding pages › documents every Get-DocsCommandTable row with a heading and an example
21. documentation-estate onboarding pages › documents the nine named subcommands
22. documentation-estate onboarding pages › documents every docs MCP tool defined in mcp-docs-tool-definitions.ts with a heading and an example
23. documentation-estate onboarding pages › documents exit codes, envelope keys and the envelope schema path
24. documentation-estate onboarding pages › states the MCP tool boundaries
25. documentation-estate onboarding pages › states the PowerShell 7.4 prerequisite
26. documentation-estate onboarding pages › states that the optional python pack enables the native Python analyzer
27. documentation-estate onboarding pages › states that linting is optional and check is the required page gate
28. documentation-estate onboarding pages › names the workflow roles, skills and the integration gate key
29. documentation-estate onboarding pages › fails naming the subcommand that an in-memory command reference omits
30. documentation-estate onboarding neutrality › neutrality › finds no consumer-identifier digest in the template pair or the onboarding pages
31. documentation-estate onboarding neutrality › neutrality › detects a synthetic identifier injected into an in-memory page
32. documentation estate end to end › passes docs-complete at revision R1 after inventory, ledger and generation
33. documentation estate end to end › fails docs-complete at revision R2 with exit code 1
34. documentation estate end to end › reports DOCS_LEDGER_MISSING_DISPOSITION with the new command's element identifier and declaration
35. documentation estate end to end › reports DOCS_STALE_PAGE with the stale page path and the changed command's declaration
36. documentation estate end to end › returns a receipt whose validation_result is fail
37. documentation estate end to end › passes docs-complete at revision R2 after the ledger and page are fixed
38. documentation estate end to end › records analysis_method scanner on every inventory snapshot element in every step
39. documentation estate end to end › records analysis_method scanner on every ledger entry in every step
40. documentation estate end to end › records no InvokeProcess call under -AnalysisMethod scanner
41. documentation estate end to end › fails closed with DOCS_SNAPSHOT_UNPINNED when inventory ran without a revision

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (reviewer re-run, check form, PowerShell 7.6.9):**
```powershell
# Formatting (check form; compares formatted text with committed text)
Invoke-Formatter -ScriptDefinition (Get-Content -LiteralPath <file> -Raw) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Logical line count
@(Get-Content -LiteralPath <file>).Count
```

**For PowerShell (executor gate, inspected, not re-run):**
```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
```

**Repository checks (reviewer):**
```bash
git diff --name-status d395d5140f3822eeef453f2055d4ac539656d629 HEAD
git diff --name-only 4ea6d64d2 HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)
