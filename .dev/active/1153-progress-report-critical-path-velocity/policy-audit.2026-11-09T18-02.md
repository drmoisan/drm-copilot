# Policy Compliance Audit: Progress Report Critical Path and Velocity (Issue #1153)

**Audit Date:** 2026-11-09
**Branch:** `feature/progress-report-critical-path` @ `693b76d4f725549a8f2858ffe6ea42b886bafd78`
**Base:** `main`; merge base `bfae0c0b79b87d06bbaee2c9bcea0e38c4e7c864`, which equals `origin/main` after `git fetch`. `artifacts/pr_context.summary.txt` (generated 2026-11-09 17:58:46 UTC) names head `693b76d4f`, so it is current for this head. `git merge-tree --write-tree origin/main HEAD` reports no conflict.
**Work Mode:** full-feature (AC sources: `spec.md` and `user-story.md`)
**Review type:** Re-audit after remediation cycle 1 (inputs `remediation-inputs.2026-11-09T17-13.md`, plan `remediation-plan.2026-11-09T17-13.md`, rows CR1 to CR5 of `code-review.2026-11-09T17-08.md`).
**Code Under Test:** merge base `bfae0c0b7` to head `693b76d4f`; 68 files (10 production PowerShell scripts and SKILL.md under `.claude/skills/epic-progress-report/`, their 11 byte-identical bundle copies, `core.json`, 13 Pester test files, and the feature folder). This audit covers all of them, not only the cycle's changes.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 new production (`Velocity.ps1`, `Schedule.ps1`, `CriticalPath.ps1`), 6 modified production, 11 bundle copies, 6 new and 7 modified test files | 21216 testcases | 21206 passed, 0 failed, 10 skipped | 95.73% lines repo-wide (Phase 0, `evidence/baseline/pester.2026-11-09T15-50.md`) | 95.80% lines repo-wide (37492 of 39137) | 100% of added executable lines (661 of 661); new files Velocity 100%, Schedule 100%, CriticalPath 100% |
| Python | 0 files | 16590 passed | 0 failed, 6 skipped | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Python, TypeScript, C#, and Bash have zero changed files in the branch diff. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/pester.2026-11-09T15-50.md` (repo-wide 95.73% lines); main final gate figures in `evidence/qa-gates/coverage-comparison.2026-11-09T16-54.md`.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-09 17:52 UTC by the one `Invoke-PoshQCParallelTest` run recorded in `evidence/qa-gates/pester.2026-11-09T17-52.md`. The reviewer parsed it independently: root LINE counter 37492 covered, 1645 missed (95.80%); per-file line coverage in section 1.2.1.
- Python baseline coverage artifact: `evidence/baseline/pytest.2026-11-09T15-44.md` (97%, 35355 statements, 1021 missed).
- Python post-change coverage artifact: `evidence/qa-gates/pytest.2026-11-09T17-56.md` (97%, 35355 statements, 1021 missed; equal). No Python file changed.
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note: the last production or test commit is `f5852b79d` (17:43 UTC, SKILL.md); the last script commit is `a896f4b61` (17:41 UTC). The coverage run started after both and wrote the file at 17:52 UTC. Later commits `10f0fa048` to `693b76d4f` change only feature-folder evidence paths, and `git status --porcelain` is empty, so the artifact describes the head tree.

---

## Executive Summary

The branch revises the `epic-progress-report` skill: task progress, sequential and aggregate task velocity, a dependency-aware list-scheduled critical path under `max_parallel_features` with a predicted epic tail, the D7 serial sum as the labelled upper bound, a range at rate +/- 2.05 SD, pause exclusion, state version 3 with a v2 migration, and a 20-minute TL;DR cadence.

Remediation cycle 1 resolved all five non-blocking rows of the prior review:

- CR1: the five composition functions moved verbatim from `Schedule.ps1` to the new pure file `Get-EpicProgressReport.CriticalPath.ps1` (Schedule 783 to 494 lines; CriticalPath 308 lines), with the Logic hub dot-source line, bundle copy, `core.json` entry, and moved pins (13 delivery files, 12 production paths, 14 scan paths, AC-50 purity list).
- CR2: the aggregate average is NaN (printed `n/a`) while no interval exists.
- CR3: the resolver differences from `_epic_orchestrator_state_resolution.py` are documented in the help of both functions.
- CR4: pause spans ending before the earliest stored instant are pruned when the state is written (`Select-EpicProgressRetainedPauseSpan`).
- CR5: the stale wave-parallel parenthetical was removed from the Logic hub help.

