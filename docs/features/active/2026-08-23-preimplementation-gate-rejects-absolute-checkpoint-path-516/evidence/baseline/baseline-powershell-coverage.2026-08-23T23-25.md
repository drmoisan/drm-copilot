# Baseline — PowerShell Per-File Line Coverage (issue #516)

Timestamp: 2026-08-24T15-27
Command: read the per-class `<counter type="LINE" ...>` elements from `artifacts/pester/powershell-coverage.xml` (JaCoCo 1.1, report name `Pester (08/24/2026 15:16:03)`) produced by the [P0-T10] full-suite run
EXIT_CODE: 0

## Per-File Line Coverage — the two canonical hook copies

| File | Lines covered | Lines missed | Total lines | Line coverage |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 99 | 11 | 110 | **90.00%** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 121 | 1 | 122 | **99.18%** |

## Aggregate Line Coverage

| Scope | Lines covered | Lines missed | Total lines | Line coverage |
| --- | --- | --- | --- | --- |
| Whole configured coverage set (report-level counter) | 6407 | 255 | 6662 | **96.17%** |

The report-level `<counter type="LINE">` and the sum over every `<class>` node agree exactly (6407 covered / 255 missed in both), so the aggregate figure is internally consistent.

## Threshold Position at Baseline

The uniform line-coverage threshold under `.claude/rules/quality-tiers.md` is **>= 85%**. Both canonical hook copies are above it at baseline:

- `.claude` copy: 90.00% — 5.00 percentage points of headroom.
- `.codex` copy: 99.18% — 14.18 percentage points of headroom.

Because neither baseline is below 85%, the [P4-T7] conditional clause covering a pre-existing shortfall is not triggered for either file; the plain >= 85% per-file gate is the binding condition at [P4-T7], alongside the no-regression-against-baseline comparison in [P4-T8].

PowerShell is exempt from the >= 75% branch-coverage threshold under `.claude/rules/quality-tiers.md` because Pester does not measure branch coverage. Both hook copies remain in the line-coverage denominator; neither appears in any coverage exclusion list.

Output Summary: Baseline per-file line coverage is 90.00% (99/110) for `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and 99.18% (121/122) for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, with an aggregate of 96.17% (6407/6662). All three values are recorded as numbers read directly from the JaCoCo counters; no value is a placeholder. Both per-file values exceed the uniform 85% line threshold at baseline.
