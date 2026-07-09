# Policy Compliance Audit: enforce-model-selection-routing (Issue #305)

**Audit Date:** 2026-07-04
**Audit Type:** Re-audit after remediation cycle 1
**Code Under Test:** Branch `bug/enforce-model-selection-routing` @ `355cbbc95e1cf422ce667365b180f4461cd0ee13` vs base `main` @ `f530d0e3ae7c5d0974b72cf0956e862dd94041c5` (merge base identical). Full branch-vs-base diff: 94 changed files spanning Python (validator core, new gate delegate, CLI flag, 3 test suites), PowerShell (1 new PreToolUse hook, 1 edited completion hook, 2 test suites, Pester runsettings), TypeScript (MCP tool surface + existence check + new extracted sibling + 2 test suites + Jest coverage wiring), Markdown/JSON config (13 agent frontmatter edits, settings.json, orchestrator-state rule, orchestrate SKILL, pack manifest, jest.config), and their byte-identical `.claude/**` bundle mirrors.

**Prior audit:** `policy-audit.2026-07-04T14-34.md` raised two BLOCKING findings. Both are remediated in cycle 1 and re-verified below.

**Template provenance note:** The MCP `resolve_policy_audit_template_asset` tool was not available in this review environment. This artifact was constructed from the canonical repo template `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`. Assumption documented per the "proceed with best-effort" constraint.

---

## Remediation Verification (cycle 1)

| Prior blocker | Prior state | Current state | Verdict |
|---|---|---|---|
| BLOCKING-1: `extensions/drm-copilot/src/repo-automation-service.ts` exceeded 500-line limit | 502 lines | **495 lines**; request-shaping logic extracted to new sibling `src/lib/validate/build-validate-orchestration-service-call-input.ts` (**46 lines**) | **RESOLVED** |
| BLOCKING-2: TypeScript coverage artifact absent | No `coverage/lcov.info`; no coverage script | Artifact present at `extensions/drm-copilot/coverage/lcov.info` (405 KB); `test:coverage` script + per-changed-file `coverageThreshold` (no global key) wired in `jest.config.cjs`; all changed TS files ≥85% line / ≥75% branch | **RESOLVED** |

Both remediations were verified directly against the working tree (line counts, artifact presence, per-file coverage) and against `evidence/qa-gates/typescript-coverage.md` (COVERAGE_GATE: PASS).

---

## Coverage Metrics by Language

| Language | Files Changed | Test Result | Post-Change Coverage | Changed-File Coverage | Verdict |
|----------|--------------|-------------|----------------------|-----------------------|---------|
| Python | 2 prod + 3 new test files | 1293 pass, 0 fail | 86.6% line / 86.5% branch (repo dev_tools) | new gate module 98.5% line (67/68) / 91.7% branch (33/36) | **PASS** |
| PowerShell | 1 new + 1 edited hook (+ runsettings) | 495 pass, 0 fail | changed hooks 85.7%–89.3% | new hook 85.7% cmd; edited hook 87.2% line / 89.3% instr | **PASS** |
| TypeScript | 8 prod (incl. new sibling) + 2 test | 1478 pass, 0 fail | extension-wide 96.75% line / 88.32% branch | all 8 changed files ≥85% line / ≥75% branch (see table) | **PASS** |
| Markdown/JSON | 17 config/doc + mirrors | bundle-parity + pack-manifest pass | non-coverage-bearing | non-coverage-bearing | **PASS** |

**Coverage-bearing note:** Coverage is a coverage-bearing metric for TypeScript, Python, PowerShell, and C#. C# has zero changed files on this branch and is therefore N/A (acceptable for a language with zero changed files). Markdown/JSON are non-coverage-bearing config/doc languages.

### TypeScript per-changed-file coverage (source: `extensions/drm-copilot/coverage/lcov.info`)

