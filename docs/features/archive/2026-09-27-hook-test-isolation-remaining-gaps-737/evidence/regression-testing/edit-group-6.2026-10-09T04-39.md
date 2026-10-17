# P5 group slot EG-6

Timestamp: 2026-10-09T04-39
Command: Route C: CR-PESTER-LIST over the EG-6 suites; CR-COMPARE against the P0-T12 artifact (E2 and E4 by design); CR-PESTER-LIST over N2 with the AC-4 and AC-6 patterns of the group; CR-LINES, via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
GROUP: EG-6
GROUP-SUITES: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1, tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1, tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1, tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1
EDIT-NOTES:
EDITED tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 :: form=direct probe=yes(Claude) orig=163 lines=176 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
EDITED tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 :: form=direct probe=yes(Claude) orig=152 lines=162 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1
EDITED tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 :: form=direct probe=yes(Claude), guard findings=0, FORMAT-CLEAN; EP-6 adaptation: the suite tests the real Get-ModelRoutingCheckpoint file seam, so a line that stashes the real function before the baseline null Mock and a Context-level Mock of that seam with the stashed body were added; no existing line changed
EDITED tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 :: form=direct probe=yes(Claude), guard findings=0, FORMAT-CLEAN; EP-6 adaptation: rows read committed fixture checkpoints through the real item and model-routing readers, so the baseline null Mocks of Get-WorktreeItemCheckpointText and Get-ModelRoutingCheckpoint carry a ParameterFilter that excludes the committed fixtures root (the model-routing filter also excludes synthetic roots and the capture root); no existing line changed
RUN-1 (group CR-PESTER-LIST)
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | Passed=7 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | Passed=5 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | Passed=16 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | Passed=21 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
TOTAL: Passed=49 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
RUN-2 (CR-COMPARE; only the group COMPARE lines count)
COMPARE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | result=EQUAL
COMPARE-EXIT_CODE: 1
RUN-3 (N2 AC-4 and AC-6 patterns for the group)
NAMED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
N2-EXIT_CODE: 1
LINES: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 176
LINES: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | 162
LINES: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | 161
LINES: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | 404
LINES-OVER-500: 0
