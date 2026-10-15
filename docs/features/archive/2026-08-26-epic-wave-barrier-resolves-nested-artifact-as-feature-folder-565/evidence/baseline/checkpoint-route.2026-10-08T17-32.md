# Baseline Checkpoint Route

Timestamp: 2026-10-08T17-32
Command: if (Test-Path -LiteralPath artifacts/orchestration/orchestrator-state.json -PathType Leaf) { $c = Get-Content -Raw -LiteralPath artifacts/orchestration/orchestrator-state.json | ConvertFrom-Json; 'route_id=' + $c.route_id + ' path_selected=' + $c.path_selected + ' next_step=' + $c.next_step } else { 'CHECKPOINT ABSENT' }
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P0-T9.ps1
EXIT_CODE: 0
Output Summary: route_id=large path_selected=large next_step=S5_atomic_execution

The checkpoint is present with route `large`, so the batch-budget large-route exemption is expected to apply. The RESET schedule is followed regardless.
