# P6-T12 Removed parameter and seam absent from hooks and suites (after C16)

Timestamp: 2026-10-09T00-38
Command: grep -r -l -F -e '-ContextExists' -e 'Get-PrAuthorBodyFileRoot' .claude/hooks tests/scripts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
  (no output)
  No hook and no suite names the removed -ContextExists parameter or the removed Get-PrAuthorBodyFileRoot seam; grep -r -l exits 1 when nothing matches, as expected.
  grep -c -F -e '-RelativeBodyAllowed' tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 -> 5 (REG-13 to REG-17)
  A4: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 LineCount=283
