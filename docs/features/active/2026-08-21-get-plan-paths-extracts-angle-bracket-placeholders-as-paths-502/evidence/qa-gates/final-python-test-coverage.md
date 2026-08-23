# QA Gate — Final Python Tests with Coverage — [P8-T4]

Timestamp: 2026-08-23T03-44

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T4]

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Test counts

```text
====================== 4094 passed, 5 skipped in 19.11s =======================
```

| Metric | Baseline ([P0-T5]) | Post-change | Change |
| --- | --- | --- | --- |
| passed | 4062 | **4094** | +32 |
| skipped | 5 | 5 | 0 |
| failed | 0 | **0** | 0 |

The 32 additional passes are the tests this item added: 16 in
`tests/scripts/dev_tools/test_blast_radius_token_shapes.py`, 6 in
`tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` (5 parametrized marker cases plus
the positive control), 2 in `tests/scripts/dev_tools/test_blast_radius_normalization.py`, 2 in
`tests/scripts/dev_tools/test_blast_radius_validation.py`, and 6 parametrized parity cases from the
three new fixtures (three fixtures across the radius and findings channels).

The five skips are the same pre-existing parametrized cases in
`tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` that declare no accessor
expectation. Unchanged from baseline.

## TOTAL row, verbatim

```text
TOTAL                                                               14946   1105   5490    559    91%
```

## Derived coverage figures

As at [P0-T5], the `term-missing` reporter prints one combined `Cover` column, not two percentages,
so both figures are derived from the raw column totals. `--cov-report=term-missing` is passed
explicitly because the project's `addopts` supplies only an LCOV reporter, so without it no coverage
table is printed at all.

| Figure | Derivation | Columns used | Value | Threshold |
| --- | --- | --- | --- | --- |
| line coverage | (Stmts - Miss) / Stmts = (14946 - 1105) / 14946 | `Stmts`, `Miss` | **92.61%** | >= 85% |
| branch coverage | (Branch - BrPart) / Branch = (5490 - 559) / 5490 | `Branch`, `BrPart` | **89.82%** | >= 75% |

Both thresholds are met with a wide margin. **PASS.**

## Comparability with the baseline

Both figures are derived by the identical method from the identical columns as the [P0-T5] baseline,
which is what makes the two directly comparable rather than merely adjacent.

| Metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| line coverage | 92.60% | **92.61%** | **+0.01 pp** |
| branch coverage | 89.81% | **89.82%** | **+0.01 pp** |
| Stmts | 14939 | 14946 | +7 |
| Miss | 1105 | 1105 | 0 |
| Branch | 5488 | 5490 | +2 |
| BrPart | 559 | 559 | 0 |

Neither metric regressed. The denominator grew by 7 statements and 2 branches — the new leaf module's
executable surface — and the missed counts did not move at all, which is the signature of a fully
covered addition.

## The two production modules this item touched

```text
scripts\dev_tools\_blast_radius_extraction.py                         101      0     46      0   100%
scripts\dev_tools\_blast_radius_token_shapes.py                        14      0      4      0   100%
```

| Module | Stmts | Miss | Branch | BrPart | Line | Branch |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 101 | 0 | 46 | 0 | **100%** | **100%** |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | 14 | 0 | 4 | 0 | **100%** | **100%** |

Both are fully covered on both metrics, including the new guard branch in `classify_path_token` and
both predicates in the new leaf module.

## Output Summary

Exit code 0, 4094 passed, 5 skipped, 0 failed. Post-change line coverage is **92.61%** (derived from
Stmts 14946 and Miss 1105) and branch coverage is **89.82%** (derived from Branch 5490 and BrPart
559), both above their uniform thresholds and both marginally above the baseline. Neither metric
regressed. The two production modules this item touched are at 100% line and 100% branch coverage.
