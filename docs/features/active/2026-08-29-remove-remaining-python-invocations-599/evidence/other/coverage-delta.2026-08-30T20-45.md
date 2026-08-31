# P6-T14 — Coverage delta across the three in-scope languages

Timestamp: 2026-08-30T20-45

Sources: `evidence/baseline/bash-coverage.2026-08-30T06-22.md` (P0-T3),
`evidence/baseline/python-lane-assertion-coverage.2026-08-30T06-22.md` (P0-T7),
`evidence/baseline/ts-coverage.2026-08-30T06-22.md` (P0-T12),
`evidence/qa-gates/final-bash-coverage.2026-08-30T20-45.md` (P6-T4),
`evidence/qa-gates/bash-new-file-coverage.2026-08-30T20-45.md` (P6-T5),
`evidence/qa-gates/final-python-coverage.2026-08-30T20-45.md` (P6-T9),
`evidence/qa-gates/final-ts-coverage.2026-08-30T20-45.md` (P6-T12).

## Bash

| Measure | Value |
| --- | --- |
| Baseline (P0-T3) | 91.4% lines, over 251 bats cases |
| Post-change (P6-T4) | 92.3% lines, over 290 bats cases |
| Movement | +0.9 points |
| New code — `.claude/lib/bash/parallel-lane-assertion.sh` (P6-T5) | `line-rate="0.989"` |
| New code — `.claude/lib/bash/report-lane-assertion.sh` (P6-T5) | `line-rate="0.949"` |

No decrease. Both new-code figures are at or above the 85% floor.

kcov measures **line coverage only**. It emits no BRANCH counter for bash, and
`.claude/rules/quality-tiers.md` applies no branch-coverage gate to bash for exactly that reason.
This is an explicit absence note, not a placeholder for an available metric. The exemption is a
threshold exemption only: both new bash files remain in the coverage denominator, and P6-T5
records that no per-file exclusion mechanism exists on the bash path — the kcov exclude pattern
is `$repo_root/tests` only (`scripts/bash/shell_qc_lib.sh:336`).

The +0.9 point movement and the +39 case movement are both attributable to the P6-T5
remediation, which added the 14-case suite `tests/shell/report_lane_assertion_dispatch.bats`.
The remaining 25 cases of the 39 were added by earlier phases of this plan between the P0-T3
baseline and this phase.

## Python

| Measure | Value |
| --- | --- |
| Baseline (P0-T7), `scripts/dev_tools/parallel_lane_assertion.py` | 100% — 143 statements, 0 missed |
| Post-change (P6-T9), same file | 100% — 143 statements, 0 missed |
| Movement | none |
| New code | not applicable |

No decrease.

The new-code figure is not applicable because **this feature adds no Python production file**.
It adds one Python test file, `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py`
(P3-T8), and test files are excluded from the coverage denominator by design. The no-regression
check for Python is therefore the comparison of the two values above, which are identical at
100% over an unchanged 143-statement denominator.

## TypeScript

| Metric | Baseline (P0-T12) | Post-change (P6-T12) | Movement |
| --- | --- | --- | --- |
| Statements | 96.72% (44234/45730) | 96.72% (44234/45730) | none |
| Branches | 90.17% (6297/6983) | 90.17% (6297/6983) | none |
| Functions | 89.93% (1295/1440) | 89.93% (1295/1440) | none |
| Lines | 96.72% (44234/45730) | 96.72% (44234/45730) | none |

No decrease. Both uniform gates hold: lines 96.72% against the >= 85% floor, branches 90.17%
against the >= 75% floor.

This feature changes no file under `extensions/drm-copilot/src/`, so the per-file threshold map
in `jest.config.cjs` gains no entry. The denominators are unchanged for the same reason.

The task allows a small non-decreasing movement in a `src/**` percentage, because P4-T7 adds a
fourth seeded file to the hermetic push-down tree. That allowance was not needed: the four
percentages and all four covered/total pairs are identical to the baseline. The acceptance is
that no percentage decreased, and the stronger identity result satisfies it.

## Verdict

No decrease in any of the three language comparisons. No blocking finding.