| Changed file | Lines% | Branches% | Verdict |
|---|---|---|---|
| src/lib/validate/orchestrator-state-core.ts | 97.31% (471/484) | 91.03% (71/78) | PASS |
| src/lib/validate/orchestration-artifacts.ts | 100.00% (205/205) | 97.67% (42/43) | PASS |
| src/lib/validate/validate-orchestration-service-call.ts | 100.00% (95/95) | 85.71% (6/7) | PASS |
| src/lib/validate/build-validate-orchestration-service-call-input.ts | 100.00% (46/46) | 100.00% (5/5) | PASS (new sibling; branch gap from cycle 1 draft closed) |
| src/repo-automation-service.ts | 98.38% (487/495) | 88.89% (40/45) | PASS |
| src/mcp-repo-automation-tool-definitions.ts | 100.00% (452/452) | n/a (0 branches) | PASS (definition/data module) |
| src/mcp-tool-definitions.ts | 100.00% (418/418) | n/a (0 branches) | PASS (definition/data module) |
| src/mcp-tool-inputs.ts | 93.15% (449/482) | 90.32% (56/62) | PASS |

### Coverage Evidence Checklist

- Python post-change coverage artifact present; comparison at `evidence/qa-gates/python-coverage-delta.md`. Verdict PASS.
- PowerShell post-change coverage artifact present; summary at `evidence/qa-gates/powershell-qa.md`. Verdict PASS.
- TypeScript coverage artifact **present** at `extensions/drm-copilot/coverage/lcov.info`; per-changed-file numbers at `evidence/qa-gates/typescript-coverage.md`. Verdict PASS.
- C# coverage artifact N/A (zero changed C# files, confirmed by `git diff --name-only ... | grep '\.cs$'` returning empty).

---

## Executive Summary

This feature adds a `require_model_routing` existence gate to the orchestrator-state validator so a completed checkpoint that recorded delegations but omitted `model_routing_receipts[]` / `complexity_assessments[]` is rejected. Enforcement is layered: a new Python gate delegate, a `--require-model-routing` CLI flag, a PreToolUse presence deterrent hook, a completion-gate block reason (`MODEL_ROUTING_BLOCKED:`), documented resume reconciliation, agent `model:` floor defaults, and a TypeScript MCP existence check.

Both blocking findings from the prior audit are resolved. The full branch-vs-base re-audit finds all seven applicable toolchains green, coverage above threshold for every language with changed files, formula reuse preserved, backward compatibility maintained, foreign-schema prohibition honored, bundle parity byte-identical, and no evidence-location violations. **Zero blocking findings remain.**

**Policy documents evaluated:**
- `general-code-change.md` — design, file-size, formula reuse, toolchain.
- `general-unit-test.md` — coverage, scenario completeness, test location.
- `quality-tiers.md` — uniform 85% line / 75% branch thresholds applied.
- `orchestrator-state.md` — model-routing/complexity invariants and foreign-schema prohibition.

**Language-specific policies evaluated:**
- Python: `python.md` + `python-suppressions.md` + `self-explanatory-code-commenting.md`.
- PowerShell: `powershell.md`.
- TypeScript: `typescript.md` + `typescript-suppressions.md` + `architecture-boundaries.md`.
- C#: N/A (no changed files).

**Temporary artifacts cleanup:** No temporary scripts introduced by the diff.

---

## Rejected Scope Narrowing

None. The launching-agent task explicitly scoped the review to the full branch diff against the merge-base with "No scope narrowing" and directed re-verification of the whole diff across every applicable language toolchain (Python, PowerShell, TypeScript, Markdown/JSON). No attempt to narrow scope to a plan subset, a subset of changed files, or to mark any language "out of scope" / "informational only" was detected. The full feature-vs-base diff was audited.

