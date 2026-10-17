# Policy Compliance Audit: Issue #928 — SubagentStop validator uncaught error exits 1 (re-audit after remediation cycle 1)

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T05-53, UTC)
**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Base:** `origin/main` @ `5bc97774b8322e57abb94dfac3cd0a000a136c5b` (merge base; the branch is 27 commits ahead and 0 behind)
**Head reviewed:** `b222a6baf6dbe42f86a352938a3e8518ca1fedc0`
**Review scope:** full branch diff `5bc97774..b222a6ba` (103 files, +3234/-49), not only the remediation cycle
**Work mode:** `full-bug` (`issue.md` line 12; AC source: `spec.md`, section `## Acceptance Criteria`, AC1-AC16)
**Code Under Test:** eight SubagentStop validators under `.claude/hooks/` (tail `try`/`catch` plus one `.NOTES` sentence each), `.claude/hooks/subagentstop-envelope.ps1` (citation only), `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment only), new suite `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` (159 lines), three edited test files, four Markdown documentation corrections, and byte-identical bundle mirrors.
**Prior review:** `policy-audit.2026-10-16T03-30.md` (head `20c7a808`); remediation plan `remediation-plan.2026-10-16T03-45.md`.

## Total Blocking Findings: 1

The single blocking finding (PA-B1, carried from the prior review) is classified `awaiting_ci`. It concerns the PowerShell coverage verdict and AC14's coverage clause, which depend on the CI coverage artifact of the PR head. No `autonomous` blocking finding exists. No new blocking finding was introduced by remediation cycle 1 or by the merge of `origin/main`.

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

The branch converts an unhandled terminating error in the validation call of eight SubagentStop validators from process exit 1 (which does not block a SubagentStop event) into `Exit-SubagentStopBlock` (exit 2 with a stderr reason). Each change is a two-line `try`/`catch` at the script tail after the S1 dependency tail, following the precedent in `validate-feature-review-coverage.ps1:202-203`. The regression suite drives all nine validators through the in-process `&` route with a throwing envelope-reader mock, and remediation cycle 1 added two statement-terminating rows (U1-ST) for the two validators that run under the default `$ErrorActionPreference`.

Remediation cycle 1 resolved the four targeted non-blocking findings (CR-N1 to CR-N4; section 8.1). CR-N5 is recorded as accepted. The only remaining blocking item is the PowerShell coverage verdict, which is CI-dependent (`awaiting_ci`). Five new non-blocking findings of Info severity are recorded (section 8.2).

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- FAIL `.claude/rules/general-unit-test.md` (coverage clause only; PA-B1, awaiting_ci)
- PASS `.claude/rules/quality-tiers.md` (`.claude/hooks` is T3; no new project)
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (code change and unit test), except the coverage verdict recorded under PA-B1
- N/A Python, TypeScript, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (stale at review start, generated for head `20c7a808`; regenerated by this review at 2026-10-16 05:51:13 UTC for head `b222a6ba`, merge base `5bc97774`), `issue.md`, `spec.md`, `plan.2026-10-15T15-44.md`, `remediation-plan.2026-10-16T03-45.md`, the prior review set (`*.2026-10-16T03-30.md`), and the `evidence/` tree.

**Temporary artifacts cleanup:**
- PASS No temporary files are committed. The `SCRATCH/928/` token in evidence artifacts refers to session scratchpad helpers; no such path appears in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller prompt asked for a full-branch review against `origin/main` "(not only the cycle)", supplied classification guidance (AC14 coverage clause and AC15 are CI-dependent and are to be classified `awaiting_ci` absent an actual defect), and asked that CR-N5 be recorded as accepted. None of these removes a file of the branch diff from scope or waives a coverage check. The audit covered the full branch diff `5bc97774..b222a6ba`.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (run by this review).
- `git diff --name-only origin/main...HEAD` filtered for `^artifacts/(baselines|qa|evidence|coverage)/` returned no path.
- Evidence is under `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/remediation-baseline/`, and `evidence/other/`, all canonical kinds in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root on the base. `.claude/hooks` is classified T3. The branch adds no project. T3 requires no property tests and no mutation score. Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | `Invoke-ValidatorUnderTest` saves and restores `[Console]::In`, `[Console]::Error`, `$script:HookDependencyFailures`, `$script:HookDependencyGuardLoadFailed`, and (since cycle 1) `$global:LASTEXITCODE` in `finally` (test file lines 52-95). |
| Isolation | PASS | Each U1 and U1-ST row exercises one validator's unhandled-error path; U2 is a separate completeness test. |
| Fast execution | PASS | In-process `&` route; no subprocess. |
| Determinism | PASS | No clock, RNG, or network use; envelope is a fixed JSON literal. |
| Readability | PASS | `.SYNOPSIS`/`.DESCRIPTION` header, Arrange-Act-Assert comments, `-Because` messages that print actual stderr. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell) | FAIL (Blocking, awaiting_ci) | Local report is partial-scope (two scan folders): 52.00% (6387/12283), recomputed by this review from `artifacts/pester/powershell-coverage.xml`. CI main baseline 90.43%. The authoritative figure is the `poshqc / PowerShell QC` artifact on the PR head. See PA-B1. |
| Line >= 85% per modified file | FAIL (Blocking, awaiting_ci) | Matched locally (recomputed by this review): discovery 100.00%, orchestrator 99.10%, planner 99.50%, enforce-epic-wave-barrier 98.96%. Absent locally: executor, pr-author, prd-feature, required-artifact, task-researcher, subagentstop-envelope. See PA-B1. |
| Branch >= 75% | N/A | Pester measures no branch coverage (`.claude/rules/powershell.md`); no branch gate applies. |
| No regression on changed lines | FAIL (Blocking, awaiting_ci) | Matched files show deltas of +0.00 to +0.01 points against ci-main 38849638374; the uncovered lines (orchestrator :235, planner :158, wave-barrier :380) are not changed lines. Six files pending CI. See PA-B1. |
| Positive / negative / edge | PASS | Script-terminating error for all nine validators (U1); statement-terminating .NET method exception for the two default-preference validators (U1-ST, added in cycle 1); characterization row for the already-compliant validator; completeness row (U2). |
| Coverage exclusion policy | PASS | No coverage configuration file is in the diff. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.43% repo lines (CI main 38849638374); ten changed files 99.12% -> Post-change: four locally matched changed files 99.36% (469/472); local repo figure 52.00% is a partial-scope run and is not comparable. Change: matched files +0.00 to +0.01 points. New/changed-code coverage: 100.00% of locally instrumented new catch lines (3/3: `validate-discovery-artifact-gate.ps1:253`, `validate-orchestrator-output.ps1:344`, `validate-planner-output.ps1:440`); five catch lines pending CI. Disposition: FAIL (Blocking, awaiting_ci, PA-B1). Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/poshqc-coverage.2026-10-16T05-40.md`, `evidence/remediation-baseline/poshqc-coverage.2026-10-16T04-51.md`.
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
| No temporary files | PASS | `test-file-constraints.2026-10-16T05-22.md`: banned-token count 0 for `TestDrive`, `New-TemporaryFile`, `Start-Process`, `GetTempPath`, `env:`; stdin and stderr use `StringReader` and `StringWriter`. |
| Test file location | PASS | `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`, beside existing hook suites. |
| File size <= 500 lines | PASS | New suite 159 lines; largest changed file `validate-planner-output.ps1` and its mirror 442 lines (`wc -l` by this review). |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Phase 0 baseline artifacts exist under `evidence/baseline/`; remediation cycle 1 baseline artifacts exist under `evidence/remediation-baseline/`.

