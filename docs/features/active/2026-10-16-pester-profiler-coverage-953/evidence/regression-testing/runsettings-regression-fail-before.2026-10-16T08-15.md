# RunSettings Regression Fail-Before (issue #953, P1-T2, expect-fail)

Timestamp: 2026-10-16T08-15
Command: TARGETED_RUN(regression-before, tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1) through SCRATCH/issue-953-p1-t2.sh: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $env:ISSUE953_PATHS = 'tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-regression-before-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; ...; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-regression-before.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=..."' followed by the JUnit freshness check and JRP steps 1-3 and 5 in the same script
EXIT_CODE: 7
ExpectedExitCode: 7
Output Summary: Expected failure on the pre-fix tree. TARGETED_RUN valid (JUnit written after START_UTC 2026-10-16T08:15:48.4573824Z). JRP: tests 7, failures 7, errors 0. The JRP failure check (step 5) PASSES for all seven RS tokens. The RS03 message contains "5.6.1" (the seam recorded the current pin), the RS05 message contains "above the ceiling" (Pester 6.0.0 was accepted, so the install seam was not invoked), and the RS07 message contains "5.6.1".

JUNIT_TESTS: 7
JUNIT_FAILURES: 7
JUNIT_ERRORS: 0

## JRP failure check (step 5) and failure messages

| Token | Failure check | failure/@message |
|---|---|---|
| RS01-RUNSETTINGS-PROFILER-MODE | PASS | Expected $true, because issue #953 selects profiler-based coverage explicitly, but got $false. |
| RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE | PASS | Expected $false, but got $true. |
| RS03-INSTALLER-PESTER-590 | PASS | Expected strings to be the same, but they were different. String lengths are both 5. Strings differ at index 2. Expected: '5.9.0' But was: '5.6.1' |
| RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE | PASS | Expected $true, because the bundled copy must match the repository copy, but got $false. |
| RS05-INSTALLER-PESTER-CEILING-BELOW-6 | PASS | Expected 1, because an installed Pester 6.0.0 is above the ceiling, but got 0. |
| RS06-TEST-IMPORT-PESTER-MAXIMUM | PASS | Expected Import-Module in module PoshQC to be called 1 times exactly, but was called 0 times |
| RS07-WORKFLOW-LINUX-PESTER-RANGE | PASS | Expected regular expression '-MinimumVersion 5\.9\.0(\s\|$)' to match '          Import-Module Pester -MinimumVersion 5.6.1', but it did not match. |
