# Registration REG-5 Fail-Before ([P5-T8], expect-fail)

Timestamp: 2026-10-12T04-05
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: TotalCount=11, PassedCount=10, FailedCount=1, FailedContainersCount=0. The single failure is REG-5; its message names prd-feature.md and RequiredArtifact (the repeated argument at .claude/agents/prd-feature.md:18).

TotalCount=11
PassedCount=10
FailedCount=1
FailedContainersCount=0
FAILED: E2 SubagentStop registrations and seams.REG-5 no registration passes the same parameter name twice

REG-5 failure message (Detailed output):
  [-] REG-5 no registration passes the same parameter name twice
   Expected $null or empty, because prd-feature.md: repeated -RequiredArtifact, but got 'prd-feature.md: repeated -RequiredArtifact'.
