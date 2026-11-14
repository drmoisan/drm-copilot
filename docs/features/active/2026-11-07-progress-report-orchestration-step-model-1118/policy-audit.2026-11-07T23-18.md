# Policy Compliance Audit: Progress Report Orchestration Step Model (Issue #1118)

**Audit Date:** 2026-11-07
**Branch:** `feature/progress-orchestration-step-model` @ `84a25a90a17f38e31a90b7e81ce3461d91e96ddb`
**Base:** `main`; merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e`. `origin/main` is at `1850596d9` (PR #1121). `git merge-tree --write-tree origin/main HEAD` exits 0 (no conflict). `artifacts/pr_context.summary.txt` was generated 2026-11-07 23:11:43 UTC for this head and resolves the range `12825cb00..84a25a90a`.
**Work Mode:** full-feature (AC sources: `spec.md` and `user-story.md`)
**Review type:** First review of the feature branch.
**Code Under Test:**
- `.claude/skills/epic-progress-report/scripts/`: entry script `Get-EpicProgressReport.ps1` (495 logical lines), `Logic` (257), `Metrics` (194), `Render` (242), `State` (381), and the new `Stages` (163), `Steps` (340), `Durations` (386), and `Gather` (340).
- `.claude/skills/epic-progress-report/SKILL.md` (440 lines).
- Bundle copies of all ten files under `extensions/drm-copilot/resources/claude-customizations/`, four new `pack-manifests/core.json` entries, and a `CHANGELOG.md` entry.
- Eleven Pester files under `tests/scripts/claude-skills/epic-progress-report/` (five new, six changed).

The branch diff is 57 files over 37 commits. This audit covers all of them.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 production in 2 copies each, 11 test | 16077 | 0 failed, 0 errors, 10 skipped | 94.1% lines repo-wide (24578 of 26118), Phase 0 baseline | 94.21% lines repo-wide (25101 of 26643) | 97.01% to 100% on the four new files; 95.56% to 100% on the five changed files |
| Python | 0 files | 16213 passed, 6 skipped | 0 failed | 96.99% lines, 94.16% branches repo-wide, Phase 0 baseline | 96.99% lines, 94.17% branches repo-wide | N/A - zero changed Python files |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Python verdict: PASS (no Python file changed; the push-down contract tests ran in the gate). Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `evidence/baseline/pester-parallel-baseline.2026-11-07T22-04.md` (repo-wide and per-file figures of the Phase 0 `Invoke-PoshQCParallelTest` run).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written by the final `Invoke-PoshQCParallelTest` run (`evidence/qa-gates/pester-parallel-final.2026-11-07T22-59.md`), parsed by the reviewer: root LINE 25101 covered, 1542 missed (94.21%); per-file figures in section 1.2.1. `artifacts/pester/pester-junit.xml` reports 16077 tests, 0 failures, 0 errors.
- Python baseline coverage artifact: `evidence/baseline/pytest-parallel-baseline.2026-11-07T22-09.md`.
- Python post-change coverage artifact: `evidence/qa-gates/pytest-parallel-final.2026-11-07T23-04.md` (JSON report in the executor scratchpad; no Python file changed).
- Per-language comparison summary: section 1.2.1 of this audit
- Artifact provenance note: the last commit that changes a production or test file is `ec927a316` ("cover the entry-point block"). The final Pester run is recorded in the later commit `a4341dbe4`, and every commit after `ec927a316` changes only feature-folder files, so the coverage file describes this head's code.

---

## Executive Summary

The branch replaces the task-velocity model of `/epic-progress-report` with a typed-step model. The implementation follows the spec closely: the step catalog, cycle expansion, per-type median estimate, default table, blockage by recorded state, batched-tick split, version 2 state with migration, the `Item` parameter set, and the new report formats are present and unit-tested. Toolchain gates are clean: PSScriptAnalyzer 0 findings (reviewer re-run), 247 of 247 skill and forwarder Pester tests pass (reviewer re-run), the full parallel gate passed with 0 failures, every skill script is at or above 95.56% line coverage, the bundle mirror is byte-identical (reviewer `cmp` of ten files), and the CLI surface is backward compatible.

The reviewer ran the shipped script for real from the main checkout against a copy of the live version 1 state file of `documentation-estate-tooling`, in TLDR and Full mode. Both runs exit 0, and the state is rewritten as version 2 with `startUnixSeconds` and `baselineWeeklyPct` kept and `baselineDone` reset to the current step count. That run also exposed three defects, recorded as blocking findings in `code-review.2026-11-07T23-18.md`:

- **RF1 (High).** The stage-name and `completed_steps` vocabulary that the step model maps is narrower than the vocabulary live checkpoints record. Live and committed records use `feature_review`, `atomic_execution`, `S5_atomic_execution`, `S7_feature_review`, `S8_create_pr`, `S9_ci_gate`, `S9_ci_green`, `S4_preflight`, and `S3_spec`; `completed_steps` uses `S3b_research` and `S4b_preflight`. All of these map to `unmapped` or fail the fallback. On the live epic, #1038's open `feature_review` stage (open since 22:05Z) is invisible, so the Now line reads `#1038 review (0 h 00 min of median 0 h 14 min)` and the remaining estimate does not fall between runs; #1038 also carries a phantom remaining `research` step. This defeats the issue's first problem statement (review time read as zero progress) on real data.
- **RF2 (Medium).** An in-progress `execution` step measures its elapsed time from the start of the whole `execution` stage and compares it with the per-task median, so every scheduled report during execution reads `over median` (sample: `#1118 execution (1 h 20 min of median 0 h 03 min, over median)`).
- **RF3 (Medium).** Item-mode and singular wording in the rendered report is wrong: `None of the 1 features is done yet.`, `1 of 1 features are done.`, `(1 blocked steps excluded)`, and in item mode `points since the epic started` and `it is not the epic's cost alone`.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; the skill scripts fall under the root `.` project, T4)
- ⚠️ `.claude/rules/tonality.md` applied to user-facing report wording (RF3)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --short` in the item worktree was empty before this review; afterwards it lists only this review's artifacts and the AC checkbox edits in `spec.md` and `user-story.md`.
- ✅ Reviewer probes ran from the session scratchpad and wrote state only to scratchpad copies (`-StatePath`). No production or test file was modified.

---

## Rejected Scope Narrowing

No narrowing was detected in the caller prompt. The caller named the changed areas and listed focus points; neither removes a file, language, toolchain check, or coverage check. The audit covers the full diff `12825cb00..84a25a90a`.

## Modified-Workflow Rule

The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`, so the rule does not fire.

