# SubagentStop Registration Decision — Issue #440 (F7)

Timestamp: 2026-08-08T22-24

Task: [P4-T3]

Command: `git diff .claude/settings.json`

EXIT_CODE: 0

## Decision

**ADD THE MATCHER.** The task's authorized skip branch does NOT apply.

The skip branch (`SKIP AUTHORIZED: F5 registered the parallel-orchestrator SubagentStop matcher`) was
evaluated and rejected, because the precondition it requires — an F5-registered `parallel-orchestrator`
`SubagentStop` matcher — is not present.

## Provenance (P0-T10 / P0-T11 evidence reference)

| Source | Finding |
| --- | --- |
| `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/upstream-contract-verification.2026-08-08T21-09.md` | U16 row: PASS with the observation that `.claude/settings.json` contains no `parallel-orchestrator` or `parallel-planner` occurrence anywhere in the file. |
| `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/frozen-constants.2026-08-08T21-09.md`, Frozen Constant 3 | "Decision: ADD the matcher. The authorized skip branch does NOT apply." |

Pre-edit state of the `SubagentStop` array (`.claude/settings.json` lines 191-250) held six matcher
blocks — the multi-persona alternation, `feature-review`, `atomic-planner`, `pr-author`,
`orchestrator`, and `epic-orchestrator` — none of which names a parallel persona.

## Applied Change

One new matcher block appended after the existing `epic-orchestrator` block, copying that block's
parameterized form:

```json
{
  "matcher": "parallel-orchestrator",
  "hooks": [
    {
      "type": "command",
      "command": "pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state"
    }
  ]
}
```

`-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json` is the U1-verified parallel
checkpoint path. `-ArtifactType parallel-orchestrator-state` is the U11-verified CLI/MCP artifact type.

## Scope Limits Honoured

- The first `SubagentStop` matcher's alternation regex (pre-edit line 193) was NOT extended. Frozen
  Constant 3 records that extending it is outside this plan.
- No existing matcher block, hook entry, or ordering was modified. `git diff --stat` reports
  `1 file changed, 17 insertions(+)` with zero deletions across all three Phase 4 settings edits
  (P4-T1, P4-T2, P4-T3).

## Output Summary

Decision recorded: ADD. The authorized skip branch does not apply, because neither
`parallel-orchestrator` nor `parallel-planner` appears anywhere in `.claude/settings.json` pre-edit,
as verified by the P0-T10 U16 row and frozen at P0-T11 (Frozen Constant 3). A single
`SubagentStop` matcher block for `parallel-orchestrator` was appended after the `epic-orchestrator`
block, invoking `.claude/hooks/validate-orchestrator-output.ps1` with
`-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state`.
The first matcher's persona alternation regex was deliberately left unchanged per the frozen scope
limit. `git diff` of `.claude/settings.json` shows 17 insertions and 0 deletions, confirming no
existing entry was modified or reordered.
