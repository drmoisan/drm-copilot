# Policy Compliance Audit: Claude Code Architecture (#136)

---

**Audit Date:** 2026-04-12  
**Code Under Test:** All 17 new files in `.claude/`, `CLAUDE.md`, and `docs/engineering/claude-code-architecture.md`  
**Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/`  
**Feature Folder Selection Rule:** Single active feature folder matching issue #136 in the branch name `feature/claude-code-architecture-136`.  
**Base Branch:** `development`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 0 files | 969 tests | ✅ 969 pass, 0 fail | 83% lines | 83% lines | N/A (no new Python code) |
| TypeScript | 0 files | 252 tests | ✅ 252 pass, 0 fail | 94.75% stmts | 94.75% stmts | N/A (no new TS code) |
| PowerShell | 1 file (hook) | 259 tests | ⚠️ 229 pass, 30 fail (pre-existing) | 26.86% cmds | 26.86% cmds | 0% (no Pester tests for hook) |
| Markdown | 13 files | N/A | N/A | N/A | N/A | N/A |
| JSON | 1 file | N/A | ✅ valid JSON with $schema | N/A | N/A | N/A |

---

## Executive Summary

This audit evaluates the `feature/claude-code-architecture-136` branch against the `development` base. The feature adds 17 new additive files implementing a four-layer Claude Code architecture (standing instructions, skills, subagents, enforcement). No existing production code, tests, or CI configuration was modified.

All language-specific toolchains pass without regression. The primary compliance gap is the absence of Pester unit tests for the new `.claude/hooks/validate-bash.ps1` PowerShell hook script.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md`
- ✅ `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no regression)
- ⚠️ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (new PowerShell code lacks tests)
- ✅ TypeScript: Prettier + ESLint + TSC + Jest (no regression)
- N/A Bash: no bash scripts changed
- ✅ JSON: `.claude/settings.json` is valid JSON with `$schema`

**Temporary artifacts cleanup:**
- ✅ No temporary scripts were created during development
- ✅ All files in scope are permanent deliverables

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | No new tests added; existing test suites (969 Pytest, 252 Jest, 229/259 Pester) run independently. No shared state introduced. |
| **Isolation** | ✅ PASS | Existing tests target single behaviors. No test changes in this feature. |
| **Fast Execution** | ✅ PASS | Python: 2.93s for 969 tests. TypeScript: 0.872s for 252 tests. |
| **Determinism** | ✅ PASS | All test suites produce consistent results across runs. |
| **Readability & Maintainability** | ✅ PASS | No test changes to evaluate; existing tests maintain established conventions. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Python: 83% (baseline evidence: `evidence/baseline/`). TypeScript: 94.75%. PowerShell: 26.86%. |
| **No Coverage Regression** | ✅ PASS | No production code changed → coverage unchanged. Python 83% → 83%. TypeScript 94.75% → 94.75%. PowerShell 26.86% → 26.86%. |
| **New Code Coverage ≥90%** | ⚠️ PARTIAL | `.claude/hooks/validate-bash.ps1` is the sole new code file (66 lines). It has 0% test coverage — no Pester tests exist for it. All other new files are Markdown/JSON configuration, not subject to unit test coverage requirements. |
| **Comprehensive Coverage** | N/A | No new testable production code beyond the PowerShell hook script. |
| **Positive Flows** | N/A | No new unit tests in scope. |
| **Negative Flows** | N/A | No new unit tests in scope. |
| **Edge Cases** | N/A | No new unit tests in scope. |
| **Error Handling** | N/A | No new unit tests in scope. |
| **Concurrency** | N/A | Not applicable. |
| **State Transitions** | N/A | Not applicable. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | N/A | No new tests added. |
| **Arrange-Act-Assert Pattern** | N/A | No new tests added. |
| **Document Intent** | N/A | No new tests added. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No new tests added. Existing tests do not depend on external services. |
| **Use Mocks/Stubs** | N/A | No new tests. |
| **Environment Stability** | ✅ PASS | No new environment dependencies introduced. No temporary file usage. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document serves as the required policy audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Objective documented in `issue.md`, `spec.md`, and `user-story.md`. Issue #136. |
| **Read existing change plans** | ✅ PASS | `plan.2026-04-11T19-55.md` reviewed — 60 tasks across 8 phases, all marked Delivered. |
| **Document the plan** | ✅ PASS | Plan created and fully executed with Phase 0 baseline through Phase 7 AC verification. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Each file has a single clear purpose (one rule file per language, one agent per specialist, one skill per workflow). No unnecessary abstraction layers. |
| **Reusability** | ✅ PASS | Skills are shared across agents via `skills:` frontmatter lists. Rules are path-scoped for automatic activation. Policy content references canonical `.github/` files rather than duplicating. |
| **Extensibility** | ✅ PASS | New agents, skills, and rules can be added following the established patterns without modifying existing files. Settings.json allow/deny lists are additive. |
| **Separation of concerns** | ✅ PASS | Four-layer architecture cleanly separates standing instructions (CLAUDE.md + rules), user workflows (skills), specialist delegation (agents), and enforcement (settings + hooks). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Each file serves a single purpose documented in its YAML frontmatter or header. |
| **Under 500 lines** | ✅ PASS | Largest file: `docs/engineering/claude-code-architecture.md` at ~200 lines. Hook script: 66 lines. Settings: ~50 lines. All agent/skill files under 100 lines. |
| **Public vs internal** | ✅ PASS | Skills are the public user-invocable surface. Agents are internal delegation targets. Hook scripts are enforcement internals. |
| **No circular dependencies** | ✅ PASS | Dependency graph is a DAG: user → skill → agent → subagent. No circular references. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Files follow clear naming: `orchestrator.md`, `atomic-planner.md`, `validate-bash.ps1`, `claude-code-architecture.md`. |
| **Docs/docstrings** | ✅ PASS | Each agent/skill file has `description:` frontmatter and structured body sections. Architecture doc has four sections with tables and walkthrough. CLAUDE.md documents reading order and architecture overview. |
| **Comment why, not what** | ✅ PASS | PowerShell hook script comments explain rationale for blocked patterns. Architecture doc explains non-equivalences and their substitutes. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Python: `poetry run black --check .` → 191 files unchanged. TypeScript: `npm run format -- --check` → all matched files clean. PowerShell: PoshQC format → no changes. |
| **2. Linting** | ✅ PASS | Python: `poetry run ruff check .` → all checks passed. TypeScript: `npm run lint` → no errors. PowerShell: PoshQC analyze → 0 errors, 0 warnings. |
| **3. Type checking** | ✅ PASS | Python: `poetry run pyright` → 0 errors, 0 warnings. TypeScript: `npm run typecheck` → clean. PowerShell: N/A. |
| **4. Testing** | ✅ PASS | Python: 969 passed in 2.93s. TypeScript: 252 passed in 0.872s. PowerShell: 229/259 (30 pre-existing failures, no new failures). |
| **Full toolchain loop** | ✅ PASS | All four steps completed in a single pass for Python and TypeScript. PowerShell pre-existing failures documented. |
| **Explicit reporting** | ✅ PASS | QA gate evidence files stored in `evidence/qa-gates/`. Commands documented in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | 17 new additive files implementing four-layer Claude Code architecture. No existing files modified. |
| **Design choices explained** | ✅ PASS | Architecture doc Section 2 documents non-equivalences and design rationale. Spec.md documents implementation strategy. |
| **Update supporting documents** | ✅ PASS | `docs/engineering/claude-code-architecture.md` created. Feature scoping docs updated. |
| **Provide next steps** | ✅ PASS | Seeded test conditions in spec.md identify 5 live-validation items for follow-up. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No new Python code was added or modified. Toolchain regression checks only.

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | `poetry run black --check .` → 191 files unchanged. |
| **Linting with Ruff** | ✅ PASS | `poetry run ruff check .` → all checks passed. |
| **Type checking with Pyright** | ✅ PASS | `poetry run pyright` → 0 errors, 0 warnings, 0 informations. |
| **Testing with Pytest** | ✅ PASS | `poetry run pytest --cov` → 969 passed in 2.93s. Coverage: 83%. |

#### 3A.2 Python Design & Typing

N/A — no new Python code.

#### 3A.3 Python Error Handling

N/A — no new Python code.

---

### Section 3B: PowerShell Code Change Policy Compliance

One new PowerShell file: `.claude/hooks/validate-bash.ps1` (66 lines).

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | PoshQC format completed — no formatting changes required (QA evidence: `qc-poshqc-format.md`). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | PoshQC analyze — 0 errors, 0 warnings (QA evidence: `qc-poshqc-analyze.md`). |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 7+ compatible** | ✅ PASS | Script uses only standard PowerShell cmdlets (`Get-Content`, `ConvertFrom-Json`, `Write-Error`). No version-specific features. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Script uses `[CmdletBinding()]`, `param()` block, and `.SYNOPSIS`/`.DESCRIPTION` help comments. |
| **Parameter validation** | ✅ PASS | Uses `[string]$CommandText` parameter. Reads from `CLAUDE_TOOL_INPUT` environment variable (JSON) with fallback to positional argument. |
| **Avoid global state** | ✅ PASS | No global or script-scoped mutable variables. All state is local to the function. |
| **Error handling** | ✅ PASS | Uses `Write-Error` for blocked commands. Exits with code 1 (block) or 0 (allow). Try/catch wraps JSON parsing. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 66 lines. Single responsibility: validate bash commands against blocked patterns. |
| **Approved verbs** | N/A | Script is a hook, not a cmdlet function. No exported function with verb-noun naming. |
| **Comment why** | ✅ PASS | Help block explains the hook's purpose. Blocked patterns are self-documenting. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | PoshQC format → no changes. |
| **Step 2: Analyze** | ✅ PASS | PoshQC analyze → 0 errors, 0 warnings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ⚠️ PARTIAL | PoshQC test → 229/259 passed. 30 failures are pre-existing (baseline). New hook script `.claude/hooks/validate-bash.ps1` has no Pester tests. |
| **Rerun loop if needed** | ✅ PASS | Single pass — no failures or changes caused by format/analyze steps. |

---

### Section 3D: JSON Configuration Policy Compliance

One new JSON file: `.claude/settings.json`.

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | File is well-formatted with consistent indentation. |
| **Schema validation** | ✅ PASS | `$schema` property present, pointing to the Claude Code settings schema. |
| **Required $schema** | ✅ PASS | `"$schema": "https://..."` is the first key in the file. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | No comments, trailing commas, or JSON5 features. Valid strict JSON. |
| **Deterministic key order** | ✅ PASS | Keys follow logical grouping: `$schema` → `permissions` → `hooks` → `defaultPermissionMode`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

N/A — no new Python code or tests. Regression check confirms 969 tests pass at 83% coverage.

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Existing tests use Pester v5. |
| **Use PoshQC Configuration** | ✅ PASS | Config at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. |
| **PowerShell 7+ Compatible** | ✅ PASS | All tests run under PowerShell 7. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ⚠️ PARTIAL | No new Pester tests for `.claude/hooks/validate-bash.ps1`. Existing tests unchanged. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | PoshQC test executed per QA evidence. |
| **No Alternative Test Runners** | ✅ PASS | Only Pester used through PoshQC. |

---

## 5. Test Coverage Detail

No new unit tests were added in this feature. All test suites are regression-only.

### Untested New Code

- `.claude/hooks/validate-bash.ps1` (66 lines): PowerShell hook script for PreToolUse bash command validation. No Pester tests exist. This is the only executable new code (all other deliverables are Markdown configuration or JSON).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Python - Total Tests | 969 | ✅ |
| Python - Tests Passed | 969 (100%) | ✅ |
| Python - Execution Time | 2.93s | ✅ Fast |
| Python - Coverage | 83% lines | ✅ No regression |
| TypeScript - Total Tests | 252 | ✅ |
| TypeScript - Tests Passed | 252 (100%) | ✅ |
| TypeScript - Execution Time | 0.872s | ✅ Fast |
| TypeScript - Coverage | 94.75% stmts | ✅ No regression |
| PowerShell - Total Tests | 259 | ⚠️ |
| PowerShell - Tests Passed | 229 (88.4%) | ⚠️ 30 pre-existing failures |
| PowerShell - Coverage | 26.86% cmds | ⚠️ No regression, but new hook untested |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 191 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors, 0 warnings | ✅ |
| Pytest Tests | `poetry run pytest --cov` | 969 passed, 83% coverage | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npm run format -- --check` | All matched files clean | ✅ |
| ESLint | `npm run lint` | No errors or warnings | ✅ |
| TSC | `npm run typecheck` | Clean compilation | ✅ |
| Jest | `npm run test:unit` | 252 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC Format | MCP: `run_poshqc_format` | No changes required | ✅ |
| PoshQC Analyze | MCP: `run_poshqc_analyze` | 0 errors, 0 warnings | ✅ |
| PoshQC Test | MCP: `run_poshqc_test` | 229/259 passed (30 pre-existing) | ⚠️ |

