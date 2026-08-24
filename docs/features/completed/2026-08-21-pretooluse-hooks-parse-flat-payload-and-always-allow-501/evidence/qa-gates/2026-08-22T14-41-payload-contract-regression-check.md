Timestamp: 2026-08-22T14-41
Command: pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 -PassThru | Select-Object -Property TotalCount,PassedCount,FailedCount,SkippedCount | Format-List"
EXIT_CODE: 0
Output Summary: 77 tests, 77 passed, 0 failed, 0 skipped. The AC-8 structural guard confirms neither `enforce-powershell-batch-budget.ps1` nor `enforce-python-batch-budget.ps1` reintroduced `$env:CLAUDE_TOOL_INPUT` or `$env:CLAUDE_HOOK_INPUT`, and both still call `Read-ClaudeHookRawPayload` through the shared module.
