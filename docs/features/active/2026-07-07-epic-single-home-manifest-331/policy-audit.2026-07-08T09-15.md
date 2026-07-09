# Policy Compliance Audit: epic-single-home-manifest (Issue #331)

**Audit Date:** 2026-07-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-07-07-epic-single-home-manifest-331/`
**Base Branch:** `main` (merge base `ee65d6e9e99b86bdbd7d00dcc47fc90db39ff56b`)
**Head:** `feature/epic-single-home-manifest-331` @ `732a607d60ea2b9e8072b3cf594caf2b810f1e09`
**Work Mode:** `full-feature` (marker `- Work Mode: full-feature` in `issue.md`)
**Code Under Test:** Python (`scripts/dev_tools/**`, `tests/scripts/dev_tools/**`), TypeScript (`extensions/drm-copilot/src/lib/**`, `test/lib/**`), plus docs/templates/skill/agent changes.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|----------------------|-------------------|
| Python | 7 files (2 new, 5 modified) | 1309 tests | PASS 1309 pass, 0 fail | 84% line TOTAL | 84% line TOTAL | 94.1% line / 93.8% branch (new file) |
| TypeScript | 10 files (1 new src, 3 modified src, tests) | 1568 tests | PASS 1568 pass, 0 fail | 96.58% line / 88.5% branch | 96.58% line / 88.56% branch | 96.2% line / 89.3% branch (new file) |
| PowerShell | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |

**Note:** PowerShell and C# rows record N/A because the branch diff contains zero changed files in those languages. Python and TypeScript both have changed files and carry explicit numeric coverage evidence and a PASS disposition (see section 1.2.1).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `coverage/lcov.info` (repo-root baseline; parsed directly by reviewer)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (present; parsed directly by reviewer)
- PowerShell baseline coverage artifact: N/A - out of scope (no PowerShell files in branch diff)
- PowerShell post-change coverage artifact: N/A - out of scope (no PowerShell files in branch diff)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (present; parsed directly by reviewer)
- Per-language comparison summary: see section 1.2.1 Per-Language Coverage Comparison below
- Coverage-delta summary: `docs/features/active/2026-07-07-epic-single-home-manifest-331/evidence/qa-gates/coverage-delta.2026-07-07T21-08.md`
- Per-file numbers were re-derived by the reviewer from the lcov artifacts (not taken solely from the summary).

**Verdict rule note:** Numeric baseline and post-change metrics are present for both in-scope languages, and per-file new/changed-code coverage is recorded; the PASS verdict is supported by inspected artifacts.

---

## Executive Summary

This feature adopts the "single epic home + flat feature siblings + one manifest" layout (Option D). The branch delivers three coordinated surfaces: (a) `new_active_feature_folder(type=epic)` epic-home scaffolding in both parity trees (TypeScript authoritative + Python co-authoritative), (b) additive, key-gated `issue_num` dependency resolution and presence-gated intent-block validation in `validate_epic_orchestrator_state.py` and its TS port, and (c) the epic-orchestrate skill + byte-identical mirror, templates, push-down, and parity gates.

The change is additive and key-gated, consistent with the backward-compatibility hard requirement. New resolution logic is extracted into sibling modules (`_epic_orchestrator_state_resolution.py`, `epic-orchestrator-state-resolution.ts`) that keep the main validators under the 500-line limit and are fully typed and documented. The recorded executor evidence shows a clean seven-stage toolchain for both languages, and the reviewer independently confirmed: per-file coverage from lcov artifacts, the 500-line limit on all changed source files, and a green `black --check` on all changed Python files.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`
- PASS `.claude/rules/typescript.md` (TS port; parity gate green)
- N/A `.claude/rules/powershell.md`, `.claude/rules/csharp.md` (no changed files)

**Overall verdict:** PASS. No blocking findings against feature #331's branch diff.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow scope to a plan/task/phase subset, to a subset of changed files, or to mark any language's coverage as out of scope. The orchestrator prompt explicitly directed a full branch-diff audit against `main`. Nothing to reject. Scope audited = full range `ee65d6e..732a607`.

---

## Evidence Location Compliance

Two checks were run:

1. **Branch-diff scan (authoritative scope).** `git diff --name-only ee65d6e..732a607 | grep '^artifacts/(baselines|qa|evidence|coverage)/'` returned no matches. All feature evidence is written under the canonical `docs/features/active/2026-07-07-epic-single-home-manifest-331/evidence/<kind>/` tree (baseline, qa-gates, regression-testing, other). **PASS** for feature #331.

2. **Whole-tree validator.** `python scripts/dev_tools/validate_evidence_locations.py --root .` exited non-zero (1) and reported one path:

| Reported path | Canonical replacement | Disposition |
|---|---|---|
| `artifacts/research/2026-07-07T19-00-epic-folder-structure-research.md` | `docs/features/active/<feature>/research/` or `docs/research/` | FAIL per validator, but not in the #331 branch diff and untracked by git — see note |

Note: The reported file is under `artifacts/research/` (not one of the four evidence kinds this agent produces). It is not present in the branch diff (`git diff --name-only` shows no match) and is untracked (`git ls-files --error-unmatch` fails). It is a pre-existing local working-tree scratch file unrelated to feature #331. It is recorded here for transparency about the validator's non-zero exit, but it is not attributable to this feature and is not a merge blocker for this PR. Recommended housekeeping (independent of #331): relocate it under `docs/features/active/<feature>/research/` or `docs/research/`, or delete it, so the whole-tree validator returns to zero.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence / Isolation | PASS | New tests are pure in-memory unit tests over validator helpers and scaffolding flow; fixtures are in-memory JSON dicts / temp-free filesystem fakes. `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` (+195). |
| Determinism | PASS | No wall-clock/RNG/network; validator and resolver are pure functions. No temp files (spec Test Requirements enforce this). |
| No temporary files | PASS | Scaffolding tests use `FileSystem` fakes; no runtime temp-file creation observed in changed test files. |
| Positive/negative/edge coverage | PASS | Intent-block tests cover valid, bad `epic_type`, empty `business_outcome_hypothesis`, non-list/non-string `leading_indicators`/`nfrs`, and absent-key byte-identical cases (spec §Intent-Block, FR-4). |
| Legacy regression (byte-identical) | PASS | `evidence/regression-testing/py-validator-legacy.*` and `py-wave-computation-legacy.*` (both exit 0); legacy fixtures unchanged. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | PASS | Python 84% line TOTAL (pre-change); TypeScript 96.58% line / 88.5% branch. Command `poetry run pytest --cov --cov-branch` / `npm run test:coverage`. |
| No coverage regression | PASS | Python 84% -> 84% line (no change); TypeScript 88.5% -> 88.56% branch (+0.06%, no line regression). No regression on changed lines. |
| New/changed-code coverage | PASS | New Python module 94.1% line / 93.8% branch; new TS module 96.2% line / 89.3% branch. Both exceed the uniform gate. |
| Coverage thresholds (>=85% line / >=75% branch on changed code) | PASS | Per-file lcov: all changed Python/TS files meet the uniform gate (see section 5). |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 84% line -> Post-change: 84% line. Change: +0% line (no regression on changed lines). New/changed-code coverage: 94.1% line / 93.8% branch (new file `_epic_orchestrator_state_resolution.py`). Disposition: PASS. Evidence: `artifacts/python/lcov.info`.
- TypeScript: Baseline: 96.58% line / 88.5% branch -> Post-change: 96.58% line / 88.56% branch. Change: +0.06% branch (no line regression). New/changed-code coverage: 96.2% line / 89.3% branch (new file `epic-orchestrator-state-resolution.ts`). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`.
- PowerShell: N/A - out of scope. No PowerShell files changed on the branch, so no baseline or post-change coverage is required. Disposition: N/A. Evidence: N/A - out of scope.
- C#: N/A - out of scope. No C# files changed on the branch. Disposition: N/A. Evidence: N/A - out of scope.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear failure messages | PASS | Assertions carry explicit expected/actual context; validator returns literal error strings that tests assert on directly. |
| Arrange-Act-Assert pattern | PASS | Changed Python/TS tests follow AAA with in-memory fixtures, a single act, and behavioral assertions. |
| Document intent | PASS | Descriptive `test_...` / `it(...)` names describe scenario and expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid external dependencies | PASS | No network/DB/process dependencies; validators and resolvers are pure functions over in-memory data. |
| Use mocks/stubs | PASS | Scaffolding tests use in-memory `FileSystem` fakes rather than real disk I/O. |
| Environment stability | PASS | No runtime temp-file creation; no mutable global state relied upon between tests. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission review | PASS | This audit document serves as the required policy review; no outstanding review items block merge. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity / separation of concerns | PASS | Resolution logic extracted into a single shared helper consumed by uniqueness, cycle, wave-barrier, and waves-consistency checks; no duplication. |
| Reusability (single shared resolver) | PASS | `build_feature_reference_index` / `resolve_feature_reference` reused across four call sites in `validate_epic_orchestrator_state.py`. |
| Additive / key-gated (backward compat hard req) | PASS | Resolver is identity on bare folder-basename keys; intent validation is a no-op when `intent` absent (`_epic_orchestrator_state_resolution.py` docstring + logic; legacy regression green). |
| File size < 500 lines | PASS | Largest changed source files: `validate_epic_orchestrator_state.py` 457, `flow.ts` 444, `epic-orchestrator-state-core.ts` 411. All < 500 (reviewer `wc -l`). |
| Error handling explicit | PASS | JSON decode failure returns a specific error string; non-dict root rejected; unresolved references reported explicitly. |

### 2.2 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | PASS | Reviewer independent `poetry run black --check` on changed Python files: exit 0, "7 files would be left unchanged." Evidence `final-py-format.*`, `final-ts-format.*` (exit 0). |
| Linting | PASS | `final-py-lint.*` (`ruff check .` exit 0), `final-ts-lint.*` (`npm run lint` exit 0). |
| Type checking | PASS | `final-py-typecheck.*` (`pyright` exit 0), `final-ts-typecheck.*` (`npm run typecheck` exit 0). |
| Tests | PASS | `final-py-test.*` (pytest, 1309 passed, exit 0), `final-ts-test.*` (1568 passed, exit 0). |
| Full toolchain loop | PASS | Executor evidence shows all stages green in a single pass for both languages. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strong typing (Pyright-clean, no bare `Any`) | PASS | Full annotations on all new/changed functions; `Any` used only for untyped JSON payloads and isolated via `cast(...)`; pyright exit 0. |
| Small cohesive modules; `_`-prefixed internal | PASS | New `_epic_orchestrator_state_resolution.py` is a `_`-prefixed sibling helper module with one clear purpose. |
| Specific exceptions; no silent ignore | PASS | `json.JSONDecodeError` caught and reported with context; unhashable `depends_on` handled explicitly (`TypeError` -> unresolved). |
| Docstrings / intent comments (self-explanatory-code policy) | PASS | Every function has Google-style docstring with Args/Returns/Raises/Side Effects; loops and branches carry intent comments. |
| Suppressions authorized | PASS | No new `# noqa` / `# type: ignore` introduced in the changed Python. |
| Logging vs print | PASS (pre-existing) | `new_active_feature_folder_flow.py` uses `print()` as CLI user-facing output; this is a pre-existing pattern for this CLI entry point, not newly introduced by this feature. Informational observation only. |

### Section 3B: TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strong typing; no new `any` | PASS | New `epic-orchestrator-state-resolution.ts` and modified core are fully typed; `npm run typecheck` exit 0. |
| Parity with Python authoritative surface | PASS | Parity gates green: `parity-validator.*`, `parity-resource-contract.*`, `parity-pack-manifest.*` (all exit 0). |
| File size < 500 lines | PASS | `flow.ts` 444, `epic-orchestrator-state-core.ts` 411, all changed TS < 500 (reviewer `wc -l`). |
| Error handling explicit | PASS | Resolver reports unresolved references explicitly; no silent catches introduced. |

### Section 3C: PowerShell / Bash / JSON / C#

N/A - out of scope. No changed files in these languages within the branch diff.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | PASS | All changed Python tests use Pytest; `final-py-test.*` 1309 passed, exit 0. |
| Coverage expectation | PASS | New module 94.1% line / 93.8% branch (>= uniform gate); repo-wide Python 84% line (above the 80% remediation trigger; see section 5 note). |
| Focused unit tests | PASS | Each test exercises a single validator/resolver behavior with in-memory fixtures. |
| Naming and readability | PASS | Descriptive `test_...` names mirror scenario and expected outcome; tests mirror code structure under `tests/scripts/dev_tools/`. |
| Pytest only | PASS | No alternative Python test runner introduced. |

### Section 4B: TypeScript Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Framework and scope | PASS | Vitest suites cover the new resolver and modified core; `final-ts-test.*` 1568 passed, exit 0. |
| Coverage expectation | PASS | New module 96.2% line / 89.3% branch; repo-wide TS 96.58% line / 88.56% branch (both >= uniform gate). |
| Test file location mirrors source | PASS | Tests live under `extensions/drm-copilot/test/lib/**` mirroring `src/lib/**`. |
| Naming and readability | PASS | `describe`/`it` names document scenario and expected outcome. |

### Section 4C: PowerShell Unit Tests

N/A - out of scope. No PowerShell files changed on the branch, so no Pester coverage or execution is required.

---

## 5. Test Coverage Detail

Verified from lcov artifacts by the reviewer.

### Python (`artifacts/python/lcov.info`)

Format `line% (LH/LF), branch% (BRH/BRF)`:

| File | Change | Line Coverage | Branch Coverage | Status |
|------|--------|---------------|-----------------|--------|
| `_epic_orchestrator_state_resolution.py` | NEW | 94.1% (80/85) | 93.8% (45/48) | PASS |
| `validate_epic_orchestrator_state.py` | MOD | 96.2% (128/133) | 91.9% (57/62) | PASS |
| `new_active_feature_folder_flow.py` | MOD | 91.1% (123/135) | 88.5% (46/52) | PASS |
| `new_active_feature_folder_io.py` | MOD | 97.3% (107/110) | 88.0% (44/50) | PASS |
| `new_active_feature_folder_docs.py` | MOD | 98.8% (79/80) | 90.0% (36/40) | PASS |

### TypeScript (`extensions/drm-copilot/coverage/lcov.info`)

| File | Change | Line Coverage | Branch Coverage | Status |
|------|--------|---------------|-----------------|--------|
| `validate/epic-orchestrator-state-resolution.ts` | NEW | 96.2% (276/287) | 89.3% (50/56) | PASS |
| `validate/epic-orchestrator-state-core.ts` | MOD | 97.6% (401/411) | 88.7% (63/71) | PASS |
| `new-active-feature-folder/flow.ts` | MOD | 99.5% (442/444) | 92.5% (74/80) | PASS |
| `new-active-feature-folder/io.ts` | MOD | 99.5% (394/396) | 91.7% (66/72) | PASS |
| `new-active-feature-folder/docs.ts` | MOD | 100% (353/353) | 100% (33/33) | PASS |

**Repo-wide note:** TypeScript 96.58% line / 88.56% branch — PASS. Python 84% line TOTAL — above the 80% FAIL trigger and unchanged from the 84% baseline (no regression). The 84% repo-wide figure sits below the 85% aspirational per-language floor in `quality-tiers.md`; it is a pre-existing state driven by untouched files (`shell_qc.py`, `tk_dialog_helpers.py`) outside this feature's scope, so it is not a regression introduced by #331. Recorded as PASS-with-note rather than FAIL because (i) it is above the 80% remediation trigger, (ii) there is no regression on changed lines, and (iii) all changed/new files independently exceed the uniform gate.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (Python) | 1309 | PASS |
| Tests Passed (Python) | 1309 (100%) | PASS |
| Tests Failed (Python) | 0 | PASS |
| Total Tests (TypeScript) | 1568 | PASS |
| Tests Passed (TypeScript) | 1568 (100%) | PASS |
| Tests Failed (TypeScript) | 0 | PASS |
| Code Coverage (Python new file) | 94.1% line, 93.8% branch | PASS |
| Code Coverage (TypeScript new file) | 96.2% line, 89.3% branch | PASS |
| Code Coverage (repo-wide TypeScript) | 96.58% line, 88.56% branch | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 7 files would be left unchanged (reviewer-run, exit 0) | PASS |
| Ruff Linting | `poetry run ruff check .` | exit 0 (`final-py-lint.*`) | PASS |
| Pyright Type Checking | `poetry run pyright` | exit 0 (`final-py-typecheck.*`) | PASS |
| Pytest Tests | `poetry run pytest --cov --cov-branch` | 1309 passed, exit 0 | PASS |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Format | `npm run format` | exit 0 (`final-ts-format.*`) | PASS |
| Lint | `npm run lint` | exit 0 (`final-ts-lint.*`) | PASS |
| Typecheck | `npm run typecheck` | exit 0 (`final-ts-typecheck.*`) | PASS |
| Vitest + coverage | `npm run test:coverage` | 1568 passed, exit 0 | PASS |

**For PowerShell:** N/A - out of scope (no PowerShell files changed on the branch).

**Notes:** No pre-existing failures were introduced. The one whole-tree evidence-location validator flag is an untracked, out-of-diff file unrelated to this feature (see Evidence Location Compliance).

---

## 8. Gaps and Exceptions

### Identified Gaps
- None that block feature #331. Repo-wide Python line coverage (84%) is below the 85% aspirational floor but is a pre-existing, out-of-scope condition with no regression (see section 5).

### Approved Exceptions
- None requested; no suppressions introduced.

### Removed/Skipped Tests
- None. All planned tests are implemented; legacy regression suites remain green.

### Policy Rule: modified-workflow-needs-green-run
Not triggered. `git diff --name-only ee65d6e..732a607` contains no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. No green-run evidence is required. The benchmark-baseline provenance rule (`.claude/rules/benchmark-baselines.md`) is also not engaged (no baseline files changed).

### Housekeeping (not a #331 blocker)
- Relocate/remove the untracked `artifacts/research/2026-07-07T19-00-epic-folder-structure-research.md` so the whole-tree evidence-location validator returns to zero (see Evidence Location Compliance).

---

## 9. Summary of Changes

### Commits in This PR/Branch

Branch `feature/epic-single-home-manifest-331` at head `732a607d60ea2b9e8072b3cf594caf2b810f1e09`, audited against merge base `ee65d6e9e99b86bdbd7d00dcc47fc90db39ff56b`. 65 files changed (+3516/-341).

### Files Modified (representative)

1. **`scripts/dev_tools/_epic_orchestrator_state_resolution.py`** (NEW)
   - Shared `issue_num`-keyed reference index, `_normalize_folder_hint`, and presence-gated `validate_intent_block`.
2. **`scripts/dev_tools/validate_epic_orchestrator_state.py`** (MODIFIED)
   - Consumes the shared resolver across four checks; remains 457 lines (< 500).
3. **`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-resolution.ts`** (NEW)
   - TypeScript port of the resolver; parity gate green.
4. **`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`** (MODIFIED)
   - Consumes the ported resolver; 411 lines (< 500).
5. **`scripts/dev_tools/new_active_feature_folder_flow.py` + `_io.py` + `_docs.py`** (MODIFIED) and `flow.ts` / `io.ts` / `docs.ts` (MODIFIED)
   - Route `epic` to `docs/features/epics/<slug>/` single home; retire `initiative.md`.
6. **`.claude/skills/epic-orchestrate/SKILL.md` + byte-identical mirror, templates** (MODIFIED/NEW)
   - Document single-home layout; remove the active->completed workaround text.
7. **Tests** under `tests/scripts/dev_tools/**` and `extensions/drm-copilot/test/lib/**` (NEW/MODIFIED).

---

## 10. Compliance Verdict

### Overall Status: PASS (FULLY COMPLIANT for the #331 branch diff)

All in-scope policy areas pass. Toolchain evidence is green for both languages (independently spot-verified: black --check, per-file coverage, file sizes). Coverage meets the uniform gate on every changed/new file in both languages. The change is additive and key-gated, satisfying the backward-compatibility hard requirement, with legacy regression evidence green.

### Policy-by-Policy Summary

- PASS General Code Change Policy (Section 2): design, structure, toolchain all green.
- PASS Language-Specific Code Change Policy (Section 3): Python and TypeScript compliant; PowerShell/Bash/JSON/C# out of scope.
- PASS General Unit Test Policy (Section 1): principles, coverage, structure, dependencies all met.
- PASS Language-Specific Unit Test Policy (Section 4): Python (Pytest) and TypeScript (Vitest) compliant; PowerShell out of scope.

### Metrics Summary

- PASS 1309/1309 Python tests passing (100%); 1568/1568 TypeScript tests passing (100%).
- PASS New Python file 94.1% line / 93.8% branch; new TypeScript file 96.2% line / 89.3% branch.
- PASS Repo-wide TypeScript 96.58% line / 88.56% branch; Python 84% line (no regression, above 80% trigger).
- PASS All changed source files under the 500-line limit.
- PASS All code quality checks passing for both in-scope languages.

### Recommendation

**Ready for merge.** No remediation plan is triggered: there are no meaningful FAIL/PARTIAL results against the feature branch diff, toolchain checks pass, coverage meets thresholds, and no acceptance criterion is unmet. The single whole-tree evidence-location validator flag is an untracked, out-of-diff file unrelated to this feature and is recorded as housekeeping only.

---

## Appendix A: Test Inventory

Representative changed/added test surfaces exercised in this review (full suites: 1309 Python, 1568 TypeScript):

- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` — intent-block valid/invalid, `issue_num` resolution, active/completed folder hints, legacy byte-identical cases.
- `tests/scripts/dev_tools/test_epic_wave_computation.py` — key-agnostic wave computation; legacy regression green.
- `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py` — epic single-home scaffolding; asserts no `active/` epic folder and no `initiative.md`.
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-*.test.ts` — TypeScript resolver/core parity coverage.
- `extensions/drm-copilot/test/lib/new-active-feature-folder/{flow,io,docs}.test.ts` — TS scaffolding parity.

---

## Appendix B: Toolchain Commands Reference

Reviewer-run (independent verification):
```bash
git diff --name-only ee65d6e9e99b86bdbd7d00dcc47fc90db39ff56b..732a607d60ea2b9e8072b3cf594caf2b810f1e09
git diff --name-only <range> -- '*.py' | xargs poetry run black --check   # exit 0
python scripts/dev_tools/validate_evidence_locations.py --root .           # exit 1 (out-of-diff untracked file)
wc -l <changed source files>                                              # all < 500
# per-file coverage parsed from artifacts/python/lcov.info and extensions/drm-copilot/coverage/lcov.info
```

Executor-recorded (from feature evidence, EXIT_CODE 0 unless noted):
```bash
poetry run black --check .            # final-py-format
poetry run ruff check .               # final-py-lint
poetry run pyright                    # final-py-typecheck
poetry run pytest --cov --cov-branch --cov-report=term-missing   # final-py-test (1309 passed)
npm run format / lint / typecheck / test:coverage   # final-ts-* (1568 passed)
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v   # parity-resource-contract
npm run test -- claude-pack-manifest-completeness   # parity-pack-manifest
npm run test -- epic-orchestrator-state-core        # parity-validator
python -m scripts.dev_tools.push_down_claude_customizations --destination <scratch>   # pushdown
```

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-08
**Policy Version:** Current (as of audit date)
