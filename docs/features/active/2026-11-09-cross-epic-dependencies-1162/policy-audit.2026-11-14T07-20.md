# Policy Compliance Audit: cross-epic-dependencies (Issue #1162)

**Audit Date:** 2026-11-14
**Audit Type:** Initial feature review (S7). Plan `plan.2026-11-09T16-32.md`, 34 of 34 tasks checked.
**Code Under Test:** merge base `2c8dee6dd3a82f210561d9efe623767ae902de51` of the base branch `main` (equal to `origin/main` after a fetch at review time) and reviewed head `73ecccd13b3f8f7601de848136eca93fdafaa328` on branch `feature/cross-epic-dependencies-1162`. The diff between them lists 117 changed files (9694 insertions, 277 deletions), 43 of them under the feature folder.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 33 files (10 production, 10 bundle and stored copies, 13 test) | 24321 tests | ✅ 24311 pass, 0 fail, 10 skipped | 95.80% lines | 95.97% lines | 98.03% lines (lowest new file); every added line in changed files covered |
| Python | 8 files (4 production, 4 test) | 16821 tests | ✅ 16815 pass, 0 fail, 6 skipped | 94.83% lines, 90.20% branches | 94.93% lines, 90.46% branches | 100.00% lines (every added line covered) |
| TypeScript | 6 files (4 production, 1 config, 1 test) | 5641 tests (root configuration) | ✅ 5641 pass, 0 fail | 97.15% lines, 93.87% branches | 98.29% lines, 93.72% branches (root report) | 100.00% lines (every added line covered) |
| JSON | 3 files (2 pack manifests, 1 test corpus) | N/A | ✅ pack-manifest and corpus parity tests pass | N/A (manifest and fixture files) | N/A (manifest and fixture files) | N/A |
| Markdown | 70 files (skills, agents, templates, copies, feature docs and evidence) | N/A | ✅ skill and progress-report contract tests pass | N/A (documentation) | N/A (documentation) | N/A |

Figures were parsed by the reviewer from the canonical artifacts in the item worktree:
- PowerShell: `artifacts/pester/powershell-coverage.xml`, re-written by the reviewer's `Invoke-PoshQCParallelTest` run at head (`evidence/qa-gates/pester-reviewer-gate.2026-11-14T07-32.md`). The root LINE counter is 40622 covered, 1706 missed (95.97%), equal to the executor final gate.
- Python: `artifacts/python/lcov.info`, written 2026-11-14T06:58Z by the executor pytest gate.
- TypeScript: `coverage/lcov.info` at the worktree root, written 2026-11-14T07:12:20Z by the reviewer's root Jest run (`evidence/qa-gates/jest-root-gate.2026-11-14T07-12.md`).

The PowerShell, Python, and TypeScript baselines are the executor Phase 0 artifacts. The TypeScript baseline is the extension configuration (97.15% / 93.87%); no root-configuration baseline was recorded.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/baseline/jest.2026-11-10T03-35.md` (Phase 0, extension configuration, 97.15% lines, 93.87% branches)
- TypeScript post-change coverage artifact: `coverage/lcov.info` (item worktree root, written 2026-11-14T07:12:20Z), summarized in `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/qa-gates/jest-root-gate.2026-11-14T07-12.md`; supporting extension report `extensions/drm-copilot/coverage/lcov.info`, summarized in `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/qa-gates/jest.2026-11-14T07-01.md`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/baseline/pester.2026-11-11T04-32.md` (Phase 0, 95.80% lines)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (item worktree, re-written by the reviewer run at head), summarized in `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/qa-gates/pester-reviewer-gate.2026-11-14T07-32.md`; executor run `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/qa-gates/pester.2026-11-14T06-55.md`
- Python baseline coverage artifact: `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/baseline/pytest.2026-11-10T03-31.md` (Phase 0, 94.83% lines, 90.20% branches)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (item worktree, written 2026-11-14T06:58Z), summarized in `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/qa-gates/pytest.2026-11-14T06-59.md`
- Per-language comparison summary: section 1.2.1 of this audit

