# Policy Compliance Audit: Pushed-Down Vendored Code Coverage Carve-Out (#1049)

**Audit Date:** 2026-11-19
**Audit Type:** Opening review (full branch scope)
**Code Under Test:** merge base `021a52e74999d17c6ae67ed7a32c14958448ceab` of the base branch `origin/epic/shared-agent-harness-layer-integration` and reviewed head `a9fcaf343c8966df05f10a517b0cae9b3d0bb358`; the diff between them lists the changed files (121 files, +3281/-112; 40 outside the feature folder). The resolved base tip equals the merge base.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production files (1 new, 3 edited; plus `PoshQC.psd1` manifest), each mirrored in the bundle; 4 test files (3 new, 1 edited) | 29313 tests (Pester, full gate) | ✅ 29295 pass, 0 fail, 18 skipped | 96.77% lines (47184/48759) | 96.78% lines (47306/48882) | New module 99.09% lines (109/110); changed lines of edited modules 100% (17/17) |
| TypeScript | 0 production files; 2 new test files | 6142 (extension), 6159 (root) | ✅ 6142 pass and 6159 pass, 0 fail | 97.42% lines (68431/70241), 94.63% branches (10597/11198) | 97.42% lines (68431/70241), 94.63% branches (10598/11199) | 100% of changed production lines (0 of 0; test files only); 97.42% lines, 94.63% branches |
| Python | 0 production files; 1 edited test file (+1 line) | 17122 tests | ✅ 17122 pass, 0 fail | 98.00% lines, 95.46% branches (equal to head: no Python production file differs from the merge base) | 98.00% lines (35359/36079), 95.46% branches (13091/13714) | 100% of changed production lines (0 of 0; test file only); repo-wide 98.00% lines, 95.46% branches |

Non-code files: two JSON files (the shared hash corpus fixture and the generator section list) and Markdown files (rule and agent sources with their generated outputs, six brief copies, the README pair, feature docs). They carry no executable code and are not coverage languages; they are validated by the test suites that read them, the generator `-Check` (no drift), and the repo-gate text cases.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/evidence/baseline/baseline-jest.2026-11-19T09-15.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (written 2026-11-19 13:04 UTC; reviewer recomputation 97.42% lines, 94.63% branches) and `evidence/qa-gates/final-jest.2026-11-19T13-07.md`; root `coverage/lcov.info` from the reviewer run (see below)
- Python baseline coverage artifact: `evidence/baseline/baseline-pytest.2026-11-19T09-17.md` (test counts; no coverage figure recorded because no Python production file changes)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (written 2026-11-19 13:42 UTC by the reviewer run at the head; 98.00% lines, 95.46% branches) and `evidence/qa-gates/reviewer-coverage-gates.2026-11-19T13-43.md`
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester.2026-11-19T09-09.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (merged full-tree run, written 2026-11-19 13:04 UTC) and `evidence/qa-gates/final-pester.2026-11-19T13-05.md`
- Per-language comparison summary: section 1.2.1 below and `evidence/qa-gates/coverage-delta-powershell.2026-11-19T13-06.md`

Baseline coverage is read from the plan's `Phase 0 baseline` artifacts under `evidence/baseline/`. The three commits after the final QC runs (`80debc1af` is before them; `fc7b78b6e` and `a9fcaf343` after) change only feature-folder files, so the post-change reports measure the code state of the head.

Reviewer run (disclosed): the root report `coverage/lcov.info` and the Python report `artifacts/python/lcov.info` were absent in the item worktree, and the feature-review coverage hook reads both for changed languages. The reviewer ran `run-test-suite.sh pytest --cov --cov-branch` and `run-test-suite.sh jest --coverage` once each through the parallel launcher at the head (retrying launcher exit 75 while another worktree held the machine test lock): pytest 17122 passed, 98.00% lines, 95.46% branches; root Jest 6159 passed, 98.39% lines, 94.39% branches (`evidence/qa-gates/reviewer-coverage-gates.2026-11-19T13-43.md`). This departs from the evidence-only model to produce artifacts the review needs; the figures change no verdict. No Python or TypeScript production file differs between the merge base and the head, so the Python head measurement is also the baseline for every production line.

