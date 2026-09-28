# Phase 5 Codex Invariants — Issue #670

Timestamp: 2026-09-17T08-38
Task: [P5-T5]
Command: @(Select-String -LiteralPath '.codex/hooks/enforce-epic-merge-gate.ps1' -SimpleMatch -Pattern 'route_id').Count (and 'items', 'parallel') ; git diff -U0 origin/epic/worktree-scoped-state-resolution-integration -- .codex/hooks/enforce-epic-merge-gate.ps1 ; git status --porcelain -- .codex/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE: 0

## Token counts

| Token | Count |
| --- | --- |
| `route_id` | 0 |
| `items` | 0 |
| `parallel` | 0 |

## Porcelain span (verbatim)

```
 M .codex/hooks/enforce-epic-merge-gate.ps1
```

## Hunk headers and old-file ranges

| Hunk header | Old-file range | Intersects 34-112 | Intersects 167-186 |
| --- | --- | --- | --- |
| `@@ -13,0 +14,8 @@` | zero-length insertion after line 13 (reason-code constants) | no | no |
| `@@ -157,0 +166,18 @@` | zero-length insertion after line 157 (standalone branch inside `Invoke-CodexEpicMergeDecision`) | no | no |
| `@@ -166,0 +193,166 @@` | zero-length insertion after line 166 (Codex standalone predicates) | no | no |

A zero-length hunk at old position p inserts between lines p and p+1 and intersects a closed interval [a, b] only if a <= p < b. Positions 13, 157 and 166 satisfy neither 34 <= p < 112 nor 167 <= p < 186. No existing line of the base revision is modified or removed.

Output Summary:
- `route_id`, `items`, `parallel` each occur 0 times: the Codex hook acquired no parallel allow path (Codex half of AC-34; AC-20).
- Porcelain shows the file as modified.
- Three insertion-only hunks; none intersects 34-112 (`Get-CodexMergeCommandPrNumber`, `Test-CodexChildMergeReady`, `Test-CodexEpicMergeReady`), and none intersects 167-186 (dot-source guard, repository-root anchoring, `exit 2` channel). The `$null` allow representation, the `exit 2` throw channel, the `step9_status` accepted set and the `epic_mode` type test are unchanged.
