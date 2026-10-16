# Remediation Cycle 1 - Full Pester Baseline With Coverage (P0-T17)

Timestamp: 2026-10-16T11-45
Command: sh SCRATCH/issue-953-r1-p0-t17.sh (FULL_RUN(baseline): New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r1-baseline-poshqc.log'); $exit = $LASTEXITCODE; ...; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-r1-baseline-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-r1-baseline-junit.xml') -Force; exit $exit); validity, JRP, and CRP via sh SCRATCH/issue-953-r1-p0-t17-2.sh
EXIT_CODE: 0
Output Summary: FULL_RUN valid: (a) both artifacts/pester/powershell-coverage.xml and artifacts/pester/pester-junit.xml were written after START_UTC 2026-10-16T11:29:39.2707348Z; (b) the log contains exactly 1 line `Code coverage population: source=config`; (c) the command passes no -ScanFolders and no -SettingsPath. Wall seconds: 944.
JRP: JUNIT_TESTS 10488, JUNIT_FAILURES 0, JUNIT_ERRORS 0 (no failed cases).
CRP: LINE_COVERED 16702, LINE_MISSED 1468, LINE_TOTAL 18170, LINE_PERCENT 91.92, SOURCEFILE_COUNT 204; threshold (85%) PASS.
Per-file: scripts/powershell/poshqc/poshqc.psm1 covered=53 missed=7 (total 60); scripts/powershell/poshqc/poshqc.testing.psm1 covered=187 missed=13 (total 200).
Pre-cycle changed lines:
- L(scripts/powershell/poshqc/poshqc.psm1, 62) = ci=5 mi=0
- L(scripts/powershell/poshqc/poshqc.psm1, 75) = ci=5 mi=0
- L(scripts/powershell/poshqc/poshqc.psm1, 76) = ci=1 mi=0
- L(scripts/powershell/poshqc/poshqc.testing.psm1, 165) = ci=3 mi=0
- L(scripts/powershell/poshqc/poshqc.testing.psm1, 169) = ci=1 mi=0
- L(scripts/powershell/poshqc/poshqc.testing.psm1, 306) = ci=1 mi=0

R1_BASELINE_JUNIT_TESTS: 10488
