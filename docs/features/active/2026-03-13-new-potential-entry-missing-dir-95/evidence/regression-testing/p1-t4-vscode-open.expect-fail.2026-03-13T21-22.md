# P1-T4 — VSCode Open Regression Test: Expected Failure

- Timestamp: 2026-03-13T21-22
- Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"
- EXIT_CODE: 1
- Failure: `uses reuse-window CLI invocation without Start-Process inside Invoke-VSCodeOpen in both production scripts` — NotSupportedException: Cannot convert 'System.Object[]' to the type 'System.String' required by parameter 'ChildPath' (same array syntax bug in @() construction; production code still contained Start-Process and lacked --reuse-window)
