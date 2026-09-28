# Final QA — PowerShell Analyze (P7-T2)

Timestamp: 2026-09-27T15-43

Iteration: 1

Command: MCP mcp__drm-copilot__run_poshqc_analyze, workspace_root `<worktree root>`, scan_folders ["tests/scripts/claude-lib/blast-radius"]

EXIT_CODE: 0

Output: {"ok":true,"tool":"run_poshqc_analyze","workspace_root":"`<worktree root>`","summary":"Ran bundled PoshQC analyze against '`<worktree root>`' with 1 selected scan folder(s)."}

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/pssa-count.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 0

```
PSSA_FINDINGS=0
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/pssa-count.ps1 -Path tests/scripts/claude-lib/blast-radius

EXIT_CODE: 0

```
PSSA_FINDINGS=0
```

Acceptance evaluation:

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| MCP call | returns | returned, ok true (disposition EXIT_CODE 0) | pass |
| Consumer file findings | PSSA_FINDINGS=0 | PSSA_FINDINGS=0 | pass |
| Folder finding set | subset of the P0-T26 set (empty) | empty | pass |

Output Summary: PASS (iteration 1). PSScriptAnalyzer with the repository settings reports 0 findings for the Pester consumer and 0 findings for the tests/scripts/claude-lib/blast-radius folder, equal to the P0-T26 baseline.
