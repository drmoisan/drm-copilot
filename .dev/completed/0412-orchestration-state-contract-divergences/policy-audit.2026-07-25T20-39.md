# Policy Compliance Audit: orchestration-state-contract-divergences (Issue #412) — Re-audit R4 (post remediation cycle 1)

---

**Audit Date:** 2026-07-25
**Audit Type:** Re-audit (R4) after remediation cycle 1; full feature-vs-base scope, not the remediation delta
**Code Under Test:**
- Python (production): `scripts/dev_tools/validate_orchestrator_state.py` (modified), `scripts/dev_tools/_orchestrator_state_step_status.py` (new), `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` (modified), `scripts/dev_tools/compute_complexity_floor.py` (modified)
- Python (tests): `tests/scripts/dev_tools/test_validate_orchestrator_state_step_status_extras.py` (new), `tests/scripts/dev_tools/test_validate_orchestrator_state_pr_creation_readiness.py`, `tests/scripts/dev_tools/test_compute_complexity_floor.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` (modified)
- PowerShell (production): `.claude/lib/orchestrator-state/OrchestratorState.psm1`, `.claude/lib/model-routing/ModelRouting.psm1` (modified; `OrchestratorState.psm1` re-modified by remediation cycle 1), plus their byte mirrors `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1` and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/model-routing/ModelRouting.psm1`
- PowerShell (tests): `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` (re-modified by remediation cycle 1), `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1`, `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1` (modified)
- TypeScript (production): `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` (modified; untouched by remediation cycle 1)
- TypeScript (tests): `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.test.ts`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts` (modified; untouched by remediation cycle 1)
- Docs/evidence: `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/**` (issue.md, spec.md, plan, remediation inputs/plan, research, evidence tree)

**Scope basis:** full branch diff `main...bug/orchestration-state-contract-divergences-412`, merge base `009808510363081d0db7684f7b555f2ded4b0b7c` (derived by this review with `git merge-base main HEAD`; tip of `origin/main`), head `bfb73c75fafde8c1896f954f29473e1d23f12213` (seven commits, the seventh being remediation cycle 1), 116 files changed. PR context artifacts at `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt` were stale at review start (recorded head `81f3df3f`, one commit behind); this review regenerated both against `main` at the current HEAD before proceeding.

**Remediation cycle 1 surface verification:** `git diff --name-only 81f3df3f..HEAD` shows exactly three non-documentation files — `.claude/lib/orchestrator-state/OrchestratorState.psm1`, its resources byte mirror, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` — plus feature-folder docs/evidence. **Zero Python and zero TypeScript files changed in the remediation cycle** (verified from the same name-only diff), so the Python and TypeScript full-suite/coverage evidence recorded at `81f3df3f` remains valid for the current HEAD, and was additionally spot-re-verified by this review as detailed below.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 4 prod + 4 test | 2123 tests | PASS 2123 pass, 0 fail (executor full re-run at post-remediation HEAD, `remediation1-pytest-guard.md`; reviewer targeted re-run 94/94 on all changed suites + push-down guard) | 90.99% lines, 81.83% branches | 91.00% lines, 81.84% branches | 100% (`_orchestrator_state_step_status.py`: 24/24 lines, 10/10 branches) |
| PowerShell | 4 prod (2 roots + 2 byte mirrors) + 3 test | 1394 tests (full PoshQC at post-remediation HEAD); 105/105 in changed suites + epic-gate suite re-run by this reviewer with `-PassThru` | PASS 0 fail | 90.22% lines, 89.68% commands | 90.26% lines, 89.73% commands | 97.17% (no new files; lowest changed-file line coverage: `OrchestratorState.psm1` 103/106 lines; 96.67% commands 145/150 post-remediation, up from 96.64%) |
| TypeScript | 1 prod + 2 test | 2035 tests / 168 suites | PASS 2035 pass, 0 fail (full-suite reviewer re-run this session with `--testMatch` override, exit 0) | 96.33% lines, 89.21% branches | 96.34% lines, 89.22% branches | 98.45% (no new files; changed-file line coverage: `orchestrator-state-core.ts` 446/453) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/evidence/baseline/phase0-typescript-test-baseline.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (present on disk; generated at `81f3df3f`, still valid — zero TypeScript files changed since, verified by `git diff --name-only 81f3df3f..HEAD`)
- PowerShell baseline coverage artifact: `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/evidence/baseline/phase0-powershell-test-baseline.md` and `evidence/remediation-baseline/poshqc-test-baseline.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (regenerated at the post-remediation HEAD, 2026-07-25 20:15; repo LINE 2159/2392 = 90.26%; `OrchestratorState.psm1` 103/106 lines = 97.17%, 145/150 commands = 96.67%; `ModelRouting.psm1` 46/46 lines = 100%)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (regenerated at the post-remediation HEAD, 2026-07-25 20:20; totals 91.00% lines, 81.84% branches)
- Per-language comparison summary: `evidence/qa-gates/final-coverage-comparison.md` (main plan) and `evidence/qa-gates/remediation1-coverage-comparison.md` (cycle 1; confirms zero PowerShell repo-wide regression and +0.03 pp on the re-modified module)

**PowerShell branch-coverage note:** Pester 5 with the `CoverageGutters` (JaCoCo) output format emits instruction/line/method/class counters only; it does not emit branch counters. The branch metric is unavailable for PowerShell by tooling limitation, not by evidence omission. Line coverage (90.26% repo-wide, >= 85%) is the enforced numeric gate for PowerShell; branch data exists and passes for Python and TypeScript.

---

## Rejected Scope Narrowing