**Notes:** The 30 PowerShell test failures are pre-existing in the `development` baseline and are not caused by this feature. No new failures were introduced.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **Missing Pester tests for `.claude/hooks/validate-bash.ps1`**: The new 66-line PowerShell hook script has no unit tests. Per the general unit test policy, new code should target ≥90% coverage. The QA gate evidence (`qc-poshqc-test.md`) acknowledges this gap, noting the file is "a hook script external to the module test coverage."

2. **Seeded test conditions unchecked**: Five of six seeded test conditions in `spec.md` remain unchecked (`[ ]`). These require live Claude Code session validation (skill invocation, permission enforcement, hook blocking, checkpoint resumption) which cannot be performed through automated unit tests. One seeded test condition (documentation review) is checked.

### Approved Exceptions

None. The missing Pester tests should be addressed before or after merge.

### Removed/Skipped Tests

None. No planned tests were removed.

---

## 9. Summary of Changes

### Files Modified (Scoping Docs)

1. `docs/features/active/2026-04-11-claude-code-architecture-136/plan.2026-04-11T19-55.md` — All 60 tasks marked Delivered.
2. `docs/features/active/2026-04-11-claude-code-architecture-136/spec.md` — Definition of Done items checked.
3. `docs/features/active/2026-04-11-claude-code-architecture-136/user-story.md` — All 10 AC items checked.

