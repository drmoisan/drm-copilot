# Policy Compliance Audit: Issue #928 — SubagentStop validator uncaught error exits 1

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T03-30, UTC)
**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Base:** `origin/main`; merge-base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
**Head reviewed:** `20c7a8088093a13f1937a4e75f7ed7f581f76a8b`
**Review scope:** full branch diff `adb9aa5f..20c7a808` (68 files, +1899/-45, 16 commits)
**Work mode:** `full-bug` (AC source: `spec.md`, section `## Acceptance Criteria`, AC1-AC16)
**Code Under Test:** eight SubagentStop validators under `.claude/hooks/` (tail `try`/`catch` plus one `.NOTES` sentence each), `.claude/hooks/subagentstop-envelope.ps1` (citation only), `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment only), new suite `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` (134 lines), three edited test files, three Markdown documentation corrections, and byte-identical bundle mirrors.

## Total Blocking Findings: 1

The single blocking finding (PA-B1) is classified `awaiting_ci`. It concerns the PowerShell coverage verdict and AC14's coverage clause, which depend on the CI coverage artifact of the PR head. No `autonomous` blocking finding exists.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 10 production (`.claude/hooks`) + 10 mirrors + 4 test files | 11 new (U1 x9, U2, probe); suites total 5332 | PASS (5332 run, 0 failed, local) | CI main run 38730332356: repo 90.43% lines (16381/18116); ten changed files 99.12% (901/909) | Local partial-scope report: 52.00% repo (6387/12283); 4 of 10 changed files present (99.36%, 469/472); 6 changed files absent | 100.00% of locally instrumented new catch lines (3/3: discovery :253, orchestrator :344, planner :440); 5 catch lines pending CI |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 4 documentation files + 2 mirrors, feature documents | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/poshqc-coverage.2026-10-16T01-32.md` (COVERAGE_SOURCE `ci-main 38730332356`, `poshqc-test-results` artifact)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (local, scan folders `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime` only; recomputed by this review), summarized in `evidence/qa-gates/poshqc-coverage.2026-10-16T03-15.md` (COVERAGE_SOURCE `ci-pr`)
- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- Python baseline coverage artifact: N/A - no Python files changed on the branch
- Python post-change coverage artifact: N/A - no Python files changed on the branch
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch converts an unhandled terminating error in the validation call of eight SubagentStop validators from process exit 1 (which does not block a SubagentStop event) into `Exit-SubagentStopBlock` (exit 2 with a stderr reason). Each change is a two-line `try`/`catch` at the script tail, placed after the S1 dependency tail, following the existing precedent in `validate-feature-review-coverage.ps1:202-203`. A new data-driven Pester suite drives all nine validators through the in-process `&` route with a throwing envelope-reader mock and asserts exit 2, the prefix, and the error text, plus an AST completeness row. Fail-before and fail-after evidence is recorded. Mirrors are byte-identical (verified by `cmp` in this review). Documentation of the SubagentStop exit-code contract is corrected in four files.

Policy compliance is met for code structure, tests, file size, mirrors, evidence locations, and excluded paths. The one blocking finding is the PowerShell coverage verdict: the local coverage report omits six of the ten changed production files, so per-file and repo-wide thresholds cannot be confirmed from local evidence. This is a CI-dependent check classified `awaiting_ci`. Six non-blocking findings are recorded (section 8).

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- FAIL `.claude/rules/general-unit-test.md` (coverage clause only; PA-B1, awaiting_ci)
- PASS `.claude/rules/quality-tiers.md` (`.claude/hooks` is T3; no new project)
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (code change and unit test), except the coverage verdict recorded under PA-B1
- N/A Python, TypeScript, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (absent at review start; regenerated by this review at 2026-10-16 03:28:12 UTC, head `20c7a808`, merge base `adb9aa5f`), `issue.md`, `spec.md`, `plan.2026-10-15T15-44.md`, `research/research.2026-10-15T16-10.md`, and the `evidence/` tree.

