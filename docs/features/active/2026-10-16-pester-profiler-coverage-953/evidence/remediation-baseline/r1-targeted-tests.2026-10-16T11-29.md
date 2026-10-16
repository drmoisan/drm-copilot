# Remediation Cycle 1 - Targeted Test Baseline (P0-T16)

Timestamp: 2026-10-16T11-29
Command: sh SCRATCH/issue-953-r1-p0-t16.sh (TARGETED_RUN(baseline-targeted, R1_SET): $env:ISSUE953_PATHS = '<R1_SET joined with ;>'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-r1-baseline-targeted-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @($env:ISSUE953_PATHS -split '';''); $c.Run.Exit = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = ''JUnitXml''; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c.Output.Verbosity = ''Detailed''; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-r1-baseline-targeted.log')); JRP via sh SCRATCH/issue-953-r1-p0-t16-2.sh
EXIT_CODE: 0
Output Summary: Run valid (START_UTC 2026-10-16T11:28:33.9272991Z; JUnit LastWriteTimeUtc 2026-10-16T11:28:41.4543207Z, later). JRP totals: tests 88, failures 0, errors 0.
JRP token check (every token: hits=1, passed=1, PASS):
- RS01-RUNSETTINGS-PROFILER-MODE PASS; RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE PASS; RS03-INSTALLER-PESTER-590 PASS; RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE PASS; RS05-INSTALLER-PESTER-CEILING-BELOW-6 PASS; RS06-TEST-IMPORT-PESTER-MAXIMUM PASS; RS07-WORKFLOW-LINUX-PESTER-RANGE PASS
- MC01-LOGGER-DEFAULT-WARNING PASS; MC02-LOGGER-DEFAULT-VERBOSE PASS; MC03-LOGGER-DEFAULT-INFORMATION PASS; MC04-INSTALL-POSTCHECK-THROWS PASS; MC05-SUBMODULE-CACHE-MISS-IMPORT PASS
- INST: registers PSGallery when absent and installs required modules PASS; logs a warning when PSGallery trust cannot be set PASS; skips installation when required modules are already present PASS; throws when an injected install operation fails PASS; keeps manifest dependency requirements empty to allow bootstrap installs PASS; reports already-installed modules without external module lookup PASS
- SEAM: imports the requested module with -Global PASS; throws the supplied error when the module is unavailable PASS; validates Pester module availability through injected module lookup PASS
This is the behavior baseline for CR-3.

R1_TARGETED_BASELINE_TESTS: 88
