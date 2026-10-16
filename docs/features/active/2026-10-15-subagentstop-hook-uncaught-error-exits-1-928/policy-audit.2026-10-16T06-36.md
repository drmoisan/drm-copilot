# Policy Compliance Audit: Issue #928 — SubagentStop validator uncaught error exits 1 (re-audit after remediation cycle 2)

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T06-36, UTC)
**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Base:** `origin/main` @ `5bc97774b8322e57abb94dfac3cd0a000a136c5b` (merge base; the branch is 30 commits ahead and 0 behind)
**Head reviewed:** `2f6b960051a92c85a3fcc7ea8c85dd89fea79014` (pushed; `git ls-remote` equals `HEAD`)
**Review scope:** full branch diff `5bc97774..2f6b9600` (115 files, +3938/-49), not only remediation cycle 2
**Work mode:** `full-bug` (`issue.md` line 12; AC source: `spec.md`, section `## Acceptance Criteria`, AC1-AC16)
**Code Under Test:** eight SubagentStop validators under `.claude/hooks/` (tail `try`/`catch` plus one `.NOTES` sentence each), `.claude/hooks/subagentstop-envelope.ps1` (citation only), `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment only), new suite `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` (159 lines), three edited test files, four Markdown documentation corrections, and byte-identical bundle mirrors.
**Prior review:** `policy-audit.2026-10-16T05-53.md` (head `b222a6ba`); remediation plan `remediation-plan.2026-10-16T06-40.md`.

## Total Blocking Findings: 1

The single blocking finding (PA-B1, carried unchanged from the two prior reviews) is classified `awaiting_ci`. It concerns the PowerShell coverage verdict and the AC14 coverage clause, which depend on the CI coverage artifact of the PR head. No `autonomous` blocking finding exists. Remediation cycle 2 changed only Markdown inside the feature folder and introduced no new blocking finding.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 10 production (`.claude/hooks`) + 10 mirrors + 4 test files | 13 in new suite (U1 x9, U1-ST x2, U2, probe); scoped suites total 5334 | PASS (5334 run, 0 failed, local, `poshqc-test.2026-10-16T05-39.md`) | CI main run 38849638374: repo 90.43% lines (16381/18116); ten changed files 99.12% (901/909) | Local partial-scope report: 52.00% repo (6387/12283); 4 of 10 changed files present (99.36%, 469/472); 6 changed files absent | 100.00% of locally instrumented new catch lines (3/3: discovery :253, orchestrator :344, planner :440); 5 catch lines pending CI |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 4 documentation files + 3 mirrors, feature documents | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/remediation-baseline/poshqc-coverage.2026-10-16T04-51.md` (COVERAGE_SOURCE `ci-main 38849638374`, `poshqc-test-results` artifact); original baseline `evidence/baseline/poshqc-coverage.2026-10-16T01-32.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (local, scan folders `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime`; recomputed by this review), summarized in `evidence/qa-gates/poshqc-coverage.2026-10-16T05-40.md`
- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- Python baseline coverage artifact: N/A - no Python files changed on the branch
- Python post-change coverage artifact: N/A - no Python files changed on the branch
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch converts an unhandled terminating error in the validation call of eight SubagentStop validators from process exit 1 (which does not block a SubagentStop event) into `Exit-SubagentStopBlock` (exit 2 with a stderr reason). Each change is a two-line `try`/`catch` at the script tail after the S1 dependency tail, following the precedent in `validate-feature-review-coverage.ps1:202-203`. The regression suite drives all nine validators through the in-process `&` route with a throwing envelope-reader mock, plus two statement-terminating rows (U1-ST).

Remediation cycle 2 (commit `2f6b9600`) resolved CR2-N3 (`spec.md` line 6 `Last Updated` now `2026-10-16T06-23`, line 8 `Version` now `0.3`) and CR2-N4 (`issue.md` line 5 status path now names the existing feature folder). Both were verified by this review with `git diff b222a6baf HEAD`: three single-line replacements, no other content change. No code, test, hook, mirror, or settings file changed since the prior review head (`git diff --name-status b222a6baf HEAD` lists only files under the feature folder).

The orchestrator's decisions on CR-N5, CR2-N1, CR2-N2, and CR2-N5 are recorded as accepted (section 8.1). Two new non-blocking findings of Info severity are recorded (section 8.2).

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- FAIL `.claude/rules/general-unit-test.md` (coverage clause only; PA-B1, awaiting_ci)
- PASS `.claude/rules/quality-tiers.md` (`.claude/hooks` is T3; no new project)
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (code change and unit test), except the coverage verdict recorded under PA-B1
- N/A Python, TypeScript, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (stale at review start, generated for head `b222a6ba`; regenerated by this review at 2026-10-16 06:34:57 UTC for head `2f6b9600`, merge base `5bc97774`), `issue.md`, `spec.md`, `plan.2026-10-15T15-44.md`, `remediation-plan.2026-10-16T03-45.md`, `remediation-plan.2026-10-16T06-40.md`, the prior review set (`*.2026-10-16T05-53.md`), and the `evidence/` tree.

**Temporary artifacts cleanup:**
- PASS No temporary files are committed. `git status --porcelain` is empty at `2f6b9600`. The `SCRATCH/928/` token in evidence artifacts refers to session scratchpad helpers; no such path appears in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller prompt asked for a full-branch review against `origin/main`, asked that CR-N5, CR2-N1, CR2-N2, and CR2-N5 be recorded as accepted orchestrator decisions, and supplied classification guidance (the F1 coverage clause and AC15 remain `awaiting_ci` absent an actual defect). None of these removes a file of the branch diff from scope or waives a coverage or toolchain check. The audit covered the full branch diff `5bc97774..2f6b9600`.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (run by this review).
- `git diff --name-only origin/main...HEAD` filtered for `^artifacts/(baselines|qa|evidence|coverage)/` returned no path (grep exit 1).
- Cycle-2 evidence is under `evidence/remediation-baseline/`, `evidence/qa-gates/`, and `evidence/other/`, all canonical kinds in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root on the base. `.claude/hooks` is classified T3. The branch adds no project. T3 requires no property tests and no mutation score. Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | `Invoke-ValidatorUnderTest` saves and restores `[Console]::In`, `[Console]::Error`, `$script:HookDependencyFailures`, `$script:HookDependencyGuardLoadFailed`, and `$global:LASTEXITCODE` in `finally` (test file lines 52-95). Unchanged since the prior review. |
| Isolation | PASS | Each U1 and U1-ST row exercises one validator's unhandled-error path; U2 is a separate completeness test. |
| Fast execution | PASS | In-process `&` route; no subprocess. |
| Determinism | PASS | No clock, RNG, or network use; envelope is a fixed JSON literal. |
| Readability | PASS | `.SYNOPSIS`/`.DESCRIPTION` header, Arrange-Act-Assert comments, `-Because` messages that print actual stderr. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell) | FAIL (Blocking, awaiting_ci) | Local report is partial-scope (two scan folders): 52.00% (6387/12283), recomputed by this review from `artifacts/pester/powershell-coverage.xml`. CI main baseline 90.43%. The authoritative figure is the `poshqc / PowerShell QC` artifact on the PR head. See PA-B1. |
| Line >= 85% per modified file | FAIL (Blocking, awaiting_ci) | Matched locally (recomputed by this review): discovery 100.00% (64/64), orchestrator 99.10% (110/111), planner 99.50% (200/201), enforce-epic-wave-barrier 98.96% (95/96). Absent locally: executor, pr-author, prd-feature, required-artifact, task-researcher, subagentstop-envelope. See PA-B1. |
| Branch >= 75% | N/A | Pester measures no branch coverage (`.claude/rules/powershell.md`); no branch gate applies. |
| No regression on changed lines | FAIL (Blocking, awaiting_ci) | Matched files are at or above the ci-main baseline; the uncovered lines (orchestrator :235, planner :158, wave-barrier :380) are not changed lines. Six files pending CI. See PA-B1. |
| Positive / negative / edge | PASS | Script-terminating error for all nine validators (U1); statement-terminating .NET method exception for the two default-preference validators (U1-ST); characterization row for the already-compliant validator; completeness row (U2). |
| Coverage exclusion policy | PASS | No coverage configuration file is in the diff. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.43% repo lines (CI main 38849638374); ten changed files 99.12% -> Post-change: four locally matched changed files 99.36% (469/472); local repo figure 52.00% is a partial-scope run and is not comparable. Change: matched files +0.00 to +0.01 points. New/changed-code coverage: 100.00% of locally instrumented new catch lines (3/3); five catch lines pending CI. Disposition: FAIL (Blocking, awaiting_ci, PA-B1). No PowerShell file changed after the coverage artifact was produced (`git diff --name-status b222a6baf HEAD` lists Markdown only). Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/poshqc-coverage.2026-10-16T05-40.md`, `evidence/remediation-baseline/poshqc-coverage.2026-10-16T04-51.md`.
- Python: N/A - no changed files on the branch.
- TypeScript: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | Explicit `# Arrange`, `# Act`, `# Assert` sections in U1, U1-ST, and U2. |
| Actionable assertion messages | PASS | U1 and U1-ST print actual stderr on prefix mismatch; U2 prints the set difference. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | `test-file-constraints.2026-10-16T05-22.md`: banned-token count 0 for `TestDrive`, `New-TemporaryFile`, `Start-Process`, `GetTempPath`, `env:`. Test file unchanged since then. |
| Test file location | PASS | `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`, beside existing hook suites. |
| File size <= 500 lines | PASS | Largest changed non-Markdown file is `validate-planner-output.ps1` and its mirror at 442 lines; new suite 159 lines (`wc -l` by this review). |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Phase 0 baseline artifacts exist under `evidence/baseline/`; cycle 1 and cycle 2 baseline artifacts exist under `evidence/remediation-baseline/` (cycle 2: `phase0-instructions-read`, `git-state`, `doc-metadata-baseline`, all `2026-10-16T06-23`).

