# R1 CR-5 Verification (Issue #927, decision D-R1-6)

Timestamp: 2026-10-16T07-41
Command: grep -c -E -e 'Get-WorktreeItemCheckpointText|Get-WorktreeItemLiveRoot|Get-WorktreeRunCheckpointText|WorktreeItemResolution|WorktreeRunResolution|Get-ChildOrchestratorCheckpointContent|Get-EpicOrchestratorCheckpointContent|Get-ParallelOrchestratorCheckpointContent|Import-Module' .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/hook-dependency-guard.ps1 .codex/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-heredoc.ps1 .codex/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-payload.ps1 .codex/hooks/hook-command-payload-powershell.ps1 .codex/hooks/hook-command-invocation-operands.ps1 .codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: None of the nine Codex gate closure files contains a Claude worktree-resolution seam name or Import-Module (all counts 0). The Claude-surface probe in suite E is on line 62. CR5_DECISION: REMOVE.

COUNT: .codex/hooks/enforce-epic-merge-gate.ps1:0
COUNT: .codex/hooks/hook-dependency-guard.ps1:0
COUNT: .codex/hooks/hook-command-scanner.ps1:0
COUNT: .codex/hooks/hook-command-heredoc.ps1:0
COUNT: .codex/hooks/hook-command-invocation.ps1:0
COUNT: .codex/hooks/hook-command-payload.ps1:0
COUNT: .codex/hooks/hook-command-payload-powershell.ps1:0
COUNT: .codex/hooks/hook-command-invocation-operands.ps1:0
COUNT: .codex/hooks/hook-docs-only-diff.ps1:0

Command 2: grep -n -F -e "-Surface 'Claude'" tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
EXIT_CODE_2: 0
PROBE_LINE: 62

CR5_DECISION: REMOVE
