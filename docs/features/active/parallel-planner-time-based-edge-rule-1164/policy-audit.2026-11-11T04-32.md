# Policy Compliance Audit: parallel-planner-time-based-edge-rule (Issue #1164)

**Audit Date:** 2026-11-11
**Code Under Test:** merge base `228e6f8c4606e53f36963dc9aa57d71b4882b49e` of the base branch `main` (equal to `origin/main` after a fetch at review time) and reviewed head `35e8a26275d7f89e559449f2437dfc18aa654b0f` on branch `feature/parallel-planner-time-based-edge-rule-1164`; the diff between them lists 162 changed files (9306 insertions, 318 deletions).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 21 files (7 production, 7 bundle mirrors, 7 test) | 21581 tests | ✅ 21571 pass, 0 fail, 10 skipped | 95.79% lines | 95.81% lines | 99.39% lines (162 of 163 changed lines) |
| Python | 17 files (8 production, 9 test) | 16673 tests | ✅ 16667 pass, 0 fail, 6 skipped | 97.11% lines, 94.38% branches | 97.13% lines, 94.41% branches | 100.00% lines (198 of 198 changed lines) |
| TypeScript | 6 files (3 production, 3 test) | 5499 tests | ✅ 5499 pass, 0 fail | 97.15% lines, 93.87% branches | 97.17% lines, 93.91% branches | 100.00% lines (305 of 305 changed lines) |
| Bash | 4 files (2 production, 2 bundle mirrors) | 799 bats tests | ✅ 799 ok, 0 not ok (CI) | 94.7% lines | 94.9% lines | 100.00% lines (70 of 70 changed lines) |
| JSON | 40 files (2 config copies, 1 pack manifest, 37 test fixtures) | N/A | ✅ config-parity and pack-manifest contract tests pass | N/A (config and fixture files) | N/A (config and fixture files) | N/A |
| Markdown | 74 files (12 planning surfaces, 2 orchestrate skill copies, feature docs and evidence) | N/A | ✅ wording contract test passes (228 tests) | N/A (documentation) | N/A (documentation) | N/A |

