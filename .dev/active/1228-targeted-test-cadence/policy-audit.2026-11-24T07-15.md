# Policy Compliance Audit: targeted-test-cadence (#1228)

---

**Audit Date:** 2026-11-24  
**Code Under Test:** merge base `a4ebf96688106d9bcd0baf51d237a6b77c055560` of the base branch `origin/main` and reviewed head `731163ca96861582594fb861f370e5153cd76369` (branch `feature/targeted-test-cadence-1228`); the diff between them lists the changed files (227 files, +5735/-275).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 test files, 0 production files | 29348 tests (final QA full run) | ✅ 29330 pass, 0 fail, 18 skipped | 96.84% lines | 96.85% lines | 96.85% lines repo-wide (no PowerShell production file changed) |
| Python | 0 files | 17104 tests (final QA full run) | ✅ 17104 pass, 0 fail | 98.01% lines, 95.47% branches | 98.01% lines, 95.47% branches | N/A - zero changed Python files |
| TypeScript | 0 files | jest-extension and root jest (final QA) | ✅ 0 fail | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

The remaining changed files are Markdown (rules, skills, agents, prompts, instructions, plan templates, ledger, feature records) and TOML (generated Codex agents and variants). They have no coverage language.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files (executor baseline recorded at `.dev/active/1228-targeted-test-cadence/evidence/baseline/jest.2026-11-23T13-33.md`)
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files (executor final QA recorded at `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/jest.2026-11-24T06-58.md`)
- PowerShell baseline coverage artifact: `.dev/active/1228-targeted-test-cadence/evidence/baseline/pester.2026-11-23T13-26.md` (Phase 0 baseline, 96.84% lines)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (final QA full run, root LINE counter 47435 covered, 1541 missed) recorded in `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/pester.2026-11-24T06-30.md`
- Per-language comparison summary: section 1.2.1 of this audit

Baseline coverage is read from the plan's `Phase 0 baseline` artifact, one run of the language's gate.

**CI-proven checks:** Format, lint, and type-check results are read from the final-QC static artifact of each language and are not re-run during the review. Each CI check the review relies on is recorded in `## CI Cross-check`.

---

## Executive Summary

The branch rewrites the test-cadence policy text on every harness surface so that the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, and every other orchestration test run (phase gate, remediation gate, sync check, review coverage re-run) uses a test selection. It changes two Pester contract test files, regenerates generated outputs and Codex variants, hand-copies bundles, and adds process-reduction ledger entry `0014` with a stored patch.

Mechanical delivery is sound: generators report no drift (reviewer re-ran both `-Check` modes and the Codex `--check`, all exit 0), every changed `.claude`, `.agents`, `.codex`, `.github`, and `.dev/templates` file is byte-identical to its bundle copy, `AGENTS.md` matches its bundle byte for byte, and a reviewer launcher run of the seven pinned contract suites passed 430 of 430 tests.

Two blocking policy-consistency defects remain. Both are introduced by the new selection cadence and leave unchanged text that contradicts it:

