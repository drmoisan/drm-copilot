# Policy Compliance Audit: Release-commit allowance leg of the preimplementation gates (#1201)

**Audit Date:** 2026-11-18  
**Code Under Test:** merge base `1b9e5746eaa5e32366de695e3f511dbc28700b08` of the base branch (`origin/main`) and reviewed head `89d0e58610eac3b66504ca2ba27a6d22a8f15312`; the diff between them lists the changed files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 12 production files (8 new, 4 edited) and 6 new test files | 600 new tests | ✅ 28087 pass, 0 fail | 96.05% lines (44864/46711) | 96.08% lines (45276/47121) | 100% (both new files, 171/171 and 32/32 per copy) |
| TypeScript | 1 production file edited, 1 new test file | 3 new tests | ✅ 5717 pass, 0 fail | 97.19% lines, 94% branches | 97.19% lines, 94% branches (extension scope); 98.3% lines, 93.78% branches (root scope) | 100% (the added line in `claude-customizations.ts` is covered) |
| Python | 1 production file edited (one tuple entry), 0 test files | 0 new tests | ✅ 16957 pass, 0 fail | 97.74% lines, 95.15% branches | 97.74% lines, 95.15% branches | 100% (the added tuple entry is part of an executed statement) |
| JSON | 2 pack manifests edited | N/A | ✅ parsed by the pack-manifest completeness and dependency-closure tests | N/A (config files) | N/A (config files) | N/A |

Markdown documentation and evidence files changed as well; they carry no coverage requirement. Bash and C# have zero changed files on the branch.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/evidence/baseline/jest-extension.2026-11-17T21-03.md`
- TypeScript post-change coverage artifact: `coverage/lcov.info` (worktree root, written by the reviewer run recorded in `evidence/qa-gates/jest-gate.2026-11-18T01-22.md`) and `evidence/qa-gates/final-qc-jest.2026-11-18T01-10.md`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/evidence/baseline/pester.2026-11-17T20-55.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-11-18T01-05 UTC, after the last code commit `db46ac6ad` at 2026-11-18T00-49 UTC; the head commit `89d0e5861` changes only evidence and documentation under `docs/`) and `evidence/qa-gates/final-qc-pester.2026-11-18T01-05.md`
- Per-language comparison summary: section 1.2.1 of this audit and `evidence/qa-gates/coverage-comparison.2026-11-18T01-10.md`

Baseline coverage is read from the plan's `Phase 0 baseline` artifacts, one run of each language's gate.

**CI-proven checks:** Format, lint, and type-check results are read from the final-QC static artifact of each language and are not re-run during the review. Each CI check the review relies on is recorded in `## CI Cross-check`, which the orchestrator compares with CI at the reviewed head.

---

## Executive Summary

The branch adds an allow-side release-commit allowance leg to the Claude and Codex preimplementation gates. Two new PowerShell hook files (`hook-release-allowance-context.ps1`, pure; `enforce-orchestration-preimplementation-gate-release.ps1`, seams and leg entry) are byte-identical in four sibling roots. Each gate gains one guarded dot-source line, one leg line immediately before the final deny, and `+ $release.DenySuffix` as the last term of the final deny. The destination-owned file `.claude/release-commit-allowance.json` is added to `EXCLUDED_RELATIVE_PATHS` in the TypeScript and Python Claude publishers, both core pack manifests list the two new hook files, and six documentation surfaces plus the changelog are updated.

