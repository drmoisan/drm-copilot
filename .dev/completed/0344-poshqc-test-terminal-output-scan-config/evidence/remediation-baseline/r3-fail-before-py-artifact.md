# R3 Fail-Before — Python Coverage Artifact Absent

- Issue: #344
- Timestamp: 2026-07-10T20-46
- Command: `pwsh -NoLogo -NoProfile -Command "Test-Path artifacts/python/lcov.info"`
- EXIT_CODE: 0

## Output Summary

`Test-Path artifacts/python/lcov.info` returned **False**. The Python coverage artifact does not exist prior to remediation, confirming the R3 fail-before state. The parity test file `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` changed on the branch but no Python lcov coverage artifact was produced.
