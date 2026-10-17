# Policy Compliance Audit: Issue #935 — hook-test-isolation-737-remainder (re-audit after remediation cycle 1)

---

**Audit Date:** 2026-10-16 (timestamp 2026-10-16T07-30, UTC host clock)
**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Base:** `main`; merge-base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`
**Head reviewed:** `ef9b856982dc373f871103121ffef6999cbff7c5` (pushed; merge of `origin/main` on top of `f0eba90a5`)
**Review scope:** full branch diff `origin/main...HEAD` (86 files, +4561/-572)
**Work mode:** `full-bug` (AC source: `spec.md`, section `## Acceptance Criteria`, AC-1..AC-26)
**Code Under Test:** 18 PowerShell files under `tests/scripts/` (7 created, 11 edited), all test suites or test helpers; no production file changed
**Prior review:** `policy-audit.2026-10-16T03-20.md` (verdict REMEDIATION_REQUIRED, COV-1); remediation plan `remediation-plan.2026-10-16T03-40.md` (cycle R1)

## Total Blocking Findings: 1

COV-1 (blocking, carried, reclassified `awaiting_ci`): the PowerShell coverage artifact on disk, `artifacts/pester/powershell-coverage.xml`, reports 66.04% line coverage (8110/12280), below the 85% default line floor, so the PowerShell coverage verdict is FAIL. Remediation cycle R1 executed the prescribed remedy: a run with the full configured scan set (`scripts`, `tests/powershell`, `tests/scripts`) produced 94.45% (11598/12280), but over a 12280-line population against the CI population of 18116 lines (`evidence/qa-gates/coverage-comparison.2026-10-16T06-56.md`, outcome `MEASUREMENT-POPULATION-MISMATCH (DENOMINATOR)`). The local runner does not reproduce the CI coverage population. Under the acceptance clause of the prior remediation inputs (item 3), the finding therefore moves to `awaiting_ci` on plan task P7-T6 (AC-24): only the coverage file of the PR CI job `poshqc / PowerShell QC` can supply a like-for-like figure, and that job cannot run before the pull request exists. The current on-disk artifact was rewritten after the R1 measurement by a later two-folder run (report stamp `Pester (10/16/2026 03:22:55)`, local time, UTC-4), which explains why it again reads 66.04%.

