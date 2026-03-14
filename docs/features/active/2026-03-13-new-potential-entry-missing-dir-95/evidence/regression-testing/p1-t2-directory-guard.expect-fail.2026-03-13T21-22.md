# P1-T2 — Directory Guard Regression Test: Expected Failure

- Timestamp: 2026-03-13T21-22
- Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"
- EXIT_CODE: 1
- Failure: `contains the parent-directory guard block before copying the template in both production scripts` — NotSupportedException: Cannot convert 'System.Object[]' to the type 'System.String' required by parameter 'ChildPath' (array syntax bug in @() construction caught and fixed before running production fix)

Note: The test itself had a bug — `@(Join-Path ..., Join-Path ...)` was parsed as binding the second Join-Path as a ChildPath argument, producing an Object[]. This was the expected-fail signal confirming both the test and production code required correction.
