# Policy Compliance Audit: epic-progress-report skill (Issue #1093)

**Audit Date:** 2026-11-07
**Branch:** `feature/epic-progress-report-skill` @ `cd19d42c4430a1bba81758db79cb1ea5167ffcb0`
**Base:** `main`; merge base `a936a1d93c37592e6b2c960499767e54779f70f3` (resolved base `origin/main` in `artifacts/pr_context.summary.txt`)
**Work Mode:** full-feature (AC sources: `spec.md` and `user-story.md`)
**Prior reviews:** none (first review of this branch)
**Code Under Test:**
- `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` (NEW path, moved entry; 475 logical lines)
- `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` (NEW path, moved and trimmed hub; 248)
- `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` (NEW; 286)
- `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1` (NEW, moved functions; 232)
- `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` (NEW, moved functions; 196)
- `scripts/dev-tools/Get-EpicProgressReport.ps1` (MODIFIED, now a forwarder; 24)
- `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (DELETED, moved)
- Bundle byte copies of the five scripts and `SKILL.md` under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/`
- `.claude/skills/epic-progress-report/SKILL.md` (NEW, 338 lines, Markdown)
- Configuration: `config/poshqc-coverage.json` (adds root `.claude/skills`), `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (six entries), `extensions/drm-copilot/CHANGELOG.md`
- Tests: six suites under `tests/scripts/claude-skills/epic-progress-report/` (NEW), `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (rewritten as the forwarder suite), `tests/fixtures/dev-tools/Get-EpicProgressReport.ForwarderTarget.Fixture.ps1` (NEW), `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` (DELETED, moved)
- Documentation and evidence: feature folder `docs/features/active/2026-11-06-epic-progress-report-skill-1093/` and `docs/features/potential/promoted/2026-11-06-epic-progress-report-skill.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 6 production (+5 bundle copies), 8 test/fixture | 163 in touched suites; 14461 tree-wide | 163 pass, 0 fail (reviewer); 14461 run, 0 fail, 10 skipped (executor P6-T13 merged shard run) | 93.85% lines repo-wide (derived, see 1.2.1); merged entry 91.18%, merged Logic 100% | 93.86% lines repo-wide (`artifacts/pester/powershell-coverage.xml`, 23247/24767) | 90.82% entry; 100% Logic, State, Metrics, Render, forwarder |
| Python | 0 files | N/A | N/A | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

Branch coverage: PowerShell is exempt from the branch threshold (Pester measures no branch counter; `.claude/rules/powershell.md`). No branch-capable language has changed files.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files in the branch diff
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files in the branch diff
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/baseline/pester-coverage.2026-11-06T23-56.md` (merged entry 93/102 = 91.18%, merged Logic 227/227 = 100%) and the #1080 final audit's derived repo-wide figure 23175/24694
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (merged eight-shard run over the full scan folders, written 2026-11-07 01:33 UTC; JUnit 14461 tests) plus `evidence/qa-gates/pester-coverage.2026-11-07T01-04.md` and `evidence/qa-gates/coverage-delta.2026-11-07T01-04.md`
- Per-language comparison summary: section 1.2.1 of this audit

---

## Executive Summary

The branch adds the user-invocable `/epic-progress-report` skill, moves the #1080 report script into `.claude/skills/epic-progress-report/scripts/` as the single source of truth, splits the Logic file into a hub plus State, Metrics and Render files, adds `-ResetBaseline`, `-PairSamples`, an optional `-StartUtc` and a versioned state document under `.claude/state/`, leaves a parameterless forwarder at `scripts/dev-tools/Get-EpicProgressReport.ps1`, mirrors the skill folder into the Claude bundle, lists it in the core pack manifest, and adds `.claude/skills` to the PoshQC coverage roots.

