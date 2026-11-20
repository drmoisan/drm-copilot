# dotnet-http exact-case lookup - fail-before run ([P3-T1], [expect-fail])

Timestamp: 2026-11-04T15-00
Command: sh SCRATCH/issue-1033-pester-files.sh tests/scripts/claude-lib/docs/DocsAnalyzerDotnetHttp.Tests.ps1 (one `Invoke-Pester` process, `Run.PassThru`; counts from the result object), run before the [P3-T2] module change
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Total=11, Passed=10, Failed=1 (the expected failure). Every other test in the file passes. EXIT_CODE records the failed-test outcome of the run (the launcher itself exits 0 because Invoke-Pester runs without Run.Exit).

## Failing test

`Invoke-DocsAnalyzerDotnetHttp.conditional compilation, selection, bounds and duplicates.recognizes verb attributes and Map* methods by their exact case and ignores a wrong-case name`

Failure message:

```text
Expected @('GET /c', 'GET /ok'), because only the exact-case HttpGet attribute and MapGet call are routes, but got @('GET /a', 'GET /c', 'GET /lower', 'GET /ok', 'POST /b', 'POST /upper').
```

The case-insensitive default hashtables `$script:DocsDotnetVerbAttribute` and `$script:DocsDotnetMapMethod` also match `Httpget`, `HTTPPOST`, `Mapget` and `MapPOST`, which yields the four extra routes `GET /a`, `POST /b`, `GET /lower` and `POST /upper`.
