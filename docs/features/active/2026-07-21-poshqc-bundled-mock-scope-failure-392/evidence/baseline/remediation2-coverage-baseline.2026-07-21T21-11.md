Timestamp: 2026-07-21T21-11

Command: pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1
EXIT_CODE: 0

Output Summary:
- Test results: Tests Passed: 1341, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0. 0 failed.
- Pester INSTRUCTION-basis summary line: `Covered 87.33% / 0%. 3,253 analyzed Commands in 31 Files.`
- Per-file LINE coverage (parsed from artifacts/pester/powershell-coverage.xml):
  - PoshQC.Testing.psm1: covered=131, missed=64, total=195 => 67.18%
  - PoshQC.ScanConfig.psm1: covered=44, missed=2, total=46 => 95.65%
- Repo measured-set aggregate LINE coverage (top-level <report> LINE counter): covered=2079, missed=297, total=2376 => 87.50%

Confirmed: the actual measured revision-2 pre-fix per-file value for PoshQC.Testing.psm1 is
67.18% (131/195), matching revision 1's interim state and below the original cycle-1 baseline of
76.41% (149/195).

## Full uncovered-line list for PoshQC.Testing.psm1 (64 lines; ci=0 and mi>0)

75, 79, 91, 102, 103, 107, 109, 110, 112, 114, 115, 117, 118, 121, 122, 125, 126, 127, 128,
291, 309, 314, 315, 316, 322, 332, 340, 341, 342, 346, 350, 351, 352, 353, 354, 356, 357, 359,
368, 369, 401, 402, 403, 410, 411, 412, 413, 414, 415, 417, 418, 419, 420, 423, 424, 427, 428,
433, 434, 435, 436, 437, 438, 439

## Regression analysis vs. original cycle-1 baseline (149/195, 46 uncovered)

- Original baseline uncovered set (46 lines) began with line 98 in the early module region, then
  291, 309, ... 439.
- Current baseline (64 uncovered) NO LONGER lists 98 (now covered by a revision-1 test) but ADDS
  a new cluster in the 75-128 module-bootstrap/import region: 75, 79, 91, 102, 103, 107, 109,
  110, 112, 114, 115, 117, 118, 121, 122, 125, 126, 127, 128 (19 lines).
- Net delta: +19 newly-uncovered early-region lines, -1 (line 98 now covered) = +18 uncovered,
  i.e. 46 -> 64, and covered 149 -> 131. This is exactly the loss-of-previously-recorded-credit
  regression this revision targets: lines in the early module region lose coverage credit in the
  full bundled run after the revision-1 test additions introduced new earlier-file callers.