### 2.2 Design Principles

PASS. The change is the minimal per-validator tail wrapper chosen in research option (a). It reuses `Exit-SubagentStopBlock` and the existing precedent. No whole-script `try` or `trap`. `exit` statements remain outside the `try` body. Neither remediation cycle changed a validator.

### 2.3 Module & File Structure

PASS. No new production module. All changed files are at most 442 lines.

### 2.4 Naming, Docs, and Comments

PASS. One `.NOTES` sentence per validator. Citation lines are 68-112 characters wide (CR2-N2, accepted).

### 2.5 After Making Changes - Toolchain Execution

PASS (local), with coverage pending CI. Final code-bearing pass (cycle 1): PoshQC format MCP ok, 15 hashes unchanged (`poshqc-format.2026-10-16T05-27.md`); analyze MCP ok (`poshqc-analyze.2026-10-16T05-28.md`); test MCP ok, 5334 tests, 0 failures (`poshqc-test.2026-10-16T05-39.md`); bundle-parity pytest 14 passed (`pytest-bundle-parity.2026-10-16T05-40.md`). Type checking does not apply to PowerShell. No contract or schema changed.

Cycle 2 is Markdown-only. `evidence/qa-gates/no-code-change-cycle2.2026-10-16T06-25.md` records an empty diff over code and configuration patterns, and this review confirmed it independently (`git diff --name-status b222a6baf HEAD`: 13 added and 2 modified files, all under the feature folder). No toolchain rerun is required for Markdown-only changes to feature documents.