---

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (no violations).
- No files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appear in the branch diff (`git diff --name-only ... | grep '^artifacts/(baselines|qa|evidence|coverage)/'` returned empty). All feature evidence is under the canonical `docs/features/active/2026-07-04-enforce-model-selection-routing-305/evidence/<kind>/` tree.
- Observation (not a violation): repo-root `coverage.xml` is a pre-existing tracked Pester/JaCoCo report regenerated by this feature's PowerShell run. It sits at repo root, not under the prohibited `artifacts/**` evidence paths, and updating a pre-existing tracked file is consistent with existing repo practice.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Python gate tests build isolated fixtures per test via `build_valid_orchestrator_state()`; no shared mutable state. Pester tests inject a synthetic checkpoint through the seam. |
| Isolation | PASS | Each test targets one behavior (missing-entry, present-and-consistent, mismatch, no-delegation, next_step trigger, malformed entries, builder ternary arms). |
| Fast execution | PASS | Pure in-memory validation; no I/O. Full Python suite 1293 tests EXIT 0; Jest 1478 EXIT 0. |
| Determinism | PASS | No wall-clock, RNG, network, or temp files in the changed tests. |
| Readability | PASS | Descriptive `test_*` / `it(...)` names and docstrings; Pester `Describe/Context/It`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | PASS | `evidence/baseline/python-baseline.md`, `evidence/baseline/powershell-baseline.md`, `evidence/baseline/typescript-baseline.md`. |
| No coverage regression (Python) | PASS | 86.5%→86.6% line, 86.5% branch held; `evidence/qa-gates/python-coverage-delta.md`. |
| New-code coverage (Python gate module) | PASS | `_orchestrator_state_model_routing_gate.py` 98.5% line, 91.7% branch. |
| New-code coverage (TypeScript) | PASS | New sibling `build-validate-orchestration-service-call-input.ts` 100% line / 100% branch; changed `orchestrator-state-core.ts` 97.31% line / 91.03% branch. |
| Scenario completeness | PASS | Positive/negative/edge/error paths present: missing receipt, phase-missing assessment, model mismatch, malformed/non-list entries, namespaced receipts, no-delegation, builder omit-ternary combinations. |
| Temp files prohibited | PASS | No temp-file creation in changed tests. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline 86.5%/86.5% → Post-change 86.6% line / 86.5% branch; new gate module 98.5%/91.7%. Disposition **PASS**.
- PowerShell: New hook 85.7% cmd; edited `validate-orchestrator-output.ps1` 87.2% line / 89.3% instruction. Disposition **PASS**.
- TypeScript: Extension-wide 96.75% line / 88.32% branch; all 8 changed files ≥85% line / ≥75% branch (per-file table above). Disposition **PASS**.

### 1.3 Test File Location

| Requirement | Status | Evidence |
|------------|--------|----------|
| Tests mirror source tree | PASS | `tests/scripts/dev_tools/…`, `tests/scripts/claude-hooks/…`, `extensions/drm-copilot/test/lib/validate/…`. No colocation in `src/`. |

---

