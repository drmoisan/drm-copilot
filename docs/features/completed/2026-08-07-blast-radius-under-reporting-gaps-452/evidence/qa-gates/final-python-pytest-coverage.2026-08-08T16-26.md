# [P11-T4] Final QA — Python tests with coverage

Timestamp: 2026-08-08T16-26
Task: [P11-T4]
Loop iteration: 1

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Test counts

| Metric | Baseline [P0-T6] | This run | Delta |
| --- | --- | --- | --- |
| Passed | 2835 | 2886 | +51 |
| Failed | 0 | 0 | 0 |
| Skipped | 0 | 0 | 0 |
| Errors | 0 | 0 | 0 |
| Wall time | — | 10.41 s | — |

`2886 passed in 10.41s`. The +51 is the tests added across Phases 3, 6, 8, and 9 plus the ten
parametrized parity cases from the five new fixtures.

## Numeric post-change coverage totals

Extracted from `coverage json` rather than the rounded `term-missing` row, so the percentages are
exact.

| Counter | Covered | Total | Percent |
| --- | --- | --- | --- |
| TOTAL line (statement) | 12263 | 13370 | **91.72%** |
| TOTAL branch | 4124 | 4934 | **83.58%** |

The `term-missing` `TOTAL` row prints `90%`, which is coverage.py's combined line-plus-branch
figure (`percent_covered` 89.53%), not the line coverage. The line and branch figures above are
the ones the thresholds apply to.

Both thresholds hold: line 91.72% >= 85%, branch 83.58% >= 75%.

## Per-file coverage for the five blast-radius modules

| Module | Stmts | Miss | Branch | BrPart | Cover | Baseline |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_glob.py` | 58 | 1 | 28 | 1 | **98%** | 98% at [P1-T9] (file created in Phase 1) |
| `scripts/dev_tools/_blast_radius_extraction.py` | 93 | 0 | 42 | 0 | **100%** | 100% at [P0-T6] |
| `scripts/dev_tools/_blast_radius_validation.py` | 118 | 0 | 46 | 0 | **100%** | 100% at [P0-T6] |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 58 | 0 | 22 | 0 | **100%** | 100% at [P0-T6] |
| `scripts/dev_tools/compute_blast_radius.py` | 60 | 0 | 8 | 0 | **100%** | 100% at [P0-T6] |

No module regressed. The single uncovered statement is `_blast_radius_glob.py:222`, the
`return entry` fallback of `_literal_prefix` taken only when an entry contains no wildcard at all.
That line is pre-existing code relocated verbatim at [P1-T3] and was uncovered at the same
statement, with the same count of 1, in the [P1-T9] baseline. Every line added by this plan is
covered.

Output Summary: 2886 passed, 0 failed, 0 skipped, 0 errors; EXIT_CODE 0. Post-change TOTAL line
coverage 91.72% (12263/13370) and TOTAL branch coverage 83.58% (4124/4934), both above the 85%
and 75% thresholds. Per-file: `_blast_radius_glob.py` 98%, and `_blast_radius_extraction.py`,
`_blast_radius_validation.py`, `_blast_radius_conflicts.py`, and `compute_blast_radius.py` all at
100%.
