# Feature Audit: Test-support hygiene and stale skipif (#938)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938`
**Base Branch:** `origin/main`
**Head Branch:** `bug/test-support-hygiene-793-skipif-938`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit after remediation cycle 1

**Total blocking findings: 0.**

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `adb9aa5f0`)
- **Head branch/commit:** `bug/test-support-hygiene-793-skipif-938` (commit `653a2b709`)
- **Merge base:** `adb9aa5f0` (equals the `origin/main` tip)
- **Evidence sources:**
  - Primary: `git diff adb9aa5f0..HEAD` for `tests/` and `extensions/`, read directly by the reviewer
  - Feature evidence: `evidence/baseline/**`, `evidence/remediation-baseline/**`, `evidence/regression-testing/**`, `evidence/qa-gates/**`, `evidence/other/**`
  - Coverage: `artifacts/python/lcov.info` (93.8% line, 88.1% branch) and `extensions/drm-copilot/coverage/lcov.info` (97.27% line, 92.29% branch)
- **Feature folder used:** `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938`
- **Requirements source:** `issue.md` `## Acceptance Criteria` only (work mode `minor-audit`; `spec.md` and `user-story.md` are absent)
- **Work mode resolution note:** `issue.md` line 12 states `- Work Mode: minor-audit`.
- **Scope note:** `artifacts/pr_context.summary.txt` and the appendix were read at head `653a2b709`. No PR exists yet.

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
| AC-1 | Support module with both builders, verbatim | PASS | Support module present (60 lines, both builders at lines 12 and 54); `evidence/regression-testing/builder-equality-check.2026-10-16T00-37.md` shows equal output and docstrings | `git diff adb9aa5f0..HEAD -- tests` | Cycle 1 did not alter the support module |
| AC-2 | No `test_*.py` defines either builder | PASS | Reviewer Grep over `tests/` for both `def` tokens returns only the support module; `evidence/regression-testing/cycle1-builder-def-search.2026-10-16T01-37.md` agrees; the former private duplicate names are absent (`cycle1-private-stub-search`, exit 1 as expected) | `grep -rn -F -e "def build_valid_epic_state" -e "def build_read_text_stub" tests --include=*.py` | |
| AC-3 | No cross-test-module builder imports; four modules import from support module | PASS | `cycle1-importer-ast-negative` shows zero offending importers; `cycle1-importer-ast-positive` lists the importers; merge_status, dispatch, plan_gates, parallel_dispatch import from the support module | AST search commands in evidence | No re-export from a test module |
| AC-4 | Docstring and comment cite the support module | PASS | `cycle1-doc-citation-new-token` hits both files; `cycle1-doc-citation-stale-token` exit 1 as expected; reviewer diff shows the docstring in `test_validate_discovery_artifacts_dispatch.py` | grep evidence | |
| AC-5 | No `skipif` or `_requires_codex_runtime`; `import pytest` removed | PASS | Reviewer Grep count 0 on the parity file; `cycle1-parity-token-search` exit 1 as expected | `grep -c -E "skipif|_requires_codex_runtime|import pytest" <file>` | |
| AC-6 | Parity file: five passed, none skipped | PASS | `evidence/qa-gates/cycle1-pytest-parity-file.2026-10-16T01-42.md` (EXIT_CODE 0) and `cycle1-pytest-nine-files`: SKIPPED lines none | `poetry run pytest <file> -q -rs` | `.codex`/`.agents` content is tracked and not ignored |
| AC-7 | Named files pass; count not lower than baseline | PASS | Nine-file set: 127 collected and 127 passed, equal to the remediation baseline; full suite 7094 passed, 0 failed (`cycle1-pytest-full-suite`) | `poetry run pytest <files> -q -rs` | The run adds the parity and pr-creation-readiness files to the seven named files |
| AC-8 | Black, Ruff, Pyright clean on touched Python files | PASS | Earlier nine-file runs EXIT_CODE 0; cycle-1 `cycle1-black-check`, `cycle1-ruff-check`, `cycle1-pyright` EXIT_CODE 0 on the two files changed in cycle 1 | commands recorded in evidence | |
| AC-9 | TypeScript toolchain passes | PASS | `prettier-check`, `eslint`, `tsc-src`, `tsc-test`, `jest-epic-core` EXIT_CODE 0; `ts-jest-coverage.2026-10-16T01-42.md` EXIT_CODE 0 with 4002 tests passed | commands recorded in evidence | The TypeScript file was not edited in cycle 1 |
| AC-10 | Every touched file at most 500 lines | PASS | `line-counts.2026-10-16T00-48.md` maximum 475; `cycle1-line-counts` and reviewer `wc -l`: 195 and 101 | `wc -l` | |

---

## Summary

All ten acceptance criteria are PASS on the evidence and reviewer verification. The change is test-only, introduces no production code, and keeps the pre-change test count. The prior blocking finding (TypeScript coverage artifact absent) is closed: the artifact exists and reports 97.27% line and 92.29% branch coverage. The prior non-blocking items (duplicate private stub, stale `issue.md` status path) were resolved in commit `653a2b709`.

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

- `test_validate_orchestration_artifacts_dispatch.py` imports related builders from two modules; the other three builders are outside #938 scope.
- The TypeScript coverage run used the package script rather than the plan literal command; recorded as a deviation and independently reproduced.