### 2.2 Design Principles

PASS. The change is the minimal per-validator tail wrapper chosen in research option (a). It reuses `Exit-SubagentStopBlock` and the existing precedent. No whole-script `try` or `trap`. `exit` statements remain outside the `try` body. Remediation cycle 1 changed no validator (`validators-unchanged-cycle1.2026-10-16T05-42.md`).

### 2.3 Module & File Structure

PASS. No new production module. All changed files are at most 442 lines.

### 2.4 Naming, Docs, and Comments

PASS. One `.NOTES` sentence per validator. The 897 citation lines were rewrapped in cycle 1 and are now 68-112 characters wide (CR-N4 resolved).

### 2.5 After Making Changes - Toolchain Execution

PASS (local), with coverage pending CI. Final pass of cycle 1: PoshQC format MCP ok with 15 hashes unchanged (`poshqc-format.2026-10-16T05-27.md`); analyze MCP ok over `.claude/hooks`, the bundle hooks, and `tests/scripts/claude-hooks` (`poshqc-analyze.2026-10-16T05-28.md`); test MCP ok, 5334 tests, 0 failures (`poshqc-test.2026-10-16T05-39.md`); bundle-parity pytest 14 passed (`pytest-bundle-parity.2026-10-16T05-40.md`). Type checking does not apply to PowerShell. No contract or schema changed.

The merge commit `b222a6ba` (origin/main into the branch) follows that QC pass. This review compared the merged paths (`git diff --name-only bb3527191 b222a6baf`, 451 paths: 433 under `docs/features`, 15 under `tests/scripts/codex-hooks` and `tests/scripts/dev_tools`, 3 TypeScript tests under `extensions/drm-copilot/test`) with the branch file list and with `.claude/hooks`, `.claude/lib`, `tests/scripts/claude-hooks`, `tests/scripts/claude-runtime`, `config/poshqc*`, and `.github/workflows`. There is no overlap, and the set of hooks that dot-source `subagentstop-envelope.ps1` is still the nine U1 rows, so the U2 completeness assertion is unaffected. The PR-head CI run (AC15) reruns the suites on the merged head.