## 2. General Code Change Policy Compliance

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | PASS | Gate is a flag-gated addition; delegates per-entry correctness to existing validators. |
| Reusability | PASS | Reuses `_validate_model_routing_receipts` and `_validate_complexity_assessments`; the cycle-1 extraction factored request-shaping into a shared, testable pure function. |
| Extensibility | PASS | New keyword `require_model_routing: bool = False` added keyword-only, mirroring `require_pr_creation_ready`. |
| Separation of concerns | PASS | New gate logic isolated in a sibling delegate module; host-bound hook wiring kept thin; request-shaping extracted from the service into a pure builder. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Under 500 lines (all changed/new files)** | PASS | All changed production files ≤ 500: `repo-automation-service.ts` **495** (was 502), new sibling **46**, `orchestrator-state-core.ts` 484, `mcp-tool-inputs.ts` 482, `mcp-repo-automation-tool-definitions.ts` 452, `mcp-tool-definitions.ts` 418, `validate_orchestrator_state.py` 500 (at limit, not exceeding), `_orchestrator_state_model_routing_gate.py` 300, `validate_orchestration_artifacts.py` 283, `validate-orchestrator-output.ps1` 321, `enforce-model-routing-receipt.ps1` 182. Largest changed test file 460 lines. |
| Cohesive modules | PASS | New Python delegate and new TS sibling each have a single purpose and full docstrings. |
| No circular dependencies | PASS | Gate imports the two per-entry validator modules; validator imports the gate. No cycle. New TS sibling imports only type declarations. |
| Formula reuse (no reimplementation) | PASS | `grep -E "def (compute_complexity_floor|resolve_delegation_model)"` in the gate module returns none; reference formulas consumed indirectly via the reused per-entry validators. No `function resolveDelegationModel`/`computeComplexityFloor(` in changed TS `src/lib/validate/`. PS hook contains neither formula. |
| No foreign schema imported | PASS | Gate docstring states the schema is never imported; invariants expressed in code per `orchestrator-state.md`. |

### 2.5 Toolchain Execution

| Language | Format | Lint | Type | Test | Coverage | Result |
|---|---|---|---|---|---|---|
| Python | black EXIT 0 | ruff EXIT 0 | pyright EXIT 0 | pytest 1293 pass | 86.6%/86.5% | PASS |
| PowerShell | PoshQC format EXIT 0 | PoshQC analyze ok=true | N/A | Pester 495 pass | 85.7%–89.3% | PASS |
| TypeScript | prettier EXIT 0 | eslint EXIT 0 | tsc EXIT 0 | Jest 1478 pass | 96.75% line / 88.32% branch; per-file ≥85/75 | PASS |

### 2.6 Bundle Parity

| Requirement | Status | Evidence |
|------------|--------|----------|
| `.claude/**` mirrors byte-identical | PASS | 18/18 edited `.claude/**` files (13 agents, 2 hooks, rule, settings.json, SKILL) `diff -q` byte-identical to `extensions/drm-copilot/resources/claude-customizations/.claude/**`. New hook registered in `pack-manifests/core.json`. Contract-test evidence `evidence/qa-gates/bundle-parity-final.md` (EXIT 0). The cycle-1 remediation touched only `src/**` TypeScript (no `.claude/**` change), so mirror parity is unaffected. |

---

## 3. Language-Specific Code Change Compliance

### 3A Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black / Ruff / Pyright / Pytest | PASS | All EXIT 0. |
| Strong typing | PASS | Full annotations; `cast(...)` at untyped dict boundaries; no bare `Any` leakage. |
| No unauthorized suppressions | PASS | No `# noqa` / `# type: ignore` introduced in the gate module. |
| Docstrings & intent comments | PASS | Module/function docstrings and loop/branch intent comments per `self-explanatory-code-commenting.md`. |
| Error handling | PASS | Gate returns an error-string list; never mutates input; no broad excepts. |

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Advanced functions / CmdletBinding | PASS | Hook functions use `[CmdletBinding()]`, typed params, `[OutputType]`. |
| Analyzer clean | PASS | PoshQC analyze ok=true, no findings. |
| Under 500 lines | PASS | 182 / 321 lines. |
| Deterministic test seams | PASS | Checkpoint read behind a mockable seam; dot-source guard prevents entrypoint execution under test. |
| Graceful failure | PASS | Malformed JSON and non-delegating input allow-through; deny only for gated agent lacking a receipt. |

### 3C TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| Prettier / ESLint / tsc | PASS | All EXIT 0. |
| No unauthorized suppressions | PASS | No `@ts-ignore` / `@ts-nocheck` / `eslint-disable` in the new sibling or changed files. |
| Existence check only (per non-goal) | PASS | `validateModelRoutingExistence` performs delegated-agent ⊆ receipt-agent superset check; no formula reimplementation. |
| Under 500 lines | PASS | `repo-automation-service.ts` 495; new sibling 46; all changed TS ≤ 484. |
| Coverage measured | PASS | Artifact present; per-changed-file ≥85% line / ≥75% branch. |
| Coverage-exclusion policy | PASS | `jest.config.cjs` `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` includes all runtime `src/**`; the per-changed-file `coverageThreshold` block has no `global` key and excludes no production path. |

