# P5 group slot EG-12

Timestamp: 2026-10-09T04-52
Command: Route C: CR-PESTER-LIST over the EG-12 suites; CR-COMPARE against the P0-T12 artifact (E2 and E4 by design); CR-PESTER-LIST over N2 with the AC-4 and AC-6 patterns of the group; CR-LINES, via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
GROUP: EG-12
GROUP-SUITES: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1, tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1, tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1, tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
EDIT-NOTES:
EDITED tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 :: form=direct probe=yes(Claude) orig=141 lines=153 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
EDITED tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 :: form=helper probe=yes(Claude) orig=187 lines=192 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
EDITED tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 :: form=direct probe=yes(Claude) orig=466 lines=485 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
   NOTE: 1 Import-Module -Force command(s) present at lines 424
EDITED tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 :: form=direct probe=yes(Claude) orig=89 lines=101 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
RUN-1 (group CR-PESTER-LIST)
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | Passed=12 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | Passed=41 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | Passed=50 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
TOTAL: Passed=107 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
RUN-2 (CR-COMPARE; only the group COMPARE lines count)
COMPARE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | result=EQUAL
COMPARE-EXIT_CODE: 1
RUN-3 (N2 AC-4 and AC-6 patterns for the group)
NAMED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
N2-EXIT_CODE: 1
LINES: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | 153
LINES: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | 192
LINES: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | 485
LINES: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | 101
LINES-OVER-500: 0
