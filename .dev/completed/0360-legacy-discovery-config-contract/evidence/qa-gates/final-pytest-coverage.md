# Final QC — Pytest with Coverage (P5-T5)

Timestamp: 2026-07-18T14-40
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Output Summary: PASS. 1592 passed in 8.86s. No failures. Achieved in a single clean loop
pass after Black, Ruff, and Pyright all reported exit code 0 with no file changes.

## Total coverage (TOTAL row)

- Stmts=11202, Miss=1336, Branch=4212, BrPart=550, combined Cover=86%.
- Total line coverage: (11202 - 1336) / 11202 = 88.1%.
- Total branch coverage (derived from combined): ~80.5%.

## Per-module coverage for the new discovery package

| Module | Stmts | Miss | Branch | BrPart | Cover | Missing |
|---|---|---|---|---|---|---|
| `scripts/dev_tools/discovery/__init__.py` | 3 | 0 | 0 | 0 | 100% | — |
| `scripts/dev_tools/discovery/domain_profile.py` | 189 | 1 | 78 | 1 | 99% | 75 |
| `scripts/dev_tools/discovery/domain_profile_models.py` | 55 | 0 | 14 | 0 | 100% | — |
| `scripts/dev_tools/discovery/profile_cli.py` | 46 | 0 | 6 | 0 | 100% | — |

Required-module detail:
- `domain_profile.py`: line coverage = (189 - 1) / 189 = 99.5%; branch coverage
  = (78 - 1) / 78 = 98.7%.
- `profile_cli.py`: line coverage = 46/46 = 100%; branch coverage = 6/6 = 100%.

Uncovered line note: `domain_profile.py:75` is the defensive `_type_name(_MISSING)`
branch. `_type_name` is never called with the `_MISSING` sentinel in the parse flow
(missing keys short-circuit to "required field is missing" before `_type_name` is reached),
so this is unreachable defensive code retained as a safety default. Coverage remains far
above the policy thresholds without it.
