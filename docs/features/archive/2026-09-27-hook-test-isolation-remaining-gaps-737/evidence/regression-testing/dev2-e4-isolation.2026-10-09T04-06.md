# P5-T2 DEV-2 isolation of E4 from the local item checkpoint

Timestamp: 2026-10-09T04-06
Command: Route C: CR-PESTER-LIST over E4 with the DEV-2 named patterns; CR-PESTER-LIST over N2 (AC-4 pattern for E4); CR-LINES; CR-HERMETIC; git diff REMOVED-LINES count; hook immutability diff and porcelain status, via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
ITEM-CHECKPOINT-PRESENT: True
RUN-1 (E4 CR-PESTER-LIST)
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | Result=Passed
SUITE: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | Passed=8 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
NAMED: DEV-2 * | Passed=1 | Failed=0 | Total=1
NAMED: allows every registered handler* | Passed=1 | Failed=0 | Total=1
NAMED: fails closed* | Passed=2 | Failed=0 | Total=2
NAMED: reports enforce-completion-consistency* | Passed=1 | Failed=0 | Total=1
NAMED: leaves no Codex batch-budget* | Passed=1 | Failed=0 | Total=1
TOTAL: Passed=8 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
RUN-2 (N2 CR-PESTER-LIST)
NAMED: AC-4 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
TOTAL: Passed=98 | Failed=122 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
N2-EXIT_CODE: 1
LINES: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | 225
LINES-OVER-500: 0
HERMETIC: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | addedLines=15 | matches=0
HERMETIC-MATCH-COUNT: 0
REMOVED-LINES: 0
HOOK-DIFF-NAME-ONLY-COUNT: 0
HOOK-STATUS-PORCELAIN-COUNT: 0
DEV-2-EXERCISED (fail-before reference: P0-T12 artifact SUITE line of E4 shows Failed=1)
