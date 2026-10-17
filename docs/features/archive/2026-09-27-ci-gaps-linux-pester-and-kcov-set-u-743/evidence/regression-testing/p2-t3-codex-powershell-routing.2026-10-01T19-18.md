# P2-T3 Codex PowerShell Routing Suite (R2a, R2b)

Timestamp: 2026-10-01T19-18
Edit: in `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`, same-named case: inserted the `$absentRoot` line as the first body line and replaced `-Root 'C:/synthetic-absent-root'` with `-Root $absentRoot` on the single-line invocation.

Command: grep -c -F -e '$absentRoot = if ($IsWindows)' tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
Output Summary: `1`

Command: grep -c -F -e '-Root $absentRoot' tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
Output Summary: `1`
