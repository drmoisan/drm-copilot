# Policy Compliance Audit: Issue #935 — hook-test-isolation-737-remainder

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T03-20, UTC host clock)
**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Base:** `main`; merge-base `97559c3e0dcfceb807ae330d3c9e6ae4c5d67964`
**Head reviewed:** `79386619519d99cb0fed56b5f4b41e42837903d3` (pushed; a merge of `origin/main` into the branch on top of `5eb283c7e`)
**Review scope:** full branch diff `origin/main...HEAD` (55 files, +3213/-574)
**Work mode:** `full-bug` (AC source: `spec.md`, section `## Acceptance Criteria`, AC-1..AC-26)
**Code Under Test:** 18 PowerShell files under `tests/scripts/` (7 created, 11 edited), all test suites or test helpers; no production file changed

## Total Blocking Findings: 1

COV-1 (blocking, `autonomous`): the only post-change PowerShell coverage artifact available, `artifacts/pester/powershell-coverage.xml`, reports 66.04% line coverage (8110/12280), below the 85% default line floor. The artifact comes from a three-folder PoshQC run, and its denominator (12280 lines) differs from the CI baseline denominator (18116), so the shortfall probably reflects the run's scope rather than lost coverage. That has not been demonstrated, so the coverage verdict is FAIL until a repo-wide post-change measurement at or above 85% (and not below the 90.42% baseline) is recorded. Remedy: regenerate the coverage artifact from a full-population PoshQC test run and record the comparison under `evidence/qa-gates/`. See `remediation-inputs.2026-10-16T03-20.md`.

Pending-CI item PC-1 (non-blocking) is the absence of PR CI results for the 19 CI-dependent acceptance criteria. Those results cannot exist before the pull request. Under the PR Creation Gate condition 2 in `.claude/skills/orchestrate/SKILL.md`, a CI-dependent criterion listed as pending-CI does not block PR creation, and the orchestrator checks it off at S9. PC-1 is therefore recorded as pending-CI and not as a blocking finding.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 18 (7 created, 11 edited; all under `tests/scripts/`) | 41 new testcases (28 HookReference, 6 Branches, 4 Discovery, 3 probe rows); every moved row retained | PASS (local PoshQC call disposition; per-row CI results pending PC-1) | 90.42% lines (16381/18116, CI run 38730332356 on main) | FAIL: 66.04% lines in `artifacts/pester/powershell-coverage.xml` (8110/12280; scoped three-folder run, see 1.2.1), below the 85% line floor (COV-1) | 100.00% (0/0 production lines changed; no changed file is in the `config/poshqc-coverage.json` roots) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 37 feature-folder documents and evidence files | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `evidence/baseline/ci-baseline.2026-10-16T00-11.md` (D-COV over `powershell-coverage.xml` of CI run 38730332356: covered 16381, not covered 1735, 90.42%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (local three-folder PoshQC run, 8110/12280 = 66.04%, different denominator from CI) - FAIL against the 85% line floor (COV-1); a full-population post-change artifact is required, and P7-T6 later confirms the figure from the PR CI artifact `poshqc-test-results`
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch delivers the #737 remainder recorded as #903 Operator Follow-ups 4, 5, 6, 10 and 11, entirely inside test infrastructure:

- F-1/F-2 reapplied from `4e8d9f92d` (conditional-ancestor rule; no first-dot-source fallback; `no dot-source loads the hook` finding), refined by R1 (root-variable and segment hook references) and R2 (helper-only `BeforeAll` blocks anchored at the last `.Helpers.ps1` dot-source). The hook-reference functions moved to the new `EpicStateIsolation.HookReference.Helpers.ps1`.
- F-3 report-only detection of variable-built hook loads (`Get-EpicStateIsolationHookReference`, `Get-EpicStateVariableHookLoad`, `Get-EpicStateVariableHookLoadReport`, Discovery row `AC-5b`); the loaded-source closure stays literal-seeded.
- I-3: four 500-line files split as pure moves (verified by this review: every removed non-blank line reappears verbatim in the target file, except the Codex helper functions, which reappear re-indented by one level when moved out of `BeforeAll`).
- N-2 and F-6 closed by recorded decisions (spec `## Decisions` D5, D6).

No path outside `tests/` and the feature folder changed. Local toolchain evidence (format, analyze, test) is clean in a single pass. All per-row results, Passed counts and post-change coverage are CI-dependent by design (plan Phase 7); no PR exists yet, so those criteria are listed as pending-CI item PC-1, which the PR Creation Gate accepts and S9 resolves. One blocking finding remains: COV-1, PowerShell coverage FAIL. The available post-change coverage artifact is below the 85% line floor, and no repo-wide post-change measurement exists to replace it. No code defect was identified.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- FAIL `.claude/rules/powershell.md` coverage gate (COV-1); code change and unit test structure otherwise PASS, with CI confirmation in PC-1
- N/A TypeScript, Python, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-10-16 03:15:20 UTC at HEAD `79386619519d`), `issue.md`, `spec.md`, `plan.2026-10-15T17-44.md`, `research/research.2026-10-15T22-03.md`, and the `evidence/` folder.

