# Acceptance-criteria Check-off, Phase 18 (P18-T4)

Timestamp: 2026-09-27T18-17
Command: edit of FEATURE/spec.md (the AC-21 and AC-37 checkboxes changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: Two criteria checked off in FEATURE/spec.md: AC-21 (spec line 643) and AC-37 (spec line 698), the 21st and 37th checkbox lines of the Acceptance Criteria section, confirmed by counting checkbox lines in document order. AC-38 (CI green) remains unchecked; it is checked off by P18-T7 after CI, which is outside this execution's scope.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-21 | drift module not grown; drift tests unmodified | evidence/qa-gates/drift-tests-unmodified | FEATURE/evidence/qa-gates/drift-tests-unmodified.2026-09-27T15-26.md; FEATURE/evidence/qa-gates/final-line-counts.2026-09-27T18-14.md; FEATURE/evidence/qa-gates/final-python-pytest-coverage.2026-09-27T18-03.md; FEATURE/evidence/qa-gates/scope-check.2026-09-27T18-17.md |
| AC-37 | 500-line limit and batch budgets | evidence/qa-gates/batch-accounting | FEATURE/evidence/qa-gates/batch-accounting.2026-09-27T18-16.md; FEATURE/evidence/qa-gates/final-line-counts.2026-09-27T18-14.md |

## Verification against the criterion text

- AC-21: scripts/dev_tools/parallel_drift_detection.py is 460 lines, below its P0-T13 value of 499. The only drift test file in the FINAL_BASE-anchored diff is the new tests/scripts/dev_tools/test_parallel_drift_scheduling.py (scope-check); no existing drift test file is modified (drift-tests-unmodified), and the full Python suite of P15-T4 passed apart from the KL-510 state-only node, so every existing drift test passes unmodified.
- AC-37: every production and test code file written by this plan is at most 500 lines (final-line-counts; files above 500 are Markdown documentation and JSON test fixtures, which the policy exempts), and every batch holds at most 3 production and 3 test files of one language (batch-accounting).
