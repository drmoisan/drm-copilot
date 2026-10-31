# Policy Compliance Audit: Parallel Scheduling Integration Cost (#1013)

---

**Audit Date:** 2026-10-31
**Branch:** `feature/parallel-scheduling-integration-cost-1013` @ `8683e0a7531b22794dac7b0431127cba5b390484`
**Base:** `main` (resolved `origin/main`), merge base `1174736c7a3cbd7dd5c73620b2c1ed02ec2c3cd6`
**Code Under Test:** `scripts/dev_tools/_blast_radius_scheduling.py`, `scripts/dev_tools/_blast_radius_aggregate.py` (new), `scripts/dev_tools/_blast_radius_combination.py` (new), `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`, `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` (new), `.claude/lib/blast-radius/BlastRadiusCombination.psm1` (new), `.claude/lib/blast-radius/BlastRadius.psm1`, their four bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`, both `config/blast-radius.json` truth tables, `pack-manifests/core.json`, eight skill/agent/rule Markdown sources and their bundle copies, the parallel-status template, 4 TypeScript test files, 13 Python test files, 8 Pester test files, and 20 JSON fixtures. Full list: Section 9.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 3 production, 13 test files | 16061 collected (full suite) | ✅ 16055 pass, 0 fail, 6 skip | 100.00% lines, 100.00% branches (`_blast_radius_scheduling.py`, 143/143, 32/32) | 99.63% lines (272/273), 97.14% branches (68/70) across the three measured modules | 99.29% lines (114/115), 94.12% branches (32/34) across the two new modules |
| PowerShell | 4 production (+4 byte-identical bundle copies), 8 test files | 13688 (full tests/scripts Pester run) | ✅ 13678 pass, 0 fail, 10 skip | 100.00% lines (BlastRadiusScheduling.psm1 116/116; BlastRadius.psm1 108/108) | 100.00% lines (356/356) across the four measured modules | 100.00% lines (109/109) across the two new modules |
| TypeScript | 0 production, 4 test files | 5284 extension + 5301 root Jest tests | ✅ all pass, 0 fail | N/A - no coverage artifact exists (`coverage/lcov.info` absent); verdict FAIL, see 1.2.1 | N/A - no coverage artifact exists; verdict FAIL, see 1.2.1 | N/A - no TypeScript production file changed |
| JSON | 20 fixtures, 2 truth tables, 1 pack manifest | N/A | ✅ parsed by the suites above; contract tests pass | N/A (config files) | N/A (config files) | N/A |
| Bash | 0 files | N/A | N/A (bats lane reads a new JSON fixture; runs in CI) | N/A (no coverage) | N/A (no coverage) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: absent. `coverage/lcov.info` does not exist in the worktree; `evidence/baseline/typescript-tests.2026-10-31T15-10.md` records a Jest run without `--coverage`. Verdict FAIL (finding F-1).
- TypeScript post-change coverage artifact: absent. `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` do not exist; `evidence/qa-gates/typescript.2026-10-31T16-01.md` ran `node run-jest.cjs` and `npm run test:unit` without `--coverage`. Verdict FAIL (finding F-1).
- PowerShell baseline coverage artifact: `evidence/baseline/powershell-tests.2026-10-31T15-09.md` (JaCoCo at executor scratch `issue-1013-p0t7-coverage.xml`).
- PowerShell post-change coverage artifact: executor scratch `SCRATCH/issue-1013-p9t6b-coverage.xml` (JaCoCo, parsed by this review: LINE 356/356, INSTRUCTION 650/652), summarized in `evidence/qa-gates/powershell-tests.2026-10-31T16-59.md`. The canonical path `artifacts/pester/powershell-coverage.xml` is not populated.
- Per-language comparison summary: Section 1.2.1 of this audit and `evidence/qa-gates/coverage-delta.2026-10-31T16-59.md`.

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the resolved base branch, merge base, head, feature folder, PR context artifacts, and AC sources, and requested the full feature-review contract. The audit scope is the full branch diff `1174736c7..8683e0a75` (129 files).

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no paths reported.
- Branch-diff scan for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: no file in the diff matches. Every evidence file is under `docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/evidence/<kind>/`.
- Result: PASS. No relocations required.

---

## Executive Summary

The branch implements issue #1013: an aggregate per-item integration-cost cap applied inside the scheduling entry point (Python and PowerShell), a planning-time issue-combination library (Python authority, PowerShell port re-exported by the facade), a validated optional `conflict_tolerance.combination_threshold_percent` member, a required `conflict_tolerance.weights.contract` cost weight, telemetry-only `observed_resolution` documentation, and the corresponding skill, agent, rule, template, bundle, and pack-manifest edits.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists on base; `scripts/dev_tools` is T4, `.claude/lib/blast-radius` is T3)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` (test files only)
- N/A Bash: no bash file changed
- ✅ JSON: fixtures and truth tables exercised by parity and contract tests

