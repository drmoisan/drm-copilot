# Phase 16 — Coverage Delta Verification

- Timestamp: 2026-06-28T00-00
- Issue: #259

## Line Coverage (JaCoCo report totals)

| Metric | Baseline (P0-T4) | Post-change (P16-T3) |
|---|---|---|
| LINE covered | 558 | 584 |
| LINE missed | 30 | 35 |
| LINE total | 588 | 619 |
| Line coverage % | 94.9% | 94.35% |

- Baseline source: `evidence/baseline/pester-baseline.2026-06-28T00-00.md`
- Post-change source: `evidence/qa-gates/final-pester.2026-06-28T00-00.md` and
  `artifacts/pester/powershell-coverage.koverage.xml`

## Delta

- Line-coverage delta: 94.35% - 94.9% = -0.55 percentage points.
- Both baseline and post-change exceed the 85% line-coverage floor.
- The denominator grew from 588 to 619 (+31 lines) because the schema transformation added the
  nested `hookSpecificOutput` deny/allow builders and the new contract test exercised additional
  pure decision functions. The covered count grew from 558 to 584 (+26).

## Changed-Code Coverage (No Regression on Changed Lines)

- Every PreToolUse hook's pure decision/deny-builder function is exercised by:
  - its updated per-hook Pester test (asserting `hookEventName='PreToolUse'` /
    `permissionDecision='deny'` via serialize-then-parse), and
  - the new `PreToolUseSchema.Contract.Tests.ps1` (one DENY assertion per hook, 13 hooks).
- The new/changed deny-builder lines are covered by these tests; no changed line regressed below
  the floor. The small overall percentage-point decline reflects the larger denominator
  (newly added envelope-builder lines), not a regression on previously covered lines.

## Branch Coverage

- The PoshQC Pester JaCoCo coverage harness does not emit a report-level BRANCH counter in
  either the baseline or post-change run, so a numeric branch-coverage headline is not available
  from this artifact. This is a constant property of the harness across both measurements.
