# Code Review: Test-support hygiene and stale skipif (#938)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938`
**Base Branch:** `origin/main` (`adb9aa5f0`)
**Head Branch:** `bug/test-support-hygiene-793-skipif-938` (`91044a5b7`)
**Review Type:** Initial review

**Total blocking findings: 1.**

---

## Executive Summary

The change is a verbatim extraction of two test builders into `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py`, import repointing in five test modules, citation updates in one Python docstring and one TypeScript comment, and removal of a stale `skipif` guard together with the now-unused `import pytest`. No production file changed.

Evidence reviewed: the full `git diff adb9aa5f0..HEAD -- tests extensions`, the support module text, `evidence/regression-testing/builder-equality-check` (old and new builders compare equal, docstrings included), the AST importer searches, the baseline and final eight-file pytest runs (125 collected and passed in both), the parity-file run (5 passed, none skipped), tracked-file evidence for `.codex`/`.agents` (171 tracked, not ignored), and the line-count evidence.

Correctness observations:
- The removed `TYPE_CHECKING` block in `test_validate_orchestration_artifacts.py` is safe: `Callable` and `Path` were used only by the removed stub. `cast` is still imported and used.
- The new support module keeps `Callable` and `Path` under `TYPE_CHECKING` with `from __future__ import annotations`, consistent with the repository style.
- `test_validate_orchestration_artifacts_dispatch.py` still imports its other builders from `test_validate_orchestration_artifacts`; that is outside the AC scope (the AC covers only the two named builders).
- Removing `skipif` makes two parity tests unconditional. This is correct because the `.codex/agents` and `.agents/skills` trees are tracked (171 files) and `git check-ignore` returns exit 1 for sample paths, so a clean CI checkout contains them.

**Top risks:**
1. The TypeScript coverage artifact is absent for the one changed TypeScript file (CR-1); this is a contract gap, not a defect in the change.
2. A private duplicate stub remains in `test_validate_orchestration_artifacts_pr_creation_readiness.py` (CR-2).
3. Two now-unconditional parity tests will fail on a checkout that lacks the `.codex`/`.agents` trees; this is intended behavior for a tracked-content parity check.

**PR readiness recommendation:** **Not ready until CR-1 is closed.**

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` | line 9 | The branch changes this TypeScript file, but `coverage/lcov.info` does not exist and no evidence file records TypeScript coverage. The reviewer contract requires an artifact and thresholds for every language with changed files. | Run jest with coverage in `extensions/drm-copilot`, store the result in an evidence file under `<FEATURE>/evidence/qa-gates/`, and report repo-wide line and branch percentages against 85% and 75%. | Coverage verification is mandatory per language with changed files; the comment-only change cannot lower coverage, so the likely outcome is a pass. | `Glob coverage/lcov.info` returned no file; `evidence/qa-gates/jest-epic-core.2026-10-16T00-48.md` records `npx jest --config jest.config.cjs <file>` with no `--coverage` |
| Minor (Non-blocking) | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py` | line 28 | Private `_build_read_text_stub` duplicates the shared `build_read_text_stub`. | Optionally import the shared builder in a later change. | Reduces duplication; not part of #938 acceptance criteria, which name only the public builder. | `Grep` for `build_read_text_stub` in `tests/` |
| Nit (Non-blocking) | `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/issue.md` | line 5 | Status line cites `docs/features/active/test-support-hygiene-793-skipif/`, a path that does not match the actual folder. | Optionally correct the path. | Documentation accuracy. | `Glob` of the feature folder |
| Nit (Non-blocking) | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` | lines 17-25 | Imports from two modules for related builders (`test_validate_orchestration_artifacts` and the support module). | None required. | The remaining three builders were not in scope. | `git diff` |

---

## Detailed Review Notes

- **Design:** shared fixtures now live in a `*_test_support.py` module in the mirrored `tests/` tree, satisfying the test-location rule. No colocation in `src/`.
- **Error handling and logging:** not applicable; no behavior change.
- **File size:** all touched files at most 500 lines (largest 475).
- **Suppressions:** none added.
- **Security:** no secrets, no network, no file creation in tests.
