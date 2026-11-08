# Policy Compliance Audit: epic wave-computation push-down (#1129)

**Audit Date:** 2026-11-08 (reaudit after remediation cycle 1, stamp 2026-11-08T15-41)  
**Code Under Test:** merge base `cdcff3871765396183590128e142a929cf78327b` of `origin/main` and reviewed head `df8d43daaf9b617c8fbee844021919f1c2c70af8` (branch `bug/epic-wave-computation-pushdown`); the diff between them lists the changed files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 7 files | 16559 tests | ✅ 16559 pass, 0 fail | 97.11% lines, 94.37% branches | 97.11% lines, 94.36% branches | 100% |
| PowerShell | 5 files | 19708 tests | ✅ 19708 pass, 0 fail | 95.56% lines | 95.57% lines | 100% |
| TypeScript | 2 files | 5448 tests | ✅ 5448 pass, 0 fail | 97.13% lines, 93.81% branches | 97.13% lines, 93.81% branches | 100% |

**Note:** Pester reports command and line coverage only, so no PowerShell branch figure exists and no PowerShell branch threshold applies. JSON (two pack manifests, four fixtures, `quality-tiers.yml` is YAML) and Markdown files carry no coverage requirement and are covered in prose below.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129/evidence/baseline/ts-jest.2026-11-08T13-51.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (LF 394, LH 390, BRF 70, BRH 67 for `codex-agents-customizations.ts`) and `evidence/qa-gates/ts-jest.2026-11-08T14-47.md`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129/evidence/baseline/ps-pester.2026-11-08T14-02.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (EpicWave.psm1 LINE covered 56 missed 0; Invoke-EpicWave.ps1 covered 5 missed 0)
- Per-language comparison summary: section 1.2.1 below and `evidence/qa-gates/rem1-coverage-delta.2026-11-08T15-39.md`

Baseline coverage is read from the plan's `Phase 0 baseline` artifacts (ts-jest, ps-pester, py-pytest under `evidence/baseline/`). The new PowerShell files record `N/A - no pre-change run` for a per-file baseline because they are new files.

**Python artifact check:** `artifacts/python/lcov.info` is present; `scripts/dev_tools/epic_wave_computation.py` shows LF 34, LH 34, BRF 12, BRH 12 (100% lines, 100% branches).

**Artifact freshness:** The cycle 1 gate artifacts (`evidence/qa-gates/rem1-*`, 15:22 to 15:39 UTC) were produced after the last production-file commit of the cycle (`566b87e4f`, the `EpicWave.psm1` parse fix) and after the cycle-1 test commits (`cc43d5e60`, `190e4d4c4`, `81fbb099f`); head `df8d43daa` adds evidence files only. The TypeScript production code is unchanged since the cycle-0 Jest run, whose artifact (`ts-jest.2026-11-08T14-47.md`) therefore still describes it. The artifacts describe the reviewed production code.

---

## Executive Summary

The branch ships the epic wave-layering computation to destination repositories as a PowerShell module and CLI (`.claude/lib/epic-wave/`), mirrors it to the Claude bundle and to the Codex bundle through `VIRTUAL_RESOURCE_DIRECTORIES` (Python and TypeScript), adds one allowlist pattern to the Codex planning-only hook, adds tool grants to two agents, replaces the wave-layering sentences in four skill files and one agent file, makes the Python reference reject unresolved references, adds a shared nine-case corpus (cycle 1 added `case-variant-keys`), and adds a citation-shipping regression test. All policy areas evaluated PASS. Cycle 1 closed the two findings that bore on delivered behavior (CLI case-sensitive key parsing, and the citation test extractor and surface coverage); the third earlier observation (error precedence on a manifest holding both a cycle and an unresolved reference) remains a non-blocking observation in the code review.

**Policy documents evaluated:**
- ✅ `general-code-change.md`
- ✅ `general-unit-test.md`