### 2.6 Summarize and Document

PASS. `spec.md` header now reflects the cycle-1 edits (`Last Updated: 2026-10-16T06-23`, `Version: 0.3`). `issue.md` line 11 (`Last Updated: 2026-10-15`) was deliberately left unchanged by the cycle-2 plan (PA-N12, Info).

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | PASS | `poshqc-format.2026-10-16T05-27.md`: no file changed by the formatter. No PowerShell file changed afterwards. |
| PSScriptAnalyzer | PASS | `poshqc-analyze.2026-10-16T05-28.md`: MCP ok, no finding. |
| Fail-closed hook policy | PASS | Each catch (`grep -n 'catch { Exit-SubagentStopBlock'` by this review: discovery :253, executor :322, orchestrator :344, planner :440, pr-author :129, prd-feature :118, required-artifact :199, task-researcher :290) calls `Exit-SubagentStopBlock` with a message that always contains the non-empty prefix. |
| Bundle mirror parity | PASS | `cmp` by this review at `2f6b9600`: all 12 changed `.claude` files are byte-identical to `extensions/drm-copilot/resources/claude-customizations/`; `.agents/skills/translate-claude-to-codex/SKILL.md` is byte-identical to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/...`. |
| Excluded paths | PASS | `git diff --quiet origin/main...HEAD` over `validate-feature-review-coverage.ps1` and its mirror, `.codex`, the bundle `.codex`, and both `settings.json` files exited 0 (this review). |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5, data-driven rows | PASS | `-ForEach $script:ValidatorRows` and `-ForEach $script:StatementTerminatingRows`, both built in `BeforeDiscovery`. |
| Mocks at the I/O boundary | PASS | `Mock Read-SubagentStopEnvelope` and `Mock Import-Module`; `Should -Invoke Read-SubagentStopEnvelope -Times 1 -Exactly`. |
| Epic-state isolation guard (#737) | PASS | Baseline seam mocks registered in `BeforeAll`; interception probe inside an `It`. |
| Fail-before evidence | PASS | `fail-before.2026-10-16T02-03.md` (eight AC1 rows FAIL pre-fix); `lastexitcode-fail-before.2026-10-16T05-10.md`. U1-ST rows are characterization rows (CR2-N1, accepted). |
| Fail-after evidence | PASS | `statement-terminating-after.2026-10-16T05-21.md` and `poshqc-test.2026-10-16T05-39.md`: suite MATCHED 13 FAILED 0. |
| Updated existing tests | PASS | REG-4 and E-RA-10 expect two `Exit-SubagentStopBlock` calls. |

## 5. Test Coverage Detail

### subagentstop-uncaught-error.Tests.ps1 (13 tests)

Not measured (test file). The suite executes the new catch line of each of the eight changed validators and the existing catch of `validate-feature-review-coverage.ps1`. In the local report, the catch lines of the three matched validators are covered.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| New suite | 13 passed, 0 failed (final cycle-1 run; no test change since) |
| Fail-before (original) | 8 failed, 2 passed (expected) |
| Fail-before (cycle 1, LASTEXITCODE restore) | 2 failed at the restore assertion (expected) |
| Full scoped suites | 5334 tests, 0 failures, 0 errors |
| Bundle parity pytest | 14 passed |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format | MCP ok, 15 hashes unchanged |
| PoshQC analyze | MCP ok, no finding |
| PoshQC test | MCP ok, 0 failures |
| Coverage (85% line) | Pending CI (PA-B1) |

## 8. Gaps and Exceptions

### 8.1 Prior Findings Disposition

| Prior finding | Status | Evidence (verified by this review) |
|---|---|---|
| CR2-N3 / PA-N8 (`spec.md` header not updated) | Resolved | `spec.md:6` reads `- **Last Updated:** 2026-10-16T06-23`; `spec.md:8` reads `- **Version:** 0.3`. `git diff b222a6baf HEAD -- spec.md` shows exactly these two line replacements. `doc-metadata-edits.2026-10-16T06-24.md` records numstat `2 2`. |
| CR2-N4 / PA-N9 (`issue.md` status path) | Resolved | `issue.md:5` reads `- Status: Promoted -> docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/ (Issue #928)`; that folder exists. `git diff b222a6baf HEAD -- issue.md` shows one line replacement. |
| CR-N5 (literal halt sentence in four validators) | Accepted (orchestrator decision) | Per-file convention; avoids widening the overlap with #929. Literals unchanged at discovery :253, pr-author :129, prd-feature :118, task-researcher :290. |
| CR2-N1 / PA-N6 (U1-ST not run against pre-fix validators) | Accepted (orchestrator decision) | U1-ST rows are characterization rows: the two validators were already blocked before the fix for this error class, so a fail-before result cannot be produced. |
| CR2-N2 / PA-N7 (uneven rewrap) | Accepted (orchestrator decision) | Line widths are within limits; a reflow would re-churn the verified AC4/AC9 hunk. |
| CR2-N5 / PA-N10 (`validate-bash.ps1` exit 1 fail-open) | Accepted as unrelated (orchestrator decision) | Different hook, event, and exit-code contract; the file is not edited by this item (`.claude/hooks/validate-bash.ps1` is absent from `git diff --stat origin/main...HEAD`). |

### 8.2 Identified Gaps

- **PA-B1 (Blocking, Remediability: awaiting_ci): PowerShell coverage verdict and AC14 coverage clause.** Carried unchanged. The local coverage artifact `artifacts/pester/powershell-coverage.xml` was produced by a run scoped to two test folders. It omits six changed production files (`validate-executor-output.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`, `subagentstop-envelope.ps1`) and reports a non-comparable repo figure of 52.00%. No defect is indicated: the four locally present changed files are at or above baseline, and the six absent files are 98.06%-100.00% in the ci-main baseline. No PR exists for the branch (`gh pr list --head ... --state all` returned `[]`). Resolution: open the PR; at S9 record per-file line coverage for the ten changed files (each >= 85% and not below baseline) and the repo-wide figure (>= 85%) from the `poshqc-test-results` artifact, then check off AC14 together with AC15.
- **PA-N11 (Non-blocking, Info): remediation plan filename stamp is later than its commit.** See code-review CR3-N1.
- **PA-N12 (Non-blocking, Info): `issue.md:11` `Last Updated` not updated after the cycle-2 edit of line 5.** See code-review CR3-N2.

### Approved Exceptions

None. The accepted orchestrator decisions in section 8.1 are design or scope choices, not exceptions to a policy.

### Removed/Skipped Tests

None removed or skipped.

## 9. Summary of Changes

### Commits in This PR/Branch

30 commits ahead of `origin/main`: the original delivery, two merges of `origin/main`, remediation cycle 1, the cycle-1 re-audit artifacts (`8706cb240`), the cycle-2 plan (`cd709e54b`), and the cycle-2 metadata edits (`2f6b96005`).

### Files Modified

- Eight validators under `.claude/hooks/` (+2/-1 tail, +1 `.NOTES` line each) and their bundle mirrors
- `.claude/hooks/subagentstop-envelope.ps1` and `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment-help text only) and mirrors
- `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.agents/skills/translate-claude-to-codex/SKILL.md`, `docs/engineering/claude-code-architecture.md` and mirrors where applicable
- `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` (new, 159 lines); three edited test files
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

Locally matched changed files 99.36% lines (469/472); six changed files pending CI; 1 blocking finding (awaiting_ci); 2 non-blocking findings (Info); CR2-N3 and CR2-N4 resolved; CR-N5, CR2-N1, CR2-N2, and CR2-N5 accepted per orchestrator decision.

### Recommendation

Open the PR and confirm the `poshqc / PowerShell QC` coverage artifact on the PR head for the ten changed files at S9. The two Info findings do not require another remediation cycle; CR3-N2 can be folded into the S9 check-off commit.

---

## Appendix A: Test Inventory

| Test file | Tests | Change | Result (final run) |
|-----------|-------|--------|--------------------|
| `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` | probe, U1 x9, U1-ST x2, U2 | New | 13 passed |
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
| Format | `mcp__drm-copilot__run_poshqc_format` | `evidence/qa-gates/poshqc-format.2026-10-16T05-27.md` |
| Lint | `mcp__drm-copilot__run_poshqc_analyze` | `evidence/qa-gates/poshqc-analyze.2026-10-16T05-28.md` |
| Type check | Not applicable to PowerShell | N/A |
| Unit tests | `mcp__drm-copilot__run_poshqc_test` | `evidence/qa-gates/poshqc-test.2026-10-16T05-39.md` |
| Coverage | Parse of `artifacts/pester/powershell-coverage.xml` (JaCoCo LINE counters) | `evidence/qa-gates/poshqc-coverage.2026-10-16T05-40.md`; recomputed by this review |
| Bundle parity | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `evidence/qa-gates/pytest-bundle-parity.2026-10-16T05-40.md` |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | Run by this review, exit 0 |
| PR context | `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main` | Run by this review, exit 0; `artifacts/pr_context.summary.txt` |

## Appendix C: Assumptions

- The timestamp `2026-10-16T06-36` is UTC (`date -u` at write time). It sorts before the stamp of `remediation-plan.2026-10-16T06-40.md`, whose filename stamp is later than its commit time (CR3-N1); this review nonetheless postdates the cycle-2 commit `2f6b9600` (committed 2026-10-16 06:26 UTC).
- Coverage was assessed from existing artifacts; coverage generation was not rerun.
- PoshQC and Pester results are taken from recorded cycle-1 evidence; no PowerShell file changed after that run.
