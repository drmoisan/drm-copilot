# Per-suite counts, final pass ([P5-T5])

Timestamp: 2026-10-08T18-32
Command: JUNIT_EXTRACT (pwsh reading artifacts/pester/pester-junit.xml; plan template, run unchanged)
EXIT_CODE: 0
Output Summary: seven new suites report 37, 13, 7, 16, 37, 13, 7 test cases; the ten existing suites report their BASE_COUNT value, except codex-pretooluse-transport.Tests.ps1 which reports 51 (56 minus 5); the two FAILED_CASE lines are exactly the [P0-T12] baseline failure set.

SUITE_TESTCASES enforce-completion-consistency.Tests.ps1=47
SUITE_TESTCASES enforce-completion-consistency.EditTarget.Tests.ps1=12
SUITE_TESTCASES enforce-completion-consistency.Payload.Tests.ps1=7
SUITE_TESTCASES enforce-completion-consistency-codex.Tests.ps1=4
SUITE_TESTCASES PreToolUseSchema.Contract.Tests.ps1=15
SUITE_TESTCASES codex-completion-consistency-hook.Tests.ps1=9
SUITE_TESTCASES enforce-completion-consistency-epic-scope.Tests.ps1=6
SUITE_TESTCASES codex-pretooluse-transport.Tests.ps1=51
SUITE_TESTCASES legacy-codex-hook-contracts.Tests.ps1=43
SUITE_TESTCASES codex-pretooluse-integration.Tests.ps1=7
SUITE_TESTCASES enforce-completion-consistency.EditSemantics.Tests.ps1=37
SUITE_TESTCASES enforce-completion-consistency.FailClosed.Tests.ps1=13
SUITE_TESTCASES enforce-completion-consistency.DefaultReader.Tests.ps1=7
SUITE_TESTCASES enforce-completion-consistency-edit-target.Tests.ps1=16
SUITE_TESTCASES enforce-completion-consistency-edit-semantics.Tests.ps1=37
SUITE_TESTCASES enforce-completion-consistency-fail-closed.Tests.ps1=13
SUITE_TESTCASES enforce-completion-consistency-default-reader.Tests.ps1=7
FAILED_CASE=enforce-pr-author-skill.Tests.ps1 :: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED_CASE=codex-pretooluse-integration.Tests.ps1 :: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
