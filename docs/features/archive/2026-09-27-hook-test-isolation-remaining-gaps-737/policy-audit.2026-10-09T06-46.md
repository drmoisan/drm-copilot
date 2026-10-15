# Policy Compliance Audit: Hook test isolation remaining gaps (#737, bundled #746)

**Audit Date:** 2026-10-09
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737`
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` (commit `7eef473959317fdebcac8a8d902baccc990fe46d`, equal to the merge base)
**Head Branch:** `bug/hook-test-isolation-remaining-gaps-exec-737` (commit `60eabbf334871031f12ac870562df1e64da9c600`, 17 commits ahead, 0 behind)
**Work Mode:** `full-bug` (acceptance-criteria source: `spec.md`)

**Code Under Test:** 119 changed PowerShell test and test-helper files under `tests/scripts/claude-hooks` (87), `tests/scripts/codex-hooks` (29), `tests/scripts/claude-runtime` (2), and `tests/scripts/claude-lib/codex-routing` (1). 11 files are added and 108 are modified. The branch also adds or edits feature-folder documents and evidence under `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/`. No file under `.claude/hooks`, `.codex/hooks`, `.claude/lib`, `extensions/`, `scripts/`, `config/`, or `src/` changed.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 119 test files, 0 production files | 8430 in the configured run (7927 at baseline, +503) | PASS: 8420 pass, 0 fail, 10 skipped (the 10 skips are pre-existing) | 86.15% lines (14997 of 17409) | 86.16% lines (15000 of 17409) | N/A (no production file changed; test files are outside the coverage denominator) |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

**Note:** Pester measures command and line coverage only. No PowerShell branch percentage exists, and none is evaluated (`.claude/rules/powershell.md`).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (no TypeScript file changed)
- TypeScript post-change coverage artifact: N/A - out of scope (no TypeScript file changed)
- PowerShell baseline coverage artifact: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/coverage-total-baseline.2026-10-09T02-42.md
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml (inspected, not regenerated) and docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/coverage-total.2026-10-09T06-33.md
- Per-language comparison summary: Section 1.2.1 below

**Verdict rule applied:** numeric baseline and post-change coverage exist for the only language with changed files (PowerShell), so a PASS verdict is permitted. Changed or new production-code coverage is N/A because the production diff is empty.

---

## Executive Summary

**Overall verdict: COMPLIANT. Blocking findings: 0. Non-blocking observations: 3 (recorded in Section 8).**

The branch is a test-only change set. It makes the Pester suites on both hook surfaces hermetic against local orchestration state, replaces the fixed suite list with a discovery guard, extends the no-Python guard to `.codex/hooks`, and adds two parity tests and the #746 helper fix. The reviewer verified the following directly, without relying on executor statements:

