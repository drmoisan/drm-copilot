# Policy Compliance Audit: cross-epic-dependencies (Issue #1162)

**Audit Date:** 2026-11-14
**Audit Type:** Re-audit after remediation cycle 1 (S7). Inputs `remediation-inputs.2026-11-14T07-20.md` (F1, F2); plan `remediation-plan.2026-11-14T07-20.md`, 20 of 20 tasks checked.
**Code Under Test:** merge base `1d9f14e2c595b0065ad42a24188620f320ac514c` of the base branch `main` (equal to `origin/main` after a fetch at review time) and reviewed head `97f4e351dd0dc42d206c225eed9ed999322d3521` on branch `feature/cross-epic-dependencies-1162`. The diff between them lists 149 changed files (11104 insertions, 264 deletions), 70 of them under the feature folder. The branch includes a plain merge of `origin/main` (commit `959b5f3e0`) that brought in #1156.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 36 files (10 production, 12 bundle and stored copies, 14 test) | 25005 tests | ✅ 24995 pass, 0 fail, 10 skipped | 95.80% lines (item Phase 0); 95.97% lines (cycle Phase 0) | 95.97% lines | 98.03% lines (lowest new file); changed line of this cycle 100% |
| Python | 8 files (4 production, 4 test) | 16828 tests | ✅ 16822 pass, 0 fail, 6 skipped | 94.83% lines, 90.20% branches (item Phase 0) | 94.93% lines, 90.48% branches | 100.00% lines (every added line covered) |
| TypeScript | 6 files (4 production, 1 config, 1 test) | 5646 tests (root configuration) | ✅ 5646 pass, 0 fail | 97.15% lines, 93.87% branches (item Phase 0, extension) | 98.30% lines, 93.73% branches (root report) | 100.00% lines (every added line covered) |
| JSON | 3 files (2 pack manifests, 1 test corpus) | N/A | ✅ pack-manifest and corpus parity tests pass | N/A (manifest and fixture files) | N/A (manifest and fixture files) | N/A |
| Markdown and TOML | 96 files (skills, agents, Codex toml, templates, copies, ledger patch, feature docs and evidence) | N/A | ✅ skill, ledger-chain, and digest contract tests pass | N/A (documentation) | N/A (documentation) | N/A |

