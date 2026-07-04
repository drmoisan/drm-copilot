# Policy Compliance Audit: F11 ts-command-runtime-cleanup (Epic #240, final feature)

**Audit Date:** 2026-06-26
**Code Under Test:** Full feature branch `feat/ts-port-command-runtime-cleanup-240` (head `8def2ad`) vs base `main` (merge-base `bbfbab94`). TypeScript (extension + MCP server) and Python (test removals/edits). 113 changed files; predominantly a deletion diff removing the bundled Python bridge.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 9 src/test files changed (1 new: `hello-message.ts` + test) | 1389 | PASS 1389 pass, 0 fail (116 suites) | line 96.62%/branch 88.29% (per coverage-delta.md) | line 96.62% / branch 88.29% | `hello-message.ts` 100%/100% |
| Python | 76 files changed (all deletions/edits of bundled-parity tests) | 1123 | PASS 1123 pass, 19 skipped, 0 fail | line 85.72% / branch 85.97% | line 85.72% / branch 85.97% | N/A (no new Python production code) |

### Coverage Evidence Checklist

- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (present, regenerated 2026-06-26T09-35 by reviewer)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (present, regenerated 2026-06-26T09-36 by reviewer)
- Per-language comparison summary: Section 1.2.1 below; feature evidence `evidence/qa-gates/coverage-delta.md`, `evidence/qa-gates/python-coverage-delta.md`

**Coverage verdict (both languages with changed files):** PASS for TypeScript and PASS for Python. No `N/A` used for either language.

---

## Executive Summary

F11 removes the dead Python bridge from the drm-copilot extension and the standalone MCP server. The `helloPython` command is ported in-process to `src/lib/hello-message.ts` (preserving the command ID and the `hello_python:ok\n` output contract); the `"python"` member is removed from `RuntimeKind` and `ScriptExecutionOptions.runtimeKind` (narrowed to `"powershell"`); the Python detection branch in `detectRuntime()` is removed; four dead Python option builders are deleted from `repo-automation-service-workflows.ts`; all bundled Python (`resources/templates/*.py`, `resources/scripts/dev_tools/**`) is deleted; `.vscodeignore` and the MCP-server `prepack` are updated to exclude Python; and the bundled-Python-parity Python tests are removed. PowerShell behavior, the canonical `scripts/dev_tools/**` source, and its `tests/scripts/dev_tools/**` source tests are retained.

The reviewer independently re-ran both test suites and confirmed they are green with the exact counts the executor reported (TS 116 suites/1389 tests; Python 1123 passed/19 skipped). All structural no-Python assertions return zero matches. Both coverage artifacts exist and meet the uniform line >= 85% / branch >= 75% thresholds.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`

**Language-specific policies evaluated:**
- PASS `typescript.md` + `typescript-suppressions.md` (toolchain is Jest per accepted divergence D1)
- PASS Python policy (no new Python production code; only test removal/surgical edits)
- N/A PowerShell, C#, Bash, JSON (no production changes in those languages; PowerShell resources and tests retained unmodified)

**Temporary artifacts cleanup:**
- PASS No temporary scripts created during this review; reviewer coverage runs regenerated existing canonical artifacts only.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | TS Jest suite (116 suites) and Python suite run order-independent; both re-run clean by reviewer. |
| Isolation | PASS | `hello-message.test.ts` targets `writeHelloMessage` alone using an in-memory FileSystem. |
| Fast Execution | PASS | TS suite 3.4s; Python suite 1.74s (reviewer-observed). |
| Determinism | PASS | `writeHelloMessage` is pure over an injected `FileSystem`; no clock/RNG/network in changed tests. |
| Readability & Maintainability | PASS | AAA structure; descriptive names in `hello-message.test.ts`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | `evidence/baseline/test-coverage-baseline.md`, `evidence/baseline/python-test-baseline.md`. |
| No Coverage Regression | PASS | TS `src` line 96.62%/branch 88.29% (>= baseline); Python byte-identical totals (removed tests target the bundled tree not in the `["src","scripts/dev_tools"]` denominator). |
| New Code Coverage | PASS | `src/lib/hello-message.ts` 100% line / 100% branch (reviewer-verified). |
| Comprehensive Coverage | PASS | helloPython in-process path covered; removed Python-spawn assertions repointed/removed per P1/P2 tasks. |
| Positive / Negative / Edge / Error flows | PASS | `hello-message.test.ts` asserts content, path normalization, returned record, ensureDir call. |
| Concurrency / State transitions | N/A | Not applicable to a single-write smoke command. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline line 96.62% / branch 88.29% -> Post-change line 96.62% / branch 88.29%. New-code (`hello-message.ts`) 100%/100%. Disposition: PASS. Evidence: `coverage/lcov.info`, `evidence/qa-gates/coverage-delta.md`, reviewer rerun.
- Python: Baseline line 85.72% / branch 85.97% -> Post-change line 85.72% / branch 85.97% (unchanged; removed tests not in coverage denominator). New/changed-code coverage: N/A (no new Python production code). Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/python-coverage-delta.md`, reviewer rerun (pytest TOTAL 83% combined; line 85.72%, branch 85.97% computed from 8620 stmts/1231 miss, 3080 branch/432 partial).

