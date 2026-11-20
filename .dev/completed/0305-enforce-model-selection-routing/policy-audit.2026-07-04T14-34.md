# Policy Compliance Audit: enforce-model-selection-routing (Issue #305)

**Audit Date:** 2026-07-04
**Code Under Test:** Branch `bug/enforce-model-selection-routing` @ `3f62485b1fc59f21b42c7bc5c40ea9422533ff6a` vs base `main` @ `f530d0e3ae7c5d0974b72cf0956e862dd94041c5` (merge base identical). 74 changed files: Python (validator core, new gate delegate, CLI flag, 3 test suites), PowerShell (1 new PreToolUse hook, 1 edited completion hook, 2 test suites, Pester runsettings), TypeScript (MCP tool surface + existence check + 1 test suite), Markdown/JSON config (13 agent frontmatter edits, settings.json, orchestrator-state rule, orchestrate SKILL, pack manifest), and their byte-identical `.claude/**` bundle mirrors.

**Template provenance note:** The MCP `resolve_policy_audit_template_asset` tool was not available in this review environment. This artifact was constructed from the canonical repo template `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`. Assumption documented per the "proceed with best-effort" constraint.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage | Verdict |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|---------|
| Python | 5 prod/test (+3 new test files) | 1293 pass | ✅ 1293 pass, 0 fail | 86.5% line / 86.5% branch | 86.6% line / 86.5% branch | new gate module 98.5% line / 91.7% branch | **PASS** |
| PowerShell | 4 (+ runsettings) | 495 pass | ✅ 495 pass, 0 fail | n/a (new hook) | changed hooks 85.7%–89.3% | new hook 85.7% cmd | **PASS** |
| TypeScript | 8 prod (+1 new test) | 1473 pass | ✅ 1473 pass, 0 fail | not measured | **coverage artifact absent** | not measured | **FAIL** |
| Markdown/JSON | 17 config/doc + mirrors | N/A | ✅ bundle-parity + pack-manifest pass | N/A (config) | N/A (config) | N/A | PASS |

**Note:** Coverage is a coverage-bearing metric only for TypeScript, Python, PowerShell, and C#. C# has zero changed files on this branch and is therefore N/A. Markdown/JSON are non-coverage-bearing config/doc languages.

### Coverage Evidence Checklist

- Python post-change coverage artifact: `artifacts/python/lcov.info` (present); comparison at `docs/features/active/2026-07-04-enforce-model-selection-routing-305/evidence/qa-gates/python-coverage-delta.md`.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (present); summary in `.../evidence/qa-gates/powershell-qa.md`.
- TypeScript coverage artifact: **ABSENT.** Expected `coverage/lcov.info` (or `extensions/drm-copilot/coverage/`); no coverage script is wired in the Jest-based extension `package.json` (`test`/`test:unit` only, no `test:coverage`/`collectCoverage`).
- C# coverage artifact: N/A (zero changed C# files).

**Non-negotiable verdict rule applied:** Because the TypeScript coverage artifact is absent for a language with changed files, this audit does NOT report an overall PASS. Overall verdict is PARTIALLY COMPLIANT (Needs Revision).

---

## Executive Summary

This feature adds a `require_model_routing` existence gate to the orchestrator-state validator so a completed checkpoint that recorded delegations but omitted `model_routing_receipts[]` / `complexity_assessments[]` is rejected. Enforcement is layered: a new Python gate delegate, a `--require-model-routing` CLI flag, a PreToolUse presence deterrent hook, a completion-gate block reason (`MODEL_ROUTING_BLOCKED:`), documented resume reconciliation, agent `model:` floor defaults, and a TypeScript MCP existence check. The Python and PowerShell toolchains are green with coverage above threshold. Two policy failures were identified: (1) `extensions/drm-copilot/src/repo-automation-service.ts` now exceeds the hard 500-line file limit, and (2) no TypeScript coverage artifact exists for a language with changed files, so coverage verification cannot be satisfied.

**Policy documents evaluated:**
- ✅ `general-code-change.md` — evaluated (design, file-size, formula reuse, toolchain).
- ✅ `general-unit-test.md` — evaluated (coverage, scenario completeness, test location).
- ✅ `quality-tiers.md` — uniform 85% line / 75% branch thresholds applied.
- ✅ `orchestrator-state.md` — model-routing/complexity invariants and foreign-schema prohibition.

