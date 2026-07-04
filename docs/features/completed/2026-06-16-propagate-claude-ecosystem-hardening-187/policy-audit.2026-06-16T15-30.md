# Policy Compliance Audit: propagate-claude-ecosystem-hardening (Issue #187)

**Audit Date:** 2026-06-16
**Code Under Test:**
- `.claude/hooks/validate-orchestrator-output.ps1` (+92)
- `.claude/hooks/validate-task-researcher-output.ps1` (+68)
- `.claude/rules/general-unit-test.md` (+23)
- `.claude/rules/orchestrator-state.md` (+19/-6)
- `.claude/skills/human-exception-runbook/SKILL.md` (new, +52)
- `.claude/skills/human-exception-runbook/example.runbook.md` (new, +36)
- `.claude/skills/orchestrate/SKILL.md` (+30)
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (+107/-, expanded)
- `scripts/dev_tools/validate_orchestrator_state.py` (+89)
- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` (+110)
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` (+134)
- `tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py` (new, +194)
- `extensions/drm-copilot/resources/claude-customizations/.claude/...` (mirror of the eight `.claude/` files)
- Docs/evidence/spec under `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New/Changed Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files (1 prod, 1 test) | 25 tests (8 new) | PASS 25 pass, 0 fail | 85.21% lines / 77.42% branch (P0 evidence) | 88.43% lines / ~82% branch (re-measured 88% line) | new helper `_validate_human_interaction` fully exercised |
| PowerShell | 2 prod + 2 test files | 36 tests (16 new) | PASS 36 pass, 0 fail | 92.86% / 71.21% cmd (P0 evidence) | 91.11% command coverage (re-measured, 205/225) | new functions' branches exercised |
| Markdown (rules/skills/docs) | 6 `.claude` + feature docs | N/A | N/A (documentation) | N/A | N/A | N/A |

Languages with zero changed files on the branch: TypeScript (N/A), C# (N/A). Coverage verdicts below are explicit PASS/FAIL only for the two languages with changed files (Python, PowerShell).

### Coverage Evidence Checklist

- Python post-change coverage artifact: `artifacts/python/lcov.info` (regenerated during this audit; `SF:scripts\dev_tools\validate_orchestrator_state.py`) — PRESENT
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` — PRESENT but does NOT contain the two changed hook files (it covers a different hook set: `check-powershell-test-purity.ps1`, `check-python-test-purity.ps1`, `enforce-*-batch-budget.ps1`, `validate-bash.ps1`). Per-hook coverage for the changed files was independently re-measured via scoped `Invoke-Pester` (91.11%, 205/225 commands). Recorded as PARTIAL on artifact contents; PASS on re-measured value.
- Per-language comparison summary: `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/evidence/qa-gates/p7-coverage-delta.2026-06-16T11-00.md`

**Non-negotiable verdict rule:** Numeric baseline and post-change coverage are recorded for both in-scope languages (Python, PowerShell).

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow scope to a plan/task/phase subset, to a subset of changed files, or to mark any language with changed files as out-of-scope/informational. The caller prompt directed a full branch-diff audit against merge-base `c903b1f`, which is consistent with the scope invariant. No verbatim narrowing text to record.

---

## Evidence Location Compliance

This branch writes all of its evidence artifacts to the canonical location `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/evidence/<kind>/` (baseline, qa-gates). The branch diff (`git diff --name-only c903b1f..24353b0b`) introduces **zero** files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.

`validate_evidence_locations.py --root .` exits non-zero (exit 1) and reports 37 violations. All 37 are pre-existing files dated 2026-04-18 and 2026-04-25 under `artifacts/evidence/baseline/**` and `artifacts/evidence/post-change/**` from prior, unrelated features. None are attributable to this branch's diff. Disposition for this PR: PASS (no branch-introduced violation). Separately recommended: a cleanup change should relocate or remove the pre-existing `artifacts/evidence/**` files so the validator exits clean repo-wide; that cleanup is out of scope for #187.

---

## Executive Summary

The change propagates seven hardened Claude-ecosystem elements into the canonical `.claude/` runtime, both bundled mirrors, and the Python orchestrator-state validator. All seven feature items are present and structurally complete. The eight changed/created `.claude/` files are byte-identical across canonical, the `extensions/` mirror, and the `packages/mcp-server/` mirror (verified by `cmp`). Backward-compatibility is preserved: absent-key paths pass in both the PowerShell hook and the Python validator.

