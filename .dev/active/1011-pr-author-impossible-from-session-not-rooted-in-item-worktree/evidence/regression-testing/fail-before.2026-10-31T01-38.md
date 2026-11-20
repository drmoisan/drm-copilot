# Fail-Before Run (Issue #1011)

Timestamp: 2026-10-31T01-38
Command: sh SCRATCH/issue-1011-pester-targeted.sh "tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1,tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1" (one process, unmodified production hooks and documents); then sh SCRATCH/issue-1011-read-results.sh -NoCoverage
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- JUnit (artifacts/pester/pester-junit.xml): tests 96, failures 24, errors 0.
- Failing, by suite (all expected):
  - enforce-pr-author-command-allowlist.Tests.ps1: AL-50, AL-51, AL-52, AL-67.
  - enforce-pr-author-skill.TargetResolution.Tests.ps1: TR-01, TR-02, TR-03, TR-04, TR-05, TR-06 (SessionRoot), TR-06 (DelegationIdentity), TR-07, TR-09.
  - pr-author-coordinator-topology-contract.Tests.ps1: CT-01, CT-02, CT-03, CT-04, CT-05 (agent and skill each), CT-07.
- Passing (expected): AL-01 to AL-49 (every pre-existing row, including AL-34 with the new `<item worktree>` substitution), AL-53 to AL-66 (new deny rows), TR-08, CT-06 (agent and skill), and the four pre-existing TargetResolution rows plus the interception probe.
