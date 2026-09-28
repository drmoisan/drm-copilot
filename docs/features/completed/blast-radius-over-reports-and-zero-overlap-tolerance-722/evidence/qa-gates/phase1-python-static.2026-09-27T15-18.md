# Phase 1 Python Static Gates (P1-T14)

Timestamp: 2026-09-27T15-18
Command: poetry run black scripts/dev_tools/_blast_radius_scheduling.py scripts/dev_tools/compute_blast_radius.py tests/scripts/dev_tools/test_blast_radius_scheduling.py tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py; poetry run black --check (same four files); poetry run ruff check --no-fix (same four files); poetry run pyright (same four files)
EXIT_CODE: 0
Output Summary: Final pass over the four Phase 1 Python files. black (write mode) exited 0 and printed "4 files left unchanged."; black check mode exited 0 and printed "4 files would be left unchanged."; ruff exited 0 and printed "All checks passed!"; pyright exited 0 and printed "0 errors, 0 warnings, 0 informations". Because files changed during the loop (see below), P1-T12 and P1-T13 were re-run against this final state.

The four files: scripts/dev_tools/_blast_radius_scheduling.py, scripts/dev_tools/compute_blast_radius.py,
tests/scripts/dev_tools/test_blast_radius_scheduling.py, and
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py.

## Final-pass printed output

```text
$ poetry run black <4 files>
All done!
4 files left unchanged.

$ poetry run black --check <4 files>
All done!
4 files would be left unchanged.

$ poetry run ruff check --no-fix <4 files>
All checks passed!

$ poetry run pyright <4 files>
0 errors, 0 warnings, 0 informations
```

(The black summary lines also print two emoji characters, and pyright printed a venv-path notice and
a newer-version notice; both notices are informational.)

## Earlier iterations of the loop (restart from formatting after each fix)

| Iteration | Finding | Fix |
| --- | --- | --- |
| 1 | black reformatted three files | accepted the formatting; the module then measured 501 lines, so docstrings were shortened and two name tuples were written with split() (494 lines) |
| 2 | ruff S311 (4) on random.Random in the property module | replaced the seeded generator with exhaustive enumeration over a fixed domain (no suppression added) |
| 2 | pyright reportUnnecessaryIsInstance on the item-key check | replaced with an exact type test that also rejects bool |
| 2 | pyright reportUnnecessaryCast and reportUnknownVariableType in the unit-test module | removed the cast; annotated the detected set |
| 3 | pyright reportUnnecessaryIsInstance after narrowing | exact type test `type(item.key) is not int` |
| 4 | none | final pass above |