**Language-specific policies evaluated:**
- ✅ `python.md` and `python-suppressions.md` (no suppression added)
- ✅ `powershell.md`
- ✅ `typescript.md`
- ✅ JSON: pack manifests and corpus fixtures parse and are exercised by contract tests

Toolchain evidence (Black, Ruff, Pyright, PSScriptAnalyzer, PoshQC format, leak scan, Prettier, ESLint, tsc, generator check, Pytest, Pester, Jest) all records EXIT_CODE 0 under `evidence/qa-gates/`.

**Temporary artifacts cleanup:**
- ✅ Scratch scripts used during execution lived under the session scratch area and are not in the branch diff
- ✅ No ongoing tooling script was added without tests
- The branch diff contains no scratch file

## Rejected Scope Narrowing

None. The caller prompt named a reaudit after remediation cycle 1, a diff scope equal to the merge base of `origin/main` and HEAD, and focus areas; it requested no plan, task, phase, file-subset, or language narrowing. The audit covers the full branch diff.

## Evidence Location Compliance

`validate_evidence_locations.py --root .` was run against the worktree and exited 0. The branch diff holds no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence sits under `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129/evidence/{baseline,regression-testing,qa-gates,other}/`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent at the branch head, so the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists at the repository root and the branch adds the project `.claude/lib/epic-wave` at tier T3. The new project is classified; no unclassified project was introduced.

## Cycle 1 Reaudit Checks

