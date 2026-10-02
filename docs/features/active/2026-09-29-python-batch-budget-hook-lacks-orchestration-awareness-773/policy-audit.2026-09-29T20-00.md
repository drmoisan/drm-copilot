# Policy Compliance Audit: Python batch-budget hook orchestration awareness (#773)

---

**Audit Date:** 2026-09-29
**Code Under Test:** Branch `bug/python-batch-budget-hook-lacks-orchestration-awareness-773` (head `2c493e30a8825137bee7f9f48439e38b322ca815`) against `main` (merge-base `43c9e95eaa39b3d896a9da5501cd57953033c2bc`). 162 files changed (109 added, 50 modified, 3 renamed). Non-documentation changes:

- PowerShell production: `.claude/hooks/enforce-batch-budget-route.ps1` (renamed from `enforce-powershell-batch-budget-route.ps1`, functions renamed), `.codex/hooks/enforce-batch-budget-route.ps1` (new), `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`, plus byte-identical bundle mirrors under `extensions/drm-copilot/resources/`.
- PowerShell tests: `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` (new), `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` (new), `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1` (new), and modified `enforce-python-batch-budget.Tests.ps1`, `codex-batch-budget-hooks.Tests.ps1`, `enforce-powershell-batch-budget-routing.Tests.ps1`, `codex-powershell-batch-budget-routing.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`.
- PowerShell data: both `pester.runsettings.psd1` copies.
- JSON: `claude-customizations/pack-manifests/core.json`, `claude-customizations/pack-manifests/powershell.json`, `codex-and-agents-customizations/pack-manifests/core.json`.
- TOML/Markdown agent and skill text: Python router, invoke-python-engineer, invoke-powershell-engineer (`.agents`), python-typed-engineer (Claude, Codex and all Codex variants, Copilot), python-orchestrator (Codex, Copilot), orchestrate-python-work prompt, and their bundle mirrors.
- Documentation: feature folder, two new potential entries, and the promoted potential entry.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 22 files (.ps1/.psd1, incl. mirrors) | 445 tests (364 hook/routing/parity + 81 contract) | ✅ 445 pass, 0 fail | 95.35-97.73% lines per changed hook; 94.12% route helper | 95.45-98.99% lines per changed hook; 94.12% each route helper; 96.16% repo-wide | 94.12-100% changed lines per file |
| JSON | 3 files | pack-manifest completeness suites | ✅ parse and completeness pass | N/A (config files) | N/A (config files) | N/A |

