# Policy Compliance Audit: parallel model routing admitted-item source and absent-band test (#843)

**Audit Date:** 2026-10-09
**Audit mode:** minor-audit (reduced artifact set)
**Base:** `origin/main` (`git diff origin/main...HEAD`); **Head:** `755537bc3d9cfa5a4efcb085a9bc4ed0afc529b1`
**Operator decision recorded:** Option A accepted for #843.
**Code Under Test:** Three Markdown runtime surfaces and three bundled mirrors (`.claude/agents/parallel-orchestrator.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`), plus three test files: `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py`, `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py`, `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts`. 63 files changed in total (1743 insertions, 0 deletions), including feature documentation and evidence.
**Blocking findings:** 0

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files (test files only) | 31 routing tests (29 + 2); AC-8 suite 109 | PASS, 0 fail | `_parallel_planner_state_routing.py` 100.0% lines, 100.0% branches | `_parallel_planner_state_routing.py` 100.0% lines, 100.0% branches (50 stmts, 16 branches, 0 missed) | N/A (0 production lines changed) |
| TypeScript | 1 file (test file only) | Routing file 24 tests (22 + 2); full run 3919 | PASS, 0 fail | `parallel-planner-state-routing.ts` 100% lines, 92.59% branches (25/27) | `parallel-planner-state-routing.ts` 100% lines, 100% branches (27/27) | N/A (0 production lines changed) |
| PowerShell | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |
| Markdown | 6 runtime files plus feature docs | N/A | validated by contract tests | N/A (not a coverage language) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `evidence/baseline/baseline-jest-coverage.2026-10-09T20-11.md`, `evidence/baseline/baseline-ts-coverage-readout.2026-10-09T20-11.md`
- TypeScript post-change coverage artifact: `evidence/qa-gates/final-jest-coverage.2026-10-09T20-20.md`, `evidence/qa-gates/final-ts-coverage-readout.2026-10-09T20-20.md`
- PowerShell baseline coverage artifact: N/A - out of scope (0 changed PowerShell files)
- PowerShell post-change coverage artifact: N/A - out of scope (0 changed PowerShell files)
- Per-language comparison summary: `evidence/qa-gates/coverage-comparison.2026-10-09T20-22.md` and section 1.2.1 below

Python coverage artifacts: `evidence/baseline/baseline-python-coverage-percentages.2026-10-09T20-11.md` (baseline) and `evidence/qa-gates/final-python-coverage-percentages.2026-10-09T20-20.md`, `evidence/qa-gates/final-python-coverage-thresholds.2026-10-09T20-20.md` (post-change).

---

## Executive Summary

The branch adds Markdown contract text and tests only. It names the orchestrator checkpoint as the band source for `/parallel-add` items in three runtime surfaces (with byte-identical bundled mirrors), adds four contract tests, and adds a band-only and a receipt-band-only deletion case to the Python and TypeScript routing validator tests. No production Python or TypeScript file changed (`git diff --name-only origin/main...HEAD -- scripts extensions/drm-copilot/src` is empty). Python and TypeScript have changed files (test files only); PowerShell and C# have zero changed files. For the affected production modules, Python coverage stays at 100.0% line / 100.0% branch and TypeScript branch coverage rises from 92.59% (25/27) to 100% (27/27). The Python (Black, Ruff, Pyright) and TypeScript (Prettier, ESLint, `tsc`) gates exit 0, and the seven-stage loop completed a clean pass 3 after two earlier repaired formatting failures. No policy violation was found.

**Policy documents evaluated:**
- Reviewed: `general-code-change.md` (simplicity, 500-line limit, I/O isolation, naming)
- Reviewed: `general-unit-test.md` (Arrange-Act-Assert, determinism, no temporary files, file location)
- Reviewed: `quality-tiers.md` (uniform gate matrix)
- Reviewed: `tonality.md` (added Markdown and docstrings)

**Language-specific policies evaluated:**
- Python: toolchain and test conventions reviewed (test files only)
- TypeScript: toolchain and test conventions reviewed (test file only)
- PowerShell, C#: N/A, 0 changed files

**Temporary artifacts cleanup:**
- No temporary scripts or files appear in the branch diff.

## Rejected Scope Narrowing

