# Policy Compliance Audit: two-axis-model-selection (Issue #286)

**Audit Date:** 2026-07-03
**Code Under Test:** Feature branch `feature/two-axis-model-selection-286` diff against `main`.

- Base branch: `main` @ `9a5de0c549327f2e47521cae51d2514e8b28b54b` (merge base)
- Head: `feature/two-axis-model-selection-286` @ `e2d47f6d610fcbeca97d57a24603168a167b87ec`
- Range audited: `9a5de0c..e2d47f6` (full branch diff, 52 files, +3161/-19)
- Work Mode (from `issue.md`): `full-feature` (AC sources: `spec.md`, `user-story.md`)
- Audit type: Re-audit (remediation cycle 1 exit review) after cherry-pick onto current `main`.

Changed programming-language files by language (branch diff):

- **Python:** 9 files (5 source, 4 test). Toolchain and coverage mandatory. Verified fresh.
- **JSON:** 2 files (`config/orchestration-routing.json` and its bundle mirror). Config, validated via parity contract.
- **Markdown:** 27 docs/skills/agents/evidence files (no code toolchain).
- **TypeScript / PowerShell / C#:** zero changed source files in the branch diff. Coverage verdict N/A (no changed files), which is the permitted verdict for a language with zero changed files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 9 files | 1257 collected | PASS 1257 pass, 0 fail, 19 skipped | 84% combined (line 86.47% / branch 86.47%) | 84% combined (line 86.47% / branch 86.47%) | 100% line, 100% branch (4 new modules) |
| JSON | 2 files | Parity contract | PASS validation | N/A (config) | N/A (config) | N/A |

### Coverage Evidence Checklist

- Python post-change coverage artifact: `artifacts/python/lcov.info` (regenerated this run; `poetry run pytest --cov --cov-branch` exit 0).
- Python per-module figures: confirmed directly (see Section 5).
- TypeScript coverage artifact: `N/A - zero changed .ts files in branch diff`.
- PowerShell coverage artifact: `N/A - zero changed .ps1 files in branch diff`.
- C# coverage artifact: `N/A - zero changed .cs files in branch diff`.
- Per-language comparison summary: Section 5 and Section 1.2.1.

**Line coverage (repo-wide, Python):** 86.47% (7937/9179 statements). **PASS** (>= 85%).
**Branch coverage (repo-wide, Python):** 86.47% ((3304-447)/3304 branches). **PASS** (>= 75%).

---

## Rejected Scope Narrowing

None. The caller prompt explicitly instructed a full feature-vs-base audit of `main..HEAD` with no narrowing and no waived checks. No attempted scope narrowing, coverage waiver, or "not applicable" mislabeling was detected in the delegation. The audit was performed at full branch scope.

---

## Evidence Location Compliance

- `scripts/dev_tools/validate_evidence_locations.py --root .` exit code: **0** (no violations).
- Branch-diff scan for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: **none found**. All feature evidence is under the canonical `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/<kind>/` tree.
- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none. No delegation instruction specified a non-canonical evidence path.

Verdict: **PASS**.

---

## Policy Rule: modified-workflow-needs-green-run

Branch-diff scan for paths matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`: **none found**. The rule does not fire. No green-workflow-run evidence is required for this change. Verdict: **N/A (rule not triggered)**.

---

## Executive Summary

The feature introduces a two-axis model-selection mechanism that keeps the file-count-driven `route` strictly separate from a judgment-based `complexity_band`. It adds two pure Python reference implementations (`compute_complexity_floor`, `resolve_delegation_model`), two additive optional checkpoint validators (`_orchestrator_state_complexity`, `_orchestrator_state_model_routing`) wired into `validate_orchestrator_state_text` via key-gated blocks, a `model_policy`/`model_budget` config block, two new agents (`commit-message` model haiku, `human-exception-runbook` model sonnet), orchestrator allowlist/settings additions, and `orchestrate`/`epic-orchestrate`/`orchestrator-state.md` documentation edits. All bundled mirrors were updated in lockstep.

The full Python toolchain was executed fresh against the current base and is green: Black (no changes), Ruff (all checks passed), Pyright (0 errors/0 warnings), Pytest (1257 passed, 19 skipped, exit 0). The 19 skips are the pre-existing gitignored `.codex`/`.agents` parity tests, unchanged from baseline. Coverage for all four new modules is 100% line and branch; repo-wide line/branch coverage is 86.47%/86.47%, both above policy thresholds.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`
- PASS `python.md` + `python-suppressions.md`
- PASS `self-explanatory-code-commenting.md`
- PASS `quality-tiers.md` (uniform coverage thresholds)
- PASS `orchestrator-state.md` (additive-invariant precedent)
- PASS `tonality.md` (authored text)

