# Policy Compliance Audit: Claude Code architecture v2 (#136)

---

**Audit Date:** 2026-04-13  
**Code Under Test:** Claude runtime files under `.claude/`, `CLAUDE.md`, `docs/engineering/claude-code-architecture.md`, `.claude/hooks/validate-bash.ps1`, and the runtime PowerShell tests under `tests/scripts/claude-runtime/` and `tests/scripts/claude-hooks/`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | Stored remediation evidence only for supporting runtime validation | 255 unit tests | ✅ 255 pass, 0 fail | Statements 94.77%; Branches 83.72%; Functions 98.65%; Lines 94.77% | Statements 94.77%; Branches 83.72%; Functions 98.65%; Lines 94.77% | Unavailable from stored tool output |
| PowerShell | `.claude/hooks/validate-bash.ps1`, runtime agent/rule docs, and runtime Pester suites | 27 targeted Pester tests | ✅ 27 pass, 0 fail | Unavailable | Unavailable | Unavailable |
| JSON | `.claude/settings.json` | N/A | ✅ validation passed | N/A | N/A | N/A |
| Markdown / agent docs | review scope only | N/A | N/A | N/A | N/A | N/A |

---

## Executive Summary

This re-audit evaluates the current `v2` workspace state after the remediation execution. The feature remains strong on structure: the selected-version review-path guidance is still correct, the targeted PowerShell analyzer and test reruns both passed, JSON validation passed, and the stored TypeScript coverage evidence remains strong. The feature is not yet policy-clean, however, because the Claude runtime still encodes a stale PowerShell **test** MCP symbol in implementation files and regression tests.