Toolchain verification passed for both in-scope languages: Python (Black, Ruff, Pyright clean; 25 pytest pass), PowerShell (format clean under repo PoshQC settings, 0 analyzer findings, 36 Pester pass). The bundle-sync contract test passes (4/4).

Two compliance issues were identified. (1) FAIL — `scripts/dev_tools/validate_orchestrator_state.py` is now 505 lines, exceeding the 500-line hard limit in `general-code-change.md`. (2) Minor — `orchestrate/SKILL.md` references `.claude/schemas/orchestrator-state.schema.json`, a file that does not exist in the repository. Item (1) is routed to remediation.

**Policy documents evaluated:**
- PASS `general-code-change.md` (one limit violation noted below)
- PASS `general-unit-test.md`

**Language-specific policies evaluated:**
- PASS Python: `python.md` (`python-code-change` / `python-unit-test`)
- PASS PowerShell: `powershell.md`
- N/A Bash, JSON, TypeScript, C#

**Temporary artifacts cleanup:**
- PASS No temporary scripts committed by this branch (toolchain helper scripts in this audit were created under `/tmp` and are not part of the repo).

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Pester tests dot-source the hook under a `.`-invocation guard and inject seams (`$FileExistsCheck`, `$ReadFileContent`); pytest tests construct checkpoint dicts in-test. No shared mutable state. |
| **Isolation** | PASS | Each `It` / `test_` targets one branch of one function (absent-key, missing-requirements, invalid-enum, halt, exception-without-runbook, etc.). |
| **Fast Execution** | PASS | Pytest: 25 tests in 0.12s. Pester: 36 tests in 1.22s. |
| **Determinism** | PASS | No wall-clock, RNG, network, or temp-file dependencies. Existence checks use injected scriptblock seams rather than real filesystem. |
| **Readability** | PASS | Descriptive `It`/`def test_` names mapping to each invariant. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | P0 baseline evidence: Python 85.21% line / 77.42% branch; PowerShell hooks 92.86% and 71.21% command. See `evidence/baseline/baseline-python.2026-06-16T11-00.md`, `evidence/baseline/baseline-pester.2026-06-16T11-00.md`. |
| **No Coverage Regression** | PASS | Python rose to 88.43% line / ~82% branch. PowerShell `validate-task-researcher-output.ps1` rose from 71.21% to 91.58%. Changed lines have dedicated tests. |
| **New/Changed Code Coverage** | PASS | New `_validate_human_interaction` (Python lines 111-186) is outside all reported uncovered ranges (228->244, 282, 332, 337, 377, 392, 432, 439, 458-476, 497, 500->505 are pre-existing code). New PowerShell functions' rejection branches exercised. |
| **Comprehensive Coverage** | PASS | 8 new pytest covering non-object block, non-list requirements, non-object requirement, response-outside-enum, halt, exception-empty-runbook, exception-missing-runbook, well-formed pass, and backward-compat absent-key. 16 new Pester covering the equivalent hook branches. |
| **Positive Flows** | PASS | absent-key pass; well-formed `scope_change` + runbook-backed `exception` pass; non-matching research artifact passes unaffected. |
| **Negative Flows** | PASS | missing requirements, missing/blank response, invalid enum, halt, exception without runbook. |
| **Edge Cases** | PASS | empty/whitespace `runbook_path`; empty research content; filename vs content detection for the autonomous-execution token. |
| **Error Handling** | PASS | Each malformed shape returns a specific Blocking message (PowerShell) or appends a specific error string (Python). |
| **Concurrency** | N/A | No concurrent behavior introduced. |
| **State Transitions** | N/A | Validators are stateless. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline 85.21% line -> Post-change 88.43% line. Branch 77.42% -> ~82%. New/changed-code coverage: new helper fully exercised. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/p7-coverage-delta.2026-06-16T11-00.md`.
- PowerShell: Baseline 92.86%/71.21% command (two hooks) -> Post-change 91.11% combined (re-measured). Disposition: PASS. Evidence: re-measured scoped Invoke-Pester (205/225 commands); `evidence/qa-gates/p7-poshqc-final.2026-06-16T11-00.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Hook returns named-requirement-index messages; pytest asserts on specific error substrings. |
| **Arrange-Act-Assert** | PASS | Tests follow AAA per the plan's [P1-T3] / [P2] acceptance. |
| **Document Intent** | PASS | Test names enumerate the invariant under test. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network/DB/process dependencies. |
| **Use Mocks/Stubs** | PASS | Filesystem existence is injected via `$FileExistsCheck`; file read via `$ReadFileContent`. No real I/O. |
| **Environment Stability** | PASS | No temporary files created in tests (verified: existence/read are scriptblock seams). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document. |