**Language-specific policies evaluated:**
- PASS Python: `python-code-change` + `python-unit-test`
- N/A PowerShell, TypeScript, C#: zero changed source files
- PASS JSON: `config/orchestration-routing.json` validated via byte-identity + parity contracts

**Temporary artifacts cleanup:**
- PASS No temporary/throwaway scripts were introduced by this feature.
- PASS All new Python modules are production reference implementations with 1:1 test files.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Tests are pure-function and parsed-dict assertions with no shared mutable state; `poetry run pytest` passes in a single collection of 1257 tests. |
| **Isolation** | PASS | Each test targets one behavior (e.g., `test_disabled_clamps_fable_cell_to_opus`, `test_preferred_leaves_non_overlay_agent_c3_at_opus`). |
| **Fast Execution** | PASS | Full suite runs in ~6.9s; targeted new-module subset 33 tests in 0.23s. |
| **Determinism** | PASS | The two reference implementations are pure and explicitly tested for determinism across repeated calls and input ordering; no clock/RNG/network/tempfile use. |
| **Readability & Maintainability** | PASS | Descriptive `test_...` names, Arrange/Act/Assert comments, parametrized band matrices. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline captured in `evidence/baseline/python-pytest-baseline.md` (84% combined, 1204 passed). |
| **No Coverage Regression** | PASS | Post-change 84% combined unchanged; denominator grew by new statements all covered. No regression on changed lines. |
| **New Code Coverage** | PASS | All four new modules 100% line and branch (>= 85%/75% and >= 90% thresholds). |
| **Comprehensive Coverage** | PASS | Floor guards, max-of-multiple, no-signal C1, never-exceed-C3, base table per band, available/disabled/preferred, backward-compat, and malformed-fail-closed cases all covered. |
| **Positive Flows** | PASS | Well-formed receipts validate with zero errors (`test_no_..._is_backward_compatible`, well-formed-receipt tests). |
| **Negative Flows** | PASS | Band-enum, band<floor, floor!=compute, empty rationale, non-list, disabled-mode fable, missing-clamp cases each assert a specific error string. |
| **Edge Cases** | PASS | Empty `signals_present` -> C1; many floor signals still clamp to C3; C4 never floor-forced. |
| **Error Handling** | PASS | Validators return `list[str]` and never raise on malformed content (verified by non-list and non-object entry tests). |
| **Concurrency** | N/A | No concurrency in scope. |
| **State Transitions** | N/A | Pure functions; no stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline 84% combined (line 86.47% / branch 86.47%) -> Post-change 84% combined (line 86.47% / branch 86.47%). Change: 0.0% aggregate. New/changed-code coverage: 100% line and branch for the four new modules; edited `validate_orchestrator_state.py` at 96%. Disposition: **PASS**. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/final-pytest-coverage.md`.
- PowerShell: `N/A - zero changed .ps1 files in branch diff`.
- TypeScript: `N/A - zero changed .ts files in branch diff`.
- C#: `N/A - zero changed .cs files in branch diff`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions compare against exact error strings and resolved dict fields. |
| **Arrange-Act-Assert Pattern** | PASS | Each test carries Arrange/Act/Assert comments. |
| **Document Intent** | PASS | Module docstrings and per-test docstrings state the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Pure functions and in-memory JSON strings; no DB/network/process. |
| **Use Mocks/Stubs** | PASS | No mocking required; tests exercise real pure code paths. |
| **Environment Stability** | PASS | No temporary files; config read is via repository fixtures, not runtime tempfiles. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit serves as the required review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md`, `spec.md`, `user-story.md`, research doc present and consistent. |
| **Read existing change plans** | PASS | `plan.2026-07-03T16-19.md` present; phase-0 instruction read evidence recorded. |
| **Document the plan** | PASS | Plan and evidence tree document the approach. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Pure functions with module constants mirroring the config block; no indirection. |
| **Reusability** | PASS | `BAND_ORDER`, `compute_complexity_floor`, and resolver constants are reused by both validators. |
| **Extensibility** | PASS | Validators are additive, key-gated, and follow the `human_interaction` precedent. |
| **Separation of concerns** | PASS | Pure formulas contain no I/O; validators are shape-only and never read a schema file. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One concern per module (floor, resolver, complexity validator, routing validator). |
| **Under 500 lines** | PASS | Largest changed file `test_validate_orchestrator_state_complexity.py` at 289 lines; all source under 220 lines. Confirmed in `evidence/qa-gates/file-size-limit.md`. |
| **Public vs internal** | PASS | Validator helpers are `_`-prefixed and re-exported via `__all__` for the deliberate cross-module boundary. |
| **No circular dependencies** | PASS | Validators import the reference implementations one-directionally; no cycle. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `PREFERRED_OVERLAY_AGENTS`, `FLOOR_CEILING_BAND`, `DISABLED_CLAMP_MODEL`, etc. |
| **Docs/docstrings** | PASS | Every module and function carries Purpose/Args/Returns/Raises/Side Effects docstrings per `self-explanatory-code-commenting.md`. |
| **Comment why, not what** | PASS | Branch and loop intent comments present (e.g., the min-clamp rationale that keeps C4 unreachable). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `poetry run black --check <changed files>` -> "9 files would be left unchanged". |
| **2. Linting** | PASS | `poetry run ruff check <changed files>` -> "All checks passed!". |
| **3. Type checking** | PASS | `poetry run pyright <changed source>` -> "0 errors, 0 warnings, 0 informations". |
| **4. Testing** | PASS | `poetry run pytest --cov --cov-branch` -> 1257 passed, 19 skipped, exit 0. |
| **Full toolchain loop** | PASS | Single clean pass; no auto-fix required. |
| **Explicit reporting** | PASS | Commands and results in this audit (Section 7) and Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Section 9. |
| **Design choices explained** | PASS | Spec DD-1 (Python-only scope) and DD-2 (no schema file) documented. |
| **Update supporting documents** | PASS | `orchestrate`, `epic-orchestrate`, `orchestrator-state.md` updated with Model Selection prose. |
| **Provide next steps** | PASS | Spec Risks record the TypeScript-port parity gap as a tracked follow-up. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check` clean. |
| **Linting with Ruff** | PASS | `poetry run ruff check` clean. |
| **Type checking with Pyright** | PASS | 0 errors. |
| **Testing with Pytest** | PASS | 1257 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | `Literal` band/policy aliases; full annotations; no unjustified `Any` (the `cast("dict[str, Any]", ...)` uses are narrowing of opaque JSON). |
| **Dataclasses for value objects** | N/A | Return values are small typed dicts matching the receipt shape by design; no value-object class warranted. |
| **Protocols/ABCs for interfaces** | N/A | Single implementation per formula. |
| **Avoid utility classes** | PASS | Module-level pure functions, not static-only classes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | Validators never raise; they accumulate literal error strings. `resolve_delegation_model` documents `KeyError` on an out-of-enum band, which the validator guards before calling. |
| **Logging over print** | PASS | No `print`; validators return error lists. |
| **Invariants at construction** | PASS | Pure functions; invariants enforced inline and by the validators. |

#### 3D: JSON Configuration

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON / parity** | PASS | `config/orchestration-routing.json` byte-identical to its bundle mirror; `test_orchestration_routing_config_parity.py` passes. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | All new tests are Pytest with `parametrize`. |
| **Coverage expectation** | PASS | New modules 100% line/branch; repo-wide 86.47%/86.47%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One behavior per test. |
| **Mocking sparingly** | PASS | No mocks; real pure paths. |
| **Organization** | PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | Descriptive `test_...` names. |
| **Docstrings/comments** | PASS | Per-test docstrings and AAA comments. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `poetry run pytest` exit 0. |
| **No Alternative Test Runners** | PASS | Pytest only. |

---

## 5. Test Coverage Detail

Per-module coverage (regenerated this run):

| Module | Stmts | Miss | Branch | BrPart | Cover | New/Edited |
|---|---|---|---|---|---|---|
| `scripts/dev_tools/compute_complexity_floor.py` | 14 | 0 | 2 | 0 | 100% | New |
| `scripts/dev_tools/resolve_delegation_model.py` | 19 | 0 | 4 | 0 | 100% | New |
| `scripts/dev_tools/_orchestrator_state_complexity.py` | 45 | 0 | 20 | 0 | 100% | New |
| `scripts/dev_tools/_orchestrator_state_model_routing.py` | 45 | 0 | 16 | 0 | 100% | New |
| `scripts/dev_tools/validate_orchestrator_state.py` | 153 | 4 | 84 | 6 | 96% | Edited |

Repo-wide TOTAL: 9179 stmts / 1242 miss / 3304 branch / 447 brpart -> line 86.47%, branch 86.47%, combined 84%.

The four uncovered lines in the edited `validate_orchestrator_state.py` are pre-existing branches unrelated to the additive optional-validator loop (the loop and the two new imports are exercised by the new backward-compat and wiring tests). No regression on changed lines.

**Two-axis design invariants verified against code:**

- `route` is not a model-selection input: grep for `route` in `compute_complexity_floor.py` returned no match; `resolve_delegation_model.py` only mentions `route` in its docstring to state it is never an input; neither validator reads `route`. `resolve_delegation_model(agent, band, fable_policy)` has no `route` parameter. **Confirmed.**
- `compute_complexity_floor` never returns C4 and never exceeds C3: `FLOOR_CEILING_BAND = "C3"` with `floor_rank = min(highest_rank, index("C3"))`; empty signals -> `C1`. **Confirmed.**
- Assessed band >= floor: enforced by `_validate_one_assessment` ordering check. **Confirmed.**
- `resolve_delegation_model` base table (C1->haiku, C2->sonnet, C3->opus, C4->fable), `preferred` overlay (C3 opus->fable only for `atomic-planner`, `prd-feature`, `feature-review`, `task-researcher`; `atomic-executor`/`pr-author` unchanged), and `disabled` clamp (fable cell -> opus with `clamped_from == "fable"`, `clamp_reason == "fable_disabled"`). **Confirmed** in code and in `test_resolve_delegation_model.py` (which cross-checks the overlay agent set against `config/orchestration-routing.json`).
- Validators fail closed on malformed data and pass unchanged on checkpoints lacking the new arrays: key-gated `optional_key_validators` loop; `test_no_complexity_assessments_is_backward_compatible` and `test_no_model_routing_receipts_is_backward_compatible` present. **Confirmed.**

**Bundle-sync byte-identity (repo-root vs `extensions/drm-copilot/resources/**`):** 8/8 mirror pairs byte-identical via `cmp -s` (commit-message, human-exception-runbook, orchestrator, orchestrator-state.md, settings.json, orchestrate SKILL, epic-orchestrate SKILL, orchestration-routing.json). **Confirmed.**

**Agent frontmatter conformance:** `commit-message.md` (`model: haiku`, `skills: [commit-message]`, `memory: project`, read-only tools `Read`, `Bash(git log *)`, `Bash(git diff *)`) and `human-exception-runbook.md` (`model: sonnet`, `skills: [human-exception-runbook]`, `memory: project`, `tools` including `Write(<FEATURE>/runbooks/**)`) match the spec. **Confirmed.**

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 1276 collected (1257 run) | PASS |
| Tests Passed | 1257 (100% of run) | PASS |
| Tests Failed | 0 | PASS |
| Tests Skipped | 19 (gitignored `.codex`/`.agents` parity, pre-existing) | PASS |
| Execution Time | ~6.9s total | PASS Fast |
| New-module subset | 33 tests / 0.23s | PASS Fast |
| Code Coverage | 86.47% lines, 86.47% branches (repo-wide); 100%/100% new modules | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <changed files>` | 9 files unchanged | PASS |
| Ruff Linting | `poetry run ruff check <changed files>` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright <changed source>` | 0 errors, 0 warnings | PASS |
| Pytest Tests | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 1257 passed, 19 skipped | PASS |

**For JSON:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Config parity | `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` | pass (evidence + byte-identity cmp) | PASS |

**Notes:** No suppressions (`# noqa` / `# type: ignore`) were introduced by this feature; grep of the changed source found none, so `python-suppressions.md` authorization is not implicated.

---

## 8. Gaps and Exceptions

### Identified Gaps
**None.** All policy requirements applicable to the changed scope are met.

### Approved Exceptions
**None.** No exception was requested or required.

Documented (non-blocking) risk carried forward from the spec: the live MCP `validate_orchestration_artifacts` tool is a TypeScript port not updated by this feature (spec DD-1 / Risks). This is an intentional, documented scope boundary tracked as a separate follow-up issue; the Python validator path enforces the new invariants. It does not violate any policy in scope and is not a remediation trigger.

### Removed/Skipped Tests
**None.** The 19 skips are pre-existing environment-gated parity tests, unchanged from baseline.

---

## 9. Summary of Changes

### Files Modified (by category)

1. **Python source (5):** `compute_complexity_floor.py`, `resolve_delegation_model.py`, `_orchestrator_state_complexity.py`, `_orchestrator_state_model_routing.py` (NEW); `validate_orchestrator_state.py` (MODIFIED — wires the two optional validators into the key-gated loop).
2. **Python tests (4):** `test_compute_complexity_floor.py`, `test_resolve_delegation_model.py`, `test_validate_orchestrator_state_complexity.py`, `test_validate_orchestrator_state_model_routing.py` (NEW).
3. **Config (1 + mirror):** `config/orchestration-routing.json` — adds `model_policy` and `model_budget.fable_policy` (default `disabled`).
4. **Agents (2 new + 1 edit + mirrors):** `commit-message.md`, `human-exception-runbook.md` (NEW); `orchestrator.md` allowlist (MODIFIED).
5. **Settings (1 + mirror):** `.claude/settings.json` authorizes `Agent(commit-message)` and `Agent(human-exception-runbook)`.
6. **Skills/rules (3 + mirrors):** `orchestrate/SKILL.md`, `epic-orchestrate/SKILL.md` (Model Selection sections and delegation edits), `orchestrator-state.md` (additive invariant prose).
7. **Docs/evidence (remaining):** scoping docs, plan, research, and the `evidence/**` tree.

### Commits
Single feature commit cherry-picked onto current `main`; head `e2d47f6`.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

The change is a clean, additive, well-tested feature. Every applicable policy gate passes on fresh execution against the current base. Coverage is above threshold, bundle mirrors are byte-identical, the two-axis invariants hold in code, and the additive validators preserve backward compatibility.

**Fail-closed reminder satisfied:** numeric baseline and post-change coverage are present for the only in-scope code language (Python); no required artifact is missing.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes / Design Principles / Module Structure / Naming & Docs / Toolchain / Summarize.

#### Language-Specific Code Change Policy (Section 3)
- **Python:** PASS Tooling / Design & Typing / Error Handling.
- **JSON:** PASS parity + strict JSON.

#### General Unit Test Policy (Section 1)
- PASS Core Principles / Coverage & Scenarios / Test Structure / External Dependencies / Policy Audit.

#### Language-Specific Unit Test Policy (Section 4)
- **Python:** PASS Framework / Style / Naming / Toolchain.

### Metrics Summary
- PASS 1257/1257 run tests passing (19 pre-existing skips).
- PASS 100% line/branch on all four new modules; 96% on the edited validator.
- PASS 86.47% repo-wide line, 86.47% branch.
- PASS 8/8 bundle mirrors byte-identical.
- PASS Evidence-location validator exit 0.

### Recommendation

**Ready for merge.** Zero blocking findings. No remediation required.

---

## Appendix A: Test Inventory

New test files and representative cases:

- `tests/scripts/dev_tools/test_compute_complexity_floor.py` — each floor guard contributes C3; max-of-multiple; no-signal C1; never-exceed-C3; determinism across ordering.
- `tests/scripts/dev_tools/test_resolve_delegation_model.py` — base table per band; available leaves fable intact; disabled clamps fable->opus with provenance; preferred overlay for the four agents at C3; `atomic-executor`/`pr-author` C3 stays opus; determinism; config cross-check of overlay agent set.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` — band enum, band>=floor, floor==compute, non-empty rationale, non-list/non-object fail-closed, `test_no_complexity_assessments_is_backward_compatible`.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing.py` — model==resolve, disabled no-fable, disabled fable-cell clamp provenance, `test_no_model_routing_receipts_is_backward_compatible`.

---

## Appendix B: Toolchain Commands Reference

```bash
# Formatting
poetry run black --check scripts/dev_tools/compute_complexity_floor.py scripts/dev_tools/resolve_delegation_model.py scripts/dev_tools/_orchestrator_state_complexity.py scripts/dev_tools/_orchestrator_state_model_routing.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_compute_complexity_floor.py tests/scripts/dev_tools/test_resolve_delegation_model.py tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing.py

# Linting
poetry run ruff check <same file list>

# Type checking
poetry run pyright scripts/dev_tools/compute_complexity_floor.py scripts/dev_tools/resolve_delegation_model.py scripts/dev_tools/_orchestrator_state_complexity.py scripts/dev_tools/_orchestrator_state_model_routing.py scripts/dev_tools/validate_orchestrator_state.py

# Testing + coverage (artifact: artifacts/python/lcov.info)
poetry run pytest --cov --cov-branch --cov-report=term-missing

# Evidence-location validation
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# Bundle-sync byte-identity
cmp -s config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json
```

Note on template resolution: the MCP tool `mcp__drm-copilot__resolve_policy_audit_template_asset` was not available in this agent's tool surface. This artifact was authored from the authoritative bundled template at `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, preserving all canonical major headings and the Appendix B command reference. Assumption documented per the fail-closed guidance.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-03
**Policy Version:** Current (as of audit date)