The reviewer re-ran at HEAD: formatter 0 differences and PSScriptAnalyzer 0 findings on all 19 changed `.ps1` files with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`; the seven touched suites 163 of 163 passed (Pester 6.2.0); an AST comparison confirmed that 29 of the 32 merged function bodies are byte-identical to the merge base, the other three being the intended changes (`Resolve-EpicProgressSetting`, `Write-EpicProgressState`, `Invoke-EpicProgressReport`); the six bundle files are byte-identical to the canonical files; the coverage artifact gives 90.82% and 100% per file. A ten-mutant probe on a scratch copy of the State and entry code killed nine mutants; one survived (finding F1).

One blocking finding exists: F1, the spec's write rule for `-PairSamples` when the sample rule adds no sample (a run within 90 seconds of the last sample) has no discriminating test. The production code is correct; the gap is in scenario completeness. Remediability: autonomous. Five acceptance criteria depend on CI on the PR head and remain pending; their local evidence is green.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ⚠️ `.claude/rules/general-unit-test.md` (Scenario Completeness: finding F1)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `check_quality_tiers.py` reports OK, 29 entries, 29 discovered projects; `scripts/dev-tools` is T4)

**Language-specific policies evaluated:**
- N/A Python (zero `.py` paths in the branch diff)
- ✅ `.claude/rules/powershell.md`
- N/A Bash, TypeScript, C#

**Temporary artifacts cleanup:**
- ✅ `git status --short` is empty at HEAD before and after every reviewer run.
- ✅ Reviewer formatter, analyzer, Pester and mutation scripts and the scratch tree were written to the session scratchpad outside the repository.

---

## Rejected Scope Narrowing

None. The caller prompt named the item worktree, branch, base, merge base, head, feature folder, PR context artifacts and the full-feature AC sources, and asked for the full feature-review contract. It did not narrow scope to a plan, phase or file subset. The audit covers the full diff `a936a1d93..cd19d42c4` (67 files).

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`: exit code 0, no output.
- No changed path starts with `artifacts/`; no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/` is in the branch diff.
- All evidence is under `docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Per-test fixtures in `BeforeEach`; executor seeded shuffles 7, 41, 1093 (163 passed each, `pester-shuffled-order.2026-11-07T01-04.md`); fresh single-process run over `tests/scripts` (14461 tests, 0 failed, `pester-single-process.2026-11-07T01-27.md`); eight-shard run 0 failed. |
| **Isolation** | ✅ PASS | One behavior per `It`; State functions tested directly; entry tested through mocked seams. |
| **Fast Execution** | ✅ PASS | Reviewer run of the seven suites completes in seconds except the two forwarder child-process cases. |
| **Determinism** | ✅ PASS | Fixed epoch fixtures; `Get-EpicProgressUtcNow` mocked; no wall-clock read in tests (reviewer grep). |
| **Readability & Maintainability** | ✅ PASS | Behavior-stating `It` names; fixture comments state expected values. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester-coverage.2026-11-06T23-56.md` (91.18%, 100%). |
| **No Coverage Regression** | ✅ PASS | Entry 91.18% to 90.82% with the same nine kinds of uncovered lines (native wrappers 172, 186, 200; clock 282; entry block 467 to 473); every changed line in `Invoke-EpicProgressReport` and `Write-EpicProgressState` is covered. Split files 100%. |
| **New Code Coverage** | ✅ PASS | 90.82% entry; 100% Logic, State, Metrics, Render, forwarder; all at or above the 85% governing threshold (root `CLAUDE.md` states no threshold, so the default governs). |
| **Comprehensive Coverage** | ✅ PASS | Missed lines at HEAD listed above; none is a changed statement. |
| **Positive Flows** | ✅ PASS | Reset, pairing, stored-start, legacy-state golden and both modes tested. |
| **Negative Flows** | ✅ PASS | Combined switches, absent start, unknown version, unparseable text, forwarder validation errors. |
| **Edge Cases** | ⚠️ PARTIAL | Finding F1: `-PairSamples` within 90 seconds of the last sample (sample rule adds nothing) is untested; reviewer mutant G (drop `-or $PairSamples` from the write condition) survived. Other boundaries (2 versus 3 intervals, 0/1/2/13/14 samples, zero-rate range) are tested. |
| **Error Handling** | ✅ PASS | Terminating errors name `-StartUtc`/`-ResetBaseline` and the combined switches; asserted before any git call. |
| **Concurrency** | N/A | Single-threaded command-line tool. |
| **State Transitions** | ⚠️ PARTIAL | State document transitions (legacy array to version 1, reset, pairing) are tested except the pairing write without a new sample (F1). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.85% lines (repo-wide, derived) -> Post-change: 93.86% lines. Change: +0.01% lines. New/changed-code coverage: 90.82% (canonical entry), 100% (Logic, State, Metrics, Render, forwarder). Disposition: PASS. Evidence: `evidence/baseline/pester-coverage.2026-11-06T23-56.md`, `evidence/qa-gates/pester-coverage.2026-11-07T01-04.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: N/A - zero changed Python files in the branch diff. Disposition: N/A.
- TypeScript: N/A - zero changed TypeScript files in the branch diff. Disposition: N/A.
- C#: N/A - zero changed C# files in the branch diff. Disposition: N/A.

