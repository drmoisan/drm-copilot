# Policy Compliance Audit: reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486) — Remediation Cycle 1 Reaudit

**Audit Date:** 2026-08-20
**Auditor:** feature-review agent (delegated session, cycle-1 reaudit)
**Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` @ `9e5c141d863f4255a32656d1d58233ae0a8d3255`
**Base:** `main` (merge-base `8092d391f50c44571145c73e161bbd1dafe0f035`, supplied by the caller and confirmed by regenerating the PR-context artifacts this session)
**Work mode:** `full-feature` (persisted `- Work Mode: full-feature` marker in `issue.md`)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, the backing file of the `template` selector served by the MCP resolver tool; this delegated session's tool set does not include the MCP server tools, so the asset was read directly from the bundled path. Instruction block removed per template guidance.
**Prior cycle:** cycle-1 audit artifacts timestamped `2026-08-20T14-09`; remediation delivered by commit `9e5c141d` per `remediation-plan.2026-08-20T14-09.md`.
**Clock note:** this session's host clock read `2026-08-20T16-10` at authoring time. Committed executor evidence from the remediation session carries timestamps up to `2026-08-20T20-12`; this is the same inter-session host-clock variance already documented in `plan-self-validation.2026-08-20T13-46.md`. Neither artifact set is backdated.

**Code Under Test:** 89 files changed vs merge-base (+8695/-21). Production code: `scripts/dev_tools/plan_gate_commands.py` (new), `scripts/dev_tools/plan_gate_discrimination.py` (new), `scripts/dev_tools/validate_orchestration_artifacts.py` (modified), `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` (new), `plan-gate-discrimination.ts` (new), `plan-gate-rules.ts` (new), `orchestration-artifacts.ts` (modified), `validate-orchestration-service-call.ts` (modified), `src/mcp-tools.ts` (modified), `src/repo-automation-service-contract.ts` (modified, type-only). Test code: 6 new Python test modules, 8 new TypeScript test modules. Config: `extensions/drm-copilot/jest.config.cjs` (additive per-file thresholds). Docs/rules: `.claude/rules/plan-acceptance-gates.md` (new), `.claude/skills/atomic-plan-contract/SKILL.md` (modified), both mirrored under `extensions/drm-copilot/resources/claude-customizations/` plus `pack-manifests/core.json`; feature folder docs, cycle-1 audit artifacts, remediation plan, and evidence.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 9 files | 4057 tests | PASS 4057 pass, 0 fail, 5 pre-existing skips | 93.70% lines, 84.62% branches (modified module) | 97.30% lines, 92.86% branches (modified module); 92.59% lines, 85.16% branches repo-wide (`scripts/`) | 98.21% lines, 90.54% branches (lowest new module) |
| TypeScript | 16 files | 2645 tests | PASS 2645 pass, 0 fail | 96.61% lines, 89.96% branches (repo-wide); 100.00% lines, 84.61% branches (`validate-orchestration-service-call.ts`) | 96.65% lines, 90.01% branches (repo-wide); 100.00% lines, 89.47% branches (`validate-orchestration-service-call.ts`) | 96.25% lines, 85.14% branches (lowest new module) |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-test.2026-08-20T11-35.md` (repo-wide 96.61% lines, 89.96% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (executor-produced at the branch head state, parsed this session: repo-wide 96.65% lines, 90.01% branches), consistent with `evidence/qa-gates/typescript-test-final.2026-08-20T20-03.md`
- PowerShell baseline coverage artifact: N/A — zero PowerShell files changed on this branch (`git diff --name-status 8092d391...9e5c141d` contains no `.ps1`/`.psm1` paths)
- PowerShell post-change coverage artifact: N/A — zero PowerShell files changed on this branch
- Per-language comparison summary: section 1.2.1 below

## Rejected Scope Narrowing

No scope-narrowing instruction was detected in the caller prompt. The caller supplied the full-branch baseline (`main` @ merge-base `8092d391`) and delegated scope, severity, and verdict determination to this audit. The audit scope is the full branch diff `8092d391..9e5c141d` against `main`.

One caller-statement discrepancy is recorded for completeness (not a scope narrowing): the caller stated that refreshed PR-context artifacts existed at `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`; both were absent at session start and were regenerated by this session with `python -m scripts.dev_tools.pr_context.collector --base main --head HEAD` before any review work.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no violations reported (this session).
- `git diff --name-only 8092d391...9e5c141d` contains zero paths under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (grep over the diff list returned no matches).
- All committed evidence artifacts, including the 18 added by the remediation commit, live under the canonical `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,remediation-baseline}/` tree. PASS.

## Executive Summary

This is the remediation-cycle-1 reaudit. The prior audit (`policy-audit.2026-08-20T14-09.md`) recorded two Blocking findings (R1 TypeScript changed-line coverage regression; R2 spec AC7 text defect and unreconciled check-offs) and two Minor findings (R3 uncovered added Python line; R4 absent combined three-failure-mode integration scenario). All four are verified closed by commit `9e5c141d`:

- **R1 closed.** `validate-orchestration-service-call.ts` is back at 100.00% lines and improved to 89.47% branches (baseline 84.61%); the new named test `throws the combined error-and-warning message when both channels are non-empty` covers the previously uncovered combined-path lines. Verified by parsing `extensions/drm-copilot/coverage/lcov.info` (zero `DA:<n>,0` entries for the file) and by the full jest run this session.
- **R2 closed.** `spec.md` now states the two-conjunct G5 severity rule in AC7 and the pre-declared-rule paragraph, carries the required deviation note (spec line 68) citing plan `[P5-T3]` and the measurement artifact, and AC7, DoD items, and plan tasks `[P12-T13]`/`[P12-T14]` are checked. `G5_SEVERITY`, the rule file, and the measurement artifact were not modified, per the cycle-1 constraints.
- **R3 closed.** The plan short-circuit in `_validate_from_args` is covered by `test_validate_from_args_returns_blocking_channel_only_for_plan`; the module's remaining four uncovered lines (72, 406, 408, 410) are the relocated baseline miss set (66, 314, 316, 318) — pre-existing, not changed-line misses.
- **R4 closed.** Combined G1+G5+G6 single-evaluation tests exist and pass in both runtimes (`test_combined_plan_produces_g1_g5_g6_findings_in_one_evaluation`; `produces one G1 Blocking finding and two Warnings (G5, G6) in a single combined-plan evaluation`), and spec seeded-condition item 2 is checked with those test names recorded.

All toolchain stages were re-run by this reviewer this session and pass cleanly in a single pass (section 2.5). Repo-wide coverage passes both uniform thresholds in both changed languages.

**One new Blocking finding (R5)** was established by this reaudit through direct probe execution: the Python runtime's G2/G3 coverage-argument path lacks the graceful-degradation guard. A repository seam that raises (for example, `git` absent from `PATH`, which makes `subprocess.run` raise `FileNotFoundError` irrespective of `allow_error=True`) escapes `evaluate_plan_gates` when the plan carries a path-separator `--cov` value, crashing the validation run. This violates the landed rule file's invariant ("No finding is produced and no exception escapes the evaluation entry point... A validation run must never fail because the repository could not be queried", `.claude/rules/plan-acceptance-gates.md` § Graceful degradation) and spec AC10, and it diverges from the TypeScript runtime, which wraps the same path in try/catch (`plan-gate-rules.ts:236-241`). One Minor advisory (M1) on non-zero-exit seam semantics is recorded in section 8.

Verdict: **PARTIALLY COMPLIANT — remediation required** (1 Blocking finding). See `remediation-inputs.2026-08-20T16-10.md`.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|---|---|---|
| Independence / isolation | PASS | New and remediation tests use in-memory plan strings, stub git adapters, and stub file readers; no shared mutable state. Full suites pass in one run (4057 py / 2645 ts, this session). |
| Fast execution | PASS | Python suite 7.57 s without coverage, 20.03 s with repo-wide coverage; TypeScript suite 5.21 s (this session). |
| Determinism | PASS | No wall-clock, RNG, timers, or network in the new tests; fixtures are constants. |
| Readability / AAA structure | PASS | Remediation tests follow the same AAA-with-docstring pattern as the cycle-1 set (verified by reading `test_plan_gate_discrimination_literals.py` and `validate-orchestration-service-call-plan-gates.test.ts`). |
| No external services | PASS | The git seam is stubbed in unit tests. |
| No temporary files in tests | PASS | Fixtures are in-memory strings; inspection of the remediation test additions found no tempfile use. |

### 1.2 Coverage and Scenarios

- The cycle-1 scenario gap (no combined three-failure-mode fixture) is closed: both runtimes now assert one G1 Blocking finding plus G5 and G6 Warnings from a single evaluation of one synthetic plan.
- New scenario gap (Blocking, R5): the graceful-degradation scenario "raising git adapter plus a path-separator `--cov` value" is untested in Python and fails when probed — the exception escapes `evaluate_plan_gates`. The existing Python degradation test (`test_failing_git_adapter_produces_no_findings`) drives only the grep-literal path, which is guarded; the coverage-cascade path is not. Details in section 8 and in `code-review.2026-08-20T16-10.md`.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.70% lines / 84.62% branches on the one pre-existing changed module (`scripts/dev_tools/validate_orchestration_artifacts.py`). Post-change: 97.30% lines / 92.86% branches on that module and 92.59% lines / 85.16% branches repo-wide over `scripts/` (measured this session with `--cov=scripts --cov-branch`). Change: +3.60 line points and +8.24 branch points on the modified module; new modules measure 100.00%/100.00% (`plan_gate_commands.py`) and 98.21%/90.54% (`plan_gate_discrimination.py`). New/changed-code coverage: 98.21% lines at the lowest new module. Disposition: PASS. Evidence: `artifacts/python/lcov.info` regenerated this session; `evidence/qa-gates/python-test-final.2026-08-20T19-56.md`.
- TypeScript: Baseline: 100.00% lines / 84.61% branches on `src/lib/validate/validate-orchestration-service-call.ts` and 96.61% lines / 89.96% branches repo-wide. Post-change: 100.00% lines / 89.47% branches on that file and 96.65% lines / 90.01% branches repo-wide. Change: the cycle-1 changed-line regression is resolved; both axes at or above baseline on every modified file. New/changed-code coverage: 96.25% lines / 85.14% branches at the lowest new module (`plan-gate-commands.ts`). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` parsed this session; `evidence/qa-gates/coverage-delta-remediation.2026-08-20T20-05.md`.

Per-language coverage verdicts (explicit, per feature-review scope rule): **Python coverage: PASS. TypeScript coverage: PASS. PowerShell: N/A (zero changed files). C#: N/A (zero changed files).**

### 1.3 Test Structure and Diagnostics

PASS. AAA sections and descriptive names throughout; parity tests assert exact expected strings so failures are self-diagnosing.

### 1.4 External Dependencies and Environment

PASS. No new dependencies; neither `pyproject.toml` nor `package.json` changed on this branch.

### 1.5 Policy Audit Requirement

PASS. This artifact. The executor evidence tree contains baseline, qa-gates, regression-testing, and remediation-baseline artifacts for every stage.

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. Cycle-1 Phase 0 policy reads recorded in `evidence/baseline/phase0-instructions-read.2026-08-20T11-26.md`; remediation Phase 0 reads recorded in `evidence/remediation-baseline/phase0-instructions-read.2026-08-20T19-23.md`; toolchain baselines captured for both languages before each cycle.

### 2.2 Design Principles

PASS. Extractor and rule evaluation are pure functions over text plus an injected repository seam; I/O is isolated behind the seam; severities are constants routed through a two-channel report. The remediation commit added tests and documentation only — zero production-code lines changed, matching the cycle-1 expectation that no production change was required.

### 2.3 Module & File Structure

PASS. All production and test files remain under the 500-line ceiling (largest: `validate_orchestration_artifacts.py` 495, `plan_gate_discrimination.py` 490, `plan-gate-rules.ts` 437, `test_validate_orchestration_artifacts_plan_gates.py` 442; verified by `wc -l` this session).

### 2.4 Naming, Docs, and Comments

PASS. Conventions observed; `G5_SEVERITY` carries the required source comment citing the measurement artifact in both runtimes.

### 2.5 After Making Changes - Toolchain Execution

All stages re-run by this reviewer in this session at head `9e5c141d` (commands in Appendix B):

| Stage | Python | TypeScript |
|---|---|---|
| 1. Formatting | PASS (`black --check`: 436 files unchanged) | PASS (`prettier --check`: all files clean) |
| 2. Linting | PASS (`ruff check --no-fix`: all checks passed) | PASS (`eslint`: exit 0, no output) |
| 3. Type checking | PASS (`pyright`: 0 errors) | PASS (`tsc --noEmit`: exit 0) |
| 4. Architecture-boundary tests | N/A — no repo-defined stage for `scripts/` | N/A — no dependency-cruiser config exists in `extensions/drm-copilot` |
| 5. Unit tests | PASS (4057 passed, 5 pre-existing skips) | PASS (193 suites, 2645 passed) |
| 6. Contract / schema checks | PASS — MCP input-schema property-key set asserted unchanged by named tests | same |
| 7. Integration tests | PASS — CLI end-to-end tests plus live CLI plan validation of both plan artifacts this session (remediation plan exit 0 clean; feature plan exit 0 with the two expected self-referential warnings from its own quoted fixture command) | service-call and MCP projection tests |

All applicable stages passed in a single pass with no auto-fixes.

### 2.6 Summarize and Document

PASS. `.claude/rules/plan-acceptance-gates.md` and `.claude/skills/atomic-plan-contract/SKILL.md` verified byte-identical to their `extensions/drm-copilot/resources/claude-customizations/` mirrors (`cmp` this session); `pack-manifests/core.json` lists the new rule file. The spec deviation note (R2) is recorded at spec line 68 with the plan-task and measurement-artifact citations required by the cycle-1 remediation inputs.

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

PASS. Black, Ruff, Pyright all clean (this session).

#### 3A.2 Python Design & Typing

PASS. New modules fully typed; Pyright passes with 0 errors; no new suppressions in the diff.

#### 3A.3 Python Error Handling

**FAIL (Blocking finding R5).** The graceful-degradation contract is implemented asymmetrically. `_evaluate_literal_rules` wraps the G5/G6 group in the specified broad guard, but `_evaluate_cov_value`'s G2/G3 tracked-tree lookups (`context.git.is_tracked_file` / `is_tracked_directory`, `plan_gate_discrimination.py:283-297`) run unguarded from `evaluate_plan_gates`. A raising seam therefore escapes the evaluation entry point. Reproduced this session with a minimal probe: a `PlanGateContext` whose git adapter raises `RuntimeError`, evaluated against a plan carrying `--cov=scripts/dev_tools`, propagated `RuntimeError` out of `evaluate_plan_gates`. The production adapter path is reachable: `SubprocessRunner.run` guards only non-zero exits via `allow_error=True`; `subprocess.run` itself raises `FileNotFoundError` when `git` is not on `PATH`, and that exception reaches the CLI `main`. The TypeScript runtime guards this exact path (`plan-gate-rules.ts` wraps `evaluateTrackedCovValue` in try/catch), so this is also a cross-runtime behavioral divergence. Violates `.claude/rules/plan-acceptance-gates.md` § Graceful degradation, spec AC10, and the fail-fast-versus-specified-degradation contract of this feature.

### Section 3B: TypeScript Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

PASS. Prettier, ESLint, TSC all clean (this session).

#### 3B.2 TypeScript Design & Safety

PASS. No `any` in the new modules; `warnings` is `ReadonlyArray<string>` and conditionally projected; the G2/G3 and G5/G6 paths are both guarded per the graceful-degradation contract.

#### 3B.3 Structure, Naming, and Comments

PASS.

#### 3B.4 Running the Toolchain

PASS. See 2.5.

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

PASS. Pytest; tests under `tests/scripts/dev_tools/` mirroring `scripts/dev_tools/`; no colocation.

#### 4A.2 Test Style and Structure

PASS for the delivered tests. Gap: no Python test drives a raising git adapter through the coverage-cascade path (see R5); the required test is enumerated in the remediation inputs.

#### 4A.3 Naming and Readability

PASS.

#### 4A.4 Running the Toolchain

PASS. 4057 passed / 5 pre-existing skips (identical skip set to baseline).

### Section 4B: TypeScript Unit Test Policy Compliance

#### 4B.1 Framework and Scope

PASS. Jest; tests under `extensions/drm-copilot/test/` mirroring `src/`.

#### 4B.2 Test Style and Structure

PASS. Parity fixture set shared verbatim with the Python side; apostrophe-bearing fixtures included; the R1 combined error-plus-warning test and the R4 combined-plan test are present and pass.

#### 4B.3 Naming and Readability

PASS.

#### 4B.4 Running the Toolchain

PASS. 193 suites / 2645 tests, exit 0, with the three per-file coverage thresholds active.

## 5. Test Coverage Detail

### Python modules (new + modified)

- `scripts/dev_tools/plan_gate_commands.py` — 100.00% lines (77/77), 100.00% branches (28/28). New file. PASS.
- `scripts/dev_tools/plan_gate_discrimination.py` — 98.21% lines (165/168), 90.54% branches (67/74). New file. PASS. The three uncovered lines (311, 350, 379) are guard exits and the unreached blocking arm of the warning-shipped G5 severity routing.
- `scripts/dev_tools/validate_orchestration_artifacts.py` — 97.30% lines (144/148), 92.86% branches (52/56). Modified file; both axes improved vs baseline (93.70/84.62). The R3 line (plan short-circuit in `_validate_from_args`) is now covered; the four remaining uncovered lines (72, 406, 408, 410) are the relocated baseline miss set. PASS.
- Repo-wide (`--cov=scripts`): 92.59% lines (13809/14914), 85.16% branches (4667/5480). PASS against the uniform 85/75 thresholds.

### TypeScript modules (new + modified)

- `src/lib/validate/plan-gate-commands.ts` — 96.25% lines, 85.14% branches. New. PASS.
- `src/lib/validate/plan-gate-discrimination.ts` — 100.00% lines, 97.92% branches. New. PASS.
- `src/lib/validate/plan-gate-rules.ts` — 97.71% lines, 89.55% branches. New. PASS.
- `src/lib/validate/orchestration-artifacts.ts` — 100.00% lines, 98.68% branches. Modified; no regression. PASS.
- `src/mcp-tools.ts` — 92.50% lines, 82.76% branches. Modified; both axes at or above baseline (92.45/82.14). PASS.
- `src/repo-automation-service-contract.ts` — 0% (type-only interface module; legitimate 0% executable-coverage case per `.claude/rules/general-unit-test.md`). PASS.
- `src/lib/validate/validate-orchestration-service-call.ts` — 100.00% lines, 89.47% branches; cycle-1 regression resolved, both axes at or above the pre-branch baseline (100.00/84.61). PASS (R1 closed).
- Repo-wide: 96.65% lines (42960/44447), 90.01% branches (6099/6776). PASS.

## 6. Test Execution Metrics

| Metric | Python | TypeScript |
|---|---|---|
| Tests run | 4062 (4057 passed, 5 skipped) | 2645 (all passed) |
| Suites | one pytest session | 193 |
| Duration (this session) | 7.57 s (20.03 s with repo-wide coverage) | 5.21 s |
| Exit code | 0 | 0 |
| Delta vs cycle-1 audit | +59 tests | +24 tests |

## 7. Code Quality Checks

- Formatting: PASS both languages (check-only, zero rewrites).
- Lint: PASS both languages, zero findings.
- Types: PASS both languages, zero errors.
- `jest.config.cjs` diff re-inspected against the Coverage Exclusion Policy: additive per-file `coverageThreshold` entries only; no `exclude`/`collectCoverageFrom` narrowing; no production path removed from the denominator; no threshold weakened by the remediation commit. PASS.
- Message-formatting prohibition (no `repr()`/`!r`/`pythonRepr` in gate messages): enforced by named tests in both runtimes; both pass. PASS.
- `modified-workflow-needs-green-run`: does not fire — the diff contains no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (grep over the diff list this session). N/A.
- Policy-document integrity: `.github/instructions/**` untouched; `.claude/hooks/validate-planner-output.ps1` untouched (AC12 re-verified against the diff list at the new merge-base). The remediation commit touched no rule, skill, or mirror file, per the cycle-1 "Do Not Do" constraints.
- Evidence locations: PASS (see "Evidence Location Compliance").
- Plan-artifact self-validation: `remediation-plan.2026-08-20T14-09.md` passes the Python CLI plan validator with zero findings (exit 0, this session), corroborating the executor's MCP-side run in `evidence/qa-gates/plan-self-validation.2026-08-20T20-10.md`.

## 8. Gaps and Exceptions

### Identified Gaps

1. **[Blocking, R5] Python graceful-degradation escape on the G2/G3 coverage path.** `_evaluate_cov_value` performs the G2/G3 tracked-tree lookups without the broad guard that the rule file mandates and that `_evaluate_literal_rules` applies to G5/G6. A raising repository seam (reachable in production when `subprocess.run` raises, for example `FileNotFoundError` for an absent `git` binary) escapes `evaluate_plan_gates` and crashes the validation run — exactly the outcome the landed contract prohibits ("A validation run must never fail because the repository could not be queried"). Reproduced this session by probe; the TypeScript runtime is unaffected because `plan-gate-rules.ts` wraps `evaluateTrackedCovValue` in try/catch. Consequences: spec AC10 is downgraded to PARTIAL in `feature-audit.2026-08-20T16-10.md`; a cross-runtime behavioral divergence exists for this input class. Remedy: mirror the TypeScript structure — extract the G2/G3 lookup block into a helper invoked inside the specified broad guard — plus one named Python test driving a raising adapter through a path-separator `--cov` value, and one parity-oriented assertion keeping the two runtimes aligned. See `remediation-inputs.2026-08-20T16-10.md`.
2. **[Minor, M1] Non-zero-exit seam semantics diverge from the rule prose in both runtimes, identically.** The rule file states that a seam reporting a non-zero exit causes G2, G3, G5, and G6 to be skipped with no finding. The shipped adapters instead translate every non-zero `git` exit into a negative answer (`[]`/`False`/empty), so a genuinely failed query (for example `git ls-files` failing outside a work tree, exit 128) flows onward and can produce a spurious G3 or G5 Warning rather than a skip. For `git grep` specifically, exit 1 is the ordinary no-match result, so exit-code-blind translation is partially correct by design; the conflation concerns fatal exits only. Both runtimes behave identically, findings stay on the Warning channel, and the never-fail intent is preserved, so this is advisory: either distinguish fatal exits (code > 1 for `git grep`; any non-zero for `ls-files`/`show`) in the adapters, or reconcile the rule-file prose to the shipped semantics in a later cycle.

### Approved Exceptions

- The cycle-1 approved exceptions stand: the [P12-T11] MCP-validation provenance chain, and the two expected self-referential `PLAN GATE WARNING` lines on the feature's own plan (from its quoted [P2-T2] fixture command).
- The remediation executor's MCP plan validation (`plan-self-validation.2026-08-20T20-10.md`) was run through a real stdio MCP session with the throwaway driver deleted afterward; accepted with the corroborating CLI re-run this session.

### Removed/Skipped Tests

None removed. The 5 Python skips are pre-existing parity-fixture skips, identical to baseline.

## 9. Summary of Changes

### Commits in This PR/Branch

Branch range `8092d391..9e5c141d`, 4 commits: `db702a8c` (planning artifacts), `04488789` (feature implementation), `8727feda` (interrupted-cycle state preservation), `9e5c141d` (cycle-1 remediation: tests and documentation reconciliation only). 89 files, +8695/-21.

### Files Modified

- Python production: 1 modified, 2 added; Python tests: 6 added (extended by the remediation commit).
- TypeScript production: 4 modified (one type-only), 3 added; TypeScript tests: 8 added (extended by the remediation commit); `jest.config.cjs` thresholds extended additively.
- Rules/skills: `.claude/rules/plan-acceptance-gates.md` added; `atomic-plan-contract/SKILL.md` extended; both mirrored byte-identically; `pack-manifests/core.json` updated.
- Feature docs: issue/spec/user-story/plan/research, cycle-1 audit artifacts (policy-audit, code-review, feature-audit, remediation-inputs, remediation-plan, all `2026-08-20T14-09`), and the evidence tree; promoted potential entry under `docs/features/potential/promoted/`.

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PASS. Toolchain fully green in a single pass; file-size ceiling respected; no new dependencies; I/O isolated behind seams.

#### Language-Specific Code Change Policy (Section 3)

PARTIAL. TypeScript: PASS. Python: FAIL on the error-handling/degradation contract (R5) — the specified degradation seam is absent from the G2/G3 path, so a seam failure crashes the run instead of degrading.

#### General Unit Test Policy (Section 1)

PASS with one scenario gap folded into R5 (the raising-seam-through-coverage-path scenario is untested in Python and currently fails).

#### Language-Specific Unit Test Policy (Section 4)

PASS for both languages' test conventions.

### Metrics Summary

- Python: 4057 tests pass; changed/new modules 97.30-100.00% lines, 90.54-100.00% branches; repo-wide 92.59% lines / 85.16% branches. Coverage verdict: PASS.
- TypeScript: 2645 tests pass; repo-wide 96.65% lines / 90.01% branches; changed/new modules 92.50-100.00% lines with zero regressions. Coverage verdict: PASS.
- PowerShell, C#: zero changed files; N/A.

### Recommendation

NO-GO for PR until the single Blocking finding (R5) is remediated: wrap the Python G2/G3 tracked-tree lookups in the specified graceful-degradation guard and add the named tests. The fix is small and bounded (one production edit mirroring the existing TypeScript structure, plus tests). The Minor advisory M1 does not block and may be deferred to a follow-up entry. See `remediation-inputs.2026-08-20T16-10.md`.

## Appendix A: Test Inventory

### Complete Test List

Python test modules for this feature (all under `tests/scripts/dev_tools/`):

- `test_plan_gate_commands.py` (extractor records, kinds, attribution window) — 235 lines
- `test_plan_gate_discrimination_cov.py` (G1-G4 classification table, dotted remedy) — 200 lines
- `test_plan_gate_discrimination_context.py` (repository seam, adapter argv, G2/G3 routing) — 252 lines
- `test_plan_gate_discrimination_literals.py` (G5/G6, checkability, placeholder guard, severity routing, raising-seam degradation on the literal path) — 347 lines
- `test_plan_gate_parity.py` (shared fixtures, severity-constant cross-check, no-repr assertions, task-regex equivalence) — 276 lines
- `test_validate_orchestration_artifacts_plan_gates.py` (structural-baseline byte identity, CLI stderr/exit contract, dispatch, warning channel, R3 direct-dispatch test, R4 combined-plan test) — 442 lines

TypeScript test modules for this feature (all under `extensions/drm-copilot/test/`):

- `lib/validate/plan-gate-commands.test.ts`, `plan-gate-discrimination-cov.test.ts`, `plan-gate-discrimination-literals.test.ts`, `plan-gate-parity.test.ts`, `plan-gate-repository.test.ts`, `orchestration-artifacts-plan-gates.test.ts` (includes the R4 combined-plan test), `validate-orchestration-service-call-plan-gates.test.ts` (includes the R1 combined error-and-warning test), `mcp-plan-gate-warning-projection.test.ts`

Full suites: 4057 Python tests, 2645 TypeScript tests, all passing this session at head `9e5c141d`.

## Appendix B: Toolchain Commands Reference

```bash
# Python (from worktree root)
poetry run black --check scripts tests                                   # exit 0, 436 files unchanged
poetry run ruff check --no-fix scripts tests                             # exit 0
poetry run pyright                                                       # exit 0, 0 errors
poetry run pytest -q                                                     # exit 0, 4057 passed / 5 skipped
poetry run pytest -q --cov=scripts --cov-branch --cov-report=term        # exit 0, repo-wide 92.59% lines / 85.16% branches
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts \
  plan docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T14-09.md \
  --workspace-root .                                                     # exit 0, zero findings
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts \
  plan docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md \
  --workspace-root .                                                     # exit 0, 2 expected self-referential warnings
python scripts/dev_tools/validate_evidence_locations.py --root .         # exit 0
python -m scripts.dev_tools.pr_context.collector --base main --head HEAD # regenerated PR-context artifacts

# TypeScript (from extensions/drm-copilot)
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"       # exit 0
npx eslint --no-error-on-unmatched-pattern src test                      # exit 0
npx tsc -p ./ --noEmit                                                   # exit 0
node run-jest.cjs                                                        # exit 0, 193 suites / 2645 tests
# Coverage inspected from the executor-produced extensions/drm-copilot/coverage/lcov.info
# (fresh at head state) rather than re-generated, per the feature-review coverage procedure.

# Mirror integrity (from worktree root)
cmp .claude/rules/plan-acceptance-gates.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md   # identical
cmp .claude/skills/atomic-plan-contract/SKILL.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md  # identical
```
