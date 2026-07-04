# Policy Compliance Audit: separate-version-bump-from-publish (#214)

**Audit Date:** 2026-06-19
**Code Under Test:** PowerShell production and test files, one new GitHub Actions workflow, `.vscode/tasks.json`, two Pester runsettings config files, and the repository `coverage.xml` report. Full list in Section 9.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production, 4 test | 677 executed (686 total, 9 disabled) | PASS 677 pass, 0 fail | 96.83% lines (hook-only scope) | 94.85% lines (extended scope) | All four scripts >= 90% line |
| YAML (GitHub Actions) | 1 file (new `publish-extension.yml`) | N/A (actionlint + green run) | PASS | N/A (no coverage instrument) | N/A | N/A |
| JSON (`.vscode/tasks.json`) | 1 file | N/A | PASS (valid JSON; task wiring) | N/A (config) | N/A | N/A |

**Note:** TypeScript, Python, and C# have zero changed code files in the branch diff. Their coverage verdicts are `N/A — no changed files on the branch`, which is the only acceptable use of `N/A` per the scope invariant.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `docs/features/active/separate-version-bump-from-publish-214/evidence/baseline/poshqc-test.baseline.2026-06-19T21-18.md`
- PowerShell post-change coverage artifact: `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/poshqc-test.final.2026-06-19T21-18.md`
- PowerShell per-file JaCoCo report: `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/coverage-214-perfile-jacoco.2026-06-19T21-18.xml`
- Per-language comparison summary: `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/coverage-comparison.2026-06-19T21-18.md`
- TypeScript / Python / C# coverage artifacts: `N/A — no changed files on the branch`

**Non-negotiable verdict rule:** Numeric baseline and post-change coverage metrics are present for PowerShell (the only language with changed code files); per-file new/changed-code coverage is recorded for all four scripts.

**Fail-closed rule:** All required baseline, QA, and coverage-comparison artifacts exist and were inspected. No required artifact is missing.

**Evidence rule:** All figures below are transcribed from inspected feature-folder artifacts and direct diff/file inspection; none are synthesized.

---

## Executive Summary

