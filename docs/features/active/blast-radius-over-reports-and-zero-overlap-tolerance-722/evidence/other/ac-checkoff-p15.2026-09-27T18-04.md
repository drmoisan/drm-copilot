# Acceptance-criteria Check-off, Phase 15 (P15-T6)

Timestamp: 2026-09-27T18-04
Command: edit of FEATURE/spec.md (the AC-34 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-34 (spec line 692, the 34th checkbox line of the Acceptance Criteria section, confirmed by counting checkbox lines in document order). Its traceability row cites evidence/qa-gates/final-python-pytest-coverage.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-34 | Python toolchain and coverage | evidence/qa-gates/final-python-pytest-coverage | FEATURE/evidence/qa-gates/final-python-pytest-coverage.2026-09-27T18-03.md; FEATURE/evidence/qa-gates/final-python-black.2026-09-27T18-00.md; FEATURE/evidence/qa-gates/final-python-ruff.2026-09-27T18-00.md; FEATURE/evidence/qa-gates/final-python-pyright.2026-09-27T18-01.md; FEATURE/evidence/qa-gates/python-coverage-delta.2026-09-27T18-03.md |

## Verification against the criterion text

- Single pass: black (write run "501 files left unchanged.", check run exit 0), ruff ("All checks passed!", exit 0), pyright ("0 errors", exit 0), and pytest ran in order with no file changed and no restart.
- pytest: 5272 passed, 5 skipped; the one failure is the KL-510 node with a state-only failure (case (b)), which the plan's Terms accept as the known local failure of issue #510 that does not occur in CI.
- Coverage on every new or changed Python production file: all six B38 files >= 85% line and >= 75% branch (lowest 97.98 / 95.24).
- No regression on changed lines: the three pre-existing files stay at 100.00 / 100.00 and every changed-line percent is 100.00.
