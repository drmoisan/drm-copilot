# Policy Compliance Audit: SubagentStop artifact-gate review notes (#929)

---

**Audit Date:** 2026-10-16
**Audit Type:** Initial feature review (feature-vs-base)
**Branch:** `bug/subagentstop-artifact-gates-review-notes-929` (HEAD `af34e23e4ccc91ce2c3f8e95324958a1eb2d41c8`, pushed)
**Base:** `origin/main` (merge base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`)
**Work Mode:** `full-bug`
**Code Under Test:** 94 changed files (6642 insertions, 132 deletions). Outside the feature folder: two production PowerShell files (`.claude/hooks/validate-task-researcher-output.ps1` and its bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`, NB-5 alias removal, 3 insertions and 4 deletions each), nine PowerShell test-tree files under `tests/scripts/claude-hooks/` (two new: `SubagentStopEnvelope.Helpers.ps1`, `validate-discovery-artifact-gate.Dispatch.Tests.ps1`), and one cross-folder Markdown edit (`docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md`, two clarification lines). The remaining files are feature-folder documentation and evidence.

**Total blocking findings: 1.**

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 11 files (2 production, 9 test-tree) | 5358 (self-hosted PoshQC run over `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime`) | ✅ 5358 passed, 0 failed (executor evidence `final-pester-selfhosted.2026-10-16T05-12.md`, `final-pester-junit.2026-10-16T05-12.md`) | Changed file: 101/103 lines = 98.06%; repo-wide: no full-suite figure recorded | Changed file: 100/102 lines = 98.04%; repo-wide from the present artifact: 8623/18115 lines = 47.60% (scoped run, see PA-1) | FAIL: changed-file coverage passes (98.04%, missed 2 -> 2, changed lines 244, 248, 265 each `ci="1"`), but repo-wide PowerShell line coverage is not demonstrated at >= 85% by any full-suite artifact (PA-1). No branch threshold applies to PowerShell. |
| Python | 0 files | N/A | N/A (reviewer reran the two AC-12 contract modules: 20 passed) | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/baseline/coverage-counters-baseline.2026-10-16T01-06.md
- PowerShell post-change coverage artifact: docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/coverage-counters-final.2026-10-16T05-12.md
- PowerShell coverage data file inspected by the reviewer: artifacts/pester/powershell-coverage.xml (written 2026-10-16 05:10 UTC by the scoped final run; SHA-256 recorded in the final counters evidence)
- Python baseline coverage artifact: N/A (no Python file changed on the branch)
- Python post-change coverage artifact: N/A (no Python file changed on the branch)
- Per-language comparison summary: section 1.2.1 of this audit and docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/coverage-comparison.2026-10-16T05-13.md

---

## Executive Summary

The branch resolves E3 review notes NB-1 to NB-5 and NB-7 to NB-11 with test additions, one shared test helper, one behavior-preserving production edit (removal of the `$agentOutput` alias), and two dated clarification lines in the E3 spec. The reviewer verified the production diff hunk by hunk: the alias assignment is deleted and its three read sites now read `$assistantMessage`; the two files remain byte-identical (`cmp`), and no message string, signature, or dependency-decision statement changed.

The reviewer reran or re-derived: `git grep` for `New-SubagentStopEnvelopeJson` and the old suppression justification (no match, exit 1), `git diff --name-only origin/main...HEAD -- .claude .codex extensions scripts` (only the two NB-5 paths), mirror parity, the R3 pattern string in both validators, line counts of all touched PowerShell files (maximum 420), the AC-12 pytest modules (20 passed), `validate_evidence_locations.py --root .` (exit 0), and a per-package parse of `artifacts/pester/powershell-coverage.xml`.

Concurrent issue #928 was evaluated rather than assumed. Its current remote head (`37545a357`) edits `.claude/hooks/validate-task-researcher-output.ps1` only in the docstring (line 23) and the script tail (lines 289-290), adds no `New-SubagentStopEnvelopeJson` call site, and does not edit any of the seven converted suites. A read-only `git merge-tree --write-tree af34e23e4 37545a357` completes without conflict.