None. The caller prompt requested the full branch diff against `origin/main` and a reduced (minor-audit) artifact set; no narrowing of scope, language coverage, or toolchain checks was requested. The reduced-audit handoff note (`evidence/other/reduced-audit-handoff.2026-10-09T20-22.md`) was treated as evidence input, not as a scope limit.

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` re-run in this audit: exit code 0, no violations.
- The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence sits under `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred (no non-canonical path was supplied).

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert structure | PASS | New Python cases carry Arrange/Act/Assert comments; TS cases are structured the same |
| Determinism, no clocks or sleeps | PASS | No clocks, sleeps, or randomness in new tests |
| No temporary files, no external dependencies | PASS | Tests read repository Markdown only |
| Test file location mirrors source | PASS | New tests are in existing mirrored files under `tests/` and `extensions/drm-copilot/test/`; no colocated tests |
| Independence and isolation | PASS | Each case builds its own routing fields and mutates a fresh record |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | Python module 100.0% line / 100.0% branch; TS module 100% line / 92.59% branch (`evidence/baseline/baseline-python-coverage-percentages.2026-10-09T20-11.md`, `baseline-ts-coverage-readout.2026-10-09T20-11.md`) |
| No Coverage Regression | PASS | Python unchanged at 100.0% / 100.0%; TS branch rose 92.59% to 100% (`evidence/qa-gates/coverage-comparison.2026-10-09T20-22.md`, `Verdict: PASS`) |
| New/Modified File Coverage | N/A | No production file added or modified; changed files are tests |
| Scenario completeness | PASS | Absent-band (AC-6) and receipt-band-only (AC-7) negative cases added in both runtimes |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: `_parallel_planner_state_routing.py` 100.0% lines / 100.0% branches -> Post-change: 100.0% lines / 100.0% branches (50 statements, 16 branches, 0 missed). Change: 0. New/changed-code coverage: N/A, 0 production lines changed (changed files are tests). Disposition: PASS (at or above 85% lines and 75% branches, no regression). Evidence: `evidence/qa-gates/final-python-coverage-percentages.2026-10-09T20-20.md` and `evidence/qa-gates/coverage-comparison.2026-10-09T20-22.md`.
- TypeScript: Baseline: `parallel-planner-state-routing.ts` 100% lines / 92.59% branches (25/27) -> Post-change: 100% lines / 100% branches (27/27). Change: branches +7.41 percentage points, lines 0. New/changed-code coverage: N/A, 0 production lines changed (changed file is a test). Disposition: PASS (at or above 85% lines and 75% branches, no regression). Evidence: `evidence/qa-gates/final-ts-coverage-readout.2026-10-09T20-20.md` and `evidence/qa-gates/coverage-comparison.2026-10-09T20-22.md`.
- PowerShell: Baseline: N/A, 0 changed files -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A. Disposition: N/A (out of scope, 0 changed PowerShell files). Evidence: `evidence/qa-gates/scope-boundary.2026-10-09T20-22.md`.
- C#: Baseline: N/A, 0 changed files -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A. Disposition: N/A (out of scope, 0 changed C# files). Evidence: `evidence/qa-gates/scope-boundary.2026-10-09T20-22.md`.
- Coverage artifact note: Python `artifacts/python/lcov.info` is present, with a module-level report `artifacts/python/routing-coverage-843.json`. TypeScript `coverage/lcov.info` is absent because AC-8 prescribes only the `text` and `json-summary` reporters; the figures come from `extensions/drm-copilot/coverage/coverage-summary.json`. Repo-wide per-language percentages were not independently recomputed; the full Jest run reported 256 suites and 3919 tests passing with no threshold message (`final-jest-coverage.2026-10-09T20-20.md`), which implies the configured repo-wide thresholds held. This review did not rerun coverage generation.

### 1.3-1.5 Diagnostics, Dependencies, Audit Requirement

Assertions use exact literals and produce actionable failure output. No external service dependency or temporary file was introduced. This audit serves as the pre-submission review.

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity, reuse, naming | PASS | Test-only additions reuse existing builders (`build_routing_fields`, `buildPlannerRoutingFields`) and helpers (`nested`, `between`, `section`, `collapse`); descriptive names |
| Under 500 lines | PASS | `test_validate_parallel_planner_state_routing.py` 494 lines (re-measured), `test_parallel_complexity_routing_contracts.py` 264, `parallel-planner-state-routing.test.ts` 313; `parallel-orchestrate/SKILL.md` is 1192 lines but Markdown is exempt (Non-blocking CR-2: 6 lines of headroom) |
| Tone policy in added Markdown and docs | PASS | Factual and neutral; no humor or hyperbole found in the diff |
| Scope containment | PASS | No change under `scripts/`, `extensions/drm-copilot/src/`, `config/`, `.github/` (`evidence/qa-gates/scope-boundary.2026-10-09T20-22.md`) |
| Mirror parity (AC-4) | PASS | `cmp` re-run in this audit: all three source/mirror pairs byte-identical; `final-mirror-parity.2026-10-09T20-20.md` EXIT_CODE 0 |
| Permission-contract rule (no backticked lowercase-led command) | PASS | `test_every_prescribed_command_invocation_has_a_persona_bash_grant` PASSED in `final-pytest-ac8-suite.2026-10-09T20-20.md` |
| Coverage exclusion policy | PASS | No `exclude` entry added; no config file in the diff |
| Suppressions | PASS | No `# type: ignore`, `noqa`, `eslint-disable`, or `ts-ignore` added (diff inspected) |
| Dependencies | PASS | None added |

