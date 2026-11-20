# Policy Audit: Epic Orchestrator-State Validator merge_status Guards (Issue #793)

- Timestamp: 2026-10-09T01-30
- Branch: bug/epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793
- Reviewed HEAD: dfad6bdeb; base: origin/main (three-dot diff `origin/main...HEAD`)
- Work mode: full-bug (AC source: `spec.md`)
- Tier: `scripts/dev_tools` is T4, `extensions/drm-copilot` is T3 (`quality-tiers.yml`)
- Template note: the MCP policy-audit template asset was not reachable in this session. The canonical section headings from `policy-audit-template-usage` are preserved. Validator gate for this artifact is UNVERIFIED because no validator tool was available to this agent (see Section 8).
- PR-context note: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent in the worktree. The baseline diff was read directly with `git diff origin/main...HEAD` (46 files, 1623 insertions, 2 deletions); the code-path diff is three files.

## Rejected Scope Narrowing

None. The caller prompt restricted inspection to code paths for diff reading only; it did not narrow the audit scope or exempt any language. Both Python and TypeScript files changed and both received explicit coverage verdicts.

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` (run by this reviewer): exit 0, no violations.
- `git diff --name-only origin/main...HEAD` contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,regression-testing,qa-gates}/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose. Verdict: PASS.

## Executive Summary

Overall verdict: PASS. Blocking findings (FAIL plus blocking PARTIAL): 0.

The change adds two `isinstance(merge_status, str)` guards in `scripts/dev_tools/validate_epic_orchestrator_state.py`, one new Python regression test file (21 tests), and one new TypeScript parity test file (8 tests). No other production file changed. Independent re-run by this reviewer of the three related Python test files: 78 passed. Coverage artifact `artifacts/python/lcov.info` exists and reports the changed module at 93.75% line and 87.10% branch.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence, isolation, determinism | PASS | Tests are pure in-process calls with literal inputs; the CLI test stubs `_read_text` via `monkeypatch`; no clock, RNG, or global state. |
| AAA structure and descriptive names | PASS | Each test has a docstring and arrange/act/assert flow; names state scenario and outcome. |
| Scenario completeness | PASS | Positive (valid strings), negative (list, dict, int, bool, invalid string), edge (None, missing key), entry point, `require_complete=True`, and CLI exit code are all covered. |
| No temporary files, no external services | PASS | `git grep` of the new test files shows no `tmp_path`, `tempfile`, or file I/O; CLI reads are stubbed. |
| Test location mirrors source | PASS | `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` mirrors `scripts/dev_tools/validate_epic_orchestrator_state.py`. |
| Banned APIs in tests (`setTimeout`, `Date.now()`, sleeps) | PASS | None present in either new file. |
| Fail-before evidence | PASS | `evidence/regression-testing/fail-before-python.md`: exit 1 with `ExpectedExitCode: 1`, 10 failed and 11 passed, all ten failures `TypeError: unhashable type`. |

### 1.2 Coverage Evidence Checklist

- Python baseline coverage artifact: `evidence/baseline/p0-python-pytest-coverage.md` (85.04% line, 75.81% branch for `scripts.dev_tools.validate_epic_orchestrator_state`)
- Python post-change coverage artifact: `evidence/qa-gates/final-python-pytest-coverage.md` (93.75% line, 87.10% branch)
- TypeScript baseline coverage artifact: `evidence/baseline/p0-ts-jest-coverage.md` (97.96% line, 91.11% branch for the core module `epic-orchestrator-state-core.ts`)
- TypeScript post-change coverage artifact: `evidence/qa-gates/final-ts-jest-coverage.md` (97.96% line, 91.21% branch)
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed
- Per-language comparison summary: see `### 1.2.1 Per-Language Coverage Comparison` below; deltas are also recorded in `evidence/qa-gates/coverage-delta.md`

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 2 (1 production, 1 test) | 21 new, 78 in related files | PASS | 85.04% line / 75.81% branch | 93.75% line / 87.10% branch | 93.75% line / 87.10% branch (changed module; changed lines 238-240 and 323-324 covered) |
| TypeScript | 1 (test only) | 8 new | PASS | 97.96% line / 91.11% branch (core module) | 97.96% line / 91.21% branch (core module) | N/A - test-only addition, no production code changed |
| PowerShell | 0 | N/A | N/A | N/A - no PowerShell files changed | N/A - no PowerShell files changed | N/A - no PowerShell files changed |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 85.04% line, 75.81% branch. Post-change: 93.75% line, 87.10% branch. Change: +8.71 points line, +11.29 points branch. New/changed-code coverage: 93.75% line, 87.10% branch. Disposition: PASS. Evidence: `evidence/baseline/p0-python-pytest-coverage.md`, `evidence/qa-gates/final-python-pytest-coverage.md`, `evidence/qa-gates/coverage-delta.md`
- TypeScript: Baseline: 97.96% line, 91.11% branch. Post-change: 97.96% line, 91.21% branch. Change: 0.00 points line, +0.10 points branch (no production code changed). Disposition: PASS. Evidence: `evidence/baseline/p0-ts-jest-coverage.md`, `evidence/qa-gates/final-ts-jest-coverage.md`, `evidence/qa-gates/coverage-delta.md`
- PowerShell: Baseline: N/A - no PowerShell files changed. Post-change: N/A - no PowerShell files changed. Change: N/A. Disposition: N/A. Evidence: `git diff --name-only origin/main...HEAD` contains no `.ps1` or `.psm1` path

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity, no broad catch-all | PASS | Two inline `isinstance` guards; no `try/except TypeError` (spec rejects it). |
| Fail fast and explicit errors | PASS | Non-string values now yield the existing validation error text instead of a traceback. |
| Public API compatibility | PASS | No signature change; error strings unchanged (spec "Backward-compatibility"). |
| File size <= 500 lines | PASS | Re-measured: production 431 lines, Python test 219, TS test 102 (also `evidence/qa-gates/line-counts.md`). |
| No new dependencies | PASS | No manifest or lockfile changes in the diff. |
| Scope discipline | PASS | Code-path diff is exactly the three declared files; no `extensions/drm-copilot/src/`, wave-barrier module, or `jest.config.cjs` change (`evidence/qa-gates/scope-check.md`; confirmed by `git diff --stat`). |
| Tone policy in authored docs | PASS | Spec, plan, and evidence use neutral language. |

