# Baseline — Python Parity Gate

- Timestamp: 2026-07-10T17-47
- Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`
- EXIT_CODE: 0

## Output Summary

1 test collected and passed: `test_poshqc_bundled_module_files_match_repo_root_sources`.

At baseline `POSHQC_PARITY_PATHS` locks four `.psm1` files (workspace vs bundled byte parity):
- `scripts/powershell/PoshQC/PoshQC.psm1`
- `scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1`
- `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1`
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1`

All four report parity at baseline. The `.psd1` manifest and `settings/*.psd1` files are NOT yet locked (the drift that Phase 3 closes).
