# Coverage Comparison (P13-T11)

Timestamp: 2026-09-30T01-36
Command: derived from evidence/baseline/coverage-*.2026-09-29T23-11.md (P0-T25..P0-T32), evidence/qa-gates/coverage-*.2026-09-30T01-17.md (P12-T4..P12-T11), and evidence/qa-gates/changed-line-coverage.2026-09-30T01-18.md (P12-T12)
EXIT_CODE: 0
Output Summary:
- Language: PowerShell (Pester line coverage; branch coverage is not measured by Pester).
- Baseline Coverage: WIR 96.23; ESR 89.42; PRE 93.42; PRES 100; WAVE 98.9; COH 98.48; MRG 96.67; EREM 95.24; PREM 93.41; DRIFT 99.04.
- Post-Change Coverage: WIR 96.23; ESR 90.18; PRE 96.73; PRES 100; WAVE 99.01; COH 98.68; MRG 96.8; EREM 95.41; PREM 93.46; DRIFT 99.12; WRR 100; MRGR 88.89; EREMR 95.65.
- New/Changed-code Coverage: WRR 100; WIR NA (no executable changed line; the export is verified by T-REC X2 (P1-T12)); ESR 94.74; PRE 100; PRES 100; WAVE 100; COH 100; MRG 100; MRGR 88.89; EREM 100; EREMR 95.65; PREM 93.94; DRIFT 100.
- Disposition: PASS (WRR, MRGR, EREMR each at least 85; each existing file at least its BASEPCT; each of the 12 non-WIR ChangedPercent values at least 85).
- The only Python change is the P13-T2 pin re-baseline (tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py); no TypeScript file is changed.