### Files Created (17 Deliverables)

1. **`CLAUDE.md`** (NEW) — Standing instructions: tone policy, compliance reading order, architecture context.
2. **`.claude/rules/python.md`** (NEW) — Python policy rules, path-scoped to `**/*.py`.
3. **`.claude/rules/powershell.md`** (NEW) — PowerShell policy rules, path-scoped to `**/*.ps1,*.psm1,*.psd1`.
4. **`.claude/rules/typescript.md`** (NEW) — TypeScript policy rules, path-scoped to `**/*.ts`.
5. **`.claude/rules/csharp.md`** (NEW) — C# policy rules, path-scoped to `**/*.cs,*.csproj`.
6. **`.claude/skills/orchestrate/SKILL.md`** (NEW) — Orchestration entry point with `context: fork` and `agent: orchestrator`.
7. **`.claude/skills/commit-message/SKILL.md`** (NEW) — Commit message generation, restricted to git read tools.
8. **`.claude/skills/pr-author/SKILL.md`** (NEW) — PR body authoring from PR context artifacts.
9. **`.claude/skills/research-issue/SKILL.md`** (NEW) — Issue research with Read/Grep/Glob/WebFetch tools.
10. **`.claude/agents/orchestrator.md`** (NEW) — Orchestrator subagent with delegation model and checkpoint protocol.
11. **`.claude/agents/atomic-planner.md`** (NEW) — Planning subagent restricted to docs/artifacts write paths.
12. **`.claude/agents/atomic-executor.md`** (NEW) — Execution subagent with language toolchain Bash patterns.
13. **`.claude/agents/feature-review.md`** (NEW) — Review subagent restricted to docs/features/active write path.
14. **`.claude/agents/task-researcher.md`** (NEW) — Research subagent restricted to artifacts/research write path.
15. **`.claude/settings.json`** (NEW) — Permissions (13 allow, 5 deny), hooks (SubagentStop, PreToolUse), defaultPermissionMode.
16. **`.claude/hooks/validate-bash.ps1`** (NEW) — PreToolUse hook: blocks 6 dangerous command patterns.
17. **`docs/engineering/claude-code-architecture.md`** (NEW) — Equivalence table, non-equivalences, sync strategy, validation walkthrough.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The feature is largely compliant. All toolchains pass without regression. The sole compliance gap is the absence of Pester unit tests for the new `.claude/hooks/validate-bash.ps1` script (66 lines, 0% test coverage).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: Objective, plan, and documentation all present.
- ✅ Design Principles: Four-layer architecture is simple, reusable, extensible, with clear separation of concerns.
- ✅ Module & File Structure: All files cohesive, under 500 lines, no circular dependencies.
- ✅ Naming, Docs, Comments: Descriptive names, YAML frontmatter descriptions, architecture documentation.
- ✅ Toolchain Execution: All language toolchains pass in a single pass.
- ✅ Summarize & Document: Architecture doc, spec, user-story, and plan all updated.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: No regression. Black, Ruff, Pyright, Pytest all pass.