No scope narrowing was attempted by the caller. The delegation prompt explicitly instructed the opposite ("Scope determination is your responsibility. Execute the full contract against the whole branch diff; do not restrict the audit to the remediation delta."), and all three languages with changed files were audited with explicit PASS/FAIL coverage verdicts. This section is recorded to document that the check was performed.

---

## Evidence Location Compliance

- Branch diff scan for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: **zero occurrences** across all 116 changed files. All evidence files added by this branch (including the 30 remediation-cycle evidence files) live under the canonical `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/evidence/<kind>/` tree (`baseline/`, `qa-gates/`, `regression-testing/`, `remediation-baseline/`, `other/`).
- `python scripts/dev_tools/validate_evidence_locations.py --root .` — exit code 0, no violations reported (re-run this session).
- Verdict: **PASS.** No FAIL-level evidence-location findings.

---

## Executive Summary

This re-audit (R4) covers the full branch for the two-divergence orchestration-state contract fix for Issue #412 (work mode `full-bug`) after remediation cycle 1. The remediation closed the orchestrator-elevated Blocking finding F-1 (prior code-review CR-1): the PowerShell portable PR-creation-readiness gate in `OrchestratorState.psm1` now blocks `blocked_remediation_loop_limit` on steps 5–8, restoring parity with the Python reference gate. This review independently confirmed closure by behavioral probe: `Test-OrchestratorStatePrCreationReadiness` on a checkpoint carrying `step6_status: "blocked_remediation_loop_limit"` returns ExitCode 1 with output `Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.` — byte-identical to the Python gate's error string produced by `validate_orchestrator_state_pr_creation_readiness` on the same checkpoint, on both the root module and the resources byte mirror. The same probe output contains no base-presence error, confirming the value remains plain-valid on `step6_status` (no regression of the divergence-1 fix). `pending` and `blocked` still block; a clean checkpoint passes (ExitCode 0). The two constants `$script:VALID_STEP_STATUS` and `$script:STEP_SPECIFIC_EXTRA_STATUS` are unchanged by the remediation (the 81f3df3f..HEAD module diff touches only the readiness function and its help text), both `.psm1` mirror pairs are byte-identical (`cmp` exit 0), and the module is at 497 lines (was 498).

All toolchain gates pass on evidence current at the post-remediation HEAD, with reviewer re-runs this session: PSScriptAnalyzer 0 findings and Invoke-Formatter idempotence on all 7 changed PowerShell files; direct Pester 105/105 on the changed suites plus the unmodified epic-merge-gate regression suite; targeted pytest 94/94 plus Black/Ruff/Pyright clean on the changed Python files; ESLint/Prettier/TSC clean on the changed TypeScript files; full Jest 168 suites / 2035 tests passed with the dot-directory `--testMatch` override. Coverage meets the uniform thresholds (line >= 85%, branch >= 75% where measurable) repo-wide and on every changed production file, with no regression against recorded baselines in any language, including the remediation-cycle PowerShell comparison (repo-wide unchanged; re-modified module +0.03 pp commands). The deliberately-unchanged file set is verified untouched at zero diff against the merge base.

**Policy documents evaluated:**
- [x] `CLAUDE.md` + `.claude/rules/general-code-change.md`
- [x] `.claude/rules/general-unit-test.md`
- [x] `.claude/rules/quality-tiers.md`
- [x] `.claude/rules/orchestrator-state.md` (domain rule for the changed validators)

**Language-specific policies evaluated:**
- [x] `.claude/rules/python.md` + `python-suppressions`
- [x] `.claude/rules/powershell.md`
- [x] `.claude/rules/typescript.md` + `typescript-suppressions`
- N/A C# (no C# files changed), N/A Bash, N/A GitHub Actions (no workflow paths changed; `modified-workflow-needs-green-run` does not fire — verified `git diff main...HEAD --name-only` contains no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths)

