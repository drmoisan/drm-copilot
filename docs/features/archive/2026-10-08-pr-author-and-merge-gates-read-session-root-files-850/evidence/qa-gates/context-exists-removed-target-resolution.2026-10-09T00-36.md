# P6-T10 -ContextExists removed from enforce-pr-author-skill.TargetResolution.Tests.ps1

Timestamp: 2026-10-09T00-36
Command: grep -c -F -e '-ContextExists' tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
  0
  C11 removed the five call-site arguments and added Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true } to the two rows of Context 'the checkpoint is taken from the resolved target, not the session root'; grep exits 1 on a zero count, as expected.