### 2.5 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting (Black, Prettier) | PASS | `final-black-check.2026-10-09T20-20.md`, `final-ts-prettier-check.2026-10-09T20-20.md` EXIT_CODE 0; earlier failures were repaired and the loop restarted |
| Linting (Ruff, ESLint) | PASS | `final-ruff.2026-10-09T20-20.md`, `final-ts-lint.2026-10-09T20-20.md` EXIT_CODE 0 |
| Type checking (Pyright, `tsc`) | PASS | `final-pyright.2026-10-09T20-20.md` (0 errors), `final-ts-typecheck.2026-10-09T20-20.md` EXIT_CODE 0 |
| Architecture / contract / integration | N/A | No applicable tool for a test-and-Markdown change; `final-pytest-related.2026-10-09T20-20.md` (97 passed, bundle-parity node PASSED) covers the contract surface |
| Unit tests | PASS | Python routing 31 passed, AC-8 suite 109 passed, related suite 97 passed; Jest 256 suites / 3919 tests passed |
| Seven-stage loop single clean pass | PASS | `evidence/qa-gates/final-loop-single-pass.2026-10-09T20-22.md` records pass 3 with no file changed |

---

## 3. Language-Specific Code Change Policy Compliance

- Python (`.claude/rules/python.md`): only test files changed; Black, Ruff, and Pyright pass; no suppressions added.
- TypeScript (`.claude/rules/typescript.md`): only a test file changed; Prettier, ESLint, and `tsc` pass; no suppressions or `any` added.
- Markdown: additions-only diff, no headings added, mirrors byte-identical.
- PowerShell, C#: 0 changed files. N/A.

## 4. Language-Specific Unit Test Policy Compliance

- Python: new cases in existing mirrored test files, Arrange-Act-Assert comments, module-level literal constants shared between cases, no temporary files.
- TypeScript: new cases mirror the Python cases in the existing Jest file under `extensions/drm-copilot/test/`; no fake-timer need arises because no time source is used.
- PowerShell, C#: N/A, 0 changed files.

## 5. Test Coverage Detail

