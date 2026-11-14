# Policy Compliance Audit: PreToolUse hook dispatcher (issue #1159)

---

**Audit Date:** 2026-11-14  
**Code Under Test:** merge base `2c8dee6dd3a82f210561d9efe623767ae902de51` of the base branch `origin/main` and reviewed head `9478c4b659092881c0db1fe2e8e04f90bfad3189`; the diff between them lists the changed files (241 files, 9844 insertions, 969 deletions)

Review context: re-audit (R4) of main-sync remediation cycle 1 (`remediation-inputs.2026-11-14T06-51.md`, `remediation-plan.2026-11-14T06-51.md`) and concurrent review of PR #1177. Scope is the full branch diff against the merge base, not the cycle. Scope sources: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-11-14 07:56:52 UTC at the reviewed head) and `git diff --name-status 2c8dee6dd..9478c4b65`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 87 files (production hooks, modules, scripts, bundle mirrors and tests) | 24357 tests | ✅ 24341 pass, 0 fail, 16 skipped | 95.80% lines (37558/39203) | 95.99% lines (40789/42491) | 98.59% (631/640 lines over the 7 new production files) |
| Python | 3 test files | 16723 tests | ✅ 16723 pass, 0 fail, 6 skipped | 97.11% lines, 94.37% branches | 97.13% lines, 94.42% branches | N/A - no production Python file changed |
| TypeScript | 0 files | 0 tests | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |
| JSON / TOML | 9 files | N/A | ✅ registry, settings and manifest tests pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - zero changed TypeScript files`
- TypeScript post-change coverage artifact: `N/A - zero changed TypeScript files`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/baseline/pester.2026-11-10T04-30.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (recorded in `evidence/qa-gates/pester.2026-11-14T07-45.md`)
- Python baseline coverage artifact: `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/baseline/pytest.2026-11-11T04-11.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` and `artifacts/python/coverage-final.json` (recorded in `evidence/qa-gates/pytest.2026-11-14T07-50.md`)
- Per-language comparison summary: section 1.2.1 of this audit

Baseline coverage is read from the plan's `Phase 0 baseline` artifacts. The reviewer parsed `artifacts/pester/powershell-coverage.xml` directly: the root LINE counter is 40789/42491 (95.99%) and the per-file figures of the 7 new production files match the evidence table exactly. The reviewer parsed `artifacts/python/coverage-final.json`: 34574/35595 lines and 12785/13540 branches, matching the evidence. The Pester artifact was written at 07:44 UTC; the only production edit of cycle 1 (`.claude/hooks/enforce-model-routing-receipt-docs.ps1`) was made at [P1-T1] (07:26 UTC), before the run, and the head commit adds no further production change. Because the coverage Stop hook compares the artifact write time with the head commit time, the reviewer reran `Invoke-PoshQCParallelTest` once in the item worktree at the reviewed head (08:12-08:27 UTC, `evidence/qa-gates/pester.2026-11-14T08-27.md`). The rerun gave identical results: 24357 tests, 0 failures, 95.99% (40789/42491), with unchanged per-file figures. Rerunning coverage departs from the reviewer's evidence-only model; the hook required it.

---

## Executive Summary

The branch replaces the per-hook PreToolUse registrations of both runtimes with one dispatcher process per tool call (`.claude/hooks/invoke-pretooluse-dispatch.ps1`, `.codex/hooks/invoke-pretooluse-dispatch.ps1`, `.codex/hooks/hook-dispatch.ps1`, `.claude/lib/hook-dispatch/HookDispatch.psm1`, `.claude/lib/hook-dispatch/HookDispatchRunner.psm1`), adds generated registries (`pretooluse-dispatch.json`), a process-cost measurement tool (`scripts/dev-tools/HookProcessCost.psm1`, `scripts/dev-tools/Measure-HookProcessCost.ps1`), a process-level parity suite, the D6 `-Force` removals and D13 tail rewrites in dispatched hooks, bundle mirrors, pack manifests and documentation.

Local gate evidence is green: one `Invoke-PoshQCParallelTest` run (24357 tests, 0 failures), one `pytest -n auto` run (16723 passed), leak scan (0 failures, no allowlist change), PowerShell and Python static loops (0 findings). Coverage meets the 85% line threshold for every changed production PowerShell file with no regression against the Phase 0 baseline.

CI on the reviewed head and on the predecessor heads shows two branch-caused failures that the local gate set did not exercise:

1. `quality-checks7 / Code Quality & Tests` fails at `tier-classification` with `QT008: discovered project '.claude/lib/hook-dispatch' has no entry` (reproduced locally at the reviewed head; the same command on the main checkout reports `quality-tiers: OK`).
2. `root-typescript-tests` and `drm-copilot-extension-tests` fail in `extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts` (`expect(required.length).toBeGreaterThan(21)`, received 10), because the test helper `collectRegisteredHookClosure` derives registered hooks only from `.codex/config.toml` command lines and does not read the new Codex registry. The Python twin of this guard (`tests/scripts/dev_tools/test_codex_core_manifest_closure.py`) was updated on the branch; the TypeScript twin was not.

Both findings are blocking and autonomous. Verdict: REMEDIATION_REQUIRED.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md`
- ✅ `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` (no production Python file changed) + ✅ `python-unit-test.instructions.md`
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no `.sh` or `.bats` file in the branch diff
- ✅ JSON: registries, settings and pack manifests parsed by the Pester and pytest suites

