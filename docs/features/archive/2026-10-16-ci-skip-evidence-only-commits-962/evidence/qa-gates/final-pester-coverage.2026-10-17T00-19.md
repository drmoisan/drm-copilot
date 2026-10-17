# Final QA pass 2: PoshQC coverage run (P6-T6)

Timestamp: 2026-10-17T00-19
Command: sh SCRATCH/tools/run-cr.sh cr-pester-cov -ScanFolderList "tests/scripts/ci,tests/scripts/workflows,tests/scripts/claude-lib/ci-gate"
EXIT_CODE: 0
Output Summary: COVERAGE-RUN-START-UTC 2026-10-17T00:18:19.8704726Z; Code coverage population: source=config (214 files after the #952 merge added PowerShell sources); Tests Passed: 236, Failed: 0; process exit code 0. Per-file line coverage is read by P6-T7. CI job (the only job that measures PowerShell coverage): poshqc / PowerShell QC (windows-latest).

## Output (ANSI codes stripped, host paths redacted)

```
RUN-CR: cr-pester-cov
COVERAGE-RUN-START-UTC: 2026-10-17T00:18:19.8704726Z
Code coverage population: source=config; files=214

Starting discovery in 12 files.
Discovery found 236 tests in 360ms.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\ci\CiChangeScope.Tests.ps1 790ms (295ms|351ms)
[+] <WORKSPACE_ROOT>\tests\scripts\ci\CiDocsOnlyPathsConfig.Tests.ps1 110ms (34ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\ci\Invoke-CiChangeScope.Tests.ps1 500ms (365ms|111ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\CiGate.Manifest.Tests.ps1 72ms (22ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\Invoke-CiGateParser.Tests.ps1 379ms (262ms|89ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\Invoke-MergeConfirmationParser.Tests.ps1 135ms (69ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\MergeConfirmationParser.Manifest.Tests.ps1 53ms (12ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiChangeScopeWorkflow.Tests.ps1 349ms (241ms|85ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1 117ms (74ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 124ms (70ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 122ms (68ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 66ms (18ms|37ms)
Tests completed in 2.85s
Tests Passed: 236, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 1.46% / 0%. 27,796 analyzed Commands in 214 Files.
Wrote Koverage coverage copy: <WORKSPACE_ROOT>\artifacts\pester\powershell-coverage.koverage.xml
EXIT_CODE_COMPUTED: 0
```