No blocking finding. No covered file reaches the 700-line advisory tier any longer.

Reviewer checks at this head:

| Check (reviewer, this head) | Result |
|---|---|
| JaCoCo parse of `artifacts/pester/powershell-coverage.xml` | Repo-wide 95.80% lines; every skill script at or above 96.40%; CriticalPath 102 of 102 |
| Logical line counts of changed covered files | Largest test 699; entry script 530; Schedule 494; CriticalPath 308 |
| `config/file-size-baseline.json` in the diff | Not changed |
| Bundle copies (`cmp`) for all 13 skill-folder files | All byte-identical |
| `core.json` | 13 `epic-progress-report/` entries, one for `CriticalPath.ps1` |
| CR1 move fidelity | Lines removed from Schedule at `f33a952e0` equal the CriticalPath file from its first function onward; CriticalPath unchanged since that commit |
| Mutation probes on a scratch copy (CR2 guard removed; CR4 `-ge` to `-gt`; anchor term dropped; sample term dropped; writer not wired) | All 5 mutants killed (4, 3, 1, 1, 2 failing cases); unmutated control 71 of 71 passed |
| Real-process run of the shipped script in item mode (`-Issue 1153`, scratch `-StatePath`, two runs) | Five TL;DR lines; Velocity line reads `aggregate n/a tasks / hr average ... over 0 intervals`; version-3 state with `"pauses": []` |
| `python -m scripts.dev_tools.check_quality_tiers` (worktree root) | Exit 0, `quality-tiers: OK (33 entries, 33 discovered projects)` |
| `validate_evidence_locations.py --root <worktree>` | Exit 0 |

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; no new project folder; `check_quality_tiers` exit 0)
- ✅ `.claude/rules/tonality.md`
- ✅ Process-reduction ledger standing rule (no reduction made; see below)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --porcelain` at head was empty before and after the reviewer's checks.
- ✅ Mutation probes ran on copies under the session scratchpad; the item-mode run wrote its state file to the scratchpad. No worktree file was written other than the review artifacts.

---

## Rejected Scope Narrowing

The audit covers the full diff `bfae0c0b7..693b76d4f`. The caller prompt names the resolved base, merge base, head, PR context artifacts, AC sources, and remediation inputs, and asks for the full feature-review contract. No caller statement narrowed the scope to the remediation cycle, skipped a toolchain or coverage check, or marked a language as out of scope, so nothing was rejected.

---

## Process-Reduction Ledger Compliance

`docs/engineering/process-reductions/` exists, so the standing rule applies. The branch makes no process reduction: no gate, evidence requirement, baseline task, or test is removed. The cycle's test edits are pin moves (path lists and counts), golden value updates from `aggregate 0 tasks / hr average` to `aggregate n/a tasks / hr average` (behavior change CR2), and added cases. `git diff --name-only bfae0c0b7 HEAD -- docs/engineering/process-reductions/` lists no path.

## Modified-Workflow Rule

The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`, so the rule does not fire.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check does not apply and produces no finding.

## Evidence Location Compliance

