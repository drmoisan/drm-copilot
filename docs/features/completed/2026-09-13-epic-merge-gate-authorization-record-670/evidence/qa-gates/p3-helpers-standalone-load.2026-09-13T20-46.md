# Phase 3 Helpers Standalone Load — Issue #670

Timestamp: 2026-09-17T08-18
Task: [P3-T5]
Command: (fresh session) . ./.claude/hooks/enforce-epic-merge-gate-authorization.ps1; Get-Command Test-StandaloneCheckpointAllowsMerge ; @(Get-Content -LiteralPath '.claude/hooks/enforce-epic-merge-gate-authorization.ps1').Count ; @(Select-String -LiteralPath '.claude/hooks/enforce-epic-merge-gate-authorization.ps1' -SimpleMatch -Pattern 'items').Count ; (same with 'route_id')
EXIT_CODE: 0

## Observations (verbatim)

```
Parent loaded before dot-source: False
Parent loaded after dot-source: False
Get-Command resolved: Test-StandaloneCheckpointAllowsMerge (Function)
LINES = 442
COUNT [items] = 0
COUNT [route_id] = 0
```

Output Summary:
- In a session that never loaded the parent hook, `Get-Command Test-StandaloneCheckpointAllowsMerge` resolved without error (Function).
- Line count 442 (at most 500).
- `items` count 0 and `route_id` count 0: the authorization path neither reads nor writes the parallel branch's key and cannot inject a synthetic `items[]` entry (Claude half of AC-34).
