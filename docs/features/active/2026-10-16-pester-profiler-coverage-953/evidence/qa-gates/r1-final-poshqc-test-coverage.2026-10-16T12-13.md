# Remediation Cycle 1 - Final Full Pester Run With Coverage (P5-T3)

Timestamp: 2026-10-16T12-13
Command: sh SCRATCH/issue-953-r1-p5-t3.sh (FULL_RUN(final): New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r1-final-poshqc.log'); $exit = $LASTEXITCODE; ...; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-r1-final-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-r1-final-junit.xml') -Force; exit $exit); validity and JRP via sh SCRATCH/issue-953-r1-p5-t3-2.sh; CRP via sh SCRATCH/issue-953-r1-p5-t4.sh
EXIT_CODE: 0
Output Summary: FULL_RUN valid: (a) both artifacts/pester/powershell-coverage.xml and artifacts/pester/pester-junit.xml were written after START_UTC 2026-10-16T11:57:02.4041516Z; (b) the log contains exactly 1 line `Code coverage population: source=config`; (c) no -ScanFolders and no -SettingsPath. Wall seconds: 930.
JRP: JUNIT_TESTS 10491, JUNIT_FAILURES 0, JUNIT_ERRORS 0 (AC-07: zero failed tests). 10491 = R1_BASELINE_JUNIT_TESTS (10488, evidence/remediation-baseline/r1-poshqc-test-coverage.2026-10-16T11-45.md) + 3.
JRP token check (every token hits=1, passed=1, PASS):
- RS01-RUNSETTINGS-PROFILER-MODE, RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE, RS03-INSTALLER-PESTER-590, RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE, RS05-INSTALLER-PESTER-CEILING-BELOW-6, RS06-TEST-IMPORT-PESTER-MAXIMUM, RS07-WORKFLOW-LINUX-PESTER-RANGE, RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS, RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR, RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR: PASS
- MC01-LOGGER-DEFAULT-WARNING, MC02-LOGGER-DEFAULT-VERBOSE, MC03-LOGGER-DEFAULT-INFORMATION, MC04-INSTALL-POSTCHECK-THROWS, MC05-SUBMODULE-CACHE-MISS-IMPORT: PASS
- INST (6 names, see plan Definitions): PASS
- SEAM (3 names, see plan Definitions): PASS
CRP: LINE_COVERED 16702, LINE_MISSED 1468, LINE_TOTAL 18170, LINE_PERCENT 91.92, SOURCEFILE_COUNT 204.
The outer Invoke-PoshQCTest call ran the fixed default seam against the real host modules: the CR-1 range query and the CR-2 bounded import accepted the in-range Pester 5.9.0 recorded by P0-T1.
