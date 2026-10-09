# P5 group slot EG-3

Timestamp: 2026-10-09T04-26
Command: Route C: CR-PESTER-LIST over the EG-3 suites; CR-COMPARE against the P0-T12 artifact (E2 and E4 by design); CR-PESTER-LIST over N2 with the AC-4 and AC-6 patterns of the group; CR-LINES, via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
GROUP: EG-3
GROUP-SUITES: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1, tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1, tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1, tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
EDIT-NOTES:
EDITED tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 :: form=direct probe=yes(Claude) orig=170 lines=181 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1
EDITED tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 :: form=direct probe=yes(Claude) orig=297 lines=309 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
EDITED tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 :: form=direct probe=yes(Claude) orig=457 lines=465 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1
EDITED tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 :: form=direct probe=yes(Claude) orig=176 lines=187 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
RUN-1 (group CR-PESTER-LIST)
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | Passed=16 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | Passed=20 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | Passed=57 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | Passed=13 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
TOTAL: Passed=106 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
RUN-2 (CR-COMPARE; only the group COMPARE lines count)
COMPARE: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | result=EQUAL
COMPARE-EXIT_CODE: 1
RUN-3 (N2 AC-4 and AC-6 patterns for the group)
NAMED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
N2-EXIT_CODE: 1
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | 181
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | 309
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | 465
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | 187
LINES-OVER-500: 0