The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `validate_evidence_locations.py --root <worktree>` exited 0 with no reported path. Item evidence lies under `<FEATURE>/evidence/baseline/`, `remediation-baseline/`, `other/`, and `qa-gates/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Fixtures are built in memory per case; all cases ran in the one parallel gate (8 shards). |
| **Isolation** - Each test targets single behavior | ✅ PASS | The CR4 selector cases call `Select-EpicProgressRetainedPauseSpan` directly; the State.V3 case calls the writer; the entry case compares one run with and one without the span. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pure calls; I/O seams mocked. |
| **Determinism** - Consistent results | ✅ PASS | Fixed epoch seconds; `Get-EpicProgressUtcNow` mocked; no clock, sleep, or random input in the tests. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Case names state the rule and boundary; comments derive the figures. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester.2026-11-09T15-50.md`, `pytest.2026-11-09T15-44.md`; cycle static baseline `evidence/remediation-baseline/poshqc-static.2026-11-09T17-31.md`. |
| **No Coverage Regression** | ✅ PASS | Repo-wide 95.73% (Phase 0) to 95.80%; every skill script at or above its main-final-gate figure (`coverage-comparison.2026-11-09T17-52.md`, reviewer parse). |
| **New Code Coverage** | ✅ PASS | CriticalPath 102 of 102, Velocity 109 of 109, Schedule 203 of 203; added executable lines 661 of 661. |
| **Modified Files** | ✅ PASS | Entry 96.40%, Gather 99.49%, Logic, Metrics, Render, State 100%. |
| **Comprehensive Coverage** | ✅ PASS | Remaining misses are the native wrapper bodies and clock read in the entry script and unchanged lines in Gather, Durations, and Steps. |
| **Positive Flows** - Valid inputs | ✅ PASS | Finite average from one interval; spans at or after the cutoff kept; serial chain, diamond, v3 round trip. |
| **Negative Flows** - Invalid inputs | ✅ PASS | n/a average with 0 intervals; spans before the cutoff dropped; graph defects; invalid cap and state versions. |
| **Edge Cases** - Boundary conditions | ✅ PASS | CR2 at 599/600/601 s; CR4 spans ending at 999/1000/1001 against a start of 1000; all intervals paused; no stored instant. |
| **Error Handling** - Error paths | ✅ PASS | Non-finite values print `n/a` (AC-10); null spans and null tick anchors are skipped. |
| **Concurrency** - If applicable | N/A | No concurrent code. The schedule simulates concurrency and is covered by the cap fixtures. |
| **State Transitions** - If applicable | ✅ PASS | v1, legacy, v2, v3 migration paths; `-ResetBaseline` and `-PairSamples` on v3; pruning on write. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.73% repo-wide lines -> Post-change: 95.80% repo-wide lines (37492 of 39137). Change: +0.07 points. New files: `Get-EpicProgressReport.Velocity.ps1` 100% (109 of 109); `Get-EpicProgressReport.Schedule.ps1` 100% (203 of 203); `Get-EpicProgressReport.CriticalPath.ps1` 100% (102 of 102). Modified files (Phase 0 -> post-change): entry `Get-EpicProgressReport.ps1` 95.56% -> 96.40% (107 of 111); `Gather.ps1` 99.32% -> 99.49% (196 of 197); `Logic.ps1` 100% -> 100% (73 of 73); `Metrics.ps1` 100% -> 100% (59 of 59); `Render.ps1` 100% -> 100% (222 of 222); `State.ps1` 100% -> 100% (153 of 153). New/changed-code coverage: 100% lines (661 of 661 added executable lines). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (parsed by the reviewer), `evidence/qa-gates/coverage-comparison.2026-11-09T17-52.md`.
- Python: zero changed files; no comparison is owed. Repo-wide figure equal to Phase 0 (97%).
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions compare exact figures, spans, and lines. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Fixture construction, one call, assertions. |
| **Document Intent** | ✅ PASS | Comments state the arithmetic (6 tasks per hour at 600 s). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Read-EpicProgressFile`, and `Test-EpicProgressPath` are mocked. |
| **Use Mocks/Stubs** | ✅ PASS | Wrapper seams mocked; no executable mocked directly. |
| **Environment Stability** | ✅ PASS | No `TestDrive`, temp file, or `function global:` in the tests; leak scan 0 failures (`poshqc-static.2026-11-09T17-43.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit with `code-review.2026-11-09T18-02.md` and `feature-audit.2026-11-09T18-02.md`; executor self-review `evidence/qa-gates/self-review.2026-11-09T17-57.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` decisions E1 to E15 and 58 AC; remediation inputs CR1 to CR5. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-09T09-45.md` and `remediation-plan.2026-11-09T17-13.md`, all tasks checked; preflight fixes recorded in `evidence/other/preflight-fixes.2026-11-09T17-28.md`. |
| **Document the plan** | ✅ PASS | The remediation plan's Design Decisions record the CR1 split boundary, the CR4 cutoff, and the CR2 rule. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | CR4 is one pure selector called once by the writer; CR2 is a guard on the interval count. |
| **Reusability** | ✅ PASS | Pruning reuses the stored instants already passed to the writer; no new data source. |
| **Extensibility** | ✅ PASS | Parameter sets unchanged; the new function has defaulted parameters. |
| **Separation of concerns** | ✅ PASS | Velocity, Schedule, and CriticalPath read no clock and call no I/O seam (AC-50 purity test covers all three). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Schedule holds graph, cap, closure, and list schedule; CriticalPath holds chain, tail, remaining time, range, and composition. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest covered file 699 logical lines (`Get-EpicProgressReport.Tests.ps1`); no file at the 700-line advisory tier; `config/file-size-baseline.json` not in the diff. |
| **Public vs internal** | ✅ PASS | Entry script defines the same 10 functions as at the merge base. |
| **No circular dependencies** | ✅ PASS | Dot-source order Durations, State, Metrics, Velocity, Schedule, CriticalPath, Render, Gather; the writer in State calls the Velocity selector at run time only. |
| **Project classification (tiers)** | ✅ PASS | No new project folder; `check_quality_tiers` exit 0. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Select-EpicProgressRetainedPauseSpan` uses an approved verb. |
| **Docs/docstrings** | ✅ PASS | New function has `.SYNOPSIS`, `.DESCRIPTION`, and every `.PARAMETER`; `ConvertTo-EpicProgressStateJson` and `Get-EpicProgressAggregateVelocity` help state the new rules; SKILL.md states both. |
| **Comment why, not what** | ✅ PASS | The selector help explains why no later calculation reads time before the cutoff. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Invoke-Formatter check: 29 files, 0 would change (`evidence/qa-gates/poshqc-static.2026-11-09T17-43.md`). |
| **2. Linting** | ✅ PASS | PSScriptAnalyzer with repo settings: 0 findings; leak scan 0 failures. |
| **3. Type checking** | N/A | PowerShell. |
| **4. Testing** | ✅ PASS | Pester 21216 testcases, 0 failed; pytest 16590 passed, 0 failed. |
| **Repository checks** | ✅ PASS | Push-down contract and citation tests pass in the pytest run; tier check exit 0 (reviewer). |
| **Full toolchain loop** | ✅ PASS | Static, Pester, coverage, and pytest gates in order after the last code commit. |
| **Explicit reporting** | ✅ PASS | Every gate artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9. |
| **Design choices explained** | ✅ PASS | SKILL.md `## Decisions` E14 names the three pure files; remediation plan Design Decisions. |
| **Update supporting documents** | ✅ PASS | SKILL.md (499 lines, under the 500-line pin) and bundle copy. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python file changed; no Python file added.