Derivation and freshness (assumptions stated): the baseline repo-wide figure is the #1080 final audit's derived 23175/24694 at `468a8d43c`, which is an ancestor of the merge base; `git diff --name-only 468a8d43c a936a1d93 -- '*.ps1' '*.psm1'` is empty, so the figure holds at the merge base. The post-change artifact is the merged eight-shard run (JUnit 14461 tests), so its root counter is repo-wide: 23247 covered, 1520 missed. The denominator rises by 73, which equals the per-file change (402 new measured lines minus 329 removed). The only production commit after the run is `cd19d42c4`, which adds comment-based help to the forwarder; the artifact's forwarder line numbers already match the HEAD file (line 24 is the final `exit`), so the run measured the HEAD content. No other language has changed files.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-ExpectedMessage` patterns name the parameters; state assertions compare joined `ts` lists. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Fixture, single call, assertions. |
| **Document Intent** | ✅ PASS | Comments state the expected kept samples and golden provenance. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | git, gh and cswap are mocked. The two forwarder child-process cases start the current `pwsh` executable, as the spec's test inventory requires; they fail at parameter validation before any git call or write (Info item in the code review). |
| **Use Mocks/Stubs** | ✅ PASS | All nine seams mocked; forwarder in-process cases mock `Join-Path` for the canonical path only. |
| **Environment Stability** | ✅ PASS | No TestDrive or temporary file (reviewer grep); directory creation tested with mocked file cmdlets; `-WhatIf` case writes nothing; `$global:LASTEXITCODE` saved and restored. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit plus `evidence/qa-gates/self-review.2026-11-07T01-34.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` (DEC-1 to DEC-11, AC-01 to AC-31), `user-story.md`, research D1 to D8. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-06T17-53.md`; phase 0 policy reads recorded. |
| **Document the plan** | ✅ PASS | Per-task commits P0-T1 to P6-T13. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Forwarder of five statements with no parameter surface; pure State functions. |
| **Reusability** | ✅ PASS | One copy of the logic in the repository (bundle copy is the published payload). |
| **Extensibility** | ✅ PASS | Versioned state document with a legacy reader. |
| **Separation of concerns** | ✅ PASS | State, Metrics, Render are pure; all I/O in entry-script wrappers; AST constraint tests pass. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Split follows DEC-5; moved bodies byte-identical (reviewer AST comparison). |
| **At or below the 800-line hard limit** | ✅ PASS | Reviewer logical line counts (`@(Get-Content -LiteralPath).Count`): production 475, 248, 286, 232, 196, 24; tests 563, 338, 323, 252, 202, 188, 121, fixture 39. None at or above 700; no Warning. `config/file-size-baseline.json` not in the branch diff. |
| **Public vs internal** | ✅ PASS | Canonical parameter surface documented; forwarder declares none. |
| **No circular dependencies** | ✅ PASS | Hub dot-sources three leaf files; none dot-sources the hub. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs and `EpicProgress` noun prefix. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function; script help documents all 15 parameters (test-pinned). |
| **Comment why, not what** | ✅ PASS | Epoch-seconds rationale, read-before-git ordering, reset sample discard. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Reviewer `Invoke-Formatter` comparison on 19 files: 0 differences. |
| **2. Linting** | ✅ PASS | Reviewer `Invoke-ScriptAnalyzer` on 19 files: 0 findings. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | Reviewer 163/163; executor 14461 tree-wide, 0 failed. |
| **Architecture boundary / contract / integration** | ✅ PASS | Python push-down contract tests 106 passed (executor `python-contract-tests.2026-11-07T01-34.md`; a reviewer re-run was refused by the preimplementation hook); skill contract suite 17/17 (reviewer). |
| **Full toolchain loop** | ✅ PASS | Clean single pass at HEAD. |
| **Explicit reporting** | ✅ PASS | Evidence under the feature `evidence/` tree. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Per-task commit messages; CHANGELOG `### Added` entry (DEC-10). |
| **Design choices explained** | ✅ PASS | `spec.md` decisions; skill notes. |
| **Update supporting documents** | ✅ PASS | SKILL.md, script help, CHANGELOG. |
| **Provide next steps** | ✅ PASS | Owner confirmation items listed in `spec.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 differences (reviewer; `powershell-format.2026-11-07T01-02.md`). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings (reviewer; `powershell-analyze.2026-11-07T01-02.md`). |
| **Fix all findings** | ✅ PASS | No open findings. |
| **PowerShell 7+ compatible** | ✅ PASS | Tests ran on PowerShell 7 with Pester 6.2.0. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType]` on every new function. |
| **Parameter validation** | ✅ PASS | `ValidateRange`/`ValidateSet` kept; combined switches rejected before I/O. |
| **ShouldProcess for state change** | ✅ PASS | `Write-EpicProgressState` keeps `SupportsShouldProcess`; directory creation and write are inside the `ShouldProcess` block (manual inspection, since PSSA does not check the `Write` verb). |
| **Wrapper seams** | ✅ PASS | No new native call; AST tests scan all five canonical files. |
| **Avoid global state** | ✅ PASS | Only the forwarder resets `$global:LASTEXITCODE`, as DEC-1 settles. |
| **Error handling** | ✅ PASS | `throw` with actionable messages. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | See 2.3. |
| **Approved verbs** | ✅ PASS | `ConvertFrom`, `ConvertTo`, `Resolve`, `Merge`, `Select`, `Write`. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 differences. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 163/163 touched suites; 14461 tree-wide, 0 failed (executor). |
| **Rerun loop if needed** | ✅ PASS | No rerun needed at HEAD. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester 5-compatible syntax; run on 6.2.0 as `Invoke-PoshQCTest` requires. |
| **Use PoshQC Configuration** | ✅ PASS | Executor coverage via `Invoke-PoshQCTest` and `Invoke-PoshQCParallelTest`. |
| **PowerShell 7+ Compatible** | ✅ PASS | See 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 163 tests across seven suites. |
| **Test Behavior Over Implementation** | ⚠️ PARTIAL | Reviewer mutants on a scratch copy: A pairing step 1 (6 new failures), B version check removed (1), C reset ignores passed start (1), D stored done beats reset (2), E stored weekly ignored (3), F reset keeps samples (1), G `-PairSamples` dropped from the write condition (0, survived; F1), H combined switches allowed (1), I default state folder changed (1), J directory creation removed (2). 9 of 10 killed. |
| **Mocking Used Sparingly** | ✅ PASS | Mocks only at the I/O seams. |
| **Organization** | ✅ PASS | Suites mirror the production files under `tests/scripts/claude-skills/epic-progress-report/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | ✅ PASS | `*.Tests.ps1`; fixture under `tests/fixtures/`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per function or seam group. |
| **Logical Grouping** | ✅ PASS | As above. |
| **Docstrings/Comments** | ✅ PASS | File header comments state scope and isolation. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | Executor runs; reviewer used plain `Invoke-Pester` without coverage so the canonical coverage artifact was not overwritten. |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### Get-EpicProgressReport.ps1 (canonical entry; entry suite 35 tests, forwarder suite 8)

**Coverage:** 90.82% (89 of 98 lines). Missed: 172, 186, 200 (native wrappers), 282 (clock seam), 467, 468, 469, 471, 473 (entry block, skipped when dot-sourced).

### Get-EpicProgressReport.Logic.ps1 (38 tests), State.ps1 (31), Metrics.ps1 (20), Render.ps1 (14)

**Coverage:** 100% each (66/66, 79/79, 52/52, 102/102).

### scripts/dev-tools/Get-EpicProgressReport.ps1 (forwarder)

**Coverage:** 100% (5 of 5 lines).

**Not covered:** only the seams listed above, by design.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (touched suites) | 163 | ✅ |
| Tests Passed | 163 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Tree-wide merged shard run (executor) | 14461 tests, 0 failed, 10 skipped | ✅ |
| Seeded shuffles (executor) | 3 seeds, 0 failed | ✅ |
| Python push-down contract tests (executor) | 106 passed, 0 failed | ✅ |
| Reviewer mutants | 9 of 10 killed | ⚠️ |
| Code Coverage | 90.82% to 100% per file (branch: not measured by Pester) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | Comparison with repository settings on 19 files | 0 differences | ✅ |
| PSScriptAnalyzer | Analyzer with repository settings on 19 files | 0 findings | ✅ |
| Pester Tests | `Invoke-Pester` over the seven touched suites | 163 passed, 0 failed | ✅ |
| Bundle parity | `cmp` of six canonical files against the bundle | identical | ✅ |
| Tier classification | `check_quality_tiers.py --repo-root <worktree>` | OK, 29 entries | ✅ |

**Notes:** No PR exists yet, so CI has not run on this head. AC-12, AC-30, AC-31, US-AC-11 and US-AC-15 are CI-dependent and pending.

---

## 8. Gaps and Exceptions

### Identified Gaps

- F1 (Major, blocking, autonomous): no test covers the spec write rule "the state is written when ... `-PairSamples` was given" for a run in which the sample rule adds no sample. The entry-suite `-PairSamples` case stores a newest sample 300 seconds old, so the sample rule writes anyway. Removing `-or $PairSamples` from the write condition leaves every test green. In the documented cadence-change procedure, a one-shot `-PairSamples` run within 90 seconds of a scheduled TL;DR run would then print paired figures and discard the pairing without an error.

Non-blocking items (details in `code-review.2026-11-07T01-41.md`): NB-1 Minor (AC-09's stated range-diff command cannot show `R` entries by design), and Info items.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None.** Every #1080 `It` name is preserved except the one replacement the spec names (`it-name-comparison.2026-11-07T01-05.md`).

---

## 9. Summary of Changes

### Commits in This PR/Branch

56 commits from `e35e3c0ad` to `cd19d42c4`, no merge commit.

### Files Modified

1. `.claude/skills/epic-progress-report/` (NEW): SKILL.md and five scripts.
2. `scripts/dev-tools/Get-EpicProgressReport.ps1` (MODIFIED): forwarder.
3. `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (DELETED).
4. Bundle mirror (NEW), `core.json` (+6 entries), `config/poshqc-coverage.json` (+1 root), CHANGELOG.
5. Tests and fixture as listed above; feature documentation and evidence.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ REMEDIATION REQUIRED - one blocking finding (F1)

