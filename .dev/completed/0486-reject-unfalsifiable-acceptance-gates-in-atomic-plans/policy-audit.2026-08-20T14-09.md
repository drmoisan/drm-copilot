# Policy Compliance Audit: reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486)

**Audit Date:** 2026-08-20
**Auditor:** feature-review agent (delegated session)
**Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` @ `cdf85294e713d08185aecf68f8869bed2975a723`
**Base:** `main` (merge-base `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec`, confirmed against `origin/main` this session)
**Work mode:** `full-feature` (persisted `- Work Mode: full-feature` marker in `issue.md`)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, the backing file of the `template` selector served by the MCP resolver tool; this delegated session's tool set does not include the MCP server tools, so the asset was read directly from the bundled path. Instruction block removed per template guidance.
**Clock note:** this session's host clock read `2026-08-20T14-09` at authoring time, which is earlier than the committed executor artifact `branch-diff-file-list.2026-08-20T14-48.md` written from a different session. This is the same inter-session host-clock variance the executor documented in `plan-self-validation.2026-08-20T13-46.md`; the artifact is not backdated.

**Code Under Test:** 67 files changed vs merge-base (+7652/-21). Production code: `scripts/dev_tools/plan_gate_commands.py` (new), `scripts/dev_tools/plan_gate_discrimination.py` (new), `scripts/dev_tools/validate_orchestration_artifacts.py` (modified), `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` (new), `plan-gate-discrimination.ts` (new), `plan-gate-rules.ts` (new), `orchestration-artifacts.ts` (modified), `validate-orchestration-service-call.ts` (modified), `src/mcp-tools.ts` (modified), `src/repo-automation-service-contract.ts` (modified, type-only). Test code: 6 new Python test modules, 8 new TypeScript test modules. Config: `extensions/drm-copilot/jest.config.cjs` (additive per-file thresholds). Docs/rules: `.claude/rules/plan-acceptance-gates.md` (new), `.claude/skills/atomic-plan-contract/SKILL.md` (modified), both mirrored under `extensions/drm-copilot/resources/claude-customizations/` plus `pack-manifests/core.json`; feature folder docs and evidence.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 9 files | 3998 tests | PASS 3998 pass, 0 fail, 5 pre-existing skips | 93.70% lines, 84.62% branches (modified module) | 96.62% lines, 91.07% branches (modified module) | 98.21% lines, 90.54% branches (lowest new module) |
| TypeScript | 16 files | 2621 tests | PASS 2621 pass, 0 fail | 96.61% lines, 89.96% branches (repo-wide); 100.00% lines, 84.61% branches (`validate-orchestration-service-call.ts`) | 96.64% lines, 89.97% branches (repo-wide); 98.51% lines, 81.25% branches (`validate-orchestration-service-call.ts`) | 96.25% lines, 84.93% branches (lowest new module) |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-test.2026-08-20T11-35.md` (repo-wide 96.61% lines, 89.96% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` regenerated and parsed this session (repo-wide 96.64% lines, 89.97% branches), consistent with `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-test.2026-08-20T13-32.md`
- PowerShell baseline coverage artifact: N/A — zero PowerShell files changed on this branch (`git diff --name-status origin/main...HEAD` contains no `.ps1`/`.psm1` paths)
- PowerShell post-change coverage artifact: N/A — zero PowerShell files changed on this branch
- Per-language comparison summary: section 1.2.1 below

## Rejected Scope Narrowing

No scope-narrowing instruction was detected in the caller prompt. The caller explicitly delegated scope determination and supplied the full-branch baseline. The audit scope is the full branch diff `71aebdb9..cdf85294` against `main`.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no violations reported.
- `git diff --name-only origin/main...HEAD` contains zero paths under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (grep over the diff list returned no matches).
- All 30 committed evidence artifacts live under the canonical `<FEATURE>/evidence/{baseline,qa-gates,regression-testing}/` tree. PASS.

## Executive Summary

The feature adds acceptance-gate rules G1–G6 to the plan validator in both runtimes (Python `scripts/dev_tools/plan_gate_commands.py` + `plan_gate_discrimination.py`; TypeScript `plan-gate-commands.ts` + `plan-gate-discrimination.ts` + `plan-gate-rules.ts`), threads a two-channel (blocking/warnings) report through the existing `plan` route with no surface growth, and records the rules in a new `.claude/rules/plan-acceptance-gates.md` with an authoring-guidance cross-reference in `atomic-plan-contract/SKILL.md`. All seven toolchain stages that exist for the changed languages pass cleanly in a single pass, re-run in this review session. Two Blocking findings remain, both already surfaced honestly by the executor's own evidence:

1. **Coverage regression on changed lines (TypeScript).** `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts` fell from 100.00%/84.61% to 98.51%/81.25% (line/branch). The uncovered lines 117–118 are lines this branch added (the combined blocking-error-plus-warning message path). Independently confirmed by parsing `coverage/lcov.info` regenerated this session (`DA` misses at exactly 117 and 118). Violates the uniform gate "No regression on changed lines" (`.claude/rules/quality-tiers.md`) and the modified-file rule in the feature-review coverage procedure. FAIL.
2. **Spec AC7 text defect leaves AC7, two Definition-of-Done items, and plan tasks [P12-T13]/[P12-T14] unreconciled.** The shipped `G5_SEVERITY = "warning"` follows the approved plan's two-conjunct rule ([P5-T3]), which explicitly pre-declared and authorized the vacuous-measurement branch taken (0 G5 findings over 166 plans, 100 candidate literals). Spec AC7's one-conjunct biconditional ("Blocking if and only if the recorded false-positive count is 0") does not handle the zero-finding case and is failed as literally written. This audit assesses the defect as residing in the spec text, not the implementation. Requires a documentation reconciliation, not a code change.

Two Minor findings (Python line 359 uncovered new defensive branch; no single-plan three-failure-mode integration scenario) are recorded in section 8 and in the code review.

Verdict: **PARTIALLY COMPLIANT — remediation required** (2 Blocking findings). See `remediation-inputs.2026-08-20T14-09.md`.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|---|---|---|
| Independence / isolation | PASS | New tests use in-memory plan strings, stub git adapters, and stub file readers; no shared mutable state. Full suites pass in one run (3998 py / 2621 ts). |
| Fast execution | PASS | Python suite 11.74 s; TypeScript suite 14.17 s (this session). |
| Determinism | PASS | No wall-clock, RNG, timers, or network in new tests; fixtures are constants. No `setTimeout`/`Date.now()` in new test files. |
| Readability / AAA structure | PASS | New tests carry docstrings/comments and Arrange–Act–Assert sections (e.g., `test_plan_gate_parity.py`, `plan-gate-parity.test.ts`). |
| No external services | PASS | The git seam is stubbed in unit tests; the only live-`git` use was the throwaway corpus driver, deleted per [P5-T5]. |
| No temporary files in tests | PASS | Fixtures are in-memory strings; spec "Tests" note confirms the constraint and inspection of the new test modules found no tempfile use. |

### 1.2 Coverage and Scenarios

- Positive, negative, boundary, and error-handling flows are covered per rule: the `--cov` classification table is exercised row-by-row (`test_plan_gate_discrimination_cov.py`, `plan-gate-discrimination-cov.test.ts`), literal checkability branches and both attribution-window boundaries are tested (AC5's four tests per runtime), and graceful degradation covers the raising and non-zero-exit adapter cases (AC10).
- Scenario gap (Minor): the seeded integration scenario "a synthetic plan carrying one instance of each of the three confirmed failure modes produces three distinct findings at their specified severities" has no single-plan test; each failure mode is verified individually at its specified severity. Recorded in section 8.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.70% lines / 84.62% branches on the one pre-existing changed module (`scripts/dev_tools/validate_orchestration_artifacts.py`). Post-change: 96.62% lines / 91.07% branches on that module. Change: +2.92 line points and +6.45 branch points on the modified module; new modules measure 100.00%/100.00% (`plan_gate_commands.py`) and 98.21%/90.54% (`plan_gate_discrimination.py`). New/changed-code coverage: 98.21% lines at the lowest new module. Disposition: PASS. Evidence: lcov re-generated this session at `artifacts/python/lcov.info` (LF/LH 148/143, BRF/BRH 56/51 for the modified module) plus `evidence/qa-gates/python-test.2026-08-20T13-21.md`.
- TypeScript: Baseline: 100.00% lines / 84.61% branches on `src/lib/validate/validate-orchestration-service-call.ts` and 96.61% lines / 89.96% branches repo-wide. Post-change: 98.51% lines / 81.25% branches on that file and 96.64% lines / 89.97% branches repo-wide. Change: -1.49 line points and -3.36 branch points on the changed file with the uncovered lines 117-118 being lines this branch added, a changed-line regression; repo-wide moved +0.03/+0.01. New/changed-code coverage: 96.25% lines at the lowest new module (`plan-gate-commands.ts`). Disposition: FAIL. Evidence: `extensions/drm-copilot/coverage/lcov.info` regenerated this session (DA misses 117, 118) plus `evidence/qa-gates/coverage-delta.2026-08-20T13-36.md`.

Per-language coverage verdicts (explicit, per feature-review scope rule): **Python coverage: PASS. TypeScript coverage: FAIL (no-regression-on-changed-lines violation; all absolute thresholds pass). PowerShell: N/A (zero changed files). C#: N/A (zero changed files).**

### 1.3 Test Structure and Diagnostics

PASS. AAA sections and descriptive names throughout the 14 new test modules; parity tests assert exact expected strings so failures are self-diagnosing.

### 1.4 External Dependencies and Environment

PASS. No new dependencies in `pyproject.toml` or `package.json` (spec Dependencies: "None added"; diff confirms neither manifest changed except jest thresholds in `jest.config.cjs`).

### 1.5 Policy Audit Requirement

PASS. This artifact. Executor evidence tree contains baseline, qa-gates, and regression-testing artifacts for every stage.

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Phase 0 policy reads recorded in `evidence/baseline/phase0-instructions-read.2026-08-20T11-26.md`; toolchain baselines captured for both languages (`evidence/baseline/*.2026-08-20T11-2x/3x.md`).

### 2.2 Design Principles

PASS. Extractor and rule evaluation are pure functions over text plus an injected repository seam (`PlanGateContext` / adapter interfaces); I/O (git, file reads) is isolated behind the seam; severities are constants routed through a two-channel report rather than parsed from message text.

### 2.3 Module & File Structure

PASS. All production and test files are under the 500-line ceiling (largest: `validate_orchestration_artifacts.py` 495, `plan_gate_discrimination.py` 490, `plan-gate-rules.ts` 437; verified by `wc -l` this session). The plan's contingency tasks [P4-T13]/[P8-T14] governed the splits; the TypeScript overflow split created `plan-gate-rules.ts` as authorized by [P8-T14], with the per-file jest threshold added per [P9-T12]. Note: the spec's "Scope of change" prose says "Two new modules (one per runtime)"; three TypeScript modules landed. The deviation is plan-authorized and documented; advisory only.

### 2.4 Naming, Docs, and Comments

PASS. `snake_case`/`PascalCase` (Python) and `camelCase`/`PascalCase` (TypeScript) conventions observed; new modules carry module docstrings/JSDoc headers; `G5_SEVERITY` carries the required source comment citing the measurement artifact in both runtimes.

### 2.5 After Making Changes - Toolchain Execution

All stages re-run by this reviewer in this session (commands in Appendix B):

| Stage | Python | TypeScript |
|---|---|---|
| 1. Formatting | PASS (`black --check`: 433 files unchanged) | PASS (`prettier --check`: all files clean) |
| 2. Linting | PASS (`ruff check --no-fix`: all checks passed) | PASS (`eslint`: exit 0, no output) |
| 3. Type checking | PASS (`pyright`: 0 errors) | PASS (`tsc --noEmit`: exit 0) |
| 4. Architecture-boundary tests | N/A — no repo-defined stage for `scripts/` | N/A — no dependency-cruiser config exists in `extensions/drm-copilot` |
| 5. Unit tests | PASS (3998 passed, 5 pre-existing skips) | PASS (193 suites, 2621 passed) |
| 6. Contract / schema checks | PASS — MCP input-schema property-key set asserted unchanged by named tests (`test_validate_orchestration_artifacts_plan_gates.py`, `mcp-plan-gate-warning-projection.test.ts`, `mcp-repo-automation-tool-definitions.test.ts`) | same |
| 7. Integration tests | PASS — CLI end-to-end tests (`test_main_emits_warning_prefix_on_stderr_and_exits_zero`, `test_main_emits_blocking_error_on_stderr_and_exits_one`) plus live CLI plan self-validation re-run this session (exit 0, two expected self-referential warnings from the plan's own quoted fixture command in [P2-T2]) | service-call and MCP projection tests |

All applicable stages passed in a single pass with no auto-fixes.

### 2.6 Summarize and Document

PASS. `.claude/rules/plan-acceptance-gates.md` records the rule table, both severity decisions, the placeholder-guard trade, the message-formatting prohibition, and the no-grandfathering argument; `atomic-plan-contract/SKILL.md` gained the "Wrap-Tolerant Assertion Authoring" section cross-referencing it. Both files byte-identical to their `extensions/drm-copilot/resources/claude-customizations/` mirrors (verified with `cmp` this session); `pack-manifests/core.json` lists the new rule file.

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

PASS. Black, Ruff, Pyright all clean (this session). Baselines captured pre-change.

#### 3A.2 Python Design & Typing

PASS. New modules fully typed (frozen dataclasses for records/report, `PlanGateContext` protocol seam); Pyright passes with 0 errors; no new suppressions found in the diff (no `# type: ignore`, `# noqa`, or `pyright: ignore` additions in the changed Python files).

#### 3A.3 Python Error Handling

PASS with one deliberate, documented exception-swallowing seam: graceful degradation catches repository-seam failures and skips G2/G3/G5/G6 rather than raising, which is a specified behavior of the rule set (spec "Graceful degradation"; rule file section of the same name), not a silent-ignore violation — the design intent is that a validation run must never fail because the repository could not be queried.

### Section 3B: TypeScript Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

PASS. Prettier, ESLint, TSC all clean (this session).

#### 3B.2 TypeScript Design & Safety

PASS. No `any` in the new modules; `warnings` is `ReadonlyArray<string>` and conditionally projected so a warning-free result is byte-identical to the pre-change shape; `PLAN_GATE_WARNING_PREFIX` exported as a single constant.

#### 3B.3 Structure, Naming, and Comments

PASS. Split into `plan-gate-rules.ts` keeps each module under the ceiling; jsdoc on exported members.

#### 3B.4 Running the Toolchain

PASS. See 2.5.

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

PASS. Pytest; new tests under `tests/scripts/dev_tools/` mirroring `scripts/dev_tools/` per the universal layout rule; no colocation.

#### 4A.2 Test Style and Structure

PASS. AAA comments, parametrized classification table, stub adapters.

#### 4A.3 Naming and Readability

PASS. Descriptive `test_*` names matching the AC-named tests (e.g., `test_g5_reports_literal_absent_from_tree_and_plan`, `test_g5_exonerates_literal_quoted_in_plan`).

#### 4A.4 Running the Toolchain

PASS. 3998 passed / 5 pre-existing skips (identical skip set to baseline).

### Section 4B: TypeScript Unit Test Policy Compliance

#### 4B.1 Framework and Scope

PASS. Jest; new tests under `extensions/drm-copilot/test/` mirroring `src/`, the extension's established test tree.

#### 4B.2 Test Style and Structure

PASS. Parity fixture set duplicated verbatim with the Python side per AC9; apostrophe-bearing fixtures included.

#### 4B.3 Naming and Readability

PASS.

#### 4B.4 Running the Toolchain

PASS. 193 suites / 2621 tests, exit 0, with the three new per-file coverage thresholds active.

## 5. Test Coverage Detail

### Python modules (new + modified)

- `scripts/dev_tools/plan_gate_commands.py` — 100.00% lines (77/77), 100.00% branches (28/28). New file. PASS.
- `scripts/dev_tools/plan_gate_discrimination.py` — 98.21% lines (165/168), 90.54% branches (67/74). New file. PASS. Misses are guard exits (77→exit … 83→exit) and three severity-routing lines (311, 350, 379) on the unreached blocking arms of warning-shipped rules.
- `scripts/dev_tools/validate_orchestration_artifacts.py` — 96.62% lines (143/148), 91.07% branches (51/56). Modified file; both axes improved vs baseline (93.70/84.62). PASS at file level. Minor: the added line 359 (`return _plan_channels(args)[0]` — the plan short-circuit inside `_validate_from_args`) is uncovered; the other four misses (72, 406, 408, 410) are pre-existing or relocated misses already uncovered at baseline (baseline miss set 66, 314, 316, 318).

### TypeScript modules (new + modified)

- `src/lib/validate/plan-gate-commands.ts` — 96.25% lines, 84.93% branches. New. PASS.
- `src/lib/validate/plan-gate-discrimination.ts` — 100.00% lines, 97.92% branches. New. PASS.
- `src/lib/validate/plan-gate-rules.ts` — 97.71% lines, 89.39% branches. New. PASS.
- `src/lib/validate/orchestration-artifacts.ts` — 100.00% lines, 98.68% branches. Modified; no regression. PASS.
- `src/mcp-tools.ts` — 92.50% lines, 82.76% branches. Modified; both axes improved. PASS.
- `src/repo-automation-service-contract.ts` — 0% (type-only interface module, one optional readonly field added; legitimate 0% executable-coverage case per `.claude/rules/general-unit-test.md`). PASS.
- `src/lib/validate/validate-orchestration-service-call.ts` — 98.51% lines, 81.25% branches; regression from 100.00/84.61 with uncovered added lines 117–118. **FAIL** (Blocking finding 1).

## 6. Test Execution Metrics

| Metric | Python | TypeScript |
|---|---|---|
| Tests run | 4003 (3998 passed, 5 skipped) | 2621 (all passed) |
| Suites | one pytest session | 193 |
| Duration (this session) | 11.74 s | 14.17 s |
| Exit code | 0 | 0 |
| Delta vs baseline | +148 tests | +8 suites / +63 tests |

## 7. Code Quality Checks

- Formatting: PASS both languages (check-only, zero rewrites).
- Lint: PASS both languages, zero findings.
- Types: PASS both languages, zero errors.
- `jest.config.cjs` diff inspected against the Coverage Exclusion Policy: additive per-file `coverageThreshold` entries only; no `exclude`/`collectCoverageFrom` narrowing; no production path removed from the denominator. PASS.
- Message-formatting prohibition (no `repr()`/`!r`/`pythonRepr` in gate messages): enforced by `test_no_repr_formatting_in_gate_messages` and its TypeScript companion; both pass. PASS.
- `modified-workflow-needs-green-run`: does not fire — the diff contains no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. N/A.
- Policy-document integrity: `.github/instructions/**` untouched; `.claude/hooks/validate-planner-output.ps1` untouched (AC12 verified against the diff list). The new `.claude/rules/plan-acceptance-gates.md` is in-scope feature output authorized by the spec, not a modification of an existing policy document.
- Evidence locations: PASS (see "Evidence Location Compliance").

## 8. Gaps and Exceptions

### Identified Gaps

1. **[Blocking] TypeScript changed-line coverage regression** — `validate-orchestration-service-call.ts` lines 117–118 (combined error-plus-warning message path) added uncovered; file fell 100.00→98.51 line, 84.61→81.25 branch. The executor's own `coverage-delta.2026-08-20T13-36.md` records this as FAIL/remediation-required and correctly did not silently fix it (no plan task assigns the fix). Remedy: one named test driving a runner that returns at least one error and one warning, asserting the thrown message appends the `PLAN GATE WARNING: `-prefixed block.
2. **[Blocking] Spec AC7 text defect / unreconciled AC and DoD checkboxes** — Shipped `G5_SEVERITY = "warning"` in both runtimes follows approved plan [P5-T3]'s two-conjunct rule (Blocking iff finding count > 0 AND false-positive count == 0), whose vacuous-measurement branch the plan pre-declared, predicted, and terminally disposed. The measurement artifact (`g5-corpus-measurement.2026-08-20T12-02.md`) is complete and internally consistent (166 plans, 100 candidates, 0 tree-absence holds, 0 findings, four driver-integrity checks). Spec AC7's one-conjunct biconditional is failed as literally written (FP count 0, severity warning), but shipping Blocking on a vacuous measurement would contradict the spec's own stated rationale ("Shipping G5 as Blocking without that measurement risks creating exactly the false-rejection generator the issue warns against") and the spec's Constraints section, which defers to "the pre-declared measurement." This audit therefore locates the defect in the spec text. Remedy: amend spec.md AC7, the pre-declared rule paragraph, and DoD item 2 to the two-conjunct rule already recorded in `.claude/rules/plan-acceptance-gates.md`, record the deviation, then check off AC7, DoD items 1–2, and plan tasks [P12-T13]/[P12-T14].
3. **[Minor] Python added line uncovered** — `validate_orchestration_artifacts.py` line 359, the defensive plan short-circuit in `_validate_from_args`, is a new uncovered line. File-level coverage improved on both axes, so this is not a threshold or file-regression failure; recorded for completeness and folded into the remediation inputs as a one-test item.
4. **[Minor] Seeded integration scenario partially satisfied** — no single synthetic plan exercises the three confirmed failure modes (G1 path-form coverage, G5 interpolated literal, G6 wrapped phrase) in one end-to-end run producing three findings at their specified severities. Each mode is individually verified at its specified severity. Spec seeded-condition checkbox 2 left unchecked.

### Approved Exceptions

- [P12-T11] was closed from the orchestrator session because the delegated executor tool set lacked the MCP validator; both the BLOCKED artifact and the superseding PASS artifact are committed with full provenance and a clock-variance note. This reviewer additionally re-validated the plan through the Python CLI this session (exit 0). Accepted; advisory only.
- Two `PLAN GATE WARNING` lines (G4 and G3) on the feature's own plan during self-validation originate from the [P2-T2] fixture command the plan quotes; warnings do not fail the gate by design. Accepted.

### Removed/Skipped Tests

None removed. The 5 Python skips are pre-existing parity-fixture skips, identical to baseline.

## 9. Summary of Changes

### Commits in This PR/Branch

Branch range `71aebdb9..cdf85294` (`git diff origin/main...HEAD`): 67 files, +7652/-21.

### Files Modified

- Python production: 1 modified, 2 added; Python tests: 6 added.
- TypeScript production: 4 modified (one type-only), 3 added; TypeScript tests: 8 added; `jest.config.cjs` thresholds extended.
- Rules/skills: `.claude/rules/plan-acceptance-gates.md` added; `atomic-plan-contract/SKILL.md` extended; both mirrored byte-identically under `extensions/drm-copilot/resources/claude-customizations/`; `pack-manifests/core.json` updated.
- Feature docs: issue/spec/user-story/plan/research plus 30 evidence artifacts; promoted potential entry moved to `docs/features/potential/promoted/`.

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PASS. Toolchain fully green in a single pass; file-size ceiling respected via plan-authorized splits; no new dependencies; I/O isolated behind seams.

#### Language-Specific Code Change Policy (Section 3)

PASS for Python and TypeScript.

#### General Unit Test Policy (Section 1)

PARTIAL. Core principles, structure, determinism, and scenario coverage pass; the no-regression-on-changed-lines coverage rule fails for one modified TypeScript file (Blocking finding 1).

#### Language-Specific Unit Test Policy (Section 4)

PASS for Python and TypeScript test conventions.

### Metrics Summary

- Python: 3998 tests pass; changed/new modules 96.62–100.00% lines, 90.54–100.00% branches. Coverage verdict: PASS.
- TypeScript: 2621 tests pass; repo-wide 96.64% lines / 89.97% branches; changed/new modules 92.50–100.00% lines with one changed-line regression. Coverage verdict: FAIL (regression), absolute thresholds all pass.
- PowerShell, C#: zero changed files; N/A.

### Recommendation

NO-GO for PR until the two Blocking findings are remediated: (1) one added TypeScript test restoring changed-line coverage on `validate-orchestration-service-call.ts`; (2) spec AC7 / DoD reconciliation and the consequent check-offs ([P12-T13], [P12-T14]). Both are small, bounded items. See `remediation-inputs.2026-08-20T14-09.md`.

## Appendix A: Test Inventory

### Complete Test List

New Python test modules (all under `tests/scripts/dev_tools/`):

- `test_plan_gate_commands.py` (extractor records, kinds, attribution window) — 235 lines
- `test_plan_gate_discrimination_cov.py` (G1–G4 classification table, dotted remedy) — 200 lines
- `test_plan_gate_discrimination_context.py` (repository seam, degradation) — 252 lines
- `test_plan_gate_discrimination_literals.py` (G5/G6, checkability, placeholder guard, severity routing) — 347 lines
- `test_plan_gate_parity.py` (eight shared fixtures, severity-constant cross-check, no-repr assertions, task-regex equivalence) — 276 lines
- `test_validate_orchestration_artifacts_plan_gates.py` (structural-baseline byte identity, CLI stderr/exit contract, dispatch, warning channel) — 321 lines

New TypeScript test modules (all under `extensions/drm-copilot/test/`):

- `lib/validate/plan-gate-commands.test.ts`, `plan-gate-discrimination-cov.test.ts`, `plan-gate-discrimination-literals.test.ts`, `plan-gate-parity.test.ts`, `plan-gate-repository.test.ts`, `orchestration-artifacts-plan-gates.test.ts`, `validate-orchestration-service-call-plan-gates.test.ts`, `mcp-plan-gate-warning-projection.test.ts`

Full suites: 3998 Python tests, 2621 TypeScript tests, all passing this session.

## Appendix B: Toolchain Commands Reference

```bash
# Python (from worktree root)
poetry run black --check scripts tests                                   # exit 0
poetry run ruff check --no-fix scripts tests                             # exit 0
poetry run pyright                                                       # exit 0, 0 errors
poetry run pytest -q --cov=scripts.dev_tools.plan_gate_commands \
  --cov=scripts.dev_tools.plan_gate_discrimination \
  --cov=scripts.dev_tools.validate_orchestration_artifacts \
  --cov-branch --cov-report=term-missing \
  --cov-report=lcov:artifacts/python/lcov.info                           # exit 0, 3998 passed / 5 skipped
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts \
  plan docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md \
  --workspace-root .                                                     # exit 0, 2 warnings on stderr
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .  # exit 0

# TypeScript (from extensions/drm-copilot)
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"       # exit 0
npx eslint --no-error-on-unmatched-pattern src test                      # exit 0
npx tsc -p ./ --noEmit                                                   # exit 0
node run-jest.cjs --coverage --coverageReporters=lcov \
  --coverageReporters=text-summary                                       # exit 0, 193 suites / 2621 tests
```
