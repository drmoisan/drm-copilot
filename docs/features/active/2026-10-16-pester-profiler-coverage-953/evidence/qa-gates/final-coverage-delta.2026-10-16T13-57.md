# Final QC: Local Coverage Delta (P8-T16 / P6-T4, sharding path)

Timestamp: 2026-10-16T13-57
Command: sh "SCRATCH/issue-953-p8-t16-p6-t4.sh" — CRP applied to `SCRATCH/issue-953-r1-final-coverage.xml` (baseline per P8-T16 substitution 3) and `SCRATCH/issue-953-final-coverage.xml` (final); per-key LINE total comparison over every key except the four PoshQC keys; per-file 85% test for the four keys; changed lines located by `Select-String -SimpleMatch` with single-quoted tokens and looked up with `L(key, nr)`.
EXIT_CODE: 0

Output Summary:
- Baseline (r1-final, head 12d3d4e77): LINE_COVERED 16702, LINE_TOTAL 18170, LINE_PERCENT 91.92, SOURCEFILE_COUNT 204.
- Final: LINE_COVERED 16827, LINE_TOTAL 18296, LINE_PERCENT 91.97, SOURCEFILE_COUNT 206. Final CRP threshold (step 7): PASS.
- Per-key LINE_TOTAL equality over the 202 keys other than the four PoshQC keys: 0 missing in final, 0 with unequal covered+missed, 0 final keys outside the baseline key set other than the four. PASS.
- Four PoshQC keys (each must satisfy 100*covered >= 85*total):
  - scripts/powershell/poshqc/poshqc.shard.psm1: new; 49/49 = 100% PASS.
  - scripts/powershell/poshqc/poshqc.coveragemerge.psm1: new; 70/70 = 100% PASS.
  - scripts/powershell/poshqc/poshqc.testing.psm1: baseline 187/200; final 193 covered, 14 missed, 207 total = 93.24% PASS.
  - scripts/powershell/poshqc/poshqc.psm1: baseline 53/60; final 53 covered, 7 missed, 60 total = 88.33% PASS.
- Changed lines located by text (counts all equal the stated counts):
  - PoshQC.psm1 `$isSupportedVersion = {` count 1 (line 63): L = ci=3 mi=0.
  - PoshQC.psm1 `Where-Object -FilterScript $isSupportedVersion` count 2 (lines 66, 79): L(66) = ci=3 mi=0; L(79) = ci=4 mi=0.
  - PoshQC.Testing.psm1 `ModuleVersion = $MinimumVersion` count 1 (line 179): ci=6 mi=0.
  - PoshQC.Testing.psm1 `-MaximumVersion $MaximumVersion` count 1 (line 183): ci=1 mi=0.
  - PoshQC.Testing.psm1 `& $EnsureModule 'Pester'` count 1 (line 320): ci=1 mi=0.
  - Every located line is present in the final CRP file and has ci > 0 (3 of 3 in each file).
- The bundled copy (`extensions/drm-copilot/resources/powershell/PoshQC/`) is outside COVERAGE_ROOTS and is not measured. The runsettings `.psd1` files are not in the coverage population (only `.ps1` and `.psm1` files are measured).
- Result: PASS.
