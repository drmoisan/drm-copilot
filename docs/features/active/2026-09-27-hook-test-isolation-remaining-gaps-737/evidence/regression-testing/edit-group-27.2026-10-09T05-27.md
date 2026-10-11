# P5 group slot EG-27

Timestamp: 2026-10-09T05-27
Command: Route C: CR-PESTER-LIST over the EG-27 suites; CR-COMPARE against the P0-T12 artifact (E2 and E4 by design); CR-PESTER-LIST over N2 with the AC-4 and AC-6 patterns of the group; CR-LINES, via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
GROUP: EG-27
GROUP-SUITES: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
EDIT-NOTES:
EDITED tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 :: form=direct probe=yes(Claude), guard findings=0, FORMAT-CLEAN; EP-6 adaptation: the suite drives the wave barrier through the real Test-CodexEpicChildRoutingLaunchAuthority, so the real function is stashed before the baseline null Mock and restored by a Describe-level BeforeAll; no existing line changed
RUN-1 (group CR-PESTER-LIST)
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | Result=Passed
SUITE: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | Passed=11 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
TOTAL: Passed=11 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
RUN-2 (CR-COMPARE; only the group COMPARE lines count)
COMPARE: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | result=EQUAL
COMPARE-EXIT_CODE: 1
RUN-3 (N2 AC-4 and AC-6 patterns for the group)
NAMED: AC-4 tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
N2-EXIT_CODE: 0
LINES: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | 160
LINES-OVER-500: 0