## 3. Language-Specific Code Change Policy Compliance

### Python (`.claude/rules/python.md`)

| Gate | Verdict | Evidence |
|---|---|---|
| Black | PASS | `evidence/qa-gates/final-python-black.md`: exit 0, 3 files unchanged. |
| Ruff | PASS | `final-python-ruff.md`: exit 0. |
| Pyright | PASS | `final-python-pyright.md`: 0 errors, 0 warnings. |
| Typed code, no suppressions | PASS | New tests use `cast` and `vars(validator)[...]` to reach private functions without `# type: ignore` or `# noqa`. |

### TypeScript (`.claude/rules/typescript.md`)

| Gate | Verdict | Evidence |
|---|---|---|
| Prettier | PASS | `final-ts-prettier.md`: exit 0. |
| ESLint | PASS | `final-ts-eslint.md`: exit 0. |
| tsc (source and test) | PASS | `final-ts-typecheck.md`: exit 0. |
| No `any` or suppressions | PASS | New TS file uses `unknown`; no `any`, `@ts-ignore`, or `eslint-disable`. |

PowerShell and C#: zero changed files; not applicable.

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Python: pytest parametrize, `tests/` mirror layout | PASS | Four parametrize groups plus a preservation parametrize; file under `tests/scripts/dev_tools/`. |
| Python: private-function access without suppression | PASS | `cast("Callable[...]", vars(validator)[...])` helpers. |
| TypeScript: Jest, `tests/` layout (`extensions/drm-copilot/test/...`) | PASS | New file discovered by existing `testMatch` (`regression-testing/ts-parity-new-file.md`). |
| Property tests (T1/T2 only) | N/A | Both areas are T3/T4; no pure-function property obligation. |

## 5. Test Coverage Detail

Coverage artifacts were inspected, not regenerated.

| Language | Artifact | Present | Verdict |
|---|---|---|---|
| Python | `artifacts/python/lcov.info` | Yes | PASS |
| TypeScript | `extensions/drm-copilot/coverage/lcov.info` | Yes (the `coverage/lcov.info` default path resolves under the extension package) | PASS |

Python, `scripts/dev_tools/validate_epic_orchestrator_state.py` (modified file). Reviewer read of the lcov record: LF 128, LH 120 (93.75%); BRF 62, BRH 54 (87.10%). Baseline (`evidence/baseline/p0-python-pytest-coverage.md`): 85.04% line, 75.81% branch. Thresholds 85% / 75%: PASS. No regression: PASS. Changed lines 238-240 and 323-324 are absent from the Missing column (191, 198, 278, 283, 408, 414, 423, 425) and all branch arcs sourced at them are taken (`changed-lines-coverage.md`).

Python repo-wide: the artifact contains only the single-module record because coverage was scoped to the changed module per spec Test Strategy. A repo-wide Python percentage cannot be derived from this artifact. The changed module, the only Python production file in the diff, exceeds both thresholds. Verdict for the language: PASS on the changed-file criterion; repo-wide figure recorded as not available from the artifact (see Section 8, non-blocking).