Pending-CI item PC-1 (non-blocking) is the absence of PR CI results for the 19 CI-dependent acceptance criteria. Under PR Creation Gate condition 2, a criterion listed as pending-CI does not block PR creation; the orchestrator verifies and checks these off at S9 (plan Phase 7).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 18 (7 created, 11 edited; all under `tests/scripts/`) | 46 new testcases (33 HookReference, 6 Branches, 4 Discovery, 3 probe rows); every moved row retained | PASS locally: on-disk Pester JUnit (two hook folders, 224 suites, 6342 testcases, 0 failures, 0 errors) at HEAD; per-row CI results pending PC-1 | 90.42% line coverage (16381/18116, CI run 38730332356 on main) | FAIL: 66.04% line coverage in `artifacts/pester/powershell-coverage.xml` (8110/12280, two-folder run), below the 85% floor; R1 full-scan local figure 94.45% (11598/12280) over a non-CI population (COV-1, awaiting CI coverage on the PR head) | 100.00% (0/0 production lines changed; no changed file is in the `config/poshqc-coverage.json` roots) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 68 feature-folder documents and evidence files | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `evidence/baseline/ci-baseline.2026-10-16T00-11.md` (CI run 38730332356: covered 16381, missed 1735, 90.42% line coverage)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, read by this review: LINE covered 8110, missed 4170 (66.04%); INSTRUCTION covered 11794, missed 6129 (65.80%); last write 2026-10-16 03:23:19 -0400 - FAIL against the 85% line floor (COV-1)
- PowerShell R1 full-scan measurement: `evidence/qa-gates/coverage-comparison.2026-10-16T06-56.md` (94.45% line coverage over 12280 lines; population differs from CI's 18116) - recorded outcome, not a like-for-like pass
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch delivers the #737 remainder recorded as #903 Operator Follow-ups 4, 5, 6, 10 and 11, entirely inside test infrastructure:

- F-1/F-2 reapplied from `4e8d9f92d`, refined by R1 (root-variable and segment hook references) and R2 (helper-only `BeforeAll` blocks), with hook-reference functions in the new `EpicStateIsolation.HookReference.Helpers.ps1`.
- F-3 report-only detection of variable-built hook loads (Discovery row `AC-5b`); the loaded-source closure stays literal-seeded.
- I-3: four 500-line files split as pure moves.
- N-2 and F-6 closed by recorded decisions (spec `## Decisions` D5, D6).

Remediation cycle R1 (commits `bdc3d10c8`..`f0eba90a5`) addressed the prior review:

- CR-N1, CR-N5, CR-N6 fixed (`1ddf0182d`): Discovery helper header now names the HookReference dependency; long comment and one-line `param()` wrapped; 26 fixture lines indented (no column-0 `$script:UnderTest` line remains in the three guard suites, verified by Grep).
- CR-N2, CR-N8 fixed (`e2aca1a95`): shared `Get-EpicStateIsolationPattern` and `Get-EpicStateIsolationStringNode`; `Test-EpicStateIsolationVariableBoundToHook` now delegates to `Get-EpicStateIsolationVariableBinding`; `'hooks'.Length` replaces the bare `5`.
- CR-N3 fixed (`78e5f6d4e`): `Test-EpicStateIsolationSeparateValue` skips the separate-token value of value-taking parameters; five new rows with a fail-before record.
- CR-N4, CR-N7: NO-CHANGE dispositions with stated reasons (`evidence/other/r1-dispositions.2026-10-16T05-13.md`); this review accepts both.
- COV-1: executed; outcome `MEASUREMENT-POPULATION-MISMATCH`, reclassified `awaiting_ci` (P7-T6).

No path outside `tests/` and the feature folder changed. The R1 local toolchain loop passed in one pass. One blocking finding remains (COV-1, `awaiting_ci`); no autonomous finding remains. Three new non-blocking code-review observations are recorded (CR-R1..CR-R3).

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- FAIL `.claude/rules/general-unit-test.md` on the coverage requirement only (COV-1, awaiting CI)
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- FAIL `.claude/rules/powershell.md` coverage gate (COV-1, awaiting CI); code change and unit test structure otherwise PASS
- N/A TypeScript, Python, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-10-16 07:25:41 UTC at HEAD `ef9b85698`), `issue.md`, `spec.md`, `plan.2026-10-15T17-44.md`, `remediation-plan.2026-10-16T03-40.md`, `research/research.2026-10-15T22-03.md`, the `evidence/` folder, and the on-disk `artifacts/pester/` files.

**Temporary artifacts cleanup:**
- PASS `git status --porcelain` was empty at review start; no `SCRATCH/` or `artifacts/` path is in the branch file list.

---

## Rejected Scope Narrowing

