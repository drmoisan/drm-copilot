Timestamp: 2026-07-21T21-11

Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'"
EXIT_CODE: 0

Output Summary:
- Narrowed bundled-hosted run over the PoshQC test folder only (fast confirmation).
- Test results: Tests Passed: 107, Failed: 0, Skipped: 7. 0 failed. Completed in ~4.9s.
- PoshQC.Testing.psm1 per-file LINE: covered=195, missed=0, total=195 => 100.00%.

## Comparison to P0-T7 (E-C experiment)

The finalized-fix narrowed run's PoshQC.Testing.psm1 LINE percentage (100.00%, 195/195) equals the
P0-T7 Candidate A experiment value (100.00%), i.e. >= the E-C value. The finalized, mirrored,
ASCII-corrected edit reproduces the E-C smoke-test result exactly.