The authoritative repository PowerShell policies now require `mcp_drmcopilotext_run_poshqc_test` for the PowerShell test runner, while the current Claude runtime files and runtime tests still use `mcp__drmCopilotExtension__run_poshqc_test`. Because the tests assert the stale symbol, the current passing targeted Pester run validates the wrong contract. The coverage story also remains incomplete for the PowerShell remediation scope because the targeted runner does not provide a numeric changed/new-code coverage value.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md`
- ✅ `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- ❌ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` (stored remediation evidence only)
- ✅ JSON: `validate_json` expectation for `.claude/settings.json`

**Temporary artifacts cleanup:**
- ✅ No temporary one-time scripts were added by this review.
- ✅ The reviewed ongoing hook/test assets are permanent repository files covered by automated tests.
- ⚠️ This review did not modify or clean generated non-feature artifacts outside the requested audit scope.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `validate-bash.Tests.ps1` saves and restores `CLAUDE_TOOL_INPUT` around tests that modify it, and the runtime structure tests are file-content assertions only. |
| **Isolation** - Each test targets single behavior | ✅ PASS | The hook suite separates blocked-command, safe-command, empty-input, malformed-JSON, and valid-JSON scenarios. The runtime suites isolate settings, structure, and architecture-doc contracts. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Current targeted PowerShell rerun completed in `1.75s` for `27` tests. Stored TypeScript evidence reports `17` suites and `255` tests in a successful coverage run. |
| **Determinism** - Consistent results | ✅ PASS | The reviewed tests rely on local file inspection and direct script invocation only. No network, external service, or temporary-file dependency was introduced. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | The PowerShell tests use clear `Describe`/`Context`/`It` organization and descriptive scenario names. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ⚠️ PARTIAL | Stored TypeScript baseline/final values are documented in `p5-t6.typescript-coverage.2026-04-13T09-09.md` and `p5-t10.coverage-comparison.2026-04-13T09-09.md`. The PowerShell remediation run explicitly records `CoverageNumericValues: unavailable`. |
| **No Coverage Regression** | ✅ PASS | Stored TypeScript evidence reports no regression (`94.77%` lines before and after). No current PowerShell regression failure was observed, but the targeted PowerShell coverage value is unavailable. |
| **New Code Coverage ≥90%** | ⚠️ PARTIAL | The PowerShell remediation evidence does not provide a numeric changed/new-code coverage figure, so this requirement is unresolved for the targeted PowerShell scope. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | The runtime tests cover key static contracts and hook behavior, but `claude-settings.Tests.ps1` and `claude-architecture-doc.Tests.ps1` currently encode the stale PowerShell test symbol, so they do not fully cover the active repository policy contract. |
| **Positive Flows** - Valid inputs | ✅ PASS | Safe-command and valid-JSON hook cases are covered and passing. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Blocked-command scenarios are covered and passing. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Empty-input and malformed-JSON fallback cases are covered and passing. |
| **Error Handling** - Error paths | ✅ PASS | The hook tests validate explicit non-zero exits for blocked operations and safe fallback behavior for malformed JSON. |
| **Concurrency** - If applicable | N/A | Not applicable to the reviewed runtime scope. |
| **State Transitions** - If applicable | ⚠️ PARTIAL | Checkpoint references are present, but live checkpoint resume remains unverified in the current environment. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | The runtime tests assert concrete missing files, forbidden strings, and required key paths, which would produce actionable failures. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | The hook tests clearly separate environment setup, script invocation, and exit-code assertions. |
| **Document Intent** | ✅ PASS | The test names are sufficiently explicit to communicate the intended contract for each scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The reviewed tests are local file and command-behavior tests only. |
| **Use Mocks/Stubs** | ✅ PASS | No external services required mocking for the reviewed runtime tests. |
| **Environment Stability** | ✅ PASS | The tests restore changed environment state and do not create temporary files. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required post-remediation policy audit for the `v2` feature scope. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | The objective remains documented in `issue.md`, `v2/spec.md`, `v2/user-story.md`, `plan.2026-04-12T15-57.md`, and `remediation-plan.2026-04-13T08-16.md`. |
| **Read existing change plans** | ✅ PASS | The primary plan and remediation plan both exist and were reviewed as part of this re-audit. |
| **Document the plan** | ✅ PASS | The `v2` folder contains a machine-readable plan, remediation inputs, remediation plan, and evidence set. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The runtime is still decomposed into clear layers: standing instructions, rules, skills, agents, settings, and hooks. |
| **Reusability** | ✅ PASS | Shared contracts remain mirrored into reusable Claude skills referenced from runtime agents. |
| **Extensibility** | ✅ PASS | The architecture documentation continues to present explicit migration maps and worker-routing boundaries. |
| **Separation of concerns** | ✅ PASS | Settings, hooks, guidance, worker definitions, and review artifacts remain clearly separated. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The reviewed hook script and runtime guidance files remain narrowly scoped to single responsibilities. |
| **Under 500 lines** | ✅ PASS | The reviewed executable/configuration files remain under the repository line limit; Markdown documentation is exempt. |
| **Public vs internal** | ✅ PASS | Skills remain the direct-use surface; agents, hooks, and settings remain internal runtime machinery. |
| **No circular dependencies** | ✅ PASS | No circular dependency issue was evident in the reviewed scope. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | File and symbol names remain explicit and role-oriented. |
| **Docs/docstrings** | ✅ PASS | The hook retains a structured help block, and the runtime docs remain comprehensive. |
| **Comment why, not what** | ✅ PASS | The current prose focuses on rationale, non-equivalences, and enforcement semantics. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ⚠️ PARTIAL | This re-audit did not rerun mutating formatter commands. Stored remediation evidence exists for the last formatter pass, but this review preferred non-mutating verification only. |
| **2. Linting** | ✅ PASS | `Invoke-PoshQCAnalyze ...` returned `POSH_ANALYZE_EXIT=0` with no findings for the targeted runtime scope. |
| **3. Type checking** | ✅ PASS | PowerShell has no type-check phase, and `.claude/settings.json` validation returned `JSON_VALIDATE_EXIT=0`. Stored TypeScript type-check evidence remains passing. |
| **4. Testing** | ✅ PASS | `Invoke-PoshQCTest ...` returned `POSH_TEST_EXIT=0` with `27` passing targeted tests and `0` failures. |
| **Full toolchain loop** | ⚠️ PARTIAL | The stored remediation evidence shows a full QA loop, but this re-audit reran only non-mutating validation steps. |
| **Explicit reporting** | ✅ PASS | Commands, exit codes, and evidence paths are recorded in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | The refreshed PR context and `v2` evidence set describe the current scope and remediation history. |
| **Design choices explained** | ✅ PASS | `docs/engineering/claude-code-architecture.md` still explains the migration mapping, non-equivalences, and sync strategy. |
| **Update supporting documents** | ✅ PASS | The feature scope includes updated architecture documentation, scoping docs, plans, and evidence. |
| **Provide next steps** | ✅ PASS | This audit identifies the exact remaining remediation work and the live-session follow-up still required. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ⚠️ PARTIAL | Stored remediation evidence exists for the last formatter run, but this re-audit did not rerun the mutating formatter. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | `Invoke-PoshQCAnalyze ...` returned `POSH_ANALYZE_EXIT=0` and printed `PSScriptAnalyzer passed: no findings`. |
| **Fix all findings** | ✅ PASS | No current analyzer findings were surfaced for `.claude/hooks`, `tests/scripts/claude-runtime`, or `tests/scripts/claude-hooks`. |
| **Use approved MCP tool names** | ❌ FAIL | `.claude/settings.json:40`, `.claude/rules/powershell.md:18`, and `.claude/agents/atomic-executor.md:23,64` still use `mcp__drmCopilotExtension__run_poshqc_test`, but `.github/instructions/powershell-code-change.instructions.md:24,75` and `.github/instructions/powershell-unit-test.instructions.md:23,65` require `mcp_drmcopilotext_run_poshqc_test` for the test runner. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions / focused scripts** | ✅ PASS | `validate-bash.ps1` remains a focused hook script using `CmdletBinding()`. |
| **Avoid global state** | ✅ PASS | The reviewed PowerShell code uses local variables only; tests restore modified environment state. |
| **Error handling** | ✅ PASS | The hook uses explicit errors and exit codes for blocked patterns. |
| **Compatibility with PowerShell 7+** | ✅ PASS | No incompatible PowerShell feature usage was observed in the reviewed scope. |

### Section 3E: TypeScript Code Change Policy Compliance

#### 3E.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ⚠️ PARTIAL | This re-audit relied on stored remediation evidence rather than rerunning a mutating formatter pass. |
| **Linting with ESLint** | ✅ PASS | Stored remediation evidence records a successful lint run in `p5-t4.typescript-lint.2026-04-13T09-09.md`. |
| **Type checking with TSC** | ✅ PASS | Stored remediation evidence records a successful type-check run in `p5-t5.typescript-typecheck.2026-04-13T09-09.md`. |
| **Testing with Jest** | ✅ PASS | Stored remediation evidence records `17` passing suites and `255` passing tests in `p5-t6.typescript-coverage.2026-04-13T09-09.md`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | The targeted PowerShell rerun used `Invoke-PoshQCTest`, and the runtime tests executed as Pester suites. |
| **Focused unit tests** | ✅ PASS | `validate-bash.Tests.ps1` targets one behavior per scenario group and remains deterministic. |
| **Organization mirrors code** | ✅ PASS | `tests/scripts/claude-hooks/validate-bash.Tests.ps1` mirrors `.claude/hooks/validate-bash.ps1`. |
| **Use the canonical PowerShell test runner contract** | ❌ FAIL | `tests/scripts/claude-runtime/claude-settings.Tests.ps1:37-41` and `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1:28,37-39` still assert the stale `mcp__drmCopilotExtension__run_poshqc_test` symbol instead of the policy-required `mcp_drmcopilotext_run_poshqc_test`. |

### Section 4E: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | ✅ PASS | Stored remediation evidence records a successful Jest coverage run in `p5-t6.typescript-coverage.2026-04-13T09-09.md`. |
| **Focused unit tests** | ✅ PASS | No new TypeScript unit-test defect was surfaced in the current review evidence. |
| **Avoid live host dependencies** | ✅ PASS | The stored Jest run completed without requiring a live Claude runtime session. |

---

## 5. Test Coverage Detail

| Area | Status | Evidence |
|---|---|---|
| TypeScript repository coverage | ✅ PASS | `p5-t6.typescript-coverage.2026-04-13T09-09.md` reports Statements `94.77%`, Branches `83.72%`, Functions `98.65%`, Lines `94.77%`. |
| TypeScript no-regression comparison | ✅ PASS | `p5-t10.coverage-comparison.2026-04-13T09-09.md` reports no TypeScript coverage regression. |
| PowerShell targeted test coverage value | ⚠️ PARTIAL | `p5-t7.poshqc-test.2026-04-13T09-09.md` explicitly records `CoverageNumericValues: unavailable` and `CoverageClaimStatus: unresolved`. |
| PowerShell changed/new-code coverage | ⚠️ PARTIAL | `p5-t10.coverage-comparison.2026-04-13T09-09.md` records `PowerShellAcceptanceClaimStatus: unresolved/remediation-required`. |

---

## 6. Test Execution Metrics

| Command | Result | Metrics |
|---|---|---|
| `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json` | ✅ PASS | `JSON_VALIDATE_EXIT=0` |
| `Invoke-PoshQCAnalyze -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders '.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks'` | ✅ PASS | `POSH_ANALYZE_EXIT=0`; no findings |
| `Invoke-PoshQCTest -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders 'tests/scripts/claude-runtime','tests/scripts/claude-hooks'` | ✅ PASS | `POSH_TEST_EXIT=0`; `27` passed, `0` failed; completed in `1.75s` |
| `npm run test:unit:coverage` (stored remediation evidence) | ✅ PASS | `17` passing suites; `255` passing tests |

---

## 7. Code Quality Checks

| Check | Status | Evidence |
|---|---|---|
| PR context refreshed against supplied base branch | ✅ PASS | `p4-t1.pr-context-refresh.2026-04-13T09-09.md` |
| Targeted PowerShell analyzer rerun | ✅ PASS | Current command output: `PSScriptAnalyzer passed: no findings`; `POSH_ANALYZE_EXIT=0` |
| Targeted PowerShell test rerun | ✅ PASS | Current command output: `Tests Passed: 27, Failed: 0`; `POSH_TEST_EXIT=0` |
| JSON schema validation | ✅ PASS | Current command output: `JSON_VALIDATE_EXIT=0` |
| Runtime PowerShell test symbol matches policy | ❌ FAIL | Current file inspection and grep results show stale `mcp__drmCopilotExtension__run_poshqc_test` usage in runtime files and tests. |

---

## 8. Gaps and Exceptions

1. **Live Claude runtime unavailable:** `p4-t2.live-entrypoints.2026-04-13T09-09.md` and `p4-t3.live-enforcement.2026-04-13T09-09.md` both record `LiveSessionAvailable: no`, so slash-command, checkpoint-resume, permission-probe, and stop-gate criteria remain unverified.
2. **PowerShell coverage values unavailable:** The targeted PowerShell rerun still does not expose numeric changed/new-code coverage values for the remediation scope.
3. **Targeted MCP wrapper misbinds multi-folder scan arguments:** Stored remediation evidence notes that the multi-folder MCP wrapper misbound `ScanFolders`, so the equivalent direct `Invoke-PoshQCAnalyze` and `Invoke-PoshQCTest` commands were used for targeted PowerShell verification.

---

## 9. Summary of Changes

The reviewed feature still delivers a multi-layer Claude runtime architecture with version-aware feature review output guidance, documented migration maps, a PowerShell command-blocking hook, and deterministic runtime regression suites. The post-remediation state remains strong on structure and documentation.

The remaining policy issue is narrow but material: the PowerShell **test** MCP contract is still stale across runtime guidance, settings, architecture documentation, and runtime tests. Because the runtime tests currently assert that stale symbol, the passing Pester gate does not yet prove compliance with the active repository PowerShell policy.

---

## 10. Compliance Verdict

**Verdict:** ❌ FAIL — remediation required

**Reason:** The feature is not yet compliant with the current repository PowerShell policy because the runtime still uses and tests the stale symbol `mcp__drmCopilotExtension__run_poshqc_test` instead of the policy-required `mcp_drmcopilotext_run_poshqc_test`. PowerShell changed/new-code coverage evidence also remains unresolved for the targeted remediation scope.

---

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/validate-bash.Tests.ps1` — hook blocked-command, safe-command, empty-input, malformed-JSON, and valid-JSON coverage
- `tests/scripts/claude-runtime/claude-settings.Tests.ps1` — settings routing and PowerShell tool-name assertions
- `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` — wrapper skill and worker inventory assertions
- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` — architecture documentation contract assertions

---

## Appendix B: Toolchain Commands Reference

- `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/development`
- `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCAnalyze -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders '.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks' }"`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders 'tests/scripts/claude-runtime','tests/scripts/claude-hooks' }"`
- `npm run test:unit:coverage` (stored remediation evidence)
| **PowerShell 5.1 & 7.6+ compatible** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe compatibility testing. Note any version-specific features.] |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe use of CmdletBinding and parameter attributes. N/A for test files.] |
| **Parameter validation** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe parameter validation attributes used. N/A for test files.] |
| **Avoid global state** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe how global state is avoided. Note any legitimate global usage.] |
| **Error handling** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe error handling approach. Note use of try/catch, -ErrorAction, etc.] |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Report file line counts. Confirm all under limit.] |
| **Approved verbs** | [✅/❌/N/A] [PASS/FAIL/N/A] | [List all function names and confirm verbs are approved.] |
| **Comment why** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe commenting approach. Confirm focus on rationale.] |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe execution and result.] |
| **Step 2: Analyze** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe execution and result.] |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe execution and result.] |
| **Rerun loop if needed** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe how many iterations were needed.] |

---

### Section 3C: Bash Script Policy Compliance (if applicable)

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Command:** `poetry run shell-qc format`<br>**Result:** [Describe result] |
| **Linting with shellcheck** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Command:** `poetry run shell-qc check`<br>**Result:** [Describe result] |
| **Testing with bats** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Command:** `poetry run shell-qc test`<br>**Result:** [Describe result or N/A if no tests] |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Confirm `#!/usr/bin/env bash` or `#!/bin/bash` used.] |
| **Error handling** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe use of `set -e`, `set -u`, `set -o pipefail`, error traps.] |
| **Under 500 lines** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Report file line counts.] |

