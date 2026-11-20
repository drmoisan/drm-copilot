# Feature Audit: Test-support hygiene and stale skipif (#938)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938`
**Base Branch:** `origin/main`
**Head Branch:** `bug/test-support-hygiene-793-skipif-938`
**Work Mode:** `minor-audit`
**Audit Type:** Initial audit

**Total blocking findings: 1.** (Policy-audit PA-1 and code-review CR-1: TypeScript coverage artifact absent. No acceptance criterion fails.)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `adb9aa5f0`)
- **Head branch/commit:** `bug/test-support-hygiene-793-skipif-938` (commit `91044a5b7`)
- **Merge base:** `adb9aa5f0` (equals the `origin/main` tip)
- **Evidence sources:**
  - Primary: `git diff adb9aa5f0..HEAD` for `tests/` and `extensions/`, read directly by the reviewer
  - Feature evidence: `evidence/baseline/**`, `evidence/regression-testing/**`, `evidence/qa-gates/**`, `evidence/other/**`
  - Coverage: `artifacts/python/lcov.info` (reviewer awk: 93.8% line, 88.1% branch)
- **Feature folder used:** `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938`
- **Requirements source:** `issue.md` `## Acceptance Criteria` only (work mode `minor-audit`; `spec.md` and `user-story.md` are absent)
- **Work mode resolution note:** `issue.md` line 12 states `- Work Mode: minor-audit`.
- **Scope note:** `artifacts/pr_context.summary.txt` and the appendix were read at head `91044a5b7`. No PR exists yet.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/issue.md` - `## Acceptance Criteria`, ten checkbox items, labelled AC-1 to AC-10 below in document order.

### Acceptance criteria

- AC-1: support module exists with both builders moved verbatim.
- AC-2: no `test_*.py` file defines either builder.
- AC-3: no `test_*.py` module imports the builders from another `test_*.py`; four named modules import from the support module.
- AC-4: docstring and TypeScript comment cite `validate_orchestration_artifacts_test_support`.
- AC-5: parity file has no `skipif` or `_requires_codex_runtime` token; unused `import pytest` removed.
- AC-6: parity file reports five passed, none skipped.
- AC-7: seven named test files pass with collected count not below baseline.
- AC-8: black, ruff, pyright clean on every touched Python file.
- AC-9: TypeScript toolchain passes with the touched file.
- AC-10: every touched or created file at most 500 lines.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | Support module with both builders, verbatim | PASS | Reviewer diff shows the removed bodies identical to the new bodies; `evidence/regression-testing/builder-equality-check.2026-10-16T00-37.md` shows equal output and docstrings | `git diff adb9aa5f0..HEAD -- tests` | Module is 60 lines |
| AC-2 | No `test_*.py` defines either builder | PASS | `evidence/regression-testing/builder-def-search.2026-10-16T00-41.md`: two hits, both in the support module; reviewer Grep over `tests/` found only the private `_build_read_text_stub` in `test_validate_orchestration_artifacts_pr_creation_readiness.py`, a different token | `grep -rn -F -e "def build_valid_epic_state" -e "def build_read_text_stub" tests --include=*.py` | See CR-2 (Non-blocking) |
| AC-3 | No cross-test-module builder imports; four modules import from support module | PASS | `importer-ast-negative` shows zero offending importers; `importer-ast-positive` lists the importers; reviewer diff shows merge_status, dispatch, plan_gates, parallel_dispatch import from `tests.scripts.dev_tools.validate_orchestration_artifacts_test_support`, and `test_validate_epic_orchestrator_state.py` also imports `build_valid_epic_state` there | AST search commands in evidence | No re-export from a test module |
| AC-4 | Docstring and comment cite the support module | PASS | Reviewer diff: `test_validate_discovery_artifacts_dispatch.py` docstring and `epic-orchestrator-state-core.test.ts` comment name the support module; `doc-citation-stale-token` exit 1 as expected | `git diff`; grep evidence | |
| AC-5 | No `skipif` or `_requires_codex_runtime`; `import pytest` removed | PASS | Reviewer diff removes the guard, both decorators, and `import pytest`; `parity-token-search.2026-10-16T00-41.md` exit 1 as expected | `grep -c -E "skipif|_requires_codex_runtime|import pytest" <file>` | |
| AC-6 | Parity file: five passed, none skipped | PASS | `evidence/qa-gates/pytest-parity-file.2026-10-16T00-48.md`: `5 passed`, no SKIPPED lines | `poetry run pytest <file> -q -rs` | `.codex`/`.agents` content is tracked (171 files) and not ignored |
| AC-7 | Seven named files pass; count not lower than baseline | PASS | Baseline 125 collected/125 passed; final 125 collected/125 passed (`evidence/qa-gates/pytest-eight-files.2026-10-16T00-48.md`); full suite 7094 passed, 0 failed | `poetry run pytest <files> -q -rs` | The run adds the parity file as an eighth file |
| AC-8 | Black, Ruff, Pyright clean on touched Python files | PASS | `evidence/qa-gates/black-check`, `ruff-check`, `pyright` all EXIT_CODE 0 over nine files including the support module | commands recorded in evidence | |
| AC-9 | TypeScript toolchain passes | PASS | `prettier-check`, `eslint`, `tsc-src`, `tsc-test`, `jest-epic-core` all EXIT_CODE 0 | commands recorded in evidence | Separate coverage-artifact gap is a policy finding (PA-1), not an AC failure |
| AC-10 | Every touched file at most 500 lines | PASS | `evidence/qa-gates/line-counts.2026-10-16T00-48.md`: maximum 475 | `wc -l` | |

---

## Summary

All ten acceptance criteria are PASS on the evidence and reviewer verification. The change is test-only, introduces no production code, and keeps the pre-change test count. The branch cannot be called review-clean because the coverage-verification contract treats the absent TypeScript coverage artifact as FAIL (one blocking finding); the finding concerns evidence production, not the delivered behavior.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/issue.md`
- Total AC items: 10
- Checked off (delivered): 10
- Remaining (unchecked): 0
- Items remaining: none

---

## Acceptance Criteria Check-off

All ten items under `## Acceptance Criteria` in `issue.md` were already `- [x]` at review start. The reviewer verified each independently (table above) and found no item to uncheck. No newly checked-off items in this review. The non-AC sections `Proposed Fix / Validation Ideas` and `Next Step` remain unchecked and are not acceptance criteria for `minor-audit`.

---

## Non-blocking Observations

- CR-2: private duplicate `_build_read_text_stub` in `test_validate_orchestration_artifacts_pr_creation_readiness.py`.
- Status line in `issue.md` cites a stale folder path.
