# PA-B1 fail-before: new rows run against the unfixed generator

Timestamp: 2026-10-28T22-58
Command: Invoke-Pester with a PesterConfiguration (Run.Path = tests/scripts/ci/New-FileSizeBaseline.Tests.ps1, JUnitXml to artifacts/pester/pester-junit.xml, coverage disabled), PowerShell 7 from a sh launcher under SCRATCH; production script unchanged
EXIT_CODE: 1 (expected: [expect-fail]; the launcher printed RESULT total=15 passed=14 failed=1)
ExpectedExitCode: 1
Output Summary:
- Counts read from artifacts/pester/pester-junit.xml: total 15, passed 14, failed 1, errors 0, skipped 0.
- The single failure is the row "800 text lines plus a final empty element" of "counts a blob whose last element is empty like the logical line count". The unfixed generator counts the 801 elements as 800 (joined text ends in LF, which the module subtracts), so the file is not baselined: expected key present with count 801, observed absent (count 800).
- The other three new rows (801 text lines, single empty element, empty element array) and all 11 earlier tests pass.