---

## 2. General Code Change Policy Compliance

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | New validators are linear, early-return helpers mirroring the existing remediation-cycle helper pattern. |
| **Reusability** | PASS | Python helper reuses the established helper-plus-error-list style; PowerShell reuses the hashtable `Ok`/`Message` return contract. |
| **Extensibility** | PASS | Injectable scriptblock seams (`$FileExistsCheck`, `$ReadFileContent`) allow extension without breaking callers. |
| **Separation of concerns** | PASS | Pure validation logic separated from the entrypoint; filesystem boundary isolated behind seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Each hook/validator change stays within its existing module. |
| **Under 500 lines** | FAIL | `scripts/dev_tools/validate_orchestrator_state.py` is **505 lines** (base 416 + 89). Exceeds the 500-line hard limit in `general-code-change.md` line 49. `.claude/hooks/validate-orchestrator-output.ps1` (233) and `validate-task-researcher-output.ps1` (210) are within limit; all test files within limit (299/212/194). |
| **Public vs internal** | PASS | New PowerShell functions are internal (dot-sourced); Python helper is module-private (`_validate_human_interaction`). |
| **No circular dependencies** | PASS | No new imports introduced in Python; no new dot-source dependencies. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Test-HumanInteractionShape`, `Test-AutomationFeasibilitySection`, `_validate_human_interaction`. |
| **Docs/docstrings** | PASS | Both PowerShell functions carry comment-based help; Python helper has a full docstring (Purpose/Args/Returns/Raises/Side Effects). |
| **Comment why, not what** | PASS | Comments explain backward-compat intent and the additive-invariant rationale. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Python `black --check` clean; PowerShell `Invoke-Formatter` clean under repo `pssa.settings.psd1`. |
| **2. Linting** | PASS | Ruff clean; PSScriptAnalyzer 0 findings. |
| **3. Type checking** | PASS | Pyright 0 errors/0 warnings. (N/A for PowerShell.) |
| **4. Testing** | PASS | 25 pytest + 36 Pester + 4 contract tests pass. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Update supporting documents** | PASS | `rules/orchestrator-state.md` and `rules/general-unit-test.md` updated additively; spec/user-story/issue present. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check scripts/dev_tools/validate_orchestrator_state.py tests/...` — 2 files unchanged, exit 0. |
| **Linting with Ruff** | PASS | `poetry run ruff check ...` — All checks passed, exit 0. |
| **Type checking with Pyright** | PASS | `poetry run pyright ...` — 0 errors, 0 warnings. |
| **Testing with Pytest** | PASS | 25 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | `_validate_human_interaction(human_interaction: object) -> list[str]`; uses `cast` with narrowed dict/list types; no unjustified `Any` escape. |
| **Avoid utility classes** | PASS | Implemented as module functions, not a static-only class. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific behavior** | PASS | Returns explicit error strings per violated invariant; no broad except. |
| **No mutation of input** | PASS | Helper reads only; returns a new list. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | Format clean under repo `pssa.settings.psd1` (initial default-settings diff was a settings artifact, not a real finding). |
| **Linting with PSScriptAnalyzer** | PASS | 0 findings on the two hooks and two test files. |
| **PowerShell 7+ compatible** | PASS | `Set-StrictMode -Version Latest`, advanced functions, no 5.1-incompatible syntax observed. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]`, `[OutputType([hashtable])]`, typed params. |
| **Parameter validation** | PASS | `[Parameter(Mandatory)]`, `[AllowNull()]`, scriptblock-typed seams with safe defaults. |
| **Avoid global state** | PASS | No script-scoped mutable state introduced. |
| **Error handling** | PASS | Returns `Ok`/`Message` hashtable; entrypoint `Write-Error` + `exit 1`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 233 and 210 lines. |
| **Approved verbs** | PASS | `Test-` is an approved verb; nouns descriptive. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `test_validate_orchestrator_state_human_interaction.py` uses plain pytest functions. |
| **Coverage expectation** | PASS | Module line 88.43% (>= 85%), branch ~82% (>= 75%). |
| **Focused unit tests** | PASS | One invariant per test. |
| **Organization** | PASS | Test file mirrors `scripts/dev_tools/` under `tests/scripts/dev_tools/`. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `New-PesterConfiguration`, Describe/Context/It. |
| **Use PoshQC Configuration** | PASS | Repo config at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. |
| **Focused Unit Tests** | PASS | One behavior per `It`. |
| **Mocking Used Sparingly** | PASS | Filesystem seam injected, not mocked globally. |
| **File Naming** | PASS | `*.Tests.ps1`. |
| **Organization** | PASS | `tests/scripts/claude-hooks/` mirrors `.claude/hooks/`. |

---

## 5. Test Coverage Detail

### `_validate_human_interaction` (Python, 8 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| test_no_human_interaction_is_backward_compatible | Positive (absent key) | PASS |
| non-object block | Negative | PASS |
| non-list requirements | Negative | PASS |
| non-object requirement | Negative | PASS |
| response outside enum | Negative | PASS |
| exception with empty runbook_path | Edge | PASS |
| exception with missing runbook_path | Edge | PASS |
| well-formed scope_change + runbook-backed exception | Positive | PASS |

**Coverage:** module 88.43% line; new helper fully exercised.

### `Test-HumanInteractionShape` + `Test-AutomationFeasibilitySection` (PowerShell, 16 new tests)

Branches: absent-key pass; missing-requirements; missing/blank response; invalid enum; halt; exception-without-runbook (injected `$FileExistsCheck=$false`); exception-with-runbook (injected `$FileExistsCheck=$true`); research matching/non-matching, section present/absent, empty content. All PASS. Combined command coverage 91.11%.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (in-scope) | 65 (25 pytest + 36 Pester + 4 contract) | PASS |
| Tests Passed | 65 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Python Execution Time | 0.12s | PASS |
| Pester Execution Time | 1.22s | PASS |
| Code Coverage (Python module) | 88.43% lines / ~82% branches | PASS |
| Code Coverage (PowerShell hooks) | 91.11% command | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py` | 2 files unchanged | PASS |
| Ruff | `poetry run ruff check ...` | All checks passed | PASS |
| Pyright | `poetry run pyright ...` | 0 errors, 0 warnings | PASS |
| Pytest | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state*.py --cov=scripts.dev_tools.validate_orchestrator_state --cov-branch` | 25 passed, 88% | PASS |
| Contract | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 4 passed | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | clean (idempotent) | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` on two hooks + two tests | 0 findings | PASS |
| Pester | scoped `Invoke-Pester` on the two hook test files | 36 passed, 0 failed, 91.11% command coverage | PASS |

