# Remediation Cycle 1 - CR-1/CR-2 Regression Fail-Before (P1-T5, expect-fail)

Timestamp: 2026-10-16T11-47
Command: sh SCRATCH/issue-953-r1-p1-t5.sh (TARGETED_RUN(cr-before, tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1): $env:ISSUE953_PATHS = 'tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-r1-cr-before-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; ...; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-r1-cr-before.log')); JRP via sh SCRATCH/issue-953-r1-p1-t5-2.sh
EXIT_CODE: 3
ExpectedExitCode: 3
Output Summary: Run on the pre-fix production tree (PoshQC.Testing.psm1 unchanged since REM_BASE_SHA). Run valid (START_UTC 2026-10-16T11:47:35.9959919Z; JUnit written later). JRP totals: tests 10, failures 3, errors 0.
JRP token check: RS01-RUNSETTINGS-PROFILER-MODE PASS; RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE PASS; RS03-INSTALLER-PESTER-590 PASS; RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE PASS; RS05-INSTALLER-PESTER-CEILING-BELOW-6 PASS; RS06-TEST-IMPORT-PESTER-MAXIMUM PASS; RS07-WORKFLOW-LINUX-PESTER-RANGE PASS.
JRP failure check:
- RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS: failed (PASS). Message: `Expected Import-Module in module PoshQC to be called 1 times exactly, but was called 0 times` (the import lacked -MinimumVersion).
- RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR: failed (PASS). Message: `Expected an exception with message like '*Run Install-PoshQCTool*' to be thrown, but the message was 'Settings not found: /rs09-missing-settings.psd1'.` (thrown at scripts/powershell/PoshQC/PoshQC.Testing.psm1:309). The presence check accepted the out-of-range 6.0.0.
- RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR: failed (PASS). Message: `Expected an exception with message like '*Run Install-PoshQCTool*' to be thrown, but the message was 'Settings not found: /rs10-missing-settings.psd1'.` (thrown at scripts/powershell/PoshQC/PoshQC.Testing.psm1:309). The presence check accepted the out-of-range 3.4.0.
