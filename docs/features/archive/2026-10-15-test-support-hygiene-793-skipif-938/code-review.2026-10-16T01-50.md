# Code Review: Test-support hygiene and stale skipif (#938)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938`
**Base Branch:** `origin/main` (`adb9aa5f0`)
**Head Branch:** `bug/test-support-hygiene-793-skipif-938` (`653a2b709`)
**Review Type:** Re-review after remediation cycle 1

**Total blocking findings: 0.**

---

## Executive Summary

The change is a verbatim extraction of two test builders into `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py`, import repointing in the dependent test modules, citation updates in one Python docstring and one TypeScript comment, and removal of a stale `skipif` guard together with the now-unused `import pytest`. Remediation cycle 1 replaced the two remaining private stub duplicates (`_stub_read_text` in `test_validate_discovery_artifacts_dispatch.py` and `_build_read_text_stub` in `test_validate_orchestration_artifacts_pr_creation_readiness.py`) with the shared `build_read_text_stub`, corrected the `issue.md` status path, and recorded TypeScript coverage evidence. No production file changed.

Evidence reviewed: `git diff adb9aa5f0..HEAD --stat -- tests extensions`, the cycle-1 diff `91044a5b7..HEAD -- tests extensions`, Grep over `tests/` for definitions and stale private names, the parity file token count, the extension and Python lcov artifacts, and the cycle-1 evidence files (nine-file pytest 127 collected and passed, full suite 7094 passed, Black, Ruff, Pyright, scope boundary).

Correctness observations:
- The cycle-1 replacement is behavior-preserving: both removed private stubs returned the same closure as `build_read_text_stub`. Removed `TYPE_CHECKING` imports of `Callable` and `Path` in `test_validate_orchestration_artifacts_pr_creation_readiness.py` are safe because only the removed stub used them; Pyright and Ruff exit 0.
- In `test_validate_discovery_artifacts_dispatch.py`, `Callable` and `Path` remain imported under `TYPE_CHECKING` because other code in the module still uses them (Pyright and Ruff exit 0).
- The prior blocking finding (CR-1, TypeScript coverage artifact absent) is closed: `extensions/drm-copilot/coverage/lcov.info` totals 97.27% line and 92.29% branch.
- Removing `skipif` makes two parity tests unconditional. This is correct because the `.codex/agents` and `.agents/skills` trees are tracked and not ignored.

**Top risks:**
1. Two now-unconditional parity tests fail on a checkout that lacks the `.codex`/`.agents` trees; this is intended behavior for a tracked-content parity check.
2. `test_validate_orchestration_artifacts_dispatch.py` imports related builders from two modules (see the Nit below).

**PR readiness recommendation:** **Ready.**

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Nit (Non-blocking) | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` | import block | Imports related builders from two modules (`test_validate_orchestration_artifacts` and the support module). | None required in #938. | The remaining three builders were outside the acceptance criteria. | `git diff adb9aa5f0..HEAD` |
| Nit (Non-blocking) | `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/evidence/qa-gates/ts-jest-coverage.2026-10-16T01-42.md` | Note line | The coverage command was the package script `test:coverage` rather than the plan literal `npx jest ... --coverage`, recorded as a deviation. | None required. | The script runs the same Jest project and reporters; reviewer awk over the lcov file reproduces the recorded totals within rounding. | `extensions/drm-copilot/coverage/lcov.info` |

---

## Detailed Review Notes

- **Design:** shared fixtures live in a `*_test_support.py` module in the mirrored `tests/` tree, satisfying the test-location rule. No colocation in `src/`. The shared stub builder now has a single definition (Grep over `tests/` returns only the support module).
- **Error handling and logging:** not applicable; no behavior change.
- **File size:** all touched files at most 500 lines (largest 475; cycle-1 files 195 and 101).
- **Suppressions:** none added.
- **Security:** no secrets, no network, no file creation in tests.
- **Evidence placement:** all evidence is under `<FEATURE>/evidence/<kind>/`; no `artifacts/` path in the branch diff.