### Section 3B: PowerShell Code Change Policy Compliance

`Select-EpicProgressRetainedPauseSpan` is an advanced function with `CmdletBinding()`, `OutputType`, and defaulted named parameters; it is pure. All earlier observations hold: wrapper seams for external calls, no global state, no `Invoke-Expression`, PowerShell 7 compatible. Formatter and analyzer clean.

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file changed.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

No Python test changed; the push-down contract tests and `test_epic_skill_script_citations_shipped.py` pass in the one `pytest -n auto` run.

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Run through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | One `Invoke-PoshQCParallelTest` run (8 workers). |
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-skills/epic-progress-report/*.Tests.ps1`. |
| **Mock the wrapper, not the executable** | ✅ PASS | No mock of `git`, `gh`, or `cswap`. |

### Section 4C: TypeScript Unit Test Policy Compliance

No TypeScript test changed.

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Velocity | `Get-EpicProgressReport.Velocity.Tests.ps1` | Exec-prefix filter, qualification, pooled median and SD, aggregate intervals, CR2 n/a average, CR4 pruning cutoff | ✅ |
| Schedule and CriticalPath | `Schedule.Tests.ps1`, `Schedule.Range.Tests.ps1` | Graph, cap, list schedule, chain, tail, range, purity pin over three files | ✅ |
| Render | `Render.Tests.ps1`, `Render.CriticalPath.Tests.ps1` | TL;DR, per-feature table, critical-path section, `n/a` rendering | ✅ |
| State | `State.Tests.ps1`, `State.V3.Tests.ps1` | v3 writer, migrations, CR4 writer pruning boundary | ✅ |
| Entry and integration | `Get-EpicProgressReport.Tests.ps1`, `CriticalPath.Tests.ps1`, `ItemMode.Tests.ps1`, `Gather.Tests.ps1`, `Metrics.Tests.ps1` | Goldens, pause spans, CR4 neutrality, repository constraints | ✅ |
| Skill contract | `EpicProgressReport.SkillContract.Tests.ps1` | 13 delivery files, calculation and state rules | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester | 21216 testcases, 21206 passed, 0 failed, 10 skipped (main final gate 21204, 0 failed) | ✅ |
| pytest | 16590 passed, 0 failed, 6 skipped (equal to baseline) | ✅ |
| Reviewer mutation probes | 5 of 5 mutants killed; control 71 of 71 passed | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format and analyzer | `evidence/qa-gates/poshqc-static.2026-11-09T17-43.md` | 0 changes, 0 findings over 29 files | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan` | 0 failures | ✅ |
| Tier classification | `check_quality_tiers` (reviewer) | Exit 0 | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <worktree>` (reviewer) | Exit 0 | ✅ |
| File size | logical line counts (reviewer) | Max 699; no file at 700 or above | ✅ |

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| `poshqc / PowerShell QC static` | pass | 0 analyzer findings, 0 format changes | `693b76d4f` | `evidence/qa-gates/poshqc-static.2026-11-09T17-43.md` |
| `poshqc / PowerShell QC shards` | pass | 21216 testcases, 0 failed, 95.80% lines | `693b76d4f` | `evidence/qa-gates/pester.2026-11-09T17-52.md`; `artifacts/pester/powershell-coverage.xml` (reviewer parse) |
| `Enforce Python coverage thresholds` | pass | 97% lines (35355 statements, 1021 missed) | `693b76d4f` | `evidence/qa-gates/pytest.2026-11-09T17-56.md` |
| `tier-classification` | pass | 33 entries, 33 discovered projects | `693b76d4f` | Reviewer `check_quality_tiers` run |

No pull request exists for this branch yet, so no CI run exists on this head. The local figures above stand for each row; AC-58 (CI success on the PR head) is pending-CI and is owned by the item's orchestrator at S9.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **AC-58 (pending-CI):** CI on the pull request head has not run; not a blocking finding.
2. **Observations (non-blocking, no action):** O1 and O2 in the code review, both recording that the cycle's CR2 and CR4 rules refine wording in `spec.md` without contradicting a checked criterion.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None removed.** Skipped counts equal the baseline (Pester 10, pytest 6).

---

## 9. Summary of Changes

New `Get-EpicProgressReport.Velocity.ps1`, `Get-EpicProgressReport.Schedule.ps1`, and `Get-EpicProgressReport.CriticalPath.ps1`, dot-sourced by the Logic hub; Metrics gains `-MedianOverride` and loses the wave-parallel figure; State writes version 3, migrates v2, and prunes stale pause spans; Gather reads the `epic.md` inline `depends_on` lists and the routing-config cap and excludes pause spans from tick batches; Render prints the five-line TL;DR, per-feature table, and critical-path section; the entry script wires pause spans, aggregate velocity, and the critical-path report; SKILL.md documents E1 to E15, the n/a average, and pruning; bundle copies and `core.json` entries; 6 new and 7 updated Pester files.

---

## 10. Compliance Verdict

### Overall Status: ✅ PASS

No blocking finding. CR1 to CR5 of the prior review are resolved.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design, structure, documentation, mirror parity, file size

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell

#### General Unit Test Policy (Section 1)
- ✅ Coverage, baseline comparison, scenario completeness

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell

### Metrics Summary

- ✅ 0 failures in Pester and pytest
- ✅ PowerShell 95.80% lines repo-wide; new files 100%; added lines 661 of 661
- ✅ All 13 skill-folder files byte-identical with their bundle copies

### Recommendation

**Proceed.** Open the pull request and wait for CI on the PR head (AC-58).

---

## Appendix A: Test Inventory

New: `Get-EpicProgressReport.CriticalPath.Tests.ps1`, `Get-EpicProgressReport.Render.CriticalPath.Tests.ps1`, `Get-EpicProgressReport.Schedule.Tests.ps1`, `Get-EpicProgressReport.Schedule.Range.Tests.ps1`, `Get-EpicProgressReport.State.V3.Tests.ps1`, `Get-EpicProgressReport.Velocity.Tests.ps1`. Modified: `EpicProgressReport.SkillContract.Tests.ps1`, `Get-EpicProgressReport.Gather.Tests.ps1`, `ItemMode.Tests.ps1`, `Metrics.Tests.ps1`, `Render.Tests.ps1`, `State.Tests.ps1`, `Get-EpicProgressReport.Tests.ps1`. All under `tests/scripts/claude-skills/epic-progress-report/`.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <worktree> diff --name-status bfae0c0b7..HEAD
git -C <worktree> diff afdf04d0b..HEAD -- .claude/skills/epic-progress-report extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
git -C <worktree> merge-tree --write-tree origin/main HEAD
cmp <skill file> <bundle copy>
python -I <scratch>/cov.py <worktree>/artifacts/pester/powershell-coverage.xml
python -I <scratch>/lines.py <worktree>
sh <scratch>/run-mutants.sh
sh <scratch>/real-run.sh
```

`run-mutants.sh` copies the skill scripts and the Velocity, State.V3, and CriticalPath test files into a scratch tree per mutant, applies one `sed` mutation, and runs `Invoke-Pester` on the copy. `real-run.sh` runs `Get-EpicProgressReport.ps1 -Issue 1153 -Mode TLDR` with a scratch `-StatePath`, then `check_quality_tiers` and `validate_evidence_locations.py`.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-09
**Policy Version:** Current (as of audit date)