**Notes:** The `Invoke-Formatter` default-settings run reported a `} catch {` brace-style diff; re-running with the repo `pssa.settings.psd1` produced a clean result. The repo settings (One True Brace Style) are authoritative.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **File size limit (`general-code-change.md`):** `scripts/dev_tools/validate_orchestrator_state.py` is 505 lines, 5 over the 500-line hard limit. Plan: extract one validator group (for example the `human_interaction` helper and its constants, or the remediation-cycle helpers) into a sibling module imported by `validate_orchestrator_state.py`, keeping the public function signature unchanged. Routed to remediation.
- **Dangling schema reference (documentation):** `.claude/skills/orchestrate/SKILL.md` line 53 (and the PowerShell hook docstring) reference `.claude/schemas/orchestrator-state.schema.json`, which does not exist in the repository. Enforcement is correctly implemented via the Python validator and PowerShell hook, so this is a documentation-accuracy issue, not a functional defect. Recommend either adding a repo-local schema (subject to the foreign-schema policy) or rewording the prose to state that invariants are enforced by validator logic, not a schema file.

### Approved Exceptions

- **None.** No exceptions were pre-approved for the file-size limit.

### Removed/Skipped Tests

- **None.** All planned tests implemented.

---

## 9. Summary of Changes

### Commits in This Branch

1. **24353b0** — feat(187): propagate hardened Claude-ecosystem elements to runtime and mirrors

### Files Modified (production/code)

