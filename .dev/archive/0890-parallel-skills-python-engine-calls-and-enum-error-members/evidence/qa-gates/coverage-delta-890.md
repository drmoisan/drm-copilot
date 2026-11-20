# Coverage Delta: scripts.dev_tools._parallel_mutation_errors (Issue #890)

Timestamp: 2026-10-12T20-30
Task: P2-T5
Command: `git diff 85ffd5aaecd9004b7d82e9db6ab0f18a4add02f6 -U0 -- scripts/dev_tools/_parallel_mutation_errors.py` (merge base recorded by P0-T3, replacing the plan's anticipated 2ef8d361e978ca8b7733a545d76a87e8418005ce per the P2-T5 rule), plus the P0-T7 and P2-T4 JSON reports.
EXIT_CODE: 0
Output Summary: post-change line 100.0% (baseline 100.0%, no regression); branch 100.0% (baseline n/a, 0 arcs); changed-line coverage 4/4 = 100%.

| Measure | Baseline (P0-T7) | Post-change (P2-T4) |
| --- | --- | --- |
| Line | 34 / 34 = 100.0% | 37 / 37 = 100.0% |
| Branch | n/a (0 branch arcs) | 2 / 2 = 100.0% |

## Changed-line coverage

Hunks against the merge base (new-file line numbers): `+45,10` (the `_ENUM_MEMBERS_BY_FIELD` comment and constant), `+176,7` and `+195,2` and `+201,4` (docstrings), `+207,7` (lookup and `ValueError` raise), and one removed line (the former conditional-expression selection).

Changed executable lines (statements coverage.py reports in `executed_lines` or `missing_lines` of the sole `files` entry): 49 (the `_ENUM_MEMBERS_BY_FIELD` assignment, lines 49-53), 207 (`allowed = _ENUM_MEMBERS_BY_FIELD.get(field_name)`), 208 (`if allowed is None:`), 209 (the `raise ValueError(...)` statement, lines 209-213). Comment and docstring lines are not executable.

- Changed executable lines not in `missing_lines`: 49, 207, 208, 209 (`missing_lines` is empty).
- Changed-line coverage = 4 / 4 = 100%.
