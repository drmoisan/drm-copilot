# Host-Tools Tests Baseline (issue #953, P0-T23)

Timestamp: 2026-10-16T08-10
Command: TARGETED_RUN(baseline-hosttools, tests/scripts/host-tools.manifest.Tests.ps1;tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1) through SCRATCH/issue-953-p0-t23.sh: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $env:ISSUE953_PATHS = '...'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-baseline-hosttools-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; ...; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-baseline-hosttools.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=..."' followed by the JUnit freshness check and JRP steps 1-4 in the same script
EXIT_CODE: 0
Output Summary: TARGETED_RUN valid (JUnit written after START_UTC 2026-10-16T08:10:46.1717997Z). JRP: tests 27, failures 0, errors 0. Token checks: AC03-POWERSHELL-MODULES-PINNED PASS (1 hit), AC06-POWERSHELL-MODULE-ZERO-FAILURES PASS (1 hit), AC07-DRYRUN-COMMITTED-MANIFEST PASS (1 hit).

JUNIT_TESTS: 27
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
TOKEN AC03-POWERSHELL-MODULES-PINNED: PASS
TOKEN AC06-POWERSHELL-MODULE-ZERO-FAILURES: PASS
TOKEN AC07-DRYRUN-COMMITTED-MANIFEST: PASS