**Temporary artifacts cleanup:**
- PASS No temporary files are committed. The `SCRATCH/928/` token in evidence artifacts refers to session scratchpad helpers; no such path appears in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller prompt supplied classification guidance (AC14 coverage clause and AC15 are CI-dependent and are to be classified `awaiting_ci` absent an actual defect) and noted that issue #929 edits another hunk of `validate-task-researcher-output.ps1`. Neither instruction removes any file of the branch diff from scope; the #929 hunk is not in this branch diff. The audit covered the full branch diff against `origin/main`.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (no violations).
- The branch file list contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- Evidence is under `evidence/baseline/`, `evidence/qa-gates/`, and `evidence/regression-testing/` (canonical kinds).
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root on the base. `.claude/hooks` is classified T3 (`quality-tiers.yml:28-30`). The branch adds no project. T3 requires no property tests and no mutation score. Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | `Invoke-ValidatorUnderTest` saves and restores `[Console]::In`, `[Console]::Error`, `$script:HookDependencyFailures`, and `$script:HookDependencyGuardLoadFailed` in `finally` (test file lines 359-385). It sets `$global:LASTEXITCODE = 0` without restoring the prior value (non-blocking PA-N2). |
| Isolation | PASS | Each U1 row exercises one validator's unhandled-error path; U2 is a separate completeness test. |
| Fast execution | PASS | In-process `&` route; no subprocess. |
| Determinism | PASS | No clock, RNG, or network use; envelope is a fixed JSON literal. |
| Readability | PASS | `.SYNOPSIS`/`.DESCRIPTION` header, Arrange-Act-Assert comments, `-Because` messages that print actual stderr. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell) | FAIL (Blocking, awaiting_ci) | Local report is partial-scope (two scan folders): 52.00% (6387/12283), recomputed by this review from `artifacts/pester/powershell-coverage.xml`. CI main baseline 90.43%. The authoritative figure is the `poshqc / PowerShell QC` artifact on the PR head. See PA-B1. |
| Line >= 85% per modified file | FAIL (Blocking, awaiting_ci) | Matched locally: discovery 100.00%, orchestrator 99.10%, planner 99.50%, enforce-epic-wave-barrier 98.96%. Absent locally: executor, pr-author, prd-feature, required-artifact, task-researcher, subagentstop-envelope. See PA-B1. |
| Branch >= 75% | N/A | Pester measures no branch coverage (`.claude/rules/powershell.md`); no branch gate applies. |
| No regression on changed lines | FAIL (Blocking, awaiting_ci) | Matched files show deltas of +0.00 to +0.01 points; six files pending CI. See PA-B1. |
| Positive / negative / edge | PASS | Negative path (throwing reader) for all nine validators; characterization row for the already-compliant validator; completeness row. Statement-terminating error class not exercised (non-blocking PA-N1). |
| Coverage exclusion policy | PASS | No coverage configuration file is in the diff. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.43% repo lines (CI main 38730332356); ten changed files 99.12% -> Post-change: four locally matched changed files 99.36% (469/472); local repo figure 52.00% is a partial-scope run and is not comparable. Change: matched files +0.00 to +0.01 points. New/changed-code coverage: 100.00% of locally instrumented new catch lines (3/3: `validate-discovery-artifact-gate.ps1:253`, `validate-orchestrator-output.ps1:344`, `validate-planner-output.ps1:440`); five catch lines pending CI. Disposition: FAIL (Blocking, awaiting_ci, PA-B1). Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/poshqc-coverage.2026-10-16T03-15.md`, `evidence/baseline/poshqc-coverage.2026-10-16T01-32.md`.
- Python: N/A - no changed files on the branch.
- TypeScript: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | Explicit `# Arrange`, `# Act`, `# Assert` sections in U1 and U2. |
| Actionable assertion messages | PASS | U1 prints actual stderr on prefix mismatch; U2 prints the set difference. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | An extended-regex search of the new test file for `env:`, `TestDrive`, `Start-Process`, `New-TemporaryFile`, and `GetTempPath` returned no match; stdin and stderr use `StringReader` and `StringWriter`. |
| Test file location | PASS | `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`, beside existing hook suites. |
| File size <= 500 lines | PASS | New suite 134 lines; largest changed file `validate-planner-output.ps1` 442 lines. |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Phase 0 baseline artifacts exist under `evidence/baseline/` (instructions read, git state, line counts, mirror hashes, PoshQC format/analyze/test/coverage, bundle parity, token counts).

