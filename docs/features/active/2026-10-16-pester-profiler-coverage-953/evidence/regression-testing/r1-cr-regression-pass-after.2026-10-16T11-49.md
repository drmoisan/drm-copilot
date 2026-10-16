# Remediation Cycle 1 - CR-1/CR-2 Regression Pass-After (P2-T5)

Timestamp: 2026-10-16T11-49
Command: sh SCRATCH/issue-953-r1-p2-t5.sh (TARGETED_RUN(cr-after, tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1): $env:ISSUE953_PATHS = 'tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-r1-cr-after-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; ...; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-r1-cr-after.log')); JRP via sh SCRATCH/issue-953-r1-p2-t5-2.sh
EXIT_CODE: 0
Output Summary: Run after P2-T1/P2-T2 (and P2-T4 mirror). Run valid (START_UTC 2026-10-16T11:49:40.7762337Z; JUnit written later). JRP totals: tests 10, failures 0, errors 0.
JRP token check (all hits=1, passed=1): RS01-RUNSETTINGS-PROFILER-MODE PASS; RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE PASS; RS03-INSTALLER-PESTER-590 PASS; RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE PASS; RS05-INSTALLER-PESTER-CEILING-BELOW-6 PASS; RS06-TEST-IMPORT-PESTER-MAXIMUM PASS; RS07-WORKFLOW-LINUX-PESTER-RANGE PASS; RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS PASS; RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR PASS; RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR PASS.
Fail-before counterpart: evidence/regression-testing/r1-cr-regression-fail-before.2026-10-16T11-47.md (tests 10, failures 3: RS08, RS09, RS10).