**Language-specific policies evaluated:**
- ✅ Python: `python.md` + `python-suppressions.md` + `self-explanatory-code-commenting.md`.
- ✅ PowerShell: `powershell.md`.
- ✅ TypeScript: `typescript.md` + `typescript-suppressions.md` + `architecture-boundaries.md`.
- N/A C#: no changed files.

**Temporary artifacts cleanup:**
- ✅ No temporary scripts introduced by the diff.

---

## Rejected Scope Narrowing

None. The launching-agent task explicitly scoped the review to "every applicable language toolchain for languages with changed files in the diff (Python, PowerShell, TypeScript, Markdown/JSON config)" and did not attempt to narrow scope to a plan subset or exclude any language. The full feature-vs-base diff was audited.

---

## Evidence Location Compliance

- `scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (no violations).
- No files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appear in the branch diff. All feature evidence is under the canonical `docs/features/active/2026-07-04-enforce-model-selection-routing-305/evidence/<kind>/` tree.
- Observation (not a violation of the Evidence Location Invariant): repo-root `coverage.xml` is a pre-existing tracked Pester/JaCoCo report regenerated by this feature's PowerShell test run. It sits at repo root, not under the prohibited `artifacts/**` evidence paths, and updating a pre-existing tracked file is consistent with existing repo practice.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | ✅ PASS | Python gate tests build isolated fixtures per test via `build_valid_orchestrator_state()`; no shared mutable state. Pester tests inject a synthetic checkpoint through the `Get-ModelRoutingCheckpoint` seam. |
| Isolation | ✅ PASS | Each test targets one behavior (missing-entry, present-and-consistent, mismatch, no-delegation, next_step trigger, malformed entries). |
| Fast execution | ✅ PASS | Pure in-memory validation; no I/O. Full Python suite 1293 tests EXIT 0. |
| Determinism | ✅ PASS | No wall-clock, RNG, network, or temp files in the changed tests. |
| Readability | ✅ PASS | Descriptive `test_*` names and docstrings; Pester `Describe/Context/It`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | `evidence/baseline/python-baseline.md` (86.5%/86.5%), `evidence/baseline/powershell-baseline.md`. |
| No coverage regression (Python) | ✅ PASS | 86.5%→86.6% line, 86.5% branch held; `evidence/qa-gates/python-coverage-delta.md`. |
| New-code coverage (Python gate module) | ✅ PASS | `_orchestrator_state_model_routing_gate.py` 98.5% line (67/68), 91.7% branch (33/36) — exceeds 85/75 and the 90% new-code trigger. |
| New-code coverage (TypeScript) | ❌ FAIL | No coverage artifact produced; new-code coverage for `orchestrator-state-core.ts` additions cannot be measured. |
| Scenario completeness | ✅ PASS | Positive/negative/edge/error paths present: missing receipt, phase-missing assessment, model mismatch, malformed entries skipped, non-list arrays, namespaced receipts, no-delegation. |
| Temp files prohibited | ✅ PASS | No temp-file creation in changed tests. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline 86.5% line / 86.5% branch → Post-change 86.6% line / 86.5% branch. New gate module 98.5% line / 91.7% branch. Disposition: **PASS**. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/python-coverage-delta.md`.
- PowerShell: New hook `enforce-model-routing-receipt.ps1` 85.7% command (42/49); edited `validate-orchestrator-output.ps1` 87.2% line (82/94) / 89.3% instruction. Disposition: **PASS**. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/powershell-qa.md`.
- TypeScript: No baseline or post-change coverage artifact; no coverage script wired. Disposition: **FAIL** (coverage verification mandatory for a language with changed files). Evidence: absence of `coverage/lcov.info` and `extensions/drm-copilot/coverage/`.

### 1.3 Test File Location

| Requirement | Status | Evidence |
|------------|--------|----------|
| Tests mirror source tree | ✅ PASS | `tests/scripts/dev_tools/…`, `tests/scripts/claude-hooks/…`, `extensions/drm-copilot/test/lib/validate/…`. No colocation in `src/`. |

---

## 2. General Code Change Policy Compliance

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | Gate is a flag-gated addition; delegates per-entry correctness to existing validators. |
| Reusability | ✅ PASS | Reuses `_validate_model_routing_receipts` and `_validate_complexity_assessments`; `STEP_STATUS_KEYS` tuple removes duplicated status-key list. |
| Extensibility | ✅ PASS | New keyword `require_model_routing: bool = False` added keyword-only, mirroring `require_pr_creation_ready`. |
| Separation of concerns | ✅ PASS | New gate logic isolated in a sibling delegate module; host-bound hook wiring kept thin. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | ✅ PASS | New module has a single purpose (existence gate) with full module docstring. |
| **Under 500 lines** | ❌ **FAIL** | `extensions/drm-copilot/src/repo-automation-service.ts` = **502 lines** (baseline 497; this feature added +5 to thread `requireModelRouting`, crossing the hard 500-line limit). All other changed production files compliant: `validate_orchestrator_state.py` 500 (at limit, not exceeding), `_orchestrator_state_model_routing_gate.py` 300, `validate_orchestration_artifacts.py` 283, `enforce-model-routing-receipt.ps1` 182, `validate-orchestrator-output.ps1` 321, `orchestrator-state-core.ts` 484, `mcp-tool-inputs.ts` 482, `mcp-tool-definitions.ts` 418. |
| No circular dependencies | ✅ PASS | Gate imports the two per-entry validator modules; validator imports the gate. No cycle (gate does not import the top validator). |
| Formula reuse (no reimplementation) | ✅ PASS | No `def compute_complexity_floor` / `def resolve_delegation_model` reimplementation in the gate or hook; reference formulas consumed indirectly via the reused per-entry validators. Verified by grep. |
| No foreign schema imported | ✅ PASS | Gate docstring states the schema is never imported; invariants expressed in code per `orchestrator-state.md`. |

### 2.5 Toolchain Execution

| Language | Format | Lint | Type | Test | Result |
|---|---|---|---|---|---|
| Python | ✅ `black` EXIT 0 | ✅ `ruff` EXIT 0 | ✅ `pyright` EXIT 0 | ✅ `pytest` 1293 pass | PASS (`evidence/qa-gates/python-*.md`) |
| PowerShell | ✅ PoshQC format EXIT 0 | ✅ PoshQC analyze ok=true | N/A | ✅ Pester 495 pass | PASS (`evidence/qa-gates/powershell-qa.md`) |
| TypeScript | ✅ prettier EXIT 0 | ✅ eslint EXIT 0 | ✅ tsc EXIT 0 | ✅ Jest 1473 pass | Toolchain PASS; **coverage stage not run/absent** (`evidence/qa-gates/typescript-qa.md`) |

### 2.6 Bundle Parity

| Requirement | Status | Evidence |
|------------|--------|----------|
| `.claude/**` mirrors byte-identical | ✅ PASS | 18/18 edited `.claude/**` files (13 agents, 2 hooks, rule, settings.json, SKILL) `diff -q` byte-identical to `extensions/drm-copilot/resources/claude-customizations/.claude/**`. New hook registered in `pack-manifests/core.json`. Contract tests: `evidence/qa-gates/bundle-parity-final.md` (EXIT 0). |

---

## 3. Language-Specific Code Change Compliance

### 3A Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black / Ruff / Pyright / Pytest | ✅ PASS | All EXIT 0 (see 2.5). |
| Strong typing | ✅ PASS | Full annotations; `cast(...)` used at untyped dict boundaries; no bare `Any` leakage. |
| No unauthorized suppressions | ✅ PASS | No `# noqa` / `# type: ignore` introduced in the gate module. |
| Docstrings & intent comments | ✅ PASS | Module/function docstrings and loop/branch intent comments present per `self-explanatory-code-commenting.md`. |
| Error handling | ✅ PASS | Gate returns an error-string list; never mutates input; no broad excepts. |

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Advanced functions / CmdletBinding | ✅ PASS | All hook functions use `[CmdletBinding()]`, typed params, `[OutputType]`. |
| Analyzer clean | ✅ PASS | PoshQC analyze ok=true, no findings. |
| Under 500 lines | ✅ PASS | 182 / 321 lines. |
| Deterministic test seams | ✅ PASS | Checkpoint read behind `Get-ModelRoutingCheckpoint`; dot-source guard prevents entrypoint execution under test. |
| Graceful failure | ✅ PASS | Malformed JSON and non-delegating input allow-through; deny only for gated agent lacking a receipt. |

### 3C TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| Prettier / ESLint / tsc | ✅ PASS | All EXIT 0. |
| No unauthorized suppressions | ✅ PASS | No `@ts-ignore` / `eslint-disable` introduced. |
| Existence check only (per non-goal) | ✅ PASS | `validateModelRoutingExistence` performs delegated-agent ⊆ receipt-agent superset check; no formula reimplementation. |
| Under 500 lines | ❌ FAIL | `repo-automation-service.ts` 502 lines (see 2.3). |
| Coverage measured | ❌ FAIL | No coverage artifact (see 1.2.1). |

### 3D JSON/Config

| Requirement | Status | Evidence |
|------------|--------|----------|
| settings.json hook registration valid | ✅ PASS | New PreToolUse `Agent`-matcher command appended; parity mirror identical. |
| pack manifest updated | ✅ PASS | New hook path added to `core.json`. |

---

## Policy Rule: modified-workflow-needs-green-run

Not triggered. The branch diff modifies no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` was edited (adding the new hook to coverage measurement) but is not a workflow/benchmark/action path. No green-run evidence requirement applies.

---

## 8. Gaps and Exceptions

### Identified Gaps
- **File-size limit (Blocking):** `extensions/drm-copilot/src/repo-automation-service.ts` = 502 lines, exceeds the hard 500-line limit in `general-code-change.md`. Introduced by this feature (+5 lines over a 497-line baseline).
- **TypeScript coverage verification (Blocking):** No coverage artifact exists for a language with changed files; coverage cannot be verified. The extension has no coverage script wired (Jest, `test`/`test:unit` only).

### Approved Exceptions
None.

### Removed/Skipped Tests
None.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT (Needs Revision)

Python and PowerShell scopes are fully compliant with green toolchains and coverage above threshold; bundle parity, formula reuse, foreign-schema prohibition, backward compatibility, and evidence-location rules all pass. Two blocking policy failures remain: the 500-line file-size violation in `repo-automation-service.ts`, and the absent TypeScript coverage artifact for a language with changed files. Both are recorded as remediation triggers.

**Fail-closed reminder honored:** overall verdict is not PASS because a required coverage artifact is missing.

### Metrics Summary
- ✅ Python 1293 pass; 86.6% line / 86.5% branch; new gate module 98.5%/91.7%.
- ✅ PowerShell 495 pass; changed hooks 85.7%–89.3%.
- ✅ TypeScript 1473 pass (format/lint/type/test green) — ❌ coverage artifact absent.
- ✅ Bundle parity 18/18 byte-identical.
- ❌ File-size: 1 file over 500 lines.

### Recommendation
**Needs revision.** Address the two blocking findings (extract logic to bring `repo-automation-service.ts` under 500 lines; wire and run TypeScript coverage to produce an artifact and confirm ≥85% line / ≥75% branch on changed TS code). See `remediation-inputs.2026-07-04T14-34.md`.

---

## Appendix B: Toolchain Commands Reference

```bash
# Scope
git diff --name-status f530d0e3ae7c5d0974b72cf0956e862dd94041c5..3f62485b1fc59f21b42c7bc5c40ea9422533ff6a

# Python
poetry run black --check scripts/dev_tools tests/scripts/dev_tools
poetry run ruff check scripts/dev_tools tests/scripts/dev_tools
poetry run pyright scripts/dev_tools
poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term-missing

# PowerShell (MCP)
mcp__drm-copilot__run_poshqc_format ; mcp__drm-copilot__run_poshqc_analyze ; mcp__drm-copilot__run_poshqc_test

# TypeScript (extensions/drm-copilot)
npm run format ; npm run lint ; npm run typecheck ; npm run test
# Coverage: NOT wired (no test:coverage / collectCoverage) — remediation required

# Bundle parity
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py

# Evidence-location scan
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# File-size check
wc -l extensions/drm-copilot/src/repo-automation-service.ts
```

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-04
**Policy Version:** Current (as of audit date)