All toolchain, coverage, file-size, evidence-location and tier gates pass. F1 is a test-completeness gap on a stated write rule and is remediable inside this item by adding one entry-suite case.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, plan, per-task commits
- ✅ Design Principles: single source, pure State functions
- ✅ Module & File Structure: largest file 563 lines
- ✅ Naming, Docs, Comments: help complete
- ✅ Toolchain Execution: clean single pass
- ✅ Summarize & Document: CHANGELOG and skill notes

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: 0 differences, 0 findings
- ✅ PowerShell Design & Safety: ShouldProcess around both writes
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent and deterministic
- ⚠️ Coverage & Scenarios: coverage met; edge case F1 untested
- ✅ Test Structure: AAA
- ✅ External Dependencies: mocked seams
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester
- ⚠️ Test Style & Structure: 9 of 10 mutants killed
- ✅ Naming & Readability: descriptive names
- ✅ Toolchain: PoshQC routes

### Metrics Summary

- ✅ 163/163 touched-suite tests passing; 14461 tree-wide, 0 failed
- ✅ 90.82% to 100% line coverage per new or changed file; 93.86% repo-wide
- ✅ Formatter and analyzer clean
- ⚠️ One surviving mutant (F1)

### Recommendation

**Remediate F1, then open the PR.** Add an entry-suite case in which the newest stored sample is less than 90 seconds old and `-PairSamples` is passed, and assert one state write with the paired samples.

