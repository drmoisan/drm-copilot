# PoshQC Full Pester Baseline with Coverage (issue #953, P0-T22)

Timestamp: 2026-10-16T08-10
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-baseline-poshqc.log'); $exit = $LASTEXITCODE; $end = [datetime]::UtcNow; "EXIT_CODE=$exit SECONDS=$([int]($end - $start).TotalSeconds) START_UTC=$($start.ToString('o'))"; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-baseline-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-baseline-junit.xml') -Force; exit $exit' (FULL_RUN(baseline), script SCRATCH/issue-953-p0-t22.sh, run with sh in the background); reduction: SCRATCH/issue-953-p0-t22-2.sh (FULL_RUN validity checks, JRP steps 1-3, CRP steps 1-7)
EXIT_CODE: 0
Output Summary: FULL_RUN valid: (a) powershell-coverage.xml and pester-junit.xml both written after START_UTC 2026-10-16T07:51:35.0618503Z; (b) exactly 1 log line contains "Code coverage population: source=config"; (c) no -ScanFolders and no -SettingsPath argument. FULL_RUN wall seconds: 1089. JRP: JUNIT_TESTS 10376, JUNIT_FAILURES 0, JUNIT_ERRORS 0. CRP (breakpoint mode, local Pester 5.6.1): LINE_COVERED 16387, LINE_MISSED 1729, LINE_TOTAL 18116, LINE_PERCENT 90.46, SOURCEFILE_COUNT 203, 85% threshold PASS. Per-file scripts/powershell/poshqc/poshqc.psm1 covered 40 missed 20 (66.67%); scripts/powershell/poshqc/poshqc.testing.psm1 covered 200 missed 0 (100%).

FULL_RUN_SECONDS: 1089
START_UTC: 2026-10-16T07:51:35.0618503Z
JUNIT_TESTS: 10376
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
PRE_EXISTING_FAILURES: none
LINE_COVERED: 16387
LINE_MISSED: 1729
LINE_TOTAL: 18116
LINE_PERCENT: 90.46
SOURCEFILE_COUNT: 203
THRESHOLD_85: PASS

## Line lookups (baseline line numbers)

- L('scripts/powershell/poshqc/poshqc.psm1', 55): ci=1 mi=0
- L('scripts/powershell/poshqc/poshqc.psm1', 56): ci=3 mi=0
- L('scripts/powershell/poshqc/poshqc.psm1', 57): ci=2 mi=0
- L('scripts/powershell/poshqc/poshqc.psm1', 58): ABSENT (line 58 is the closing `)` of `$requiredModules`, a non-executable line; CRP step 6 reports ABSENT)
- L('scripts/powershell/poshqc/poshqc.psm1', 61): ci=4 mi=0
- L('scripts/powershell/poshqc/poshqc.psm1', 74): ci=4 mi=0
- L('scripts/powershell/poshqc/poshqc.testing.psm1', 168): ci=1 mi=0
- L('scripts/powershell/poshqc/poshqc.testing.psm1', 305): ci=1 mi=0

## Per-file values

- scripts/powershell/poshqc/poshqc.psm1: covered=40 missed=20
- scripts/powershell/poshqc/poshqc.testing.psm1: covered=200 missed=0

Note: the local LINE_TOTAL (18116) differs from the CI baseline run 38846579572 (18154) because the CI run's head commit differs from this branch; the authoritative CI comparison is Phase 7.
