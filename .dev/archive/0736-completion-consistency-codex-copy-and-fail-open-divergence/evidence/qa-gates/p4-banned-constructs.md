# Banned-construct scan ([P4-T1])

Timestamp: 2026-10-08T18-00
Command: grep -c -E "TestDrive|New-TemporaryFile|env:TEMP|Set-Location|Push-Location|Start-Sleep|GetTempPath|Out-File|Set-Content|New-Item" <ten test files from P1-T11>
EXIT_CODE: 0
Output Summary: the nine files other than the transport suite print `<path>:0`; `codex-pretooluse-transport.Tests.ps1:6` (the six pre-existing payload literals). Exit 0 because the transport count is non-zero.