**Temporary artifacts cleanup:**
- [x] No temporary or throwaway scripts were committed by this branch (diff inspection: only production, test, and feature-doc/evidence files).
- [x] No new tooling scripts were added.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | New Python tests build fresh in-memory checkpoint dicts per test; Pester suites use `BeforeAll` module imports only; the remediation-added Pester case builds its checkpoint from the suite's `New-CheckpointObject` factory. Full-suite runs pass (2123 pytest / 1394 Pester / 2035 Jest). |
| **Isolation** - Each test targets single behavior | PASS | One assertion target per test, including the remediation case `returns ExitCode 1 when a readiness step is blocked_remediation_loop_limit` (OrchestratorState.Tests.ps1 line 130), which isolates the readiness gate from base validation. |
| **Fast Execution** | PASS | Reviewer direct Pester on 4 suites: 3.14s (105 tests); targeted pytest 0.26s (94 tests); full Jest 5.75s. |
| **Determinism** | PASS | All fixtures in-memory or scratch-built by factories; config reads limited to the committed `config/orchestration-routing.json`. No wall-clock, RNG, timers, or network in the added tests. |
| **Readability & Maintainability** | PASS | Descriptive names, module docstrings, AAA structure throughout (verified by diff inspection, including the remediation diff). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Main-plan baselines in `evidence/baseline/phase0-*-test-baseline.md`; remediation-cycle baseline in `evidence/remediation-baseline/poshqc-test-baseline.md` (1393 tests observed vs 1391 recorded, 0 failures either way, attributed to the published-bundle execution path of the PoshQC MCP tool — pre-existing drift, not a branch defect). |
| **No Coverage Regression** | PASS | Python 90.99% → 91.00% lines, 81.83% → 81.84% branches; PowerShell 90.22% → 90.26% lines, 89.68% → 89.73% commands (remediation cycle: repo-wide unchanged at 90.26%/89.73%; `OrchestratorState.psm1` commands 96.64% → 96.67%); TypeScript 96.33% → 96.34% lines, 89.21% → 89.22% branches. All deltas non-negative. |
| **New Code Coverage** | PASS | Sole new production file `scripts/dev_tools/_orchestrator_state_step_status.py`: 24/24 lines = 100%, 10/10 branches = 100%. |
| **Comprehensive Coverage** | PASS | Lowest changed-file metrics: `validate_orchestrator_state.py` 97.50% lines / 92.86% branches; `OrchestratorState.psm1` 97.17% lines / 96.67% commands; `orchestrator-state-core.ts` 98.45% lines / 94.52% branches. |
| **Positive Flows** | PASS | Owning-key acceptance for all four extra values; floor `C3` for each `floor: true` signal; clean checkpoint passes readiness (reviewer probe ExitCode 0). |
| **Negative Flows** | PASS | Non-owning-key rejection matrices; completion-gate rejection of the three failure values; Python and (post-remediation) PowerShell readiness rejection of step6 loop-limit value; `pending`/`blocked` still block readiness (reviewer probes); floor-mismatch rejection naming recomputed `C1`. |
| **Edge Cases** | PASS | Empty signal list → `C1`; unknown signal name → `C1`; mixed list → `C3`; never `C4`; absent step key contributes no plain-mode error. |
| **Error Handling** | PASS | Validator remains a non-raising error-string collector; literal message forms asserted byte-for-byte in Python, Jest, and the remediation Pester case (`Should -BeLike '*Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.*'`). |
| **Concurrency** | N/A | Pure set-membership and list-intersection logic; no concurrency surface. |
| **State Transitions** | PASS | Completion-gate transitions covered: `passed` does not block completion (reviewer probe: zero step9 errors under `require_complete`); each failure value blocks; absent `step9_status` treated as `pending`. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 90.99% lines / 81.83% branches -> Post-change: 91.00% lines / 81.84% branches. Change: +0.01 pp lines, +0.01 pp branches. New/changed-code coverage: 100% (`_orchestrator_state_step_status.py`, new file; lowest changed file `validate_orchestrator_state.py` 97.50% lines / 92.86% branches). Disposition: PASS. Evidence: `artifacts/python/lcov.info` (regenerated at post-remediation HEAD), `evidence/baseline/phase0-python-test-baseline.md`, `evidence/qa-gates/remediation1-coverage-comparison.md`.
- PowerShell: Baseline: 90.22% lines / 89.68% commands -> Post-change: 90.26% lines / 89.73% commands. Change: +0.04 pp lines, +0.05 pp commands. New/changed-code coverage: 97.17% lines (`OrchestratorState.psm1`, lowest changed file, 96.67% commands post-remediation; `ModelRouting.psm1` 100% lines). Branch counters not emitted by Pester 5 CoverageGutters format (tooling limitation, documented above). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (post-remediation), `evidence/remediation-baseline/poshqc-test-baseline.md`, `evidence/qa-gates/remediation1-coverage-comparison.md`.
- TypeScript: Baseline: 96.33% lines / 89.21% branches -> Post-change: 96.34% lines / 89.22% branches. Change: +0.01 pp lines, +0.01 pp branches. New/changed-code coverage: 98.45% lines / 94.52% branches (`orchestrator-state-core.ts`, sole changed production file; per-file `coverageThreshold` 85/75 enforced in unchanged `jest.config.cjs`). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` (valid at HEAD — zero TypeScript changes since generation), `evidence/baseline/phase0-typescript-test-baseline.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions compare against literal expected error strings, so a failure prints the exact contract string mismatch. |
| **Arrange-Act-Assert Pattern** | PASS | AAA structure present in every added Python, Pester, and Jest test, including the remediation Pester case (diff inspection). |
| **Document Intent** | PASS | Every added test carries a docstring or descriptive `It`/`it` name stating scenario and expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or subprocess use in added tests. Only file read is the committed routing config (by tests, never by the modules under test). |
| **Use Mocks/Stubs** | PASS | No mocking needed for the pure functions under test; existing `Test-PythonOrchestratorValidatorAvailable` seam untouched. |
| **Environment Stability** | PASS | No temporary files created by tests (prohibited); all fixtures in-memory. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document, plus `code-review.2026-07-25T20-39.md` and `feature-audit.2026-07-25T20-39.md` in the same folder; prior-cycle artifacts retained at timestamp `2026-07-25T19-14`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #412, `issue.md` (work mode `full-bug`), authoritative-side rulings in `spec.md`; remediation cycle 1 driven by `remediation-inputs.2026-07-25T19-30.md` (orchestrator elevation of CR-1 to Blocking, causation rationale recorded). |
| **Read existing change plans** | PASS | `plan.2026-07-25T15-37.md` (7 phases, 82 tasks, all checked) and `remediation-plan.2026-07-25T19-30.md` (3 phases, 27 tasks, all checked); Phase 0 policy-read evidence for both cycles. |
| **Document the plan** | PASS | Both plans committed on-branch with batch decomposition and constraints. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Per-key additive map + set-membership check; floor fix is a single list intersection; the remediation fix is a one-line membership test `@('pending', 'blocked', 'blocked_remediation_loop_limit') -contains $field.Value` replacing the two-literal comparison. |
| **Reusability** | PASS | `STEP_STATUS_KEYS` and collectors extracted once and re-exported; embedded-constant-plus-parity-test pattern reuses the `BASE_COMPLEXITY_TO_MODEL` precedent. |
| **Extensibility** | PASS | New per-key vocabulary entries require only a map entry plus tests; shared set untouched. |
| **Separation of concerns** | PASS | Pure validation logic separate from I/O; both floor implementations read no files at runtime (re-verified: zero file-read matches in both changed modules). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | `_orchestrator_state_step_status.py` holds exactly the step-status vocabulary and its two collectors. |
| **Under 500 lines** | PASS | `OrchestratorState.psm1` 497 (was 498 pre-remediation; the `.DESCRIPTION` reflow removed one line); `validate_orchestrator_state.py` 495; `ModelRouting.psm1` 229; `_orchestrator_state_step_status.py` 184; `compute_complexity_floor.py` 133; `_orchestrator_state_pr_creation_readiness.py` 128; `orchestrator-state-core.ts` 453; all changed test files 134–416 lines. Verified with `wc -l` this session. The pre-existing 735-line `test_validate_orchestrator_state.py` has zero diff on this branch. |
| **Public vs internal** | PASS | Python helper modules `_`-prefixed with `__all__`; PowerShell additions `$script:`-scoped. |
| **No circular dependencies** | PASS | Helper modules are leaves; no new import cycles. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `STEP_SPECIFIC_EXTRA_STATUS`, `COMPLETION_BLOCKING_STEP_STATUS`, `FLOOR_SIGNAL_NAMES`, `PR_CREATION_BLOCKING_STEP_STATUS`. |
| **Docs/docstrings** | PASS | Remediation updated the readiness function's `.DESCRIPTION` to state the blocked set accurately ("must not be pending, blocked, or blocked_remediation_loop_limit"), resolving the docstring-contradiction noted in remediation-inputs F-1 item 2. All other doc surfaces as previously audited. |
| **Comment why, not what** | PASS | The remediation comment states the intent ("Reject an upstream step recorded as pending, blocked, or blocked_remediation_loop_limit; steps 5-8 must have finished before the first PR of a branch is created."). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Reviewer this session: `Invoke-Formatter` idempotence check on all 7 changed PowerShell files with the PoshQC settings — content identical for all 7; `poetry run black --check` on all 8 changed Python files — unchanged, exit 0; `npx prettier --check` on the 3 changed TypeScript files — all formatted. Executor PoshQC format gates exit 0 for both cycles (`evidence/qa-gates/remediation1-phase2-poshqc-format.md`). |
| **2. Linting** | PASS | Reviewer: `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information` on all 7 changed PowerShell files → 0 findings; `poetry run ruff check` on changed Python files → all checks passed; `npx eslint` on changed TypeScript files → exit 0. Executor PoshQC analyze exit 0 with 0 findings at post-remediation HEAD. |
| **3. Type checking** | PASS | Reviewer: `poetry run pyright` on the 4 changed Python production files → 0 errors, 0 warnings; `npx tsc --noEmit` → exit 0. N/A for PowerShell. |
| **4. Testing** | PASS | Reviewer: direct Pester with `-PassThru` and explicit exit branch on the 3 changed suites + epic-merge-gate suite → 105/105, exit 0; targeted pytest on 6 suites (changed + guards) → 94/94; full Jest with `--testMatch "**/test/**/*.test.ts"` → 168 suites / 2035 tests, exit 0. Executor at post-remediation HEAD: full PoshQC test 1394/0 failures; full pytest 2123/0. |
| **Full toolchain loop** | PASS | Single clean pass in this review; executor evidence records single clean passes per phase in both cycles. Architecture-boundary and contract-check stages: no repo-defined tooling exists for the changed scopes — N/A. |
| **Explicit reporting** | PASS | Exact commands in Appendix B; per-phase executor commands recorded in `evidence/qa-gates/*` with EXIT_CODE fields. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Seven commit messages (Section 9) plus spec design summary and remediation-inputs record. |
| **Design choices explained** | PASS | Rejected alternatives documented in `spec.md`; the remediation's elevation rationale (self-introduced fail-open path) documented in `remediation-inputs.2026-07-25T19-30.md`. |
| **Update supporting documents** | PASS | `spec.md` AC checkboxes maintained; PR-body statement prepared at `evidence/other/pr-body-backcompat-statement.md`; AC reconciliation for the cycle at `evidence/qa-gates/remediation1-ac-reconciliation.md`. |
| **Provide next steps** | PASS | Remaining step: PR authoring including the divergence-2 backward-compatibility statement (sole unchecked AC, correctly deferred). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check <8 changed files>` → 8 files unchanged, exit 0 (reviewer, this session). |
| **Linting with Ruff** | PASS | `poetry run ruff check <8 changed files>` → all checks passed (reviewer, this session). No new suppressions in the branch diff (prior grep: zero `noqa`/`type: ignore`/`pyright: ignore` hits; no Python changes since). |
| **Type checking with Pyright** | PASS | `poetry run pyright <4 changed production files>` → 0 errors, 0 warnings, 0 informations (reviewer, this session). |
| **Testing with Pytest** | PASS | Executor full run at post-remediation HEAD: 2123 passed, 0 failed (`evidence/qa-gates/remediation1-pytest-guard.md`); reviewer targeted 94/94. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Full annotations; `dict[str, frozenset[str]]`, `frozenset[str] | set[str]` unions; no `Any` in new code. |
| **Dataclasses for value objects** | N/A | No value objects introduced. |
| **Protocols/ABCs for interfaces** | N/A | Single implementation per function by design. |
| **Avoid utility classes** | PASS | Module-level functions; no classes added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | Non-raising error-string collector contract preserved; no `try/except` added. |
| **Logging over print** | PASS | No `print` added to production code. |
| **Invariants at construction** | PASS | Constants are `frozenset`/tuple immutables; helpers are pure. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | Reviewer check-only `Invoke-Formatter` idempotence on all 7 changed files with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`: all identical. Executor PoshQC format exit 0 (both cycles). |
| **Linting with PSScriptAnalyzer** | PASS | Reviewer: 0 findings on all 7 changed files (Error/Warning/Information severities). Executor PoshQC analyze exit 0 at post-remediation HEAD. |
| **Fix all findings** | PASS | Zero findings to fix. |
| **PowerShell 7+ compatible** | PASS | The remediation uses an array-literal `-contains` membership test — no version-specific features. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | Changed functions retain `[CmdletBinding()]`, `[OutputType()]`, mandatory parameters. |
| **Parameter validation** | PASS | No parameter surface changed in either cycle. |
| **Avoid global state** | PASS | Constants `$script:`-scoped; remediation added no new state (the blocked set is an inline literal in the single function that uses it). |
| **Error handling** | PASS | Error-string collector pattern preserved; fail-closed contract of the module header unchanged; readiness message form byte-identical to the Python reference (verified by probe). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | `OrchestratorState.psm1` 497 lines (limit 500; remediation reduced it by one — see code review Minor finding on remaining headroom); `ModelRouting.psm1` 229. |
| **Approved verbs** | PASS | No new functions in either cycle. |
| **Comment why** | PASS | Updated readiness comment and `.DESCRIPTION` state the blocked set and its purpose. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Executor PoshQC format exit 0 (cycle artifacts); reviewer idempotence check clean. |
| **Step 2: Analyze** | PASS | Reviewer direct PSSA 0 findings; executor PoshQC analyze exit 0. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | Reviewer direct Pester `-PassThru` with explicit exit branch: 105/105 (changed suites + epic gate). Executor: PoshQC test 1394/0 failures at post-remediation HEAD; direct repo-root Pester 54/54 on the orchestrator-state tree (`evidence/qa-gates/remediation1-phase2-pester-direct.md`). Note: `run_poshqc_test` executes the npx-cached published bundle, so both plans paired it with direct repo-root Pester runs that exercise the edited modules; a bare `Invoke-Pester` exits 0 even on failures, so direct runs use `-PassThru` with an explicit exit branch, and `-CI` is avoided because it would overwrite the tracked repo-root `testResults.xml`. |
| **Rerun loop if needed** | PASS | Single pass; no restarts recorded or required. |