**CI-proven checks:** Format, lint, and type-check results are read from `evidence/qa-gates/final-qc-powershell-static.2026-11-19T12-46.md`, `evidence/qa-gates/final-qc-typescript-static.2026-11-19T12-46.md`, and `evidence/qa-gates/final-qc-python-static.2026-11-19T12-52.md`, and were not re-run.

---

## Executive Summary

The branch adds a narrow, manifest-derived vendored-code exception to the pushed-down `general-unit-test` coverage rule and implements the destination check in a new PoshQC submodule. A destination opts in with one boolean key; PoshQC classifies each `.push-down-manifest.json` entry and coverage candidate as `exempt`, `modified`, `missing`, or `unlisted`, removes only `exempt` files from the `config` population, fails closed on an invalid manifest, and writes `vendored-coverage-exemptions.json` beside the coverage output file. The rule source, generated rule and agent outputs, six brief copies, and the PoshQC README are updated; this repository does not opt in, enforced by a repo-gate test.

No blocking finding. Every changed PowerShell production file is above the 85% line threshold with all changed lines covered; no TypeScript or Python production file changed. All static checks, the generator check, and the full Pester, Jest, and pytest gates pass.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md`
- ✅ `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` (test files only)
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (one test file only; no new Python)
- N/A Bash: no bash file changed
- ✅ JSON: corpus fixture and generator section list

**Policy document edits (authorized):** The branch edits `.claude/rules/general-unit-test.md`, `.github/instructions/general-unit-test.instructions.md`, `.agents/skills/general-unit-test/SKILL.md`, the feature-review agents, and the execution-environment brief copies, all through their generator sources. `spec.md` `## Owner Authorization` (2026-10-31) scopes the exception to the vendored paragraph, the Enforcement sentence, the brief sentence, and (OQ-3 default, `### Rule Source`) the Coverage Exclusion Policy section in the Copilot output. The reviewer compared the diff with that scope and found no other policy text changed. The Phase 0 gate record cites the authorization (`evidence/other/phase0-gate.2026-11-19T08-48.md`).

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; executor helpers lived under the issue scratch directory (`SCRATCH/issue-1049-*`), outside the repository tree.
- ✅ No ongoing tooling script was added outside the tested PoshQC module.

---

## Rejected Scope Narrowing

None. The caller prompt supplied the resolved base, merge base, head, feature folder, and AC sources, and asked for the full `feature-review-workflow` contract; it contains no plan-, task-, phase-, file-, or language-scope narrowing. This audit covers the full branch diff from `021a52e74999d17c6ae67ed7a32c14958448ceab`, which matches `artifacts/pr_context.summary.txt` (generated 2026-11-19 13:16:23 UTC at `a9fcaf343`).

---

## Owner Directive Decisions

