# P1-T10 — VSCode Open Regression Test: PASS

- Timestamp: 2026-03-13T21-22
- Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path './tests/scripts/dev-tools/new-potential-entry.Tests.ps1' -Output Detailed"
- EXIT_CODE: 0
- Output Summary: Tests Passed: 43, Failed: 0, Skipped: 0 — `uses reuse-window CLI invocation without Start-Process inside Invoke-VSCodeOpen in both production scripts` [+] PASSED for both production scripts. Body contains --reuse-window, VSCODE_IPC_HOOK_CLI detection, Get-Process *insiders* detection, and no Start-Process.
