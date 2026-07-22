Timestamp: 2026-07-21T21-11

Command: pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1
EXIT_CODE: 0

Output Summary:
- Test results: Tests Passed: 1341, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0. 0 failed.
- Pester INSTRUCTION-basis summary: `Covered 89.64%` (up from 87.33% pre-fix baseline).
- Per-file / aggregate LINE coverage (parsed from artifacts/pester/powershell-coverage.xml):
  - PoshQC.Testing.psm1: covered=195, missed=0, total=195 => 100.00% (0 uncovered lines).
  - PoshQC.ScanConfig.psm1: covered=44, missed=2, total=46 => 95.65% (uncovered lines 47, 79 —
    same 2 lines as the P0-T5 pre-fix baseline; no regression).
  - Repo measured-set aggregate LINE: covered=2143, missed=233, total=2376 => 90.19%.

## Result vs. targets and baselines

- PoshQC.Testing.psm1 100% >= 85% target: PASS. Up from pre-fix 131/195 (67.18%) and above the
  original cycle-1 baseline of 149/195 (76.41%).
- Repo measured-set 90.19% >= 85% target: PASS. Up from pre-fix 2079/2376 (87.50%) and above the
  original cycle-1 baseline of 2097/2376 (88.26%).
- PoshQC.ScanConfig.psm1 unchanged at 44/46 (95.65%): no regression (issue #344 protection).

## Toolchain note

The first P2-T1 attempt failed the analyze stage: the new issue #392 comment introduced non-ASCII
em-dash characters, which tripped `PSUseBOMForUnicodeEncodedFile` (missing BOM for a non-ASCII
file). Fixed by replacing the em-dashes with ASCII in both `scripts/powershell/PoshQC/PoshQC.psm1`
and its mirror (byte-identical; parity re-verified). This re-run is the clean pass: format,
analyze (0 findings), and test (0 failed) all green in a single suite invocation.
