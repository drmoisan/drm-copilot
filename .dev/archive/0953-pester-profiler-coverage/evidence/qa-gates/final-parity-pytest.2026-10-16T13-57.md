# Final QC: Bundled-Parity Pytest (P8-T16 / P6-T5, sharding path)

Timestamp: 2026-10-16T13-57
Command: poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
EXIT_CODE: 0

Output Summary:
- Summary line: `1 passed in 0.05s`.
- `POSHQC_PARITY_PATHS` now includes `PoshQC.Shard.psm1` and `PoshQC.CoverageMerge.psm1` (P8-T12), so the parity check covers 11 file pairs.
- Result: PASS (AC-02).
