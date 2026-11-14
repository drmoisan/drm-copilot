# Policy Compliance Audit: Progress Report Orchestration Step Model (Issue #1118)

**Audit Date:** 2026-11-08
**Branch:** `feature/progress-orchestration-step-model` @ `b82381ed282445648ee6a9e95f106778999e9f85`
**Base:** `main`; merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e` with `origin/main` (fetched at review time; `origin/main` is at `1850596d9`). `git merge-tree --write-tree origin/main HEAD` exits 0 (no conflict). `artifacts/pr_context.summary.txt` was generated 2026-11-08 00:04:26 UTC for head `b82381ed2` and resolves the range `12825cb00..b82381ed2`.
**Work Mode:** full-feature (AC sources: `spec.md` and `user-story.md`)
**Review type:** Re-audit after remediation cycle 1 (prior review `*.2026-11-07T23-18.md`, findings RF1, RF2, RF3; cycle plan `remediation-plan.2026-11-07T23-18.md`).
**Code Under Test:**
- `.claude/skills/epic-progress-report/scripts/`: entry script `Get-EpicProgressReport.ps1` (495 logical lines, unchanged in cycle 1), `Logic` (257), `Metrics` (194), `Render` (271), `State` (381), and the branch-new `Stages` (173), `Steps` (344), `Durations` (386), and `Gather` (350).
- `.claude/skills/epic-progress-report/SKILL.md` (453 lines).
- Bundle copies of all ten files under `extensions/drm-copilot/resources/claude-customizations/`, four new `pack-manifests/core.json` entries, and a `CHANGELOG.md` entry.
- Eleven Pester files under `tests/scripts/claude-skills/epic-progress-report/` (five new, six changed).

The branch diff is 72 files over 52 commits. This audit covers all of them, not only the cycle-1 commits (`84a25a90a..b82381ed2`, 33 files).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 production in 2 copies each, 11 test | 16092 | 0 failed, 0 errors, 10 skipped | 94.1% lines repo-wide (24578 of 26118), Phase 0 baseline | 94.23% lines repo-wide (25135 of 26675) | 98.39% to 100% on the four branch-new files; 95.56% to 100% on the five changed files |
| Python | 0 files | 16213 passed, 6 skipped | 0 failed | 96.99% lines, 94.16% branches repo-wide, Phase 0 baseline | 96.99% lines, 94.17% branches repo-wide | N/A - zero changed Python files |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Python verdict: PASS (no Python file changed; the push-down contract tests ran in the gate). Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `evidence/baseline/pester-parallel-baseline.2026-11-07T22-04.md` (Phase 0 `Invoke-PoshQCParallelTest` run), referenced for cycle 1 by `evidence/remediation-baseline/baseline-reference.2026-11-07T23-34.md`.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-07 23:50 UTC by the cycle-1 `Invoke-PoshQCParallelTest` run (`evidence/qa-gates/pester-parallel-final.2026-11-07T23-53.md`), parsed by the reviewer: root LINE 25135 covered, 1540 not covered (94.23%); per-file figures in section 1.2.1. `artifacts/pester/pester-junit.xml` reports 16092 tests, 0 failures, 0 errors.
- Python baseline coverage artifact: `evidence/baseline/pytest-parallel-baseline.2026-11-07T22-09.md`.
- Python post-change coverage artifact: `evidence/qa-gates/pytest-parallel-final.2026-11-07T23-59.md` (JSON report in the executor scratchpad; no Python file changed).
- Per-language comparison summary: section 1.2.1 of this audit
- Artifact provenance note: the last commit that changes a production, test, or bundle file is `d6522e358` (2026-11-07 23:43:13 UTC). The coverage and junit files were written at 23:50 UTC by a run that started at 23:45 UTC, and every later commit changes only feature-folder files, so the coverage file describes this head's code.

---

## Executive Summary

The branch replaces the task-velocity model of `/epic-progress-report` with a typed-step model. The first review found three blocking defects (RF1 live stage vocabulary, RF2 in-progress execution start, RF3 report wording). Remediation cycle 1 fixed all three in the dot-sourced files (the entry script is unchanged), added 18 named tests, updated `spec.md` and `SKILL.md`, and mirrored the five changed files into the bundle.

Reviewer verification at this head:

- **RF1 resolved.** `ConvertTo-EpicProgressStepType` maps the eleven aliases; the research fallback and `next_step` map accept `S3b_research`. #1038 merged after the prior review (its epic row is `worktree_removed`), so its open review no longer exists on live data. The reviewer instead ran the shipped `Invoke-EpicProgressReport` over the real file of the live #1114 checkpoint, which records `S2_research`, `S3_spec`, `S4_atomic_planning`, `S4_preflight`, `S5_atomic_execution`, and `S7_feature_review`, with `S7_feature_review` reopened. Output at +10, +15, and +20 minutes: `**Now:** #1114 review (0 h 10 min of median 0 h 14 min)`, then `0 h 15 min ... over median`, with the remaining estimate falling from 29 to 25 minutes and then holding at 25 (the review credit floors at zero). Every alias type received real samples (research 1, spec 1, plan 2, preflight 2, execution 19).
- **RF2 resolved.** `Get-EpicProgressStepReport` starts the in-progress execution step at the later of the stage start and the plan anchor's last tick. A mutant that removes the rule, and a mutant that takes the earlier time, are each caught by the new Gather tests.
- **RF3 resolved.** Real `-Issue 1118` run: `#1118 is not done yet.`, `| State | Item |`, `| Running | #1118: 48 of 52 steps (92%). |`, and `points since the measurement started ... not this item's cost alone.` Singular forms are pinned by the one-feature golden.
- Toolchain: PSScriptAnalyzer 0 findings on the 29 changed PowerShell files (reviewer run), 262 of 262 skill and forwarder Pester tests pass (reviewer run), full parallel gate 0 failures, every skill script at or above 95.56% line coverage, ten bundle copies byte-identical (reviewer `cmp`), evidence-location validator exit 0.

