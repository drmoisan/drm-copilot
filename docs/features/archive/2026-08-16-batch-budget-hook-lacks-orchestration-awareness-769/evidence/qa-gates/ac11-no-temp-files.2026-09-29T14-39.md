# AC-11 Temporary-File Check (#769, P9-T12)

Timestamp: 2026-09-29T14-39
Command: git grep -n -F -e "New-TemporaryFile" -e "GetTempFileName" -e "GetTempPath" -e "TestDrive" -e "Set-Content" -e "Out-File" -e "New-Item" -- tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: no output; none of the four test files creates or writes a file.
