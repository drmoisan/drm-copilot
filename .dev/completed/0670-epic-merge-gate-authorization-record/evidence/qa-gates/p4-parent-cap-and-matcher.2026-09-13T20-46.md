# Phase 4 Parent Cap and Matcher Invariance — Issue #670

Timestamp: 2026-09-17T08-24
Task: [P4-T3]
Command: @(Get-Content -LiteralPath '.claude/hooks/enforce-epic-merge-gate.ps1').Count ; git status --porcelain -- .claude/hooks/enforce-epic-merge-gate.ps1 ; git diff -U0 origin/epic/worktree-scoped-state-resolution-integration -- .claude/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE: 0

## Line count

`.claude/hooks/enforce-epic-merge-gate.ps1`: 483 (at most 500).

## Porcelain span (verbatim)

```
 M .claude/hooks/enforce-epic-merge-gate.ps1
```

The file is shown as modified, so a zero-intersection result below describes a written change rather than an absent one.

## Hunk headers and old-file ranges

| Hunk header | Old-file range | Intersects 131-175 (`Get-EpicMergeGateCommandPrNumber` body) | Intersects 48-50 (`$script:*CheckpointPath` assignments) |
| --- | --- | --- | --- |
| `@@ -8 +8 @@` | lines 8-8 | no | no |
| `@@ -22,6 +22,13 @@` | lines 22-27 | no | no |
| `@@ -37,0 +45,6 @@` | zero-length insertion after line 37 | no | no |
| `@@ -46,0 +60,2 @@` | zero-length insertion after line 46 | no | no |
| `@@ -327,30 +341,0 @@` | lines 327-356 (removed envelope factories plus separator) | no | no |
| `@@ -432,0 +418,11 @@` | zero-length insertion after line 432 (branch-4 block) | no | no |

A zero-length hunk at old position p inserts between lines p and p+1; it would intersect a closed interval [a, b] only if a <= p < b. The insertion points 37, 46 and 432 fall outside both intervals (46 < 48).

Output Summary:
- Line count 483 (at most 500).
- Porcelain shows ` M .claude/hooks/enforce-epic-merge-gate.ps1`.
- Six hunks enumerated; none intersects the closed interval 131 through 175, and none intersects the closed interval 48 through 50. `Get-EpicMergeGateCommandPrNumber` and the three checkpoint path assignments are untouched.