- F1: the three QA-gate skills now apply to a remediation gate whose test step runs a selection, but their unchanged `Overall coverage delta` rule and `Do not report success based on partial or targeted runs` prohibition make that gate unsatisfiable as written.
- F2: the feature-review coverage step now re-runs coverage over a selection, but the unchanged Python sentence of the skill, the unchanged `feature-review` agent procedure (repo-wide figure parsed from the local artifact; "does NOT rerun coverage generation"), and the unchanged policy-audit template sentence read a selection-only artifact as a repo-wide FAIL. The reviewer's own selection run produced a repo-wide PowerShell figure of 1.87% (917 of 48976 lines), which the unchanged agent procedure grades FAIL.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (zero changed Python files)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (two changed Pester test files)
- N/A Bash: shfmt + shellcheck + bats (zero changed shell files)
- N/A JSON: format_json + validate_json (zero changed JSON files)

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; the executor's helper scripts live under the gitignored `artifacts/issue-1228/` and the session scratch folder.
- ✅ No new tooling script is added to the repository.
- Reviewer scratch files (selection-run launcher and report copies) are in the session scratchpad and are not in the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The new rows read repository files and in-memory text only; they share no state. The reviewer launcher run sharded the seven suites across 7 parallel processes with 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each `TCW-*` row checks one heading of one file for its required and forbidden tokens; `TCW-CADENCE-SWEEP-HELPER` isolates the token matcher from file I/O. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 430 selected tests ran in 16.46 s of test time (176.67 s wall clock including shard start-up). |
| **Determinism** - Consistent results | ✅ PASS | Inputs are committed files and literal strings; no clock, random, or network use. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row IDs (`TCW-HANDOFF-*`, `TCW-ENGINEER-*`, `TCW-REVIEW-*`, `TCW-SCOPED-*`, `TCW-CADENCE-SWEEP-*`) and issue comments state each row's purpose. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 96.84% lines (PowerShell), read from the `Phase 0 baseline` artifact<br>**Command:** `Invoke-PoshQCParallelTest` through the launcher `pester` suite (one run of the gate)<br>**Artifact:** `.dev/active/1228-targeted-test-cadence/evidence/baseline/pester.2026-11-23T13-26.md`<br>**Timestamp:** 2026-11-23 13:26 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.85% lines (PowerShell), read from the single gate run<br>**Change:** +0.01% lines against the `Phase 0 baseline`<br>**Status:** No regression |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** no production file changed in any coverage language; the two changed files are Pester test files, which are not in the coverage population<br>**Thresholds:** 85% line (default; root `CLAUDE.md` states none), branch threshold not applicable to PowerShell<br>**Status:** No changed production file below a threshold |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** no production code; tests only<br>**New code coverage:** 96.85% repo-wide PowerShell lines<br>**Calculation method:** root LINE counter of the final QA `powershell-coverage.xml` |
| **Comprehensive Coverage** | ✅ PASS | The new rows cover every edited surface family named by AC-01 to AC-10: canonical section, remediation handoff, typed engineers (42 rows), review workflow, scoped Pester runs, QA-gate skills, brief, and the cadence sweep with its helper. |
| **Positive Flows** - Valid inputs | ✅ PASS | Required-token rows pass on the edited files. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Forbidden-token lists (`CadenceSweepToken`, the old QA-gate literal) fail a file that still carries removed wording. |
| **Edge Cases** - Boundary conditions | ✅ PASS | The sweep normalises whitespace before matching, so a phrase split across lines is still found; the exclusion list uses ordinal suffix matching so bundle copies of excluded files are also excluded. |
| **Error Handling** - Error paths | ✅ PASS | `TCW-CADENCE-SWEEP-HELPER` proves the matcher reports each planted token (upper-cased in prose). |
| **Concurrency** - If applicable | N/A | Contract tests read files only. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.84% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.85% lines. Change: +0.01% lines. New/changed-code coverage: 96.85% lines repo-wide; no PowerShell production file changed. Disposition: PASS. Evidence: `.dev/active/1228-targeted-test-cadence/evidence/baseline/pester.2026-11-23T13-26.md`, `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/pester.2026-11-24T06-30.md`, `artifacts/pester/powershell-coverage.xml` (root LINE counter 47435 covered, 1541 missed, recomputed by the reviewer).
- Python: Baseline: 98.01% lines, 95.47% branches -> Post-change: 98.01% lines, 95.47% branches. Change: +0.00% lines. New/changed-code coverage: N/A - zero changed Python files. Disposition: N/A. Evidence: `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/pytest.2026-11-24T06-43.md`.
- TypeScript: Baseline: N/A - zero changed TypeScript files -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A - zero changed TypeScript files. Disposition: N/A. Evidence: `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/jest.2026-11-24T06-58.md`.