### Section 3C: TypeScript Code Change Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | `npx prettier --check <3 changed files>` → all files use Prettier style (reviewer, this session). |
| **Linting with ESLint** | PASS | `npx eslint <3 changed files>` → exit 0, no output (reviewer, this session). No new suppressions in the branch diff. |
| **Type checking with TSC** | PASS | `npx tsc --noEmit` → exit 0 (reviewer, this session). |
| **Testing** | PASS | Full Jest suite: 168 suites / 2035 tests passed, exit 0 (reviewer full re-run this session with `--testMatch "**/test/**/*.test.ts"` — see Section 7 environmental note); targeted run on the 3 orchestrator-state-core suites: 34/34. |

#### 3C.2 TypeScript Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing / no assertions** | PASS | `ReadonlyMap<string, ReadonlySet<string>>`; `COMPLETION_BLOCKING_STEP_STATUS: ReadonlySet<unknown>` documented as deliberate raw-value semantics; no `as X` assertions added. |
| **Byte-identical error strings** | PASS | `Checkpoint has invalid ${key}: ${String(value)}` (line 357) and `Checkpoint completion validation failed: ${key} is ${String(value)}.` (line 405) match the Python forms byte-for-byte for string values; source re-inspected this session; Jest literal-string assertions green. |
| **Separation of concerns** | PASS | Pure validation module; no host-bound APIs touched. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest; no alternative runners** | PASS | All new tests are pytest functions; `pytest.mark.parametrize` for matrices; reviewer targeted run 94/94. |
| **Coverage expectation** | PASS | New file 100%/100%; repo-wide 91.00%/81.84% (>= 85/75). |
| **Focused tests, sparing mocks, mirrored organization** | PASS | One behavior per test; zero mocks; `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`; the new step-status suite is a sibling file keeping the 735-line legacy file untouched. |
| **Naming and docstrings** | PASS | `test_<behavior>` names; module and per-test docstrings. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x with PoshQC configuration** | PASS | Pester v5.6.1; PoshQC gates run by executor in both cycles; direct repo-root Pester paired per plan. |
| **Focused tests; behavior over implementation** | PASS | The remediation case asserts the public entry point's ExitCode and emitted string, and the accompanying plain-mode acceptance case (`accepts step6_status value blocked_remediation_loop_limit`, line 367) pins the no-regression requirement. |
| **File naming and structure** | PASS | `.Tests.ps1` suffix; `Describe`/`Context`/`It`; `tests/scripts/claude-lib/**` mirrors `.claude/lib/**`. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | PASS | Jest (ts-jest), the extension's established framework. The `.claude/rules/typescript.md` Vitest naming remains a pre-existing repo-level inconsistency (recorded as Info in the code review; rule files must not be modified by this branch). |
| **Test location** | PASS | `extensions/drm-copilot/test/lib/validate/` mirrors `src/lib/validate/`. |
| **Determinism** | PASS | No timers, `Date.now`, or randomness in changed tests. |
| **Byte-identity assertions** | PASS | Literal-string assertions on the ported message forms; 34/34 targeted, 2035/2035 full. |