Toolchain: Python format, lint, and type check were re-run by this review on the changed scope and pass; 338 targeted Python tests were re-run and pass. The executor's full-suite Python (16055 pass), Pester (13678 pass), and Jest (5284 + 5301 pass) runs are recorded with exit 0. Coverage for Python and PowerShell exceeds the governing thresholds for every changed production file. Two gaps were found: (1) TypeScript has changed files on the branch but no coverage artifact exists (FAIL under the mandatory coverage rule); (2) the duplicate-key rejection path of the new combination library has no negative-flow test in either runtime (PARTIAL under Scenario Completeness).

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; executor helper scripts live in the session scratch directory outside the repository.
- ✅ No new tooling script was added to the repository.
- Helper scripts (`SCRATCH/issue-1013-*.py`, `*.sh`) remain outside the repository by design.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `evidence/regression-testing/isolation-python.2026-10-31T17-00.md` (reversed module order, exit 0); `isolation-pester.2026-10-31T17-03.md` (three seeded shuffles 1013/2026/31, exit 0); `isolation-jest.2026-10-31T16-59.md` (`--randomize --seed=1013`, exit 0). |
| **Isolation** - Each test targets single behavior | ✅ PASS | New modules are tested per function: `select_capped_pairs` (aggregate tests), `find_combinations`/`has_same_file_overlap` (combination tests), reader cases (threshold, contract-weight tests). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 338 targeted Python tests ran in 1.46s in this review. |
| **Determinism** - Consistent results | ✅ PASS | Pure functions over committed LF JSON fixtures; property tests are exhaustive over a finite domain (no RNG); no clock reads. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names, e.g. `test_contract_only_pair_combines_when_its_cost_meets_the_threshold`, `test_find_combinations_does_not_mutate_its_inputs`; Pester files carry synopsis blocks. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS (Python, PowerShell) / ❌ FAIL (TypeScript) | Python baseline `evidence/baseline/python-tests.2026-10-31T15-06.md`; PowerShell baseline `evidence/baseline/powershell-tests.2026-10-31T15-09.md`; TypeScript has no coverage baseline. |
| **No Coverage Regression** | ✅ PASS (Python, PowerShell) / ❌ FAIL (TypeScript, not measurable) | `_blast_radius_scheduling.py` 100.00% -> 100.00% line and branch; `BlastRadiusScheduling.psm1` 100.00% -> 100.00%; `BlastRadius.psm1` 100.00% -> 100.00%. |
| **New Code Coverage >= governing threshold** | ✅ PASS | `_blast_radius_aggregate.py` 100.00% line / 100.00% branch; `_blast_radius_combination.py` 98.75% line / 91.67% branch; `BlastRadiusAggregate.psm1` 100.00% line; `BlastRadiusCombination.psm1` 100.00% line. Governing thresholds 85% line / 75% branch (root `CLAUDE.md` states none, defaults apply). |
| **Comprehensive Coverage** | ✅ PASS | Every function in the three Python modules has FNDA >= 1 except the four `CappableOverlap` Protocol property stubs (type-only, no executable behavior). |
| **Positive Flows** - Valid inputs | ✅ PASS | Fixture-driven cases for cap promotion, tie-break, cascade, threshold boundary (one below, at, one above), candidate classes, component chain, contract-only pairs. |
| **Negative Flows** - Invalid inputs | ⚠️ PARTIAL | Reader rejects (negative, float, string, boolean, unknown sibling, absent/invalid `contract`) are tested in both runtimes. Not tested: the duplicate-key rejection of `find_combinations` (`_blast_radius_combination.py:245-246`, uncovered line 246 in `artifacts/python/lcov.info`) and of `Get-CombinationOrderedItem` (`BlastRadiusCombination.psm1:95-96`). No test in either combination suite references the error text `must be distinct`. Finding F-2. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Tolerance 0 no-op, absent key, missing band read as `default_band`, append-only same file not a candidate, identifier repeated within one radius counted once. |
| **Error Handling** - Error paths | ⚠️ PARTIAL | See Negative Flows (F-2). Band-invalid errors are covered by pre-existing scheduling tests. |
| **Concurrency** - If applicable | N/A | Pure synchronous functions; no shared state. |
| **State Transitions** - If applicable | ✅ PASS | The cap loop's iterative state is pinned by the cascade fixture (at least two promotion rounds) and the idempotence property (a second pass changes nothing). |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 100.00% lines, 100.00% branches (`_blast_radius_scheduling.py`). Post-change: 99.63% lines, 97.14% branches across the three measured modules (scheduling 100.00%/100.00%, aggregate 100.00%/100.00%, combination 98.75%/91.67%). Change: +0.00% on the modified file; new files added at or above threshold. New/changed-code coverage: 99.29% lines, 94.12% branches. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (parsed by this review), `evidence/qa-gates/python-tests.2026-10-31T16-08.md`, `evidence/qa-gates/coverage-delta.2026-10-31T16-59.md`.
- PowerShell: Baseline: 100.00% lines (BlastRadiusScheduling.psm1 116/116, BlastRadius.psm1 108/108). Post-change: 100.00% lines (356/356 across the four modules). Change: +0.00% on modified files; new files at 100.00%. New/changed-code coverage: 100.00% lines. Disposition: PASS. Evidence: executor scratch JaCoCo `issue-1013-p9t6b-coverage.xml` (parsed by this review), `evidence/qa-gates/powershell-tests.2026-10-31T16-59.md`, `evidence/qa-gates/coverage-delta.2026-10-31T16-59.md`.
- TypeScript: Baseline: N/A, no coverage artifact. Post-change: N/A, no coverage artifact. Change: not measurable. New/changed-code coverage: N/A, no TypeScript production file changed. Disposition: FAIL. Evidence: `coverage/lcov.info` absent from the worktree; `evidence/qa-gates/typescript.2026-10-31T16-01.md` shows Jest ran without `--coverage`. The mandatory coverage rule requires a coverage artifact for every language with changed files on the branch (4 TypeScript test files changed).