**For PowerShell:**
- ✅ Tooling & Baseline: PoshQC format and analyze pass.
- ✅ PowerShell Design & Safety: CmdletBinding, proper parameter handling, no global state.
- ✅ Structure & Naming: 66 lines, cohesive, well-documented.
- ⚠️ Toolchain: Pester tests missing for new hook script.

**For TypeScript:**
- ✅ Tooling & Baseline: Prettier, ESLint, TSC, Jest all pass.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: Existing tests maintain all principles.
- ⚠️ Coverage & Scenarios: New PowerShell code at 0% coverage (should be ≥90%).
- N/A Test Structure: No new tests.
- ✅ External Dependencies: No new external dependencies.
- ✅ Policy Audit: This document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ⚠️ Framework & Scope: No new Pester tests for new hook script.

---

### Metrics Summary

- ✅ Python: 969/969 tests passing (100%), 83% line coverage, no regression
- ✅ TypeScript: 252/252 tests passing (100%), 94.75% statement coverage, no regression
- ⚠️ PowerShell: 229/259 tests passing (30 pre-existing failures), 26.86% coverage, no regression but new hook untested
- ✅ All code quality checks passing (format, lint, type-check)
- ⚠️ New code coverage gap: `.claude/hooks/validate-bash.ps1` at 0% (target: ≥90%)