---

## 5. Test Coverage Detail

### `scripts/dev_tools/_orchestrator_state_step_status.py` (new)

**Coverage:** 100% lines (24/24), 100% branches (10/10). Owning-key acceptance (4 params), non-owning-key rejection matrix (20 params), completion blocklist cases, `passed` non-blocking, absent-key default. **Not covered:** None.

### `scripts/dev_tools/validate_orchestrator_state.py` (modified)

**Coverage:** 97.50% lines (156/160), 92.86% branches (78/84). Changed lines fully covered; the unmodified 735-line legacy suite pins that no previously valid checkpoint is newly rejected in plain mode.

### `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` (modified)

**Coverage:** 100% lines (19/19), 100% branches (10/10). New blocklist entry pinned by `test_pr_creation_readiness_rejects_step6_blocked_remediation_loop_limit`.

### `scripts/dev_tools/compute_complexity_floor.py` (modified)

**Coverage:** 100% lines (16/16), 100% branches (2/2). Truth table plus static parity assertion against the live config.

### `.claude/lib/orchestrator-state/OrchestratorState.psm1` (modified in both cycles)

**Coverage:** 97.17% lines (103/106), 96.67% commands (145/150) post-remediation — up from 96.64% commands; the one command added by the remediation membership test is covered by the new Pester case (`remediation1-coverage-comparison.md`, independently consistent with `artifacts/pester/powershell-coverage.xml`). Per-key acceptance/rejection cases plus the readiness rejection/acceptance pair added in remediation cycle 1.

