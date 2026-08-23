# QA Gate — Final Python Tests with Coverage — [P8-T4]

Timestamp: 2026-08-23T05-14

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T4]
Run: revision-6 re-run.

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Test counts

```text
====================== 4095 passed, 5 skipped in 18.16s =======================
```

| Metric | Baseline ([P0-T5]) | Previous run | This run | Change vs baseline |
| --- | --- | --- | --- | --- |
| passed | 4062 | 4094 | **4095** | +33 |
| skipped | 5 | 5 | 5 | 0 |
| failed | 0 | 0 | **0** | 0 |

The single additional pass over the previous run is
`test_placeholder_only_overlap_stops_conflicting_after_normalization`, added by [P5-T3]. The 33
additional passes over baseline are this item's full test contribution: 16 in the new leaf-module
suite, 6 in the extraction-rules suite (five parametrized marker cases plus the positive control), 3
in the normalization suite, 2 in the validation suite, and 6 parametrized parity cases from the three
new fixtures across the radius and findings channels.

The five skips are the same pre-existing parametrized cases in
`tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` that declare no accessor expectation.

## TOTAL row, verbatim

```text
TOTAL                                                               14946   1105   5490    559    91%
```

## Derived coverage figures

The `term-missing` reporter prints one combined `Cover` column, not two percentages, so both figures
are derived from the raw column totals. The reporter is passed explicitly because the project's
`addopts` supplies only an LCOV reporter, so without it no coverage table is printed at all.

| Figure | Derivation | Columns used | Value | Threshold |
| --- | --- | --- | --- | --- |
| line coverage | (14946 - 1105) / 14946 | `Stmts`, `Miss` | **92.61%** | >= 85% |
| branch coverage | (5490 - 559) / 5490 | `Branch`, `BrPart` | **89.82%** | >= 75% |

Both thresholds met with a wide margin. **PASS.**

## Comparability with the baseline

| Metric | Baseline | This run | Delta |
| --- | --- | --- | --- |
| line coverage | 92.60% | **92.61%** | **+0.01 pp** |
| branch coverage | 89.81% | **89.82%** | **+0.01 pp** |
| Stmts | 14939 | 14946 | +7 |
| Miss | 1105 | 1105 | 0 |
| Branch | 5488 | 5490 | +2 |
| BrPart | 559 | 559 | 0 |

Neither metric regressed. All four raw totals are identical to the previous run, and that is the
expected signature of a test-only addition rather than an absence of effect: [P5-T3] added test lines,
which the `omit` list excludes from measurement, and exercised production lines that were already
covered. An unchanged denominator with an unchanged miss count is what such an addition should
produce, and stating it explicitly is what distinguishes it from a coverage run that silently failed
to pick the new test up. The test count moving from 4094 to 4095 is the independent confirmation that
the new test did run.

## The two production modules this item touched

```text
scripts\dev_tools\_blast_radius_extraction.py                         101      0     46      0   100%
scripts\dev_tools\_blast_radius_token_shapes.py                        14      0      4      0   100%
```

| Module | Stmts | Miss | Branch | BrPart | Line | Branch |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 101 | **0** | 46 | **0** | **100%** | **100%** |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | 14 | **0** | 4 | **0** | **100%** | **100%** |

Both fully covered on both metrics, including the new guard branch in `classify_path_token` and both
predicates in the leaf module.

## Output Summary

Exit code 0, **4095 passed, 5 skipped, 0 failed**. Line coverage **92.61%** and branch coverage
**89.82%**, both above threshold and both marginally above the 92.60% and 89.81% baseline. Neither
metric regressed. Both touched production modules are at 100% line and 100% branch coverage.
