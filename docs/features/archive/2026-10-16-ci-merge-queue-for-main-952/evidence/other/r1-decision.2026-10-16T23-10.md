# R1 decision record (AC-27, Codex helper coverage)

Timestamp: 2026-10-16T23-10
Decision: OPTION A, ACCEPT.
Authorizing party: the parallel-run coordinator (bug-burndown-2026-10-15), acting under the operator's standing authority, by directive to this item's orchestrator on 2026-10-16. Precedent: issue #935 (merged to main at cdc7bbc99), which resolved the same evidence class by a coordinator decision record and an amendment line under its acceptance criterion.

## Finding

Re-audit `remediation-inputs.2026-10-16T22-01.md` R1 (`human_decision_required`): AC-27 requires at least 85% line coverage for every new PowerShell file. On the full CI run (R_final_3 38967059138) `.codex/hooks/enforce-epic-merge-gate-command.ps1` measures 74.07% (40/54), while its byte-identical Claude copy measures 100.00% and every other file meets the thresholds.

## Basis

- `evidence/regression-testing/codex-helper-scoped-coverage.2026-10-16T21-56.md`: a scoped `tests/scripts/codex-hooks` run credits the Codex helper at 100.00% (54/54); all fourteen disputed lines are executed and credited; 1806 tests pass.
- `evidence/regression-testing/codex-helper-coverage-diagnosis.2026-10-16T20-01.md`: each uncredited line is mapped to the passing Codex rows that execute it.
- `evidence/qa-gates/coverage-comparison.2026-10-16T21-28.md`: the full-run figure and the ATTRIBUTION-LIMITED disposition under the issue #936 breakpoint-binding mechanism.
- `remediation-inputs.2026-10-16T22-01.md`: the reviewer's evidence assessment and option list.

The full-run 74.07% is therefore the issue #936 breakpoint attribution effect, not untested code.

## Effect

An amendment line is added beneath AC-27 in `spec.md` (criterion text unchanged). The 85% floor, the no-regression clause, and the no-exclusion rule still apply. Issue #953 (profiler-mode coverage, `UseBreakpoints = $false`) merged to main at 475bb06d5 and is merged into this branch; if the pull-request CI run measures the Codex helper at or above 85% in the full run, AC-27 is recorded as met outright and the amendment no longer applies.