Observation (pre-existing, not introduced by this feature): `typescript.md` names Vitest as the framework, but the `extensions/drm-copilot` package uses Jest (`run-jest.cjs`) for its entire pre-existing suite. This framework choice predates the branch; the new tests follow the package's established convention rather than introducing a new one. Not a finding against this diff.

### 3D JSON/Config

| Requirement | Status | Evidence |
|------------|--------|----------|
| settings.json hook registration valid | PASS | New PreToolUse `Agent`-matcher command appended; parity mirror identical. |
| pack manifest updated | PASS | New hook path added to `core.json`. |
| jest.config coverage wiring valid | PASS | `test:coverage` script + lcov/text-summary reporters + per-changed-file threshold block. |

---

## Policy Rule: modified-workflow-needs-green-run

Not triggered. The branch diff modifies no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (`git diff --name-only ... | grep` returned empty). `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` was edited to add the new hook to coverage measurement but is not a workflow/benchmark/action path. No green-run evidence requirement applies.

---

## Policy Rule: benchmark-baselines

Not applicable. No benchmark baseline files are added or modified in the diff; no path under `scripts/benchmarks/**` changed.

---

## 8. Gaps and Exceptions

### Identified Gaps
None. Both prior blocking findings are resolved and re-verified; no new gaps introduced.

### Approved Exceptions
None.

### Removed/Skipped Tests
None.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT (PASS)

All applicable language toolchains are green. Coverage is above threshold for every language with changed files (explicit PASS for Python, PowerShell, TypeScript; C# N/A with zero changed files). File-size limit is satisfied across all changed and new files. Formula reuse, foreign-schema prohibition, backward compatibility, bundle parity, and evidence-location rules all pass. The two prior blocking findings are resolved.

### Metrics Summary
- Python 1293 pass; 86.6% line / 86.5% branch; new gate module 98.5%/91.7%.
- PowerShell 495 pass; changed hooks 85.7%–89.3%.
- TypeScript 1478 pass; extension-wide 96.75% line / 88.32% branch; all 8 changed files ≥85/75.
- Bundle parity 18/18 byte-identical.
- File-size: all changed/new files ≤ 500 lines.

### Recommendation
**PASS / Go for PR.** No remediation required. Zero blocking findings.

---

## Appendix B: Toolchain Commands Reference

```bash
# Scope
git diff --name-status f530d0e3ae7c5d0974b72cf0956e862dd94041c5..355cbbc95e1cf422ce667365b180f4461cd0ee13

# Python
poetry run black --check scripts/dev_tools tests/scripts/dev_tools
poetry run ruff check scripts/dev_tools tests/scripts/dev_tools
poetry run pyright scripts/dev_tools
poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term-missing

# PowerShell (MCP)
mcp__drm-copilot__run_poshqc_format ; mcp__drm-copilot__run_poshqc_analyze ; mcp__drm-copilot__run_poshqc_test

# TypeScript (extensions/drm-copilot)
npm run format ; npm run lint ; npm run typecheck ; npm run test
npm run test:coverage   # node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary
#   -> artifact: extensions/drm-copilot/coverage/lcov.info

# Bundle parity
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py

# Evidence-location scan
python scripts/dev_tools/validate_evidence_locations.py --root .

# File-size checks (all <= 500)
wc -l extensions/drm-copilot/src/repo-automation-service.ts \
      extensions/drm-copilot/src/lib/validate/build-validate-orchestration-service-call-input.ts
```

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-04
**Policy Version:** Current (as of audit date)
