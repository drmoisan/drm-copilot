# Policy Compliance Audit: npm-token-guard-gaps (#739)

**Audit Date:** 2026-10-01
**Branch:** `bug/npm-token-guard-gaps-739` (head `9273246f`)
**Base:** `main` (merge base `12fd3c2639f17aec3572f90e8d929205059be56d`, which is `origin/main` and includes #723 / PR #813)
**Work Mode:** `minor-audit` (marker `- Work Mode: minor-audit` in `issue.md`)
**Code Under Test:** `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (modified, 263 to 492 lines) and `docs/features/completed/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md` (1 line changed). Full branch diff: 41 files, 1418 insertions, 53 deletions, including feature-folder records and 36 evidence files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 file (test module under `tests/`) | 6331 full suite, 52 guard module | PASS, 0 fail, 6 skipped | 93.53% lines, 86.76% branches | 93.53% lines, 86.76% branches | N/A (0 production lines changed; the changed file is under `tests/`, which coverage omits) |
| TypeScript | 0 files | N/A | N/A | N/A | N/A | N/A |
| PowerShell | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |
| Markdown | 40 files (runbook plus 39 feature records) | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- Python baseline coverage artifact: `evidence/baseline/baseline-pytest-coverage.2026-10-01T20-49.md`, `evidence/baseline/baseline-coverage-percentages.2026-10-01T20-49.md`
- Python post-change coverage artifact: `evidence/qa-gates/final-pytest-coverage.2026-10-01T20-57.md`, `evidence/qa-gates/final-coverage-percentages.2026-10-01T20-57.md`
- TypeScript baseline coverage artifact: N/A - out of scope (0 changed TypeScript files)
- TypeScript post-change coverage artifact: N/A - out of scope (0 changed TypeScript files)
- PowerShell baseline coverage artifact: N/A - out of scope (0 changed PowerShell files)
- PowerShell post-change coverage artifact: N/A - out of scope (0 changed PowerShell files)
- Per-language comparison summary: `evidence/qa-gates/coverage-comparison.2026-10-01T20-58.md` and section 1.2.1 below

Templates were read from the repository copies under `extensions/drm-copilot/resources/templates/policy_audit/`, using the validator-passing #802 policy audit as the structural reference.

---

## Executive Summary

The branch extends the #712 `NPM_TOKEN` guard test module from two detected families to four (`vars` context references, `_authToken` configuration keys, and `NPM_TOKEN` assignments are added alongside the existing `secrets` and `NODE_AUTH_TOKEN` detection), rewrites the module docstring, and corrects step 2 of the #712 runbook "Recording completion" section. No production file under `src/` or `scripts/` changed, and no `.github/` file changed. The only changed code file is a Python test module; repo-wide Python coverage is unchanged at 93.53% lines and 86.76% branches, above the 85% / 75% uniform thresholds. The reviewer reran Black, Ruff, Pyright, and the targeted pytest module (52 passed); full-suite results (6331 passed, 6 skipped) were taken from existing executor artifacts per the no-rerun rule. Overall verdict: PASS, 0 blocking findings, 2 non-blocking findings.

**Policy documents evaluated:**
- Reviewed: `CLAUDE.md`
- Reviewed: `general-code-change.md`
- Reviewed: `general-unit-test.md`
- Reviewed: `quality-tiers.md`
- Reviewed: `tonality.md`

**Language-specific policies evaluated:**
- Python: `python.md`, `python-suppressions.md` (test module only)
- TypeScript, PowerShell, C#: N/A, 0 changed files
- Markdown: tone and accuracy review of the runbook line, docstrings, and evidence text

**Temporary artifacts cleanup:**
- No temporary scripts were committed. `git status` before this review showed a clean working tree; the only untracked files are the three review artifacts written by this review.

## Rejected Scope Narrowing

None. The caller listed the "changed files of substance" for orientation; that list matches the full branch diff after excluding feature records, and the audit covered the full diff regardless.

## Evidence Location Compliance

- Scan: `git diff --name-only origin/main...HEAD` filtered for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/` returned no paths.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` printed no violation.
- All executor evidence lives under `docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/{baseline,other,qa-gates,regression-testing}/`. Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Each helper test operates on its own in-memory string; no shared mutable state |
| Isolation | PASS | One finder or helper per test function; the tree-scan test is parametrized per finder |
| Fast execution | PASS | Reviewer run of the module: `52 passed in 0.09s` |
| Determinism | PASS | No clock, RNG, network, or sleep usage; enumeration sorted by POSIX relative path |
| Readability | PASS | Every test carries `# Arrange`, `# Act`, `# Assert` markers; parametrize IDs are descriptive; assertion messages name the input via `{text!a}` or list offenders |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | 93.53% lines / 86.76% branches (`evidence/baseline/baseline-coverage-percentages.2026-10-01T20-49.md`) |
| No Coverage Regression | PASS | Post-change equals baseline, delta 0 (`evidence/qa-gates/coverage-comparison.2026-10-01T20-58.md`, `Verdict: PASS`) |
| New/Modified File Coverage | N/A | 0 changed production files; the changed test module is omitted from coverage by `pyproject.toml` `[tool.coverage.run] omit` (`"tests/*"`) |
| Coverage exclusion policy | PASS | `pyproject.toml` is not in the diff; no `omit` or `exclude` entry changed |
| Scenario completeness | PASS | Each finder has parametrized positive cases, negative cases, and an `empty` edge case; `collect_offenders` has a direct test; the enumeration has a non-vacuity test. See NB-2 for one untested false-positive shape |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.53% lines (93.52893424562217) / 86.76% branches (86.76187419768935) -> Post-change: 93.53% lines (93.52893424562217) / 86.76% branches (86.76187419768935). Change: 0.00 percentage points lines, 0.00 percentage points branches. New/changed-code coverage: N/A, 0 production lines changed (the only changed Python file is under `tests/`, which coverage omits). Disposition: PASS (repo-wide at or above 85% lines and 75% branches, no regression). Evidence: `evidence/qa-gates/coverage-comparison.2026-10-01T20-58.md`, `evidence/qa-gates/final-coverage-thresholds.2026-10-01T20-57.md`.
- TypeScript: N/A, 0 changed TypeScript files on the branch; no coverage comparison applies.
- PowerShell: N/A, 0 changed PowerShell files on the branch; no coverage comparison applies.
- C#: N/A, 0 changed C# files on the branch; no coverage comparison applies.
- Coverage artifact note: the reviewer parsed `artifacts/python/lcov.info` (written 2026-10-01T20:57) and obtained 93.53% lines (16130 of 17246) and 86.76% branches (5407 of 6232), matching the executor coverage.py JSON readout. Coverage generation was not rerun by the reviewer.
- Threshold note: the agent contract Verification Procedure cites 90% new-file and 80% repo-wide, while its threshold section and `.claude/rules/quality-tiers.md` state 85% line / 75% branch. The 85/75 rule was applied. The result is the same under either.

### 1.3-1.5 Diagnostics, Dependencies, Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Actionable failure messages | PASS | Messages include the input text via `{text!a}` or the `<path>:<line>` offender list |
| No temporary files in tests | PASS | Reviewer search of the module for `tempfile`, `tmp_path`, `tmpdir`, `subprocess`, `urllib`, and `socket` returned no match |
| No external service dependency | PASS | Helper tests use in-memory strings; the tree-scan test reads the repository `.github/` tree from disk, inherited from #712 (see code-review CR-4) |
| Pre-submission audit | PASS | This audit serves as the pre-submission review |

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify objective | PASS | `issue.md` states the objective and twelve acceptance criteria |
| Document the plan | PASS | `plan.2026-09-29T21-55.md`, with preflight records in `evidence/other/` |
| Simplicity first | PASS | Line scanning consolidated into `_matching_line_numbers`; each finder is a one-line delegation |
| Reusability | PASS | `collect_offenders` and the parametrized tree scan remove duplicated scan tests |
| Scope containment | PASS | Reviewer `git diff --name-only origin/main...HEAD -- src scripts` and `-- .github` print nothing (AC10) |
| Dependencies | PASS | Imports limited to `re`, `pathlib`, `typing`, `pytest`, and `collections.abc` under `TYPE_CHECKING`; no dependency added |
| Under 500 lines | PASS | Reviewer `grep -c ""` on the module prints `492` |
| Naming | PASS | `snake_case` functions, `UPPER_SNAKE` module constants, private helpers and patterns prefixed with `_` |
| Error handling | N/A | Test-only change; no production error path added |
| No secrets recorded | PASS | Fixture literals use placeholders (`x`, `${TOKEN}`, `$TOKEN`, `${{ secrets.PUBLISH }}`) |

### 2.5 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting (Black) | PASS | Reviewer `poetry run black --check` on the module: `1 file would be left unchanged.`, exit 0; executor `evidence/qa-gates/final-black.2026-10-01T20-55.md` |
| Linting (Ruff) | PASS | Reviewer `poetry run ruff check --no-fix`: `All checks passed!`, exit 0 |
| Type checking (Pyright strict) | PASS | Reviewer `poetry run pyright`: `0 errors, 0 warnings, 0 informations` |
| Architecture-boundary tests | PASS | No production module or import boundary changed |
| Unit tests | PASS | Reviewer module run: 52 passed; full suite (executor): 6331 passed, 6 skipped, no failing node |
| Contract / schema checks | PASS | No contract or schema surface changed |
| Integration tests | PASS | `test_github_yaml_files_contain_no_npm_token_route` (4 nodes) reads the real `.github/` tree and passes on the combined #723 + #739 state (`evidence/qa-gates/ac-node-listing.2026-10-01T20-58.md`) |
| Single-pass loop | PASS | `evidence/qa-gates/final-loop-single-pass.2026-10-01T20-58.md` records one pass with identical pre/post `git status` |

---

## 3. Language-Specific Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Python: suppressions per `python-suppressions.md` | PASS | Reviewer search for `noqa`, `type: ignore`, and `pyright: ignore` in the module returned no match. The plan pre-authorized `# noqa: S105`; it was not needed and not added |
| Python: annotation-only imports under `TYPE_CHECKING` | PASS | `Callable` imported under `if TYPE_CHECKING:`; `from __future__ import annotations` present |
| Python: Google-style docstrings | PASS | `_matching_line_numbers`, `find_npm_auth_token_config_references`, `find_npm_token_assignments`, and `collect_offenders` each carry a summary, description, `Args:`, and `Returns:`. See NB-1 for one test docstring with outdated wording |
| Python: type annotations | PASS | Pyright strict reports 0 errors |
| Markdown: tone | PASS | Runbook step 2, docstrings, and evidence text are factual and neutral |
| TypeScript, PowerShell, C# | N/A | 0 changed files |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Python: pytest parametrization with IDs | PASS | 35 new parametrized nodes (17 to 52) with descriptive IDs |
| Python: test file location | PASS | The module stays at its pre-existing location under `tests/scripts/dev_tools/` |
| Python: no temporary files | PASS | See section 1.3-1.5 |
| TypeScript, PowerShell, C# | N/A | 0 changed files |

## 5. Test Coverage Detail

The changed module is test code and is omitted from coverage measurement, so no production function, class, or module under test was added or changed. Post-change Python repo-wide coverage: 93.53% lines (16130 of 17246), 86.76% branches (5407 of 6232); delta 0 against baseline. Threshold gate `evidence/qa-gates/final-coverage-thresholds.2026-10-01T20-57.md` (`--min-line 85 --min-branch 75`) exited 0.

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Guard module tests passed | 52 of 52 (baseline 17) | PASS |
| Full suite passed | 6331 passed, 6 skipped (baseline 6296 passed, 6 skipped) | PASS |
| Execution time | 0.09s module; 85.27s full suite | Fast |
| Code coverage | 93.53% lines, 86.76% branches | PASS |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Format | `poetry run black --check` | exit 0 | PASS |
| Lint | `poetry run ruff check --no-fix` | exit 0 | PASS |
| Type check | `poetry run pyright` | 0 errors | PASS |
| File size | `grep -c ""` | 492 lines | PASS |

**Notes:** All four checks were rerun by the reviewer against the module at head `9273246f`.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **NB-1** (non-blocking, `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` line 208): the docstring of `test_find_npm_token_references_detects_reintroduced_reference` still reads "A reintroduced ``NPM_TOKEN`` secret reference is reported at its line." although the parameter list now includes `vars-dot` and `vars-bracket`. Deviation D5 updated the sibling negative test to "secret or variable" but not this one. Suggested wording: "secret or variable reference".
- **NB-2** (non-blocking, same module lines 47-49, `_NPM_TOKEN_ASSIGNMENT`): the `\bNPM_TOKEN\s*=` alternative also matches a comparison such as `if: ${{ env.NPM_TOKEN == '' }}` (reviewer in-memory probe returned `True`). This is a fail-closed false positive and no current `.github/` file contains that shape, so it has no present impact. No test case documents the behavior.

### Plan Deviations Reviewed

| ID | Summary | Policy impact |
|----|---------|---------------|
| D1 | #723 merged first (PR #813, `12fd3c26`); no guard or runbook overlap | None; reviewer scan of `.github` YAML for `_authtoken`, `npm_token`, and `node_auth_token` returned no match |
| D2 | Guard runs recorded on the combined #723 + #739 state | None; reviewer rerun on head gives 52 passed |
| D3 | Phase 1 performed by `atomic-executor` instead of delegated `python-typed-engineer` | Process deviation only; output passes every gate |
| D4 | Four Phase 1 artifact timestamps are 1-3 minutes later than actual run times | Evidence-hygiene deviation, disclosed; reviewer re-verified the line count, constraint scan, and runbook checks. Not blocking |
| D5 | Two existing docstrings reworded after the `vars` extension | None; one related docstring was not updated (NB-1) |

### Approved Exceptions
**None.**

### Removed/Skipped Tests
**None.** The 6 skipped full-suite nodes are pre-existing and identical at baseline.

## 9. Summary of Changes

### Commits in This PR/Branch
1. **bb0720dd** - docs(739): create active feature folder for npm-token-guard-gaps
2. **28dc76c7** - docs(739): add research for npm-token-guard-gaps
3. **614ee7ee** - docs(739): add acceptance criteria to issue.md
4. **be5e8614** - docs(739): add minimal-audit plan for npm-token-guard-gaps
5. **c3b8f415** - docs(739): record preflight round 1 (revisions required)
6. **be1f408a** - docs(739): apply preflight round 1 plan deltas
7. **b2625759** - docs(739): record preflight round 2 (all clear)
8. **8c2a7c85** - Merge remote-tracking branch 'origin/main' into bug/npm-token-guard-gaps-739
9. **6e63dd50** - docs(739): record Phase 0 policy reads and baseline evidence
10. **e3b82107** - test(739): extend npm token guard to vars, _authToken, and NPM_TOKEN assignments
11. **9273246f** - docs(739): record final QC evidence and check off AC1-AC12

### Files Modified
1. `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (MODIFIED): adds `_NPM_AUTH_TOKEN_CONFIG_REFERENCE` and `_NPM_TOKEN_ASSIGNMENT`, renames `_NPM_TOKEN_SECRET_REFERENCE` to `_NPM_TOKEN_CONTEXT_REFERENCE` and extends it to `vars`, adds `_matching_line_numbers` and `collect_offenders`, and parametrizes the tree scan over four finders.
2. `docs/features/completed/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md` (MODIFIED): step 2 now names the pending evidence record and cites D5.
3. Feature folder `issue.md`, plan, research, and evidence records (NEW or MODIFIED, 39 files).

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT (PASS)

All applicable policy checks are met for the branch diff. 0 blocking findings; 2 non-blocking findings (NB-1, NB-2).

### Metrics Summary

- 52/52 guard module tests and 6331 full-suite tests passing (6 pre-existing skips)
- Python line coverage 93.53%, branch coverage 86.76%; delta 0
- Black, Ruff, and Pyright clean on the changed module
- Evidence location scan clean

### Recommendation

**Ready for PR creation.** Optionally address NB-1 (docstring wording) and NB-2 (document or narrow the comparison false positive) in this branch or a follow-up.

### Total Blocking Count

0

## Appendix A: Test Inventory

| Test function | Nodes | Purpose |
|---------------|-------|---------|
| `find_npm_token_references` positive and negative tests | parametrized | `secrets` and `vars` context references, including `spaced-bracket`, `lowercase-bracket`, `vars-dot`, `vars-bracket`, and `vars-longer-name` |
| `find_npm_auth_token_config_references` positive and negative tests | parametrized | Seven `_authToken` forms; negative cases for OIDC, `registry-url`, `always-auth`, `NODE_AUTH_TOKEN`, and `GH_AUTHTOKEN` |
| `find_npm_token_assignments` positive and negative tests | parametrized | YAML, shell, `$GITHUB_ENV`, and PowerShell assignments; negative cases for context reads, longer names, prefixed names, and prose |
| `test_collect_offenders_names_each_matching_line` | 1 | `<path>:<line>` format and ordering |
| `test_github_yaml_enumeration_is_non_vacuous` | 1 | Guards the tree scan against an empty enumeration |
| `test_github_yaml_files_contain_no_npm_token_route` | 4 | Tree scan of `.github/` YAML, one node per finder |

Total: 52 nodes in the module (17 at baseline).

## Appendix B: Toolchain Commands Reference

```bash
poetry run black --check tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run ruff check --no-fix tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pyright tests/scripts/dev_tools/test_workflow_npm_token_guard.py
poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q
poetry run pytest --cov --cov-branch --cov-report=term-missing
poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-01
**Policy Version:** Current (as of audit date)