### `.claude/lib/model-routing/ModelRouting.psm1` (modified)

**Coverage:** 100% lines (46/46), 100% commands (51/51). Truth-table cases plus two parity `It` blocks pinning `$script:FLOOR_SIGNAL_NAMES` to the config.

### `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` (modified)

**Coverage:** 98.45% lines (446/453), 94.52% branches (69/73); per-file `coverageThreshold` (85/75) enforced by the unchanged `jest.config.cjs`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (all languages, at post-remediation HEAD) | 2123 (pytest) + 1394 (Pester full) + 2035 (Jest) = 5552 | PASS |
| Tests Passed | 5552 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | pytest full 2123 tests (executor); Jest full 5.75s (reviewer); Pester full 66.2s (junit artifact); reviewer direct Pester 3.14s (105 tests) | PASS Fast |
| Net new/modified test cases on branch | +39 pytest, +38 Pester (37 main + 1 remediation), +4 Jest | PASS |
| Coverage | Py 91.00%/81.84%; PS 90.26% line / 89.73% commands; TS 96.34%/89.22% | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <8 changed files>` | 8 files unchanged, exit 0 | PASS |
| Ruff Linting | `poetry run ruff check <8 changed files>` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright <4 changed prod files>` | 0 errors, 0 warnings | PASS |
| Pytest Tests | Executor full (`remediation1-pytest-guard.md`): 2123 passed; reviewer targeted 94/94 | exit 0 | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter idempotence | `Invoke-Formatter -ScriptDefinition <content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` on all 7 changed files | content identical for all 7 | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Path <each> -Settings <pssa settings> -Severity Error, Warning, Information` | 0 findings on all 7 files | PASS |
| Pester Tests | Direct `Invoke-Pester` (`-PassThru`, explicit exit branch) on changed suites + epic gate suite | 105/105 passed, exit 0 | PASS |
| Full PoshQC test | Executor `mcp__drm-copilot__run_poshqc_test` at post-remediation HEAD | 1394 tests, 0 failures, exit 0 | PASS |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check <3 changed files>` | All matched files use Prettier style | PASS |
| ESLint | `npx eslint <3 changed files>` | exit 0 | PASS |
| TSC | `npx tsc --noEmit` | exit 0 | PASS |
| Jest (full) | `npx jest --testMatch "**/test/**/*.test.ts"` | 168 suites / 2035 tests passed, exit 0 | PASS |

**Behavioral probe matrix (reviewer, this session):**

| Probe | Result |
|---|---|
| PS `Test-OrchestratorStatePrCreationReadiness` on step6 halted-loop checkpoint (root module) | ExitCode 1; output exactly `Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.`; no base-presence error (plain-valid preserved) |
| Same probe on the resources byte mirror | Identical ExitCode and output |
| PY `validate_orchestrator_state_pr_creation_readiness` on the same checkpoint | `['Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.']` — byte-identical to PS |
| PS readiness with step6 `pending` / `blocked` / `completed` | ExitCode 1 / 1 / 0 with correct messages |
| PY plain validation of the halted-loop checkpoint | `[]` (accepted) |
| PY plain acceptance of step9 `passed` / `failed_remediation_required` / `blocked_ci_loop_limit`; rejection of `step5_status: passed` | `[]` / `[]` / `[]`; `['Checkpoint has invalid step5_status: passed']` |
| PY completion gate blocks the three failure values; `passed` produces zero step9 errors | Confirmed |
| PY and PS floor truth table (7 cases: empty, 3 non-floor, unknown, floor, mixed) | Identical outputs `C1 C1 C1 C1 C1 C3 C3` |
| Shared `VALID_STEP_STATUS` (PY re-export) | Exactly the 8 legacy values |

**Notes (pre-existing / environmental, not defects of this branch):**
1. **Jest discovery under dot-directory worktree.** This worktree sits under `.claude/`, so the configured `testMatch: ["<rootDir>/test/**/*.test.ts"]` matches nothing and the plain invocation exits 1 with `No tests found`. The `--testMatch "**/test/**/*.test.ts"` override discovers all 168 suites and the suite passes. `jest.config.cjs` was deliberately not modified; CI checkouts are not under a dot-directory. The TypeScript test gate is judged on the override run.
2. **`npm audit`** fails repo-wide on the pre-existing `brace-expansion` advisory GHSA-mh99-v99m-4gvg; owned by a separate effort, associated CI jobs are not required checks, unrelated to this branch.
3. **`mcp__drm-copilot__run_poshqc_test`** executes the npx-cached published bundle rather than the working tree; both plans therefore paired it with direct repo-root Pester runs that exercise the edited `.claude/lib` modules. Both were run and both recorded.
4. **PoshQC baseline test-count drift.** The remediation baseline observed 1393 tests where the main plan recorded 1391 (0 failures either way, before any edit), attributed to the published-bundle execution path. Post-change is 1394, exactly +1 for the one added test.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **None blocking.** The prior audit's identified gap (PowerShell portable PR-creation-readiness gate not extended; prior code-review CR-1, elevated to Blocking F-1 by the orchestrator for remediation cycle 1) is **closed and independently verified** by this re-audit: behavioral probe parity with the Python gate (byte-identical error string), plain-mode acceptance preserved, constants unchanged, mirrors byte-identical, dedicated Pester coverage added, and fail-before evidence recorded (`evidence/regression-testing/remediation1-fail-open-probe-before.md` / `remediation1-fail-open-probe-after.md`, `remediation1-new-test-expect-fail.md` / `remediation1-new-test-pass-after.md`).
- **Pre-existing 500-line violation in `tests/scripts/dev_tools/test_validate_orchestrator_state.py` (735 lines).** Zero diff on this branch; new cases were correctly placed in a new sibling file. Pre-existing, out of scope.

