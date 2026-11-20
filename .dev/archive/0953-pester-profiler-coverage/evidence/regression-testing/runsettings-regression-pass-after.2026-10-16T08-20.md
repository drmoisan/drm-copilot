# RunSettings Regression Pass-After (issue #953, P3-T8)

Timestamp: 2026-10-16T08-20
Command: TARGETED_RUN(regression-after, tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1) through SCRATCH/issue-953-p3-t8.sh: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $env:ISSUE953_PATHS = 'tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-regression-after-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; ...; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-regression-after.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=..."' followed by the JUnit freshness check and JRP steps 1-4 in the same script
EXIT_CODE: 0
Output Summary: TARGETED_RUN valid (JUnit written after START_UTC 2026-10-16T08:19:53.9934055Z). JRP: tests 7, failures 0, errors 0. All seven RS tokens PASS (one hit each). Paired with the fail-before evidence runsettings-regression-fail-before.2026-10-16T08-15.md (7 of 7 failed).

JUNIT_TESTS: 7
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
TOKEN RS01-RUNSETTINGS-PROFILER-MODE: PASS
TOKEN RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE: PASS
TOKEN RS03-INSTALLER-PESTER-590: PASS
TOKEN RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE: PASS
TOKEN RS05-INSTALLER-PESTER-CEILING-BELOW-6: PASS
TOKEN RS06-TEST-IMPORT-PESTER-MAXIMUM: PASS
TOKEN RS07-WORKFLOW-LINUX-PESTER-RANGE: PASS
