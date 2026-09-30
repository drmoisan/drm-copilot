# Policy Compliance Audit: PowerShell batch-budget hook large-path routing (#769)

---

**Audit Date:** 2026-09-29  
**Branch:** `bug/batch-budget-hook-lacks-orchestration-awareness-769` @ `79c69039aa76152316a581625acbeed33ad15ceb`  
**Base:** `main` (merge base `b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e`)  
**Scope:** full branch diff against the merge base (120 files, +4531/-545). No caller-supplied narrowing was applied.  
**Template source:** repository copy of the bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`. The drm-copilot MCP template tool was not callable from this reviewer session; the repository copy of the same bundled asset was used and the process deviation is recorded in Section 8.

**Code Under Test (production and test code with changed lines):**

- PowerShell production: `.claude/hooks/enforce-powershell-batch-budget.ps1` (modified), `.claude/hooks/enforce-powershell-batch-budget-route.ps1` (new), `.codex/hooks/enforce-powershell-batch-budget.ps1` (modified), `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (modified, configuration), plus byte-identical bundle mirrors under `extensions/drm-copilot/resources/`.
- PowerShell tests: `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` (new), `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` (new), `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` (modified), `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` (modified).
- Non-code surfaces: Markdown agent/skill/rule/prompt text (Claude, Copilot, `.agents`), Codex agent TOML (6 files plus mirrors), one JSON pack manifest, feature-folder documents and evidence, three potential entries.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 source files (+4 mirrors), 4 test files | 231 tests in the six affected suites | ✅ 231 pass, 0 fail | 95.35% lines (Claude hook), 96.55% lines (Codex hook) | 95.45% lines (Claude hook), 94.12% lines (route helper, new), 97.73% lines (Codex hook); repo-wide 96.13% lines | 100% / 94.12% / 96.51% changed-line coverage |
| Python | 0 files | N/A | N/A (parity suites run as regression only) | N/A - no Python files changed | N/A - no Python files changed | N/A - no Python files changed |
| TypeScript | 0 files | N/A | N/A | N/A - no TypeScript files changed | N/A - no TypeScript files changed | N/A - no TypeScript files changed |
| C# | 0 files | N/A | N/A | N/A - no C# files changed | N/A - no C# files changed | N/A - no C# files changed |
| JSON / TOML / Markdown | 1 JSON, 12 TOML, many Markdown | N/A | ✅ JSON parses; TOML variants regenerate cleanly | N/A (non-code configuration and documentation) | N/A (non-code configuration and documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/evidence/baseline/claude-hook-coverage.2026-09-29T14-39.md` and `.../evidence/baseline/codex-hook-coverage.2026-09-29T14-39.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (canonical, JaCoCo, generated 2026-09-29 15:20) and `.../evidence/qa-gates/claude-hook-coverage.2026-09-29T14-39.md`, `.../evidence/qa-gates/codex-hook-coverage.2026-09-29T14-39.md`
- Per-language comparison summary: Section 1.2.1 of this audit and `.../evidence/qa-gates/coverage-comparison.2026-09-29T14-39.md`

---

## Executive Summary

The branch fixes issue #769: the Claude and Codex PowerShell batch-budget PreToolUse hooks now read `artifacts/orchestration/orchestrator-state.json`, exempt non-terminal `large`/`remediation`/`preparation` routes from the production-file count, and in direct mode deny the 4th distinct production PowerShell path with a `POWERSHELL_LARGE_PATH_REQUIRED` routing instruction. The test-file cap, the `CLAUDE_POWERSHELL_BUDGET_*` environment override, and the persisted cap override are removed. Per-batch policy text is removed from PowerShell surfaces on every runtime and the threshold text is reconciled to `1-3` / more than 3.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` / `general-code-change.instructions.md`
- ✅ `.claude/rules/general-unit-test.md` / `general-unit-test.instructions.md`
- ✅ `.claude/rules/quality-tiers.md`
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python files changed)
- ✅ `.claude/rules/powershell.md` (`powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`)
- N/A Bash (no shell files changed)
- ✅ JSON: the single changed JSON file (`pack-manifests/powershell.json`) parses and is covered by the pack-manifest completeness test

