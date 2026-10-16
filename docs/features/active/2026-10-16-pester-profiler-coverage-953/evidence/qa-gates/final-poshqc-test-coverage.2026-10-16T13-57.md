# Final QC: Full Pester Run with Coverage (P8-T16 / P6-T3, sharding path)

Timestamp: 2026-10-16T13-57
Command: sh "SCRATCH/issue-953-p8-t16-p6-t3.sh" (FULL_RUN(final), run in the background) — `New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-final-poshqc.log'); $exit = $LASTEXITCODE; ...; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-final-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-final-junit.xml') -Force`; followed by sh "SCRATCH/issue-953-p8-t16-p6-t3-2.sh" (validity checks a-b, JRP, CRP). No `-ScanFolders` and no `-SettingsPath` argument.
EXIT_CODE: 0

Output Summary:
- FULL_RUN output: EXIT_CODE=0 SECONDS=995 START_UTC=2026-10-16T13:37:20.4011274Z.
- Validity: (a) coverage and JUnit files both written after START_UTC (True/True); (b) exactly 1 log line contains `Code coverage population: source=config`; (c) no `-ScanFolders`/`-SettingsPath`. FULL_RUN valid.
- JRP totals: JUNIT_TESTS 10516, JUNIT_FAILURES 0, JUNIT_ERRORS 0.
- Expected total (P8-T16 substitution 2): 10491 (r1-final JUnit) + 10 (sharding-unit-shard) + 8 (sharding-unit-merge) + 4 (sharding-unit-testing) + (10 (sharding-workflow-tests) - 7 (r1 PoshQcWorkflow.Tests.ps1 testsuite)) = 10516. Equal: YES.
- JRP token checks (18, all PASS, 1 hit each): RS01-RUNSETTINGS-PROFILER-MODE, RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE, RS03-INSTALLER-PESTER-590, RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE, RS05-INSTALLER-PESTER-CEILING-BELOW-6, RS06-TEST-IMPORT-PESTER-MAXIMUM, RS07-WORKFLOW-LINUX-PESTER-RANGE, RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS, RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR, RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR, AC03-POWERSHELL-MODULES-PINNED, AC06-POWERSHELL-MODULE-ZERO-FAILURES, AC07-DRYRUN-COMMITTED-MANIFEST, MC01-LOGGER-DEFAULT-WARNING, MC02-LOGGER-DEFAULT-VERBOSE, MC03-LOGGER-DEFAULT-INFORMATION, MC04-INSTALL-POSTCHECK-THROWS, MC05-SUBMODULE-CACHE-MISS-IMPORT.
- FULL_RUN wall seconds: 995.
- CRP: LINE_COVERED 16827, LINE_MISSED 1469, LINE_TOTAL 18296, LINE_PERCENT 91.97, SOURCEFILE_COUNT 206; CRP steps 2-5 passed; threshold (step 7) PASS.
- Result: PASS.