| Check | Status | Evidence |
|---|---|---|
| No gate weakened | ✅ PASS | `git diff ef5f602e2..HEAD` over `tests/`, `.claude/`, and `config/` shows only additions to tests and fixtures; `ALLOWLIST` (one entry with its MCP-route reason), the stale-entry check, the reason check, and the frozen-surface digests are unchanged; `config/file-size-baseline.json` is not in the diff. |
| Extractor and allowlist not narrowed | ✅ PASS | `_PATH_PATTERN` gains an optional `(?:\./)?` prefix and keeps its lookbehind and character classes; `_MODULE_PATTERN` is new; both surface tuples grow from 4 to 8 (Claude) and 4 to 7 (Codex). No pattern, tuple member, or allowlist entry was removed. |
| Mirror byte parity | ✅ PASS | `cmp` equal: `.claude/lib/epic-wave/EpicWave.psm1` against the Claude bundle copy and against `resources/lib/epic-wave/EpicWave.psm1`; `.claude/skills/epic-progress-report/SKILL.md` against its bundle copy. |
| Evidence location | ✅ PASS | `validate_evidence_locations.py --root .` exited 0 with no output; cycle 1 evidence sits under `evidence/qa-gates/` and `evidence/other/`. |
| Gate artifacts | ✅ PASS | `rem1-py-black`, `rem1-py-ruff`, `rem1-py-pyright`, `rem1-ps-format`, `rem1-ps-pssa`, `rem1-ps-leak-scan` record EXIT_CODE 0; `rem1-py-pytest` 16559 passed; `rem1-ps-pester` 19708 tests, 0 failures. No TypeScript file changed in the cycle, so no Jest rerun was required. |
| File size | ✅ PASS | The citation test is 344 logical lines; no covered file reaches 700 lines. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Pester files import the module in `BeforeAll` and remove it in `AfterAll`; pytest tests read committed files or in-memory dictionaries. The full Pester and pytest gates ran in parallel (workers=8, `-n auto`) with no order dependence reported. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `It` per corpus case in `EpicWave.Parity.Tests.ps1`; one test per helper behavior in the citation test file; separate tests for publication and byte parity in the virtual-paths file. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The new in-memory tests add negligible time; the pytest gate took 272.50s for 16559 tests and the Pester gate 702.42s wall-clock for 19708 tests across 8 workers. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, network, or temp files; the CLI test runs in-process against committed fixtures; the reader is injected for the exit-code cases. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names (`test_find_stale_allowlist_entries_reports_uncited_entry`), module docstrings, Arrange/Act/Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** Python 97.11% lines and 94.37% branches; PowerShell 95.56% lines; Jest 97.13% lines and 93.81% branches, read from the `Phase 0 baseline` artifacts.<br>**Artifact:** `evidence/baseline/py-pytest.2026-11-08T14-02.md`, `ps-pester.2026-11-08T14-02.md`, `ts-jest.2026-11-08T13-51.md`<br>**Timestamp:** 2026-11-08 |
| **No Coverage Regression** | ✅ PASS | **Post-change:** Python 97.11% lines and 94.36% branches; PowerShell 95.57% lines; Jest unchanged.<br>**Change:** +0.00% Python lines, -0.01% Python branches (3 of 4 added branches covered, uncovered branch count rises by one in the push-down module path with no changed-line regression), +0.01% PowerShell lines.<br>**Status:** No regression on changed lines; every changed file holds or improves its own figures. |
| **Changed Files Meet Thresholds** | ✅ PASS | `epic_wave_computation.py` 100% lines and 100% branches; `validate_epic_planner_state.py` 100% lines, 99.00% branches; `push_down_codex_and_agents_customizations.py` 98.18% lines, 88.89% branches; `codex-agents-customizations.ts` 98.97% lines, 95.71% branches; `EpicWave.psm1` 100% (56/56); `Invoke-EpicWave.ps1` 100% (5/5); `enforce-epic-planning-only.ps1` 95.86% (unchanged). All meet 85% line and 75% branch. |
| **New Code Coverage** | ✅ PASS | New files: `EpicWave.psm1` 56/56 lines, `Invoke-EpicWave.ps1` 5/5 lines. Changed lines in the three modified source modules are covered (3 added TypeScript lines and 1 added branch covered). Calculation: JaCoCo and lcov per-file counters from the artifacts above. |
| **Comprehensive Coverage** | ✅ PASS | `Get-EpicWaveNumber`, `Resolve-EpicWaveFeature`, `ConvertTo-EpicWaveManifest`, `Invoke-EpicWaveCommand`, the CLI wrapper, `compute_wave_numbers`, both exception classes, and the new hook pattern are executed by tests. Untested: none recorded. |
| **Positive Flows** - Valid inputs | ✅ PASS | Corpus cases empty, single, chain, diamond, multiple-roots (pytest lane and Pester lane); CLI exit 0 against `cli-valid-manifest.json`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Cycle, self-loop, unresolved reference: three distinct message prefixes asserted; CLI exit 1 for cycle; exit 2 for missing path, unreadable file, non-object JSON. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Empty manifest, single node, multiple roots, diamond. Cycle 1 added the `case-variant-keys` corpus case and CLI cases; the mixed cycle-plus-unresolved-reference precedence is a recorded non-blocking observation.
| **Error Handling** - Error paths | ✅ PASS | Reader exception to exit 2; invalid JSON to exit 2; non-matching exception rethrown. |
| **Concurrency** - If applicable | N/A | Pure single-threaded computation. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 97.11% lines and 94.37% branches (from `evidence/baseline/py-pytest.2026-11-08T14-02.md`) -> Post-change: 97.11% lines and 94.36% branches. Change: +0.00% lines, -0.01% branches (arithmetic from 4 added branches, 3 covered; the changed Python modules hold or exceed their own baselines). New/changed-code coverage: 100%. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (epic_wave_computation.py LH 34 of LF 34, BRH 12 of BRF 12) and `evidence/qa-gates/rem1-py-pytest.2026-11-08T15-39.md`.
- PowerShell: Baseline: 95.56% lines (from `evidence/baseline/ps-pester.2026-11-08T14-02.md`) -> Post-change: 95.57% lines. Change: +0.01% lines. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (EpicWave.psm1 covered 56, Invoke-EpicWave.ps1 covered 5) and `evidence/qa-gates/rem1-ps-pester.2026-11-08T15-34.md`.
- TypeScript: Baseline: 97.13% lines and 93.81% branches (from `evidence/baseline/ts-jest.2026-11-08T13-51.md`) -> Post-change: 97.13% lines and 93.81% branches. Change: +0.00% lines, +0.00% branches. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` and `evidence/qa-gates/ts-jest.2026-11-08T14-47.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | The citation test asserts with the message "Epic surfaces cite unshipped scripts: <list>"; stale-entry and allowlist tests name the offending path. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange/Act/Assert comments in the hook cases and the virtual-path tests. |
| **Document Intent** | ✅ PASS | Module and test docstrings state the #1129 purpose. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Tests read committed repository files only; no network, no subprocess. |
| **Use Mocks/Stubs** | ✅ PASS | Injected `-ReadManifestText` scriptblock for the I/O seam; in-memory file system in the virtual-path tests. |
| **Environment Stability** | ✅ PASS | No temporary file creation in the added tests; the git diff holds no temp-file helper. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the review; the executor's `evidence/qa-gates/self-review.2026-11-08T14-49.md` precedes it. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1129 and `spec.md` root-cause analysis. |
| **Read existing change plans** | ✅ PASS | `research/research.2026-11-08T13-18.md` and the plan premise corrections. |
| **Document the plan** | ✅ PASS | `plan.2026-11-08T08-08.md`, all tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Memoized recursion mirrors the Python reference; the CLI wrapper is eleven executable lines. |
| **Reusability** | ✅ PASS | One module serves the CLI, the tests, and both bundles. |
| **Extensibility** | ✅ PASS | The Codex publication uses the directory mapping, so a later helper file needs no per-file entry. |
| **Separation of concerns** | ✅ PASS | `Get-EpicWaveNumber` is pure; `Invoke-EpicWaveCommand` owns parsing and exit codes; the CLI owns process I/O. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One module with one purpose. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts: `EpicWave.psm1` 222; `test_epic_skill_script_citations_shipped.py` 244; the largest edited covered file is below 500; no file reaches 700 lines, so no Warning applies. `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | ✅ PASS | `Export-ModuleMember` exports only `Get-EpicWaveNumber` and `Invoke-EpicWaveCommand`. |
| **No circular dependencies** | ✅ PASS | The module has no imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs `Get`, `Invoke`, `ConvertTo`, `Resolve`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every PowerShell function; Google-style docstrings on the Python additions. |
| **Comment why, not what** | ✅ PASS | Comments explain ordering of error classes and the ordinal copy. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Black, PoshQC format, Prettier artifacts record EXIT_CODE 0 (`evidence/qa-gates/py-black`, `ps-format`, `ts-prettier`). |
| **2. Linting** | ✅ PASS | Ruff, PSScriptAnalyzer (0 findings), ESLint, leak scan artifacts record EXIT_CODE 0. |
| **3. Type checking** | ✅ PASS | Pyright and `tsc` artifacts record EXIT_CODE 0. |
| **4. Testing** | ✅ PASS | Pytest 16559 passed; Pester 19708 tests, 0 failures; Jest 5448 passed. |
| **Full toolchain loop** | ✅ PASS | Static artifacts at 14:24 precede the test gates at 14:47 and no file changed between them. |
| **Explicit reporting** | ✅ PASS | Each command and result is recorded in an evidence artifact. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Self-review artifact and plan. |
| **Design choices explained** | ✅ PASS | The spec records the Python-reference-stays and PowerShell-ships decision. |
| **Update supporting documents** | ✅ PASS | Skill and agent text, frozen-surface re-pin note. |
| **Provide next steps** | ✅ PASS | The PR must state that destinations refresh the push-down after an extension rebuild and reinstall (AC11, pending CI). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** `evidence/qa-gates/py-black.2026-11-08T14-24.md`, EXIT_CODE 0 |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check .`<br>**Result:** `py-ruff.2026-11-08T14-24.md`, EXIT_CODE 0 |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** `py-pyright.2026-11-08T14-24.md`, EXIT_CODE 0 |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov-branch --cov`<br>**Result:** 16559 passed, 6 skipped, 0 failed |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Full annotations; `Mapping` and `Sequence` imported under `TYPE_CHECKING`; no `Any`. |
| **Dataclasses for value objects** | N/A | Exception classes only. |
| **Protocols/ABCs for interfaces** | N/A | No multiple-implementation interface added. |
| **Avoid utility classes** | ✅ PASS | Module-level functions. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `EpicWaveUnresolvedReferenceError(ValueError)` is caught by name beside `EpicWaveCycleError`; no broad catch. |
| **Logging over print** | ✅ PASS | No print statement. |
| **Invariants at construction** | ✅ PASS | The exception stores `feature_folder` and `dependency` at construction. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** PoshQC format check<br>**Result:** `ps-format.2026-11-08T14-24.md`, EXIT_CODE 0 |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with repository settings<br>**Result:** `ps-pssa.2026-11-08T14-24.md`, 0 findings |
| **Fix all findings** | ✅ PASS | No finding outstanding. |
| **PowerShell 7+ compatible** | ✅ PASS | The module and CLI ran under `pwsh` 7 in the reviewer probe. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` with `OutputType` on every function. |
| **Parameter validation** | ✅ PASS | Mandatory parameters and typed dictionary parameters; the CLI `-ManifestPath` is deliberately non-mandatory so the wrapper returns exit 2 with a message. |
| **Avoid global state** | ✅ PASS | Memo and in-progress sets are passed explicitly. |
| **Error handling** | ✅ PASS | Three stable error prefixes thrown; non-matching exceptions rethrown. The functions change no state, so ShouldProcess does not apply. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 222 and 26 logical lines. |
| **Approved verbs** | ✅ PASS | Get, Invoke, ConvertTo, Resolve. |
| **Comment why** | ✅ PASS | Rationale comments on the ordinal copy and error ordering. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | EXIT_CODE 0. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `Invoke-PoshQCParallelTest` ExitCode 0. |
| **Rerun loop if needed** | ✅ PASS | Single pass recorded. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Schema validation** | ✅ PASS | The pack-manifest contract tests (`test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`) pass in the pytest gate and read both `core.json` files. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | The corpus and CLI fixtures parse in both the pytest and Pester lanes. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Parametrized corpus lane; plain functions elsewhere. |
| **Coverage expectation** | ✅ PASS | Changed Python modules at 88.89% to 100% branches and 98.18% to 100% lines; repo-wide 97.11% lines and 94.36% branches from the local gate; the CI job `quality-checks7 / Code Quality & Tests (3.13)` is not yet run (no PR exists), recorded in the CI Cross-check. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One behavior per test. |
| **Mocking sparingly** | ✅ PASS | In-memory file system for the push-down tests; no patching in the new tests. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<behavior>` names. |
| **Docstrings/comments** | ✅ PASS | One-line docstring per test. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `poetry run pytest -n auto` equivalent recorded. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only for Python. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`, `It -ForEach`, `BeforeAll`, `AfterAll`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`, ExitCode 0. |
| **PowerShell 7+ Compatible** | ✅ PASS | Run under `pwsh` 7. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | EpicWave.Tests.ps1 (27 tests), EpicWave.Parity.Tests.ps1 (10 tests), hook file gains 5 cases. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions on returned maps, messages, exit codes, and stdout JSON. |
| **Mocking Used Sparingly** | ✅ PASS | Injected reader scriptblock only. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/epic-wave/EpicWave.Tests.ps1`<br>**Code file:** `.claude/lib/epic-wave/EpicWave.psm1`<br>Mirrors the existing `tests/scripts/claude-lib/` convention. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `EpicWave.Tests.ps1`, `EpicWave.Parity.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Describe per function with `It` per behavior. |
| **Logical Grouping** | ✅ PASS | Parity lane and behavior lane are separate files. |
| **Docstrings/Comments** | ✅ PASS | Self-documenting `It` names. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | ExitCode 0, 19708 tests, 0 failures. |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### Get-EpicWaveNumber, Resolve-EpicWaveFeature, ConvertTo-EpicWaveManifest, Invoke-EpicWaveCommand (37 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Parity corpus cases empty, single, chain, diamond, multiple-roots | Positive and Edge Case | 96-134, 57-83 | ✅ |
| Parity corpus cases two-node-cycle, self-loop, unresolved-reference | Negative | 67-70, 114-125 | ✅ |
| Command exit 0, 1, 2 with injected reader | Error Handling | 189-219 | ✅ |
| CLI in-process against committed fixtures | Positive and Negative | Invoke-EpicWave.ps1 22-25 | ✅ |

**Coverage:** 100% of `EpicWave.psm1` (56 of 56 lines) and `Invoke-EpicWave.ps1` (5 of 5 lines).

**Not covered:** None.

### Citation-shipping test and Python corpus lane (16 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_every_epic_surface_citation_is_shipped | Positive on the real tree | 186-199 | ✅ |
| test_allowlist_reasons_name_the_mcp_route | Positive | 202-207 | ✅ |
| test_allowlist_has_no_stale_entry | Negative on the real tree | 210-215 | ✅ |
| test_find_unshipped_citations_reports_unlisted_path | Negative in memory | 90-117 | ✅ |
| test_find_stale_allowlist_entries_reports_uncited_entry | Negative in memory | 120-141 | ✅ |
| test_corpus_case_matches_reference (8 cases) | Positive and Negative | reference module | ✅ |

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 16559 pytest, 19708 Pester, 5448 Jest | ✅ |
| Tests Passed | 100% of non-skipped | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | pytest 272.50s, Pester 702.42s wall-clock | ✅ Fast enough for parallel gates |
| Average Time per Test | not separately recorded | ✅ |
| Discovery Time | not separately recorded | ✅ |
| Functions/Classes Tested | 4 of 4 exported or internal PowerShell functions; 2 of 2 Python exception classes and the compute function | ✅ |
| Test File Size | 244 logical lines (largest new test file) | ✅ PASS at or below 800 lines |
| Code Coverage (if applicable) | 97.11% lines, 94.36% branches (Python) | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | EXIT_CODE 0 | ✅ |
| Ruff Linting | `poetry run ruff check .` | EXIT_CODE 0 | ✅ |
| Pyright Type Checking | `poetry run pyright` | EXIT_CODE 0 | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 16559 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | PoshQC format check | EXIT_CODE 0 | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` repository settings | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | ExitCode 0 | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npm run format:check` equivalent | EXIT_CODE 0 | ✅ |
| ESLint | `npm run lint` | EXIT_CODE 0 | ✅ |
| tsc | `npm run typecheck` | EXIT_CODE 0 | ✅ |
| Jest | `node run-jest.cjs --coverage` | 5448 passed | ✅ |

**Notes:** The Codex agent-variant generator check (`generate_codex_agent_variants --check`) exits 0. The Codex TOML variants carry no `tools:` grant for either agent (the existing ci-gate grants are also absent from them), so no variant change was needed.

---

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| quality-checks7 / Code Quality & Tests (3.13) | pending | 97.11% lines, 94.36% branches local | df8d43daaf9b617c8fbee844021919f1c2c70af8 | `evidence/qa-gates/rem1-py-pytest.2026-11-08T15-39.md`; no PR exists yet, so CI has not run |
| Python format, lint, type | pass | Black, Ruff, Pyright EXIT_CODE 0 | df8d43daaf9b617c8fbee844021919f1c2c70af8 | `evidence/qa-gates/py-black`, `py-ruff`, `py-pyright` |
| PowerShell format, analyze, test | pass | 0 findings, ExitCode 0 | df8d43daaf9b617c8fbee844021919f1c2c70af8 | `evidence/qa-gates/ps-format`, `ps-pssa`, `ps-pester` |
| TypeScript lint, type, test | pass | EXIT_CODE 0, 5448 passed | df8d43daaf9b617c8fbee844021919f1c2c70af8 | `evidence/qa-gates/ts-lint`, `ts-typecheck`, `ts-jest` |

---

## 8. Gaps and Exceptions

### Identified Gaps
- AC11 depends on CI and the pull request statement; it remains unchecked and is pending CI. This is not a defect on the branch.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
**None.** All planned tests implemented. No test was removed or weakened in the diff; the only edit to an existing test file adds cases.

---

## 9. Summary of Changes

The change ships a tested PowerShell wave-layering module and CLI to Claude and Codex destinations, aligns the Python reference with it through a shared corpus, repoints the epic wave-layering text at the shipped CLI, and adds a regression test that fails when an epic surface cites an unshipped script.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All evaluated policy areas PASS. Coverage artifacts exist for Python, PowerShell, and TypeScript, are current for the production code at the reviewed head, and meet the governing thresholds. Mirror, bundle, manifest, hook, agent-grant, and frozen-surface checks hold. One non-blocking observation remains in the code review.

**Fail-closed reminder:** every required baseline, QA, and coverage-comparison artifact was present at review time.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plan present
- ✅ Design Principles: pure core, injected reader, thin CLI
- ✅ Module & File Structure: all files under 500 lines
- ✅ Naming, Docs, Comments: approved verbs, help blocks
- ✅ Toolchain Execution: single pass, all EXIT_CODE 0
- ✅ Summarize & Document: self-review and plan

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright clean
- ✅ Python Design & Typing: fully annotated
- ✅ Error Handling: specific exception, caught by name

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyzer clean
- ✅ PowerShell Design & Safety: strict mode, CmdletBinding, no globals
- ✅ Structure & Naming: 222-line module
- ✅ Toolchain: single pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: deterministic, isolated
- ✅ Coverage & Scenarios: positive, negative, edge, error
- ✅ Test Structure: Arrange-Act-Assert
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest
- ✅ Test Style & Structure: focused
- ✅ Naming & Readability: descriptive
- ✅ Toolchain: Pytest only

**For PowerShell:**
- ✅ Framework & Scope: Pester 6 through PoshQC
- ✅ Test Style & Structure: focused, mirrored layout
- ✅ Naming & Readability: self-documenting
- ✅ Toolchain: ExitCode 0

---

### Metrics Summary

- ✅ 16559 pytest, 19708 Pester, 5448 Jest tests passing with 0 failures
- ✅ 100% line coverage on both new PowerShell files and on `epic_wave_computation.py`
- ✅ Repo-wide Python 97.11% lines and 94.36% branches; PowerShell 95.57% lines
- ✅ Proper file organization: tests mirror source layout
- ✅ All code quality checks passing

---

### Recommendation

**Ready for merge**

No blocking policy finding. Open the pull request with the statement that destinations must refresh the push-down after an extension rebuild and reinstall, then let CI satisfy AC11.

---

## Appendix A: Test Inventory

### Complete Test List

1. `tests/scripts/claude-lib/epic-wave/EpicWave.Parity.Tests.ps1` › one `It` per corpus case (10 tests)
2. `tests/scripts/claude-lib/epic-wave/EpicWave.Tests.ps1` › distinct error messages, command exit codes 0, 1, 2, in-process CLI runs (27 tests)
3. `tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1` › allows the shipped wave CLI and the Python parity reference (3 cases); rejects another script and a chained command (2 cases)
4. `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` › 8 tests
5. `tests/scripts/dev_tools/test_epic_wave_corpus_parity.py::test_corpus_case_matches_reference` › 9 parametrized cases
6. `tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py` › `test_epic_wave_directory_publishes_stored_resources`, `test_epic_wave_resources_match_claude_lib_sources`
7. `tests/scripts/dev_tools/test_validate_epic_planner_state_shape_errors.py::test_dependency_on_skipped_feature_reports_unresolved_reference`
8. `extensions/drm-copilot/test/lib/push-down/codex-agents-epic-wave-directory.test.ts` › publication under `.codex/lib/epic-wave/` and `VIRTUAL_ROOT_FOLDERS` membership

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest -n auto --cov-branch --cov
```

**For PowerShell:**
```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-08 (reaudit after remediation cycle 1, stamp 2026-11-08T15-41)  
**Policy Version:** Current (as of audit date)
