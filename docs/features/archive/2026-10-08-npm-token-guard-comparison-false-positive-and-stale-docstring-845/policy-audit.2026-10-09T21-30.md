# Policy Compliance Audit: npm token guard comparison false positive and stale docstring (#845)

**Audit Date:** 2026-10-09
**Code Under Test:** `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (1 Python test file, +9 / -4; no production file changed)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 0 files | N/A | N/A | N/A | N/A | N/A |
| Python | 1 file (test file only) | 56 in module | PASS, 0 fail | N/A (`tests/*` omitted from coverage) | N/A (`tests/*` omitted from coverage) | N/A (0 production lines changed) |
| PowerShell | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: not applicable - 0 changed TypeScript files on the branch
- TypeScript post-change coverage artifact: not applicable - 0 changed TypeScript files on the branch
- PowerShell baseline coverage artifact: not applicable - 0 changed PowerShell files on the branch
- PowerShell post-change coverage artifact: not applicable - 0 changed PowerShell files on the branch
- Per-language comparison summary: Python only; the sole changed file is test code omitted from coverage by `pyproject.toml` `[tool.coverage.run]` (`evidence/baseline/baseline-coverage-scope.md`, `evidence/qa-gates/coverage-applicability.md`); see section 1.2.1 below

---

## Executive Summary

- Review timestamp: 2026-10-09T21-30
- Branch: bug/npm-token-guard-comparison-false-positive-and-stale-docstring-845
- Base: origin/main, three-dot diff (`git diff origin/main...HEAD`)
- Work mode: full-bug (AC source: `spec.md`)
- Changed production surface: none
- Changed test file: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (+9 / -4)
- Blocking findings: 0
- Non-blocking findings: 2 (NB-1, NB-2)
- Overall verdict: PASS

**Scope and assumptions:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in this worktree (`artifacts/` contains only `orchestration/`). The audit scope was derived directly from `git diff origin/main...HEAD`, which is the same authoritative scope source. The branch contains a merge of origin/main; only the branch's own changes (36 files) were evaluated. Evidence artifacts were read from the feature folder. The test module, Ruff, and the evidence-location validator were re-run read-only by the reviewer to confirm the recorded results.

**Policy documents evaluated:** `general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`, `tonality.md`.

**Language-specific policies evaluated:** Python (`python.md`). TypeScript, PowerShell, C#, Bash: not applicable, 0 changed files.

## Rejected Scope Narrowing

No scope narrowing was supplied by the caller. The caller prompt specified the full branch diff against origin/main.

## Evidence Location Compliance

- `git diff origin/main...HEAD --name-only -- artifacts` returned no paths; no file was written to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` produced no violations (no output).
- All evidence lives under `<FEATURE>/evidence/{baseline,regression-testing,qa-gates,other}/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose; no non-canonical path was supplied by the caller.
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence, determinism, no temp files, no external services | PASS | New rows are pure in-memory parametrize cases on synthetic strings; no filesystem, clock, or network use added |
| Scenario completeness | PASS | Positive (`empty-assignment-end-of-line`), negative (`equality-comparison`, `shell-equality-test`), and boundary (`inequality-comparison`) rows added; fail-first demonstrated |
| Test file location | PASS | File lives under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools`; not moved |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | PASS | Measurement scope recorded in `evidence/baseline/baseline-coverage-scope.md` |
| No coverage regression | PASS | `git diff origin/main...HEAD -- src scripts extensions` is empty; no production line changed, so no changed-line coverage can regress |
| New/modified file coverage | N/A | The one modified file is test code, outside the coverage denominator (`tests/*` omitted in `pyproject.toml`) |
| Scenario completeness | PASS | See 1.1 |

### 1.2.1 Per-Language Coverage Comparison

- Python: `pyproject.toml` `[tool.coverage.run]` measures `src` and `scripts/dev_tools` and omits `tests/*`. The changed file is test code outside the coverage denominator, and no production file changed. Baseline and post-change repo-wide figures are therefore unaffected. Disposition: PASS. No production file is excluded from measurement by this branch. Evidence: `evidence/baseline/baseline-coverage-scope.md`, `evidence/qa-gates/coverage-applicability.md`.
- TypeScript: not applicable, zero changed files.
- PowerShell: not applicable, zero changed files.
- C#: not applicable, zero changed files.
- Coverage artifact note (NB-1): `artifacts/python/lcov.info` is absent. The verdict rests on the fact that the sole changed code file is not a coverage-measured production file and that no production file changed. Recorded as non-blocking because no measured file changed.

### 1.3-1.5 Diagnostics, Dependencies, Audit Requirement

No external service dependency or temporary file was introduced. Assertion messages are unchanged. This audit serves as the pre-submission review.

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity and scope | PASS | Single-lookahead change `(?!=)` to one regex alternative plus docstring edits and test rows; production code untouched |
| 500-line file limit | PASS | Test file is 497 lines (`wc -l`, reviewer-verified; baseline 492) |
| Error handling | PASS | No error-handling paths changed |
| Tone (`.claude/rules/tonality.md`) | PASS | Feature documents and evidence use factual, neutral wording; no humor or hyperbole found |

### 2.5 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting, lint, type check, unit tests | PASS | `final-black.md`, `final-black-check.md`, `final-ruff.md`, `final-pyright.md`, `final-pytest-module.md` all carry LoopPass 1 with exit 0; `final-loop-single-pass.md` shows identical pre and post status, so no auto-fix occurred. Reviewer re-ran Ruff (`All checks passed!`) and pytest (56 passed) |
| Architecture-boundary, contract/schema, integration (loop stages 4, 6, 7) | PASS | No import, schema, or contract surface changed. The integration scenario (`test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment]` against `.github/`) is recorded in `integration-retest.md` and `ac-node-listing.md` |

---

## 3. Language-Specific Code Change Policy Compliance

- Python (`.claude/rules/python.md`): PASS. Type hints unchanged; Ruff E/E501 at 88 clean; the docstring replacement is 77 characters per spec D2; Black reports no changes.
- TypeScript, PowerShell, C#, Bash: 0 changed files. N/A.

## 4. Language-Specific Unit Test Policy Compliance

- Python: PASS. The new rows follow the existing `pytest.param(..., id=...)` convention with descriptive ids; tests are pure in-memory parametrized cases.
- TypeScript, PowerShell, C#: 0 changed files. N/A.

## 5. Test Coverage Detail

No production function, class, or module was added or changed. The changed test module contains 56 collected nodes, all passing. Production coverage is unaffected (see 1.2.1).

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Module tests passed | 56 of 56 (`final-pytest-module.md`; reviewer re-run) | PASS |
| New rows | 4 (1 positive, 3 negative/boundary) | PASS |
| Fail-first demonstrated | 2 comparison rows failed before fix, passed after | PASS |
| Code coverage | N/A (test-only change; `tests/*` omitted from measurement) | N/A |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Format | `poetry run black --check` | file unchanged | PASS |
| Lint | `poetry run ruff check --no-fix` | All checks passed! | PASS |
| Type check | `poetry run pyright` | 0 errors, 0 warnings, 0 informations | PASS |
| Unit tests | `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` | 56 passed | PASS |
| Evidence locations | `validate_evidence_locations.py --root .` | no violations | PASS |

**Notes:** All stages passed in a single pass with no auto-fix.

---

## 8. Gaps and Exceptions

### Identified Gaps

- NB-1 (non-blocking): `artifacts/python/lcov.info` is absent. Coverage verification was satisfied by the documented measurement scope (test-only change, `tests/*` omitted). No action required for this branch.
- NB-2 (non-blocking): `evidence/qa-gates/diff-numstat.md` uses the two-dot form `git diff origin/main` for the numstat, while the review standard is the three-dot form. The result matches the reviewer's three-dot diff (9 added, 4 removed), so the evidence is accurate; the form differs only in convention.

### Plan Deviations Reviewed (PD-1 to PD-6)

| ID | Summary | Assessment |
|----|---------|------------|
| PD-1 | Commit and push at every phase boundary with explicit pathspecs | Acceptable; commit history shows five phase commits with pathspec scope matching AC-14 |
| PD-2 | Probes run as scratchpad script files instead of `python -c` | Acceptable; outputs equivalent and noted in each `Command:` field |
| PD-3 | Git commands run separately | Acceptable; no effect on content |
| PD-4 | P3-T9 run as two commands | Acceptable; both nodes also PASSED in the full-module run |
| PD-5 | AC check-off via one sed edit then count verification | Acceptable; counts 14 and 0 recorded |
| PD-6 | Status listing empty because phases were committed | Acceptable; the three-dot name-only diff in `scope-boundary.md` is the authoritative scope proof |

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None.** All 13 pre-existing parametrize rows are preserved (numstat shows 4 removed lines, none containing `pytest.param(`).

## 9. Summary of Changes

### Files Modified

1. `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (MODIFIED, +9 / -4): `_NPM_TOKEN_ASSIGNMENT` alternative B now `\bNPM_TOKEN\s*=(?!=)`; `find_npm_token_assignments` docstring lists an `==` comparison among non-reported inputs; test docstring summary line revised; four new parametrize rows.
2. Feature folder documentation and evidence (NEW), and the promoted lifecycle record `docs/features/potential/promoted/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring.md`.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

All applicable policy checks are met. Blocking findings: 0. Non-blocking findings: 2 (NB-1, NB-2).

### Metrics Summary

- 56 of 56 module tests passing
- Black, Ruff, Pyright clean in a single pass
- Test file 497 of 500 lines
- Evidence location scan clean
- Coverage: not applicable to the changed test file; no production file changed

### Recommendation

Overall verdict: PASS. Ready for PR flow.

## Appendix A: Test Inventory

New rows in `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`:

- `test_find_npm_token_assignments_detects_assignment[empty-assignment-end-of-line]` (positive; input `NPM_TOKEN=`, expects `[1]`)
- `test_find_npm_token_assignments_ignores_non_matching_text[equality-comparison]` (negative)
- `test_find_npm_token_assignments_ignores_non_matching_text[shell-equality-test]` (negative)
- `test_find_npm_token_assignments_ignores_non_matching_text[inequality-comparison]` (boundary)

All 13 pre-existing rows remain unchanged.

## Appendix B: Toolchain Commands Reference

```bash
poetry run black --check tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run ruff check --no-fix tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pyright tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-09
**Policy Version:** Current (as of audit date)
