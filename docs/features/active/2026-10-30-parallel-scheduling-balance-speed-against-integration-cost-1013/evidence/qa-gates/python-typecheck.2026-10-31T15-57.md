# QA Gate — Python Type Check

Timestamp: 2026-10-31T15-57
Command: poetry run pyright scripts/dev_tools tests/scripts/dev_tools
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations. (An earlier pass reported three `dict(<object>)` argument-type errors in `test_blast_radius_aggregate.py` and `test_blast_radius_combination.py`; each now casts the fixture value to `Mapping[str, object]` before copying.)