The PowerShell, Python, and TypeScript post-change figures were parsed by the reviewer from the canonical artifacts in the item worktree (`artifacts/pester/powershell-coverage.xml` JaCoCo root LINE counter 37690 of 39337; `artifacts/python/lcov.info` 386 files, 34525 of 35546 lines and 12758 of 13514 branches; `extensions/drm-copilot/coverage/lcov.info` 255 files, 63979 of 65845 lines and 9785 of 10419 branches). They equal the figures of the post-merge gate records. The Jest record states 97.16% lines; the reviewer's computation from the same counts is 97.17% (63979 / 65845 = 97.166%), a rounding difference only. The bash figures come from the CI `shell-coverage` job (kcov) of run 42746009388. Changed-line counts come from `evidence/qa-gates/coverage-comparison.2026-11-10T02-09.md`; the reviewer confirmed that every missed line in the canonical artifacts lies outside the branch's changed hunks except line 96 of the new file `ParallelAdmissionPrecedenceGate.psm1`.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/baseline/jest-gate.2026-11-09T23-40.md` (Phase 0 run, 97.15% lines, 93.87% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (item worktree, written 2026-11-10T04:05Z by the post-merge run), summarized in `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/qa-gates/jest-gate.2026-11-10T04-06.md`
- PowerShell baseline coverage artifact: `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/baseline/pester-gate.2026-11-09T23-35.md` (Phase 0 run, 95.79% lines)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (item worktree, written 2026-11-10T04:32Z by the post-merge `Invoke-PoshQCParallelTest` run), summarized in `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/qa-gates/pester-gate.2026-11-10T04-34.md`
- Python baseline coverage artifact: `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/baseline/pytest-gate.2026-11-09T23-39.md` (Phase 0 run, 97.11% lines, 94.38% branches)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (item worktree, written 2026-11-10T04:01Z by the post-merge run), summarized in `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/qa-gates/pytest-gate.2026-11-10T04-06.md`
- Bash baseline coverage artifact: `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/baseline/shell-ci.2026-11-09T23-37.md` (main CI run 42703258177, kcov 94.7%)
- Bash post-change coverage artifact: CI run 42746009388 `shell-coverage` artifact, summarized in `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/qa-gates/shell-ci.2026-11-10T03-17.md`
- Per-language comparison summary: section 1.2.1 of this audit

Baseline coverage is read from the plan's `Phase 0 baseline` artifacts. Freshness: the newest commit that changes a PowerShell, Python, or TypeScript file is the merge commit `25dcbcdc2` (2026-11-10T03:39:23Z); the three canonical artifacts were written after it (04:01Z, 04:05Z, 04:32Z). The only later commit, `35e8a2627`, adds seven evidence files under the feature folder and no code. No bash file changed after the CI run head `02f7ff869` (`git diff --name-only 02f7ff869 HEAD -- .claude/lib/bash` is empty). The worktree is clean (`git status --porcelain` empty).

---

## Executive Summary

The branch implements owner directive OD-1164-1: two parallel items run sequentially if and only if the expected merge time exceeds the expected time gained by running them in parallel. It recalibrates `conflict_tolerance` in both config copies to integer minutes (band durations C1 30, C2 45, C3 90, C4 180; weights `same_file` 90, `contract` 90, `possible_overlap` 20, `module` 10, `append_only` 10, new optional `separable` 15). It adds access-aware path pricing (`read_paths` cost 0, `separable_paths` priced at `separable`) in PowerShell (`BlastRadiusAccess.psm1`) and Python (`_path_pair_weight`), and a drift escape for writes to read-declared paths (`ParallelDriftAccess.psm1`, `_parallel_drift_scheduling.py`). It adds a precedence gate (`ParallelAdmissionPrecedenceGate.psm1`, `test-precedence` subcommand, rejection code `precedence_not_justified`) and an `access-paths` derivation subcommand. Per-pair estimates are recorded and validated on checkpoints (Python and TypeScript) and on the manifest (invariant M9, Python and bash). The rule text is added to the twelve planning surfaces.

The reviewer verified the following directly at head:
- All 16 changed `.claude/` files are byte-identical to their bundle mirrors (`cmp`). The two `config/blast-radius.json` copies differ outside `conflict_tolerance`, as they did at the merge base, and their parsed `conflict_tolerance` members are equal and match spec B3.
- Each of the four new `.claude/` files has one `core.json` entry.
- The canonical coverage artifacts reproduce the recorded per-file and repo-wide figures exactly.
- No covered file reaches 700 logical lines (largest: `Invoke-ParallelAdmission.ps1`, 687). `config/file-size-baseline.json` is unchanged.
- `validate_evidence_locations` exits 0.
- A real-process probe of `test-precedence` covered nine shapes. It reproduced the exact spec B6.3 rejection line, exit 0 and exit 1 per case, the legacy skip, and the blank-reason rejection.
- A real-process probe of `access-paths` on the item's own plan derived exactly the path named only by `Run` tasks.
- The branch validators and the `main` validators return identical results (0 errors each) on 8 real planner and orchestrator checkpoints from the main checkout and sibling worktrees.
- A cross-runtime probe (esbuild bundle of the worktree TypeScript validator against the Python validator) found two divergences at new error sites. Both come from the shared `pythonRepr` helper, which the branch did not change. See section 8.

No blocking finding. US-AC13 (the PR body states the behaviour change and the MCP release dependency) cannot be verified before the pull request exists. It is listed as pending-PR and owned by the orchestrator at PR authoring.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `quality-tiers.md` (repository has adopted tiers; `quality-tiers.yml` exists)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (`.claude/rules/python.md`, `.claude/rules/python-suppressions.md`)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` (`.claude/rules/typescript.md`)
- ✅ Bash: shfmt and shellcheck through CI `shell-qc check`, 0 findings
- N/A C#: no C# file in the branch diff

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; executor helpers lived under the issue SCRATCH directory outside the repository (`git status --porcelain` is clean at head).
- ✅ No new tooling script was added; the new files are the planned modules, tests, and fixtures.
- Reviewer probe scripts (`r1164_cov.txt`, `r1164_probe.sh`, `r1164_ap.sh`, `r1164_mut.txt`, `r1164_ts.cjs`, `r1164_real.txt`) live in the session scratchpad outside the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Parallel gates only: 8-worker `Invoke-PoshQCParallelTest`, `pytest -n auto`, Jest workers, all 0 failed; `Invoke-PoshQCLeakScan` 0 failures (`evidence/qa-gates/powershell-static.2026-11-10T04-06.md`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | `BlastRadiusAccess.Tests.ps1` and `test_blast_radius_access_weights.py` test one weight row per case; `ParallelAdmissionPrecedenceGate.Tests.ps1` tests one gate outcome per case. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | pytest 16673 tests in 344.78 s under load; Jest 45.08 s; the new suites are in-memory. |
| **Determinism** - Consistent results | ✅ PASS | Plan text and records are passed in memory; corpus fixtures are committed JSON; no clock, network, or temporary file in the new tests. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Behavior-named cases; shared corpora carry a `description` naming the spec rows. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 95.79% lines; Python 97.11% lines, 94.38% branches; TypeScript 97.15% lines, 93.87% branches; bash 94.7% lines<br>**Command:** Phase 0 `Invoke-PoshQCParallelTest`, `pytest -n auto --cov-branch --cov`, `node run-jest.cjs --coverage`, main CI `shell-coverage`<br>**Artifact:** `evidence/baseline/*-gate.2026-11-09T23-*.md`, `evidence/baseline/shell-ci.2026-11-09T23-37.md`<br>**Timestamp:** 2026-11-09 23:35 to 23:40 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.81%; Python 97.13% / 94.41%; TypeScript 97.17% / 93.91%; bash 94.9%<br>**Change:** +0.02 / +0.02 and +0.03 / +0.02 and +0.04 / +0.2 points<br>**Status:** No per-file drop on any changed production file (section 5). |
| **Changed Files Meet Thresholds** | ✅ PASS | **Thresholds:** 85% line and 75% branch (root `CLAUDE.md` states no threshold, so the defaults govern; Pester and kcov have no branch gate)<br>**Status:** lowest changed production file `Invoke-ParallelAdmission.ps1` 96.79% lines; lowest branch figure `parallel-orchestrator-state-core.ts` 92.11%. |
| **New Code Coverage ≥90%** | ✅ PASS | **New files:** `BlastRadiusAccess.psm1` 100%, `ParallelAdmissionPrecedenceGate.psm1` 97.62%, `ParallelDriftAccess.psm1` 100%, `parallel-manifest-pairs.sh` 100%<br>**Changed lines:** 735 of 736 covered across languages; the one missed line is line 96 of `ParallelAdmissionPrecedenceGate.psm1` (`return $null` when the item key is absent from `items`). |
| **Comprehensive Coverage** | ✅ PASS | Every spec B4 row is a case of the shared corpus `tests/fixtures/blast_radius/scheduling/scheduling-1164-committed-minutes.json`, run by both runtimes; 23 validator corpus cases under `tests/fixtures/parallel_state_scheduling/`; 7 new M9 manifest fixtures. |
| **Positive Flows** - Valid inputs | ✅ PASS | Accept fixtures (`accept-planner-fields-valid.json`, `accept-orchestrator-overlap-valid.json`, `accept-without-fields.json`, `manifest_m9_valid_pair_decisions.json`); cost-edge precedence accepted. |
| **Negative Flows** - Invalid inputs | ✅ PASS | 18 `reject-*` validator fixtures; `weights.separable` zero, negative, boolean, non-integer rejected by both readers; tolerated cost entry rejected. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Tie C3/C3 (90 against 90) tolerated; tolerance 0 strict case; `conflict_tolerance` absent; separable on one side only falls through. |
| **Error Handling** - Error paths | ✅ PASS | `Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1` drives the CLI rejection path to exit 1 and the exact signal line. |
| **Concurrency** - If applicable | N/A | Pure functions with no shared state. |
| **State Transitions** - If applicable | ✅ PASS | Drift re-pricing of peers with their declarations (`ParallelDriftAccess.Tests.ps1`, `test_parallel_drift_scheduling.py`). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.79% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.81% lines. Change: +0.02% lines. New/changed-code coverage: 99.39% lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/pester-gate.2026-11-10T04-34.md`, `evidence/baseline/pester-gate.2026-11-09T23-35.md`.
- Python: Baseline: 97.11% lines, 94.38% branches (from the `Phase 0 baseline` artifact) -> Post-change: 97.13% lines, 94.41% branches. Change: +0.02% lines, +0.03% branches. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/pytest-gate.2026-11-10T04-06.md`, `evidence/baseline/pytest-gate.2026-11-09T23-39.md`; CI run 42746009388 job `quality-checks7 (3.13)` succeeded, which includes `Enforce Python coverage thresholds`.
- TypeScript: Baseline: 97.15% lines, 93.87% branches (from the `Phase 0 baseline` artifact) -> Post-change: 97.17% lines, 93.91% branches. Change: +0.02% lines, +0.04% branches. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/qa-gates/jest-gate.2026-11-10T04-06.md`, `evidence/baseline/jest-gate.2026-11-09T23-40.md`.
- Bash: Baseline: 94.7% lines (from the `Phase 0 baseline` artifact) -> Post-change: 94.9% lines. Change: +0.2% lines. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: CI run 42746009388 `shell-coverage` artifact, `evidence/qa-gates/shell-ci.2026-11-10T03-17.md`, `evidence/baseline/shell-ci.2026-11-09T23-37.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Corpus tests compare the full expected error list and name the case (`assert errors == case["expected_errors"], path.stem`; Jest `it.each` with the case name). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange / Act / Assert comments in the new TypeScript and Pester files. |
| **Document Intent** | ✅ PASS | Module docstrings and file-level help blocks name the issue and spec section. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or database use; the bash parity lane reads committed fixtures. |
| **Use Mocks/Stubs** | ✅ PASS | The CLI tests inject the file-read seam (`Read-ParallelAdmissionJsonText`) instead of touching disk. |
| **Environment Stability** | ✅ PASS | No temporary files; fixtures are read in place. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-10T03-18.md` (108 PASS, 0 FAIL) and this audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md`, and `user-story.md` (issue #1164, OD-1164-1). |
| **Read existing change plans** | ✅ PASS | `research/research.2026-11-09T22-15.md`; plan `plan.2026-11-09T16-56.md`; correction plan `remediation-plan.2026-11-10T02-18.md`. |
| **Document the plan** | ✅ PASS | Plan and three preflight-fix records under `evidence/other/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The rule shape is unchanged; only committed values, one pricing row set, and recording change. |
| **Reusability** | ✅ PASS | `BlastRadiusAccess.psm1` reuses `Test-GlobEntry` and `Test-MergeablePath`; the gate reuses `Get-BlastRadiusPairBenefit`. |
| **Extensibility** | ✅ PASS | New fields are optional and key-gated; `ItemAccess` defaults to `NO_ACCESS`, so existing callers are unchanged. |
| **Separation of concerns** | ✅ PASS | Pure logic in new host-neutral modules; `Invoke-ParallelAdmission.ps1` gains two thin subcommand wrappers that read through the existing seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Access pricing, precedence gate, and drift access each live in their own module. |
| **At or below the 800-line hard limit** | ✅ PASS | Reviewer logical line counts at head: largest covered files `Invoke-ParallelAdmission.ps1` 687, `_blast_radius_scheduling.py` 663, `parallel-state-records.ts` 658. No file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | `BlastRadiusAccess.psm1` exports two functions; the gate exports one. |
| **No circular dependencies** | ✅ PASS | The gate imports the scheduling module; the scheduling module does not import the gate. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved PowerShell verbs; `snake_case` Python; `camelCase` TypeScript. |
| **Docs/docstrings** | ✅ PASS | Comment-based help and Google-style docstrings with Args and Returns (`evidence/qa-gates/commenting-sweep.2026-11-10T02-42.md`, 0 findings). |
| **Comment why, not what** | ✅ PASS | Loop intent and row-order comments state why (for example, append-only precedes every write class). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter` check with `pssa.settings.psd1`; `black --check`; `prettier --check`; CI `shfmt` diff<br>**Result:** 0 differences (`powershell-static`, `python-static`, `typescript-static` records of 2026-11-10T04-06; `shell-ci.2026-11-10T03-17.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer`; `ruff check`; `npm run lint`; `shellcheck`<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`; `npm run typecheck`<br>**Result:** 0 errors; N/A for PowerShell and bash |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`; `pytest tests/ -n auto`; `node run-jest.cjs --coverage`; CI bats<br>**Result:** 21571, 16667, 5499, and 799 passed; 0 failures |
| **Full toolchain loop** | ✅ PASS | Post-merge static and test gates recorded after the last code-bearing commit `25dcbcdc2`. |
| **Explicit reporting** | ✅ PASS | Commands and exit codes under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit subjects per phase; spec `## Implementation Strategy`. |
| **Design choices explained** | ✅ PASS | Spec `## Decisions for Owner Review` D1 to D10. |
| **Update supporting documents** | ✅ PASS | Rule, skills, agents, and mirrors updated (section 9). |
| **Provide next steps** | ✅ PASS | Spec rollout: the PR body must call out the behaviour change and the MCP release dependency (US-AC13). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No new Python production file** | ✅ PASS | `git diff --name-status` lists no `A` entry under `scripts/`; the four named modules are extended in place. |
| **Type hints and frozen dataclasses** | ✅ PASS | `ItemAccess` is a frozen dataclass; new keyword-only parameters default to `NO_ACCESS`. |
| **Suppressions** | ✅ PASS | One `# pyright: ignore[reportPrivateUsage]` in the test file `test_blast_radius_access_weights.py` (line 21) importing `_path_pair_weight`. The suppression policy governs `# noqa` and `# type: ignore`; the repository has 39 such pyright test-file uses. Recorded as a Minor code-review row. |
| **Errors** | ✅ PASS | `_read_int_map` raises `TypeError`/`ValueError` with the same labels as existing weights. |

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on every new function. |
| **Parameter validation** | ✅ PASS | `Mandatory` on required inputs; `[AllowNull()]`/`[AllowEmptyCollection()]` on optional ones. |
| **ShouldProcess** | N/A | No state-changing function; the new modules are pure. |
| **Strict mode and error handling** | ✅ PASS | `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, sibling imports with `-ErrorAction Stop`. |
| **PSScriptAnalyzer** | ✅ PASS | 0 findings on the 21 `.ps1`/`.psm1` files. |

### Section 3C: TypeScript Code Change Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No new production file** | ✅ PASS | No `A` entry under `extensions/drm-copilot/src`. |
| **Escape hatches** | ✅ PASS | No `any`, `as any`, `ts-ignore`, or `eslint-disable` in the added lines. |
| **Parity port** | ✅ PASS | Shared corpus reproduced by both runtimes; divergence classes in section 8. |

### Section 3D: JSON and Bash Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Config copies** | ✅ PASS | `conflict_tolerance` parsed equal in both copies; `test_blast_radius_config_parity` 20 passed. |
| **Pack manifest** | ✅ PASS | One entry per new file; completeness and dependency-closure tests pass. |
| **Bash sourcing** | ✅ PASS | `# shellcheck source=` plus `disable=SC1091`, the existing pattern of `parallel-manifest-validate.sh`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Coverage expectation** | ✅ PASS | Every changed Python production file at 100% lines and branches except `validate_parallel_orchestrator_state.py` 97.78% / 94.12% (missed lines 235 and 274 are pre-existing, outside the changed hunks). |
| **Focused unit tests** | ✅ PASS | Parametrized corpus cases with one expected error list each. |
| **Mocking sparingly** | ✅ PASS | No mocks in the new Python tests. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester 5+ syntax** | ✅ PASS | `Describe`/`Context`/`It` with `BeforeAll`. |
| **Test location** | ✅ PASS | `tests/scripts/claude-lib/<module folder>/` mirrors `.claude/lib/`. |
| **Coverage** | ✅ PASS | New modules 100%, 97.62%, 100%; no changed-line regression. |

### Section 4C: TypeScript Unit Test Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Jest structure** | ✅ PASS | `describe`/`it.each` with Arrange/Act/Assert comments. |
| **Coverage** | ✅ PASS | `parallel-state-records.ts` 100% / 100%; the two core files unchanged in branch figures. |

---

## 5. Test Coverage Detail

Per-file figures parsed by the reviewer from the canonical artifacts at head:

- PowerShell: `BlastRadiusAccess.psm1` 53/53; `BlastRadiusScheduling.psm1` 136/136; `Invoke-ParallelAdmission.ps1` 241/249 (missed 86, 87, 99, 341, 680, 684 to 686: seams and entry-script tail, outside the changed hunks); `ParallelAdmissionPrecedence.psm1` 179/179; `ParallelAdmissionPrecedenceGate.psm1` 41/42 (missed 96); `ParallelDrift.psm1` 128/128; `ParallelDriftAccess.psm1` 14/14.
- Python (lines, branches): `_blast_radius_scheduling.py` 171/171, 40/40; `_parallel_drift_scheduling.py` 47/47, 18/18; `_parallel_state_records.py` 191/191, 96/96; `parallel_drift_detection.py` 80/80, 26/26; `parallel_drift_detection_cli.py` 75/75, 10/10; `parallel_manifest_contract.py` 168/168, 82/82; `validate_parallel_orchestrator_state.py` 88/90, 32/34; `validate_parallel_planner_state.py` 117/117, 46/46.
- TypeScript (lines, branches): `parallel-state-records.ts` 658/658, 141/141; `parallel-planner-state-core.ts` 468/468, 48/49; `parallel-orchestrator-state-core.ts` 324/326, 35/38.
- Bash (CI kcov): `parallel-manifest-pairs.sh` 68/68; `parallel-manifest-validate.sh` 119/122 (missed 97, 98, 262 pre-existing).

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Skipped | Source |
|-----|-------|--------|--------|---------|--------|
| Pester full tree, post-merge | 21581 | 21571 | 0 | 10 | `evidence/qa-gates/pester-gate.2026-11-10T04-34.md` |
| pytest full tree, post-merge | 16673 | 16667 | 0 | 6 | `evidence/qa-gates/pytest-gate.2026-11-10T04-06.md` |
| Jest extension, post-merge | 5499 | 5499 | 0 | 0 | `evidence/qa-gates/jest-gate.2026-11-10T04-06.md` |
| Bats with kcov (CI run 42746009388) | 799 | 799 | 0 | 0 | `evidence/qa-gates/shell-ci.2026-11-10T03-17.md` |
| Reviewer test-precedence probe | 9 shapes | 9 as specified | 0 | 0 | scratchpad `r1164_probe.sh` |
| Reviewer validator backward-compat probe | 8 real checkpoints | 8 identical to main | 0 | 0 | scratchpad `r1164_real.txt` |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| PowerShell format and lint | PASS | `evidence/qa-gates/powershell-static.2026-11-10T04-06.md` (21 files) |
| Leak scan | PASS | same record |
| Python static (Black, Ruff, Pyright) | PASS | `evidence/qa-gates/python-static.2026-11-10T04-06.md` (17 files) |
| TypeScript static (Prettier, ESLint, tsc) | PASS | `evidence/qa-gates/typescript-static.2026-11-10T04-06.md` |
| Bash static (shfmt, shellcheck) | PASS | CI run 42746009388 `shell-qc check` step |
| Mirror byte-equality | PASS | reviewer `cmp` of 16 pairs |
| Evidence-location validator | PASS | reviewer run, exit 0 |
| Base drift | PASS | `origin/main` after fetch equals the merge base `228e6f8c4` |

## CI Cross-check

No pull request exists for the branch yet. The newest CI run on the branch is workflow_dispatch run 42746009388 at `02f7ff869` (conclusion success, all 23 jobs). The later commits are the merge of `origin/main` (`25dcbcdc2`, no conflicts) and an evidence-only commit (`35e8a2627`); their local gates are listed below.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 formatter differences, 0 analyzer findings on 21 files | 25dcbcdc2 | `evidence/qa-gates/powershell-static.2026-11-10T04-06.md` |
| poshqc / PowerShell QC | pass | 21571 passed, 0 failed; 95.81% lines | 25dcbcdc2 | `evidence/qa-gates/pester-gate.2026-11-10T04-34.md` |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 16667 passed, 0 failed; 97.13% lines, 94.41% branches | 25dcbcdc2 | `evidence/qa-gates/pytest-gate.2026-11-10T04-06.md`; CI run 42746009388 at 02f7ff869 success |
| Python static (Black, Ruff, Pyright) | pass | 0 findings on 17 files | 25dcbcdc2 | `evidence/qa-gates/python-static.2026-11-10T04-06.md` |
| Extension tests (Jest) | pass | 5499 passed; 97.17% lines, 93.91% branches | 25dcbcdc2 | `evidence/qa-gates/jest-gate.2026-11-10T04-06.md` |
| TypeScript lint and typecheck | pass | 0 findings | 25dcbcdc2 | `evidence/qa-gates/typescript-static.2026-11-10T04-06.md` |
| shell-coverage / Shell Coverage (Bats + kcov) | pass | 799 ok; 94.9% lines | 02f7ff869 | `evidence/qa-gates/shell-ci.2026-11-10T03-17.md` |
| CI Required Gate | pass | all 23 jobs success | 02f7ff869 | `evidence/qa-gates/shell-ci.2026-11-10T03-17.md` |

The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.

---

## Evidence Location Compliance

`validate_evidence_locations --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All executor evidence is under `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/<kind>/`.

## Rejected Scope Narrowing

None. The caller prompt did not narrow scope; this audit covers the full `228e6f8c4..35e8a2627` diff.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists. The new modules lie under the classified paths `.claude/lib/blast-radius`, `.claude/lib/parallel-admission`, `.claude/lib/parallel-drift`, and `.claude/lib/bash`; no new project folder was added.

## Workflow Rule

No path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` changed, so `modified-workflow-needs-green-run` does not fire. No path under `docs/engineering/process-reductions/` changed, and the branch reduces no evidence, plan task, gate, or review process.

---

## 8. Gaps and Exceptions

### Identified Gaps

- Non-blocking: cross-runtime string parity for inputs containing an apostrophe. The new error sites `items[i] read_paths entry <repr> is not in blast_radius.paths.` and `tolerated_overlaps[i] reasons ... found: <repr>.` interpolate the value through Python `repr` and the TypeScript `pythonRepr` helper of `parallel-state-shared.ts`. For `it's.md`, Python prints `"it's.md"` and TypeScript prints `'it\'s.md'`. The helper is unchanged by the branch, and the same divergence already applies to the pre-existing `repr` sites of the parallel validators. The committed corpus is byte-identical in both runtimes. The reviewer probe also confirmed two inherent runtime differences: an integral float `90.0` is rejected by Python and accepted by TypeScript, and the parser messages for unparseable JSON differ.
- Non-blocking: the one uncovered line in a new file (`ParallelAdmissionPrecedenceGate.psm1` line 96) is the null-band return when a precedence key is absent from `items`; the file is at 97.62%.

### Approved Exceptions

None.

### Removed/Skipped Tests

None removed. The 10 Pester skips and 6 pytest skips match the Phase 0 baseline counts.

---

## 9. Summary of Changes

- New production files: `.claude/lib/blast-radius/BlastRadiusAccess.psm1`, `.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1`, `.claude/lib/parallel-drift/ParallelDriftAccess.psm1`, `.claude/lib/bash/parallel-manifest-pairs.sh`, and their bundle copies.
- Edited production files: `BlastRadiusScheduling.psm1`, `Invoke-ParallelAdmission.ps1`, `ParallelAdmissionPrecedence.psm1`, `ParallelDrift.psm1`, `parallel-manifest-validate.sh` (with mirrors); eight Python modules; three TypeScript validator files; both `blast-radius.json` copies; `core.json`.
- Surfaces: six planning surfaces plus `parallel-orchestrate`, each with its mirror.
- Tests: seven new test files, eleven edited test files, 37 new fixtures.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

### Policy-by-Policy Summary

- General code change: PASS
- General unit test: PASS
- PowerShell code change and unit test: PASS
- Python code change and unit test: PASS
- TypeScript code change and unit test: PASS
- Bash: PASS

### Metrics Summary

- PowerShell 95.81% lines; Python 97.13% lines, 94.41% branches; TypeScript 97.17% lines, 93.91% branches; bash 94.9% lines.
- Pester 21571, pytest 16667, Jest 5499, bats 799 passed; 0 failures.
- Blocking findings: 0.

### Recommendation

Ready for the normal PR flow. The PR body must carry the two statements of US-AC13; the orchestrator owns that and the S9 CI gate on the final head.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-lib/blast-radius/BlastRadiusAccess.Tests.ps1` (new)
- `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1` (modified)
- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1` (new)
- `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1` (modified)
- `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedenceGate.Tests.ps1` (new)
- `tests/scripts/claude-lib/parallel-drift/ParallelDriftAccess.Tests.ps1` (new)
- `tests/scripts/claude-runtime/parallel-scheduling-rule-wording.Tests.ps1` (new, 228 tests)
- `tests/scripts/dev_tools/test_blast_radius_access_weights.py` (new, 18 tests)
- `tests/scripts/dev_tools/test_parallel_state_scheduling_parity.py` (new, 22 tests)
- `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`, `test_blast_radius_contract_weight.py`, `test_blast_radius_scheduling.py`, `test_parallel_drift_detection_cli.py`, `test_parallel_drift_scheduling.py`, `test_parallel_issue_combination_contracts.py`, `test_validate_parallel_state_tolerated_edge_fields.py` (modified)
- `extensions/drm-copilot/test/lib/validate/parallel-state-scheduling-parity.test.ts` (new); `parallel-state-tolerated-edge-fields.test.ts`, `test/lib/push-down/config-carriage.test-helpers.ts` (modified)

## Appendix B: Toolchain Commands Reference

- PowerShell tests and coverage: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>`
- PowerShell static: `Invoke-Formatter` and `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`; `Invoke-PoshQCLeakScan -Root <item worktree root>`
- Python tests and coverage: `env -u VIRTUAL_ENV poetry run pytest tests/ -n auto --cov-branch --cov-report=term-missing --cov`
- Python static: `black --check`, `ruff check`, `pyright` over the changed files
- TypeScript: `node run-jest.cjs --coverage`; `npx prettier --check`; `npm run lint`; `npm run typecheck` in `extensions/drm-copilot`
- Bash: CI `ci.yml` jobs `shell-qc check` and `shell-coverage / Shell Coverage (Bats + kcov)`
- Evidence locations: `python -m scripts.dev_tools.validate_evidence_locations --root <item worktree root>`
- Reviewer probes: `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 test-precedence -Entry <json>` and `access-paths -Entry <json>` from the worktree root; esbuild bundle of `src/lib/validate/orchestration-artifacts.ts` compared with the Python validators
