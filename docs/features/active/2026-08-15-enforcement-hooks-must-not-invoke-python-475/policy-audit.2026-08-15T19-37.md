# Policy Compliance Audit: enforcement-hooks-must-not-invoke-python (#475)

**Audit Date:** 2026-08-15
**Code Under Test:** 119 changed files vs `main` (merge-base `b1a86fd3`, head `116a56fb`): 3 modified `.claude/hooks/*.ps1`, 2 modified + 12 new `.claude/lib/**/*.psm1`, 17 bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/**`, `pack-manifests/core.json`, 2 `pester.runsettings.psd1` (repo + bundled mirror), 34 PowerShell test files (new and modified) under `tests/scripts/**`, and 54 Markdown scoping/evidence documents. Zero `.py`, `.ts`, or `.cs` files changed.

**Template source:** bundled MCP template asset content read from `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, the identical asset served by `resolve_policy_audit_template_asset` (selector `template`). The MCP tool surface was not available in this review session, so the bundled asset file was read directly; the content is the authoritative asset, not a divergent copy.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 64 files (.ps1/.psm1/.psd1) | 2740 tests | PASS 2740 pass, 0 fail | 94.85% lines (4019/4237) | 95.92% lines (5098/5315) | 99.31% (1008/1015 new-module lines); 100% (10/10 changed seam-body lines) |
| JSON | 1 file (core.json) | 46 contract assertions | PASS validation | N/A (config file) | N/A (config file) | N/A |

Python, TypeScript, and C# rows are omitted because those languages have zero changed files in the branch diff (verified: `git diff --name-only main...HEAD` contains no `.py`, `.ts`, or `.cs` paths). For reference only, the executor's evidence records repo-wide Python coverage byte-identical to baseline at 92.30% line / 84.66% branch, both above floors.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed)
- PowerShell baseline coverage artifact: docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml (final run, independently re-parsed by this review), summarized in evidence/qa-gates/phase16-final-poshqc-test.2026-08-15T19-10.md and evidence/qa-gates/coverage-delta.2026-08-15T19-18.md
- Per-language comparison summary: section 1.2.1 below

**Non-negotiable verdict rule:** This audit reports numeric baseline and post-change coverage for the single language in scope (PowerShell) plus new-code and changed-code coverage.

**Fail-closed rule acknowledged:** all required baseline, QA, and coverage-comparison artifacts were located and inspected; none is absent.

**Evidence rule acknowledged:** every number in this audit was either re-derived by this review (coverage XML parse, test executions, byte comparisons) or read from a named evidence artifact; nothing was synthesized.

---

## Rejected Scope Narrowing

None detected. The caller's delegation prompt instructed a full feature-vs-base audit of the entire branch diff (119 files) against `main` and did not attempt to narrow scope to a plan subset, a file subset, or to mark any language's coverage as out of scope. This audit's scope is the full branch diff `b1a86fd3..116a56fb`.

---

## Evidence Location Compliance

Scan performed by this review:

- Command: `python scripts/dev_tools/validate_evidence_locations.py --root .` — EXIT_CODE 0, zero violations.
- Command: `git diff --name-only main...HEAD | grep -E '^artifacts/(baselines|baseline|qa|qa-gates|evidence|coverage|regression-testing|post-change)/'` — zero matches.

All evidence artifacts in the branch diff live under the canonical `docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/<kind>/` scheme (`baseline/`, `qa-gates/`, `regression-testing/`, `other/`). No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events were required.

---

## Executive Summary

This branch removes every Python invocation from the enforcement-hook surface (`.claude/hooks/**`, `.claude/lib/**`), ports the orchestrator-state completion validator to PowerShell at complete parity with the 85-row Python check inventory, adds an AST-based structural guard preventing reintroduction, fixes defect D-1 (epic/parallel checkpoints unconditionally blocked), avoids latent defect D-2 (discovery success output false-deny), and mirrors all changes byte-identically into the pushed-down bundle.

The audit finds the change compliant. All independently re-verified checks pass: the guard suite (27/27 including both repository-scan assertions), the full `claude-lib` + `claude-hooks` Pester trees (1677/1677), per-file line coverage floors (lowest changed/new file 91.38%, floor 85%), mirror byte-identity (17/17), manifest registration (12/12 modules), the 500-line cap (0 files over), the six incidental hooks (byte-unchanged), and `.claude/settings.json` (unchanged). The deletions in the two gate files were audited line by line: every removed line is a Python-leg removal, doc-comment removal, or refactor into a new parity module; zero check rows, error-string templates, or thresholds were removed or weakened. Error-string spot-checks between the Python validators and the PowerShell ports matched exactly.

**Policy documents evaluated:**
- PASS `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- PASS `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- PASS `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` — zero Python files changed
- N/A Bash — zero Bash files changed (`.claude/lib/bash/**` untouched, guard-excluded by design)
- PASS JSON — `core.json` change validated by the 46 pytest contract assertions (`test_push_down_claude_resource_contracts.py`)

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts remain in the branch diff; the executor's one-off scan scripts were run from the session scratchpad and are not in the tree.
- PASS Ongoing tooling additions (guard suite, parity suites, discovery module) are fully tested and registered in coverage targets.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | This review executed `tests/scripts/claude-lib` + `tests/scripts/claude-hooks` in a fresh Pester run (1677/1677 pass) and the guard suite standalone (27/27), independent of the executor's full-suite ordering. |
| **Isolation** - Each test targets single behavior | PASS | Row-ID-keyed `It` names (`U5.2 reports each missing receipt key by name`, `C6.10 reports a non-empty local_execution_overrides with the emptiness variant`) each assert one inventory row's behavior. |
| **Fast Execution** - Tests complete quickly | PASS | Full suite 2740 tests in 101.6s (junit header); this review's 1677-test subset completed in under 3 minutes; guard suite 1.65s. |
| **Determinism** - Consistent results | PASS | SD-3 prohibits PATH mutation, live `python` probes, and shadow functions; verified by the final-constraint-sweep clause (a) and by absence of `$env:PATH` writes in new test files. Fixtures are in-memory JSON strings; the config-parity test reads the repo config at test time only. |
| **Readability & Maintainability** - Clear structure | PASS | Describe/Context/It structure throughout; oracle-intent headers on parity suites; helper file documents its two carve-outs and residual gap. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline 94.85% lines (4019/4237), 52 files analyzed. Command: `mcp__drm-copilot__run_poshqc_test` with repo settings. Recorded in `evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md` before changes. |
| **No Coverage Regression** | PASS | Post-change 95.92% lines (5098/5315), +1.07 pts vs baseline; zero files regressed vs the intermediate `[P15-T3]` state; both discovery hooks exceed their own pre-change baselines (91.38% vs 87.27%; 91.80% vs 87.93%). Independently re-parsed from `artifacts/pester/powershell-coverage.xml` by this review. |
| **New Code Coverage >= 90%** | PASS | Twelve new modules aggregate 99.31% (1008/1015); lowest single new file `DiscoveryValidation.psm1` at 94.44%. Changed seam-body lines in the two discovery hooks: 10/10 = 100%. |
| **Comprehensive Coverage** | PASS | 85/85 parity inventory rows each map to an implementing function and at least one failing fixture asserting the exact error string, plus passing fixtures per family (`evidence/other/parity-coverage.2026-08-15T18-30.md`, spot-checked by this review against test files and module sources). |
| **Positive Flows** - Valid inputs | PASS | Passing fixtures per family (e.g., `passes a well-formed list-form receipt`, `passes a receipt that matches the resolver exactly`, hook-level allow-verdict tests). |
| **Negative Flows** - Invalid inputs | PASS | One failing fixture per inventory row (85 rows); guard detection fixtures for all four detection classes; unsupported-artifact-type fail-closed test. |
| **Edge Cases** - Boundary conditions | PASS | Boolean-vs-integer rejection (`U6.T6`), truthy-vs-true (`U6.R4`), null-vs-absent (`U5.2` presence semantics), whitespace-only strings (`U6.C7`, `U6.H5`), Python `repr()`/None rendering fixtures. |
| **Error Handling** - Error paths | PASS | Fail-closed fixtures for missing file, invalid JSON, non-object root across preflight, completion, structural dispatch, and discovery legs; version-floor fail-closed tests (13). |
| **Concurrency** - If applicable | N/A | No concurrent code paths in scope; hooks are single-process validators. |
| **State Transitions** - If applicable | N/A | Validators are stateless over checkpoint input; no stateful component added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.85% lines -> Post-change: 95.92% lines. Change: +1.07% lines. New/changed-code coverage: 99.31% (new modules), 100% (changed seam-body lines). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (re-parsed by this review), `evidence/qa-gates/coverage-delta.2026-08-15T19-18.md`, `evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md`. PowerShell branch coverage is not emitted by the Pester 5 JaCoCo exporter (verified by this review: zero `BRANCH` counters in the coverage XML, a condition equally true of the baseline artifact); the 75% branch floor is therefore not evaluable by the repository's PowerShell toolchain for any branch, which is a pre-existing instrument limitation recorded in section 8, not a waiver introduced by this change.
- TypeScript: N/A - out of scope (zero changed files). Disposition: N/A.
- Python: N/A - out of scope (zero changed files; repo-wide values recorded in evidence remain above floors at 92.30% line / 84.66% branch). Disposition: N/A.
- C#: N/A - out of scope (zero changed files). Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Exact-string assertions against inventory error templates give precise diffs on failure; repository-scan `It` carries the finding list in `-Because`. |
| **Arrange-Act-Assert Pattern** | PASS | Fixtures arrange in-memory JSON, act through the public entry function, assert on `ExitCode`/`Output`/error lists; verified in sampled suites (`OrchestratorStateCompletion.Tests.ps1`, dispatch tests). |
| **Document Intent** | PASS | Row-ID prefixes tie tests to inventory rows; suite headers state the bash-migration oracle intent (verified in `OrchestratorStateReceipts.Tests.ps1`, `CodexDeployment.Parity.Tests.ps1`). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or live-executable dependencies; the discovery schema fixtures are read-only repo files; SD-3 bans live `python` probes and PATH manipulation. |
| **Use Mocks/Stubs** | PASS | Seam mocks only (`Invoke-DiscoveryValidatorExe`, `$Invoker` scriptblocks, `Test-Path` with a literal-path `-ParameterFilter`); the 15 pinned `Mock` registrations and 11 `Should -Invoke` assertions survive unmodified per AC-5. |
| **Environment Stability** | PASS | No temporary files (constraint-sweep clause; in-memory document strings used throughout); version-floor tests use an injectable version seam instead of mutating `$PSVersionTable`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit, together with `code-review.2026-08-15T19-37.md` and `feature-audit.2026-08-15T19-37.md`, constitutes the required pre-PR policy review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #475, `issue.md` (work mode `full-feature`), owner directive of 2026-08-15, HI-1 resolution recorded in spec and checkpoint. |
| **Read existing change plans** | PASS | Two research artifacts under `research/`; plan `plan.2026-08-15T12-47.md` (revision 9, 17 phases, 109/109 tasks checked). |
| **Document the plan** | PASS | Plan and spec are in the branch; the checkpoint records binding scope decisions (SD-1..SD-3, PD-1..PD-3, HI-1, LEO-1). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The default invokers collapse from probe-plus-two-legs to a single portable path; the structural check reuses `Get-OrchestratorStateCheckpoint` rather than duplicating the load contract (`validate-orchestrator-output.ps1:186-190`). |
| **Reusability** | PASS | One shared discovery-validation module replaces two duplicated seam bodies; U6.C5/U6.M4 wire to the single existing `Get-ComplexityFloor`/`Resolve-DelegationModel` formulas; the M3 gate reuses the per-entry validators (PD-2). |
| **Extensibility** | PASS | `[scriptblock] $Invoker` seams retained on both gates; `$ArtifactType` dispatch fails closed on unknown types so new types must be wired deliberately. |
| **Separation of concerns** | PASS | Check families decomposed into 12 cohesive modules (receipts, model receipts, codex receipts, routing matrix, routing contract, completion checks, unconditional aggregation); hooks carry wiring only. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Each new module owns one check family; the routing-matrix constants module isolates PD-1. |
| **Under 500 lines** | PASS | Verified by this review across all changed `.ps1/.psm1/.psd1`: zero files exceed 500 lines (largest are exactly 500: `DiscoveryValidation.psm1`, guard helper, guard suite). |
| **Public vs internal** | PASS | Modules export only their `Get-*Error`/`Test-*`/`Resolve-*` entry points; internal helpers are unexported. |
| **No circular dependencies** | PASS | Dependency direction is hooks -> orchestrator-state modules -> model-routing/codex-routing leaf modules; no cycles observed in the import graph. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Approved-verb function names (`Get-`, `Test-`, `Resolve-`, `Invoke-`); analyzer pass with zero findings confirms verb compliance. |
| **Docs/docstrings** | PASS | Comment-based help on public functions; PD-3 rationale documented at the dispatch site; version floor documented in module header and help (AC-18/AC-27). |
| **Comment why, not what** | PASS | Comments record rationale (why pinned constants, why the import-guard avoids reloading a mocked module, why the structural check omits `REQUIRED_STATE_KEYS`). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` (repo-wide)<br>**Result:** 0 files changed (`evidence/qa-gates/phase16-final-poshqc-format.2026-08-15T19-02.md`; prior clean pass at 18-21). |
| **2. Linting** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze` (repo settings, full scan set)<br>**Result:** 0 findings (`evidence/qa-gates/phase16-final-poshqc-analyze.2026-08-15T19-05.md`). |
| **3. Type checking** | N/A | Not applicable for PowerShell. Python-side `poetry run pyright` also clean (0 errors) though no Python changed. |
| **4. Testing** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` (repo settings)<br>**Result:** 2740 tests, 0 failures (junit header verified by this review); independent re-run of `claude-lib` + `claude-hooks` trees by this review: 1677/1677. |
| **Full toolchain loop** | PASS | Final Phase 16 loop ran format -> analyze -> test in one clean pass after the comment-only correction restart documented in `discovery-hook-coverage-remediation.2026-08-15T19-01.md`. |
| **Explicit reporting** | PASS | Every stage has a schema-conforming evidence artifact with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Single conventional commit `116a56fb fix(claude-hooks): remove Python invocations from enforcement-hook surface`; spec Overview and Implementation Strategy describe the delta. |
| **Design choices explained** | PASS | Decision Record (language selection, HI-1), PD-1/PD-2/PD-3 rationales, D-2 avoidance rationale, version-floor adoption rationale — all recorded in `spec.md`. |
| **Update supporting documents** | PASS | New potential entry `docs/features/potential/2026-08-15-portable-hook-validation-residuals.md`; original potential file moved to `promoted/`. |
| **Provide next steps** | PASS | Recorded stop condition: no PR from this run; the parent session rebases onto `main` before PR authoring. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_format`<br>**Result:** 0 files changed on the final tree. |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`<br>**Result:** 0 findings. |
| **Fix all findings** | PASS | Zero findings outstanding; no analyzer debt introduced. |
| **PowerShell 7+ compatible** | PASS with documented floor | The discovery-validation module raises an explicit destination floor to 7.4+ for `Test-Json -SchemaFile` Draft 2020-12, enforced fail-closed at runtime with an actionable message naming #475 (AC-26); this is a deliberate owner-directed floor, documented in the module header, help text, and potential entry. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]`, `[OutputType()]`, and mandatory-parameter attributes on the new public functions (verified in `validate-orchestrator-output.ps1`, `DiscoveryValidation.psm1`, receipt modules). |
| **Parameter validation** | PASS | `[Parameter(Mandatory = $true)]` on required inputs; typed `[scriptblock]` seam parameters. |
| **Avoid global state** | PASS | Script-scoped constants are read-only pinned data (`$script:COMPLETION_EMPTY_LIST_KEYS`, routing matrix); no mutable global state; no validation-time disk read of `config/orchestration-routing.json` (PD-1). |
| **Error handling** | PASS | Fail-closed everywhere: load errors, non-object roots, unsupported artifact types, and sub-7.4 hosts all yield deny verdicts with explicit messages; no silent catch-alls observed in the diff. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | All changed PowerShell files at or under 500 lines (three at exactly 500; flagged as at-cap in the code review, not a violation). |
| **Approved verbs** | PASS | `Get-`, `Test-`, `Resolve-`, `Invoke-` throughout; analyzer clean. |
| **Comment why** | PASS | Rationale-focused comments at dispatch, import-guard, and pinned-constant sites. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Clean pass, 0 changes. |
| **Step 2: Analyze** | PASS | Clean pass, 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | 2740/2740; independent 1677/1677 re-run by this review. |
| **Rerun loop if needed** | PASS | One restart occurred in Phase 16 after a comment-only test correction; the loop then completed clean in a single pass. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | PASS | `core.json` change is additive registration of 12 modules; contract pytest suite passed (46 assertions). |
| **Schema validation** | PASS | `test_push_down_claude_resource_contracts.py` green (`evidence/qa-gates/bundle-mirror-pytest.2026-08-15T18-15.md`). |
| **Required $schema** | N/A | `core.json` is a pack manifest governed by the contract tests, not the `$schema`-governed config set. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | Parsed clean by this review (`json.loads`). |
| **Deterministic key order** | PASS | Registration entries follow the existing manifest ordering convention; contract tests enforce structure. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | BeforeAll/Describe/Context/It with modern Should syntax throughout the 21 new/modified suites. |
| **Use PoshQC Configuration** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_test`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, extended additively with 12 new coverage targets (diff verified additive-only by this review; bundled mirror byte-identical). |
| **PowerShell 7+ Compatible** | PASS | Version-floor behavior tested through an injectable seam without mutating `$PSVersionTable`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | One inventory row or one behavior per `It`; 85 rows each individually asserted. |
| **Test Behavior Over Implementation** | PASS | Assertions target verdicts, exit codes, and exact error strings (the external contract), plus deliberate reuse assertions where reuse is itself the contract (M3, U6.C5, U6.M4, U6.X5, U6.T10). |
| **Mocking Used Sparingly** | PASS | Real code paths dominate; mocks confined to seams; Phase 16 recovery used real unmocked seam invocations rather than widening mocks. |
| **Organization** | PASS | `tests/scripts/claude-lib/**` and `tests/scripts/claude-hooks/**` mirror `.claude/lib/**` and `.claude/hooks/**`; guard suite under `tests/scripts/claude-runtime/` mirrors the house precedent location. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | All 21 suites follow `<Name>.Tests.ps1`; helper follows `<Name>.Helpers.ps1`. |
| **Describe/Context/It Structure** | PASS | Verified in sampled suites. |
| **Logical Grouping** | PASS | Grouped by check family and by fixture class (detection vs non-detection in the guard). |
| **Docstrings/Comments** | PASS | Self-documenting row-ID test names; oracle-intent headers. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Executor ran the MCP surface; this review corroborated with direct `Invoke-Pester` runs (permitted check-only verification). |
| **No Alternative Test Runners** | PASS | Pester only. |

---

## 5. Test Coverage Detail

### Changed and new production files — line coverage (re-parsed from `artifacts/pester/powershell-coverage.xml` by this review)

| File | Status | Line coverage | 85% floor |
|------|--------|---------------|-----------|
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | MODIFIED | 91.38% (53/58) | MET (baseline 87.27%) |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | MODIFIED | 91.80% (56/61) | MET (baseline 87.93%) |
| `.claude/hooks/validate-orchestrator-output.ps1` | MODIFIED | 94.55% (104/110) | MET (baseline 92.16%) |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | MODIFIED | 100.00% (108/108) | MET (baseline 97.17%) |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` | MODIFIED | 100.00% (96/96) | MET (baseline 100.00%) |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | NEW | 94.44% (102/108) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | NEW | 100.00% (112/112) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` | NEW | 100.00% (90/90) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` | NEW | 100.00% (80/80) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1` | NEW | 100.00% (80/80) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | NEW | 98.99% (98/99) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | NEW | 99.06% (105/106) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` | NEW | 100.00% (73/73) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | NEW | 100.00% (28/28) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` | NEW | 100.00% (65/65) | MET |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | NEW | 100.00% (67/67) | MET |
| `.claude/lib/codex-routing/CodexTopology.psm1` | NEW | 100.00% (108/108) | MET |
| `.claude/lib/model-routing/ModelRouting.psm1` | UNMODIFIED (formula reuse) | 100.00% (46/46) | MET |

The 10 uncovered lines in the two discovery hooks (5 each: 224/227/228/231/233 and 251/252/253/254/257) are pre-existing main-entry lines that were also uncovered at baseline; the previously uncovered replacement seam-body lines (10 total) are all covered after the Phase 16 additive remediation.

**Not covered:** the two single-line residuals in `OrchestratorStateCompletionChecks.psm1` and `OrchestratorStateRoutingContract.psm1` (98.99% and 99.06%); both files exceed the floor by a wide margin.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full PoshQC suite, executor artifact) | 2740 | PASS |
| Tests Passed | 2740 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Independent re-run by this review (claude-lib + claude-hooks) | 1677/1677 passed | PASS |
| Guard suite (this review, repository scans included) | 27/27 passed in 1.65s | PASS |
| Execution Time (full suite) | 101.6s | PASS Fast |
| Files analyzed for coverage | 64 (52 at baseline; +12 new modules) | PASS |
| Code Coverage | 95.92% lines; branch counters not emitted by instrument | PASS (line); see section 8 for the branch-instrument gap |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | 0 files changed | PASS |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | 0 findings | PASS |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` | 2740 tests, 0 failures | PASS |
| Guard suite (independent) | `Invoke-Pester tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 27/27 including both repository scans | PASS |
| Lib+hooks trees (independent) | `Invoke-Pester tests/scripts/claude-lib, tests/scripts/claude-hooks` | 1677/1677 | PASS |

**For Python (contract tests only; no Python code changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black .` | 0 files reformatted | PASS |
| Ruff | `poetry run ruff check .` | 0 findings | PASS |
| Pyright | `poetry run pyright` | 0 errors | PASS |
| Pytest | `poetry run pytest --cov --cov-branch` | 3785 passed, 0 failed | PASS |

**Notes:**
The Python-side runs exist because the bundle mirror and manifest changes are guarded by Python contract tests; the Python production surface itself is unchanged. Mirror byte-identity was additionally re-verified directly by this review: 17/17 changed `.claude/**` files byte-identical to their bundle mirrors; both `pester.runsettings.psd1` copies byte-identical.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PowerShell branch coverage is unmeasurable with the current instrument.** The Pester 5 JaCoCo exporter emits no `BRANCH` counters (verified by this review: zero occurrences in `artifacts/pester/powershell-coverage.xml`; equally true of the baseline). The repository's 75% branch floor for PowerShell therefore cannot be evaluated for this or any branch. This is a pre-existing toolchain limitation, not introduced or worsened by this change, and no threshold was relaxed. Recommended follow-up: file a potential entry for a branch-capable PowerShell coverage instrument; no existing potential entry records this gap.
- **Evidence timestamps mix timezone bases.** Site-verification artifacts appear stamped in UTC (20-15 through 23-30) while baseline/final artifacts appear stamped in local time (18-21 through 19-21), which breaks chronological ordering by filename. Content-level `Timestamp:` fields are internally consistent per artifact. Minor documentation defect; no evidentiary impact because artifacts cross-reference by task ID.

### Approved Exceptions

- **LEO-1 (declared local execution override).** The run deleted `.claude/state/powershell-batch-budget.<session_id>.json` at the start of each PowerShell-writing plan phase. Assessment: agreed as sanctioned. The batch-budget hook's own deny remedy at `enforce-powershell-batch-budget.ps1:136-137` names "reset the batch by deleting <StateFile>" as a first-class remedy alongside splitting into a new batch; a plan phase is a batch boundary, each phase independently respected the 3-production/3-test cap (audited per-phase in the plan and the self-gating audit's 21-file task attribution), and the `CLAUDE_POWERSHELL_BUDGET_*` cap overrides were deliberately not used. The override is fully declared in the checkpoint with approver, rationale, and binding condition. The completion-gate check `local_execution_overrides must be empty at completion` correctly still fails against this record and was left standing rather than deleted — that reconciliation belongs to the orchestrator at run completion, not to this review.
- **Destination version floor PowerShell 7.4+ (owner-directed).** A deliberate floor above the repo's stated 7+ standard, enforced fail-closed with an actionable message, documented in module header/help/potential entry, and tested through an injectable seam (AC-26..AC-28). Not a policy violation; recorded as an owner-approved constraint.
- **Deliberate parity deviations PD-1, PD-2, PD-3.** Assessed and agreed as correct engineering decisions rather than deferrals: PD-1 (pinned routing constants with a config-parity test) — literal parity would crash on `FileNotFoundError` in every destination lacking `config/orchestration-routing.json`, which is the exact portability failure the feature removes; the config-parity test pins drift where the config exists. PD-2 (single emission) — Python's duplicate emission is a call-graph artifact; the hook's verdict keys on non-empty output and prefix tokens, never counts; a test pins single emission. PD-3 (defined fail-closed structural behavior for epic/parallel) — the Python CLI exits 2 on argparse before running any check for these types, so there is no behavior to port; the definition is fail-closed and fixes defect D-1. All three are owner-visible in the spec with dedicated ACs (AC-21/22/23) and tests.

### Removed/Skipped Tests

**None removed to weaken the surface.** The four existing-test updates of research section 4.3 (probe-mock deletions, source-text assertion replaced by its AST inverse, comment update) are removals of tests for deleted Python-leg behavior, replaced by equal-or-stronger structural assertions (AC-11/AC-12). The full suite carries 9 disabled tests repo-wide (junit `disabled="9"`), unchanged in character from baseline and outside this feature's scope.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **116a56fb** - fix(claude-hooks): remove Python invocations from enforcement-hook surface

### Files Modified

1. **`.claude/hooks/enforce-discovery-artifact-gate.ps1`**, **`.claude/hooks/validate-discovery-artifact-gate.ps1`** (MODIFIED) - `Invoke-DiscoveryValidatorExe` bodies replaced: delegate to the shared `DiscoveryValidation.psm1`; empty-output-on-success contract (D-2 avoidance); seam name and return contract preserved.
2. **`.claude/hooks/validate-orchestrator-output.ps1`** (MODIFIED) - Python leg and probe removed; `$ArtifactType` dispatch added (complete-parity completion validation for `orchestrator-state`; PD-3 structural check for epic/parallel; fail-closed default); `Test-HumanInteractionShape` unchanged.
3. **`.claude/lib/orchestrator-state/OrchestratorState.psm1`** (MODIFIED) - `Test-PythonOrchestratorValidatorAvailable` deleted; preflight default invoker collapsed to the portable U-family + PR-creation-readiness path; `$Invoker` seam retained.
4. **`.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`** (MODIFIED) - extended from presence-level fallback to the complete-parity completion entry point with single-emission gate reuse (PD-2).
5. **12 NEW `.claude/lib` modules** - discovery validation, receipts, model receipts, codex model/topology receipts, codex deployment/topology resolvers, routing matrix (pinned constants, PD-1), routing contract, completion checks, unconditional aggregation, checkpoint-value helper.
6. **17 bundle mirrors + `core.json`** (MODIFIED/NEW) - byte-identical mirrors; 12 manifest registrations.
7. **2 `pester.runsettings.psd1`** (MODIFIED) - additive-only: 12 new coverage targets.
8. **34 test files** (NEW/MODIFIED) - guard suite + helper, 85-row parity suites, dispatch suites, version-floor suite, manifest suites, real-dispatch coverage suites, and the four research-mandated existing-test updates.
9. **54 Markdown documents** (NEW/MODIFIED/DELETED) - feature folder (issue/spec/user-story/plan/research/evidence), potential entry lifecycle (promoted + new residuals entry).

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All policy gates evaluated PASS for the single production language in scope (PowerShell). Coverage floors are met with margin on every changed and new file; the toolchain completed clean in a single final pass; the guard, mirror, manifest, evidence-location, and file-size invariants were all independently re-verified by this review. The three deliberate parity deviations and the LEO-1 override are declared, owner-visible, tested, and assessed as sound. The self-gating invariant held: line-level deletion audit of the gate files found zero removed checks, zero weakened error strings, and zero relaxed thresholds; the checkpoint, not the checks, absorbed the 42 Phase-10 reconciliation failures, and the 11 mid-run completion failures were correctly left standing.

**Coverage verdicts (explicit, per language with changed files):**
- PowerShell: **PASS** (line 95.92% repo-wide; every changed/new file >= 85%; new-code 99.31%; changed-line 100%; no regression)
- Python: N/A (zero changed files)
- TypeScript: N/A (zero changed files)
- C#: N/A (zero changed files)

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, research, and plan all recorded
- PASS Design Principles: simplification plus decomposition into cohesive modules
- PASS Module & File Structure: 500-line cap held; no cycles
- PASS Naming, Docs, Comments: analyzer-clean, rationale-focused
- PASS Toolchain Execution: clean single final pass, evidence per stage
- PASS Summarize & Document: spec/decision records/potential entry complete

#### Language-Specific Code Change Policy (Section 3)
**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios (line floors; branch-instrument gap recorded in section 8)
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)
**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

### Metrics Summary

- 2740/2740 tests passing (100%); 1677/1677 on independent re-run of the changed trees
- 95.92% repo-wide PowerShell line coverage (+1.07 pts vs baseline)
- 99.31% new-module line coverage; 100% changed-seam-line coverage
- 17/17 bundle mirrors byte-identical; 12/12 modules manifest-registered
- 0 formatter changes, 0 analyzer findings, 0 evidence-location violations, 0 files over 500 lines
- Guard: 5 findings before removal (fail-before evidence), 0 findings after, in both trees

### Recommendation

**Ready for merge** (subject to the recorded stop condition: the parent session rebases onto `main` and runs PR authoring; no PR is created from this run). Zero blocking findings. Two minor non-blocking items are recorded in section 8 (branch-coverage instrument gap; mixed timestamp bases) and in the code review.

---

## Appendix A: Test Inventory

Scope note: the branch adds or modifies 34 test files. The complete per-`It` inventory (2740 tests) is machine-recorded in `artifacts/pester/pester-junit.xml`; the row-by-row mapping of the 85 parity rows to their asserting `It` names is in `evidence/other/parity-coverage.2026-08-15T18-30.md`. Suite-level inventory of the feature's test files:

1. tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 (27 tests: 4 detection classes, non-detection fixtures, 2 repository-scan assertions, allowlist-staleness assertion) + EnforcementHooksNoPythonInvocation.Helpers.ps1
2. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 (U5, U6.R, U6.H rows)
3. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1 (U6.C, U6.M rows)
4. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 (U6.X rows)
5. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 (U6.T rows)
6. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 (C1-C5, C7 rows)
7. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 (C6 rows)
8. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 (PD-1 config-parity, 31 tests)
9. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 (U-family aggregation, 19 tests)
10. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 (shared value helpers)
11. tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 (extended: M-family, PD-2 single emission, reuse assertions)
12. tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 (modified: portable-default preflight; seam tests at :250-273 unmodified)
13. tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 (extended manifest pinning)
14. tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 (27 tests), CodexTopology.Parity.Tests.ps1 (36 tests), CodexRouting.Manifest.Tests.ps1 (5 tests)
15. tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 (40 tests), DiscoveryValidation.VersionFloor.Tests.ps1 (13 tests), DiscoveryValidation.Manifest.Tests.ps1 (4 tests)
16. tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 (dispatch, D-1 regression, both-layers U6.H proof)
17. tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1, validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 (real-seam coverage suites)
18. tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1, validate-orchestrator-output.model-routing.Tests.ps1, enforce-discovery-artifact-gate.Tests.ps1, validate-discovery-artifact-gate.Tests.ps1, enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 (research-mandated updates; pinned seam references unmodified)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting (check surface)
mcp__drm-copilot__run_poshqc_format   # workspace_root = worktree root, full scan set

# Linting
mcp__drm-copilot__run_poshqc_analyze  # repo settings, default scan set from config/poshqc-scan.json

# Testing + coverage
mcp__drm-copilot__run_poshqc_test     # settings: scripts/powershell/PoshQC/settings/pester.runsettings.psd1
                                      # coverage artifact: artifacts/pester/powershell-coverage.xml

# Independent verification runs used by this review
pwsh -NoProfile -Command "Invoke-Pester tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1"
pwsh -NoProfile -Command "Invoke-Pester tests/scripts/claude-lib, tests/scripts/claude-hooks"
```

**For Python (contract tests, no Python code changed):**
```bash
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**Review-specific verification commands:**
```bash
# PR context refresh (base main)
python -m scripts.dev_tools.pr_context.collector --base main --head HEAD \
  --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt

# Evidence-location compliance
python scripts/dev_tools/validate_evidence_locations.py --root .

# Mirror byte-identity (17 changed .claude files vs bundle)
# python filecmp/read_bytes comparison; result: 17/17 identical, MISMATCH_COUNT = 0

# Coverage XML parse (per-file LINE counters)
# python xml.etree parse of artifacts/pester/powershell-coverage.xml
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-08-15
**Policy Version:** Current (as of audit date)
