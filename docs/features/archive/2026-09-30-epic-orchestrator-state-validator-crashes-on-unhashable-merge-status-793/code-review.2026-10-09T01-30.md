# Code Review: Epic Orchestrator-State Validator merge_status Guards (Issue #793)

- Timestamp: 2026-10-09T01-30
- Reviewed HEAD: dfad6bdeb against origin/main
- Files reviewed: `scripts/dev_tools/validate_epic_orchestrator_state.py` (modified), `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` (new), `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts` (new)

## Executive Summary

Verdict: APPROVE. Blocking findings: 0.

The production change is two minimal, correct `isinstance(merge_status, str)` guards placed before set-membership tests. Short-circuit order is correct, so the hash never occurs on a non-string. `None` handling is preserved at both sites (skipped by the enum check, reported by the completion check, because `None` is not a `str`). int and bool values remain errors with identical text. No broad `except` was introduced. The tests exercise both new branches through the private functions, the public entry point, and the CLI exit code, and a fail-before run demonstrates they detect the defect. Five low or informational observations follow; none requires remediation.

Typed-Python review: guards narrow `Any` to `str` for the membership test; pyright reports 0 errors. Test helpers avoid suppressions by using `cast` and `vars(module)[name]`.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev_tools/validate_epic_orchestrator_state.py` | lines 238-240, 323-324 | Correct guard placement and short-circuit order; local `merge_status` variable avoids a second `feature.get` call. | None. | Meets spec design summary; bool/int behavior unchanged. | `git diff origin/main...HEAD`; `guard-literal-count.md` shows 2 occurrences. |
| Low | `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` | `test_enum_site_accepts_every_valid_string_status` | A loop inside one test stops at the first failing status; the status name is only the assert message. | Optionally convert to `pytest.mark.parametrize` over `sorted(VALID_MERGE_STATUS)` for per-status reporting. | Improves failure isolation; behavior is already covered. | File lines 154-163. |
| Low | `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` | `test_completion_site_reports_non_string_merge_status` | `expected_repr` is used only as the assert message, so the parameter does not affect the check. | Drop the unused parameter from this test or assert on it. | Removes an unused parametrization column. | File lines 98-108. |
| Low | `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` | imports of `build_valid_epic_state` and `build_read_text_stub` | The new test module imports helpers from two sibling test modules, coupling their layout. | Consider moving shared builders to a test-support module when a third consumer appears. | Existing sibling file is at 496 lines (spec D-3), so reuse by import is a reasonable trade-off now. | Spec Decision D-3; import block lines 17-24. |
| Info | `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts` | whole file | Parity tests pass on first run, as expected for an already-correct TS port; they are non-regression pins, not defect detectors. | None; spec D-4 documents this. | Fail-before evidence exists only for Python. | `ts-parity-new-file.md`; spec D-4. |
| Info | `spec.md` | Repro step 1 | The documented repro uses key `folder` while the validator reads `feature_folder`, so the output shows `<unknown>`. | None required; the executor noted this in `repro-after-enum-list.md`. | Documentation nit; does not affect the fix. | `repro-after-enum-list.md`. |

## Review Dimensions

- Correctness: PASS. Re-ran the three related Python test files: 78 passed. Both guarded conditions evaluate as specified for str, None, list, dict, int, bool.
- Design and simplicity: PASS. Inline guards, no helper, no widened diff; matches the #659 pattern.
- Error handling: PASS. Reuses existing error strings; no exception swallowing.
- Test quality: PASS with the Low observations above. Determinism and isolation are met; no file, clock, or network use.
- Coverage: PASS. Changed module 93.75% line and 87.10% branch; changed lines fully covered; no regression (`coverage-delta.md`; lcov re-read by reviewer).
- Size: PASS. 431, 219, and 102 lines.
- Security: no impact; the change rejects malformed input more safely.
- Tone: neutral.

## Blocking Findings

None.