### Approved Exceptions

- **PowerShell branch coverage not measurable.** Pester 5 `CoverageGutters` output emits command/line counters only. Tooling limitation documented in the plan task text and both coverage-comparison artifacts; line coverage gate enforced instead. Not a threshold exception.
- **MCP tooling unavailable to this review session.** The policy-audit template structure follows the bundled assets at `extensions/drm-copilot/resources/templates/policy_audit/` (the same assets the MCP `resolve_policy_audit_template_asset` tool serves), and artifact validation used the equivalent Python CLI `python -m scripts.dev_tools.validate_orchestration_artifacts`. Documented assumption; content contract identical.

### Removed/Skipped Tests

**None.** No tests were removed or skipped by this branch in either cycle; the 9 disabled Pester tests in the junit artifact pre-date the branch.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **29f03d93** - docs(412): add research, spec, and atomic plan for orchestration-state-contract-divergences
2. **0b0354a5** - docs(412): apply preflight deltas to atomic plan and correct spec test-runner facts
3. **beba5606** - fix(412): align Python step-status vocabulary and complexity-floor semantics
4. **ab8a6370** - fix(412): mirror step-status and complexity-floor semantics in PowerShell modules
5. **ce8e6b6d** - fix(412): port per-step-key status vocabulary to the MCP TypeScript validator
6. **81f3df3f** - docs(412): record Phase 6 full-repo QA evidence and close plan/spec
7. **bfb73c75** - fix(412): close PowerShell PR-creation readiness fail-open on remediation-loop halt (remediation cycle 1)

### Files Modified

1. **`scripts/dev_tools/_orchestrator_state_step_status.py`** (NEW) — per-key additive status map, completion blocklist, two pure error collectors.
2. **`scripts/dev_tools/validate_orchestrator_state.py`** (MODIFIED) — delegates step-status checks; shared `VALID_STEP_STATUS` literal unchanged (re-verified this session: literal present at lines 93–102 with the original 8 members; branch diff touches only its consumers); 500 → 495 lines.
3. **`scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`** (MODIFIED) — readiness blocklist widened to `{pending, blocked, blocked_remediation_loop_limit}`.
4. **`scripts/dev_tools/compute_complexity_floor.py`** (MODIFIED) — embedded `FLOOR_SIGNAL_NAMES` frozenset; intersection-based floor; docstrings updated; pure (0 file-I/O matches, re-verified).
5. **`.claude/lib/orchestrator-state/OrchestratorState.psm1`** + resources byte mirror (MODIFIED in both cycles) — `$script:STEP_SPECIFIC_EXTRA_STATUS` layered on unchanged `$script:VALID_STEP_STATUS` (main cycle); readiness blocklist extended with `blocked_remediation_loop_limit` and `.DESCRIPTION` corrected (remediation cycle); mirrors byte-identical (`cmp` exit 0, re-verified this session); 485 → 498 → 497 lines.
6. **`.claude/lib/model-routing/ModelRouting.psm1`** + resources byte mirror (MODIFIED) — `$script:FLOOR_SIGNAL_NAMES` intersection in `Get-ComplexityFloor`; mirrors byte-identical (re-verified). Untouched by remediation cycle 1.
7. **`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`** (MODIFIED) — per-key map, completion blocklist, `isValidStepStatus`; error strings byte-identical to Python. Untouched by remediation cycle 1.
8. Test files as listed under Code Under Test; 101 feature-doc/evidence files under the canonical feature folder (main plan + remediation cycle).

