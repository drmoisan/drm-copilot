# PoshQC Bundled Parity Gate (Remediation Cycle 1)

- Issue: #344
- Timestamp: 2026-07-10T20-46
- Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`
- EXIT_CODE: 0

## Output Summary

1 test collected and passed (`test_poshqc_bundled_module_files_match_repo_root_sources`, parametrized across the eight PoshQC parity paths). All eight workspace/bundled pairs are byte-identical:

1. `scripts/powershell/PoshQC/PoshQC.psm1` (changed this cycle — mirror resynced) — PASS
2. `scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1` — PASS
3. `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` — PASS
4. `scripts/powershell/PoshQC/PoshQC.Testing.psm1` — PASS
5. `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` — PASS
6. `scripts/powershell/PoshQC/PoshQC.psd1` — PASS
7. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (changed this cycle — mirror resynced) — PASS
8. `scripts/powershell/PoshQC/settings/pssa.settings.psd1` — PASS

Result: `1 passed in 0.03s`. The two files changed this cycle and their bundled mirrors are byte-identical; the parity gate holds.
