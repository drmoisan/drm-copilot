# P6-T9 Check 6 isolation in Context 'allowed commands' (rule EE, EE-1)

Timestamp: 2026-10-09T00-35
Command: grep -c -F -e 'Get-PrAuthorCheckpointContent' tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
EXIT_CODE: 0
Output Summary:
  4
  Three pre-existing occurrences (contexts 'receipt - all checks pass (allow)', 'Get-PrAuthorBypassReason helper', 'Test-PrAuthorBypassRequired helper') plus the new Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { $null } line in the BeforeEach of Context 'allowed commands' (C10 revision-4 bullet).