Independent reviewer verification (not relying solely on executor evidence): Pester run of the six affected suites (231/231 passed), PSScriptAnalyzer with `pssa.settings.psd1` (0 findings on all 8 changed PowerShell files), Invoke-Formatter check with PoshQC semantics (all 8 files unchanged), repo/bundle byte-identity (`cmp`, 20 pairs identical), acceptance-criteria greps, `generate_codex_agent_variants --check` (exit 0), Python parity suites against a clean `git archive HEAD` snapshot (44 passed), and `validate_evidence_locations.py --root .` (exit 0). Coverage figures were read from the canonical artifact `artifacts/pester/powershell-coverage.xml`; coverage generation was not rerun.

Result: no Blocking findings. PowerShell coverage PASS. One process deviation (template resolution route) and one evidence caveat (the canonical coverage artifact omits the new route helper) are recorded in Section 8.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts are committed on the branch; executor scratch scripts lived under the session scratchpad (`SCRATCH/`), which is outside the repository.
- ✅ No new ongoing tooling scripts were added.
- Reviewer scratch scripts (`jacoco.py`, `run-pester.ps1`, `run-pssa.ps1`, clean snapshot) were created only in the session scratchpad and are not part of the branch.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each `It` re-initializes the in-memory store via `BeforeEach { Initialize-RoutingStore }` / `Initialize-CodexRoutingStore`; no shared persisted state. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Suites are grouped by Context: route predicate, selected route, direct mode, large path, test paths, removed cap overrides, checkpoint seam, entry point. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The six affected suites (231 tests) completed in a single local run within the tool timeout; no sleeps or waits. |
| **Determinism** - Consistent results | ✅ PASS | Checkpoint and state are supplied as in-memory strings through `ReadCheckpoint`, `TestPathExists`, `ReadState`, `WriteState` seams. No clock or RNG use. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Data-driven `-ForEach` tables with named rows; helper functions (`Invoke-RoutedHook`, `Get-RoutedDenyReason`) keep cases short. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Baseline per-file line coverage: Claude hook 95.35%, Codex hook 96.55% (`evidence/baseline/claude-hook-coverage.2026-09-29T14-39.md`, `evidence/baseline/codex-hook-coverage.2026-09-29T14-39.md`). |
| **No Coverage Regression** | ✅ PASS | Claude hook 95.35% -> 95.45% (+0.10); Codex hook 96.55% -> 97.73% (+1.18). Values confirmed in `artifacts/pester/powershell-coverage.xml`. |
| **New Code Coverage >= 85% (uniform tier rule)** | ✅ PASS | New file `enforce-powershell-batch-budget-route.ps1`: 32/34 lines = 94.12% (executor direct Pester run; see Section 8 caveat). Changed-line coverage: Claude hook 33/33 = 100%, Codex hook 83/86 = 96.51%. |
| **Comprehensive Coverage** | ✅ PASS | All new/changed functions exercised: `ConvertFrom-PowerShellBatchBudgetCheckpoint`, `Get-PowerShellBatchBudgetSelectedRoute`, `Test-PowerShellBatchBudgetLargePathRoute`, `Invoke-PowerShellBatchBudgetDecision -LargePathRoute`, `Invoke-PowerShellBatchBudgetHook -ReadCheckpoint`, `Invoke-PowerShellBatchBudgetCodexEntryPoint`. Uncovered lines: route helper 134-135 and Codex 171-172 (defensive catch in the predicate, unreachable because the inner calls do not throw), Claude 481-486 and Codex 458 (process entry-point wiring). |
| **Positive Flows** - Valid inputs | ✅ PASS | First three production paths allowed; `large`/`remediation`/`preparation` routes allow six paths; `path_selected`-only large route allows. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Malformed JSON, array JSON, string JSON, empty/whitespace text, null/non-string `route_id`, wrong-case route, unknown route all yield direct mode. |
| **Edge Cases** - Boundary conditions | ✅ PASS | 4th path boundary; repeated path; terminal `next_step: complete`; `S12_complete` in `completed_steps`; legacy state with `prodCap`/`testCap`/`testFiles`. |
| **Error Handling** - Error paths | ✅ PASS | Throwing `ReadCheckpoint` seam yields direct mode without raising; unreadable envelope still denied under a large route; Codex entry point with empty payload. |
| **Concurrency** - If applicable | N/A | Hooks run per tool call in separate processes; no in-process concurrency. |
| **State Transitions** - If applicable | ✅ PASS | State accumulation across calls (three allowed then deny) and no state write on large path, test path, repeated path. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.35% lines (Claude hook) and 96.55% lines (Codex hook) -> Post-change: 95.45% lines (Claude hook), 97.73% lines (Codex hook), 94.12% lines (new route helper); repo-wide 96.13% lines. Change: +0.10% lines (Claude hook), +1.18% lines (Codex hook); new file has no baseline. New/changed-code coverage: 100% (Claude hook), 94.12% (route helper), 96.51% (Codex hook). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/coverage-comparison.2026-09-29T14-39.md`, `evidence/qa-gates/changed-line-coverage.2026-09-29T14-39.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Prohibited-phrase loop uses `-Because "the deny reason must not mention '$phrase'"`; source scan uses `-Because "$($source.Name) must not read the removed override"`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Cases arrange via `Initialize-RoutingStore -PersistedText`, act via one hook call, assert decision and write counters. |
| **Document Intent** | ✅ PASS | Descriptive `It` names (for example `'<Route> route allows six distinct production paths without a state write'`) and file-level synopsis blocks. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, process, or service dependency. Two read-only filesystem touches: a source scan of the hook files (`Get-ChildItem`/`Get-Content`) and one case that exercises the default `ReadCheckpoint` against a synthetic absent root (`Test-Path` returns false). |
| **Use Mocks/Stubs** | ✅ PASS | Scriptblock seams replace filesystem state and checkpoint reads; no `Mock` of executables. |
| **Environment Stability** | ✅ PASS | No temporary files: `git grep` for `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `TestDrive`, `Set-Content`, `Out-File`, `New-Item` over the four changed test files returns no match. Environment variables set in tests are reset in `AfterEach` (reset to `$null`; see code review Nit). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the pre-PR policy review for #769. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` record owner-confirmed intent (2026-09-29): the cap is a routing gate; the large path has no cap. |
| **Read existing change plans** | ✅ PASS | `plan.2026-09-29T13-19.md` and the research record `research/2026-09-29T13-35-batch-budget-routing-research.md`. |
| **Document the plan** | ✅ PASS | Atomic plan committed at `f650eee0`; policy-read record `evidence/baseline/phase0-instructions-read.2026-09-29T14-39.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | A single boolean predicate over checkpoint text plus a `-LargePathRoute` switch on the existing decision function. Override mechanisms removed rather than extended. |
| **Reusability** | ✅ PASS | Claude route helpers live in a dot-sourced sibling file. The Codex hook inlines equivalent helpers by design (spec: the Codex bundle cannot carry `.claude/lib`); duplication noted as Minor in the code review. |
| **Extensibility** | ✅ PASS | Route set is a single literal list; `ReadCheckpoint` is an injectable seam with a safe default. |
| **Separation of concerns** | ✅ PASS | Pure parsing/predicate functions perform no I/O; I/O is confined to the entry function's seam defaults. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Route helper file contains only checkpoint parsing and route selection. |
| **Under 500 lines** | ✅ PASS | `wc -l`: Claude hook 486, route helper 137, Codex hook 461, Claude routing tests 353, Claude tests 490, Codex tests 371, Codex routing tests 382, runsettings 336. |
| **Public vs internal** | ✅ PASS | `Get-PowerShellBatchBudgetBlockDecision` name, parameters, and deny shape unchanged (`PreToolUseSchema.Contract.Tests.ps1` passes). |
| **No circular dependencies** | ✅ PASS | Hook dot-sources route helper; route helper has no imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs: `ConvertFrom-`, `Get-`, `Test-`, `Invoke-`. |
| **Docs/docstrings** | ✅ PASS | Both hook headers describe the routing model, precedence, terminal exclusion, the stale-checkpoint limitation, and #673 hygiene; new functions carry comment-based help. |
| **Comment why, not what** | ✅ PASS | For example, "The checkpoint is read before any state operation, so the large path neither creates the state directory nor reads or writes the state file." |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter -ScriptDefinition <LF-normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (PoshQC format semantics, check-only).<br>**Result:** all 8 changed PowerShell files unchanged. Executor evidence: `evidence/qa-gates/powershell-format.2026-09-29T14-39.md`. |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`.<br>**Result:** 0 findings on all 8 files. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Architecture-boundary tests** | N/A | No TypeScript or .NET files changed. |
| **5. Unit tests** | ✅ PASS | **Command:** `Invoke-Pester` over the six affected suites.<br>**Result:** 231 passed, 0 failed. Executor full-directory runs: claude-hooks 2070/2070, codex-hooks 1149/1149, claude-runtime 83/83. |
| **6. Contract / schema checks** | ✅ PASS | `PreToolUseSchema.Contract.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1` pass; Python parity suites 44/44 on a clean HEAD snapshot. |
| **7. Integration tests** | ✅ PASS | Codex entry-point tests and executor live route probes (`evidence/regression-testing/live-route-probe-*.md`). |
| **Full toolchain loop** | ✅ PASS | Executor recorded format -> analyze -> test in `evidence/qa-gates/`; reviewer re-ran format/analyze/test check-only with no changes. |
| **Explicit reporting** | ✅ PASS | Commands listed in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9. |
| **Design choices explained** | ✅ PASS | `spec.md` Proposed Fix, rejected signals, known limitations. |
| **Update supporting documents** | ✅ PASS | Rule, skill, agent, and prompt text on Claude, Copilot, Codex, and `.agents` surfaces with bundle mirrors. |
| **Provide next steps** | ✅ PASS | Follow-ups 1 and 2 recorded under `docs/features/potential/`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** Invoke-Formatter check with `pssa.settings.psd1`.<br>**Result:** no changes on 8 files. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** Invoke-ScriptAnalyzer with `pssa.settings.psd1`.<br>**Result:** 0 findings. |
| **Fix all findings** | ✅ PASS | Two `PSReviewUnusedParameter` suppressions on the retained `-TestCap` parameter carry a justification string (see code review Nit). |
| **PowerShell 7+ compatible** | ✅ PASS | Tests ran under `pwsh`; Codex routing suite declares `#Requires -Version 7.0`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | All new functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `[AllowNull()]`/`[AllowEmptyString()]` on checkpoint text; `[Parameter(Mandatory)]` retained where required. |
| **Avoid global state** | ✅ PASS | No script-scoped mutable state in production code. |
| **Error handling** | ✅ PASS | Checkpoint read/parse failures are caught, logged with `Write-Verbose`, and fail toward direct-mode enforcement (never toward allow). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | Max 490 lines (existing Claude test file). |
| **Approved verbs** | ✅ PASS | `ConvertFrom`, `Get`, `Test`, `Invoke`. |
| **Comment why** | ✅ PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | No changes. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 231/231 affected; executor directory totals 2070 + 1149 + 83, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | Reviewer single pass clean. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | `pack-manifests/powershell.json` adds one array entry; parsed by `test_push_down_claude_pack_manifest_completeness.py` (passed). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `Describe`/`Context`/`It`, `BeforeAll`/`BeforeEach`/`AfterEach`, `-ForEach` data tables, `Should -Be`/`-BeLike`/`-HaveCount`. |
| **Use PoshQC Configuration** | ✅ PASS | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` adds the route helper to the coverage list; bundle copy identical. |
| **PowerShell 7+ Compatible** | ✅ PASS | Executed under `pwsh`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Claude routing suite 47 cases; Codex routing suite 49 cases. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions on decisions, reasons, and write counters rather than internals. |
| **Mocking Used Sparingly** | ✅ PASS | No Pester `Mock`; only scriptblock seams. |
| **Organization** | ✅ PASS | New suites at the spec-mandated paths `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, which follow the repository's established layout for hook tests. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Both new files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe`, 6-8 `Context` blocks per suite. |
| **Logical Grouping** | ✅ PASS | Grouped by behavior area. |
| **Docstrings/Comments** | ✅ PASS | File-level synopsis describes seams and the no-file-write guarantee. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | Executor ran `mcp__drm-copilot__run_poshqc_test` (canonical artifact `artifacts/pester/powershell-coverage.xml`); counts taken from direct Pester runs because the MCP result carries no counts. |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### Test-PowerShellBatchBudgetLargePathRoute / Get-PowerShellBatchBudgetSelectedRoute (Claude 25 cases, Codex mirrored)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| route_id large / remediation / preparation | Positive | route helper 112-132 | ✅ |
| route_id small / blank / unknown / wrong case / no route keys | Negative | route helper 72-89, 119-120 | ✅ |
| route_id null or non-string with path_selected large | Edge Case | route helper 79-89 | ✅ |
| terminal next_step complete / S12_complete | Edge Case | route helper 124-130 | ✅ |
| malformed / array / string JSON / empty / whitespace | Error Handling | route helper 35-50 | ✅ |