The delegation carried four owner directives (scope epic #1018, integration branch, step `any`). Decision files are under `artifacts/orchestration/owner-directive-decisions/a4496c52139fabd66/`.

- OD-1 (`scheduling`): honored — the review ran to completion without halting and recorded its assumptions.
- OD-2 (`merge_timing`): refused — outside the reviewer's scope; the reviewer performs no merge.
- OD-3 (`merge_timing`): refused — outside the reviewer's scope; the reviewer deletes no branch.
- OD-4 (`scheduling`): honored — findings were weighed under the cost-benefit rule; the two hardening observations in the code review are classified non-blocking.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each Pester `Describe` resets its in-memory destination in `BeforeEach`; Jest cases build their own in-memory file system. All suites ran through the parallel launcher (Pester 8 workers). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One status, one invalid-manifest case, or one population source per `It`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | All new tests are in-memory; the full Pester gate grew by 101 tests with wall-clock 714 s to 751 s across 8 workers (machine-load variance included). |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, or temporary file; the Jest invariant test injects a fixed clock; CRLF content is built in code. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `It` names that state the expected status; Arrange/Act/Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 96.77% lines; TypeScript 97.42% lines, 94.63% branches<br>**Command:** `run-test-suite.sh pester`; `run-test-suite.sh jest-extension --coverage`; `run-test-suite.sh pytest`<br>**Artifact:** `evidence/baseline/baseline-pester.2026-11-19T09-09.md`, `baseline-jest.2026-11-19T09-15.md`, `baseline-pytest.2026-11-19T09-17.md`<br>**Timestamp:** 2026-11-19 09:09 / 09:15 / 09:17 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 96.78% lines; TypeScript 97.42% lines, 94.63% branches<br>**Change:** PowerShell +0.01 points; TypeScript 0.00<br>**Status:** No regression; zero baseline-covered changed lines are uncovered (`coverage-delta-powershell.2026-11-19T13-06.md`) |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage (reviewer read of the XML):** `PoshQC.VendoredCoverage.psm1` 99.09%, `PoshQC.Coverage.psm1` 94.92%, `PoshQC.Testing.psm1` 94.30%, `PoshQC.psm1` 88.52%; `PoshQC.psd1` has no executable lines<br>**Thresholds:** 85% line (PowerShell has no branch gate)<br>**Status:** All changed production files meet the threshold |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** `PoshQC.VendoredCoverage.psm1` (new); changed hunks of `PoshQC.Coverage.psm1`, `PoshQC.Testing.psm1`, `PoshQC.psm1`<br>**New code coverage:** 99.09% (109/110) for the new module; 100% (17/17) of changed executable lines in edited modules<br>**Calculation method:** `git diff --unified=0` hunks intersected with XML executable lines (`coverage-delta-powershell.2026-11-19T13-06.md`); module counters re-read by the reviewer |
| **Comprehensive Coverage** | ✅ PASS | Every function of the new module has direct cases (see section 5). Untested: line 107 (non-object JSON document throw). |
| **Positive Flows** - Valid inputs | ✅ PASS | `exempt` classification, unknown-field tolerance, higher minor version, opt-in `true`, subtraction for `config`, report write beside default and shard outputs. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Ten invalid-manifest cases; non-boolean opt-in throws naming `config/poshqc-coverage.json`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Empty corpus case, BOM, lone CR, CRLF, non-ASCII; case-renamed path; empty entries report; blank coverage output path (AD-3). |
| **Error Handling** - Error paths | ✅ PASS | Invalid manifest stops `Invoke-PoshQCTest` before Pester; absent manifest logs exactly one warning. |
| **Concurrency** - If applicable | ✅ PASS | Per-shard report location beside each shard's coverage output avoids concurrent writes to one path (AD-2); tested with a shard path. |
| **State Transitions** - If applicable | ✅ PASS | Status transitions by input state (`exempt` to `modified` on edit or link; `missing`; `unlisted`) are each tested. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.77% lines (from `evidence/baseline/baseline-pester.2026-11-19T09-09.md`) -> Post-change: 96.78% lines. Change: +0.01 points. New/changed-code coverage: new module 99.09% lines; changed executable lines of edited modules 100%; per changed file at or above 85% (lowest `PoshQC.psm1` 88.52%, unchanged from baseline). Branch: not measured by Pester; no branch gate applies. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/coverage-delta-powershell.2026-11-19T13-06.md`.
- TypeScript: Baseline: 97.42% lines / 94.63% branches (from `evidence/baseline/baseline-jest.2026-11-19T09-15.md`) -> Post-change: 97.42% lines / 94.63% branches. Change: 0.00 lines, 0.00 branches (one branch added to both numerator and denominator in an untouched file). New/changed-code coverage: 100% of changed production lines (0 of 0; the two changed files are tests), with the extension report at 97.42% lines and 94.63% branches. Root report from the reviewer run: 98.39% lines, 94.39% branches. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `coverage/lcov.info`, `evidence/qa-gates/final-jest.2026-11-19T13-07.md`, `evidence/qa-gates/reviewer-coverage-gates.2026-11-19T13-43.md`.
- Python: Baseline: N/A - no pre-change run (the Phase 0 pytest baseline recorded test counts only; no Python production file differs between the merge base and the head, so the head figure applies to every production line) -> Post-change: 98.00% lines / 95.46% branches. Change: N/A. New/changed-code coverage: 100% of changed production lines (0 of 0; the one changed file is a test outside the measured denominator), with repo-wide 98.00% lines and 95.46% branches. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/reviewer-coverage-gates.2026-11-19T13-43.md`, `evidence/qa-gates/final-pytest.2026-11-19T12-52.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions compare status, path lists, and the file name in thrown messages; RepoGate cases name the copy under test via `<RelativePath>`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange/Act/Assert comments in the new Pester and Jest cases. |
| **Document Intent** | ✅ PASS | File-level doc comments and descriptive case names with issue references. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or process; the only real file reads are the committed corpus fixture and, in the repo gate, the repository's own committed files. |
| **Use Mocks/Stubs** | ✅ PASS | Script-block seams for byte reads, existence, reparse points, warnings, directory creation and content writes; `Mock New-Item`/`Set-Content` in the default-writer test so nothing is written. |
| **Environment Stability** | ✅ PASS | No `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `tmpdir`, or `mkdtemp` in the new tests (reviewer grep). Leak scan: 0 failures. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit; executor self-review `evidence/qa-gates/self-review.2026-11-19T13-10.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1049, `spec.md` (v0.2), `user-story.md`, research `research/research.2026-10-31T18-20.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-10-31T14-03.md` (revision 2.1 after the first Phase 0 gate block). |
| **Document the plan** | ✅ PASS | Task-check records P0-T1 through P4-T9 under `evidence/other/`; phase-gate records P1-P3; the blocked first Phase 0 verdict kept in place (append-only). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One submodule of small functions; existing modules gain one seam and one call site each. |
| **Reusability** | ✅ PASS | Reuses `Get-PoshQCCoverageFileSet` and the existing configuration seam pattern; hash parity shared with the child 4 writer through one corpus. |
| **Extensibility** | ✅ PASS | Seams with safe defaults; unknown manifest fields tolerated within a major version. |
| **Separation of concerns** | ✅ PASS | Pure functions (hash, parse, classify, render) separated from I/O helpers (`Read-PoshQCFileByte`, `Test-PoshQCReparsePoint`, `Write-PoshQCVendoredCoverageReport`). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | `PoshQC.VendoredCoverage.psm1` holds only the vendored-coverage concern. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts of the 15 changed covered files (reviewer `awk 'END{print NR}'`): largest `PoshQC.Testing.psm1` 567 (and bundle copy), `PoshQC.VendoredCoverage.Tests.ps1` 440, `PoshQC.CoverageConfig.Tests.ps1` 404. None at or above 700. `config/file-size-baseline.json` not changed. |
| **Public vs internal** | ✅ PASS | Only `Get-PoshQCVendoredCoverageStatus` added to `FunctionsToExport` and `Export-ModuleMember`. |
| **No circular dependencies** | ✅ PASS | `PoshQC.VendoredCoverage.psm1` is loaded before `PoshQC.Coverage.psm1` and imports nothing from it. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-PoshQCCanonicalContentHash`, `ConvertFrom-PoshQCPushDownManifest`, `Resolve-PoshQCVendoredCoverageExemption`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every new function; README section added. |
| **Comment why, not what** | ✅ PASS | e.g. the one-pass normalization equivalence and the `-NoEnumerate` empty-file rationale. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat`; `npx prettier --check src test`; `poetry run black --check <file>`<br>**Result:** 0 files changed in each |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze` (PSScriptAnalyzer); `npm run lint`; `poetry run ruff check <file>`<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `npm run typecheck` (two tsc projects); `poetry run pyright <file>`<br>**Result:** 0 errors; not applicable to PowerShell |
| **4. Architecture** | ✅ PASS | No dependency-cruiser configuration exists; no TypeScript production change. |
| **5. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester`, `jest-extension --coverage`, `jest`, `pytest`<br>**Result:** 29313 / 6142 / 6159 / 17122, 0 failures |
| **6. Contract checks** | ✅ PASS | Codex generator `--check` exit 0; `Invoke-HarnessGeneration.ps1 -Surface all -Check` exit 0, `harness-generation: no drift` |
| **7. Integration** | ✅ PASS | Integration lanes run in CI; pending-CI at the PR head (not blocking). |
| **Full toolchain loop** | ✅ PASS | No step changed a file in the final loop (`final-qc-powershell-static.2026-11-19T12-46.md`). |
| **Explicit reporting** | ✅ PASS | Commands and exit codes recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Per-phase commit messages; self-review record. |
| **Design choices explained** | ✅ PASS | Spec decisions AD-1 to AD-4 and OQ-1 to OQ-7 defaults. |
| **Update supporting documents** | ✅ PASS | PoshQC README and bundle copy; rule, agent, and brief copies. |
| **Provide next steps** | ✅ PASS | Pending-CI confirmation at the PR head. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python production file changed and no Python file was added (no-new-Python rule met). The one change adds a path to the `POSHQC_PARITY_PATHS` tuple in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (extended in place, as the spec permits).

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check <file>`<br>**Result:** `1 file would be left unchanged.` |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check <file>`<br>**Result:** `All checks passed!` |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright <file>`<br>**Result:** 0 errors |
| **Testing with Pytest** | ✅ PASS | **Command:** `run-test-suite.sh pytest`<br>**Result:** 17122 passed, 6 skipped, 0 failed |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | The edited test adds one string to an existing typed tuple; Pyright reports 0 errors. |
| **Design rules for production Python** | ✅ PASS | No Python production file changed, so the dataclass, protocol, and utility-class rules have no new subject; the edit introduces no class. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -ScanFolders scripts, tests/scripts`<br>**Result:** 0 formatted, 986 already formatted, porcelain identical |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze` with `pssa.settings.psd1`<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | None outstanding; leak scan 0 failures. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Hashing uses `SHA256.Create()` and `ReadAllBytes` as the spec requires for 5.1; the module otherwise targets PowerShell 7+ per `.claude/rules/powershell.md`. The report writer's `-Encoding utf8` emits a BOM on 5.1 (Nit in the code review). |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | All seven new functions use `CmdletBinding` and `OutputType`. |
| **Parameter validation** | ✅ PASS | `Mandatory` on required parameters; `AllowEmptyCollection` where empty input is valid. |
| **Avoid global state** | ✅ PASS | No script or global state in the production module. |
| **Error handling** | ✅ PASS | `$ErrorActionPreference = 'Stop'` in I/O functions; specific throws naming the file. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | New module 352 lines; edited modules 331 and 567. No Warning. |
| **Approved verbs** | ✅ PASS | Get, Read, Test, ConvertFrom, ConvertTo, Resolve, Write; PSScriptAnalyzer clean. |
| **Comment why** | ✅ PASS | Comments state rationale (normalization equivalence, opt-in read through `PSObject`). |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 files changed. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | ✅ PASS | The toolchain defines no type-check stage for PowerShell; the stage is skipped per `.claude/rules/powershell.md`. |
| **Step 4: Test** | ✅ PASS | 29313 tests, 0 failed. |
| **Rerun loop if needed** | ✅ PASS | Single clean pass in the final loop. |

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Prettier / ESLint / tsc** | ✅ PASS | `final-qc-typescript-static.2026-11-19T12-46.md`, exit 0 for each step. |
| **No production change** | ✅ PASS | `git diff <merge-base> -- extensions/drm-copilot/src` empty (recorded in `final-jest.2026-11-19T13-07.md`; branch diff lists only two `test/` files). No `coverageThreshold` entry required. |
| **Runtime determinism in tests** | ✅ PASS | Injected `fixedClock`; no timers or `Date.now`. |

### Section 3D: JSON and Generator-Source Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON** | ✅ PASS | `corpus.json` parsed by Jest `JSON.parse` and Pester `ConvertFrom-Json`; `general-unit-test.json` parsed by the generator (check exit 0). |
| **Generated-target consistency** | ✅ PASS | `-Surface rules`, `agents`, `skills` and `all` `-Check` exit 0; the 12 regenerated outputs are exactly the planned set (`rules-generation.2026-11-19T11-36.md`). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | The edited module is a pytest module. |
| **Coverage expectation** | ✅ PASS | Repo-wide 98.00% lines, 95.46% branches from `artifacts/python/lcov.info` (reviewer run); 0 Python production lines changed; CI result recorded in `## CI Cross-check`. |
| **Organization** | ✅ PASS | Test stays under `tests/scripts/dev_tools/`. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `BeforeDiscovery`/`BeforeAll`/`BeforeEach`, `-ForEach` data-driven cases, `InModuleScope`, `Should -Invoke`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .` through the launcher<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged) |
| **Focused Unit Tests** | ✅ PASS | 45 vendored-coverage cases, 5 report call-site cases, 10 configuration cases, 41 repo-gate cases. |
| **Mocking Used Sparingly** | ✅ PASS | Seams preferred; `Mock` used only for default-seam routing and to prevent writes. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage*.Tests.ps1`, `PoshQC.TestingVendoredReport.Tests.ps1`, `PoshQC.CoverageConfig.Tests.ps1`<br>**Code files:** `scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1`, `PoshQC.Testing.psm1`, `PoshQC.Coverage.psm1`<br>Structure mirrors the code location. |
| **File Naming** - *.Tests.ps1 | ✅ PASS | All four end in `.Tests.ps1`. |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest; `*.test.ts`** | ✅ PASS | Both new files are Jest `*.test.ts`. |
| **Layout under `test/`** | ✅ PASS | `extensions/drm-copilot/test/lib/push-down/`, beside the child 4 push-down tests. |

---

## 5. Test Coverage Detail

### PoshQC.VendoredCoverage.psm1 (45 tests in `PoshQC.VendoredCoverage.Tests.ps1`, plus call-site tests)

| Function | Scenario Types | Status |
|-----------|--------------|--------|
| `Get-PoshQCCanonicalContentHash` | Positive, Edge Case (corpus: CRLF, lone CR, BOM, non-ASCII, empty, `abc`) | ✅ |
| `Read-PoshQCFileByte` / `Test-PoshQCReparsePoint` | Positive (committed fixture) | ✅ |
| `ConvertFrom-PoshQCPushDownManifest` | Positive, Negative (10 invalid cases), Edge Case (higher minor, unknown fields) | ✅ |
| `Get-PoshQCVendoredCoverageStatus` | Positive, Negative, Edge Case (case rename, reparse point, absent manifest), default seams | ✅ |
| `Get-PoshQCVendoredCoverageOptIn` | Positive, Negative | ✅ |
| `Resolve-PoshQCVendoredCoverageExemption` | Positive (only `exempt` removed) | ✅ |
| `ConvertTo-PoshQCVendoredCoverageReportJson` / `Write-PoshQCVendoredCoverageReport` | Positive, Edge Case (empty, default/shard/blank paths), default seams | ✅ |

**Coverage:** 99.09% (109/110 lines).

**Not covered:** line 107, the throw for a manifest that parses to a non-object JSON value (Nit in the code review).

### Edited modules

- `PoshQC.Coverage.psm1`: 12/12 changed executable lines covered; file 94.92%.
- `PoshQC.Testing.psm1`: 5/5 changed executable lines covered; file 94.30%.
- `PoshQC.psm1`: list entries only; file 88.52%, unchanged.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Pester 29313; Jest 6142 (ext) + 6159 (root); pytest 17122 | ✅ |
| Tests Passed | Pester 29295 (18 skipped); Jest 100%; pytest 17122 (6 skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Pester 750.95 s wall-clock (8 workers); pytest 67.54 s | ✅ |
| Test File Size | Largest new test file 440 logical lines | ✅ |
| Code Coverage | PowerShell 96.78% lines; TypeScript 97.42% lines / 94.63% branches; Python 98.00% lines / 95.46% branches | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -ScanFolders scripts, tests/scripts` | 0 formatted | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze` | 0 findings | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan -Root` | 0 failures | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest -Root .` (launcher) | 29313 tests, 0 failed | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check src test` | `All matched files use Prettier code style!` | ✅ |
| ESLint | `npm run lint` | 0 problems | ✅ |
| tsc | `npm run typecheck` | 0 errors | ✅ |
| Jest | `run-test-suite.sh jest-extension --coverage`; `jest` | 6142 / 6159 passed | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <file>` | unchanged | ✅ |
| Ruff Linting | `poetry run ruff check <file>` | `All checks passed!` | ✅ |
| Pyright Type Checking | `poetry run pyright <file>` | 0 errors | ✅ |
| Pytest Tests | `run-test-suite.sh pytest` | 17122 passed | ✅ |

**For generation and contracts:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Harness generator check | `Invoke-HarnessGeneration.ps1 -Surface all -Check` | exit 0, no drift | ✅ |
| Codex generator check | `python -m scripts.dev_tools.generate_codex_agent_variants --check` | exit 0 | ✅ |

**Notes:** No pre-existing failure exists in any baseline. Static checks were not re-run by the reviewer; results are read from the recorded evidence.

---

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC (format, analyze, shards) | pass | 0 format changes, 0 analyzer findings; 29313 tests, 0 failed; 96.78% lines | a9fcaf343c8966df05f10a517b0cae9b3d0bb358 | `evidence/qa-gates/final-qc-powershell-static.2026-11-19T12-46.md`, `evidence/qa-gates/final-pester.2026-11-19T13-05.md` |
| poshqc / PowerShell hook suites (Linux) | pass | subset of the Pester gate, 0 failed | a9fcaf343c8966df05f10a517b0cae9b3d0bb358 | `evidence/qa-gates/final-pester.2026-11-19T13-05.md` |
| TypeScript format, lint, typecheck | pass | 0 findings, 0 errors | a9fcaf343c8966df05f10a517b0cae9b3d0bb358 | `evidence/qa-gates/final-qc-typescript-static.2026-11-19T12-46.md` |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest, windows-latest) | pass | 6142 passed; 97.42% lines, 94.63% branches | a9fcaf343c8966df05f10a517b0cae9b3d0bb358 | `evidence/qa-gates/final-jest.2026-11-19T13-07.md` |
| Python static (Black, Ruff, Pyright) | pass | 0 findings | a9fcaf343c8966df05f10a517b0cae9b3d0bb358 | `evidence/qa-gates/final-qc-python-static.2026-11-19T12-52.md` |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 17122 passed | a9fcaf343c8966df05f10a517b0cae9b3d0bb358 | `evidence/qa-gates/final-pytest.2026-11-19T12-52.md` |
| Enforce Python coverage thresholds | pass | 98.00% lines, 95.46% branches | a9fcaf343c8966df05f10a517b0cae9b3d0bb358 | `artifacts/python/lcov.info`; `evidence/qa-gates/reviewer-coverage-gates.2026-11-19T13-43.md` |
| Harness generation / Codex generator checks | pass | 0 drift findings | a9fcaf343c8966df05f10a517b0cae9b3d0bb358 | `evidence/qa-gates/final-contracts.2026-11-19T13-07.md` |
| CI Required Gate | pass | follows the jobs above | a9fcaf343c8966df05f10a517b0cae9b3d0bb358 | local evidence above |

No PR exists yet for the branch and the PR context records CI status as not available, so these rows are claims from local evidence for the orchestrator to compare with CI at the PR head. The runs were made at earlier commits; every later commit (`fc7b78b6e`, `a9fcaf343`) changes only feature-folder files.

---

## Evidence Location Compliance

- Branch-diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: none.
- `env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0, no violation reported.
- All feature evidence is under `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/evidence/<kind>/`. Append-only: the blocked first Phase 0 verdict and its task checks remain beside the re-run records.

## Vendored Push-Down Exemption Check

Applied per the branch's new `## Coverage Verification` step: no `vendored-coverage-exemptions.json` exists beside `artifacts/pester/powershell-coverage.xml` (this repository does not opt in); no coverage `exclude`, `omit`, `coveragePathIgnorePatterns`, or settings-file coverage path changed on the branch (`config/poshqc-coverage.json`, `extensions/drm-copilot/jest.config.cjs`, and `pyproject.toml` are not in the diff); no `.push-down-manifest.json` exists or changed. No finding.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## File Size Advisory

No covered file in the branch diff is at or above 700 logical lines (largest: `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and its bundle copy, 567). `config/file-size-baseline.json` is not changed. No finding.

## Tier Classification

`quality-tiers.yml` exists; `scripts/powershell/PoshQC` is already classified and the branch does not change the file. No finding.

---

## 8. Gaps and Exceptions

### Identified Gaps

None blocking.

- **Pending-CI (not blocking):** CI on the PR head (PowerShell QC shards on windows-latest, Linux hook suites, extension Jest jobs, Python quality and coverage jobs), confirmed by the S9 CI gate after the PR is opened.
- **Non-blocking code-review observations:** leaf-only reparse-point check; case-variant manifest keys rejected as invalid JSON; one uncovered throw line; BOM on Windows PowerShell 5.1 for the report writer.

### Approved Exceptions

- **Policy-file edits:** authorized by `spec.md` `## Owner Authorization`, within the scope stated there (verified by the reviewer against the diff).

### Removed/Skipped Tests

**None.** The 18 skipped Pester tests and 6 skipped pytest tests are unchanged from the Phase 0 baselines.

---

## 9. Summary of Changes

The branch lets a destination repository exempt unchanged pushed-down PowerShell files from its PoshQC coverage population, by exact manifest path and verified canonical hash behind a boolean opt-in, with a deterministic exemption report and fail-closed handling, and amends the pushed-down coverage rule, review step, and brief to define and police that exception.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

Every changed language has numeric baseline and post-change coverage, every changed PowerShell production file meets the line threshold with all changed lines covered, and all static, contract, and test gates pass. The policy-file edits are owner-authorized.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes
- ✅ Design Principles
- ✅ Module & File Structure
- ✅ Naming, Docs, Comments
- ✅ Toolchain Execution
- ✅ Summarize & Document

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell
- ✅ TypeScript (tests only)
- ✅ Python (one test file only)
- ✅ JSON and generator sources

#### General Unit Test Policy (Section 1)
- ✅ Core Principles
- ✅ Coverage & Scenarios
- ✅ Test Structure
- ✅ External Dependencies
- ✅ Policy Audit

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell (Pester)
- ✅ TypeScript (Jest)
- ✅ Python (pytest)

### Metrics Summary

- ✅ Pester 29313 tests, 0 failed; Jest 6142 and 6159 passed; pytest 17122 passed
- ✅ PowerShell 96.78% lines; new module 99.09%; changed lines 100%
- ✅ TypeScript 97.42% lines, 94.63% branches (no production change)
- ✅ Python 98.00% lines, 95.46% branches (no production change)
- ✅ All static, generator, and contract checks clean

### Recommendation

**Ready for merge** after PR authoring and a green S9 CI gate at the PR head.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.Tests.ps1` (new): `Get-PoshQCCanonicalContentHash`, `Get-PoshQCVendoredCoverageStatus`, file helpers, `Get-PoshQCVendoredCoverageOptIn`, `Resolve-PoshQCVendoredCoverageExemption`, exemption report
- `tests/scripts/powershell/PoshQC/PoshQC.TestingVendoredReport.Tests.ps1` (new): `Invoke-PoshQCTest` vendored coverage report (5 cases)
- `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1` (new): repository gate (opt-in absent, no manifest, rule/agent/brief/README text)
- `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` (edited): opt-in reading and population subtraction cases
- `extensions/drm-copilot/test/lib/push-down/push-down-hash-parity.test.ts` (new)
- `extensions/drm-copilot/test/lib/push-down/push-down-apply-hash-invariant.test.ts` (new)
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (edited: one parity path)

---

## Appendix B: Toolchain Commands Reference

```bash
# PowerShell
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester

# TypeScript (extensions/drm-copilot)
npx prettier --check src test && npm run lint && npm run typecheck
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage

# Python
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch

# Generation and contracts
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check
env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-19
**Policy Version:** Current (as of audit date)