1. `.claude/hooks/validate-orchestrator-output.ps1` (MODIFIED) — adds `Test-HumanInteractionShape`, wired into `Invoke-OrchestratorOutputValidation`.
2. `.claude/hooks/validate-task-researcher-output.ps1` (MODIFIED) — adds `Test-AutomationFeasibilitySection`, wired into `Invoke-TaskResearcherOutputValidation`.
3. `scripts/dev_tools/validate_orchestrator_state.py` (MODIFIED) — adds `_validate_human_interaction` and constants; wired into `validate_orchestrator_state_text`. **Now 505 lines (over limit).**
4. `.claude/rules/general-unit-test.md`, `.claude/rules/orchestrator-state.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (MODIFIED, additive).
5. `.claude/skills/human-exception-runbook/SKILL.md`, `example.runbook.md` (NEW).
6. `extensions/drm-copilot/resources/claude-customizations/.claude/...` (MODIFIED, byte-identical mirror).
7. Tests: `validate-orchestrator-output.Tests.ps1`, `validate-task-researcher-output.Tests.ps1`, `test_validate_orchestrator_state_human_interaction.py`.

Note on `packages/mcp-server/resources/claude-customizations/`: this tree is git-ignored via `packages/mcp-server/.gitignore` (`resources/`) and therefore does not appear in the branch diff. It is byte-identical to canonical in the working tree (verified by `cmp`), consistent with the spec Non-Goal that the mcp-server mirror is updated in-change but has no automated parity gate.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The feature is functionally complete and the toolchain is clean, but one hard policy limit is violated (500-line file size on `validate_orchestrator_state.py`). That violation must be remediated before merge. The dangling schema reference is a minor documentation issue.

**Fail-closed reminder:** This audit is not marked fully compliant because the file-size hard limit is exceeded.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design Principles
- ❌ Module & File Structure — 500-line limit exceeded on one file
- ✅ Naming, Docs, Comments
- ✅ Toolchain Execution

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python Tooling / Typing / Error Handling
- ✅ PowerShell Tooling / Design / Structure

#### General Unit Test Policy (Section 1)
- ✅ Core Principles, Coverage & Scenarios, Test Structure, External Dependencies

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python and PowerShell

### Metrics Summary

- ✅ 65/65 in-scope tests passing (100%)
- ✅ Python module 88.43% line / ~82% branch coverage
- ✅ PowerShell hooks 91.11% command coverage
- ✅ Bundle-sync contract test 4/4
- ✅ Both mirrors byte-identical to canonical
- ❌ One production file exceeds the 500-line limit

### Recommendation

**Needs revision** — Address the 505-line file-size violation on `scripts/dev_tools/validate_orchestrator_state.py` (split into a sibling module). The dangling schema reference should be corrected in the same pass. After remediation, re-run the Python and PowerShell toolchains and re-verify mirror parity.

---

## Appendix A: Test Inventory

- `test_validate_orchestrator_state_human_interaction.py` — 8 tests (incl. `test_no_human_interaction_is_backward_compatible`).
- `test_validate_orchestrator_state.py` + `test_validate_orchestrator_state_remediation_loop.py` — 17 pre-existing tests still green.
- `validate-orchestrator-output.Tests.ps1` — 7 new `It` blocks for `Test-HumanInteractionShape` plus pre-existing.
- `validate-task-researcher-output.Tests.ps1` — 9 new `It` blocks for `Test-AutomationFeasibilitySection`.
- `test_push_down_claude_resource_contracts.py` — 4 contract tests (extensions mirror parity).

## Appendix B: Toolchain Commands Reference

```bash
# Python
poetry run black --check scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py
poetry run ruff check scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py
poetry run pyright scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py
poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py --cov=scripts.dev_tools.validate_orchestrator_state --cov-branch --cov-report=term-missing
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

```powershell
# PowerShell (scoped, measurement-only)
Invoke-Pester -Configuration (config: Run.Path = the two *.Tests.ps1; CodeCoverage.Path = the two hooks)
Invoke-ScriptAnalyzer -Path <hook/test files> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <hook text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
```

```bash
# Mirror parity
cmp <.claude/...> <extensions/.../.claude/...>
cmp <.claude/...> <packages/mcp-server/.../.claude/...>
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-06-16
**Policy Version:** Current (as of audit date)