### 2.6 Summarize and Document

PASS. `spec.md`, the plans, research, and evidence document the change and the cycle-1 resolution (`evidence/other/remediation-cycle1-resolution.2026-10-16T05-44.md`). The spec header was not updated after the cycle-1 edits (PA-N8, Info).

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | PASS | `poshqc-format.2026-10-16T05-27.md`: no file changed by the formatter. |
| PSScriptAnalyzer | PASS | `poshqc-analyze.2026-10-16T05-28.md`: MCP ok, no finding. |
| Fail-closed hook policy | PASS | Each catch calls `Exit-SubagentStopBlock` (exit 2) with a message that always contains the non-empty prefix. |
| Bundle mirror parity | PASS | `cmp` by this review at `b222a6ba`: all 12 changed `.claude` files and the `.agents` skill are byte-identical to their bundle counterparts. |
| Excluded paths | PASS | `git diff --quiet origin/main...HEAD` over `validate-feature-review-coverage.ps1` and its mirror, `.codex`, the Codex-bundle `.codex`, and both `settings.json` files exited 0 (this review). |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5, data-driven rows | PASS | `-ForEach $script:ValidatorRows` and `-ForEach $script:StatementTerminatingRows`, both built in `BeforeDiscovery`. |
| Mocks at the I/O boundary | PASS | `Mock Read-SubagentStopEnvelope` and `Mock Import-Module`; `Should -Invoke Read-SubagentStopEnvelope -Times 1 -Exactly`. |
| Epic-state isolation guard (#737) | PASS | Baseline seam mocks registered in `BeforeAll`; interception probe inside an `It`; `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` 344/0 failed. |
| Fail-before evidence | PASS | `fail-before.2026-10-16T02-03.md` (eight AC1 rows FAIL pre-fix); `lastexitcode-fail-before.2026-10-16T05-10.md` (two U1-ST rows fail only at the LASTEXITCODE-restore assertion). U1-ST was not run against the pre-fix validators (PA-N6, Info). |
| Fail-after evidence | PASS | `statement-terminating-after.2026-10-16T05-21.md` and `poshqc-test.2026-10-16T05-39.md`: suite MATCHED 13 FAILED 0. |
| Updated existing tests | PASS | REG-4 and E-RA-10 expect two `Exit-SubagentStopBlock` calls, both outside any function and neither inside the argument-check block. |

## 5. Test Coverage Detail

### subagentstop-uncaught-error.Tests.ps1 (13 tests)

Not measured (test file). The suite executes the new catch line of each of the eight changed validators and the existing catch of `validate-feature-review-coverage.ps1` (line 203, uncovered in the ci-main baseline). In the local report, the catch lines of the three matched validators are covered.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| New suite | 13 passed, 0 failed (final cycle-1 run) |
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
| CR-N1 / PA-N1 (statement-terminating error class not exercised) | Resolved | Test file lines 31-34 add `$script:StatementTerminatingRows` (discovery, pr-author); lines 117-134 add U1-ST with a mock that raises `InvalidOperationException` through `ExceptionDispatchInfo.Throw()`, a .NET method call. Both rows pass (`poshqc-test.2026-10-16T05-39.md`). `spec.md:63`, `:197`, `:289` updated to state the observed result. |
| CR-N2 / PA-N2 (`$global:LASTEXITCODE` not restored) | Resolved | Test file line 68 saves `$global:LASTEXITCODE`; line 91 restores it in `finally` after line 82 captures the exit code. U1-ST line 133 asserts the restore; fail-before recorded the missing restore. |
| CR-N3 / PA-N3 (architecture doc PreToolUse exit-code statement) | Resolved | `docs/engineering/claude-code-architecture.md:237` now describes the JSON `permissionDecision: deny` on stdout with exit 0, states that exit 1 is not used because PreToolUse fails open on it, and states exit 2 on a `hook-dependency-guard.ps1` load failure. This matches `.claude/hooks/validate-bash.ps1:12-22`, `:437`, and `:443-448`. `spec.md:279` Out of Scope updated. |
| CR-N4 / PA-N4 (citation line width) | Resolved | `subagentstop-envelope.ps1:12-14` (and mirror) are 80, 97, 56 characters; `subagentstop-envelope.Tests.ps1:9-11` are 68, 100, 112 characters (`awk` by this review). Whitespace-normalized text is unchanged (`limited-diff.2026-10-16T05-41.md`). |
| CR-N5 / PA-N5 (literal halt sentence in four validators) | Accepted, not a finding | Deliberately unchanged: the literal matches the per-file convention of those four validators and avoids widening the overlap with #929 in `validate-task-researcher-output.ps1`. The literal text equals `$script:SubagentStopReportAndHaltLine` in the other four validators (verified in the prior review). |
| CR-N6 / PA-N6 (branch behind origin/main) | Resolved | `git rev-list --count HEAD..origin/main` is 0 at `b222a6ba`. |

### 8.2 Identified Gaps

- **PA-B1 (Blocking, Remediability: awaiting_ci): PowerShell coverage verdict and AC14 coverage clause.** Carried unchanged from the prior review. The local coverage artifact `artifacts/pester/powershell-coverage.xml` was produced by a run scoped to two test folders. It omits six changed production files (`validate-executor-output.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`, `subagentstop-envelope.ps1`) and reports a non-comparable repo figure of 52.00%. No defect is indicated: the four locally present changed files are at or above baseline, and the six absent files are 98.06%-100.00% in the ci-main baseline. Resolution: the `poshqc / PowerShell QC` job on the PR head produces the `poshqc-test-results` coverage artifact; record per-file line coverage for the ten changed files (each >= 85% and not below baseline) and the repo-wide figure (>= 85%), then check off AC14 together with AC15 at S9.
- **PA-N6 (Non-blocking, Info): U1-ST rows were not run against the pre-fix validators.** See code-review CR2-N1.
- **PA-N7 (Non-blocking, Info): uneven rewrap of the test-file citation paragraph.** See code-review CR2-N2.
- **PA-N8 (Non-blocking, Info): `spec.md` header not updated after cycle-1 edits.** See code-review CR2-N3.
- **PA-N9 (Non-blocking, Info): `issue.md` status path does not match the feature folder.** See code-review CR2-N4.
- **PA-N10 (Non-blocking, Info, outside item scope): PreToolUse analogue of the #928 defect in `validate-bash.ps1`.** See code-review CR2-N5.

### Approved Exceptions

None. CR-N5 is an accepted design choice, not an exception to a policy.

### Removed/Skipped Tests

None removed or skipped.

## 9. Summary of Changes

### Commits in This PR/Branch

27 commits ahead of `origin/main`, including the original delivery (`d6e597329` to `20c7a8088`), a merge of `origin/main` (`b62a865f1`), remediation cycle 1 (`37545a357`, `39d20cab6`, test and evidence commits, `53ee03f93`, `bb3527191`), and the merge of `origin/main` at `b222a6baf`.

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

Locally matched changed files 99.36% lines (469/472); six changed files pending CI; 1 blocking finding (awaiting_ci); 5 non-blocking findings (all Info); prior CR-N1 to CR-N4 and CR-N6 resolved; CR-N5 accepted.

### Recommendation

Open the PR and confirm the `poshqc / PowerShell QC` coverage artifact on the PR head for the ten changed files at S9. The Info findings do not require another remediation cycle.

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
| Format | `mcp__drm-copilot__run_poshqc_format` (scan folders `.claude/hooks`, bundle hooks, `tests/scripts/claude-hooks`) | `evidence/qa-gates/poshqc-format.2026-10-16T05-27.md` |
| Lint | `mcp__drm-copilot__run_poshqc_analyze` (same scan folders) | `evidence/qa-gates/poshqc-analyze.2026-10-16T05-28.md` |
| Type check | Not applicable to PowerShell | N/A |
| Unit tests | `mcp__drm-copilot__run_poshqc_test` (scan folders `tests/scripts/claude-hooks`, `tests/scripts/claude-runtime`) | `evidence/qa-gates/poshqc-test.2026-10-16T05-39.md` |
| Coverage | Parse of `artifacts/pester/powershell-coverage.xml` (JaCoCo LINE counters) | `evidence/qa-gates/poshqc-coverage.2026-10-16T05-40.md`; recomputed by this review |
| Bundle parity | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `evidence/qa-gates/pytest-bundle-parity.2026-10-16T05-40.md` |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | Run by this review, exit 0 |
| PR context | `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main` | Run by this review; `artifacts/pr_context.summary.txt` |

## Appendix C: Assumptions

- The timestamp `2026-10-16T05-53` is UTC (`date -u`), matching the UTC-based stamps of this feature's evidence.
- Coverage was assessed from existing artifacts; coverage generation was not rerun.
- PoshQC and Pester results are taken from recorded cycle-1 evidence; this review session has no PoshQC MCP tool and did not rerun Pester. The merge commit `b222a6ba` touches no path in the PowerShell test or production scope (section 2.5).