**Temporary artifacts cleanup:**
- ✅ Scratch scripts named in evidence (`SCRATCH/issue-1159-*.sh`) live in the issue scratch directory, outside the repository; none is in the branch diff.
- ✅ The new tooling script `scripts/dev-tools/Measure-HookProcessCost.ps1` and module `scripts/dev-tools/HookProcessCost.psm1` are tested (`tests/scripts/dev-tools/Measure-HookProcessCost.Tests.ps1`, `tests/scripts/dev-tools/HookProcessCost.Tests.ps1`).

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The full tree ran in 8 parallel shards with 0 failures (`pester.2026-11-14T07-45.md`); pytest ran under xdist (`-n auto`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | New suites target one unit each: `HookDispatch.Tests.ps1` (matcher, registry, combination), `HookDispatchRunner.Tests.ps1` (runner seams), `invoke-pretooluse-dispatch.Tests.ps1` (entry scripts), `HookProcessCost.Tests.ps1` (measurement module). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Full Pester tree 856.2 s wall across 8 workers; pytest 227.91 s. The parity suite starts real processes by design (spec AC) and is the slowest new suite. |
| **Determinism** - Consistent results | ✅ PASS | Runner tests inject the script-invoker, stdin-replayer and process-starter seams; `HookProcessCost.Tests.ps1` injects process-starter and timestamp seams with no wall-clock wait (spec AC line 169). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Describe/Context/It names state the behavior, for example `loads each stateless shared module once per call`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 95.80% lines; Python 97.11% lines, 94.37% branches<br>**Command:** `Invoke-PoshQCParallelTest`; `poetry run pytest -n auto`<br>**Artifact:** `evidence/baseline/pester.2026-11-10T04-30.md`, `evidence/baseline/pytest.2026-11-11T04-11.md`<br>**Timestamp:** 2026-11-10 04:30, 2026-11-11 04:11 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.99% lines; Python 97.13% lines, 94.42% branches<br>**Change:** +0.19% PowerShell lines; +0.02% Python lines, +0.05% Python branches<br>**Status:** No regression; no per-file drop against the baseline for the 48 listed PowerShell files |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest changed production file `scripts/dev-tools/Measure-HookProcessCost.ps1` 86.36% (38/44)<br>**Thresholds:** 85% line; no PowerShell branch threshold (Pester measures none)<br>**Status:** All changed production PowerShell files meet the threshold |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** 7 new production PowerShell files<br>**New code coverage:** 98.59% (631/640)<br>**Calculation method:** per-file LINE counters from `artifacts/pester/powershell-coverage.xml`, summed over the new files |
| **Comprehensive Coverage** | ✅ PASS | `HookDispatch.psm1` 100% (107/107); `HookDispatchRunner.psm1` 98.82% (84/85); `.codex/hooks/hook-dispatch.ps1` 99.35%; both entry scripts 100%; `HookProcessCost.psm1` 99.44%. Uncovered: 6 lines of the `Measure-HookProcessCost.ps1` entry wiring. |
| **Positive Flows** - Valid inputs | ✅ PASS | Allow envelopes per registry hook in the parity corpus; matcher admission tests for exact, list and regex matchers on both runtimes. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Deny envelopes per hook; schema-invalid registry and unresolved hook path yield `HOOK_DISPATCH_BLOCKED:` (spec AC line 190). Reviewer real-process probe: a non-JSON payload yields a `HOOK_DISPATCH_BLOCKED:` deny on both runtimes. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Codex `apply_patch` alias to `Edit`/`Write`; absent `isolation` field falls back to per-process; empty tool name. |
| **Error Handling** - Error paths | ✅ PASS | Exit 2 maps to deny with stderr reason; other exit codes, invalid JSON and terminating errors map to no decision (spec AC line 188). |
| **Concurrency** - If applicable | N/A | The dispatcher runs hooks sequentially in one process; no shared concurrent state. |
| **State Transitions** - If applicable | ✅ PASS | Runner restores stdin, console writers, location, strict mode and `$ErrorActionPreference` after each hook; covered by runner tests. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.99% lines. Change: +0.19% lines. New/changed-code coverage: 98.59% lines. Disposition: PASS. Evidence: `evidence/baseline/pester.2026-11-10T04-30.md`, `evidence/qa-gates/pester.2026-11-14T07-45.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 97.11% lines (from the `Phase 0 baseline` artifact) -> Post-change: 97.13% lines. Change: +0.02% lines, branches 94.37% to 94.42%. No Python production file changed. Disposition: PASS. Evidence: `evidence/baseline/pytest.2026-11-11T04-11.md`, `evidence/qa-gates/pytest.2026-11-14T07-50.md`, `artifacts/python/lcov.info`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Parity assertions use `-Because` text naming runtime and envelope; repeated module loads are reported as `<path> x<count>`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New suites carry `# Arrange`, `# Act`, `# Assert` sections. |
| **Document Intent** | ✅ PASS | Suites carry header comments naming issue #1159 and the spec decision they prove. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Unit suites use seams. The parity suite starts `pwsh` child processes by spec requirement (process-level parity, spec AC line 186). |
| **Use Mocks/Stubs** | ✅ PASS | Script-invoker, stdin-replayer, process-starter and timestamp seams are injected as scriptblocks. |
| **Environment Stability** | ✅ PASS | No temporary files are created by the new unit suites (spec AC line 169); payloads are replayed from memory. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the policy review for PR #1177. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1159; `spec.md` decisions D1-D15. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-09T16-31.md`; cycle 1 `remediation-plan.2026-11-14T06-51.md`. |
| **Document the plan** | ✅ PASS | Plan, task-check evidence and integration records under `evidence/other/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Each hook script runs unchanged with `&` in its own script scope (D2); no re-implementation of hook logic. |
| **Reusability** | ✅ PASS | Registry reading, matcher selection and decision combination live in `HookDispatch.psm1`, shared by the Claude entry script. |
| **Extensibility** | ✅ PASS | New hooks are registered in the registry; `isolation` knob reverts to per-process with one data edit (D14). |
| **Separation of concerns** | ✅ PASS | Pure selection and combination logic in `HookDispatch.psm1`; process and console I/O in `HookDispatchRunner.psm1`; thin entry scripts. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One module per concern under `.claude/lib/hook-dispatch/`. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest covered file in the diff is `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` at 593 logical lines; no file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | `Export-ModuleMember` limits the runner surface to `Invoke-HookDispatchRunner` and `Invoke-HookDispatchChildProcess`. |
| **No circular dependencies** | ✅ PASS | `HookDispatchRunner.psm1` imports `HookDispatch.psm1`; no reverse import. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs (`Invoke-`, `Get-`, `ConvertTo-`, `Select-`, `Resolve-`, `Read-`). |
| **Docs/docstrings** | ✅ PASS | Comment-based help on exported functions; README, architecture doc and six execution-environment brief copies updated. |
| **Comment why, not what** | ✅ PASS | For example the runner comment explaining why strict mode is reset before a hook runs. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter` (check mode); `poetry run black --check`<br>**Result:** 0 changes (`powershell-static.2026-11-14T07-29.md`, `python-static.2026-11-14T07-29.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer`; `poetry run ruff check`<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright` on the 3 changed Python test files<br>**Result:** 0 errors; N/A for PowerShell |
| **4. Testing** | ❌ FAIL | **Command:** `Invoke-PoshQCParallelTest`; `pytest -n auto`<br>**Result:** both green locally, but the root Jest suite (`codex-bundle-publish.integration.test.ts`) fails in CI because of this branch, and the local gate set did not run Jest. See finding F2. |
| **Full toolchain loop** | ❌ FAIL | The CI `tier-classification` stage fails with QT008 for the new `.claude/lib/hook-dispatch` folder (finding F1); no local gate ran `check_quality_tiers`. |
| **Explicit reporting** | ✅ PASS | Each gate has append-only evidence with `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | PR #1177 body (`artifacts/pr_body_1159.md`, equal to the posted body apart from a trailing newline). |
| **Design choices explained** | ✅ PASS | Spec decisions D1-D15 and the PR body Design section. |
| **Update supporting documents** | ✅ PASS | `README.md`, `docs/engineering/claude-code-architecture.md`, six brief copies. |
| **Provide next steps** | ✅ PASS | Remediation inputs list F1 and F2. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check` on 3 files<br>**Result:** 3 files unchanged |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors, 0 warnings |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov --cov-branch`<br>**Result:** 16723 passed, 6 skipped |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | `registry_hook_paths(registry_text: str) -> set[str]`; `registry_text: str \| None = None`. |
| **Dataclasses for value objects** | N/A | Test helper functions only. |
| **Protocols/ABCs for interfaces** | N/A | Test helper functions only. |
| **Avoid utility classes** | ✅ PASS | Module-level functions. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | No broad catches added. |
| **Logging over print** | N/A | Test code. |
| **Invariants at construction** | N/A | Test code. |

---

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter` with `pssa.settings.psd1`<br>**Result:** 0 files changed (`powershell-static.2026-11-14T07-29.md`; full-diff passes in `powershell-static.2026-11-14T06-12.md`) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** 0 findings; CI `poshqc / PowerShell QC static` passed at the reviewed head |
| **Fix all findings** | ✅ PASS | No findings outstanding. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Repository requires PowerShell 7+; hooks run under `pwsh`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and typed parameters on exported functions. |
| **Parameter validation** | ✅ PASS | `[Parameter(Mandatory)]`, `[AllowEmptyString()]` used on runner parameters. |
| **Avoid global state** | ✅ PASS | The runner sets the global `LASTEXITCODE` sentinel because hook scripts report exit codes through it; it is read back and reset per hook. |
| **Error handling** | ✅ PASS | Dispatcher self-failure fails closed with `HOOK_DISPATCH_BLOCKED:` (D8). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest changed production file 535 logical lines (`.claude/hooks/enforce-python-batch-budget.ps1`, pre-existing size). |
| **Approved verbs** | ✅ PASS | PSScriptAnalyzer `PSUseApprovedVerbs` reports 0 findings. |
| **Comment why** | ✅ PASS | Comments state rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 changes. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 24357 tests, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | Pass 1 clean in cycle 1. |

---

### Section 3D: JSON Configuration Policy Compliance (if applicable)

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | N/A | Registries are generated (D10) and validated by tests rather than reformatted. |
| **Schema validation** | ✅ PASS | Registry schema validated by `Read-HookDispatchRegistry` tests; byte-equal regeneration from the merge-base registrations (`main-sync-registrations.2026-11-14T07-09.md`). |
| **Required $schema** | N/A | The registries reuse the settings shape and are not governed by a `$schema` rule. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Parsed by `ConvertFrom-Json` and `json.loads` in the gates. |
| **Deterministic key order** | ✅ PASS | Generated in registration order by rule D10. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | pytest with xdist. |
| **Coverage expectation** | ✅ PASS | Repo-wide 97.13% lines, 94.42% branches locally; the CI step `Enforce Python coverage thresholds` was skipped at the reviewed head because `tier-classification` failed first (see `## CI Cross-check`). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | New tests in `test_codex_core_manifest_closure.py` cover the registry roots. |
| **Mocking sparingly** | ✅ PASS | `read_text` callable injected. |
| **Organization** | ✅ PASS | Under `tests/scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_guard_reports_hook_absent_from_manifest` style. |
| **Docstrings/comments** | ✅ PASS | Google-style docstrings on helpers. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto`<br>**Result:** 16723 passed |
| **No Alternative Test Runners** | ✅ PASS | pytest only. |

---

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Pester through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Test Behavior Over Implementation** | ✅ PASS | Parity suite compares observable decisions, reasons and exit codes. |
| **Mocking Used Sparingly** | ✅ PASS | Seams injected instead of broad `Mock` use. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/hook-dispatch/HookDispatch.Tests.ps1`<br>**Code file:** `.claude/lib/hook-dispatch/HookDispatch.psm1`<br>Mirrors the source layout, as do the dev-tools and codex-hooks suites. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites use `.Tests.ps1`; corpus helpers are `.ps1` data files. |
| **Describe/Context/It Structure** | ✅ PASS | Describe per unit, Context per runtime or scenario. |
| **Logical Grouping** | ✅ PASS | Grouped by runtime and registry. |
| **Docstrings/Comments** | ✅ PASS | Header comments per suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Result:** 24357 tests, 0 failures, 16 skipped |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### HookDispatch.psm1 (unit suite `HookDispatch.Tests.ps1`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| matcher selection (exact, list, regex) | Positive | selection functions | ✅ |
| registry read failures yield `HOOK_DISPATCH_BLOCKED:` | Negative | registry reader | ✅ |
| decision precedence and reason joining | Edge Case | combination functions | ✅ |

**Coverage:** 100% (107/107 lines)

**Not covered:** None.

### HookDispatchRunner.psm1 (unit suite `HookDispatchRunner.Tests.ps1`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| in-process run through injected seams | Positive | in-process branch | ✅ |
| per-process run when isolation is absent | Positive | per-process branch | ✅ |
| terminating error maps to no decision | Error Handling | catch block | ✅ |

**Coverage:** 98.82% (84/85 lines)

**Not covered:** one line of the default process-starter body.

### Measurement tool (`HookProcessCost.psm1`, `Measure-HookProcessCost.ps1`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| scenario derivation from Registration and Dispatcher sources | Positive | derivation functions | ✅ |
| summary statistics and report formatting | Positive | statistics and formatter | ✅ |

**Coverage:** 99.44% and 86.36%

**Not covered:** 6 entry-wiring lines of `Measure-HookProcessCost.ps1`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 24357 Pester; 16723 pytest | ✅ |
| Tests Passed | 24341 Pester (16 skipped); 16723 pytest (6 skipped) | ✅ |
| Tests Failed | 0 locally; 1 Jest test fails in CI | ❌ |
| Execution Time | 856.2 s Pester; 227.91 s pytest | ✅ Fast |
| Average Time per Test | about 35 ms Pester per test (8 workers) | ✅ Fast |
| Discovery Time | not separately recorded by the gate | ✅ |
| Functions/Classes Tested | every exported function of the new modules | ✅ |
| Test File Size | 593 logical lines largest | ✅ PASS at or below 800 lines |
| Code Coverage (if applicable) | 95.99% PowerShell lines; 97.13% Python lines, 94.42% branches | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check` | 3 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 16723 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` check mode | 0 changes | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest -Root .` | 24357 tests, 0 failures | ✅ |

**Notes:**
- `poshqc / PowerShell QC static` fails on the main push run at the merge base (run 43559694003); it passed on this branch at the reviewed head, so that failure is pre-existing on main and not attributed to the branch.
- The tier-classification and Jest failures are attributed to the branch: both reproduce or trace to files the branch added or changed (findings F1, F2).

---

## CI Cross-check

CI run 43573314091 (workflow `CI`) was in progress on the reviewed head at review time. Rows record the outcome claimed from local evidence; the source column states what was observed in CI at review time.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| quality-checks7 / Code Quality & Tests (3.13) | fail | QT008 for `.claude/lib/hook-dispatch` (reproduced locally) | 9478c4b659092881c0db1fe2e8e04f90bfad3189 | local `check_quality_tiers --repo-root <worktree>`; CI step `tier-classification` failure observed |
| Enforce Python coverage thresholds | pass | 97.13% lines, 94.42% branches | 9478c4b659092881c0db1fe2e8e04f90bfad3189 | `evidence/qa-gates/pytest.2026-11-14T07-50.md`; CI step skipped after the tier failure |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | fail | 1 failed of 5571 (`codex-bundle-publish.integration.test.ts`) | 9478c4b659092881c0db1fe2e8e04f90bfad3189 | CI failure observed at this head; failure text read from run 43570680445 at f97b8e543, which has the same TypeScript and bundle content |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | fail | 1 failed of 5554 (same test) | 9478c4b659092881c0db1fe2e8e04f90bfad3189 | CI failure observed; same source as the row above |
| poshqc / PowerShell QC static | pass | 0 findings | 9478c4b659092881c0db1fe2e8e04f90bfad3189 | `evidence/qa-gates/powershell-static.2026-11-14T07-29.md`; CI pass observed |
| poshqc / PowerShell QC shard 1-3 | pass | 24357 tests, 0 failures | 9478c4b659092881c0db1fe2e8e04f90bfad3189 | `evidence/qa-gates/pester.2026-11-14T07-45.md`; CI pending at review time |
| poshqc / PowerShell hook suites (Linux) | pass | Windows run green; Linux CI-dependent | 9478c4b659092881c0db1fe2e8e04f90bfad3189 | `evidence/qa-gates/pester.2026-11-14T07-45.md`; CI pending at review time, success at predecessor f97b8e543 |

---

## Evidence Location Compliance

`validate_evidence_locations --root <worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. All evidence is under `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/<kind>/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists at the repository root and CI runs the `tier-classification` stage, so tiers are adopted. The new project folder `.claude/lib/hook-dispatch` has no entry (finding F1).

---

## 8. Gaps and Exceptions

### Identified Gaps
- F1 (Blocking): `quality-tiers.yml` lacks an entry for `.claude/lib/hook-dispatch`; CI `tier-classification` fails with QT008.
- F2 (Blocking): `extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts` `collectRegisteredHookClosure` reads only `.codex/config.toml` command lines, so `codex-bundle-publish.integration.test.ts` fails once the Codex PreToolUse hooks move into `.codex/hooks/pretooluse-dispatch.json`. This is a test that pinned the per-hook registration shape (spec AC line 203) and a push-down dependency-closure test (spec AC line 201).

### Approved Exceptions
- D13 tail rewrites in dispatched hooks are the spec's separately evidenced exception to the hook-file edit rule (`evidence/regression-testing/d13-remediation.2026-11-11T04-48.md`).

### Removed/Skipped Tests
1. **"has parity envelopes for <Leaf>"** - 6 rows skipped by design
   - **Reason:** hooks that cannot be exercised without filesystem mocks carry a recorded NoEnvelope reason (spec AC line 187).
   - **Impact:** the per-hook suites of those hooks still run unchanged.
   - **Justification:** the spec AC requires the suite to report such hooks by name, which it does.

---

## 9. Summary of Changes

The branch runs every PreToolUse hook of each runtime in one dispatcher process per tool call, proven equivalent to per-hook processes by a parity suite, and records before and after process cost.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Local gates, coverage, file size, evidence location and documentation checks comply. Two branch-caused CI failures (F1 tier classification, F2 Jest registry-shape test) block merge.

**Fail-closed reminder:** The audit is not marked ready for merge.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and spec present
- ✅ Design Principles: dispatcher design follows D1-D15
- ✅ Module & File Structure: no file at or above 700 lines
- ✅ Naming, Docs, Comments: compliant
- ❌ Toolchain Execution: CI tier classification and Jest fail (F1, F2)
- ✅ Summarize & Document: PR body and docs updated

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean
- ✅ Python Design & Typing: typed helpers
- ✅ Error Handling: no broad catches

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: fail-closed dispatcher
- ✅ Structure & Naming: compliant
- ✅ Toolchain: green

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ✅ Coverage & Scenarios: thresholds met, no regression
- ✅ Test Structure: AAA
- ✅ External Dependencies: seams; parity processes by spec
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: pytest
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: green

**For PowerShell:**
- ✅ Framework & Scope: Pester via PoshQC
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: green

---

### Metrics Summary

- ✅ 24357 Pester tests, 0 failures; 16723 pytest passed
- ❌ 1 Jest test fails in CI (F2)
- ✅ 95.99% PowerShell line coverage; 98.59% on new production files
- ✅ Test files mirror source layout
- ❌ CI tier classification fails (F1)
- ✅ Pester 856.2 s on 8 workers

---

### Recommendation

**Needs revision**

Add a `.claude/lib/hook-dispatch` entry to `quality-tiers.yml` (F1). Update `collectRegisteredHookClosure` to add the hooks named by `.codex/hooks/pretooluse-dispatch.json` as closure roots, matching the Python twin (F2). Then run `check_quality_tiers`, the root Jest suite with coverage (`npm run test:unit:coverage`) and the extension Jest suite, and record each as new evidence.

---

## Appendix A: Test Inventory

### Complete Test List

New suites on the branch (individual `It` rows are enumerated in `artifacts/pester/pester-junit.xml`, 24357 test cases):

1. `tests/scripts/claude-lib/hook-dispatch/HookDispatch.Tests.ps1` › matcher, registry and combination tests
2. `tests/scripts/claude-lib/hook-dispatch/HookDispatchRunner.Tests.ps1` › in-process and per-process runner tests
3. `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1` › Claude entry script tests
4. `tests/scripts/codex-hooks/hook-dispatch.Tests.ps1` › Codex dispatcher tests
5. `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1` › Codex entry script tests
6. `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` › per-hook and combined parity, module-load tests
7. `tests/scripts/dev-tools/HookProcessCost.Tests.ps1` › measurement module tests
8. `tests/scripts/dev-tools/Measure-HookProcessCost.Tests.ps1` › measurement entry script tests
9. `tests/scripts/dev_tools/test_codex_core_manifest_closure.py` › registry closure roots (modified)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
poetry run black --check <files>
poetry run ruff check <files>
poetry run pyright <files>
poetry run pytest -n auto --cov --cov-branch
poetry run python -m scripts.dev_tools.check_quality_tiers --repo-root <worktree>
```

**For PowerShell:**
```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
Invoke-Formatter / Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCLeakScan -Root .
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-14  
**Policy Version:** Current (as of audit date)
