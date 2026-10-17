# Final PoshQC Full Pester Run with Coverage (issue #953, P6-T3, post-split restart pass)

Timestamp: 2026-10-16T09-55
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-final-poshqc.log'); $exit = $LASTEXITCODE; $end = [datetime]::UtcNow; "EXIT_CODE=$exit SECONDS=$([int]($end - $start).TotalSeconds) START_UTC=$($start.ToString('o'))"; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-final-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-final-junit.xml') -Force; exit $exit' (FULL_RUN(final), script SCRATCH/issue-953-p6-t3.sh, run with sh in the background); reduction: SCRATCH/issue-953-p6-t3-2.sh (FULL_RUN validity checks, JRP steps 1-4, CRP steps 1-5 and 7)
EXIT_CODE: 0
Output Summary: FULL_RUN valid: (a) powershell-coverage.xml and pester-junit.xml both written after START_UTC 2026-10-16T09:39:03.7871724Z; (b) exactly 1 log line contains "Code coverage population: source=config"; (c) no -ScanFolders and no -SettingsPath argument. FULL_RUN wall seconds: 942. JRP: JUNIT_TESTS 10388 = 10376 (P0-T22) + 7 (RS) + 5 (module-coverage-tests.2026-10-16T08-26.md), JUNIT_FAILURES 0, JUNIT_ERRORS 0; the decision D9 split leaves the total unchanged. All fifteen tokens (RS01-RS07, AC03/AC06/AC07 HT, MC01-MC05) PASS. CRP: LINE_COVERED 16647, LINE_MISSED 1469, LINE_TOTAL 18116, LINE_PERCENT 91.89, SOURCEFILE_COUNT 203, 85% threshold PASS.

FULL_RUN_SECONDS: 942
START_UTC: 2026-10-16T09:39:03.7871724Z
JUNIT_TESTS: 10388
EXPECTED_JUNIT_TESTS: 10388
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
LINE_COVERED: 16647
LINE_MISSED: 1469
LINE_TOTAL: 18116
LINE_PERCENT: 91.89
SOURCEFILE_COUNT: 203
THRESHOLD_85: PASS

## JRP token checks

- RS01-RUNSETTINGS-PROFILER-MODE: PASS
- RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE: PASS
- RS03-INSTALLER-PESTER-590: PASS
- RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE: PASS
- RS05-INSTALLER-PESTER-CEILING-BELOW-6: PASS
- RS06-TEST-IMPORT-PESTER-MAXIMUM: PASS
- RS07-WORKFLOW-LINUX-PESTER-RANGE: PASS
- AC03-POWERSHELL-MODULES-PINNED: PASS
- AC06-POWERSHELL-MODULE-ZERO-FAILURES: PASS
- AC07-DRYRUN-COMMITTED-MANIFEST: PASS
- MC01-LOGGER-DEFAULT-WARNING: PASS
- MC02-LOGGER-DEFAULT-VERBOSE: PASS
- MC03-LOGGER-DEFAULT-INFORMATION: PASS
- MC04-INSTALL-POSTCHECK-THROWS: PASS
- MC05-SUBMODULE-CACHE-MISS-IMPORT: PASS