Coverage freshness: the final QA PowerShell report was written at 2026-11-24T06:29:17Z and the reduction commit `731163ca9` was committed at 2026-11-24T07:04:36Z. Content equivalence was proved: the worktree is clean, and the two changed `.ps1` files were last modified at 2026-11-24T04:34:58Z and 2026-11-23T14:21:27Z, both before the report. The reviewer ran a selection launcher run (see section 7), snapshotted the full-run `powershell-coverage.xml` and `pester-junit.xml` before it, and restored both byte-identically afterwards (SHA-256 prefix `2adad1d3e05f83de` before and after), which gives the restored report a write time after the commit. The figures above are the full-run figures.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Each assertion carries `-Because` text naming the rule (for example "the full suite runs only at the Phase 0 baseline and in the final QA loop") and reports offending file and token pairs. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | The two new `It` blocks carry `# Arrange`, `# Act`, `# Assert` comments. |
| **Document Intent** | ✅ PASS | Issue #1228 comments precede each new row group. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Repository files only; no network or process calls. |
| **Use Mocks/Stubs** | N/A | No seam needed for read-only contract tests. |
| **Environment Stability** | ✅ PASS | Paths resolve from `$script:RepoRoot`; no temporary files are created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the required review; findings F1 and F2 are open. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Owner objective quoted verbatim in `spec.md` and ledger entry `0014`. |
| **Read existing change plans** | ✅ PASS | Research record `research/research.2026-11-23T12-00.md` inventories every surface and pinned test. |
| **Document the plan** | ✅ PASS | `plan.2026-11-23T06-50.md`, all tasks checked with task-check evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One reference sentence (R1) replaces each restatement and points to the canonical section. |
| **Reusability** | ✅ PASS | The phase-gate form is reused for the remediation gate and the sync check. |
| **Extensibility** | ✅ PASS | The canonical section remains the single definition. |
| **Separation of concerns** | ❌ FAIL | The new cadence is not carried into three dependent contracts (QA-gate delta rules, feature-review repo-wide source, policy-audit template); see F1 and F2. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Test changes stay inside the existing wording suites. |
| **At or below the 800-line hard limit** | ✅ PASS | `test-cadence-wording.Tests.ps1` 629 logical lines; `regeneration-path-skill-contract.Tests.ps1` 350 logical lines. Neither is at or above 700. `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | N/A | No public API. |
| **No circular dependencies** | N/A | No module imports changed. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `$script:CanonicalSelectionToken`, `$script:CadenceSweepToken`, `$script:CadenceSweepExclusion`. |
| **Docs/docstrings** | ✅ PASS | Issue and decision references in comments. |
| **Comment why, not what** | ✅ PASS | Comments cite D5, D10, PD2, PD5. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root <worktree>`<br>**Result:** 1879 files, 0 reformatted (final-QC static artifact `powershell-static.2026-11-24T06-02.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root <worktree>`<br>**Result:** 0 findings |
| **3. Type checking** | N/A | Not applicable for PowerShell; Pyright 0 errors repo-wide (`python-static.2026-11-24T06-07.md`). |
| **4. Testing** | ✅ PASS | **Command:** launcher `pester` suite (full), launcher `pytest` suite (full), launcher Jest suites<br>**Result:** 0 failures in each final QA run |
| **Full toolchain loop** | ✅ PASS | Final QC completed in one pass per the qa-gates artifacts. |
| **Explicit reporting** | ✅ PASS | Commands and exit codes are recorded in each evidence file. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Ledger `0014` `## Summary`. |
| **Design choices explained** | ✅ PASS | `spec.md` D1 to D10. |
| **Update supporting documents** | ⚠️ PARTIAL | The `feature-review` agent source, its generated copies, and the policy-audit template were not updated (F2). |
| **Provide next steps** | ✅ PASS | This audit names the remediation. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .`<br>**Result:** 0 reformatted; porcelain identical before and after |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** 0 findings; per-file check of both changed tests also 0 |
| **Fix all findings** | ✅ PASS | No findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Repository targets PowerShell 7+; `[System.IO.Path]::GetRelativePath` was already used in the file. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | N/A | Test files; no new function. |
| **Parameter validation** | N/A | Test files. |
| **Avoid global state** | ✅ PASS | Discovery data is held in `$script:` variables in `BeforeDiscovery`, as in the existing rows. |
| **Error handling** | ✅ PASS | File reads fail the row on error. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 629 and 350 logical lines. |
| **Approved verbs** | N/A | No new function. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Final-QC static artifact. |
| **Step 2: Analyze** | ✅ PASS | Final-QC static artifact. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Full Pester final QA 0 failures; reviewer selection run 430 tests, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | One clean pass recorded. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`/`It -ForEach`, `Should -Be`, `Should -BeNullOrEmpty`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through the launcher<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, unchanged |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7 target. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One heading or one sweep per row. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows pin policy statements, the intended contract. |
| **Mocking Used Sparingly** | ✅ PASS | No mocks. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`<br>**Code file:** Markdown surfaces under `.claude/`, `.agents/`, `.codex/`, `.github/`<br>Existing contract-suite location retained. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Both files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | New rows join the existing `Describe 'Test cadence wording'`. |
| **Logical Grouping** | ✅ PASS | Row groups per surface family. |
| **Docstrings/Comments** | ✅ PASS | Issue comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <7 suites>`<br>**Result:** 430 tests, 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Launcher only. |

---

## 5. Test Coverage Detail

### test-cadence-wording.Tests.ps1 new rows (reviewer selection run)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `TCW-CANONICAL-*` (9) | Positive and negative tokens | canonical section | ✅ |
| `TCW-HANDOFF-*` (4), `TCW-REVIEW-*` (4), `TCW-SCOPED-*` (4) | Positive | named sections | ✅ |
| `TCW-ENGINEER-*` (42) | Positive | typed-engineer `## Workflow` | ✅ |
| `TCW-QAGATE-*` (14) | Positive and negative | `## When to Use This Skill` | ✅ |
| `TCW-CADENCE-SWEEP-SURFACES`, `TCW-CADENCE-SWEEP-HELPER` | Negative and error path | all swept surfaces | ✅ |
| `RSC-REGENERATE` (2) | Positive | orchestrate item 5 | ✅ |

**Coverage:** test files; no production line coverage applies.

**Not covered:** no row pins the QA-gate delta and prohibition clauses or the feature-review repo-wide source against the new cadence (F1, F2).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 29348 (final QA Pester), 430 (reviewer selection) | ✅ |
| Tests Passed | 29330 and 430 | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 762.97 s final QA; 176.67 s reviewer selection | ✅ |
| Average Time per Test | about 38 ms (selection, 16.46 s test time) | ✅ |
| Discovery Time | included in shard start-up | ✅ |
| Functions/Classes Tested | not applicable to Markdown contracts | ✅ |
| Test File Size | 629 and 350 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 96.85% PowerShell lines repo-wide | ✅ |

---

## 7. Code Quality Checks

**For Python:** zero changed Python files; final-QC figures are recorded for the CI cross-check.

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 1071 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | launcher `pytest` suite (`poetry run pytest -n auto`) | 17104 passed, 0 failed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | 0 reformatted | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | 0 findings | ✅ |
| Pester Tests | launcher `pester` suite (`Invoke-PoshQCParallelTest`) | 29348 tests, 0 failed | ✅ |

**Reviewer-run checks (2026-11-24, item worktree, head `731163ca9`):**

- `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`: exit 0, "harness-generation: no drift".
- The same with `-Surface instructions -Check`: exit 0, no drift.
- `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`: exit 0.
- `cmp AGENTS.md extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md`: exit 0.
- Byte comparison of every changed `.claude`, `.agents`, `.codex`, `.github`, and `.dev/templates` path with its bundle copy: no difference, no absent bundle.
- `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath` with `test-cadence-wording`, `regeneration-path-skill-contract`, `parallel-gate-wording`, `less-evidence-contract`, `ProcessReductionChain.Ledger`, `ProcessReductionLedger.Index`, and `HarnessGeneration.RepoGate` suites: attempt 1 exit 75 (queue timeout, lock held by another worktree), attempt 2 exit 0, 430 tests, 0 failures. Its merged coverage report showed 917 covered and 48059 missed lines (1.87%), a selection-only figure; this is the F2 evidence. The full-run reports were restored afterwards as described in 1.2.1.
- A launcher `pytest` selection of the push-down and frozen-surface suites exited 75 (queue timeout, lock held by another worktree) and did not run; those results are taken from the executor's final QA pytest run (17104 passed).
- `git apply -R --check` of `patches/0014-targeted-test-cadence.patch` on the live tree reports only the three `docs/features/templates/` paths as absent, which the entry documents (the chain maps them to `.dev/templates/`); `ProcessReductionChain.Ledger.Tests.ps1` passed in the selection run.

**Notes:** No pre-existing failure was observed.

---

## CI Cross-check

No pull request exists for the branch and no CI run is recorded for head `731163ca9`; the orchestrator's S9 CI green gate compares these claims with CI on the PR head.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static (format, analyze) | pass | 0 reformatted, 0 findings | 731163ca9 | `evidence/qa-gates/powershell-static.2026-11-24T06-02.md` |
| poshqc / Pester tests | pass | 29348 tests, 0 failed, 96.85% lines | 731163ca9 | `evidence/qa-gates/pester.2026-11-24T06-30.md` |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 17104 passed; 98.01% lines, 95.47% branches | 731163ca9 | `evidence/qa-gates/pytest.2026-11-24T06-43.md`, `evidence/qa-gates/python-static.2026-11-24T06-07.md` |
| Enforce Python coverage thresholds | pass | 98.01% lines, 95.47% branches | 731163ca9 | `evidence/qa-gates/pytest.2026-11-24T06-43.md` |
| Harness generation drift check | pass | no drift (both modes) | 731163ca9 | reviewer run, section 7 |

---

## Evidence Location Compliance

- `validate_evidence_locations.py --root <item worktree>`: exit 0.
- The branch diff adds no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All item evidence is under `.dev/active/1228-targeted-test-cadence/evidence/<kind>/`.

## Additional Policy Checks

- `modified-workflow-needs-green-run`: not triggered; no path under `.github/workflows/`, `.github/actions/`, or `scripts/benchmarks/` changed.
- Documentation surface check: not applicable; `docs/documentation-estate/docs-profile.json` is absent on the branch head.
- Tier classification: `quality-tiers.yml` exists on the base; the branch adds no project or library folder, so no classification change is required.
- Coverage exclusions: no `exclude`, `omit`, `coveragePathIgnorePatterns`, or settings-file coverage path changed; `.push-down-manifest.json` unchanged.
- Process-reduction ledger: entry `0014` and its stored patch are present with a README index row; the commit `731163ca9` subject carries `reduction: 0014`. Part of the reduction landed earlier in `242d160fd` ("wip(harness): pause #1228 targeted test cadence mid-execution", 141 files) without the token or the entry. This follows the repository's owner-requested pause-checkpoint practice (for example `4b2454e46` on issue 1016), the entry's stored patch covers the full delta from the merge base, and the entry states this derivation, so it is recorded as an Info item, not a finding.

## Rejected Scope Narrowing

None. The delegation prompt did not narrow scope.

---

## 8. Gaps and Exceptions

### Identified Gaps

- F1 (Blocking): QA-gate skills apply to the remediation gate, whose test step is a selection, but keep `Overall coverage delta` and the prohibition on partial or targeted runs. Files: `.claude/skills/{python,powershell,csharp}-qa-gate/SKILL.md`, the `.agents` copies, bundles, and csharp-legacy variants.
- F2 (Blocking): repo-wide coverage source. The new D3 text of `feature-review-workflow` step 5 keeps the sentence "a local artifact that shows the Python total below a threshold is still FAIL"; `scripts/harness-generation/sources/agents/feature-review.md` (both halves) and its generated `.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, and bundles still parse the repo-wide figure from the local artifact, grade it FAIL, and state "The agent does NOT rerun coverage generation"; `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` 4A.1 and its bundle keep the same Python sentence.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented.

---

## 9. Summary of Changes

The branch limits full-suite test runs in orchestrations to the `Phase 0 baseline` and the final QA loop on every harness surface, pins the new wording with contract tests, and records the change as process reduction `0014`.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain, coverage, parity, generator, ledger, and evidence checks pass. Two blocking policy-consistency findings (F1, F2) remain: dependent contracts still require full-suite figures from runs that the new cadence makes selection-only.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: research, spec, and plan present
- ⚠️ Design Principles: dependent contracts not updated (F1, F2)
- ✅ Module & File Structure: within limits
- ✅ Naming, Docs, Comments: clear
- ✅ Toolchain Execution: clean final QC
- ⚠️ Summarize & Document: feature-review agent and template not updated

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: test-only change
- ✅ Structure & Naming: clean
- ✅ Toolchain: clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: met
- ✅ Coverage & Scenarios: no regression
- ✅ Test Structure: AAA and messages present
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester through PoshQC
- ✅ Test Style & Structure: focused rows
- ✅ Naming & Readability: clear
- ✅ Toolchain: launcher only

---

### Metrics Summary

- ✅ 29348/29348 executed Pester tests without failure in the final QA run (18 skipped)
- ✅ 430/430 selected contract tests passing in the reviewer run
- ✅ 96.85% PowerShell line coverage repo-wide (baseline 96.84%)
- ✅ All code quality checks passing
- ✅ Bundle parity and generator drift checks clean

---

### Recommendation

**Needs revision**

Address F1 and F2 in one remediation cycle (full path; design scope across the QA-gate skills, the feature-review agent source and its generated copies, the feature-review skill, and the policy-audit template), with contract-test rows that pin the corrected wording and extend ledger entry `0014`.

---

## Appendix A: Test Inventory

### Complete Test List

- Test cadence wording › `TCW-CANONICAL-*`, `TCW-CANONICAL-REF-*`, `TCW-CANONICAL-DISCRIMINATES`
- Test cadence wording › `TCW-HANDOFF-CLAUDE`, `TCW-HANDOFF-AGENTS`
- Test cadence wording › `TCW-ENGINEER-<language>-<surface>` (42 rows)
- Test cadence wording › `TCW-REVIEW-*`, `TCW-SCOPED-*`, `TCW-BRIEF-*`, `TCW-QAGATE-*`
- Test cadence wording › `TCW-CADENCE-SWEEP-SURFACES`, `TCW-CADENCE-SWEEP-HELPER`
- Regeneration path skill contract › `RSC-REGENERATE`

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing (selection through the launcher)
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1

# Generators
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface instructions -Check
```

**For Python:**
```bash
env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-24  
**Policy Version:** Current (as of audit date)