## Evidence Location Compliance

A scan of the branch diff found no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0. The evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, and `qa-gates/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each `It` builds its own in-memory fixture; `BeforeEach` resets mock state; the parallel gate shards the files. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per `It`; test files mirror the nine scripts. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The reviewer's scoped run of 247 tests completed in under two minutes. |
| **Determinism** - Consistent results | ✅ PASS | Fixed epoch seconds; `Get-EpicProgressUtcNow` is mocked. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `It` names; golden comments state the arithmetic. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `pester-parallel-baseline.2026-11-07T22-04.md`. |
| **No Coverage Regression** | ✅ PASS | Repo-wide 94.1% to 94.21%; entry script 90.82% to 95.56%; the four other changed files stay at 100%. |
| **New Code Coverage** | ✅ PASS | Stages 100%, Steps 97.01%, Durations 98.39%, Gather 99.28%. |
| **Modified Files** | ✅ PASS | Entry 95.56%; Logic, Metrics, Render, State 100%. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | Line coverage is high, but fixtures use only the catalog stage names (`review`, `execution`), so the live vocabulary of RF1 is untested. |
| **Positive Flows** - Valid inputs | ✅ PASS | TL;DR and Full goldens in epic and item mode. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Unknown and non-positive `-StepDefaultMinutes`, malformed stage entries, unparseable checkpoint and state text, `-EpicFolder` with `-Issue`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Odd and even medians, empty sample list, 1000-sample ceiling, version 3 state. |
| **Error Handling** - Error paths | ✅ PASS | Throw paths asserted with `-ExpectedMessage`. |
| **Concurrency** - If applicable | N/A | Single-threaded report. |
| **State Transitions** - If applicable | ✅ PASS | Blocked span opened and cleared, anchors seeded and advanced, version 1 to version 2 migration. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.1% repo-wide lines (Phase 0 baseline) -> Post-change: 94.21% repo-wide lines. Change: +0.11 points. New/changed-code coverage: 95.56% on `Get-EpicProgressReport.ps1` (86 of 90; baseline 90.82%), 100% on `Logic` (70 of 70), `Metrics` (65 of 65), `Render` (129 of 129), and `State` (117 of 117), 100% on the new `Stages` (55 of 55), 97.01% on `Steps` (130 of 134), 98.39% on `Durations` (122 of 124), and 99.28% on `Gather` (137 of 138). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-parallel-baseline.2026-11-07T22-04.md`, `evidence/qa-gates/pester-parallel-final.2026-11-07T22-59.md`.
- Python: Baseline: 96.99% repo-wide lines and 94.16% repo-wide branches -> Post-change: 96.99% repo-wide lines and 94.17% repo-wide branches. Change: 0.00 points for lines and +0.01 points for branches. No Python file changed. Disposition: PASS. Evidence: `evidence/baseline/pytest-parallel-baseline.2026-11-07T22-09.md`, `evidence/qa-gates/pytest-parallel-final.2026-11-07T23-04.md`.
- TypeScript, C#, Bash: zero changed files; no comparison is owed.