---

## Appendix A: Test Inventory

### tests/scripts/claude-skills/epic-progress-report/

- `EpicProgressReport.SkillContract.Tests.ps1` (17): frontmatter, headings, literal fragments, paths, bundle and manifest parity, forbidden tokens, prompt arguments.
- `Get-EpicProgressReport.Logic.Tests.ps1` (38): kickoff, issue, worktree, PR, quota, task count, phase, feature state.
- `Get-EpicProgressReport.Metrics.Tests.ps1` (20): formatters, velocities, SD (2 versus 3 intervals), critical path, range including zero-rate.
- `Get-EpicProgressReport.Render.Tests.ps1` (14): summary, TL;DR and Full goldens, before-first-task `n/a`.
- `Get-EpicProgressReport.State.Tests.ps1` (31): sample rule, settings default path, state reader and writer, baseline resolution, pairing.
- `Get-EpicProgressReport.Tests.ps1` (35): seams, AST constraints, help, modes, reset, pairing, combined switches, stored start, legacy Full golden, directory creation.

### tests/scripts/dev-tools/

- `Get-EpicProgressReport.Tests.ps1` (8): forwarder structure, in-process exit handling, child-process validation exits.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (reviewer, worktree root, scripts in the session scratchpad):**
```powershell
Invoke-Formatter -ScriptDefinition (Get-Content -LiteralPath <file> -Raw) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
$c = New-PesterConfiguration
$c.Run.Path = @('tests/scripts/claude-skills/epic-progress-report','tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1')
$c.Run.PassThru = $true
Invoke-Pester -Configuration $c
```

**Mutation probe:** the five canonical scripts and the State and entry suites copied to a scratch tree with the same relative layout; each mutant applied by exact string replacement (application checked); new failures counted relative to the scratch baseline, whose only failure (`contains no recovered hardcoded value`) comes from the forwarder and SKILL.md being absent in the scratch tree; originals restored and re-run.

**Moved-function check:** PowerShell AST extraction of every function definition at the merge base and at HEAD, compared by exact text.

**Evidence-location scan:** `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` (exit 0).

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)