Figures were parsed by the reviewer from the canonical artifacts in the item worktree:
- PowerShell: `artifacts/pester/powershell-coverage.xml`, written at 2026-11-14T09:30Z by the cycle's final `Invoke-PoshQCParallelTest` run. The last LINE counter is 41422 covered, 1741 missed (95.9665%).
- Python: `artifacts/python/lcov.info`, written at 2026-11-14T09:34Z by the cycle's final `pytest -n auto` run. Summed totals 17145/18060 lines (94.93%), 5995/6626 branches (90.48%).
- TypeScript: `coverage/lcov.info` at the worktree root, written at 2026-11-14T09:35Z by the cycle's final root Jest run. Summed totals 70512/71732 lines (98.30%), 10580/11288 branches (93.73%).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/baseline/jest.2026-11-10T03-35.md` (item Phase 0, extension configuration, 97.15% lines, 93.87% branches); cycle Phase 0 `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/remediation-baseline/jest-root.2026-11-14T08-19.md` (98.30% lines, 93.73% branches)
- TypeScript post-change coverage artifact: `coverage/lcov.info` (item worktree root, written 2026-11-14T09:35Z), summarized in `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/qa-gates/jest-root.2026-11-14T09-35.md`; extension report summarized in `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/qa-gates/jest.2026-11-14T09-35.md`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/baseline/pester.2026-11-11T04-32.md` (item Phase 0, 95.80% lines); cycle Phase 0 `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/remediation-baseline/pester.2026-11-14T08-14.md` (95.97% lines)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (item worktree, written 2026-11-14T09:30Z), summarized in `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/qa-gates/pester.2026-11-14T09-30.md`
- Python baseline coverage artifact: `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/baseline/pytest.2026-11-10T03-31.md` (item Phase 0, 94.83% lines, 90.20% branches); cycle Phase 0 `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/remediation-baseline/pytest.2026-11-14T08-18.md` (94.93% lines, 90.48% branches)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (item worktree, written 2026-11-14T09:34Z), summarized in `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/qa-gates/pytest.2026-11-14T09-34.md`
- Per-language comparison summary: section 1.2.1 of this audit

Freshness:
- The last commit that changes code is the `origin/main` merge `959b5f3e0` (2026-11-14T09:02:43Z). The two later commits (`67f0e2dfb`, `97f4e351d`) change only files under the feature folder and the remediation plan.
- All three canonical reports were written between 09:30Z and 09:35Z, after that commit, by the cycle's final gates. The worktree is clean (`git status --porcelain` empty). No gate re-run was needed in this review.

Scope source: `artifacts/pr_context.summary.txt` in the worktree was generated at 2026-11-14 09:40:39 UTC for head `97f4e351d`, range `1d9f14e2c..97f4e351d`, and matches the reviewed head. The reviewer also took the file list directly from `git diff --name-status 1d9f14e2c..HEAD`.

---

## Executive Summary

This re-audit covers the full branch diff after remediation cycle 1. Both blocking findings of the 2026-11-14T07-20 review are closed:
- F1 (readiness fetch without `--prune`): `Get-EpicCrossReadinessResult` now runs `fetch -q --prune origin`. A new adapter test models a stale remote-tracking ref and asserts `release` with `PREREQ_IN_MAIN`. The executor recorded fail-before and pass-after evidence. The reviewer reproduced the discrimination independently with a reverted-fix mutant in a scratch copy: the new test fails against the mutant and passes against the head module.
- F2 (decision-to-status mapping): the **Status mapping (D7).** paragraph is present in both epic-orchestrate skills, the epic-orchestrator agent, the Codex toml, and all four bundle copies. It agrees with the three validators. Four `CES-STATUS-MAPPING` contract cases pin it, with fail-before and pass-after evidence.

The `origin/main` merge that brought in #1156 is neutral for this item's content. Per path, the item's added and removed lines are identical before and after the merge, except for the two expected files (the frozen-digest expectations and the 0010 ledger patch). The pinned digests equal the SHA-256 of the committed surfaces. The ledger-chain suites pass in the post-merge full Pester gate.

All gates pass with 0 failures, every changed production file exceeds the coverage thresholds, and all 39 checkbox criteria evaluate PASS. No blocking finding remains. One non-blocking advisory Warning (file size) carries over unchanged.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `quality-tiers.md` (`quality-tiers.yml` exists; no new project folder added)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (`.claude/rules/python.md`)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` (`.claude/rules/typescript.md`)
- N/A C#: no C# file in the branch diff
- N/A Bash: no bash file in the branch diff

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; executor and reviewer helpers live in SCRATCH outside the repository.
- ✅ The reviewer mutant probe created its scratch copies inside SCRATCH and removed them after the run.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Parallel gates only: 8-worker `Invoke-PoshQCParallelTest`, `pytest -n auto`, Jest workers, all 0 failed. The new stale-ref test holds its state in module script scope and clears it in a `finally` block. Leak scan 0 findings (`powershell-static.2026-11-14T09-09.md`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | The stale-ref test targets one decision path; each `CES-STATUS-MAPPING` case targets one surface. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | pytest 203 s for 16828 tests; root Jest about 13 s for 5646 tests; the new tests are in-memory. |
| **Determinism** - Consistent results | ✅ PASS | `git`, `gh`, and the clock go through mocked seams; no sleep. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | The `It` name states the scenario and outcome; the contract tokens quote the asserted sentences verbatim. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** item Phase 0 PowerShell 95.80% lines; Python 94.83% lines, 90.20% branches; TypeScript 97.15% lines, 93.87% branches (extension). Cycle Phase 0 PowerShell 95.97%; Python 94.93% / 90.48%; TypeScript root 98.30% / 93.73%<br>**Command:** `Invoke-PoshQCParallelTest`; `pytest -n auto --cov=scripts.dev_tools --cov-branch`; `node run-jest.cjs --coverage`<br>**Artifact:** `evidence/baseline/` and `evidence/remediation-baseline/`<br>**Timestamp:** 2026-11-10 to 2026-11-14 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.97%; Python 94.93% / 90.48%; TypeScript root 98.30% / 93.73%<br>**Status:** no per-file drop on any changed production file. The PowerShell four-decimal movement (95.9696% to 95.9665%) comes only from 835 lines that the #1156 merge added at 95.81%; the P1 phase gate before the merge recorded 40622/42328, identical to the cycle baseline (`coverage-comparison.2026-11-14T09-36.md`). |
| **Changed Files Meet Thresholds** | ✅ PASS | **Thresholds:** 85% line and 75% branch (root `CLAUDE.md` states none, so the defaults govern; Pester has no branch gate)<br>**Status:** lowest changed PowerShell production file `Get-EpicProgressReport.ps1` 96.49%; lowest Python `validate_epic_orchestrator_state.py` 98.46% / 96.77%; lowest TypeScript `epic-orchestrator-state-resolution.ts` 98.85% / 96.99%. |
| **New Code Coverage ≥90%** | ✅ PASS | **New files:** `EpicCrossDependency.psm1` 98.03%, `Invoke-EpicCrossReadiness.ps1` 100%, `OrchestratorStateEpicCrossDependency.psm1` 100%, `Get-EpicProgressReport.CrossEpic.ps1` 100%<br>**Changed lines:** the cycle's one changed production line (the pruning fetch) is covered; the remaining missed lines lie outside the added ranges. |
| **Comprehensive Coverage** | ✅ PASS | Every exported function of the new modules has tests; the corpus pins every new error string across three runtimes. |
| **Positive Flows** - Valid inputs | ✅ PASS | Stale-ref release path, valid manifests, release decisions, released main gate, plan-priced external node. |
| **Negative Flows** - Invalid inputs | ✅ PASS | The failed-fetch row and the thrown-wrapper row still give `PREREQ_UNVERIFIABLE` with the new argument array; nine manifest codes. |
| **Edge Cases** - Boundary conditions | ✅ PASS | A stale ref that a non-pruning fetch would read is now modelled; `-WaitSeconds` boundaries; longer-token negative; cap 1. |
| **Error Handling** - Error paths | ✅ PASS | Adapter failure, invalid JSON, and ancestry exit 2 give `hold` with an `UNVERIFIABLE` reason. |
| **Concurrency** - If applicable | N/A | No concurrent code path; the bounded wait is sequential polling. |
| **State Transitions** - If applicable | ✅ PASS | The status mapping is now documented and pinned; the started-while-held invariant is tested in three runtimes. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.97% lines. Change: +0.17% lines (cycle Phase 0 95.97% -> 95.97%, equal at reported precision). New/changed-code coverage: 98.03% lines (lowest new file; the cycle's changed line covered). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/pester.2026-11-14T09-30.md`, `evidence/remediation-baseline/pester.2026-11-14T08-14.md`, `evidence/baseline/pester.2026-11-11T04-32.md`.
- Python: Baseline: 94.83% lines, 90.20% branches (from the `Phase 0 baseline` artifact) -> Post-change: 94.93% lines, 90.48% branches. Change: +0.10% lines, +0.28% branches. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/pytest.2026-11-14T09-34.md`, `evidence/remediation-baseline/pytest.2026-11-14T08-18.md`, `evidence/baseline/pytest.2026-11-10T03-31.md`.
- TypeScript: Baseline: 97.15% lines, 93.87% branches (from the extension `Phase 0 baseline` artifact) -> Post-change: 98.30% lines, 93.73% branches (root report); extension report 97.19% lines, 94.00% branches. Change: +0.04% lines, +0.13% branches on the extension configuration; root report unchanged from the cycle baseline. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: `coverage/lcov.info`, `evidence/qa-gates/jest-root.2026-11-14T09-35.md`, `evidence/qa-gates/jest.2026-11-14T09-35.md`, `evidence/baseline/jest.2026-11-10T03-35.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact decision strings compared; `-Because` text on the mapping rows. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Table setup, one command call, then assertions. |
| **Document Intent** | ✅ PASS | Intent comments above the mapping tokens and the stale-ref mock. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No test starts `gh` or `git`; wrappers are mocked with matching parameter names (`GitArgs`, `GhArgs`). |
| **Use Mocks/Stubs** | ✅ PASS | The new test mocks only `Invoke-EpicCrossGitExe`, `Invoke-EpicCrossGhExe`, and `Get-EpicCrossUtcNow`. |
| **Environment Stability** | ✅ PASS | No temporary files: reviewer search of the added test lines for temporary-path APIs found no match. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-14T09-37.md` (0 FAIL rows) and this audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-11-14T07-20.md` names the required change for each finding. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-14T07-20.md`; preflight fixes `evidence/other/preflight-fixes.2026-11-14T07-52.md`. |
| **Document the plan** | ✅ PASS | 20 tasks with task-check, phase-gate, and final-gate evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | F1 is one argument added in place; F2 is one appended paragraph per surface. |
| **Reusability** | ✅ PASS | The contract rows reuse the existing section, collapse, and token helpers. |
| **Extensibility** | ✅ PASS | No interface change; validators unchanged. |
| **Separation of concerns** | ✅ PASS | I/O stays in the two wrappers and the gather functions. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | No new module in this cycle. |
| **At or below the 800-line hard limit** | ✅ PASS | `EpicCrossDependency.psm1` 769 lines and its two copies (advisory-tier Warning in the code review, unchanged by the cycle); next largest `Get-EpicProgressReport.Tests.ps1` 699, `jest.config.cjs` 596. `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | No export change. |
| **No circular dependencies** | ✅ PASS | No import change. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | The new test name states scenario and outcome. |
| **Docs/docstrings** | ✅ PASS | The mapping paragraph documents the D7 statuses on every surface. |
| **Comment why, not what** | ✅ PASS | The mock comment explains the one-clone stale-ref model. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat`; `black --check .`<br>**Result:** 0 reformatted (1678 files); 1065 files unchanged (`powershell-static.2026-11-14T09-09.md`, `python-static.2026-11-14T09-10.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze`; `ruff check .`; `Invoke-PoshQCLeakScan`<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`<br>**Result:** 0 errors; N/A for PowerShell; no TypeScript source changed in the cycle |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`; `pytest -n auto`; `node run-jest.cjs --coverage` (extension and root)<br>**Result:** 24995, 16822, 5629, and 5646 passed; 0 failures |
| **Full toolchain loop** | ✅ PASS | P1 phase gate one clean pass (`phase-gate.P1.2026-11-14T08-57.md`); final QA after the main merge (`evidence/qa-gates/*.2026-11-14T09-*`). Codex generator `--check` exit 0. |
| **Explicit reporting** | ✅ PASS | Commands, exit codes, and counts under `evidence/qa-gates/` and `evidence/other/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `692aece0c` message names F1 and F2. |
| **Design choices explained** | ✅ PASS | `evidence/other/autonomous-decisions.2026-11-14T09-36.md` (D-1 to D-3). |
| **Update supporting documents** | ✅ PASS | Mapping paragraph on all description surfaces and copies; frozen digests and ledger patch refreshed. |
| **Provide next steps** | ✅ PASS | PR authoring and the S9 CI gate. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No new Python production file** | ✅ PASS | All four Python production files are `M` entries; the cycle changed only the test expectations file. |
| **Type hints** | ✅ PASS | Pyright 0 errors. |
| **Suppressions** | ✅ PASS | No `noqa`, `type: ignore`, or `pyright: ignore` in the added lines. |
| **Hooks invoke no Python** | ✅ PASS | No hook file or registration changed (`git diff --stat` over `.claude/hooks`, `.codex/hooks`, `.claude/settings.json` is empty). |

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding` and `OutputType` on functions. |
| **Wrapper seams** | ✅ PASS | The fetch still runs through `Invoke-EpicCrossGitExe -GitArgs`. |
| **Adapter correctness** | ✅ PASS | F1 closed: the fetch prunes, so a deleted remote integration branch no longer reads as present. Only one fetch site exists in the module. |
| **ShouldProcess** | N/A | No state-changing function; the CLI only reads and fetches. |
| **PSScriptAnalyzer** | ✅ PASS | 0 findings. |

### Section 3C: TypeScript Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No new production file** | ✅ PASS | No `A` entry under `extensions/drm-copilot/src`. |
| **Escape hatches** | ✅ PASS | No `any`, `ts-ignore`, or `eslint-disable` in the added lines. |
| **Parity port** | ✅ PASS | Shared corpus reproduced by Python, TypeScript, and PowerShell. |

### Section 3D: JSON and Mirror Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pack manifests** | ✅ PASS | No manifest change in the cycle; completeness and dependency-closure tests pass. |
| **Mirror byte identity** | ✅ PASS | Reviewer `git ls-files -s`: one blob id for all 16 Claude pairs, all 5 Codex and `.agents` pairs, both stored lib copies, and both templates. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Coverage expectation** | ✅ PASS | `_epic_orchestrator_state_resolution.py` and `_epic_orchestrator_state_wave_barrier.py` 100% / 100%; `validate_epic_orchestrator_state.py` 98.46% / 96.77%; `validate_epic_planner_state.py` 100% / 99.21%. |
| **Focused unit tests** | ✅ PASS | Parametrized per corpus case. |
| **Mocking sparingly** | ✅ PASS | No mocks; pure validators over corpus data. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester 6 syntax** | ✅ PASS | `-ForEach` data rows; `InModuleScope` with `-Parameters`. |
| **Test location** | ✅ PASS | Tests mirror `.claude/lib/epic-wave/` and `.claude/lib/orchestrator-state/`. |
| **Mock signature parity** | ✅ PASS | Wrapper mocks declare `GitArgs` and `GhArgs`. |
| **Coverage** | ✅ PASS | See 1.2; no changed-line regression. |

### Section 4C: TypeScript Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Jest structure** | ✅ PASS | One case per corpus entry. |
| **Coverage** | ✅ PASS | Per-file `coverageThreshold` entries enforced; all four files above thresholds. |

---

## 5. Test Coverage Detail

- PowerShell (lines, final gate): `EpicCrossDependency.psm1` 349/356; `Invoke-EpicCrossReadiness.ps1` 5/5; `OrchestratorStateEpicCrossDependency.psm1` 52/52; `OrchestratorStateEpicWaveBarrier.psm1` 139/139; `Get-EpicProgressReport.CrossEpic.ps1` 56/56; `Get-EpicProgressReport.ps1` 110/114 (missed lines predate this item); `Logic` 74/74, `Schedule` 210/210, `CriticalPath` 116/116, `Render` 226/226.
- Python (lines, branches): `_epic_orchestrator_state_resolution.py` 177/177, 102/102; `_epic_orchestrator_state_wave_barrier.py` 98/98, 50/50; `validate_epic_orchestrator_state.py` 128/130, 60/62; `validate_epic_planner_state.py` 241/241, 125/126.
- TypeScript (root report, lines and branches): `epic-orchestrator-state-resolution.ts` 514/520, 129/133; `epic-orchestrator-state-core.ts` 401/401, 75/78; `epic-orchestrator-state-wave-barrier.ts` 327/327, 68/69; `epic-planner-state-core.ts` 501/501, 128/132.
- Python figures come from a `--cov=scripts.dev_tools` run, which contains every changed Python production file. Assumption: this scope is the repository's established Python gate scope, as in the first review.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Skipped | Source |
|-----|-------|--------|--------|---------|--------|
| Pester full tree, final gate | 25005 | 24995 | 0 | 10 | `evidence/qa-gates/pester.2026-11-14T09-30.md` |
| pytest full tree, final gate | 16828 | 16822 | 0 | 6 | `evidence/qa-gates/pytest.2026-11-14T09-34.md` |
| Jest extension, final gate | 5629 | 5629 | 0 | 0 | `evidence/qa-gates/jest.2026-11-14T09-35.md` |
| Jest root configuration, final gate | 5646 | 5646 | 0 | 0 | `evidence/qa-gates/jest-root.2026-11-14T09-35.md` |
| Reviewer F1 mutant probe, head module | 26 | 26 | 0 | 0 | SCRATCH `r2-mutant.sh`, control copy |
| Reviewer F1 mutant probe, reverted fetch | 26 | 20 | 6 | 0 | SCRATCH `r2-mutant.sh`, mutant copy; the stale-ref test is among the failures |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| PowerShell format, analyzer, leak scan | PASS | `evidence/qa-gates/powershell-static.2026-11-14T09-09.md` |
| Python static (Black, Ruff, Pyright, Codex generator check) | PASS | `evidence/qa-gates/python-static.2026-11-14T09-10.md` |
| TypeScript static (Prettier, ESLint, tsc) | PASS | `evidence/qa-gates/typescript-static.2026-11-14T05-56.md`; no TypeScript file changed since, including the main merge |
| Mirror byte identity | PASS | reviewer `git ls-files -s` blob comparison |
| Frozen digests | PASS | reviewer SHA-256 of the committed `.claude/agents/epic-orchestrator.md` (5561f79d...af03) and `.claude/skills/epic-orchestrate/SKILL.md` (e334237b...7e80) equals the pinned values and the `+` lines of the 0010 patch |
| Main-merge neutrality | PASS | reviewer per-path numstat comparison of the item diff before (`2c8dee6dd..50414140f`) and after (`1d9f14e2c..959b5f3e0`) the merge: identical except the expectations file and the 0010 patch; added and removed lines of both epic surfaces identical |
| Evidence-location validator | PASS | reviewer run, exit 0 |
| Base drift | PASS | `origin/main` after fetch equals the merge base `1d9f14e2c`; `git merge-tree` of `origin/main` and HEAD is clean |

## CI Cross-check

No pull request exists for the branch (`gh pr list --head` returns an empty list), and no CI run exists for it (`gh run list --branch` returns an empty list). The rows below are local evidence only.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 formatter changes, 0 analyzer findings, 0 leak findings | 97f4e351d | `evidence/qa-gates/powershell-static.2026-11-14T09-09.md` (sources unchanged since) |
| poshqc / PowerShell QC | pass | 24995 passed, 0 failed; 95.97% lines | 97f4e351d | `evidence/qa-gates/pester.2026-11-14T09-30.md` |
| quality-checks7 / Code Quality and Tests | pass | 16822 passed, 0 failed; 94.93% lines, 90.48% branches | 97f4e351d | `evidence/qa-gates/pytest.2026-11-14T09-34.md` |
| Enforce Python coverage thresholds | pass | local total 94.93% lines, 90.48% branches; no CI result exists | 97f4e351d | `artifacts/python/lcov.info` |
| Extension tests (Jest) | pass | 5629 passed; 97.19% lines, 94.00% branches | 97f4e351d | `evidence/qa-gates/jest.2026-11-14T09-35.md` |
| TypeScript tests, root configuration (Jest) | pass | 5646 passed; 98.30% lines, 93.73% branches | 97f4e351d | `evidence/qa-gates/jest-root.2026-11-14T09-35.md` |

The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All cycle evidence is under `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/<kind>/`. No absolute path or host name appears in the added lines of the branch diff (reviewer search for drive-letter user paths, home paths, and the host user name: no match).

## Rejected Scope Narrowing

None. The caller asked the reviewer to read the gate artifacts rather than re-run gates; that matches the evidence model and narrows no file. This audit covers the full `1d9f14e2c..97f4e351d` diff.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists. The branch adds no new project folder: the new files sit in the existing `.claude/lib/epic-wave/`, `.claude/lib/orchestrator-state/`, and `.claude/skills/epic-progress-report/scripts/` directories.

## Workflow Rule

No path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` changed, so `modified-workflow-needs-green-run` does not fire. `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch` was regenerated again in the cycle and at the main merge (commit subjects carry `reduction: 0010`). No reduction was added or withdrawn, and `PRC-LEDGER-CHAIN-HOLDS` and `PRC-LEDGER-SUBCHAIN-HOLDS` pass in the post-merge full Pester gate.

## Owner Directives

OD-1 to OD-8 were received in the delegation block. Decisions are stated in the final message as `OWNER-DIRECTIVE-DECISION:` lines. The reviewer used the existing worktree by absolute path (OD-3, OD-4), added no evidence file and edited none (OD-6), and re-ran no gate (OD-5). One disclosure for OD-5: the F1 discrimination probe ran the single adapter test file once in one Pester process, against a scratch copy of the head module and a scratch copy with the fix reverted. It was a mutation probe, not a gate or coverage run, and wrote no canonical report.

---

## 8. Gaps and Exceptions

### Identified Gaps

- No blocking gap.
- Non-blocking: `EpicCrossDependency.psm1` at 769 lines (advisory tier), unchanged by the cycle.

### Approved Exceptions

None.

### Removed/Skipped Tests

None removed. The 10 Pester skips and 6 pytest skips match the Phase 0 baseline counts.

---

## 9. Summary of Changes

- Cycle 1: pruning fetch in `Get-EpicCrossReadinessResult` (three byte-identical copies); stale-ref adapter test; status-mapping paragraph on four surfaces and four bundle copies; `CES-STATUS-MAPPING` contract rows; frozen digests and the 0010 expectations hunk refreshed; `origin/main` merged (#1156) with the 0010 patch and expectations conflicts resolved.
- Item as a whole: new readiness module and CLI, Layer 2 module, progress-report part file; extended Python and TypeScript validators; skills, agents, Codex variants, templates, bundles, and pack manifests.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

### Policy-by-Policy Summary

- General code change: PASS
- General unit test: PASS
- PowerShell code change and unit test: PASS
- Python code change and unit test: PASS
- TypeScript code change and unit test: PASS

### Metrics Summary

- PowerShell 95.97% lines; Python 94.93% lines, 90.48% branches; TypeScript 98.30% lines, 93.73% branches (root).
- Pester 24995, pytest 16822, Jest 5629 (extension) and 5646 (root) passed; 0 failures.
- Blocking findings: 0.

### Recommendation

Proceed to PR authoring; CI on the PR head is owned by the S9 gate.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1` (new)
- `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1` (new; cycle 1 added the stale-ref test and updated two fetch keys)
- `tests/scripts/claude-lib/epic-wave/Invoke-EpicCrossReadiness.Tests.ps1` (new)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicCrossDependency.Tests.ps1`, `OrchestratorStateEpicCrossDependency.Parity.Tests.ps1` (new)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1`, `OrchestratorState.Manifest.Tests.ps1` (modified)
- `tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1` (new; cycle 1 added `CES-STATUS-MAPPING`)
- `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CrossEpic.Tests.ps1` (new); `EpicProgressReport.SkillContract.Tests.ps1`, `Get-EpicProgressReport.CriticalPath.Tests.ps1`, `Get-EpicProgressReport.Render.CriticalPath.Tests.ps1`, `Get-EpicProgressReport.Schedule.Tests.ps1`, `Get-EpicProgressReport.Tests.ps1` (modified)
- `tests/scripts/dev_tools/test_epic_cross_dependency_validation.py`, `test_epic_cross_dependency_parity_corpus.py` (new); `parallel_orchestrator_surface_expectations.py`, `test_push_down_codex_and_agents_virtual_paths.py` (modified)
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-cross-dependency.test.ts` (new)
- Corpus: `tests/fixtures/epic_cross_dependency/cross-dependency-cases.json`, `epic-without-cross-edges.md`

## Appendix B: Toolchain Commands Reference

- PowerShell tests and coverage: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>`
- PowerShell static: `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCLeakScan` with `-Root <item worktree root>`
- Python: `env -u VIRTUAL_ENV poetry run pytest -n auto --cov=scripts.dev_tools --cov-branch`; `black --check .`; `ruff check .`; `pyright`; `python -m scripts.dev_tools.generate_codex_agent_variants --check`
- TypeScript: `node run-jest.cjs --coverage` at the worktree root and in `extensions/drm-copilot`
- Evidence locations: `python scripts/dev_tools/validate_evidence_locations.py --root <item worktree root>`
- Reviewer probes: SCRATCH `r2-mutant.sh` (head module and reverted-fetch mutant against the adapter test file), `r2-neutral.sh` (per-path main-merge neutrality), `r2-checks.sh` (digests, blob parity, file sizes, diff scans), `r2-cov.js` (per-file coverage parse)