---

### Section 3D: JSON Configuration Policy Compliance (if applicable)

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Command:** `poetry run python -m scripts.dev_tools.format_json`<br>**Result:** [Describe result - files formatted or already formatted] |
| **Schema validation** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Command:** `poetry run python -m scripts.dev_tools.validate_json`<br>**Result:** [Describe result - all schemas valid] |
| **Required $schema** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Confirm all governed JSON files have `$schema` property.] |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Confirm no comments, trailing commas, or other JSON5 features.] |
| **Deterministic key order** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Confirm keys are sorted via `jq --sort-keys`.] |

---

## 4. Language-Specific Unit Test Policy Compliance

**Instructions:** Complete one section per language with tests. Delete sections for languages not used or not tested.

---

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe use of Pytest. Note any fixtures or plugins used.] |
| **Coverage expectation** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Report coverage metrics. Confirm new code has >= 90% coverage and repo-wide >= 80%.] |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe test focus. Confirm each test exercises single behavior.] |
| **Mocking sparingly** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe mocking strategy. List what is mocked and why.] |
| **Organization** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe test organization. Confirm tests mirror code structure.] |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe test naming. Provide examples of descriptive test names.] |
| **Docstrings/comments** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe documentation approach for tests.] |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Command:** `poetry run pytest`<br>**Result:** [Describe test results] |
| **No Alternative Test Runners** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Confirm only Pytest is used.] |

