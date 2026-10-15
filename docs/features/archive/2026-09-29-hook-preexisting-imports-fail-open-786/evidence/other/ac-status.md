# AC Status ([P12-T28]; rewritten by remediation cycle 1 [P6-T5])

Timestamp: 2026-10-10T18-43

### Acceptance Criteria Status
- Source: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md (Work Mode full-bug; spec.md only)
- Total AC items: 27
- Checked off (delivered): 27
- Remaining (unchecked): 0
- Items remaining: none

Superseded: the [P12-T6] AC-6 gap rule of the main plan no longer applies after the 2026-10-10 AC-6 amendment (spec.md Change Log).
Plan-check note: main-plan [P9-T7] (c) is stricter than AC-26; AC-26 is checked off on the reviewer's evaluation.
AC-24 note: evaluated under the orchestrator decision of 2026-10-10 (evidence/other/r1-ac24-decision.md); PS-SET files from the per-surface measurement (evidence/qa-gates/r1-ac24-per-surface.md), all other files from the combined run (evidence/qa-gates/final-pester-coverage.md, evidence/qa-gates/coverage-comparison.md).

Remediation cycle 1 check-offs:
- AC-6: checked off by [P6-T2] after [P6-T1] (evidence/qa-gates/r1-ac6-verify.md) on the amended criterion (spec.md Change Log 2026-10-10).
- AC-24: checked off by [P6-T3] after [P3-T6] and the pass 1 [P5-T3] and [P5-T4] acceptances (evidence/qa-gates/r1-final-qc-loop.md). The six PS-SET files read 95.78, 95.86, 100.00, 100.00, 100.00, and 98.73 per surface, with no lost changed line; their combined-run figures (74.70, 82.25, 57.89, 80.25, 86.55, 98.09) are retained unchanged in final-pester-coverage.md and coverage-comparison.md.
- AC-17: unchanged and confirmed by [P6-T4] (evidence/qa-gates/r1-ac17-confirm.md).
- AC-26 and AC-27 were checked off by the reviewer before this cycle (feature-audit.2026-10-10T06-50.md).

Verification: `^- \[x\] AC-\d+:` matches 27 lines in spec.md, and `^- \[ \] AC-\d+:` matches 0 lines (sum 27).

Remediation cycle 2 note: CI-1 (Linux hook-suite failures on PR #881) closed by test-only fixes (evidence/other/r2-ci-diagnosis.md); AC-17, AC-24, and AC-27 re-verified (evidence/qa-gates/r2-preexisting-tests.md, evidence/qa-gates/r2-final-pester-coverage.md, evidence/qa-gates/r2-ac24-per-surface.md, evidence/qa-gates/r2-final-qc-loop.md, evidence/qa-gates/r2-pr-checks.md).