**Temporary artifacts cleanup:**
- PASS `git status --porcelain` is empty at review start. The `SCRATCH/935/issue-935/` token in evidence artifacts refers to session scratchpad output; no such path is in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller prompt stated that Phase 7 context "is not a scope limit" and asked for the full feature-vs-base review. The audit covers all 55 files of `origin/main...HEAD`.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- `git diff --name-only origin/main...HEAD | grep '^artifacts/'` returned no path; the branch adds nothing under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- Evidence is under `evidence/baseline/`, `evidence/qa-gates/`, and `evidence/regression-testing/` (canonical kinds). `evidence/other/` is reserved for P7-T7.
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds no project; all changed code is under `tests/scripts/`, which falls under the root entry `path: "."` (T4). No classification gap arises. Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | New rows parse in-memory fixture text per row; no shared mutable state other than the documented `$script:EpicStateParseCache` memo (D6) and the pre-existing `$script:ReportLine` pattern reused by `$script:VariableLoadLine`. |
| Isolation | PASS | Each R1, R2 and F-3 row targets one function (`Test-EpicStateIsolationHookReference`, `Get-EpicStateIsolationFinding`, `Get-EpicStateIsolationHookReference`, `Get-EpicStateProcessSpawningHook`, `Get-EpicStateLoadedSourceClosure`). |
| Fast execution | PASS | Fixtures are AST parses of short strings; the Discovery rows reuse the parse memo. |
| Determinism | PASS | This review's grep over the 18 changed files found no executable use of `New-TemporaryFile`, `TestDrive`, `GetTempFileName`, `Get-Date`, `Start-Sleep`, `Start-Process` or `ProcessStartInfo`; matches are comments, detection tokens or string fixtures (same 9 lines as `evidence/qa-gates/determinism-search.2026-10-16T03-10.md`). |
| Readability | PASS | Data-driven rows with descriptive `<Case>`/`<Form>`/`<Reader>` names, Arrange-Act-Assert comments and `-Because` messages that print the actual records. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell) | FAIL | Post-change artifact `artifacts/pester/powershell-coverage.xml` reports 66.04% (8110/12280), from a three-folder run. Baseline 90.42% at main (CI run 38730332356). The branch changes no file in the coverage roots and removes no test that exercises production code (splits are pure moves), so the shortfall is probably due to the run's scope, but no repo-wide post-change measurement exists (COV-1). |
| Branch >= 75% | N/A | Pester measures no branch coverage; no branch threshold applies to PowerShell (`.claude/rules/powershell.md`). |
| No regression on changed lines | PASS | 0 production lines changed. |
| Positive / negative / edge | PASS | R1 positive (11) and negative (3) rows; R2 rows (a)-(d); F-3 positive forms (5), non-load readers (3), process-spawning union, closure-stays-literal; F-1 non-compliant (3) and compliant (2); F-2 row. |
| Coverage exclusion policy | PASS | `config/poshqc-coverage.json` is not in the diff; no production path is excluded. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% lines (16381/18116, CI run 38730332356 at main `adb9aa5f0`). Post-change: 66.04% lines in the local artifact (8110/12280), which comes from a three-folder PoshQC run with a 12280-line denominator against the CI denominator of 18116, so the two figures are not directly comparable. Change: -24.38 points as measured (66.04% against 90.42%). No file in the coverage roots changed and no production-exercising test was removed, so the measured drop is probably due to the run's scope, but this is not demonstrated. New/changed-code coverage: 100.00% (0/0 production lines). Disposition: FAIL (COV-1; remedy is a full-population post-change measurement, later confirmed by P7-T6 from the PR CI artifact). Evidence: `evidence/baseline/ci-baseline.2026-10-16T00-11.md`, `artifacts/pester/powershell-coverage.xml`, `git diff --name-only origin/main...HEAD`, `config/poshqc-coverage.json`.
- TypeScript: N/A - no changed files on the branch.
- Python: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | Every new row carries `# Arrange`, `# Act`, `# Assert` sections (HookReference suite lines 110-118, 167-171, 277-285). |
| Actionable assertion messages | PASS | `-Because` texts include the joined findings or the list of detected records (`Form:Name:Root`). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | Fixtures are here-strings and an in-memory reader table (`F-3 closure stays literal-seeded`). |
| Fixture names absent from hook trees | PASS | `evidence/qa-gates/fixture-names.2026-10-16T03-10.md` (no Glob match under `.claude/hooks` or `.codex/hooks`). |
| Test file location | PASS | All new suites and helpers are in `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, `tests/scripts/claude-runtime`, beside the suites they split from. |
| File size <= 500 lines | PASS | Recomputed by this review with `awk 'END { print NR }'`: maximum 428 (`EpicStateIsolation.Helpers.ps1`, `enforce-epic-worktree-removal-gate.Tests.ps1`). |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Phase 0 artifacts exist under `evidence/baseline/` (instructions read, branch state, line counts, split anchors, withheld source, format/analyze/test baselines, CI baseline source and CI baseline).

### 2.2 Design Principles

PASS with non-blocking observations. Hook-reference logic is separated into its own pure helper file; F-3 output is report-only; the closure seed is unchanged. Duplicated predicate scriptblocks and regex constants in the new helper are recorded as non-blocking (code review CR-N2).

### 2.3 Module & File Structure

PASS. Every created or edited code file is at or below 500 lines; the four I-3 originals are now 428, 418, 271 and 402 lines.

### 2.4 Naming, Docs, and Comments

PASS. Approved-verb `Verb-Noun` function names; comment-based help or header comments on every new function; header paragraphs for the shape-B residual limit, R2 relaxation, and F-3 report-only behavior.

### 2.5 After Making Changes - Toolchain Execution

PASS for local stages; CI stages pending (PC-1).

| Stage | Result | Evidence |
|-------|--------|----------|
| 1 Formatting | PASS | Pass 1 re-indented `EpicStateIsolation.Helpers.ps1` (committed `4c9d38da0`); pass 2 after-output empty (`ps-format.2026-10-16T02-46.md`). |
| 2 Linting | PASS | `run_poshqc_analyze` returned without error (`ps-analyze.2026-10-16T02-48.md`). |
| 3 Type checking | N/A | Not applicable to PowerShell. |
| 4 Architecture-boundary tests | N/A | No boundary test covers `tests/scripts/`. |
| 5 Unit tests | PASS (local disposition) | `run_poshqc_test` returned without error (`ps-test.2026-10-16T03-10.md`); per-row results pending PR CI. |
| 6 Contract / schema | N/A | No API or schema changed. |
| 7 Integration tests | N/A | No adapter changed. |

The loop closed in a single clean pass (`loop-status.2026-10-16T03-10.md`). The later merge commit `793866195` brought only `.github/dependabot.yml`, one Python test module and Markdown from main (`git diff --stat adb9aa5f0 97559c3e0`), none of which is in the PowerShell scan folders or coverage roots.

### 2.6 Summarize and Document

PASS. `spec.md` `## Decisions` (D1-D6), the plan, research and the evidence folder document the change and its residual limits.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| PoshQC format | PASS | `ps-format.2026-10-16T02-46.md` (no change). |
| PSScriptAnalyzer | PASS | `ps-analyze.2026-10-16T02-48.md` (returned without error). |
| `[OutputType()]` and typed parameters | PASS | Every new function declares `[OutputType(...)]` and typed, `Mandatory` parameters where required. |
| No mutable module state | PASS | No new script-scope state in helpers; `$script:EpicStateParseCache` is the pre-existing documented memo (D6). |
| Fail-fast error handling | PASS | Pure functions return `$false`/`$null` for absent input; no catch-all handlers added. |
| Policy files untouched | PASS | No path under `.claude/` or `.github/` in the diff. |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5 with `#Requires` | PASS | New suites start with `#Requires -Version 7.0` and the Pester 5 module requirement. |
| Data-driven rows | PASS | `-ForEach` rows for R1, F-3 forms and readers, F-1 branches, and `<Surface>`. |
| Hook isolation in new split suites | PASS | Each split suite has its own `BeforeAll` with the baseline mocks and a `baseline mock interception probe` row (3 rows, one per split suite). |
| Pure moves | PASS | This review compared removed lines with the targets; only intended re-indentation differs. |
| Per-row CI results (both jobs) | Pending | PR CI does not exist yet (PC-1). |