**Deliberately unchanged (verified zero diff against merge base this session):** `config/orchestration-routing.json` + bundled mirror, `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, `.claude/hooks/enforce-epic-merge-gate.ps1` (unmodified regression witness; its Pester suite re-run green by this reviewer inside the 105/105 run), `.claude/hooks/validate-orchestrator-output.ps1` (owned by issue #413 / PR #416; zero commits on this branch touch it), `extensions/drm-copilot/jest.config.cjs`, `.claude/settings.json`, both batch-budget hooks, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, `scripts/dev_tools/_orchestrator_state_complexity.py`, `testResults.xml`.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All policy gates pass at the post-remediation HEAD on a combination of executor evidence current at this HEAD and reviewer re-runs performed this session: formatting, linting, type checking, and tests are clean in a single pass for Python, PowerShell, and TypeScript; coverage meets the uniform thresholds repo-wide and on every changed file with no regression (including the remediation-cycle PowerShell comparison); file-size limits hold on every changed file (`OrchestratorState.psm1` back to 497/500); no suppressions were added; both mirror pairs are byte-identical; evidence locations are canonical; the deliberately-unchanged file set is verified untouched; and the single Blocking remediation finding (F-1 / prior CR-1) is confirmed closed by independent behavioral probes with byte-identical cross-language error strings.

**Fail-closed check:** no required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing for either cycle.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: research → spec → plan → remediation-inputs → remediation-plan chain complete with evidence
- ✅ Design Principles: minimal additive mechanism in both cycles
- ✅ Module & File Structure: all changed files under 500 lines
- ✅ Naming, Docs, Comments: remediation corrected the readiness `.DESCRIPTION` to match behavior
- ✅ Toolchain Execution: single clean pass, reviewer-re-verified at HEAD
- ✅ Summarize & Document: commits, spec, remediation records, evidence tree complete

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python: Tooling / Design & Typing / Error Handling all pass
- ✅ PowerShell: Tooling / Design & Safety / Structure & Naming / Toolchain all pass
- ✅ TypeScript: Tooling / Design / byte-identity contract all pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles, Coverage & Scenarios, Test Structure, External Dependencies, Policy Audit

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python, ✅ PowerShell, ✅ TypeScript (framework note recorded as Info)

---

### Metrics Summary

- ✅ 5552/5552 tests passing across three languages at the post-remediation HEAD
- ✅ Python 91.00% line / 81.84% branch (repo-wide); new file 100%/100%
- ✅ PowerShell 90.26% line / 89.73% commands (repo-wide); changed modules 97.17% and 100% lines
- ✅ TypeScript 96.34% line / 89.22% branch (repo-wide); changed file 98.45%/94.52%
- ✅ No coverage regression in any metric versus recorded baselines in either cycle
- ✅ All code quality checks passing; 0 analyzer findings; 0 new suppressions

---

### Recommendation

**Ready for merge** (Go), subject to the standard PR flow: the PR body must include the prepared divergence-2 backward-compatibility statement (`evidence/other/pr-body-backcompat-statement.md`) to satisfy the sole remaining acceptance criterion (spec AC #24, structurally satisfiable only at PR authoring). No remediation triggers remain: zero Blocking findings, zero Major findings, and the prior cycle's Blocking finding is confirmed closed.

---

## Appendix A: Test Inventory

Net new/changed test cases on this branch (full suites enumerated in framework outputs):

**Python:** owning-key acceptance and 20-triple non-owning rejection matrices, completion blocklist and `passed` non-blocking cases, absent-key default (`test_validate_orchestrator_state_step_status_extras.py`, new); `test_pr_creation_readiness_rejects_step6_blocked_remediation_loop_limit`; floor truth table plus `test_floor_signal_names_match_config_floor_true_entries` (static parity); `test_non_floor_only_assessment_with_floor_c1_accepted` / `..._c3_rejected` (compatibility pin).

**Pester:** per-key acceptance and non-owning rejection cases (`OrchestratorState.Tests.ps1`); readiness rejection of `blocked_remediation_loop_limit` with base-validation acceptance retained (remediation cycle 1, same file, lines 130–144 and 367–369); floor truth-table cases (`Get-ComplexityFloor.Tests.ps1`); `FLOOR_SIGNAL_NAMES` parity equality and exclusion cases (`ModelRouting.Parity.Tests.ps1`).

**Jest:** owning-key acceptance, non-owning rejection loop, completion failure-value rejection, `passed` non-blocking (`orchestrator-state-core.test.ts`, `orchestrator-state-core.completion.test.ts`).

---

## Appendix B: Toolchain Commands Reference

**For Python (run from repo root):**
```bash
poetry run black --check <changed .py files>
poetry run ruff check <changed .py files>
poetry run pyright scripts/dev_tools/validate_orchestrator_state.py scripts/dev_tools/_orchestrator_state_step_status.py scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py scripts/dev_tools/compute_complexity_floor.py
PYTHONPATH=. poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_step_status_extras.py tests/scripts/dev_tools/test_validate_orchestrator_state_pr_creation_readiness.py tests/scripts/dev_tools/test_compute_complexity_floor.py tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
```

**For PowerShell (run from repo root):**
```powershell
Invoke-ScriptAnalyzer -Path <each changed file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information
Invoke-Formatter -ScriptDefinition (Get-Content -Raw <file>) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1   # compared for idempotence
$conf = New-PesterConfiguration; $conf.Run.Path = @(<changed suites + epic gate suite>); $conf.Run.PassThru = $true; $result = Invoke-Pester -Configuration $conf; if ($result.FailedCount -gt 0) { exit 1 } else { exit 0 }
```

**For TypeScript (run from `extensions/drm-copilot/`):**
```bash
npx prettier --check src/lib/validate/orchestrator-state-core.ts test/lib/validate/orchestrator-state-core.test.ts test/lib/validate/orchestrator-state-core.completion.test.ts
npx eslint src/lib/validate/orchestrator-state-core.ts test/lib/validate/orchestrator-state-core.test.ts test/lib/validate/orchestrator-state-core.completion.test.ts
npx tsc --noEmit
npx jest --testMatch "**/test/**/*.test.ts"
# Note: the --testMatch override is required only in dot-directory worktrees (see Section 7 note 1).
```

**Review-infrastructure commands:**
```bash
git merge-base main HEAD                                   # 009808510363081d0db7684f7b555f2ded4b0b7c
git diff --name-only 81f3df3f..HEAD                        # remediation-cycle surface verification
PYTHONPATH=. poetry run python -m scripts.dev_tools.pr_context.collector --base main --head HEAD
PYTHONPATH=. poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
cmp .claude/lib/orchestrator-state/OrchestratorState.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1
cmp .claude/lib/model-routing/ModelRouting.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/model-routing/ModelRouting.psm1
PYTHONPATH=. poetry run python <behavioral probe scripts>  # readiness/completion/floor matrix; run from repo root to avoid stale installed-package imports
python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit <path>
```

---

**Audit Completed By:** feature-review agent (Claude Code), re-audit R4
**Audit Date:** 2026-07-25
**Policy Version:** Current (as of audit date)