Freshness and reviewer gate runs:
- The newest commit touching PowerShell files is `6c6959e96` (2026-11-14T06:55:26Z). The executor's `artifacts/pester/powershell-coverage.xml` was written at 06:54:40Z, 46 seconds earlier.
- The PowerShell sources in that commit were last modified at 06:11:50Z (root module) and 06:36:50Z (stored copy), before the 06:41Z gate start. The executor figures therefore describe the committed code, but the report's write time precedes the commit.
- The root TypeScript report `coverage/lcov.info` was absent, because the executor ran the extension configuration only.
- The reviewer therefore ran the root Jest configuration (about 23 s) and one full `Invoke-PoshQCParallelTest` in the item worktree. These are the canonical gates, run once each, parallel-only and one suite at a time (OD-5). The runs are disclosed here as a departure from the evidence-only model.
- The Python report (06:58Z) postdates the newest Python-touching commit (06:55:26Z).
- The worktree is clean (`git status --porcelain` empty).

Scope source: `artifacts/pr_context.summary.txt` in the worktree was generated at 2026-11-14 07:09:32 UTC for head `73ecccd13`, range `2c8dee6dd..73ecccd13`, and matches the reviewed head. The reviewer also took the file list directly from `git diff --name-status 2c8dee6dd..73ecccd13`.

---

## Executive Summary

The branch delivers issue #1162:
- A `cross_epic_depends_on` manifest edge, validated at kickoff by a new PowerShell readiness CLI.
- Feature and integration-to-main hold decisions from pure functions behind two executable wrappers.
- Key-gated checkpoint invariants in Python, TypeScript, and a new PowerShell Layer 2 module, pinned by a shared corpus.
- External nodes in the epic progress report.
- Skill, agent, Codex, template, bundle, and pack-manifest updates.

All toolchain gates pass, every changed production file exceeds the coverage thresholds, and all 39 checkbox criteria evaluate PASS.

Two blocking findings remain (code review F1 and F2):
- F1: `Get-EpicCrossReadinessResult` fetches without `--prune`. A prerequisite integration branch deleted on the remote is still read through its stale `origin/<branch>` ref, so `PREREQ_IN_MAIN` and the D4 "no extra merge" path are unreachable in that state. Confirmed by a real-git probe.
- F2: the D7 records paragraph names four statuses with no decision-to-status mapping. The started-while-held invariant rejects `released` on a launched feature, which is the likely record after a `PREREQ_ALREADY_INTEGRATED` release.

