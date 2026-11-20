# Coverage delta — baseline versus final, per language

Timestamp: 2026-09-07T19-35

All values are numeric. Sources: Python baseline [P0-T7]
(`evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md`) and final [P8-T5]
(`evidence/qa-gates/final-python-pytest-coverage.2026-09-07T18-40.md`); TypeScript baseline [P0-T11]
(`evidence/baseline/typescript-jest-coverage.2026-09-07T15-20.md`) and final [P8-T9]
(`evidence/qa-gates/final-typescript-jest-coverage.2026-09-07T18-54.md`); PowerShell baseline
[P0-T14] (`evidence/baseline/powershell-poshqc-test.2026-09-07T15-25.md`) and final [P8-T12]
(`evidence/qa-gates/final-powershell-poshqc-test.2026-09-07T19-25.md`).

Thresholds applied: line/statement >= 85; branch >= 75 where the tooling measures branches; per-file
new-code >= 85; no run-level value below its baseline by more than 0.5 percentage points.

## Python (pytest-cov, `--cov=scripts.dev_tools --cov-branch`)

| Metric | Baseline | Final | Delta | Threshold | Met |
| --- | --- | --- | --- | --- | --- |
| Statement coverage | 92.71 | 92.72 | +0.01 | >= 85 | yes |
| Branch coverage | 85.30 | 85.32 | +0.02 | >= 75 | yes |

Source integers: baseline `covered_lines` 14101 / `num_statements` 15210 and `covered_branches` 4758
/ `num_branches` 5578; final 14131 / 15241 and 4771 / 5592.

New-module rows (terminal `Cover` column, the single combined column pytest-cov prints):

| Module | Final `Cover` | Threshold | Met |
| --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_mergeable.py` | 95 | >= 85 (new code) | yes |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 100 | >= 85 (new code) | yes |

Neither module existed in the baseline in its current form: `_blast_radius_mergeable.py` is new and
`_blast_radius_conflicts.py` gained the exclusion filter, so the baseline column is not applicable to
them and only the final value is gated.

## TypeScript (Jest, `--coverageReporters=text`)

| Metric (`All files` row) | Baseline | Final | Delta | Threshold | Met |
| --- | --- | --- | --- | --- | --- |
| `% Lines` | 96.72 | 96.73 | +0.01 | >= 85 | yes |
| `% Branch` | 90.17 | 90.19 | +0.02 | >= 75 | yes |

Named rows:

| File | Baseline `% Lines` | Final `% Lines` | Baseline `% Branch` | Final `% Branch` | Met |
| --- | --- | --- | --- | --- | --- |
| `claude-blast-radius-derive-manifests.ts` | n/a (file did not exist) | 100 | n/a | 95.65 | yes |
| `claude-blast-radius-derive-core.ts` | 100 | 100 | 95.83 | 97.5 | yes |

`claude-blast-radius-derive-manifests.ts` is created by this plan, so it has no baseline row; its
final values are gated against the >= 85 line and >= 75 branch thresholds and additionally against
the per-file `coverageThreshold` entry [P4-T3] added to `jest.config.cjs`, which Jest enforces by
exiting non-zero. `claude-blast-radius-derive-core.ts` rose 1.67 branch points after the manifest
constants moved out of it.

## PowerShell (Pester via PoshQC, JaCoCo `LINE` counters)

| Metric | Baseline | Final | Delta | Threshold | Met |
| --- | --- | --- | --- | --- | --- |
| Report-level line coverage | 94.80 | 94.89 | +0.09 | >= 85, and not below baseline by more than 0.5 | yes |

Source integers: baseline `covered` 7427 / `missed` 407; final `covered` 7757 / `missed` 418.

Per-`sourcefile` rows for the five PowerShell production files of this plan:

| File | Baseline | Final | covered / missed | Threshold | Met |
| --- | --- | --- | --- | --- | --- |
| `BlastRadius.psm1` | 100.00 | 100.00 | 97 / 0 | >= 85, not below baseline | yes |
| `BlastRadiusConflict.psm1` | n/a (file did not exist) | 97.67 | 42 / 1 | >= 85 (new code) | yes |
| `ProjectFileMergeGrammar.psm1` | n/a (file did not exist) | 99.18 | 121 / 1 | >= 85 (new code) | yes |
| `ProjectFileMerge.psm1` | n/a (file did not exist) | 100.00 | 124 / 0 | >= 85 (new code) | yes |
| `Resolve-MergeableConflict.ps1` | n/a (file did not exist) | 86.15 | 56 / 9 | >= 85 (new code) | yes |

No branch column appears for PowerShell: Pester measures no branch coverage and the JaCoCo report
carries no `BRANCH` counter for these sources, so the branch threshold is not evaluable and does not
apply, per `.claude/rules/quality-tiers.md`. That is a threshold exemption only; every PowerShell
production file remains in the coverage denominator.

## Summary

Every final value meets its threshold. Every per-file new-code value is at or above 85. No run-level
value is below its baseline at all, let alone by more than 0.5 percentage points: all three run-level
metrics rose.
