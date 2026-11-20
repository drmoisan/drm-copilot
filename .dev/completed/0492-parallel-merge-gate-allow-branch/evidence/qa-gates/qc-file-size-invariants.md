# QC — File Size and Structural Invariants

Timestamp: 2026-08-19T08-58

Command: `wc -l < .claude/hooks/enforce-epic-merge-gate.ps1` and `grep` for the dot-source guard and entrypoint.

EXIT_CODE: 0

Output Summary:
- Line count of `.claude/hooks/enforce-epic-merge-gate.ps1`: **408 lines** (< 500 limit): PASS.
- Dot-source guard present: `if ($MyInvocation.InvocationName -eq '.') {` at line 395: PASS.
- Entrypoint present: `Invoke-EpicMergeGateDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT` at line 400, terminal `exit 0` at line 408: PASS.
- The injectable read-seam function pattern is retained and extended with `Get-ParallelOrchestratorCheckpointContent` (AC6).

Verdict: PASS. File remains under 500 lines and retains both the dot-source guard and the host-bound entrypoint.