- **Production diff is empty.** `git diff --name-only origin/epic/enforcement-hook-precision-integration...HEAD -- .claude .codex extensions scripts config src package.json` printed no path. Every non-documentation changed file is under `tests/`.
- **500-line cap holds.** `wc -l` over the four test directories reports a maximum of 500 lines (four files at exactly 500; none above).
- **Coverage artifact is fresh and meets the threshold.** `artifacts/pester/powershell-coverage.xml` (written 06:30, after the last code commit at 06:08) reports LINE `covered=15000 missed=2409`, which is 86.16% and at or above the 85% threshold. The JUnit file `artifacts/pester/pester-junit.xml` reports `tests="8430" errors="0" failures="0" disabled="10"` and contains zero `<failure` elements.
- **No temporary file, clock, RNG, network, or interpreter token** appears in any added line (an independent scan over the added lines of `git diff -U0` matched only the word "python" in the families parity test, which reads the Python literal as text).
- **Evidence placement is canonical.** `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no output, and the branch diff contains no path under `artifacts/`.
- **Post-commit drift is none.** `git diff --name-only 0f24b15d..HEAD` lists only files under the feature folder, so the QA evidence (06:08 to 06:34) describes the final test content.

Three non-blocking observations are recorded: a mutable script-scope memo in a test helper, the extent of mocking required by spec Decision 2, and unresolved process-spawning independence for six suites (a spec-sanctioned report-only outcome).

**Assumptions and limits of this review:**

- `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent from the worktree. The collector could not be run under the worktree isolation guard. The caller-specified base ref was used directly with `git diff` and `git log` as the baseline evidence, and the result is equivalent for a branch that is 0 commits behind the base.
- The bundled policy-audit template files under `extensions/drm-copilot/resources/templates/policy_audit/` were used because the MCP template resolver tool was not callable from this agent.
- Pester, PoshQC, and coverage were not re-executed. Their existing artifacts were inspected and cross-checked (counts, timestamps, coverage counters), as the review procedure requires.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | `evidence/qa-gates/local-state-differential-after.2026-10-09T06-17.md` reports `result=EQUAL` for every suite between the run without and the run with a hostile `artifacts/orchestration/epic-orchestrator-state.json`. New suites build all state in `BeforeAll` and `It` scopes. The full configured run (8430 tests) passed in the default order. Randomized order was not run. |
| Isolation | PASS | New rows target one behavior each (for example `AC-8 non-compliant ordering against a helper dot-source`, `AC-9 ...`). The probe rows each cover one seam class. |
| Fast execution | PASS | The new guard and parity suites do no process spawning and no network access. The whole configured run took 412 s (`pester-junit.xml` `time="412.425"`); no baseline duration was recorded, so no run-time regression figure is stated. |
| Determinism | PASS | No `Get-Date`, `Start-Sleep`, `Get-Random`, or wall-clock token appears in an added line. Suite and closure enumeration use ordinal sorting (`Discovery.Helpers.ps1` `Get-EpicStateDiscoveredSuite`). |
| Readability and maintainability | PASS | Descriptive row names carry the AC identifier; Discovery rows use Arrange/Act/Assert comments; assertions carry `-Because` text. |

### 1.2 Coverage and Scenarios

| Scenario class | Status | Evidence |
|---|---|---|
| Comprehensive coverage | PASS | Every guard function has a fixture row: Discovery (21 `It` definitions), Predicate (CR-2), Branches (CR-3), Probe (helper, harness, surface rows). Named-pattern run: `evidence/qa-gates/pester-targeted.2026-10-09T06-22.md` shows AC-8 through AC-21 patterns all `Failed=0`. |
| Positive flows | PASS | Each CR-2 path has a compliant row (`AC-8 compliant ...` through `AC-12 compliant ...`) that must produce no finding. |
| Negative flows | PASS | Each CR-2 path has a non-compliant row that must produce a finding; `AC-13 non-compliant ...` has seven rows. Fail-before evidence: `evidence/regression-testing/predicate-fail-before.2026-10-09T03-04.md` (6 rows fail against the unmodified predicate: the five CR-2 non-compliant rows and the CR-3 parse-error row). |
| Edge cases | PASS | Empty seam array (`AC-6 helper accepts an empty seam array`), empty and null registration sets (`AC-21 ...`), zero declarations and empty and null family sets (`AC-19 ...`), unparseable and absent suite files (`AC-2 missing suite`, `AC-2 unparseable suite`). |
| Error handling | PASS | Finding messages name the suite, seam, and violated rule; asserted by content in `AC-4 helper form naming the wrong seam is a finding`. |
| Concurrency | N/A | No concurrent behavior is introduced. |
| State transitions | N/A | No stateful component is introduced. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 86.15% line coverage (14997 covered, 2412 missed) -> Post-change: 86.16% line coverage (15000 covered, 2409 missed). Change: +0.01 percentage points. New/changed-code coverage: N/A - out of scope (no production file changed). Disposition: PASS. Evidence: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/coverage-total-baseline.2026-10-09T02-42.md; docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/qa-gates/coverage-total.2026-10-09T06-33.md; artifacts/pester/powershell-coverage.xml (reviewer recomputed 15000 / 17409 = 86.16%).