One blocking finding: the only PowerShell coverage artifact is from a run scoped to two test folders, so it reports repo-wide PowerShell line coverage of 47.60%; no full-suite figure is recorded (PA-1). AC-26 and AC-27 are pending CI (PA-2, PA-3, non-blocking).

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ⚠️ `.claude/rules/general-unit-test.md` (repo-wide coverage evidence gap, PA-1)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on base; `.claude/hooks` is T3, `extensions/drm-copilot` is T3, the `tests/` tree falls under the root `.` entry, T4)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md` (PowerShell code change and unit test)
- N/A Python: no changed files.
- N/A TypeScript: no changed files.
- N/A C#: no changed files.
- N/A GitHub Actions: no changed workflow files.

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed. `git diff --name-only origin/main...HEAD` lists no file under `artifacts/` or `SCRATCH/`.
- ✅ The reviewer's coverage parse script was written to the session scratchpad only. The reviewer regenerated `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (gitignored) because they were absent.

---

## Rejected Scope Narrowing

None detected. The caller fixed the diff at `git diff origin/main...HEAD`, which matches the resolved merge base `5bc97774b`. The caller description of the change set ("test-focused fixes ... and extraction of a shared ... helper") is descriptive and did not exclude any file or language. The caller statement that AC-26 and AC-27 are CI-dependent matches spec.md lines 248-249 and the CI-dependent criterion protocol. The caller note that "PowerShell evidence uses PoshQC MCP results plus CI" was not treated as a waiver of coverage verification; PowerShell coverage is evaluated below and receives an explicit FAIL for the repo-wide figure.

## Evidence Location Compliance