Both are autonomous and contained.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `quality-tiers.md` (`quality-tiers.yml` exists; no new project folder added)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (`.claude/rules/python.md`)
- ⚠️ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`): toolchain clean; adapter correctness defect F1
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` (`.claude/rules/typescript.md`)
- N/A C#: no C# file in the branch diff
- N/A Bash: no bash file in the branch diff

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; executor and reviewer helpers live in SCRATCH outside the repository.
- ✅ The reviewer stale-ref probe created and removed its scratch repositories inside SCRATCH.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Parallel gates only: 8-worker `Invoke-PoshQCParallelTest`, `pytest -n auto`, Jest workers, all 0 failed; leak scan 0 findings (`powershell-static.2026-11-14T06-41.md`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | Table-driven rows per decision row and per manifest code; corpus cases per error string. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | pytest 173 s for 16815 tests; root Jest about 21 s for 5641 tests; new tests are in-memory. |
| **Determinism** - Consistent results | ✅ PASS | Clock, sleep, manifest read, `gh`, and `git` go through injected seams; tests assert the injected sleep count and perform no real sleep. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Behavior-named `Describe`/`It` blocks and test IDs; corpus case names state the condition. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 95.80% lines; Python 94.83% lines, 90.20% branches; TypeScript 97.15% lines, 93.87% branches (extension)<br>**Command:** `Invoke-PoshQCParallelTest`; `pytest -n auto --cov=scripts.dev_tools --cov-branch`; `node run-jest.cjs --coverage`<br>**Artifact:** `evidence/baseline/pester.2026-11-11T04-32.md`, `pytest.2026-11-10T03-31.md`, `jest.2026-11-10T03-35.md`<br>**Timestamp:** 2026-11-10 to 2026-11-11 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.97%; Python 94.93% / 90.46%; TypeScript 97.18% / 94.00% (extension) and 98.29% / 93.72% (root)<br>**Status:** no repository-wide or per-file drop on any changed production file (`coverage-comparison.2026-11-14T07-02.md`, reviewer reports). |
| **Changed Files Meet Thresholds** | ✅ PASS | **Thresholds:** 85% line and 75% branch (root `CLAUDE.md` states none, so the defaults govern; Pester has no branch gate)<br>**Status:** lowest changed PowerShell production file `Get-EpicProgressReport.ps1` 96.49%; lowest Python `validate_epic_orchestrator_state.py` 98.46% / 96.77%; lowest TypeScript `epic-orchestrator-state-resolution.ts` 98.84% / 96.99%. |
| **New Code Coverage ≥90%** | ✅ PASS | **New files:** `EpicCrossDependency.psm1` 98.03%, `Invoke-EpicCrossReadiness.ps1` 100%, `OrchestratorStateEpicCrossDependency.psm1` 100%, `Get-EpicProgressReport.CrossEpic.ps1` 100%<br>**Changed lines:** every added line in changed production files covered; the missed lines and branches lie outside the added ranges. |
| **Comprehensive Coverage** | ✅ PASS | Every exported function of the new modules has tests; the corpus pins every new error string across three runtimes. |
| **Positive Flows** - Valid inputs | ✅ PASS | Valid manifests, release decisions, released main gate, plan-priced external node. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Nine manifest codes; malformed checkpoint shapes; usage errors with exit 2. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `-WaitSeconds` 0, 540, 541, and -1; main-sync PR exclusion; longer-token negative; cap 1. The stale-ref state is absent from the adapter rows (F1). |
| **Error Handling** - Error paths | ✅ PASS | Adapter failure, invalid JSON, and ancestry exit 2 give `hold` with an `UNVERIFIABLE` reason; fail-closed import of the Layer 2 module. |
| **Concurrency** - If applicable | N/A | No concurrent code path; the bounded wait is sequential polling. |
| **State Transitions** - If applicable | ✅ PASS | Hold-record statuses and the started-while-held invariant are tested; the documented mapping is absent (F2). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.97% lines. Change: +0.17% lines. New/changed-code coverage: 98.03% lines (lowest new file; every added line in changed files covered). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/pester-reviewer-gate.2026-11-14T07-32.md`, `evidence/qa-gates/pester.2026-11-14T06-55.md`, `evidence/baseline/pester.2026-11-11T04-32.md`.
- Python: Baseline: 94.83% lines, 90.20% branches (from the `Phase 0 baseline` artifact) -> Post-change: 94.93% lines, 90.46% branches. Change: +0.10% lines, +0.26% branches. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/pytest.2026-11-14T06-59.md`, `evidence/baseline/pytest.2026-11-10T03-31.md`.
- TypeScript: Baseline: 97.15% lines, 93.87% branches (from the extension `Phase 0 baseline` artifact) -> Post-change: 97.18% lines, 94.00% branches (extension report); 98.29% lines, 93.72% branches (root report `coverage/lcov.info`). Change: +0.03% lines, +0.13% branches on the extension configuration. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: `coverage/lcov.info`, `evidence/qa-gates/jest-root-gate.2026-11-14T07-12.md`, `evidence/qa-gates/jest.2026-11-14T07-01.md`, `evidence/baseline/jest.2026-11-10T03-35.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact error strings asserted; `-Because` text on contract rows. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New tests separate setup, call, and assertion. |
| **Document Intent** | ✅ PASS | File-level synopsis blocks state scope and seams. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No test starts `gh` or `git`; wrappers are mocked with matching parameter names. |
| **Use Mocks/Stubs** | ✅ PASS | Mocks only `Invoke-EpicCrossGhExe`, `Invoke-EpicCrossGitExe`, `Read-EpicProgressText`, and existing progress-report seams. |
| **Environment Stability** | ✅ PASS | No temporary files (reviewer search of the added test lines for temporary-path APIs: no match); inputs are in-memory or committed LF fixtures. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-14T07-04.md` and this audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md` decisions D1 to D11. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-09T16-32.md`; research `research/research.2026-11-09T21-50.md`. |
| **Document the plan** | ✅ PASS | Plan with task checks under `evidence/other/task-check.*`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Pure decision functions plus thin adapters; external nodes reuse the existing schedule with one optional property. |
| **Reusability** | ✅ PASS | Reuses `feature_has_started`, `Read-EpicProgressText`, and the main-sync procedure. |
| **Extensibility** | ✅ PASS | Key-gated additions; an absent key leaves every result unchanged. |
| **Separation of concerns** | ✅ PASS | I/O only in the two wrappers and the gather functions. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Readiness module, Layer 2 module, progress-report part file. |
| **At or below the 800-line hard limit** | ✅ PASS | `EpicCrossDependency.psm1` 769 lines and its two copies (advisory-tier Warning in the code review); next largest `Get-EpicProgressReport.Tests.ps1` 699, `jest.config.cjs` 596, `_epic_orchestrator_state_resolution.py` 562. `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | Private helpers are not exported. |
| **No circular dependencies** | ✅ PASS | New modules import nothing that imports them. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs; `EpicCross` and `EpicProgressCrossEpic` nouns. |
| **Docs/docstrings** | ✅ PASS | Comment-based help, Python docstrings, JSDoc. |
| **Comment why, not what** | ✅ PASS | Routing and aggregation comments explain decision order. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat`; `black --check .`; `prettier --check`<br>**Result:** 0 reformatted, 1065 files unchanged, Prettier clean |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze`; `ruff check .`; `eslint`<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`; `npm run typecheck`<br>**Result:** 0 errors; N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`; `pytest -n auto`; `node run-jest.cjs --coverage` (extension and root)<br>**Result:** 24311, 16815, 5624, and 5641 passed; 0 failures |
| **Full toolchain loop** | ✅ PASS | The first Pester gate failed (dynamic invocation, ledger chain), was fixed, and the PowerShell loop restarted from format (`pester.2026-11-14T06-37.md`, `powershell-static.2026-11-14T06-41.md`). |
| **Explicit reporting** | ✅ PASS | Commands, exit codes, and counts under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages per phase. |
| **Design choices explained** | ✅ PASS | Spec D1 to D11; ledger regeneration method in `pester.2026-11-14T06-37.md`. |
| **Update supporting documents** | ⚠️ PARTIAL | Skills, agents, templates, copies, and pack manifests updated; the D7 records paragraph lacks the decision-to-status mapping (F2). |
| **Provide next steps** | ✅ PASS | Remediation inputs of this review. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No new Python production file** | ✅ PASS | All four Python production files are `M` entries; the two new `.py` files are tests of the extended validators. |
| **Type hints** | ✅ PASS | Full annotations; Pyright 0 errors. |
| **Suppressions** | ✅ PASS | No `noqa`, `type: ignore`, or `pyright: ignore` in the added lines. |
| **Hooks invoke no Python** | ✅ PASS | No hook file changed; the no-Python-invocation repository scan passes after the `$usage` fix. |

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding` and `OutputType` on functions. |
| **Wrapper seams** | ✅ PASS | `Invoke-EpicCrossGhExe -GhArgs` and `Invoke-EpicCrossGitExe -GitArgs` splat array arguments. |
| **Adapter correctness** | ❌ FAIL | F1: the fetch does not prune, so a deleted remote integration branch reads as present. |
| **ShouldProcess** | N/A | No state-changing function; the CLI only reads and fetches. |
| **PSScriptAnalyzer** | ✅ PASS | 0 findings; one justified suppression on a pure factory (`New-EpicProgressExternalNode`). |

### Section 3C: TypeScript Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No new production file** | ✅ PASS | No `A` entry under `extensions/drm-copilot/src`. |
| **Escape hatches** | ✅ PASS | No `any`, `ts-ignore`, or `eslint-disable` in the added lines. |
| **Parity port** | ✅ PASS | Shared corpus reproduced by Python, TypeScript, and PowerShell. |

### Section 3D: JSON and Mirror Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pack manifests** | ✅ PASS | Entries for the four new `.claude/` files and the two `.codex/lib/epic-wave/` copies; completeness and dependency-closure tests pass. |
| **Mirror byte identity** | ✅ PASS | One blob id per source and copy for all 16 Claude pairs, both Codex stored copies, and both templates. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Coverage expectation** | ✅ PASS | `_epic_orchestrator_state_resolution.py` and `_epic_orchestrator_state_wave_barrier.py` 100% / 100%; the two validators at 98.46% / 96.77% and 100% / 99.21%. |
| **Focused unit tests** | ✅ PASS | Parametrized per corpus case. |
| **Mocking sparingly** | ✅ PASS | No mocks; pure validators over corpus data. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester 6 syntax** | ✅ PASS | `-ForEach` data rows; `BeforeAll` imports with `-Force`. |
| **Test location** | ✅ PASS | Tests mirror `.claude/lib/epic-wave/`, `.claude/lib/orchestrator-state/`, and the progress-report scripts. |
| **Mock signature parity** | ✅ PASS | Wrapper mocks declare `GhArgs` and `GitArgs`. |
| **Coverage** | ✅ PASS | See 1.2; no changed-line regression. |

### Section 4C: TypeScript Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Jest structure** | ✅ PASS | One case per corpus entry. |
| **Coverage** | ✅ PASS | Per-file `coverageThreshold` entries enforced; all four files above thresholds. |

---

## 5. Test Coverage Detail

- PowerShell (lines, reviewer run): `EpicCrossDependency.psm1` 349/356; `Invoke-EpicCrossReadiness.ps1` 5/5; `OrchestratorStateEpicCrossDependency.psm1` 52/52; `OrchestratorStateEpicWaveBarrier.psm1` 139/139 (baseline 136/136); `Get-EpicProgressReport.CrossEpic.ps1` 56/56; `Get-EpicProgressReport.ps1` 110/114 (missed lines 204, 218, 232, 314 predate this item; baseline 107/111); `Logic` 74/74, `Schedule` 210/210, `CriticalPath` 116/116, `Render` 226/226.
- Python (lines, branches): `_epic_orchestrator_state_resolution.py` 177/177, 102/102; `_epic_orchestrator_state_wave_barrier.py` 98/98, 50/50; `validate_epic_orchestrator_state.py` 128/130, 60/62 (missed lines 280 and 285 outside the added lines); `validate_epic_planner_state.py` 241/241, 125/126.
- TypeScript (root report, lines and branches): `epic-orchestrator-state-resolution.ts` 98.84% / 96.99%; `epic-orchestrator-state-core.ts` 100% / 96.15%; `epic-orchestrator-state-wave-barrier.ts` 100% / 98.55%; `epic-planner-state-core.ts` 100% / 96.96%.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Skipped | Source |
|-----|-------|--------|--------|---------|--------|
| Pester full tree, executor final | 24321 | 24311 | 0 | 10 | `evidence/qa-gates/pester.2026-11-14T06-55.md` |
| Pester full tree, reviewer at head | 24321 | 24311 | 0 | 10 | `evidence/qa-gates/pester-reviewer-gate.2026-11-14T07-32.md` |
| pytest full tree, executor final | 16821 | 16815 | 0 | 6 | `evidence/qa-gates/pytest.2026-11-14T06-59.md` |
| Jest extension, executor final | 5624 | 5624 | 0 | 0 | `evidence/qa-gates/jest.2026-11-14T07-01.md` |
| Jest root configuration, reviewer at head | 5641 | 5641 | 0 | 0 | `evidence/qa-gates/jest-root-gate.2026-11-14T07-12.md` |
| Reviewer stale-ref probe | 2 cases | as described | 0 | 0 | SCRATCH `r1162-staleref.sh`: unpruned fetch, `git show` exit 0; pruned fetch, exit 128 |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| PowerShell format, analyzer, leak scan | PASS | `evidence/qa-gates/powershell-static.2026-11-14T06-41.md` |
| Python static (Black, Ruff, Pyright) | PASS | `evidence/qa-gates/python-static.2026-11-14T05-55.md` |
| TypeScript static (Prettier, ESLint, tsc) | PASS | `evidence/qa-gates/typescript-static.2026-11-14T05-56.md` |
| Mirror byte identity | PASS | reviewer `git ls-files -s` blob comparison |
| Evidence-location validator | PASS | reviewer run, exit 0 |
| Base drift | PASS | `origin/main` after fetch equals the merge base `2c8dee6dd` |

## CI Cross-check

No pull request exists for the branch (`gh pr list --head` returns none), and no CI run exists for it (`gh run list --branch` returns none). The rows below are local evidence.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 formatter changes, 0 analyzer findings, 0 leak findings | 73ecccd13 | `evidence/qa-gates/powershell-static.2026-11-14T06-41.md` (sources unchanged since) |
| poshqc / PowerShell QC | pass | 24311 passed, 0 failed; 95.97% lines | 73ecccd13 | `evidence/qa-gates/pester-reviewer-gate.2026-11-14T07-32.md` |
| quality-checks7 / Code Quality & Tests | pass | 16815 passed, 0 failed; 94.93% lines, 90.46% branches | 73ecccd13 | `evidence/qa-gates/pytest.2026-11-14T06-59.md` (run after the last Python-touching commit) |
| Extension tests (Jest) | pass | 5624 passed; 97.18% lines, 94.00% branches | 73ecccd13 | `evidence/qa-gates/jest.2026-11-14T07-01.md` |
| TypeScript tests, root configuration (Jest) | pass | 5641 passed; 98.29% lines, 93.72% branches | 73ecccd13 | `evidence/qa-gates/jest-root-gate.2026-11-14T07-12.md` |

The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All executor evidence and the reviewer's two gate records are under `docs/features/active/2026-11-09-cross-epic-dependencies-1162/evidence/<kind>/`. No absolute path or host name appears in the added lines or the evidence (reviewer search of the diff).

## Rejected Scope Narrowing

None. The caller asked the reviewer to read the gate artifacts rather than re-run format, lint, and type checks; that matches the evidence model and narrows no file. The reviewer re-ran the PowerShell and root TypeScript test gates only for the freshness reasons stated above. This audit covers the full `2c8dee6dd..73ecccd13` diff.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists. The branch adds no new project folder: the new files sit in the existing `.claude/lib/epic-wave/`, `.claude/lib/orchestrator-state/`, and `.claude/skills/epic-progress-report/scripts/` directories.

## Workflow Rule

No path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` changed, so `modified-workflow-needs-green-run` does not fire. One path under `docs/engineering/process-reductions/` changed: `patches/0010-early-dependent-starts.patch` was regenerated so the stored reversal still applies over this item's edits. No reduction was added or withdrawn, and the ledger-chain suites pass.

## Owner Directives

OD-1 to OD-8 were received in the delegation block. Decisions are stated in the final message as `OWNER-DIRECTIVE-DECISION:` lines. OD-4 (command shapes), OD-5 (parallel-only, one suite at a time), OD-6 (append-only evidence), and OD-8 (fix related findings inside the item) shaped this review. The reviewer added two new evidence files and edited none. F1 and F2 are related findings routed to remediation inside this item.

---

## 8. Gaps and Exceptions

### Identified Gaps

- Blocking (F1): readiness fetch without pruning; stale remote-tracking ref read as a live branch.
- Blocking (F2): D7 records paragraph lacks the decision-to-status mapping that the started-while-held invariant requires.
- Non-blocking: `EpicCrossDependency.psm1` at 769 lines (advisory tier).

### Approved Exceptions

None.

### Removed/Skipped Tests

None removed. The 10 Pester skips and 6 pytest skips match the Phase 0 baseline counts.

---

## 9. Summary of Changes

- New production files: `EpicCrossDependency.psm1`, `Invoke-EpicCrossReadiness.ps1`, `OrchestratorStateEpicCrossDependency.psm1`, `Get-EpicProgressReport.CrossEpic.ps1`, with bundle and stored copies.
- Edited production files: `OrchestratorStateEpicWaveBarrier.psm1`; five progress-report part files; four Python validator modules; four TypeScript validator files; `jest.config.cjs`.
- Surfaces: epic-orchestrate, epic-plan, epic-run, and epic-progress-report skills; epic-orchestrator and epic-planner agents; Codex variants; both epic templates; pack manifests; frozen digests; ledger patch 0010.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

### Policy-by-Policy Summary

- General code change: PARTIAL (F2 documentation gap)
- General unit test: PASS
- PowerShell code change and unit test: FAIL on adapter correctness (F1); toolchain PASS
- Python code change and unit test: PASS
- TypeScript code change and unit test: PASS

### Metrics Summary

- PowerShell 95.97% lines; Python 94.93% lines, 90.46% branches; TypeScript 98.29% lines, 93.72% branches (root).
- Pester 24311, pytest 16815, Jest 5624 (extension) and 5641 (root) passed; 0 failures.
- Blocking findings: 2 (F1, F2), both autonomous and contained.

### Recommendation

Run a remediation cycle for F1 and F2 per `remediation-inputs.2026-11-14T07-20.md`, then re-review.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1` (new)
- `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1` (new)
- `tests/scripts/claude-lib/epic-wave/Invoke-EpicCrossReadiness.Tests.ps1` (new)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicCrossDependency.Tests.ps1` (new)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicCrossDependency.Parity.Tests.ps1` (new)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1`, `OrchestratorState.Manifest.Tests.ps1` (modified)
- `tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1` (new)
- `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CrossEpic.Tests.ps1` (new); `EpicProgressReport.SkillContract.Tests.ps1`, `Get-EpicProgressReport.CriticalPath.Tests.ps1`, `Get-EpicProgressReport.Render.CriticalPath.Tests.ps1`, `Get-EpicProgressReport.Schedule.Tests.ps1`, `Get-EpicProgressReport.Tests.ps1` (modified)
- `tests/scripts/dev_tools/test_epic_cross_dependency_validation.py`, `test_epic_cross_dependency_parity_corpus.py` (new); `parallel_orchestrator_surface_expectations.py`, `test_push_down_codex_and_agents_virtual_paths.py` (modified)
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-cross-dependency.test.ts` (new)
- Corpus: `tests/fixtures/epic_cross_dependency/cross-dependency-cases.json`, `epic-without-cross-edges.md`

## Appendix B: Toolchain Commands Reference

- PowerShell tests and coverage: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>`
- PowerShell static: `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCLeakScan` with `-Root <item worktree root>`
- Python: `env -u VIRTUAL_ENV poetry run pytest -n auto --cov=scripts.dev_tools --cov-branch`; `black --check .`; `ruff check .`; `pyright`
- TypeScript: `node run-jest.cjs --coverage` at the worktree root and in `extensions/drm-copilot`; `npx prettier --check`; `npx eslint`; `npm run typecheck`
- Evidence locations: `python scripts/dev_tools/validate_evidence_locations.py --root <item worktree root>`
- Reviewer probe: SCRATCH `r1162-staleref.sh` (bare remote, two clones, branch deleted from the second clone, `git show` of the stale ref after an unpruned and a pruned fetch)
