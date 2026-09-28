# Phase 3 Python Static Gates (P3-T11)

Timestamp: 2026-09-27T15-31
Command: poetry run black tests/scripts/dev_tools/blast_radius_parity_test_support.py tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py; poetry run black --check (same three files); poetry run ruff check --no-fix (same three files); poetry run pyright (same three files)
EXIT_CODE: 0
Output Summary: black (write mode) exited 0 and printed "3 files left unchanged."; black check mode exited 0 and printed "3 files would be left unchanged."; ruff exited 0 and printed "All checks passed!"; pyright exited 0 and printed "0 errors, 0 warnings, 0 informations". The write-mode run changed nothing, so P3-T10 did not need a re-run. Line counts: blast_radius_parity_test_support.py 261, test_blast_radius_config_tolerance_keys.py 79, test_blast_radius_historical_runs.py 179 (all at most 500).

## Printed output

```text
$ poetry run black <three files>
All done!
3 files left unchanged.

$ poetry run black --check <three files>
All done!
3 files would be left unchanged.

$ poetry run ruff check --no-fix <three files>
All checks passed!

$ poetry run pyright <three files>
0 errors, 0 warnings, 0 informations
```

(The black summary lines also print two emoji characters; pyright also printed a venv-path notice and
a newer-version notice, both informational.)

## Additional read-only regression check

After the config edit, `poetry run pytest -q tests/scripts/dev_tools -k "blast_radius or config"`
printed "591 passed, 4551 deselected" with no failure, so no existing Python blast-radius or config
test is affected by the new conflict_tolerance key. The TypeScript carriage helper and the PowerShell
key-partition test are updated in Phases 4 and 5 and are not gated here (P3-T12 text).