Bundle copies under `extensions/drm-copilot/resources/` are not separate entries in the Pester report. Each is byte-identical to its source, and the source is measured.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Joined-string comparisons and `-Because` in contract tests. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Fixture, call, and assertions separated in each `It`. |
| **Document Intent** | ✅ PASS | Each file header states scope and isolation. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | git, gh, cswap, and file seams are mocked. |
| **Use Mocks/Stubs** | ✅ PASS | Mocks target the wrapper seams. |
| **Environment Stability** | ✅ PASS | Reviewer grep of the eleven test files for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `Out-File`, `Set-Content`, `New-Item`, and `$global:` found no use; one test calls the writer with `-WhatIf`, which prints a What-if line and writes nothing. Leak scan: 0 findings in the folder. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-11-07T23-18.md` and `feature-audit.2026-11-07T23-18.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md`, `user-story.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-11-07T15-48.md`, every task checked, per-task commits. |
| **Research** | ⚠️ PARTIAL | `research.2026-11-07T20-56.md` surveyed the #1096 and #1105 stage-timing records but not the #1106 record on `main` or live checkpoints, which use the vocabulary of RF1. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Pure functions per concern; composition in `Get-EpicProgressStepReport`. |
| **Reusability** | ✅ PASS | `Get-EpicProgressPlanTask` and `Read-EpicProgressText` are shared. |
| **Extensibility** | ✅ PASS | One step catalog; defaults overridable. |
| **Separation of concerns** | ✅ PASS | I/O only in entry seams and the Gather reading functions. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File size** | ✅ PASS | Reviewer logical counts: largest production file 495, largest test file 656; no file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Cohesive modules** | ✅ PASS | Stages, Steps, Durations, State, Metrics, Render, Gather each hold one concern. |
| **No circular dependencies** | ✅ PASS | The Logic hub dot-sources the seven files once. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs and the `EpicProgress` noun prefix. |
| **Docs** | ✅ PASS | Comment-based help on every function; `SKILL.md` updated. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | `format-final.2026-11-07T22-50.md`. |
| **Linting** | ✅ PASS | `pssa-final.2026-11-07T22-50.md`; reviewer re-run 0 findings on 20 files. |
| **Type checking** | N/A | PowerShell. |
| **Unit tests** | ✅ PASS | One parallel Pester run (0 failed) and one `pytest -n auto` run (0 failed). |
| **Contract checks** | ✅ PASS | Push-down contract tests in the pytest gate; skill contract tests in Pester. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **CHANGELOG** | ✅ PASS | `extensions/drm-copilot/CHANGELOG.md` `### Changed` entry. |
| **Design choices explained** | ✅ PASS | `spec.md` Decisions D1 to D13; `SKILL.md` Decisions section. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