TypeScript: no TypeScript production file changed (two test-only additions). Repo-wide from `final-ts-jest-coverage.md`: lines 97.16%, branches 91.7%, functions 91.59%: PASS (>= 85 / >= 75). The related core module `epic-orchestrator-state-core.ts` is 97.96% line and 91.21% branch, no regression from baseline 97.96% / 91.11%. New test files are not coverage targets. Verdict: PASS.

Coverage exclusion policy: no `exclude` entry was added or changed (`jest.config.cjs` untouched). PASS.

## 6. Test Execution Metrics

| Run | Result | Source |
|---|---|---|
| Python merge-status file | 21 passed | `pass-after-python.md` |
| Python combined (merge-status + existing) | 53 passed, 0 failed | `final-python-pytest-coverage.md` |
| Python wave-barrier non-regression | 25 passed (equals baseline) | `final-python-wave-barrier-pytest.md` |
| Reviewer re-run, three Python files | 78 passed in 0.21s | Reviewer command (check-only, no coverage) |
| TypeScript new file | 8 passed | `final-ts-jest-new-file.md` |
| TypeScript full suite | 257 suites, 3925 tests passed (baseline 3917 plus 8) | `final-ts-jest-coverage.md` |

## 7. Code Quality Checks

| Check | Verdict | Evidence |
|---|---|---|
| Format, lint, type (Python and TypeScript) | PASS | Section 3 evidence. |
| Guard literal count | PASS | `guard-literal-count.md`: exactly 2 occurrences of `isinstance(merge_status, str)`. |
| Issue repro after fix | PASS | `repro-after-enum-list.md`, `repro-after-enum-dict.md`, `repro-after-completion-list.md`: no traceback. Baseline repros recorded in `evidence/baseline/p0-repro-*.md`. |
| Evidence schema (`Timestamp`, `Command`, `EXIT_CODE`) | PASS | Present in every evidence file read; `fail-before-python.md` declares `ExpectedExitCode: 1`. |
| Modified-workflow rule (`.github/workflows/**`, etc.) | N/A | No such path in the diff. |

## 8. Gaps and Exceptions

All items below are non-blocking.

1. Review-artifact validator: no validator tool was available to this agent, so validation of the three review artifacts is UNVERIFIED. The caller should run `validate_orchestration_artifacts.py` for `policy-audit`, `code-review`, and `feature-audit` and return any output for correction.
2. MCP template asset unavailable: structure follows the canonical headings rather than a resolved template copy.
3. Python repo-wide coverage figure not derivable from the module-scoped `artifacts/python/lcov.info`. The changed-file and no-regression criteria are met.
4. `evidence/baseline/phase0-instructions-read.md` has no `Output Summary` line. It records a documentation read, not a gate; low severity.
5. Timestamp ordering: this review is stamped 2026-10-09T01-30 per the caller, which sorts before the executor's evidence timestamps of 2026-10-09T20-xx. Recorded as supplied; no remediation implied.
6. Spec header still reads `Status: Draft`, `Version: 0.2`, with all ACs checked. Documentation-only inconsistency.

## 9. Summary of Changes

- `scripts/dev_tools/validate_epic_orchestrator_state.py`: +7/-2; enum site guard and completion site guard with a local `merge_status` assignment.
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py`: new, 219 lines, 21 test cases.
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts`: new, 102 lines, 8 test cases.
- Feature docs, plan, research, promoted lifecycle record, and 37 evidence files.

## 10. Compliance Verdict

PASS. Blocking findings: 0. Remediation inputs are not required.

## Appendix A: Test Inventory

- Python (21 cases): enum-site non-string rows (list, dict, int, bool); completion-site non-string rows (same four); entry-point rows (list, dict) with and without `require_complete=True`; CLI exit-code rows (list, dict); valid-string acceptance; invalid-string text preservation; None and missing skip; completion accepts merged and worktree_removed; completion reports string, None, and missing.
- TypeScript (8 cases): enum-site rows and completion-site rows for list, dict, number, boolean, each asserting no throw plus the `invalid merge_status` substring or the exact completion sentence.

## Appendix B: Toolchain Commands Reference

- `poetry run black --check <files>`; `poetry run ruff check --no-fix <files>`; `poetry run pyright <files>`
- `poetry run pytest <new+existing tests> --cov=scripts.dev_tools.validate_epic_orchestrator_state --cov-branch --cov-report=term-missing`
- `npm run lint|typecheck|test:coverage --prefix extensions/drm-copilot`; prettier `--check` on the new test file
- Reviewer-run: `validate_evidence_locations.py --root .`; `pytest -q` on the three related Python test files; `git diff --stat origin/main...HEAD`
