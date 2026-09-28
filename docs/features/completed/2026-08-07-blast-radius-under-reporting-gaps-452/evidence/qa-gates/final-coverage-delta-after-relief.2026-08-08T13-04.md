# Post-relief Python coverage delta and threshold verification ([P11-T18])

Timestamp: 2026-08-08T13-04

Command:
```
poetry run pytest --cov --cov-branch --cov-report=term-missing   ([P11-T16] run)
poetry run coverage json -o -                                    (exact separated totals)
```
Compared against the [P0-T6] baseline artifact
`evidence/baseline/phase0-python-pytest-coverage.2026-08-08T10-42.md` and the
[P11-T4] post-change artifact
`evidence/qa-gates/final-python-pytest-coverage.2026-08-08T16-26.md`.

EXIT_CODE: 0

## Output Summary

### Repository-wide coverage across the three measurement points

| Counter | [P0-T6] baseline | [P11-T4] post-change | [P11-T16] post-relief | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| TOTAL line (statement) | 91.71% (12247 / 13354) | 91.72% (12263 / 13370) | **91.72% (12266 / 13373)** | >= 85% | PASS |
| TOTAL branch | 83.58% (4122 / 4932) | 83.58% (4124 / 4934) | **83.58% (4124 / 4934)** | >= 75% | PASS |
| Passed / failed / skipped | 2835 / 0 / 0 | 2886 / 0 / 0 | 2886 / 0 / 0 | equal to [P11-T4] | PASS |

Post-relief line coverage is 91.72%, which is AT LEAST 85 PERCENT.
Post-relief branch coverage is 83.58%, which is AT LEAST 75 PERCENT.
Neither figure regressed against the [P0-T6] baseline or the [P11-T4]
post-change value; line coverage is up 0.01 points on baseline and flat on
[P11-T4], and branch coverage is flat on both.

The `term-missing` `TOTAL` row prints `90%` at all three measurement points,
which is coverage.py's combined line-plus-branch figure (`percent_covered`
89.53%), not the line coverage. The separated line and branch figures above are
the ones the policy floors apply to.

### Per-file coverage for the two files the relief touched

| Module | [P0-T6] baseline | [P11-T4] post-change | [P11-T16] post-relief | Regressed? |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_validation.py` | 100% (119 stmts, 46 branches) | 100% (118 stmts, 46 branches) | **100% (111 stmts, 42 branches)** | NO |
| `scripts/dev_tools/_blast_radius_thresholds.py` | n/a (did not exist) | n/a (did not exist) | **100% (10 stmts, 0 miss, 4 branches, 0 partial)** | NO |

`_blast_radius_validation.py` stays at 100% line and 100% branch coverage. Its
statement count falls from 118 to 111 and its branch count from 46 to 42: the
moved constant, the moved function, and the function's four branch arcs left the
module, and one import statement arrived.

`_blast_radius_thresholds.py` enters the measurement at 100% line and 100%
branch coverage with ZERO test edits. Its ten statements and four branch arcs
are exercised through the `compute_blast_radius` facade by three pre-existing
tests in `tests/scripts/dev_tools/test_blast_radius_validation.py`:
`test_v3_triggers_only_above_the_over_breadth_fraction` (happy path, exact
boundary, and the false arm of both guards),
`test_validation_rejects_a_malformed_over_breadth_threshold` (parametrized over
a string and a boolean, taking the true arm of the `TypeError` guard), and
`test_validation_rejects_an_out_of_range_over_breadth_threshold` (true arm of the
`ValueError` guard). No test imports the moved symbols directly, which is why no
import redirect was required.

### New / changed-code coverage

The relief's changed code is exactly: the ten statements and four branch arcs
now resident in `scripts/dev_tools/_blast_radius_thresholds.py`, and the one
import statement added to `scripts/dev_tools/_blast_radius_validation.py`.

| Scope | Line coverage | Branch coverage |
| --- | --- | --- |
| New/changed code of this relief | **100%** (11 of 11 statements covered) | **100%** (4 of 4 branch arcs covered) |

New/changed-code coverage of 100% line and 100% branch clears the >= 85% line
and >= 75% branch thresholds with margin.

### Statement-count reconciliation

Repository statement total rises by 3 (13370 to 13373) and covered statements
rise by 3 (12263 to 12266). The delta is the new module's two module-scaffolding
imports (`from __future__ import annotations` and
`from typing import TYPE_CHECKING`) plus the one import statement added to
`scripts/dev_tools/_blast_radius_validation.py`, all three of which execute on
import and are therefore covered. The `if TYPE_CHECKING:` block is NOT counted:
it is listed in `exclude_lines` under `[tool.coverage.report]` in
`pyproject.toml`, so it and its body sit outside measurement in this repository.
The eight remaining statements of the new module are relocated pre-existing code
that left `_blast_radius_validation.py` in the same run, which is why its
statement count falls by seven (eight out, one import in). The branch counters
are byte-identical at 4124 / 4934,
because the relocated function's branch arcs moved rather than multiplied. This
arithmetic is what a pure move predicts and is consistent with the equal
pass/fail/skip counts recorded at [P11-T16].

### Conclusion

Post-relief line coverage is at least 85 percent, post-relief branch coverage is
at least 75 percent, and NO CHANGED FILE REGRESSED against its [P11-T4] percent.