## 5. Test Coverage Detail

All changed files are test suites or test helpers under `tests/scripts/`, outside the coverage roots (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`). They are not measured. The new rows exercise only the isolation-guard helpers; the moved rows exercise the same hooks as before the split.

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| New testcases | 41 (HookReference 28, Branches 6, Discovery 4, split-suite probe rows 3) |
| Local test runs | P1, P4, P5 and final P6 `run_poshqc_test` calls returned without error |
| Baseline Windows Passed counts (CI) | 51, 25, 120, 32, 54 for the five suites in `ci-baseline.2026-10-16T00-11.md` |
| Post-split Passed counts | Pending P7-T5 (PC-1) |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format | No change (final pass) |
| PoshQC analyze | Returned without error |
| PoshQC test | Returned without error |
| Line counts | All 18 files <= 500 |
| Determinism grep | 0 executable matches |
| Scope (`.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`) | 0 paths |

## 8. Gaps and Exceptions

### Identified Gaps

- COV-1 (blocking, `autonomous`): PowerShell coverage FAIL. `artifacts/pester/powershell-coverage.xml` reports 66.04% line coverage, below the 85% floor. Remedy: run `mcp__drm-copilot__run_poshqc_test` over the full PowerShell test population (every folder that `poshqc / PowerShell QC` runs), confirm the regenerated artifact uses the `config/poshqc-coverage.json` roots, and record repo-wide line coverage at or above 85% and not below the 90.42% baseline in `evidence/qa-gates/coverage-comparison.<timestamp>.md`.
- PC-1 (pending-CI, non-blocking): AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23 and AC-24 require PR CI JUnit artifacts, job conclusions or the CI coverage file. No PR exists, so these results cannot exist yet. Owner: orchestrator, plan Phase 7 (P7-T2..P7-T10).
- AC-26 PR-description half: verified by P7-T9 after the PR exists (non-blocking observation in the code review and feature audit).
- PoshQC MCP results carry only a call disposition; local evidence cannot show per-row results or counts. This is a known tool limit recorded in the plan.

### Approved Exceptions

None.

### Removed/Skipped Tests

None removed. Moved rows keep their names; each split adds one probe row.

## 9. Summary of Changes

### Commits in This PR/Branch

- `62c205808` docs(935): add feature folder, research and spec
- `fe5a17000` docs(935): add atomic plan draft
- `c117fa984` docs(935): revise plan for preflight round 1 findings
- `025ce2154` docs(935): revise plan for preflight round 2 findings
- `4484c2886` docs(935): record main CI baseline counts and coverage (P7-T1)
- `4986cbfb8` docs(935): phase 0 baseline evidence
- `44a48200c` test(935): split four 500-line test files (I-3)
- `924e6f9d4` test(935): reapply withheld #737 F-1/F-2 from 4e8d9f92d
- `c2dbca25a` test(935): move hook-reference functions to EpicStateIsolation.HookReference.Helpers.ps1
- `94adb8c93` test(935): R1 root-variable hook references and R2 helper-only blocks
- `64396d7d6` test(935): report-only detection of variable-built hook loads (F-3)
- `4c9d38da0` style(935): apply PoshQC formatter output (final QA loop pass 1)
- `5eb283c7e` docs(935): final QA evidence
- `793866195` merge of `origin/main`

### Files Modified

- Created: `EpicStateIsolation.HookReference.Helpers.ps1`, `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`, `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`, `enforce-prd-feature-before-planner.CallTarget.Tests.ps1` (claude-hooks); `enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1`, `...command-exemption.Selectors.Tests.ps1` (codex-hooks); `EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1` (claude-runtime).
- Edited: `EpicStateIsolation.Helpers.ps1`, `.Discovery.Helpers.ps1`, `.Compliance.Helpers.ps1`, the Branches, Predicate, legacy and Discovery guard suites, and the four I-3 originals.
- Feature folder documents and evidence (Markdown).

## 10. Compliance Verdict

### Overall Status: NOT COMPLIANT (coverage evidence, COV-1)

### Policy-by-Policy Summary

- General Unit Test Policy: FAIL on the coverage requirement (COV-1); all other requirements PASS
- General Code Change Policy: PASS
- PowerShell code change and unit test policy: FAIL on the coverage gate (COV-1); local format, analyze and test PASS; CI confirmation pending (PC-1)
- Quality tiers and coverage exclusion policy: PASS
- Evidence location policy: PASS
- Tonality: PASS

### Metrics Summary

PowerShell baseline 90.42% lines; post-change artifact 66.04% (scoped run); 0 production lines changed; 1 blocking finding (COV-1, `autonomous`); 19 criteria pending CI (PC-1); 8 non-blocking code-review findings.

### Recommendation

Run one remediation cycle for COV-1: regenerate the PowerShell coverage artifact from a full-population run and record the comparison. Then re-review and proceed to PR creation. At S9, run plan Phase 7 (P7-T2..P7-T10) against the final PR head, record the CI-sourced evidence, and check off the remaining criteria. Include the operator follow-ups and decisions in the PR description (AC-26).

---

## Appendix A: Test Inventory

1. `R1 identifies <Case>` (11 cases) and `R1 does not identify <Case>` (3 cases) — HookReference suite
2. `R2 (a)`..`R2 (d)` — HookReference suite
3. `F-3 detects <Form>` (5), `F-3 ignores a Join-Path used only by <Reader>` (3), `F-3 process-spawning report includes a variable-built hook path`, `F-3 closure stays literal-seeded` — HookReference suite
4. `F-1 non-compliant <Branch>` (3), `F-1 compliant <Branch>` (2), `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` — Branches suite
5. `AC-5b variable-built hook-load report <Surface>` (2), `F-3 non-vacuity <Surface> reports at least one variable-built hook load` (2) — Discovery suite
6. `baseline mock interception probe` — ManifestBranch, CallTarget, Selectors suites

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (executor, via MCP):**
```
mcp__drm-copilot__run_poshqc_format   scan_folders = tests/scripts/claude-hooks, tests/scripts/codex-hooks, tests/scripts/claude-runtime
mcp__drm-copilot__run_poshqc_analyze  scan_folders = (same)
mcp__drm-copilot__run_poshqc_test     scan_folders = (same)
```

**Reviewer commands (check-only):**
```
git diff --stat origin/main...HEAD
git diff origin/main...HEAD -- <each changed .ps1 file>
git diff --stat adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 97559c3e0dcfceb807ae330d3c9e6ae4c5d67964
git log --oneline --no-merges origin/main..HEAD
git status --porcelain
awk 'END { print NR }' <each changed .ps1 file>
grep -n -E -e 'New-TemporaryFile|TestDrive|GetTempFileName|Get-Date|Start-Sleep|Start-Process|ProcessStartInfo' <each changed .ps1 file>
grep -vxFf <split target> <lines removed from the I-3 original>   (pure-move comparison)
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
read of the root LINE counter in artifacts/pester/powershell-coverage.xml
```