Python, TypeScript, and C#: zero changed source files on the branch (`git diff --name-only 43c9e95e..HEAD -- '*.py'` printed nothing; no `.ts` or `.cs` file is in the diff). Their coverage verdicts are N/A because no file of those languages changed.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero changed TypeScript files)
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/evidence/baseline/claude-python-hook-coverage.2026-09-29T19-00.md` and the three sibling `*-hook-coverage.2026-09-29T19-00.md` files
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (canonical) plus `evidence/qa-gates/route-helper-coverage.2026-09-29T21-02.md` for the two new helper files
- Per-language comparison summary: Section 1.2.1 and `evidence/qa-gates/coverage-comparison.2026-09-29T21-11.md`

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the resolved base branch, merge-base, head SHA, feature folder, and work mode, and requested the full feature-review workflow. The audit scope is the full branch diff `43c9e95eaa39b3d896a9da5501cd57953033c2bc..2c493e30a8825137bee7f9f48439e38b322ca815`.

## Evidence Location Compliance

- Diff scan: `git diff --name-only 43c9e95e..HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` returned no path.
- Validator: `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- All execution evidence is under `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Verdict: PASS. No FAIL-level evidence-location finding.

## Modified-Workflow Rule

`git diff --name-only 43c9e95e..HEAD -- .github/workflows .github/actions scripts/benchmarks` printed nothing. The `modified-workflow-needs-green-run` rule does not fire.

---

## Executive Summary

The branch extends the #769 orchestration-aware routing model to the Claude and Codex Python batch-budget hooks, extracts the route predicate into one language-neutral helper (`enforce-batch-budget-route.ps1`) shared by both PowerShell and Python hooks in each runtime, removes the Python cap overrides and test-file counting, and rewrites Python-scoped agent, skill, and prompt text to the routing model. All changed code is PowerShell; the remaining changes are JSON manifests, TOML/Markdown instruction surfaces, and feature documentation.

The reviewer independently re-ran the PowerShell analyzer, formatter check, the nine hook/routing/parity Pester suites with coverage, the three named contract suites, the full `tests/scripts/dev_tools` pytest suite in a clean `git archive` snapshot, mirror byte-parity checks, line counts, and every grep-based acceptance check. All passed. No Blocking finding was identified. Two Minor findings and two Nit findings are recorded in the code review and do not require remediation before merge.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no `.py` file changed; Python-scoped instruction text changed but carries no toolchain obligation)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: shfmt + shellcheck + bats (no shell file changed)
- ✅ JSON: parse check and pack-manifest completeness suites

Toolchain summary: Invoke-Formatter drift 0 of 22 files; PSScriptAnalyzer findings 0 of 22 files; Pester 364/364 (hook, routing, parity suites) and 81/81 (PreToolUse schema, Codex transport, Codex epic runtime contracts); pytest `tests/scripts/dev_tools` 5252 passed, 6 skipped, 0 failed in a clean snapshot; TypeScript manifest-completeness twin 16/16 per executor evidence.

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted (plan scratch scripts lived under the session scratchpad; `git status` is clean and the diff contains no scratch script)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (no new tooling script was added)
- Reviewer scratch scripts (`route-cov.ps1`, `qa-checks.ps1`, `cov.py`, and the `snap773` snapshot) were written to the session scratchpad only.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New suites build per-test stores in `BeforeEach` and inject all I/O through scriptblock seams (`ReadCheckpoint`, `ReadState`, `WriteState`, `TestPathExists`, `EnsureDirectory`, `ReadSessionIdFile`). No shared mutable state across `It` blocks. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Routing suites are organized by `Context` per behavior (direct mode, large path, precedence, fail-closed, test-path classification, legacy state, deny text). The parity suite isolates helper identity from predicate behavior. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The nine suites (364 tests) and three contract suites (81 tests) ran in a single reviewer session without timeouts; no test waits on wall-clock time. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, or live checkpoint is read. The Codex shared Context injects an empty checkpoint for the Python row (AC-11). Reviewer grep for `orchestrator-state.json` in new suites finds only assertions on the injected path string `/repo/artifacts/orchestration/orchestrator-state.json`. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Data-driven `-ForEach` tables name each case (for example `route_id null with path_selected large`). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** CPYHOOK 95.35%, XPYHOOK 96.55%, CPSHOOK 95.45%, XPSHOOK 97.73%, old route helper 94.12% lines<br>**Command:** scratch `pester-coverage.ps1` per plan P0-T15..P0-T18<br>**Timestamp:** 2026-09-29 19:00<br>**Artifacts:** `evidence/baseline/*-hook-coverage.2026-09-29T19-00.md` |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** CPYHOOK 95.45%, XPYHOOK 98.99%, CPSHOOK 95.45%, XPSHOOK 98.99%, each route helper 94.12%<br>**Change:** +0.10, +2.44, 0.00, +1.26, 0.00 percentage points<br>**Status:** No regression. Reviewer re-run reproduced every post-change figure. |
| **New Code Coverage ≥85% (uniform rule)** | ✅ PASS | **New/modified files:** both route helpers (new), four hooks (modified)<br>**New/changed-line coverage:** CPYHOOK 100%, CPSHOOK 100%, XPYHOOK 98.11%, XPSHOOK 100%, CROUTE 94.12%, XROUTE 94.12%<br>**Calculation method:** changed lines from `git diff` against BASE_SHA `91805f15` intersected with Pester missed-command lines (`evidence/qa-gates/changed-line-coverage.2026-09-29T21-03.md`). `91805f15` is an ancestor of the merge-base and `git diff 91805f15..43c9e95e -- .claude/hooks .codex/hooks tests/scripts` is empty, so the comparison base is equivalent. |
| **Comprehensive Coverage** | ✅ PASS | All three route functions and every changed Python-hook function are exercised. Uncovered lines: route helper 136-137 (defensive catch in `Test-BatchBudgetLargePathRoute`, unchanged from the #769 helper); Claude Python hook 88 and 98 (whitespace path/root guards, pre-existing) and 484-489 (process entry wiring); Codex Python hook 341 (process entry wiring). |
| **Positive Flows** - Valid inputs | ✅ PASS | First three distinct production paths allowed; repeated path allowed without write; large/remediation/preparation routes allow any number of production paths. |
| **Negative Flows** - Invalid inputs | ✅ PASS | 4th distinct production path denied with `PYTHON_LARGE_PATH_REQUIRED`; unreadable envelope (Claude) and malformed JSON (Codex) fail closed, including under a large route. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Present-but-null or blank `route_id` with `path_selected: large`; wrong-case route; array and string JSON roots; terminal `next_step: complete`; `S12_complete` in `completed_steps`; legacy state with `prodCap`, `testCap`, `testFiles`. |
| **Error Handling** - Error paths | ✅ PASS | Throwing checkpoint reader, throwing state reader, and throwing state writer each yield direct-mode enforcement or a logged skip with exit 0. |
| **Concurrency** - If applicable | N/A | Hooks are single-invocation processes; no concurrent code path exists. |
| **State Transitions** - If applicable | ✅ PASS | Counter transitions 0 to 3 recorded, 4th denied; large path leaves state untouched; the state directory is not created on the large path (asserted through the `EnsureDirectory` seam). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.35% lines (lowest changed Python hook, CPYHOOK) -> Post-change: 95.45% lines. Change: +0.10% lines. New/changed-code coverage: 94.12% (lowest file, both route helpers). Disposition: PASS. Evidence: `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/evidence/qa-gates/coverage-comparison.2026-09-29T21-11.md`, `artifacts/pester/powershell-coverage.xml`.
- PowerShell repo-wide: 96.16% lines (10521 of 10941) from `artifacts/pester/powershell-coverage.xml`. Disposition: PASS (threshold 85%). No branch threshold applies to PowerShell.
- Python: zero changed files. Disposition: N/A.
- TypeScript: zero changed files. Disposition: N/A.
- C#: zero changed files. Disposition: N/A.

Canonical-artifact note: `artifacts/pester/powershell-coverage.xml` (generated 2026-09-29 19:43 local by the MCP PoshQC runner) contains the four changed hooks but not the two new route helpers, because the MCP runner reads the installed extension's `pester.runsettings.psd1`, which predates this branch. The branch runsettings (both copies) list both helpers. Helper coverage is taken from the direct Pester run recorded in `evidence/qa-gates/route-helper-coverage.2026-09-29T21-02.md`, which AC-27 names as the authoritative source for helper figures, and was reproduced by the reviewer (94.12% each, lines 136-137 missed).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Pester `Should -Be`/`-Match`/`-Not -Match` assertions on decision fields and deny text; data-driven case names appear in failure output. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Each `It` arranges a store and checkpoint text, invokes the hook once, and asserts decision and store effects. |
| **Document Intent** | ✅ PASS | Each new suite has a synopsis/description block; `It` names state the expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or external process. The parity suite reads the two helper files from the repository (read-only) to hash and dot-source them. |
| **Use Mocks/Stubs** | ✅ PASS | Filesystem and checkpoint access replaced by scriptblock seams; Codex entry point exercised in-process through `HookSeams`. |
| **Environment Stability** | ✅ PASS | Reviewer grep for `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `TestDrive`, `Set-Content`, `Out-File`, `New-Item` in the three new suites and in the added lines of the two modified Python-hook suites returned no match. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the pre-submission policy review for #773. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` state the defect (Python hooks lack checkpoint awareness) and the owner direction from #769. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-09-29T18-51.md` records the 16 policy files read in order. |
| **Document the plan** | ✅ PASS | `plan.2026-09-29T17-45.md` and `research/2026-09-29T18-00-python-batch-budget-routing-research.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The Python hooks mirror the #769 PowerShell structure; the large-path branch is a single early return. |
| **Reusability** | ✅ PASS | The route predicate is defined once per runtime in `enforce-batch-budget-route.ps1` and dot-sourced by all four hooks, replacing an inline Codex copy (`.codex/hooks/enforce-powershell-batch-budget.ps1` -124 lines). |
| **Extensibility** | ✅ PASS | Language-neutral function names allow a future C# hook to reuse the helper. |
| **Separation of concerns** | ✅ PASS | The helper is pure (text in, value out); checkpoint I/O stays in the hook behind the `ReadCheckpoint` seam. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One helper file per runtime with three route functions; hooks keep decision and entry logic. |
| **Under 500 lines** | ✅ PASS | Largest changed files: `legacy-codex-hook-contracts.Tests.ps1` 497, `.claude/hooks/enforce-python-batch-budget.ps1` 489, `.claude/hooks/enforce-powershell-batch-budget.ps1` 486, `enforce-python-batch-budget.Tests.ps1` 481. All under 500 (reviewer `wc -l`). |
| **Public vs internal** | ✅ PASS | No module manifest exports changed; hooks remain script entry points. |
| **No circular dependencies** | ✅ PASS | Hooks dot-source the helper; the helper dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `ConvertFrom-BatchBudgetCheckpoint`, `Get-BatchBudgetSelectedRoute`, `Test-BatchBudgetLargePathRoute`, `Invoke-PythonBatchBudgetCodexEntryPoint`. |
| **Docs/docstrings** | ✅ PASS | Both Python hook comment-based help blocks describe the routing model, test classification, legacy-key handling, and the stale-checkpoint limitation with the #673 mitigation. |
| **Comment why, not what** | ✅ PASS | For example, "The checkpoint is read before any state operation, so the large path neither creates the state directory nor reads or writes the state file." |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` compared to file text for all 22 changed `.ps1`/`.psd1` files<br>**Result:** FORMAT_DRIFT=0 |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` for all 22 files<br>**Result:** ANALYZER_FINDINGS=0 |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-Pester` (Configuration with the nine hook/routing/parity suites and CodeCoverage) and a second run of the three contract suites<br>**Result:** 364/364 and 81/81 passed |
| **Full toolchain loop** | ✅ PASS | Executor evidence records format/analyze/test per phase (`format-p*.md`, `analyze-p*.md`) and a final pass (`powershell-format.2026-09-29T20-57.md`, `powershell-analyze.2026-09-29T20-58.md`); reviewer re-run produced no changes and no findings. |
| **Explicit reporting** | ✅ PASS | Commands listed here and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | 13 commits with `(773)` scope; see Section 9. |
| **Design choices explained** | ✅ PASS | `spec.md` "Proposed Fix" and research Sections 2, 3, 6, 8. |
| **Update supporting documents** | ✅ PASS | Python router, invoke skills, engineer and orchestrator agents, and prompt updated with mirrors; two follow-up potential entries recorded (AC-29). |
| **Provide next steps** | ✅ PASS | Follow-ups recorded in `docs/features/potential/2026-09-29-python-execution-only-typed-per-batch-cap.md` and `docs/features/potential/2026-09-29-generic-orchestrator-test-file-routing-clause.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** Invoke-Formatter with `pssa.settings.psd1` on 22 changed files<br>**Result:** no drift |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** Invoke-ScriptAnalyzer with `pssa.settings.psd1` on 22 changed files<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | No findings. Retained `PSReviewUnusedParameter` suppressions on the ignored `TestCap` parameters carry justifications (see code review Nit). |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Hooks declare PowerShell 7+ in `.NOTES`, consistent with the existing hook runtime; test suites use `#Requires -Version 7.0`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every new or changed function has `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `[AllowNull()]`/`[AllowEmptyString()]` on checkpoint text; `[Parameter(Mandatory)]` on required inputs. |
| **Avoid global state** | ✅ PASS | No global variables; the Codex hook no longer reads `$env:CLAUDE_*` (grep returned no match). |
| **Error handling** | ✅ PASS | Checkpoint read and parse failures are caught, logged with `Write-Verbose`, and treated as direct mode; the Codex entry point writes errors to stderr and returns 2. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | See 2.3. |
| **Approved verbs** | ✅ PASS | `ConvertFrom`, `Get`, `Test`, `Invoke`, `ConvertTo` are approved; analyzer `PSUseApprovedVerbs` reported nothing. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | FORMAT_DRIFT=0. |
| **Step 2: Analyze** | ✅ PASS | ANALYZER_FINDINGS=0. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 445 of 445 tests passed across twelve suites. |
| **Rerun loop if needed** | ✅ PASS | Single reviewer pass; no auto-fix occurred. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | **Command:** `python -c "json.load(...)"` on the three changed manifests<br>**Result:** all parse. Changes are single-line array entries matching existing formatting. |
| **Schema validation** | ✅ PASS | **Command:** pack-manifest completeness suites (`test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `claude-pack-manifest-completeness.test.ts`)<br>**Result:** pass (clean-snapshot pytest run; executor TypeScript evidence 16/16) |
| **Required $schema** | N/A | Pack manifests are not schema-governed files. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Parsed by the Python `json` module. |
| **Deterministic key order** | ✅ PASS | Only array entries changed; object keys unchanged. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `BeforeAll`/`BeforeEach`/`Describe`/`Context`/`It` with `-ForEach`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` (executor, `evidence/qa-gates/powershell-mcp-test.2026-09-29T20-59.md`)<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` updated to list both new helpers and drop the old helper path; bundle copy identical. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Suites target PowerShell 7 as the hook runtime does. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Routing suites 368 and 389 lines; parity suite 87 lines. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions target decisions, deny text, and seam call effects (state read/write/directory creation). |
| **Mocking Used Sparingly** | ✅ PASS | Only I/O seams are replaced. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1`<br>**Code files:** `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`, both route helpers<br>Placement follows the existing `claude-hooks`/`codex-hooks` convention used by the #769 suites. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All three new files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per suite; `Context` per behavior group. |
| **Logical Grouping** | ✅ PASS | Direct mode, large path, precedence, fail-closed, classification, legacy state, deny text. |
| **Docstrings/Comments** | ✅ PASS | Suite-level comment-based help present. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** MCP PoshQC test (executor) and direct `Invoke-Pester` with the same settings (reviewer)<br>**Result:** 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### Route helper `enforce-batch-budget-route.ps1` (55 parity-suite tests plus routing-suite cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| keeps the Claude and Codex route helpers byte-identical | Positive | whole file (hash) | ✅ |
| route_id large / remediation / preparation | Positive | 106-133 | ✅ |
| route_id null with path_selected large; route_id small wins | Edge Case | 76-90 | ✅ |
| malformed JSON; array JSON; string JSON; empty/whitespace | Negative | 36-52 | ✅ |
| terminal next_step complete; terminal S12_complete | Edge Case | 124-130 | ✅ |

**Coverage:** 94.12% (32 of 34 analyzed lines) per copy.

**Not covered:** lines 136-137 (defensive `catch` in `Test-BatchBudgetLargePathRoute`; no input reaches it because `ConvertFrom-BatchBudgetCheckpoint` absorbs parse failures). Unchanged from the #769 helper.

### Python hooks (Claude and Codex)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| direct mode allows three distinct production paths and denies the 4th | Positive/Negative | decision function | ✅ |
| large-path routes allow without reading, writing, or creating state | Positive | hook large-path branch | ✅ |
| deny reason names the routing target and omits removed phrases | Negative | deny reason construction | ✅ |
| legacy state with prodCap/testCap/testFiles loads | Edge Case | state conversion | ✅ |
| throwing checkpoint reader yields direct mode | Error Handling | checkpoint read catch | ✅ |

**Coverage:** Claude 95.45% (126 of 132), Codex 98.99% (98 of 99).

**Not covered:** Claude lines 88, 98 (pre-existing whitespace guards) and 484-489 (process entry wiring); Codex line 341 (process entry wiring).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 445 (PowerShell) + 5252 pytest (clean snapshot) | ✅ |
| Tests Passed | 445 (100%) PowerShell; 5252 pytest | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Not separately timed; single reviewer run completed without timeout | ✅ Fast |
| Average Time per Test | Not separately timed | ✅ Fast |
| Discovery Time | Not separately timed | ✅ |
| Functions/Classes Tested | 3/3 route functions; all changed hook functions | ✅ |
| Test File Size | 87-497 lines | ✅ Maintainable |
| Code Coverage (if applicable) | 94.12-98.99% lines per changed file; PowerShell has no branch metric | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -Settings pssa.settings.psd1` (22 files) | 0 drift | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` (22 files) | 0 findings | ✅ |
| Pester Tests | `Invoke-Pester` (12 suites) | 445/445 | ✅ |

**For Python (regression only; no `.py` changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Pytest Tests | `python -m pytest -q tests/scripts/dev_tools` in a `git archive HEAD` snapshot | 5252 passed, 6 skipped, 0 failed | ✅ |

**Notes:**
In the working tree, `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails on the gitignored `.claude/state/current-session-id` file (known issue #510, recorded by the executor as `KL-510: STATE-ONLY`). The clean-snapshot run passes that test, which confirms the bundle and repo runtime contracts match at HEAD.

---

## 8. Gaps and Exceptions

### Identified Gaps
**None.** All policy requirements are met. Two Minor and two Nit findings are recorded in `code-review.2026-09-29T20-00.md`; none is a policy failure.

### Approved Exceptions
**None.** No exceptions needed.

Process deviation (reviewer tooling): the MCP `resolve_policy_audit_template_asset` tool is not available in this reviewer session. The templates were taken from the same bundled assets at `extensions/drm-copilot/resources/templates/policy_audit/`.

### Removed/Skipped Tests
**None.** All planned tests implemented. The 6 pytest skips are pre-existing and outside the changed scope.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **43020508** - docs(773): promote Python batch-budget routing bug and add planning artifacts
2. **daf9c403** - refactor(773): share a language-neutral batch-budget route helper in the Claude runtime
3. **bb869e05** - test(773): add Claude Python batch-budget routing regression tests
4. **9af8b8bb** - fix(773): route over-budget Python changes to the large path in the Claude hook
5. **ca702882** - refactor(773): load the shared route helper in the Codex PowerShell hook
6. **7dc1cc27** - test(773): add Codex Python batch-budget routing regression tests
7. **363ae79f** - fix(773): route over-budget Python changes to the large path in the Codex hook
8. **7861c723** - docs(773): state the Python routing rule on Claude and Copilot surfaces
9. **b5c70cc1** - docs(773): remove per-batch text from Codex and .agents Python surfaces
10. **86c291da** - docs(773): record Python routing follow-up potential entries
11. **26766bcb** - docs(773): record final QA evidence
12. **d5409c1f** - docs(773): check off acceptance criteria
13. **2c493e30** - docs(773): end the Python router documentation list with a period

### Files Modified

1. **`.claude/hooks/enforce-batch-budget-route.ps1`** (RENAMED from `enforce-powershell-batch-budget-route.ps1`) and **`.codex/hooks/enforce-batch-budget-route.ps1`** (NEW)
   - Language-neutral route helper; byte-identical copies.
2. **`.claude/hooks/enforce-python-batch-budget.ps1`**, **`.codex/hooks/enforce-python-batch-budget.ps1`** (MODIFIED)
   - Checkpoint-aware routing, production-only counting, cap overrides removed, routing deny text; Codex exposes `Invoke-PythonBatchBudgetCodexEntryPoint`.
3. **`.claude/hooks/enforce-powershell-batch-budget.ps1`**, **`.codex/hooks/enforce-powershell-batch-budget.ps1`** (MODIFIED)
   - Dot-source the shared helper; Codex inline route functions removed.
4. **Test suites** (3 NEW, 5 MODIFIED) under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`.
5. **Pack manifests and runsettings** (MODIFIED) - helper registration.
6. **Python instruction surfaces** (MODIFIED) - routing text on Claude, Codex, `.agents`, and Copilot surfaces with bundle mirrors; Codex variants regenerated.
7. **Documentation** (NEW) - feature folder, evidence, two potential entries; promoted potential entry moved.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All applicable general, PowerShell, and JSON policy checks pass with reviewer-reproduced evidence. PowerShell coverage is at or above 85% for every changed file, new-file coverage is 94.12%, repo-wide PowerShell coverage is 96.16%, and there is no regression on changed lines. No Blocking finding exists.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan, research, and policy-read record present
- ✅ Design Principles: shared helper removes duplication
- ✅ Module & File Structure: all files under 500 lines
- ✅ Naming, Docs, Comments: routing model and #673 limitation documented
- ✅ Toolchain Execution: format, analyze, test clean
- ✅ Summarize & Document: follow-up entries recorded

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: 0 drift, 0 findings
- ✅ PowerShell Design & Safety: advanced functions, seams, fail-closed parsing
- ✅ Structure & Naming: approved verbs, neutral helper names
- ✅ Toolchain: single clean pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: seam-injected, deterministic
- ✅ Coverage & Scenarios: all thresholds met, no regression
- ✅ Test Structure: AAA, data-driven cases
- ✅ External Dependencies: no temp files, no live checkpoint
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5
- ✅ Test Style & Structure: behavior-focused
- ✅ Naming & Readability: `.Tests.ps1`, named cases
- ✅ Toolchain: 445/445

---

### Metrics Summary

- ✅ 445/445 PowerShell tests passing (100%)
- ✅ 5252 pytest passed, 0 failed in clean snapshot
- ✅ 94.12-98.99% line coverage per changed PowerShell file; 96.16% repo-wide
- ✅ Changed-line coverage 94.12-100%
- ✅ All code quality checks passing
- ✅ All mirrors byte-identical (18 pairs checked with `cmp`)

---

### Recommendation

**Ready for merge**

No Blocking or Major finding. The two Minor findings (residual user-approval scope-expansion clause in `.github/agents/python-typed-engineer.agent.md`; session-id file read before the large-path check in the Claude Python hook) can be handled as follow-ups. Normal PR flow and the CI S9 gate apply.

---

## Appendix A: Test Inventory

### Complete Test List

1. `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1` › batch-budget route helper parity › byte identity; per-runtime function set; 21 predicate cases; selected-route cases (55 tests)
2. `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` › direct mode, large path, precedence, fail-closed, classification, legacy state, deny text
3. `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` › same groups for the Codex hook and entry point
4. `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` › existing behaviors updated for routing
5. `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` › unchanged PowerShell regression
6. `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` › shared Codex Context (Python row injects an empty checkpoint)
7. `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` › #769 routing suite (function renames only)
8. `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` › #769 routing suite (function renames only)
9. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` › shared-module list, byte identity, core manifest, 500-line checks
10. `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` (81 tests)

Suites 1-9 total 364 tests.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (reviewer re-run):**
```powershell
# Formatting and linting over the 22 changed .ps1/.psd1 files
$files = git diff --name-only --diff-filter=AMR 43c9e95eaa39b3d896a9da5501cd57953033c2bc HEAD -- '*.ps1' '*.psd1'
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
foreach ($f in $files) { Invoke-ScriptAnalyzer -Path $f -Settings $settings }
foreach ($f in $files) { $t = Get-Content $f -Raw; (Invoke-Formatter -ScriptDefinition $t -Settings $settings) -ne $t }

# Testing with coverage (nine hook/routing/parity suites)
$c = New-PesterConfiguration
$c.Run.Path = @('tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1', '...')
$c.CodeCoverage.Enabled = $true
$c.CodeCoverage.Path = @('.claude/hooks/enforce-batch-budget-route.ps1', '.codex/hooks/enforce-batch-budget-route.ps1', '.claude/hooks/enforce-python-batch-budget.ps1', '.codex/hooks/enforce-python-batch-budget.ps1', '.claude/hooks/enforce-powershell-batch-budget.ps1', '.codex/hooks/enforce-powershell-batch-budget.ps1')
Invoke-Pester -Configuration $c

# Contract suites
Invoke-Pester -Path tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1, tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1, tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1

# Executor MCP step
mcp__drm-copilot__run_poshqc_test
```

**Python regression (clean snapshot):**
```bash
git archive HEAD | tar -x -C <scratchpad>/snap773
<repo-venv>/python -m pytest -q -rf -p no:cacheprovider --rootdir <scratchpad>/snap773 <scratchpad>/snap773/tests/scripts/dev_tools
```

**Parity, scope, and evidence checks:**
```bash
cmp .claude/hooks/enforce-batch-budget-route.ps1 .codex/hooks/enforce-batch-budget-route.ps1
cmp <runtime file> extensions/drm-copilot/resources/<pack>/<runtime file>   # 18 pairs
git diff --name-only 43c9e95e..HEAD -- '*.py' .github/copilot-instructions.md .github/instructions .github/agents/python-execution-only-typed.agent.md scripts/dev_tools/resolve_codex_topology.py extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts
git diff --name-only 43c9e95e..HEAD -- .github/workflows .github/actions scripts/benchmarks
python scripts/dev_tools/validate_evidence_locations.py --root .
python <scratchpad>/cov.py   # parses artifacts/pester/powershell-coverage.xml LINE counters (reviewer scratch)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-29
**Policy Version:** Current (as of audit date)