Caller observations, classified:

- **(a)** `-EpicFolder documentation-estate-tooling` from the item worktree printed `10 of 10 types use defaults` and no step in progress. This depends on where the script runs. The epic checkpoint is gitignored and exists only at the main checkout root. From the main checkout (where the scheduled job runs) the same script prints `11 of 11 features are done` and `#1019 integration-pr ... 10 of 11 types use defaults`. From the item worktree with `-CheckpointPath` set to the main checkout's file, the output matches the main-checkout run exactly. The silent fallback to "every child running" when the epic checkpoint is absent predates the branch: the merge-base script also took branch names and merge status only from that file. Non-blocking (NB2).
- **(b)** `#1118 execution (0 h 00 min ...)` reproduces at this head as `#1118 review (0 h 00 min of median 0 h 09 min)` while this re-audit runs. The only open stage is the composite `remediation_cycle_1`, so the step comes from `next_step` with no start. The behavior follows spec decision D2, and no acceptance criterion requires an elapsed time for a step without a recorded start. Non-blocking (NB1), with a recommendation.

No blocking finding remains.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; the skill scripts fall under the root `.` project, T4)
- ✅ `.claude/rules/tonality.md` applied to user-facing report wording (RF3 resolved)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --porcelain` in the item worktree was empty after the reviewer's Pester run and real runs. This review adds only its own artifacts.
- ✅ Reviewer probes, mutants, and real runs wrote only under the session scratchpad (`-StatePath` set there). The main checkout's `.claude/state` and `git status` were not changed.

---

## Rejected Scope Narrowing

No narrowing was detected in the caller prompt. The caller named the prior findings and two executor observations and asked for a full review of the branch against `spec.md` and `user-story.md`. The audit covers the full diff `12825cb00..b82381ed2`.

## Modified-Workflow Rule

The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`, so the rule does not fire.

## Evidence Location Compliance