Repo-wide note: the Python and PowerShell artifacts are scoped to the changed modules (the executor passed explicit `--cov=` and Pester coverage paths), so they report the changed-module aggregate rather than a whole-repository figure. Because every changed production line is at or above 98.75% line coverage, the branch cannot lower the repository-wide figure for either language; this is recorded as an observation, not a finding.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Pester rows compare formatted strings (`Format-CombinationPair`, `Format-Combination`) so a mismatch prints the full expected and actual record. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Fixture load (arrange), library call (act), equality assertion (assert) in each case. |
| **Document Intent** | ✅ PASS | Module docstrings and Pester synopsis blocks state the scenario and the spec decision (D-2, D-5, D-6, D-7). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Tests read committed files only; no network, database, or subprocess. |
| **Use Mocks/Stubs** | ✅ PASS | No mocking required; functions are pure. |
| **Environment Stability** | ✅ PASS | Search of new test files for `tmp_path`, `tempfile`, `TestDrive`, `New-TemporaryFile`, `mkdtemp`, `os.tmpdir` returned no match. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit; executor self-review `evidence/qa-gates/self-review.2026-10-31T17-06.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md` (v0.5), `user-story.md`, research `research/research.2026-10-30T13-28.md`. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-31T15-05.md`; #1006 dependency gate `evidence/baseline/dependency-1006-gate.2026-10-31T15-01.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-30T09-15.md` with five preflight-fix records. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Cap and combination logic in small leaf modules (122 and 247 lines in Python); scheduling gains one post-pass call. |
| **Reusability** | ✅ PASS | Combination reuses `decide_pair`, `_entries_overlap`, the mergeable matcher, and `config_conflict_tolerance`; no duplicated overlap semantics. |
| **Extensibility** | ✅ PASS | Optional member with a default keeps every existing config valid; structural `CappableOverlap` Protocol decouples the cap from the scheduling record types. |
| **Separation of concerns** | ✅ PASS | All new functions are pure; no I/O. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One concern per new module (cap; combination). |
| **At or below the 800-line hard limit** | ✅ PASS | Largest covered files: `_blast_radius_scheduling.py` 561, `BlastRadiusScheduling.psm1` 530 (and bundle copy 530), `BlastRadius.Tests.ps1` 492, `BlastRadius.psm1` 481. No covered file at or above 700 lines; no Warning. `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | `__all__` declared; PowerShell modules export one function each; facade export set grows by `Get-BlastRadiusCombination` only. |
| **No circular dependencies** | ✅ PASS | `_blast_radius_aggregate.py` imports `ConflictTolerance` under `TYPE_CHECKING` only (AC-03); combination imports scheduling one way. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `select_capped_pairs`, `_first_over_cap_item`, `has_same_file_overlap`, `Get-AggregateCappedPair`, `Get-UnionFindRoot`. |
| **Docs/docstrings** | ✅ PASS | Module docstrings state purpose, rules, invariants; Google-style function docstrings; PowerShell comment-based help. |
| **Comment why, not what** | ✅ PASS | e.g. "The full reasons are read, because contract_dependency is never first." |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check <changed python> tests/scripts/dev_tools` (this review, 430 files unchanged); Invoke-Formatter comparison `evidence/qa-gates/powershell-static.2026-10-31T16-41.md`; Prettier `evidence/qa-gates/typescript.2026-10-31T16-01.md`. |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` (this review, "All checks passed!"); PSScriptAnalyzer clean; ESLint exit 0. |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <changed python files>` (this review, 0 errors, 0 warnings); `tsc --noEmit` both projects exit 0. |
| **4. Testing** | ✅ PASS | Full Python suite 16055 pass; Pester 13678 pass; Jest 5284 + 5301 pass; this review re-ran 338 targeted Python tests (pass). |
| **Full toolchain loop** | ✅ PASS | Loop history recorded in the QA evidence (Prettier restart; Pester Python-scan restart after `Get-UnionFindRoot`); final pass clean. |
| **Explicit reporting** | ✅ PASS | Every gate has an evidence file with Command and EXIT_CODE. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages (Section 9). |
| **Design choices explained** | ✅ PASS | spec D-1 to D-7. |
| **Update supporting documents** | ✅ PASS | `.claude/rules/parallel-orchestration.md`, skills, agents, template, bundle copies. |
| **Provide next steps** | ✅ PASS | Rollout section in spec; AC-14 pending CI. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check scripts/dev_tools/_blast_radius_*.py tests/scripts/dev_tools`<br>**Result:** 430 files would be left unchanged. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright <3 production + 7 new test files>`<br>**Result:** 0 errors, 0 warnings, 0 informations. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest <11 feature modules> -q --no-cov`<br>**Result:** 338 passed, 5 skipped (pre-existing `manifest_m1_*` skips). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Fully annotated; no `Any`. |
| **Dataclasses for value objects** | ✅ PASS | `CombinationPair`, `Combination`, `CombinationResult` are frozen dataclasses; `ConflictTolerance` gains a defaulted field. |
| **Protocols/ABCs for interfaces** | ✅ PASS | `CappableOverlap` Protocol. |
| **Avoid utility classes** | ✅ PASS | Module-level functions. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `TypeError`/`ValueError` naming the config key; `ValueError` for duplicate keys. |
| **Logging over print** | ✅ PASS | No print or logging added; pure functions. |
| **Invariants at construction** | ✅ PASS | Reader validates every member before constructing `ConflictTolerance`. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `sh SCRATCH/issue-1013-p9t5.sh` (Invoke-Formatter comparison)<br>**Result:** no difference; `evidence/qa-gates/powershell-static.2026-10-31T16-41.md`. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** zero findings. |
| **Fix all findings** | ✅ PASS | The enforcement-hook Python-scan failure on a closure was fixed by the named function `Get-UnionFindRoot`. |
| **PowerShell 5.1 & 7.6+ compatible** | ⚠️ PARTIAL (observation) | Tests ran on PowerShell 7 only. The code uses `::new()`, generic `HashSet`, and `-AsHashtable` only in tests; no 7-only syntax was found in the production modules on inspection. Not a blocking finding. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on every function. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyCollection`, `AllowNull` used as appropriate. |
| **Avoid global state** | ✅ PASS | Only `$script:` constants. |
| **Error handling** | ✅ PASS | `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, imports with `-ErrorAction Stop`, explicit `throw`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 154, 228, 530, 481 lines. |
| **Approved verbs** | ✅ PASS | Get-, Test-. |
| **Comment why** | ✅ PASS | Parity notes and rationale comments. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 3B.1. |
| **Step 2: Analyze** | ✅ PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `evidence/qa-gates/powershell-tests.2026-10-31T16-59.md`: tests=13688 failures=0 errors=0 skipped=10. |
| **Rerun loop if needed** | ✅ PASS | One restart recorded. |