**Coverage:** 94.12% of the route helper file (32/34 lines). **Not covered:** lines 134-135 (defensive catch).

### Invoke-PowerShellBatchBudgetHook / Invoke-PowerShellBatchBudgetDecision (Claude and Codex)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| allows first three, denies the 4th (no checkpoint, small route) | Positive/Negative | Claude 304-320 | ✅ |
| deny reason names routing target, counted paths, observed route | Positive | Claude 311-315 | ✅ |
| deny reason omits prohibited phrases and state-file path | Negative | Claude 314 | ✅ |
| large route allows six paths without state write | Positive | Claude 384-399, 293-296 | ✅ |
| test paths allowed and not recorded | Edge Case | Claude 298-302 | ✅ |
| legacy state and env overrides ignored | Edge Case | Claude 202-232 | ✅ |
| throwing checkpoint reader, unreadable envelope under large route | Error Handling | Claude 354-360, 388-393 | ✅ |

**Coverage:** Claude hook 95.45% (126/132); Codex hook 97.73% (129/132). **Not covered:** entry-point process wiring (Claude 481-486, Codex 458) and defensive catches (Claude 88, 98; Codex 171-172).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (affected suites, reviewer run) | 231 | ✅ |
| Tests Passed | 231 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Directory totals (executor) | claude-hooks 2070, codex-hooks 1149, claude-runtime 83; 0 failed | ✅ |
| Functions Tested | all new and changed functions | ✅ |
| Test File Size | 353 / 382 / 490 / 371 lines | ✅ |
| Code Coverage | 96.13% lines repo-wide (PowerShell); branch coverage not measured by Pester (no PowerShell branch gate) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -Settings pssa.settings.psd1` (check-only) | 8/8 unchanged | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `Invoke-Pester` (six affected suites) | 231/231 | ✅ |

**For Python (regression only; no Python files changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Parity suites (worktree) | `poetry run pytest` six parity suites | 43 passed, 1 failed | ⚠️ pre-existing, environment-only |
| Parity suites (clean HEAD snapshot) | `python -m pytest` in `git archive HEAD` extract | 44 passed | ✅ |
| Codex variants | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | exit 0 | ✅ |

**Notes:** The single worktree failure is `test_bundled_claude_payload_contains_all_repo_runtime_contracts` with "Repo file missing from bundle: .claude\state\current-session-id". The file is gitignored runtime state (open issue #510). It fails identically at the baseline and passes on a clean snapshot of HEAD, so it is not introduced by this branch.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Canonical coverage artifact omits the new route helper (evidence caveat, non-blocking).** `artifacts/pester/powershell-coverage.xml` (generated 15:20 by the MCP PoshQC runner) contains the Claude and Codex hooks but not `.claude/hooks/enforce-powershell-batch-budget-route.ps1`, although the repository `pester.runsettings.psd1` lists it (committed 14:56 in `f6fe2c05`). The MCP runner reads the installed extension's settings, which predate this branch. The new file's 94.12% figure comes from the executor's direct Pester coverage run (`evidence/qa-gates/claude-hook-coverage.2026-09-29T14-39.md`); its uncovered lines (134, 135) match the defensive catch block in the file, which corroborates the measurement. Coverage verdict remains PASS; confirm the file appears in CI coverage after merge.

### Approved Exceptions

- **Template resolution route (process deviation).** `policy-audit-template-usage` requires resolving the template through the drm-copilot MCP template tool. That tool was not in this reviewer's tool set. The repository copy of the same bundled asset (`extensions/drm-copilot/resources/templates/policy_audit/`) was used, and all canonical headings are preserved. This is a reviewer-environment deviation, not a branch finding. The orchestrator may treat it as a condition on this audit.
- **KL-510 local parity failure.** Pre-existing, environment-only; see Section 7.

### Removed/Skipped Tests

1. **"allows a new Pester test file under the test cap and records it"** and **"denies a new test file when the test cap is full"** - replaced in `enforce-powershell-batch-budget.Tests.ps1`.
   - **Reason:** the test-file cap was removed by design (spec In scope item 1).
   - **Impact:** replaced by "allows a Pester test file without recording it" and "does not count a test file toward the production threshold".
   - **Justification:** the removed behavior is a spec-mandated removal.
2. Codex shared-row cap-override and test-cap expectations in `codex-batch-budget-hooks.Tests.ps1` made language-specific (7 PowerShell-row cases removed, 49 routing cases added).

## Rejected Scope Narrowing

None detected. The caller prompt requested the full feature-review workflow end-to-end and did not narrow scope, files, or languages.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- The branch diff contains no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/evidence/<kind>/`.

