# Baseline: Scoped Pester (suite set A)

Timestamp: 2026-10-08T17-32
Command: sh <SCRATCHPAD>/s-pester.sh A
EXIT_CODE: 1
Output Summary:
PESTER_SET: A FILES=45
PESTER_TOTAL: 1016
PESTER_PASSED: 1015
PESTER_FAILED: 1
PESTER_SKIPPED: 0
PESTER_FAILED_BLOCKS: 0
PESTER_FAILED_CONTAINERS: 0
FAILED_TEST: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILURE_MESSAGE: Expected strings to be the same, but they were different. (tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:154; expected 'allow', was 'deny')

B_SCOPED (pre-existing failing tests in set A):
- enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists

Note: the exit code 1 is caused only by the B_SCOPED member above; the in-scope production paths equal BASE_SHA (production-equals-base artifact).
