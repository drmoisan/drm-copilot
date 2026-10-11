# Batch-Budget Probe ([P0-T13])

Timestamp: 2026-10-09T22-08
Command: sh <SCRATCHPAD>/r.sh p0t13 (Select-String -SimpleMatch -Pattern 'powershell-batch-budget.' and -Pattern '[int] $ProdCap = 3' over .claude/hooks/enforce-powershell-batch-budget.ps1; listing of .claude/state/powershell-batch-budget.*; route_id and path_selected of artifacts/orchestration/orchestrator-state.json)
EXIT_CODE: 0
Output Summary: 'powershell-batch-budget.' matches at lines 11 and 382; '[int] $ProdCap = 3' matches at line 330; no batch-budget state file present; orchestrator-state route_id large, path_selected large.

Output:

```text
## powershell-batch-budget. matches
MATCH: line 11 | The running set is persisted under .claude/state/powershell-batch-budget.<session_id>.json,
MATCH: line 382 | $stateFile = Join-Path -Path $stateDir -ChildPath ("powershell-batch-budget.$resolvedSessionId.json")
## [int] $ProdCap = 3 matches
MATCH: line 330 | [int] $ProdCap = 3,
## .claude/state listing
STATE: none
## orchestrator-state
route_id: large
path_selected: large
```
