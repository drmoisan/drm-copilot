# P6-T11 S824 edits (C15)

Timestamp: 2026-10-09T00-37
Command: grep -c -F -e '-ContextExists' -e 'Get-PrAuthorBodyFileRoot' -e 'PA-21' tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
  0
  The parameter, the seam mock, and row PA-21 are gone; grep exits 1 on a zero count, as expected.
  grep -c -F -e '-RelativeBodyAllowed' tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 -> 1 (PA-24)
  A4: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 LineCount=154