---

### Recommendation

**Needs revision**

The feature is well-structured, all toolchains pass, and no regressions exist. The single blocking finding is the missing Pester tests for `.claude/hooks/validate-bash.ps1`. This script validates dangerous bash commands and should have unit tests covering:
- Each of the 6 blocked patterns (positive detection)
- Safe commands that should pass (negative cases)
- Edge cases (empty input, JSON parsing failure, environment variable fallback)

After adding Pester tests for the hook script, this feature would be ready for merge.

---

## Appendix A: Test Inventory

No new tests were added. Existing test suites:
- Python: 969 tests across `tests/` directory
- TypeScript: 252 tests across 16 test suites in `extensions/drm-copilot/test/`
- PowerShell: 259 tests (229 passing, 30 pre-existing failures)

---

## Appendix B: Toolchain Commands Reference

**Python:**
```bash
poetry run black --check .          # Formatting (check-only)
poetry run ruff check .             # Linting
poetry run pyright                  # Type checking
poetry run pytest --cov --cov-report=term-missing  # Testing with coverage
```

**TypeScript (from extensions/drm-copilot):**
```bash
npm run format -- --check           # Formatting (check-only)
npm run lint                        # Linting
npm run typecheck                   # Type checking
npm run test:unit                   # Unit tests
```

**PowerShell (MCP functions):**
```
mcp__drmCopilotExtension__run_poshqc_format     # Formatting
mcp__drmCopilotExtension__run_poshqc_analyze    # Linting
mcp_drmcopilotext_run_poshqc_test               # Testing
```

**Review check (this audit):**
```bash
poetry run black --check .                       # Python format check
poetry run ruff check .                          # Python lint
poetry run pyright                               # Python type check
poetry run pytest --cov --cov-report=term-missing -q  # Python tests
npm run format -- --check                        # TypeScript format check (from extensions/drm-copilot)
npm run lint                                     # TypeScript lint
npm run typecheck                                # TypeScript type check
npm run test:unit                                # TypeScript tests
```