The audit scope is the full branch diff against the merge base (73 files). The review verified byte identity of every mirror set, the gate edits, the absence of the allowance file, the test inventory (600 new Pester tests, 3 new Jest tests, no pre-existing test file changed), the coverage artifacts of all three changed code languages, and the fail-closed behavior of the command decision by a direct in-process probe of 23 additional command lines. No blocking finding was identified.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (mirrored by `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (mirrored by `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (one tuple entry; reviewed under section 3A for completeness)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md`
- N/A Bash: zero changed shell files
- ✅ JSON: two pack manifests

The PowerShell toolchain (format check, PSScriptAnalyzer, leak scan) reported zero findings on the 18 changed PowerShell files; the Pester gate passed 28087 tests with 0 failures; the Jest and pytest gates passed with no coverage drop.

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted (executor scripts lived under the scratch directory outside the repository; no scratch file is in the branch diff)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (no new tooling script was added)
- The reviewer wrote two probe scripts and one Jest launcher in the session scratch directory outside the repository; none is tracked.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Every row registers its own mocks inside the `It` (Pester mocks are It-scoped); no test writes script state read by another row except constants set in `BeforeAll`. The suites passed in the 8-worker parallel Pester run. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Pure-unit table (`hook-release-allowance-context.Tests.ps1`), seam and leg-entry table (`enforce-orchestration-preimplementation-gate-release.Tests.ps1`), decision tables per surface, and a parity suite; each `It` asserts one row. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | JUnit times: 2.6 s (314 tests), 2.1 s (44), 8.1 s (102), 7.7 s (102), 0.8 s (38). |
| **Determinism** - Consistent results | ✅ PASS | All file system, branch, and staged-index reads go through mocked seams; synthetic forward-slash root `/synthetic-worktrees/release`; no clock, randomness, or live git. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Decision rows carry ids tied to AC numbers (for example `AC15-commit-amend`); the shared cases file documents every row key. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 96.05% lines; TypeScript 97.19% lines, 94% branches; Python 97.74% lines, 95.15% branches, read from the `Phase 0 baseline` artifacts<br>**Command:** `Invoke-PoshQCParallelTest`, `pytest -n auto`, Jest with workers (one run of each gate)<br>**Artifact:** `evidence/baseline/pester.2026-11-17T20-55.md`, `evidence/baseline/jest-extension.2026-11-17T21-03.md`, `evidence/baseline/pytest.2026-11-17T21-03.md`<br>**Timestamp:** 2026-11-17 20:38 to 21:03 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 96.08%; TypeScript 97.19% / 94%; Python 97.74% / 95.15%<br>**Change:** +0.03% PowerShell lines; 0.00% TypeScript and Python<br>**Status:** No regression. The changed lines of the Claude gate (39, 437, 438) and the Codex gate (35, 446, 447) are covered in the JaCoCo report; the Claude gate's uncovered lines 148, 466, 490-492, 495 are pre-existing and unchanged. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** Claude gate 96.61% (171/177), Codex gate 100% (182/182), `claude-customizations.ts` 100% lines / 96.82% branches, `push_down_claude_customizations.py` 93.67% lines / 87.50% branches<br>**Thresholds:** 85% line; 75% branch for TypeScript and Python; no PowerShell branch gate<br>**Status:** All changed files meet the thresholds |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** `hook-release-allowance-context.ps1` (both measured copies), `enforce-orchestration-preimplementation-gate-release.ps1` (both measured copies)<br>**New code coverage:** 100% (171/171 and 32/32 per copy)<br>**Calculation method:** per-file JaCoCo `line` elements of `artifacts/pester/powershell-coverage.xml` parsed by the reviewer |
| **Comprehensive Coverage** | ✅ PASS | **All functions tested:** every function of both new files is reached (100% line coverage); the parser has one row per rule of AC-1, the decision suites have 101 rows per surface.<br>**Untested code:** none in the new files. |
| **Positive Flows** - Valid inputs | ✅ PASS | AC-8 to AC-11 rows: allowed `git add` forms (6), allowed `git commit` forms (8), add-then-commit union (1), two-allowance selection (2 allow, 1 deny). |
| **Negative Flows** - Invalid inputs | ✅ PASS | AC-12 to AC-17 rows: config failures (5), whole-line shape (8), branch (2), options (42), paths (12), staged index (5), each asserting the exact full deny text. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Trailing `;`, case-variant and trailing-slash `-C`, second `--`, `--` only, `-- -A`, case-differing operand, attached `-C`, bare `git -C`. |
| **Error Handling** - Error paths | ✅ PASS | Config seam throw, container seam throw, branch-reader and staged-reader throw (`PREIMPL_RELEASE_LEG_ERROR` asserted through the debug stream). |
| **Concurrency** - If applicable | N/A | The leg is a synchronous pure decision with no shared state. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.05% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.08% lines. Change: +0.03% lines. New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `evidence/baseline/pester.2026-11-17T20-55.md`, `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/final-qc-pester.2026-11-18T01-05.md`.
- TypeScript: Baseline: 97.19% lines (from the `Phase 0 baseline` artifact) -> Post-change: 97.19% lines. Change: 0.00% lines, 0.00% branches (94% to 94%). New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `evidence/baseline/jest-extension.2026-11-17T21-03.md`, `evidence/qa-gates/final-qc-jest.2026-11-18T01-10.md`, `coverage/lcov.info` with `evidence/qa-gates/jest-gate.2026-11-18T01-22.md` (root scope 98.3% lines, 93.78% branches).
- Python: Baseline: 97.74% lines (from the `Phase 0 baseline` artifact) -> Post-change: 97.74% lines. Change: 0.00% lines, 0.00% branches (95.15% to 95.15%). New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `evidence/baseline/pytest.2026-11-17T21-03.md`, `artifacts/python/lcov.info`, `evidence/qa-gates/final-qc-pytest.2026-11-18T01-10.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Every decision assertion uses `Should -BeExactly` with `-Because "row <Id>"`; invocation counts name the seam and expected count. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit `# Arrange`, `# Act`, `# Assert` comments in the seam suite and Jest suite; decision rows arrange through `Invoke-ReleaseAllowanceRow`. |
| **Document Intent** | ✅ PASS | Comment-based help at the top of every suite; row ids carry AC numbers. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No git process, network, or real worktree read; the parity suite reads tracked repository files as a contract test, the established pattern of the existing parity suites. |
| **Use Mocks/Stubs** | ✅ PASS | Mocked seams: `Get-OrchestrationGateReleaseAllowanceConfigText`, `Test-OrchestrationGateReleaseAllowancePathIsContainer`, `Get-EpicScopeWorktreeHeadBranch`, `Get-OrchestrationGateStagedIndex`, `Read-OrchestrationGateCheckpoint`, `Get-OrchestrationGateBookkeepingConfigText`, and `Test-Path`/`Get-Content` for the two seam bodies. Jest uses `buildInMemoryFileSystem` and `fixedClock`. |
| **Environment Stability** | ✅ PASS | A scan of the seven new test files for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `Set-Content`, `Out-File`, `env:`, `Start-Sleep`, `setTimeout`, `Date.now`, and `writeFileSync` returned no match. No temporary file is created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, the code review, and the feature audit with timestamp 2026-11-18T01-18 form the review set. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` (#1201, full-bug) and `spec.md` (AC-1 to AC-32, decisions AD-1 to AD-6). |
| **Read existing change plans** | ✅ PASS | `research/research.2026-11-17T19-10.md` maps the existing legs (#1026, #1160, #1169, #1182) and the #1188 resolver. |
| **Document the plan** | ✅ PASS | `plan.2026-11-17T14-05.md` with per-task evidence under `evidence/other/task-check.*`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One pure file and one seam file; the gate edit is three lines per gate. |
| **Reusability** | ✅ PASS | Reuses `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-OrchestrationCommandTextUnresolvable`, `Get-OrchestrationGateStagedIndex`, `ConvertFrom-DocsOnlyNameList`, `Get-OrchestrationGateBookkeepingWorktreeRoot`, and `Get-EpicScopeWorktreeHeadBranch` without modification. |
| **Extensibility** | ✅ PASS | Schema-versioned config; reader parameters with defaults that call the named seams. |
| **Separation of concerns** | ✅ PASS | The context file performs no I/O; only the two seams in the release sibling touch the file system. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Parser, matcher, classifier, and decision in the pure file; seams and leg entry in the sibling. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts: `hook-release-allowance-context.ps1` 495, `enforce-orchestration-preimplementation-gate-release.ps1` 166, Claude gate 495, Codex gate 487, `claude-customizations.ts` 497, `push_down_claude_customizations.py` 462, test files 96 to 281. No file reaches 700; `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | ✅ PASS | The gate consumes only `Get-OrchestrationReleaseAllowanceResult`; helper functions carry the `ReleaseAllowance` noun prefix. |
| **No circular dependencies** | ✅ PASS | The release sibling dot-sources the context file; the context file dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs (`Get`, `Test`, `ConvertFrom`); script-scope variables all prefixed `$script:ReleaseAllowance` (8 names, unique in the hook directory). |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function; file headers state the evaluation order. |
| **Comment why, not what** | ✅ PASS | For example the comment on the `[string[]] $rest` assignment explains the one-element array unrolling. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** Invoke-Formatter check (PowerShell), `black --check .`, `prettier --check`<br>**Result:** zero differences (`evidence/qa-gates/final-qc-static-*.md`) |
| **2. Linting** | ✅ PASS | **Command:** PSScriptAnalyzer, `ruff check .`, `eslint src test`<br>**Result:** zero findings |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`, `tsc -p ./ --noEmit`, `tsc -p tsconfig.jest.json --noEmit`<br>**Result:** zero errors; not applicable for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester`, `pytest`, `jest-extension`; reviewer root `node run-jest.cjs --coverage`<br>**Result:** 0 failures in each run |
| **Full toolchain loop** | ✅ PASS | Final QA evidence records a single passing pass of format, lint, type, unit, and contract (`generate_codex_agent_variants --check`); integration runs in CI. |
| **Explicit reporting** | ✅ PASS | Commands, exit codes, and figures are recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages of `0ac5ea660`, `db46ac6ad`, `89d0e5861`; `evidence/qa-gates/self-review.2026-11-18T01-11.md`. |
| **Design choices explained** | ✅ PASS | AD-1 to AD-6 in `spec.md`. |
| **Update supporting documents** | ✅ PASS | Six execution-environment copies, the `.agents` orchestrate skill and bundle, `.claude/rules/orchestrator-state.md` and bundle, `CHANGELOG.md`. |
| **Provide next steps** | ✅ PASS | Spec `## Rollout & Follow-up`: merge, release, push-down refresh, epic #1018 integration. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** 1070 files unchanged |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check .`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors |
| **Testing with Pytest** | ✅ PASS | **Command:** `pytest -n auto --cov --cov-branch`<br>**Result:** 16957 passed, 0 failed |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | The entry joins the existing `tuple[Path, ...]` constant. |
| **Dataclasses for value objects** | N/A | No new value object. |
| **Protocols/ABCs for interfaces** | N/A | No new interface. |
| **Avoid utility classes** | N/A | No new class. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No new control flow. |
| **Logging over print** | N/A | No new output. |
| **Invariants at construction** | N/A | No new construction. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** check-only Invoke-Formatter comparison with `pssa.settings.psd1` on the 18 changed PowerShell files<br>**Result:** `format_drift=0` |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** PSScriptAnalyzer with repository settings on the same files<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | No findings to fix; leak scan 0 failures. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The hooks target PowerShell 7+ (`.NOTES`), consistent with `.claude/rules/powershell.md`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every function has `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowNull`, `AllowEmptyString`, `AllowEmptyCollection` used where needed. No function changes state, so no `ShouldProcess` is needed. |
| **Avoid global state** | ✅ PASS | Only read-only script-scope constants with the unique `ReleaseAllowance` prefix (required by the in-process dispatcher). |
| **Error handling** | ✅ PASS | The config seam throws on a non-file or failed read; the leg maps that to `RELEASE_ALLOWANCE_CONFIG_INVALID`; the outer catch returns a declined result with a `PREIMPL_RELEASE_LEG_ERROR` debug record, which leaves the gate's deny in place (fail closed). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 495 and 166 logical lines for the new files; 495 and 487 for the gates. |
| **Approved verbs** | ✅ PASS | `Get-`, `Test-`, `ConvertFrom-` only. |
| **Comment why** | ✅ PASS | Header comments state the evaluation order and its rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 drift (`evidence/qa-gates/final-qc-static-powershell.2026-11-18T00-51.md`). |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 28105 tests, 28087 passed, 0 failed, 18 skipped (`evidence/qa-gates/final-qc-pester.2026-11-18T01-05.md`). |
| **Rerun loop if needed** | ✅ PASS | The final pass is clean; earlier loops are recorded in the phase-gate evidence. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | The two manifest edits follow the existing two-space array style; `prettier --check "*.json"` passed for the extension scope. |
| **Schema validation** | ✅ PASS | The pack-manifest completeness, dependency-closure, and resource-contract pytest suites passed. |
| **Required $schema** | N/A | The pack manifests are not `$schema`-governed files. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Plain string entries; no comments or trailing commas. |
| **Deterministic key order** | N/A | Only array entries were added. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | The existing Python suites ran under `pytest -n auto`; no Python test was added (spec decision: the tuple entry is verified by the Pester parity suite). |
| **Coverage expectation** | ✅ PASS | Python total 97.74% lines and 95.15% branches in `artifacts/python/lcov.info` (reviewer parse); the CI result of `Enforce Python coverage thresholds` is recorded in `## CI Cross-check` as pending. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | N/A | No Python test was added. |
| **Mocking sparingly** | N/A | No Python test was added. |
| **Organization** | N/A | No Python test was added. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | N/A | No Python test was added. |
| **Docstrings/comments** | N/A | No Python test was added. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `pytest -n auto --cov --cov-branch`<br>**Result:** 16957 passed |
| **No Alternative Test Runners** | ✅ PASS | Only pytest. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe -ForEach`, `It -ForEach`, `BeforeDiscovery`, `Should -Invoke -Exactly`, `Should -BeExactly`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through `run-test-suite.sh pester`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `config/poshqc-coverage.json` (unchanged) |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | `#Requires -Version 7.0` on each suite. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 314 pure-unit, 44 seam/entry, 102 Claude decision, 102 Codex decision, 38 parity tests. |
| **Test Behavior Over Implementation** | ✅ PASS | Decision suites drive `Invoke-OrchestrationPreimplementationGateDecision` with a Bash or Write payload and assert the hook decision and full reason text. |
| **Mocking Used Sparingly** | ✅ PASS | Only I/O seams are mocked; the parser, classifier, decision, tokenizers, and suffix composition run for real. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1`<br>**Code file:** `.claude/hooks/hook-release-allowance-context.ps1`<br>Codex decisions live under `tests/scripts/codex-hooks/`, mirroring `.codex/hooks/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Five `*.Tests.ps1` files plus the shared `*.Cases.ps1` data file. |
| **Describe/Context/It Structure** | ✅ PASS | Surface-parameterized `Describe`; `Context` per seam; `It` per row. |
| **Logical Grouping** | ✅ PASS | Rows grouped by AC number in the cases file. |
| **Docstrings/Comments** | ✅ PASS | Comment-based help in each suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` (8 workers)<br>**Result:** 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Only Pester through PoshQC. |

---

## 5. Test Coverage Detail

### hook-release-allowance-context.ps1 (314 tests across both surface copies)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Parser rows for the example document and each AC-1 invalid row | Positive/Negative | 186-240, 109-184 | ✅ |
| Branch match rows (AC-2) | Positive/Negative | 242-259 | ✅ |
| Relevance and segment-shape rows | Positive/Negative/Edge Case | 261-408 | ✅ |
| Command decision rows | Positive/Negative | 410-495 | ✅ |

**Coverage:** 100% (171/171 per copy)

**Not covered:** None.

### enforce-orchestration-preimplementation-gate-release.ps1 (44 tests across both surface copies)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Config seam: absent, file, non-file, read failure | Positive/Error Handling | 45-65 | ✅ |
| Container seam: true and false | Positive | 67-83 | ✅ |
| Leg entry declines, config failures, catch path, call counts | Negative/Error Handling | 103-166 | ✅ |

**Coverage:** 100% (32/32 per copy)

**Not covered:** None.

### Gate wiring (204 decision tests and 38 parity tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `decides release-allowance row <Id>` (Claude, 102) | Positive/Negative | Claude gate 39, 437, 438 | ✅ |
| `decides release-allowance row <Id>` (Codex, 102) | Positive/Negative | Codex gate 35, 446, 447 | ✅ |
| Parity, wiring, manifest, exclusion, and documentation tokens (38) | Contract | n/a | ✅ |

**Coverage:** the three changed lines of each gate are covered.

**Not covered:** None of the changed lines.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 28105 Pester; 5717 Jest (root); 16963 pytest collected | ✅ |
| Tests Passed | 28087 Pester (99.94%, 18 skipped); 5717 Jest; 16957 pytest (6 skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 716.56 s Pester wall-clock; 23 s Jest root; 198.88 s pytest | ✅ Fast |
| Average Time per Test | About 35 ms for the 600 new Pester tests (21.3 s total) | ✅ Fast |
| Discovery Time | Included in the parallel shard times | ✅ |
| Functions/Classes Tested | 17/17 functions of the two new files (100%) | ✅ |
| Test File Size | 96 to 281 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 100% lines for both new files | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 1070 unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 16957 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | check-only formatter comparison on changed files | 0 drift | ✅ |
| PSScriptAnalyzer | repository settings on changed files | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 28087 passed, 0 failed | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check` | 0 findings | ✅ |
| ESLint | `npx eslint src test` | 0 findings | ✅ |
| TSC | `npx tsc --noEmit` (two configs) | 0 errors | ✅ |
| Jest | `node run-jest.cjs --coverage` (root) | 5717 passed | ✅ |

**Notes:**
The reviewer ran the root Jest gate once because the canonical root artifact `coverage/lcov.info` was absent at review start (the executor's Jest gate wrote its report to the scratch directory); the run is recorded in `evidence/qa-gates/jest-gate.2026-11-18T01-22.md`. No other gate was re-run. Architecture boundaries: no `.dependency-cruiser.cjs` exists, so that stage has no command.

---

## CI Cross-check

CI on PR #1202 was in progress at review time (concurrent review mode). The claimed outcomes below come from local evidence at the reviewed head; the orchestrator compares them with CI at the join.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| CI Required Gate | pass | CI status pending at review time | 89d0e58610eac3b66504ca2ba27a6d22a8f15312 | `evidence/qa-gates/final-qc-*.md`, `evidence/qa-gates/jest-gate.2026-11-18T01-22.md` |
| CI full run | pass | CI status pending at review time | 89d0e58610eac3b66504ca2ba27a6d22a8f15312 | `evidence/qa-gates/final-qc-pester.2026-11-18T01-05.md` |
| quality-checks7 / Code Quality & Tests (3.13) (Enforce Python coverage thresholds) | pass | 97.74% lines, 95.15% branches locally; CI pending | 89d0e58610eac3b66504ca2ba27a6d22a8f15312 | `artifacts/python/lcov.info`, `evidence/qa-gates/final-qc-pytest.2026-11-18T01-10.md` |

---

## Evidence Location Compliance

`git diff --name-only <merge-base>..HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no output. All branch evidence is under `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/evidence/<kind>/`. A scan of the feature folder for user-profile absolute paths returned no match.

## Rejected Scope Narrowing

None detected. The caller prompt sets the scope to the full branch diff against the merge base of `origin/main` and HEAD.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds files only under existing directories (`.claude/hooks`, `.codex/hooks`, bundle mirrors, `tests/`); no new project folder needs a tier entry.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None.** All policy requirements are met. Non-blocking observations are recorded in the code review (case-insensitive `-C` comparison on case-sensitive file systems, by design of AD-5).

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented. The 18 skipped Pester tests are pre-existing and outside the branch diff.

---

## 9. Summary of Changes

The branch lets a repository that commits `.claude/release-commit-allowance.json` have an agent stage and commit the listed release paths on a matching branch without an orchestration checkpoint, through a fail-closed, allow-side leg in both preimplementation gates, and keeps push-down from ever writing that file.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All evaluated policies are satisfied with numeric baseline and post-change coverage for PowerShell, TypeScript, and Python. CI on the PR head was pending at review time and is compared by the orchestrator at the join.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is absent.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: issue, spec, research, and plan present
- ✅ Design Principles: pure file plus seam file; existing helpers reused
- ✅ Module & File Structure: all files below 700 logical lines
- ✅ Naming, Docs, Comments: approved verbs, comment-based help
- ✅ Toolchain Execution: single clean final pass recorded
- ✅ Summarize & Document: six documentation surfaces and changelog updated

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright clean
- ✅ Python Design & Typing: one typed tuple entry
- ✅ Error Handling: no new control flow

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyzer clean
- ✅ PowerShell Design & Safety: advanced functions, fail-closed catch
- ✅ Structure & Naming: approved verbs, unique script-scope prefix
- ✅ Toolchain: Pester parallel run clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: table-driven, seam mocks only
- ✅ Coverage & Scenarios: 100% on new files, no regression
- ✅ Test Structure: exact-text assertions with row ids
- ✅ External Dependencies: no live git, no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: existing suites unchanged and passing
- ✅ Test Style & Structure: no new Python test (spec decision)
- ✅ Naming & Readability: no new Python test
- ✅ Toolchain: pytest parallel run clean

**For PowerShell:**
- ✅ Framework & Scope: Pester 6 features
- ✅ Test Style & Structure: behavior-level decision tables
- ✅ Naming & Readability: `*.Tests.ps1`, row ids
- ✅ Toolchain: PoshQC parallel run

---

### Metrics Summary

- ✅ 28087/28105 Pester tests passing (18 pre-existing skips), 5717/5717 Jest, 16957 pytest
- ✅ 17/17 functions of the new files tested (100%)
- ✅ 100% line coverage on both new PowerShell files; repo-wide PowerShell 96.08%
- ✅ Proper file organization: tests mirror `.claude/hooks` and `.codex/hooks`
- ✅ All code quality checks passing
- ✅ Test execution time: 21.3 seconds for the new Pester suites (fast)

---

### Recommendation

**Ready for merge** once CI on PR #1202 is green at the reviewed head (AC-31 is CI-dependent and is checked off at S9 by the item orchestrator).

---

## Appendix A: Test Inventory

### Complete Test List

1. `hook-release-allowance-context.Tests.ps1` › Describe per surface (Claude, Codex) › parser rows, branch-match rows, relevance rows, segment-shape rows, decision rows (314)
2. `enforce-orchestration-preimplementation-gate-release.Tests.ps1` › Describe per surface › interception probe (1), config seam (4), container seam (2), leg entry (15); 22 per surface, 44 total
3. `enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1` › baseline mock interception probe; `decides release-allowance row <Id>` for 101 rows (102)
4. `enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1` (Codex) › same rows through the Codex gate (102)
5. `hook-release-allowance-context.Parity.Tests.ps1` › byte identity, line bounds, gate wiring, manifests, absence, exclusion tuple, documentation tokens, no-Python (38)
6. `claude-customizations-release-allowance.test.ts` › EXCLUDED_RELATIVE_PATHS contains the path; destination unchanged with no packs; destination unchanged with core pack (3)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
env -u VIRTUAL_ENV poetry run black --check .
env -u VIRTUAL_ENV poetry run ruff check .
env -u VIRTUAL_ENV poetry run pyright
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch
```

**For PowerShell:**
```bash
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
```

**For TypeScript:**
```bash
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
npx eslint --no-error-on-unmatched-pattern src test
npx tsc -p ./ --noEmit
node run-jest.cjs --coverage
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-18  
**Policy Version:** Current (as of audit date)