---

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe Pester v5 features used (BeforeAll, BeforeEach, Describe/Context/It, modern Should syntax).] |
| **Use PoshQC Configuration** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>[Describe configuration updates if any.] |
| **PowerShell 5.1 & 7.6+ Compatible** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe compatibility testing. Note any version-specific features.] |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe test focus. Report test distribution across functions.] |
| **Test Behavior Over Implementation** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe what behaviors are tested vs. implementation details.] |
| **Mocking Used Sparingly** | [✅/❌/N/A] [PASS/FAIL/N/A] | [List all mocked components and justification for each.] |
| **Organization** | [✅/❌/N/A] [PASS/FAIL/N/A] | **CRITICAL:** Test file location must mirror code file location.<br>**Test file:** `[path]`<br>**Code file:** `[path]`<br>[Confirm structure mirrors code location.] |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | [✅/❌/N/A] [PASS/FAIL/N/A] | [Confirm file named correctly: `[name].Tests.ps1`] |
| **Describe/Context/It Structure** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe test structure: # Describe blocks, # Context blocks, # It blocks.] |
| **Logical Grouping** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe how tests are grouped. Show grouping strategy.] |
| **Docstrings/Comments** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Describe documentation approach. Note that test names should be self-documenting.] |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** [Describe test results] |
| **No Alternative Test Runners** | [✅/❌/N/A] [PASS/FAIL/N/A] | [Confirm only Pester is used through PoshQC.] |

