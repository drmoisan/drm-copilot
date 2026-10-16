# Baseline PoshQC coverage run (P0-T11)

Timestamp: 2026-10-16T23-25
Command: sh SCRATCH/tools/run-cr.sh cr-pester-cov -ScanFolderList "tests/scripts/workflows,tests/scripts/claude-lib/ci-gate"
EXIT_CODE: 0
Output Summary: COVERAGE-RUN-START-UTC 2026-10-16T23:25:56.3940329Z; Code coverage population: source=config (208 files); Tests Passed: 69, Failed: 0; Pester reported "Covered 0.2% / 0%" of 27,230 analyzed commands (the scan folders exercise only a small part of the config population). Process exit code 0. The numeric line-coverage baseline is read by P0-T12. CI job: poshqc / PowerShell QC (windows-latest).

## Output (ANSI codes stripped, host paths redacted)

```
RUN-CR: cr-pester-cov
COVERAGE-RUN-START-UTC: 2026-10-16T23:25:56.3940329Z
Code coverage population: source=config; files=208

Starting discovery in 6 files.
Discovery found 69 tests in 318ms.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\CiGate.Manifest.Tests.ps1 528ms (85ms|309ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\Invoke-CiGateParser.Tests.ps1 584ms (413ms|114ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1 82ms (17ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 164ms (101ms|39ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 148ms (77ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 65ms (19ms|26ms)
Tests completed in 1.59s
Tests Passed: 69, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 0.2% / 0%. 27,230 analyzed Commands in 208 Files.
Wrote Koverage coverage copy: <WORKSPACE_ROOT>\artifacts\pester\powershell-coverage.koverage.xml
EXIT_CODE_COMPUTED: 0
```
