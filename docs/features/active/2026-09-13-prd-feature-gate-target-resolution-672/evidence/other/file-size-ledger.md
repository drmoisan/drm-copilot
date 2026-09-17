# File-Size Ledger

This ledger deliberately carries no timestamp in its filename: `[P1-T6]` and `[P4-T20]` both append to it, and two differently timestamped filenames would be two different files. Each block carries its own `Timestamp:` line.

## Phase 1 block — after the helpers extraction, before the behaviour change

Timestamp: 2026-09-17T11-02

Command: `(Get-Content -LiteralPath '<path>').Count`, run from the worktree root through the scratchpad wrapper `sh runps.sh p1verify.ps1`.

| file | measured lines | cap |
| --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 262 | 500 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 203 | 500 |

Both measured counts are at or under the 500-line cap in `.claude/rules/general-code-change.md`. The research record's projection was roughly 266 for the parent and roughly 211 for the sibling; the binding requirement is the measured 500-line cap, not the projection, and both measurements sit close to it.
