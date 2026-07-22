Timestamp: 2026-07-21T21-11

Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'"
EXIT_CODE: 0

Output Summary:
- Narrowed bundled-hosted run over the PoshQC test folder only (E1b pattern).
- Test results: Tests Passed: 107, Failed: 0, Skipped: 7. 0 failed. Completed in ~4.9s.
- PoshQC.Testing.psm1 LINE: covered=131, missed=64, total=195 => 67.18%.

## Uncovered-line list for PoshQC.Testing.psm1 (64 lines)

75, 79, 91, 102, 103, 107, 109, 110, 112, 114, 115, 117, 118, 121, 122, 125, 126, 127, 128,
291, 309, 314, 315, 316, 322, 332, 340, 341, 342, 346, 350, 351, 352, 353, 354, 356, 357, 359,
368, 369, 401, 402, 403, 410, 411, 412, 413, 414, 415, 417, 418, 419, 420, 423, 424, 427, 428,
433, 434, 435, 436, 437, 438, 439

## Comparison against P0-T5 (full bundled suite baseline)

IDENTICAL. The narrowed run's PoshQC.Testing.psm1 uncovered-line list (64 lines) and per-file
percentage (67.18%, 131/195) exactly match P0-T5's full-suite values. The same
loss-of-previously-recorded-credit regression — including the newly-uncovered 75-128
module-bootstrap cluster — reproduces at this narrower, faster scope. This narrowed command is a
faithful, fast reproduction loop for the Phase 0 candidate experiments.
