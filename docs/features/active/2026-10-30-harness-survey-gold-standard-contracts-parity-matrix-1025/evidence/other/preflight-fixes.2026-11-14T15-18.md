# Preflight Fixes (Plan A, Issue #1025)

- Timestamp: 2026-11-14T15-18
- Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/plan.2026-10-30T17-06.md
- Scope: single-pass preflight of plan A (version 3.0, refreshed 2026-11-14); plan B not edited.
- Plan snapshot before fixes: SCRATCH/issue-1025-plan-snapshot.2026-11-14T15-07.md

## Fixes

1. `## Gate Shape` | validator-blind defect (coverage source on a non-green parallel run) | Added a `Coverage source (P0-T3, P2-T6, P4-T2)` bullet. `Invoke-PoshQCParallelTest` writes `artifacts/pester/powershell-coverage.xml` only after a fully green run and a failed run can leave an older merged file in place, while the plan's pass condition allows failures already present in `pester-baseline`. Coverage is now read from the merged file only when the returned `ExitCode` is 0, and otherwise from the per-shard coverage files under `artifacts/pester/parallel/` merged with `Merge-PoshQCCoverageReport` (exported by `scripts/powershell/PoshQC/PoshQC.psd1`). The asserted figures are unchanged.
2. `[P2-T3]` | enumeration omission (meaning unchanged) | The parenthetical list of failure-case Its omitted two cases that the lead clause ("one It per failure case of spec AC `Completeness unit tests: failure cases`") already requires and that user-story criterion `The completeness gate fails on` names: an inventoried feature with no entry, and an entry without `disposition`. Both added to the parenthetical.
3. `[P4-T6]` | task text and acceptance disagree on the artifact set (meaning unchanged) | The acceptance names `<FEATURE>/evidence/qa-gates/no-new-python.<timestamp>.md`, which the task text did not say to write. The task text now names both artifacts.