## Modified-Workflow Rule

The branch diff modifies no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. The `modified-workflow-needs-green-run` rule does not fire.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **f650eee0** - docs(769): promote batch-budget routing bug and add planning artifacts
2. **cf9f8641** - test(769): add Claude batch-budget routing regression tests
3. **53413fd1** - fix(769): route over-budget PowerShell changes to the large path in the Claude hook
4. **f6fe2c05** - fix(769): bundle the Claude batch-budget route helpers
5. **d942c72e** - test(769): add Codex batch-budget routing regression tests
6. **13e39957** - fix(769): route over-budget PowerShell changes to the large path in the Codex hook
7. **9581bf6c** - docs(769): state the PowerShell routing rule on Claude and Copilot surfaces
8. **d31c05b8** - docs(769): remove per-batch text from Codex and .agents PowerShell surfaces
9. **ff5a4349** - docs(769): record batch-budget follow-up potential entries
10. **80863cda** - docs(769): record final QA evidence
11. **79c69039** - docs(769): check off acceptance criteria

### Files Modified

1. **`.claude/hooks/enforce-powershell-batch-budget.ps1`** (MODIFIED) - checkpoint seam, large-path switch, routing deny message, override removal, docstring.
2. **`.claude/hooks/enforce-powershell-batch-budget-route.ps1`** (NEW) - pure checkpoint parsing and route predicate.
3. **`.codex/hooks/enforce-powershell-batch-budget.ps1`** (MODIFIED) - same semantics with inlined helpers and Codex routing target; testable entry-point function.
4. **`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`** (MODIFIED) - coverage list entry for the route helper.
5. **`extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json`** (MODIFIED) - pack entry for the route helper.
6. **Text surfaces** (MODIFIED) - `.claude/rules/powershell.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/skills/{invoke-powershell-engineer,powershell-change-budget-router}/SKILL.md`, `.github/agents/{powershell-orchestrator,powershell-typed-engineer}.agent.md`, `.github/prompts/orchestrate-powershell-work.prompt.md`, `.github/skills/powershell-change-budget-router/SKILL.md`, `.agents/skills/{invoke-powershell-engineer,powershell}/SKILL.md`, `.codex/agents/powershell-typed-engineer*.toml` (6).
7. **Bundle mirrors** (MODIFIED/NEW) - byte-identical copies of items 1-6 under `extensions/drm-copilot/resources/`.
8. **Tests** (NEW/MODIFIED) - four Pester suites listed above.
9. **Feature docs** (NEW) - `issue.md`, `spec.md`, plan, research, evidence; three potential entries; promoted-entry move.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT (with one documented reviewer-process deviation)

