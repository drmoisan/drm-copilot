Timestamp: 2026-02-16T18-54-17-05:00
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File ./scripts/powershell/BootstrapPC/verify-host.ps1 -NoSuchParameterForNegativeTest
EXIT_CODE: 1
Output Summary: controlled negative invocation produced expected nonzero exit
Failure: verify-host.ps1: A parameter cannot be found that matches parameter name 'NoSuchParameterForNegativeTest'.

--- Command Output ---
verify-host.ps1: A parameter cannot be found that matches parameter name 'NoSuchParameterForNegativeTest'.