This branch separates the release pipeline into a PR-gated version-bump phase and a post-merge, tag-triggered CI publish phase (issue #214). The PowerShell publish/release scripts lose their in-place `npm version`, `vsce publish`, and `git tag` side effects; a new tag-triggered workflow (`publish-extension.yml`) performs the Marketplace upload; a new post-merge tag-push script (`Invoke-ReleaseTagPush.ps1`) isolates the single remaining tag push; and `.vscode/tasks.json` is retargeted to the PR-gated/CI-published model.

The only language with changed code files is PowerShell. The PowerShell toolchain (format -> analyze -> test via PoshQC MCP tools) is clean: format EXIT 0, analyze EXIT 0 with zero findings, test EXIT 0 with 677 passing and 0 failing. Per-file line coverage for the four changed/new scripts is >= 90% each; overall measured-scope line coverage is 94.85%. The new workflow passes `actionlint` and has a green branch-head run (run 27857355771, conclusion success), satisfying `modified-workflow-needs-green-run`.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`

**Language-specific policies evaluated:**
- N/A `python-code-change` + `python-unit-test` — no Python changed files
- PASS `powershell-code-change` + `powershell-unit-test`
- N/A TypeScript / C# — no changed files
- PASS GitHub Actions — `ci-workflows.md` reviewed (see Section 7)

**Temporary artifacts cleanup:**
- PASS No temporary/one-time scripts remain; all changed scripts are permanent release tooling with tests.
- PASS All new scripts are tested and toolchain-clean.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Each Pester `It` uses `BeforeAll`/`BeforeEach` mock registration scoped to its `Context`; no shared mutable state across tests. |
| **Isolation** | PASS | Tests target one guarded function or one pure helper per `It` (token guard, manifest read, branch-name builder, tag-name builder, PR-open seam). |
| **Fast Execution** | PASS | 677 tests execute in the PoshQC test run (EXIT 0); no sleeps, retries, or timing hacks. Evidence: `poshqc-test.final.2026-06-19T21-18.md`. |
| **Determinism** | PASS | External executables are reached only through wrapper seams (`Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-GhExe`/`Invoke-VsceExe`/`Get-VsceListing`); tests mock the seams, not `git`/`gh`/`npm`/`vsce`. No network or live-executable dependency. |
| **Readability & Maintainability** | PASS | `Describe`/`Context`/`It` structure with descriptive scenario names; one behavior per `It`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline 96.83% lines (275/284), hook-only scope. Command: `mcp__drm-copilot__run_poshqc_test`. Artifact: `evidence/baseline/poshqc-test.baseline.2026-06-19T21-18.md`. |
| **No Coverage Regression** | PASS | Overall moved 96.83% -> 94.85% solely due to denominator growth (the four production scripts were added to the measured scope). The five pre-existing hook files retain baseline per-file coverage; no previously-measured line lost coverage. Evidence: `coverage-comparison.2026-06-19T21-18.md`. |
| **New Code Coverage** | PASS | Per-file line coverage: Publish-DrmCopilotExtension.ps1 93.97%, Invoke-FullRelease.ps1 91.67%, Invoke-MarketplacePublish.ps1 90.32%, Invoke-ReleaseTagPush.ps1 95.83%. Each exceeds the uniform >= 85% threshold (and >= 90%). |
| **Comprehensive Coverage** | PASS | Guarded functions, pure helpers, and entry-point paths are exercised; residual uncovered lines are the single-line wrapper-seam bodies and host-bound entry wiring (documented in `coverage-comparison.2026-06-19T21-18.md`). |
| **Positive Flows** | PASS | Confirmed-token bump + `gh pr create`, both-tag derivation/push, `-DryRun`/`-Package` modes. |
| **Negative Flows** | PASS | Non-`yes` token rejected (exit 2); missing manifest reported (exit 1); dirty working tree blocks (exit 1). |
| **Edge Cases** | PASS | Case-sensitive token comparison (`-cne 'yes'`); single-manifest vs both-manifest bump paths. |
| **Error Handling** | PASS | git/npm/gh/vsce seam-failure branches assert a stderr report and the correct non-zero exit code. |
| **Concurrency** | N/A | No concurrent behavior in scope. |
| **State Transitions** | N/A | Scripts are single-shot tasks; no stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline 96.83% lines (hook-only scope) -> Post-change 94.85% lines (extended scope). Change is denominator growth, not regression. New/changed-code coverage: all four scripts >= 90% line. Disposition: PASS. Evidence: `evidence/qa-gates/coverage-comparison.2026-06-19T21-18.md`, `evidence/qa-gates/coverage-214-perfile-jacoco.2026-06-19T21-18.xml`.
- TypeScript: N/A - no changed files on the branch.
- Python: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Tests assert on returned exit codes and on `Write-StderrLine` invocation with the expected message text. |
| **Arrange-Act-Assert Pattern** | PASS | Mock setup (Arrange), guarded-function invocation (Act), exit-code / Assert-MockCalled assertions (Assert). |
| **Document Intent** | PASS | `It` names describe scenario and expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, DB, or live executable; wrapper seams isolate git/npm/gh/vsce. |
| **Use Mocks/Stubs** | PASS | Mocks target wrapper seams (`Invoke-GitExe`, `Invoke-NpmExe`, `Invoke-GhExe`, `Get-NpmVersion`, `Test-Path`, `Get-Content`) with param signatures matching production. No direct `Mock git`/`gh`/`npm`/`vsce`. |
| **Environment Stability** | PASS | No temporary file creation (grep for `New-TemporaryFile`/`$env:TEMP`/`GetTemp*` in the four test files returned zero matches). RepoRoot is passed explicitly; no ambient working-directory dependence. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit plus `code-review.2026-06-19T22-30.md` and `feature-audit.2026-06-19T22-30.md` constitute the required review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Objective stated in `spec.md` (separate PR-gated bump from tag-triggered publish); issue #214. |
| **Read existing change plans** | PASS | `plan.2026-06-19T21-18.md` present and consistent with the diff. |
| **Document the plan** | PASS | Plan and spec recorded in the feature folder; commits reference #214. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Each script is a small guarded function plus single-line wrapper seams; no deep indirection or runner framework. |
| **Reusability** | PASS | Shared seam pattern (`Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-GhExe`) and pure helpers (`Get-NpmVersion`, `Get-ReleaseBranchName`, tag-name builders) reused across scripts. |
| **Extensibility** | PASS | Guarded functions accept `RepoRoot` explicitly; tag/branch builders are pure and parameterized. |
| **Separation of concerns** | PASS | Pure logic (manifest read, name derivation) is separated from I/O (the wrapper seams) and from the host-bound entry point. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One release responsibility per script (full-release PR opener, extension-only PR opener, tag push, local package/dry-run). |
| **Under 500 lines** | PASS | Publish 346, Invoke-FullRelease 264, Invoke-MarketplacePublish 254, Invoke-ReleaseTagPush 212; tests 293/322/278/246. All under 500. |
| **Public vs internal** | PASS | Entry point gated by `if ($MyInvocation.InvocationName -ne '.')`; functions dot-sourced for tests. |
| **No circular dependencies** | PASS | Scripts are standalone; no cross-script imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Approved verbs and descriptive nouns (`Invoke-ReleaseTagPushGuarded`, `Get-ExtensionTagName`). |
| **Docs/docstrings** | PASS | Comment-based help (`.SYNOPSIS`/`.DESCRIPTION`/`.PARAMETER`/`.EXAMPLE`) present on every script and function. |
| **Comment why, not what** | PASS | Comments explain step rationale (e.g., why `--no-git-tag-version`, why update main before tagging). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `mcp__drm-copilot__run_poshqc_format` EXIT 0. Artifact: `poshqc-format.final.2026-06-19T21-18.md`. |
| **2. Linting** | PASS | `mcp__drm-copilot__run_poshqc_analyze` EXIT 0, zero findings. Artifact: `poshqc-analyze.final.2026-06-19T21-18.md`. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | PASS | `mcp__drm-copilot__run_poshqc_test` EXIT 0, 677 pass / 0 fail. Artifact: `poshqc-test.final.2026-06-19T21-18.md`. |
| **Full toolchain loop** | PASS | One PSUseBOMForUnicodeEncodedFile finding (em-dash) was remediated and the loop restarted from format; final pass clean. |
| **Explicit reporting** | PASS | Commands and results recorded in the qa-gates evidence artifacts. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Spec, plan, and commit messages describe the bump/publish separation. |
| **Design choices explained** | PASS | Spec Invariants/Scope/Risks sections explain the seam pattern and CI gating. |
| **Update supporting documents** | PASS | Two runbooks authored; `tasks.json` detail/labels updated. |
| **Provide next steps** | PASS | Post-merge tag-push task and `VSCE_PAT` provisioning runbook describe the remaining manual steps. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | `mcp__drm-copilot__run_poshqc_format` EXIT 0. |
| **Linting with PSScriptAnalyzer** | PASS | `mcp__drm-copilot__run_poshqc_analyze` EXIT 0, zero findings. |
| **Fix all findings** | PASS | The single PSUseBOMForUnicodeEncodedFile finding was fixed (em-dash -> ASCII hyphen). |
| **PowerShell 7+ compatible** | PASS | `Set-StrictMode -Version Latest`, advanced functions, no 5.1-incompatible constructs observed. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | All functions use `[CmdletBinding()]` and typed `[OutputType]`. |
| **Parameter validation** | PASS | `[Parameter(Mandatory = $true)]`, `[ValidateSet('DryRun','Package')]`, `[string[]]` typing on seam args. |
| **Avoid global state** | PASS | State passed explicitly via parameters; no script-scoped mutable globals. |
| **Error handling** | PASS | `$ErrorActionPreference='Stop'` where appropriate; `throw` on invariant violation; explicit non-zero returns and `Write-StderrLine` on guard/seam failure; no silent catch-all. |

Note on ShouldProcess: the state-changing scripts gate on an explicit `-ConfirmToken` (literal `yes`, case-sensitive) rather than `SupportsShouldProcess`. This is the established repository pattern for these release tasks and is invariant-preserving per `spec.md`. Recorded as Info in the code review, not a finding.

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | All four production scripts 212-346 lines. |
| **Approved verbs** | PASS | `Invoke-`, `Get-`, `Test-`, `Write-` are approved; analyzer EXIT 0 confirms no PSUseApprovedVerbs finding. |
| **Comment why** | PASS | Step comments explain rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | EXIT 0. |
| **Step 2: Analyze** | PASS | EXIT 0, zero findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | EXIT 0, 677 pass / 0 fail. |
| **Rerun loop if needed** | PASS | Restarted once after the BOM/em-dash fix; final pass clean. |

### Section 3D: JSON / Workflow Configuration

| Requirement | Status | Evidence |
|------------|--------|----------|
| **`.vscode/tasks.json` valid and retargeted** | PASS | Diff retargets task labels/detail to the PR-gated/CI-published model and adds the `ReleaseTagPushConfirm` input and the post-merge tag-push task. |
| **Workflow lint (actionlint)** | PASS | `actionlint .github/workflows/publish-extension.yml` EXIT 0, zero findings. Artifact: `actionlint.publish-extension.2026-06-19T21-18.md`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe`/`Context`/`It`, `BeforeAll`/`BeforeEach`, modern `Should` and `Mock -CommandName` syntax. |
| **Use PoshQC Configuration** | PASS | Run via `mcp__drm-copilot__run_poshqc_test` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; coverage scope additively extended to include the four scripts. |
| **PowerShell 7+ Compatible** | PASS | No version-specific incompatibilities observed. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | One behavior per `It`. |
| **Test Behavior Over Implementation** | PASS | Assertions verify exit codes, seam-call arguments, and stderr reporting. |
| **Mocking Used Sparingly** | PASS | Mocks limited to wrapper seams and narrow filesystem helpers; no direct executable mocks. |
| **Organization** | PASS | Test files mirror production paths: `tests/scripts/dev-tools/*.Tests.ps1` and `tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | PASS | All test files named `*.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | Present in all four files. |
| **Logical Grouping** | PASS | Contexts group by scenario (guard, bump+PR, dirty-tree, missing-manifest, seam-failure). |
| **Docstrings/Comments** | PASS | Self-documenting `It` names. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | `mcp__drm-copilot__run_poshqc_test` EXIT 0. |
| **No Alternative Test Runners** | PASS | Only Pester via PoshQC. |

---

## 5. Test Coverage Detail

Per-file line coverage from `coverage-214-perfile-jacoco.2026-06-19T21-18.xml` (transcribed from `coverage-comparison.2026-06-19T21-18.md`):

| File | Covered | Missed | Total | Line % | >= 85% |
|---|---|---|---|---|---|
| scripts/powershell/Publish-DrmCopilotExtension.ps1 | 109 | 7 | 116 | 93.97% | PASS |
| scripts/dev-tools/Invoke-FullRelease.ps1 | 66 | 6 | 72 | 91.67% | PASS |
| scripts/dev-tools/Invoke-MarketplacePublish.ps1 | 56 | 6 | 62 | 90.32% | PASS |
| scripts/dev-tools/Invoke-ReleaseTagPush.ps1 | 46 | 2 | 48 | 95.83% | PASS |

**Not covered:** Single-line external-executable wrapper-seam bodies (`Invoke-GitExe`, `Invoke-NpmExe`, `Invoke-GhExe`, `Invoke-VsceExe`, `Get-VsceListing`) and a small number of host-bound entry-point statements in `Publish-DrmCopilotExtension.ps1` (artifacts/vsix `New-Item`, vsce-not-on-PATH `Write-Error`). Exercising these would require mocking the real executables, which `.claude/rules/powershell.md` prohibits. This is the irreducible host-bound wiring described by `general-unit-test.md`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 686 (677 executed, 9 disabled) | PASS |
| Tests Passed | 677 (100% of executed) | PASS |
| Tests Failed | 0 | PASS |
| Functions/Classes Tested | All guarded functions + pure helpers + entry-point paths | PASS |
| Code Coverage | 94.85% lines overall measured scope; instruction proxy 93.78% | PASS |

Branch coverage: the repository Pester coverage engine emits only INSTRUCTION/LINE/METHOD/CLASS counters (no BRANCH counter). Instruction coverage (93.78%) is recorded as the closest available proxy and exceeds the 75% branch threshold. This is a tooling characteristic, not a regression introduced by this feature. Recorded in `poshqc-test.final.2026-06-19T21-18.md`.

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | EXIT 0 | PASS |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | EXIT 0, 0 findings | PASS |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` | EXIT 0, 677 pass / 0 fail | PASS |

**For GitHub Actions:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| actionlint | `actionlint .github/workflows/publish-extension.yml` | EXIT 0, 0 findings | PASS |
| Green branch-head run | `gh run view 27857355771` | conclusion success; publish step skipped on `pull_request` | PASS |

**`ci-workflows.md` (deliberately-failing nested `pwsh` command rule):** N/A. `publish-extension.yml` contains no `pwsh` step with an intentionally-failing nested command; all `run:` steps are `npm`/`npx` invocations whose exit codes are the intended step result.

**`benchmark-baselines.md`:** N/A. No `scripts/benchmarks/**` change and no benchmark baseline in the diff.

**Notes:** The two `pester.runsettings.psd1` changes are additive coverage-scope extensions (adding the four scripts to `CodeCoverage.Path`; the five pre-existing hook entries retained). The root `coverage.xml` is the regenerated Pester JaCoCo report for this feature's test run.

---

## 8. Gaps and Exceptions

### Identified Gaps
**None.** All policy requirements for the changed languages are met. Branch coverage is reported via the instruction-coverage proxy because the repository coverage engine emits no BRANCH counter; this is a documented tooling characteristic, not a gap in this feature.

### Approved Exceptions
- Two human-interaction `exception` requirements (one-time `VSCE_PAT` provisioning; release-PR merge approval) are recorded in `artifacts/orchestration/orchestrator-state.json` under `human_interaction.requirements[]`, each with a non-empty `runbook_path`, consistent with `orchestrator-state.md`. Runbooks present at `docs/features/active/separate-version-bump-from-publish-214/runbooks/`.

### Removed/Skipped Tests
**None introduced by this feature.** The 9 disabled tests are pre-existing and unchanged from baseline.

---

## 9. Summary of Changes

### Commits in This PR/Branch (range b70045e..b3f55e6)

1. **829e44c** - refactor(release): separate version-bump PR from tag-triggered CI publish (#214)
2. **52ca3d6** - ci(release): add path-filtered pull_request trigger to publish-extension (#214)
3. **b3f55e6** - docs(214): record Phase 5 workflow validation evidence (actionlint + green run)

### Files Modified (production / config / workflow; evidence and docs omitted here)

1. **scripts/powershell/Publish-DrmCopilotExtension.ps1** (MODIFIED) - removed `npm version`/`vsce publish`/`git tag`; retained `-DryRun`/`-Package`, manifest pre-flight, and `vsce ls` forbidden-file scan.
2. **scripts/dev-tools/Invoke-FullRelease.ps1** (MODIFIED) - rewritten as both-manifest release-PR opener (`gh pr create`); no publish, no tag.
3. **scripts/dev-tools/Invoke-MarketplacePublish.ps1** (MODIFIED) - rewritten as extension-only release-PR opener; no publish, no tag.
4. **scripts/dev-tools/Invoke-ReleaseTagPush.ps1** (NEW) - confirmation-gated post-merge tag push (`v*`, `mcp-server-v*`); the sole tag-pushing script.
5. **.github/workflows/publish-extension.yml** (NEW) - tag-triggered + `workflow_dispatch` + path-filtered `pull_request`; publish step gated `if: startsWith(github.ref, 'refs/tags/v')`.
6. **.vscode/tasks.json** (MODIFIED) - retargeted release task labels/detail; added `ReleaseTagPushConfirm` input and post-merge tag-push task.
7. **scripts/powershell/PoshQC/settings/pester.runsettings.psd1** and **extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1** (MODIFIED) - additive coverage-scope extension.
8. **coverage.xml** (MODIFIED) - regenerated Pester JaCoCo report.
9. **tests/scripts/...** (4 files, NEW/MODIFIED) - Pester suites mirroring the four scripts.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policies for the changed languages (PowerShell, GitHub Actions, JSON config) are satisfied with inspected evidence. PowerShell toolchain is clean; per-file and overall coverage meet the uniform thresholds; the new workflow has a green branch-head run with the publish step correctly gated; evidence locations are canonical (validator EXIT 0); no evidence-location or scope violations were found.

**Fail-closed reminder:** No required baseline, QA, coverage, or coverage-comparison artifact is missing; PASS is supported by evidence.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)
**For PowerShell:**
- PASS Tooling & Baseline
- PASS Design & Safety
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

- PASS 677/677 executed tests passing (100%)
- PASS All four changed/new scripts >= 90% line coverage
- PASS 94.85% overall line coverage; 93.78% instruction proxy for branch
- PASS All production and test files under 500 lines
- PASS All PowerShell quality checks clean (format/analyze/test EXIT 0)
- PASS actionlint clean and green branch-head workflow run present

---

### Recommendation

**Ready for merge.** No blocking or partial findings. The `modified-workflow-needs-green-run` policy is satisfied. Remediation is not required.

---

## Rejected Scope Narrowing

None. The caller prompt set scope to the full branch diff against `main` (merge-base `b70045e...`) and explicitly directed application of every applicable toolchain and coverage check for each language with changed files. No instruction attempted to narrow scope to a plan subset, a file subset, or to mark any changed-file language as out of scope. The audit was performed against the full feature-vs-base diff.

---

## Evidence Location Compliance

`python scripts/dev_tools/validate_evidence_locations.py --root .` returned EXIT 0 (no violations). A diff scan for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` returned zero matches. All feature evidence is under the canonical `docs/features/active/separate-version-bump-from-publish-214/evidence/<kind>/` path. No FAIL-level evidence-location findings.

---

## Appendix A: Test Inventory

Test suites (Pester) covering the changed scripts:
- `tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1` (293 lines) - dry-run/package modes, manifest validation (missing/empty-required/missing-README), build path, forbidden-file warning, vsce-package-failure, entry-point dry-run.
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (322 lines) - token guard, both-manifest bump + `gh pr create`, dirty-tree block, missing-manifest reporting, seam failures, real `Get-NpmVersion`/`Write-StderrLine`, entry-point.
- `tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1` (278 lines) - token guard, single-manifest bump + `gh pr create`, dirty-tree block, missing-manifest reporting, seam failures, real helpers, entry-point.
- `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` (246 lines) - token guard (case-sensitive), both-tag derivation/push, missing-manifest reporting (ext + mcp), pull/tag-create/tag-push seam failures, real helpers and tag-name builders, entry-point.

Aggregate run: 686 tests (677 executed, 9 pre-existing disabled), 0 failures.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```text
# Formatting
mcp__drm-copilot__run_poshqc_format   (workspace_root = repo root)

# Linting
mcp__drm-copilot__run_poshqc_analyze  (workspace_root = repo root)

# Testing + coverage
mcp__drm-copilot__run_poshqc_test     (workspace_root = repo root)
# coverage scope: scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

**For GitHub Actions:**
```text
actionlint .github/workflows/publish-extension.yml
gh run view 27857355771
```

**Review-side verification commands:**
```bash
git diff --name-status b70045e02d0d3b6290e9ed9799d0dec5ed09425b..HEAD
git log --oneline 52ca3d61..b3f55e64        # confirm post-green-run commit is docs-only
python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-06-19
**Policy Version:** Current (as of audit date)