Additional reviewer-computed figures from the same artifact: instruction coverage 21337 covered and 3471 missed (86.01%); method coverage 1312 covered and 170 missed (88.53%). These are informational; no threshold attaches to them.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Arrange-Act-Assert structure | PASS | `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` lines 105 to 126 carry explicit Arrange/Act/Assert comments; the parity rows separate setup, call, and assertion. |
| Clear failure messages | PASS | `-Because` text on guard rows; the guard `AC-4` row prints the joined findings (`$findings -join '; '`). Fail-before output in `discovery-guard-fail-before.2026-10-09T03-18.md` shows the finding text naming suite, seam, and rule. |
| Unique test names | PASS | `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` is part of the passing full run. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| No external services | PASS | No network cmdlet or executable launch in the added lines. The new suites start no process. |
| No temporary files in tests | PASS | Reviewer scan of all added lines for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `Out-File`, `Set-Content`, `Add-Content`, `WriteAllText`, `New-Item`: no match. Executor scan: `evidence/qa-gates/hermeticity-scan.2026-10-09T06-10.md` (120 files, `matches=0`). The guard reads committed files through `Get-Content -Raw -LiteralPath` and `[System.IO.File]::ReadAllText`; reading is not file creation. |
| No reliance on mutable global state | PARTIAL (non-blocking) | `Discovery.Helpers.ps1` line 25 defines `$script:EpicStateParseCache`, a memo keyed by full source text. It is deterministic but is mutable script-scope state; see Section 8, observation O-1. |
| Test file location mirrors production | PASS | New tests are under `tests/scripts/claude-hooks`, `tests/scripts/claude-runtime`, and `tests/scripts/claude-lib/codex-routing`. No test file is placed under `.claude/`, `.codex/`, or `src/`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Audit artifact produced with numeric coverage | PASS | This document; Section 1.2.1 and the coverage table. |
| Coverage exclusion policy | PASS | The branch diff contains no change to `pester.runsettings.psd1`, `PSScriptAnalyzerSettings`, or any exclusion list; the coverage artifact lists 19 packages, all under `.claude/`, `.codex/`, and `scripts/`, and contains zero path under `/tests/`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Baselines recorded | PASS | `evidence/baseline/` holds format, analyzer, full Pester (7916 pass, 1 fail, 10 skipped), population, coverage, and upstream-verification artifacts. The baseline failure is the E4 local-state dependence that the change fixes. |
| Upstream dependencies merged first | PASS | `evidence/baseline/upstream-verification.2026-10-09T02-26.md` reports `UPSTREAM-VERIFIED: 3` (#736 via PR 853, #732 via PR 858, #850 via PR 857, each merge commit an ancestor of the base). |

### 2.2 Design Principles

| Principle | Status | Evidence |
|---|---|---|
| Simplicity first | PASS | Mocks are one-line null returns; a shared helper (`Register-EpicStateBaselineMock`) is used only where a suite is near the line cap or its dot-source is `-ForEach` bound (plan EP-2). |
| Reusability | PASS | Discovery, compliance, baseline, and scan-root logic are split into four helper files shared by the guard suites and the flagged suites. |
| Extensibility | PASS | Guard functions take an injectable `-ReadSource` script block; the seam requirement table is data (`Get-EpicStateSeamRequirement`). |
| Separation of concerns | PASS | Pure AST/text functions are separate from the two file-boundary readers (`Get-EpicStateDiscoveredSuite`, `Get-EpicStateSourceReader`). |

### 2.3 Module and File Structure

| Requirement | Status | Evidence |
|---|---|---|
| 500-line cap | PASS | Reviewer run `wc -l tests/scripts/claude-hooks/*.ps1 tests/scripts/codex-hooks/*.ps1 tests/scripts/claude-runtime/*.ps1 tests/scripts/claude-lib/codex-routing/*.ps1 \| sort -n \| tail`: maximum 500. Files at exactly 500: `enforce-epic-worktree-removal-gate.Tests.ps1` (modified), `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (codex, modified), `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` (modified), `EnforcementHooksNoPythonInvocation.Helpers.ps1` (unchanged). The cap is "may not exceed 500", so these pass with no headroom. Largest added file: `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` at 333 lines; the rewritten helper `EpicStateIsolation.Helpers.ps1` is 474 lines. |
| No-Python guard split | PASS | The guard and its helper were at the cap; scan roots moved to `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` (82 lines). `enforcement-hooks-no-python-invocation.Tests.ps1` has 34 additions and 46 deletions. |
| Public API compatibility | PASS | No production API changed. `Get-GuardedPowerShellFile` keeps its name and contract after the move. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | Functions use approved verbs and descriptive nouns (`Get-EpicStateSeamCensus`, `Test-EpicStateProbeCalledFromIt`). PSScriptAnalyzer reports `PSSA-TOTAL: 0` over 120 files (`evidence/qa-gates/pssa.2026-10-09T06-11.md`). |
| File headers and comments | PASS | Each new helper opens with a synopsis stating purpose, inputs, and the no-file/no-process invariant. CR-7 comments name the modules actually imported (verified against lines 99 and 111 of the two WorktreeResolution suites). |
| Stale comment text | PASS with Nit | The phrase "the three library modules are imported without" returns no match under `tests/` (`grep -rn` run by the reviewer). The scan-root helper header (lines 5 to 6) refers to "the scan-root rows file when that file exists", and no such file exists; recorded as Nit N-1 in the code review. |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|---|---|---|
| Format | PASS | `evidence/qa-gates/format-check.2026-10-09T06-10.md`: `FORMAT-CLEAN` for 120 files, `FORMAT-DRIFT-COUNT: 0`. Repository route: `format-mcp.2026-10-09T06-19.md` (`ok=true`, status listing unchanged before and after). |
| Lint | PASS | `pssa.2026-10-09T06-11.md`: `PSSA-TOTAL: 0`. Repository route: `analyze-mcp.2026-10-09T06-19.md`. |
| Type check | N/A | Not applicable for PowerShell. |
| Architecture-boundary tests | PASS | Included in the full configured run; no failure. |
| Unit tests | PASS | `pester-full.2026-10-09T06-33.md`: `Tests Passed: 8420, Failed: 0, Skipped: 10`. JUnit cross-check: `tests="8430" failures="0" disabled="10"`. |
| Contract/schema checks | PASS | `bundle-parity.2026-10-09T06-18.md`: 14 Python bundle-parity tests passed; `legacy-codex-hook-contracts` (43) and `CodexRouting.Manifest` (5) passed. |
| Integration tests | PASS | Part of the full configured run. The integration suite `codex-pretooluse-integration.Tests.ps1` passes with `Failed=0` (baseline `Failed=1`). |
| Loop closed in one pass | PASS | `evidence/qa-gates/qa-loop.2026-10-09T06-34.md`: `LOOP-PASSES: 1`, no file changed within the final pass. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Change summary and evidence | PASS | Section 9 below; per-AC artifact index in `evidence/qa-gates/ac-checkoff.2026-10-09T06-34.md`. |
| Error handling and logging | PASS | Guard failures are explicit findings or thrown errors with specific messages (`Invoke-EpicStateInterceptionProbe needs at least one seam name.`). The one catch in the probe helper (`Invoke-EpicStateProbeItemLiveRoot`) swallows an expected binding error after the seam call and records it with `Write-Verbose`; the comment states why only the call counts matter. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling and Baseline

| Requirement | Status | Evidence |
|---|---|---|
| PowerShell 7+ | PASS | New files carry `#Requires -Version 7.0`; PSScriptAnalyzer clean. |
| PoshQC format, analyze, test route | PASS | Run through the repository routes, `format-mcp.2026-10-09T06-19.md`, `analyze-mcp.2026-10-09T06-19.md`, `pester-full.2026-10-09T06-33.md`. |
| Change budget (1 to 3 production files) | N/A | Zero production PowerShell files changed. Test files do not count toward the threshold (`.claude/rules/powershell.md`). |

#### 3B.2 PowerShell Design and Safety

| Requirement | Status | Evidence |
|---|---|---|
| Advanced functions with named parameters | PASS | Helpers use `[CmdletBinding()]`, `[Parameter(Mandatory)]`, and `[ValidateSet('Claude','Codex')]` (`Baseline.Helpers.ps1` lines 36 to 55, 151 to 162). |
| Avoid `Invoke-Expression`, secrets, hard-coded credentials | PASS | No match in added lines. |
| Avoid global and mutable script-scope state | PARTIAL (non-blocking) | `$script:EpicStateParseCache` (observation O-1). The other script-scope variables are constants set once. |
| Fail explicitly; no silent catch-all | PASS | See 2.6. |
| Approved verbs | PASS | PSScriptAnalyzer `PSSA-TOTAL: 0`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive files under 500 lines | PASS | See 2.3. |
| No suppressions added | PASS | The single `SuppressMessageAttribute` in `enforce-gate-suites.EpicStateIsolation.Tests.ps1` line 284 predates this branch (the file's diff has 5 additions, 29 deletions, none of them a suppression). |

#### 3B.4 Running the Toolchain

Reported in 2.5. No toolchain step was waived or marked non-blocking by the executor.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|---|---|---|
| Pester 5; `*.Tests.ps1` naming | PASS | New suites declare `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`. Helper files use `.Helpers.ps1` or `.Cases.ps1` suffixes and are not discovered as suites. |
| Mirror production structure | PASS | See 1.4. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|---|---|---|
| Describe/Context/It, one behavior per It | PASS | Observed in all new suites. The one-line probe `It` rows each call a single probe. |
| Mock signature parity and registration order | PASS | Mocks are registered after the hook dot-source and module import, in the order the guard enforces (F1). Module seams use `-ModuleName`; script-scope seams do not. |
| Never mock executables directly | PASS | No `git`, `gh`, or `pwsh` mock added. |
| Mock sparingly | PARTIAL (non-blocking) | The change adds null-returning mocks to 105 suites. Spec Decision 2 explicitly accepts closure-wide over-inclusion and supersedes #709 D9; the policy conflict is resolved by the spec. See observation O-2. |
| Deterministic Test Requirements (no network, PATH, working-directory assumptions) | PASS | Paths are resolved from `$PSScriptRoot`; no ambient PATH use in new rows. One pre-existing suite (`codex-pretooluse-integration.Tests.ps1`) still resolves `pwsh` through `Get-Command`; that line is unchanged by this branch. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names; AC traceability | PASS | Rows are named `AC-<n> ...` and map one to one to the spec criteria; the targeted run reports per-pattern totals. |
| Prohibited: weakened assertions | PASS with note | No assertion text was removed. The E4 change adds launcher environment variables for one hook (`codex-pretooluse-integration.Tests.ps1` lines 95 to 100), which changes the context in which that child process runs. Recorded as code-review finding F-4 (non-blocking). |

#### 4B.4 Running the Toolchain

Reported in 2.5.

---

## 5. Test Coverage Detail

### Production code coverage

No production file changed, so changed-line and new-file coverage are not applicable. Repo-wide PowerShell line coverage is 86.16% (threshold 85%): PASS. No regression: +0.01 percentage points.

### Guard and parity test inventory by acceptance criterion (from `pester-targeted.2026-10-09T06-22.md` and `guard-final.2026-10-09T06-08.md`)

| Group | Rows | Result |
|---|---|---|
| AC-4 compliance rows, one per discovered suite and fixture | 190 | 190 pass, 0 fail |
| AC-6 probe-presence rows and fixtures | 95 | 95 pass |
| AC-7 interception rows (Claude and Codex surfaces) | 4 | 4 pass |
| AC-8 to AC-12 CR-2 predicate rows | 2 each | 10 pass |
| AC-13 CR-3 branch rows | 10 | 10 pass |
| AC-15 scan-root rows | 5 | 5 pass |
| AC-17 parity rows (two runtimes) | 80 | 80 pass |
| AC-18 function-inventory rows | 3 | 3 pass |
| AC-19 families parity rows | 9 | 9 pass |
| AC-20 and AC-21 registration-helper rows | 2 each | 4 pass |
| Discovery container total | 290 | 290 pass |
| Probe container total | 10 | 10 pass |

Discovered population at the final run: 130 Claude-hook suites and 52 Codex-hook suites (`POPULATION-TOTAL: 182`). The guard asserts non-vacuity per surface and never a literal count.

---

## 6. Test Execution Metrics

| Metric | Value | Source |
|---|---|---|
| Baseline full configured run | 7916 passed, 1 failed, 10 skipped | `evidence/baseline/pester-full-baseline.2026-10-09T02-42.md` |
| Final full configured run | 8420 passed, 0 failed, 10 skipped | `evidence/qa-gates/pester-full.2026-10-09T06-33.md` |
| JUnit cross-check by reviewer | 8430 testcases, 0 `<failure`, `disabled="10"` | `artifacts/pester/pester-junit.xml` |
| Targeted run (115 files) | 2953 passed, 0 failed | `evidence/qa-gates/pester-targeted.2026-10-09T06-22.md` |
| Population run without local checkpoint | 5258 passed, 0 failed | `evidence/qa-gates/pester-population-final.2026-10-09T06-12.md` |
| Population run with hostile checkpoint present | 5258 passed, 0 failed, every suite `EQUAL` | `evidence/qa-gates/pester-population-with-local-checkpoint.2026-10-09T06-17.md` |
| Hostile checkpoint cleanup | `CHECKPOINT-PRESENT-AFTER: False`, no status line under `artifacts/` | `evidence/qa-gates/hostile-checkpoint-deleted.2026-10-09T06-17.md` |
| Freshness against base | 0 commits behind (rechecked by reviewer: `git rev-list --count HEAD..origin/epic/enforcement-hook-precision-integration` printed 0) | `evidence/qa-gates/freshness.2026-10-09T05-52.md` |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| Format | PASS | 120 of 120 files clean |
| Lint | PASS | 0 findings across 120 files |
| Type check | N/A | PowerShell |
| Tests | PASS | See Section 6 |
| Coverage threshold (line >= 85%) | PASS | 86.16% repo-wide |
| Coverage no-regression | PASS | +0.01 percentage points; production diff empty |
| Production code unchanged | PASS | Empty diff over `.claude`, `.codex`, `extensions`, `scripts`, `config`, `src` (reviewer-run); `evidence/qa-gates/hooks-unchanged.2026-10-09T06-10.md` |
| Bundle parity | PASS | `mirror-check.2026-10-09T06-10.md` found no mirror for any changed file; the independent search of `extensions/drm-copilot/resources` for the new helper and test names returned nothing |
| Workflow files modified (`modified-workflow-needs-green-run`) | N/A | No path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` changed |
| Tonality | PASS | Reviewer scan of the new test and helper files for hyperbole, humor, and non-ASCII characters returned no match; comments are factual |

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap. The following are non-blocking observations. They do not meet the meaningful-FAIL-or-PARTIAL bar that triggers remediation, so no remediation inputs file was produced.

- **O-1 (non-blocking, Minor).** `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` line 25 and lines 79 to 94 hold `$script:EpicStateParseCache`, a mutable script-scope memo keyed by the full source text. Rule: `.claude/rules/powershell.md` "Avoid global state and mutable script-scoped variables". The memo is deterministic and bounded by the committed tree, but it retains every parsed source text for the session. Optional follow-up: key by a hash or drop the cache if run time permits.
- **O-2 (non-blocking, Info).** The baseline mocks add a null-returning mock to 105 suites, against the "mock sparingly" guidance in `.claude/rules/powershell.md`. Spec Decision 2 accepts this and supersedes #709 D9. The interception probe and the with/without hostile checkpoint differential are the controls that show the mocks do not change outcomes.
- **O-3 (non-blocking, Info).** Six process-spawning suites cannot be proven independent of local state statically (`evidence/other/process-spawning-report.2026-10-09T05-29.md`, `REPORT-TOTAL: 6`, listed in `evidence/other/follow-ups.md`). The spec (Decision 4, AC-5) sanctions report-only handling. The differential found no outcome difference for any of them.

### Approved Exceptions

- **Plan interpretations PI-1, PI-3 and deviations DEV-1, DEV-2** are recorded in `plan.2026-10-08T13-54.md` (v1.8). PI-1 compares before and after counts after subtracting probe rows added by design (AC-6 requires the added row). PI-3 records that six of seven AC-13 branches already passed against the unmodified predicate, with an absence-of-test dossier (`evidence/regression-testing/fail-before-exception.2026-10-09T03-05.md`). DEV-1 renames the execution branch. DEV-2 isolates `codex-pretooluse-integration.Tests.ps1` from a local item checkpoint by a test-side change, because the hook derives its repository root from its own script location. None of these changes a hook.

### Removed/Skipped Tests

- No test was removed or skipped by this branch. One `Context` ("Non-vacuity floor for the registration count") that documented the legacy `@($null).Count` expression was replaced by direct helper rows, as AC-21 requires. The 10 skipped tests are pre-existing (baseline: `Skipped: 10`).

### Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 and printed nothing.
- The branch diff contains zero path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All feature evidence is under `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/{baseline,regression-testing,qa-gates,other}/`. `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none required; the executor wrote only canonical paths (`evidence/qa-gates/evidence-location.2026-10-09T06-35.md`: `EVIDENCE-OUTSIDE-FEATURE: 0`).

### Rejected Scope Narrowing

None detected. The caller prompt lists the scope of the branch diff and does not exclude any language or file set. The full branch diff against the resolved base was audited.

---

## 9. Summary of Changes

### Commits in This PR/Branch

17 commits ahead of `origin/epic/enforcement-hook-precision-integration`, from `69e8b935` (discovery helpers and census evidence) to `60eabbf3` (final commit check-off). Test-bearing commits:

- `345763ad`, `2c90909d`, `0edc4ee9`: harden the predicate (CR-2, CR-3), add the discovery guard, add the baseline helper and probe.
- `02a71964`, `e9ee9368`, `5bb18a4f`: baseline mocks and probe rows in the flagged suites, EG-1 to EG-27.
- `1a9848dd`: scan `.codex/hooks` in the no-Python guard.
- `aa643790`: preimplementation-gate behavioral parity test.
- `53bf7720`: `GENERATED_AGENT_FAMILIES` parity test.
- `987a1bdc`: #746 registration helper fix.
- `0f24b15d`: probe harness module-family isolation and a portable case path.
- `974cb692`, `ceee8bfa`, `60eabbf3`: documents and evidence only.

### Files Modified

| Area | Added | Modified | Notes |
|---|---|---|---|
| `tests/scripts/claude-hooks` | 9 | 78 | Helpers (4 new, 1 rewritten), guard suites (4 new, 1 reduced), parity suite and cases, 70 flagged suites |
| `tests/scripts/codex-hooks` | 0 | 29 | Flagged Codex suites and `codex-pretooluse-integration.Tests.ps1` |
| `tests/scripts/claude-runtime` | 1 | 1 | Scan-root helper (new), no-Python guard (edited) |
| `tests/scripts/claude-lib/codex-routing` | 1 | 0 | Families parity test |
| `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737` | many | few | Plan, spec check-offs, evidence, lifecycle documents |
| Production, config, mirrors | 0 | 0 | Verified empty |

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT (0 blocking findings; 3 non-blocking observations)

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PASS. 500-line cap, separation of concerns, explicit error handling, no dependency added, no breaking API.

#### Language-Specific Code Change Policy (Section 3)

PASS with one non-blocking PARTIAL (mutable script-scope memo, O-1).

#### General Unit Test Policy (Section 1)

PASS. Coverage 86.16% (threshold 85%); no temporary files; no clock, RNG, or network use; test location mirrors production; the coverage exclusion policy is not engaged (no exclusion change).

#### Language-Specific Unit Test Policy (Section 4)

PASS with one non-blocking PARTIAL (mock volume, accepted by spec Decision 2, O-2).

### Metrics Summary

| Metric | Value |
|---|---|
| Blocking findings | 0 |
| Non-blocking observations | 3 (O-1, O-2, O-3) |
| Repo-wide PowerShell line coverage | 86.16% (baseline 86.15%) |
| Full-run result | 8420 passed, 0 failed, 10 skipped |
| Production files changed | 0 |
| Largest changed file | 500 lines (cap 500) |

### Recommendation

Proceed to the pull-request step. No remediation is required. The three observations may be filed as optional follow-ups. The code-review and feature-audit artifacts for this run carry the same blocking count of 0.

---

## Appendix A: Test Inventory

### Complete Test List

New test files (11 added; line counts from `wc -l`):

- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (333 lines): AC-2 to AC-6 discovery and compliance rows.
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1` (280 lines): AC-8 to AC-12 CR-2 rows.
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1` (197 lines): AC-13 CR-3 rows.
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1` (123 lines): AC-6 and AC-7 probe and helper rows.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` (206 lines): AC-17 and AC-18.
- `tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1` (136 lines): AC-19.
- Support files: `EpicStateIsolation.Baseline.Helpers.ps1` (177), `EpicStateIsolation.Compliance.Helpers.ps1` (207), `EpicStateIsolation.Discovery.Helpers.ps1` (259), `enforce-orchestration-preimplementation-gate.Parity.Cases.ps1` (178), `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` (82).

Edited existing suites: 108 files (rewritten guard helper `EpicStateIsolation.Helpers.ps1` at 474 lines; the legacy guard `enforce-gate-suites.EpicStateIsolation.Tests.ps1` at 350 lines; `enforcement-hooks-no-python-invocation.Tests.ps1`; `codex-pretooluse-integration.Tests.ps1`; and 104 flagged hook suites). The per-suite change is a baseline mock block and one probe row, except the CR-7 comment edits in two suites.

## Appendix B: Toolchain Commands Reference

Commands the reviewer ran (check-only, no mutation of tracked files):

```bash
git rev-list --count HEAD..origin/epic/enforcement-hook-precision-integration
git rev-list --count origin/epic/enforcement-hook-precision-integration..HEAD
git diff --name-only origin/epic/enforcement-hook-precision-integration...HEAD -- .claude .codex extensions scripts config src package.json
git diff --numstat origin/epic/enforcement-hook-precision-integration...HEAD -- tests
git diff --name-only 0f24b15d..HEAD
git diff -U0 origin/epic/enforcement-hook-precision-integration...HEAD -- tests
wc -l tests/scripts/claude-hooks/*.ps1 tests/scripts/codex-hooks/*.ps1 tests/scripts/claude-runtime/*.ps1 tests/scripts/claude-lib/codex-routing/*.ps1
grep -rn "three library modules are imported without" tests
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

Existing artifacts inspected (not regenerated): `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`, and the evidence files cited in each section.

Repository toolchain routes used by the executor (recorded in the evidence): `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `Invoke-PoshQCTest` through the PoshQC module, and direct `Invoke-Pester` over explicit file lists for counts.
