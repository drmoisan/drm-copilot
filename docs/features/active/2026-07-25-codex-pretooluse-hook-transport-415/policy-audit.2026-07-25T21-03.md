# Policy Compliance Audit: Codex PreToolUse Hook Transport Repair (Issue #415)

**Audit Date:** 2026-07-25
**Reviewer:** feature-review agent
**Branch:** `bug/codex-pretooluse-hook-transport-415` @ `ee98ca7fb69901f541ae10cf8f63f46262f3e6d5`
**Base:** `main`, merge-base `009808510363081d0db7684f7b555f2ded4b0b7c`
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (the identical file the MCP selector `template` resolves; the MCP tool itself was unavailable in this review session, so the bundled source file was copied directly).

**Code Under Test:**

- `.codex/hooks/codex-pretooluse-file-mapping.ps1` (NEW, 474 lines) + bundle mirror
- `.codex/hooks/check-python-test-purity.ps1`, `check-powershell-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, `enforce-evidence-locations.ps1`, `enforce-checkpoint-monotonic.ps1`, `enforce-completion-consistency.ps1`, `enforce-orchestration-preimplementation-gate.ps1` (MODIFIED) + bundle mirrors
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` (DELETED, bundle-only orphan, issue #335 cross-reference)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (MODIFIED, +1 entry)
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (NEW), `codex-pretooluse-integration.Tests.ps1` (NEW), `legacy-codex-hook-contracts.Tests.ps1` (MODIFIED)
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` (MODIFIED, -1 stale exception entry)
- Feature docs and evidence under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 19 files (9 root + 9 bundle mirrors + 1 bundle deletion) | 1391 tests | ✅ 1391 pass, 0 fail | 90.22% lines (2150/2383) | 90.15% lines (2151/2386) | N/A - not measured (Blocking finding B1) |
| Python | 1 test file | 8 parity tests | ✅ 8 pass, 0 fail | N/A - no artifact (Blocking finding B2) | N/A - no artifact (Blocking finding B2) | N/A - test-only change |
| JSON | 1 file (`core.json`) | 8 tests | ✅ validation via pytest manifest/resource contracts | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/baseline/phase0-poshqc-test.2026-07-25T19-16.md` (JaCoCo totals from `artifacts/pester/powershell-coverage.xml` at merge-base)
- PowerShell post-change coverage artifact: `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/qa-gates/final-poshqc-test.2026-07-25T21-02.md` plus `artifacts/pester/powershell-coverage.xml` (re-parsed by this review: LINE covered=2151 missed=235)
- Per-language comparison summary: section 1.2.1 of this document and `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/qa-gates/coverage-comparison.2026-07-25T21-06.md`

**Fail-closed application:** the Python coverage artifact required for a language with changed files is absent, and PowerShell new/changed-file coverage is outside the coverage instrument. Per the fail-closed rule this audit's verdict is not PASS; it is BLOCKED pending remediation (see Section 10).

---

## Rejected Scope Narrowing

The plan and spec supplied by the executed workflow contain the following coverage-scope narrowing (plan `[P0-T6]`, quoted verbatim from `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/plan.2026-07-25T18-07.md` and mirrored in `artifacts/pr_context.summary.txt`):

> "Scope justification: one Python test file is modified by this plan (P1-T4); the Python gate is format/lint/type-check plus these two targeted parity contracts. The full `--cov --cov-branch` suite is out of scope because no Python production file changes."

This narrowing is rejected for review purposes: Python has changed files in the branch diff, so a Python coverage verdict must be an explicit PASS or FAIL. Because no Python coverage artifact exists (`artifacts/python/lcov.info` absent), the Python coverage verdict is **FAIL** (fail-closed), recorded as Blocking finding B2. The mitigating context (test-only Python change; parity suites green) is documented in Section 8 for the remediation planner.

The delegating prompt for this review did not attempt to narrow the audit scope; the full feature-vs-base diff (`00980851..ee98ca7f`, 59 files) was audited.

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0 (no violations).
- Branch diff scan for files added under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, `artifacts/post-change/`: **none found**. All evidence resolves under the canonical `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/<kind>/` tree.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events were needed during this review.

**Verdict: PASS.**

---

## Executive Summary

This branch repairs the Codex `PreToolUse` stdin transport for the eight handlers registered under the `^(apply_patch|Edit|Write)$` matcher in `.codex/config.toml`. A new shared, entrypoint-free transport module (`codex-pretooluse-file-mapping.ps1`) replaces seven drift-prone per-handler payload adapters; tool-name admission is widened to the matcher's set; unmapped well-formed input now allows instead of exiting 2; error messages are `-HookName`-parameterized; root/bundle byte-identity is restored (including deletion of the unregistered bundle-only `enforce-pr-author-skill.ps1`, cross-referenced to issue #335).

Independent re-verification by this review: all four Pester suites pass (33 new-suite tests + 26 parity-suite tests), pytest parity contracts pass (8/8), Black/Ruff/Pyright are clean, config matcher groups still carry 5 / 5 / 8 handler blocks with zero diff to `.codex/config.toml`, the full `.codex/` tree is byte-identical to its bundle copy (`diff -r` clean), all changed files are ≤ 500 lines, and evidence locations are canonical.

Two Blocking findings prevent a PASS verdict, both in coverage verification:

- **B1 (PowerShell):** the new 474-line production module and 7 of the 8 rewired hooks are outside the `CodeCoverage.Path` allow-list in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, so new-file and changed-file coverage thresholds cannot be verified. Repository precedent (issues #275, #301, #305, #312, #334, #344, #357, #366, #392 recorded in that same file) is to add new/changed production PowerShell files to the measured set.
- **B2 (Python):** no Python coverage artifact exists for a branch with changed Python files (fail-closed rule).

**Policy documents evaluated:**
- ✅ `general-code-change` policy (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ Python: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- ✅ PowerShell: `.claude/rules/powershell.md`
- N/A TypeScript / C# / Bash (zero changed files)
- ✅ JSON: manifest change validated by pytest manifest-completeness and resource-contract suites

**Temporary artifacts cleanup:**
- ✅ The executor's fail-before probe was created outside the repository tree (session scratchpad) and deleted after use per plan `[P1-T1]`; no throwaway scripts are present in the diff.
- ✅ The untracked `.codex/state/` runtime directory was removed and does not exist at review time (`Test-Path` false); nothing under `.codex/state/` entered the commit.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Process-level cases spawn isolated `pwsh` processes per invocation; unit cases dot-source with injected state (`-CheckpointRaw '{}'`). This review ran the two new suites alone and the three parity suites alone, both green, confirming order independence. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One contract facet per `It` block (safe allow, unmapped allow, deny envelope, malformed stdin, session_id requirement, latent-defect regression, self-naming stderr). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | New suites: 33 tests in 63.2s (dominated by ~130 deliberate process spawns); parity suites: 26 tests in 13.4s. Acceptable for process-level contract tests. |
| **Determinism** - Consistent results | ✅ PASS | No wall-clock reads, no randomness, no sleeps; checkpoint-dependent deny cases use sentinels that resolve identically regardless of on-disk checkpoint state (`codex-pretooluse-transport.Tests.ps1:182-217`). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `It` names, `-ForEach` parameterized matrices, intent comments on every non-obvious case. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** 90.22% lines (2150/2383)<br>**Command:** `mcp__drm-copilot__run_poshqc_test` (full workspace)<br>**Timestamp:** 2026-07-25 19:16<br>Artifact: `evidence/baseline/phase0-poshqc-test.2026-07-25T19-16.md` |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 90.15% lines (2151/2386)<br>**Change:** −0.07 pp lines<br>**Status:** No regression on changed lines — the delta is denominator growth from three new entrypoint lines behind a dot-source guard in the one measured rewired hook; no previously-covered line became uncovered (`evidence/qa-gates/coverage-comparison.2026-07-25T21-06.md`, verified against `artifacts/pester/powershell-coverage.xml` by this review). |
| **New Code Coverage ≥90%** | ❌ FAIL | **New/modified files:** `codex-pretooluse-file-mapping.ps1` (new) plus 8 rewired hooks.<br>**New code coverage:** not measurable — the new module and 7/8 rewired hooks are outside `CodeCoverage.Path` in `pester.runsettings.psd1` (confirmed: the module does not appear in `artifacts/pester/powershell-coverage.xml`).<br>**Blocking finding B1.** Behavioral exercise exists (~130 process spawns) but per-file line coverage evidence is required by policy. |
| **Comprehensive Coverage** | ✅ PASS | Shared-module public functions exercised in-process (`legacy-codex-hook-contracts.Tests.ps1` mapping-unit cases; transport-suite preimplementation deny cases) and at process level across all 8 handlers × 3 tool names, both unmapped variants, 15 deny cases, 50 malformed-stdin spawns. |
| **Positive Flows** - Valid inputs | ✅ PASS | Safe `Edit`/`Write`/`apply_patch` payloads across all 8 group handlers (24 spawns) + config-driven 59-spawn matrix across all 17 registered handlers. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Empty stdin, invalid JSON (all 17 registered handlers), missing/null `tool_input` (8 group handlers), missing `session_id` (2 batch-budget hooks). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Unmapped `apply_patch` (`command:''`, `command:'noop'`); rename `*** Move to:` both-sides mapping; ungoverned-Update-with-unreadable-source latent-defect regression. |
| **Error Handling** - Error paths | ✅ PASS | Every exit-2 case asserts empty stdout + nonempty, hook-self-naming stderr; deny cases assert the exact native envelope with no legacy `decision` key. |
| **Concurrency** - If applicable | N/A | Hooks are single-shot short-lived processes; no concurrent state in scope. |
| **State Transitions** - If applicable | ✅ PASS | Checkpoint monotonic/consistency deny paths retested through preserved fail-closed cases; batch-budget state keying retested at unit level with injected state. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.22% lines -> Post-change: 90.15% lines. Change: -0.07 pp lines. New/changed-code coverage: N/A - excluded from the coverage instrument (Blocking finding B1). Disposition: FAIL. Evidence: `evidence/qa-gates/coverage-comparison.2026-07-25T21-06.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: N/A. Post-change: N/A. Change: no artifact exists to compare (Blocking finding B2, fail-closed). New/changed-code coverage: N/A - test-only change. Disposition: FAIL. Evidence: absence of `artifacts/python/lcov.info` confirmed by directory listing at review time.
- TypeScript: N/A - out of scope. Disposition: N/A. Evidence: zero TypeScript files in `git diff --name-status 00980851..HEAD`.
- C#: N/A - out of scope. Disposition: N/A. Evidence: zero C# files in `git diff --name-status 00980851..HEAD`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Every `Should` carries `-Because` with handler and case context; the integration matrix accumulates per-combination failure rows (`handler x tool: exit/stdout/stderr`) before asserting. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange (payload builders), Act (`Invoke-CodexHookProcess`), Assert (exit/stdout/stderr/envelope) cleanly separated in both new suites. |
| **Document Intent** | ✅ PASS | Suite helpers and non-obvious cases carry intent comments (e.g., discovery-time `-ForEach` literal explanation at `codex-pretooluse-transport.Tests.ps1:188-189`). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, no databases. Deliberate `pwsh` child processes are the unit under test (hook process contract); pattern matches the pre-existing `legacy-codex-hook-contracts.Tests.ps1` precedent required by spec Hard Constraint 5. |
| **Use Mocks/Stubs** | ✅ PASS | Unit-level deny cases inject state (`-CheckpointRaw '{}'`) instead of mutating the repository; no executable mocking needed. |
| **Environment Stability** | ✅ PASS | **No temporary files created by any test** (verified by inspection of both new suites: stdin is fed via `ProcessStartInfo` + `RedirectStandardInput`, spec Hard Constraint 5). Poisoned `CLAUDE_*` variables are baked into every spawn, proving environment independence. The state-hygiene case asserts `.codex/state` is not created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document. Companion artifacts: `code-review.2026-07-25T21-03.md`, `feature-audit.2026-07-25T21-03.md`, `remediation-inputs.2026-07-25T21-03.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #415; `issue.md` (Work Mode: full-bug), `spec.md` v1.0 with measured failure table and root-cause analysis. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md` records the policy reads; the plan traces spec constraints per task. |
| **Document the plan** | ✅ PASS | `plan.2026-07-25T18-07.md` (8 phases, per-task acceptance criteria, evidence paths). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One shared module with two public functions; handlers replace only plumbing; the deliberately-failing pre-fix adapters were deleted rather than wrapped. |
| **Reusability** | ✅ PASS | Removes seven near-duplicate payload adapters that had drifted; shared regexes lifted verbatim and centralized. |
| **Extensibility** | ✅ PASS | `-ResolveUpdateContent`/`-GovernedPath` switches keep checkpoint-specific behavior opt-in; admitted-name list is a single script-scoped constant. |
| **Separation of concerns** | ✅ PASS | Transport (parse/map) fully separated from policy (allow/deny); the module performs no policy evaluation (documented in its `PUBLIC SURFACE` docstring, verified by diff: no policy function was modified in any of the 8 hooks). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Module owns exactly the two transport concerns; 3 internal helpers are documented as internal and are not called by any hook (verified by grep across `.codex/hooks/`). |
| **Under 500 lines** | ✅ PASS | Measured by this review with `(Get-Content -LiteralPath $path).Count`: module 474; hooks 166/166/254/256/196/339/438/265; new tests 269/198; modified suite 278. Extraction reduced `enforce-checkpoint-monotonic.ps1` 420→339 and `enforce-completion-consistency.ps1` 425→438 remains under cap. |
| **Public vs internal** | ✅ PASS | Public surface (2 functions) vs internal helpers (3) explicitly documented in the module header. |
| **No circular dependencies** | ✅ PASS | Hooks dot-source the module; the module dot-sources nothing. `enforce-completion-consistency` still dot-sources its neighbor for shared checkpoint policy (pre-existing, documented as by-design). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs (`ConvertFrom-`, `ConvertTo-`, `Test-`, `Resolve-`); nouns are specific (`CodexPreToolUsePayload`, `CodexFileEditInput`). |
| **Docs/docstrings** | ✅ PASS | Every function carries `.SYNOPSIS`/`.DESCRIPTION`/`.PARAMETER`/`.OUTPUTS`/`.NOTES`; the stale `enforce-evidence-locations.ps1` docstring (claimed allow envelope) was corrected to the allow-silently contract per spec. |
| **Comment why, not what** | ✅ PASS | Comments explain rationale (e.g., why `AllowEmptyString` is required so empty stdin reaches the parser instead of a binding failure; why both rename sides are emitted). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format`; `poetry run black --check tests/scripts/dev_tools`<br>**Result:** exit 0, zero files changed (`evidence/qa-gates/final-poshqc-format.2026-07-25T20-58.md`, `final-black.2026-07-25T21-04.md`); Black re-run clean by this review. |
| **2. Linting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`; `poetry run ruff check tests/scripts/dev_tools`<br>**Result:** 0 errors / 0 warnings / 0 information (`final-poshqc-analyze.2026-07-25T20-59.md`); Ruff re-run clean by this review. No new suppressions were added anywhere in the diff. |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors, 0 warnings (re-run by this review). N/A for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test`; `poetry run pytest <parity modules> -q`<br>**Result:** 1391 Pester tests, 0 failures (`final-poshqc-test.2026-07-25T21-02.md`); this review independently re-ran the 4 relevant Pester suites (59 tests, 0 failures) and the parity pytest (8 passed). |
| **Full toolchain loop** | ✅ PASS | Final loop clean in a single pass; one earlier analyzer finding (Phase 7 `PSUseShouldProcessForStateChangingFunctions`) was fixed at cause and the loop restarted from format — the required restart discipline. |
| **Explicit reporting** | ✅ PASS | Every stage recorded with `Timestamp:`/`Command:`/`EXIT_CODE:` under `evidence/qa-gates/` and `evidence/baseline/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `ee98ca7f` message and `evidence/other/scope-verification.2026-07-25T21-10.md`. |
| **Design choices explained** | ✅ PASS | Module header documents the extraction rationale (500-line cap pressure on the two checkpoint hooks) and the public/internal split. |
| **Update supporting documents** | ✅ PASS | Stale docstring corrected; #335 cross-reference note recorded (`evidence/regression-testing/issue-335-bundle-orphan-removal.2026-07-25T19-33.md`). |
| **Provide next steps** | ✅ PASS | Executor flagged the coverage allow-list follow-up (`coverage-comparison.2026-07-25T21-06.md`, "Recorded observation"); this audit escalates it to Blocking (B1). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check tests/scripts/dev_tools`<br>**Result:** exit 0, 182 files unchanged (re-run by this review). |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check tests/scripts/dev_tools`<br>**Result:** all checks passed (re-run by this review). |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors, 0 warnings, 0 informations (re-run by this review). |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`<br>**Result:** 8 passed (re-run by this review). Full-suite coverage evidence is absent — Blocking finding B2. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | The single Python change removes one entry from a `frozenset[str]` constant; no signatures touched; Pyright clean. |
| **Dataclasses for value objects** | N/A | No new Python value objects. |
| **Protocols/ABCs for interfaces** | N/A | No new Python interfaces. |
| **Avoid utility classes** | ✅ PASS | No classes added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No Python error-handling paths changed. |
| **Logging over print** | N/A | No Python runtime code changed. |
| **Invariants at construction** | N/A | No Python constructors changed. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format`<br>**Result:** exit 0, zero files changed (`final-poshqc-format.2026-07-25T20-58.md`). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`<br>**Result:** 0 errors / 0 warnings / 0 information (`final-poshqc-analyze.2026-07-25T20-59.md`). |
| **Fix all findings** | ✅ PASS | One transient analyzer finding fixed at cause (test helper renamed away from a state-changing verb), loop restarted from format; no suppression added. |
| **PowerShell 7+ compatible** | ✅ PASS | `#Requires -Version 7.0` on tests; hooks use PS7-safe constructs; analyzer settings enforce compatibility. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | All module functions use `[CmdletBinding()]`, `[OutputType()]`, and typed parameters. |
| **Parameter validation** | ✅ PASS | `[Parameter(Mandatory)]`, `[ValidateNotNullOrEmpty()]`, deliberate `[AllowEmptyString()]`/`[AllowNull()]` with documented rationale (empty stdin must reach the parser to fail closed with a hook-named error). |
| **Avoid global state** | ✅ PASS | Script-scoped read-only constants only (`$script:CodexAdmittedToolNames`, regex constants, `$script:GovernedCheckpointPath`); no mutable shared state. |
| **Error handling** | ✅ PASS | Fail-fast throws in the parser with hook-named messages; `Resolve-CodexUpdatedFileContent` deliberately never throws and returns empty content so governed reconstruction failures route into the existing fail-closed deny rather than exit 2 (documented in `.NOTES`). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | All changed files ≤ 500 lines, measured by this review (max: module 474, `enforce-completion-consistency.ps1` 438). |
| **Approved verbs** | ✅ PASS | `ConvertFrom-`, `ConvertTo-`, `Test-`, `Resolve-`, `Invoke-`, `Get-` throughout; analyzer clean. |
| **Comment why** | ✅ PASS | Rationale comments on admission-by-matcher, both-sides rename emission, governed-path scoping, and dot-source guards. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Exit 0, no changes (final loop). |
| **Step 2: Analyze** | ✅ PASS | Exit 0, zero findings (final loop). |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 1391 tests, 0 failures (final loop); 59 relevant tests re-run green by this review. |
| **Rerun loop if needed** | ✅ PASS | One restart (Phase 7 analyzer finding), then a clean single pass. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | `core.json` change is a single sorted-position insertion; file remains machine-formatted. |
| **Schema validation** | ✅ PASS | `test_push_down_codex_and_agents_pack_manifest_completeness.py` and the resource-contract suite pass (8/8, re-run by this review). |
| **Required $schema** | N/A | `pack-manifests/core.json` is not in the `$schema`-governed set; validated by its dedicated pytest contracts instead. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | No comments or trailing commas introduced. |
| **Deterministic key order** | ✅ PASS | New entry inserted in alphabetical order within `paths` (verified in diff). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Only Pytest; the change is a one-line constant removal in an existing contract test module. |
| **Coverage expectation** | ❌ FAIL | No Python coverage artifact exists for this branch (Blocking finding B2, fail-closed). Context: the only Python change deletes a stale allow-list entry in a test module; no production Python changed. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Contract tests target manifest completeness and root/bundle parity; unchanged in structure. |
| **Mocking sparingly** | ✅ PASS | No mocks; the contracts read the repository tree. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | Existing descriptive `test_...` names retained. |
| **Docstrings/comments** | ✅ PASS | The edited constant's docstring context explains the exception list's purpose. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | 8 passed, exit 0 (re-run by this review). |
| **No Alternative Test Runners** | ✅ PASS | Only Pytest. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules Pester 5.0.0`; `Describe`/`It`/`-ForEach`/`BeforeAll`; modern `Should` syntax throughout. |
| **Use PoshQC Configuration** | ✅ PASS | Full run through `mcp__drm-copilot__run_poshqc_test` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (1391 tests). Coverage-path configuration gap is B1 (Section 8). |
| **PowerShell 7+ Compatible** | ✅ PASS | `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Per-contract-facet cases; deny matrices parameterized per handler × tool name. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions target the process contract (exit code, stdout envelope, stderr naming), not internals. |
| **Mocking Used Sparingly** | ✅ PASS | No mocks; injected state for the one checkpoint-dependent unit case. |
| **Organization** | ✅ PASS | Test files under `tests/scripts/codex-hooks/` mirror `.codex/hooks/` production scope, consistent with the existing suites for that tree. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `codex-pretooluse-transport.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe per suite; parameterized `It` blocks; 33 tests total in the new suites. |
| **Logical Grouping** | ✅ PASS | Transport contract vs config-driven integration split across the two files. |
| **Docstrings/Comments** | ✅ PASS | Self-documenting `It` names plus intent comments on non-obvious mechanics. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | Executor: full `run_poshqc_test` exit 0. Review re-verification used `Invoke-Pester` on the five affected suites (59 tests, 0 failures). |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### codex-pretooluse-file-mapping.ps1 (exercised by 33 new tests + 2 retargeted parity assertions)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| allows a safe Edit/Write/apply_patch payload on every group handler | Positive | process-level (no line attribution — B1) | ✅ |
| allows a well-formed apply_patch payload whose tool_input maps to no file edit | Edge Case | process-level (no line attribution — B1) | ✅ |
| allows an apply_patch update that touches only ungoverned files with a missing source | Error Handling (latent-defect regression) | process-level (no line attribution — B1) | ✅ |
| emits only the native deny envelope on a forbidden payload (15 cases) | Negative | process-level (no line attribution — B1) | ✅ |
| denies a preimplementation-gate implementation path mapped from Edit/Write/apply_patch | Negative (unit, in-process) | `ConvertTo-CodexFileEditInput` direct-map and patch paths | ✅ |
| fails closed with exit 2 for missing/null tool_input on every group handler | Negative | parser throw paths | ✅ |
| fails closed with exit 2 when a batch-budget payload omits session_id | Negative | `-RequireSessionId` path | ✅ |
| reconstructs update patches in memory and includes move destinations (parity suite) | Positive (unit, in-process) | `Resolve-CodexUpdatedFileContent`, move mapping | ✅ |

**Coverage:** per-file numeric line coverage is not available for this module because it is outside `CodeCoverage.Path` (Blocking finding B1). Behavioral exercise spans all public-function branches listed above.

**Not covered (numerically):** the entire module, in the line-coverage instrument — see B1.

### Registered-handler integration matrix (6 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| parses at least three matcher groups and every registered handler from config.toml | Positive (guard) | config parsing helper | ✅ |
| allows every registered handler for every tool name its own matcher admits (59 spawns) | Positive | all 17 handler entrypoints (process-level) | ✅ |
| fails closed with exit 2 for empty stdin / invalid JSON on every registered handler (34 spawns) | Negative | all 17 handler entrypoints (process-level) | ✅ |
| reports enforce-completion-consistency in its own stderr rather than its neighbour | Negative (regression) | `-HookName` parameterization | ✅ |
| leaves no Codex batch-budget state behind | Edge Case | state hygiene | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full PoshQC run, executor) | 1391 | ✅ |
| Tests Passed | 1391 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Review re-run (5 affected Pester suites) | 59 tests, 0 failures | ✅ |
| Review re-run (pytest parity) | 8 passed | ✅ |
| Execution Time (new suites, review re-run) | 63.2s + 13.4s | ✅ Acceptable (process-level by design) |
| Discovery Time (new suites) | 213ms + 292ms | ✅ |
| Test File Size | 269 / 198 / 278 lines | ✅ Maintainable |
| Code Coverage | 90.15% lines repo-wide (measured set); branch coverage not emitted by Pester/JaCoCo through PoshQC (all `mb`/`cb` attributes zero — verified) | ⚠️ See B1/B2 |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check tests/scripts/dev_tools` | 182 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check tests/scripts/dev_tools` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors, 0 warnings | ✅ |
| Pytest Tests | `poetry run pytest <2 parity modules> -q` | 8 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | exit 0, no changes | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | 0 findings | ✅ |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` / `Invoke-Pester` (review) | 1391 pass / 59 pass | ✅ |

**Notes:**
No pre-existing failures. The two baseline parity failures expected from the pre-branch root/bundle `config.toml` divergence were resolved by discarding the uncommitted root-side ordering swap; `.codex/config.toml` is byte-identical to the merge-base and to its bundle copy (SHA verified).

---

## 8. Gaps and Exceptions

### Identified Gaps

- **B1 (Blocking) — PowerShell coverage instrument excludes the changed production surface.** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` contains only 2 of the 10 changed `.codex/hooks` production files (`enforce-completion-consistency.ps1`, `enforce-completion-helpers.ps1`). The new 474-line module `codex-pretooluse-file-mapping.ps1` and 7 rewired hooks have no per-file coverage measurement, so the new-file (≥85% line) and modified-file (≥85% line, no changed-line regression) thresholds cannot be verified. `.claude/rules/general-unit-test.md` (Coverage Exclusion Policy) requires every production source file in the coverage denominator, and the runsettings file's own history (issues #275, #301, #305, #312, #334, #344, #357, #366, #392) shows the repository convention of adding new/changed production files to the measured set — several of those entries were themselves remediation-cycle fixes for exactly this gap. The executor flagged the omission as a follow-up (`coverage-comparison.2026-07-25T21-06.md`); this audit escalates it to Blocking. Remediation is enumerated in `remediation-inputs.2026-07-25T21-03.md`.
- **B2 (Blocking) — Python coverage artifact absent for a language with changed files.** `artifacts/python/lcov.info` does not exist and no per-language Python coverage evidence was captured for this branch. The branch changes one Python test file, so per the mandatory coverage-verification rule the Python coverage verdict fails closed. Context for the remediation planner: no production Python changed; parity suites pass 8/8; the gap is evidentiary, closable by one full `poetry run pytest --cov` run with the numbers recorded under `evidence/qa-gates/`.
- **Minor — branch coverage is not emitted by the PowerShell toolchain.** Verified directly: every `mb`/`cb` attribute in `artifacts/pester/powershell-coverage.xml` is zero and no aggregate BRANCH counter exists. This is a pre-existing, documented toolchain limitation (`spec.md:248`), not a waiver introduced by this branch. It is recorded here so the ≥75% branch threshold's non-evaluation is explicit.
- **Info — `.codex/state/` is not gitignored.** The untracked runtime state directory was deleted manually as environment hygiene and is absent at review time. A `.gitignore` entry would prevent recurrence; out of scope for this fix.

### Approved Exceptions

**None.** No exceptions were requested or approved. (The plan-level narrowing of the Python coverage gate was not an approved exception and is rejected in `## Rejected Scope Narrowing`.)

### Removed/Skipped Tests

**None.** No tests were removed or skipped. Two parity-suite assertions were retargeted at the shared module with identical expected values (`legacy-codex-hook-contracts.Tests.ps1`, tasks `[P5-T4]`/`[P6-T4]`); no deny-path or fail-closed assertion changed.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **11c41d60** - docs(codex-hooks): promote and plan Codex PreToolUse transport repair (#415)
2. **25d0b39c** - chore(415): capture Phase 0 policy-read and toolchain baselines
3. **ee98ca7f** - fix(codex-hooks): admit every matched tool name in PreToolUse handlers

### Files Modified

1. **`.codex/hooks/codex-pretooluse-file-mapping.ps1`** (NEW, + bundle mirror)
   - Shared transport module: `ConvertFrom-CodexPreToolUsePayload` (hook-named exit-2 throws; optional `-RequireSessionId`) and `ConvertTo-CodexFileEditInput` (tool-name admission, direct mapping, apply_patch marker parsing, governed-path-scoped Update reconstruction), plus 3 documented internal helpers.
2. **8 rewired hooks under `.codex/hooks/`** (MODIFIED, + bundle mirrors)
   - Per-hook `apply_patch`-only validators and mapping helpers deleted; entrypoints call the shared module; every policy function byte-unchanged; `enforce-evidence-locations` docstring corrected and its empty-stdin silent-allow latent defect closed (now exit 2, per spec AC 4).
3. **`extensions/.../hooks/enforce-pr-author-skill.ps1`** (DELETED)
   - Unregistered bundle-only legacy-transport orphan removed for byte-identity; #335 cross-reference note recorded.
4. **`extensions/.../pack-manifests/core.json`** (MODIFIED)
   - New shared module listed.
5. **Tests** (2 NEW suites, 1 MODIFIED suite, 1 MODIFIED pytest module)
   - Process-level transport/integration contract coverage; parity/static lists extended to the shared module; stale pytest exception entry removed.
6. **Feature docs/evidence** (NEW)
   - spec, plan, research, promoted note, and 27 evidence artifacts under canonical `evidence/<kind>/` paths.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT — BLOCKED pending coverage remediation

The implementation, tests, parity gates, toolchain hygiene, and hard-constraint compliance are verified and sound. The audit cannot report PASS because required coverage evidence is incomplete: per-file coverage for the new/changed PowerShell production surface is outside the coverage instrument (B1), and the Python per-language coverage artifact is absent (B2). Per the fail-closed rule, the verdict is BLOCKED for coverage, not PASS.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objective, plan, and baselines recorded
- ✅ Design Principles: extraction removes duplication; policy/transport separation clean
- ✅ Module & File Structure: all files ≤ 500 lines (measured)
- ✅ Naming, Docs, Comments: approved verbs; rationale-first comments
- ✅ Toolchain Execution: final loop clean in one pass, evidence recorded
- ✅ Summarize & Document: complete

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black/Ruff/Pyright/Pytest clean (re-verified)
- ✅ Python Design & Typing: trivial constant change
- ✅ Error Handling: no runtime paths changed

**For PowerShell:**
- ✅ Tooling & Baseline: format/analyze/test clean
- ✅ PowerShell Design & Safety: advanced functions, validation, fail-fast with documented deliberate exceptions
- ✅ Structure & Naming: under cap, approved verbs
- ✅ Toolchain: clean single pass after one disciplined restart

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, deterministic
- ❌ Coverage & Scenarios: scenario completeness PASS; numeric coverage evidence for the changed surface FAIL (B1, B2)
- ✅ Test Structure: AAA, diagnostic assertions
- ✅ External Dependencies: no temp files, no env dependence (poisoned-env proof)

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest only
- ❌ Coverage expectation: artifact absent (B2)
- ✅ Test Style & Structure / Naming & Readability / Toolchain

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 via PoshQC
- ✅ Test Style & Structure: behavior-contract focused
- ✅ Naming & Readability: compliant
- ✅ Toolchain: compliant

### Metrics Summary

- ✅ 1391/1391 Pester tests passing (100%); 59 re-verified independently
- ✅ 8/8 pytest parity contracts passing (re-verified)
- ⚠️ 90.15% repo-wide line coverage on the measured set (≥85% threshold met), but the changed production surface is largely outside the measured set (B1)
- ❌ Python coverage artifact absent (B2)
- ✅ All code quality checks passing (format, lint, type-check)
- ✅ Root/bundle byte parity: `diff -r` clean across the full `.codex/` tree
- ✅ Hard constraints 1–6 verified (see feature audit)

### Recommendation

**Needs revision (remediation required before PR).** Two Blocking findings (B1, B2), both coverage-evidence gaps rather than behavioral defects. Remediation is enumerated in `remediation-inputs.2026-07-25T21-03.md`; no production behavior change is expected from either fix.

---

## Appendix A: Test Inventory

### New suites (this branch)

1. Codex PreToolUse hooks honour the native stdin transport contract › allows a safe Edit payload on every group handler
2. Codex PreToolUse hooks honour the native stdin transport contract › allows a safe Write payload on every group handler
3. Codex PreToolUse hooks honour the native stdin transport contract › allows a safe apply_patch payload on every group handler
4. Codex PreToolUse hooks honour the native stdin transport contract › allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'')
5. Codex PreToolUse hooks honour the native stdin transport contract › allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'noop')
6. Codex PreToolUse hooks honour the native stdin transport contract › fails closed with exit 2 when a batch-budget payload omits session_id
7. Codex PreToolUse hooks honour the native stdin transport contract › allows an apply_patch update that touches only ungoverned files with a missing source
8. Codex PreToolUse hooks honour the native stdin transport contract › emits only the native deny envelope for a forbidden payload (15 parameterized cases: purity ×6, evidence-locations ×3, checkpoint-monotonic ×3, completion-consistency ×3)
9. Codex PreToolUse hooks honour the native stdin transport contract › denies a preimplementation-gate implementation path mapped from Edit/Write/apply_patch (3 cases)
10. Codex PreToolUse hooks honour the native stdin transport contract › fails closed with exit 2 for a missing/null tool_input on every group handler (2 cases)
11. Every registered Codex PreToolUse handler accepts every tool name its matcher admits › parses at least three matcher groups and every registered handler from config.toml
12. Every registered Codex PreToolUse handler accepts every tool name its matcher admits › allows every registered handler for every tool name its own matcher admits
13. Every registered Codex PreToolUse handler accepts every tool name its matcher admits › fails closed with exit 2 for empty stdin / invalid JSON on every registered handler (2 cases)
14. Every registered Codex PreToolUse handler accepts every tool name its matcher admits › reports enforce-completion-consistency in its own stderr rather than its neighbour
15. Every registered Codex PreToolUse handler accepts every tool name its matcher admits › leaves no Codex batch-budget state behind

### Parity/regression suites re-run by this review

- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 (12 tests)
- tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 (10 tests)
- tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 (4 tests)
- tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py + test_push_down_codex_and_agents_pack_manifest_completeness.py (8 tests)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Formatting
poetry run black --check tests/scripts/dev_tools

# Linting
poetry run ruff check tests/scripts/dev_tools

# Type checking
poetry run pyright

# Testing (parity contracts)
poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q

# Coverage (required for B2 remediation)
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**For PowerShell:**
```powershell
# Formatting
mcp__drm-copilot__run_poshqc_format   # or: Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
mcp__drm-copilot__run_poshqc_analyze  # or: Invoke-PoshQCAnalyze -Root .

# Testing + coverage
mcp__drm-copilot__run_poshqc_test     # or: Invoke-PoshQCTest -Root .

# Review re-verification (targeted)
Invoke-Pester -Path tests/scripts/codex-hooks, tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 -Output Normal
```

**Review-specific checks:**
```bash
git diff --stat 00980851..HEAD -- .claude/                # empty
git diff 00980851..HEAD -- .codex/config.toml             # empty
diff -r .codex extensions/drm-copilot/resources/codex-and-agents-customizations/.codex   # clean
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .              # exit 0
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-25
**Policy Version:** Current (as of audit date)
