# P0-T14 Baseline Gate Summary

Timestamp: 2026-09-27T03-34

Source artifacts: `evidence/baseline/p0-poshqc-format.md`, `evidence/baseline/p0-poshqc-analyze.md`, `evidence/baseline/p0-scoped-coverage.md`, `evidence/baseline/p0-pester-full.md`, `evidence/baseline/p0-pytest-push-down.md`.

## Halting checks

| Check | Condition | Result |
| --- | --- | --- |
| [P0-T9] | `FORMAT_CHANGED_COUNT: 0` | GREEN |
| [P0-T10] | `ANALYZE_RESULT: passed` | GREEN |
| [P0-T11] | no `FAILED:` line in the Parity or legacy-codex suite; both `percent=` values at least 85 (97.08, 97.08) | GREEN |
| [P0-T12] | no `JUNIT_FAILED:` entry for the Parity or legacy-codex test file | GREEN |
| [P0-T13] | no failed node in the four skill-document suites | GREEN |

## Recording checks (rule 12, no halt)

| Check | Condition | Result |
| --- | --- | --- |
| [P0-T11] | `FailedCount: 0` | GREEN |
| [P0-T12] | `JUNIT_FAILURES: 0` and `JUNIT_ERRORS: 0` | GREEN |
| [P0-T13] | no failed node | GREEN |

All halting rows read GREEN. B_SCOPED and B_FULL are both empty. Execution proceeds to Phase 1.