All general, PowerShell, and unit-test policy requirements evaluated for the branch diff pass. PowerShell coverage is above the 85% line threshold per file, repo-wide, and on changed lines, with no regression. No Blocking findings.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present
- ✅ Design Principles: simple predicate plus seam; fail toward enforcement
- ✅ Module & File Structure: all files under 500 lines
- ✅ Naming, Docs, Comments: approved verbs; docstrings updated
- ✅ Toolchain Execution: format/analyze/test clean
- ✅ Summarize & Document: follow-ups recorded

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: advanced functions, no global state
- ✅ Structure & Naming: compliant
- ✅ Toolchain: single clean pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: in-memory seams, deterministic
- ✅ Coverage & Scenarios: >= 85% line, no regression
- ✅ Test Structure: AAA, clear names
- ✅ External Dependencies: no temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester v5
- ✅ Test Style & Structure: focused, seam-based
- ✅ Naming & Readability: `*.Tests.ps1`, Describe/Context/It
- ✅ Toolchain: Pester

### Metrics Summary

- ✅ 231/231 affected-suite tests passing (100%)
- ✅ 96.13% repo-wide PowerShell line coverage (canonical artifact)
- ✅ Per-file: 95.45% / 94.12% / 97.73%; changed-line 100% / 94.12% / 96.51%
- ✅ 0 analyzer findings; formatter clean
- ✅ Repo/bundle mirrors byte-identical (20 pairs)