### 2.2 Design Principles

PASS. The change is the minimal per-validator tail wrapper chosen in research option (a). It reuses `Exit-SubagentStopBlock` and the existing precedent. No whole-script `try` or `trap`, which would break the S1 structural shape. `exit` statements remain outside the `try` body.

### 2.3 Module & File Structure

PASS. No new production module. All changed files are at most 442 lines (`evidence/qa-gates/line-counts.2026-10-16T03-16.md`; re-measured with `wc -l` by this review).

### 2.4 Naming, Docs, and Comments

PASS. One `.NOTES` sentence per validator, placed inside the `.NOTES` section (verified by line position in all eight files). Comment-help line wrapping in two citation edits is inconsistent with the surrounding paragraphs (non-blocking PA-N4).

### 2.5 After Making Changes - Toolchain Execution

PASS (local), with coverage pending CI. Final pass: PoshQC format MCP ok with 15 hashes unchanged (`poshqc-format.2026-10-16T02-58.md`); analyze MCP ok over `.claude/hooks`, the bundle hooks, and `tests/scripts/claude-hooks` (`poshqc-analyze.2026-10-16T02-58.md`); test MCP ok, 5332 tests, 0 failures (`poshqc-test.2026-10-16T03-00.md`); bundle-parity pytest 14 passed (`pytest-bundle-parity.2026-10-16T03-16.md`). Type checking does not apply to PowerShell. No contract or schema changed.

### 2.6 Summarize and Document

