# Final QA pass 1: PoshQC coverage run (P6-T6)

Timestamp: 2026-10-17T00-06
Command: sh SCRATCH/tools/run-cr.sh cr-pester-cov -ScanFolderList "tests/scripts/ci,tests/scripts/workflows,tests/scripts/claude-lib/ci-gate"
EXIT_CODE: 0
Output Summary: COVERAGE-RUN-START-UTC 2026-10-17T00:05:13.4672984Z; Code coverage population: source=config (210 files, 208 at baseline plus the two scripts/ci files); Tests Passed: 215, Failed: 0; process exit code 0. Per-file line coverage is read by P6-T7. CI job (the only job that measures PowerShell coverage): poshqc / PowerShell QC (windows-latest).

## Output (ANSI codes stripped, host paths redacted)

```
RUN-CR: cr-pester-cov
COVERAGE-RUN-START-UTC: 2026-10-17T00:05:13.4672984Z
Code coverage population: source=config; files=210

Starting discovery in 10 files.
Discovery found 215 tests in 336ms.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\ci\CiChangeScope.Tests.ps1 867ms (306ms|417ms)
[+] <WORKSPACE_ROOT>\tests\scripts\ci\CiDocsOnlyPathsConfig.Tests.ps1 204ms (76ms|111ms)
[+] <WORKSPACE_ROOT>\tests\scripts\ci\Invoke-CiChangeScope.Tests.ps1 635ms (445ms|154ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\CiGate.Manifest.Tests.ps1 59ms (15ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\Invoke-CiGateParser.Tests.ps1 295ms (180ms|90ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiChangeScopeWorkflow.Tests.ps1 333ms (232ms|78ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1 52ms (15ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 129ms (74ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 122ms (72ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 60ms (15ms|32ms)
Tests completed in 2.82s
Tests Passed: 215, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 1.22% / 0%. 27,547 analyzed Commands in 210 Files.
Wrote Koverage coverage copy: <WORKSPACE_ROOT>\artifacts\pester\powershell-coverage.koverage.xml
EXIT_CODE_COMPUTED: 0
```
