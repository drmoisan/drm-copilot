# P5 group slot EG-20

Timestamp: 2026-10-09T05-11
Command: Route C: CR-PESTER-LIST over the EG-20 suites; CR-COMPARE against the P0-T12 artifact (E2 and E4 by design); CR-PESTER-LIST over N2 with the AC-4 and AC-6 patterns of the group; CR-LINES, via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
GROUP: EG-20
GROUP-SUITES: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1, tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1, tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1, tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
EDIT-NOTES:
EDITED tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 :: form=direct probe=no orig=168 lines=169 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
EDITED tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 :: form=direct probe=no orig=344 lines=348 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
EDITED tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 :: form=helper probe=yes(Claude), guard findings=0, FORMAT-CLEAN; the suite dot-sources no hook, so the baseline helper dot-source is the anchor of the guard and the seams are registered after it (hook-local seams guarded by Get-Command)
EDITED tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 :: form=direct probe=no, guard findings=0, FORMAT-CLEAN; EP-6 adaptation: the Test-EpicPlanningBashAllowed Context calls the real function, so it is stashed before the baseline null Mock and restored by a Context-level Mock; no existing line changed
RUN-1 (group CR-PESTER-LIST)
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | Result=Passed
SUITE: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | Passed=9 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | Passed=12 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | Passed=11 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | Passed=10 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
TOTAL: Passed=42 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
RUN-2 (CR-COMPARE; only the group COMPARE lines count)
COMPARE: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | result=EQUAL
COMPARE-EXIT_CODE: 1
RUN-3 (N2 AC-4 and AC-6 patterns for the group)
NAMED: AC-4 tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 * | Passed=0 | Failed=0 | Total=0
NAMED: AC-4 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 * | Passed=0 | Failed=0 | Total=0
NAMED: AC-4 tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 * | Passed=0 | Failed=0 | Total=0
N2-EXIT_CODE: 1
LINES: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | 169
LINES: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 348
LINES: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | 197
LINES: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | 150
LINES-OVER-500: 0