---

## 5. Test Coverage Detail

**Instructions:** Create one subsection for each function/class/module under test. Use tables to show test names, scenario types, lines covered, and status.

### [Function/Class/Module Name] ([N] tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| [test name] | [Positive/Negative/Edge Case/Error Handling] | [line ranges] | [✅/❌] |
| [test name] | [Positive/Negative/Edge Case/Error Handling] | [line ranges] | [✅/❌] |
| [test name] | [Positive/Negative/Edge Case/Error Handling] | [line ranges] | [✅/❌] |

**Coverage:** [X]% of [function/class] (lines [start]-[end])

**Detailed line-by-line coverage (optional):**
- Line [N]: [✅/❌] Covered ([describe what's tested])
- Lines [N-M]: [✅/❌] Covered ([describe what's tested])
- Line [N]: ❌ Not covered ([explain why or plan to cover])

**Not covered:** [List any untested code and justification, or state "None"]

---

### [Additional Function/Class/Module] ([N] tests)

[Repeat structure above for each component tested]

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | [N] | [✅/❌] |
| Tests Passed | [N] ([X]%) | [✅/❌] |
| Tests Failed | [N] | [✅/❌] |
| Execution Time | [X]s total | [✅/❌] Fast/Slow |
| Average Time per Test | [X]ms | [✅/❌] Fast/Slow |
| Discovery Time | [X]ms | [✅/❌] |
| Functions/Classes Tested | [N]/[M] ([X]%) | [✅/❌] |
| Test File Size | [N] lines | [✅/❌] Maintainable |
| Code Coverage (if applicable) | [X]% lines, [Y]% branches | [✅/❌] |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black .` | [result] | [✅/❌] |
| Ruff Linting | `poetry run ruff check` | [result] | [✅/❌] |
| Pyright Type Checking | `poetry run pyright` | [result] | [✅/❌] |
| Pytest Tests | `poetry run pytest` | [result] | [✅/❌] |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | [result] | [✅/❌] |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | [result] | [✅/❌] |
| Pester Tests | `Invoke-PoshQCTest -Root .` | [result] | [✅/❌] |

**Notes:**
[Document any pre-existing failures unrelated to this work. Explain any deviations from clean runs.]

---

## 8. Gaps and Exceptions

### Identified Gaps
[List any policy requirements that are not fully met. If none, state "**None.** All policy requirements are met."]

**Example:**
- [Requirement name]: [Description of gap and plan to address]

### Approved Exceptions
[List any approved exceptions to policy requirements with justification. If none, state "**None.** No exceptions needed."]

**Example:**
- [Requirement name]: [Justification for exception and approval source]

### Removed/Skipped Tests
[List any tests that were planned but removed or skipped, with justification. If none, state "**None.** All planned tests implemented."]

**Example:**
1. **"[test name]"** - Removed in commit [hash]
   - **Reason:** [Why was it removed?]
   - **Impact:** [What coverage is lost?]
   - **Justification:** [Why is this acceptable?]

---

## 9. Summary of Changes

### Commits in This PR/Branch

[List all commits with hashes and brief descriptions]

**Example:**
1. **[hash]** - [commit message]
2. **[hash]** - [commit message]
3. **[hash]** - [commit message]

### Files Modified

[List all files that were created, modified, or deleted]

**Example:**

1. **[path/to/file]** (NEW/MODIFIED/DELETED)
   - [Description of changes]
   - [Key points]

2. **[path/to/file]** (NEW/MODIFIED/DELETED)
   - [Description of changes]
   - [Key points]

3. **[path/to/file]** (NEW/MODIFIED/DELETED)
   - [Description of changes]
   - [Key points]

---

## 10. Compliance Verdict

### Overall Status: [✅ FULLY COMPLIANT / ⚠️ PARTIALLY COMPLIANT / ❌ NON-COMPLIANT]

[Provide a brief summary of overall compliance status and any major findings.]

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- [✅/⚠️/❌] Before Making Changes: [Brief status]
- [✅/⚠️/❌] Design Principles: [Brief status]
- [✅/⚠️/❌] Module & File Structure: [Brief status]
- [✅/⚠️/❌] Naming, Docs, Comments: [Brief status]
- [✅/⚠️/❌] Toolchain Execution: [Brief status]
- [✅/⚠️/❌] Summarize & Document: [Brief status]

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- [✅/⚠️/❌] Tooling & Baseline: [Brief status]
- [✅/⚠️/❌] Python Design & Typing: [Brief status]
- [✅/⚠️/❌] Error Handling: [Brief status]

**For PowerShell:**
- [✅/⚠️/❌] Tooling & Baseline: [Brief status]
- [✅/⚠️/❌] PowerShell Design & Safety: [Brief status]
- [✅/⚠️/❌] Structure & Naming: [Brief status]
- [✅/⚠️/❌] Toolchain: [Brief status]

#### General Unit Test Policy (Section 1)
- [✅/⚠️/❌] Core Principles: [Brief status]
- [✅/⚠️/❌] Coverage & Scenarios: [Brief status]
- [✅/⚠️/❌] Test Structure: [Brief status]
- [✅/⚠️/❌] External Dependencies: [Brief status]
- [✅/⚠️/❌] Policy Audit: [Brief status]

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- [✅/⚠️/❌] Framework & Scope: [Brief status]
- [✅/⚠️/❌] Test Style & Structure: [Brief status]
- [✅/⚠️/❌] Naming & Readability: [Brief status]
- [✅/⚠️/❌] Toolchain: [Brief status]

**For PowerShell:**
- [✅/⚠️/❌] Framework & Scope: [Brief status]
- [✅/⚠️/❌] Test Style & Structure: [Brief status]
- [✅/⚠️/❌] Naming & Readability: [Brief status]
- [✅/⚠️/❌] Toolchain: [Brief status]

---

### Metrics Summary

[Provide a bulleted summary of key metrics from Section 6]

**Example:**
- [✅/❌] [N]/[M] tests passing ([X]%)
- [✅/❌] [N]/[M] functions/classes tested ([X]%)
- [✅/❌] [X]% line coverage
- [✅/❌] Proper file organization: [describe]
- [✅/❌] All code quality checks passing
- [✅/❌] Test execution time: [X] seconds ([fast/slow])

---

### Recommendation

**[Ready for merge / Needs revision / Blocked]**

[Provide clear recommendation and any next steps. If not ready for merge, list specific items that must be addressed.]

---

## Appendix A: Test Inventory

### Complete Test List

[List all tests in a hierarchical structure that matches the test organization (Describe/Context/It or test class hierarchy)]

**Example format:**

1. [Describe/Class] › [Context/Method] › [test name]
2. [Describe/Class] › [Context/Method] › [test name]
3. [Describe/Class] › [Context/Method] › [test name]
...

**Alternative flat format:**

- [test_module.py::TestClassName::test_method_name]
- [test_module.py::TestClassName::test_method_name]
- [test_module.py::test_function_name]
...

---

## Appendix B: Toolchain Commands Reference

[Provide quick reference of all commands used in this audit]

**For Python:**
```bash
# Formatting
poetry run black .

# Linting
poetry run ruff check
poetry run ruff check --fix  # auto-fix

# Type checking
poetry run pyright

# Testing
poetry run pytest
poetry run pytest --cov=src/[package] --cov-report=term-missing
```

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

---

**Audit Completed By:** [Agent Name / Human Name]  
**Audit Date:** [YYYY-MM-DD]  
**Policy Version:** Current (as of audit date)
