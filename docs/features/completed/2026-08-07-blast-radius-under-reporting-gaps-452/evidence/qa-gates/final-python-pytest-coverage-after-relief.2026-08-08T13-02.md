# Post-relief Python test gate with coverage ([P11-T16])

Timestamp: 2026-08-08T13-02

Command:
```
poetry run pytest --cov --cov-branch --cov-report=term-missing
poetry run coverage json -o -    (exact totals, not the rounded term-missing row)
```

EXIT_CODE: 0

## Output Summary

`2886 passed in 10.70s`. Passed 2886, failed 0, skipped 0, errors 0.

### Pure-move proof against [P11-T4]

| Metric | [P11-T4] (pre-relief) | [P11-T16] (post-relief) | Delta |
| --- | --- | --- | --- |
| Passed | 2886 | 2886 | 0 |
| Failed | 0 | 0 | 0 |
| Skipped | 0 | 0 | 0 |
| Errors | 0 | 0 | 0 |

The passed/failed/skipped counts are EQUAL to the [P11-T4] counts. No test was
added, removed, renamed, or redirected by the relief, and no test imports the
moved symbols directly, so the equality is exact rather than coincidental. The
relief is proven to be a pure move with zero behaviour change.

### Numeric post-relief coverage totals

Extracted from `coverage json` rather than the rounded `term-missing` TOTAL row,
matching the method used in the [P11-T4] artifact.

| Counter | Covered | Total | Percent |
| --- | --- | --- | --- |
| TOTAL line (statement) | 12266 | 13373 | **91.72%** |
| TOTAL branch | 4124 | 4934 | **83.58%** |

Both thresholds hold: line 91.72% >= 85%, branch 83.58% >= 75%.

Against [P11-T4] (12263/13370 line, 4124/4934 branch): covered statements rose
by 3 and total statements rose by 3. The three added statements are the new leaf
module's two module-scaffolding imports (`from __future__ import annotations`
and `from typing import TYPE_CHECKING`) plus the one import statement added to
`scripts/dev_tools/_blast_radius_validation.py`. All three execute on import and
are therefore covered. The `if TYPE_CHECKING:` block is NOT counted: it is listed
in `exclude_lines` under `[tool.coverage.report]` in `pyproject.toml`, so it and
its body are outside measurement in this repository. The branch counters are
byte-identical at 4124/4934, because the relocated function's four branch arcs
moved with it. The rounded line percentage is unchanged at 91.72% and the rounded
branch percentage is unchanged at 83.58%.

The `term-missing` `TOTAL` row prints `90%`, which is coverage.py's combined
line-plus-branch figure (`percent_covered` 89.53%), not the line coverage. The
line and branch figures above are the ones the thresholds apply to.

### Per-file coverage for the six blast-radius modules

| Module | Stmts | Miss | Branch | BrPart | Cover | [P11-T4] |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_thresholds.py` | 10 | 0 | 4 | 0 | **100%** | n/a (created by this relief) |
| `scripts/dev_tools/_blast_radius_glob.py` | 58 | 1 | 28 | 1 | **98%** | 98% |
| `scripts/dev_tools/_blast_radius_extraction.py` | 93 | 0 | 42 | 0 | **100%** | 100% |
| `scripts/dev_tools/_blast_radius_validation.py` | 111 | 0 | 42 | 0 | **100%** | 100% |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 58 | 0 | 22 | 0 | **100%** | 100% |
| `scripts/dev_tools/compute_blast_radius.py` | 60 | 0 | 8 | 0 | **100%** | 100% |

No module regressed. The new module reaches 100% line and 100% branch coverage
with zero test edits, because `config_over_breadth_fraction` is exercised through
the `compute_blast_radius` facade by
`tests/scripts/dev_tools/test_blast_radius_validation.py`:
`test_v3_triggers_only_above_the_over_breadth_fraction` (line 147) covers the
happy path and the exact boundary and takes the false arm of both guards,
`test_validation_rejects_a_malformed_over_breadth_threshold` (line 227) is
parametrized over a string and a boolean and takes the true arm of the `TypeError`
guard, and `test_validation_rejects_an_out_of_range_over_breadth_threshold`
(line 235) takes the true arm of the `ValueError` guard.

`_blast_radius_validation.py` drops from 118 to 111 statements and from 46 to 42
branches, which is the moved constant, the moved function, and its four branch
arcs leaving, less the one added import statement. It stays at 100%.

The single uncovered statement repository-wide in this change set remains
`_blast_radius_glob.py:222`, the `return entry` fallback of `_literal_prefix`
taken only when an entry contains no wildcard at all. It is pre-existing code
relocated verbatim at [P1-T3], uncovered with the same count of 1 in the
[P1-T9] and [P11-T4] runs, and untouched by this relief.

Iteration: 1.
