# Remediation Cycle 1 - Coverage Delta (P5-T4)

Timestamp: 2026-10-16T12-13
Command: sh SCRATCH/issue-953-r1-p5-t4.sh (pwsh -NoProfile -Command: CRP steps 1-7 applied to SCRATCH/issue-953-r1-baseline-coverage.xml and SCRATCH/issue-953-r1-final-coverage.xml; per-file values for two keys; L(key, nr) on the final file)
EXIT_CODE: 0
Output Summary:
- Baseline: LINE_COVERED 16702, LINE_TOTAL 18170, LINE_PERCENT 91.92.
- Final: LINE_COVERED 16702, LINE_TOTAL 18170, LINE_PERCENT 91.92. Threshold (85%) PASS.
- LINE_TOTAL baseline equals final: True (AC-08 denominator unchanged).
- scripts/powershell/poshqc/poshqc.psm1: baseline covered 53 missed 7; final covered 53 missed 7 (total 60 both; 88.33%, per-file 85% PASS).
- scripts/powershell/poshqc/poshqc.testing.psm1: baseline covered 187 missed 13; final covered 187 missed 13 (total 200 both; 93.5%, per-file 85% PASS).
- Changed counted lines (final file, all covered):
  - L(scripts/powershell/poshqc/poshqc.psm1, 63) = ci=3 mi=0
  - L(scripts/powershell/poshqc/poshqc.psm1, 66) = ci=3 mi=0
  - L(scripts/powershell/poshqc/poshqc.psm1, 79) = ci=4 mi=0
  - L(scripts/powershell/poshqc/poshqc.testing.psm1, 167) = ci=6 mi=0
  - L(scripts/powershell/poshqc/poshqc.testing.psm1, 171) = ci=1 mi=0
  - L(scripts/powershell/poshqc/poshqc.testing.psm1, 308) = ci=1 mi=0
- The bundled copies under extensions/drm-copilot/resources/powershell/PoshQC/ are outside the coverage roots of config/poshqc-coverage.json:3-9 and are not measured.