N/A - no Python file in the branch diff.

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline captured** | ✅ PASS | `format-baseline`, `pssa-baseline`, `pester-parallel-baseline` under `evidence/baseline/`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding` and `OutputType` on every function. |
| **ShouldProcess on writes** | ✅ PASS | `Write-EpicProgressState` is the only writer and uses `SupportsShouldProcess`. |
| **Parameter validation** | ✅ PASS | Existing attributes unchanged (reviewer diff of the param block); `-Issue` `ValidateRange('Positive')`. |
| **No global state** | ✅ PASS | No `$global:` in production files. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Approved verbs** | ✅ PASS | Get, ConvertTo, ConvertFrom, Resolve, Merge, Read, Find, Test, Invoke, Write, Format, Select. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Format, analyze, test loop** | ✅ PASS | Two recorded restarts; final pass clean. |

### Section 3C: TypeScript Code Change Policy Compliance

N/A - no TypeScript file in the branch diff.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

N/A - no Python file in the branch diff.

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester tests mirror sources** | ✅ PASS | `tests/scripts/claude-skills/epic-progress-report/` mirrors the nine scripts. |
| **Mocks at seams** | ✅ PASS | Seam mocks with matching signatures. |
| **No temporary files** | ✅ PASS | See section 1.4. |
| **Fixtures represent real inputs** | ⚠️ PARTIAL | Stage names in fixtures are catalog names only (RF1). |

### Section 4C: TypeScript Unit Test Policy Compliance

N/A - no TypeScript file in the branch diff.

---

## 5. Test Coverage Detail

| File | Baseline | Final |
|---|---|---|
| `Get-EpicProgressReport.ps1` | 90.82% | 95.56% |
| `Get-EpicProgressReport.Logic.ps1` | 100% | 100% |
| `Get-EpicProgressReport.Metrics.ps1` | 100% | 100% |
| `Get-EpicProgressReport.Render.ps1` | 100% | 100% |
| `Get-EpicProgressReport.State.ps1` | 100% | 100% |
| `Get-EpicProgressReport.Stages.ps1` | new | 100% |
| `Get-EpicProgressReport.Steps.ps1` | new | 97.01% |
| `Get-EpicProgressReport.Durations.ps1` | new | 98.39% |
| `Get-EpicProgressReport.Gather.ps1` | new | 99.28% |

The four uncovered entry-script lines are the native git, gh, and cswap calls and the clock read inside their seams.

## 6. Test Execution Metrics

| Run | Tests | Failed | Source |
|---|---|---|---|
| Final `Invoke-PoshQCParallelTest` | 16077 | 0 | `pester-parallel-final.2026-11-07T22-59.md`; junit re-read by reviewer |
| Final `pytest -n auto` | 16213 passed, 6 skipped | 0 | `pytest-parallel-final.2026-11-07T23-04.md` |
| Reviewer scoped Pester (skill folder and forwarder) | 247 | 0 | reviewer run at this head |

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| PSScriptAnalyzer | 0 findings | reviewer run on 9 production and 11 test files |
| Bundle mirror | 10 of 10 identical | reviewer `cmp` |
| `core.json` | 4 new entries, each once | reviewer diff |
| Merge with `origin/main` | clean | `git merge-tree` exit 0 |
| Real run, epic TLDR and Full | exit 0; v1 state migrated to v2 | reviewer run from the main checkout with a scratchpad state copy |
| Real-data correctness | 3 defects | RF1, RF2, RF3 |

## 8. Gaps and Exceptions

### Identified Gaps

1. RF1: live stage and step vocabulary unmapped (High, blocking).
2. RF2: in-progress execution elapsed time measured from the stage start (Medium, blocking).
3. RF3: item-mode and singular report wording (Medium, blocking).

### Approved Exceptions

None.

### Removed/Skipped Tests

The task-velocity, standard-deviation, and range tests were removed with their functions, as Decision D13 allows. No test was skipped.

## 9. Summary of Changes

### Commits in This PR/Branch

37 commits from `45877fb1b` to `84a25a90a`: feature documents and plan, Phase 0 baselines, 13 implementation and test commits (`805124ba9` to `ec927a316`), and QA evidence records.

### Files Modified

57 files: 9 production scripts and `SKILL.md` with their bundle copies, `core.json`, `CHANGELOG.md`, 11 test files, the promoted record, and feature-folder documents and evidence.

## 10. Compliance Verdict

### Overall Status: ❌ REMEDIATION REQUIRED

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PASS, with the research gap recorded under RF1.

#### Language-Specific Code Change Policy (Section 3)

PowerShell: PASS.

#### General Unit Test Policy (Section 1)

PASS on coverage and isolation; PARTIAL on scenario completeness (RF1 fixtures).

#### Language-Specific Unit Test Policy (Section 4)

PowerShell: PASS, with the fixture gap of RF1.

### Metrics Summary

- PowerShell repo-wide lines 94.21% (baseline 94.1%); skill files 95.56% to 100%.
- Python repo-wide lines 96.99%, branches 94.17%; no Python file changed.
- Blocking findings: 3 (RF1 design, RF2 and RF3 contained), all `autonomous`.

### Recommendation

Open a full remediation cycle covering RF1, RF2, and RF3 as described in `remediation-inputs.2026-11-07T23-18.md`, then re-review.

## Appendix A: Test Inventory

| File | Status |
|---|---|
| `EpicProgressReport.SkillContract.Tests.ps1` | changed |
| `Get-EpicProgressReport.Tests.ps1` | changed |
| `Get-EpicProgressReport.Metrics.Tests.ps1` | changed |
| `Get-EpicProgressReport.Render.Tests.ps1` | changed |
| `Get-EpicProgressReport.State.Tests.ps1` | changed |
| `Get-EpicProgressReport.Logic.Tests.ps1` | unchanged |
| `Get-EpicProgressReport.Stages.Tests.ps1` | new |
| `Get-EpicProgressReport.Steps.Tests.ps1` | new |
| `Get-EpicProgressReport.Durations.Tests.ps1` | new |
| `Get-EpicProgressReport.Gather.Tests.ps1` | new |
| `Get-EpicProgressReport.ItemMode.Tests.ps1` | new |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (forwarder) | unchanged, passing |

## Appendix B: Toolchain Commands Reference

- Format: `Invoke-Formatter` per file (executor, `format-final.2026-11-07T22-50.md`).
- Lint: `Invoke-ScriptAnalyzer -Path <file>` (executor and reviewer).
- Test: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>` (executor); reviewer scoped `Invoke-Pester` with `Run.Path` set to the skill test folder and the forwarder test.
- Python: `poetry run pytest -n auto --cov --cov-branch` (executor).
- Evidence locations: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` (reviewer).
- Real run: `pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder documentation-estate-tooling -Mode TLDR` and `-Mode Full`, from the main checkout, with `-StatePath` set to a scratchpad copy of the live version 1 state (reviewer).
