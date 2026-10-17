# P7-T12 Gate parity size and run check

Timestamp: 2026-10-09T05-42
Command: Route C: CR-LINES over N7 and N8 and CR-PESTER-LIST over N7 via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | 206
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1 | 178
LINES-OVER-500: 0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | Passed=85 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=2
TOTAL: Passed=85 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
N7-SEAMS: claude | Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText, Get-EpicScopeCheckpointText
N7-EXTRA-SEAMS: claude | Get-CheckpointContent, Get-EpicCheckpointContent, Get-ParallelCheckpointContent
N7-SEAMS: codex | Get-EpicScopeCheckpointText
N7-EXTRA-SEAMS: codex | Get-CheckpointContent, Get-EpicCheckpointContent, Get-ParallelCheckpointContent, Get-WorktreeResolutionGitFileText
EXIT_CODE_COMPUTED: 0
