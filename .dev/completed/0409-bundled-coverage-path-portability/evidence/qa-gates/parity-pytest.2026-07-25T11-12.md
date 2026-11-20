# Bundled-Parity Pytest (issue #409)

Timestamp: 2026-07-25T11-12

Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py`

EXIT_CODE: 0

Output Summary:
- `collected 1 item` / `tests\scripts\dev_tools\test_poshqc_bundled_parity.py .` / `1 passed in 0.03s`.
- Pass/fail counts: **1 passed, 0 failed**.
- The single test `test_poshqc_bundled_module_files_match_repo_root_sources` asserts exact text parity for all 8 locked paths, including `PoshQC.Testing.psm1` (the file changed by this fix) and `settings/pester.runsettings.psd1` (unchanged by this fix). All parity assertions pass.