A scan of the branch diff (`git diff --name-only 12825cb00 HEAD`) found no path under `artifacts/`, so none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`, run from the item worktree, exited 0. Cycle-1 evidence lies under `<FEATURE>/evidence/remediation-baseline/`, `other/`, and `qa-gates/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each `It` builds its own in-memory fixture; the parallel gate shards the files. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per `It`; the cycle-1 tests sit in the file of the function they cover. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The reviewer's scoped run of 262 tests completed in about two minutes. |
| **Determinism** - Consistent results | ✅ PASS | Fixed epoch seconds; `Get-EpicProgressUtcNow` is mocked. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `It` names; golden comments state the arithmetic (for example the 29 and 25 minute estimates). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `pester-parallel-baseline.2026-11-07T22-04.md`; cycle reference `baseline-reference.2026-11-07T23-34.md`. |
| **No Coverage Regression** | ✅ PASS | Repo-wide 94.1% to 94.23%; `Render` stays at 100% (149 of 149); entry script 90.82% to 95.56%. |
| **New Code Coverage** | ✅ PASS | Stages 100%, Steps 98.54%, Durations 98.39%, Gather 99.3%. |
| **Modified Files** | ✅ PASS | Entry 95.56%; Logic, Metrics, Render, State 100%. |
| **Comprehensive Coverage** | ✅ PASS | The live vocabulary gap of the prior review is closed: the Stages, Steps, and ItemMode tests use the alias names. The reviewer's mutants (10 reverted-fix variants) were each caught by at least one named test. |
| **Positive Flows** - Valid inputs | ✅ PASS | TL;DR and Full goldens in epic, one-feature epic, and item mode. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Unknown and non-positive `-StepDefaultMinutes`, malformed stage entries, unparseable checkpoint and state text, `-EpicFolder` with `-Issue`, unknown `S6_unknown` and `promotion` names. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Odd and even medians, empty sample list, 1000-sample ceiling, version 3 state, last tick earlier than the stage start. |
| **Error Handling** - Error paths | ✅ PASS | Throw paths asserted with `-ExpectedMessage`. |
| **Concurrency** - If applicable | N/A | Single-threaded report. |
| **State Transitions** - If applicable | ✅ PASS | Blocked span opened and cleared, anchors seeded and advanced, version 1 to version 2 migration, two-run estimate with an open review. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.1% repo-wide lines (Phase 0 baseline) -> Post-change: 94.23% repo-wide lines. Change: +0.13 points. New/changed-code coverage: 95.56% on `Get-EpicProgressReport.ps1` (86 of 90; baseline 90.82%), 100% on `Logic` (70 of 70), `Metrics` (65 of 65), `Render` (149 of 149; baseline 100%), and `State` (117 of 117), 100% on the branch-new `Stages` (60 of 60), 98.54% on `Steps` (135 of 137), 98.39% on `Durations` (122 of 124), and 99.3% on `Gather` (141 of 142). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-parallel-baseline.2026-11-07T22-04.md`, `evidence/qa-gates/pester-parallel-final.2026-11-07T23-53.md`.
- Python: Baseline: 96.99% repo-wide lines and 94.16% repo-wide branches -> Post-change: 96.99% repo-wide lines and 94.17% repo-wide branches. Change: 0.00 points for lines and +0.01 points for branches. No Python file changed. Disposition: PASS. Evidence: `evidence/baseline/pytest-parallel-baseline.2026-11-07T22-09.md`, `evidence/qa-gates/pytest-parallel-final.2026-11-07T23-59.md`.
- TypeScript, C#, Bash: zero changed files; no comparison is owed.

Bundle copies under `extensions/drm-copilot/resources/` are not separate entries in the Pester report. Each is byte-identical to its source, and the source is measured.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Literal-string goldens show the differing line; `-Because` in contract tests. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Fixture, call, and assertions separated in each `It`. |
| **Document Intent** | ✅ PASS | Each file header states scope and isolation. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | git, gh, cswap, and file seams are mocked. |
| **Use Mocks/Stubs** | ✅ PASS | Mocks target the wrapper seams. |
| **Environment Stability** | ✅ PASS | Reviewer grep of the eleven test files for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `Out-File`, `Start-Sleep`, and `$global:` found no use; `New-Item` and `Set-Content` occur only as mocks and in the write-command contract test. Leak scan: `leak-scan-final.2026-11-07T23-44.md` reports 0 findings for the eleven test files. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-11-08T00-12.md` and `feature-audit.2026-11-08T00-12.md`; the executor's `self-review.2026-11-08T00-01.md` has no FAIL row. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md`, `user-story.md`; cycle inputs `remediation-inputs.2026-11-07T23-18.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-11-07T15-48.md` and `remediation-plan.2026-11-07T23-18.md`, every task checked, per-task commits. |
| **Research** | ✅ PASS | The prior research gap (live vocabulary) is closed by the alias table in `spec.md`. The reviewer's inventory of live checkpoints found one further unmapped name, `S2_feature_documents` (non-blocking NB3). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The alias table is one hashtable lookup; the RF2 rule is one loop after the tick split. |
| **Reusability** | ✅ PASS | `Test-EpicProgressCompletedStep` takes a prefix array instead of a second helper. |
| **Extensibility** | ✅ PASS | New aliases are one table entry. |
| **Separation of concerns** | ✅ PASS | All cycle-1 changes are in pure dot-sourced files; the entry script is unchanged. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File size** | ✅ PASS | Reviewer logical counts (`@(Get-Content).Count`): largest production file 495, largest test file 656; no file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Cohesive modules** | ✅ PASS | Stages, Steps, Durations, State, Metrics, Render, and Gather each hold one concern. |
| **No circular dependencies** | ✅ PASS | The Logic hub dot-sources the seven files once. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs and the `EpicProgress` noun prefix. |
| **Docs** | ✅ PASS | Each changed function's `.DESCRIPTION` states the new rule; `SKILL.md` lists the aliases and wording. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | `format-final.2026-11-07T23-44.md`: 0 rewritten, 29 already formatted. |
| **Linting** | ✅ PASS | `pssa-final.2026-11-07T23-44.md`; reviewer re-run 0 findings on 29 files. |
| **Type checking** | N/A | PowerShell. |
| **Unit tests** | ✅ PASS | One parallel Pester run (0 failed) and one `pytest -n auto` run (0 failed) in cycle 1. |
| **Contract checks** | ✅ PASS | Push-down contract tests in the pytest gate; skill contract tests in Pester. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **CHANGELOG** | ✅ PASS | `extensions/drm-copilot/CHANGELOG.md` entry extended with the aliases, the execution start, and the wording. |
| **Design choices explained** | ✅ PASS | `spec.md` Decisions D1 to D13 and the amended normalization paragraph. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