None detected. The caller prompt describes Phase 7 as "Context for evaluating acceptance criteria (not a scope limit)" and requests the full feature-review contract over the whole branch. The audit covers all 86 files of `origin/main...HEAD`.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- The branch file list contains no path under `artifacts/` (so none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`).
- R1 evidence is under `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/` and `evidence/other/` (canonical kinds).
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds no project; all changed code is under `tests/scripts/`, covered by the root entry `path: "."` (T4). Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | New CR-N3 rows parse their own in-memory fixture per row; no shared state added. |
| Isolation | PASS | Each CR-N3 row targets `Get-EpicStateIsolationHookReference` with one parameter shape. |
| Fast execution | PASS | Short here-string fixtures parsed to AST. |
| Determinism | PASS | Grep of the 18 changed files for `New-TemporaryFile`, `TestDrive`, `GetTempFileName`, `Get-Date`, `Start-Sleep`, `Start-Process`, `ProcessStartInfo` found only comments, detection tokens and string fixtures (HookReference suite lines 270 and 324 are inside here-strings; the CR-N3 rows compose the process-start cmdlet name at run time). |
| Readability | PASS | Arrange-Act-Assert comments and `-Because` messages that print the detected records. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Line >= 85% repo-wide (PowerShell coverage) | FAIL | On-disk artifact 66.04% (8110/12280) from a two-folder run; R1 full-scan figure 94.45% over a 12280-line population that differs from CI's 18116. Awaiting the PR CI coverage file (COV-1, P7-T6). |
| Branch >= 75% | Not evaluated | Pester reports no branch metric, so the branch threshold does not apply to this language (`.claude/rules/powershell.md`). |
| No regression on changed lines | PASS | 0 production lines changed. |
| Positive / negative / edge | PASS | CR-N3 adds value-parameter skip rows (2), a Join-Path `-Credential` row, and switch rows (2) that confirm switches do not consume the next element. |
| Coverage exclusion policy | PASS | `config/poshqc-coverage.json` is not in the diff; no production path is excluded. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% line coverage (16381/18116, CI run 38730332356 at main `adb9aa5f0`). Post-change: 66.04% line coverage in the on-disk artifact (8110/12280; two-folder run at 03:22 local time, after the R1 record); R1 full-scan run recorded 94.45% (11598/12280). Change: not like-for-like; both local figures use a 12280-line population against CI's 18116 (difference -5836). New/changed-code coverage: 100.00% (0/0 production lines). Disposition: FAIL (COV-1, `awaiting_ci` on P7-T6, which reads the `poshqc / PowerShell QC` coverage file on the final PR head). Evidence: `evidence/baseline/ci-baseline.2026-10-16T00-11.md`, `evidence/qa-gates/coverage-comparison.2026-10-16T06-56.md`, `evidence/baseline/r1-coverage-population.2026-10-16T04-39.md`, `artifacts/pester/powershell-coverage.xml`.
- TypeScript: N/A - no changed files on the branch.
- Python: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | CR-N3 rows (HookReference suite lines 358-429) carry `# Arrange`, `# Act`, `# Assert`. |
| Actionable assertion messages | PASS | `-Because` texts list `Form:Name:Root` of each detected record. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No temporary files | PASS | Fixtures are here-strings. |
| Fixture names absent from hook trees | PASS | `evidence/qa-gates/r1-fixture-names.2026-10-16T05-47.md`. |
| Test file location | PASS | All suites and helpers under `tests/scripts/`. |
| File size <= 500 lines | PASS | Recomputed by this review: maximum 433 (`EpicStateIsolation.Helpers.ps1`); HookReference helper 410, HookReference suite 429. |

### 1.5 Policy Audit Requirement

PASS. This document records the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. R1 Phase 0 artifacts exist (`evidence/baseline/r1-*.md`: instructions read, branch state, line counts, token counts, coverage baseline and population, format, analyze, test).

### 2.2 Design Principles

PASS. CR-N2 consolidated the shared patterns and string-node enumeration; residual minor duplication is recorded as non-blocking CR-R2 in the code review.

### 2.3 Module & File Structure

PASS. All 18 changed code files at or below 500 lines.

### 2.4 Naming, Docs, and Comments

PASS. New functions use approved verbs, `[OutputType()]`, typed parameters and header comments; the Discovery helper header declares its load-order dependency (CR-N1).

### 2.5 After Making Changes - Toolchain Execution

| Stage | Result | Evidence |
|-------|--------|----------|
| 1 Formatting | PASS | `evidence/qa-gates/r1-ps-format.2026-10-16T06-10.md` (porcelain before and after empty). |
| 2 Linting | PASS | `evidence/qa-gates/r1-ps-analyze.2026-10-16T06-11.md` (returned without error). |
| 3 Type checking | N/A | Not applicable to PowerShell. |
| 4 Architecture-boundary tests | N/A | No boundary test covers `tests/scripts/`. |
| 5 Unit tests | PASS | `evidence/qa-gates/r1-ps-test.2026-10-16T06-26.md`; on-disk JUnit after the main merge: 6342 testcases, 0 failures, 0 errors. |
| 6 Contract / schema | N/A | No API or schema changed. |
| 7 Integration tests | N/A | No adapter changed. |

The R1 loop closed in one pass (`evidence/qa-gates/r1-loop-status.2026-10-16T06-26.md`). The merge `ef9b85698` brought two Codex hook suites and Python tests from main; the post-merge local JUnit includes both Codex suites with 0 failures.

### 2.6 Summarize and Document

PASS. `evidence/qa-gates/r1-findings-status.2026-10-16T06-56.md` lists each of the nine prior findings once with its disposition and evidence.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| PoshQC format | PASS | R1 format pass with no change. |
| PSScriptAnalyzer | PASS | R1 analyze returned without error. |
| `[OutputType()]` and typed parameters | PASS | `Get-EpicStateIsolationPattern` (with `ValidateSet`), `Get-EpicStateIsolationStringNode`, `Test-EpicStateIsolationSeparateValue` declare both. |
| No mutable module state | PASS | No new script-scope state. |
| Fail-fast error handling | PASS | `ValidateSet` rejects an unknown pattern name; pure functions return `$false`/`$null` on absent input. |
| Policy files untouched | PASS | No path under `.claude/` or `.github/` in the diff. |

Other languages: N/A (no changed files).

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester 5 with `#Requires` | PASS | Unchanged suite headers. |
| Data-driven rows | PASS | CR-N3 rows use `-ForEach` with `<Parameter>` and `<Switch>` names. |
| Fail-before for CR-N3 | PASS | `evidence/regression-testing/r1-cr-n3-fail-before.2026-10-16T05-56.md`. |
| Per-row CI results (both jobs) | Pending | PR CI does not exist yet (PC-1). |

## 5. Test Coverage Detail

All changed files are test suites or helpers under `tests/scripts/`, outside the coverage roots (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`). No production line changed, so the branch cannot lower the CI coverage figure through changed code; the I-3 splits are pure moves and remove no testcase (local post-split Passed counts equal baseline plus one probe each, section 6).

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| New testcases on the branch | 46 (HookReference 33, Branches 6, Discovery 4, probe rows 3) |
| On-disk JUnit (post-merge, two hook folders) | 224 suites, 6342 testcases, 0 failures, 0 errors, 0 skipped |
| Local post-split counts vs CI baseline | worktree-removal-gate 47 + ManifestBranch 5 = 52 (baseline 51); TargetResolution 20 + CallTarget 6 = 26 (baseline 25); command-exemption 60 + Selectors 61 = 121 (baseline 120); epic-scope 54 (baseline 54) |
| CI post-split counts | Pending P7-T5 (PC-1) |

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PoshQC format | No change (R1 pass) |
| PoshQC analyze | Returned without error |
| PoshQC test | Returned without error; on-disk JUnit 0 failures |
| Line counts | All 18 files <= 500 (maximum 433) |
| Determinism grep | 0 executable matches |
| Scope (`.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`, `artifacts/`) | 0 paths |

## 8. Gaps and Exceptions

### Identified Gaps

- COV-1 (blocking, `awaiting_ci`): PowerShell coverage FAIL against the on-disk artifact (66.04%). The local runner resolves a 12280-line population; the CI population is 18116 lines. Resolution: P7-T6 reads the coverage file of `poshqc / PowerShell QC` on the final PR head and records it against the 85% floor and the 90.42% baseline.
- PC-1 (pending-CI, non-blocking): AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24. Owner: orchestrator, plan Phase 7 (P7-T2..P7-T10).
- AC-26 PR-description half: verified by P7-T9 after the PR exists.
- `origin/main` has advanced to `b6be46b5e` (PR #948, issue #931: `scripts/dev-tools/Invoke-FullReleaseFlow*` and its tests) since the merge-base; no overlap with this branch's files. The branch should be brought up to date with main before the PR is opened.

### Approved Exceptions

None.

### Removed/Skipped Tests

None removed or skipped.

## 9. Summary of Changes

### Commits in This PR/Branch (since the prior review)

- `3cea50483` docs(935): record feature review artifacts (verdict REMEDIATION_REQUIRED, COV-1)
- `0ba688dac`, `7861ee2e3`, `973415060` docs(935): remediation cycle 1 plan and preflight revisions
- `bdc3d10c8` docs(935): R1 phase 0 baseline evidence
- `1ddf0182d` test(935): R1 header, readability and fixture-indent fixes (CR-N1, CR-N5, CR-N6)
- `e2aca1a95` test(935): R1 shared hook-reference patterns and predicates (CR-N2, CR-N8)
- `78e5f6d4e` test(935): R1 skip separate-token values of value parameters (CR-N3)
- `c40ee18db` docs(935): R1 final QA evidence
- `f0eba90a5` docs(935): R1 coverage comparison (COV-1)
- `ef9b85698` merge of `origin/main`

Earlier commits (`62c205808`..`793866195`) are listed in `policy-audit.2026-10-16T03-20.md` section 9.

### Files Modified

- Created: `EpicStateIsolation.HookReference.Helpers.ps1`, `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`, `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`, `enforce-prd-feature-before-planner.CallTarget.Tests.ps1` (claude-hooks); `enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1`, `...command-exemption.Selectors.Tests.ps1` (codex-hooks); `EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1` (claude-runtime).
- Edited: `EpicStateIsolation.Helpers.ps1`, `.Discovery.Helpers.ps1`, `.Compliance.Helpers.ps1`, the Branches, Predicate, legacy and Discovery guard suites, and the four I-3 originals.
- Feature folder documents and evidence (Markdown).

## 10. Compliance Verdict

### Overall Status: NOT COMPLIANT pending CI coverage (COV-1, `awaiting_ci`)

### Policy-by-Policy Summary

- General Unit Test Policy: FAIL on the coverage requirement (COV-1, awaiting CI); all other requirements PASS
- General Code Change Policy: PASS
- PowerShell code change and unit test policy: FAIL on the coverage gate (COV-1, awaiting CI); format, analyze and test PASS
- Quality tiers and coverage exclusion policy: PASS
- Evidence location policy: PASS
- Tonality: PASS

### Metrics Summary

PowerShell baseline 90.42% line coverage; on-disk post-change artifact 66.04% (two-folder run); R1 full-scan local figure 94.45% over a non-CI population; 0 production lines changed; 1 blocking finding (COV-1, `awaiting_ci`); 19 criteria pending CI (PC-1); prior CR-N1..CR-N8 closed (6 fixed, 2 accepted dispositions); 3 new non-blocking observations.

### Recommendation

No further autonomous remediation cycle is required. Bring the branch up to date with `origin/main`, open the pull request, and at S9 run plan Phase 7 (P7-T2..P7-T10) against the final PR head. P7-T6 resolves COV-1 from the CI coverage file; if that figure is below 85% or below 90.42%, COV-1 becomes an autonomous finding again. Include the operator follow-ups and decisions in the PR description (AC-26).

---

## Appendix A: Test Inventory

1. `R1 identifies <Case>` (11) and `R1 does not identify <Case>` (3) — HookReference suite
2. `R2 (a)`..`R2 (d)` — HookReference suite
3. `F-3 detects <Form>` (5), `F-3 ignores a Join-Path used only by <Reader>` (3), `F-3 process-spawning report includes a variable-built hook path`, `F-3 closure stays literal-seeded` — HookReference suite
4. `CR-N3 does not report the separate-token value of <Parameter>` (2), `CR-N3 binds Join-Path positionals after the separate-token value of -Credential`, `CR-N3 still reports a positional load after the switch <Switch>` (2) — HookReference suite (new in R1)
5. `F-1 non-compliant <Branch>` (3), `F-1 compliant <Branch>` (2), `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` — Branches suite
6. `AC-5b variable-built hook-load report <Surface>` (2), `F-3 non-vacuity <Surface> reports at least one variable-built hook load` (2) — Discovery suite
7. `baseline mock interception probe` — ManifestBranch, CallTarget, Selectors suites

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (executor, via MCP; R1):**
```
mcp__drm-copilot__run_poshqc_format   (R1 P4-T1)
mcp__drm-copilot__run_poshqc_analyze  (R1 P4-T2)
mcp__drm-copilot__run_poshqc_test     (R1 P4-T3, three folders; R1 P5-T2, scan_folders omitted)
```

**Reviewer commands (check-only):**
```
git rev-parse HEAD
git diff --stat origin/main...HEAD
git diff --name-only origin/main...HEAD
git diff 3cea50483 f0eba90a5 -- tests
git diff --stat f0eba90a5 ef9b85698 -- .claude/hooks .claude/lib .codex scripts tests/scripts tests/powershell config
git log --oneline 5bc97774b8322e57abb94dfac3cd0a000a136c5b..origin/main
awk 'END { print NR }' <each changed .ps1 file>
grep -n -E 'New-TemporaryFile|TestDrive|GetTempFileName|Get-Date|Start-Sleep|Start-Process|ProcessStartInfo' <each changed .ps1 file>
grep -E '^  .counter type="(LINE|INSTRUCTION)"' artifacts/pester/powershell-coverage.xml
stat -c '%y' artifacts/pester/powershell-coverage.xml
grep -o '<testsuite name="[^"]*" tests="[0-9]*" errors="[0-9]*" failures="[0-9]*"' artifacts/pester/pester-junit.xml
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```
