# QA Gate — Python Extended Parity Pytest

- Timestamp: 2026-07-10T18-33
- Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`
- EXIT_CODE: 0

## Output Summary

1 test passed: `test_poshqc_bundled_module_files_match_repo_root_sources`. All eight parity-locked file pairs (four `.psm1`, `PoshQC.ScanConfig.psm1`, `PoshQC.psd1`, `settings/pester.runsettings.psd1`, `settings/pssa.settings.psd1`) are byte-identical between workspace and bundled copies.

Only test code changed in Python for this feature: the sole Python edit is extending `POSHQC_PARITY_PATHS` in the test file `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. There is no Python production code in scope, so a Python production coverage delta is not applicable.