N/A - no Python file in the branch diff.

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline captured** | ✅ PASS | Phase 0 baselines under `evidence/baseline/`; the cycle references them. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding` and `OutputType` on every function. |
| **ShouldProcess on writes** | ✅ PASS | `Write-EpicProgressState` is the only writer and uses `SupportsShouldProcess` (inspected by hand; PSSA does not check the `Write` verb). |
| **Parameter validation** | ✅ PASS | CLI parameters unchanged in cycle 1; `Test-EpicProgressCompletedStep -Prefix` widened to `[string[]]`, and single-string callers still bind. |
| **No global state** | ✅ PASS | No `$global:` in production files. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Approved verbs** | ✅ PASS | Get, ConvertTo, ConvertFrom, Resolve, Merge, Read, Find, Test, Invoke, Write, Format, Select. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Format, analyze, test loop** | ✅ PASS | Cycle 1 passed format, analyze, Pester, and pytest in one pass. |

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
| **Fixtures represent real inputs** | ✅ PASS | Cycle-1 fixtures use the live names (`S2_research`, `S3_spec`, `S4_atomic_planning`, `S4_preflight`, `atomic_execution`, `feature_review`, `S8_create_pr`, `S3b_research`). |

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
| `Get-EpicProgressReport.Steps.ps1` | new | 98.54% |
| `Get-EpicProgressReport.Durations.ps1` | new | 98.39% |
| `Get-EpicProgressReport.Gather.ps1` | new | 99.3% |

The four uncovered entry-script lines are the native git, gh, and cswap calls and the clock read inside their seams.

## 6. Test Execution Metrics

| Run | Tests | Failed | Source |
|---|---|---|---|
| Cycle-1 `Invoke-PoshQCParallelTest` | 16092 | 0 | `pester-parallel-final.2026-11-07T23-53.md`; junit re-read by reviewer |
| Cycle-1 `pytest -n auto` | 16213 passed, 6 skipped | 0 | `pytest-parallel-final.2026-11-07T23-59.md` |
| Reviewer scoped Pester (skill folder and forwarder) | 262 | 0 | reviewer run at this head |
| Reviewer mutant runs (Stages, Steps, Gather, Render, ItemMode tests; 81 tests) | 10 mutants | each caught | reviewer scratch copy |

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| PSScriptAnalyzer | 0 findings | reviewer run on 29 changed PowerShell files with the repo settings |
| Bundle mirror | 10 of 10 identical | reviewer `cmp` |
| `core.json` | 4 new entries, each once | branch diff |
| Merge with `origin/main` | clean | `git merge-tree` exit 0 |
| Real run, epic Full from the main checkout | exit 0 | scratch state copy of the live version 1 file |
| Real run, item `-Issue 1118` Full | exit 0; item wording | reviewer run, scratch state |
| Real-file probe, #1114 checkpoint with `S7_feature_review` open | elapsed shown; estimate 29 to 25 min | reviewer scratch probe |

## 8. Gaps and Exceptions

### Identified Gaps

None blocking. Non-blocking items NB1 to NB4 are listed in `code-review.2026-11-08T00-12.md`.

### Approved Exceptions

None.

### Removed/Skipped Tests

The task-velocity, standard-deviation, and range tests were removed with their functions, as Decision D13 allows. Cycle 1 removed no test; the plan's existing-test dispositions were followed (goldens updated where the wording changed).

## 9. Summary of Changes

### Commits in This PR/Branch

52 commits from `45877fb1b` to `b82381ed2`: feature documents and plan, Phase 0 baselines, the implementation and test commits, the first review (`d0c03c700`), the cycle-1 plan, seven cycle-1 fix, test, documentation, and mirror commits (`df931aac1` to `d6522e358`), and QA evidence records.

### Files Modified

72 files: 9 production scripts and `SKILL.md` with their bundle copies, `core.json`, `CHANGELOG.md`, 11 test files, the promoted record, and feature-folder documents and evidence.

## 10. Compliance Verdict

### Overall Status: ✅ PASS

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PASS.

#### Language-Specific Code Change Policy (Section 3)

PowerShell: PASS.

#### General Unit Test Policy (Section 1)

PASS.

#### Language-Specific Unit Test Policy (Section 4)

PowerShell: PASS.

### Metrics Summary

- PowerShell repo-wide lines 94.23% (baseline 94.1%); skill files 95.56% to 100%.
- Python repo-wide lines 96.99%, branches 94.17%; no Python file changed.
- Blocking findings: 0. RF1, RF2, and RF3 are resolved.

### Recommendation

Proceed to PR creation. The non-blocking items NB1 (wording for a step without a recorded start) and NB2 (warning when the epic checkpoint is absent) are small, contained changes; the orchestrator may fold them into this item or leave them, as the owner prefers.

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

- Format: `Invoke-PoshQCFormat` in write mode over the skill, bundle, and test folders (executor, `format-final.2026-11-07T23-44.md`).
- Lint: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (executor and reviewer).
- Test: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>` (executor); reviewer scoped `Invoke-Pester` with `Run.Path` set to the skill test folder and the forwarder test, no coverage.
- Python: `env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov` (executor).
- Evidence locations: `env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` from the item worktree (reviewer).
- Real runs: `pwsh -NoProfile -File <item worktree>/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder documentation-estate-tooling` from the main checkout, and the same with `-RepositoryRoot <item worktree>` with and without `-CheckpointPath <main checkout epic checkpoint>`; `-Issue 1118 -RepositoryRoot <main checkout>`; each with `-StatePath` under the session scratchpad (reviewer).