Note: pytest-cov's single "Cover" column reports the blended statement+branch figure (83%). The separated line coverage (85.72%) and branch coverage (85.97%) both meet thresholds; the audited metric is the separated pair, not the blended figure.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear Failure Messages | PASS | Jest matchers with explicit expected values in `hello-message.test.ts`. |
| Arrange-Act-Assert | PASS | New test follows AAA. |
| Document Intent | PASS | Descriptive test names. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid External Dependencies | PASS | In-memory FileSystem; no real fs/subprocess/temp files. |
| Use Mocks/Stubs | PASS | Injected FileSystem seam. |
| Environment Stability | PASS | No temp file creation; hermetic. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission Review | PASS | This audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | PASS | F11 plan `plans/F11-command-runtime-cleanup.plan.md`; spec AC-E3/AC-E4. |
| Read existing change plans | PASS | F11 plan + epic spec read by executor (phase0-instructions-read.md). |
| Document the plan | PASS | F11 plan with 7 phases and 13 ACs. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | PASS | `writeHelloMessage` is a small pure function; deletion of dead code reduces surface. |
| Reusability | PASS | Reuses F1 `FileSystem` interface; no re-port. |
| Extensibility | PASS | Keyword-style input object; injected seam. |
| Separation of concerns | PASS | Pure logic in `hello-message.ts`; host wiring in `extension.ts`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | PASS | New file single-responsibility. |
| Under 500 lines | PASS for F11-changed files | All F11-changed src/test files <= 500 (hello-message.ts 103; command-runtime.ts 424; extension.ts 433; support 136; workflows 133; args 55; resolve-prompts-service-call.ts 219; extension.test.ts 315; extension.integration.test.ts 437; hello-message.test.ts 116; mcp prepack.cjs 55). See Section 8 for two pre-existing >500 files NOT in the F11 diff. |
| Public vs internal | PASS | Exports are intentional and typed. |
| No circular dependencies | PASS | Typecheck passes; no new cross-layer imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | PASS | `writeHelloMessage`, `WriteHelloMessageInput/Result`. |
| Docs/docstrings | PASS | Full JSDoc on `hello-message.ts` (purpose/responsibilities/side-effects). |
| Comment why, not what | PASS | Comments explain POSIX normalization and byte-identical content rationale. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| 1. Formatting | PASS | `npm run format` EXIT 0 (`evidence/qa-gates/format-final.md`). |
| 2. Linting | PASS | `npm run lint` EXIT 0 (`evidence/qa-gates/lint-final.md`). |
| 3. Type checking | PASS | `npm run typecheck` EXIT 0 (`evidence/qa-gates/typecheck-final.md`); RuntimeKind narrowing left no `runtimeKind:"python"`. |
| 4. Testing | PASS | TS 1389 pass (reviewer rerun); Python 1123 pass/19 skip (reviewer rerun). |
| Full toolchain loop | PASS | Final QA loop recorded in P7 evidence. |
| Explicit reporting | PASS | This audit + Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | PASS | F11 plan + spec mirror update. |
| Design choices explained | PASS | helloPython port decision recorded in plan. |
| Update supporting documents | PASS | `extensions/drm-copilot/README.md` updated (Python-runtime claims removed). |
| Provide next steps | PASS | Epic completion recorded (`evidence/qa-gates/f11-acceptance.md`). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: TypeScript (applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Prettier format | PASS | `npm run format` EXIT 0. |
| ESLint lint | PASS | `npm run lint` EXIT 0; no new suppressions found. |
| TSC type-check | PASS | `npm run typecheck` EXIT 0. |
| Jest test | PASS | 1389 tests (D1: Jest is the real, CI-exercised toolchain; spec-accepted divergence from the Vitest text in `typescript.md`). |
| Strong typing / no `any` | PASS | `WriteHelloMessageInput/Result` typed; discriminated `tool: "hello_python"` literal. |
| ES modules | PASS | Import/export syntax. |
| Error handling | PASS | Non-zero command outcomes surfaced as thrown errors in resolve service call. |

### Section 3B: Python (applicable — test removals/edits only)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Testing with Pytest | PASS | 1123 pass / 19 skip (reviewer rerun); all `tests/scripts/dev_tools/**` source tests retained and green. |
| No source removed | PASS | `scripts/dev_tools/**` (91 .py) and `tests/scripts/dev_tools/**` (111 .py) retained; only bundled-parity tests removed/edited. |

No new Python production code; design/typing sections N/A.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| Test framework (Jest per D1) | PASS | `@jest/globals`, `jest.fn()`. |
| Coverage expectation | PASS | New code `hello-message.ts` 100%/100%; repo-wide `src` 96.62%/88.29%. |
| Focused unit tests | PASS | Single-behavior tests. |
| Organization | PASS | `test/lib/hello-message.test.ts` mirrors `src/lib/hello-message.ts`. |

### Section 4B: Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pytest | PASS | Reviewer rerun. |
| Coverage | PASS | line 85.72% / branch 85.97% repo-wide; no regression. |

---

## 5. Test Coverage Detail

### writeHelloMessage (hello-message.ts)
| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| writes artifacts/hello_python.txt with exact content | Positive | PASS |
| ensureDir called for artifacts parent | Positive | PASS |
| returns record with tool/workspaceRoot/summary/POSIX path | Positive | PASS |

**Coverage:** 100% line / 100% branch (reviewer-verified).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| TS Total Tests | 1389 (116 suites) | PASS |
| TS Passed | 1389 (100%) | PASS |
| TS Failed | 0 | PASS |
| TS Execution Time | 3.4s | PASS Fast |
| Python Total | 1142 (1123 pass, 19 skip) | PASS |
| Python Failed | 0 | PASS |
| Python Execution Time | 1.74s | PASS Fast |
| TS Code Coverage | 96.62% line, 88.29% branch | PASS |
| Python Code Coverage | 85.72% line, 85.97% branch | PASS |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| TS Format | `npm run format` | EXIT 0 | PASS |
| TS Lint | `npm run lint` | EXIT 0 | PASS |
| TS Typecheck | `npm run typecheck` | EXIT 0 | PASS |
| TS Test+Coverage | `node run-jest.cjs --coverage --collectCoverageFrom="src/**/*.ts"` | EXIT 0, 1389 pass | PASS |
| Python Test+Coverage | `poetry run pytest --cov --cov-branch` | EXIT 0, 1123 pass | PASS |

**Notes:** D1 accepted divergence — the `extensions/drm-copilot` package uses Jest, not Vitest as described in `.claude/rules/typescript.md`. This is a pre-existing, package-wide condition not introduced by F11; the runnable/CI-exercised toolchain is Jest. Recorded as policy-reconciliation, not an F11 blocker.

---

## Evidence Location Compliance

The branch diff was scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.

- `git diff --name-only bbfbab94..8def2ad | rg "artifacts/(baselines|qa|evidence|coverage)/"` returned zero matches.
- `scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (no violations).
- All F11 evidence is written under the canonical `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/<kind>/`.

No EVIDENCE_LOCATION_OVERRIDE_REJECTED conditions occurred during this review. The reviewer-regenerated coverage artifacts (`coverage/lcov.info`, `artifacts/python/lcov.info`) are tool-output coverage artifacts written by the test runners to their configured canonical paths (the SKILL coverage-artifact paths), not feature-evidence artifacts; they are gitignored and not committed.

**Verdict:** PASS — no evidence-location violations.

---

## Rejected Scope Narrowing

The caller framed the work as "Feature F11 (the final feature of epic #240)" and pointed at the F11 plan AC checklist. This did not attempt to narrow the audit to a plan/file subset or mark any language out of scope; the caller explicitly instructed "Determine scope yourself per the SKILL invariant" and to verify BOTH suites. No scope-narrowing instruction was detected. The audit was performed against the full branch diff (`bbfbab94..8def2ad`, 113 files) covering both TypeScript and Python.

---

## 8. Gaps and Exceptions

### Identified Gaps
- **Pre-existing files over the 500-line limit (NOT in the F11 diff):** `extensions/drm-copilot/src/workflow-command-arguments.ts` (663 lines) and `extensions/drm-copilot/test/extension.workflow-commands.test.ts` (774 lines). Both exist byte-identically at the merge base `bbfbab94` (663 and 774 lines respectively) and are unmodified by F11. They are pre-existing conditions outside this feature's change set; they are recorded here for visibility but are not F11 regressions or F11 blocking findings. Recommend a separate remediation item to split these files.
- **`user-story.md` absent:** Work mode is `full-feature`, whose AC sources are `spec.md` and `user-story.md`. `user-story.md` does not exist in the feature folder; the epic carries its user story inline in `spec.md` ("## User Story") and tracks ACs in `spec.md` plus per-feature plan checklists. AC evaluation used `spec.md` (epic ACs) and the F11 plan checklist as authoritative. This is an inventory observation, not a behavior gap.

### Approved Exceptions
- D1 (Jest vs Vitest): accepted, package-wide, pre-existing; recorded in `spec.md`.

### Removed/Skipped Tests
- Removed: 4 bundled-Python-parity test files (`test_validate_orchestration_artifacts_bundle_parity.py`, `test_resolve_hard_lock_prompt_mirror_parity.py`, `test_push_down_claude_bundled_parity.py`, `test_push_down_copilot_customizations_mirror_parity.py`) and the entire `tests/extensions/drm_copilot/resources/templates/**` bundled-wrapper test tree (10 test files + 3 `__init__.py`).
- Surgically edited: `test_push_down_copilot_customizations_helpers.py` (drops only the bundled-module test, per plan P5-T3), plus `test_push_down_claude_customizations.py` and `test_push_down_codex_and_agents_customizations.py` (each drops bundled-Python parity helpers/tests that referenced the now-deleted bundled tree). The latter two were NOT explicitly enumerated in plan tasks P5-T1..T5, which named only `test_push_down_copilot_customizations_helpers.py` for surgical edits. The edits are consistent with F11's intent (they remove tests that load the deleted bundled `resources/scripts/dev_tools/**`), retain all source-behavior and DATA-payload tests, and leave zero remaining bundled-Python references in `tests/` (verified). Justification: acceptable; reason: the bundled subjects no longer exist, so the parity tests could not run; impact: none (canonical source behavior remains covered by retained source tests). Recorded as a Minor scope-documentation observation in the code review.

---

## 9. Summary of Changes

113 files changed against `bbfbab94`. Highlights: new `src/lib/hello-message.ts` (+test); modified `command-runtime.ts`, `extension.ts`, `repo-automation-service-support.ts`, `repo-automation-service-workflows.ts`, `repo-automation-args.ts`, `resolve-prompts-service-call.ts` (comment-only), `.vscodeignore`, `README.md`; new `packages/mcp-server/prepack.cjs` + `package.json` prepack change; deletion of 13 bundled templates `.py`, the entire bundled `resources/scripts/dev_tools/**` tree, and bundled-parity Python tests.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT (PASS)

All toolchain stages pass; both languages with changed files have coverage artifacts present and above the uniform line >= 85% / branch >= 75% thresholds; both suites are green at the executor-reported counts (independently reproduced). No blocking findings. Two pre-existing >500-line files exist outside the F11 diff (documented, not F11 findings).

**Fail-closed reminder:** No required baseline, QA, coverage, or comparison artifact is missing; PASS is warranted.

### Metrics Summary
- PASS 1389/1389 TS tests passing (100%)
- PASS 1123 Python tests passing, 19 skipped, 0 failed
- PASS 96.62% TS line / 88.29% branch; 85.72% Python line / 85.97% branch
- PASS `hello-message.ts` new code 100%/100%
- PASS zero `runtimeKind:"python"` in src/test; zero `.py` under `resources/`
- PASS all F11-changed files <= 500 lines

### Recommendation

**Ready for merge.** No remediation triggered by policy audit. The two pre-existing >500-line files should be addressed in a separate, non-blocking follow-up.

---

## Appendix B: Toolchain Commands Reference

**TypeScript (from `extensions/drm-copilot/`):**
```bash
npm run format
npm run lint
npm run typecheck
node run-jest.cjs --coverage --collectCoverageFrom="src/**/*.ts"
```

**Python (from repo root):**
```bash
poetry run pytest -q
poetry run pytest --cov --cov-branch --cov-report=term
```

**No-Python / structural audit:**
```bash
rg -n 'runtimeKind: *"python"|detectRuntime\("python"\)' extensions/drm-copilot/src extensions/drm-copilot/test   # zero
rg --files extensions/drm-copilot/resources -g '*.py'                                                              # zero
rg -n "extensions/drm-copilot/resources/scripts|extensions/drm-copilot/resources/templates/.*\.py" tests          # zero
scripts/dev_tools/validate_evidence_locations.py --root .                                                          # exit 0
```

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-06-26
**Policy Version:** Current (as of audit date)
