Timestamp: 2026-06-25T07-45
Command: pwsh -NoLogo -NoProfile -Command '$result = Invoke-Pester -Path "tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1" -Output Detailed -PassThru; if ($result.FailedCount -gt 0) { exit 1 }'
EXIT_CODE: 1
Output Summary:
- Pester discovered 17 tests in tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1.
- 16 tests passed and 1 test failed.
- The new Issue #232 regression failed before implementation because Invoke-CompletionConsistencyDecision returned allow instead of block for a complete checkpoint with ci_gate evidence but no pr_gate evidence.
