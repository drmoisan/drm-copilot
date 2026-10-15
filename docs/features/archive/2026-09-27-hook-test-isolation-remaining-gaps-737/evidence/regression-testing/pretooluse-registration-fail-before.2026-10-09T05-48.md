# P9-T2 AC-20 fail-before against the unmodified helper

Timestamp: 2026-10-09T05-48
Command: Route C: CR-PESTER-LIST over tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 with patterns [AC-20 *] and CR-LINES via pwsh -NoProfile -File
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | Result=Failed
SUITE: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | Passed=8 | Failed=2 | Skipped=0 | NotRun=0 | ProbeRows=0
NAMED: AC-20 * | Passed=0 | Failed=2 | Total=2
FAILED: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-20 one registration returns an array of count one :: Expected $true, because a single registration must still be returned as an array, but got $false.
FAILED: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.AC-20 zero registrations return an empty array that is not null :: Expected $true, because an empty registration set must be an empty array and not null, but got $false.
TOTAL: Passed=8 | Failed=2 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 1
LINES: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | 243
LINES-OVER-500: 0