No production function, class, or module was added or changed. For the production modules exercised by the new tests: `_parallel_planner_state_routing.py` stays at 100.0% line / 100.0% branch (50 statements, 16 branches, none missed); `parallel-planner-state-routing.ts` moves from 100% line / 92.59% branch (25/27) to 100% line / 100% branch (27/27), closing the `sameValue` arms noted in #532.

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Python routing suite | 31 passed (29 + 2) | PASS |
| AC-8 pytest suite | 109 passed (103 + 6) | PASS |
| Related pytest suite | 97 passed | PASS |
| Jest routing file | 24 passed (22 + 2) | PASS |
| Jest full suite | 256 suites, 3919 tests passed (3917 + 2) | PASS |
| Code coverage | Python module 100.0% / 100.0%; TS module 100% / 100% | PASS |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check` | EXIT_CODE 0 | PASS |
| Ruff | `poetry run ruff check` | EXIT_CODE 0 | PASS |
| Pyright | `poetry run pyright` | 0 errors | PASS |
| Prettier | `npx prettier --check` | EXIT_CODE 0 | PASS |
| ESLint | `npm run lint` | EXIT_CODE 0 | PASS |
| TypeScript | `npm run typecheck` | EXIT_CODE 0 | PASS |

**Notes:** Evidence file names are listed in section 2.5. Exact command lines are recorded inside each evidence artifact.

### Evidence and Timestamp Conventions

| Item | Verdict | Notes |
|---|---|---|
| One baseline and one final artifact per command; names carry `yyyy-MM-ddTHH-mm` | PASS | Baseline set (18 artifacts) and final set paired as listed in `evidence/other/reduced-audit-handoff.2026-10-09T20-22.md` |
| Four early Phase 1 artifacts carrying `TimestampNote:` | PASS (Non-blocking observation N-1) | `other/phase1-handoff.2026-10-09T20-15.md`, `regression-testing/contract-fail-before.2026-10-09T20-18.md`, `regression-testing/contract-pass-after.2026-10-09T20-22.md`, `other/mirror-parity.2026-10-09T20-22.md`. Each discloses that the filename label was entered before a clock read and that the actual time lies between 2026-10-09T20-11 and 2026-10-09T20-16. The disclosure is explicit and bounded and the content is unaffected; filename order no longer matches execution order for these four. The labels were not renamed because the evidence references them by name. |
| Supplementary Jest run with `--reporters=default` | PASS (Non-blocking observation N-2) | `qa-gates/final-jest-routing-file.2026-10-09T20-20.md` records the planned `--verbose` command (EXIT_CODE 0, 24 passed = 22 + 2) with `CommandSubstitution: none`, and a separately labelled supplementary command that supplied the two new test titles. The planned command was not replaced. |
| Expected-nonzero commands | PASS | The Python coverage-threshold probe with floor 101 is labelled `ExpectedExitCode: 1` in baseline and final artifacts, and a separate EXIT_CODE 0 threshold artifact exists (`final-python-coverage-thresholds.2026-10-09T20-20.md`) |
| Fail-before evidence | PASS | `contract-fail-before` records 4 failed / 7 passed before the Markdown edits; `fail-before-exception` documents why the AC-6/AC-7 cases cannot fail before (no production change), with proof of the alternative |

### AC Tracking Skill Compliance

AC source: `issue.md` `## Acceptance Criteria` (minor-audit). All eight items are checkbox format and all are already `[x]`. Each was individually verified in `feature-audit.2026-10-09T20-24.md`. No check-off change was required.

---

## 8. Gaps and Exceptions

### Identified Gaps
- Non-blocking N-1 and N-2 (timestamp labels, supplementary Jest run), described above and judged acceptable.
- Repo-wide per-language coverage percentages were not independently recomputed by this review; the per-module comparison and the Jest threshold outcome were relied on.
- Stages 4, 6, and 7 of the seven-stage loop (architecture, contract/schema, integration) have no applicable tool for a test-and-Markdown change.

### Approved Exceptions
**None.**

### Removed/Skipped Tests
**None.**

## 9. Summary of Changes

### Files Modified
1. `.claude/agents/parallel-orchestrator.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md` (MODIFIED): admitted-item band source, resolution, and stop-when-absent text; additions only.
2. Three mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/` (MODIFIED): byte-identical to their sources.
3. `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py` (MODIFIED): four contract tests.
4. `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py` and `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` (MODIFIED): band-only and receipt-band-only deletion cases.
5. Feature folder documentation, evidence, and promotion record (NEW).

Totals: 63 files changed, 1743 insertions, 0 deletions.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

All applicable policy checks are met for the changed Python and TypeScript test files and the Markdown surfaces. Coverage verdicts: Python PASS, TypeScript PASS; PowerShell and C# have zero changed files. Blocking findings: 0.

### Metrics Summary

- Python routing suite 31 passed; AC-8 suite 109 passed; related suite 97 passed
- Jest 256 suites / 3919 tests passed
- Python module coverage 100.0% line / 100.0% branch; TypeScript module coverage 100% line / 100% branch (baseline 92.59%)
- Evidence location scan clean
- Non-blocking observations: N-1 (timestamp labels on four Phase 1 artifacts), N-2 (supplementary Jest run)

### Recommendation

**Ready for PR creation.** No remediation inputs file is required.

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py`: four new contract tests (kickoff paragraph, `## Model Selection`, agent `## Delegation Model`, `parallel-add` step 2).
- `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py`: two new cases (band-only deletion, receipt-band-only deletion); file total 31 routing tests with the module under test.
- `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts`: two new cases mirroring the Python cases; file total 24 tests.

## Appendix B: Toolchain Commands Reference

Exact command lines are recorded in each evidence artifact. The tools run were:

```bash
poetry run black --check
poetry run ruff check
poetry run pyright
poetry run pytest
npx prettier --check
npm run lint
npm run typecheck
npx jest --coverage
cmp <source> <mirror>
poetry run python -m scripts.dev_tools.validate_evidence_locations --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-09
**Policy Version:** Current (as of audit date)