### Recommendation

**Ready for merge**, subject to the normal CI gate. Confirm in CI that the route helper appears in PowerShell coverage output.

---

## Appendix A: Test Inventory

### Complete Test List (new suites, grouped)

1. Claude routing › large-path route predicate › 21 data rows
2. Claude routing › selected route › 4 data rows
3. Claude routing › direct mode › 6 cases (no checkpoint, small route, reason content, prohibited phrases, repeated path, terminal checkpoint)
4. Claude routing › large path › 5 cases (3 routes, decision switch, path_selected-only)
5. Claude routing › test paths › 2 cases
6. Claude routing › removed cap overrides › 4 cases
7. Claude routing › checkpoint seam › 5 cases
8. Codex routing › mirrored contexts (49 cases) including Codex entry-point cases with `-HookSeams`

Modified suites: `enforce-powershell-batch-budget.Tests.ps1` (test-cap cases replaced; `-ReadCheckpoint $script:NoCheckpoint` added to entry-level cases), `codex-batch-budget-hooks.Tests.ps1` (PowerShell row made language-specific).

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands (check-only):**

```bash
git diff --stat=200 b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e..HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
python <scratchpad>/jacoco.py artifacts/pester/powershell-coverage.xml
cmp -s <repo path> extensions/drm-copilot/resources/<surface>/<repo path>   # 20 pairs
git grep -n -i -F -e "per-batch" -e "batch cap" -e "smaller batches" -e "split the work" -e "new batch" -e "three-test" -- <AC-13 pathspecs>
MSYS_NO_PATHCONV=1 git grep -n -F "/orchestrate" -- <AC-15 files>
git grep -n -F "powershell-orchestrator" -- <AC-15 files>
git grep -n -F '$env:CLAUDE_' -- .codex/hooks/enforce-powershell-batch-budget.ps1
git diff --stat b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e HEAD -- .github/copilot-instructions.md .github/instructions
wc -l <changed PowerShell files>
poetry run pytest -q -rf <six parity suites>
git archive HEAD | tar -x -C <scratchpad>/clean && python -m pytest -q <six parity suites>   # run inside the snapshot
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
```

**For PowerShell:**
```powershell
# Formatting (check-only, PoshQC semantics)
Invoke-Formatter -ScriptDefinition ((Get-Content $f -Raw) -replace "`r?`n", "`n") -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting
Invoke-ScriptAnalyzer -Path $f -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing
Invoke-Pester -Configuration <Run.Path = six affected suites>

# Canonical toolchain (executor)
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-09-29  
**Policy Version:** Current (as of audit date)