### Section 3C: TypeScript (test files only)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting (Prettier)** | ✅ PASS | `evidence/qa-gates/typescript.2026-10-31T16-01.md`. |
| **Linting (ESLint)** | ✅ PASS | exit 0. |
| **Type checking (tsc)** | ✅ PASS | both projects exit 0. |
| **Tests (Jest)** | ✅ PASS | 327 suites / 5284 tests (extension), 330 suites / 5301 tests (root). |
| **Coverage** | ❌ FAIL | No `coverage/lcov.info`; finding F-1. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Fixtures parse in Python, PowerShell (`ConvertFrom-Json -AsHashtable`), and TypeScript suites. |
| **Class 1 byte-equality** | ✅ PASS | `conflict_tolerance` equal across both truth tables (`test_class_one_keys_are_equal_across_both_committed_copies`, contract-tests evidence). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Parametrized fixture tests. |
| **Coverage expectation** | ✅ PASS | See 1.2.1. |
| **Focused unit tests** | ✅ PASS | One behavior per test. |
| **Mocking sparingly** | ✅ PASS | None used. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/test_blast_radius_*.py` mirrors `scripts/dev_tools/`. |
| **Naming conventions** | ✅ PASS | `test_<behavior>` names. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, discovery-time `-ForEach` case generation, `Should`. |
| **PowerShell 5.1 & 7.6+ Compatible** | ⚠️ PARTIAL (observation) | Tests use `ConvertFrom-Json -AsHashtable` (PowerShell 6+); consistent with existing blast-radius suites. |
| **Organization** | ✅ PASS | `tests/scripts/claude-lib/blast-radius/*.Tests.ps1` mirrors `.claude/lib/blast-radius/`. |
| **File Naming** | ✅ PASS | `*.Tests.ps1`. |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### `_blast_radius_aggregate.py` (aggregate tests + properties)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| fixture parity (`aggregate-cap-promotes-cheapest-pair`, `-tie-break`, `-cascade`) | Positive / Edge Case | 66-122 | ✅ |
| set-level properties (superset/subset, tolerance 0, within cap, order invariance, idempotence) | Edge Case | 66-122 | ✅ |

**Coverage:** 100.00% lines (35/35), 100.00% branches (10/10). **Not covered:** None.

### `_blast_radius_combination.py` (combination + threshold tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_find_combinations_matches_fixture` | Positive / Edge Case | 145-235 | ✅ |
| `test_combination_is_disabled_at_tolerance_zero`, `..._when_the_key_is_absent` | Edge Case | 164-168 | ✅ |
| `test_has_same_file_overlap`, `..._is_symmetric` | Positive / Edge Case | 109-142 | ✅ |
| duplicate-key rejection | Negative | 245-246 | ❌ (absent; F-2) |

**Coverage:** 98.75% lines (79/80), 91.67% branches (22/24). **Not covered:** line 246 (duplicate-key `ValueError`).

### `_blast_radius_scheduling.py` (modified)

**Coverage:** 100.00% lines (158/158), 100.00% branches (36/36).

### PowerShell modules

**Coverage:** BlastRadiusScheduling.psm1 138/138, BlastRadiusAggregate.psm1 37/37, BlastRadiusCombination.psm1 72/72, BlastRadius.psm1 109/109 lines (100.00% each). Instruction coverage 650/652 (99.69%); one uncovered instruction each in BlastRadiusCombination.psm1 and BlastRadiusScheduling.psm1.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Python 16061, Pester 13688, Jest 5284 + 5301 | ✅ |
| Tests Passed | All non-skipped | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Python full suite 591.48s; targeted 1.46s | ✅ |
| Functions/Classes Tested | 15/15 scheduling, 8/8 combination, 3/3 aggregate executable functions | ✅ |
| Test File Size | Largest new test file 406 logical lines | ✅ PASS |
| Code Coverage (if applicable) | Python 99.63% lines, 97.14% branches; PowerShell 100.00% lines | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check ...` | 430 unchanged | ✅ |
| Ruff Linting | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright <changed files>` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest <feature modules> --no-cov` | 338 passed, 5 skipped | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `sh SCRATCH/issue-1013-p9t5.sh` | no diff | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings .../pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `sh SCRATCH/issue-1013-pester-run.sh p9t6b` | 0 failures | ✅ |

**Notes:** PowerShell results are taken from executor evidence; this review did not re-run Pester (the full run takes several minutes and the JaCoCo/JUnit outputs were parsed directly).

---

## 8. Gaps and Exceptions

### Identified Gaps

- **F-1 (FAIL) TypeScript coverage artifact absent.** Four TypeScript test files changed; no `coverage/lcov.info` exists and no Jest run used `--coverage`. Coverage verification is mandatory for all languages with changed files. Remediation: run `npm run test:unit:coverage` (root) and the extension Jest run with `--coverage`, confirm repository-wide TypeScript line >= 85% and branch >= 75%, and record a `evidence/qa-gates/typescript-coverage.<timestamp>.md` artifact.
- **F-2 (PARTIAL) Duplicate-key negative flow untested.** `find_combinations` and `Get-BlastRadiusCombination` reject repeated item keys, but neither runtime has a test for it. Remediation: add one test per runtime asserting the error.

### Approved Exceptions

- AC-01 fail-before is structurally impossible (behavior holds at base); exception dossier `evidence/regression-testing/fail-before-exception.2026-10-31T15-21.md`.

### Removed/Skipped Tests

**None.** Skips are pre-existing (`test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case`, five `manifest_m1_*` accessor skips).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **3a64f2d41** - docs(parallel): prepare issue 1013 integration-cost scheduling plan
2. **5374dc1ad** - wip(1013): contract-weight revision of spec and plan, paused mid-edit
3. **ee466067c** - docs(parallel): complete D-7 contract-weight plan revision for issue 1013
4. **04deb67b3** - docs(parallel): revise issue 1013 plan for main drift after 1006-1012
5. **62ccaaf1c** - docs(parallel): record issue 1013 preflight fixes
6. **2ea9c968c** - docs(parallel): record issue 1013 phase 0 baselines
7. **44fefb249** - test(parallel): add issue 1013 cap, combination, and contract-weight tests
8. **b6518e453** - feat(parallel): add the contract cost weight to blast-radius scheduling
9. **7549d0715** - feat(parallel): add the aggregate cost cap and issue combination (Python)
10. **16194a0e4** - feat(parallel): commit combination_threshold_percent and pin defaults
11. **507ff0def** - feat(parallel): port the aggregate cap and issue combination to PowerShell
12. **463d4d67f** - test(parallel): pin validator acceptance of combination and telemetry fields
13. **99944e07d** - docs(parallel): document the cap, combination, telemetry, and contract weight
14. **252f43aec** - chore(parallel): mirror issue 1013 sources into the bundle and pack manifest
15. **fd61b6e57** - style(parallel): apply issue 1013 final QA formatting and lint fixes
16. **8683e0a75** - docs(parallel): record issue 1013 final QA, isolation, scope, and self-review

### Files Modified

129 files: 3 Python production (2 new), 4 PowerShell production (2 new) plus 4 bundle copies, 2 truth tables, 1 pack manifest, 16 Markdown skill/agent/rule sources and bundle copies, 1 template, 4 TypeScript tests, 13 Python tests, 8 Pester tests, 20 JSON fixtures, feature-folder documents and evidence, and 1 promoted potential record. The scope check `evidence/qa-gates/scope-check.2026-10-31T17-05.md` matches the diff to the spec's 76-entry Complete File List. Twelve source/bundle pairs were verified byte-identical by this review (`git ls-tree` blob hashes equal).

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Python and PowerShell implementation, tests, toolchain, coverage, file size, mirrors, scope, and evidence locations comply. Two findings require remediation: F-1 (TypeScript coverage artifact absent, FAIL) and F-2 (duplicate-key negative-flow tests absent, PARTIAL). Both are autonomous and proportionate.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan, spec, research, dependency gate recorded
- ✅ Design Principles: pure leaf modules, reuse of relation primitives
- ✅ Module & File Structure: all files below 700 lines
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: clean final pass
- ✅ Summarize & Document: compliant

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright clean (re-run by this review)
- ✅ Python Design & Typing: frozen dataclasses, Protocol
- ✅ Error Handling: specific exceptions naming the key

**For PowerShell:**
- ✅ Tooling & Baseline: formatter and analyzer clean
- ✅ PowerShell Design & Safety: advanced functions, StrictMode
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: Pester clean

**For TypeScript:**
- ❌ Coverage: artifact absent (F-1)

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: isolation checks pass in three runtimes
- ⚠️ Coverage & Scenarios: duplicate-key negative flow untested (F-2); TypeScript coverage absent (F-1)
- ✅ Test Structure: compliant
- ✅ External Dependencies: no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope / Style / Naming / Toolchain

**For PowerShell:**
- ✅ Framework & Scope / Style / Naming / Toolchain

### Metrics Summary

- ✅ Python 16055 pass, Pester 13678 pass, Jest 10585 pass
- ✅ Python changed modules 99.63% lines, 97.14% branches
- ✅ PowerShell changed modules 100.00% lines
- ❌ TypeScript coverage not measured
- ✅ All covered files below 700 lines

### Recommendation

**Needs revision.** Remediate F-1 and F-2 in one proportionate cycle, then re-review. AC-14 remains pending the CI bats lane and is checked off at S9 per the CI-dependent criteria rule.

---

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_blast_radius_aggregate.py` (new)
- `tests/scripts/dev_tools/test_blast_radius_aggregate_properties.py` (new)
- `tests/scripts/dev_tools/test_blast_radius_combination.py` (new)
- `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py` (new)
- `tests/scripts/dev_tools/test_blast_radius_contract_weight.py` (new)
- `tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py` (new)
- `tests/scripts/dev_tools/test_push_down_claude_blast_radius_default_tolerance.py` (new)
- `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`, `test_blast_radius_historical_runs.py`, `test_blast_radius_scheduling.py`, `test_blast_radius_scheduling_properties.py`, `test_parallel_drift_scheduling.py`, `test_validate_parallel_state_tolerated_edge_fields.py` (modified)
- `tests/scripts/claude-lib/blast-radius/BlastRadiusAggregate.Tests.ps1`, `BlastRadiusCombination.Tests.ps1`, `BlastRadiusScheduling.ContractWeight.Tests.ps1` (new)
- `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1`, `BlastRadius.HistoricalRuns.Tests.ps1`, `BlastRadiusScheduling.Tests.ps1`, `BlastRadiusScheduling.PairCost.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` (modified)
- `extensions/drm-copilot/test/lib/push-down/blast-radius-default-tolerance.test.ts` (new); `blast-radius-derive-tolerance-keys.test.ts`, `config-carriage.test-helpers.ts`, `test/lib/validate/parallel-state-tolerated-edge-fields.test.ts` (modified)

---

## Appendix B: Toolchain Commands Reference

**Run by this review (check-only):**
```bash
git diff --name-status 1174736c7a3cbd7dd5c73620b2c1ed02ec2c3cd6 HEAD
git ls-tree -r HEAD -- <12 sources and 12 bundle copies>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run black --check scripts/dev_tools/_blast_radius_aggregate.py scripts/dev_tools/_blast_radius_combination.py scripts/dev_tools/_blast_radius_scheduling.py tests/scripts/dev_tools
poetry run ruff check scripts/dev_tools tests/scripts/dev_tools
poetry run pyright <3 production files and 7 new test files>
poetry run pytest <11 feature test modules> -q -p no:cacheprovider --no-cov
python -I <scratch>/jacoco_read.py <scratch>/issue-1013-p9t6b-coverage.xml
python -I <scratch>/sizes.py <worktree> 1174736c7a3cbd7dd5c73620b2c1ed02ec2c3cd6   # logical line counts (splitlines)
```

**Executor commands (from evidence):**
```bash
poetry run pytest -q -p no:cacheprovider --cov=scripts.dev_tools._blast_radius_scheduling --cov=scripts.dev_tools._blast_radius_aggregate --cov=scripts.dev_tools._blast_radius_combination --cov-branch
sh SCRATCH/issue-1013-pester-run.sh p9t6b
sh SCRATCH/issue-1013-ts-static.sh; npm run format:check; npm run lint; npm run typecheck; npm run test:unit
```

**Remediation command (F-1):**
```bash
npm run test:unit:coverage
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-31
**Policy Version:** Current (as of audit date)
