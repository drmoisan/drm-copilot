# P2-T1 Claude PowerShell Routing Suite (R2a, R2b)

Timestamp: 2026-10-01T19-16
Edit: in `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`, case `the default reader yields direct mode when the checkpoint file is absent`: inserted `$absentRoot = if ($IsWindows) { 'C:/synthetic-absent-root' } else { '/synthetic-absent-root' }` as the first body line and passed `-Root $absentRoot`.

Command: grep -c -F -e '$absentRoot = if ($IsWindows)' tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
Output Summary: `1`

Command: grep -c -F -e '-Root $absentRoot' tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
Output Summary: `1`
