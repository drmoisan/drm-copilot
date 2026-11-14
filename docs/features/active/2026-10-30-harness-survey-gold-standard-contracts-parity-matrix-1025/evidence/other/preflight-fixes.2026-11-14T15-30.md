# Preflight Fixes (Plan A, Issue #1025, Round 2)

- Timestamp: 2026-11-14T15-30
- Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/plan.2026-10-30T17-06.md
- Scope: confirming single-pass preflight of plan A after the planner revision committed as "docs(1025): revise plan A for preflight design-check defects"; plan B and spec.md not edited.
- Plan snapshot before fixes: SCRATCH/issue-1025-plan-snapshot.2026-11-14T15-29.md
- Earlier record (unchanged): evidence/other/preflight-fixes.2026-11-14T15-18.md

## Fixes

1. `[P0-T3]`, `[P2-T6]`, `[P4-T2]` | sibling inconsistency with the `## Gate Shape` coverage-source bullet (meaning unchanged) | The round 1 fix added the `Coverage source (P0-T3, P2-T6, P4-T2)` bullet, but the three task texts still named `artifacts/pester/powershell-coverage.xml` as the only source. Each now reads coverage from the `## Gate Shape` coverage source, and P0-T3 records which source was used, as that bullet already requires. The asserted figures and thresholds are unchanged.