PASS. `spec.md`, the plan, research, and evidence document the change.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | PASS | `poshqc-format.2026-10-16T02-58.md`: no file changed by the formatter. |
| PSScriptAnalyzer | PASS | `poshqc-analyze.2026-10-16T02-58.md`: MCP ok, no finding. |
| Fail-closed hook policy | PASS | Each catch calls `Exit-SubagentStopBlock` (exit 2); `Exit-SubagentStopBlock` takes a mandatory non-empty `Message` (`subagentstop-envelope.ps1:183-187`), and the composed message is never empty because it always contains the prefix. |
| Bundle mirror parity | PASS | `cmp` by this review: all 12 changed `.claude` files and the `.agents` skill are byte-identical to their bundle counterparts. |
| Excluded paths | PASS | `git diff --name-only` over `.codex`, the Codex bundle `.codex`, `.claude/settings.json`, and `**/core.json` returned nothing. The only `.claude/agents` change is body text in `epic-orchestrator.md` lines 133-135 (no frontmatter). |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5, data-driven rows | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `-ForEach $script:ValidatorRows` built in `BeforeDiscovery`. |
| Mocks at the I/O boundary | PASS | `Mock Read-SubagentStopEnvelope` and `Mock Import-Module`; `Should -Invoke Read-SubagentStopEnvelope -Times 1 -Exactly`. |
| Epic-state isolation guard (#737) | PASS | Baseline seam mocks registered in `BeforeAll`; interception probe inside an `It` (AC-4 and AC-6 rows of `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` pass). |
| Fail-before evidence | PASS | `regression-testing/fail-before.2026-10-16T02-03.md`: 8 FAILED (each AC1 validator), feature-review row and U2 PASS. |
| Fail-after evidence | PASS | `regression-testing/fail-after.2026-10-16T02-22.md`: suite MATCHED 10 FAILED 0. |
| Updated existing tests | PASS | REG-4 and E-RA-10 now expect two `Exit-SubagentStopBlock` calls, both outside any function and neither inside the argument-check block; both PASS in the final run. |

## 5. Test Coverage Detail

### subagentstop-uncaught-error.Tests.ps1 (11 tests)

Not measured (test file). The suite executes the new catch line of each of the eight changed validators and the existing catch of `validate-feature-review-coverage.ps1`. In the local report, the catch lines of the three matched validators are covered.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| New tests | 11 passed, 0 failed (final run) |
| Fail-before | 8 failed, 2 passed (expected) |
| Full scoped suites | 5332 tests, 0 failures, 0 errors |
| Bundle parity pytest | 14 passed |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format | MCP ok, 15 hashes unchanged |
| PoshQC analyze | MCP ok, no finding |
| PoshQC test | MCP ok, 0 failures |
| Coverage (85% line) | Pending CI (PA-B1) |

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-B1 (Blocking, Remediability: awaiting_ci): PowerShell coverage verdict and AC14 coverage clause.** The local coverage artifact `artifacts/pester/powershell-coverage.xml` was produced by a run scoped to two test folders. It omits six changed production files (`validate-executor-output.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`, `subagentstop-envelope.ps1`) and reports a non-comparable repo figure of 52.00%. Per-file thresholds, the repo-wide threshold, and no-regression on changed lines cannot be confirmed for those files. No defect is indicated: all four locally present changed files are at or above baseline, and the CI main baseline for the ten files is 99.12%. Resolution: the `poshqc / PowerShell QC` job on the PR head produces the `poshqc-test-results` coverage artifact; record per-file line coverage for the ten changed files (each >= 85% and not below baseline) and the repo-wide figure (>= 85%), then check off AC14 together with AC15 at S9.
- **PA-N1 (Non-blocking): statement-terminating error class not exercised.** See code-review CR-N1.
- **PA-N2 (Non-blocking): `$global:LASTEXITCODE` not restored by the test helper.** See code-review CR-N2.
- **PA-N3 (Non-blocking): stale PreToolUse exit-code statement in the same architecture document.** See code-review CR-N3.
- **PA-N4 (Non-blocking): comment-help line wrapping in the 897 citation edits.** See code-review CR-N4.
- **PA-N5 (Non-blocking): report-and-halt sentence duplicated as a literal in four validators.** See code-review CR-N5.
- **PA-N6 (Non-blocking): branch is behind `origin/main` by the PR #943 merge (`97559c3e`).** `git diff --name-only adb9aa5f origin/main` lists only `.github/dependabot.yml`, #940 feature documents, and `tests/scripts/dev_tools/test_dependabot_config_contract.py`; no path overlaps this branch. Repository practice is to update the branch from `main` before opening the PR.

### Approved Exceptions

None.

### Removed/Skipped Tests

None removed or skipped. Two existing tests (REG-4, E-RA-10) changed their expected call count from one to two; this follows directly from the added catch and keeps the placement assertions.

## 9. Summary of Changes

### Commits in This PR/Branch

- `d6e597329` docs(928): scaffold active bug folder
- `b5699b5da` docs(928): add research
- `fc044c305` docs(928): add spec
- `b8ccf4a3c` docs(928): add atomic plan
- `90768d1a3` docs(928): revise plan per preflight round 1
- `b5f83eeb8` docs(928): revise plan per preflight round 2
- `9d943c692` chore(928): capture phase 0 baseline evidence
- `6b3a1dabc` test(928): add failing unhandled-error regression suite
- `f00fe6f95` fix(928): block SubagentStop validators with exit 2 on an unhandled validation error
- `7ce44089f` docs(928): state the unhandled-error block in validator .NOTES
- `a9ec4bf0e` docs(928): update 897 citations and SubagentStop exit-code documentation
- `576b03c15` chore(928): mirror changed Claude and agents resources to the bundle
- `9cf9bc0a1` docs(928): revise plan for phase 6 test-count and probe-test delta
- `9743a6026` docs(928): fix P6-T3 probe placement per preflight
- `e2e19b4f1` chore(928): record final QC evidence
- `20c7a8088` docs(928): check off verified acceptance criteria

### Files Modified

- Eight validators under `.claude/hooks/` (+2/-1 tail, +1 `.NOTES` line each) and their bundle mirrors
- `.claude/hooks/subagentstop-envelope.ps1` and `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment-help text only) and mirrors
- `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.agents/skills/translate-claude-to-codex/SKILL.md`, `docs/engineering/claude-code-architecture.md` and mirrors where applicable
- `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` (new, 134 lines); three edited test files
- Feature folder documents and evidence (Markdown)

## 10. Compliance Verdict

### Overall Status: COMPLIANT PENDING CI

### Policy-by-Policy Summary

- General Unit Test Policy: FAIL on the coverage clause only (PA-B1, awaiting_ci); all other items PASS
- General Code Change Policy: PASS
- PowerShell code change and unit test policy: PASS (coverage per PA-B1)
- Quality tiers and coverage exclusion policy: PASS
- Evidence location policy: PASS
- Tonality: PASS

### Metrics Summary

Locally matched changed files 99.36% lines (469/472); six changed files pending CI; 1 blocking finding (awaiting_ci); 6 non-blocking findings.

### Recommendation

Update the branch from `main`, open the PR, and confirm the `poshqc / PowerShell QC` coverage artifact on the PR head for the ten changed files at S9. Address the related non-blocking findings in a remediation cycle per operator policy.

---

## Appendix A: Test Inventory

| Test file | Tests | Change | Result (final run) |
|-----------|-------|--------|--------------------|
| `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` | probe, U1 x9, U2 | New | 11 passed |
| `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` | REG-4 x4 (edited) | Expected call count 1 to 2 | 11 passed in suite |
| `tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1` | E-RA-10 (edited) | Expected call count 1 to 2 | 15 passed in suite |
| `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` | header comment only | Citation | 78 passed in suite |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | unchanged | Regression | 598 passed |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` | unchanged | Regression | 148 passed |
| `tests/scripts/claude-runtime/claude-settings.Tests.ps1` | unchanged | Regression | 9 passed |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | unchanged | Bundle parity | 14 passed |

## Appendix B: Toolchain Commands Reference

| Stage | Command | Evidence |
|-------|---------|----------|
| Format | `mcp__drm-copilot__run_poshqc_format` (scan folders `.claude/hooks`, bundle hooks, `tests/scripts/claude-hooks`) | `evidence/qa-gates/poshqc-format.2026-10-16T02-58.md` |
| Lint | `mcp__drm-copilot__run_poshqc_analyze` (same scan folders) | `evidence/qa-gates/poshqc-analyze.2026-10-16T02-58.md` |
| Type check | Not applicable to PowerShell | N/A |
| Unit tests | `mcp__drm-copilot__run_poshqc_test` (scan folders `tests/scripts/claude-hooks`, `tests/scripts/claude-runtime`) | `evidence/qa-gates/poshqc-test.2026-10-16T03-00.md` |
| Coverage | Parse of `artifacts/pester/powershell-coverage.xml` (JaCoCo LINE counters) | `evidence/qa-gates/poshqc-coverage.2026-10-16T03-15.md`; recomputed by this review |
| Bundle parity | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `evidence/qa-gates/pytest-bundle-parity.2026-10-16T03-16.md` |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | Run by this review, exit 0 |
| PR context | `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main` | Run by this review; `artifacts/pr_context.summary.txt` |

## Appendix C: Assumptions

- The timestamp `2026-10-16T03-30` is UTC (`date -u`), matching the UTC-based stamps of this feature's evidence so that review artifacts sort after them.
- Coverage was assessed from existing artifacts; coverage generation was not rerun.
- PoshQC and Pester results are taken from recorded evidence; this review did not rerun Pester because PowerShell QC runs through MCP tools not available in this review session.
