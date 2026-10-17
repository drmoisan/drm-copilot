# Baseline per-suite test counts ([P0-T12])

Timestamp: 2026-10-08T17-38
Command: JUNIT_EXTRACT (pwsh reading artifacts/pester/pester-junit.xml; plan template, run unchanged)
EXIT_CODE: 0
Output Summary: ten existing suites have positive counts; the seven new suites report 0; two baseline failures recorded below (one in enforce-pr-author-skill.Tests.ps1, one in codex-pretooluse-integration.Tests.ps1).

BASE_COUNT enforce-completion-consistency.Tests.ps1=47
BASE_COUNT enforce-completion-consistency.EditTarget.Tests.ps1=12
BASE_COUNT enforce-completion-consistency.Payload.Tests.ps1=7
BASE_COUNT enforce-completion-consistency-codex.Tests.ps1=4
BASE_COUNT PreToolUseSchema.Contract.Tests.ps1=15
BASE_COUNT codex-completion-consistency-hook.Tests.ps1=9
BASE_COUNT enforce-completion-consistency-epic-scope.Tests.ps1=6
BASE_COUNT codex-pretooluse-transport.Tests.ps1=56
BASE_COUNT legacy-codex-hook-contracts.Tests.ps1=43
BASE_COUNT codex-pretooluse-integration.Tests.ps1=7

SUITE_TESTCASES enforce-completion-consistency.EditSemantics.Tests.ps1=0
SUITE_TESTCASES enforce-completion-consistency.FailClosed.Tests.ps1=0
SUITE_TESTCASES enforce-completion-consistency.DefaultReader.Tests.ps1=0
SUITE_TESTCASES enforce-completion-consistency-edit-target.Tests.ps1=0
SUITE_TESTCASES enforce-completion-consistency-edit-semantics.Tests.ps1=0
SUITE_TESTCASES enforce-completion-consistency-fail-closed.Tests.ps1=0
SUITE_TESTCASES enforce-completion-consistency-default-reader.Tests.ps1=0

Baseline failure set (verbatim):
FAILED_CASE=enforce-pr-author-skill.Tests.ps1 :: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED_CASE=codex-pretooluse-integration.Tests.ps1 :: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
