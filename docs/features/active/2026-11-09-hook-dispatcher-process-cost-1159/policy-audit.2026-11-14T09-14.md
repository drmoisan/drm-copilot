# Policy Compliance Audit: PreToolUse hook dispatcher (issue #1159)

---

**Audit Date:** 2026-11-14  
**Code Under Test:** merge base `1d9f14e2c595b0065ad42a24188620f320ac514c` of the base branch `origin/main` and reviewed head `5a58ecdc239fce59d73db7194cfaa371f3df355a`; the diff between them lists the changed files (275 files, 11448 insertions, 972 deletions)

Review context: re-audit (R4) of remediation cycle 2 (`remediation-inputs.2026-11-14T07-57.md`, `remediation-plan.2026-11-14T07-57.md`) plus the main-sync merge `5a58ecdc2` (issue #1156 arrived), and concurrent review of PR #1177. Scope is the full branch diff against the merge base, not the cycle. Scope sources: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-11-14 09:14:20 UTC at the reviewed head) and `git diff --name-status 1d9f14e2c..5a58ecdc2`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 87 files (production hooks, modules, scripts, bundle mirrors and tests) | 25036 tests | ✅ 25020 pass, 0 fail, 16 skipped | 95.80% lines (37558/39203) | 95.99% lines (41589/43326) | 98.59% (631/640 lines over the 7 new production files) |
| Python | 3 test files | 16736 tests | ✅ 16730 pass, 0 fail, 6 skipped | 97.11% lines, 94.37% branches | 97.13% lines, 94.42% branches | N/A - no production Python file changed |
| TypeScript | 3 test files (2 modified, 1 added) | 5579 tests | ✅ 5579 pass, 0 fail | 98.29% lines, 93.67% branches | 98.29% lines, 93.69% branches | N/A - no production TypeScript file changed |
| JSON / TOML / YAML | 10 files | N/A | ✅ registry, settings, manifest and tier tests pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/remediation-baseline/jest-root.2026-11-14T08-48.md`
- TypeScript post-change coverage artifact: `coverage/lcov.info` (reviewer root Jest run at the reviewed head, `evidence/qa-gates/jest-root.2026-11-14T09-18.md`; cycle record `evidence/qa-gates/jest-root.2026-11-14T09-01.md`)
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/baseline/pester.2026-11-10T04-30.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (reviewer `Invoke-PoshQCParallelTest` run at the reviewed head, `evidence/qa-gates/pester.2026-11-14T09-36.md`)
- Python baseline coverage artifact: `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/baseline/pytest.2026-11-11T04-11.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (reviewer `pytest -n auto --cov --cov-branch` run at the reviewed head, `evidence/qa-gates/pytest.2026-11-14T09-23.md`; cycle record `evidence/qa-gates/pytest.2026-11-14T09-07.md`)
- Per-language comparison summary: section 1.2.1 of this audit

Coverage re-measurement disclosure: the merge commit `5a58ecdc2` (09:14:01 UTC) is the newest commit touching `*.ts`, `*.py` and `*.ps1` files at the reviewed head. Every coverage report in the item worktree predated it (TypeScript 09:01 UTC, Python 09:07 UTC, PowerShell 08:27 UTC). The merge also brought production code from #1156, so the reviewer re-ran the three coverage gates once each at the reviewed head, in parallel mode: root Jest (`npm run test:unit:coverage`), `pytest -n auto --cov --cov-branch`, and `Invoke-PoshQCParallelTest`. This departs from the reviewer's evidence-only model; the coverage freshness Stop hook requires it. The branch's own per-path deltas are identical across the old and new merge base (`git diff --numstat` comparison over 275 paths), so the branch-attributable figures are comparable with the cycle records.

---

## Executive Summary

The branch replaces the per-hook PreToolUse registrations of both runtimes with one dispatcher process per tool call (`.claude/hooks/invoke-pretooluse-dispatch.ps1`, `.codex/hooks/invoke-pretooluse-dispatch.ps1`, `.codex/hooks/hook-dispatch.ps1`, `.claude/lib/hook-dispatch/HookDispatch.psm1`, `.claude/lib/hook-dispatch/HookDispatchRunner.psm1`). It adds generated registries (`pretooluse-dispatch.json`), a process-cost measurement tool, a process-level parity suite, the D6 `-Force` removals and D13 tail rewrites, bundle mirrors, pack manifests and documentation.

Remediation cycle 2 closed both blocking findings of the previous review:

1. F1: `quality-tiers.yml` classifies `.claude/lib/hook-dispatch` as T3. The reviewer ran `check_quality_tiers` at the reviewed head; it printed `quality-tiers: OK (35 entries, 35 discovered projects)` and exited 0.
2. F2: `collectRegisteredHookClosure` in `extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts` adds the 21 hooks named by the bundle Codex registry as closure roots. `codex-bundle-publish.integration.test.ts` passes in the reviewer root Jest run (5579 passed, 0 failed) and in CI `root-typescript-tests` on ubuntu-latest and windows-latest at the reviewed head.

The cycle 2 consumer sweep (`evidence/other/main-integration.2026-11-14T08-49.md`) and the reviewer's independent `git grep` find no other reader of the per-hook registration shape. Coverage meets the thresholds for every changed production file with no regression against the Phase 0 baselines. No blocking finding remains. Verdict: PASS. CI run 43579582942 completed green on the reviewed head (26 of 26 checks). The PR body needs a refresh (code-review N1, non-blocking).

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md`
- ✅ `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` (no production Python file changed) + ✅ `python-unit-test.instructions.md`
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` (test helper and tests only)
- N/A Bash: no `.sh` or `.bats` file in the branch diff
- ✅ JSON / TOML / YAML: registries, settings, config, pack manifests and `quality-tiers.yml` are read by the Pester, pytest, Jest and tier-check gates

**Temporary artifacts cleanup:**
- ✅ Scratch scripts named in evidence (`SCRATCH/issue-1159-*.sh`) and the reviewer launchers live in the session scratch directory, outside the repository; none is in the branch diff.
- ✅ The tooling script `scripts/dev-tools/Measure-HookProcessCost.ps1` and module `scripts/dev-tools/HookProcessCost.psm1` are tested.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The full Pester tree ran in 8 parallel shards with 0 failures; pytest ran under xdist; Jest ran with its normal workers. |
| **Isolation** - Each test targets single behavior | ✅ PASS | New suites target one unit each; the cycle 2 Jest file targets `registryHookPaths` only. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Root Jest 24 s; pytest 298.85 s; Pester 1113.92 s on 8 workers. The parity suite starts real processes by design (spec AC line 186). |
| **Determinism** - Consistent results | ✅ PASS | Runner and measurement tests inject seams with no wall-clock wait; the cycle 2 Jest cases read in-memory text only. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Test names state the behavior, for example `skips a registry hook whose command names no .codex/hooks script`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 95.80% lines; Python 97.11% lines, 94.37% branches; TypeScript 98.29% lines, 93.67% branches<br>**Command:** `Invoke-PoshQCParallelTest`; `poetry run pytest -n auto`; `npm run test:unit:coverage`<br>**Artifact:** `evidence/baseline/pester.2026-11-10T04-30.md`, `evidence/baseline/pytest.2026-11-11T04-11.md`, `evidence/remediation-baseline/jest-root.2026-11-14T08-48.md`<br>**Timestamp:** 2026-11-10 04:30, 2026-11-11 04:11, 2026-11-14 08:48 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.99% lines; Python 97.13% lines, 94.42% branches; TypeScript 98.29% lines, 93.69% branches<br>**Status:** No regression; no per-file drop against the Phase 0 baseline for the changed production PowerShell files that have a baseline row |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest changed production file `scripts/dev-tools/Measure-HookProcessCost.ps1` 86.36% (38/44)<br>**Thresholds:** 85% line; 75% branch for TypeScript and Python; no PowerShell branch threshold (Pester measures none)<br>**Status:** All changed production PowerShell files meet the threshold; no production Python or TypeScript file changed |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** 7 new production PowerShell files<br>**New code coverage:** 98.59% (631/640)<br>**Calculation method:** per-file LINE counters from `artifacts/pester/powershell-coverage.xml`, summed over the new files |
| **Comprehensive Coverage** | ✅ PASS | `HookDispatch.psm1` 100% (107/107); `HookDispatchRunner.psm1` 98.82% (84/85); `.codex/hooks/hook-dispatch.ps1` 99.35% (154/155); both entry scripts 100%; `HookProcessCost.psm1` 99.44% (176/177). All 48 changed production PowerShell files appear in the report; the 38 with a Phase 0 baseline row show no drop. Uncovered: 6 entry-wiring lines of `Measure-HookProcessCost.ps1`. |
| **Positive Flows** - Valid inputs | ✅ PASS | Allow envelopes per registry hook in the parity corpus; `returns every PreToolUse hook path named by a registry command`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Deny envelopes per hook; schema-invalid registry yields `HOOK_DISPATCH_BLOCKED:`; `skips a registry hook whose command names no .codex/hooks script`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Codex `apply_patch` alias; absent `isolation`; `returns no path for a registry without PreToolUse groups` (four shapes including a top-level array). |
| **Error Handling** - Error paths | ✅ PASS | Exit 2 maps to deny; terminating errors map to no decision; a missing registry makes the TypeScript helper throw. |
| **Concurrency** - If applicable | N/A | The dispatcher runs hooks sequentially in one process; no shared concurrent state. |
| **State Transitions** - If applicable | ✅ PASS | Runner restores stdin, console writers, location, strict mode and `$ErrorActionPreference` after each hook. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.99% lines. Change: +0.19% lines. New/changed-code coverage: 98.59% lines. Disposition: PASS. Evidence: `evidence/baseline/pester.2026-11-10T04-30.md`, `artifacts/pester/powershell-coverage.xml` (reviewer run at the reviewed head).
- Python: Baseline: 97.11% lines (from the `Phase 0 baseline` artifact) -> Post-change: 97.13% lines. Change: +0.02% lines, branches 94.37% to 94.42%. No Python production file changed. Disposition: PASS. Evidence: `evidence/baseline/pytest.2026-11-11T04-11.md`, `evidence/qa-gates/pytest.2026-11-14T09-07.md`, `artifacts/python/lcov.info` (reviewer run at the reviewed head).
- TypeScript: Baseline: 98.29% lines (from the cycle 2 `Phase 0 baseline` artifact) -> Post-change: 98.29% lines. Change: +0.00% lines, branches 93.67% to 93.69%. No TypeScript production file changed; the changed files are test code outside the coverage denominator. Disposition: PASS. Evidence: `evidence/remediation-baseline/jest-root.2026-11-14T08-48.md`, `evidence/qa-gates/jest-root.2026-11-14T09-01.md`, `coverage/lcov.info` (reviewer run at the reviewed head, 70272/71492 lines, 10508/11216 branches).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Parity assertions use `-Because` text; Jest assertions compare full arrays so a failure prints the difference. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New suites, including the cycle 2 Jest file, carry `// Arrange`, `// Act`, `// Assert` or `# Arrange` sections. |
| **Document Intent** | ✅ PASS | Suite headers name issue #1159; the Jest file header states that no file is read or created. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Unit suites use seams. The parity suite starts `pwsh` child processes by spec requirement. The integration test reads the real bundle through a read-through filesystem that refuses writes. |
| **Use Mocks/Stubs** | ✅ PASS | Script-invoker, stdin-replayer, process-starter and timestamp seams; in-memory destination filesystem in the integration test. |
| **Environment Stability** | ✅ PASS | No temporary files are created by the new unit suites. |

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
| **Read existing change plans** | ✅ PASS | `plan.2026-11-09T16-31.md`; cycle plans `remediation-plan.2026-11-14T06-51.md` and `remediation-plan.2026-11-14T07-57.md` (all tasks checked). |
| **Document the plan** | ✅ PASS | Plans, task-check evidence and integration records under `evidence/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Each hook script runs unchanged with `&` in its own script scope (D2). `registryHookPaths` is a single pure function. |
| **Reusability** | ✅ PASS | Shared registry and combination logic in `HookDispatch.psm1`; the TypeScript helper reuses the existing `HOOK_COMMAND_PATH` pattern. |
| **Extensibility** | ✅ PASS | New hooks are registered in the registry; the `isolation` knob reverts to per-process with one data edit (D14). |
| **Separation of concerns** | ✅ PASS | Pure selection logic separate from process I/O; `registryHookPaths` takes text, and file reads stay in `collectRegisteredHookClosure`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One module per concern under `.claude/lib/hook-dispatch/`. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest covered file in the diff is `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` at 593 logical lines over 134 added or modified covered files; no file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | `Export-ModuleMember` limits the runner surface; the TypeScript helper exports only `registryHookPaths` beside the existing exports. |
| **No circular dependencies** | ✅ PASS | `HookDispatchRunner.psm1` imports `HookDispatch.psm1`; no reverse import. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved PowerShell verbs; `registryHookPaths`, `isRecord`, `arrayProperty` in TypeScript. |
| **Docs/docstrings** | ✅ PASS | Comment-based help; TSDoc on every new TypeScript function; README, architecture doc and brief copies updated. |
| **Comment why, not what** | ✅ PASS | For example the integration-test comment explaining why registry hooks are closure roots. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter` (check mode); `poetry run black --check`; `npx prettier --check`<br>**Result:** 0 changes (`powershell-static.2026-11-14T07-29.md`, `python-static.2026-11-14T07-29.md`, `typescript-static.2026-11-14T09-00.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer`; `poetry run ruff check`; `npm run lint`<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright`; `npm run typecheck` (includes `typecheck:test`)<br>**Result:** 0 errors; N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`; `pytest -n auto`; `npm run test:unit:coverage`; extension `test:coverage`<br>**Result:** reviewer runs at the reviewed head green (Pester 25036 tests, 0 failures; pytest 16730 passed; root Jest 5579 passed); extension Jest 5557 passed in `jest-extension.2026-11-14T09-01.md` |
| **Full toolchain loop** | ✅ PASS | The tier-classification stage that failed in CI now passes locally (`quality-tiers: OK (35 entries, 35 discovered projects)`); integration-class Jest tests run in the root Jest gate. |
| **Explicit reporting** | ✅ PASS | Each gate has append-only evidence with `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ⚠️ PARTIAL | The posted PR #1177 body equals `artifacts/pr_body_1159.md` but predates remediation cycles 1 and 2 and the main sync (code-review N1, non-blocking). |
| **Design choices explained** | ✅ PASS | Spec decisions D1-D15 and the PR body Design section. |
| **Update supporting documents** | ✅ PASS | `README.md`, `docs/engineering/claude-code-architecture.md`, six brief copies. |
| **Provide next steps** | ✅ PASS | Remediation inputs and the feature audit list CI confirmation and the body refresh. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check` on 3 files<br>**Result:** 3 files unchanged (no Python change since) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors, 0 warnings |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov --cov-branch`<br>**Result:** 16730 passed, 6 skipped (reviewer run at the reviewed head) |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | `registry_hook_paths(registry_text: str) -> set[str]`. |
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
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter` with `pssa.settings.psd1`<br>**Result:** 0 files changed (`powershell-static.2026-11-14T07-29.md`); no PowerShell file changed in cycle 2 |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | No findings outstanding. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Repository requires PowerShell 7+; hooks run under `pwsh`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and typed parameters on exported functions. |
| **Parameter validation** | ✅ PASS | `[Parameter(Mandatory)]`, `[AllowEmptyString()]` on runner parameters. |
| **Avoid global state** | ✅ PASS | The runner's global `LASTEXITCODE` sentinel is required because hook scripts report exit codes through it; it is reset per hook. |
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
| **Step 4: Test** | ✅ PASS | 25036 tests, 0 failures (reviewer run at the reviewed head). |
| **Rerun loop if needed** | ✅ PASS | No PowerShell change in cycle 2 (`conditional-gates.2026-11-14T09-07.md`). |

---

### Section 3C: TypeScript Code Change Policy Compliance (if applicable)

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | **Command:** `npx prettier --check` over the three changed files<br>**Result:** `All matched files use Prettier code style!` |
| **Linting with ESLint** | ✅ PASS | **Command:** `npm run lint`<br>**Result:** 0 findings |
| **Type checking with tsc** | ✅ PASS | **Command:** `npm run typecheck` (includes `typecheck:test`)<br>**Result:** 0 errors |
| **Testing with Jest** | ✅ PASS | **Command:** `npm run test:unit:coverage` (root); `npm run test:coverage` (extension)<br>**Result:** 5579 passed (reviewer, reviewed head); 5557 passed (`jest-extension.2026-11-14T09-01.md`) |

#### 3C.2 TypeScript Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict typing, no unjustified `any`** | ✅ PASS | Parsed JSON is typed `unknown` and narrowed by `isRecord` and `arrayProperty`; no type assertion and no suppression. |
| **Explicit return types on exports** | ✅ PASS | `registryHookPaths(registryText: string): string[]`. |

---

### Section 3D: JSON Configuration Policy Compliance (if applicable)

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | N/A | Registries are generated (D10) and validated by tests rather than reformatted. |
| **Schema validation** | ✅ PASS | Registry schema validated by `Read-HookDispatchRegistry` tests; `quality-tiers.yml` validated by `check_quality_tiers` and `test_quality_tiers_contract_classification.py`. |
| **Required $schema** | N/A | The registries reuse the settings shape and are not governed by a `$schema` rule. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Parsed by `ConvertFrom-Json`, `json.loads` and `JSON.parse` in the gates. |
| **Deterministic key order** | ✅ PASS | Generated in registration order by rule D10. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | pytest with xdist. |
| **Coverage expectation** | ✅ PASS | Repo-wide 97.13% lines, 94.42% branches in the reviewer run. The CI job `quality-checks7 / Code Quality & Tests (3.13)`, which runs the Python coverage-threshold step, passed on the reviewed head (see `## CI Cross-check`). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Registry-root tests in `test_codex_core_manifest_closure.py`. |
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
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto`<br>**Result:** 16730 passed |
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
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/hook-dispatch/HookDispatch.Tests.ps1`<br>**Code file:** `.claude/lib/hook-dispatch/HookDispatch.psm1`<br>Mirrors the source layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites use `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Describe per unit, Context per runtime or scenario. |
| **Logical Grouping** | ✅ PASS | Grouped by runtime and registry. |
| **Docstrings/Comments** | ✅ PASS | Header comments per suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Result:** 25036 tests, 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

### Section 4C: TypeScript Unit Test Policy Compliance (if applicable)

#### 4C.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | ✅ PASS | Root and extension Jest through `run-jest.cjs`. |
| **Test location** | ✅ PASS | `extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.test.ts` sits beside the helper it tests in the extension `test/` tree, not in `src/`. |
| **No temporary files** | ✅ PASS | In-memory registry text only. |

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

### registryHookPaths (Jest suite `real-bundle-filesystem.test-helpers.test.ts`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| returns every PreToolUse hook path named by a registry command | Positive | group and hook loops, de-duplication | ✅ |
| skips a registry hook whose command names no .codex/hooks script | Negative | shape guards | ✅ |
| returns no path for a registry without PreToolUse groups | Edge Case | empty and non-object shapes | ✅ |

**Coverage:** test-helper code, outside the coverage denominator.

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 25036 Pester; 16736 pytest; 5579 root Jest | ✅ |
| Tests Passed | 25020 (16 skipped) Pester; 16730 pytest (6 skipped); 5579 root Jest | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 1113.92 s Pester; 298.85 s pytest; 24 s root Jest | ✅ Fast |
| Average Time per Test | under 40 ms Pester per test (8 workers) | ✅ Fast |
| Discovery Time | not separately recorded by the gate | ✅ |
| Functions/Classes Tested | every exported function of the new modules and `registryHookPaths` | ✅ |
| Test File Size | 593 logical lines largest | ✅ PASS at or below 800 lines |
| Code Coverage (if applicable) | 95.99% PowerShell lines; 97.13% Python lines, 94.42% branches; 98.29% TypeScript lines, 93.69% branches | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check` | 3 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 16730 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` check mode | 0 changes | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest -Root .` | 25036 tests, 0 failures | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check` | 0 differences | ✅ |
| ESLint | `npm run lint` | 0 findings | ✅ |
| tsc | `npm run typecheck` | 0 errors | ✅ |
| Jest | `npm run test:unit:coverage` | 5579 passed | ✅ |

**Tier classification:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| check_quality_tiers | `poetry run python -m scripts.dev_tools.check_quality_tiers --repo-root <worktree>` | OK, 35 entries, 35 discovered projects | ✅ |

---

## CI Cross-check

CI run 43579582942 (workflow `CI`, `pull_request`) ran on the reviewed head concurrently with this review and completed before the artifacts were finalized, with all 26 checks passing (`gh pr checks 1177`). Rows record the outcome claimed from local evidence; the source column states what was observed in CI.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| quality-checks7 / Code Quality & Tests (3.13) | pass | tier check OK (35 entries, 35 discovered projects) | 5a58ecdc239fce59d73db7194cfaa371f3df355a | reviewer `check_quality_tiers` at the reviewed head; CI pass observed |
| Enforce Python coverage thresholds | pass | 97.13% lines, 94.42% branches | 5a58ecdc239fce59d73db7194cfaa371f3df355a | reviewer pytest run; CI pass observed |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | pass | 5579 passed, 0 failed | 5a58ecdc239fce59d73db7194cfaa371f3df355a | reviewer root Jest run; CI pass observed |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | pass | 5579 passed, 0 failed | 5a58ecdc239fce59d73db7194cfaa371f3df355a | reviewer root Jest run; CI pass observed |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | pass | 5557 passed | 5a58ecdc239fce59d73db7194cfaa371f3df355a | `evidence/qa-gates/jest-extension.2026-11-14T09-01.md`; CI pass observed |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | pass | 5557 passed | 5a58ecdc239fce59d73db7194cfaa371f3df355a | `evidence/qa-gates/jest-extension.2026-11-14T09-01.md`; CI pass observed |
| poshqc / PowerShell QC static | pass | 0 findings | 5a58ecdc239fce59d73db7194cfaa371f3df355a | `evidence/qa-gates/powershell-static.2026-11-14T07-29.md`; CI pass observed |
| poshqc / PowerShell QC shard 1-3 | pass | 25036 tests, 0 failures | 5a58ecdc239fce59d73db7194cfaa371f3df355a | reviewer Pester run; CI pass observed |
| poshqc / PowerShell hook suites (Linux) | pass | Windows run green; Linux CI-dependent | 5a58ecdc239fce59d73db7194cfaa371f3df355a | reviewer Pester run on Windows; CI pass observed; the Definition of Done item stays for the S9 check-off |

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. All evidence is under `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/<kind>/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists at the repository root and CI runs the `tier-classification` stage, so tiers are adopted. The new project folder `.claude/lib/hook-dispatch` now has a T3 entry, and the check passes at the reviewed head (previous finding F1 closed).

## Merge Neutrality

The main-sync merge `5a58ecdc2` (parents `bf1805ec0` and `1d9f14e2c`) brought issue #1156. Per-path `git diff --numstat` from the old merge base `2c8dee6dd` to `bf1805ec0` equals that from the new merge base `1d9f14e2c` to the reviewed head across all 275 paths. #1156 did not change `.claude/settings.json` or `.codex/config.toml`. Its new hook files contain no `Import-Module` or dot-source line. `gh pr view 1177` reports `MERGEABLE`.

---

## 8. Gaps and Exceptions

### Identified Gaps
- None blocking.
- Non-blocking: the posted PR body predates remediation cycles 1 and 2 and the main sync (code-review N1).
- Pending-CI check-off: the Linux hook-suite Definition of Done item (CI green on the reviewed head; the orchestrator checks it off at S9).

### Approved Exceptions
- D13 tail rewrites in dispatched hooks are the spec's separately evidenced exception to the hook-file edit rule (`evidence/regression-testing/d13-remediation.2026-11-11T04-48.md`).

### Removed/Skipped Tests
1. **"has parity envelopes for <Leaf>"** - 6 rows skipped by design
   - **Reason:** hooks that cannot be exercised without filesystem mocks carry a recorded NoEnvelope reason (spec AC line 187).
   - **Impact:** the per-hook suites of those hooks still run unchanged.
   - **Justification:** the spec AC requires the suite to report such hooks by name, which it does.

---

## 9. Summary of Changes

The branch runs every PreToolUse hook of each runtime in one dispatcher process per tool call, proven equivalent to per-hook processes by a parity suite, and records before and after process cost. Cycle 2 classified the new library folder and re-targeted the TypeScript push-down closure helper to the Codex registry.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

Local gates, coverage, file size, evidence location, tier classification and documentation checks comply at the reviewed head. Previous findings F1 and F2 are closed.

**Fail-closed reminder:** CI run 43579582942 is green on the reviewed head; the orchestrator records the CI gate and the Linux Definition of Done check-off at S9.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and spec present
- ✅ Design Principles: dispatcher design follows D1-D15
- ✅ Module & File Structure: no file at or above 700 lines
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: green locally at the reviewed head
- ⚠️ Summarize & Document: PR body needs a refresh (non-blocking)

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

**For TypeScript:**
- ✅ Tooling: Prettier, ESLint and tsc clean
- ✅ Typing: `unknown` narrowed without assertions

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

**For TypeScript:**
- ✅ Framework & Scope: Jest
- ✅ Toolchain: green

---

### Metrics Summary

- ✅ 25036 Pester tests, 0 failures; 16730 pytest passed; 5579 root Jest passed
- ✅ 95.99% PowerShell line coverage; 98.59% on new production files
- ✅ Test files mirror source layout
- ✅ Tier classification passes
- ✅ No file at or above 700 lines

---

### Recommendation

**Ready for merge**

CI run 43579582942 is green on the reviewed head, including `poshqc / PowerShell hook suites (Linux)`; the orchestrator checks off the Linux Definition of Done item at S9. Refresh the PR body through the `pr-author` route.

---

## Appendix A: Test Inventory

### Complete Test List

New suites on the branch (individual Pester `It` rows are enumerated in `artifacts/pester/pester-junit.xml`):

1. `tests/scripts/claude-lib/hook-dispatch/HookDispatch.Tests.ps1` › matcher, registry and combination tests
2. `tests/scripts/claude-lib/hook-dispatch/HookDispatchRunner.Tests.ps1` › in-process and per-process runner tests
3. `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1` › Claude entry script tests
4. `tests/scripts/codex-hooks/hook-dispatch.Tests.ps1` › Codex dispatcher tests
5. `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1` › Codex entry script tests
6. `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` › per-hook and combined parity, module-load tests
7. `tests/scripts/dev-tools/HookProcessCost.Tests.ps1` › measurement module tests
8. `tests/scripts/dev-tools/Measure-HookProcessCost.Tests.ps1` › measurement entry script tests
9. `tests/scripts/dev_tools/test_codex_core_manifest_closure.py` › registry closure roots (modified)
10. `extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.test.ts` › three `registryHookPaths` cases (new in cycle 2)
11. `extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts` › registry hooks in the published closure (modified in cycle 2)

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

**For TypeScript:**
```bash
npm run test:unit:coverage
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-14  
**Policy Version:** Current (as of audit date)