- `python -I scripts/dev_tools/validate_evidence_locations.py --root .` (reviewer rerun at `af34e23e4`): exit 0, no output.
- `git diff --name-only origin/main...HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 77 evidence files sit under `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/{baseline,regression-testing,qa-gates,other}/`.
- Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entries were needed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|-----------|--------|----------|
| **Independence** | ✅ PASS | New cases build their inputs inline; the NB-11 case resets `$script:HookDependencyFailures` in `finally` (`tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:342-344`). |
| **Isolation** | ✅ PASS | Each `It` targets one function: `Test-NumericDerivationEvidence` (R3 rows), `Find-DiscoveryArtifactReference` (R4 rows), `Invoke-DiscoveryArtifactGateValidation` (dispatch, gate), `Invoke-TaskResearcherOutputValidation` (NB-11). |
| **Fast Execution** | ✅ PASS | All new cases are in process with mocks; no new child process (spec "Performance constraints"). |
| **Determinism** | ✅ PASS | No clock, sleep, randomness, network, or file write in the added lines (reviewer grep of `+` lines for `TestDrive`, `TemporaryFile`, `GetTempFileName`, `Set-Content`, `Out-File`, `New-Item`, `Start-Sleep`, `Get-Date`: no match). |
| **Readability** | ✅ PASS | Descriptive `It` names, Arrange/Act/Assert comments, `-Because` messages on string-prefix assertions. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Repo-wide line coverage >= 85% (PowerShell)** | ❌ FAIL | The only artifact, `artifacts/pester/powershell-coverage.xml`, reports report-level `LINE missed="9492" covered="8623"` = 47.60%. The run was scoped to `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime` while the coverage roots (`config/poshqc-coverage.json`) include `scripts/` and `.claude/lib`, so packages such as `scripts/dev-tools` (0/1745) and `.claude/lib/blast-radius` (0/845) report 0%. No full-suite figure is recorded. See PA-1. |
| **Changed-file line coverage >= 85%** | ✅ PASS | `.claude/hooks/validate-task-researcher-output.ps1`: 100/102 = 98.04% (final), 101/103 = 98.06% (baseline). |
| **No regression on changed lines** | ✅ PASS | Final `missed` 2 equals baseline `missed` 2; changed lines 244, 248, 265 each `ci="1"` (`coverage-counters-final.2026-10-16T05-12.md`). The covered count fell by one because the deleted alias line was itself covered. |
| **Branch coverage** | N/A | PowerShell (Pester) measures no branch figure; no branch threshold applies. |
| **Coverage exclusions** | ✅ PASS | `config/poshqc-coverage.json` unchanged by the branch; no `exclude` entry added. |
| **Scenario completeness** | ✅ PASS | Positive (accept rows, dispatch success), negative (reject rows, first-failure block), edge (word-boundary rejections, upper case, trim-only tokens, duplicated references), error handling (NB-11 dependency decision). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 98.06% lines -> Post-change: 98.04% lines (changed file `.claude/hooks/validate-task-researcher-output.ps1`). Change: -0.02 percentage points from deleting one covered line; `missed` unchanged at 2. New/changed-code coverage: PASS for the changed production file. Repo-wide: FAIL against the governing 85% line threshold because the only artifact is a scoped run (47.60%); the `.claude/hooks` package in that artifact is 5517/5659 = 97.49%. Root `CLAUDE.md` states no coverage threshold, so the 85% default governs. Disposition: FAIL (PA-1). Evidence: docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/coverage-comparison.2026-10-16T05-13.md, artifacts/pester/powershell-coverage.xml.
- The bundle mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` is outside the configured coverage roots. It is text-identical to the measured source (verified by `cmp` and by `test_push_down_claude_resource_contracts.py`). This is the pre-existing repository configuration, no `exclude` entry is involved, and it is not recorded as a finding.
- Python, TypeScript, C#: no changed files. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | String-prefix assertions carry `-Because $result.Message` or `-Because $result.Reason` (`validate-discovery-artifact-gate.Dispatch.Tests.ps1:60`, `validate-task-researcher-output.Coverage.Tests.ps1:346-348`). |
| **Arrange-Act-Assert** | ✅ PASS | Markers present in every new `It`. |
| **Test File Location** | ✅ PASS | All new and edited test files are under `tests/scripts/claude-hooks/`, mirroring `.claude/hooks/`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No external services** | ✅ PASS | `Invoke-DiscoveryValidatorExe` is mocked in every new dispatch and gate case. |
| **No temporary files** | ✅ PASS | Reviewer grep (section 1.1); the helper's comment-help states it writes no file. |
| **No mutable global state** | ✅ PASS | The NB-11 case restores `$script:HookDependencyFailures`; no environment variable is set by a new case. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policy audit produced** | ✅ PASS | This file. |
| **AC check-off reported** | ✅ PASS | See feature-audit.2026-10-16T05-25.md. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policy reading recorded** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-16T00-21.md`. |
| **Baseline captured** | ✅ PASS | 16 baseline files under `evidence/baseline/`, including coverage counters, PoshQC format/analyze/test, and mirror parity. |

### 2.2 Design Principles

| Principle | Status | Evidence |
|-----------|--------|----------|
| **Simplicity** | ✅ PASS | NB-5 removes one redundant local; the helper is a single 35-line function. |
| **Reusability** | ✅ PASS | Seven copies of the envelope builder replaced by one dot-sourced helper (NB-4). One inline JSON literal remains in the NB-11 case (CR-1, non-blocking). |
| **Extensibility** | ✅ PASS | `-AgentType` parameter with a default keeps every prior call shape valid. |
| **Separation of concerns** | ✅ PASS | Test support code lives in a `.Helpers.ps1` file that is not a test container. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **500-line limit** | ✅ PASS | Maximum 420 lines (`validate-discovery-artifact-gate.Tests.ps1`); production hook 289 lines (reviewer `wc -l`; `final-line-counts.2026-10-16T05-15.md`). |
| **Bundle mirror parity** | ✅ PASS | `cmp` reports the two hook copies identical; pytest parity contract passes. |
| **Production scope** | ✅ PASS | Only the two NB-5 paths changed under `.claude`, `.codex`, `extensions`, `scripts`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Approved verb** | ✅ PASS | `ConvertTo-SubagentStopEnvelopeJson` uses an approved verb and needs no `PSUseShouldProcessForStateChangingFunctions` suppression. |
| **Comment-help** | ✅ PASS | Helper file and function carry `.SYNOPSIS` and `.DESCRIPTION`; the dispatch suite header states why it is a sibling container. |
| **Characterization comments** | ✅ PASS | NB-2 rows each carry a comment citing E3 spec Risk 5a. |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|-------|--------|----------|
| Format | ✅ PASS | `final-format.2026-10-16T04-26.md`: MCP `ok: true`; porcelain unchanged before and after. |
| Lint | ✅ PASS | `final-analyze.2026-10-16T04-31.md`: MCP `ok: true`; per-file PSScriptAnalyzer `TOTAL_FINDINGS=0` over all 11 PowerShell files. |
| Type check | N/A | Not applicable to PowerShell. |
| Architecture | N/A | No architecture-boundary tool applies to PowerShell hooks. |
| Unit tests | ✅ PASS | `final-pester-selfhosted.2026-10-16T05-12.md` (5358 passed, 0 failed); `final-registration-suites.2026-10-16T05-13.md` (792 passed, 0 failed); `final-poshqc-test-mcp.2026-10-16T04-52.md` (MCP `ok: true`). |
| Contract | ✅ PASS | AC-12 pytest modules: 20 passed (executor evidence and reviewer rerun). |
| Integration | Pending CI | `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` run on the PR head (AC-26, AC-27). |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Decisions recorded** | ✅ PASS | spec.md records NB-2, NB-10, NB-11 decisions and the NB-7/NB-8 resolutions (lines 67-89, 138-142). |
| **Concurrent-item sequencing recorded** | ✅ PASS | `evidence/other/issue-928-sequencing.2026-10-16T04-08.md`; reviewer re-checked against #928 head `37545a357` (clean trial merge). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **`#Requires -Version 7.0`** | ✅ PASS | Present in both new files. |
| **`[CmdletBinding()]` and `[OutputType()]`** | ✅ PASS | Helper function declares both. |
| **No new suppressions** | ✅ PASS | Seven `SuppressMessageAttribute` lines removed; none added (`grep -c SuppressMessageAttribute` on the helper = 0). |
| **PSScriptAnalyzer clean** | ✅ PASS | `TOTAL_FINDINGS=0`. |
| **Behavior preserved** | ✅ PASS | NB-5 hunk replaces three reads of `$agentOutput` with `$assistantMessage`, the value it aliased. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester 5** | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` in the new suite. |
| **Mocks via `Mock` / `Should -Invoke`** | ✅ PASS | Dispatch and gate cases assert exact invocation counts with `-ParameterFilter`. |
| **Empty-array assertions** | ✅ PASS | NB-3 cases wrap calls in `@( )` and use `Should -HaveCount 0`. |
| **Coverage expectation** | ❌ FAIL | Repo-wide figure not evidenced by a full-suite run (PA-1). Changed-file coverage passes. |
| **Property-based tests** | N/A | Tiers T3 and T4; property tests are required only for T1/T2. |

---

## 5. Test Coverage Detail

### `.claude/hooks/validate-task-researcher-output.ps1`

| Line | Content | Coverage |
|------|---------|----------|
| 244 | `if ([string]::IsNullOrWhiteSpace($assistantMessage)) {` | ✅ `ci="1"` |
| 248 | `$researchPath = Get-ResearchPathFromOutput -AgentOutput $assistantMessage` | ✅ `ci="1"` |
| 265 | `$feasibilityResult = Test-AutomationFeasibilitySection ... -AgentOutput $assistantMessage` | ✅ `ci="1"` |
| 240 | `if ($null -ne $dependencyDecision) { return $dependencyDecision }` | Reached in process by the NB-11 case (spec NB-11) |

**Coverage:** 100/102 lines (98.04%), missed 2 (unchanged from baseline).

**Not covered:** Two lines, unchanged from baseline; not introduced by this branch.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Self-hosted PoshQC (scoped) | 5358 passed, 0 failed, 0 skipped | ✅ |
| JUnit comparison | `FINAL_FAILED_CASES=0`, `NOT_IN_BASELINE=0` | ✅ |
| Registration suites | 792 passed, 0 failed | ✅ |
| AC-12 pytest (reviewer rerun) | 20 passed | ✅ |
| Repo-wide PowerShell line coverage (present artifact) | 47.60% (scoped run) | ❌ PA-1 |

---

## 7. Code Quality Checks

| Check | Result | Status |
|-------|--------|--------|
| PoshQC format | No file changed | ✅ |
| PSScriptAnalyzer | 0 findings in 11 files | ✅ |
| Mirror parity | Identical | ✅ |
| Old builder references | `git grep` exit 1 for both patterns | ✅ |
| File size | Maximum 420 lines | ✅ |

---

## 8. Gaps and Exceptions

### Identified Gaps

| ID | Severity | Description | Remediability | Related |
|----|----------|-------------|---------------|---------|
| PA-1 | Blocking | PowerShell repo-wide line coverage is not demonstrated at >= 85%. The only coverage artifact (`artifacts/pester/powershell-coverage.xml`) comes from a run scoped to `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime` and reports 8623/18115 = 47.60% across the 203 files in the configured roots. Neither `pester-selfhosted-baseline.2026-10-16T01-06.md` nor `final-pester-selfhosted.2026-10-16T05-12.md` records a full-suite report-level counter. Required action: run `Invoke-PoshQCTest -Root <worktree>` without `-ScanFolders` (the same command the CI `PowerShell QC` job runs) and record the report-level `LINE` counter verbatim under `evidence/qa-gates/`, or copy it from the CI `poshqc-test-results` artifact for the PR head. | autonomous | Related (evidence gap of this item) |
| PA-2 | Pending CI (non-blocking) | AC-26: `poshqc / PowerShell QC` on the PR head. No PR exists yet (`pr_context.summary.txt`: "no PR exists yet for this branch"). | awaiting_ci | Related |
| PA-3 | Pending CI (non-blocking) | AC-27: `poshqc / PowerShell hook suites (Linux)` on the PR head. This job also confirms the case-sensitive dot-source path on Linux. | awaiting_ci | Related |
| PA-4 (= CR-1) | Minor (non-blocking) | The NB-11 case builds its envelope from a hand-written JSON literal (`tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:336`) instead of `ConvertTo-SubagentStopEnvelopeJson`; its Describe (`:329-350`) does not dot-source the helper. | autonomous | Related (NB-4 intent, same file) |

### Approved Exceptions

| Exception | Basis |
|-----------|-------|
| No fail-before test | spec decision 11 and AC-25: every new test is a characterization test against unchanged behavior; `evidence/regression-testing/fail-before-exception.2026-10-16T01-10.md`. |
| Local test counts read from the self-hosted module, not MCP | spec "Verification policy: Option A". |

### Unrelated Follow-ups (not item findings)

- None new. The `profile_cli.py` prefix match in `Get-DiscoveryArtifactType` remains the pre-existing E3 follow-up owned by `TODO(#9002)` and is explicitly out of scope (spec line 43).

### Removed/Skipped Tests

- None. Seven local `New-SubagentStopEnvelopeJson` definitions were removed (test support code, not tests); every call site was converted with the original `agent_type` value passed through `-AgentType`.

---

## 9. Summary of Changes

| Area | Change |
|------|--------|
| Production | `$agentOutput` alias removed in `.claude/hooks/validate-task-researcher-output.ps1` and its bundle mirror (NB-5). |
| Tests | R3 reject/accept rows in two suites (NB-1, NB-2); R4 trim-only cases (NB-3); dispatch suite (NB-9); in-process dependency-decision case (NB-11); shared helper and conversion of seven suites (NB-4). |
| Docs | Two clarification lines in the E3 spec (NB-7, NB-8); this item's spec, plan, research, evidence (NB-10 counters). |

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
PASS. Toolchain clean, scope limited, file sizes within limit, mirror parity held.

#### Language-Specific Code Change Policy (Section 3)
PASS for PowerShell.

#### General Unit Test Policy (Section 1)
PARTIAL. Test design and changed-file coverage pass; repo-wide PowerShell coverage is not evidenced by a full-suite run (PA-1).

#### Language-Specific Unit Test Policy (Section 4)
PARTIAL for the same reason.

### Metrics Summary

| Metric | Value |
|--------|-------|
| Blocking findings | 1 (PA-1) |
| Non-blocking findings | 3 (PA-2, PA-3, PA-4) |
| Changed-file line coverage | 98.04% |
| Tests failed | 0 |

### Recommendation

Record a full-suite PowerShell coverage counter (PA-1) and convert the NB-11 envelope literal to the shared helper (PA-4) in one remediation cycle, then re-review. AC-26 and AC-27 are checked off at S9.

---

## Appendix A: Test Inventory

| File | Added cases |
|------|-------------|
| `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` | 7 accept rows, 6 reject rows |
| `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` | 7 accept rows, 6 reject rows, 1 NB-11 case |
| `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` | 4 R4 `It` blocks (one with 5 rows), 1 gate case |
| `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1` | 2 dispatch cases (new file) |
| `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` | Shared helper (new file, not a test container) |

## Appendix B: Toolchain Commands Reference

- `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` (executor)
- `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root <root> -ScanFolders @('tests/scripts/claude-hooks','tests/scripts/claude-runtime')` (executor, scoped)
- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` (executor and reviewer)
- `python -I scripts/dev_tools/validate_evidence_locations.py --root .` (reviewer)
- `git merge-tree --write-tree af34e23e4 37545a357` (reviewer, read-only)
