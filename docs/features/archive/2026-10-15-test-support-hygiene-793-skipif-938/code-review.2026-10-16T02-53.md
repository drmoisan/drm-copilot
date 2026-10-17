# Code Review: Test-support hygiene and stale skipif (#938)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938`
**Base Branch:** `origin/main` (merge base `97559c3e0`)
**Head Branch:** `bug/test-support-hygiene-793-skipif-938` (`c8281987b`)
**Review Type:** Re-review after remediation cycle 2

**Total blocking findings: 0.**

---

## Executive Summary

Cycle 2 moves three shared builders (`build_valid_orchestrator_state`, `build_valid_policy_audit_text`, `build_complete_large_orchestrator_state`) out of `test_validate_orchestration_artifacts.py` into `validate_orchestration_artifacts_test_support.py`, and repoints `test_validate_orchestration_artifacts_dispatch.py` and `test_validate_orchestration_artifacts_state_shape.py`. The dispatch test now imports every shared builder only from the support module. The old module retains one import (`build_valid_policy_audit_text`) from the support module and re-exports nothing. Combined with the earlier cycles, the branch is a test-only change: no production file is touched.

Evidence reviewed: `git diff --stat HEAD~1 HEAD`, `git diff --name-only origin/main...HEAD`, direct reads of the dispatch and old-module import blocks, Grep over `tests/` for importers of the old module (none), `wc -l` of the five files, and cycle 2 evidence (AST equality of moved builders, importer AST searches, Black, Ruff, Pyright, ten-file pytest 135 passed equal to baseline, full suite 7099 passed and 6 skipped, scope boundary).

Correctness observations:
- The moved builders are AST-identical to their pre-move definitions (`evidence/regression-testing/cycle2-builder-equality.2026-10-16T02-36.md`), and the ten-file group's coverage of `validate_orchestration_artifacts.py` is identical before and after (149/9/56/5).
- `build_valid_epic_orchestrator_state` remains defined locally in the dispatch test. It is a different builder from the three moved ones and was outside RI-3, so it is not a finding.
- The dispatch module carries a comment explaining why `get_first_receipt` is not imported; the comment is accurate and not harmful.
- The Pyright failure at 02-41 was environmental (missing `.venv` dependencies); the 02-50 rerun is clean.

**Top risks:** none material. The support module (285 lines) is a shared dependency of seven test modules, so a later edit to a builder affects all of them; this is the intended design.

**PR readiness recommendation:** **Ready.**

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Nit (Non-blocking) | `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/evidence/qa-gates/cycle2-pyright.2026-10-16T02-41.md` | whole file | Superseded evidence recording an environmental Pyright failure remains alongside the passing 02-50 rerun. | None required. | The 02-51 loop artifact states the supersession explicitly. | `cycle2-final-loop-single-pass.2026-10-16T02-51.md` |

---

## Detailed Review Notes

- **Design:** shared fixtures live in `*_test_support.py` under the mirrored `tests/` tree. No test module imports from another builder-owning test module for the moved names; no re-export.
- **Error handling and logging:** not applicable; no behavior change.
- **File size:** 285 (support), 144 (old module), 278 (dispatch), 154 (state_shape); all at most 500.
- **Suppressions:** none added.
- **Security:** no secrets, network, or temporary files.
- **Evidence placement:** all under `<FEATURE>/evidence/<kind>/`; validated by `validate_evidence_locations.py` (exit 0).
- **Out of scope:** same-named builders in `test_validate_orchestrator_state_remediation_loop.py` and `test_validate_policy_audit_artifact.py` are pre-existing independent definitions in other modules and were not part of RI-2 or RI-3.
