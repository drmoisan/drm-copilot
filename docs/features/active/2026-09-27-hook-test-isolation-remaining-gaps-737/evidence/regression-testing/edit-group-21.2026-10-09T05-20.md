# P5 group slot EG-21

Timestamp: 2026-10-09T05-20
Command: Route C: CR-PESTER-LIST over the EG-21 suites; CR-COMPARE against the P0-T12 artifact (E2 and E4 by design); CR-PESTER-LIST over N2 with the AC-4 and AC-6 patterns of the group; CR-LINES, via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
GROUP: EG-21
GROUP-SUITES: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1, tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1, tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1, tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
EDIT-NOTES:
EDITED tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 :: form=direct probe=no, guard findings=0, FORMAT-CLEAN; EP-6 adaptation: the suite exercises the real registry and allowlist functions Get-EpicPlanningRegisteredMcpTool and Test-EpicPlanningBashAllowed over committed registry files, so their real bodies are stashed before the baseline null Mocks and restored by a Describe-level BeforeEach; no existing line changed
EDITED tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 :: form=helper probe=yes(Codex) orig=244 lines=249 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
DEV-2-HANDLED tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 :: form=none probe=no orig=225 lines=225 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
EDITED tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 :: form=direct probe=no, guard findings=0, FORMAT-CLEAN; EP-6 adaptation: the suite reads committed fixtures through the real default reader (a plain null Mock failed 5 rows), so the baseline null Mock carries a ParameterFilter that excludes the committed fixtures root
RUN-1 (group CR-PESTER-LIST)
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | Result=Passed
SUITE: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | Passed=38 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | Passed=36 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | Passed=8 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | Passed=7 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
TOTAL: Passed=89 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
RUN-2 (CR-COMPARE; only the group COMPARE lines count)
COMPARE: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | result=BY-DESIGN-OK
COMPARE: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | result=EQUAL
COMPARE-EXIT_CODE: 1
RUN-3 (N2 AC-4 and AC-6 patterns for the group)
NAMED: AC-4 tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 * | Passed=0 | Failed=0 | Total=0
NAMED: AC-4 tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 * | Passed=0 | Failed=0 | Total=0
NAMED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 * | Passed=0 | Failed=0 | Total=0
N2-EXIT_CODE: 0
LINES: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | 325
LINES: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | 249
LINES: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | 225
LINES: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | 154
LINES-OVER-500: 0
